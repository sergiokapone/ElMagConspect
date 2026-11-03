"""
Бетатрон: наростання поля, розгін і вивід електрона на мішень.
Запуск: python betatron_sim.py  (відкриється вікно з анімацією).
Клавіші: пробіл --- пауза, R --- спочатку, стрілки вгору/вниз --- швидкість показу.

Модель (SI, площина орбіти z=0):
  B_z(r,t) = b(t) * beta(r) * (1 - eps(t)),   b(t) = B_max sin(omega t),
  beta(r)  = (r0/r)^n,  n = 0.5  (радіальна стійкість: 0 < n < 1),
  потік Phi(r,t) = b(t) * phi(r),  phi(r0) = 2*pi*r0^2  (умова B_bar = 2 B_orb),
  вихрове поле E_phi = -(1/(2 pi r)) dPhi/dt.
Рух: релятивістський, dp/dt = q (E + v x B), q = -e.
Вивід: у момент, коли B майже максимальне, коротким імпульсом додаткового
струму ослаблюють поле на (1-eps): рівноважний радіус зростає, електрон
виходить на мішень.

УВАГА щодо масштабу часу: реальні 50 Гц дають ~10^6 обертів за чверть періоду.
Щоб порахувати це за секунди, тут взято f = 100 кГц (~500 обертів);
фізика та сама, але приріст енергії за оберт більший (десятки кеВ).
Вертикальний рух (вісь z) не моделюється.
"""
import math
import numpy as np
import time
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.patches import Wedge, Circle, Rectangle

# ------------------------- ПАРАМЕТРИ -------------------------
c = 2.99792458e8          # м/с
e = 1.602176634e-19       # Кл
m = 9.1093837e-31         # кг
mc2_MeV = 0.51099895      # МеВ

r0 = 0.25                 # радіус рівноважної орбіти, м
B_max = 0.40              # амплітуда поля на орбіті, Тл
f = 100e3                 # частота живлення, Гц (див. примітку вище)
n_idx = 0.5               # показник спаду поля B ~ r^-n
W_inj_keV = 50.0          # енергія інжекції, кеВ
delta_inj = 0.04          # початкове радіальне відхилення (бетатронні коливання)

# вивід пучка
phase_ext = math.pi / 2 - 0.03   # фаза omega*t, коли вмикають імпульс виводу
eps_max = 0.10                    # відносне ослаблення поля імпульсом
tau_ext_turns = 12                # тривалість наростання імпульсу, обертів
r_target = 1.12 * r0              # внутрішній радіус мішені
r_wall = 1.30 * r0                # стінка камери
target_half_angle = math.radians(12)

steps_per_turn = 100
omega = 2 * math.pi * f
T_rev = 2 * math.pi * r0 / c
dt = T_rev / steps_per_turn
tau_ext = tau_ext_turns * T_rev


# ------------------------- ФІЗИКА -------------------------
def b_of_t(t):
    return B_max * math.sin(omega * t)

def db_dt(t):
    return B_max * omega * math.cos(omega * t)

def beta(r):
    return (r0 / max(r, 0.2 * r0)) ** n_idx

def phi_flux(r):
    """потік на одиницю b(t): phi(r0)=2*pi*r0^2, далі інтеграл від B(r)."""
    r = max(r, 0.2 * r0)
    return 2 * math.pi * r0**2 + 2 * math.pi * r0**n_idx * (
        r ** (2 - n_idx) - r0 ** (2 - n_idx)) / (2 - n_idx)

def smoothstep(x):
    x = min(max(x, 0.0), 1.0)
    return x * x * (3 - 2 * x)

def eps_of_t(t, t_ext):
    return eps_max * smoothstep((t - t_ext) / tau_ext)

def deriv(s, t, t_ext):
    x, y, px, py = s
    r = math.hypot(x, y)
    p2 = px * px + py * py
    gam = math.sqrt(1 + p2 / (m * c) ** 2)
    vx, vy = px / (gam * m), py / (gam * m)
    Bz = b_of_t(t) * beta(r) * (1 - eps_of_t(t, t_ext))
    Eph = -db_dt(t) * phi_flux(r) / (2 * math.pi * r)
    Ex = Eph * (-y / r)      # E_phi * (-y/r, x/r)
    Ey = Eph * (x / r)
    q = -e
    Fx = q * (Ex + vy * Bz)
    Fy = q * (Ey - vx * Bz)
    return (vx, vy, Fx, Fy)

def rk4(s, t, h, t_ext):
    k1 = deriv(s, t, t_ext)
    s2 = [s[i] + 0.5 * h * k1[i] for i in range(4)]
    k2 = deriv(s2, t + 0.5 * h, t_ext)
    s3 = [s[i] + 0.5 * h * k2[i] for i in range(4)]
    k3 = deriv(s3, t + 0.5 * h, t_ext)
    s4 = [s[i] + h * k3[i] for i in range(4)]
    k4 = deriv(s4, t + h, t_ext)
    return [s[i] + h / 6 * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]) for i in range(4)]


def simulate():
    # інжекція: імпульс, що відповідає колу радіуса r0 у полі b_inj
    T_inj = W_inj_keV * 1e-3
    pc_inj = math.sqrt(T_inj**2 + 2 * T_inj * mc2_MeV)          # МеВ
    p_inj = pc_inj * 1e6 * e / c
    b_inj = p_inj / (e * r0)
    t = math.asin(b_inj / B_max) / omega
    t_ext = phase_ext / omega

    # старт на куті 180°, рух проти годинникової стрілки (φ̂ = (0,-1))
    s = [-r0 * (1 + delta_inj), 0.0, 0.0, -p_inj]

    ts, xs, ys, Ws, Bs, rs, eps_hist = [], [], [], [], [], [], []
    hit = None
    max_steps = int(2.0 * (math.pi / 2 / omega) / dt) + 40 * steps_per_turn
    for _ in range(max_steps):
        x, y, px, py = s
        r = math.hypot(x, y)
        gam = math.sqrt(1 + (px * px + py * py) / (m * c) ** 2)
        ts.append(t); xs.append(x); ys.append(y); rs.append(r)
        Ws.append((gam - 1) * mc2_MeV)
        Bs.append(b_of_t(t))
        eps_hist.append(eps_of_t(t, t_ext))

        theta = math.atan2(y, x)
        if t > t_ext and r > r_target and abs(theta) < target_half_angle:
            hit = "мішень"; break
        if r > r_wall:
            hit = "стінка"; break
        s = rk4(s, t, dt, t_ext)
        t += dt

    return (np.array(ts), np.array(xs), np.array(ys), np.array(Ws),
            np.array(Bs), np.array(rs), np.array(eps_hist), t_ext, hit)


# ------------------------- ПОКАЗ В РЕАЛЬНОМУ ЧАСІ -------------------------
# Швидкість показу задається в ОБЕРТАХ НА СЕКУНДУ ЕКРАННОГО ЧАСУ і рахується
# за годинником, тому не залежить від швидкості комп'ютера та кількості кадрів.
# Це лише швидкість ПОКАЗУ: електрон не гальмує (див. v/c на екрані).
V_SLOW = 0.5     # на початку: електрон обертається повільно, видно коливання
V_FAST = 50.0    # середній відрізок розгону (покадрове «прискорення» часу)
V_END = 0.8      # під час виводу: знову повільно, видно, як електрон виходить
RAMP_UP = (2, 12)        # (обертів до початку розгону показу, тривалість виходу на V_FAST)
RAMP_DOWN_TURNS = 25     # за скільки обертів до виводу плавно сповільнюємось
PRE_DUR = 2.5            # с: показ інжекції (електрон влітає з інжектора)
INJ_Y = 0.55 * r0        # звідки стартує електрон при інжекції
WAVE_LMAX = 0.5 * r0 * 1.0 + 0.3   # довжина «хвильки» випромінювання, м (схематично)


def smooth(x):
    x = min(max(x, 0.0), 1.0)
    return x * x * (3 - 2 * x)


def v_over_c(W_MeV):
    g = 1 + W_MeV / mc2_MeV
    return math.sqrt(1 - 1 / (g * g))


class Player:
    def __init__(self, data):
        (self.ts, self.xs, self.ys, self.Ws, self.Bs, self.rs,
         self.epsh, self.t_ext, self.hit) = data
        self.N = len(self.ts)
        self.i_ext = int(np.searchsorted(self.ts, self.t_ext))
        self.ext_turn = self.i_ext / steps_per_turn
        t_us = self.ts * 1e6
        self.t_us = t_us
        # напрямок вильоту випромінювання = напрямок швидкості в момент влучання
        dx, dy = self.xs[-1] - self.xs[-2], self.ys[-1] - self.ys[-2]
        nrm = math.hypot(dx, dy)
        self.dir = (dx / nrm, dy / nrm)

        self.fig = plt.figure(figsize=(11, 6.2))
        self.fig.canvas.manager.set_window_title("Бетатрон")
        gs = self.fig.add_gridspec(2, 2, width_ratios=[1.15, 1], hspace=0.38, wspace=0.28)
        ax = self.fig.add_subplot(gs[:, 0])
        axB = self.fig.add_subplot(gs[0, 1])
        axR = self.fig.add_subplot(gs[1, 1])

        lim = 2.0 * r0
        ax.set_xlim(-lim, lim); ax.set_ylim(-lim, lim); ax.set_aspect("equal")
        ax.set_title("Вид зверху (площина орбіти)")
        ax.add_patch(Circle((0, 0), r_wall, fill=False, ec="k", lw=1.5))
        ax.add_patch(Circle((0, 0), 0.6 * r0, fill=False, ec="gray", lw=1))
        ax.add_patch(Circle((0, 0), r0, fill=False, ec="gray", ls="--", lw=0.8))
        ax.add_patch(Wedge((0, 0), r_wall, -math.degrees(target_half_angle),
                           math.degrees(target_half_angle), width=r_wall - r_target,
                           fc="gold", ec="k", alpha=0.9))
        ax.text(r_wall * 1.01, -0.06, "мішень", va="top", ha="left", fontsize=9)
        ax.text(0, 0, "вісь", ha="center", va="center", fontsize=8, color="gray")
        # інжектор
        x_inj = -r0 * (1 + delta_inj)
        ax.add_patch(Rectangle((x_inj - 0.02, INJ_Y + 0.01), 0.04, 0.07,
                               fc="0.6", ec="k"))
        ax.text(x_inj - 0.04, INJ_Y + 0.045, "інжектор", ha="right", va="center", fontsize=9)

        self.trail, = ax.plot([], [], "-", color="tab:red", lw=1.2)
        self.dot, = ax.plot([], [], "o", color="red", ms=8)
        self.flash, = ax.plot([], [], "*", color="orange", mec="red", ms=0)
        self.waves = [ax.plot([], [], "-", color="purple", lw=1.6)[0] for _ in range(5)]
        self.ph_txt = ax.text(0.98, 0.03, "", transform=ax.transAxes, color="purple",
                              fontsize=10, ha="right", va="bottom")
        self.info = ax.text(0.02, 0.97, "", transform=ax.transAxes, va="top",
                            fontsize=10, family="monospace",
                            bbox=dict(fc="white", ec="0.7", alpha=0.9))
        ax.set_xticks([]); ax.set_yticks([])

        tt = np.linspace(self.ts[0], self.ts[-1], 400)
        axB.plot(tt * 1e6, B_max * np.sin(omega * tt), "b-")
        axB.axvspan(t_us[0], self.t_ext * 1e6, color="tab:green", alpha=0.12, label="розгін")
        axB.axvspan(self.t_ext * 1e6, t_us[-1], color="tab:orange", alpha=0.25, label="вивід")
        axB.set_xlim(t_us[0], t_us[-1] * 1.0001)
        axB.set_ylabel(r"$B_\mathrm{орб}$, Тл"); axB.set_xlabel("t, мкс")
        axB.legend(loc="lower right", fontsize=8)
        axB.set_title(r"Поле на орбіті, чверть періоду ($T/4$)")
        self.mB, = axB.plot([], [], "ro")

        axR.plot(t_us, self.rs / r0, color="tab:red", lw=0.8)
        axR.axhline(1.0, color="gray", ls="--", lw=0.8)
        axR.axhline(r_target / r0, color="goldenrod", ls=":", lw=1)
        axR.axvline(self.t_ext * 1e6, color="tab:orange", lw=0.8)
        axR.set_xlim(t_us[0], t_us[-1] * 1.0001)
        axR.set_ylabel(r"$r/r_0$"); axR.set_xlabel("t, мкс")
        axR.set_title("Радіус: бетатронні коливання, потім вивід")
        self.mR, = axR.plot([], [], "ro")

        self.fig.canvas.mpl_connect("key_press_event", self.on_key)
        self.reset()

    # ---- керування
    def reset(self):
        self.fi = 0.0
        self.pre = 0.0
        self.hit_time = None
        self.mult = 1.0
        self.paused = False
        self.last = time.perf_counter()

    def on_key(self, ev):
        if ev.key == " ":
            self.paused = not self.paused
            self.last = time.perf_counter()
        elif ev.key in ("r", "R", "к", "К"):
            self.reset()
        elif ev.key == "up":
            self.mult *= 1.5
        elif ev.key == "down":
            self.mult /= 1.5

    # ---- швидкість показу, обертів/с екранного часу
    def speed(self, turns):
        w_up = smooth((turns - RAMP_UP[0]) / RAMP_UP[1])
        w_dn = smooth((turns - (self.ext_turn - RAMP_DOWN_TURNS)) / RAMP_DOWN_TURNS)
        lv = math.log(V_SLOW) + (math.log(V_FAST) - math.log(V_SLOW)) * w_up
        lv += (math.log(V_END) - lv) * w_dn
        return math.exp(lv) * self.mult

    def advance(self, dt):
        if self.paused:
            return
        if self.pre < PRE_DUR:
            self.pre += dt * self.mult
            return
        if self.fi >= self.N - 1:
            return
        v = self.speed(self.fi / steps_per_turn)
        self.fi = min(self.fi + v * steps_per_turn * dt, self.N - 1)

    # ---- випромінювання: віяло хвильок, що летять уздовж напрямку електрона
    def draw_waves(self, tau):
        px, py = self.xs[-1], self.ys[-1]
        dx, dy = self.dir
        nx, ny = -dy, dx
        L = min(WAVE_LMAX, 0.35 * tau * 1.0 + 0.0) if tau > 0 else 0.0
        lam, amp = 0.06, 0.014
        for k, ang in enumerate((-0.30, -0.15, 0.0, 0.15, 0.30)):
            ca, sa = math.cos(ang), math.sin(ang)
            ddx, ddy = dx * ca - dy * sa, dx * sa + dy * ca
            nnx, nny = -ddy, ddx
            sgrid = np.linspace(0, L, 120)
            ph = 2 * math.pi * (sgrid / lam - 2.0 * tau)
            env = np.minimum(1.0, sgrid / 0.05)
            off = amp * env * np.sin(ph)
            self.waves[k].set_data(px + sgrid * ddx + off * nnx,
                                   py + sgrid * ddy + off * nny)
        self.ph_txt.set_text("гальмівне випромінювання (γ)" if L > 0.08 else "")
        # спалах на мішені
        pulse = max(0.0, 1.0 - tau / 0.6)
        self.flash.set_data([px], [py])
        self.flash.set_markersize(26 * pulse)

    def hide_waves(self):
        for w in self.waves:
            w.set_data([], [])
        self.ph_txt.set_text("")
        self.flash.set_markersize(0)

    # ---- малювання
    def draw(self):
        if self.pre < PRE_DUR:                      # --- інжекція
            k = self.pre / PRE_DUR
            x0 = self.xs[0]
            y = INJ_Y * (1 - k)
            self.trail.set_data([x0, x0], [INJ_Y, y])
            self.dot.set_data([x0], [y])
            self.hide_waves()
            self.mB.set_data([self.t_us[0]], [self.Bs[0]])
            self.mR.set_data([self.t_us[0]], [self.rs[0] / r0])
            self.info.set_text(f"ІНЖЕКЦІЯ\nW = {self.Ws[0]*1e3:5.0f} кеВ  v/c = {v_over_c(self.Ws[0]):.2f}\n"
                               f"B_орб = {self.Bs[0]*1e3:.1f} мТл (майже 0)")
            return
        fi = self.fi
        i0 = int(fi)
        i1 = min(i0 + 1, self.N - 1)
        fr = fi - i0
        x = self.xs[i0] + (self.xs[i1] - self.xs[i0]) * fr
        y = self.ys[i0] + (self.ys[i1] - self.ys[i0]) * fr
        a = max(0, i0 - steps_per_turn)
        self.trail.set_data(np.append(self.xs[a:i0 + 1], x), np.append(self.ys[a:i0 + 1], y))
        tu = self.t_us[i0] + (self.t_us[i1] - self.t_us[i0]) * fr
        self.mB.set_data([tu], [self.Bs[i0]])
        self.mR.set_data([tu], [self.rs[i0] / r0])
        turns = fi / steps_per_turn
        W = self.Ws[i0]
        finished = fi >= self.N - 1
        if finished:
            if self.hit_time is None:
                self.hit_time = time.perf_counter()
            self.dot.set_data([], [])
            self.draw_waves(time.perf_counter() - self.hit_time)
            stage, mode = f"ВИВІД НА {self.hit.upper()}", ""
        else:
            self.dot.set_data([x], [y])
            self.hide_waves()
            stage = "розгін" if i0 < self.i_ext else "вивід"
            v = self.speed(turns)
            mode = ("сповільнений показ" if v < 3 else "прискорений показ") + f" ({v:.1f} об/с)"
        self.info.set_text(f"{stage}\nW = {W:6.2f} МеВ\nv/c = {v_over_c(W):.4f}\n"
                           f"оберт {turns:5.1f}\n{mode}")

    def update(self, _frame):
        now = time.perf_counter()
        dt = min(now - self.last, 0.1)
        self.last = now
        self.advance(dt)
        self.draw()
        return (self.trail, self.dot, self.mB, self.mR, self.info, self.flash,
                self.ph_txt, *self.waves)


if __name__ == "__main__":
    data = simulate()
    ts, Ws, hit = data[0], data[3], data[-1]
    print(f"обертів: {len(ts)/steps_per_turn:.0f}, енергія при виводі: "
          f"{Ws[int(np.searchsorted(ts, data[7]))]:.1f} МеВ, кінець: {hit}")
    player = Player(data)
    anim = FuncAnimation(player.fig, player.update, interval=16,
                         blit=False, cache_frame_data=False)
    plt.show()

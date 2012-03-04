"""As SIRV1.py, but animating the effect of varying p."""

def f(u, t, beta, nu, p):
    S, I, R, V = u
    return [-beta*S*I - p(t)*S,
            beta*S*I - nu*I,
            nu*I,
            p(t)*S]

import odesolvers
import numpy as np
import sys, time
import matplotlib.pyplot as mpl

def simulate(beta, nu, p, S0, I0, frame_counter=0, mpl_lines=None):
    method = odesolvers.Euler(f, f_args=(beta, nu, p))
    method.set_initial_condition([S0, I0, 0, 0])
    dt = 0.5  # t counts days
    T = 60
    N = int(T/dt)
    t = np.linspace(0, T, N+1)
    u, t = method.solve(t)
    S, I, R, V = u[:,0], u[:,1], u[:,2], u[:,3]

    if mpl_lines is None:
        mpl_lines = mpl.plot(t, S, 'r-',
                             t, I, 'b-',
                             t, R, 'g-',
                             t, V, 'y-')
    else:
        for line, func in zip(mpl_lines, [S, I, R, V]):
            line.set_ydata(func)
        mpl.draw()
    mpl.legend(['S', 'I', 'R', 'V'])
    mpl.title('beta=%.4f, nu=%.1f, p=%.2f' % (beta, nu, p(T)))
    mpl.savefig('tmp_%04d.png' % frame_counter)
    frame_counter += 1
    time.sleep(1)
    return frame_counter, mpl_lines

# beta = 0.0005; nu = 0.1; I0 = 1; p = 0.1
I0   = 1
S0 = 1500.
beta = 0.0005
nu = 0.1
p = 0.1
mpl_lines = None
frame_counter = 0
mpl.ion() # key
p_list = np.logspace(0.000001, 0.3, 12)
for p in p_list:
    frame_counter, mpl_lines = \
       simulate(beta, nu, lambda t: np.log10(p) if t > 8 else 0,
                S0, I0, frame_counter, mpl_lines)
#mpl.show()

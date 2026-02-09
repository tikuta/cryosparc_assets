#!/usr/bin/env python3
import numpy as np

if __name__ == '__main__':
    cs = np.load("P38_S1_all_live_exposures.cs")
    for i in range(len(cs)):
        for j in range(len(cs[i])):
            if isinstance(cs[i][j], bytes) and b'S1' in cs[i][j]:
                cs[i][j] = cs[i][j].replace(b'S1', b'S2')
    with open("P38_S2_all_live_exposures.cs", 'wb') as f:
        np.save(f, cs)


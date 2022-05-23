#!/usr/bin/env python


# tess_lk2
#
# fetch TESS lightcurves for selected objects
# from TESS QPL or SPOC pipeline ffi extractions

# usage:
    # > tess_lk2.py
    # 

# bugs:
    # if multiple records for a single sector (eg high cadence + FFI) 
    # both data and plot files are overwritten. 

import sys

import lightkurve as lk
import numpy as np
import matplotlib.pyplot as plt

from lightkurve import search_lightcurve

testing_list = """
PG 1248+066
"""

gaia_objs = """
GAIA DR2 6157882048944683776
GAIA DR2 6162393443937250816
GAIA DR2 6172519950324719360
GAIA DR2 6122193344616725376
GAIA DR2 6121001577091666688
GAIA DR2 5603285806919711360
GAIA DR2 4794394824848838144
GAIA DR2 4794330984455278592
GAIA DR2 4792421648153876864
GAIA DR2 5482955799829681792
GAIA DR2 5603285806919711360
GAIA DR2 5606816922873376384
GAIA DR2 5606816922873377280
GAIA DR2 5606816922877511424
GAIA DR2 5606816922877511552
GAIA DR2 5614913348547819392
GAIA DR2 3087687074686316416
GAIA DR2 3081515859516630784
GAIA DR2 3068776574200806912
GAIA DR2 5544508148687474688
GAIA DR2 3072666989934119040
GAIA DR2 5258974457944841344
GAIA DR2 5258974462239566208
GAIA DR2 6083566848303076224
GAIA DR2 6164003820450910720
GAIA DR2 5910655996154552704
GAIA DR2 5912980535531070080
GAIA DR2 6709289123148723712
GAIA DR2 6708316944410790144
GAIA DR2 6711987633911959808
GAIA DR2 6711987633914083840
GAIA DR2 6711987633914863488
GAIA DR2 4180566169150316800
GAIA DR2 6660524786016586112
GAIA DR2 6901338860658392192
"""

done = """
BD -12 134A
BD +37 1977
BD +37 442
BPS CS 22885-0043
BPS CS 22956-0094
BPS CS 29517-0049
CW83 0512-08
CW83 0832-01
CW83 0904-02
EC 01339-6730
EC 02512-7246
EC 02527-7111
EC 04013-4017
EC 04271-2909
NGC 246
EC 10475-2703
EC 05048-2516
EC 05063-1455
EC 05160-3050
"""

not_found = """
2M 0420+0120
2M 0117+4932
2M 0450+6711
2M 1832+1734
BPS CS 22893-0020
EC 00468-5440
EC 01086-5138
EC 13150-2832
EC 14316-1908
"""

not_working = """
BD +39 3226 - corrupt?
BD +75 325 - corrupt?
CD -24 9052 - corrupt?
"""

search_list = testing_list

for target in search_list.strip().split("\n"):
    print(f"Searching {target}")
    for result in lk.search_lightcurve(target):
        lc = result.download().remove_outliers()
        try:
            print(f"Found in sector {lc.sector}")
        except AttributeError:
            print('lc.sector missing! Assigning 0 for now')
            lc.sector = 0
        label = f"{target} in Sector {lc.sector} ({lc.origin} pipeline)"
        lc.plot(label=label).figure.savefig(f"./lk2/{target.replace(' ','_')}_Sector_{str(lc.sector).zfill(2)}.png")
        # Save the light curve into e.g. CSV format as follows:
        lc.write(f"./lk2/{target.replace(' ','_')}_Sector_{str(lc.sector).zfill(2)}.csv", format="ascii.csv", overwrite=True)
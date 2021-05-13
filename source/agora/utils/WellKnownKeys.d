/*******************************************************************************

    The list of well-known keypairs

    This module should not be imported directly.
    Instead use `agora.utils.Test : WK.Keys`.
    It is solely here to host all well-known keys in a separate, single file,
    as they are stored as array of `ubyte` to speed-up compilation.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.WellKnownKeys;

import agora.crypto.Key;
import agora.crypto.ECC: Scalar, Point;

// Can't do this because then `public import` is useless
//package:

/// Returns: The keypair at index `index`. Pre-generated like the keys.
package KeyPair wellKnownKeyByIndex (size_t index) @safe pure nothrow @nogc
{
    // Uncomment me to update
    version (none)
    {
        // This will not link but it doesn't matter, the message is output at CT
        import agora.cli.vanity.main;
        import std.string : toUpper;

        pragma(msg, "========================================");
        static foreach (idx; 0 .. KeyCountTarget)
            pragma(msg, "    case ", int(idx), ": return ", indexName(idx).toUpper, ";");
        pragma(msg, "========================================");
    }

    switch (index)
    {
    case 0: return A;
    case 1: return C;
    case 2: return D;
    case 3: return E;
    case 4: return F;
    case 5: return G;
    case 6: return H;
    case 7: return J;
    case 8: return K;
    case 9: return L;
    case 10: return M;
    case 11: return N;
    case 12: return P;
    case 13: return Q;
    case 14: return R;
    case 15: return S;
    case 16: return T;
    case 17: return U;
    case 18: return V;
    case 19: return W;
    case 20: return X;
    case 21: return Y;
    case 22: return Z;
    case 23: return AA;
    case 24: return AC;
    case 25: return AD;
    case 26: return AE;
    case 27: return AF;
    case 28: return AG;
    case 29: return AH;
    case 30: return AJ;
    case 31: return AK;
    case 32: return AL;
    case 33: return AM;
    case 34: return AN;
    case 35: return AP;
    case 36: return AQ;
    case 37: return AR;
    case 38: return AS;
    case 39: return AT;
    case 40: return AU;
    case 41: return AV;
    case 42: return AW;
    case 43: return AX;
    case 44: return AY;
    case 45: return AZ;
    case 46: return CA;
    case 47: return CC;
    case 48: return CD;
    case 49: return CE;
    case 50: return CF;
    case 51: return CG;
    case 52: return CH;
    case 53: return CJ;
    case 54: return CK;
    case 55: return CL;
    case 56: return CM;
    case 57: return CN;
    case 58: return CP;
    case 59: return CQ;
    case 60: return CR;
    case 61: return CS;
    case 62: return CT;
    case 63: return CU;
    case 64: return CV;
    case 65: return CW;
    case 66: return CX;
    case 67: return CY;
    case 68: return CZ;
    case 69: return DA;
    case 70: return DC;
    case 71: return DD;
    case 72: return DE;
    case 73: return DF;
    case 74: return DG;
    case 75: return DH;
    case 76: return DJ;
    case 77: return DK;
    case 78: return DL;
    case 79: return DM;
    case 80: return DN;
    case 81: return DP;
    case 82: return DQ;
    case 83: return DR;
    case 84: return DS;
    case 85: return DT;
    case 86: return DU;
    case 87: return DV;
    case 88: return DW;
    case 89: return DX;
    case 90: return DY;
    case 91: return DZ;
    case 92: return EA;
    case 93: return EC;
    case 94: return ED;
    case 95: return EE;
    case 96: return EF;
    case 97: return EG;
    case 98: return EH;
    case 99: return EJ;
    case 100: return EK;
    case 101: return EL;
    case 102: return EM;
    case 103: return EN;
    case 104: return EP;
    case 105: return EQ;
    case 106: return ER;
    case 107: return ES;
    case 108: return ET;
    case 109: return EU;
    case 110: return EV;
    case 111: return EW;
    case 112: return EX;
    case 113: return EY;
    case 114: return EZ;
    case 115: return FA;
    case 116: return FC;
    case 117: return FD;
    case 118: return FE;
    case 119: return FF;
    case 120: return FG;
    case 121: return FH;
    case 122: return FJ;
    case 123: return FK;
    case 124: return FL;
    case 125: return FM;
    case 126: return FN;
    case 127: return FP;
    case 128: return FQ;
    case 129: return FR;
    case 130: return FS;
    case 131: return FT;
    case 132: return FU;
    case 133: return FV;
    case 134: return FW;
    case 135: return FX;
    case 136: return FY;
    case 137: return FZ;
    case 138: return GA;
    case 139: return GC;
    case 140: return GD;
    case 141: return GE;
    case 142: return GF;
    case 143: return GG;
    case 144: return GH;
    case 145: return GJ;
    case 146: return GK;
    case 147: return GL;
    case 148: return GM;
    case 149: return GN;
    case 150: return GP;
    case 151: return GQ;
    case 152: return GR;
    case 153: return GS;
    case 154: return GT;
    case 155: return GU;
    case 156: return GV;
    case 157: return GW;
    case 158: return GX;
    case 159: return GY;
    case 160: return GZ;
    case 161: return HA;
    case 162: return HC;
    case 163: return HD;
    case 164: return HE;
    case 165: return HF;
    case 166: return HG;
    case 167: return HH;
    case 168: return HJ;
    case 169: return HK;
    case 170: return HL;
    case 171: return HM;
    case 172: return HN;
    case 173: return HP;
    case 174: return HQ;
    case 175: return HR;
    case 176: return HS;
    case 177: return HT;
    case 178: return HU;
    case 179: return HV;
    case 180: return HW;
    case 181: return HX;
    case 182: return HY;
    case 183: return HZ;
    case 184: return JA;
    case 185: return JC;
    case 186: return JD;
    case 187: return JE;
    case 188: return JF;
    case 189: return JG;
    case 190: return JH;
    case 191: return JJ;
    case 192: return JK;
    case 193: return JL;
    case 194: return JM;
    case 195: return JN;
    case 196: return JP;
    case 197: return JQ;
    case 198: return JR;
    case 199: return JS;
    case 200: return JT;
    case 201: return JU;
    case 202: return JV;
    case 203: return JW;
    case 204: return JX;
    case 205: return JY;
    case 206: return JZ;
    case 207: return KA;
    case 208: return KC;
    case 209: return KD;
    case 210: return KE;
    case 211: return KF;
    case 212: return KG;
    case 213: return KH;
    case 214: return KJ;
    case 215: return KK;
    case 216: return KL;
    case 217: return KM;
    case 218: return KN;
    case 219: return KP;
    case 220: return KQ;
    case 221: return KR;
    case 222: return KS;
    case 223: return KT;
    case 224: return KU;
    case 225: return KV;
    case 226: return KW;
    case 227: return KX;
    case 228: return KY;
    case 229: return KZ;
    case 230: return LA;
    case 231: return LC;
    case 232: return LD;
    case 233: return LE;
    case 234: return LF;
    case 235: return LG;
    case 236: return LH;
    case 237: return LJ;
    case 238: return LK;
    case 239: return LL;
    case 240: return LM;
    case 241: return LN;
    case 242: return LP;
    case 243: return LQ;
    case 244: return LR;
    case 245: return LS;
    case 246: return LT;
    case 247: return LU;
    case 248: return LV;
    case 249: return LW;
    case 250: return LX;
    case 251: return LY;
    case 252: return LZ;
    case 253: return MA;
    case 254: return MC;
    case 255: return MD;
    case 256: return ME;
    case 257: return MF;
    case 258: return MG;
    case 259: return MH;
    case 260: return MJ;
    case 261: return MK;
    case 262: return ML;
    case 263: return MM;
    case 264: return MN;
    case 265: return MP;
    case 266: return MQ;
    case 267: return MR;
    case 268: return MS;
    case 269: return MT;
    case 270: return MU;
    case 271: return MV;
    case 272: return MW;
    case 273: return MX;
    case 274: return MY;
    case 275: return MZ;
    case 276: return NA;
    case 277: return NC;
    case 278: return ND;
    case 279: return NE;
    case 280: return NF;
    case 281: return NG;
    case 282: return NH;
    case 283: return NJ;
    case 284: return NK;
    case 285: return NL;
    case 286: return NM;
    case 287: return NN;
    case 288: return NP;
    case 289: return NQ;
    case 290: return NR;
    case 291: return NS;
    case 292: return NT;
    case 293: return NU;
    case 294: return NV;
    case 295: return NW;
    case 296: return NX;
    case 297: return NY;
    case 298: return NZ;
    case 299: return PA;
    case 300: return PC;
    case 301: return PD;
    case 302: return PE;
    case 303: return PF;
    case 304: return PG;
    case 305: return PH;
    case 306: return PJ;
    case 307: return PK;
    case 308: return PL;
    case 309: return PM;
    case 310: return PN;
    case 311: return PP;
    case 312: return PQ;
    case 313: return PR;
    case 314: return PS;
    case 315: return PT;
    case 316: return PU;
    case 317: return PV;
    case 318: return PW;
    case 319: return PX;
    case 320: return PY;
    case 321: return PZ;
    case 322: return QA;
    case 323: return QC;
    case 324: return QD;
    case 325: return QE;
    case 326: return QF;
    case 327: return QG;
    case 328: return QH;
    case 329: return QJ;
    case 330: return QK;
    case 331: return QL;
    case 332: return QM;
    case 333: return QN;
    case 334: return QP;
    case 335: return QQ;
    case 336: return QR;
    case 337: return QS;
    case 338: return QT;
    case 339: return QU;
    case 340: return QV;
    case 341: return QW;
    case 342: return QX;
    case 343: return QY;
    case 344: return QZ;
    case 345: return RA;
    case 346: return RC;
    case 347: return RD;
    case 348: return RE;
    case 349: return RF;
    case 350: return RG;
    case 351: return RH;
    case 352: return RJ;
    case 353: return RK;
    case 354: return RL;
    case 355: return RM;
    case 356: return RN;
    case 357: return RP;
    case 358: return RQ;
    case 359: return RR;
    case 360: return RS;
    case 361: return RT;
    case 362: return RU;
    case 363: return RV;
    case 364: return RW;
    case 365: return RX;
    case 366: return RY;
    case 367: return RZ;
    case 368: return SA;
    case 369: return SC;
    case 370: return SD;
    case 371: return SE;
    case 372: return SF;
    case 373: return SG;
    case 374: return SH;
    case 375: return SJ;
    case 376: return SK;
    case 377: return SL;
    case 378: return SM;
    case 379: return SN;
    case 380: return SP;
    case 381: return SQ;
    case 382: return SR;
    case 383: return SS;
    case 384: return ST;
    case 385: return SU;
    case 386: return SV;
    case 387: return SW;
    case 388: return SX;
    case 389: return SY;
    case 390: return SZ;
    case 391: return TA;
    case 392: return TC;
    case 393: return TD;
    case 394: return TE;
    case 395: return TF;
    case 396: return TG;
    case 397: return TH;
    case 398: return TJ;
    case 399: return TK;
    case 400: return TL;
    case 401: return TM;
    case 402: return TN;
    case 403: return TP;
    case 404: return TQ;
    case 405: return TR;
    case 406: return TS;
    case 407: return TT;
    case 408: return TU;
    case 409: return TV;
    case 410: return TW;
    case 411: return TX;
    case 412: return TY;
    case 413: return TZ;
    case 414: return UA;
    case 415: return UC;
    case 416: return UD;
    case 417: return UE;
    case 418: return UF;
    case 419: return UG;
    case 420: return UH;
    case 421: return UJ;
    case 422: return UK;
    case 423: return UL;
    case 424: return UM;
    case 425: return UN;
    case 426: return UP;
    case 427: return UQ;
    case 428: return UR;
    case 429: return US;
    case 430: return UT;
    case 431: return UU;
    case 432: return UV;
    case 433: return UW;
    case 434: return UX;
    case 435: return UY;
    case 436: return UZ;
    case 437: return VA;
    case 438: return VC;
    case 439: return VD;
    case 440: return VE;
    case 441: return VF;
    case 442: return VG;
    case 443: return VH;
    case 444: return VJ;
    case 445: return VK;
    case 446: return VL;
    case 447: return VM;
    case 448: return VN;
    case 449: return VP;
    case 450: return VQ;
    case 451: return VR;
    case 452: return VS;
    case 453: return VT;
    case 454: return VU;
    case 455: return VV;
    case 456: return VW;
    case 457: return VX;
    case 458: return VY;
    case 459: return VZ;
    case 460: return WA;
    case 461: return WC;
    case 462: return WD;
    case 463: return WE;
    case 464: return WF;
    case 465: return WG;
    case 466: return WH;
    case 467: return WJ;
    case 468: return WK;
    case 469: return WL;
    case 470: return WM;
    case 471: return WN;
    case 472: return WP;
    case 473: return WQ;
    case 474: return WR;
    case 475: return WS;
    case 476: return WT;
    case 477: return WU;
    case 478: return WV;
    case 479: return WW;
    case 480: return WX;
    case 481: return WY;
    case 482: return WZ;
    case 483: return XA;
    case 484: return XC;
    case 485: return XD;
    case 486: return XE;
    case 487: return XF;
    case 488: return XG;
    case 489: return XH;
    case 490: return XJ;
    case 491: return XK;
    case 492: return XL;
    case 493: return XM;
    case 494: return XN;
    case 495: return XP;
    case 496: return XQ;
    case 497: return XR;
    case 498: return XS;
    case 499: return XT;
    case 500: return XU;
    case 501: return XV;
    case 502: return XW;
    case 503: return XX;
    case 504: return XY;
    case 505: return XZ;
    case 506: return YA;
    case 507: return YC;
    case 508: return YD;
    case 509: return YE;
    case 510: return YF;
    case 511: return YG;
    case 512: return YH;
    case 513: return YJ;
    case 514: return YK;
    case 515: return YL;
    case 516: return YM;
    case 517: return YN;
    case 518: return YP;
    case 519: return YQ;
    case 520: return YR;
    case 521: return YS;
    case 522: return YT;
    case 523: return YU;
    case 524: return YV;
    case 525: return YW;
    case 526: return YX;
    case 527: return YY;
    case 528: return YZ;
    case 529: return ZA;
    case 530: return ZC;
    case 531: return ZD;
    case 532: return ZE;
    case 533: return ZF;
    case 534: return ZG;
    case 535: return ZH;
    case 536: return ZJ;
    case 537: return ZK;
    case 538: return ZL;
    case 539: return ZM;
    case 540: return ZN;
    case 541: return ZP;
    case 542: return ZQ;
    case 543: return ZR;
    case 544: return ZS;
    case 545: return ZT;
    case 546: return ZU;
    case 547: return ZV;
    case 548: return ZW;
    case 549: return ZX;
    case 550: return ZY;
    case 551: return ZZ;
    case 552: return AAA;
    case 553: return AAC;
    case 554: return AAD;
    case 555: return AAE;
    case 556: return AAF;
    case 557: return AAG;
    case 558: return AAH;
    case 559: return AAJ;
    case 560: return AAK;
    case 561: return AAL;
    case 562: return AAM;
    case 563: return AAN;
    case 564: return AAP;
    case 565: return AAQ;
    case 566: return AAR;
    case 567: return AAS;
    case 568: return AAT;
    case 569: return AAU;
    case 570: return AAV;
    case 571: return AAW;
    case 572: return AAX;
    case 573: return AAY;
    case 574: return AAZ;
    case 575: return ACA;
    case 576: return ACC;
    case 577: return ACD;
    case 578: return ACE;
    case 579: return ACF;
    case 580: return ACG;
    case 581: return ACH;
    case 582: return ACJ;
    case 583: return ACK;
    case 584: return ACL;
    case 585: return ACM;
    case 586: return ACN;
    case 587: return ACP;
    case 588: return ACQ;
    case 589: return ACR;
    case 590: return ACS;
    case 591: return ACT;
    case 592: return ACU;
    case 593: return ACV;
    case 594: return ACW;
    case 595: return ACX;
    case 596: return ACY;
    case 597: return ACZ;
    case 598: return ADA;
    case 599: return ADC;
    case 600: return ADD;
    case 601: return ADE;
    case 602: return ADF;
    case 603: return ADG;
    case 604: return ADH;
    case 605: return ADJ;
    case 606: return ADK;
    case 607: return ADL;
    case 608: return ADM;
    case 609: return ADN;
    case 610: return ADP;
    case 611: return ADQ;
    case 612: return ADR;
    case 613: return ADS;
    case 614: return ADT;
    case 615: return ADU;
    case 616: return ADV;
    case 617: return ADW;
    case 618: return ADX;
    case 619: return ADY;
    case 620: return ADZ;
    case 621: return AEA;
    case 622: return AEC;
    case 623: return AED;
    case 624: return AEE;
    case 625: return AEF;
    case 626: return AEG;
    case 627: return AEH;
    case 628: return AEJ;
    case 629: return AEK;
    case 630: return AEL;
    case 631: return AEM;
    case 632: return AEN;
    case 633: return AEP;
    case 634: return AEQ;
    case 635: return AER;
    case 636: return AES;
    case 637: return AET;
    case 638: return AEU;
    case 639: return AEV;
    case 640: return AEW;
    case 641: return AEX;
    case 642: return AEY;
    case 643: return AEZ;
    case 644: return AFA;
    case 645: return AFC;
    case 646: return AFD;
    case 647: return AFE;
    case 648: return AFF;
    case 649: return AFG;
    case 650: return AFH;
    case 651: return AFJ;
    case 652: return AFK;
    case 653: return AFL;
    case 654: return AFM;
    case 655: return AFN;
    case 656: return AFP;
    case 657: return AFQ;
    case 658: return AFR;
    case 659: return AFS;
    case 660: return AFT;
    case 661: return AFU;
    case 662: return AFV;
    case 663: return AFW;
    case 664: return AFX;
    case 665: return AFY;
    case 666: return AFZ;
    case 667: return AGA;
    case 668: return AGC;
    case 669: return AGD;
    case 670: return AGE;
    case 671: return AGF;
    case 672: return AGG;
    case 673: return AGH;
    case 674: return AGJ;
    case 675: return AGK;
    case 676: return AGL;
    case 677: return AGM;
    case 678: return AGN;
    case 679: return AGP;
    case 680: return AGQ;
    case 681: return AGR;
    case 682: return AGS;
    case 683: return AGT;
    case 684: return AGU;
    case 685: return AGV;
    case 686: return AGW;
    case 687: return AGX;
    case 688: return AGY;
    case 689: return AGZ;
    case 690: return AHA;
    case 691: return AHC;
    case 692: return AHD;
    case 693: return AHE;
    case 694: return AHF;
    case 695: return AHG;
    case 696: return AHH;
    case 697: return AHJ;
    case 698: return AHK;
    case 699: return AHL;
    case 700: return AHM;
    case 701: return AHN;
    case 702: return AHP;
    case 703: return AHQ;
    case 704: return AHR;
    case 705: return AHS;
    case 706: return AHT;
    case 707: return AHU;
    case 708: return AHV;
    case 709: return AHW;
    case 710: return AHX;
    case 711: return AHY;
    case 712: return AHZ;
    case 713: return AJA;
    case 714: return AJC;
    case 715: return AJD;
    case 716: return AJE;
    case 717: return AJF;
    case 718: return AJG;
    case 719: return AJH;
    case 720: return AJJ;
    case 721: return AJK;
    case 722: return AJL;
    case 723: return AJM;
    case 724: return AJN;
    case 725: return AJP;
    case 726: return AJQ;
    case 727: return AJR;
    case 728: return AJS;
    case 729: return AJT;
    case 730: return AJU;
    case 731: return AJV;
    case 732: return AJW;
    case 733: return AJX;
    case 734: return AJY;
    case 735: return AJZ;
    case 736: return AKA;
    case 737: return AKC;
    case 738: return AKD;
    case 739: return AKE;
    case 740: return AKF;
    case 741: return AKG;
    case 742: return AKH;
    case 743: return AKJ;
    case 744: return AKK;
    case 745: return AKL;
    case 746: return AKM;
    case 747: return AKN;
    case 748: return AKP;
    case 749: return AKQ;
    case 750: return AKR;
    case 751: return AKS;
    case 752: return AKT;
    case 753: return AKU;
    case 754: return AKV;
    case 755: return AKW;
    case 756: return AKX;
    case 757: return AKY;
    case 758: return AKZ;
    case 759: return ALA;
    case 760: return ALC;
    case 761: return ALD;
    case 762: return ALE;
    case 763: return ALF;
    case 764: return ALG;
    case 765: return ALH;
    case 766: return ALJ;
    case 767: return ALK;
    case 768: return ALL;
    case 769: return ALM;
    case 770: return ALN;
    case 771: return ALP;
    case 772: return ALQ;
    case 773: return ALR;
    case 774: return ALS;
    case 775: return ALT;
    case 776: return ALU;
    case 777: return ALV;
    case 778: return ALW;
    case 779: return ALX;
    case 780: return ALY;
    case 781: return ALZ;
    case 782: return AMA;
    case 783: return AMC;
    case 784: return AMD;
    case 785: return AME;
    case 786: return AMF;
    case 787: return AMG;
    case 788: return AMH;
    case 789: return AMJ;
    case 790: return AMK;
    case 791: return AML;
    case 792: return AMM;
    case 793: return AMN;
    case 794: return AMP;
    case 795: return AMQ;
    case 796: return AMR;
    case 797: return AMS;
    case 798: return AMT;
    case 799: return AMU;
    case 800: return AMV;
    case 801: return AMW;
    case 802: return AMX;
    case 803: return AMY;
    case 804: return AMZ;
    case 805: return ANA;
    case 806: return ANC;
    case 807: return AND;
    case 808: return ANE;
    case 809: return ANF;
    case 810: return ANG;
    case 811: return ANH;
    case 812: return ANJ;
    case 813: return ANK;
    case 814: return ANL;
    case 815: return ANM;
    case 816: return ANN;
    case 817: return ANP;
    case 818: return ANQ;
    case 819: return ANR;
    case 820: return ANS;
    case 821: return ANT;
    case 822: return ANU;
    case 823: return ANV;
    case 824: return ANW;
    case 825: return ANX;
    case 826: return ANY;
    case 827: return ANZ;
    case 828: return APA;
    case 829: return APC;
    case 830: return APD;
    case 831: return APE;
    case 832: return APF;
    case 833: return APG;
    case 834: return APH;
    case 835: return APJ;
    case 836: return APK;
    case 837: return APL;
    case 838: return APM;
    case 839: return APN;
    case 840: return APP;
    case 841: return APQ;
    case 842: return APR;
    case 843: return APS;
    case 844: return APT;
    case 845: return APU;
    case 846: return APV;
    case 847: return APW;
    case 848: return APX;
    case 849: return APY;
    case 850: return APZ;
    case 851: return AQA;
    case 852: return AQC;
    case 853: return AQD;
    case 854: return AQE;
    case 855: return AQF;
    case 856: return AQG;
    case 857: return AQH;
    case 858: return AQJ;
    case 859: return AQK;
    case 860: return AQL;
    case 861: return AQM;
    case 862: return AQN;
    case 863: return AQP;
    case 864: return AQQ;
    case 865: return AQR;
    case 866: return AQS;
    case 867: return AQT;
    case 868: return AQU;
    case 869: return AQV;
    case 870: return AQW;
    case 871: return AQX;
    case 872: return AQY;
    case 873: return AQZ;
    case 874: return ARA;
    case 875: return ARC;
    case 876: return ARD;
    case 877: return ARE;
    case 878: return ARF;
    case 879: return ARG;
    case 880: return ARH;
    case 881: return ARJ;
    case 882: return ARK;
    case 883: return ARL;
    case 884: return ARM;
    case 885: return ARN;
    case 886: return ARP;
    case 887: return ARQ;
    case 888: return ARR;
    case 889: return ARS;
    case 890: return ART;
    case 891: return ARU;
    case 892: return ARV;
    case 893: return ARW;
    case 894: return ARX;
    case 895: return ARY;
    case 896: return ARZ;
    case 897: return ASA;
    case 898: return ASC;
    case 899: return ASD;
    case 900: return ASE;
    case 901: return ASF;
    case 902: return ASG;
    case 903: return ASH;
    case 904: return ASJ;
    case 905: return ASK;
    case 906: return ASL;
    case 907: return ASM;
    case 908: return ASN;
    case 909: return ASP;
    case 910: return ASQ;
    case 911: return ASR;
    case 912: return ASS;
    case 913: return AST;
    case 914: return ASU;
    case 915: return ASV;
    case 916: return ASW;
    case 917: return ASX;
    case 918: return ASY;
    case 919: return ASZ;
    case 920: return ATA;
    case 921: return ATC;
    case 922: return ATD;
    case 923: return ATE;
    case 924: return ATF;
    case 925: return ATG;
    case 926: return ATH;
    case 927: return ATJ;
    case 928: return ATK;
    case 929: return ATL;
    case 930: return ATM;
    case 931: return ATN;
    case 932: return ATP;
    case 933: return ATQ;
    case 934: return ATR;
    case 935: return ATS;
    case 936: return ATT;
    case 937: return ATU;
    case 938: return ATV;
    case 939: return ATW;
    case 940: return ATX;
    case 941: return ATY;
    case 942: return ATZ;
    case 943: return AUA;
    case 944: return AUC;
    case 945: return AUD;
    case 946: return AUE;
    case 947: return AUF;
    case 948: return AUG;
    case 949: return AUH;
    case 950: return AUJ;
    case 951: return AUK;
    case 952: return AUL;
    case 953: return AUM;
    case 954: return AUN;
    case 955: return AUP;
    case 956: return AUQ;
    case 957: return AUR;
    case 958: return AUS;
    case 959: return AUT;
    case 960: return AUU;
    case 961: return AUV;
    case 962: return AUW;
    case 963: return AUX;
    case 964: return AUY;
    case 965: return AUZ;
    case 966: return AVA;
    case 967: return AVC;
    case 968: return AVD;
    case 969: return AVE;
    case 970: return AVF;
    case 971: return AVG;
    case 972: return AVH;
    case 973: return AVJ;
    case 974: return AVK;
    case 975: return AVL;
    case 976: return AVM;
    case 977: return AVN;
    case 978: return AVP;
    case 979: return AVQ;
    case 980: return AVR;
    case 981: return AVS;
    case 982: return AVT;
    case 983: return AVU;
    case 984: return AVV;
    case 985: return AVW;
    case 986: return AVX;
    case 987: return AVY;
    case 988: return AVZ;
    case 989: return AWA;
    case 990: return AWC;
    case 991: return AWD;
    case 992: return AWE;
    case 993: return AWF;
    case 994: return AWG;
    case 995: return AWH;
    case 996: return AWJ;
    case 997: return AWK;
    case 998: return AWL;
    case 999: return AWM;
    case 1000: return AWN;
    case 1001: return AWP;
    case 1002: return AWQ;
    case 1003: return AWR;
    case 1004: return AWS;
    case 1005: return AWT;
    case 1006: return AWU;
    case 1007: return AWV;
    case 1008: return AWW;
    case 1009: return AWX;
    case 1010: return AWY;
    case 1011: return AWZ;
    case 1012: return AXA;
    case 1013: return AXC;
    case 1014: return AXD;
    case 1015: return AXE;
    case 1016: return AXF;
    case 1017: return AXG;
    case 1018: return AXH;
    case 1019: return AXJ;
    case 1020: return AXK;
    case 1021: return AXL;
    case 1022: return AXM;
    case 1023: return AXN;
    case 1024: return AXP;
    case 1025: return AXQ;
    case 1026: return AXR;
    case 1027: return AXS;
    case 1028: return AXT;
    case 1029: return AXU;
    case 1030: return AXV;
    case 1031: return AXW;
    case 1032: return AXX;
    case 1033: return AXY;
    case 1034: return AXZ;
    case 1035: return AYA;
    case 1036: return AYC;
    case 1037: return AYD;
    case 1038: return AYE;
    case 1039: return AYF;
    case 1040: return AYG;
    case 1041: return AYH;
    case 1042: return AYJ;
    case 1043: return AYK;
    case 1044: return AYL;
    case 1045: return AYM;
    case 1046: return AYN;
    case 1047: return AYP;
    case 1048: return AYQ;
    case 1049: return AYR;
    case 1050: return AYS;
    case 1051: return AYT;
    case 1052: return AYU;
    case 1053: return AYV;
    case 1054: return AYW;
    case 1055: return AYX;
    case 1056: return AYY;
    case 1057: return AYZ;
    case 1058: return AZA;
    case 1059: return AZC;
    case 1060: return AZD;
    case 1061: return AZE;
    case 1062: return AZF;
    case 1063: return AZG;
    case 1064: return AZH;
    case 1065: return AZJ;
    case 1066: return AZK;
    case 1067: return AZL;
    case 1068: return AZM;
    case 1069: return AZN;
    case 1070: return AZP;
    case 1071: return AZQ;
    case 1072: return AZR;
    case 1073: return AZS;
    case 1074: return AZT;
    case 1075: return AZU;
    case 1076: return AZV;
    case 1077: return AZW;
    case 1078: return AZX;
    case 1079: return AZY;
    case 1080: return AZZ;
    default:
        assert(0, "No keypair at this index");
    }
}

/*******************************************************************************

    Genesis KeyPair used in unittests

    In unittests, we need the genesis key pair to be known for us to be
    able to write tests. Hence the genesis block has a different value.

    Note that while this is a well-known keys, it is not part of the
    range returned by `byRange`, nor can it be indexed by `size_t`,
    to avoid it being mistakenly used.
    It is however accessible via `opIndex(PublicKey)`.

    Address: boa1xzgenes5cf8xel37fz79gzs49v56znllk7jw7qscjwl5p6a9zxk8zaygm67

*******************************************************************************/

static immutable Genesis = KeyPair(PublicKey(Point([145, 153, 230, 20, 194, 78, 108, 254, 62, 72, 188, 84, 10, 21, 43, 41, 161, 79, 255, 183, 164, 239, 2, 24, 147, 191, 64, 235, 165, 17, 172, 113])), SecretKey(Scalar([219, 240, 132, 196, 246, 124, 232, 51, 106, 227, 192, 37, 207, 52, 79, 97, 126, 3, 28, 131, 199, 13, 37, 58, 72, 139, 97, 27, 78, 70, 48, 5])));


/*******************************************************************************

    Commons Budget KeyPair used in unittests

    In unittests, we need the commons budget key pair to be known for us to be
    able to write tests.
    In the real network, there are different values.

    Note that while this is a well-known keys, it is not part of the
    range returned by `byRange`, nor can it be indexed by `size_t`,
    to avoid it being mistakenly used.

    Address: boa1xqcmmns5swnm03zay5wjplgupe65uw4w0dafzsdsqtwq6gv3h3lcz24a8ch

*******************************************************************************/

static immutable CommonsBudget = KeyPair(PublicKey(Point([49, 189, 206, 20, 131, 167, 183, 196, 93, 37, 29, 32, 253, 28, 14, 117, 78, 58, 174, 123, 122, 145, 65, 176, 2, 220, 13, 33, 145, 188, 127, 129])), SecretKey(Scalar([147, 123, 24, 11, 143, 213, 66, 225, 171, 44, 69, 79, 164, 82, 174, 69, 189, 195, 142, 74, 201, 124, 39, 152, 141, 130, 222, 220, 236, 118, 193, 11])));


/*******************************************************************************

    Key pairs used for Enrollments in the genesis block

*******************************************************************************/

// val2: boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2 - SAQXRDHTWME4GUIVNYCKPN433VJ4BJP2L2T7UWHGSSW47VFC67EQFY3S
static immutable NODE2 = KeyPair(PublicKey(Point([153, 223, 171, 177, 195, 76, 197, 30, 122, 135, 199, 165, 59, 248, 20, 63, 104, 203, 140, 183, 177, 199, 208, 11, 136, 169, 69, 145, 67, 250, 64, 156])), SecretKey(Scalar([33, 120, 140, 243, 179, 9, 195, 81, 21, 110, 4, 167, 183, 155, 221, 83, 192, 165, 250, 94, 167, 250, 88, 230, 148, 173, 207, 212, 162, 247, 201, 2])));

// val3: boa1xzval3ah8z7ewhuzx6mywveyr79f24w49rdypwgurhjkr8z2ke2mycftv9n - SC3H3ADGT3YGLMDWCLKZ2GILDHDTC4WDE7M3G4URQPWJZZM43TTAM2QG
static immutable NODE3 = KeyPair(PublicKey(Point([153, 223, 199, 183, 56, 189, 151, 95, 130, 54, 182, 71, 51, 36, 31, 138, 149, 85, 213, 40, 218, 64, 185, 28, 29, 229, 97, 156, 74, 182, 85, 178])), SecretKey(Scalar([182, 125, 128, 102, 158, 240, 101, 176, 118, 18, 213, 157, 25, 11, 25, 199, 49, 114, 195, 39, 217, 179, 114, 145, 131, 236, 156, 229, 156, 220, 230, 6])));

// val4: boa1xzval4nvru2ej9m0rptq7hatukkavemryvct4f8smyy3ky9ct5u0s8w6gfy - SBIJAVYYCSRV5RNO2WVTT25H6VZTEV3YSE7U7WT7UQUNSVBUGB6QNBWG
static immutable NODE4 = KeyPair(PublicKey(Point([153, 223, 214, 108, 31, 21, 153, 23, 111, 24, 86, 15, 95, 171, 229, 173, 214, 103, 99, 35, 48, 186, 164, 240, 217, 9, 27, 16, 184, 93, 56, 248])), SecretKey(Scalar([80, 144, 87, 24, 20, 163, 94, 197, 174, 213, 171, 57, 235, 167, 245, 115, 50, 87, 120, 145, 63, 79, 218, 127, 164, 40, 217, 84, 52, 48, 125, 6])));

// val5: boa1xzval5zfar2etl3xzkkyec5xvy03pxnhn9l4c0anl6pejep0xn9wwsrmnc4 - SABQSYXZIG3ONZHJNZBDR76HTVBT672MYWYDN6QIPZ6OCJ2UTL5A52XP
static immutable NODE5 = KeyPair(PublicKey(Point([153, 223, 208, 73, 232, 213, 149, 254, 38, 21, 172, 76, 226, 134, 97, 31, 16, 154, 119, 153, 127, 92, 63, 179, 254, 131, 153, 100, 47, 52, 202, 231])), SecretKey(Scalar([3, 9, 98, 249, 65, 182, 230, 228, 233, 110, 66, 56, 255, 199, 157, 67, 63, 127, 76, 197, 176, 54, 250, 8, 126, 124, 225, 39, 84, 154, 250, 14])));

// val6: boa1xzval6zletrt49ls5r2mqylcljutfat6dtd5hwslp2gxas5kwvsw5ngea9p - SAV6R6W6D2XBTGVRC7R32Y2BDY47UJ5ORZNSRUH23B3TV47SXDBQ7GYR
static immutable NODE6 = KeyPair(PublicKey(Point([153, 223, 232, 95, 202, 198, 186, 151, 240, 160, 213, 176, 19, 248, 252, 184, 180, 245, 122, 106, 219, 75, 186, 31, 10, 144, 110, 194, 150, 115, 32, 234])), SecretKey(Scalar([43, 232, 250, 222, 30, 174, 25, 154, 177, 23, 227, 189, 99, 65, 30, 57, 250, 39, 174, 142, 91, 40, 208, 250, 216, 119, 58, 243, 242, 184, 195, 15])));

// val7: boa1xzval7zrjx7wn00tpcqyxpfyayf32je8apv3h2g5km0rgpljg49a7s6we9a - SC7SAZXF726MPSE5A67QNFLTGQL7XDQM5E2T3O7LZUFI36YE32NA4R3Q
static immutable NODE7 = KeyPair(PublicKey(Point([153, 223, 248, 67, 145, 188, 233, 189, 235, 14, 0, 67, 5, 36, 233, 19, 21, 75, 39, 232, 89, 27, 169, 20, 182, 222, 52, 7, 242, 69, 75, 223])), SecretKey(Scalar([191, 32, 102, 229, 254, 188, 199, 200, 157, 7, 191, 6, 149, 115, 52, 23, 251, 142, 12, 233, 53, 61, 187, 235, 205, 10, 141, 251, 4, 222, 154, 14])));

/*******************************************************************************

    All well-known keypairs

    The pattern is as follow:
    Keys are in the range `[a,z]`, `[aa,zz]` and `[aaa,azz]`, for a total of
    1,080 keys (23 + 23 * 23 * 2 - 1), as we needed more than 1,000 keys.
    Keys have been mined to be easily recognizable in logs, as such, their
    public keys starts with `boa1x[x]` ([x] meaning any character),
    followed by their name, followed by `00`.
    For example, `A` is `boa1xza00...` and `ACC` is `boa1xqacc00...`.

*******************************************************************************/

/// A: boa1xza007gllhzdawnr727hds36guc0frnjsqscgf4k08zqesapcg3uujh9g93
static immutable A = KeyPair(PublicKey(Point([186, 247, 249, 31, 253, 196, 222, 186, 99, 242, 189, 118, 194, 58, 71, 48, 244, 142, 114, 128, 33, 132, 38, 182, 121, 196, 12, 195, 161, 194, 35, 206])), SecretKey(Scalar([11, 16, 204, 181, 0, 119, 242, 17, 35, 69, 12, 33, 171, 177, 218, 164, 189, 192, 97, 118, 228, 249, 120, 215, 255, 116, 132, 46, 193, 227, 77, 12])));
/// C: boa1xrc00kar2yqa3jzve9cm4cvuaa8duazkuwrygmqgpcuf0gqww8ye7ua9lkl
static immutable C = KeyPair(PublicKey(Point([240, 247, 219, 163, 81, 1, 216, 200, 76, 201, 113, 186, 225, 156, 239, 78, 222, 116, 86, 227, 134, 68, 108, 8, 14, 56, 151, 160, 14, 113, 201, 159])), SecretKey(Scalar([175, 190, 50, 89, 66, 224, 153, 243, 87, 140, 156, 71, 101, 104, 251, 112, 80, 251, 231, 152, 132, 91, 61, 21, 33, 162, 244, 83, 31, 53, 181, 14])));
/// D: boa1xqd00qsu7n5ykyckc23wmcjglfalcdea3x2af88hx2x5qx65x7w8g2r5t29
static immutable D = KeyPair(PublicKey(Point([26, 247, 130, 28, 244, 232, 75, 19, 22, 194, 162, 237, 226, 72, 250, 123, 252, 55, 61, 137, 149, 212, 156, 247, 50, 141, 64, 27, 84, 55, 156, 116])), SecretKey(Scalar([26, 97, 174, 225, 0, 177, 244, 233, 117, 162, 59, 39, 52, 142, 23, 43, 51, 158, 88, 61, 196, 48, 41, 178, 54, 94, 98, 183, 238, 243, 120, 11])));
/// E: boa1xre00xg0n4l024ms8ze5sukenjuw6ryyp0h0ne8x3tgvj4rvgfumqeuly2r
static immutable E = KeyPair(PublicKey(Point([242, 247, 153, 15, 157, 126, 245, 87, 112, 56, 179, 72, 114, 217, 156, 184, 237, 12, 132, 11, 238, 249, 228, 230, 138, 208, 201, 84, 108, 66, 121, 176])), SecretKey(Scalar([223, 92, 46, 61, 217, 0, 189, 23, 139, 216, 5, 48, 203, 54, 174, 105, 171, 24, 16, 44, 128, 22, 50, 194, 247, 89, 195, 54, 229, 129, 152, 8])));
/// F: boa1xzf00xqr0uylydl5z5kayn0eemtdcvjl97z5x06uvu9mr38zk5alsl770l2
static immutable F = KeyPair(PublicKey(Point([146, 247, 152, 3, 127, 9, 242, 55, 244, 21, 45, 210, 77, 249, 206, 214, 220, 50, 95, 47, 133, 67, 63, 92, 103, 11, 177, 196, 226, 181, 59, 248])), SecretKey(Scalar([49, 252, 34, 208, 204, 217, 156, 103, 1, 63, 143, 212, 20, 161, 242, 130, 193, 120, 254, 161, 0, 92, 232, 154, 166, 182, 31, 45, 115, 194, 230, 7])));
/// G: boa1xqg00pky3g8j6jk3hfc9p5kvrdmq28tjr9u0sd9yfxwmp2p9c529zzkf0jt
static immutable G = KeyPair(PublicKey(Point([16, 247, 134, 196, 138, 15, 45, 74, 209, 186, 112, 80, 210, 204, 27, 118, 5, 29, 114, 25, 120, 248, 52, 164, 73, 157, 176, 168, 37, 197, 20, 81])), SecretKey(Scalar([244, 161, 81, 190, 102, 182, 228, 215, 227, 138, 42, 78, 246, 166, 103, 141, 143, 3, 234, 184, 125, 45, 1, 180, 174, 84, 109, 22, 65, 225, 178, 1])));
/// H: boa1xph007vhkq4j58eyhwxx8eg5hjc0p5etp5kss0w8fh2ux6xjf2v4wlxm25k
static immutable H = KeyPair(PublicKey(Point([110, 247, 249, 151, 176, 43, 42, 31, 36, 187, 140, 99, 229, 20, 188, 176, 240, 211, 43, 13, 45, 8, 61, 199, 77, 213, 195, 104, 210, 74, 153, 87])), SecretKey(Scalar([86, 42, 146, 127, 185, 15, 95, 80, 65, 53, 219, 151, 121, 233, 32, 101, 205, 106, 125, 235, 153, 87, 190, 34, 5, 187, 208, 41, 56, 156, 219, 3])));
/// J: boa1xrj0050flv70cl7y72qhxa7awf2u9ux2h4pkfulatvasj4n5dj8yglwer6u
static immutable J = KeyPair(PublicKey(Point([228, 247, 209, 233, 251, 60, 252, 127, 196, 242, 129, 115, 119, 221, 114, 85, 194, 240, 202, 189, 67, 100, 243, 253, 91, 59, 9, 86, 116, 108, 142, 68])), SecretKey(Scalar([248, 101, 254, 79, 193, 250, 77, 199, 35, 70, 97, 60, 124, 44, 116, 68, 106, 2, 44, 254, 179, 143, 223, 218, 85, 203, 141, 160, 45, 160, 40, 13])));
/// K: boa1xrk00cupup5vxwpz09kl9rau78cwag28us4vuctr6zdxvwfzaht9v6tms8q
static immutable K = KeyPair(PublicKey(Point([236, 247, 227, 129, 224, 104, 195, 56, 34, 121, 109, 242, 143, 188, 241, 240, 238, 161, 71, 228, 42, 206, 97, 99, 208, 154, 102, 57, 34, 237, 214, 86])), SecretKey(Scalar([29, 30, 221, 87, 205, 220, 203, 183, 133, 143, 0, 184, 26, 26, 176, 174, 50, 180, 19, 154, 116, 124, 4, 155, 157, 15, 229, 32, 252, 146, 245, 8])));
/// L: boa1xrl00g8w67cx8ky2t5g6yfg08pkmy74p39697696y8ge24whwds4xzc8hpd
static immutable L = KeyPair(PublicKey(Point([254, 247, 160, 238, 215, 176, 99, 216, 138, 93, 17, 162, 37, 15, 56, 109, 178, 122, 161, 137, 116, 95, 104, 186, 33, 209, 149, 85, 215, 115, 97, 83])), SecretKey(Scalar([20, 168, 101, 19, 232, 63, 83, 116, 32, 247, 60, 237, 2, 61, 59, 28, 44, 76, 216, 70, 101, 213, 255, 237, 250, 113, 78, 27, 194, 208, 137, 5])));
/// M: boa1xzm00zy4szktfrhpudpw05knhtpg22jvnmh4x5xakj5duxcx46stjyeg5h8
static immutable M = KeyPair(PublicKey(Point([182, 247, 136, 149, 128, 172, 180, 142, 225, 227, 66, 231, 210, 211, 186, 194, 133, 42, 76, 158, 239, 83, 80, 221, 180, 168, 222, 27, 6, 174, 160, 185])), SecretKey(Scalar([223, 147, 123, 226, 150, 45, 218, 228, 254, 107, 254, 13, 246, 251, 97, 213, 135, 138, 222, 21, 159, 112, 1, 228, 128, 163, 156, 56, 61, 117, 66, 14])));
/// N: boa1xqn000ll89ut9pzylvjaya48jd0u32h3r64zldldxs97nsd83r8qgcjz2np
static immutable N = KeyPair(PublicKey(Point([38, 247, 191, 255, 57, 120, 178, 132, 68, 251, 37, 210, 118, 167, 147, 95, 200, 170, 241, 30, 170, 47, 183, 237, 52, 11, 233, 193, 167, 136, 206, 4])), SecretKey(Scalar([229, 58, 163, 56, 113, 136, 242, 242, 3, 111, 116, 240, 130, 35, 123, 212, 179, 13, 179, 170, 155, 162, 57, 154, 86, 183, 35, 156, 71, 68, 85, 0])));
/// P: boa1xrp00xtuq6v5m9qe7dualpjvw6k468vdrvcxkcjtj093l3k3j6v4g2v4v92
static immutable P = KeyPair(PublicKey(Point([194, 247, 153, 124, 6, 153, 77, 148, 25, 243, 121, 223, 134, 76, 118, 173, 93, 29, 141, 27, 48, 107, 98, 75, 147, 203, 31, 198, 209, 150, 153, 84])), SecretKey(Scalar([30, 113, 192, 241, 72, 139, 141, 224, 253, 76, 123, 24, 221, 144, 6, 52, 8, 55, 4, 76, 194, 84, 124, 220, 240, 28, 187, 227, 184, 14, 89, 14])));
/// Q: boa1xpq00hzr6m0dupx9zvtttjqjeq9ld6n2fruktrp23qujdcy290ld6zcpl5c
static immutable Q = KeyPair(PublicKey(Point([64, 247, 220, 67, 214, 222, 222, 4, 197, 19, 22, 181, 200, 18, 200, 11, 246, 234, 106, 72, 249, 101, 140, 42, 136, 57, 38, 224, 138, 43, 254, 221])), SecretKey(Scalar([222, 62, 98, 9, 26, 52, 67, 68, 55, 109, 132, 115, 124, 203, 255, 17, 60, 80, 48, 81, 66, 61, 138, 103, 90, 3, 2, 104, 45, 17, 46, 4])));
/// R: boa1xpr00rxtcprlf99dnceuma0ftm9sv03zhtlwfytd5p0dkvzt4ryp595zpjp
static immutable R = KeyPair(PublicKey(Point([70, 247, 140, 203, 192, 71, 244, 148, 173, 158, 51, 205, 245, 233, 94, 203, 6, 62, 34, 186, 254, 228, 145, 109, 160, 94, 219, 48, 75, 168, 200, 26])), SecretKey(Scalar([238, 13, 71, 137, 3, 218, 84, 47, 145, 168, 208, 99, 116, 232, 187, 86, 194, 249, 202, 187, 54, 80, 223, 144, 3, 19, 168, 83, 124, 254, 232, 13])));
/// S: boa1xqs00rejsuwmlreljp8k2c0k7q8cmkgxx76m6tc9f8j2s97vsvw4gzyhdcq
static immutable S = KeyPair(PublicKey(Point([32, 247, 143, 50, 135, 29, 191, 143, 63, 144, 79, 101, 97, 246, 240, 15, 141, 217, 6, 55, 181, 189, 47, 5, 73, 228, 168, 23, 204, 131, 29, 84])), SecretKey(Scalar([237, 231, 201, 236, 36, 120, 255, 203, 58, 13, 199, 7, 200, 168, 185, 17, 111, 87, 94, 128, 148, 179, 80, 245, 153, 111, 236, 8, 46, 6, 250, 11])));
/// T: boa1xpt00hv2rrlrm56pq70dukq4trlrfveqwna20su7457dnrl33xkrua6s5tf
static immutable T = KeyPair(PublicKey(Point([86, 247, 221, 138, 24, 254, 61, 211, 65, 7, 158, 222, 88, 21, 88, 254, 52, 179, 32, 116, 250, 167, 195, 158, 173, 60, 217, 143, 241, 137, 172, 62])), SecretKey(Scalar([240, 215, 158, 8, 24, 184, 38, 53, 139, 84, 84, 179, 161, 86, 25, 33, 235, 85, 164, 147, 91, 102, 57, 168, 74, 74, 225, 207, 216, 189, 33, 15])));
/// U: boa1xzu00x9m4u5ke9uav3v5vxr9pmfdcxc6qmzw3ht7kk20cckyc7uzusk2zah
static immutable U = KeyPair(PublicKey(Point([184, 247, 152, 187, 175, 41, 108, 151, 157, 100, 89, 70, 24, 101, 14, 210, 220, 27, 26, 6, 196, 232, 221, 126, 181, 148, 252, 98, 196, 199, 184, 46])), SecretKey(Scalar([133, 8, 176, 113, 246, 201, 228, 118, 15, 22, 25, 0, 94, 26, 110, 40, 179, 119, 218, 122, 158, 186, 201, 179, 84, 60, 34, 12, 207, 189, 236, 12])));
/// V: boa1xzv00g8k23usvepjkqhf3xzp7r5d6crync0klk6zakwl3y8eh47hgjct2py
static immutable V = KeyPair(PublicKey(Point([152, 247, 160, 246, 84, 121, 6, 100, 50, 176, 46, 152, 152, 65, 240, 232, 221, 96, 100, 158, 31, 111, 219, 66, 237, 157, 248, 144, 249, 189, 125, 116])), SecretKey(Scalar([34, 96, 70, 11, 235, 190, 175, 128, 213, 122, 125, 109, 49, 116, 34, 128, 162, 137, 226, 147, 250, 255, 187, 249, 174, 186, 99, 6, 4, 237, 84, 6])));
/// W: boa1xqw00qrxlefaq79mhrcyhfjlz03u5kt5p3zwj6kvl96wp4t5cu0uzuftw8p
static immutable W = KeyPair(PublicKey(Point([28, 247, 128, 102, 254, 83, 208, 120, 187, 184, 240, 75, 166, 95, 19, 227, 202, 89, 116, 12, 68, 233, 106, 204, 249, 116, 224, 213, 116, 199, 31, 193])), SecretKey(Scalar([206, 220, 131, 194, 180, 14, 113, 107, 40, 200, 64, 46, 43, 40, 73, 180, 165, 243, 177, 97, 170, 251, 67, 90, 240, 188, 120, 98, 254, 111, 179, 15])));
/// X: boa1xqx0039s4ulz2n9cqalv04pgphf79q09csw0w9lyfv52mmlc6ynhzjzgyex
static immutable X = KeyPair(PublicKey(Point([12, 247, 196, 176, 175, 62, 37, 76, 184, 7, 126, 199, 212, 40, 13, 211, 226, 129, 229, 196, 28, 247, 23, 228, 75, 40, 173, 239, 248, 209, 39, 113])), SecretKey(Scalar([192, 84, 168, 60, 64, 211, 210, 197, 253, 94, 158, 189, 77, 30, 142, 75, 91, 132, 77, 54, 253, 139, 107, 4, 219, 153, 170, 38, 118, 112, 27, 7])));
/// Y: boa1xpy00m8r9qpmkh8zznkn3jc9w9n3t6x3wdzx4sdsd9xqjk3m0dwzx9ecvul
static immutable Y = KeyPair(PublicKey(Point([72, 247, 236, 227, 40, 3, 187, 92, 226, 20, 237, 56, 203, 5, 113, 103, 21, 232, 209, 115, 68, 106, 193, 176, 105, 76, 9, 90, 59, 123, 92, 35])), SecretKey(Scalar([199, 233, 132, 66, 249, 102, 244, 217, 151, 235, 83, 210, 234, 85, 151, 103, 179, 3, 252, 83, 127, 139, 48, 151, 216, 23, 23, 75, 239, 79, 245, 7])));
/// Z: boa1xpz00vc5rg6wlehmfzaan8rg9s53wyptsya59cusk6fxx939tufu72hkkf4
static immutable Z = KeyPair(PublicKey(Point([68, 247, 179, 20, 26, 52, 239, 230, 251, 72, 187, 217, 156, 104, 44, 41, 23, 16, 43, 129, 59, 66, 227, 144, 182, 146, 99, 22, 37, 95, 19, 207])), SecretKey(Scalar([102, 191, 174, 200, 35, 29, 81, 60, 165, 34, 146, 179, 97, 158, 205, 73, 211, 92, 84, 190, 192, 36, 107, 218, 195, 42, 91, 29, 58, 148, 6, 0])));
/// AA: boa1xqaa00924jl7l2y5y00mvplsy6f0ycu829uw8s8hx88m2xg939n5x6h0ema
static immutable AA = KeyPair(PublicKey(Point([59, 215, 188, 170, 172, 191, 239, 168, 148, 35, 223, 182, 7, 240, 38, 146, 242, 99, 135, 81, 120, 227, 192, 247, 49, 207, 181, 25, 5, 137, 103, 67])), SecretKey(Scalar([61, 178, 231, 106, 137, 193, 206, 63, 29, 243, 230, 94, 113, 151, 239, 88, 196, 164, 241, 143, 231, 94, 68, 132, 192, 15, 228, 26, 61, 108, 144, 13])));
/// AC: boa1xzac00c7adkrn3ustmngchgegzhr74j2ftrk6692p5et33d2v3xnwy3nwa8
static immutable AC = KeyPair(PublicKey(Point([187, 135, 191, 30, 235, 108, 57, 199, 144, 94, 230, 140, 93, 25, 64, 174, 63, 86, 74, 74, 199, 109, 104, 170, 13, 50, 184, 197, 170, 100, 77, 55])), SecretKey(Scalar([5, 227, 102, 67, 48, 238, 94, 115, 238, 74, 186, 202, 122, 64, 85, 92, 254, 217, 205, 192, 17, 93, 77, 14, 41, 175, 125, 25, 234, 165, 243, 14])));
/// AD: boa1xzad00g0td5vjrkhrjtmr64txu7pny367xjq60d4y8amjmv53nzyc2gsf76
static immutable AD = KeyPair(PublicKey(Point([186, 215, 189, 15, 91, 104, 201, 14, 215, 28, 151, 177, 234, 171, 55, 60, 25, 146, 58, 241, 164, 13, 61, 181, 33, 251, 185, 109, 148, 140, 196, 76])), SecretKey(Scalar([51, 104, 168, 99, 230, 198, 46, 146, 110, 183, 23, 239, 87, 42, 213, 61, 26, 130, 231, 103, 238, 149, 128, 18, 192, 152, 24, 86, 16, 222, 250, 3])));
/// AE: boa1xrae007pe5kahsqkz63mn8t8cv5ynvvjyvyaa7pml5u4z842ll6xsg53w7u
static immutable AE = KeyPair(PublicKey(Point([251, 151, 191, 193, 205, 45, 219, 192, 22, 22, 163, 185, 157, 103, 195, 40, 73, 177, 146, 35, 9, 222, 248, 59, 253, 57, 81, 30, 170, 255, 244, 104])), SecretKey(Scalar([98, 28, 85, 194, 123, 216, 147, 104, 183, 72, 115, 125, 103, 51, 161, 71, 209, 120, 129, 138, 202, 159, 107, 193, 172, 164, 85, 85, 3, 189, 61, 15])));
/// AF: boa1xpaf00a6fs438fangzjh0qpps6k2fcftkzzgfy3pe8p42t2tu64g7lwntxw
static immutable AF = KeyPair(PublicKey(Point([122, 151, 191, 186, 76, 43, 19, 167, 179, 64, 165, 119, 128, 33, 134, 172, 164, 225, 43, 176, 132, 132, 146, 33, 201, 195, 85, 45, 75, 230, 170, 143])), SecretKey(Scalar([160, 8, 20, 104, 41, 43, 164, 28, 73, 43, 42, 187, 186, 198, 107, 150, 240, 169, 241, 89, 52, 190, 0, 107, 25, 213, 87, 95, 36, 18, 37, 9])));
/// AG: boa1xrag00haycagfe3n8re0lpxzcama4m0n2mcm4gnzxe9ddyuz0rkhwzrr8cp
static immutable AG = KeyPair(PublicKey(Point([250, 135, 190, 253, 38, 58, 132, 230, 51, 56, 242, 255, 132, 194, 199, 119, 218, 237, 243, 86, 241, 186, 162, 98, 54, 74, 214, 147, 130, 120, 237, 119])), SecretKey(Scalar([27, 55, 158, 82, 10, 50, 165, 5, 158, 172, 86, 25, 56, 168, 130, 89, 128, 250, 182, 41, 230, 194, 221, 11, 192, 37, 39, 50, 233, 156, 86, 8])));
/// AH: boa1xpah00hllwzscvszqvmjlwe9hxz205wwsrpzm87gz59en85m85pe6svyakd
static immutable AH = KeyPair(PublicKey(Point([123, 119, 190, 255, 251, 133, 12, 50, 2, 3, 55, 47, 187, 37, 185, 132, 167, 209, 206, 128, 194, 45, 159, 200, 21, 11, 153, 158, 155, 61, 3, 157])), SecretKey(Scalar([122, 248, 193, 76, 179, 125, 98, 41, 67, 115, 89, 91, 193, 141, 44, 61, 216, 84, 211, 156, 131, 147, 200, 253, 198, 14, 234, 224, 98, 129, 40, 11])));
/// AJ: boa1xpaj00zf9a8gn4z32fr64xnm6eu09wr97rvsp6gzklrnaxvefdudw34c37t
static immutable AJ = KeyPair(PublicKey(Point([123, 39, 188, 73, 47, 78, 137, 212, 81, 82, 71, 170, 154, 123, 214, 120, 242, 184, 101, 240, 217, 0, 233, 2, 183, 199, 62, 153, 153, 75, 120, 215])), SecretKey(Scalar([253, 211, 57, 51, 39, 232, 145, 34, 160, 135, 88, 110, 107, 81, 210, 117, 174, 111, 177, 142, 54, 73, 72, 131, 133, 36, 99, 36, 125, 226, 10, 5])));
/// AK: boa1xrak008fl99ra0pfnngza5vmazd5dc3g48vdsvyyuqpujuzesvqp5dr4zrh
static immutable AK = KeyPair(PublicKey(Point([251, 103, 188, 233, 249, 74, 62, 188, 41, 156, 208, 46, 209, 155, 232, 155, 70, 226, 40, 169, 216, 216, 48, 132, 224, 3, 201, 112, 89, 131, 0, 26])), SecretKey(Scalar([125, 247, 185, 24, 172, 26, 9, 134, 162, 63, 221, 64, 172, 17, 40, 89, 48, 26, 50, 218, 94, 87, 176, 142, 217, 83, 128, 120, 21, 250, 60, 4])));
/// AL: boa1xqal00037v9f4u0vjm0xq24x6mhcgurg0sd0rpcmm3seeavhvzd0jk7f4zp
static immutable AL = KeyPair(PublicKey(Point([59, 247, 189, 241, 243, 10, 154, 241, 236, 150, 222, 96, 42, 166, 214, 239, 132, 112, 104, 124, 26, 241, 135, 27, 220, 97, 156, 245, 151, 96, 154, 249])), SecretKey(Scalar([186, 41, 94, 139, 11, 174, 236, 73, 102, 39, 155, 68, 252, 28, 118, 161, 14, 156, 60, 150, 38, 233, 177, 5, 227, 38, 179, 194, 55, 34, 185, 15])));
/// AM: boa1xqam00nfz03mv4jr80c7wr4hd2zqtgezr9kysgjqg3gdz7ygyutvylhhwlx
static immutable AM = KeyPair(PublicKey(Point([59, 183, 190, 105, 19, 227, 182, 86, 67, 59, 241, 231, 14, 183, 106, 132, 5, 163, 34, 25, 108, 72, 34, 64, 68, 80, 209, 120, 136, 39, 22, 194])), SecretKey(Scalar([214, 2, 141, 17, 241, 235, 39, 248, 0, 6, 58, 195, 233, 134, 5, 179, 174, 16, 194, 58, 22, 142, 25, 224, 166, 130, 73, 153, 172, 153, 113, 5])));
/// AN: boa1xqan00lytjh62at6znuf52tqdg9ykv74z6ll7hsnuhkafm63ygc3uqs4xnv
static immutable AN = KeyPair(PublicKey(Point([59, 55, 191, 228, 92, 175, 165, 117, 122, 20, 248, 154, 41, 96, 106, 10, 75, 51, 213, 22, 191, 255, 94, 19, 229, 237, 212, 239, 81, 34, 49, 30])), SecretKey(Scalar([23, 82, 70, 83, 217, 9, 0, 239, 63, 28, 216, 90, 202, 221, 8, 111, 130, 55, 146, 164, 30, 145, 125, 99, 184, 195, 183, 220, 51, 210, 94, 1])));
/// AP: boa1xrap00gy9ttpvhk9hfz5vhwuy430ua7td88exhq2rx9lm3l6sgfeqzaeew9
static immutable AP = KeyPair(PublicKey(Point([250, 23, 189, 4, 42, 214, 22, 94, 197, 186, 69, 70, 93, 220, 37, 98, 254, 119, 203, 105, 207, 147, 92, 10, 25, 139, 253, 199, 250, 130, 19, 144])), SecretKey(Scalar([38, 16, 91, 103, 92, 69, 27, 3, 107, 74, 14, 80, 13, 157, 141, 109, 142, 68, 99, 55, 178, 210, 92, 109, 144, 204, 45, 48, 123, 96, 89, 5])));
/// AQ: boa1xzaq00973gwxst86hm6mxqlgr3vslsywxsfg5j9870r2c7q4kh832mnwxpa
static immutable AQ = KeyPair(PublicKey(Point([186, 7, 188, 190, 138, 28, 104, 44, 250, 190, 245, 179, 3, 232, 28, 89, 15, 192, 142, 52, 18, 138, 72, 167, 243, 198, 172, 120, 21, 181, 207, 21])), SecretKey(Scalar([110, 15, 255, 135, 219, 97, 39, 48, 49, 160, 71, 86, 172, 161, 85, 241, 27, 82, 180, 147, 124, 162, 61, 18, 247, 165, 56, 7, 26, 206, 225, 9])));
/// AR: boa1xzar00gtqpgugvzd99pzg3gs72axf0tc8csqr8dl0e4m0ljkqpn7gnh3jj8
static immutable AR = KeyPair(PublicKey(Point([186, 55, 189, 11, 0, 81, 196, 48, 77, 41, 66, 36, 69, 16, 242, 186, 100, 189, 120, 62, 32, 1, 157, 191, 126, 107, 183, 254, 86, 0, 103, 228])), SecretKey(Scalar([234, 5, 165, 39, 117, 204, 82, 112, 43, 249, 48, 0, 245, 234, 226, 228, 91, 220, 160, 136, 53, 134, 15, 212, 80, 247, 81, 79, 245, 112, 71, 12])));
/// AS: boa1xpas00zgtq3z88ts60k24teuhnq57486lvd7e9tgqwsqnzjaacv9784p9g3
static immutable AS = KeyPair(PublicKey(Point([123, 7, 188, 72, 88, 34, 35, 157, 112, 211, 236, 170, 175, 60, 188, 193, 79, 84, 250, 251, 27, 236, 149, 104, 3, 160, 9, 138, 93, 238, 24, 95])), SecretKey(Scalar([216, 238, 51, 28, 72, 124, 62, 182, 23, 138, 223, 45, 25, 94, 57, 109, 64, 129, 246, 203, 105, 32, 221, 150, 190, 31, 213, 110, 220, 243, 232, 4])));
/// AT: boa1xzat00p6zcr99zx3e58x88ffyfd8rmuregx3rt4m2jrcm0tlq404vk7e5yp
static immutable AT = KeyPair(PublicKey(Point([186, 183, 188, 58, 22, 6, 82, 136, 209, 205, 14, 99, 157, 41, 34, 90, 113, 239, 131, 202, 13, 17, 174, 187, 84, 135, 141, 189, 127, 5, 95, 86])), SecretKey(Scalar([251, 160, 141, 166, 84, 225, 236, 121, 109, 192, 98, 153, 202, 133, 239, 25, 13, 138, 7, 116, 10, 237, 146, 211, 119, 119, 213, 37, 109, 190, 137, 6])));
/// AU: boa1xpau00fyvnzut8v5m4rz7avh9c2teg2tg8gfwqy0dl00mqmf7u8lwl5m03s
static immutable AU = KeyPair(PublicKey(Point([123, 199, 189, 36, 100, 197, 197, 157, 148, 221, 70, 47, 117, 151, 46, 20, 188, 161, 75, 65, 208, 151, 0, 143, 111, 222, 253, 131, 105, 247, 15, 247])), SecretKey(Scalar([186, 73, 189, 233, 247, 83, 236, 241, 14, 215, 206, 44, 240, 220, 205, 70, 195, 249, 144, 69, 189, 105, 80, 187, 68, 33, 17, 133, 55, 247, 101, 7])));
/// AV: boa1xpav00jh3pd7fryqkn44aldwqd2h9v86zy3vrw4zzlfetpmwd0ltv7tp43k
static immutable AV = KeyPair(PublicKey(Point([122, 199, 190, 87, 136, 91, 228, 140, 128, 180, 235, 94, 253, 174, 3, 85, 114, 176, 250, 17, 34, 193, 186, 162, 23, 211, 149, 135, 110, 107, 254, 182])), SecretKey(Scalar([105, 92, 68, 82, 64, 215, 176, 24, 5, 255, 196, 164, 252, 95, 15, 14, 145, 7, 251, 58, 143, 20, 59, 71, 123, 6, 210, 63, 14, 129, 48, 6])));
/// AW: boa1xzaw003h32js6fsjn8sqzh49pulxfmzjcrq0j8hk5a44tnptm42dc8wxm98
static immutable AW = KeyPair(PublicKey(Point([186, 231, 190, 55, 138, 165, 13, 38, 18, 153, 224, 1, 94, 165, 15, 62, 100, 236, 82, 192, 192, 249, 30, 246, 167, 107, 85, 204, 43, 221, 84, 220])), SecretKey(Scalar([243, 149, 187, 2, 173, 57, 199, 107, 73, 131, 73, 185, 193, 53, 97, 21, 110, 220, 82, 234, 151, 105, 205, 234, 179, 19, 194, 52, 57, 198, 85, 2])));
/// AX: boa1xrax00verg7nke9wq7ay6hfydrv759650775kpg84jfez3l49927kk85qgt
static immutable AX = KeyPair(PublicKey(Point([250, 103, 189, 153, 26, 61, 59, 100, 174, 7, 186, 77, 93, 36, 104, 217, 234, 23, 84, 127, 189, 75, 5, 7, 172, 147, 145, 71, 245, 41, 85, 235])), SecretKey(Scalar([235, 239, 238, 120, 65, 200, 140, 49, 247, 119, 177, 173, 212, 79, 37, 178, 203, 13, 32, 109, 216, 49, 163, 254, 54, 40, 13, 64, 145, 73, 40, 5])));
/// AY: boa1xqay00ds2js5hgnyhadr7jehhpp5av7y7wa8lzvsar8aagwm9rhvkjz7n48
static immutable AY = KeyPair(PublicKey(Point([58, 71, 189, 176, 84, 161, 75, 162, 100, 191, 90, 63, 75, 55, 184, 67, 78, 179, 196, 243, 186, 127, 137, 144, 232, 207, 222, 161, 219, 40, 238, 203])), SecretKey(Scalar([67, 100, 47, 119, 251, 131, 120, 232, 164, 185, 183, 166, 225, 51, 20, 9, 73, 209, 142, 146, 113, 123, 237, 228, 104, 1, 51, 169, 57, 239, 135, 6])));
/// AZ: boa1xraz00fk0e2mura8ehelcxqkzdtrcalzy8ddrqnvzjcm48zrydla62vzuct
static immutable AZ = KeyPair(PublicKey(Point([250, 39, 189, 54, 126, 85, 190, 15, 167, 205, 243, 252, 24, 22, 19, 86, 60, 119, 226, 33, 218, 209, 130, 108, 20, 177, 186, 156, 67, 35, 127, 221])), SecretKey(Scalar([16, 207, 238, 162, 169, 252, 125, 201, 96, 245, 206, 126, 34, 101, 48, 25, 238, 118, 48, 121, 35, 188, 150, 155, 99, 33, 142, 112, 49, 232, 76, 0])));
/// CA: boa1xzca00zkzjge2h7sc30d5durkkxeuf2fv9d0q4tyddpn5r8f93dwjdyatgp
static immutable CA = KeyPair(PublicKey(Point([177, 215, 188, 86, 20, 145, 149, 95, 208, 196, 94, 218, 55, 131, 181, 141, 158, 37, 73, 97, 90, 240, 85, 100, 107, 67, 58, 12, 233, 44, 90, 233])), SecretKey(Scalar([222, 246, 56, 247, 42, 42, 12, 126, 252, 144, 10, 58, 78, 184, 142, 161, 80, 40, 67, 252, 157, 117, 10, 23, 246, 176, 252, 246, 251, 236, 213, 3])));
/// CC: boa1xzcc00nzvnd9pap4l88rcl98aw6jf99nf84547h228w8wwz34u9mgdywl0j
static immutable CC = KeyPair(PublicKey(Point([177, 135, 190, 98, 100, 218, 80, 244, 53, 249, 206, 60, 124, 167, 235, 181, 36, 148, 179, 73, 235, 74, 250, 234, 81, 220, 119, 56, 81, 175, 11, 180])), SecretKey(Scalar([219, 169, 147, 20, 94, 115, 13, 130, 127, 44, 245, 254, 30, 96, 96, 116, 153, 241, 178, 245, 219, 51, 210, 85, 218, 138, 20, 124, 219, 57, 123, 11])));
/// CD: boa1xzcd00f8jn36mzppkue6w3gpt2ufevulupaa5a8f9uc0st8uh68jyak7p64
static immutable CD = KeyPair(PublicKey(Point([176, 215, 189, 39, 148, 227, 173, 136, 33, 183, 51, 167, 69, 1, 90, 184, 156, 179, 159, 224, 123, 218, 116, 233, 47, 48, 248, 44, 252, 190, 143, 34])), SecretKey(Scalar([214, 86, 92, 143, 179, 186, 22, 135, 220, 157, 51, 4, 191, 169, 77, 9, 61, 63, 144, 43, 38, 193, 201, 248, 34, 197, 165, 231, 212, 187, 36, 7])));
/// CE: boa1xzce00jfyy7jxukasfx8xndpx2l8mcyf2kmcfrvux9800pdj2670q5htf0e
static immutable CE = KeyPair(PublicKey(Point([177, 151, 190, 73, 33, 61, 35, 114, 221, 130, 76, 115, 77, 161, 50, 190, 125, 224, 137, 85, 183, 132, 141, 156, 49, 78, 247, 133, 178, 86, 188, 240])), SecretKey(Scalar([166, 254, 61, 125, 175, 183, 223, 247, 69, 152, 187, 207, 68, 45, 40, 99, 148, 90, 235, 220, 17, 190, 102, 45, 102, 56, 45, 60, 145, 21, 99, 4])));
/// CF: boa1xpcf00w890489epg7rxmpx6en59w3wmhp2kwunetvgarqh7aszmcx53nct5
static immutable CF = KeyPair(PublicKey(Point([112, 151, 189, 199, 43, 234, 114, 228, 40, 240, 205, 176, 155, 89, 157, 10, 232, 187, 119, 10, 172, 238, 79, 43, 98, 58, 48, 95, 221, 128, 183, 131])), SecretKey(Scalar([27, 193, 25, 148, 34, 62, 213, 25, 109, 40, 191, 13, 143, 51, 112, 161, 104, 213, 107, 219, 235, 116, 96, 86, 185, 146, 162, 56, 157, 180, 2, 7])));
/// CG: boa1xpcg002968u7jf3c9atw8l37dfpcstjy65z2rnsw5u6vf7hsnnzdv7lwfnq
static immutable CG = KeyPair(PublicKey(Point([112, 135, 189, 69, 209, 249, 233, 38, 56, 47, 86, 227, 254, 62, 106, 67, 136, 46, 68, 213, 4, 161, 206, 14, 167, 52, 196, 250, 240, 156, 196, 214])), SecretKey(Scalar([234, 12, 53, 136, 30, 41, 51, 194, 71, 177, 243, 48, 61, 192, 223, 235, 107, 246, 203, 236, 102, 154, 130, 16, 143, 6, 217, 120, 132, 146, 74, 14])));
/// CH: boa1xqch00vpknchgg3maayw8ymyk86f9myz9w0rwxdqe62ckh3ykzu9chjvj5m
static immutable CH = KeyPair(PublicKey(Point([49, 119, 189, 129, 180, 241, 116, 34, 59, 239, 72, 227, 147, 100, 177, 244, 146, 236, 130, 43, 158, 55, 25, 160, 206, 149, 139, 94, 36, 176, 184, 92])), SecretKey(Scalar([100, 128, 163, 153, 127, 70, 89, 24, 35, 44, 64, 53, 210, 181, 170, 85, 242, 196, 243, 46, 252, 215, 98, 203, 250, 50, 162, 37, 32, 133, 142, 6])));
/// CJ: boa1xqcj00xwz7e6mxg5p324m98enc7j2a727ty9p7jqf6aezvfps4f8xtg5mal
static immutable CJ = KeyPair(PublicKey(Point([49, 39, 188, 206, 23, 179, 173, 153, 20, 12, 85, 93, 148, 249, 158, 61, 37, 119, 202, 242, 200, 80, 250, 64, 78, 187, 145, 49, 33, 133, 82, 115])), SecretKey(Scalar([165, 197, 37, 47, 201, 189, 96, 184, 74, 143, 219, 152, 241, 207, 92, 30, 31, 159, 252, 250, 221, 215, 208, 45, 226, 95, 103, 21, 183, 251, 220, 7])));
/// CK: boa1xzck00rqy608ptstcht3dtuttkrmg8ahnrwy3vxlutyls2lp3rgn7cusnk2
static immutable CK = KeyPair(PublicKey(Point([177, 103, 188, 96, 38, 158, 112, 174, 11, 197, 215, 22, 175, 139, 93, 135, 180, 31, 183, 152, 220, 72, 176, 223, 226, 201, 248, 43, 225, 136, 209, 63])), SecretKey(Scalar([143, 203, 27, 188, 235, 127, 115, 214, 236, 119, 184, 64, 202, 147, 125, 66, 41, 12, 234, 47, 219, 65, 137, 37, 232, 198, 251, 92, 220, 56, 56, 4])));
/// CL: boa1xzcl0065ptcctj62vzv6xyhaah3e97jktmzg9f4pl36x7trr2ku873l4pgf
static immutable CL = KeyPair(PublicKey(Point([177, 247, 191, 84, 10, 241, 133, 203, 74, 96, 153, 163, 18, 253, 237, 227, 146, 250, 86, 94, 196, 130, 166, 161, 252, 116, 111, 44, 99, 85, 184, 127])), SecretKey(Scalar([185, 12, 116, 40, 22, 19, 138, 109, 98, 101, 165, 60, 25, 83, 6, 97, 41, 210, 240, 87, 208, 121, 93, 135, 201, 136, 144, 9, 60, 43, 89, 13])));
/// CM: boa1xzcm00nywe7x9tr9uep8739st9uwz293n749032fsh8dnjtxt3n6ghpqu6q
static immutable CM = KeyPair(PublicKey(Point([177, 183, 190, 100, 118, 124, 98, 172, 101, 230, 66, 127, 68, 176, 89, 120, 225, 40, 177, 159, 170, 87, 197, 73, 133, 206, 217, 201, 102, 92, 103, 164])), SecretKey(Scalar([191, 56, 125, 188, 210, 141, 27, 129, 81, 136, 22, 221, 97, 81, 230, 59, 230, 222, 122, 44, 117, 252, 136, 48, 123, 199, 167, 55, 7, 49, 79, 8])));
/// CN: boa1xqcn007rdezmmqlw9nt77jtrkm48h7n78tycl7rgmcwt92k0yg75vpmvj2h
static immutable CN = KeyPair(PublicKey(Point([49, 55, 191, 195, 110, 69, 189, 131, 238, 44, 215, 239, 73, 99, 182, 234, 123, 250, 126, 58, 201, 143, 248, 104, 222, 28, 178, 170, 207, 34, 61, 70])), SecretKey(Scalar([49, 228, 170, 132, 26, 187, 182, 81, 89, 251, 51, 91, 128, 5, 255, 113, 161, 53, 185, 49, 103, 187, 92, 53, 98, 239, 29, 36, 222, 64, 63, 10])));
/// CP: boa1xzcp004fmz534clzk23u3vqa03z7n432wf67rpsrxs6x5gzxm97ykl52436
static immutable CP = KeyPair(PublicKey(Point([176, 23, 190, 169, 216, 169, 26, 227, 226, 178, 163, 200, 176, 29, 124, 69, 233, 214, 42, 114, 117, 225, 134, 3, 52, 52, 106, 32, 70, 217, 124, 75])), SecretKey(Scalar([214, 50, 204, 87, 244, 211, 128, 78, 176, 108, 128, 14, 157, 209, 181, 9, 95, 2, 79, 60, 166, 71, 70, 234, 99, 39, 134, 209, 85, 7, 195, 5])));
/// CQ: boa1xpcq00pz4md60d06vukmw8mj7xseslt3spu7sp6daz36dt7eg5q35m8ehhc
static immutable CQ = KeyPair(PublicKey(Point([112, 7, 188, 34, 174, 219, 167, 181, 250, 103, 45, 183, 31, 114, 241, 161, 152, 125, 113, 128, 121, 232, 7, 77, 232, 163, 166, 175, 217, 69, 1, 26])), SecretKey(Scalar([103, 10, 23, 147, 131, 226, 78, 153, 84, 216, 60, 68, 9, 187, 232, 114, 249, 97, 173, 193, 49, 140, 232, 205, 99, 113, 255, 94, 31, 66, 224, 5])));
/// CR: boa1xpcr00mgq8muds4drcfuwazut02scrscnrkdyu7c6r674zzfmlv8qkj0mq7
static immutable CR = KeyPair(PublicKey(Point([112, 55, 191, 104, 1, 247, 198, 194, 173, 30, 19, 199, 116, 92, 91, 213, 12, 14, 24, 152, 236, 210, 115, 216, 208, 245, 234, 136, 73, 223, 216, 112])), SecretKey(Scalar([35, 235, 21, 140, 183, 218, 59, 252, 44, 141, 247, 120, 195, 188, 20, 48, 155, 35, 163, 136, 167, 14, 181, 44, 137, 213, 37, 9, 152, 116, 133, 4])));
/// CS: boa1xqcs00zfel327tv0gxcgy843wxsx3emg483wnfx95wnu6kjet3epc8402lz
static immutable CS = KeyPair(PublicKey(Point([49, 7, 188, 73, 207, 226, 175, 45, 143, 65, 176, 130, 30, 177, 113, 160, 104, 231, 104, 169, 226, 233, 164, 197, 163, 167, 205, 90, 89, 92, 114, 28])), SecretKey(Scalar([85, 229, 9, 161, 86, 25, 248, 206, 241, 53, 200, 213, 146, 62, 145, 195, 15, 45, 247, 106, 42, 146, 45, 51, 197, 217, 89, 42, 228, 42, 154, 9])));
/// CT: boa1xpct00yh5vjsmwa0p9xxeue772zkjxa5j8jl4mg9y5jx2eyzk6uaczgtlgt
static immutable CT = KeyPair(PublicKey(Point([112, 183, 188, 151, 163, 37, 13, 187, 175, 9, 76, 108, 243, 62, 242, 133, 105, 27, 180, 145, 229, 250, 237, 5, 37, 36, 101, 100, 130, 182, 185, 220])), SecretKey(Scalar([206, 233, 154, 2, 183, 135, 63, 0, 140, 222, 223, 194, 58, 109, 74, 32, 110, 195, 233, 173, 192, 145, 139, 209, 143, 45, 233, 176, 125, 218, 106, 6])));
/// CU: boa1xqcu00f4wcvh4l6f7cxxwwsu0ajdrlnt8rlwlh9d7udua7hjeeuxz2dzne4
static immutable CU = KeyPair(PublicKey(Point([49, 199, 189, 53, 118, 25, 122, 255, 73, 246, 12, 103, 58, 28, 127, 100, 209, 254, 107, 56, 254, 239, 220, 173, 247, 27, 206, 250, 242, 206, 120, 97])), SecretKey(Scalar([94, 51, 155, 192, 176, 52, 22, 156, 169, 22, 143, 66, 66, 81, 239, 218, 168, 189, 238, 74, 204, 143, 189, 77, 221, 153, 89, 21, 57, 55, 216, 3])));
/// CV: boa1xpcv00ekj9s8g9f2vdkv85s6njnpcu9hvww0ppr56xzqky6a403ru8spdes
static immutable CV = KeyPair(PublicKey(Point([112, 199, 191, 54, 145, 96, 116, 21, 42, 99, 108, 195, 210, 26, 156, 166, 28, 112, 183, 99, 156, 240, 132, 116, 209, 132, 11, 19, 93, 171, 226, 62])), SecretKey(Scalar([247, 148, 158, 1, 52, 104, 185, 252, 202, 207, 218, 39, 231, 249, 202, 123, 115, 152, 137, 210, 153, 230, 118, 138, 150, 193, 1, 7, 233, 30, 189, 7])));
/// CW: boa1xqcw00qe0yvjxul3dqh9c824ae39f8mv888zkuqjfmj8vfkdnuv8juuqesy
static immutable CW = KeyPair(PublicKey(Point([48, 231, 188, 25, 121, 25, 35, 115, 241, 104, 46, 92, 29, 85, 238, 98, 84, 159, 108, 57, 206, 43, 112, 18, 78, 228, 118, 38, 205, 159, 24, 121])), SecretKey(Scalar([230, 176, 61, 40, 121, 31, 97, 188, 48, 70, 184, 67, 76, 183, 228, 54, 96, 189, 194, 230, 52, 187, 5, 36, 200, 64, 121, 3, 59, 78, 104, 14])));
/// CX: boa1xzcx009ad7kyxxcmhug8afwh6jccsrn7nqgmcp04m5sk6g5nhwqsy6c8avy
static immutable CX = KeyPair(PublicKey(Point([176, 103, 188, 189, 111, 172, 67, 27, 27, 191, 16, 126, 165, 215, 212, 177, 136, 14, 126, 152, 17, 188, 5, 245, 221, 33, 109, 34, 147, 187, 129, 2])), SecretKey(Scalar([250, 94, 223, 228, 7, 98, 8, 180, 243, 206, 255, 58, 35, 213, 73, 177, 139, 164, 63, 79, 57, 45, 241, 211, 92, 239, 118, 221, 54, 213, 160, 12])));
/// CY: boa1xqcy007z3nnh68cxc48f5r283zg985cww8nv6ldlcjnrduukq8l5jz3fff4
static immutable CY = KeyPair(PublicKey(Point([48, 71, 191, 194, 140, 231, 125, 31, 6, 197, 78, 154, 13, 71, 136, 144, 83, 211, 14, 113, 230, 205, 125, 191, 196, 166, 54, 243, 150, 1, 255, 73])), SecretKey(Scalar([132, 226, 87, 66, 148, 119, 64, 52, 137, 67, 191, 142, 193, 198, 240, 205, 161, 244, 53, 171, 58, 26, 217, 148, 93, 32, 100, 26, 78, 84, 247, 4])));
/// CZ: boa1xpcz00vl3593shhapmmramduzkh7dttn6klrrmrxlw0tsmpys4h8gsp7ryc
static immutable CZ = KeyPair(PublicKey(Point([112, 39, 189, 159, 141, 11, 24, 94, 253, 14, 246, 62, 237, 188, 21, 175, 230, 173, 115, 213, 190, 49, 236, 102, 251, 158, 184, 108, 36, 133, 110, 116])), SecretKey(Scalar([122, 242, 19, 103, 68, 131, 151, 194, 231, 186, 166, 154, 132, 242, 243, 26, 251, 243, 101, 145, 10, 250, 142, 36, 201, 165, 243, 239, 98, 73, 245, 15])));
/// DA: boa1xrda008g08ffz736fkxsm9wfllhprs4wp7w8zxkh4ky06axa2u2qch8ya03
static immutable DA = KeyPair(PublicKey(Point([219, 215, 188, 232, 121, 210, 145, 122, 58, 77, 141, 13, 149, 201, 255, 238, 17, 194, 174, 15, 156, 113, 26, 215, 173, 136, 253, 116, 221, 87, 20, 12])), SecretKey(Scalar([154, 122, 75, 127, 160, 12, 154, 61, 75, 11, 52, 81, 9, 54, 46, 233, 179, 194, 178, 107, 1, 66, 174, 225, 43, 74, 60, 213, 238, 48, 50, 14])));
/// DC: boa1xrdc003e0yjaz8jktc35jct5acfghq7dwr0apu0pa2n2rsspuefwqeagxz6
static immutable DC = KeyPair(PublicKey(Point([219, 135, 190, 57, 121, 37, 209, 30, 86, 94, 35, 73, 97, 116, 238, 18, 139, 131, 205, 112, 223, 208, 241, 225, 234, 166, 161, 194, 1, 230, 82, 224])), SecretKey(Scalar([116, 206, 77, 30, 185, 56, 189, 171, 182, 82, 7, 80, 119, 139, 85, 217, 214, 160, 170, 90, 165, 106, 219, 222, 150, 201, 196, 160, 129, 123, 31, 14])));
/// DD: boa1xpdd00xpjxdlvq634pfn47lwz9pa0wslst30kvq809gv3ysdayfagnrmc2f
static immutable DD = KeyPair(PublicKey(Point([90, 215, 188, 193, 145, 155, 246, 3, 81, 168, 83, 58, 251, 238, 17, 67, 215, 186, 31, 130, 226, 251, 48, 7, 121, 80, 200, 146, 13, 233, 19, 212])), SecretKey(Scalar([70, 237, 94, 86, 85, 248, 118, 82, 217, 253, 110, 131, 87, 161, 228, 218, 207, 156, 27, 168, 117, 222, 59, 158, 32, 151, 222, 57, 235, 105, 188, 0])));
/// DE: boa1xzde00jwwhheuve4kt9ffqyf7ddenxkuxr4xtphwshytp353usp2y2mt62d
static immutable DE = KeyPair(PublicKey(Point([155, 151, 190, 78, 117, 239, 158, 51, 53, 178, 202, 148, 128, 137, 243, 91, 153, 154, 220, 48, 234, 101, 134, 238, 133, 200, 176, 198, 145, 228, 2, 162])), SecretKey(Scalar([1, 201, 173, 239, 29, 67, 180, 55, 16, 227, 11, 222, 119, 247, 82, 140, 65, 25, 27, 0, 92, 76, 230, 229, 172, 96, 57, 165, 150, 85, 96, 8])));
/// DF: boa1xrdf00ktakh4rcfqm77k85hljdx4nlych2jj6jfa7l6mhmadwa9cqc9c9l4
static immutable DF = KeyPair(PublicKey(Point([218, 151, 190, 203, 237, 175, 81, 225, 32, 223, 189, 99, 210, 255, 147, 77, 89, 252, 152, 186, 165, 45, 73, 61, 247, 245, 187, 239, 173, 119, 75, 128])), SecretKey(Scalar([154, 67, 112, 50, 130, 85, 124, 209, 224, 128, 192, 87, 165, 162, 146, 142, 106, 227, 13, 34, 178, 31, 92, 119, 34, 155, 253, 155, 45, 82, 48, 3])));
/// DG: boa1xrdg00us6nwnwtlhwfxrduz7jvjncj0hj6vpyhez4swgh5ntxnd3zhd99wh
static immutable DG = KeyPair(PublicKey(Point([218, 135, 191, 144, 212, 221, 55, 47, 247, 114, 76, 54, 240, 94, 147, 37, 60, 73, 247, 150, 152, 18, 95, 34, 172, 28, 139, 210, 107, 52, 219, 17])), SecretKey(Scalar([24, 169, 4, 215, 180, 172, 72, 22, 250, 192, 132, 47, 79, 153, 58, 101, 133, 118, 210, 140, 219, 69, 242, 171, 127, 189, 39, 165, 19, 109, 135, 5])));
/// DH: boa1xqdh00q9yz3c8gwewtgdsmm42ve5zwrj8sxytsw05g3z057vt2kfgj3nl6r
static immutable DH = KeyPair(PublicKey(Point([27, 119, 188, 5, 32, 163, 131, 161, 217, 114, 208, 216, 111, 117, 83, 51, 65, 56, 114, 60, 12, 69, 193, 207, 162, 34, 39, 211, 204, 90, 172, 148])), SecretKey(Scalar([4, 175, 250, 62, 29, 71, 135, 34, 8, 227, 42, 236, 99, 181, 109, 98, 218, 219, 177, 113, 166, 183, 113, 0, 142, 34, 161, 218, 129, 52, 140, 15])));
/// DJ: boa1xrdj000ssr3v53uqt2lp73lexfytwypedggctr0dtvjctn8t8enuzvh5wa4
static immutable DJ = KeyPair(PublicKey(Point([219, 39, 189, 240, 128, 226, 202, 71, 128, 90, 190, 31, 71, 249, 50, 72, 183, 16, 57, 106, 17, 133, 141, 237, 91, 37, 133, 204, 235, 62, 103, 193])), SecretKey(Scalar([5, 56, 20, 106, 76, 187, 215, 109, 214, 80, 1, 164, 111, 173, 49, 42, 204, 226, 162, 39, 61, 78, 93, 113, 111, 101, 243, 58, 25, 209, 7, 4])));
/// DK: boa1xrdk008k4q94wfgadm3prcg4zyuey9taljqhnsdxz53xj2d2thvkxrfts04
static immutable DK = KeyPair(PublicKey(Point([219, 103, 188, 246, 168, 11, 87, 37, 29, 110, 226, 17, 225, 21, 17, 57, 146, 21, 125, 252, 129, 121, 193, 166, 21, 34, 105, 41, 170, 93, 217, 99])), SecretKey(Scalar([134, 70, 62, 159, 82, 250, 19, 33, 244, 240, 67, 214, 187, 233, 89, 67, 148, 97, 6, 31, 222, 101, 230, 49, 195, 150, 133, 198, 33, 25, 242, 14])));
/// DL: boa1xzdl00w6mgv5lcck9sleafxa8lj6qe7lapvgfrlrk6322nx8j67pwl07mh0
static immutable DL = KeyPair(PublicKey(Point([155, 247, 189, 218, 218, 25, 79, 227, 22, 44, 63, 158, 164, 221, 63, 229, 160, 103, 223, 232, 88, 132, 143, 227, 182, 162, 165, 76, 199, 150, 188, 23])), SecretKey(Scalar([15, 17, 88, 176, 253, 3, 69, 165, 186, 245, 135, 68, 88, 63, 53, 36, 234, 250, 190, 75, 69, 31, 69, 38, 206, 102, 152, 225, 75, 30, 109, 12])));
/// DM: boa1xpdm005hly332hrx8jaf7esegrpu263chgskghzkwak6rs4u29avq4m8p4g
static immutable DM = KeyPair(PublicKey(Point([91, 183, 190, 151, 249, 35, 21, 92, 102, 60, 186, 159, 102, 25, 64, 195, 197, 106, 56, 186, 33, 100, 92, 86, 119, 109, 161, 194, 188, 81, 122, 192])), SecretKey(Scalar([203, 154, 136, 198, 239, 167, 31, 165, 90, 12, 25, 121, 148, 6, 186, 81, 160, 226, 0, 42, 111, 37, 141, 172, 117, 231, 125, 129, 9, 2, 140, 9])));
/// DN: boa1xqdn00frjpx4elc8pcclsygmd0qnz2hqqdp4q3stpee9laktcjh8cp8r9wf
static immutable DN = KeyPair(PublicKey(Point([27, 55, 189, 35, 144, 77, 92, 255, 7, 14, 49, 248, 17, 27, 107, 193, 49, 42, 224, 3, 67, 80, 70, 11, 14, 114, 95, 246, 203, 196, 174, 124])), SecretKey(Scalar([202, 31, 90, 247, 156, 222, 159, 9, 113, 85, 187, 158, 192, 19, 252, 36, 152, 5, 235, 239, 189, 231, 137, 14, 126, 138, 73, 5, 47, 144, 50, 13])));
/// DP: boa1xzdp004905nhwhgcmr54htn3dzum6qm5hn92y4wem5pj9z2wm5afyv76rn0
static immutable DP = KeyPair(PublicKey(Point([154, 23, 190, 165, 125, 39, 119, 93, 24, 216, 233, 91, 174, 113, 104, 185, 189, 3, 116, 188, 202, 162, 85, 217, 221, 3, 34, 137, 78, 221, 58, 146])), SecretKey(Scalar([138, 38, 5, 66, 134, 200, 234, 104, 144, 186, 197, 121, 106, 213, 145, 160, 151, 92, 25, 70, 144, 210, 12, 225, 104, 222, 51, 17, 17, 131, 15, 7])));
/// DQ: boa1xrdq00mt66xlc294q0624c62tjnhrg0r9sh0nydm7pqxjy6439afsrlcl58
static immutable DQ = KeyPair(PublicKey(Point([218, 7, 191, 107, 214, 141, 252, 40, 181, 3, 244, 170, 227, 74, 92, 167, 113, 161, 227, 44, 46, 249, 145, 187, 240, 64, 105, 19, 85, 137, 122, 152])), SecretKey(Scalar([105, 228, 25, 226, 106, 4, 90, 153, 52, 102, 251, 189, 251, 89, 30, 228, 233, 5, 254, 220, 35, 111, 80, 239, 249, 120, 136, 120, 70, 146, 99, 7])));
/// DR: boa1xrdr003xcf6wump55mnt75s7n2cyv44xn2yk52va76vmfdgyxspn5wfuexd
static immutable DR = KeyPair(PublicKey(Point([218, 55, 190, 38, 194, 116, 238, 108, 52, 166, 230, 191, 82, 30, 154, 176, 70, 86, 166, 154, 137, 106, 41, 157, 246, 153, 180, 181, 4, 52, 3, 58])), SecretKey(Scalar([70, 70, 104, 147, 143, 232, 219, 50, 206, 186, 208, 92, 106, 77, 255, 71, 134, 46, 56, 45, 7, 52, 87, 112, 96, 178, 40, 4, 38, 181, 226, 15])));
/// DS: boa1xpds0074zuqj8w3v6zlssug4vx2l3kxth3gxx8v8gu4qu7t7qq57suxutzt
static immutable DS = KeyPair(PublicKey(Point([91, 7, 191, 213, 23, 1, 35, 186, 44, 208, 191, 8, 113, 21, 97, 149, 248, 216, 203, 188, 80, 99, 29, 135, 71, 42, 14, 121, 126, 0, 41, 232])), SecretKey(Scalar([244, 101, 105, 14, 203, 231, 120, 23, 203, 208, 242, 118, 182, 35, 31, 18, 217, 93, 200, 15, 57, 125, 70, 253, 243, 20, 80, 96, 122, 150, 124, 6])));
/// DT: boa1xzdt00cfuwz6lj43h2keejt0daaw58jqfyap93ugu0els3uz4fxqzu8qcy3
static immutable DT = KeyPair(PublicKey(Point([154, 183, 191, 9, 227, 133, 175, 202, 177, 186, 173, 156, 201, 111, 111, 122, 234, 30, 64, 73, 58, 18, 199, 136, 227, 243, 248, 71, 130, 170, 76, 1])), SecretKey(Scalar([31, 140, 143, 149, 47, 247, 221, 153, 12, 231, 196, 229, 191, 101, 239, 91, 40, 205, 222, 35, 159, 48, 210, 82, 38, 142, 111, 215, 3, 110, 211, 14])));
/// DU: boa1xzdu0085nhmq6c7kxp83etcx57tpp53lf8zqdehs0gnedntzlf9f5kte933
static immutable DU = KeyPair(PublicKey(Point([155, 199, 188, 244, 157, 246, 13, 99, 214, 48, 79, 28, 175, 6, 167, 150, 16, 210, 63, 73, 196, 6, 230, 240, 122, 39, 150, 205, 98, 250, 74, 154])), SecretKey(Scalar([242, 24, 141, 157, 104, 221, 231, 188, 12, 3, 36, 16, 5, 122, 215, 242, 153, 194, 250, 69, 83, 225, 249, 75, 146, 121, 29, 239, 47, 30, 89, 0])));
/// DV: boa1xrdv00w4hu7lj35kjtee2qz5trh5eldx6lfxln6a6u92s0mnammfyu8tjnk
static immutable DV = KeyPair(PublicKey(Point([218, 199, 189, 213, 191, 61, 249, 70, 150, 146, 243, 149, 0, 84, 88, 239, 76, 253, 166, 215, 210, 111, 207, 93, 215, 10, 168, 63, 115, 238, 246, 146])), SecretKey(Scalar([95, 146, 198, 114, 100, 155, 70, 173, 7, 94, 194, 114, 187, 16, 236, 127, 72, 87, 158, 22, 204, 152, 166, 187, 96, 241, 10, 13, 235, 186, 94, 14])));
/// DW: boa1xrdw00322humjpx9jh94cgljwhd8xrf9ha696z2adwnzrlg7ktvfjldka8r
static immutable DW = KeyPair(PublicKey(Point([218, 231, 190, 42, 85, 249, 185, 4, 197, 149, 203, 92, 35, 242, 117, 218, 115, 13, 37, 191, 116, 93, 9, 93, 107, 166, 33, 253, 30, 178, 216, 153])), SecretKey(Scalar([180, 117, 33, 69, 66, 68, 99, 176, 73, 83, 225, 119, 237, 239, 158, 131, 236, 162, 135, 11, 137, 29, 218, 191, 238, 46, 222, 118, 76, 191, 155, 5])));
/// DX: boa1xzdx00ch38g8t6kue8qdrdf9d86fvmq9ypczdjfypl8cc2u6l7ecvehkdf2
static immutable DX = KeyPair(PublicKey(Point([154, 103, 191, 23, 137, 208, 117, 234, 220, 201, 192, 209, 181, 37, 105, 244, 150, 108, 5, 32, 112, 38, 201, 36, 15, 207, 140, 43, 154, 255, 179, 134])), SecretKey(Scalar([35, 14, 158, 245, 9, 121, 174, 69, 247, 39, 7, 169, 191, 225, 1, 183, 67, 6, 169, 47, 199, 145, 175, 248, 110, 66, 173, 132, 185, 27, 77, 15])));
/// DY: boa1xzdy00st0npp5um6nxmqfh3vdxxtl0fhmlke5qjc22nqukqd86v0shpf8cp
static immutable DY = KeyPair(PublicKey(Point([154, 71, 190, 11, 124, 194, 26, 115, 122, 153, 182, 4, 222, 44, 105, 140, 191, 189, 55, 223, 237, 154, 2, 88, 82, 166, 14, 88, 13, 62, 152, 248])), SecretKey(Scalar([41, 120, 204, 255, 107, 57, 150, 187, 206, 14, 130, 51, 247, 169, 143, 210, 86, 250, 241, 26, 214, 87, 211, 18, 99, 227, 7, 40, 159, 231, 158, 15])));
/// DZ: boa1xpdz00ycfpjyeztac63zhptetjdd8s2xtkcdhdth5qg80hqc22nuqwjazls
static immutable DZ = KeyPair(PublicKey(Point([90, 39, 188, 152, 72, 100, 76, 137, 125, 198, 162, 43, 133, 121, 92, 154, 211, 193, 70, 93, 176, 219, 181, 119, 160, 16, 119, 220, 24, 82, 167, 192])), SecretKey(Scalar([58, 134, 209, 217, 131, 17, 255, 254, 155, 176, 207, 150, 169, 106, 220, 29, 208, 44, 162, 115, 26, 201, 212, 96, 202, 254, 223, 84, 154, 66, 230, 7])));
/// EA: boa1xqea00pyt8elclz3w5agfhe5qusxp8g39tzzgf8dfjcyufplc5sq7tddnfv
static immutable EA = KeyPair(PublicKey(Point([51, 215, 188, 36, 89, 243, 252, 124, 81, 117, 58, 132, 223, 52, 7, 32, 96, 157, 17, 42, 196, 36, 36, 237, 76, 176, 78, 36, 63, 197, 32, 15])), SecretKey(Scalar([66, 157, 154, 65, 224, 185, 25, 89, 95, 146, 197, 226, 174, 83, 119, 50, 103, 199, 237, 25, 195, 138, 104, 255, 107, 128, 174, 163, 215, 124, 249, 11])));
/// EC: boa1xpec00rutd5tacsmtdy6kq9raexjf4xd44p53jxmveu37rmtdhe0c59dx9m
static immutable EC = KeyPair(PublicKey(Point([115, 135, 188, 124, 91, 104, 190, 226, 27, 91, 73, 171, 0, 163, 238, 77, 36, 212, 205, 173, 67, 72, 200, 219, 102, 121, 31, 15, 107, 109, 242, 252])), SecretKey(Scalar([12, 163, 139, 28, 90, 128, 109, 97, 161, 47, 174, 232, 126, 0, 187, 9, 239, 122, 2, 22, 8, 143, 122, 185, 49, 194, 69, 155, 10, 250, 3, 6])));
/// ED: boa1xred00q7drzwdymphlsxqgym636q335dmx3rgkqxft0zemvyxs6vuta4uee
static immutable ED = KeyPair(PublicKey(Point([242, 215, 188, 30, 104, 196, 230, 147, 97, 191, 224, 96, 32, 155, 212, 116, 8, 198, 141, 217, 162, 52, 88, 6, 74, 222, 44, 237, 132, 52, 52, 206])), SecretKey(Scalar([176, 69, 113, 123, 197, 14, 51, 108, 96, 219, 163, 16, 196, 127, 190, 88, 109, 152, 102, 175, 186, 13, 214, 130, 199, 182, 77, 173, 91, 54, 233, 5])));
/// EE: boa1xpee00vdku5kx8j2gwz8uuzla0eedrgrqpprn686nvdw2la7dsnhq9xhve0
static immutable EE = KeyPair(PublicKey(Point([115, 151, 189, 141, 183, 41, 99, 30, 74, 67, 132, 126, 112, 95, 235, 243, 150, 141, 3, 0, 66, 57, 232, 250, 155, 26, 229, 127, 190, 108, 39, 112])), SecretKey(Scalar([145, 194, 188, 64, 191, 215, 104, 87, 29, 171, 221, 86, 65, 63, 142, 114, 75, 72, 41, 49, 22, 249, 82, 224, 124, 64, 186, 221, 201, 58, 225, 1])));
/// EF: boa1xzef00ty4aylnttmunmnacgvxnhv45xu4cn2lv0pck6d5hxlvedac3hjxuu
static immutable EF = KeyPair(PublicKey(Point([178, 151, 189, 100, 175, 73, 249, 173, 123, 228, 247, 62, 225, 12, 52, 238, 202, 208, 220, 174, 38, 175, 177, 225, 197, 180, 218, 92, 223, 102, 91, 220])), SecretKey(Scalar([191, 75, 34, 201, 203, 178, 137, 251, 64, 232, 159, 226, 99, 67, 234, 114, 116, 112, 8, 207, 130, 248, 196, 67, 152, 104, 135, 25, 138, 49, 139, 11])));
/// EG: boa1xreg0088s9r4wh3jymu20fz80lc5gkn53qwkrzyxy8sw76rknreqqknw4ml
static immutable EG = KeyPair(PublicKey(Point([242, 135, 188, 231, 129, 71, 87, 94, 50, 38, 248, 167, 164, 71, 127, 241, 68, 90, 116, 136, 29, 97, 136, 134, 33, 224, 239, 104, 118, 152, 242, 0])), SecretKey(Scalar([44, 21, 150, 149, 82, 112, 65, 237, 155, 120, 117, 170, 133, 250, 243, 45, 160, 88, 152, 183, 209, 141, 61, 165, 151, 51, 243, 158, 173, 129, 79, 9])));
/// EH: boa1xzeh00nk4t8l9tnmsydqlagc8fn2p28lsedgd9qe6994s7cq6jxzg3l4v6p
static immutable EH = KeyPair(PublicKey(Point([179, 119, 190, 118, 170, 207, 242, 174, 123, 129, 26, 15, 245, 24, 58, 102, 160, 168, 255, 134, 90, 134, 148, 25, 209, 75, 88, 123, 0, 212, 140, 36])), SecretKey(Scalar([3, 246, 155, 21, 229, 102, 99, 234, 145, 112, 243, 190, 67, 106, 84, 1, 110, 251, 251, 62, 233, 75, 118, 105, 120, 159, 124, 202, 144, 236, 102, 10])));
/// EJ: boa1xqej00jh50l2me46pkd3dmkpdl6n4ugqss2ev3utuvpuvwhe93l9gjlmxzu
static immutable EJ = KeyPair(PublicKey(Point([51, 39, 190, 87, 163, 254, 173, 230, 186, 13, 155, 22, 238, 193, 111, 245, 58, 241, 0, 132, 21, 150, 71, 139, 227, 3, 198, 58, 249, 44, 126, 84])), SecretKey(Scalar([223, 54, 117, 79, 196, 155, 188, 244, 177, 142, 170, 58, 238, 197, 137, 85, 228, 241, 33, 27, 166, 159, 98, 252, 6, 175, 119, 44, 252, 31, 105, 1])));
/// EK: boa1xrek007nswxza46dpjl6p06lymfuh0c4rcw3nphk8uj9uu6s5cwxufezxwp
static immutable EK = KeyPair(PublicKey(Point([243, 103, 191, 211, 131, 140, 46, 215, 77, 12, 191, 160, 191, 95, 38, 211, 203, 191, 21, 30, 29, 25, 134, 246, 63, 36, 94, 115, 80, 166, 28, 110])), SecretKey(Scalar([197, 252, 44, 210, 32, 54, 161, 3, 198, 96, 118, 77, 160, 21, 224, 4, 101, 163, 7, 186, 121, 93, 88, 237, 45, 42, 157, 55, 206, 9, 192, 12])));
/// EL: boa1xpel00xrdhqpkxaeel48fm2pqsvpwchfc62pfpvcstqlxct3lult283u546
static immutable EL = KeyPair(PublicKey(Point([115, 247, 188, 195, 109, 192, 27, 27, 185, 207, 234, 116, 237, 65, 4, 24, 23, 98, 233, 198, 148, 20, 133, 152, 130, 193, 243, 97, 113, 255, 62, 181])), SecretKey(Scalar([98, 242, 230, 227, 221, 131, 130, 106, 16, 140, 41, 98, 217, 9, 207, 95, 152, 174, 30, 84, 42, 120, 90, 100, 114, 140, 116, 113, 192, 198, 212, 11])));
/// EM: boa1xrem00vnftj99pt9vaur98ut4tz4h75zljsx383nrxdzky6dahxy5dv0pyc
static immutable EM = KeyPair(PublicKey(Point([243, 183, 189, 147, 74, 228, 82, 133, 101, 103, 120, 50, 159, 139, 170, 197, 91, 250, 130, 252, 160, 104, 158, 51, 25, 154, 43, 19, 77, 237, 204, 74])), SecretKey(Scalar([177, 206, 176, 163, 218, 182, 175, 252, 231, 231, 131, 184, 91, 182, 142, 87, 90, 33, 133, 83, 232, 103, 220, 61, 62, 73, 25, 175, 48, 158, 93, 13])));
/// EN: boa1xren00hu862uj5ay62gvd83l652gcjdlmx0umqknj9y8j65stjnlsyjkzj9
static immutable EN = KeyPair(PublicKey(Point([243, 55, 190, 252, 62, 149, 201, 83, 164, 210, 144, 198, 158, 63, 213, 20, 140, 73, 191, 217, 159, 205, 130, 211, 145, 72, 121, 106, 144, 92, 167, 248])), SecretKey(Scalar([211, 128, 60, 139, 154, 112, 169, 119, 195, 3, 190, 150, 63, 15, 76, 147, 242, 99, 115, 169, 33, 76, 140, 195, 209, 156, 197, 82, 93, 218, 241, 4])));
/// EP: boa1xzep00evpkx4f2ljmtc555f06cq4fetrfns34hgc3rfedxswd4rxy5g85my
static immutable EP = KeyPair(PublicKey(Point([178, 23, 191, 44, 13, 141, 84, 171, 242, 218, 241, 74, 81, 47, 214, 1, 84, 229, 99, 76, 225, 26, 221, 24, 136, 211, 150, 154, 14, 109, 70, 98])), SecretKey(Scalar([101, 135, 145, 23, 231, 234, 23, 110, 180, 230, 41, 215, 240, 233, 190, 108, 91, 131, 57, 39, 113, 116, 68, 17, 185, 113, 184, 55, 243, 164, 164, 3])));
/// EQ: boa1xreq00f9e0jwqkgrz5y9e752x9pdf22fmvxp2ef8eem7pmde42rus334t9u
static immutable EQ = KeyPair(PublicKey(Point([242, 7, 189, 37, 203, 228, 224, 89, 3, 21, 8, 92, 250, 138, 49, 66, 212, 169, 73, 219, 12, 21, 101, 39, 206, 119, 224, 237, 185, 170, 135, 200])), SecretKey(Scalar([193, 252, 84, 194, 13, 178, 35, 133, 97, 123, 241, 201, 229, 221, 155, 200, 235, 97, 254, 144, 114, 172, 79, 30, 66, 168, 233, 14, 175, 195, 32, 10])));
/// ER: boa1xrer00je6j3zgcjtgpp2masfkap8e0kjkcev9rp9wz7w46q6zppq67wfln7
static immutable ER = KeyPair(PublicKey(Point([242, 55, 190, 89, 212, 162, 36, 98, 75, 64, 66, 173, 246, 9, 183, 66, 124, 190, 210, 182, 50, 194, 140, 37, 112, 188, 234, 232, 26, 16, 66, 13])), SecretKey(Scalar([64, 234, 93, 191, 89, 122, 73, 13, 197, 250, 49, 139, 251, 114, 0, 13, 55, 96, 33, 152, 229, 226, 160, 249, 219, 163, 57, 50, 228, 175, 21, 5])));
/// ES: boa1xpes00hnn47s02j3hnafw7u39tv4jgr8x4jleqc8hlr83wqsrxhsqk3ftjx
static immutable ES = KeyPair(PublicKey(Point([115, 7, 190, 243, 157, 125, 7, 170, 81, 188, 250, 151, 123, 145, 42, 217, 89, 32, 103, 53, 101, 252, 131, 7, 191, 198, 120, 184, 16, 25, 175, 0])), SecretKey(Scalar([12, 86, 129, 212, 90, 46, 139, 131, 78, 12, 106, 8, 209, 101, 238, 137, 18, 255, 4, 30, 150, 233, 36, 22, 41, 161, 12, 180, 65, 177, 249, 0])));
/// ET: boa1xret004je2fvykr8c6ne5l83q5sdk3ckk7kl95f4f0myshy4jx9pxsf7apf
static immutable ET = KeyPair(PublicKey(Point([242, 183, 190, 178, 202, 146, 194, 88, 103, 198, 167, 154, 124, 241, 5, 32, 219, 71, 22, 183, 173, 242, 209, 53, 75, 246, 72, 92, 149, 145, 138, 19])), SecretKey(Scalar([43, 239, 254, 15, 101, 172, 164, 252, 91, 235, 155, 117, 244, 251, 204, 15, 241, 101, 175, 60, 208, 214, 23, 6, 80, 228, 182, 64, 221, 6, 200, 14])));
/// EU: boa1xqeu00d77e8z9s6qcp9t5xn0f5wefpckf96trxmch2ntkyjdhk4dx73zlr8
static immutable EU = KeyPair(PublicKey(Point([51, 199, 189, 190, 246, 78, 34, 195, 64, 192, 74, 186, 26, 111, 77, 29, 148, 135, 22, 73, 116, 177, 155, 120, 186, 166, 187, 18, 77, 189, 170, 211])), SecretKey(Scalar([34, 122, 99, 124, 123, 154, 11, 120, 28, 122, 166, 153, 29, 134, 140, 106, 110, 163, 91, 7, 73, 86, 155, 178, 144, 63, 100, 117, 235, 8, 99, 3])));
/// EV: boa1xqev000a7nrvlq9jvhp3pn2lvlhh52ez8lymdsj8y5gpl6chwsz6u6tsu4f
static immutable EV = KeyPair(PublicKey(Point([50, 199, 189, 253, 244, 198, 207, 128, 178, 101, 195, 16, 205, 95, 103, 239, 122, 43, 34, 63, 201, 182, 194, 71, 37, 16, 31, 235, 23, 116, 5, 174])), SecretKey(Scalar([76, 7, 123, 209, 226, 62, 238, 12, 225, 208, 250, 218, 222, 39, 233, 107, 147, 148, 12, 134, 253, 31, 104, 147, 192, 18, 109, 17, 36, 247, 20, 8])));
/// EW: boa1xzew00c2pgvw96559qsgj32degt9urxhvmhszp7qp36mtc234jqpk8alr5g
static immutable EW = KeyPair(PublicKey(Point([178, 231, 191, 10, 10, 24, 226, 234, 148, 40, 32, 137, 69, 77, 202, 22, 94, 12, 215, 102, 239, 1, 7, 192, 12, 117, 181, 225, 81, 172, 128, 27])), SecretKey(Scalar([67, 178, 46, 147, 252, 135, 189, 58, 76, 66, 48, 216, 237, 38, 174, 33, 112, 67, 86, 76, 81, 87, 118, 69, 135, 41, 93, 97, 118, 181, 248, 14])));
/// EX: boa1xzex00mhxj3e33l8p0ek56zfly3ul7lt0jvszxrrwy2d000v85fxzu5h4tm
static immutable EX = KeyPair(PublicKey(Point([178, 103, 191, 119, 52, 163, 152, 199, 231, 11, 243, 106, 104, 73, 249, 35, 207, 251, 235, 124, 153, 1, 24, 99, 113, 20, 215, 189, 236, 61, 18, 97])), SecretKey(Scalar([146, 8, 92, 175, 196, 3, 229, 153, 121, 17, 18, 203, 232, 86, 99, 131, 60, 137, 151, 193, 116, 231, 110, 186, 16, 140, 15, 8, 80, 158, 113, 2])));
/// EY: boa1xqey0079077q0r0cy7unj753cdq3rkjjjz680rqj8rs72uw97tuzsjs60qq
static immutable EY = KeyPair(PublicKey(Point([50, 71, 191, 197, 127, 188, 7, 141, 248, 39, 185, 57, 122, 145, 195, 65, 17, 218, 82, 144, 180, 119, 140, 18, 56, 225, 229, 113, 197, 242, 248, 40])), SecretKey(Scalar([55, 58, 86, 200, 151, 22, 141, 175, 49, 20, 80, 94, 92, 226, 194, 136, 92, 189, 59, 76, 237, 77, 118, 228, 144, 216, 222, 143, 2, 143, 97, 3])));
/// EZ: boa1xzez00fngdvj4vk06zxtxc82dkdh4uzrchyrnuuafpwrrw7ajx8h7x7x3m2
static immutable EZ = KeyPair(PublicKey(Point([178, 39, 189, 51, 67, 89, 42, 178, 207, 208, 140, 179, 96, 234, 109, 155, 122, 240, 67, 197, 200, 57, 243, 157, 72, 92, 49, 187, 221, 145, 143, 127])), SecretKey(Scalar([228, 229, 71, 205, 64, 149, 177, 18, 132, 5, 217, 202, 54, 175, 146, 225, 127, 72, 61, 186, 209, 174, 1, 211, 59, 156, 77, 40, 118, 121, 146, 10])));
/// FA: boa1xpfa000hxhjnl7qhwuznlhrhej3fxcu20hkg7qzq5gfeyggxr4fss397n8f
static immutable FA = KeyPair(PublicKey(Point([83, 215, 189, 247, 53, 229, 63, 248, 23, 119, 5, 63, 220, 119, 204, 162, 147, 99, 138, 125, 236, 143, 0, 64, 162, 19, 146, 33, 6, 29, 83, 8])), SecretKey(Scalar([99, 69, 22, 220, 180, 127, 203, 30, 110, 233, 127, 72, 88, 31, 13, 68, 31, 65, 106, 228, 235, 214, 201, 8, 184, 236, 25, 175, 234, 115, 167, 5])));
/// FC: boa1xqfc00syjvnrh45sslyar7067z05836we9maqz05x9897e3qnrduqng96tw
static immutable FC = KeyPair(PublicKey(Point([19, 135, 190, 4, 147, 38, 59, 214, 144, 135, 201, 209, 249, 250, 240, 159, 67, 199, 78, 201, 119, 208, 9, 244, 49, 78, 95, 102, 32, 152, 219, 192])), SecretKey(Scalar([63, 234, 42, 191, 44, 108, 42, 47, 33, 16, 69, 47, 186, 108, 18, 32, 246, 178, 190, 249, 0, 16, 18, 16, 196, 225, 151, 2, 118, 90, 189, 12])));
/// FD: boa1xrfd00664suhpt48473627lehz5zlsjuwyvps9zufr7xgv4glux3qhkkvd2
static immutable FD = KeyPair(PublicKey(Point([210, 215, 191, 90, 172, 57, 112, 174, 167, 175, 163, 165, 123, 249, 184, 168, 47, 194, 92, 113, 24, 24, 20, 92, 72, 252, 100, 50, 168, 255, 13, 16])), SecretKey(Scalar([31, 50, 157, 67, 151, 216, 0, 195, 52, 130, 226, 235, 130, 67, 247, 139, 7, 160, 181, 129, 14, 114, 227, 127, 151, 43, 63, 235, 213, 234, 70, 1])));
/// FE: boa1xrfe00atqxeqsds3lwrltjc8xzqaelwgwjp3trz0gtj5mantz0j9qfkc0k8
static immutable FE = KeyPair(PublicKey(Point([211, 151, 191, 171, 1, 178, 8, 54, 17, 251, 135, 245, 203, 7, 48, 129, 220, 253, 200, 116, 131, 21, 140, 79, 66, 229, 77, 246, 107, 19, 228, 80])), SecretKey(Scalar([197, 41, 245, 2, 182, 26, 103, 4, 47, 210, 247, 167, 101, 237, 44, 175, 205, 92, 50, 102, 115, 25, 220, 246, 34, 99, 217, 61, 19, 179, 250, 6])));
/// FF: boa1xpff00yzve5jwwufgnd942e3kyuetj6zvyqq47xvaxeg8d2tsshuxpdfjkm
static immutable FF = KeyPair(PublicKey(Point([82, 151, 188, 130, 102, 105, 39, 59, 137, 68, 218, 90, 171, 49, 177, 57, 149, 203, 66, 97, 0, 10, 248, 204, 233, 178, 131, 181, 75, 132, 47, 195])), SecretKey(Scalar([186, 3, 40, 199, 134, 245, 218, 148, 118, 90, 95, 8, 161, 159, 67, 100, 151, 250, 230, 65, 60, 211, 156, 39, 142, 251, 58, 27, 55, 14, 155, 10])));
/// FG: boa1xpfg00n0xm2yaa3xxe6v3ndp6us9evukxgp4j3u4nc0kd4lu5dpfgrpeua6
static immutable FG = KeyPair(PublicKey(Point([82, 135, 190, 111, 54, 212, 78, 246, 38, 54, 116, 200, 205, 161, 215, 32, 92, 179, 150, 50, 3, 89, 71, 149, 158, 31, 102, 215, 252, 163, 66, 148])), SecretKey(Scalar([191, 109, 239, 198, 21, 147, 93, 243, 107, 174, 110, 225, 46, 158, 90, 120, 134, 92, 36, 120, 26, 71, 115, 208, 82, 124, 236, 92, 196, 30, 9, 15])));
/// FH: boa1xqfh009dwsmwfwdryggg4lxgsyre0zznrjdaal5n5psuaq9hnmxqwp3e3ze
static immutable FH = KeyPair(PublicKey(Point([19, 119, 188, 173, 116, 54, 228, 185, 163, 34, 16, 138, 252, 200, 129, 7, 151, 136, 83, 28, 155, 222, 254, 147, 160, 97, 206, 128, 183, 158, 204, 7])), SecretKey(Scalar([24, 229, 240, 248, 180, 232, 52, 192, 162, 60, 130, 143, 136, 11, 145, 225, 35, 34, 94, 54, 73, 123, 136, 252, 83, 75, 3, 142, 27, 92, 159, 0])));
/// FJ: boa1xpfj003y4lhngsxzjnk6cx67kh5ltkqd3s0d2s034r5tjkgptjuk56jtryp
static immutable FJ = KeyPair(PublicKey(Point([83, 39, 190, 36, 175, 239, 52, 64, 194, 148, 237, 172, 27, 94, 181, 233, 245, 216, 13, 140, 30, 213, 65, 241, 168, 232, 185, 89, 1, 92, 185, 106])), SecretKey(Scalar([241, 41, 159, 3, 82, 41, 128, 64, 124, 90, 28, 23, 193, 51, 58, 251, 125, 160, 226, 9, 99, 58, 199, 197, 220, 253, 49, 56, 255, 222, 139, 7])));
/// FK: boa1xqfk00x44r9njua77gz424l30mt2wj05pkceg34f5pg5sfqr4fvm6puachy
static immutable FK = KeyPair(PublicKey(Point([19, 103, 188, 213, 168, 203, 57, 115, 190, 242, 5, 85, 87, 241, 126, 214, 167, 73, 244, 13, 177, 148, 70, 169, 160, 81, 72, 36, 3, 170, 89, 189])), SecretKey(Scalar([71, 94, 126, 191, 244, 63, 33, 99, 198, 242, 203, 253, 113, 46, 44, 233, 7, 178, 21, 186, 123, 5, 107, 16, 225, 6, 198, 40, 245, 123, 9, 2])));
/// FL: boa1xrfl00xmyf28jxnnh2g3xvwgqffx4wxh6sdkn5mvqauygtv3vmpwq93vv77
static immutable FL = KeyPair(PublicKey(Point([211, 247, 188, 219, 34, 84, 121, 26, 115, 186, 145, 19, 49, 200, 2, 82, 106, 184, 215, 212, 27, 105, 211, 108, 7, 120, 68, 45, 145, 102, 194, 224])), SecretKey(Scalar([77, 7, 33, 244, 111, 11, 94, 78, 163, 58, 127, 85, 231, 77, 39, 64, 45, 155, 182, 137, 170, 168, 169, 159, 75, 184, 19, 247, 234, 39, 145, 2])));
/// FM: boa1xzfm00ddax760pta9zqr2n7kwzpjc75nrv5mgky2lwrvnnej94hlkzxxy9a
static immutable FM = KeyPair(PublicKey(Point([147, 183, 189, 173, 233, 189, 167, 133, 125, 40, 128, 53, 79, 214, 112, 131, 44, 122, 147, 27, 41, 180, 88, 138, 251, 134, 201, 207, 50, 45, 111, 251])), SecretKey(Scalar([24, 180, 138, 27, 9, 160, 70, 62, 233, 71, 163, 223, 249, 230, 144, 25, 169, 147, 159, 81, 143, 87, 208, 218, 90, 226, 27, 255, 2, 58, 97, 4])));
/// FN: boa1xqfn00yp3myu4jt2se80flcksf9j2nta3t6yvhfh7gugzllkmzwfskczvk5
static immutable FN = KeyPair(PublicKey(Point([19, 55, 188, 129, 142, 201, 202, 201, 106, 134, 78, 244, 255, 22, 130, 75, 37, 77, 125, 138, 244, 70, 93, 55, 242, 56, 129, 127, 246, 216, 156, 152])), SecretKey(Scalar([215, 214, 37, 105, 87, 205, 231, 230, 87, 236, 35, 112, 205, 162, 10, 29, 218, 35, 37, 157, 196, 183, 233, 76, 1, 184, 38, 251, 206, 222, 176, 6])));
/// FP: boa1xpfp00tr86d9zdgv3uy08qs0ld5s3wmx869yte68h3y4erteyn3wkq692jq
static immutable FP = KeyPair(PublicKey(Point([82, 23, 189, 99, 62, 154, 81, 53, 12, 143, 8, 243, 130, 15, 251, 105, 8, 187, 102, 62, 138, 69, 231, 71, 188, 73, 92, 141, 121, 36, 226, 235])), SecretKey(Scalar([58, 189, 43, 99, 241, 9, 230, 123, 151, 139, 76, 54, 225, 91, 4, 253, 80, 22, 50, 16, 39, 219, 205, 212, 214, 99, 2, 142, 18, 132, 248, 6])));
/// FQ: boa1xpfq00t5f0uv8v0wzclvt72fl3x2vz4z48harsx5zdks6m5pecxey9vh4e8
static immutable FQ = KeyPair(PublicKey(Point([82, 7, 189, 116, 75, 248, 195, 177, 238, 22, 62, 197, 249, 73, 252, 76, 166, 10, 162, 169, 239, 209, 192, 212, 19, 109, 13, 110, 129, 206, 13, 146])), SecretKey(Scalar([158, 43, 218, 41, 159, 105, 179, 249, 223, 210, 245, 105, 247, 223, 128, 36, 111, 134, 105, 17, 109, 64, 150, 166, 87, 107, 254, 248, 179, 200, 46, 2])));
/// FR: boa1xpfr005hadezanqmze3f99st3v4n8q3zu0lrzsc3t4mvcj7fnrn7sseah6p
static immutable FR = KeyPair(PublicKey(Point([82, 55, 190, 151, 235, 114, 46, 204, 27, 22, 98, 146, 150, 11, 139, 43, 51, 130, 34, 227, 254, 49, 67, 17, 93, 118, 204, 75, 201, 152, 231, 232])), SecretKey(Scalar([203, 110, 193, 3, 61, 228, 226, 133, 142, 253, 166, 89, 190, 246, 28, 25, 13, 91, 13, 60, 99, 65, 165, 245, 106, 99, 195, 109, 117, 109, 202, 14])));
/// FS: boa1xqfs008pm8f73te5dsys46ewdk3ha5wzlfcz2d6atn2z4nayunp66aelwmr
static immutable FS = KeyPair(PublicKey(Point([19, 7, 188, 225, 217, 211, 232, 175, 52, 108, 9, 10, 235, 46, 109, 163, 126, 209, 194, 250, 112, 37, 55, 93, 92, 212, 42, 207, 164, 228, 195, 173])), SecretKey(Scalar([201, 32, 185, 206, 118, 215, 225, 237, 154, 234, 250, 121, 222, 90, 68, 231, 29, 14, 58, 12, 124, 188, 24, 246, 66, 170, 2, 73, 8, 41, 195, 10])));
/// FT: boa1xrft007petq803lnkk4820l8ya6xpshrl3tg9az8yghejm9t7mwgc8wtgrs
static immutable FT = KeyPair(PublicKey(Point([210, 183, 191, 193, 202, 192, 119, 199, 243, 181, 170, 117, 63, 231, 39, 116, 96, 194, 227, 252, 86, 130, 244, 71, 34, 47, 153, 108, 171, 246, 220, 140])), SecretKey(Scalar([253, 231, 24, 223, 94, 243, 245, 225, 161, 11, 236, 65, 245, 141, 83, 113, 156, 165, 243, 3, 150, 180, 123, 122, 60, 85, 205, 93, 190, 117, 215, 3])));
/// FU: boa1xzfu00gaqcea0j0n4jdmveve4hhwsa264tthyaqrtyx9pu0rrc3rsma3zdy
static immutable FU = KeyPair(PublicKey(Point([147, 199, 189, 29, 6, 51, 215, 201, 243, 172, 155, 182, 101, 153, 173, 238, 232, 117, 90, 170, 215, 114, 116, 3, 89, 12, 80, 241, 227, 30, 34, 56])), SecretKey(Scalar([242, 242, 43, 219, 11, 26, 91, 166, 206, 154, 30, 179, 6, 91, 67, 117, 39, 116, 129, 15, 113, 124, 221, 185, 167, 228, 234, 47, 81, 139, 185, 15])));
/// FV: boa1xzfv00s88ky9mf50nqngvztmnmtjzv4yr0w555aet366ssrv5zqaj6zsga3
static immutable FV = KeyPair(PublicKey(Point([146, 199, 190, 7, 61, 136, 93, 166, 143, 152, 38, 134, 9, 123, 158, 215, 33, 50, 164, 27, 221, 74, 83, 185, 92, 117, 168, 64, 108, 160, 129, 217])), SecretKey(Scalar([235, 211, 233, 148, 253, 251, 76, 134, 184, 249, 211, 145, 108, 222, 172, 127, 141, 213, 117, 156, 60, 240, 114, 96, 121, 9, 220, 54, 249, 124, 187, 12])));
/// FW: boa1xrfw002v36u00c7x32mzqfpg7d7d9a7y6lg77s5jsl7exjcka45n7aek3d4
static immutable FW = KeyPair(PublicKey(Point([210, 231, 189, 76, 142, 184, 247, 227, 198, 138, 182, 32, 36, 40, 243, 124, 210, 247, 196, 215, 209, 239, 66, 146, 135, 253, 147, 75, 22, 237, 105, 63])), SecretKey(Scalar([25, 19, 9, 168, 18, 151, 81, 73, 20, 106, 49, 114, 115, 209, 54, 178, 149, 230, 236, 14, 18, 249, 211, 243, 206, 102, 50, 173, 109, 111, 22, 8])));
/// FX: boa1xrfx00a4kcu5z3ykqe4klf3uqnwauyqzupngpg2f9nh7rharwu657aav5me
static immutable FX = KeyPair(PublicKey(Point([210, 103, 191, 181, 182, 57, 65, 68, 150, 6, 107, 111, 166, 60, 4, 221, 222, 16, 2, 224, 102, 128, 161, 73, 44, 239, 225, 223, 163, 119, 53, 79])), SecretKey(Scalar([154, 160, 54, 23, 15, 126, 81, 184, 195, 160, 67, 118, 54, 40, 211, 202, 204, 114, 64, 113, 225, 94, 235, 158, 153, 93, 214, 115, 8, 40, 42, 1])));
/// FY: boa1xzfy008emrqpm9g6peswqjgt69yte3agnslchljqvkxk9t3defh8ytx59g0
static immutable FY = KeyPair(PublicKey(Point([146, 71, 188, 249, 216, 192, 29, 149, 26, 14, 96, 224, 73, 11, 209, 72, 188, 199, 168, 156, 63, 139, 254, 64, 101, 141, 98, 174, 45, 202, 110, 114])), SecretKey(Scalar([201, 145, 58, 167, 217, 130, 146, 202, 215, 215, 186, 1, 149, 146, 44, 209, 240, 94, 168, 193, 128, 51, 39, 207, 114, 52, 35, 100, 106, 29, 243, 7])));
/// FZ: boa1xrfz00mtqhemyyqgy7cp62spfmjlrn9grht3jmtpp9k22a3s7mdpk94lzl6
static immutable FZ = KeyPair(PublicKey(Point([210, 39, 191, 107, 5, 243, 178, 16, 8, 39, 176, 29, 42, 1, 78, 229, 241, 204, 168, 29, 215, 25, 109, 97, 9, 108, 165, 118, 48, 246, 218, 27])), SecretKey(Scalar([60, 203, 185, 175, 215, 1, 141, 74, 234, 83, 221, 97, 141, 62, 114, 252, 97, 234, 64, 21, 255, 178, 161, 84, 180, 54, 174, 63, 252, 156, 248, 6])));
/// GA: boa1xrga00na8qnq8c0j0mwkrtu43radp3zvqefxdatvzqnrak858c6r6e0fk69
static immutable GA = KeyPair(PublicKey(Point([209, 215, 190, 125, 56, 38, 3, 225, 242, 126, 221, 97, 175, 149, 136, 250, 208, 196, 76, 6, 82, 102, 245, 108, 16, 38, 62, 216, 244, 62, 52, 61])), SecretKey(Scalar([74, 40, 38, 162, 79, 108, 127, 156, 246, 101, 42, 56, 124, 173, 178, 203, 146, 172, 236, 95, 76, 36, 4, 110, 241, 144, 210, 125, 82, 4, 244, 12])));
/// GC: boa1xqgc00exnps6wflt0ue5vjf3509z76y8wn4qzfk3qs7na495q6nh63x6mrl
static immutable GC = KeyPair(PublicKey(Point([17, 135, 191, 38, 152, 97, 167, 39, 235, 127, 51, 70, 73, 49, 163, 202, 47, 104, 135, 116, 234, 1, 38, 209, 4, 61, 62, 212, 180, 6, 167, 125])), SecretKey(Scalar([78, 48, 2, 89, 139, 60, 182, 179, 147, 244, 152, 204, 30, 214, 34, 87, 129, 219, 38, 55, 1, 184, 244, 20, 38, 10, 98, 218, 214, 50, 0, 11])));
/// GD: boa1xzgd00t6x05nhcvduu3m9uz59nxjexfq8kgph26x9ghnzj26epu5wcgww8c
static immutable GD = KeyPair(PublicKey(Point([144, 215, 189, 122, 51, 233, 59, 225, 141, 231, 35, 178, 240, 84, 44, 205, 44, 153, 32, 61, 144, 27, 171, 70, 42, 47, 49, 73, 90, 200, 121, 71])), SecretKey(Scalar([210, 68, 173, 32, 17, 92, 148, 222, 115, 245, 159, 145, 77, 107, 216, 117, 198, 45, 39, 12, 63, 161, 148, 35, 1, 24, 123, 140, 26, 183, 252, 13])));
/// GE: boa1xpge006c0w0uwdf68yyavns68n80aexkswjh5ks5dk2a2rnyp6gazvd0qj5
static immutable GE = KeyPair(PublicKey(Point([81, 151, 191, 88, 123, 159, 199, 53, 58, 57, 9, 214, 78, 26, 60, 206, 254, 228, 214, 131, 165, 122, 90, 20, 109, 149, 213, 14, 100, 14, 145, 209])), SecretKey(Scalar([12, 233, 25, 146, 222, 175, 180, 38, 183, 4, 115, 191, 12, 159, 198, 67, 140, 148, 44, 242, 115, 234, 253, 23, 56, 102, 71, 253, 1, 241, 41, 15])));
/// GF: boa1xqgf003p0uemd2zmfmtsucu6e58vuuc68mvyg834u9vlrnfzt2cmcvhs7qu
static immutable GF = KeyPair(PublicKey(Point([16, 151, 190, 33, 127, 51, 182, 168, 91, 78, 215, 14, 99, 154, 205, 14, 206, 115, 26, 62, 216, 68, 30, 53, 225, 89, 241, 205, 34, 90, 177, 188])), SecretKey(Scalar([89, 195, 42, 61, 94, 129, 252, 85, 127, 169, 86, 58, 14, 228, 240, 4, 169, 73, 245, 126, 241, 16, 5, 67, 37, 40, 56, 33, 5, 26, 51, 13])));
/// GG: boa1xzgg00zdrwnsrsy37e0rszcshvd4l4wmjyjxc4vlevm5zea997vzk5wttdz
static immutable GG = KeyPair(PublicKey(Point([144, 135, 188, 77, 27, 167, 1, 192, 145, 246, 94, 56, 11, 16, 187, 27, 95, 213, 219, 145, 36, 108, 85, 159, 203, 55, 65, 103, 165, 47, 152, 43])), SecretKey(Scalar([15, 86, 160, 130, 18, 8, 169, 159, 65, 49, 233, 32, 73, 68, 93, 41, 25, 192, 248, 90, 68, 135, 150, 149, 105, 126, 42, 149, 206, 90, 210, 7])));
/// GH: boa1xqgh0092ewc7trruh8cau8zh2dn8n880c6ky6cnm6kvr6z9e8n5ckgmh9rw
static immutable GH = KeyPair(PublicKey(Point([17, 119, 188, 170, 203, 177, 229, 140, 124, 185, 241, 222, 28, 87, 83, 102, 121, 156, 239, 198, 172, 77, 98, 123, 213, 152, 61, 8, 185, 60, 233, 139])), SecretKey(Scalar([147, 36, 120, 151, 0, 42, 226, 94, 213, 84, 221, 17, 127, 19, 54, 89, 22, 126, 123, 45, 105, 225, 97, 188, 223, 84, 190, 38, 54, 205, 207, 1])));
/// GJ: boa1xqgj006mdkcr599mffk6np3q62x65gh585enuww280jvkyh6phwgqmxg8jv
static immutable GJ = KeyPair(PublicKey(Point([17, 39, 191, 91, 109, 176, 58, 20, 187, 74, 109, 169, 134, 32, 210, 141, 170, 34, 244, 61, 51, 62, 57, 202, 59, 228, 203, 18, 250, 13, 220, 128])), SecretKey(Scalar([218, 43, 106, 163, 142, 48, 47, 207, 107, 72, 27, 161, 13, 31, 114, 243, 166, 85, 149, 137, 36, 185, 45, 141, 247, 220, 117, 210, 22, 77, 174, 15])));
/// GK: boa1xqgk00z5pvcwqeapdysl7htqzkxsjfftucq4csnjsm0tkc4x6734wyfssg2
static immutable GK = KeyPair(PublicKey(Point([17, 103, 188, 84, 11, 48, 224, 103, 161, 105, 33, 255, 93, 96, 21, 141, 9, 37, 43, 230, 1, 92, 66, 114, 134, 222, 187, 98, 166, 215, 163, 87])), SecretKey(Scalar([5, 35, 70, 108, 141, 149, 246, 224, 26, 191, 107, 129, 65, 248, 160, 40, 159, 141, 23, 201, 139, 116, 56, 178, 151, 92, 160, 197, 46, 163, 134, 13])));
/// GL: boa1xrgl00erwhke35kqwchxznrn3eanlzya3fqzh3qnxq2yjmpte8a0ky73s4k
static immutable GL = KeyPair(PublicKey(Point([209, 247, 191, 35, 117, 237, 152, 210, 192, 118, 46, 97, 76, 115, 142, 123, 63, 136, 157, 138, 64, 43, 196, 19, 48, 20, 73, 108, 43, 201, 250, 251])), SecretKey(Scalar([93, 106, 183, 211, 239, 67, 69, 32, 45, 243, 156, 176, 124, 202, 122, 85, 25, 159, 63, 138, 191, 47, 182, 55, 208, 124, 55, 233, 75, 90, 149, 6])));
/// GM: boa1xrgm00a22xw6hxtzq7z3mp4xwsxjxpzney6cvrer04xjswfqagptce03htk
static immutable GM = KeyPair(PublicKey(Point([209, 183, 191, 170, 81, 157, 171, 153, 98, 7, 133, 29, 134, 166, 116, 13, 35, 4, 83, 201, 53, 134, 15, 35, 125, 77, 40, 57, 32, 234, 2, 188])), SecretKey(Scalar([42, 29, 187, 85, 97, 177, 111, 79, 25, 78, 106, 92, 200, 239, 234, 61, 19, 84, 68, 105, 182, 110, 233, 107, 55, 142, 253, 141, 189, 90, 81, 0])));
/// GN: boa1xzgn00832a38vprs087pn5a8h75vnks2tdgl7lfwmxw9725xvpywsrup9hq
static immutable GN = KeyPair(PublicKey(Point([145, 55, 188, 241, 87, 98, 118, 4, 112, 121, 252, 25, 211, 167, 191, 168, 201, 218, 10, 91, 81, 255, 125, 46, 217, 156, 95, 42, 134, 96, 72, 232])), SecretKey(Scalar([101, 7, 72, 147, 172, 171, 37, 178, 12, 54, 56, 193, 100, 226, 196, 29, 21, 102, 219, 128, 4, 137, 15, 138, 218, 24, 109, 196, 227, 123, 135, 8])));
/// GP: boa1xzgp00calus9agtv9t54jnrq4vesq8a8zas534uvqnc4qfzzq8p2zc850hf
static immutable GP = KeyPair(PublicKey(Point([144, 23, 191, 29, 255, 32, 94, 161, 108, 42, 233, 89, 76, 96, 171, 51, 0, 31, 167, 23, 97, 72, 215, 140, 4, 241, 80, 36, 66, 1, 194, 161])), SecretKey(Scalar([34, 54, 95, 216, 244, 128, 113, 46, 187, 36, 33, 165, 28, 14, 186, 62, 44, 132, 137, 238, 44, 119, 47, 203, 80, 158, 112, 95, 15, 146, 127, 8])));
/// GQ: boa1xpgq00er53wc3l75deg9qm2u099wvke7emqcer4cyalau9wp7xwzqcp6hvj
static immutable GQ = KeyPair(PublicKey(Point([80, 7, 191, 35, 164, 93, 136, 255, 212, 110, 80, 80, 109, 92, 121, 74, 230, 91, 62, 206, 193, 140, 142, 184, 39, 127, 222, 21, 193, 241, 156, 32])), SecretKey(Scalar([44, 118, 27, 177, 79, 187, 33, 20, 75, 21, 225, 79, 53, 139, 162, 122, 128, 234, 35, 21, 180, 220, 120, 51, 188, 137, 249, 26, 152, 4, 80, 9])));
/// GR: boa1xzgr00vkptvd0al5kcfa4qc75jkv82k22tm6ccngp4teq2ght2j77xh9ehx
static immutable GR = KeyPair(PublicKey(Point([144, 55, 189, 150, 10, 216, 215, 247, 244, 182, 19, 218, 131, 30, 164, 172, 195, 170, 202, 82, 247, 172, 98, 104, 13, 87, 144, 41, 23, 90, 165, 239])), SecretKey(Scalar([43, 211, 107, 18, 131, 50, 77, 248, 29, 96, 235, 151, 159, 6, 76, 107, 85, 122, 220, 219, 233, 222, 247, 91, 32, 193, 196, 50, 141, 205, 197, 11])));
/// GS: boa1xpgs00e0udm4ge3sdvkdmerar87vv6g98fnnzd0kqe9xytuwgzuyqs3y3rn
static immutable GS = KeyPair(PublicKey(Point([81, 7, 191, 47, 227, 119, 84, 102, 48, 107, 44, 221, 228, 125, 25, 252, 198, 105, 5, 58, 103, 49, 53, 246, 6, 74, 98, 47, 142, 64, 184, 64])), SecretKey(Scalar([57, 210, 162, 70, 137, 111, 143, 180, 85, 236, 161, 182, 218, 244, 63, 229, 150, 143, 149, 245, 112, 178, 61, 147, 111, 118, 101, 192, 81, 9, 40, 1])));
/// GT: boa1xqgt009yf36yjpymhr47k4lrr3s08p8cfvvsf2cgsmzzdhqp7zjv5aqu3r4
static immutable GT = KeyPair(PublicKey(Point([16, 183, 188, 164, 76, 116, 73, 4, 155, 184, 235, 235, 87, 227, 28, 96, 243, 132, 248, 75, 25, 4, 171, 8, 134, 196, 38, 220, 1, 240, 164, 202])), SecretKey(Scalar([110, 72, 154, 73, 188, 172, 53, 215, 228, 107, 169, 16, 204, 48, 189, 121, 201, 91, 62, 89, 32, 49, 108, 231, 38, 110, 188, 182, 114, 128, 135, 12])));
/// GU: boa1xpgu00zgm09sgta7gmc6r5yc2xchnj82rrna270ah8werefqpnsnj2ff6w2
static immutable GU = KeyPair(PublicKey(Point([81, 199, 188, 72, 219, 203, 4, 47, 190, 70, 241, 161, 208, 152, 81, 177, 121, 200, 234, 24, 231, 213, 121, 253, 185, 221, 145, 229, 32, 12, 225, 57])), SecretKey(Scalar([138, 59, 21, 240, 242, 26, 206, 129, 92, 64, 93, 203, 160, 219, 30, 62, 41, 208, 147, 24, 146, 163, 167, 174, 36, 11, 253, 136, 25, 0, 99, 6])));
/// GV: boa1xrgv00u38pz9hag4uql9wsexvzz8t3e6trxfz9khv8wknmh7xf47qapz8wj
static immutable GV = KeyPair(PublicKey(Point([208, 199, 191, 145, 56, 68, 91, 245, 21, 224, 62, 87, 67, 38, 96, 132, 117, 199, 58, 88, 204, 145, 22, 215, 97, 221, 105, 238, 254, 50, 107, 224])), SecretKey(Scalar([145, 99, 171, 154, 160, 107, 1, 116, 99, 46, 174, 208, 238, 9, 182, 14, 40, 211, 73, 161, 227, 52, 104, 39, 243, 88, 36, 151, 61, 69, 29, 1])));
/// GW: boa1xqgw00puwa97trl34n2zrra77egxf5kdhq7xfrtnarygcgqxxfw0xkh4ffz
static immutable GW = KeyPair(PublicKey(Point([16, 231, 188, 60, 119, 75, 229, 143, 241, 172, 212, 33, 143, 190, 246, 80, 100, 210, 205, 184, 60, 100, 141, 115, 232, 200, 140, 32, 6, 50, 92, 243])), SecretKey(Scalar([122, 149, 155, 111, 31, 139, 151, 140, 15, 217, 254, 37, 66, 124, 36, 61, 246, 241, 34, 138, 243, 192, 179, 4, 25, 4, 135, 239, 61, 189, 172, 13])));
/// GX: boa1xqgx000rfz9zkw3zdyruh98x2qanp8e80qgtwv3frvdt08qvl0p0yktsxrx
static immutable GX = KeyPair(PublicKey(Point([16, 103, 189, 227, 72, 138, 43, 58, 34, 105, 7, 203, 148, 230, 80, 59, 48, 159, 39, 120, 16, 183, 50, 41, 27, 26, 183, 156, 12, 251, 194, 242])), SecretKey(Scalar([202, 32, 17, 178, 209, 250, 199, 167, 69, 145, 166, 181, 13, 105, 154, 117, 219, 126, 43, 10, 195, 238, 36, 189, 64, 17, 52, 43, 179, 180, 103, 15])));
/// GY: boa1xpgy003c9a2epuju3mw2jjpc9vh95j7nccxen37jmy7m9f75zzz3qdcxl3r
static immutable GY = KeyPair(PublicKey(Point([80, 71, 190, 56, 47, 85, 144, 242, 92, 142, 220, 169, 72, 56, 43, 46, 90, 75, 211, 198, 13, 153, 199, 210, 217, 61, 178, 167, 212, 16, 133, 16])), SecretKey(Scalar([11, 248, 19, 201, 4, 62, 90, 205, 16, 17, 206, 56, 40, 158, 138, 236, 30, 226, 235, 233, 119, 12, 101, 22, 98, 117, 226, 126, 242, 163, 86, 1])));
/// GZ: boa1xqgz00x9farwd6ypumu8wenu7262x8rdawcw303sqdllhv0gaa4ysuhhy09
static immutable GZ = KeyPair(PublicKey(Point([16, 39, 188, 197, 79, 70, 230, 232, 129, 230, 248, 119, 102, 124, 242, 180, 163, 28, 109, 235, 176, 232, 190, 48, 3, 127, 251, 177, 232, 239, 106, 72])), SecretKey(Scalar([117, 137, 120, 90, 253, 126, 100, 210, 225, 248, 192, 46, 129, 206, 25, 114, 194, 36, 150, 9, 125, 112, 235, 106, 28, 144, 52, 89, 1, 11, 83, 1])));
/// HA: boa1xrha00tgpk5ws09tfz76r2pdzf33hj382u3gaul4yzfq3xw3kjf4q8q8lu9
static immutable HA = KeyPair(PublicKey(Point([239, 215, 189, 104, 13, 168, 232, 60, 171, 72, 189, 161, 168, 45, 18, 99, 27, 202, 39, 87, 34, 142, 243, 245, 32, 146, 8, 153, 209, 180, 147, 80])), SecretKey(Scalar([19, 71, 122, 226, 241, 25, 194, 175, 186, 152, 85, 132, 31, 157, 127, 89, 186, 92, 220, 36, 149, 53, 210, 233, 14, 76, 180, 0, 97, 100, 251, 9])));
/// HC: boa1xrhc00kjk5r6p70xsayzt0jjs2e2jt0aq2zmf72rwf7zvr53t3kqsecs059
static immutable HC = KeyPair(PublicKey(Point([239, 135, 190, 210, 181, 7, 160, 249, 230, 135, 72, 37, 190, 82, 130, 178, 169, 45, 253, 2, 133, 180, 249, 67, 114, 124, 38, 14, 145, 92, 108, 8])), SecretKey(Scalar([201, 129, 134, 4, 26, 196, 251, 175, 207, 64, 226, 86, 47, 217, 123, 74, 131, 171, 30, 98, 15, 201, 80, 211, 154, 199, 80, 46, 111, 51, 254, 3])));
/// HD: boa1xqhd00z2wxqgnlqr9wgdypdrv92fmz7sfq0wjzsv49yu3a6rtql9v6mfe4c
static immutable HD = KeyPair(PublicKey(Point([46, 215, 188, 74, 113, 128, 137, 252, 3, 43, 144, 210, 5, 163, 97, 84, 157, 139, 208, 72, 30, 233, 10, 12, 169, 73, 200, 247, 67, 88, 62, 86])), SecretKey(Scalar([209, 146, 236, 238, 154, 61, 83, 230, 229, 18, 69, 200, 186, 0, 176, 155, 128, 59, 19, 61, 93, 28, 16, 53, 183, 252, 90, 22, 178, 131, 161, 2])));
/// HE: boa1xrhe005pahwc3435rfharnju4g4tyw466uznaq9e5edzppre08zrkevxdys
static immutable HE = KeyPair(PublicKey(Point([239, 151, 190, 129, 237, 221, 136, 214, 52, 26, 111, 209, 206, 92, 170, 42, 178, 58, 186, 215, 5, 62, 128, 185, 166, 90, 32, 132, 121, 121, 196, 59])), SecretKey(Scalar([158, 175, 77, 16, 122, 230, 143, 247, 210, 49, 128, 206, 158, 74, 102, 236, 50, 82, 72, 242, 173, 70, 97, 199, 45, 182, 9, 220, 112, 233, 224, 11])));
/// HF: boa1xphf00zlza5e6zctt2mya5yrhcrrlrqjswgyalsr4kwcdj74wtmvzz8xzgu
static immutable HF = KeyPair(PublicKey(Point([110, 151, 188, 95, 23, 105, 157, 11, 11, 90, 182, 78, 208, 131, 190, 6, 63, 140, 18, 131, 144, 78, 254, 3, 173, 157, 134, 203, 213, 114, 246, 193])), SecretKey(Scalar([255, 34, 229, 86, 81, 89, 44, 234, 163, 71, 24, 71, 104, 237, 251, 102, 24, 84, 54, 206, 137, 218, 169, 183, 128, 35, 41, 251, 166, 147, 124, 0])));
/// HG: boa1xphg00t6kd2af2gqzteahfw4lkmjxadjt7gn3zx7vhsxw4qhdrlzsqj8a4j
static immutable HG = KeyPair(PublicKey(Point([110, 135, 189, 122, 179, 85, 212, 169, 0, 18, 243, 219, 165, 213, 253, 183, 35, 117, 178, 95, 145, 56, 136, 222, 101, 224, 103, 84, 23, 104, 254, 40])), SecretKey(Scalar([96, 174, 155, 73, 172, 141, 236, 101, 83, 70, 192, 47, 189, 112, 9, 207, 238, 2, 15, 88, 17, 197, 251, 188, 188, 133, 213, 14, 40, 31, 173, 0])));
/// HH: boa1xrhh00jd4vrxr2qj8vrf8tqkagakdm39ym8stkzr2n0rnrun8665w3gtt6j
static immutable HH = KeyPair(PublicKey(Point([239, 119, 190, 77, 171, 6, 97, 168, 18, 59, 6, 147, 172, 22, 234, 59, 102, 238, 37, 38, 207, 5, 216, 67, 84, 222, 57, 143, 147, 62, 181, 71])), SecretKey(Scalar([153, 198, 244, 212, 89, 69, 176, 92, 48, 32, 31, 12, 203, 17, 40, 86, 140, 59, 204, 124, 246, 187, 52, 33, 146, 168, 139, 249, 165, 145, 26, 10])));
/// HJ: boa1xqhj00k749r78aczh2pvg2kvlla88yk9jfqwr3e7z0damtzpku8pkvjqsf5
static immutable HJ = KeyPair(PublicKey(Point([47, 39, 190, 222, 169, 71, 227, 247, 2, 186, 130, 196, 42, 204, 255, 250, 115, 146, 197, 146, 64, 225, 199, 62, 19, 219, 221, 172, 65, 183, 14, 27])), SecretKey(Scalar([22, 6, 10, 187, 93, 156, 3, 255, 60, 112, 119, 168, 213, 88, 142, 207, 195, 27, 100, 51, 104, 188, 163, 116, 127, 149, 87, 82, 13, 114, 146, 0])));
/// HK: boa1xrhk00dece25r8uhfvw5da8qttmgj7md7c48x0heezwls5xrg576wlhmrxl
static immutable HK = KeyPair(PublicKey(Point([239, 103, 189, 185, 198, 85, 65, 159, 151, 75, 29, 70, 244, 224, 90, 246, 137, 123, 109, 246, 42, 115, 62, 249, 200, 157, 248, 80, 195, 69, 61, 167])), SecretKey(Scalar([65, 225, 147, 175, 138, 140, 41, 114, 144, 52, 178, 99, 74, 252, 194, 66, 71, 58, 230, 98, 243, 205, 79, 98, 2, 222, 111, 196, 9, 219, 161, 9])));
/// HL: boa1xzhl00sxjumzamt4xwhfszu4y77a7zvmvfx2n7petkr6e4p33m8e2p6mw3g
static immutable HL = KeyPair(PublicKey(Point([175, 247, 190, 6, 151, 54, 46, 237, 117, 51, 174, 152, 11, 149, 39, 189, 223, 9, 155, 98, 76, 169, 248, 57, 93, 135, 172, 212, 49, 142, 207, 149])), SecretKey(Scalar([131, 37, 117, 80, 31, 13, 226, 35, 50, 254, 70, 185, 222, 87, 98, 28, 165, 169, 207, 32, 8, 191, 138, 163, 75, 35, 147, 82, 103, 249, 157, 14])));
/// HM: boa1xqhm00msfr5j4q4j4x8fcx90qmsva82u0d032cyt7fanggwna26v5m8tds9
static immutable HM = KeyPair(PublicKey(Point([47, 183, 191, 112, 72, 233, 42, 130, 178, 169, 142, 156, 24, 175, 6, 224, 206, 157, 92, 123, 95, 21, 96, 139, 242, 123, 52, 33, 211, 234, 180, 202])), SecretKey(Scalar([170, 168, 141, 225, 167, 53, 94, 154, 95, 136, 36, 18, 249, 88, 52, 53, 237, 92, 116, 222, 5, 140, 56, 250, 72, 205, 7, 33, 49, 165, 181, 6])));
/// HN: boa1xzhn00ts0d3yz4879ks7url90x7dg0rd8n6drajd52r7ttcnkmd9j3djvye
static immutable HN = KeyPair(PublicKey(Point([175, 55, 189, 112, 123, 98, 65, 84, 254, 45, 161, 238, 15, 229, 121, 188, 212, 60, 109, 60, 244, 209, 246, 77, 162, 135, 229, 175, 19, 182, 218, 89])), SecretKey(Scalar([109, 185, 46, 61, 64, 211, 111, 108, 156, 40, 135, 187, 81, 70, 33, 230, 229, 82, 10, 109, 242, 130, 164, 148, 24, 139, 45, 115, 143, 38, 4, 2])));
/// HP: boa1xzhp00uyq6mur980s53qa504scex9lg646ad5gwj4w9j77cgqkj6jkflxnm
static immutable HP = KeyPair(PublicKey(Point([174, 23, 191, 132, 6, 183, 193, 148, 239, 133, 34, 14, 209, 245, 134, 50, 98, 253, 26, 174, 186, 218, 33, 210, 171, 139, 47, 123, 8, 5, 165, 169])), SecretKey(Scalar([28, 90, 77, 236, 248, 94, 233, 55, 117, 12, 233, 189, 171, 49, 139, 233, 249, 67, 34, 54, 115, 162, 71, 135, 77, 105, 79, 118, 194, 121, 232, 8])));
/// HQ: boa1xqhq00zatl6kxga7ny6arsvaxznhzd5hp42d8v0sy48qhcs0ze9lgua7hrc
static immutable HQ = KeyPair(PublicKey(Point([46, 7, 188, 93, 95, 245, 99, 35, 190, 153, 53, 209, 193, 157, 48, 167, 113, 54, 151, 13, 84, 211, 177, 240, 37, 78, 11, 226, 15, 22, 75, 244])), SecretKey(Scalar([55, 147, 181, 74, 191, 136, 111, 35, 59, 92, 143, 63, 153, 181, 221, 235, 252, 104, 227, 110, 15, 58, 56, 153, 16, 168, 100, 249, 28, 156, 44, 13])));
/// HR: boa1xrhr009q28lsfu85mlnwn3wxdn7kh0d4kr5exh08jhzem9yp3272un6yde6
static immutable HR = KeyPair(PublicKey(Point([238, 55, 188, 160, 81, 255, 4, 240, 244, 223, 230, 233, 197, 198, 108, 253, 107, 189, 181, 176, 233, 147, 93, 231, 149, 197, 157, 148, 129, 138, 188, 174])), SecretKey(Scalar([81, 106, 81, 203, 55, 126, 30, 41, 153, 241, 66, 22, 25, 202, 112, 79, 102, 1, 232, 54, 223, 20, 161, 233, 158, 111, 10, 184, 199, 238, 173, 15])));
/// HS: boa1xphs00j34wnv0ersqeyzxrn4mzfa68ntr6hd8jla6xuuzfpu5axgy044696
static immutable HS = KeyPair(PublicKey(Point([111, 7, 190, 81, 171, 166, 199, 228, 112, 6, 72, 35, 14, 117, 216, 147, 221, 30, 107, 30, 174, 211, 203, 253, 209, 185, 193, 36, 60, 167, 76, 130])), SecretKey(Scalar([211, 0, 121, 242, 176, 154, 109, 164, 113, 79, 108, 147, 167, 66, 107, 251, 193, 115, 31, 80, 89, 122, 99, 245, 218, 60, 46, 249, 53, 26, 27, 5])));
/// HT: boa1xpht00ykgm9cc48mxld7f9t2flnaesp4hxu652kvwhqsrc47uktt6catp45
static immutable HT = KeyPair(PublicKey(Point([110, 183, 188, 150, 70, 203, 140, 84, 251, 55, 219, 228, 149, 106, 79, 231, 220, 192, 53, 185, 185, 170, 42, 204, 117, 193, 1, 226, 190, 229, 150, 189])), SecretKey(Scalar([141, 131, 240, 233, 113, 82, 67, 148, 226, 139, 186, 7, 55, 167, 89, 237, 148, 214, 236, 18, 31, 149, 199, 154, 103, 75, 143, 18, 85, 199, 113, 0])));
/// HU: boa1xqhu002zd45yp7p292ucuhzy49a9krmmm84gseh0u2f8cd8tkvy3zasf44c
static immutable HU = KeyPair(PublicKey(Point([47, 199, 189, 66, 109, 104, 64, 248, 42, 42, 185, 142, 92, 68, 169, 122, 91, 15, 123, 217, 234, 136, 102, 239, 226, 146, 124, 52, 235, 179, 9, 17])), SecretKey(Scalar([57, 248, 152, 88, 115, 237, 158, 204, 78, 124, 90, 206, 58, 136, 131, 130, 144, 88, 130, 120, 74, 165, 42, 148, 113, 143, 71, 165, 179, 244, 41, 7])));
/// HV: boa1xphv000epcnswxu2nthdc6d68lk5a2l84qg4zy0mhfwtgduktj62cju8pup
static immutable HV = KeyPair(PublicKey(Point([110, 199, 189, 249, 14, 39, 7, 27, 138, 154, 238, 220, 105, 186, 63, 237, 78, 171, 231, 168, 17, 81, 17, 251, 186, 92, 180, 55, 150, 92, 180, 172])), SecretKey(Scalar([54, 22, 208, 133, 236, 35, 70, 234, 62, 169, 24, 136, 53, 29, 137, 61, 153, 221, 138, 23, 122, 189, 203, 120, 90, 82, 245, 49, 239, 208, 25, 0])));
/// HW: boa1xrhw00qrlgkxwfu7whswe9n483g200zejk5w58fpw6pfnfe6qq06g3m9dfz
static immutable HW = KeyPair(PublicKey(Point([238, 231, 188, 3, 250, 44, 103, 39, 158, 117, 224, 236, 150, 117, 60, 80, 167, 188, 89, 149, 168, 234, 29, 33, 118, 130, 153, 167, 58, 0, 31, 164])), SecretKey(Scalar([74, 27, 46, 59, 218, 104, 92, 157, 226, 136, 90, 232, 180, 138, 95, 119, 98, 106, 224, 93, 222, 131, 150, 89, 206, 28, 190, 253, 123, 106, 185, 15])));
/// HX: boa1xrhx00ppxc7e49f3vwwhpwh0j72lmx9fzqujyac08v68vmngscdcj09vrj7
static immutable HX = KeyPair(PublicKey(Point([238, 103, 188, 33, 54, 61, 154, 149, 49, 99, 157, 112, 186, 239, 151, 149, 253, 152, 169, 16, 57, 34, 119, 15, 59, 52, 118, 110, 104, 134, 27, 137])), SecretKey(Scalar([62, 111, 115, 206, 60, 145, 144, 189, 161, 5, 98, 57, 219, 192, 132, 112, 185, 190, 83, 170, 25, 116, 19, 48, 156, 38, 63, 221, 214, 23, 56, 9])));
/// HY: boa1xqhy0099m3xq3m72ad0s6e239jwlc8frcf63utgqrzgr0p282q0pxyr0359
static immutable HY = KeyPair(PublicKey(Point([46, 71, 188, 165, 220, 76, 8, 239, 202, 235, 95, 13, 101, 81, 44, 157, 252, 29, 35, 194, 117, 30, 45, 0, 24, 144, 55, 133, 71, 80, 30, 19])), SecretKey(Scalar([85, 126, 144, 136, 164, 128, 242, 72, 118, 37, 204, 47, 143, 21, 155, 211, 55, 64, 132, 70, 78, 47, 91, 107, 162, 220, 229, 63, 171, 84, 210, 1])));
/// HZ: boa1xqhz007nh2c66ahuq2n46c3falh48aydvnjgvrr2kwr5a74pr4cyyx282er
static immutable HZ = KeyPair(PublicKey(Point([46, 39, 191, 211, 186, 177, 173, 118, 252, 2, 167, 93, 98, 41, 239, 239, 83, 244, 141, 100, 228, 134, 12, 106, 179, 135, 78, 250, 161, 29, 112, 66])), SecretKey(Scalar([96, 230, 239, 207, 174, 58, 179, 13, 143, 227, 132, 121, 138, 37, 30, 44, 32, 40, 127, 149, 233, 19, 105, 90, 126, 129, 13, 89, 35, 121, 204, 6])));
/// JA: boa1xrja00k529u5t5kakup6hz8mx5eerv2mumnc890lum8x5lnxfak55wx29gc
static immutable JA = KeyPair(PublicKey(Point([229, 215, 190, 212, 81, 121, 69, 210, 221, 183, 3, 171, 136, 251, 53, 51, 145, 177, 91, 230, 231, 131, 149, 255, 230, 206, 106, 126, 102, 79, 109, 74])), SecretKey(Scalar([190, 182, 16, 140, 102, 92, 217, 159, 242, 35, 247, 68, 38, 10, 210, 70, 48, 128, 91, 182, 224, 202, 21, 110, 238, 191, 232, 221, 98, 10, 136, 9])));
/// JC: boa1xzjc0004t6nuqzd7d2kqfsf37n8vewftuzqmznp0mfq4e5vcclcqs30u2sh
static immutable JC = KeyPair(PublicKey(Point([165, 135, 189, 245, 94, 167, 192, 9, 190, 106, 172, 4, 193, 49, 244, 206, 204, 185, 43, 224, 129, 177, 76, 47, 218, 65, 92, 209, 152, 199, 240, 8])), SecretKey(Scalar([221, 157, 106, 235, 75, 115, 41, 28, 60, 2, 247, 197, 240, 41, 36, 155, 113, 255, 46, 11, 73, 220, 221, 34, 234, 238, 93, 197, 231, 213, 228, 6])));
/// JD: boa1xzjd00w76p0e6vfc5zwdz039ywzxg0ln23k5c80emfdndz5l6fvec20k4w8
static immutable JD = KeyPair(PublicKey(Point([164, 215, 189, 222, 208, 95, 157, 49, 56, 160, 156, 209, 62, 37, 35, 132, 100, 63, 243, 84, 109, 76, 29, 249, 218, 91, 54, 138, 159, 210, 89, 156])), SecretKey(Scalar([219, 109, 154, 131, 194, 201, 221, 180, 87, 78, 16, 231, 72, 114, 93, 66, 138, 37, 119, 226, 117, 139, 130, 17, 82, 152, 180, 76, 129, 192, 168, 3])));
/// JE: boa1xqje00uc088dt4d39a9vrwxdteul3rf9905nthkxuskakegj0zdas372xd4
static immutable JE = KeyPair(PublicKey(Point([37, 151, 191, 152, 121, 206, 213, 213, 177, 47, 74, 193, 184, 205, 94, 121, 248, 141, 37, 43, 233, 53, 222, 198, 228, 45, 219, 101, 18, 120, 155, 216])), SecretKey(Scalar([217, 43, 137, 1, 43, 106, 101, 137, 152, 183, 143, 36, 198, 223, 213, 28, 223, 53, 170, 207, 139, 166, 133, 125, 120, 74, 125, 228, 222, 231, 138, 11])));
/// JF: boa1xpjf0033ygnhpreq40zf7mpzfqxfee9f32j8hus4r5earfvyjha06u5x4nu
static immutable JF = KeyPair(PublicKey(Point([100, 151, 190, 49, 34, 39, 112, 143, 32, 171, 196, 159, 108, 34, 72, 12, 156, 228, 169, 138, 164, 123, 242, 21, 29, 51, 209, 165, 132, 149, 250, 253])), SecretKey(Scalar([35, 65, 175, 211, 233, 28, 218, 44, 31, 170, 78, 170, 252, 109, 40, 187, 125, 87, 160, 54, 74, 154, 242, 43, 200, 29, 41, 135, 232, 69, 63, 2])));
/// JG: boa1xpjg00tsn98a44m07ye7jl6k882h9zmwehsxpmu7muaw0j63m6nj6l8hfnx
static immutable JG = KeyPair(PublicKey(Point([100, 135, 189, 112, 153, 79, 218, 215, 111, 241, 51, 233, 127, 86, 57, 213, 114, 139, 110, 205, 224, 96, 239, 158, 223, 58, 231, 203, 81, 222, 167, 45])), SecretKey(Scalar([12, 97, 179, 62, 20, 89, 252, 39, 123, 159, 77, 122, 5, 110, 152, 116, 100, 54, 128, 124, 24, 152, 252, 35, 103, 60, 143, 114, 69, 154, 58, 7])));
/// JH: boa1xqjh00znu4y75d69zyz687vtwephnwkv7yffjakncp8g7qdftyxnxf7u9px
static immutable JH = KeyPair(PublicKey(Point([37, 119, 188, 83, 229, 73, 234, 55, 69, 17, 5, 163, 249, 139, 118, 67, 121, 186, 204, 241, 18, 153, 118, 211, 192, 78, 143, 1, 169, 89, 13, 51])), SecretKey(Scalar([223, 226, 40, 16, 222, 81, 64, 202, 58, 29, 196, 221, 198, 80, 121, 42, 231, 186, 173, 22, 121, 253, 33, 221, 63, 180, 94, 49, 131, 156, 238, 15])));
/// JJ: boa1xpjj00uzcsug9pcnjp6c778rchnjmu9um6ehrkrg2zq4fj80mryfk0wsumc
static immutable JJ = KeyPair(PublicKey(Point([101, 39, 191, 130, 196, 56, 130, 135, 19, 144, 117, 143, 120, 227, 197, 231, 45, 240, 188, 222, 179, 113, 216, 104, 80, 129, 84, 200, 239, 216, 200, 155])), SecretKey(Scalar([43, 64, 187, 114, 237, 83, 177, 149, 101, 124, 44, 192, 193, 254, 140, 132, 223, 119, 42, 145, 43, 144, 92, 23, 100, 1, 92, 178, 65, 88, 146, 5])));
/// JK: boa1xzjk00j4n6zmrjd84sg76snywkmquavh3u0csr987rngc6lvurltufcwety
static immutable JK = KeyPair(PublicKey(Point([165, 103, 190, 85, 158, 133, 177, 201, 167, 172, 17, 237, 66, 100, 117, 182, 14, 117, 151, 143, 31, 136, 12, 167, 240, 230, 140, 107, 236, 224, 254, 190])), SecretKey(Scalar([238, 144, 92, 234, 35, 136, 173, 110, 197, 232, 250, 128, 233, 150, 251, 89, 232, 213, 60, 97, 96, 86, 61, 248, 107, 15, 52, 196, 155, 3, 205, 1])));
/// JL: boa1xpjl00fwkg9sr590t23u388sl2ylfahaw5wd3vh2wevaxy7s6sjkunw3lck
static immutable JL = KeyPair(PublicKey(Point([101, 247, 189, 46, 178, 11, 1, 208, 175, 90, 163, 200, 156, 240, 250, 137, 244, 246, 253, 117, 28, 216, 178, 234, 118, 89, 211, 19, 208, 212, 37, 110])), SecretKey(Scalar([182, 145, 121, 246, 148, 241, 204, 143, 217, 30, 135, 193, 134, 168, 8, 40, 201, 35, 68, 74, 166, 15, 68, 88, 226, 226, 234, 63, 178, 24, 203, 12])));
/// JM: boa1xpjm0049zxwxahmv77epxdrwwe746jmwmrud7m5ehstfxh4v704fyjx6n6p
static immutable JM = KeyPair(PublicKey(Point([101, 183, 190, 165, 17, 156, 110, 223, 108, 247, 178, 19, 52, 110, 118, 125, 93, 75, 110, 216, 248, 223, 110, 153, 188, 22, 147, 94, 172, 243, 234, 146])), SecretKey(Scalar([196, 217, 44, 255, 63, 76, 21, 141, 155, 61, 19, 127, 215, 168, 248, 238, 197, 0, 208, 151, 230, 42, 118, 170, 143, 56, 77, 53, 193, 35, 206, 5])));
/// JN: boa1xpjn00xkyw4eu45ps64e75ayy8m8eehftwuctuwflgr8hhr03s0pgppr53j
static immutable JN = KeyPair(PublicKey(Point([101, 55, 188, 214, 35, 171, 158, 86, 129, 134, 171, 159, 83, 164, 33, 246, 124, 230, 233, 91, 185, 133, 241, 201, 250, 6, 123, 220, 111, 140, 30, 20])), SecretKey(Scalar([227, 85, 41, 178, 129, 29, 62, 232, 6, 221, 97, 168, 65, 240, 70, 43, 27, 247, 29, 98, 111, 0, 159, 1, 231, 45, 240, 33, 205, 27, 254, 9])));
/// JP: boa1xrjp00yyeaxuele0wn0zkx9204j8ehxy4qnm9pe0cqqcjttkcj4s6pm6mer
static immutable JP = KeyPair(PublicKey(Point([228, 23, 188, 132, 207, 77, 204, 255, 47, 116, 222, 43, 24, 170, 125, 100, 124, 220, 196, 168, 39, 178, 135, 47, 192, 1, 137, 45, 118, 196, 171, 13])), SecretKey(Scalar([130, 134, 241, 129, 113, 182, 23, 72, 89, 206, 216, 7, 45, 178, 178, 37, 176, 241, 84, 164, 169, 195, 53, 101, 213, 132, 247, 145, 3, 150, 125, 2])));
/// JQ: boa1xrjq00fxftlngjer43ngacz2t4e9cs3k4wy5dhkcnx3hmsnncvqeqf9wsj0
static immutable JQ = KeyPair(PublicKey(Point([228, 7, 189, 38, 74, 255, 52, 75, 35, 172, 102, 142, 224, 74, 93, 114, 92, 66, 54, 171, 137, 70, 222, 216, 153, 163, 125, 194, 115, 195, 1, 144])), SecretKey(Scalar([149, 165, 215, 35, 78, 75, 139, 202, 79, 54, 88, 62, 78, 173, 23, 36, 30, 198, 128, 175, 215, 64, 162, 188, 127, 207, 235, 252, 4, 197, 168, 14])));
/// JR: boa1xrjr009tnfh42tuag8w7grg02t3g4gdhl74sgxjrc2khqedtv9yyw7wnvfh
static immutable JR = KeyPair(PublicKey(Point([228, 55, 188, 171, 154, 111, 85, 47, 157, 65, 221, 228, 13, 15, 82, 226, 138, 161, 183, 255, 171, 4, 26, 67, 194, 173, 112, 101, 171, 97, 72, 71])), SecretKey(Scalar([161, 96, 221, 165, 175, 18, 187, 183, 48, 156, 36, 230, 186, 122, 250, 141, 18, 140, 100, 175, 5, 101, 216, 141, 128, 167, 11, 160, 198, 252, 50, 0])));
/// JS: boa1xqjs00awh35vf39gf5lpwexs6c8axgyz9sugya9s0ktjragr7ed0g77ztuz
static immutable JS = KeyPair(PublicKey(Point([37, 7, 191, 174, 188, 104, 196, 196, 168, 77, 62, 23, 100, 208, 214, 15, 211, 32, 130, 44, 56, 130, 116, 176, 125, 151, 33, 245, 3, 246, 90, 244])), SecretKey(Scalar([201, 162, 173, 154, 32, 118, 28, 94, 244, 103, 78, 92, 33, 66, 169, 103, 3, 172, 71, 215, 104, 41, 249, 194, 165, 50, 227, 86, 235, 3, 144, 2])));
/// JT: boa1xqjt00vau4wqg8lgzrqphpd5uhdeg0yedntksmdnyp97xlwdr2slcdq2c2s
static immutable JT = KeyPair(PublicKey(Point([36, 183, 189, 157, 229, 92, 4, 31, 232, 16, 192, 27, 133, 180, 229, 219, 148, 60, 153, 108, 215, 104, 109, 179, 32, 75, 227, 125, 205, 26, 161, 252])), SecretKey(Scalar([98, 5, 140, 87, 8, 49, 141, 111, 13, 29, 161, 110, 220, 139, 50, 215, 43, 171, 163, 222, 103, 65, 141, 206, 42, 33, 91, 234, 194, 115, 2, 5])));
/// JU: boa1xzju00fvxt3jlrvpsgw5s236tluutnhpwjh7rsvgxrtztu570ncd5vjeqcn
static immutable JU = KeyPair(PublicKey(Point([165, 199, 189, 44, 50, 227, 47, 141, 129, 130, 29, 72, 42, 58, 95, 249, 197, 206, 225, 116, 175, 225, 193, 136, 48, 214, 37, 242, 158, 124, 240, 218])), SecretKey(Scalar([226, 48, 156, 10, 105, 61, 30, 223, 40, 35, 22, 61, 1, 201, 150, 210, 122, 163, 236, 241, 81, 34, 138, 123, 54, 115, 64, 207, 192, 141, 202, 7])));
/// JV: boa1xzjv009tvu260c0yenduk24xgcjeegke5g6etz8lnfk53gqmk20qvnma2td
static immutable JV = KeyPair(PublicKey(Point([164, 199, 188, 171, 103, 21, 167, 225, 228, 204, 219, 203, 42, 166, 70, 37, 156, 162, 217, 162, 53, 149, 136, 255, 154, 109, 72, 160, 27, 178, 158, 6])), SecretKey(Scalar([186, 125, 165, 170, 139, 99, 139, 154, 95, 108, 150, 183, 121, 181, 85, 225, 220, 145, 153, 178, 20, 126, 4, 161, 15, 74, 44, 52, 192, 237, 118, 4])));
/// JW: boa1xpjw000a2av2d3wy6fky29v45tawtpnxgyfpvae5qydnmyy8gjer7v7y9df
static immutable JW = KeyPair(PublicKey(Point([100, 231, 189, 253, 87, 88, 166, 197, 196, 210, 108, 69, 21, 149, 162, 250, 229, 134, 102, 65, 18, 22, 119, 52, 1, 27, 61, 144, 135, 68, 178, 63])), SecretKey(Scalar([58, 178, 95, 145, 237, 164, 255, 137, 48, 73, 89, 5, 11, 175, 60, 183, 111, 138, 10, 42, 196, 205, 242, 202, 144, 173, 91, 69, 212, 178, 37, 7])));
/// JX: boa1xrjx00x0d9uuvq82qrusl0umgqhtsrsywve26gna430cpc4a3lh5u5rgkx9
static immutable JX = KeyPair(PublicKey(Point([228, 103, 188, 207, 105, 121, 198, 0, 234, 0, 249, 15, 191, 155, 64, 46, 184, 14, 4, 115, 50, 173, 34, 125, 172, 95, 128, 226, 189, 143, 239, 78])), SecretKey(Scalar([183, 145, 93, 174, 144, 34, 200, 54, 68, 201, 187, 179, 65, 180, 104, 112, 241, 133, 15, 141, 84, 26, 226, 68, 213, 181, 50, 91, 208, 103, 202, 7])));
/// JY: boa1xpjy00vlrkcaupcrfs6jlkvvp2e2q0dknad05mtg2sauycdwsmmhc39lhly
static immutable JY = KeyPair(PublicKey(Point([100, 71, 189, 159, 29, 177, 222, 7, 3, 76, 53, 47, 217, 140, 10, 178, 160, 61, 182, 159, 90, 250, 109, 104, 84, 59, 194, 97, 174, 134, 247, 124])), SecretKey(Scalar([70, 179, 27, 255, 242, 91, 123, 218, 48, 79, 11, 199, 79, 169, 250, 246, 49, 173, 200, 222, 158, 60, 92, 132, 189, 244, 16, 214, 241, 40, 50, 1])));
/// JZ: boa1xzjz00w2r59j0vvcam0mxp694004sgl9vhtedws5qt8kz3eyr3eyc6674u8
static immutable JZ = KeyPair(PublicKey(Point([164, 39, 189, 202, 29, 11, 39, 177, 152, 238, 223, 179, 7, 69, 171, 223, 88, 35, 229, 101, 215, 150, 186, 20, 2, 207, 97, 71, 36, 28, 114, 76])), SecretKey(Scalar([238, 195, 130, 40, 229, 194, 224, 209, 94, 156, 31, 98, 208, 157, 70, 224, 64, 152, 180, 143, 178, 184, 107, 138, 61, 91, 194, 42, 22, 139, 176, 15])));
/// KA: boa1xqka00etnrg6wtq5vfl7jaj25hkpqpz9l5m6nwnxm506u68naaanjrmpudc
static immutable KA = KeyPair(PublicKey(Point([45, 215, 191, 43, 152, 209, 167, 44, 20, 98, 127, 233, 118, 74, 165, 236, 16, 4, 69, 253, 55, 169, 186, 102, 221, 31, 174, 104, 243, 239, 123, 57])), SecretKey(Scalar([136, 210, 38, 176, 100, 209, 102, 167, 115, 95, 193, 212, 146, 171, 188, 65, 98, 178, 12, 204, 161, 238, 32, 238, 42, 252, 115, 160, 250, 213, 136, 12])));
/// KC: boa1xqkc00edtmp88uwfmmjed3lq2zmehmkea049aj5q64e4vd5h9209gskhver
static immutable KC = KeyPair(PublicKey(Point([45, 135, 191, 45, 94, 194, 115, 241, 201, 222, 229, 150, 199, 224, 80, 183, 155, 238, 217, 235, 234, 94, 202, 128, 213, 115, 86, 54, 151, 42, 158, 84])), SecretKey(Scalar([169, 17, 67, 6, 174, 0, 29, 107, 74, 80, 245, 2, 108, 172, 187, 136, 123, 195, 224, 183, 87, 45, 29, 155, 204, 114, 106, 209, 83, 60, 101, 3])));
/// KD: boa1xzkd00lqs4kjq70p9lrhp7pzg2pd9e44sw779pvcxx7z4g5k7k9nwpp8lm4
static immutable KD = KeyPair(PublicKey(Point([172, 215, 191, 224, 133, 109, 32, 121, 225, 47, 199, 112, 248, 34, 66, 130, 210, 230, 181, 131, 189, 226, 133, 152, 49, 188, 42, 162, 150, 245, 139, 55])), SecretKey(Scalar([227, 2, 196, 31, 248, 43, 90, 243, 175, 148, 165, 75, 230, 53, 146, 15, 69, 2, 142, 120, 85, 56, 223, 40, 62, 172, 78, 211, 80, 180, 112, 3])));
/// KE: boa1xrke002ptxggsmw530zeesg7757e982g8gz7v5cl5gvftsyu85f8236ww8d
static immutable KE = KeyPair(PublicKey(Point([237, 151, 189, 65, 89, 144, 136, 109, 212, 139, 197, 156, 193, 30, 245, 61, 146, 157, 72, 58, 5, 230, 83, 31, 162, 24, 149, 192, 156, 61, 18, 117])), SecretKey(Scalar([168, 62, 201, 96, 237, 193, 192, 96, 114, 15, 157, 131, 188, 85, 9, 82, 214, 65, 49, 19, 82, 105, 55, 43, 151, 18, 65, 24, 176, 13, 187, 0])));
/// KF: boa1xqkf00fhhcwqgqq9wq9cmv55k6yplevkzk5cr836xy345swl5nt460ztjvx
static immutable KF = KeyPair(PublicKey(Point([44, 151, 189, 55, 190, 28, 4, 0, 5, 112, 11, 141, 178, 148, 182, 136, 31, 229, 150, 21, 169, 129, 158, 58, 49, 35, 90, 65, 223, 164, 215, 93])), SecretKey(Scalar([250, 131, 227, 42, 26, 84, 143, 66, 222, 138, 91, 124, 245, 137, 172, 185, 233, 128, 91, 206, 177, 204, 121, 167, 233, 219, 9, 214, 41, 3, 142, 5])));
/// KG: boa1xqkg00gms4jl9r3sn0mgue8tc0vgnue3h8d0fwyqa3fvvyr47cnkcuue0s8
static immutable KG = KeyPair(PublicKey(Point([44, 135, 189, 27, 133, 101, 242, 142, 48, 155, 246, 142, 100, 235, 195, 216, 137, 243, 49, 185, 218, 244, 184, 128, 236, 82, 198, 16, 117, 246, 39, 108])), SecretKey(Scalar([75, 175, 155, 174, 238, 222, 17, 220, 9, 163, 208, 1, 152, 252, 189, 175, 182, 132, 216, 211, 91, 26, 32, 45, 203, 87, 169, 52, 78, 221, 71, 3])));
/// KH: boa1xzkh00datnt9rmge6z6sdtpwkmdwmhpwn3t5z7m0g56h05md7wtgqtzzfx6
static immutable KH = KeyPair(PublicKey(Point([173, 119, 189, 189, 92, 214, 81, 237, 25, 208, 181, 6, 172, 46, 182, 218, 237, 220, 46, 156, 87, 65, 123, 111, 69, 53, 119, 211, 109, 243, 150, 128])), SecretKey(Scalar([89, 160, 140, 112, 150, 135, 24, 227, 84, 189, 241, 152, 9, 136, 130, 244, 81, 86, 187, 155, 214, 146, 216, 26, 115, 153, 19, 228, 166, 155, 90, 6])));
/// KJ: boa1xrkj00t4rmpcrnr4hjff8mfr9et5l38cha9u6k8jsw6m3dycpqx86vspge2
static immutable KJ = KeyPair(PublicKey(Point([237, 39, 189, 117, 30, 195, 129, 204, 117, 188, 146, 147, 237, 35, 46, 87, 79, 196, 248, 191, 75, 205, 88, 242, 131, 181, 184, 180, 152, 8, 12, 125])), SecretKey(Scalar([230, 231, 70, 2, 85, 48, 204, 47, 34, 233, 182, 199, 55, 57, 108, 32, 152, 212, 169, 70, 110, 124, 208, 147, 170, 233, 205, 121, 175, 165, 13, 3])));
/// KK: boa1xqkk0037xy9tgyfu6gc4fr2f5yvxa9ngvp33c9h7m5rtstz5tldd2mja2yk
static immutable KK = KeyPair(PublicKey(Point([45, 103, 190, 62, 49, 10, 180, 17, 60, 210, 49, 84, 141, 73, 161, 24, 110, 150, 104, 96, 99, 28, 22, 254, 221, 6, 184, 44, 84, 95, 218, 213])), SecretKey(Scalar([104, 118, 47, 149, 119, 105, 33, 222, 249, 98, 9, 123, 45, 217, 84, 212, 73, 78, 34, 41, 212, 70, 1, 81, 18, 160, 129, 233, 157, 201, 200, 2])));
/// KL: boa1xrkl00u33tyq0kfcf56mmskyqcpujdxzyxsm4pmwd8jsd9cs7025q923ksg
static immutable KL = KeyPair(PublicKey(Point([237, 247, 191, 145, 138, 200, 7, 217, 56, 77, 53, 189, 194, 196, 6, 3, 201, 52, 194, 33, 161, 186, 135, 110, 105, 229, 6, 151, 16, 243, 213, 64])), SecretKey(Scalar([193, 220, 37, 132, 234, 247, 202, 188, 15, 102, 88, 105, 126, 245, 237, 245, 27, 216, 210, 108, 166, 24, 145, 170, 141, 139, 129, 229, 33, 32, 166, 3])));
/// KM: boa1xpkm00kqdurslck80w3fg0ck5f6mgrz5dwjrzuj0rxneptrev0lt5m83qng
static immutable KM = KeyPair(PublicKey(Point([109, 183, 190, 192, 111, 7, 15, 226, 199, 123, 162, 148, 63, 22, 162, 117, 180, 12, 84, 107, 164, 49, 114, 79, 25, 167, 144, 172, 121, 99, 254, 186])), SecretKey(Scalar([115, 197, 237, 48, 165, 81, 33, 184, 85, 133, 235, 79, 195, 112, 211, 120, 22, 58, 189, 50, 204, 154, 15, 52, 113, 166, 160, 78, 138, 35, 155, 14])));
/// KN: boa1xpkn00qjpuxseu28eftssejngf9vsstp8ctm9y94y3auyeatqasekufkudc
static immutable KN = KeyPair(PublicKey(Point([109, 55, 188, 18, 15, 13, 12, 241, 71, 202, 87, 8, 102, 83, 66, 74, 200, 65, 97, 62, 23, 178, 144, 181, 36, 123, 194, 103, 171, 7, 97, 155])), SecretKey(Scalar([77, 77, 80, 91, 83, 102, 47, 177, 252, 114, 95, 242, 154, 152, 109, 163, 222, 233, 60, 127, 3, 26, 218, 117, 88, 202, 55, 3, 196, 89, 227, 3])));
/// KP: boa1xqkp00rxwhryzt4tav7a7g4pjdfj7rzm88qlqgnsf0akk60ztsg85gdn9y0
static immutable KP = KeyPair(PublicKey(Point([44, 23, 188, 102, 117, 198, 65, 46, 171, 235, 61, 223, 34, 161, 147, 83, 47, 12, 91, 57, 193, 240, 34, 112, 75, 251, 107, 105, 226, 92, 16, 122])), SecretKey(Scalar([177, 67, 183, 77, 206, 112, 110, 110, 249, 165, 199, 53, 234, 59, 213, 29, 88, 30, 95, 141, 115, 162, 78, 137, 69, 15, 89, 205, 202, 207, 117, 0])));
/// KQ: boa1xpkq00s3xg954ujp50lv50x37mxx9zzavllctjxj4hv9nlzy5stx2xehkv6
static immutable KQ = KeyPair(PublicKey(Point([108, 7, 190, 17, 50, 11, 74, 242, 65, 163, 254, 202, 60, 209, 246, 204, 98, 136, 93, 103, 255, 133, 200, 210, 173, 216, 89, 252, 68, 164, 22, 101])), SecretKey(Scalar([249, 255, 171, 30, 163, 119, 67, 176, 51, 233, 35, 4, 135, 232, 57, 98, 220, 92, 226, 77, 7, 246, 62, 173, 135, 171, 242, 100, 74, 195, 90, 7])));
/// KR: boa1xrkr00uc4r7f9dtgpurrzf22m9p457gx0eql2ym4vyjxmgyhpdtvg309lre
static immutable KR = KeyPair(PublicKey(Point([236, 55, 191, 152, 168, 252, 146, 181, 104, 15, 6, 49, 37, 74, 217, 67, 90, 121, 6, 126, 65, 245, 19, 117, 97, 36, 109, 160, 151, 11, 86, 196])), SecretKey(Scalar([62, 213, 94, 151, 219, 144, 121, 174, 6, 238, 255, 7, 152, 149, 251, 172, 220, 211, 248, 212, 0, 6, 121, 53, 242, 63, 210, 242, 61, 219, 90, 0])));
/// KS: boa1xzks000hktlxdqtv9dd80fpflakvttuywh9nmdlz4fjhf6awyr5m56jr3aw
static immutable KS = KeyPair(PublicKey(Point([173, 7, 189, 247, 178, 254, 102, 129, 108, 43, 90, 119, 164, 41, 255, 108, 197, 175, 132, 117, 203, 61, 183, 226, 170, 101, 116, 235, 174, 32, 233, 186])), SecretKey(Scalar([60, 227, 73, 27, 22, 199, 223, 120, 23, 111, 228, 255, 71, 6, 28, 129, 246, 38, 165, 156, 120, 114, 221, 223, 199, 183, 210, 103, 96, 199, 114, 14])));
/// KT: boa1xpkt00glrqke94attxn75dhq3gpax838x0ap444lz68tyer8zcvrxsrtelj
static immutable KT = KeyPair(PublicKey(Point([108, 183, 189, 31, 24, 45, 146, 215, 171, 89, 167, 234, 54, 224, 138, 3, 211, 30, 39, 51, 250, 26, 214, 191, 22, 142, 178, 100, 103, 22, 24, 51])), SecretKey(Scalar([207, 129, 68, 81, 166, 38, 51, 138, 219, 45, 97, 21, 169, 60, 128, 46, 216, 137, 48, 48, 136, 145, 22, 109, 173, 136, 56, 2, 235, 148, 163, 8])));
/// KU: boa1xzku00sa3qk775mxtnxcxzpxwz7fulawsyf7zstgf8nlf4mcx2xmzhkz25t
static immutable KU = KeyPair(PublicKey(Point([173, 199, 190, 29, 136, 45, 239, 83, 102, 92, 205, 131, 8, 38, 112, 188, 158, 127, 174, 129, 19, 225, 65, 104, 73, 231, 244, 215, 120, 50, 141, 177])), SecretKey(Scalar([103, 110, 214, 75, 25, 169, 29, 82, 78, 188, 221, 227, 108, 111, 29, 88, 129, 157, 48, 79, 47, 187, 255, 13, 252, 200, 2, 212, 50, 119, 177, 3])));
/// KV: boa1xpkv00clpxdmfpspp0jnz2ermdm98e9yh530cfhyl2yrzw8papj4gevln66
static immutable KV = KeyPair(PublicKey(Point([108, 199, 191, 31, 9, 155, 180, 134, 1, 11, 229, 49, 43, 35, 219, 118, 83, 228, 164, 189, 34, 252, 38, 228, 250, 136, 49, 56, 225, 232, 101, 84])), SecretKey(Scalar([228, 50, 252, 201, 221, 197, 152, 142, 195, 253, 37, 34, 33, 35, 166, 94, 128, 151, 102, 234, 37, 96, 203, 45, 86, 209, 185, 175, 239, 58, 168, 11])));
/// KW: boa1xrkw00322q4ewmn990n9pdst8axglhdta2tul3r3td6krjr5zefm58k5hfj
static immutable KW = KeyPair(PublicKey(Point([236, 231, 190, 42, 80, 43, 151, 110, 101, 43, 230, 80, 182, 11, 63, 76, 143, 221, 171, 234, 151, 207, 196, 113, 91, 117, 97, 200, 116, 22, 83, 186])), SecretKey(Scalar([67, 193, 145, 168, 185, 51, 31, 184, 228, 223, 20, 34, 85, 189, 141, 169, 206, 15, 99, 102, 18, 251, 231, 6, 156, 237, 45, 96, 204, 150, 16, 4])));
/// KX: boa1xpkx00ycnmauprs836lg9q5a00x48k43hcj9vmfad2g6r67qq5yf72dz3h0
static immutable KX = KeyPair(PublicKey(Point([108, 103, 188, 152, 158, 251, 192, 142, 7, 142, 190, 130, 130, 157, 123, 205, 83, 218, 177, 190, 36, 86, 109, 61, 106, 145, 161, 235, 192, 5, 8, 159])), SecretKey(Scalar([81, 90, 96, 241, 141, 17, 132, 86, 26, 172, 117, 129, 43, 20, 248, 191, 175, 95, 87, 241, 229, 198, 135, 201, 48, 182, 134, 181, 95, 128, 164, 9])));
/// KY: boa1xqky002p8wchh54d0sr753j2z5kgphp3mu80yezauvrnr7y55dg3gvpqq6u
static immutable KY = KeyPair(PublicKey(Point([44, 71, 189, 65, 59, 177, 123, 210, 173, 124, 7, 234, 70, 74, 21, 44, 128, 220, 49, 223, 14, 242, 100, 93, 227, 7, 49, 248, 148, 163, 81, 20])), SecretKey(Scalar([118, 7, 131, 53, 33, 75, 193, 60, 34, 110, 62, 43, 228, 147, 63, 251, 241, 130, 77, 194, 92, 122, 197, 127, 126, 64, 34, 124, 104, 90, 9, 6])));
/// KZ: boa1xzkz00p4ql2zj3pmtasus4jvafpwjezaskky872wdt42wps3x9r0c93jptv
static immutable KZ = KeyPair(PublicKey(Point([172, 39, 188, 53, 7, 212, 41, 68, 59, 95, 97, 200, 86, 76, 234, 66, 233, 100, 93, 133, 172, 67, 249, 78, 106, 234, 167, 6, 17, 49, 70, 252])), SecretKey(Scalar([73, 114, 82, 99, 137, 31, 159, 101, 15, 202, 31, 159, 250, 48, 58, 235, 22, 6, 211, 150, 132, 52, 87, 98, 73, 244, 65, 90, 46, 22, 24, 10])));
/// LA: boa1xpla00frnv5qyk6txgjra9rjaryuezyud956clr0vyln88dyzwcxc2e6nte
static immutable LA = KeyPair(PublicKey(Point([127, 215, 189, 35, 155, 40, 2, 91, 75, 50, 36, 62, 148, 114, 232, 201, 204, 136, 156, 105, 105, 172, 124, 111, 97, 63, 51, 157, 164, 19, 176, 108])), SecretKey(Scalar([226, 76, 147, 222, 241, 109, 122, 31, 118, 77, 104, 127, 242, 59, 218, 114, 29, 6, 227, 193, 177, 102, 115, 184, 214, 7, 92, 34, 87, 15, 11, 14])));
/// LC: boa1xplc0082wgfh24mu075zqnv8envvdqnxe48phy0e7n9j8kemyshwy64hnr8
static immutable LC = KeyPair(PublicKey(Point([127, 135, 188, 234, 114, 19, 117, 87, 124, 127, 168, 32, 77, 135, 204, 216, 198, 130, 102, 205, 78, 27, 145, 249, 244, 203, 35, 219, 59, 36, 46, 226])), SecretKey(Scalar([68, 102, 207, 1, 212, 26, 229, 132, 126, 29, 15, 36, 22, 49, 44, 79, 123, 48, 208, 201, 178, 35, 75, 43, 194, 157, 117, 132, 112, 173, 45, 12])));
/// LD: boa1xzld00wckfd5wtswhvtqly6xae9ep6vmslcxpgqjm7tcnr5e5rzacl6ltc8
static immutable LD = KeyPair(PublicKey(Point([190, 215, 189, 216, 178, 91, 71, 46, 14, 187, 22, 15, 147, 70, 238, 75, 144, 233, 155, 135, 240, 96, 160, 18, 223, 151, 137, 142, 153, 160, 197, 220])), SecretKey(Scalar([178, 4, 230, 62, 201, 23, 52, 254, 145, 246, 193, 236, 226, 131, 84, 145, 247, 54, 232, 34, 15, 235, 68, 37, 172, 222, 72, 28, 50, 196, 35, 5])));
/// LE: boa1xrle000nhe9sxtrtt2d09fsku75p3zj3tgjdx3c80xg2u5hrrt9560yejm6
static immutable LE = KeyPair(PublicKey(Point([255, 151, 189, 243, 190, 75, 3, 44, 107, 90, 154, 242, 166, 22, 231, 168, 24, 138, 81, 90, 36, 211, 71, 7, 121, 144, 174, 82, 227, 26, 203, 77])), SecretKey(Scalar([244, 247, 103, 4, 7, 59, 154, 185, 11, 131, 53, 90, 207, 161, 134, 158, 231, 87, 132, 213, 39, 16, 233, 120, 138, 13, 141, 168, 142, 175, 108, 5])));
/// LF: boa1xzlf00qlq5hsunkx25vrsg33er6k7vtnus8yypwtrpms0sgahwkpsm0h9d2
static immutable LF = KeyPair(PublicKey(Point([190, 151, 188, 31, 5, 47, 14, 78, 198, 85, 24, 56, 34, 49, 200, 245, 111, 49, 115, 228, 14, 66, 5, 203, 24, 119, 7, 193, 29, 187, 172, 24])), SecretKey(Scalar([15, 71, 225, 255, 45, 218, 241, 196, 191, 14, 146, 110, 169, 215, 136, 33, 190, 42, 214, 28, 12, 38, 218, 27, 206, 243, 89, 157, 147, 12, 244, 1])));
/// LG: boa1xqlg009skkvqtedmaxznquwlef9swunyg6vnn07hzp85ec2dnprvwem7y9p
static immutable LG = KeyPair(PublicKey(Point([62, 135, 188, 176, 181, 152, 5, 229, 187, 233, 133, 48, 113, 223, 202, 75, 7, 114, 100, 70, 153, 57, 191, 215, 16, 79, 76, 225, 77, 152, 70, 199])), SecretKey(Scalar([8, 88, 78, 238, 167, 160, 189, 225, 46, 167, 123, 219, 156, 91, 119, 3, 195, 232, 98, 240, 7, 153, 246, 190, 152, 92, 148, 91, 106, 121, 81, 8])));
/// LH: boa1xqlh00hkhek6p5dvdketpr8x8xl422a9srshr7yt6gvfmqtuncuks8unund
static immutable LH = KeyPair(PublicKey(Point([63, 119, 190, 246, 190, 109, 160, 209, 172, 109, 178, 176, 140, 230, 57, 191, 85, 43, 165, 128, 225, 113, 248, 139, 210, 24, 157, 129, 124, 158, 57, 104])), SecretKey(Scalar([227, 15, 107, 138, 175, 178, 141, 216, 153, 135, 74, 15, 29, 90, 66, 46, 139, 57, 193, 77, 169, 58, 226, 252, 74, 139, 225, 8, 8, 198, 184, 7])));
/// LJ: boa1xrlj00v7wyf9vf0cm2thd58tquqxpj9xtdrh2hhfyrmag4cdkmej5nystea
static immutable LJ = KeyPair(PublicKey(Point([255, 39, 189, 158, 113, 18, 86, 37, 248, 218, 151, 118, 208, 235, 7, 0, 96, 200, 166, 91, 71, 117, 94, 233, 32, 247, 212, 87, 13, 182, 243, 42])), SecretKey(Scalar([117, 158, 26, 247, 188, 147, 3, 198, 188, 185, 206, 29, 64, 218, 83, 42, 93, 164, 18, 195, 44, 77, 178, 114, 68, 132, 160, 150, 59, 180, 61, 13])));
/// LK: boa1xplk00tel54kwfkvz3vmtxznqa9f8wgfgcy5uwt7a3azy6zca7dj7ry8y98
static immutable LK = KeyPair(PublicKey(Point([127, 103, 189, 121, 253, 43, 103, 38, 204, 20, 89, 181, 152, 83, 7, 74, 147, 185, 9, 70, 9, 78, 57, 126, 236, 122, 34, 104, 88, 239, 155, 47])), SecretKey(Scalar([13, 173, 142, 215, 92, 20, 168, 111, 222, 106, 136, 152, 85, 135, 67, 44, 158, 34, 76, 27, 39, 106, 80, 123, 226, 132, 224, 122, 200, 112, 43, 12])));
/// LL: boa1xqll00rk7zafvc8c5rfqwnehxmcegjkkuyvwld9v7q0dqk2vgxlgy7dcptx
static immutable LL = KeyPair(PublicKey(Point([63, 247, 188, 118, 240, 186, 150, 96, 248, 160, 210, 7, 79, 55, 54, 241, 148, 74, 214, 225, 24, 239, 180, 172, 240, 30, 208, 89, 76, 65, 190, 130])), SecretKey(Scalar([194, 250, 66, 169, 249, 111, 225, 0, 134, 91, 67, 241, 74, 216, 92, 170, 8, 48, 237, 242, 87, 120, 131, 151, 225, 243, 228, 36, 71, 221, 116, 15])));
/// LM: boa1xqlm00e88nqh4vvenf9vhvt0mr0xm4q9vz57kkkn36q50l596jad53n735v
static immutable LM = KeyPair(PublicKey(Point([63, 183, 191, 39, 60, 193, 122, 177, 153, 154, 74, 203, 177, 111, 216, 222, 109, 212, 5, 96, 169, 235, 90, 211, 142, 129, 71, 254, 133, 212, 186, 218])), SecretKey(Scalar([15, 158, 165, 67, 200, 1, 176, 60, 47, 41, 44, 255, 82, 68, 124, 124, 72, 238, 193, 183, 194, 35, 179, 125, 252, 44, 114, 88, 209, 157, 89, 1])));
/// LN: boa1xpln002lccz065f7uj6vvsnslcnams4u25vmy855ucuynvskqj9skehqxlw
static immutable LN = KeyPair(PublicKey(Point([127, 55, 189, 95, 198, 4, 253, 81, 62, 228, 180, 198, 66, 112, 254, 39, 221, 194, 188, 85, 25, 178, 30, 148, 230, 56, 73, 178, 22, 4, 139, 11])), SecretKey(Scalar([243, 53, 92, 19, 132, 30, 191, 222, 198, 224, 97, 4, 114, 22, 238, 218, 214, 199, 176, 189, 44, 251, 92, 90, 106, 24, 196, 165, 239, 205, 253, 3])));
/// LP: boa1xplp00jmz36m9v3sgywff7q4fkqdp8nr8rn709c7678vlh3srmsly9f902h
static immutable LP = KeyPair(PublicKey(Point([126, 23, 190, 91, 20, 117, 178, 178, 48, 65, 28, 148, 248, 21, 77, 128, 208, 158, 99, 56, 231, 231, 151, 30, 215, 142, 207, 222, 48, 30, 225, 242])), SecretKey(Scalar([103, 119, 225, 74, 79, 102, 44, 230, 246, 191, 221, 127, 75, 129, 59, 181, 96, 81, 92, 52, 199, 14, 224, 179, 58, 46, 95, 3, 49, 120, 191, 1])));
/// LQ: boa1xrlq00k264v4s7slcjh7kvngmgwwwuvnmjsnasfg6ah5pr5z7zunc0hh9p9
static immutable LQ = KeyPair(PublicKey(Point([254, 7, 190, 202, 213, 89, 88, 122, 31, 196, 175, 235, 50, 104, 218, 28, 231, 113, 147, 220, 161, 62, 193, 40, 215, 111, 64, 142, 130, 240, 185, 60])), SecretKey(Scalar([142, 105, 177, 163, 208, 102, 21, 56, 168, 226, 142, 118, 223, 172, 159, 120, 96, 164, 132, 5, 100, 138, 160, 92, 155, 132, 41, 60, 26, 33, 91, 6])));
/// LR: boa1xzlr00rh5kjwe4gw3ufca8ecxp7kjk2nk5ef0q3lp47znz3gd0wc6nqel05
static immutable LR = KeyPair(PublicKey(Point([190, 55, 188, 119, 165, 164, 236, 213, 14, 143, 19, 142, 159, 56, 48, 125, 105, 89, 83, 181, 50, 151, 130, 63, 13, 124, 41, 138, 40, 107, 221, 141])), SecretKey(Scalar([115, 157, 113, 19, 157, 73, 178, 17, 107, 134, 117, 101, 33, 186, 32, 220, 144, 212, 166, 9, 41, 20, 46, 104, 65, 236, 251, 7, 93, 60, 175, 4])));
/// LS: boa1xqls00px0d7cjhy38gdelfaj3aqr94ska9c60zr9g3zjh8uhekj9zgm8fff
static immutable LS = KeyPair(PublicKey(Point([63, 7, 188, 38, 123, 125, 137, 92, 145, 58, 27, 159, 167, 178, 143, 64, 50, 214, 22, 233, 113, 167, 136, 101, 68, 69, 43, 159, 151, 205, 164, 81])), SecretKey(Scalar([208, 192, 113, 123, 86, 30, 155, 165, 239, 215, 123, 150, 163, 158, 125, 196, 109, 27, 4, 221, 37, 208, 53, 22, 196, 202, 94, 16, 2, 173, 20, 13])));
/// LT: boa1xplt00s9vjtsr5ctssc30fgxrwp3chc9ee0v64taxw7ysu7hruqvj5un33n
static immutable LT = KeyPair(PublicKey(Point([126, 183, 190, 5, 100, 151, 1, 211, 11, 132, 49, 23, 165, 6, 27, 131, 28, 95, 5, 206, 94, 205, 85, 125, 51, 188, 72, 115, 215, 31, 0, 201])), SecretKey(Scalar([27, 164, 242, 229, 67, 110, 35, 237, 203, 183, 185, 167, 205, 133, 192, 173, 76, 37, 51, 169, 199, 176, 35, 234, 134, 2, 32, 205, 50, 92, 141, 8])));
/// LU: boa1xrlu00hfqc9t2q29x8gqjmvqc0ztftk432hwj7a6ukeamqz2tas4j3un5mz
static immutable LU = KeyPair(PublicKey(Point([255, 199, 190, 233, 6, 10, 181, 1, 69, 49, 208, 9, 109, 128, 195, 196, 180, 174, 213, 138, 174, 233, 123, 186, 229, 179, 221, 128, 74, 95, 97, 89])), SecretKey(Scalar([75, 129, 124, 165, 109, 172, 112, 56, 87, 11, 147, 104, 157, 107, 121, 67, 25, 108, 154, 68, 126, 140, 187, 110, 145, 41, 90, 157, 12, 248, 57, 14])));
/// LV: boa1xplv00frah79uj0vkzmhrgn85v5snn9c9f56dfp5tzhezcja807cxyvrvhg
static immutable LV = KeyPair(PublicKey(Point([126, 199, 189, 35, 237, 252, 94, 73, 236, 176, 183, 113, 162, 103, 163, 41, 9, 204, 184, 42, 105, 166, 164, 52, 88, 175, 145, 98, 93, 59, 253, 131])), SecretKey(Scalar([28, 13, 171, 127, 146, 81, 126, 195, 2, 102, 200, 159, 188, 70, 116, 62, 216, 47, 113, 181, 23, 230, 127, 28, 134, 17, 9, 57, 30, 233, 79, 9])));
/// LW: boa1xplw00mldxs85l4vuxgse9szjwhtvv99vtp44e7slzwqa8mt6350vysxady
static immutable LW = KeyPair(PublicKey(Point([126, 231, 191, 127, 105, 160, 122, 126, 172, 225, 145, 12, 150, 2, 147, 174, 182, 48, 165, 98, 195, 90, 231, 208, 248, 156, 14, 159, 107, 212, 104, 246])), SecretKey(Scalar([131, 244, 92, 168, 8, 20, 192, 83, 227, 198, 15, 122, 76, 180, 138, 224, 11, 56, 71, 123, 119, 80, 223, 241, 6, 146, 26, 138, 36, 45, 223, 0])));
/// LX: boa1xzlx00lg6q5aryvx282v80tfezvd8f2djatmeq2ldp44wp9662rh7u3xllk
static immutable LX = KeyPair(PublicKey(Point([190, 103, 191, 232, 208, 41, 209, 145, 134, 81, 212, 195, 189, 105, 200, 152, 211, 165, 77, 151, 87, 188, 129, 95, 104, 107, 87, 4, 186, 210, 135, 127])), SecretKey(Scalar([214, 130, 236, 44, 209, 190, 171, 173, 20, 69, 163, 95, 61, 85, 244, 34, 144, 70, 62, 205, 77, 255, 19, 89, 75, 209, 12, 119, 69, 132, 112, 10])));
/// LY: boa1xrly00dx94d0mp0v54rw8mepp6aukn4y4pd06hx6ccd0t05ku3ghk8j4afz
static immutable LY = KeyPair(PublicKey(Point([254, 71, 189, 166, 45, 90, 253, 133, 236, 165, 70, 227, 239, 33, 14, 187, 203, 78, 164, 168, 90, 253, 92, 218, 198, 26, 245, 190, 150, 228, 81, 123])), SecretKey(Scalar([121, 3, 39, 114, 61, 182, 34, 87, 221, 52, 156, 175, 84, 180, 208, 37, 217, 79, 108, 11, 172, 85, 67, 33, 236, 87, 211, 246, 196, 78, 208, 15])));
/// LZ: boa1xqlz00vese85flmw9qsccklfpyu6d5edqvwze0wns6slqr5f0zzlxrjr2cv
static immutable LZ = KeyPair(PublicKey(Point([62, 39, 189, 153, 134, 79, 68, 255, 110, 40, 33, 140, 91, 233, 9, 57, 166, 211, 45, 3, 28, 44, 189, 211, 134, 161, 240, 14, 137, 120, 133, 243])), SecretKey(Scalar([11, 126, 104, 196, 101, 47, 76, 146, 25, 238, 61, 117, 196, 221, 148, 242, 216, 92, 50, 57, 211, 62, 202, 30, 225, 214, 123, 109, 60, 138, 248, 10])));
/// MA: boa1xpma00kvm9xfup43g8zrd7dqtfkeslhwj3p35nggn9ff6ptnq42hsrn400a
static immutable MA = KeyPair(PublicKey(Point([119, 215, 190, 204, 217, 76, 158, 6, 177, 65, 196, 54, 249, 160, 90, 109, 152, 126, 238, 148, 67, 26, 77, 8, 153, 82, 157, 5, 115, 5, 85, 120])), SecretKey(Scalar([97, 195, 246, 126, 8, 224, 152, 209, 129, 28, 64, 109, 200, 149, 255, 122, 125, 62, 252, 188, 133, 129, 64, 66, 146, 127, 32, 169, 23, 20, 31, 15])));
/// MC: boa1xrmc006snjv8gcsd96n5dkt4q5lz95ycej6r0fm789lchrjmu2p8yvx3g9v
static immutable MC = KeyPair(PublicKey(Point([247, 135, 191, 80, 156, 152, 116, 98, 13, 46, 167, 70, 217, 117, 5, 62, 34, 208, 152, 204, 180, 55, 167, 126, 57, 127, 139, 142, 91, 226, 130, 114])), SecretKey(Scalar([101, 16, 132, 51, 181, 239, 178, 72, 159, 144, 143, 80, 8, 24, 226, 191, 174, 86, 38, 3, 176, 9, 109, 213, 136, 79, 12, 150, 115, 184, 32, 12])));
/// MD: boa1xpmd00ulntleupxfael7tfkx4tjuphdp2hxp4zstawcn7u3jmhy9yksvzsx
static immutable MD = KeyPair(PublicKey(Point([118, 215, 191, 159, 154, 255, 158, 4, 201, 238, 127, 229, 166, 198, 170, 229, 192, 221, 161, 85, 204, 26, 138, 11, 235, 177, 63, 114, 50, 221, 200, 82])), SecretKey(Scalar([63, 239, 141, 152, 192, 192, 244, 192, 27, 128, 232, 162, 171, 200, 101, 57, 22, 83, 234, 93, 233, 67, 149, 63, 255, 86, 213, 169, 78, 94, 210, 8])));
/// ME: boa1xqme00fs9nd00n8wfar73cqq8f07r0cxjpwlczpn5kqkrtkkt33g2nj8z7f
static immutable ME = KeyPair(PublicKey(Point([55, 151, 189, 48, 44, 218, 247, 204, 238, 79, 71, 232, 224, 0, 58, 95, 225, 191, 6, 144, 93, 252, 8, 51, 165, 129, 97, 174, 214, 92, 98, 133])), SecretKey(Scalar([55, 86, 134, 171, 9, 183, 77, 107, 70, 229, 247, 71, 124, 154, 225, 178, 126, 35, 186, 34, 219, 170, 211, 188, 11, 27, 78, 194, 65, 134, 79, 8])));
/// MF: boa1xzmf00v7wqaxfhxs2ysj70np9c4sr9c09zqmhuae0s4tpuvqxczwcmdgemm
static immutable MF = KeyPair(PublicKey(Point([182, 151, 189, 158, 112, 58, 100, 220, 208, 81, 33, 47, 62, 97, 46, 43, 1, 151, 15, 40, 129, 187, 243, 185, 124, 42, 176, 241, 128, 54, 4, 236])), SecretKey(Scalar([236, 19, 169, 249, 45, 171, 115, 204, 1, 235, 193, 16, 133, 69, 63, 153, 60, 176, 144, 67, 44, 245, 44, 13, 36, 241, 108, 222, 248, 191, 83, 12])));
/// MG: boa1xzmg006dte4t5ypf73qkjyz6lme5hz3dzz8s905pamaxh8prgkuvy5w2ljv
static immutable MG = KeyPair(PublicKey(Point([182, 135, 191, 77, 94, 106, 186, 16, 41, 244, 65, 105, 16, 90, 254, 243, 75, 138, 45, 16, 143, 2, 190, 129, 238, 250, 107, 156, 35, 69, 184, 194])), SecretKey(Scalar([61, 164, 87, 156, 112, 191, 74, 73, 8, 106, 205, 59, 83, 250, 91, 243, 118, 121, 224, 173, 129, 162, 107, 219, 97, 30, 18, 206, 192, 231, 169, 13])));
/// MH: boa1xzmh008xzkp59yql33ffgkgece6nw0zcmjgsdtdldlz2fcttucj9582nwu3
static immutable MH = KeyPair(PublicKey(Point([183, 119, 188, 230, 21, 131, 66, 144, 31, 140, 82, 148, 89, 25, 198, 117, 55, 60, 88, 220, 145, 6, 173, 191, 111, 196, 164, 225, 107, 230, 36, 90])), SecretKey(Scalar([188, 136, 127, 159, 121, 45, 205, 4, 187, 156, 39, 1, 55, 183, 226, 33, 11, 132, 40, 125, 247, 96, 60, 25, 74, 86, 186, 68, 50, 232, 93, 11])));
/// MJ: boa1xrmj00ehauqsh4ftgxwgfqg4c5sgcvpf7hen8j0sqvufxgcyg02dzk7m5r9
static immutable MJ = KeyPair(PublicKey(Point([247, 39, 191, 55, 239, 1, 11, 213, 43, 65, 156, 132, 129, 21, 197, 32, 140, 48, 41, 245, 243, 51, 201, 240, 3, 56, 147, 35, 4, 67, 212, 209])), SecretKey(Scalar([13, 228, 6, 132, 254, 244, 129, 38, 104, 238, 146, 57, 44, 184, 17, 220, 119, 30, 190, 244, 217, 102, 217, 23, 15, 229, 123, 240, 105, 140, 11, 12])));
/// MK: boa1xpmk00z6w5zefynn0y938vvj5dyk799vz5fkwk9gjhlr5zydvyvr6erqxdw
static immutable MK = KeyPair(PublicKey(Point([119, 103, 188, 90, 117, 5, 148, 146, 115, 121, 11, 19, 177, 146, 163, 73, 111, 20, 172, 21, 19, 103, 88, 168, 149, 254, 58, 8, 141, 97, 24, 61])), SecretKey(Scalar([238, 214, 29, 92, 195, 109, 174, 90, 143, 165, 10, 105, 172, 100, 246, 118, 52, 103, 112, 7, 223, 134, 139, 53, 182, 115, 15, 235, 150, 212, 21, 0])));
/// ML: boa1xqml00qmh2z2asywn00zu687333p8y3dw2y74pydzaa88vsue43a6shjxal
static immutable ML = KeyPair(PublicKey(Point([55, 247, 188, 27, 186, 132, 174, 192, 142, 155, 222, 46, 104, 254, 140, 98, 19, 146, 45, 114, 137, 234, 132, 141, 23, 122, 115, 178, 28, 205, 99, 221])), SecretKey(Scalar([124, 76, 107, 95, 102, 77, 124, 105, 179, 19, 169, 204, 118, 70, 43, 221, 72, 19, 115, 67, 67, 138, 21, 84, 227, 185, 84, 217, 14, 109, 134, 14])));
/// MM: boa1xzmm00p7rd6y4m4cexqpt6au4cdpdelq9wf0q0h3s5kf9zfvc8px68t2nra
static immutable MM = KeyPair(PublicKey(Point([183, 183, 188, 62, 27, 116, 74, 238, 184, 201, 128, 21, 235, 188, 174, 26, 22, 231, 224, 43, 146, 240, 62, 241, 133, 44, 146, 137, 44, 193, 194, 109])), SecretKey(Scalar([103, 83, 101, 165, 142, 85, 65, 181, 59, 19, 19, 244, 197, 213, 245, 125, 31, 133, 228, 227, 53, 205, 226, 46, 96, 129, 3, 207, 248, 41, 18, 14])));
/// MN: boa1xpmn00ancez6xkuy2qrgsj76ms3nr6jzsrh095ra8gj9zhjqaz5vz6g68zm
static immutable MN = KeyPair(PublicKey(Point([119, 55, 191, 179, 198, 69, 163, 91, 132, 80, 6, 136, 75, 218, 220, 35, 49, 234, 66, 128, 238, 242, 208, 125, 58, 36, 81, 94, 64, 232, 168, 193])), SecretKey(Scalar([207, 159, 102, 192, 139, 126, 195, 114, 248, 112, 31, 23, 81, 201, 244, 241, 216, 164, 244, 16, 72, 39, 191, 103, 28, 76, 160, 142, 132, 213, 199, 5])));
/// MP: boa1xqmp00fvkzjaucwj37ghpahscdqlrvuseduav5e99lcdjl05smly7ug0sqs
static immutable MP = KeyPair(PublicKey(Point([54, 23, 189, 44, 176, 165, 222, 97, 210, 143, 145, 112, 246, 240, 195, 65, 241, 179, 144, 203, 121, 214, 83, 37, 47, 240, 217, 125, 244, 134, 254, 79])), SecretKey(Scalar([173, 18, 162, 87, 100, 112, 89, 47, 201, 178, 100, 16, 182, 209, 6, 115, 195, 213, 138, 61, 171, 10, 204, 106, 170, 178, 105, 110, 127, 90, 119, 0])));
/// MQ: boa1xqmq00qdusspsj4n4x2rjfp47ekrg2ee9lrv9wc8vrvu28m9c55tqpeumj8
static immutable MQ = KeyPair(PublicKey(Point([54, 7, 188, 13, 228, 32, 24, 74, 179, 169, 148, 57, 36, 53, 246, 108, 52, 43, 57, 47, 198, 194, 187, 7, 96, 217, 197, 31, 101, 197, 40, 176])), SecretKey(Scalar([50, 39, 63, 24, 216, 244, 125, 119, 143, 82, 188, 185, 203, 245, 244, 144, 134, 68, 59, 111, 207, 156, 33, 237, 209, 165, 221, 205, 156, 123, 223, 10])));
/// MR: boa1xzmr009jaupwddxdt7n23yylvz0kcqu8wdu6upvrg3hx04xkcj5qv6mhcme
static immutable MR = KeyPair(PublicKey(Point([182, 55, 188, 178, 239, 2, 230, 180, 205, 95, 166, 168, 144, 159, 96, 159, 108, 3, 135, 115, 121, 174, 5, 131, 68, 110, 103, 212, 214, 196, 168, 6])), SecretKey(Scalar([213, 18, 187, 47, 218, 6, 5, 23, 240, 44, 203, 51, 239, 102, 242, 130, 94, 177, 69, 126, 163, 134, 53, 218, 9, 11, 88, 152, 28, 66, 121, 0])));
/// MS: boa1xzms00qpesd5fld0psxxlxkk4z72e7w2jvw79yuday3wh83yp5d4z0hl59n
static immutable MS = KeyPair(PublicKey(Point([183, 7, 188, 1, 204, 27, 68, 253, 175, 12, 12, 111, 154, 214, 168, 188, 172, 249, 202, 147, 29, 226, 147, 141, 233, 34, 235, 158, 36, 13, 27, 81])), SecretKey(Scalar([224, 158, 1, 188, 62, 27, 44, 52, 13, 81, 33, 135, 98, 171, 52, 224, 107, 12, 208, 233, 137, 239, 16, 157, 34, 147, 212, 124, 150, 67, 27, 12])));
/// MT: boa1xqmt00gaf6hh9cdpdwfyyu0h890e08f2zcd9xmnt7mm6qzrcty6d2m5j68n
static immutable MT = KeyPair(PublicKey(Point([54, 183, 189, 29, 78, 175, 114, 225, 161, 107, 146, 66, 113, 247, 57, 95, 151, 157, 42, 22, 26, 83, 110, 107, 246, 247, 160, 8, 120, 89, 52, 213])), SecretKey(Scalar([90, 75, 128, 155, 78, 89, 80, 97, 92, 120, 172, 131, 9, 8, 211, 118, 202, 148, 180, 102, 35, 157, 161, 10, 34, 206, 187, 193, 67, 181, 81, 11])));
/// MU: boa1xzmu00mgfecwd5zes2ps4cj0su0x83zcjz6q2ddmgh8kpyscuczycu4v0pn
static immutable MU = KeyPair(PublicKey(Point([183, 199, 191, 104, 78, 112, 230, 208, 89, 130, 131, 10, 226, 79, 135, 30, 99, 196, 88, 144, 180, 5, 53, 187, 69, 207, 96, 146, 24, 230, 4, 76])), SecretKey(Scalar([235, 218, 171, 140, 18, 184, 239, 244, 58, 213, 105, 216, 45, 156, 121, 162, 185, 103, 163, 113, 125, 143, 58, 227, 115, 48, 85, 144, 2, 151, 45, 13])));
/// MV: boa1xqmv00h23tc8hq22ynerm3vtjztujzdvxuyqfhrayaarh5yg8efyxncmvls
static immutable MV = KeyPair(PublicKey(Point([54, 199, 190, 234, 138, 240, 123, 129, 74, 36, 242, 61, 197, 139, 144, 151, 201, 9, 172, 55, 8, 4, 220, 125, 39, 122, 59, 208, 136, 62, 82, 67])), SecretKey(Scalar([167, 32, 108, 141, 8, 34, 181, 31, 190, 64, 143, 141, 64, 162, 109, 25, 51, 180, 86, 215, 42, 28, 143, 69, 9, 41, 190, 3, 39, 13, 80, 3])));
/// MW: boa1xzmw00l977xqlj8729vghvtreznf5s3fwwhexm4s4e7edvnrn82l586s966
static immutable MW = KeyPair(PublicKey(Point([182, 231, 191, 229, 247, 140, 15, 200, 254, 81, 88, 139, 177, 99, 200, 166, 154, 66, 41, 115, 175, 147, 110, 176, 174, 125, 150, 178, 99, 153, 213, 250])), SecretKey(Scalar([88, 68, 139, 238, 36, 2, 242, 238, 32, 246, 191, 247, 35, 88, 159, 235, 164, 54, 221, 55, 183, 38, 148, 150, 144, 15, 212, 221, 119, 70, 191, 14])));
/// MX: boa1xqmx0055xyzzm9n6gynwq5jl9n6dmu7crwa62uudfp9h9m530mdgzutjk56
static immutable MX = KeyPair(PublicKey(Point([54, 103, 190, 148, 49, 4, 45, 150, 122, 65, 38, 224, 82, 95, 44, 244, 221, 243, 216, 27, 187, 165, 115, 141, 72, 75, 114, 238, 145, 126, 218, 129])), SecretKey(Scalar([250, 169, 126, 213, 177, 121, 203, 198, 25, 34, 126, 93, 44, 42, 86, 59, 172, 97, 101, 200, 156, 210, 109, 2, 223, 247, 48, 98, 184, 12, 244, 10])));
/// MY: boa1xzmy00p853lj5ym5zr6x9236a3tvlc3e4lphcxrmwn54c8663ud3cvjn6an
static immutable MY = KeyPair(PublicKey(Point([182, 71, 188, 39, 164, 127, 42, 19, 116, 16, 244, 98, 170, 58, 236, 86, 207, 226, 57, 175, 195, 124, 24, 123, 116, 233, 92, 31, 90, 143, 27, 28])), SecretKey(Scalar([212, 99, 201, 75, 129, 47, 240, 188, 13, 195, 41, 220, 53, 197, 204, 131, 42, 127, 235, 65, 148, 211, 122, 130, 145, 98, 23, 18, 134, 172, 120, 10])));
/// MZ: boa1xqmz00w7wa9qcc2rd6upg2pjv58xack7kxyagxvgpw788v6tyljv7enzrwn
static immutable MZ = KeyPair(PublicKey(Point([54, 39, 189, 222, 119, 74, 12, 97, 67, 110, 184, 20, 40, 50, 101, 14, 110, 226, 222, 177, 137, 212, 25, 136, 11, 188, 115, 179, 75, 39, 228, 207])), SecretKey(Scalar([181, 26, 254, 27, 57, 52, 106, 123, 151, 143, 76, 123, 159, 241, 190, 247, 31, 154, 160, 58, 253, 166, 122, 148, 10, 76, 175, 250, 16, 25, 255, 9])));
/// NA: boa1xzna00zgfwq2ae8gfgrm27mewmsm384s494yade9vu8qn2yu0amauv5l0jk
static immutable NA = KeyPair(PublicKey(Point([167, 215, 188, 72, 75, 128, 174, 228, 232, 74, 7, 181, 123, 121, 118, 225, 184, 158, 176, 169, 106, 78, 183, 37, 103, 14, 9, 168, 156, 127, 119, 222])), SecretKey(Scalar([216, 244, 108, 201, 104, 57, 76, 48, 27, 15, 228, 170, 157, 125, 251, 206, 139, 222, 36, 141, 167, 208, 53, 201, 134, 55, 252, 37, 190, 49, 220, 1])));
/// NC: boa1xznc00gadzf950pgk9ewryjnemujdss8nqpl48w428f4vlydtjtv683kfhz
static immutable NC = KeyPair(PublicKey(Point([167, 135, 189, 29, 104, 146, 90, 60, 40, 177, 114, 225, 146, 83, 206, 249, 38, 194, 7, 152, 3, 250, 157, 213, 81, 211, 86, 124, 141, 92, 150, 205])), SecretKey(Scalar([207, 234, 158, 16, 255, 133, 30, 80, 139, 39, 108, 35, 204, 96, 42, 44, 19, 238, 47, 221, 176, 253, 225, 12, 219, 203, 19, 187, 7, 149, 184, 12])));
/// ND: boa1xpnd00x6vp3y40ksz0e6twxznr6jaywzqxygezxys7rpnq69p7532khkj2e
static immutable ND = KeyPair(PublicKey(Point([102, 215, 188, 218, 96, 98, 74, 190, 208, 19, 243, 165, 184, 194, 152, 245, 46, 145, 194, 1, 136, 140, 136, 196, 135, 134, 25, 131, 69, 15, 169, 21])), SecretKey(Scalar([153, 11, 123, 208, 24, 45, 5, 78, 254, 207, 119, 29, 65, 125, 102, 45, 5, 98, 135, 235, 166, 71, 92, 251, 87, 136, 115, 192, 208, 162, 7, 2])));
/// NE: boa1xqne00f2q9pzqyvqq9f7lz07fw2j58rp55m25p7gt2n4e49jrfq37xu0fna
static immutable NE = KeyPair(PublicKey(Point([39, 151, 189, 42, 1, 66, 32, 17, 128, 1, 83, 239, 137, 254, 75, 149, 42, 28, 97, 165, 54, 170, 7, 200, 90, 167, 92, 212, 178, 26, 65, 31])), SecretKey(Scalar([102, 69, 219, 17, 101, 250, 166, 243, 231, 136, 69, 241, 81, 236, 42, 176, 75, 121, 19, 245, 204, 4, 9, 31, 23, 105, 185, 233, 219, 191, 89, 4])));
/// NF: boa1xrnf00cqqdnas0sw7c5mqkjzzr354lp65dwrecpepymvf2fzc4mzyp32uuj
static immutable NF = KeyPair(PublicKey(Point([230, 151, 191, 0, 3, 103, 216, 62, 14, 246, 41, 176, 90, 66, 16, 227, 74, 252, 58, 163, 92, 60, 224, 57, 9, 54, 196, 169, 34, 197, 118, 34])), SecretKey(Scalar([45, 163, 140, 75, 7, 152, 80, 252, 171, 171, 25, 3, 216, 145, 126, 77, 240, 225, 193, 76, 228, 60, 147, 13, 170, 106, 247, 56, 103, 219, 16, 15])));
/// NG: boa1xpng00zc8g0tmzj3pefzfxqwmsl69vlakunusg8taslyxyjh8l9lza0f9wt
static immutable NG = KeyPair(PublicKey(Point([102, 135, 188, 88, 58, 30, 189, 138, 81, 14, 82, 36, 152, 14, 220, 63, 162, 179, 253, 183, 39, 200, 32, 235, 236, 62, 67, 18, 87, 63, 203, 241])), SecretKey(Scalar([169, 27, 243, 131, 121, 203, 101, 39, 190, 142, 186, 14, 37, 137, 0, 42, 140, 172, 168, 80, 120, 217, 123, 206, 14, 255, 156, 157, 237, 230, 43, 1])));
/// NH: boa1xrnh00qxjmf2apk7zr5t43ev9kne6wtdtsvwmywejkheamwvklvlq3ak6jj
static immutable NH = KeyPair(PublicKey(Point([231, 119, 188, 6, 150, 210, 174, 134, 222, 16, 232, 186, 199, 44, 45, 167, 157, 57, 109, 92, 24, 237, 145, 217, 149, 175, 158, 237, 204, 183, 217, 240])), SecretKey(Scalar([47, 34, 243, 93, 249, 98, 245, 139, 172, 83, 232, 2, 3, 16, 151, 140, 6, 182, 26, 177, 130, 52, 19, 158, 169, 82, 95, 23, 188, 254, 132, 11])));
/// NJ: boa1xpnj00waav2cz6acxaek57j2qsj7jackmy6m2wvee7pcwcf8a6pz26808s3
static immutable NJ = KeyPair(PublicKey(Point([103, 39, 189, 221, 235, 21, 129, 107, 184, 55, 115, 106, 122, 74, 4, 37, 233, 119, 22, 217, 53, 181, 57, 153, 207, 131, 135, 97, 39, 238, 130, 37])), SecretKey(Scalar([111, 34, 143, 155, 56, 153, 229, 88, 238, 41, 47, 134, 101, 162, 61, 151, 226, 188, 75, 139, 16, 137, 122, 172, 8, 162, 103, 169, 88, 251, 179, 10])));
/// NK: boa1xpnk00ff99nz70p24lmmc54c8rr94jqfp948w3u86tem3lqzv2qkus4fqpz
static immutable NK = KeyPair(PublicKey(Point([103, 103, 189, 41, 41, 102, 47, 60, 42, 175, 247, 188, 82, 184, 56, 198, 90, 200, 9, 9, 106, 119, 71, 135, 210, 243, 184, 252, 2, 98, 129, 110])), SecretKey(Scalar([10, 230, 107, 215, 98, 245, 238, 68, 174, 196, 209, 130, 169, 25, 232, 98, 248, 242, 119, 131, 218, 195, 122, 249, 11, 177, 69, 185, 171, 172, 192, 4])));
/// NL: boa1xqnl00fr33snlmlhp66ggygvx860h2cnkstmww9ejm0k4hnx9976c0aqqnc
static immutable NL = KeyPair(PublicKey(Point([39, 247, 189, 35, 140, 97, 63, 239, 247, 14, 180, 132, 17, 12, 49, 244, 251, 171, 19, 180, 23, 183, 56, 185, 150, 223, 106, 222, 102, 41, 125, 172])), SecretKey(Scalar([216, 102, 16, 14, 92, 50, 25, 183, 13, 252, 36, 121, 74, 35, 191, 73, 237, 136, 0, 209, 107, 75, 168, 210, 219, 255, 208, 76, 18, 156, 101, 3])));
/// NM: boa1xrnm00uh8v7vv9vk2l8vlhz3feaz80c9s8mk9jmkwe5tx7ccwy4v7lmhny5
static immutable NM = KeyPair(PublicKey(Point([231, 183, 191, 151, 59, 60, 198, 21, 150, 87, 206, 207, 220, 81, 78, 122, 35, 191, 5, 129, 247, 98, 203, 118, 118, 104, 179, 123, 24, 113, 42, 207])), SecretKey(Scalar([37, 140, 128, 171, 176, 237, 102, 187, 218, 196, 178, 117, 116, 142, 250, 20, 166, 222, 164, 22, 247, 132, 10, 152, 57, 196, 41, 158, 3, 214, 190, 12])));
/// NN: boa1xrnn00264lfprtktmccrm4jqas534l33kx2knx7k0d73pu593pqsyjgl2l9
static immutable NN = KeyPair(PublicKey(Point([231, 55, 189, 90, 175, 210, 17, 174, 203, 222, 48, 61, 214, 64, 236, 41, 26, 254, 49, 177, 149, 105, 155, 214, 123, 125, 16, 242, 133, 136, 65, 2])), SecretKey(Scalar([32, 82, 90, 41, 68, 32, 24, 187, 179, 110, 141, 67, 28, 169, 46, 243, 149, 49, 146, 151, 224, 152, 205, 116, 60, 100, 22, 3, 162, 184, 36, 12])));
/// NP: boa1xqnp0066eu8m6hfp208czj6yx65skrtda7qf2hdun2whxn5jhqsx2wjn72v
static immutable NP = KeyPair(PublicKey(Point([38, 23, 191, 90, 207, 15, 189, 93, 33, 83, 207, 129, 75, 68, 54, 169, 11, 13, 109, 239, 128, 149, 93, 188, 154, 157, 115, 78, 146, 184, 32, 101])), SecretKey(Scalar([50, 145, 102, 106, 124, 158, 179, 143, 139, 143, 135, 35, 136, 174, 133, 193, 250, 114, 6, 202, 135, 113, 192, 69, 11, 173, 205, 210, 193, 41, 174, 0])));
/// NQ: boa1xznq00emva0xzuqv0c7tvrqdpz26k7a0nhc4r4enc6wjksc59uwlzknvm0n
static immutable NQ = KeyPair(PublicKey(Point([166, 7, 191, 59, 103, 94, 97, 112, 12, 126, 60, 182, 12, 13, 8, 149, 171, 123, 175, 157, 241, 81, 215, 51, 198, 157, 43, 67, 20, 47, 29, 241])), SecretKey(Scalar([246, 64, 106, 254, 100, 228, 77, 162, 0, 128, 20, 53, 230, 59, 94, 249, 13, 208, 17, 113, 10, 84, 14, 209, 25, 179, 206, 150, 138, 1, 43, 13])));
/// NR: boa1xznr00094gsdskszx8rfrtqsdgvw759c2t9z0l82qsvtl3wfw867g58t5s7
static immutable NR = KeyPair(PublicKey(Point([166, 55, 189, 229, 170, 32, 216, 90, 2, 49, 198, 145, 172, 16, 106, 24, 239, 80, 184, 82, 202, 39, 252, 234, 4, 24, 191, 197, 201, 113, 245, 228])), SecretKey(Scalar([49, 35, 190, 138, 58, 148, 9, 200, 124, 173, 151, 194, 20, 122, 67, 4, 139, 22, 232, 244, 28, 224, 168, 193, 38, 246, 55, 74, 133, 52, 169, 1])));
/// NS: boa1xzns004l07cqfs0u6pfwl92urkp3ltrgl2nc8c6dw7kptt80n8yrkvhc3su
static immutable NS = KeyPair(PublicKey(Point([167, 7, 190, 191, 127, 176, 4, 193, 252, 208, 82, 239, 149, 92, 29, 131, 31, 172, 104, 250, 167, 131, 227, 77, 119, 172, 21, 172, 239, 153, 200, 59])), SecretKey(Scalar([244, 194, 153, 199, 225, 32, 118, 212, 98, 215, 77, 153, 215, 251, 31, 119, 12, 184, 191, 6, 19, 234, 112, 254, 3, 149, 205, 232, 99, 28, 224, 9])));
/// NT: boa1xqnt00fwj5l38eumc5paf84s82erupykn90jnxknh4rq6z2xyztyyyqwqnd
static immutable NT = KeyPair(PublicKey(Point([38, 183, 189, 46, 149, 63, 19, 231, 155, 197, 3, 212, 158, 176, 58, 178, 62, 4, 150, 153, 95, 41, 154, 211, 189, 70, 13, 9, 70, 32, 150, 66])), SecretKey(Scalar([165, 242, 7, 108, 96, 166, 82, 183, 134, 97, 59, 47, 87, 60, 70, 173, 251, 139, 16, 37, 119, 137, 96, 89, 40, 194, 200, 37, 99, 135, 74, 10])));
/// NU: boa1xqnu005sc7au7tgnjp30yv6av9xr7tutc9ep470cyjqsscahzn0jzvwmj0w
static immutable NU = KeyPair(PublicKey(Point([39, 199, 190, 144, 199, 187, 207, 45, 19, 144, 98, 242, 51, 93, 97, 76, 63, 47, 139, 193, 114, 26, 249, 248, 36, 129, 8, 99, 183, 20, 223, 33])), SecretKey(Scalar([67, 30, 110, 16, 127, 152, 242, 162, 245, 62, 127, 221, 186, 15, 229, 102, 11, 57, 136, 133, 166, 59, 241, 161, 3, 163, 149, 244, 229, 25, 99, 12])));
/// NV: boa1xpnv000fnejkhhs48aprt7j04mc90ruy92rp89qfenmke449c5gnjdpq8v6
static immutable NV = KeyPair(PublicKey(Point([102, 199, 189, 233, 158, 101, 107, 222, 21, 63, 66, 53, 250, 79, 174, 240, 87, 143, 132, 42, 134, 19, 148, 9, 204, 247, 108, 214, 165, 197, 17, 57])), SecretKey(Scalar([221, 251, 52, 83, 103, 37, 65, 35, 201, 76, 56, 220, 104, 169, 5, 87, 192, 27, 238, 154, 33, 245, 244, 215, 66, 32, 106, 72, 18, 6, 181, 15])));
/// NW: boa1xrnw00zmggsvepe58k86xm6ntryxlzx6aarlsfehhd0ftqp0pmfxvl0qx0n
static immutable NW = KeyPair(PublicKey(Point([230, 231, 188, 91, 66, 32, 204, 135, 52, 61, 143, 163, 111, 83, 88, 200, 111, 136, 218, 239, 71, 248, 39, 55, 187, 94, 149, 128, 47, 14, 210, 102])), SecretKey(Scalar([15, 73, 89, 160, 108, 246, 26, 184, 145, 210, 27, 183, 15, 174, 153, 22, 233, 119, 60, 22, 123, 18, 102, 114, 37, 197, 4, 232, 41, 23, 102, 0])));
/// NX: boa1xznx00yq6lu33xg53ft49alwyzs5kpm5699h27tdr89xqzuhldmxjtzfmye
static immutable NX = KeyPair(PublicKey(Point([166, 103, 188, 128, 215, 249, 24, 153, 20, 138, 87, 82, 247, 238, 32, 161, 75, 7, 116, 209, 75, 117, 121, 109, 25, 202, 96, 11, 151, 251, 118, 105])), SecretKey(Scalar([189, 199, 92, 184, 131, 50, 142, 23, 146, 248, 71, 86, 168, 57, 91, 54, 110, 139, 21, 170, 58, 57, 234, 4, 205, 63, 249, 145, 73, 157, 101, 13])));
/// NY: boa1xqny00e3uqlyt6v7gsmrt7475v7ne5e90yy4xl6wv3zsp7f8ae2zuqjuc27
static immutable NY = KeyPair(PublicKey(Point([38, 71, 191, 49, 224, 62, 69, 233, 158, 68, 54, 53, 250, 190, 163, 61, 60, 211, 37, 121, 9, 83, 127, 78, 100, 69, 0, 249, 39, 238, 84, 46])), SecretKey(Scalar([236, 233, 151, 10, 48, 42, 33, 242, 47, 41, 228, 70, 238, 119, 74, 245, 21, 47, 209, 114, 99, 162, 64, 86, 98, 226, 161, 69, 92, 118, 43, 10])));
/// NZ: boa1xznz00rhtgjwq0vmcxgsp3daxurd47q96n4vkgs75dz7xz3h4lzfu0snf2t
static immutable NZ = KeyPair(PublicKey(Point([166, 39, 188, 119, 90, 36, 224, 61, 155, 193, 145, 0, 197, 189, 55, 6, 218, 248, 5, 212, 234, 203, 34, 30, 163, 69, 227, 10, 55, 175, 196, 158])), SecretKey(Scalar([211, 215, 164, 88, 145, 95, 0, 44, 65, 27, 198, 46, 173, 243, 237, 198, 89, 9, 102, 208, 58, 104, 212, 169, 149, 167, 33, 196, 52, 73, 52, 15])));
/// PA: boa1xrpa00hanju4chk4vjy9mhtuw0hl45glvypf4gd3akgakf3zdjf86h3cvpz
static immutable PA = KeyPair(PublicKey(Point([195, 215, 190, 253, 156, 185, 92, 94, 213, 100, 136, 93, 221, 124, 115, 239, 250, 209, 31, 97, 2, 154, 161, 177, 237, 145, 219, 38, 34, 108, 146, 125])), SecretKey(Scalar([191, 81, 75, 165, 24, 254, 132, 77, 234, 10, 108, 19, 33, 75, 22, 167, 25, 18, 118, 217, 141, 149, 250, 78, 188, 152, 52, 245, 50, 62, 195, 2])));
/// PC: boa1xrpc00j53zp9pl4lp7rak39flhs00x6l4puuf9hnn3e883n8jaxfjewy3f0
static immutable PC = KeyPair(PublicKey(Point([195, 135, 190, 84, 136, 130, 80, 254, 191, 15, 135, 219, 68, 169, 253, 224, 247, 155, 95, 168, 121, 196, 150, 243, 156, 114, 115, 198, 103, 151, 76, 153])), SecretKey(Scalar([236, 40, 131, 240, 150, 183, 186, 103, 210, 136, 221, 91, 78, 119, 178, 2, 27, 92, 199, 155, 225, 228, 218, 90, 122, 66, 12, 219, 250, 253, 123, 0])));
/// PD: boa1xqpd003v6ty4x8aga52epjwgkf7jd4n2673cfp3sdf7gzfahgvaw7h2g2ns
static immutable PD = KeyPair(PublicKey(Point([2, 215, 190, 44, 210, 201, 83, 31, 168, 237, 21, 144, 201, 200, 178, 125, 38, 214, 106, 215, 163, 132, 134, 48, 106, 124, 129, 39, 183, 67, 58, 239])), SecretKey(Scalar([87, 232, 6, 20, 72, 67, 184, 108, 135, 233, 142, 167, 97, 171, 64, 176, 174, 93, 60, 76, 44, 38, 244, 224, 78, 69, 146, 25, 213, 71, 49, 5])));
/// PE: boa1xppe006mvz954t7r7je5exzttvc2h9sqvhe580mzegctan2js8582frsv4f
static immutable PE = KeyPair(PublicKey(Point([67, 151, 191, 91, 96, 139, 74, 175, 195, 244, 179, 76, 152, 75, 91, 48, 171, 150, 0, 101, 243, 67, 191, 98, 202, 48, 190, 205, 82, 129, 232, 117])), SecretKey(Scalar([148, 117, 18, 59, 86, 178, 41, 88, 243, 137, 25, 137, 123, 208, 127, 161, 187, 124, 229, 37, 177, 187, 17, 38, 172, 175, 186, 115, 63, 107, 203, 12])));
/// PF: boa1xppf00a7uxscx886qa9l0tup753a8alejgn0g9xwv9madt5zsxnljv5gm3r
static immutable PF = KeyPair(PublicKey(Point([66, 151, 191, 190, 225, 161, 131, 28, 250, 7, 75, 247, 175, 129, 245, 35, 211, 247, 249, 146, 38, 244, 20, 206, 97, 119, 214, 174, 130, 129, 167, 249])), SecretKey(Scalar([100, 102, 98, 170, 221, 238, 27, 200, 39, 24, 131, 74, 81, 177, 193, 231, 192, 172, 134, 200, 245, 111, 200, 140, 48, 166, 9, 102, 192, 184, 12, 10])));
/// PG: boa1xzpg009tdd5cw8a3g7v38yfv6srqqv3mjuyddlqw9e9xf8te5t44sttre80
static immutable PG = KeyPair(PublicKey(Point([130, 135, 188, 171, 107, 105, 135, 31, 177, 71, 153, 19, 145, 44, 212, 6, 0, 50, 59, 151, 8, 214, 252, 14, 46, 74, 100, 157, 121, 162, 235, 88])), SecretKey(Scalar([207, 41, 250, 96, 244, 212, 239, 21, 204, 243, 26, 113, 72, 189, 23, 32, 96, 35, 173, 218, 80, 159, 113, 152, 236, 122, 87, 35, 201, 76, 74, 1])));
/// PH: boa1xqph00jms49608m7y6ngqh0uhkur9q58c0jgcl0rnrxd23jvp27lkk4knrz
static immutable PH = KeyPair(PublicKey(Point([3, 119, 190, 91, 133, 75, 167, 159, 126, 38, 166, 128, 93, 252, 189, 184, 50, 130, 135, 195, 228, 140, 125, 227, 152, 204, 213, 70, 76, 10, 189, 251])), SecretKey(Scalar([244, 164, 0, 42, 195, 77, 159, 202, 10, 146, 0, 242, 67, 198, 80, 38, 73, 166, 91, 57, 101, 117, 113, 85, 27, 60, 158, 71, 54, 142, 152, 7])));
/// PJ: boa1xppj00nzsrcp3945tktxrh2r3tscfn9w65vz8qpnxf5dz0e85h58ujvsq9r
static immutable PJ = KeyPair(PublicKey(Point([67, 39, 190, 98, 128, 240, 24, 150, 180, 93, 150, 97, 221, 67, 138, 225, 132, 204, 174, 213, 24, 35, 128, 51, 50, 104, 209, 63, 39, 165, 232, 126])), SecretKey(Scalar([83, 170, 165, 254, 185, 201, 87, 0, 53, 159, 155, 41, 253, 54, 26, 105, 174, 39, 136, 132, 104, 180, 37, 236, 237, 63, 4, 6, 199, 39, 203, 11])));
/// PK: boa1xppk006g7nrlpez08sawd8fxdlr0gnfgfw2de5skzqltszgq5yglctey9sn
static immutable PK = KeyPair(PublicKey(Point([67, 103, 191, 72, 244, 199, 240, 228, 79, 60, 58, 230, 157, 38, 111, 198, 244, 77, 40, 75, 148, 220, 210, 22, 16, 62, 184, 9, 0, 161, 17, 252])), SecretKey(Scalar([48, 88, 136, 121, 190, 130, 72, 91, 207, 5, 237, 171, 8, 213, 36, 130, 47, 94, 210, 167, 232, 117, 239, 26, 15, 38, 216, 251, 28, 18, 202, 2])));
/// PL: boa1xppl0033tlfk9mk0avqzs26j984nj372ve7w436fq2p00u6xrye0vx8f2ga
static immutable PL = KeyPair(PublicKey(Point([67, 247, 190, 49, 95, 211, 98, 238, 207, 235, 0, 40, 43, 82, 41, 235, 57, 71, 202, 102, 124, 234, 199, 73, 2, 130, 247, 243, 70, 25, 50, 246])), SecretKey(Scalar([134, 203, 213, 77, 230, 118, 251, 65, 111, 33, 228, 191, 98, 83, 176, 2, 139, 176, 123, 177, 228, 109, 75, 43, 44, 83, 95, 49, 184, 248, 171, 11])));
/// PM: boa1xqpm00rur2jtt9rxmzglychymja8jptx95gxfhnr2fkj0m9z3r2exq2gpmq
static immutable PM = KeyPair(PublicKey(Point([3, 183, 188, 124, 26, 164, 181, 148, 102, 216, 145, 242, 98, 228, 220, 186, 121, 5, 102, 45, 16, 100, 222, 99, 82, 109, 39, 236, 162, 136, 213, 147])), SecretKey(Scalar([247, 33, 65, 244, 210, 106, 158, 54, 161, 85, 205, 105, 204, 38, 80, 147, 99, 149, 27, 48, 53, 73, 109, 57, 170, 24, 136, 140, 122, 252, 190, 14])));
/// PN: boa1xppn00g7sfsyypdtrzapjwfcdjfnge7ju8rvfx3j0thttkdp0f0kv7u8rk9
static immutable PN = KeyPair(PublicKey(Point([67, 55, 189, 30, 130, 96, 66, 5, 171, 24, 186, 25, 57, 56, 108, 147, 52, 103, 210, 225, 198, 196, 154, 50, 122, 238, 181, 217, 161, 122, 95, 102])), SecretKey(Scalar([98, 250, 95, 104, 240, 83, 30, 146, 101, 113, 113, 75, 114, 179, 80, 251, 129, 33, 41, 110, 127, 221, 117, 156, 146, 192, 40, 22, 118, 69, 50, 3])));
/// PP: boa1xppp009alfw25mzjetzh9fs349mt47xct265gufswyfqdpax4ramyddw8k0
static immutable PP = KeyPair(PublicKey(Point([66, 23, 188, 189, 250, 92, 170, 108, 82, 202, 197, 114, 166, 17, 169, 118, 186, 248, 216, 90, 181, 68, 113, 48, 113, 18, 6, 135, 166, 168, 251, 178])), SecretKey(Scalar([246, 32, 206, 15, 35, 54, 71, 129, 161, 209, 203, 80, 155, 220, 219, 77, 65, 9, 137, 17, 234, 89, 52, 74, 233, 78, 17, 67, 88, 141, 94, 7])));
/// PQ: boa1xzpq00hqdh8zr6mf42xl38fc7f50h5k36dnznk6wtu8wk687dqm5glp6svf
static immutable PQ = KeyPair(PublicKey(Point([130, 7, 190, 224, 109, 206, 33, 235, 105, 170, 141, 248, 157, 56, 242, 104, 251, 210, 209, 211, 102, 41, 219, 78, 95, 14, 235, 104, 254, 104, 55, 68])), SecretKey(Scalar([20, 108, 84, 11, 101, 104, 139, 168, 247, 241, 121, 44, 15, 53, 25, 244, 172, 165, 254, 151, 131, 147, 93, 169, 144, 201, 140, 251, 126, 18, 140, 2])));
/// PR: boa1xppr00ztf4zdfrzfpul6sq5w0g8zws2j0w987m0puqfcdhw4r0ejvfhd7nl
static immutable PR = KeyPair(PublicKey(Point([66, 55, 188, 75, 77, 68, 212, 140, 73, 15, 63, 168, 2, 142, 122, 14, 39, 65, 82, 123, 138, 127, 109, 225, 224, 19, 134, 221, 213, 27, 243, 38])), SecretKey(Scalar([206, 194, 115, 156, 242, 46, 171, 123, 33, 219, 118, 125, 119, 34, 240, 217, 35, 184, 188, 119, 173, 167, 154, 58, 223, 63, 169, 105, 73, 59, 194, 3])));
/// PS: boa1xrps007eqtqa0whxukn679lh0jjx495esw6e0dj3t4za2xytfdz5c9jy3rf
static immutable PS = KeyPair(PublicKey(Point([195, 7, 191, 217, 2, 193, 215, 186, 230, 229, 167, 175, 23, 247, 124, 164, 106, 150, 153, 131, 181, 151, 182, 81, 93, 69, 213, 24, 139, 75, 69, 76])), SecretKey(Scalar([161, 148, 87, 156, 11, 52, 168, 142, 46, 178, 61, 229, 168, 0, 29, 75, 44, 33, 111, 110, 121, 76, 239, 28, 9, 82, 135, 0, 105, 13, 160, 8])));
/// PT: boa1xqpt00e4666lc32sva94k7tsq75692xg95ptgpszll0gm0l9q93vgq3fxa6
static immutable PT = KeyPair(PublicKey(Point([2, 183, 191, 53, 214, 181, 252, 69, 80, 103, 75, 91, 121, 112, 7, 169, 162, 168, 200, 45, 2, 180, 6, 2, 255, 222, 141, 191, 229, 1, 98, 196])), SecretKey(Scalar([232, 115, 236, 21, 137, 157, 240, 208, 0, 60, 159, 136, 208, 246, 211, 69, 63, 251, 227, 119, 0, 148, 137, 232, 1, 145, 88, 14, 224, 249, 46, 8])));
/// PU: boa1xzpu00caz24qpmqmuyap0wlfx2pje6fasuqfnzek4j4dvd8wq8y5ctfwpyk
static immutable PU = KeyPair(PublicKey(Point([131, 199, 191, 29, 18, 170, 0, 236, 27, 225, 58, 23, 187, 233, 50, 131, 44, 233, 61, 135, 0, 153, 139, 54, 172, 170, 214, 52, 238, 1, 201, 76])), SecretKey(Scalar([191, 237, 144, 36, 64, 41, 212, 35, 163, 232, 174, 224, 91, 131, 73, 173, 142, 240, 237, 73, 171, 3, 81, 39, 39, 0, 227, 208, 160, 125, 80, 15])));
/// PV: boa1xrpv00huxl3y722aygp0wp24638wqmdajam3c044mq3dsfl0cz9fc24r7as
static immutable PV = KeyPair(PublicKey(Point([194, 199, 190, 252, 55, 226, 79, 41, 93, 34, 2, 247, 5, 85, 212, 78, 224, 109, 189, 151, 119, 28, 62, 181, 216, 34, 216, 39, 239, 192, 138, 156])), SecretKey(Scalar([136, 85, 242, 15, 144, 159, 241, 98, 95, 20, 16, 151, 252, 87, 72, 17, 214, 48, 239, 225, 197, 102, 195, 141, 8, 166, 105, 50, 47, 142, 49, 4])));
/// PW: boa1xrpw002qje4dd7c4zwu8hexpmf6fduuzx00xr7y0u274lvyeqwuzge0hza6
static immutable PW = KeyPair(PublicKey(Point([194, 231, 189, 64, 150, 106, 214, 251, 21, 19, 184, 123, 228, 193, 218, 116, 150, 243, 130, 51, 222, 97, 248, 143, 226, 189, 95, 176, 153, 3, 184, 36])), SecretKey(Scalar([7, 77, 214, 160, 172, 57, 112, 171, 182, 229, 184, 26, 149, 2, 158, 55, 221, 115, 151, 128, 152, 108, 14, 84, 170, 74, 14, 58, 16, 13, 195, 4])));
/// PX: boa1xqpx00393x8pzurg7nnmu2yjm8hyycquamy9pjrxem0utsj5xd6sc7w02u4
static immutable PX = KeyPair(PublicKey(Point([2, 103, 190, 37, 137, 142, 17, 112, 104, 244, 231, 190, 40, 146, 217, 238, 66, 96, 28, 238, 200, 80, 200, 102, 206, 223, 197, 194, 84, 51, 117, 12])), SecretKey(Scalar([173, 189, 124, 104, 98, 34, 35, 166, 51, 233, 126, 171, 81, 21, 129, 78, 137, 34, 63, 18, 192, 138, 227, 36, 18, 13, 106, 0, 193, 213, 60, 11])));
/// PY: boa1xzpy00ygxrj82c66udcuhyejrljnuquyx0f4y7yk2lhraazyg50c7v6py94
static immutable PY = KeyPair(PublicKey(Point([130, 71, 188, 136, 48, 228, 117, 99, 90, 227, 113, 203, 147, 50, 31, 229, 62, 3, 132, 51, 211, 82, 120, 150, 87, 238, 62, 244, 68, 69, 31, 143])), SecretKey(Scalar([89, 79, 13, 235, 121, 195, 254, 165, 254, 27, 121, 17, 47, 247, 1, 125, 243, 14, 42, 98, 103, 152, 215, 170, 7, 4, 5, 173, 240, 175, 75, 14])));
/// PZ: boa1xppz00cv25tjfkx93j998g90ggjmpyky64dtxuaqh5qxcxud5f9yww64cxq
static immutable PZ = KeyPair(PublicKey(Point([66, 39, 191, 12, 85, 23, 36, 216, 197, 140, 138, 83, 160, 175, 66, 37, 176, 146, 196, 213, 90, 179, 115, 160, 189, 0, 108, 27, 141, 162, 74, 71])), SecretKey(Scalar([6, 77, 193, 228, 167, 119, 53, 230, 190, 166, 254, 255, 89, 153, 250, 166, 161, 177, 55, 22, 30, 240, 69, 75, 135, 159, 75, 211, 12, 152, 141, 5])));
/// QA: boa1xqqa00jsjy8qsmfuly2kx03clzc5avyuxs5q6szcx6dncujlf35cu43xs5t
static immutable QA = KeyPair(PublicKey(Point([1, 215, 190, 80, 145, 14, 8, 109, 60, 249, 21, 99, 62, 56, 248, 177, 78, 176, 156, 52, 40, 13, 64, 88, 54, 155, 60, 114, 95, 76, 105, 142])), SecretKey(Scalar([8, 202, 177, 201, 65, 111, 78, 241, 138, 172, 75, 102, 236, 175, 77, 178, 52, 127, 228, 89, 39, 212, 162, 207, 1, 86, 205, 14, 36, 85, 223, 14])));
/// QC: boa1xrqc00lu9jvareccjh9q3d5xg9urgpc8jk8wh7wknmv2mz7ej32nqn4w3ff
static immutable QC = KeyPair(PublicKey(Point([193, 135, 191, 252, 44, 153, 209, 231, 24, 149, 202, 8, 182, 134, 65, 120, 52, 7, 7, 149, 142, 235, 249, 214, 158, 216, 173, 139, 217, 148, 85, 48])), SecretKey(Scalar([52, 165, 133, 203, 245, 187, 91, 244, 197, 232, 9, 18, 8, 164, 142, 171, 109, 196, 79, 116, 160, 154, 252, 240, 140, 213, 139, 162, 105, 37, 115, 15])));
/// QD: boa1xpqd00y5f62zf3n2uaetsxs5flh2qawkekc7n36dzmslwjlegnln65y2jks
static immutable QD = KeyPair(PublicKey(Point([64, 215, 188, 148, 78, 148, 36, 198, 106, 231, 114, 184, 26, 20, 79, 238, 160, 117, 214, 205, 177, 233, 199, 77, 22, 225, 247, 75, 249, 68, 255, 61])), SecretKey(Scalar([181, 8, 32, 146, 219, 153, 93, 105, 251, 35, 211, 20, 248, 35, 122, 48, 121, 162, 86, 49, 244, 184, 98, 214, 254, 216, 124, 99, 71, 226, 106, 5])));
/// QE: boa1xpqe00y8gs30867qffs4qhma5ddmuzm3l79zsyn24vu8zenxdkexkva853k
static immutable QE = KeyPair(PublicKey(Point([65, 151, 188, 135, 68, 34, 243, 235, 192, 74, 97, 80, 95, 125, 163, 91, 190, 11, 113, 255, 138, 40, 18, 106, 171, 56, 113, 102, 102, 109, 178, 107])), SecretKey(Scalar([43, 69, 248, 163, 33, 126, 132, 173, 128, 0, 47, 190, 16, 60, 40, 239, 214, 163, 2, 98, 253, 160, 137, 154, 67, 225, 36, 84, 203, 87, 50, 2])));
/// QF: boa1xrqf00qnsy3ahnmvfn9zakgfmludthcf8tva00lug26x3mumvjwuw49sfyw
static immutable QF = KeyPair(PublicKey(Point([192, 151, 188, 19, 129, 35, 219, 207, 108, 76, 202, 46, 217, 9, 223, 248, 213, 223, 9, 58, 217, 215, 191, 252, 66, 180, 104, 239, 155, 100, 157, 199])), SecretKey(Scalar([137, 178, 182, 143, 44, 197, 238, 30, 42, 74, 76, 149, 251, 152, 55, 26, 146, 138, 232, 216, 186, 205, 97, 187, 208, 217, 68, 69, 91, 194, 161, 11])));
/// QG: boa1xqqg00k4zmlyrrzm3shcd02mc3qrrc72rpjxuzdxk4emekmhl8w7k3th2dr
static immutable QG = KeyPair(PublicKey(Point([0, 135, 190, 213, 22, 254, 65, 140, 91, 140, 47, 134, 189, 91, 196, 64, 49, 227, 202, 24, 100, 110, 9, 166, 181, 115, 188, 219, 119, 249, 221, 235])), SecretKey(Scalar([210, 130, 15, 206, 120, 95, 251, 38, 102, 23, 235, 193, 77, 173, 96, 8, 26, 202, 243, 110, 187, 223, 112, 38, 222, 111, 203, 70, 11, 159, 109, 8])));
/// QH: boa1xzqh00x240szkzr40c98dhnm5qnxennhtlpcedw8pdluyuye89r66x6kwqr
static immutable QH = KeyPair(PublicKey(Point([129, 119, 188, 202, 171, 224, 43, 8, 117, 126, 10, 118, 222, 123, 160, 38, 108, 206, 119, 95, 195, 140, 181, 199, 11, 127, 194, 112, 153, 57, 71, 173])), SecretKey(Scalar([143, 106, 37, 115, 64, 140, 237, 14, 241, 156, 41, 103, 185, 253, 240, 183, 89, 201, 66, 151, 75, 112, 117, 51, 19, 227, 146, 1, 100, 119, 92, 4])));
/// QJ: boa1xrqj00up0mmeedeytypf9xqe49nryjav66shhgqxvy7eevv6x9ev7d0tmxg
static immutable QJ = KeyPair(PublicKey(Point([193, 39, 191, 129, 126, 247, 156, 183, 36, 89, 2, 146, 152, 25, 169, 102, 50, 75, 172, 214, 161, 123, 160, 6, 97, 61, 156, 177, 154, 49, 114, 207])), SecretKey(Scalar([164, 234, 45, 68, 104, 60, 152, 154, 58, 10, 20, 136, 61, 123, 177, 240, 29, 9, 203, 241, 221, 93, 240, 126, 127, 13, 127, 211, 111, 239, 242, 8])));
/// QK: boa1xpqk00xfv4c2qc5tg2kg5r5c5celf6svjwkxy7rgx3um266uv4tzjgfhhk8
static immutable QK = KeyPair(PublicKey(Point([65, 103, 188, 201, 101, 112, 160, 98, 139, 66, 172, 138, 14, 152, 166, 51, 244, 234, 12, 147, 172, 98, 120, 104, 52, 121, 181, 107, 92, 101, 86, 41])), SecretKey(Scalar([120, 66, 61, 184, 244, 166, 255, 211, 244, 249, 17, 172, 182, 118, 182, 62, 105, 59, 40, 255, 249, 47, 19, 50, 158, 131, 37, 100, 73, 149, 131, 15])));
/// QL: boa1xqql00dphj6e282prh37k8sxf7gyfrvkxatpqp6nsjyu4xx6nfuekcgpu3y
static immutable QL = KeyPair(PublicKey(Point([1, 247, 189, 161, 188, 181, 149, 29, 65, 29, 227, 235, 30, 6, 79, 144, 68, 141, 150, 55, 86, 16, 7, 83, 132, 137, 202, 152, 218, 154, 121, 155])), SecretKey(Scalar([177, 233, 97, 28, 239, 217, 109, 127, 33, 167, 168, 241, 215, 77, 2, 244, 194, 196, 235, 30, 75, 102, 5, 109, 112, 35, 15, 242, 77, 22, 244, 10])));
/// QM: boa1xrqm00d3sy2la054yjaegx0eu070w5tav7553x96mn4prwtjh9jdwtsyn0v
static immutable QM = KeyPair(PublicKey(Point([193, 183, 189, 177, 129, 21, 254, 190, 149, 36, 187, 148, 25, 249, 227, 252, 247, 81, 125, 103, 169, 72, 152, 186, 220, 234, 17, 185, 114, 185, 100, 215])), SecretKey(Scalar([150, 29, 231, 7, 92, 57, 140, 128, 85, 223, 94, 252, 82, 172, 103, 121, 66, 18, 13, 141, 248, 34, 193, 39, 179, 156, 14, 225, 125, 145, 45, 13])));
/// QN: boa1xpqn007hf7rnw90pa0ah6pcf6ava33f2dtnlxqzq0df6pmkptlzn2laf4hu
static immutable QN = KeyPair(PublicKey(Point([65, 55, 191, 215, 79, 135, 55, 21, 225, 235, 251, 125, 7, 9, 215, 89, 216, 197, 42, 106, 231, 243, 0, 64, 123, 83, 160, 238, 193, 95, 197, 53])), SecretKey(Scalar([118, 12, 52, 88, 56, 174, 8, 8, 151, 144, 240, 106, 71, 110, 158, 248, 168, 73, 125, 77, 139, 145, 23, 151, 96, 237, 78, 77, 21, 105, 91, 8])));
/// QP: boa1xzqp002z7tdz4rpcyf8mg5t59hamv0rkndlankhkc0unygyv3h4hustjgd6
static immutable QP = KeyPair(PublicKey(Point([128, 23, 189, 66, 242, 218, 42, 140, 56, 34, 79, 180, 81, 116, 45, 251, 182, 60, 118, 155, 127, 217, 218, 246, 195, 249, 50, 32, 140, 141, 235, 126])), SecretKey(Scalar([12, 116, 187, 46, 218, 175, 37, 73, 48, 174, 196, 88, 38, 183, 113, 126, 154, 131, 170, 238, 195, 137, 139, 157, 140, 129, 240, 219, 32, 169, 200, 6])));
/// QQ: boa1xzqq00x66sye2ejxd5cly3543uth04tt74ssauw3hfnuucpgssd7gq608x9
static immutable QQ = KeyPair(PublicKey(Point([128, 7, 188, 218, 212, 9, 149, 102, 70, 109, 49, 242, 70, 149, 143, 23, 119, 213, 107, 245, 97, 14, 241, 209, 186, 103, 206, 96, 40, 132, 27, 228])), SecretKey(Scalar([60, 79, 121, 96, 144, 179, 85, 35, 32, 173, 52, 159, 195, 232, 236, 41, 168, 48, 94, 123, 13, 54, 99, 188, 72, 96, 188, 57, 96, 100, 111, 1])));
/// QR: boa1xzqr00tegae3cvhl2g3kc7g8je69szxa80cdvl4pwts5tlrmehx35es7ca8
static immutable QR = KeyPair(PublicKey(Point([128, 55, 189, 121, 71, 115, 28, 50, 255, 82, 35, 108, 121, 7, 150, 116, 88, 8, 221, 59, 240, 214, 126, 161, 114, 225, 69, 252, 123, 205, 205, 26])), SecretKey(Scalar([239, 239, 133, 94, 139, 75, 91, 82, 217, 52, 92, 216, 119, 246, 3, 201, 188, 163, 108, 217, 218, 192, 68, 74, 23, 91, 156, 226, 252, 115, 109, 3])));
/// QS: boa1xrqs000ky4xzxs4dgevlgxewpsmpsa64n905gzfkn9k4lclhmz80kr843js
static immutable QS = KeyPair(PublicKey(Point([193, 7, 189, 246, 37, 76, 35, 66, 173, 70, 89, 244, 27, 46, 12, 54, 24, 119, 85, 153, 95, 68, 9, 54, 153, 109, 95, 227, 247, 216, 142, 251])), SecretKey(Scalar([105, 215, 104, 183, 159, 118, 67, 74, 44, 164, 193, 193, 239, 204, 25, 163, 96, 218, 253, 178, 123, 200, 178, 144, 72, 170, 199, 180, 15, 116, 179, 0])));
/// QT: boa1xpqt00m858rqzs3xx78dfsdt29hh3vca0hpwcse5c7hctdqt0uhmzwuynkt
static immutable QT = KeyPair(PublicKey(Point([64, 183, 191, 103, 161, 198, 1, 66, 38, 55, 142, 212, 193, 171, 81, 111, 120, 179, 29, 125, 194, 236, 67, 52, 199, 175, 133, 180, 11, 127, 47, 177])), SecretKey(Scalar([50, 45, 249, 83, 185, 136, 78, 38, 163, 42, 227, 217, 71, 90, 243, 9, 11, 236, 190, 90, 184, 203, 167, 169, 73, 58, 199, 75, 154, 169, 150, 8])));
/// QU: boa1xzqu00nhutal8857kpkexl8yf3q5f6c3jmxe6c63j7d4hz9rcf537wvl7k7
static immutable QU = KeyPair(PublicKey(Point([129, 199, 190, 119, 226, 251, 243, 158, 158, 176, 109, 147, 124, 228, 76, 65, 68, 235, 17, 150, 205, 157, 99, 81, 151, 155, 91, 136, 163, 194, 105, 31])), SecretKey(Scalar([93, 181, 22, 125, 32, 171, 22, 49, 54, 97, 75, 157, 219, 10, 147, 162, 169, 195, 103, 138, 48, 236, 102, 203, 169, 75, 11, 135, 251, 248, 164, 12])));
/// QV: boa1xpqv00dvsxm4j0qpr6t2ltu45m0ylfe3jgk79cnt3v25jzcsd82uq22klyg
static immutable QV = KeyPair(PublicKey(Point([64, 199, 189, 172, 129, 183, 89, 60, 1, 30, 150, 175, 175, 149, 166, 222, 79, 167, 49, 146, 45, 226, 226, 107, 139, 21, 73, 11, 16, 105, 213, 192])), SecretKey(Scalar([40, 74, 228, 37, 201, 5, 105, 78, 159, 202, 247, 14, 26, 147, 4, 243, 65, 198, 231, 41, 92, 232, 33, 254, 178, 212, 172, 227, 56, 42, 41, 7])));
/// QW: boa1xqqw00ldzkaxt75sjuy529fdt0g0ynelfsgtaxdyuufuy8caaeaugq2nq4t
static immutable QW = KeyPair(PublicKey(Point([0, 231, 191, 237, 21, 186, 101, 250, 144, 151, 9, 69, 21, 45, 91, 208, 242, 79, 63, 76, 16, 190, 153, 164, 231, 19, 194, 31, 29, 238, 123, 196])), SecretKey(Scalar([18, 214, 11, 245, 189, 250, 198, 229, 12, 169, 156, 216, 99, 85, 239, 162, 66, 7, 131, 58, 31, 72, 248, 190, 83, 136, 227, 9, 1, 128, 114, 8])));
/// QX: boa1xpqx004z936a56j0u5u6xapzzvh8xu3653fw36fd8fqkmjtvmrlpwl0ymay
static immutable QX = KeyPair(PublicKey(Point([64, 103, 190, 162, 44, 117, 218, 106, 79, 229, 57, 163, 116, 34, 19, 46, 115, 114, 58, 164, 82, 232, 233, 45, 58, 65, 109, 201, 108, 216, 254, 23])), SecretKey(Scalar([38, 211, 119, 146, 116, 119, 142, 19, 148, 191, 240, 93, 47, 120, 115, 116, 168, 146, 85, 207, 64, 27, 41, 197, 118, 96, 230, 148, 155, 160, 15, 2])));
/// QY: boa1xqqy00xapv08f6qrxnw5l6rn9mmjdrhrjtpwztm2e8yvxvzmt7deqd9v5uh
static immutable QY = KeyPair(PublicKey(Point([0, 71, 188, 221, 11, 30, 116, 232, 3, 52, 221, 79, 232, 115, 46, 247, 38, 142, 227, 146, 194, 225, 47, 106, 201, 200, 195, 48, 91, 95, 155, 144])), SecretKey(Scalar([119, 219, 225, 176, 64, 70, 240, 126, 244, 123, 118, 65, 227, 91, 130, 207, 247, 217, 218, 196, 221, 249, 72, 181, 28, 151, 231, 54, 105, 139, 11, 4])));
/// QZ: boa1xpqz00u5y2ks6mnalalqtn896sgwhdn2zrf0d5f34xvjja0svzhgs8rygrp
static immutable QZ = KeyPair(PublicKey(Point([64, 39, 191, 148, 34, 173, 13, 110, 125, 255, 126, 5, 204, 229, 212, 16, 235, 182, 106, 16, 210, 246, 209, 49, 169, 153, 41, 117, 240, 96, 174, 136])), SecretKey(Scalar([106, 56, 152, 217, 2, 60, 101, 197, 196, 218, 204, 48, 201, 172, 179, 28, 6, 116, 68, 134, 241, 219, 183, 75, 59, 181, 23, 90, 129, 52, 151, 11])));
/// RA: boa1xzra00te4xfr6yxg7xd58eln8llve569hn72ukzz0agncwuvn2uszk45ayg
static immutable RA = KeyPair(PublicKey(Point([135, 215, 189, 121, 169, 146, 61, 16, 200, 241, 155, 67, 231, 243, 63, 254, 204, 211, 69, 188, 252, 174, 88, 66, 127, 81, 60, 59, 140, 154, 185, 1])), SecretKey(Scalar([118, 113, 103, 136, 104, 120, 39, 199, 5, 225, 152, 163, 37, 72, 242, 110, 53, 25, 216, 17, 66, 94, 223, 85, 208, 53, 137, 250, 231, 191, 142, 5])));
/// RC: boa1xzrc00uefc32yenk07q6u25f8pp594k4cprrzwcveztdx24lr3v4jpwlqwg
static immutable RC = KeyPair(PublicKey(Point([135, 135, 191, 153, 78, 34, 162, 102, 118, 127, 129, 174, 42, 137, 56, 67, 66, 214, 213, 192, 70, 49, 59, 12, 200, 150, 211, 42, 191, 28, 89, 89])), SecretKey(Scalar([157, 229, 75, 62, 107, 64, 43, 93, 107, 46, 3, 80, 191, 146, 198, 219, 78, 37, 108, 98, 194, 96, 173, 217, 147, 91, 131, 123, 166, 224, 33, 4])));
/// RD: boa1xrrd00mrncwzyxlsd87exe57p89ulxu9nhgh3chjg9xj6wk7ysu052hwfh5
static immutable RD = KeyPair(PublicKey(Point([198, 215, 191, 99, 158, 28, 34, 27, 240, 105, 253, 147, 102, 158, 9, 203, 207, 155, 133, 157, 209, 120, 226, 242, 65, 77, 45, 58, 222, 36, 56, 250])), SecretKey(Scalar([228, 23, 147, 232, 6, 151, 24, 181, 239, 57, 213, 249, 97, 54, 27, 235, 194, 80, 42, 167, 52, 116, 241, 247, 19, 87, 167, 232, 253, 173, 181, 15])));
/// RE: boa1xzre000thp9r3u0kxlhfe0rt5m3xlse0gmmcnxqqpnxc3vw2nhdv2auejmg
static immutable RE = KeyPair(PublicKey(Point([135, 151, 189, 235, 184, 74, 56, 241, 246, 55, 238, 156, 188, 107, 166, 226, 111, 195, 47, 70, 247, 137, 152, 0, 12, 205, 136, 177, 202, 157, 218, 197])), SecretKey(Scalar([116, 105, 187, 184, 164, 26, 21, 251, 242, 243, 241, 66, 7, 196, 23, 97, 91, 6, 69, 230, 244, 140, 191, 204, 226, 114, 199, 200, 27, 65, 113, 4])));
/// RF: boa1xzrf00m4sh4xh7ey8t8zrnknu27yhjrt0qqjffvn3kd3cacp9vm22fc2d2d
static immutable RF = KeyPair(PublicKey(Point([134, 151, 191, 117, 133, 234, 107, 251, 36, 58, 206, 33, 206, 211, 226, 188, 75, 200, 107, 120, 1, 36, 165, 147, 141, 155, 28, 119, 1, 43, 54, 165])), SecretKey(Scalar([96, 133, 88, 177, 34, 215, 4, 106, 122, 130, 82, 6, 38, 5, 236, 139, 144, 101, 100, 10, 80, 18, 90, 48, 181, 52, 95, 185, 80, 199, 76, 12])));
/// RG: boa1xprg00hyh24v4c7rlkqjga3ttqd7u02855g6w2qac0ez0k4vpt6kqxpqvwg
static immutable RG = KeyPair(PublicKey(Point([70, 135, 190, 228, 186, 170, 202, 227, 195, 253, 129, 36, 118, 43, 88, 27, 238, 61, 71, 165, 17, 167, 40, 29, 195, 242, 39, 218, 172, 10, 245, 96])), SecretKey(Scalar([50, 171, 107, 22, 53, 51, 101, 243, 51, 118, 121, 139, 96, 53, 83, 141, 233, 139, 235, 253, 31, 240, 225, 178, 113, 162, 230, 216, 151, 230, 154, 12])));
/// RH: boa1xzrh00v0s0fm2yu6rjz48k38hwg9lxnu8s5j45m8q9c60z0amf0qv8pd7mc
static immutable RH = KeyPair(PublicKey(Point([135, 119, 189, 143, 131, 211, 181, 19, 154, 28, 133, 83, 218, 39, 187, 144, 95, 154, 124, 60, 41, 42, 211, 103, 1, 113, 167, 137, 253, 218, 94, 6])), SecretKey(Scalar([58, 83, 189, 53, 103, 70, 92, 90, 8, 250, 243, 167, 205, 115, 31, 106, 98, 128, 99, 222, 44, 249, 12, 97, 209, 41, 60, 114, 47, 48, 60, 1])));
/// RJ: boa1xrrj000fj7upq6d4vn9gcupqy7gdutcpurp4e9q2v3udpzrhxk9lkpv6jjn
static immutable RJ = KeyPair(PublicKey(Point([199, 39, 189, 233, 151, 184, 16, 105, 181, 100, 202, 140, 112, 32, 39, 144, 222, 47, 1, 224, 195, 92, 148, 10, 100, 120, 208, 136, 119, 53, 139, 251])), SecretKey(Scalar([64, 193, 232, 213, 133, 195, 98, 218, 153, 38, 186, 151, 243, 179, 39, 202, 6, 209, 143, 231, 48, 6, 48, 128, 145, 74, 254, 177, 155, 39, 213, 4])));
/// RK: boa1xqrk00y3syh0f63vmt496r7y0zq06clgk8p5c84he4lhuvhlwgxa5c3ml7p
static immutable RK = KeyPair(PublicKey(Point([7, 103, 188, 145, 129, 46, 244, 234, 44, 218, 234, 93, 15, 196, 120, 128, 253, 99, 232, 177, 195, 76, 30, 183, 205, 127, 126, 50, 255, 114, 13, 218])), SecretKey(Scalar([175, 235, 10, 173, 10, 145, 158, 149, 162, 43, 234, 163, 236, 106, 139, 124, 251, 156, 109, 98, 208, 204, 27, 131, 78, 10, 139, 16, 141, 188, 11, 4])));
/// RL: boa1xprl00kucm9m57zekj4aapuc5cdxsc3vch4hlhwpjf2nuy0dwq75j78xt7j
static immutable RL = KeyPair(PublicKey(Point([71, 247, 190, 220, 198, 203, 186, 120, 89, 180, 171, 222, 135, 152, 166, 26, 104, 98, 44, 197, 235, 127, 221, 193, 146, 85, 62, 17, 237, 112, 61, 73])), SecretKey(Scalar([206, 23, 138, 45, 254, 204, 207, 24, 145, 64, 219, 60, 243, 191, 237, 108, 7, 143, 52, 127, 71, 174, 251, 190, 144, 26, 78, 50, 48, 112, 74, 12])));
/// RM: boa1xprm00kyq3t7z8qyn0qn59m9fgs4xyrc8444fqpek5ss7de30eh0k2farm8
static immutable RM = KeyPair(PublicKey(Point([71, 183, 190, 196, 4, 87, 225, 28, 4, 155, 193, 58, 23, 101, 74, 33, 83, 16, 120, 61, 107, 84, 128, 57, 181, 33, 15, 55, 49, 126, 110, 251])), SecretKey(Scalar([10, 247, 77, 191, 40, 34, 189, 23, 35, 218, 135, 3, 138, 87, 38, 109, 26, 127, 147, 172, 100, 55, 76, 186, 190, 186, 105, 18, 214, 37, 73, 2])));
/// RN: boa1xzrn00664kvvc9ldeyqratzjhdsquvy3rqgyzs0altgjsnmjhecfqqc2845
static immutable RN = KeyPair(PublicKey(Point([135, 55, 191, 90, 173, 152, 204, 23, 237, 201, 0, 62, 172, 82, 187, 96, 14, 48, 145, 24, 16, 65, 65, 253, 250, 209, 40, 79, 114, 190, 112, 144])), SecretKey(Scalar([234, 203, 46, 79, 20, 128, 72, 203, 10, 111, 17, 119, 230, 107, 176, 125, 28, 106, 240, 133, 201, 15, 137, 182, 172, 95, 233, 66, 203, 104, 249, 1])));
/// RP: boa1xrrp009g29pts2xn7q4ru20uxg00l5cs75j8vl8r46gszvy70kdh5mkm77k
static immutable RP = KeyPair(PublicKey(Point([198, 23, 188, 168, 81, 66, 184, 40, 211, 240, 42, 62, 41, 252, 50, 30, 255, 211, 16, 245, 36, 118, 124, 227, 174, 145, 1, 48, 158, 125, 155, 122])), SecretKey(Scalar([193, 249, 123, 185, 217, 47, 43, 193, 221, 240, 149, 125, 206, 143, 231, 226, 189, 126, 146, 188, 81, 181, 72, 73, 90, 87, 111, 44, 136, 234, 207, 7])));
/// RQ: boa1xzrq00cq8l905t2c2pk08fpf6w2waas3j96v2g6fmdx7u2varn7yqgxj62p
static immutable RQ = KeyPair(PublicKey(Point([134, 7, 191, 0, 63, 202, 250, 45, 88, 80, 108, 243, 164, 41, 211, 148, 238, 246, 17, 145, 116, 197, 35, 73, 219, 77, 238, 41, 157, 28, 252, 64])), SecretKey(Scalar([58, 230, 141, 188, 7, 148, 140, 18, 166, 85, 96, 30, 165, 206, 54, 127, 81, 110, 140, 219, 171, 100, 163, 241, 128, 133, 64, 33, 57, 118, 44, 2])));
/// RR: boa1xqrr00xnghw6d6023h2hy7mngenvsttcsynmxt7qt806xr05ssjpjhqvhwt
static immutable RR = KeyPair(PublicKey(Point([6, 55, 188, 211, 69, 221, 166, 233, 234, 141, 213, 114, 123, 115, 70, 102, 200, 45, 120, 129, 39, 179, 47, 192, 89, 223, 163, 13, 244, 132, 36, 25])), SecretKey(Scalar([120, 44, 86, 61, 125, 60, 145, 50, 255, 145, 144, 181, 18, 134, 6, 186, 162, 242, 237, 2, 219, 253, 50, 147, 102, 253, 234, 105, 156, 0, 93, 12])));
/// RS: boa1xprs006vupkwqev6kpctxjtk2d7vnpgtk5v4048y8acvqsgp3ltsj0eae6t
static immutable RS = KeyPair(PublicKey(Point([71, 7, 191, 76, 224, 108, 224, 101, 154, 176, 112, 179, 73, 118, 83, 124, 201, 133, 11, 181, 25, 87, 212, 228, 63, 112, 192, 65, 1, 143, 215, 9])), SecretKey(Scalar([130, 43, 122, 101, 83, 155, 195, 160, 85, 148, 171, 60, 3, 143, 78, 27, 214, 243, 98, 128, 223, 78, 199, 186, 145, 209, 85, 156, 210, 4, 157, 10])));
/// RT: boa1xzrt000err5k6eurhxhptzlz3dcq0em05d469rmff7eg549msr52qj0f8mh
static immutable RT = KeyPair(PublicKey(Point([134, 183, 189, 249, 24, 233, 109, 103, 131, 185, 174, 21, 139, 226, 139, 112, 7, 231, 111, 163, 107, 162, 143, 105, 79, 178, 138, 84, 187, 128, 232, 160])), SecretKey(Scalar([97, 139, 114, 62, 94, 180, 128, 153, 204, 199, 252, 165, 83, 217, 133, 214, 250, 115, 41, 95, 244, 216, 235, 216, 235, 203, 54, 49, 150, 19, 79, 15])));
/// RU: boa1xpru00hhfgkq49pp72lskddhmfw40y0xa08hjlwvc7pwrnlersm6ckk9gl0
static immutable RU = KeyPair(PublicKey(Point([71, 199, 190, 247, 74, 44, 10, 148, 33, 242, 191, 11, 53, 183, 218, 93, 87, 145, 230, 235, 207, 121, 125, 204, 199, 130, 225, 207, 249, 28, 55, 172])), SecretKey(Scalar([97, 225, 24, 39, 74, 44, 91, 100, 129, 255, 103, 120, 59, 233, 140, 176, 209, 224, 144, 230, 141, 176, 129, 41, 165, 230, 189, 81, 73, 174, 0, 9])));
/// RV: boa1xqrv00dp5mvaxe36rhge6ae6pg3w38xatkhweev35ms9sgy64lua7meu925
static immutable RV = KeyPair(PublicKey(Point([6, 199, 189, 161, 166, 217, 211, 102, 58, 29, 209, 157, 119, 58, 10, 34, 232, 156, 221, 93, 174, 236, 229, 145, 166, 224, 88, 32, 154, 175, 249, 223])), SecretKey(Scalar([64, 185, 74, 253, 29, 143, 236, 200, 65, 201, 117, 61, 29, 200, 86, 192, 237, 148, 84, 187, 154, 239, 21, 110, 252, 116, 176, 58, 81, 149, 8, 10])));
/// RW: boa1xqrw009m7l5u8n6nzu8v5f7nmj6k88p96v26dsvdm2hph2r3v024xt5m02l
static immutable RW = KeyPair(PublicKey(Point([6, 231, 188, 187, 247, 233, 195, 207, 83, 23, 14, 202, 39, 211, 220, 181, 99, 156, 37, 211, 21, 166, 193, 141, 218, 174, 27, 168, 113, 99, 213, 83])), SecretKey(Scalar([75, 251, 117, 155, 102, 188, 132, 144, 246, 161, 151, 13, 49, 131, 81, 97, 220, 120, 19, 179, 99, 229, 192, 130, 141, 213, 90, 223, 140, 255, 121, 11])));
/// RX: boa1xqrx00xghahh8xnlre35gyvew39nq9ws2g79ep4dphcjht83fgyh6l6z2zr
static immutable RX = KeyPair(PublicKey(Point([6, 103, 188, 200, 191, 111, 115, 154, 127, 30, 99, 68, 17, 153, 116, 75, 48, 21, 208, 82, 60, 92, 134, 173, 13, 241, 43, 172, 241, 74, 9, 125])), SecretKey(Scalar([204, 200, 92, 63, 132, 174, 19, 202, 138, 116, 132, 40, 34, 29, 63, 150, 141, 156, 120, 164, 56, 221, 194, 20, 7, 181, 209, 9, 15, 155, 55, 6])));
/// RY: boa1xzry00h07sxt2sc7s4ev0zl20rcv4s9p9fvl57qrehvuh26cx9umz43unmn
static immutable RY = KeyPair(PublicKey(Point([134, 71, 190, 239, 244, 12, 181, 67, 30, 133, 114, 199, 139, 234, 120, 240, 202, 192, 161, 42, 89, 250, 120, 3, 205, 217, 203, 171, 88, 49, 121, 177])), SecretKey(Scalar([78, 108, 164, 5, 156, 113, 152, 165, 3, 246, 246, 49, 109, 136, 211, 199, 3, 133, 225, 29, 223, 218, 204, 28, 147, 239, 203, 204, 220, 46, 115, 4])));
/// RZ: boa1xqrz00c8ezmluuu57mkvfywkw7zszj06q3nus2n09qyfj9ukvwvfkawyyzc
static immutable RZ = KeyPair(PublicKey(Point([6, 39, 191, 7, 200, 183, 254, 115, 148, 246, 236, 196, 145, 214, 119, 133, 1, 73, 250, 4, 103, 200, 42, 111, 40, 8, 153, 23, 150, 99, 152, 155])), SecretKey(Scalar([188, 53, 29, 217, 127, 136, 134, 36, 39, 119, 219, 92, 107, 229, 57, 145, 24, 177, 148, 174, 94, 174, 199, 166, 157, 200, 162, 19, 38, 47, 126, 9])));
/// SA: boa1xpsa00p4drtuc7tx750arwvz35648wv2hnuwtw2j6tzt50m5pu2t6escf3y
static immutable SA = KeyPair(PublicKey(Point([97, 215, 188, 53, 104, 215, 204, 121, 102, 245, 31, 209, 185, 130, 141, 53, 83, 185, 138, 188, 248, 229, 185, 82, 210, 196, 186, 63, 116, 15, 20, 189])), SecretKey(Scalar([101, 123, 53, 104, 27, 128, 227, 108, 112, 163, 102, 169, 118, 231, 143, 63, 111, 83, 135, 201, 213, 49, 50, 158, 74, 86, 55, 234, 64, 21, 3, 2])));
/// SC: boa1xpsc00led7zy66dd8whrwlj0p20gdl0u7jqq0zw6wj54cwfja5v9zmwe7f0
static immutable SC = KeyPair(PublicKey(Point([97, 135, 191, 249, 111, 132, 77, 105, 173, 59, 174, 55, 126, 79, 10, 158, 134, 253, 252, 244, 128, 7, 137, 218, 116, 169, 92, 57, 50, 237, 24, 81])), SecretKey(Scalar([15, 156, 38, 97, 177, 226, 65, 107, 133, 250, 93, 68, 76, 229, 25, 64, 246, 216, 166, 153, 97, 222, 67, 250, 80, 14, 108, 98, 236, 160, 100, 1])));
/// SD: boa1xqsd003wstc9wn8p9cgkzv6ysc0glet2y24m0ythdclplc365rk72v3r6nu
static immutable SD = KeyPair(PublicKey(Point([32, 215, 190, 46, 130, 240, 87, 76, 225, 46, 17, 97, 51, 68, 134, 30, 143, 229, 106, 34, 171, 183, 145, 119, 110, 62, 31, 226, 58, 160, 237, 229])), SecretKey(Scalar([141, 35, 254, 128, 86, 153, 118, 32, 173, 124, 105, 99, 238, 104, 11, 84, 194, 123, 114, 130, 110, 124, 3, 217, 14, 84, 140, 31, 245, 94, 129, 9])));
/// SE: boa1xrse00prze8azwuprkxqaq8flahkjgru8kcxa8kjcl2kqfyhqh4js9xxntu
static immutable SE = KeyPair(PublicKey(Point([225, 151, 188, 35, 22, 79, 209, 59, 129, 29, 140, 14, 128, 233, 255, 111, 105, 32, 124, 61, 176, 110, 158, 210, 199, 213, 96, 36, 151, 5, 235, 40])), SecretKey(Scalar([199, 159, 218, 248, 41, 211, 22, 17, 131, 102, 182, 239, 11, 44, 105, 6, 189, 19, 12, 126, 192, 239, 10, 4, 2, 59, 82, 176, 73, 237, 158, 9])));
/// SF: boa1xzsf00nnd2tzpphlndsah93q6dy98esy8svxdzx4ynrw9zk34gavvjfqwjh
static immutable SF = KeyPair(PublicKey(Point([160, 151, 190, 115, 106, 150, 32, 134, 255, 155, 97, 219, 150, 32, 211, 72, 83, 230, 4, 60, 24, 102, 136, 213, 36, 198, 226, 138, 209, 170, 58, 198])), SecretKey(Scalar([95, 18, 174, 140, 171, 227, 197, 48, 155, 3, 245, 109, 120, 3, 190, 41, 40, 124, 153, 186, 16, 238, 5, 40, 232, 189, 4, 57, 137, 178, 88, 9])));
/// SG: boa1xpsg006ps7a4gwjndpczgfrr963407ashwmpg9n99ek76r6y7048u0mgek6
static immutable SG = KeyPair(PublicKey(Point([96, 135, 191, 65, 135, 187, 84, 58, 83, 104, 112, 36, 36, 99, 46, 163, 87, 251, 176, 187, 182, 20, 22, 101, 46, 109, 237, 15, 68, 243, 234, 126])), SecretKey(Scalar([228, 25, 83, 114, 1, 184, 186, 143, 109, 25, 221, 201, 17, 166, 193, 87, 107, 180, 185, 192, 93, 236, 123, 56, 10, 198, 133, 157, 85, 88, 171, 9])));
/// SH: boa1xqsh00m8c69kzx2twpparmzuvavjaarck4el4p2a3uysgazx6lh6se9hzvy
static immutable SH = KeyPair(PublicKey(Point([33, 119, 191, 103, 198, 139, 97, 25, 75, 112, 67, 209, 236, 92, 103, 89, 46, 244, 120, 181, 115, 250, 133, 93, 143, 9, 4, 116, 70, 215, 239, 168])), SecretKey(Scalar([103, 234, 193, 185, 160, 79, 102, 7, 43, 21, 91, 8, 218, 255, 19, 115, 238, 147, 252, 2, 150, 249, 185, 242, 166, 254, 83, 71, 77, 236, 250, 0])));
/// SJ: boa1xpsj00y72ayvc3jjaex788wr02p777yhcrwyjzxnx89tckzsqdpuyxgcyl8
static immutable SJ = KeyPair(PublicKey(Point([97, 39, 188, 158, 87, 72, 204, 70, 82, 238, 77, 227, 157, 195, 122, 131, 239, 120, 151, 192, 220, 73, 8, 211, 49, 202, 188, 88, 80, 3, 67, 194])), SecretKey(Scalar([98, 148, 242, 151, 71, 200, 120, 82, 140, 54, 26, 66, 251, 131, 23, 210, 223, 62, 18, 116, 86, 158, 252, 125, 99, 238, 186, 99, 36, 213, 56, 3])));
/// SK: boa1xrsk00g4kx8hlm2n6rmzr3k0h3enprycgj4p4m87xwtkrq2ytsw2xxz9jyx
static immutable SK = KeyPair(PublicKey(Point([225, 103, 189, 21, 177, 143, 127, 237, 83, 208, 246, 33, 198, 207, 188, 115, 48, 140, 152, 68, 170, 26, 236, 254, 51, 151, 97, 129, 68, 92, 28, 163])), SecretKey(Scalar([204, 233, 125, 26, 185, 40, 15, 222, 96, 35, 28, 121, 50, 24, 96, 154, 218, 94, 13, 81, 54, 67, 131, 50, 53, 134, 114, 54, 67, 233, 144, 14])));
/// SL: boa1xzsl000xxc8vg7wsst7py7l70zh00madjdmksl58kn0tme9upy6ycqrj65y
static immutable SL = KeyPair(PublicKey(Point([161, 247, 189, 230, 54, 14, 196, 121, 208, 130, 252, 18, 123, 254, 120, 174, 247, 239, 173, 147, 119, 104, 126, 135, 180, 222, 189, 228, 188, 9, 52, 76])), SecretKey(Scalar([78, 151, 126, 157, 62, 47, 66, 228, 163, 193, 163, 86, 182, 18, 62, 185, 251, 115, 142, 253, 224, 198, 86, 76, 32, 40, 166, 74, 206, 194, 171, 9])));
/// SM: boa1xpsm00jafudn9mvc3p2tnl0de4073r2jskhmx3nwd20derahn8uk64kvkat
static immutable SM = KeyPair(PublicKey(Point([97, 183, 190, 93, 79, 27, 50, 237, 152, 136, 84, 185, 253, 237, 205, 95, 232, 141, 82, 133, 175, 179, 70, 110, 106, 158, 220, 143, 183, 153, 249, 109])), SecretKey(Scalar([228, 167, 94, 212, 229, 106, 84, 45, 254, 245, 51, 230, 36, 236, 188, 182, 64, 136, 11, 234, 208, 248, 237, 20, 154, 72, 248, 59, 172, 199, 97, 14])));
/// SN: boa1xrsn00ksx8q49evlsdk6setafegwtxykk6px93kh75n4mp2vy0du7wwlm7v
static immutable SN = KeyPair(PublicKey(Point([225, 55, 190, 208, 49, 193, 82, 229, 159, 131, 109, 168, 101, 125, 78, 80, 229, 152, 150, 182, 130, 98, 198, 215, 245, 39, 93, 133, 76, 35, 219, 207])), SecretKey(Scalar([89, 229, 2, 227, 149, 181, 235, 110, 120, 150, 235, 166, 148, 171, 56, 24, 218, 71, 219, 209, 251, 10, 116, 114, 41, 97, 26, 42, 47, 197, 73, 6])));
/// SP: boa1xqsp00866sk3nlcpp2s0ta7ks7lg2jlnmgmqdn0c6q6agh8rweflvxtlj59
static immutable SP = KeyPair(PublicKey(Point([32, 23, 188, 250, 212, 45, 25, 255, 1, 10, 160, 245, 247, 214, 135, 190, 133, 75, 243, 218, 54, 6, 205, 248, 208, 53, 212, 92, 227, 118, 83, 246])), SecretKey(Scalar([188, 41, 78, 77, 142, 219, 72, 78, 161, 79, 187, 87, 131, 162, 142, 20, 168, 43, 162, 20, 214, 248, 147, 33, 1, 36, 53, 53, 1, 73, 65, 7])));
/// SQ: boa1xqsq00c8hq9ftetvhcm4wmd9yl0pdz9f8n0dajehdryjct2zpstf29n2hqf
static immutable SQ = KeyPair(PublicKey(Point([32, 7, 191, 7, 184, 10, 149, 229, 108, 190, 55, 87, 109, 165, 39, 222, 22, 136, 169, 60, 222, 222, 203, 55, 104, 201, 44, 45, 66, 12, 22, 149])), SecretKey(Scalar([164, 207, 221, 8, 187, 172, 62, 53, 155, 34, 214, 113, 129, 164, 146, 23, 148, 43, 127, 35, 100, 189, 219, 217, 242, 216, 181, 17, 255, 94, 62, 11])));
/// SR: boa1xrsr0043k2648svf5x7f6u5rmhwtaxn8ukmps4q07tnudz7g60qtq0gxpw6
static immutable SR = KeyPair(PublicKey(Point([224, 55, 190, 177, 178, 181, 83, 193, 137, 161, 188, 157, 114, 131, 221, 220, 190, 154, 103, 229, 182, 24, 84, 15, 242, 231, 198, 139, 200, 211, 192, 176])), SecretKey(Scalar([194, 168, 71, 18, 65, 5, 234, 158, 143, 198, 83, 154, 148, 171, 137, 46, 13, 74, 172, 136, 40, 218, 121, 167, 52, 152, 57, 176, 197, 207, 128, 11])));
/// SS: boa1xrss00wdcwuv8lw5ceess64uvp9stmx8m2jm9ts4rdzyqc6yu22x2clm2x2
static immutable SS = KeyPair(PublicKey(Point([225, 7, 189, 205, 195, 184, 195, 253, 212, 198, 115, 8, 106, 188, 96, 75, 5, 236, 199, 218, 165, 178, 174, 21, 27, 68, 64, 99, 68, 226, 148, 101])), SecretKey(Scalar([1, 184, 49, 14, 150, 225, 219, 115, 251, 171, 84, 146, 16, 33, 63, 234, 64, 162, 199, 201, 153, 28, 25, 39, 57, 173, 72, 223, 75, 191, 81, 14])));
/// ST: boa1xpst00pxgwe33fe0hh4xp2xlm56sg845rwy4szusw9p2fc5mzuknzqel3qd
static immutable ST = KeyPair(PublicKey(Point([96, 183, 188, 38, 67, 179, 24, 167, 47, 189, 234, 96, 168, 223, 221, 53, 4, 30, 180, 27, 137, 88, 11, 144, 113, 66, 164, 226, 155, 23, 45, 49])), SecretKey(Scalar([0, 224, 62, 190, 115, 52, 141, 177, 119, 114, 217, 191, 27, 21, 159, 233, 32, 23, 156, 108, 117, 53, 8, 124, 168, 214, 112, 134, 49, 136, 94, 14])));
/// SU: boa1xrsu008fu7erzymj2hsdahdzdwyq8q74wlgel63yupkkhf99y05hykls7ca
static immutable SU = KeyPair(PublicKey(Point([225, 199, 188, 233, 231, 178, 49, 19, 114, 85, 224, 222, 221, 162, 107, 136, 3, 131, 213, 119, 209, 159, 234, 36, 224, 109, 107, 164, 165, 35, 233, 114])), SecretKey(Scalar([206, 195, 149, 164, 226, 190, 101, 108, 96, 115, 200, 63, 89, 243, 226, 224, 123, 170, 4, 242, 49, 98, 108, 118, 109, 64, 31, 237, 90, 4, 215, 12])));
/// SV: boa1xzsv00n30paa39krylq76klyaqg342xvkyl2r4r3tu5tls3pt6x9usymx8m
static immutable SV = KeyPair(PublicKey(Point([160, 199, 190, 113, 120, 123, 216, 150, 195, 39, 193, 237, 91, 228, 232, 17, 26, 168, 204, 177, 62, 161, 212, 113, 95, 40, 191, 194, 33, 94, 140, 94])), SecretKey(Scalar([3, 76, 108, 31, 153, 31, 209, 34, 22, 175, 158, 161, 185, 210, 82, 203, 87, 46, 200, 200, 44, 54, 17, 12, 127, 6, 207, 148, 62, 126, 187, 2])));
/// SW: boa1xrsw00xmf6sayugyde8z6ztnllzkrn8ym4aurs6uegp5j65vfvs2g3u38rw
static immutable SW = KeyPair(PublicKey(Point([224, 231, 188, 219, 78, 161, 210, 113, 4, 110, 78, 45, 9, 115, 255, 197, 97, 204, 228, 221, 123, 193, 195, 92, 202, 3, 73, 106, 140, 75, 32, 164])), SecretKey(Scalar([40, 7, 34, 181, 82, 53, 93, 150, 116, 118, 170, 230, 134, 15, 1, 151, 253, 162, 145, 31, 100, 17, 13, 219, 132, 147, 233, 196, 90, 92, 212, 1])));
/// SX: boa1xqsx00qpmcdhvwzf4nrfzxs6yfe5h3q8dp7hn6k5tmudea0x3gyqksghlnn
static immutable SX = KeyPair(PublicKey(Point([32, 103, 188, 1, 222, 27, 118, 56, 73, 172, 198, 145, 26, 26, 34, 115, 75, 196, 7, 104, 125, 121, 234, 212, 94, 248, 220, 245, 230, 138, 8, 11])), SecretKey(Scalar([176, 100, 237, 145, 243, 11, 133, 79, 211, 107, 224, 24, 51, 174, 102, 254, 48, 106, 226, 202, 221, 244, 233, 97, 90, 50, 149, 33, 52, 153, 33, 0])));
/// SY: boa1xzsy00xnfcwr5c3gh9vekvgar0dvtyqe0d46n53479lhqzk7ghwezd6wfyx
static immutable SY = KeyPair(PublicKey(Point([160, 71, 188, 211, 78, 28, 58, 98, 40, 185, 89, 155, 49, 29, 27, 218, 197, 144, 25, 123, 107, 169, 210, 53, 241, 127, 112, 10, 222, 69, 221, 145])), SecretKey(Scalar([137, 4, 35, 165, 145, 9, 122, 222, 244, 148, 67, 98, 35, 167, 32, 29, 181, 22, 14, 144, 78, 34, 60, 1, 50, 20, 13, 43, 35, 235, 11, 0])));
/// SZ: boa1xqsz00ddxuptyk6wdx7dtrhwsetpzrt2ppsd28tdna87w82ylc7fkluccp3
static immutable SZ = KeyPair(PublicKey(Point([32, 39, 189, 173, 55, 2, 178, 91, 78, 105, 188, 213, 142, 238, 134, 86, 17, 13, 106, 8, 96, 213, 29, 109, 159, 79, 231, 29, 68, 254, 60, 155])), SecretKey(Scalar([43, 162, 34, 206, 1, 221, 175, 169, 139, 95, 243, 121, 86, 48, 49, 220, 223, 213, 121, 136, 182, 9, 21, 3, 163, 29, 242, 237, 215, 64, 197, 9])));
/// TA: boa1xrta0047sfpv0xy3ugjams7k4u3xmud6ad8k296njacds73chmv6zwdghut
static immutable TA = KeyPair(PublicKey(Point([215, 215, 190, 190, 130, 66, 199, 152, 145, 226, 37, 221, 195, 214, 175, 34, 109, 241, 186, 235, 79, 101, 23, 83, 151, 112, 216, 122, 56, 190, 217, 161])), SecretKey(Scalar([237, 145, 210, 96, 29, 172, 60, 225, 2, 200, 125, 147, 239, 36, 65, 174, 115, 172, 144, 2, 155, 46, 64, 160, 105, 244, 54, 21, 19, 99, 85, 3])));
/// TC: boa1xztc00q6tplrkzmglcw0vxvz3dpptfa3ht8ttkecef4d2weadqu42vj66pw
static immutable TC = KeyPair(PublicKey(Point([151, 135, 188, 26, 88, 126, 59, 11, 104, 254, 28, 246, 25, 130, 139, 66, 21, 167, 177, 186, 206, 181, 219, 56, 202, 106, 213, 59, 61, 104, 57, 85])), SecretKey(Scalar([112, 229, 176, 166, 1, 21, 18, 197, 77, 137, 156, 15, 191, 126, 51, 239, 60, 141, 232, 49, 126, 192, 0, 0, 111, 23, 166, 69, 139, 253, 42, 0])));
/// TD: boa1xztd006sn2aq7h5rjh9ngg760a9wqz4g8puj34pk3ppfm57eud6r76vk8lf
static immutable TD = KeyPair(PublicKey(Point([150, 215, 191, 80, 154, 186, 15, 94, 131, 149, 203, 52, 35, 218, 127, 74, 224, 10, 168, 56, 121, 40, 212, 54, 136, 66, 157, 211, 217, 227, 116, 63])), SecretKey(Scalar([103, 177, 48, 238, 133, 155, 103, 159, 156, 198, 5, 89, 155, 153, 155, 8, 14, 244, 61, 95, 186, 130, 229, 73, 57, 29, 240, 162, 245, 119, 54, 8])));
/// TE: boa1xrte00rjhhqautqgeeaa5gdckxwhsgw6cffufdrghl3ammmwrc4dvkyseun
static immutable TE = KeyPair(PublicKey(Point([215, 151, 188, 114, 189, 193, 222, 44, 8, 206, 123, 218, 33, 184, 177, 157, 120, 33, 218, 194, 83, 196, 180, 104, 191, 227, 221, 239, 110, 30, 42, 214])), SecretKey(Scalar([70, 224, 123, 157, 197, 250, 49, 166, 183, 109, 145, 230, 185, 15, 160, 96, 43, 4, 206, 11, 178, 150, 249, 76, 94, 24, 240, 14, 12, 100, 249, 13])));
/// TF: boa1xrtf00ryfm2mcj02ctl5rsrl9k5e245w8aampa5atc26tzakjls66rv4723
static immutable TF = KeyPair(PublicKey(Point([214, 151, 188, 100, 78, 213, 188, 73, 234, 194, 255, 65, 192, 127, 45, 169, 149, 86, 142, 63, 123, 176, 246, 157, 94, 21, 165, 139, 182, 151, 225, 173])), SecretKey(Scalar([27, 147, 198, 4, 250, 230, 153, 123, 238, 140, 68, 193, 103, 111, 224, 39, 155, 207, 20, 113, 69, 75, 18, 120, 157, 115, 105, 53, 15, 86, 80, 9])));
/// TG: boa1xqtg00l8pfptesx4eeenqalv2myru384qy4cns8amunzk0xes5ppknaxnwr
static immutable TG = KeyPair(PublicKey(Point([22, 135, 191, 231, 10, 66, 188, 192, 213, 206, 115, 48, 119, 236, 86, 200, 62, 68, 245, 1, 43, 137, 192, 253, 223, 38, 43, 60, 217, 133, 2, 27])), SecretKey(Scalar([183, 148, 80, 95, 46, 177, 193, 126, 175, 87, 27, 29, 201, 225, 193, 163, 235, 77, 250, 142, 13, 4, 184, 3, 146, 105, 125, 201, 147, 220, 7, 5])));
/// TH: boa1xzth00s5cnrrk0xn5kc383yjdmrmn2kpa4l872dpgrq24tcxq28zc3sxzew
static immutable TH = KeyPair(PublicKey(Point([151, 119, 190, 20, 196, 198, 59, 60, 211, 165, 177, 19, 196, 146, 110, 199, 185, 170, 193, 237, 126, 127, 41, 161, 64, 192, 170, 175, 6, 2, 142, 44])), SecretKey(Scalar([74, 119, 156, 16, 40, 62, 113, 32, 104, 249, 219, 92, 234, 160, 201, 239, 48, 79, 181, 112, 163, 35, 58, 62, 202, 62, 213, 249, 12, 138, 9, 9])));
/// TJ: boa1xptj00wpwpqtlsmgd99wtd4jmwq6wx0uzdptdnxkvd8dtvznpeajkacmsuv
static immutable TJ = KeyPair(PublicKey(Point([87, 39, 189, 193, 112, 64, 191, 195, 104, 105, 74, 229, 182, 178, 219, 129, 167, 25, 252, 19, 66, 182, 204, 214, 99, 78, 213, 176, 83, 14, 123, 43])), SecretKey(Scalar([158, 160, 0, 108, 43, 180, 104, 102, 163, 152, 120, 159, 236, 185, 135, 248, 202, 5, 214, 130, 95, 81, 251, 244, 154, 21, 23, 193, 121, 243, 206, 4])));
/// TK: boa1xqtk005fkr4n2hvchrql6x03rjc0mhgp9lw3h9n9m7wtrynjfcr5wc5nllf
static immutable TK = KeyPair(PublicKey(Point([23, 103, 190, 137, 176, 235, 53, 93, 152, 184, 193, 253, 25, 241, 28, 176, 253, 221, 1, 47, 221, 27, 150, 101, 223, 156, 177, 146, 114, 78, 7, 71])), SecretKey(Scalar([61, 51, 0, 81, 217, 190, 49, 197, 96, 66, 117, 167, 33, 234, 95, 220, 53, 83, 48, 209, 216, 170, 24, 57, 75, 192, 33, 224, 90, 22, 83, 5])));
/// TL: boa1xptl00u42h0uxqkx279yztf6fvqnjj6scrxmwkv207svyrdkuvlwgyvtlne
static immutable TL = KeyPair(PublicKey(Point([87, 247, 191, 149, 85, 223, 195, 2, 198, 87, 138, 65, 45, 58, 75, 1, 57, 75, 80, 192, 205, 183, 89, 138, 127, 160, 194, 13, 182, 227, 62, 228])), SecretKey(Scalar([144, 82, 161, 235, 40, 162, 19, 18, 223, 156, 87, 240, 43, 92, 217, 216, 34, 231, 218, 119, 120, 143, 17, 5, 158, 115, 141, 243, 181, 100, 27, 13])));
/// TM: boa1xrtm009fl8ls586pmzmamwmu6fzeg4ge4uye9wncp69wajsjyugzkv4g5z8
static immutable TM = KeyPair(PublicKey(Point([215, 183, 188, 169, 249, 255, 10, 31, 65, 216, 183, 221, 187, 124, 210, 69, 148, 85, 25, 175, 9, 146, 186, 120, 14, 138, 238, 202, 18, 39, 16, 43])), SecretKey(Scalar([91, 97, 69, 92, 213, 18, 175, 68, 125, 110, 16, 225, 254, 15, 227, 170, 157, 186, 208, 121, 202, 61, 87, 161, 166, 213, 152, 13, 94, 221, 166, 7])));
/// TN: boa1xptn00s633esntjxefrhkvkns86rxkegk73xu6h47eerkyjzue8pzjdvlql
static immutable TN = KeyPair(PublicKey(Point([87, 55, 190, 26, 140, 115, 9, 174, 70, 202, 71, 123, 50, 211, 129, 244, 51, 91, 40, 183, 162, 110, 106, 245, 246, 114, 59, 18, 66, 230, 78, 17])), SecretKey(Scalar([50, 100, 108, 161, 191, 78, 43, 197, 87, 37, 227, 62, 51, 121, 153, 234, 206, 6, 128, 47, 88, 227, 185, 74, 39, 240, 71, 137, 12, 247, 210, 1])));
/// TP: boa1xqtp00ye27056cxcy03fkps658ta5m2zffd4c5sf80dm8jkxp7wdccjvg40
static immutable TP = KeyPair(PublicKey(Point([22, 23, 188, 153, 87, 159, 77, 96, 216, 35, 226, 155, 6, 26, 161, 215, 218, 109, 66, 74, 91, 92, 82, 9, 59, 219, 179, 202, 198, 15, 156, 220])), SecretKey(Scalar([85, 64, 196, 166, 28, 88, 145, 18, 147, 169, 250, 52, 235, 4, 68, 62, 41, 25, 161, 11, 230, 69, 202, 13, 107, 244, 51, 84, 184, 151, 28, 10])));
/// TQ: boa1xztq00ex7vnmmwp2gqnt464xl7q7c7tf7qtg2qehu7qqlaulmn4m2mdlrna
static immutable TQ = KeyPair(PublicKey(Point([150, 7, 191, 38, 243, 39, 189, 184, 42, 64, 38, 186, 234, 166, 255, 129, 236, 121, 105, 240, 22, 133, 3, 55, 231, 128, 15, 247, 159, 220, 235, 181])), SecretKey(Scalar([208, 64, 25, 207, 106, 3, 156, 72, 65, 114, 248, 248, 126, 190, 60, 242, 252, 55, 50, 127, 76, 27, 2, 17, 150, 4, 141, 185, 186, 181, 116, 7])));
/// TR: boa1xptr00tr7u7cltr423hr6ghxarhcmdst0zveaj60uwq9v3w6ryc6wze3xjm
static immutable TR = KeyPair(PublicKey(Point([86, 55, 189, 99, 247, 61, 143, 172, 117, 84, 110, 61, 34, 230, 232, 239, 141, 182, 11, 120, 153, 158, 203, 79, 227, 128, 86, 69, 218, 25, 49, 167])), SecretKey(Scalar([55, 216, 227, 192, 207, 200, 111, 35, 48, 203, 224, 33, 202, 247, 124, 238, 129, 48, 249, 9, 234, 148, 108, 66, 136, 69, 217, 171, 36, 154, 43, 14])));
/// TS: boa1xzts00egf6mwp2k57tmm56x8cqhesk2yp4uw7fmx466nn4hh0dnrk7xkqv2
static immutable TS = KeyPair(PublicKey(Point([151, 7, 191, 40, 78, 182, 224, 170, 212, 242, 247, 186, 104, 199, 192, 47, 152, 89, 68, 13, 120, 239, 39, 102, 174, 181, 57, 214, 247, 123, 102, 59])), SecretKey(Scalar([92, 85, 203, 1, 200, 184, 125, 189, 255, 158, 159, 92, 152, 28, 11, 85, 136, 102, 106, 87, 246, 224, 106, 36, 2, 14, 122, 58, 31, 130, 152, 12])));
/// TT: boa1xqtt00ry2qskaep9gasgpr9z2450r7wha6qh32ttzfq4gwnzcqujszrq5cw
static immutable TT = KeyPair(PublicKey(Point([22, 183, 188, 100, 80, 33, 110, 228, 37, 71, 96, 128, 140, 162, 85, 104, 241, 249, 215, 238, 129, 120, 169, 107, 18, 65, 84, 58, 98, 192, 57, 40])), SecretKey(Scalar([25, 8, 28, 152, 223, 56, 200, 41, 204, 35, 1, 100, 120, 24, 132, 92, 155, 163, 112, 184, 201, 181, 215, 172, 73, 163, 103, 70, 197, 119, 32, 7])));
/// TU: boa1xptu00y7p3gjraxd3mdzhar7cjr5259gqypmhzcedea03fj6w6fmxyu87cw
static immutable TU = KeyPair(PublicKey(Point([87, 199, 188, 158, 12, 81, 33, 244, 205, 142, 218, 43, 244, 126, 196, 135, 69, 80, 168, 1, 3, 187, 139, 25, 110, 122, 248, 166, 90, 118, 147, 179])), SecretKey(Scalar([180, 180, 193, 223, 72, 168, 202, 26, 26, 82, 251, 107, 188, 135, 170, 109, 238, 228, 252, 38, 101, 20, 102, 27, 198, 123, 130, 254, 0, 247, 239, 3])));
/// TV: boa1xqtv00av94t2ewc9g7hkc2plwzr393ptwt6phccmylwpq6x8xeqj20s9tpz
static immutable TV = KeyPair(PublicKey(Point([22, 199, 191, 172, 45, 86, 172, 187, 5, 71, 175, 108, 40, 63, 112, 135, 18, 196, 43, 114, 244, 27, 227, 27, 39, 220, 16, 104, 199, 54, 65, 37])), SecretKey(Scalar([219, 77, 77, 115, 25, 99, 249, 201, 73, 111, 110, 228, 237, 199, 110, 122, 75, 63, 20, 81, 56, 93, 33, 157, 31, 93, 79, 68, 171, 235, 89, 14])));
/// TW: boa1xptw00har2nwyfgn4hdg65t4z7vy05jvfy9kdqu4rqplp0nz8kupyhyg5a4
static immutable TW = KeyPair(PublicKey(Point([86, 231, 190, 253, 26, 166, 226, 37, 19, 173, 218, 141, 81, 117, 23, 152, 71, 210, 76, 73, 11, 102, 131, 149, 24, 3, 240, 190, 98, 61, 184, 18])), SecretKey(Scalar([234, 208, 41, 217, 63, 109, 162, 41, 171, 230, 158, 66, 99, 171, 163, 87, 154, 202, 170, 135, 55, 38, 190, 167, 104, 196, 172, 58, 139, 181, 225, 9])));
/// TX: boa1xqtx00e3c9q5rpus92hycshtac9x3mzjz4drrf8tqa2e5zk26q2ywwyte8t
static immutable TX = KeyPair(PublicKey(Point([22, 103, 191, 49, 193, 65, 65, 135, 144, 42, 174, 76, 66, 235, 238, 10, 104, 236, 82, 21, 90, 49, 164, 235, 7, 85, 154, 10, 202, 208, 20, 71])), SecretKey(Scalar([19, 141, 175, 54, 246, 81, 3, 158, 110, 97, 27, 112, 249, 51, 88, 203, 150, 8, 70, 10, 98, 209, 86, 207, 170, 243, 176, 126, 177, 12, 225, 12])));
/// TY: boa1xzty00gt3j6s7g9x2zh947raclfvpqujfgytys0nud39qtu4fhgpsa93ap7
static immutable TY = KeyPair(PublicKey(Point([150, 71, 189, 11, 140, 181, 15, 32, 166, 80, 174, 90, 248, 125, 199, 210, 192, 131, 146, 74, 8, 178, 65, 243, 227, 98, 80, 47, 149, 77, 208, 24])), SecretKey(Scalar([124, 6, 25, 42, 231, 63, 101, 173, 161, 86, 11, 62, 242, 58, 223, 151, 230, 210, 4, 92, 232, 99, 128, 110, 163, 48, 103, 46, 229, 124, 174, 2])));
/// TZ: boa1xztz00u7753ap982msqygqnfjwlzmvnsy2a7j562vg4c0p2zxenuse5xzyk
static immutable TZ = KeyPair(PublicKey(Point([150, 39, 191, 158, 245, 35, 208, 148, 234, 220, 0, 68, 2, 105, 147, 190, 45, 178, 112, 34, 187, 233, 83, 74, 98, 43, 135, 133, 66, 54, 103, 200])), SecretKey(Scalar([46, 156, 13, 98, 128, 156, 154, 129, 66, 166, 57, 5, 91, 219, 154, 74, 77, 111, 182, 251, 189, 249, 99, 182, 3, 109, 19, 166, 127, 192, 128, 7])));
/// UA: boa1xqua0049tf8pyr0f0pypl9m3v9hg7ljcpefal0pksqc7yhtkf2aw5wsh5c5
static immutable UA = KeyPair(PublicKey(Point([57, 215, 190, 165, 90, 78, 18, 13, 233, 120, 72, 31, 151, 113, 97, 110, 143, 126, 88, 14, 83, 223, 188, 54, 128, 49, 226, 93, 118, 74, 186, 234])), SecretKey(Scalar([104, 9, 195, 51, 148, 234, 85, 243, 82, 161, 38, 169, 97, 44, 55, 56, 215, 186, 94, 129, 41, 34, 251, 141, 202, 31, 77, 147, 53, 115, 142, 4])));
/// UC: boa1xzuc00wfuwxt599nkvq7vw9nu7e66upl9e2fg7mmf9864c274jlts8m0lee
static immutable UC = KeyPair(PublicKey(Point([185, 135, 189, 201, 227, 140, 186, 20, 179, 179, 1, 230, 56, 179, 231, 179, 173, 112, 63, 46, 84, 148, 123, 123, 73, 79, 170, 225, 94, 172, 190, 184])), SecretKey(Scalar([241, 45, 178, 61, 249, 101, 123, 135, 19, 48, 152, 222, 234, 192, 241, 169, 47, 21, 23, 207, 137, 51, 249, 157, 226, 246, 131, 88, 74, 89, 186, 11])));
/// UD: boa1xqud00h7w8g6lhr2ydpk3auu2eqvl98rhxgktzjt2kzy9dzpqmwfqaqykzz
static immutable UD = KeyPair(PublicKey(Point([56, 215, 190, 254, 113, 209, 175, 220, 106, 35, 67, 104, 247, 156, 86, 64, 207, 148, 227, 185, 145, 101, 138, 75, 85, 132, 66, 180, 65, 6, 220, 144])), SecretKey(Scalar([234, 213, 129, 217, 14, 103, 28, 250, 129, 209, 165, 88, 66, 8, 203, 23, 124, 106, 129, 173, 132, 172, 237, 110, 128, 54, 1, 250, 137, 230, 58, 11])));
/// UE: boa1xrue00xp5zg8sr33wlg2qpxegnt7j9jrula7z70wdy2mttfmls522602s46
static immutable UE = KeyPair(PublicKey(Point([249, 151, 188, 193, 160, 144, 120, 14, 49, 119, 208, 160, 4, 217, 68, 215, 233, 22, 67, 231, 251, 225, 121, 238, 105, 21, 181, 173, 59, 252, 40, 165])), SecretKey(Scalar([100, 235, 121, 238, 242, 22, 54, 207, 182, 217, 39, 6, 179, 8, 37, 140, 5, 96, 182, 75, 128, 48, 125, 115, 154, 75, 22, 44, 170, 12, 82, 2])));
/// UF: boa1xzuf00z85w4qx0jp9vmdc39c5qpfqfgslg75szf45px8jcl3tvugk4a3cyx
static immutable UF = KeyPair(PublicKey(Point([184, 151, 188, 71, 163, 170, 3, 62, 65, 43, 54, 220, 68, 184, 160, 2, 144, 37, 16, 250, 61, 72, 9, 53, 160, 76, 121, 99, 241, 91, 56, 139])), SecretKey(Scalar([121, 75, 148, 50, 198, 65, 146, 89, 135, 126, 124, 234, 212, 133, 193, 46, 219, 51, 201, 195, 222, 19, 208, 148, 83, 174, 198, 70, 154, 191, 13, 15])));
/// UG: boa1xrug0046ez9w3guh2qsxmn9g4tv4tkfn7m8pl6g2v6ks9qek4ncysqmh9kk
static immutable UG = KeyPair(PublicKey(Point([248, 135, 190, 186, 200, 138, 232, 163, 151, 80, 32, 109, 204, 168, 170, 217, 85, 217, 51, 246, 206, 31, 233, 10, 102, 173, 2, 131, 54, 172, 240, 72])), SecretKey(Scalar([235, 97, 144, 72, 186, 95, 16, 94, 45, 215, 184, 37, 49, 155, 128, 21, 44, 207, 254, 44, 162, 168, 21, 196, 138, 247, 62, 124, 181, 161, 94, 6])));
/// UH: boa1xpuh00qg37n6zw802dalrxku2p7fv7tjwfvnfphh35p980x23d9g7mf3z6j
static immutable UH = KeyPair(PublicKey(Point([121, 119, 188, 8, 143, 167, 161, 56, 239, 83, 123, 241, 154, 220, 80, 124, 150, 121, 114, 114, 89, 52, 134, 247, 141, 2, 83, 188, 202, 139, 74, 143])), SecretKey(Scalar([31, 119, 154, 11, 215, 137, 54, 199, 242, 212, 65, 196, 157, 43, 161, 45, 31, 174, 82, 111, 113, 96, 6, 126, 71, 200, 236, 23, 165, 59, 33, 5])));
/// UJ: boa1xruj00aqdt34rw9n2t70nymq46wekpwz7y0evuphy97ptwljgs04jm3cd94
static immutable UJ = KeyPair(PublicKey(Point([249, 39, 191, 160, 106, 227, 81, 184, 179, 82, 252, 249, 147, 96, 174, 157, 155, 5, 194, 241, 31, 150, 112, 55, 33, 124, 21, 187, 242, 68, 31, 89])), SecretKey(Scalar([143, 122, 177, 211, 57, 175, 18, 1, 161, 150, 187, 143, 22, 117, 7, 249, 74, 22, 161, 16, 64, 176, 51, 240, 75, 241, 39, 225, 36, 14, 119, 14])));
/// UK: boa1xpuk00922604hzhl247w6yx7qdqsxgmt6gnpzpwxkk4t4jx88ude7e2jmx8
static immutable UK = KeyPair(PublicKey(Point([121, 103, 188, 170, 86, 159, 91, 138, 255, 85, 124, 237, 16, 222, 3, 65, 3, 35, 107, 210, 38, 17, 5, 198, 181, 170, 186, 200, 199, 63, 27, 159])), SecretKey(Scalar([168, 205, 108, 209, 39, 53, 206, 175, 221, 91, 108, 178, 55, 126, 24, 130, 218, 57, 5, 1, 114, 198, 5, 151, 239, 110, 153, 113, 20, 92, 38, 0])));
/// UL: boa1xpul00ada6cts6rqtjva5v6fmfq6k264rc79whvnzqp0dr9gdmsuy4426tw
static immutable UL = KeyPair(PublicKey(Point([121, 247, 191, 173, 238, 176, 184, 104, 96, 92, 153, 218, 51, 73, 218, 65, 171, 43, 85, 30, 60, 87, 93, 147, 16, 2, 246, 140, 168, 110, 225, 194])), SecretKey(Scalar([147, 115, 141, 17, 144, 50, 15, 233, 86, 240, 119, 166, 48, 9, 53, 140, 154, 31, 45, 120, 88, 52, 189, 76, 228, 205, 251, 135, 112, 234, 108, 9])));
/// UM: boa1xpum002500rnqsv3rsu3d7tg2tjqh2wsadetmlnf5vfw7lyw35c2jtkm7th
static immutable UM = KeyPair(PublicKey(Point([121, 183, 189, 84, 123, 199, 48, 65, 145, 28, 57, 22, 249, 104, 82, 228, 11, 169, 208, 235, 114, 189, 254, 105, 163, 18, 239, 124, 142, 141, 48, 169])), SecretKey(Scalar([164, 137, 102, 184, 45, 7, 223, 131, 126, 29, 35, 243, 33, 169, 159, 158, 205, 243, 215, 87, 159, 252, 178, 239, 70, 230, 99, 159, 28, 211, 22, 8])));
/// UN: boa1xrun00rlny95ktl55cp7mawmndxessx23xvcl45thwwqeczwqr39yz2e3jd
static immutable UN = KeyPair(PublicKey(Point([249, 55, 188, 127, 153, 11, 75, 47, 244, 166, 3, 237, 245, 219, 155, 77, 152, 64, 202, 137, 153, 143, 214, 139, 187, 156, 12, 224, 78, 0, 226, 82])), SecretKey(Scalar([58, 67, 30, 182, 165, 251, 117, 54, 253, 101, 170, 101, 4, 250, 46, 159, 53, 73, 70, 17, 79, 244, 32, 41, 107, 225, 138, 225, 250, 202, 166, 5])));
/// UP: boa1xrup00z3a7hskv42d7wtslerqp2sus9pzst0r5sjv7er47nqekcyjs5k6h7
static immutable UP = KeyPair(PublicKey(Point([248, 23, 188, 81, 239, 175, 11, 50, 170, 111, 156, 184, 127, 35, 0, 85, 14, 64, 161, 20, 22, 241, 210, 18, 103, 178, 58, 250, 96, 205, 176, 73])), SecretKey(Scalar([105, 49, 231, 192, 124, 249, 171, 129, 135, 95, 76, 97, 159, 127, 243, 244, 8, 211, 205, 127, 96, 16, 209, 244, 119, 166, 1, 182, 53, 55, 207, 9])));
/// UQ: boa1xruq00nmflcwj02qwj77e65rljzfkwu3znclweqlhwz5hfxk76etjhmwvg6
static immutable UQ = KeyPair(PublicKey(Point([248, 7, 190, 123, 79, 240, 233, 61, 64, 116, 189, 236, 234, 131, 252, 132, 155, 59, 145, 20, 241, 247, 100, 31, 187, 133, 75, 164, 214, 246, 178, 185])), SecretKey(Scalar([134, 169, 52, 5, 222, 144, 5, 214, 185, 136, 203, 214, 141, 129, 48, 46, 164, 164, 68, 22, 232, 48, 164, 229, 94, 233, 22, 137, 228, 149, 240, 13])));
/// UR: boa1xzur00denz99pta099vlmzg37qymnpfx7wpyufjv62xv94jztqmhj0l7cnq
static immutable UR = KeyPair(PublicKey(Point([184, 55, 189, 185, 152, 138, 80, 175, 175, 41, 89, 253, 137, 17, 240, 9, 185, 133, 38, 243, 130, 78, 38, 76, 210, 140, 194, 214, 66, 88, 55, 121])), SecretKey(Scalar([235, 119, 78, 245, 49, 182, 199, 23, 113, 215, 11, 140, 250, 249, 45, 137, 146, 186, 110, 111, 62, 229, 2, 27, 84, 80, 158, 228, 91, 244, 247, 4])));
/// US: boa1xrus00vt68czzfusj473yxumfy79p2r00d4677kf65ces248k5h22q088dt
static immutable US = KeyPair(PublicKey(Point([249, 7, 189, 139, 209, 240, 33, 39, 144, 149, 125, 18, 27, 155, 73, 60, 80, 168, 111, 123, 107, 175, 122, 201, 213, 49, 152, 42, 167, 181, 46, 165])), SecretKey(Scalar([78, 161, 110, 127, 250, 135, 195, 39, 79, 240, 124, 0, 33, 199, 6, 43, 27, 129, 77, 237, 214, 27, 117, 239, 247, 136, 175, 141, 250, 93, 204, 11])));
/// UT: boa1xrut008k23spf69w06ndgrcxdjnqh57rs8lmp8e98kcs9yr32xdfuqpgyy3
static immutable UT = KeyPair(PublicKey(Point([248, 183, 188, 246, 84, 96, 20, 232, 174, 126, 166, 212, 15, 6, 108, 166, 11, 211, 195, 129, 255, 176, 159, 37, 61, 177, 2, 144, 113, 81, 154, 158])), SecretKey(Scalar([18, 54, 118, 162, 43, 137, 131, 235, 98, 82, 144, 174, 143, 119, 67, 109, 164, 10, 208, 208, 23, 116, 192, 121, 201, 55, 84, 241, 170, 88, 207, 3])));
/// UU: boa1xzuu00qnhnpxq7jgxnqemjzuk5406068g6xzpt7glywudhs87dsgzcrj7m5
static immutable UU = KeyPair(PublicKey(Point([185, 199, 188, 19, 188, 194, 96, 122, 72, 52, 193, 157, 200, 92, 181, 42, 253, 63, 71, 70, 140, 32, 175, 200, 249, 29, 198, 222, 7, 243, 96, 129])), SecretKey(Scalar([187, 84, 203, 2, 225, 221, 4, 110, 151, 192, 253, 160, 248, 142, 65, 121, 190, 225, 5, 103, 146, 192, 88, 84, 71, 133, 212, 79, 16, 214, 36, 2])));
/// UV: boa1xruv00nmahwyn979dej3xyjd93sp44sc579mec4fp39dpahvd45pjd846k2
static immutable UV = KeyPair(PublicKey(Point([248, 199, 190, 123, 237, 220, 73, 151, 197, 110, 101, 19, 18, 77, 44, 96, 26, 214, 24, 167, 139, 188, 226, 169, 12, 74, 208, 246, 236, 109, 104, 25])), SecretKey(Scalar([176, 165, 156, 46, 89, 120, 16, 72, 213, 104, 235, 106, 97, 251, 76, 128, 43, 81, 123, 234, 54, 37, 81, 189, 164, 102, 43, 57, 114, 48, 127, 14])));
/// UW: boa1xzuw00a3k6n8th8arenx093h0dafwdfytpvyazmh8ldvhqgkfg9equulhc2
static immutable UW = KeyPair(PublicKey(Point([184, 231, 191, 177, 182, 166, 117, 220, 253, 30, 102, 103, 150, 55, 123, 122, 151, 53, 36, 88, 88, 78, 139, 119, 63, 218, 203, 129, 22, 74, 11, 144])), SecretKey(Scalar([8, 91, 238, 241, 10, 3, 132, 211, 116, 153, 118, 220, 145, 254, 170, 182, 67, 237, 207, 136, 90, 79, 98, 7, 75, 174, 245, 42, 119, 183, 184, 12])));
/// UX: boa1xqux00qedlwzrh4zmzhhq6tu9x8d4gye939lg8kpmk3pggaxnxzl5fxc2jm
static immutable UX = KeyPair(PublicKey(Point([56, 103, 188, 25, 111, 220, 33, 222, 162, 216, 175, 112, 105, 124, 41, 142, 218, 160, 153, 44, 75, 244, 30, 193, 221, 162, 20, 35, 166, 153, 133, 250])), SecretKey(Scalar([10, 56, 31, 173, 196, 209, 91, 245, 240, 213, 106, 45, 77, 249, 100, 183, 76, 193, 122, 233, 48, 55, 48, 164, 47, 224, 208, 29, 250, 220, 52, 5])));
/// UY: boa1xzuy00ucecatmz56wm2272nj7vx6wlzardrj8njdafcqru0usrrcgndwk7r
static immutable UY = KeyPair(PublicKey(Point([184, 71, 191, 152, 206, 58, 189, 138, 154, 118, 212, 175, 42, 114, 243, 13, 167, 124, 93, 27, 71, 35, 206, 77, 234, 112, 1, 241, 252, 128, 199, 132])), SecretKey(Scalar([35, 24, 187, 60, 166, 55, 77, 101, 49, 51, 29, 20, 15, 15, 60, 203, 80, 134, 59, 135, 60, 40, 18, 143, 235, 87, 118, 140, 243, 132, 134, 12])));
/// UZ: boa1xzuz00c95umn24058y0m722rsjuzqcznl6yhfnajtahu4qj5nw58c9rg4vn
static immutable UZ = KeyPair(PublicKey(Point([184, 39, 191, 5, 167, 55, 53, 85, 244, 57, 31, 191, 41, 67, 132, 184, 32, 96, 83, 254, 137, 116, 207, 178, 95, 111, 202, 130, 84, 155, 168, 124])), SecretKey(Scalar([165, 169, 126, 11, 228, 157, 16, 226, 90, 55, 110, 112, 29, 145, 246, 25, 234, 136, 30, 120, 123, 79, 227, 201, 176, 14, 43, 187, 159, 248, 100, 4])));
/// VA: boa1xzva00v5mjwltgcumzl3q57rpemsun7jyq2zepqy3mlu3y6h67qacdl6fau
static immutable VA = KeyPair(PublicKey(Point([153, 215, 189, 148, 220, 157, 245, 163, 28, 216, 191, 16, 83, 195, 14, 119, 14, 79, 210, 32, 20, 44, 132, 4, 142, 255, 200, 147, 87, 215, 129, 220])), SecretKey(Scalar([144, 101, 177, 8, 167, 41, 147, 226, 208, 7, 80, 90, 50, 187, 195, 80, 144, 71, 229, 0, 203, 107, 194, 142, 53, 239, 35, 218, 91, 87, 31, 1])));
/// VC: boa1xpvc00wlxntd0r0xlqyr6ngvncgj3hux9kms6esuk5f8k9fhlr6hwgff2z2
static immutable VC = KeyPair(PublicKey(Point([89, 135, 189, 223, 52, 214, 215, 141, 230, 248, 8, 61, 77, 12, 158, 17, 40, 223, 134, 45, 183, 13, 102, 28, 181, 18, 123, 21, 55, 248, 245, 119])), SecretKey(Scalar([192, 222, 56, 57, 110, 54, 217, 161, 166, 85, 162, 40, 82, 46, 101, 239, 88, 239, 82, 67, 94, 184, 225, 48, 6, 238, 69, 171, 13, 104, 160, 12])));
/// VD: boa1xpvd00q2dfnchm4c07yk8efkh7j2ljqqj8ejkat3hsea9mayeswykwp9dhl
static immutable VD = KeyPair(PublicKey(Point([88, 215, 188, 10, 106, 103, 139, 238, 184, 127, 137, 99, 229, 54, 191, 164, 175, 200, 0, 145, 243, 43, 117, 113, 188, 51, 210, 239, 164, 204, 28, 75])), SecretKey(Scalar([163, 20, 15, 30, 41, 89, 253, 43, 123, 29, 181, 229, 31, 114, 110, 42, 16, 89, 12, 117, 52, 203, 73, 16, 19, 154, 102, 175, 138, 144, 157, 11])));
/// VE: boa1xzve006qmtx2turepwt5pz00s3uqk6yvpm83grq52rh50mvnx9pxxqd2kfj
static immutable VE = KeyPair(PublicKey(Point([153, 151, 191, 64, 218, 204, 165, 240, 121, 11, 151, 64, 137, 239, 132, 120, 11, 104, 140, 14, 207, 20, 12, 20, 80, 239, 71, 237, 147, 49, 66, 99])), SecretKey(Scalar([55, 161, 237, 53, 237, 10, 108, 4, 117, 225, 86, 118, 1, 240, 114, 226, 232, 197, 142, 103, 115, 33, 118, 151, 166, 184, 141, 148, 94, 103, 162, 7])));
/// VF: boa1xzvf00wj8p6mlgdh3hk73yh985ahfulz5rdyfdym3ltffvldp04qzcgflzl
static immutable VF = KeyPair(PublicKey(Point([152, 151, 189, 210, 56, 117, 191, 161, 183, 141, 237, 232, 146, 229, 61, 59, 116, 243, 226, 160, 218, 68, 180, 155, 143, 214, 148, 179, 237, 11, 234, 1])), SecretKey(Scalar([67, 215, 153, 254, 171, 255, 61, 6, 166, 119, 22, 69, 67, 140, 110, 193, 233, 228, 159, 127, 4, 239, 246, 235, 45, 5, 182, 104, 122, 196, 123, 4])));
/// VG: boa1xqvg00z5h4qttja3nz8la9evkzzz78eu5p8933khpl3jyx09up8f7nnyvdm
static immutable VG = KeyPair(PublicKey(Point([24, 135, 188, 84, 189, 64, 181, 203, 177, 152, 143, 254, 151, 44, 176, 132, 47, 31, 60, 160, 78, 88, 198, 215, 15, 227, 34, 25, 229, 224, 78, 159])), SecretKey(Scalar([18, 226, 23, 215, 141, 78, 51, 183, 116, 46, 153, 208, 236, 222, 4, 213, 76, 174, 143, 117, 235, 220, 25, 48, 34, 237, 44, 7, 242, 86, 170, 1])));
/// VH: boa1xzvh00yctughgwvdes94qxyfaqeqf3nwx70ckw5y94c3tev8peqsgta6k9j
static immutable VH = KeyPair(PublicKey(Point([153, 119, 188, 152, 95, 17, 116, 57, 141, 204, 11, 80, 24, 137, 232, 50, 4, 198, 110, 55, 159, 139, 58, 132, 45, 113, 21, 229, 135, 14, 65, 4])), SecretKey(Scalar([1, 63, 181, 197, 234, 239, 52, 194, 135, 179, 246, 104, 143, 89, 151, 246, 95, 106, 60, 36, 134, 10, 174, 178, 108, 124, 27, 218, 129, 78, 130, 1])));
/// VJ: boa1xqvj00qkl4nvuu2cgtg2spk6vx34w6xh7cvzjazhy2tyhduyhuv9qt20fh7
static immutable VJ = KeyPair(PublicKey(Point([25, 39, 188, 22, 253, 102, 206, 113, 88, 66, 208, 168, 6, 218, 97, 163, 87, 104, 215, 246, 24, 41, 116, 87, 34, 150, 75, 183, 132, 191, 24, 80])), SecretKey(Scalar([203, 125, 223, 60, 64, 213, 124, 74, 62, 242, 214, 156, 118, 240, 214, 125, 185, 182, 207, 194, 224, 228, 100, 191, 196, 39, 88, 242, 213, 110, 107, 10])));
/// VK: boa1xqvk004x5760vht7mlkh4krwsqruz6eymes73xl60jj0w0upe6j2vmvvcn8
static immutable VK = KeyPair(PublicKey(Point([25, 103, 190, 166, 167, 180, 246, 93, 126, 223, 237, 122, 216, 110, 128, 7, 193, 107, 36, 222, 97, 232, 155, 250, 124, 164, 247, 63, 129, 206, 164, 166])), SecretKey(Scalar([106, 255, 105, 45, 10, 179, 50, 134, 130, 247, 209, 212, 255, 181, 75, 39, 109, 130, 71, 233, 114, 71, 159, 255, 57, 58, 171, 156, 82, 148, 92, 15])));
/// VL: boa1xpvl00lkevahdm26266kme7js3p5w9csyxrffnwjxnn6p69sws54x5avvm4
static immutable VL = KeyPair(PublicKey(Point([89, 247, 191, 246, 203, 59, 118, 237, 90, 86, 181, 109, 231, 210, 132, 67, 71, 23, 16, 33, 134, 148, 205, 210, 52, 231, 160, 232, 176, 116, 41, 83])), SecretKey(Scalar([125, 153, 92, 99, 215, 39, 186, 42, 47, 206, 18, 38, 125, 83, 69, 111, 71, 226, 119, 177, 137, 31, 202, 103, 120, 175, 196, 19, 48, 147, 50, 3])));
/// VM: boa1xqvm009fukweh5nkf8thx65vzqcgyktne2pe6ghpwev4rwem9kdnz0n4djq
static immutable VM = KeyPair(PublicKey(Point([25, 183, 188, 169, 229, 157, 155, 210, 118, 73, 215, 115, 106, 140, 16, 48, 130, 89, 115, 202, 131, 157, 34, 225, 118, 89, 81, 187, 59, 45, 155, 49])), SecretKey(Scalar([77, 184, 149, 21, 185, 7, 152, 224, 225, 81, 48, 113, 15, 232, 142, 97, 21, 152, 131, 14, 85, 102, 101, 251, 32, 31, 235, 96, 6, 225, 225, 9])));
/// VN: boa1xpvn008wwknthrafukr6jrveyahdzvtuzf93re8t2rpghdf5kxrfcgk30jf
static immutable VN = KeyPair(PublicKey(Point([89, 55, 188, 238, 117, 166, 187, 143, 169, 229, 135, 169, 13, 153, 39, 110, 209, 49, 124, 18, 75, 17, 228, 235, 80, 194, 139, 181, 52, 177, 134, 156])), SecretKey(Scalar([113, 195, 0, 239, 48, 62, 28, 142, 115, 70, 3, 25, 38, 215, 253, 194, 176, 157, 45, 235, 242, 125, 44, 103, 79, 225, 224, 254, 138, 190, 170, 15])));
/// VP: boa1xpvp00fm03anlmfp45gzmxrvqfu4979ulw7uhg70y0hzprm7y24esr5554l
static immutable VP = KeyPair(PublicKey(Point([88, 23, 189, 59, 124, 123, 63, 237, 33, 173, 16, 45, 152, 108, 2, 121, 82, 248, 188, 251, 189, 203, 163, 207, 35, 238, 32, 143, 126, 34, 171, 152])), SecretKey(Scalar([195, 199, 235, 117, 254, 7, 26, 27, 4, 185, 102, 26, 17, 119, 127, 181, 30, 21, 27, 99, 103, 174, 249, 65, 8, 95, 25, 159, 117, 35, 43, 8])));
/// VQ: boa1xqvq00wfdlla5dcnhac8mc72t5jhdjzggq50pa8qm34m5gnq5707gzmua3v
static immutable VQ = KeyPair(PublicKey(Point([24, 7, 189, 201, 111, 255, 218, 55, 19, 191, 112, 125, 227, 202, 93, 37, 118, 200, 72, 64, 40, 240, 244, 224, 220, 107, 186, 34, 96, 167, 159, 228])), SecretKey(Scalar([59, 165, 236, 210, 50, 248, 119, 197, 7, 147, 84, 5, 62, 237, 215, 187, 117, 181, 102, 68, 202, 80, 125, 172, 94, 171, 217, 10, 134, 38, 202, 13])));
/// VR: boa1xzvr00tkrefwf9k3eem3uu3k9f36l5xap4sjjpfcd64ragwq5f3eqqts3ft
static immutable VR = KeyPair(PublicKey(Point([152, 55, 189, 118, 30, 82, 228, 150, 209, 206, 119, 30, 114, 54, 42, 99, 175, 208, 221, 13, 97, 41, 5, 56, 110, 170, 62, 161, 192, 162, 99, 144])), SecretKey(Scalar([183, 139, 1, 241, 217, 52, 88, 41, 251, 75, 22, 59, 120, 42, 247, 18, 56, 220, 121, 119, 166, 75, 143, 26, 208, 240, 55, 74, 245, 162, 108, 2])));
/// VS: boa1xrvs005jpptaknhln095a253aml6pg2pcxpvsnu7std89dz6e29kguytlzv
static immutable VS = KeyPair(PublicKey(Point([217, 7, 190, 146, 8, 87, 219, 78, 255, 155, 203, 78, 170, 145, 238, 255, 160, 161, 65, 193, 130, 200, 79, 158, 130, 218, 114, 180, 90, 202, 139, 100])), SecretKey(Scalar([205, 173, 102, 71, 139, 74, 90, 178, 2, 60, 181, 128, 2, 0, 206, 60, 170, 108, 27, 27, 121, 205, 94, 134, 68, 170, 130, 19, 118, 45, 113, 14])));
/// VT: boa1xzvt002829dwnhsadqak7q646yt74r6s7gf057jzp75ehv8p79l4zcy7xsc
static immutable VT = KeyPair(PublicKey(Point([152, 183, 189, 71, 81, 90, 233, 222, 29, 104, 59, 111, 3, 85, 209, 23, 234, 143, 80, 242, 18, 250, 122, 66, 15, 169, 155, 176, 225, 241, 127, 81])), SecretKey(Scalar([41, 37, 78, 10, 152, 248, 81, 215, 179, 138, 69, 103, 101, 208, 236, 34, 101, 209, 80, 137, 228, 33, 30, 62, 56, 137, 128, 239, 199, 147, 74, 10])));
/// VU: boa1xzvu00egeweefhe5zre3j3ze0neey9lgg6drt9j08urx223sggmqjd8xw9k
static immutable VU = KeyPair(PublicKey(Point([153, 199, 191, 40, 203, 179, 148, 223, 52, 16, 243, 25, 68, 89, 124, 243, 146, 23, 232, 70, 154, 53, 150, 79, 63, 6, 101, 42, 48, 66, 54, 9])), SecretKey(Scalar([236, 199, 83, 23, 204, 245, 41, 252, 112, 164, 220, 234, 199, 239, 240, 11, 6, 234, 181, 131, 18, 251, 163, 253, 136, 188, 59, 136, 67, 187, 232, 9])));
/// VV: boa1xpvv00r9ly054vk926rmxah0pupnk6zpeehsr39x29adyuly76ruwj3nhgx
static immutable VV = KeyPair(PublicKey(Point([88, 199, 188, 101, 249, 31, 74, 178, 197, 86, 135, 179, 118, 239, 15, 3, 59, 104, 65, 206, 111, 1, 196, 166, 81, 122, 210, 115, 228, 246, 135, 199])), SecretKey(Scalar([23, 73, 240, 91, 202, 255, 162, 105, 174, 162, 63, 17, 95, 5, 105, 214, 130, 64, 240, 196, 220, 119, 38, 141, 22, 73, 10, 82, 133, 63, 175, 0])));
/// VW: boa1xrvw00gd7mps25k333jhvzw6y74694rhjvupphna3q3tnkhe2magq7cedn6
static immutable VW = KeyPair(PublicKey(Point([216, 231, 189, 13, 246, 195, 5, 82, 209, 140, 101, 118, 9, 218, 39, 171, 162, 212, 119, 147, 56, 16, 222, 125, 136, 34, 185, 218, 249, 86, 250, 128])), SecretKey(Scalar([110, 228, 121, 141, 59, 55, 235, 208, 51, 4, 35, 153, 29, 123, 180, 110, 201, 188, 130, 11, 51, 173, 161, 52, 117, 17, 218, 175, 153, 164, 221, 10])));
/// VX: boa1xqvx00j9wthmxd3hmjesve4qal9h98eng05fcu6ptewesj2hkc5uj2ujyv2
static immutable VX = KeyPair(PublicKey(Point([24, 103, 190, 69, 114, 239, 179, 54, 55, 220, 179, 6, 102, 160, 239, 203, 114, 159, 51, 67, 232, 156, 115, 65, 94, 93, 152, 73, 87, 182, 41, 201])), SecretKey(Scalar([121, 101, 188, 95, 153, 94, 209, 211, 137, 167, 124, 23, 24, 86, 3, 205, 204, 73, 22, 212, 198, 12, 147, 177, 36, 247, 12, 92, 221, 129, 80, 1])));
/// VY: boa1xrvy00l7gew73gsa92y50lu2zzzzxfx0gc0t7tnn0fnxwc3fwnua6q8jdwl
static immutable VY = KeyPair(PublicKey(Point([216, 71, 191, 254, 70, 93, 232, 162, 29, 42, 137, 71, 255, 138, 16, 132, 35, 36, 207, 70, 30, 191, 46, 115, 122, 102, 103, 98, 41, 116, 249, 221])), SecretKey(Scalar([151, 242, 123, 36, 61, 49, 99, 161, 175, 239, 224, 111, 170, 29, 111, 183, 117, 231, 223, 152, 204, 173, 110, 212, 175, 205, 181, 41, 56, 236, 40, 15])));
/// VZ: boa1xrvz0049psxr2ay5dh48cp0ladu3cgtf65zn36fl8u060hjgpv0su5z9p76
static immutable VZ = KeyPair(PublicKey(Point([216, 39, 190, 165, 12, 12, 53, 116, 148, 109, 234, 124, 5, 255, 235, 121, 28, 33, 105, 213, 5, 56, 233, 63, 63, 31, 167, 222, 72, 11, 31, 14])), SecretKey(Scalar([82, 176, 135, 227, 32, 21, 216, 228, 78, 91, 42, 221, 82, 4, 10, 246, 130, 146, 109, 65, 201, 18, 78, 11, 162, 251, 235, 110, 79, 2, 189, 7])));
/// WA: boa1xrwa00ffukqswug7f4tdnzlj0zcfs9mq62j5s05td3x7rmtxpzghjyc5s8t
static immutable WA = KeyPair(PublicKey(Point([221, 215, 189, 41, 229, 129, 7, 113, 30, 77, 86, 217, 139, 242, 120, 176, 152, 23, 96, 210, 165, 72, 62, 139, 108, 77, 225, 237, 102, 8, 145, 121])), SecretKey(Scalar([140, 243, 182, 227, 209, 49, 167, 157, 200, 209, 172, 140, 203, 109, 249, 42, 178, 86, 71, 51, 102, 201, 148, 132, 192, 21, 127, 80, 98, 148, 5, 8])));
/// WC: boa1xqwc003r2twygmjwt0f20veacfdq5fvuajgpk9p5k95wwp347zffwwm0ptq
static immutable WC = KeyPair(PublicKey(Point([29, 135, 190, 35, 82, 220, 68, 110, 78, 91, 210, 167, 179, 61, 194, 90, 10, 37, 156, 236, 144, 27, 20, 52, 177, 104, 231, 6, 53, 240, 146, 151])), SecretKey(Scalar([107, 75, 6, 5, 110, 246, 73, 252, 125, 214, 99, 64, 145, 72, 37, 172, 238, 27, 201, 41, 130, 74, 86, 61, 250, 70, 143, 11, 134, 255, 64, 8])));
/// WD: boa1xpwd00vm35u06f75cgwfxh2hu2mh65er5h8nwfwhmtedhzatam5hzhlfxdz
static immutable WD = KeyPair(PublicKey(Point([92, 215, 189, 155, 141, 56, 253, 39, 212, 194, 28, 147, 93, 87, 226, 183, 125, 83, 35, 165, 207, 55, 37, 215, 218, 242, 219, 139, 171, 238, 233, 113])), SecretKey(Scalar([216, 139, 116, 68, 161, 37, 5, 121, 25, 40, 119, 227, 26, 182, 222, 233, 243, 189, 64, 66, 225, 20, 71, 235, 206, 40, 69, 14, 3, 151, 119, 6])));
/// WE: boa1xrwe00864rg93kvey0jtnxgpsmt5090q65jjcncu6j5xx2axlmswg4mjc9g
static immutable WE = KeyPair(PublicKey(Point([221, 151, 188, 250, 168, 208, 88, 217, 153, 35, 228, 185, 153, 1, 134, 215, 71, 149, 224, 213, 37, 44, 79, 28, 212, 168, 99, 43, 166, 254, 224, 228])), SecretKey(Scalar([108, 136, 236, 217, 17, 163, 30, 216, 222, 66, 242, 252, 9, 76, 206, 228, 197, 190, 196, 47, 22, 225, 162, 85, 136, 72, 158, 36, 212, 192, 127, 7])));
/// WF: boa1xrwf003dhtnjlnta0fzukdk8pcmfuu3n3n5vnehr3qsp27xaud6sgmdzwrk
static immutable WF = KeyPair(PublicKey(Point([220, 151, 190, 45, 186, 231, 47, 205, 125, 122, 69, 203, 54, 199, 14, 54, 158, 114, 51, 140, 232, 201, 230, 227, 136, 32, 21, 120, 221, 227, 117, 4])), SecretKey(Scalar([134, 89, 10, 226, 201, 117, 57, 67, 47, 180, 113, 107, 193, 199, 48, 189, 247, 92, 112, 24, 238, 136, 23, 9, 81, 188, 154, 43, 58, 238, 103, 3])));
/// WG: boa1xpwg00mew8y8s787rd8k53v3glq2xc5d8yypu6m8xkkmt8w2ey25y8740xu
static immutable WG = KeyPair(PublicKey(Point([92, 135, 191, 121, 113, 200, 120, 120, 254, 27, 79, 106, 69, 145, 71, 192, 163, 98, 141, 57, 8, 30, 107, 103, 53, 173, 181, 157, 202, 201, 21, 66])), SecretKey(Scalar([98, 127, 40, 17, 163, 245, 186, 37, 147, 88, 115, 69, 254, 40, 196, 115, 192, 42, 85, 1, 168, 38, 68, 251, 80, 91, 232, 27, 79, 71, 139, 3])));
/// WH: boa1xqwh00y72exjus9a7p9qpuxcgylrj82gsdcqmf835m2em56gdjn65chrasf
static immutable WH = KeyPair(PublicKey(Point([29, 119, 188, 158, 86, 77, 46, 64, 189, 240, 74, 0, 240, 216, 65, 62, 57, 29, 72, 131, 112, 13, 164, 241, 166, 213, 157, 211, 72, 108, 167, 170])), SecretKey(Scalar([80, 7, 139, 88, 162, 155, 69, 238, 188, 114, 31, 240, 37, 30, 203, 115, 34, 158, 148, 179, 3, 7, 212, 175, 219, 33, 91, 242, 19, 70, 175, 13])));
/// WJ: boa1xpwj00kdc55vd8rzhl82v55l5htgngx90azyfw6hj9tpt656fj0fur08s2c
static immutable WJ = KeyPair(PublicKey(Point([93, 39, 190, 205, 197, 40, 198, 156, 98, 191, 206, 166, 82, 159, 165, 214, 137, 160, 197, 127, 68, 68, 187, 87, 145, 86, 21, 234, 154, 76, 158, 158])), SecretKey(Scalar([206, 144, 88, 177, 136, 132, 195, 155, 240, 71, 81, 194, 229, 230, 36, 64, 160, 137, 75, 121, 108, 140, 51, 164, 207, 129, 141, 55, 99, 159, 251, 15])));
/// WK: boa1xpwk007kh4kqf6z7v6zauhll885t4aup4ufy3w49cycsvw003nxcy0eu2xy
static immutable WK = KeyPair(PublicKey(Point([93, 103, 191, 214, 189, 108, 4, 232, 94, 102, 133, 222, 95, 255, 57, 232, 186, 247, 129, 175, 18, 72, 186, 165, 193, 49, 6, 57, 239, 140, 205, 130])), SecretKey(Scalar([5, 123, 137, 193, 113, 75, 206, 195, 163, 138, 218, 153, 115, 31, 196, 159, 211, 90, 144, 105, 97, 197, 128, 89, 250, 120, 153, 229, 27, 111, 136, 0])));
/// WL: boa1xpwl00cslzqk93r70ns4ht4v5jzpqlnf9fd0zqhjcwssuve3xtdp7fa7gaz
static immutable WL = KeyPair(PublicKey(Point([93, 247, 191, 16, 248, 129, 98, 196, 126, 124, 225, 91, 174, 172, 164, 132, 16, 126, 105, 42, 90, 241, 2, 242, 195, 161, 14, 51, 49, 50, 218, 31])), SecretKey(Scalar([150, 243, 174, 140, 86, 136, 139, 25, 34, 238, 128, 179, 101, 176, 250, 103, 218, 188, 140, 153, 147, 236, 108, 168, 12, 179, 130, 220, 200, 109, 22, 15])));
/// WM: boa1xrwm00mcw2hsyp65tnut79kdl70fgsqfea3682x7ar9k55c796h22de07f2
static immutable WM = KeyPair(PublicKey(Point([221, 183, 191, 120, 114, 175, 2, 7, 84, 92, 248, 191, 22, 205, 255, 158, 148, 64, 9, 207, 99, 163, 168, 222, 232, 203, 106, 83, 30, 46, 174, 165])), SecretKey(Scalar([122, 217, 20, 30, 148, 155, 27, 212, 248, 49, 74, 42, 92, 29, 39, 255, 239, 64, 30, 232, 117, 49, 144, 16, 241, 11, 72, 59, 61, 37, 152, 5])));
/// WN: boa1xrwn00nrukl2furd4e3czfvf2hncxennmwg4d9lmtpwg5am0aa7pvqvnjc0
static immutable WN = KeyPair(PublicKey(Point([221, 55, 190, 99, 229, 190, 164, 240, 109, 174, 99, 129, 37, 137, 85, 231, 131, 102, 115, 219, 145, 86, 151, 251, 88, 92, 138, 119, 111, 239, 124, 22])), SecretKey(Scalar([64, 40, 121, 126, 196, 175, 16, 109, 147, 111, 91, 150, 187, 60, 65, 214, 42, 233, 11, 110, 157, 105, 13, 222, 109, 18, 251, 244, 243, 76, 104, 9])));
/// WP: boa1xzwp00erz89cysa8jaqcnr6lecsfprdrdk7czx9zr8y4wpqyan0pkt6hksl
static immutable WP = KeyPair(PublicKey(Point([156, 23, 191, 35, 17, 203, 130, 67, 167, 151, 65, 137, 143, 95, 206, 32, 144, 141, 163, 109, 189, 129, 24, 162, 25, 201, 87, 4, 4, 236, 222, 27])), SecretKey(Scalar([133, 175, 217, 33, 195, 84, 210, 113, 158, 28, 227, 210, 31, 141, 114, 228, 15, 101, 223, 211, 94, 104, 119, 75, 159, 40, 149, 57, 74, 128, 132, 1])));
/// WQ: boa1xzwq00g4kndn7l93h3llp8qjd6v9p52vsma4gy3qltrauzz5a02wqapzqcq
static immutable WQ = KeyPair(PublicKey(Point([156, 7, 189, 21, 180, 219, 63, 124, 177, 188, 127, 240, 156, 18, 110, 152, 80, 209, 76, 134, 251, 84, 18, 32, 250, 199, 222, 8, 84, 235, 212, 224])), SecretKey(Scalar([207, 26, 52, 14, 24, 192, 71, 149, 46, 154, 128, 166, 3, 244, 98, 249, 240, 241, 67, 155, 34, 34, 171, 31, 168, 74, 184, 77, 127, 48, 7, 14])));
/// WR: boa1xrwr00lx0cfwqryrpnweaak4x6dyadr2z2ak7n7m2q9jusvd2vpl2qry67p
static immutable WR = KeyPair(PublicKey(Point([220, 55, 191, 230, 126, 18, 224, 12, 131, 12, 221, 158, 246, 213, 54, 154, 78, 180, 106, 18, 187, 111, 79, 219, 80, 11, 46, 65, 141, 83, 3, 245])), SecretKey(Scalar([26, 233, 211, 152, 247, 104, 129, 51, 13, 195, 188, 95, 189, 58, 164, 108, 67, 146, 83, 176, 196, 52, 167, 110, 152, 60, 182, 64, 93, 132, 15, 10])));
/// WS: boa1xqws002zs6zp5yw5z0pd2jkjgk6uu37nuuaystmqgdk84a42atpkw6dl8j6
static immutable WS = KeyPair(PublicKey(Point([29, 7, 189, 66, 134, 132, 26, 17, 212, 19, 194, 213, 74, 210, 69, 181, 206, 71, 211, 231, 58, 72, 47, 96, 67, 108, 122, 246, 170, 234, 195, 103])), SecretKey(Scalar([186, 39, 118, 219, 253, 216, 111, 119, 109, 213, 142, 101, 128, 31, 224, 54, 161, 189, 76, 52, 104, 223, 73, 233, 42, 232, 54, 122, 246, 93, 8, 6])));
/// WT: boa1xzwt00lp3rtuwur5smrll8sky0urmkvl0qhkarftfny3869z3cf9xvz4kn7
static immutable WT = KeyPair(PublicKey(Point([156, 183, 191, 225, 136, 215, 199, 112, 116, 134, 199, 255, 158, 22, 35, 248, 61, 217, 159, 120, 47, 110, 141, 43, 76, 201, 19, 232, 162, 142, 18, 83])), SecretKey(Scalar([59, 160, 126, 34, 57, 238, 14, 108, 37, 220, 87, 247, 7, 208, 228, 235, 44, 11, 56, 246, 235, 96, 159, 196, 94, 252, 97, 81, 120, 54, 76, 12])));
/// WU: boa1xqwu004zqdm4893q23lvy6m440a3pcnur3y7pppyn4sghhww3xgnuvdpjww
static immutable WU = KeyPair(PublicKey(Point([29, 199, 190, 162, 3, 119, 83, 150, 32, 84, 126, 194, 107, 117, 171, 251, 16, 226, 124, 28, 73, 224, 132, 36, 157, 96, 139, 221, 206, 137, 145, 62])), SecretKey(Scalar([60, 6, 209, 23, 237, 210, 92, 31, 104, 215, 68, 192, 205, 159, 21, 119, 212, 129, 220, 218, 175, 227, 25, 201, 210, 55, 244, 24, 134, 155, 217, 4])));
/// WV: boa1xzwv00cns2krmlcety644a6z8u6y5hnl8jm5gnu772374nj0zng9ydqym22
static immutable WV = KeyPair(PublicKey(Point([156, 199, 191, 19, 130, 172, 61, 255, 25, 89, 53, 90, 247, 66, 63, 52, 74, 94, 127, 60, 183, 68, 79, 158, 242, 163, 234, 206, 79, 20, 208, 82])), SecretKey(Scalar([45, 11, 69, 216, 28, 242, 108, 118, 49, 17, 25, 94, 165, 214, 111, 199, 32, 43, 116, 53, 137, 5, 172, 26, 201, 1, 213, 242, 216, 13, 104, 2])));
/// WW: boa1xrww00ltzx03aq062z40rtsnsvgzz6vhhuyu47u5wsf3nppzqrsagvrs9w9
static immutable WW = KeyPair(PublicKey(Point([220, 231, 191, 235, 17, 159, 30, 129, 250, 80, 170, 241, 174, 19, 131, 16, 33, 105, 151, 191, 9, 202, 251, 148, 116, 19, 25, 132, 34, 0, 225, 212])), SecretKey(Scalar([142, 18, 113, 38, 49, 186, 251, 53, 195, 218, 252, 0, 215, 20, 156, 249, 6, 95, 222, 9, 1, 110, 136, 59, 24, 182, 156, 232, 119, 197, 88, 11])));
/// WX: boa1xpwx00tk3qq68mxsxdl7ywdxn26m79kezn7kevym43rxnsdaj77gyx2v9dv
static immutable WX = KeyPair(PublicKey(Point([92, 103, 189, 118, 136, 1, 163, 236, 208, 51, 127, 226, 57, 166, 154, 181, 191, 22, 217, 20, 253, 108, 176, 155, 172, 70, 105, 193, 189, 151, 188, 130])), SecretKey(Scalar([27, 135, 88, 156, 213, 61, 224, 138, 244, 51, 69, 195, 179, 72, 139, 203, 231, 139, 69, 168, 69, 57, 75, 159, 203, 202, 247, 58, 24, 1, 179, 0])));
/// WY: boa1xrwy00hgjnlx88pfaprf0ypnsqkglt0k39mwhher3626fg7ucvnmvsdt6jx
static immutable WY = KeyPair(PublicKey(Point([220, 71, 190, 232, 148, 254, 99, 156, 41, 232, 70, 151, 144, 51, 128, 44, 143, 173, 246, 137, 118, 235, 223, 35, 142, 149, 164, 163, 220, 195, 39, 182])), SecretKey(Scalar([80, 198, 124, 198, 60, 216, 191, 3, 143, 165, 49, 114, 181, 93, 113, 141, 163, 156, 23, 84, 150, 174, 230, 76, 34, 66, 138, 165, 240, 255, 172, 15])));
/// WZ: boa1xqwz007sxpcgj0d6dmrtm07x8c7kl5se3grwzymrpnl4x9tdm8n6ztjx3cz
static immutable WZ = KeyPair(PublicKey(Point([28, 39, 191, 208, 48, 112, 137, 61, 186, 110, 198, 189, 191, 198, 62, 61, 111, 210, 25, 138, 6, 225, 19, 99, 12, 255, 83, 21, 109, 217, 231, 161])), SecretKey(Scalar([255, 244, 54, 157, 8, 18, 59, 102, 20, 120, 57, 11, 89, 228, 214, 199, 54, 251, 136, 183, 91, 145, 65, 252, 245, 60, 34, 241, 207, 184, 142, 3])));
/// XA: boa1xqxa00zc0k603y3xvqwwrueh8em40msv6sqnl56t3jn7q5la0kxzxu368dt
static immutable XA = KeyPair(PublicKey(Point([13, 215, 188, 88, 125, 180, 248, 146, 38, 96, 28, 225, 243, 55, 62, 119, 87, 238, 12, 212, 1, 63, 211, 75, 140, 167, 224, 83, 253, 125, 140, 35])), SecretKey(Scalar([213, 143, 82, 187, 91, 227, 105, 146, 188, 98, 4, 66, 45, 158, 250, 169, 194, 181, 42, 229, 100, 249, 100, 162, 204, 110, 245, 244, 213, 254, 136, 8])));
/// XC: boa1xpxc00kvcsxzkgmsdwf9h8tyjy6j34yp4czm53tmcpzhmt0hl5pqzx3akp6
static immutable XC = KeyPair(PublicKey(Point([77, 135, 190, 204, 196, 12, 43, 35, 112, 107, 146, 91, 157, 100, 145, 53, 40, 212, 129, 174, 5, 186, 69, 123, 192, 69, 125, 173, 247, 253, 2, 1])), SecretKey(Scalar([185, 231, 72, 226, 102, 124, 29, 245, 179, 253, 209, 65, 155, 5, 220, 205, 187, 112, 249, 206, 6, 193, 71, 173, 109, 87, 145, 189, 117, 16, 232, 0])));
/// XD: boa1xzxd004kdvv0mhw2rat4k9ct040jnhwhh8r294hk9kj753qhummqyl5kpsa
static immutable XD = KeyPair(PublicKey(Point([140, 215, 190, 182, 107, 24, 253, 221, 202, 31, 87, 91, 23, 11, 125, 95, 41, 221, 215, 185, 198, 162, 214, 246, 45, 165, 234, 68, 23, 230, 246, 2])), SecretKey(Scalar([217, 229, 147, 48, 117, 215, 92, 124, 70, 146, 83, 125, 231, 155, 167, 60, 96, 144, 209, 209, 237, 12, 90, 9, 210, 139, 126, 55, 79, 197, 128, 0])));
/// XE: boa1xrxe002ztm54ny76hpwtdvara7tr8nfz4kadkmw9m795rnd4kczggvumavh
static immutable XE = KeyPair(PublicKey(Point([205, 151, 189, 66, 94, 233, 89, 147, 218, 184, 92, 182, 179, 163, 239, 150, 51, 205, 34, 173, 186, 219, 109, 197, 223, 139, 65, 205, 181, 182, 4, 132])), SecretKey(Scalar([160, 12, 75, 189, 64, 11, 213, 13, 155, 137, 38, 13, 53, 150, 58, 191, 155, 121, 35, 90, 83, 89, 208, 85, 16, 178, 129, 58, 253, 212, 56, 10])));
/// XF: boa1xzxf00v5dv03ncsk50sudspq9vatlxpljx37efujeg7rvj7y63ecwaj80fm
static immutable XF = KeyPair(PublicKey(Point([140, 151, 189, 148, 107, 31, 25, 226, 22, 163, 225, 198, 192, 32, 43, 58, 191, 152, 63, 145, 163, 236, 167, 146, 202, 60, 54, 75, 196, 212, 115, 135])), SecretKey(Scalar([148, 185, 1, 3, 246, 145, 167, 185, 72, 246, 210, 136, 139, 56, 17, 54, 251, 22, 127, 47, 94, 159, 89, 33, 156, 135, 191, 194, 131, 93, 209, 12])));
/// XG: boa1xrxg00w74e5c8mmhj0jw24fq7we2vzkx5378rl7t8p9mdw2q0f3fj2vmnql
static immutable XG = KeyPair(PublicKey(Point([204, 135, 189, 222, 174, 105, 131, 239, 119, 147, 228, 229, 85, 32, 243, 178, 166, 10, 198, 164, 124, 113, 255, 203, 56, 75, 182, 185, 64, 122, 98, 153])), SecretKey(Scalar([79, 24, 75, 200, 68, 195, 206, 54, 54, 83, 88, 138, 80, 6, 202, 164, 27, 18, 108, 114, 41, 76, 186, 122, 177, 144, 218, 229, 130, 100, 53, 8])));
/// XH: boa1xzxh00jgrny8wh2ac5jsr8k4246tpazltmultxk6ux8w35cn445fw6ufd56
static immutable XH = KeyPair(PublicKey(Point([141, 119, 190, 72, 28, 200, 119, 93, 93, 197, 37, 1, 158, 213, 85, 116, 176, 244, 95, 94, 249, 245, 154, 218, 225, 142, 232, 211, 19, 173, 104, 151])), SecretKey(Scalar([36, 199, 67, 56, 104, 65, 175, 45, 70, 216, 56, 77, 149, 157, 46, 3, 68, 0, 182, 32, 250, 220, 206, 166, 239, 251, 252, 76, 94, 193, 39, 14])));
/// XJ: boa1xrxj00lrjgwnngwvvf8l274xgmc92agrtpxnvtn7w5z6f2fdkpkrkv45h4j
static immutable XJ = KeyPair(PublicKey(Point([205, 39, 191, 227, 146, 29, 57, 161, 204, 98, 79, 245, 122, 166, 70, 240, 85, 117, 3, 88, 77, 54, 46, 126, 117, 5, 164, 169, 45, 176, 108, 59])), SecretKey(Scalar([191, 82, 29, 14, 28, 80, 6, 30, 218, 141, 255, 234, 91, 131, 215, 92, 133, 240, 194, 132, 236, 231, 138, 132, 73, 215, 127, 128, 239, 229, 130, 13])));
/// XK: boa1xrxk00ns02k7hx4dvqepe7lfrc4jxxl5s5pfy2shlcjf4tlfwrwm6ylawev
static immutable XK = KeyPair(PublicKey(Point([205, 103, 190, 112, 122, 173, 235, 154, 173, 96, 50, 28, 251, 233, 30, 43, 35, 27, 244, 133, 2, 146, 42, 23, 254, 36, 154, 175, 233, 112, 221, 189])), SecretKey(Scalar([142, 251, 161, 195, 214, 161, 213, 251, 253, 19, 62, 68, 195, 88, 69, 169, 66, 45, 47, 255, 36, 133, 88, 25, 187, 200, 72, 99, 125, 198, 49, 2])));
/// XL: boa1xqxl005ajcgrws6qjp4xt8a6fst34anfusm3pe563f8xcgyf2z922mlssdn
static immutable XL = KeyPair(PublicKey(Point([13, 247, 190, 157, 150, 16, 55, 67, 64, 144, 106, 101, 159, 186, 76, 23, 26, 246, 105, 228, 55, 16, 230, 154, 138, 78, 108, 32, 137, 80, 138, 165])), SecretKey(Scalar([174, 181, 161, 66, 252, 54, 7, 189, 119, 18, 47, 6, 52, 232, 231, 35, 155, 217, 139, 124, 112, 150, 171, 254, 92, 115, 148, 170, 136, 163, 64, 4])));
/// XM: boa1xzxm00hwej8gwxpk8gv972sufrd6j8s602s4yrfw4md4c4um382gzxugpw8
static immutable XM = KeyPair(PublicKey(Point([141, 183, 190, 238, 204, 142, 135, 24, 54, 58, 24, 95, 42, 28, 72, 219, 169, 30, 26, 122, 161, 82, 13, 46, 174, 219, 92, 87, 155, 137, 212, 129])), SecretKey(Scalar([136, 31, 243, 187, 202, 149, 93, 15, 156, 91, 57, 54, 171, 77, 9, 112, 178, 204, 142, 219, 240, 115, 167, 8, 21, 123, 12, 44, 172, 222, 28, 10])));
/// XN: boa1xrxn00qp60tqhjwlwpzl5vmhj5wv5urck72tfgdg9dc2w5swsea3qlqvydk
static immutable XN = KeyPair(PublicKey(Point([205, 55, 188, 1, 211, 214, 11, 201, 223, 112, 69, 250, 51, 119, 149, 28, 202, 112, 120, 183, 148, 180, 161, 168, 43, 112, 167, 82, 14, 134, 123, 16])), SecretKey(Scalar([152, 118, 58, 18, 227, 107, 179, 175, 62, 35, 249, 53, 220, 91, 248, 148, 62, 230, 215, 122, 8, 49, 5, 61, 66, 121, 58, 101, 54, 129, 181, 4])));
/// XP: boa1xzxp00gal0kzu2q85ptgw7znn4fnnq7t6e5wkvlcuwex4qdjq5zvwqzjrxm
static immutable XP = KeyPair(PublicKey(Point([140, 23, 189, 29, 251, 236, 46, 40, 7, 160, 86, 135, 120, 83, 157, 83, 57, 131, 203, 214, 104, 235, 51, 248, 227, 178, 106, 129, 178, 5, 4, 199])), SecretKey(Scalar([98, 177, 236, 150, 177, 254, 217, 158, 136, 218, 133, 200, 40, 252, 45, 253, 70, 200, 25, 61, 66, 82, 199, 103, 211, 184, 39, 6, 166, 211, 227, 14])));
/// XQ: boa1xqxq00vdqrnlypxwf2whlpvllygjpd2quu9ya5yn5lyc22d9s67gghjerkd
static immutable XQ = KeyPair(PublicKey(Point([12, 7, 189, 141, 0, 231, 242, 4, 206, 74, 157, 127, 133, 159, 249, 17, 32, 181, 64, 231, 10, 78, 208, 147, 167, 201, 133, 41, 165, 134, 188, 132])), SecretKey(Scalar([148, 175, 72, 24, 69, 163, 25, 240, 189, 69, 1, 156, 185, 11, 27, 96, 241, 1, 6, 31, 10, 144, 79, 44, 97, 244, 43, 112, 237, 192, 238, 1])));
/// XR: boa1xqxr00tcva05y2wln34z0j8udlv7tmuhptcx42jgnn5rm0sz2a8yyssudjk
static immutable XR = KeyPair(PublicKey(Point([12, 55, 189, 120, 103, 95, 66, 41, 223, 156, 106, 39, 200, 252, 111, 217, 229, 239, 151, 10, 240, 106, 170, 72, 156, 232, 61, 190, 2, 87, 78, 66])), SecretKey(Scalar([136, 55, 216, 96, 69, 35, 28, 177, 153, 247, 218, 227, 20, 15, 112, 183, 236, 193, 210, 101, 253, 51, 183, 168, 130, 95, 226, 103, 139, 114, 29, 2])));
/// XS: boa1xzxs00y7a6yr8hn22hwyj0jkn07w6jvyx8uuwmngdcq55fulcfnz5j565tj
static immutable XS = KeyPair(PublicKey(Point([141, 7, 188, 158, 238, 136, 51, 222, 106, 85, 220, 73, 62, 86, 155, 252, 237, 73, 132, 49, 249, 199, 110, 104, 110, 1, 74, 39, 159, 194, 102, 42])), SecretKey(Scalar([152, 221, 171, 75, 117, 44, 11, 241, 96, 99, 84, 165, 153, 235, 4, 92, 208, 7, 229, 240, 249, 2, 150, 21, 53, 157, 81, 45, 178, 104, 223, 0])));
/// XT: boa1xqxt009ufklnemhy4tjp7xc8zsltgl458eus099kt00xejyqjte3cdasdh3
static immutable XT = KeyPair(PublicKey(Point([12, 183, 188, 188, 77, 191, 60, 238, 228, 170, 228, 31, 27, 7, 20, 62, 180, 126, 180, 62, 121, 7, 148, 182, 91, 222, 108, 200, 128, 146, 243, 28])), SecretKey(Scalar([235, 253, 240, 60, 208, 215, 77, 88, 197, 157, 26, 138, 216, 223, 33, 194, 219, 95, 36, 39, 207, 85, 156, 61, 39, 15, 57, 170, 108, 7, 224, 0])));
/// XU: boa1xqxu00lmdsfh7xdz3t6welmx9tc956qnqldj4y3ytpqwadn42cq9xzuek9h
static immutable XU = KeyPair(PublicKey(Point([13, 199, 191, 251, 108, 19, 127, 25, 162, 138, 244, 236, 255, 102, 42, 240, 90, 104, 19, 7, 219, 42, 146, 36, 88, 64, 238, 182, 117, 86, 0, 83])), SecretKey(Scalar([9, 144, 154, 208, 80, 120, 183, 18, 75, 35, 150, 116, 224, 200, 70, 183, 142, 40, 198, 229, 224, 209, 13, 85, 100, 183, 135, 153, 8, 28, 209, 4])));
/// XV: boa1xpxv0097wxqah62nf0ys7zcekymzmuu2uhhq02kklmyyh8pyhd7nknjumdu
static immutable XV = KeyPair(PublicKey(Point([76, 199, 188, 190, 113, 129, 219, 233, 83, 75, 201, 15, 11, 25, 177, 54, 45, 243, 138, 229, 238, 7, 170, 214, 254, 200, 75, 156, 36, 187, 125, 59])), SecretKey(Scalar([253, 214, 60, 99, 12, 17, 133, 16, 231, 183, 66, 143, 136, 53, 49, 113, 204, 53, 221, 167, 73, 201, 57, 42, 153, 168, 20, 129, 132, 142, 97, 7])));
/// XW: boa1xrxw00jqytry5754lkxxwgpuee2ragxnexwpw6gr9agpfus45yps7yvvamc
static immutable XW = KeyPair(PublicKey(Point([204, 231, 190, 64, 34, 198, 74, 122, 149, 253, 140, 103, 32, 60, 206, 84, 62, 160, 211, 201, 156, 23, 105, 3, 47, 80, 20, 242, 21, 161, 3, 15])), SecretKey(Scalar([85, 45, 35, 14, 50, 217, 110, 129, 223, 15, 125, 57, 114, 178, 190, 199, 128, 195, 78, 129, 127, 25, 6, 69, 129, 102, 75, 231, 125, 246, 112, 8])));
/// XX: boa1xpxx007eyhx4qh4w2dfmm8fh8yse5fv6prtgnw2ulpl4lam32l5v7ykkrah
static immutable XX = KeyPair(PublicKey(Point([76, 103, 191, 217, 37, 205, 80, 94, 174, 83, 83, 189, 157, 55, 57, 33, 154, 37, 154, 8, 214, 137, 185, 92, 248, 127, 95, 247, 113, 87, 232, 207])), SecretKey(Scalar([93, 9, 228, 125, 39, 202, 36, 172, 217, 141, 234, 105, 53, 125, 103, 78, 24, 182, 136, 205, 89, 191, 138, 166, 81, 51, 181, 237, 71, 20, 24, 0])));
/// XY: boa1xqxy007lvxlzrnpknzdd6s986m6mr9yx6z68c3p7h644ndfepv9gg4m5frp
static immutable XY = KeyPair(PublicKey(Point([12, 71, 191, 223, 97, 190, 33, 204, 54, 152, 154, 221, 64, 167, 214, 245, 177, 148, 134, 208, 180, 124, 68, 62, 190, 171, 89, 181, 57, 11, 10, 132])), SecretKey(Scalar([206, 255, 62, 252, 94, 128, 84, 113, 254, 170, 56, 160, 121, 220, 253, 133, 199, 197, 2, 43, 161, 125, 250, 184, 225, 65, 179, 68, 215, 241, 60, 12])));
/// XZ: boa1xrxz00mdgqpcm4j7u7pw4v2mjxr4ewmzt8q0wsvt7dsck0e5v89wwywkhhq
static immutable XZ = KeyPair(PublicKey(Point([204, 39, 191, 109, 64, 3, 141, 214, 94, 231, 130, 234, 177, 91, 145, 135, 92, 187, 98, 89, 192, 247, 65, 139, 243, 97, 139, 63, 52, 97, 202, 231])), SecretKey(Scalar([245, 157, 249, 85, 230, 152, 97, 80, 213, 223, 199, 132, 206, 99, 138, 105, 189, 241, 65, 204, 179, 173, 7, 106, 65, 155, 77, 164, 244, 252, 195, 10])));
/// YA: boa1xpya00yake0jveklrf7zgudmjjs08h3gtvjwxmp47kcyhghu3r7qc46xh0e
static immutable YA = KeyPair(PublicKey(Point([73, 215, 188, 157, 182, 95, 38, 102, 223, 26, 124, 36, 113, 187, 148, 160, 243, 222, 40, 91, 36, 227, 108, 53, 245, 176, 75, 162, 252, 136, 252, 12])), SecretKey(Scalar([14, 192, 46, 134, 77, 28, 144, 133, 135, 229, 98, 89, 186, 60, 54, 183, 122, 2, 45, 131, 16, 181, 69, 166, 120, 12, 53, 191, 169, 56, 91, 14])));
/// YC: boa1xqyc00zcjg7reafqwgjn84yxmrgcyyxjfjkn4xgz7lq3xyhwsyw5kpvw2km
static immutable YC = KeyPair(PublicKey(Point([9, 135, 188, 88, 146, 60, 60, 245, 32, 114, 37, 51, 212, 134, 216, 209, 130, 16, 210, 76, 173, 58, 153, 2, 247, 193, 19, 18, 238, 129, 29, 75])), SecretKey(Scalar([97, 91, 195, 1, 2, 91, 190, 237, 72, 100, 77, 17, 94, 246, 246, 160, 132, 18, 88, 255, 103, 205, 37, 164, 54, 14, 38, 166, 250, 32, 224, 10])));
/// YD: boa1xpyd00hkhqvt06583c9pyvfd5sqsfhdtkgpdsy8m9fmztngjm7h95f803rk
static immutable YD = KeyPair(PublicKey(Point([72, 215, 190, 246, 184, 24, 183, 234, 135, 142, 10, 18, 49, 45, 164, 1, 4, 221, 171, 178, 2, 216, 16, 251, 42, 118, 37, 205, 18, 223, 174, 90])), SecretKey(Scalar([200, 41, 94, 102, 6, 204, 209, 242, 252, 251, 162, 144, 45, 89, 123, 248, 141, 121, 158, 120, 57, 245, 135, 212, 28, 60, 163, 123, 94, 63, 194, 2])));
/// YE: boa1xzye0078vkj3ztrj22hfzccz3h9q9ave93dd8exw26t5hc0q8rnvgyme7km
static immutable YE = KeyPair(PublicKey(Point([137, 151, 191, 199, 101, 165, 17, 44, 114, 82, 174, 145, 99, 2, 141, 202, 2, 245, 153, 44, 90, 211, 228, 206, 86, 151, 75, 225, 224, 56, 230, 196])), SecretKey(Scalar([91, 179, 158, 204, 98, 2, 27, 31, 94, 5, 67, 251, 240, 27, 190, 214, 211, 25, 232, 143, 212, 14, 130, 142, 125, 100, 53, 149, 30, 97, 166, 4])));
/// YF: boa1xzyf00lrwcej29w227r5f7gvtrn2yzhd0c49v4gwtvaksmta08pe664qmhz
static immutable YF = KeyPair(PublicKey(Point([136, 151, 191, 227, 118, 51, 37, 21, 202, 87, 135, 68, 249, 12, 88, 230, 162, 10, 237, 126, 42, 86, 85, 14, 91, 59, 104, 109, 125, 121, 195, 157])), SecretKey(Scalar([141, 119, 65, 240, 247, 131, 222, 87, 91, 166, 41, 46, 36, 131, 21, 180, 203, 239, 1, 220, 64, 169, 77, 48, 227, 239, 100, 191, 34, 48, 24, 8])));
/// YG: boa1xqyg00gms63720cnrplxt7ecjpp4yx5mh8tmh0lxs3049lf0d74lgcaeyxr
static immutable YG = KeyPair(PublicKey(Point([8, 135, 189, 27, 134, 163, 229, 63, 19, 24, 126, 101, 251, 56, 144, 67, 82, 26, 155, 185, 215, 187, 191, 230, 132, 95, 82, 253, 47, 111, 171, 244])), SecretKey(Scalar([189, 80, 151, 225, 119, 69, 104, 189, 255, 175, 219, 3, 50, 221, 31, 188, 244, 164, 157, 236, 113, 58, 151, 88, 68, 27, 98, 16, 27, 108, 35, 12])));
/// YH: boa1xpyh00en50ped2dh2j0pd3uum6jy8c2sr2ejf6txct2rp059xcpszekxccm
static immutable YH = KeyPair(PublicKey(Point([73, 119, 191, 51, 163, 195, 150, 169, 183, 84, 158, 22, 199, 156, 222, 164, 67, 225, 80, 26, 179, 36, 233, 102, 194, 212, 48, 190, 133, 54, 3, 1])), SecretKey(Scalar([32, 229, 16, 91, 53, 104, 232, 224, 154, 170, 54, 77, 167, 255, 165, 133, 63, 1, 42, 5, 87, 186, 159, 188, 230, 17, 82, 17, 221, 210, 234, 6])));
/// YJ: boa1xzyj00588rluvch70h848hrymtq0sehrha98puq9ngsnhdkkyfc0g8m7ylg
static immutable YJ = KeyPair(PublicKey(Point([137, 39, 190, 135, 56, 255, 198, 98, 254, 125, 207, 83, 220, 100, 218, 192, 248, 102, 227, 191, 74, 112, 240, 5, 154, 33, 59, 182, 214, 34, 112, 244])), SecretKey(Scalar([168, 106, 41, 1, 83, 30, 170, 53, 217, 248, 172, 158, 107, 148, 243, 165, 52, 226, 94, 119, 218, 122, 9, 4, 171, 229, 185, 231, 138, 0, 122, 12])));
/// YK: boa1xqyk003tk2jl8sv50j9nt4lslj3etxemtx0tn9t6zpdnaxf4yuydxffn4p5
static immutable YK = KeyPair(PublicKey(Point([9, 103, 190, 43, 178, 165, 243, 193, 148, 124, 139, 53, 215, 240, 252, 163, 149, 155, 59, 89, 158, 185, 149, 122, 16, 91, 62, 153, 53, 39, 8, 211])), SecretKey(Scalar([147, 104, 212, 16, 24, 176, 186, 195, 217, 76, 181, 140, 12, 213, 205, 99, 24, 254, 30, 119, 61, 43, 239, 147, 77, 82, 229, 211, 254, 244, 187, 14])));
/// YL: boa1xqyl00n3m06t8madagq990f3ppdmn7qeq2fv22csfgxduea8e2m7kj3hcwx
static immutable YL = KeyPair(PublicKey(Point([9, 247, 190, 113, 219, 244, 179, 239, 173, 234, 0, 82, 189, 49, 8, 91, 185, 248, 25, 2, 146, 197, 43, 16, 74, 12, 222, 103, 167, 202, 183, 235])), SecretKey(Scalar([31, 61, 118, 144, 24, 186, 194, 41, 128, 9, 181, 127, 56, 40, 87, 146, 151, 189, 17, 195, 80, 225, 168, 113, 89, 59, 91, 240, 152, 178, 233, 2])));
/// YM: boa1xzym00sxa9ca4uw5jz8veyp3jvaw225m9hduy7c6spxj6as23qxey6zhrht
static immutable YM = KeyPair(PublicKey(Point([137, 183, 190, 6, 233, 113, 218, 241, 212, 144, 142, 204, 144, 49, 147, 58, 229, 42, 155, 45, 219, 194, 123, 26, 128, 77, 45, 118, 10, 136, 13, 146])), SecretKey(Scalar([97, 163, 115, 26, 41, 109, 123, 123, 222, 161, 123, 76, 226, 239, 63, 185, 27, 95, 136, 242, 170, 154, 151, 194, 111, 90, 244, 171, 8, 234, 169, 4])));
/// YN: boa1xqyn004vtj7ppsrsdpq6vpxnvvlz85pwx7c9drhsveprfwzqs859ccdj5tw
static immutable YN = KeyPair(PublicKey(Point([9, 55, 190, 172, 92, 188, 16, 192, 112, 104, 65, 166, 4, 211, 99, 62, 35, 208, 46, 55, 176, 86, 142, 240, 102, 66, 52, 184, 64, 129, 232, 92])), SecretKey(Scalar([53, 82, 68, 235, 6, 191, 88, 95, 254, 190, 59, 180, 231, 31, 62, 106, 154, 156, 75, 203, 171, 195, 177, 151, 124, 117, 114, 81, 11, 148, 115, 13])));
/// YP: boa1xzyp005dy3h7qe9m4ktfavq52a2pg2v3d2vzxjt2r4qnczv2adefw4udadg
static immutable YP = KeyPair(PublicKey(Point([136, 23, 190, 141, 36, 111, 224, 100, 187, 173, 150, 158, 176, 20, 87, 84, 20, 41, 145, 106, 152, 35, 73, 106, 29, 65, 60, 9, 138, 235, 114, 151])), SecretKey(Scalar([6, 137, 223, 172, 241, 65, 224, 107, 46, 246, 241, 255, 99, 11, 214, 44, 219, 135, 50, 88, 164, 73, 234, 63, 131, 47, 75, 248, 74, 12, 198, 13])));
/// YQ: boa1xzyq000vdmwuxatdkd45ymlssuvpp4sd0ha49u7hqlmjsmmy4xf322cta07
static immutable YQ = KeyPair(PublicKey(Point([136, 7, 189, 236, 110, 221, 195, 117, 109, 179, 107, 66, 111, 240, 135, 24, 16, 214, 13, 125, 251, 82, 243, 215, 7, 247, 40, 111, 100, 169, 147, 21])), SecretKey(Scalar([232, 58, 246, 50, 177, 0, 173, 70, 218, 154, 159, 107, 160, 9, 45, 22, 227, 106, 32, 149, 178, 162, 188, 71, 140, 68, 144, 54, 205, 228, 138, 4])));
/// YR: boa1xryr0020e6p44v4a6ywy8srrct8dualadvchn794qv90dccvu06kz5z49lm
static immutable YR = KeyPair(PublicKey(Point([200, 55, 189, 79, 206, 131, 90, 178, 189, 209, 28, 67, 192, 99, 194, 206, 222, 119, 253, 107, 49, 121, 248, 181, 3, 10, 246, 227, 12, 227, 245, 97])), SecretKey(Scalar([201, 150, 101, 9, 25, 2, 138, 60, 162, 32, 107, 223, 5, 48, 242, 3, 218, 81, 217, 201, 59, 141, 131, 221, 36, 74, 103, 194, 123, 171, 119, 3])));
/// YS: boa1xqys00jfmvnnaf4ejvta95skhlx4dx07qv68mtuhn5aae5me9mm778e0lsw
static immutable YS = KeyPair(PublicKey(Point([9, 7, 190, 73, 219, 39, 62, 166, 185, 147, 23, 210, 210, 22, 191, 205, 86, 153, 254, 3, 52, 125, 175, 151, 157, 59, 220, 211, 121, 46, 247, 239])), SecretKey(Scalar([99, 83, 147, 7, 58, 124, 158, 222, 5, 171, 118, 248, 41, 91, 140, 230, 36, 192, 228, 86, 32, 205, 195, 89, 131, 31, 251, 134, 111, 225, 140, 13])));
/// YT: boa1xryt00r7w5rq77kqjfanwketzqydwsg09yz76zrh84w424s24ppu2sq4cvm
static immutable YT = KeyPair(PublicKey(Point([200, 183, 188, 126, 117, 6, 15, 122, 192, 146, 123, 55, 91, 43, 16, 8, 215, 65, 15, 41, 5, 237, 8, 119, 61, 93, 85, 86, 10, 168, 67, 197])), SecretKey(Scalar([228, 107, 110, 122, 200, 184, 152, 120, 201, 53, 26, 103, 6, 201, 208, 191, 72, 182, 212, 213, 164, 191, 53, 115, 127, 216, 214, 209, 16, 66, 170, 3])));
/// YU: boa1xzyu006uy469xsqm035gfrw2m3svlug8m5vujy72l3fg6tm7jcjjgjswpz0
static immutable YU = KeyPair(PublicKey(Point([137, 199, 191, 92, 37, 116, 83, 64, 27, 124, 104, 132, 141, 202, 220, 96, 207, 241, 7, 221, 25, 201, 19, 202, 252, 82, 141, 47, 126, 150, 37, 36])), SecretKey(Scalar([88, 36, 174, 237, 72, 231, 45, 35, 174, 112, 95, 0, 167, 49, 162, 44, 0, 235, 222, 69, 219, 211, 183, 254, 44, 242, 6, 166, 140, 58, 33, 11])));
/// YV: boa1xzyv00sz96005j6yy82xujmxw9ucwpjexc9ccj0l8wch9uu7c3g7sg873ad
static immutable YV = KeyPair(PublicKey(Point([136, 199, 190, 2, 46, 158, 250, 75, 68, 33, 212, 110, 75, 102, 113, 121, 135, 6, 89, 54, 11, 140, 73, 255, 59, 177, 114, 243, 158, 196, 81, 232])), SecretKey(Scalar([51, 49, 247, 193, 117, 44, 241, 120, 107, 191, 216, 8, 155, 254, 174, 252, 207, 51, 0, 99, 100, 208, 116, 53, 165, 208, 207, 28, 102, 14, 64, 15])));
/// YW: boa1xqyw003h6azzz06w8lfldzq5etapg7958n5ul6sx5ucdm0neajeuuyxz8y6
static immutable YW = KeyPair(PublicKey(Point([8, 231, 190, 55, 215, 68, 33, 63, 78, 63, 211, 246, 136, 20, 202, 250, 20, 120, 180, 60, 233, 207, 234, 6, 167, 48, 221, 190, 121, 236, 179, 206])), SecretKey(Scalar([238, 178, 112, 228, 127, 150, 242, 68, 139, 43, 191, 191, 250, 105, 149, 201, 173, 172, 21, 95, 177, 179, 14, 68, 231, 220, 71, 246, 154, 43, 242, 8])));
/// YX: boa1xpyx00devuck547mt6mcnhjdn382tqm4xhf9q2vhc3xwhraeymrn7ks6vgl
static immutable YX = KeyPair(PublicKey(Point([72, 103, 189, 185, 103, 49, 106, 87, 219, 94, 183, 137, 222, 77, 156, 78, 165, 131, 117, 53, 210, 80, 41, 151, 196, 76, 235, 143, 185, 38, 199, 63])), SecretKey(Scalar([192, 33, 124, 156, 18, 190, 217, 138, 38, 43, 143, 19, 150, 141, 153, 249, 97, 26, 69, 133, 134, 214, 86, 97, 67, 233, 135, 190, 111, 229, 15, 9])));
/// YY: boa1xryy00z54csv7yw6p864m77z8r63d8rhkssruzzt77eq306tgt032atuhdr
static immutable YY = KeyPair(PublicKey(Point([200, 71, 188, 84, 174, 32, 207, 17, 218, 9, 245, 93, 251, 194, 56, 245, 22, 156, 119, 180, 32, 62, 8, 75, 247, 178, 8, 191, 75, 66, 223, 21])), SecretKey(Scalar([97, 106, 231, 226, 83, 127, 242, 103, 40, 118, 254, 70, 8, 255, 23, 0, 103, 184, 23, 197, 141, 15, 234, 44, 241, 92, 139, 240, 202, 80, 148, 9])));
/// YZ: boa1xpyz00eh3v84e3n752gygdxs4l9mfgymc27rj5mc6v28z2edajgnwj88a50
static immutable YZ = KeyPair(PublicKey(Point([72, 39, 191, 55, 139, 15, 92, 198, 126, 162, 144, 68, 52, 208, 175, 203, 180, 160, 155, 194, 188, 57, 83, 120, 211, 20, 113, 43, 45, 236, 145, 55])), SecretKey(Scalar([26, 163, 221, 37, 224, 34, 99, 226, 33, 217, 15, 53, 227, 47, 92, 52, 147, 239, 1, 0, 133, 11, 77, 250, 25, 34, 68, 144, 98, 28, 123, 3])));
/// ZA: boa1xrza00mdgjmm88v4v8spywevwe5hvfk5kntvculyf45q63z4fcekzpqxkdk
static immutable ZA = KeyPair(PublicKey(Point([197, 215, 191, 109, 68, 183, 179, 157, 149, 97, 224, 18, 59, 44, 118, 105, 118, 38, 212, 180, 214, 204, 115, 228, 77, 104, 13, 68, 85, 78, 51, 97])), SecretKey(Scalar([119, 159, 146, 159, 198, 209, 173, 239, 2, 94, 102, 101, 186, 72, 165, 16, 198, 76, 119, 127, 171, 229, 233, 152, 245, 72, 42, 20, 231, 57, 163, 9])));
/// ZC: boa1xqzc006gftnq9e27afpkyrq5mg3q0uy2wxq2fuhq8rm2d274s7rwkjdrqhl
static immutable ZC = KeyPair(PublicKey(Point([5, 135, 191, 72, 74, 230, 2, 229, 94, 234, 67, 98, 12, 20, 218, 34, 7, 240, 138, 113, 128, 164, 242, 224, 56, 246, 166, 171, 213, 135, 134, 235])), SecretKey(Scalar([12, 161, 235, 202, 201, 204, 157, 254, 66, 148, 104, 10, 148, 123, 79, 7, 238, 42, 43, 67, 101, 104, 72, 70, 105, 226, 150, 65, 97, 159, 98, 6])));
/// ZD: boa1xrzd0047pv33cxuzmavpms5csujev7mu7thc2m87njlyhguez2jtjeld2g3
static immutable ZD = KeyPair(PublicKey(Point([196, 215, 190, 190, 11, 35, 28, 27, 130, 223, 88, 29, 194, 152, 135, 37, 150, 123, 124, 242, 239, 133, 108, 254, 156, 190, 75, 163, 153, 18, 164, 185])), SecretKey(Scalar([31, 237, 187, 29, 85, 184, 219, 72, 139, 130, 13, 96, 113, 220, 241, 52, 178, 171, 254, 168, 158, 124, 141, 46, 15, 60, 204, 214, 85, 113, 69, 8])));
/// ZE: boa1xrze00dw9mc98wtpmrc3yzxxxm49v4wph0uxhcah5fjqxcsnal68wdrkler
static immutable ZE = KeyPair(PublicKey(Point([197, 151, 189, 174, 46, 240, 83, 185, 97, 216, 241, 18, 8, 198, 54, 234, 86, 85, 193, 187, 248, 107, 227, 183, 162, 100, 3, 98, 19, 239, 244, 119])), SecretKey(Scalar([87, 130, 236, 62, 167, 64, 15, 139, 0, 86, 231, 9, 14, 22, 8, 253, 123, 163, 41, 99, 193, 83, 198, 200, 145, 174, 171, 80, 50, 202, 47, 12])));
/// ZF: boa1xqzf00v85vg4rd3n5fwldjens0dtavh4tvq7pgmpwfxwzs3lvpp7sckuj0l
static immutable ZF = KeyPair(PublicKey(Point([4, 151, 189, 135, 163, 17, 81, 182, 51, 162, 93, 246, 203, 51, 131, 218, 190, 178, 245, 91, 1, 224, 163, 97, 114, 76, 225, 66, 63, 96, 67, 232])), SecretKey(Scalar([219, 92, 10, 96, 120, 147, 50, 60, 251, 53, 26, 255, 215, 58, 112, 212, 54, 252, 8, 254, 42, 31, 158, 162, 238, 39, 244, 232, 231, 204, 187, 12])));
/// ZG: boa1xrzg00t053qr5mkvukfrhpswd6tc8vkrpv5chq6ax25ewmrutzk9qtggztt
static immutable ZG = KeyPair(PublicKey(Point([196, 135, 189, 111, 164, 64, 58, 110, 204, 229, 146, 59, 134, 14, 110, 151, 131, 178, 195, 11, 41, 139, 131, 93, 50, 169, 151, 108, 124, 88, 172, 80])), SecretKey(Scalar([224, 164, 174, 82, 82, 37, 179, 220, 176, 195, 149, 242, 24, 180, 160, 187, 167, 195, 52, 134, 116, 57, 143, 250, 51, 30, 129, 210, 8, 209, 148, 15])));
/// ZH: boa1xrzh00y462ava4s8f72j5x4y8jsuagh45nlkngfjwu4h94vq3fj5cpf3y9w
static immutable ZH = KeyPair(PublicKey(Point([197, 119, 188, 149, 210, 186, 206, 214, 7, 79, 149, 42, 26, 164, 60, 161, 206, 162, 245, 164, 255, 105, 161, 50, 119, 43, 114, 213, 128, 138, 101, 76])), SecretKey(Scalar([178, 105, 205, 86, 48, 12, 134, 181, 0, 122, 136, 156, 132, 13, 185, 246, 127, 230, 218, 151, 53, 196, 166, 199, 88, 222, 15, 144, 59, 75, 29, 3])));
/// ZJ: boa1xzzj00pa6ly3e863wrngys87za2pqudpuyjn9ws70rsre0xl3vyry6u6eq4
static immutable ZJ = KeyPair(PublicKey(Point([133, 39, 188, 61, 215, 201, 28, 159, 81, 112, 230, 130, 64, 254, 23, 84, 16, 113, 161, 225, 37, 50, 186, 30, 120, 224, 60, 188, 223, 139, 8, 50])), SecretKey(Scalar([182, 117, 187, 5, 192, 162, 85, 127, 10, 132, 27, 214, 86, 175, 225, 96, 211, 18, 176, 210, 25, 41, 34, 153, 222, 254, 226, 178, 49, 97, 7, 3])));
/// ZK: boa1xpzk000tdjnqkh8q6gut2mf3emnjesr65q74jhanytjmcfwaqj30cvfelc0
static immutable ZK = KeyPair(PublicKey(Point([69, 103, 189, 235, 108, 166, 11, 92, 224, 210, 56, 181, 109, 49, 206, 231, 44, 192, 122, 160, 61, 89, 95, 179, 34, 229, 188, 37, 221, 4, 162, 252])), SecretKey(Scalar([14, 122, 107, 179, 9, 130, 70, 136, 139, 208, 53, 191, 37, 66, 164, 97, 139, 235, 70, 207, 248, 145, 64, 163, 39, 12, 94, 117, 128, 247, 202, 7])));
/// ZL: boa1xqzl00y6crfmfncdlyt379gl2jc6yaagnka0jze68gttryf56jmk6v3y5u4
static immutable ZL = KeyPair(PublicKey(Point([5, 247, 188, 154, 192, 211, 180, 207, 13, 249, 23, 31, 21, 31, 84, 177, 162, 119, 168, 157, 186, 249, 11, 58, 58, 22, 177, 145, 52, 212, 183, 109])), SecretKey(Scalar([133, 80, 141, 41, 33, 63, 230, 203, 197, 23, 62, 133, 68, 251, 183, 104, 97, 36, 40, 42, 100, 97, 231, 56, 41, 120, 88, 146, 237, 90, 42, 4])));
/// ZM: boa1xrzm00jsf294ycxgmzym5h4557w4eau90kyyp4elpnvllyeha5nhw7qdhuu
static immutable ZM = KeyPair(PublicKey(Point([197, 183, 190, 80, 74, 139, 82, 96, 200, 216, 137, 186, 94, 180, 167, 157, 92, 247, 133, 125, 136, 64, 215, 63, 12, 217, 255, 147, 55, 237, 39, 119])), SecretKey(Scalar([167, 177, 183, 198, 127, 134, 67, 218, 228, 17, 23, 171, 171, 179, 118, 108, 155, 87, 11, 240, 198, 219, 113, 157, 142, 56, 230, 142, 47, 248, 143, 9])));
/// ZN: boa1xzzn004g5pleglkzr0ans7uuex07jxddd4fp3jewqm8jarahaeve5afjqmn
static immutable ZN = KeyPair(PublicKey(Point([133, 55, 190, 168, 160, 127, 148, 126, 194, 27, 251, 56, 123, 156, 201, 159, 233, 25, 173, 109, 82, 24, 203, 46, 6, 207, 46, 143, 183, 238, 89, 154])), SecretKey(Scalar([250, 54, 244, 89, 165, 131, 77, 151, 139, 181, 208, 142, 0, 26, 190, 90, 166, 158, 212, 167, 102, 182, 39, 191, 205, 31, 223, 97, 193, 19, 104, 7])));
/// ZP: boa1xqzp00cykklnkxk3uxkatupt6qqceljy92alhawt6d8v3z8vagl9gxdtdej
static immutable ZP = KeyPair(PublicKey(Point([4, 23, 191, 4, 181, 191, 59, 26, 209, 225, 173, 213, 240, 43, 208, 1, 140, 254, 68, 42, 187, 251, 245, 203, 211, 78, 200, 136, 236, 234, 62, 84])), SecretKey(Scalar([71, 49, 185, 52, 142, 229, 149, 98, 143, 223, 94, 39, 236, 247, 11, 180, 38, 207, 39, 177, 148, 13, 255, 165, 178, 164, 234, 130, 132, 226, 239, 1])));
/// ZQ: boa1xpzq00hyw6raadmgd8srhcm2sep2zkld8msxcc20f2lk3mnr60zl6dddjd9
static immutable ZQ = KeyPair(PublicKey(Point([68, 7, 190, 228, 118, 135, 222, 183, 104, 105, 224, 59, 227, 106, 134, 66, 161, 91, 237, 62, 224, 108, 97, 79, 74, 191, 104, 238, 99, 211, 197, 253])), SecretKey(Scalar([186, 6, 255, 234, 235, 153, 130, 28, 171, 212, 52, 222, 12, 25, 175, 182, 165, 225, 108, 16, 49, 19, 161, 122, 85, 127, 10, 223, 93, 150, 153, 12])));
/// ZR: boa1xrzr00p9xdwaqf4w7ecw26zm8a60dsfr9666q3rnwqzwsfsyce8hwtlc2p6
static immutable ZR = KeyPair(PublicKey(Point([196, 55, 188, 37, 51, 93, 208, 38, 174, 246, 112, 229, 104, 91, 63, 116, 246, 193, 35, 46, 181, 160, 68, 115, 112, 4, 232, 38, 4, 198, 79, 119])), SecretKey(Scalar([98, 154, 24, 227, 81, 37, 65, 74, 29, 48, 207, 162, 149, 104, 156, 199, 33, 155, 59, 27, 102, 163, 176, 165, 32, 255, 9, 18, 104, 236, 121, 14])));
/// ZS: boa1xrzs00crxz6qrk9c7j547r9d3u6mepukejxc9lezmsr30nu5cc20wuretup
static immutable ZS = KeyPair(PublicKey(Point([197, 7, 191, 3, 48, 180, 1, 216, 184, 244, 169, 95, 12, 173, 143, 53, 188, 135, 150, 204, 141, 130, 255, 34, 220, 7, 23, 207, 148, 198, 20, 247])), SecretKey(Scalar([98, 75, 72, 10, 172, 253, 48, 4, 201, 21, 170, 246, 43, 107, 236, 11, 101, 16, 131, 132, 74, 52, 249, 127, 233, 224, 40, 219, 52, 163, 125, 4])));
/// ZT: boa1xrzt00vc44696wc80lmqclqlkspypnw3al53hvaenj2f3tceyvrsyqq4hmp
static immutable ZT = KeyPair(PublicKey(Point([196, 183, 189, 152, 173, 116, 93, 59, 7, 127, 246, 12, 124, 31, 180, 2, 64, 205, 209, 239, 233, 27, 179, 185, 156, 148, 152, 175, 25, 35, 7, 2])), SecretKey(Scalar([224, 164, 202, 150, 246, 179, 45, 88, 168, 214, 177, 205, 63, 39, 59, 1, 39, 38, 139, 163, 133, 176, 109, 72, 10, 159, 57, 74, 121, 62, 206, 8])));
/// ZU: boa1xrzu00sedygcmx2e25zan9q0rludr8su7fxtxc5dgk8vtx6952436l785m4
static immutable ZU = KeyPair(PublicKey(Point([197, 199, 190, 25, 105, 17, 141, 153, 89, 85, 5, 217, 148, 15, 31, 248, 209, 158, 28, 242, 76, 179, 98, 141, 69, 142, 197, 155, 69, 162, 171, 29])), SecretKey(Scalar([38, 148, 70, 214, 100, 110, 17, 17, 51, 70, 13, 57, 101, 206, 119, 72, 48, 251, 154, 91, 42, 251, 160, 211, 225, 238, 48, 203, 191, 48, 212, 3])));
/// ZV: boa1xqzv0095meh3sjnra93q4h0jndtwmmtr5n2lhrksvvv5f9w7tt3mj2r52k5
static immutable ZV = KeyPair(PublicKey(Point([4, 199, 188, 180, 222, 111, 24, 74, 99, 233, 98, 10, 221, 242, 155, 86, 237, 237, 99, 164, 213, 251, 142, 208, 99, 25, 68, 149, 222, 90, 227, 185])), SecretKey(Scalar([161, 2, 180, 94, 224, 22, 16, 246, 192, 123, 89, 119, 210, 35, 68, 140, 98, 176, 192, 11, 32, 223, 0, 83, 102, 171, 78, 205, 51, 13, 53, 10])));
/// ZW: boa1xpzw00dfctsal0uh8dkhjfejy4479wrlcyh3kzhr9ukjyx7tkexm68vwjwj
static immutable ZW = KeyPair(PublicKey(Point([68, 231, 189, 169, 194, 225, 223, 191, 151, 59, 109, 121, 39, 50, 37, 107, 226, 184, 127, 193, 47, 27, 10, 227, 47, 45, 34, 27, 203, 182, 77, 189])), SecretKey(Scalar([103, 26, 252, 49, 36, 62, 230, 88, 100, 251, 210, 15, 253, 198, 127, 167, 136, 217, 100, 172, 205, 101, 187, 176, 129, 4, 86, 172, 42, 142, 29, 9])));
/// ZX: boa1xpzx00rfye5upq5kguzer9ahauyyu7p2zw7tvzlda3f4gmysfm2mq0qa0rm
static immutable ZX = KeyPair(PublicKey(Point([68, 103, 188, 105, 38, 105, 192, 130, 150, 71, 5, 145, 151, 183, 239, 8, 78, 120, 42, 19, 188, 182, 11, 237, 236, 83, 84, 108, 144, 78, 213, 176])), SecretKey(Scalar([214, 60, 206, 230, 150, 71, 52, 20, 111, 37, 225, 144, 22, 199, 44, 227, 210, 115, 157, 192, 12, 224, 112, 245, 112, 96, 255, 115, 34, 212, 87, 1])));
/// ZY: boa1xzzy00uneu28tgv9ghvxdvkpmujdgt6z8wuda0asdsvwuvr8m492z0ksqnc
static immutable ZY = KeyPair(PublicKey(Point([132, 71, 191, 147, 207, 20, 117, 161, 133, 69, 216, 102, 178, 193, 223, 36, 212, 47, 66, 59, 184, 222, 191, 176, 108, 24, 238, 48, 103, 221, 74, 161])), SecretKey(Scalar([223, 212, 18, 124, 255, 94, 186, 87, 104, 31, 59, 221, 56, 14, 38, 15, 128, 132, 144, 210, 178, 106, 213, 62, 121, 25, 217, 140, 25, 135, 65, 10])));
/// ZZ: boa1xpzz00gljtpzy204zq2g4vcgzqva96yuznt403d9xuc8pzf8z2gs5dp2dt7
static immutable ZZ = KeyPair(PublicKey(Point([68, 39, 189, 31, 146, 194, 34, 41, 245, 16, 20, 138, 179, 8, 16, 25, 210, 232, 156, 20, 215, 87, 197, 165, 55, 48, 112, 137, 39, 18, 145, 10])), SecretKey(Scalar([114, 174, 177, 23, 189, 20, 22, 137, 240, 153, 86, 32, 136, 112, 183, 112, 128, 251, 224, 56, 101, 78, 217, 65, 93, 215, 193, 243, 88, 10, 99, 14])));
/// AAA: boa1xraaa00qplhf3n9fg3unn29aktu57emk8a6t5u5zxqnuc86ukvudc8tceh6
static immutable AAA = KeyPair(PublicKey(Point([251, 222, 189, 224, 15, 238, 152, 204, 169, 68, 121, 57, 168, 189, 178, 249, 79, 103, 118, 63, 116, 186, 114, 130, 48, 39, 204, 31, 92, 179, 56, 220])), SecretKey(Scalar([36, 40, 35, 75, 118, 249, 66, 232, 96, 207, 213, 80, 122, 200, 13, 225, 138, 251, 251, 157, 34, 78, 234, 255, 29, 108, 103, 153, 210, 103, 157, 7])));
/// AAC: boa1xqaac000j0shdemzcp84hdmxysx56gn0fl2njr8knv26tlay0huwuxzqw22
static immutable AAC = KeyPair(PublicKey(Point([59, 220, 61, 239, 147, 225, 118, 231, 98, 192, 79, 91, 183, 102, 36, 13, 77, 34, 111, 79, 213, 57, 12, 246, 155, 21, 165, 255, 164, 125, 248, 238])), SecretKey(Scalar([100, 27, 167, 242, 20, 59, 228, 6, 109, 227, 94, 136, 93, 12, 118, 66, 10, 0, 9, 224, 145, 71, 180, 47, 41, 89, 6, 205, 192, 176, 210, 11])));
/// AAD: boa1xzaad00yvxff0tn5hp00c27u95m4ll7vyx6d09yq9wmfpgz0yctgk5efpkz
static immutable AAD = KeyPair(PublicKey(Point([187, 214, 189, 228, 97, 146, 151, 174, 116, 184, 94, 252, 43, 220, 45, 55, 95, 255, 204, 33, 180, 215, 148, 128, 43, 182, 144, 160, 79, 38, 22, 139])), SecretKey(Scalar([192, 4, 77, 23, 83, 202, 135, 124, 163, 80, 200, 76, 130, 137, 13, 244, 211, 130, 70, 88, 27, 62, 99, 22, 131, 40, 62, 212, 96, 82, 180, 8])));
/// AAE: boa1xraae00q9lcgn65mvarlqdsvlqtkevfez3vq7694hf8tddadvlsuxerfa5d
static immutable AAE = KeyPair(PublicKey(Point([251, 220, 189, 224, 47, 240, 137, 234, 155, 103, 71, 240, 54, 12, 248, 23, 108, 177, 57, 20, 88, 15, 104, 181, 186, 78, 182, 183, 173, 103, 225, 195])), SecretKey(Scalar([223, 178, 215, 164, 116, 223, 201, 93, 98, 78, 183, 115, 227, 18, 140, 59, 1, 82, 156, 196, 223, 207, 122, 254, 81, 134, 61, 53, 223, 55, 131, 1])));
/// AAF: boa1xqaaf00ncr6ans9r50fxlu2m8pmqc90dy9k6ufy5pw3gy5d2j29u756y2qk
static immutable AAF = KeyPair(PublicKey(Point([59, 212, 189, 243, 192, 245, 217, 192, 163, 163, 210, 111, 241, 91, 56, 118, 12, 21, 237, 33, 109, 174, 36, 148, 11, 162, 130, 81, 170, 146, 139, 207])), SecretKey(Scalar([223, 238, 23, 92, 76, 31, 174, 39, 89, 117, 132, 235, 209, 228, 222, 169, 55, 255, 55, 162, 8, 119, 172, 192, 73, 229, 101, 181, 35, 201, 18, 4])));
/// AAG: boa1xzaag00rzkc4g8h34ae9qfwtsmanu28l96pz3sq9tv9p476z6vdk7jrr85u
static immutable AAG = KeyPair(PublicKey(Point([187, 212, 61, 227, 21, 177, 84, 30, 241, 175, 114, 80, 37, 203, 134, 251, 62, 40, 255, 46, 130, 40, 192, 5, 91, 10, 26, 251, 66, 211, 27, 111])), SecretKey(Scalar([12, 201, 99, 43, 118, 38, 158, 103, 47, 185, 168, 238, 5, 75, 186, 183, 111, 169, 42, 137, 186, 213, 74, 208, 116, 45, 192, 192, 183, 74, 74, 9])));
/// AAH: boa1xzaah00d664ff5yn02f4g27wmcanxl6aewr4x38w7kywpu6yxdr860c0jkd
static immutable AAH = KeyPair(PublicKey(Point([187, 219, 189, 237, 214, 170, 148, 208, 147, 122, 147, 84, 43, 206, 222, 59, 51, 127, 93, 203, 135, 83, 68, 238, 245, 136, 224, 243, 68, 51, 70, 125])), SecretKey(Scalar([197, 158, 176, 22, 183, 216, 167, 50, 124, 142, 45, 83, 118, 46, 203, 145, 197, 162, 235, 175, 190, 106, 233, 5, 228, 221, 242, 77, 28, 24, 146, 9])));
/// AAJ: boa1xpaaj00dvepa35naenxmfhu4dv6quckkhzl0ahjn50tl0g8xrnqr6v93tn8
static immutable AAJ = KeyPair(PublicKey(Point([123, 217, 61, 237, 102, 67, 216, 210, 125, 204, 205, 180, 223, 149, 107, 52, 14, 98, 214, 184, 190, 254, 222, 83, 163, 215, 247, 160, 230, 28, 192, 61])), SecretKey(Scalar([112, 171, 190, 27, 167, 32, 243, 75, 226, 165, 200, 41, 98, 2, 241, 98, 205, 44, 152, 238, 1, 55, 113, 152, 57, 46, 91, 81, 102, 84, 101, 3])));
/// AAK: boa1xraak00ertrjjntju3mvve3nn6nxxujqdm6k98hq2227q32zwdg8jrp37fa
static immutable AAK = KeyPair(PublicKey(Point([251, 219, 61, 249, 26, 199, 41, 77, 114, 228, 118, 198, 102, 51, 158, 166, 99, 114, 64, 110, 245, 98, 158, 224, 82, 149, 224, 69, 66, 115, 80, 121])), SecretKey(Scalar([56, 79, 186, 10, 1, 150, 34, 30, 247, 104, 86, 147, 223, 87, 88, 47, 132, 228, 127, 216, 168, 172, 117, 6, 104, 17, 103, 198, 89, 21, 148, 9])));
/// AAL: boa1xpaal00f7lk4hzl7gzqk0v4kfczx2lp6sylfwphreufzquzelatrvxe6pvc
static immutable AAL = KeyPair(PublicKey(Point([123, 223, 189, 233, 247, 237, 91, 139, 254, 64, 129, 103, 178, 182, 78, 4, 101, 124, 58, 129, 62, 151, 6, 227, 207, 18, 32, 112, 89, 255, 86, 54])), SecretKey(Scalar([1, 252, 31, 250, 251, 91, 116, 248, 6, 35, 171, 163, 70, 227, 174, 181, 184, 159, 22, 15, 248, 168, 42, 133, 234, 110, 183, 186, 188, 81, 155, 3])));
/// AAM: boa1xqaam008fw57ga5kfjky8xysr55klre59yg75ftkzn5uznqfkpggcf3zat9
static immutable AAM = KeyPair(PublicKey(Point([59, 221, 189, 231, 75, 169, 228, 118, 150, 76, 172, 67, 152, 144, 29, 41, 111, 143, 52, 41, 17, 234, 37, 118, 20, 233, 193, 76, 9, 176, 80, 140])), SecretKey(Scalar([112, 134, 38, 161, 223, 233, 147, 189, 194, 228, 152, 26, 132, 245, 52, 204, 136, 192, 190, 120, 245, 130, 68, 206, 229, 180, 213, 202, 242, 156, 144, 9])));
/// AAN: boa1xpaan00pd2cw5qnxk5ml3keqt6dxtjhkjsg8ld7zhp0d03697mueueh5ak9
static immutable AAN = KeyPair(PublicKey(Point([123, 217, 189, 225, 106, 176, 234, 2, 102, 181, 55, 248, 219, 32, 94, 154, 101, 202, 246, 148, 16, 127, 183, 194, 184, 94, 215, 199, 69, 246, 249, 158])), SecretKey(Scalar([1, 9, 184, 80, 193, 91, 56, 49, 103, 224, 167, 172, 17, 88, 63, 40, 246, 199, 102, 252, 165, 219, 110, 129, 112, 151, 199, 25, 94, 99, 0, 6])));
/// AAP: boa1xraap00j6qhchaphryxws7kwj8f32tyyd93l9l4vpttxee7zrsx5waxax7p
static immutable AAP = KeyPair(PublicKey(Point([251, 208, 189, 242, 208, 47, 139, 244, 55, 25, 12, 232, 122, 206, 145, 211, 21, 44, 132, 105, 99, 242, 254, 172, 10, 214, 108, 231, 194, 28, 13, 71])), SecretKey(Scalar([201, 203, 51, 234, 82, 19, 85, 251, 185, 243, 76, 170, 56, 186, 3, 45, 202, 222, 36, 163, 66, 114, 221, 246, 61, 42, 124, 12, 34, 144, 202, 14])));
/// AAQ: boa1xraaq006qvew349w6jk7p0u42p6z5kepzh46dyanpt524nzzmtlsyvzhwx3
static immutable AAQ = KeyPair(PublicKey(Point([251, 208, 61, 250, 3, 50, 232, 212, 174, 212, 173, 224, 191, 149, 80, 116, 42, 91, 33, 21, 235, 166, 147, 179, 10, 232, 170, 204, 66, 218, 255, 2])), SecretKey(Scalar([138, 87, 137, 13, 58, 171, 120, 46, 7, 113, 234, 37, 189, 186, 53, 234, 220, 22, 168, 133, 94, 108, 248, 188, 3, 129, 10, 252, 73, 32, 105, 0])));
/// AAR: boa1xpaar00h0c5nweknjrglw578fwe2fux3mzt8fjpjycl7k80d78tvvfjm5j2
static immutable AAR = KeyPair(PublicKey(Point([123, 209, 189, 247, 126, 41, 55, 102, 211, 144, 209, 247, 83, 199, 75, 178, 164, 240, 209, 216, 150, 116, 200, 50, 38, 63, 235, 29, 237, 241, 214, 198])), SecretKey(Scalar([35, 233, 163, 238, 148, 64, 182, 24, 158, 169, 94, 13, 181, 240, 169, 139, 49, 220, 137, 223, 236, 29, 10, 213, 205, 201, 36, 165, 148, 66, 219, 7])));
/// AAS: boa1xqaas00yleaj8j2cl2ctgafymnp5l8ksegcvhx565uex6849ppldk2fsv5k
static immutable AAS = KeyPair(PublicKey(Point([59, 216, 61, 228, 254, 123, 35, 201, 88, 250, 176, 180, 117, 36, 220, 195, 79, 158, 208, 202, 48, 203, 154, 154, 167, 50, 109, 30, 165, 8, 126, 219])), SecretKey(Scalar([162, 125, 210, 1, 55, 198, 10, 48, 85, 137, 154, 23, 95, 37, 204, 161, 36, 87, 73, 193, 151, 146, 103, 193, 167, 62, 157, 123, 114, 32, 127, 2])));
/// AAT: boa1xzaat002jzv7xlpc3zvy6rsa950qeu3nhr5pyckyj6nauamft0462r6crna
static immutable AAT = KeyPair(PublicKey(Point([187, 213, 189, 234, 144, 153, 227, 124, 56, 136, 152, 77, 14, 29, 45, 30, 12, 242, 51, 184, 232, 18, 98, 196, 150, 167, 222, 119, 105, 91, 235, 165])), SecretKey(Scalar([164, 197, 140, 210, 195, 35, 56, 180, 66, 140, 185, 12, 138, 250, 182, 2, 215, 211, 66, 187, 73, 227, 186, 24, 126, 225, 222, 207, 185, 154, 150, 5])));
/// AAU: boa1xqaau00440td2m44laqnzd22u2psqnfmq506t9kz3e3hs6zysmmey8vtvsc
static immutable AAU = KeyPair(PublicKey(Point([59, 222, 61, 245, 171, 214, 213, 110, 181, 255, 65, 49, 53, 74, 226, 131, 0, 77, 59, 5, 31, 165, 150, 194, 142, 99, 120, 104, 68, 134, 247, 146])), SecretKey(Scalar([118, 101, 150, 211, 12, 141, 86, 16, 242, 123, 135, 133, 124, 234, 234, 185, 40, 220, 227, 158, 13, 79, 151, 247, 41, 165, 99, 1, 93, 92, 201, 12])));
/// AAV: boa1xpaav00yf02wj6xn3mt35zvnzf6s2hlen9gp4tgajcpfjmd83wwj5zpkvma
static immutable AAV = KeyPair(PublicKey(Point([123, 214, 61, 228, 75, 212, 233, 104, 211, 142, 215, 26, 9, 147, 18, 117, 5, 95, 249, 153, 80, 26, 173, 29, 150, 2, 153, 109, 167, 139, 157, 42])), SecretKey(Scalar([203, 140, 148, 48, 84, 76, 149, 137, 184, 49, 199, 252, 159, 164, 174, 179, 46, 231, 225, 120, 82, 60, 165, 177, 112, 3, 167, 22, 31, 116, 179, 9])));
/// AAW: boa1xpaaw007lf0vuk7x2xeanfwpz3y0uskkqn3am39urgxms05er3vszmwkp8a
static immutable AAW = KeyPair(PublicKey(Point([123, 215, 61, 254, 250, 94, 206, 91, 198, 81, 179, 217, 165, 193, 20, 72, 254, 66, 214, 4, 227, 221, 196, 188, 26, 13, 184, 62, 153, 28, 89, 1])), SecretKey(Scalar([104, 98, 104, 205, 41, 219, 95, 2, 65, 101, 82, 210, 142, 72, 104, 128, 89, 103, 77, 115, 76, 251, 7, 37, 161, 218, 32, 153, 216, 9, 142, 14])));
/// AAX: boa1xpaax0085ynse433nsq5fymnl96cwf4wmuvmcp6hz450t0ajguc6yk5cfm0
static immutable AAX = KeyPair(PublicKey(Point([123, 211, 61, 231, 161, 39, 12, 214, 49, 156, 1, 68, 147, 115, 249, 117, 135, 38, 174, 223, 25, 188, 7, 87, 21, 104, 245, 191, 178, 71, 49, 162])), SecretKey(Scalar([119, 34, 209, 162, 198, 57, 122, 254, 172, 41, 51, 70, 233, 103, 233, 55, 189, 242, 54, 42, 111, 91, 158, 145, 238, 90, 5, 118, 198, 48, 29, 4])));
/// AAY: boa1xqaay008egdgnxqhqsc540zas8wd72vgff8rwf0xy844d58fr73kj3879w8
static immutable AAY = KeyPair(PublicKey(Point([59, 210, 61, 231, 202, 26, 137, 152, 23, 4, 49, 74, 188, 93, 129, 220, 223, 41, 136, 74, 78, 55, 37, 230, 33, 235, 86, 208, 233, 31, 163, 105])), SecretKey(Scalar([170, 188, 214, 100, 18, 39, 243, 205, 221, 33, 241, 32, 90, 205, 248, 97, 106, 204, 79, 89, 213, 101, 130, 98, 63, 140, 189, 164, 99, 6, 97, 15])));
/// AAZ: boa1xzaaz00naxfknpq66ryyrflk8m06jazv9cjn0tengz9d4hewn9a6y2laavx
static immutable AAZ = KeyPair(PublicKey(Point([187, 209, 61, 243, 233, 147, 105, 132, 26, 208, 200, 65, 167, 246, 62, 223, 169, 116, 76, 46, 37, 55, 175, 51, 64, 138, 218, 223, 46, 153, 123, 162])), SecretKey(Scalar([116, 34, 148, 161, 110, 250, 114, 21, 40, 153, 35, 108, 41, 54, 222, 81, 65, 87, 79, 240, 9, 19, 26, 121, 114, 180, 180, 81, 227, 117, 11, 0])));
/// ACA: boa1xzaca005ntexnn7spl9m6dlngqd7uvgcdgj04qrt9tcvl5rsld4h20kxxkw
static immutable ACA = KeyPair(PublicKey(Point([187, 142, 189, 244, 154, 242, 105, 207, 208, 15, 203, 189, 55, 243, 64, 27, 238, 49, 24, 106, 36, 250, 128, 107, 42, 240, 207, 208, 112, 251, 107, 117])), SecretKey(Scalar([221, 45, 238, 157, 209, 70, 131, 5, 209, 189, 59, 201, 62, 143, 51, 243, 160, 220, 131, 115, 201, 239, 58, 102, 232, 210, 78, 76, 119, 198, 157, 1])));
/// ACC: boa1xqacc00wljgyz70nsuf38y9t8dxlzdcag5t0gwch3y73yp7ccme4vyg6r5d
static immutable ACC = KeyPair(PublicKey(Point([59, 140, 61, 238, 252, 144, 65, 121, 243, 135, 19, 19, 144, 171, 59, 77, 241, 55, 29, 69, 22, 244, 59, 23, 137, 61, 18, 7, 216, 198, 243, 86])), SecretKey(Scalar([51, 242, 241, 84, 180, 54, 28, 2, 235, 88, 240, 133, 174, 175, 124, 3, 116, 79, 127, 48, 63, 187, 29, 85, 131, 223, 182, 89, 15, 241, 237, 2])));
/// ACD: boa1xzacd00xwxnujgvuklnggcs0qlk5dccrrwgd5l5mzap0ekq4ltzev8szp90
static immutable ACD = KeyPair(PublicKey(Point([187, 134, 189, 230, 113, 167, 201, 33, 156, 183, 230, 132, 98, 15, 7, 237, 70, 227, 3, 27, 144, 218, 126, 155, 23, 66, 252, 216, 21, 250, 197, 150])), SecretKey(Scalar([95, 104, 204, 174, 225, 120, 28, 29, 12, 138, 0, 183, 74, 169, 53, 134, 12, 227, 223, 125, 10, 13, 220, 101, 64, 102, 7, 173, 129, 252, 197, 6])));
/// ACE: boa1xrace00wytmpskhd0dsl89eeuh0mcetpvawyrm74s5gm94ptnpxq6r43syq
static immutable ACE = KeyPair(PublicKey(Point([251, 140, 189, 238, 34, 246, 24, 90, 237, 123, 97, 243, 151, 57, 229, 223, 188, 101, 97, 103, 92, 65, 239, 213, 133, 17, 178, 212, 43, 152, 76, 13])), SecretKey(Scalar([192, 216, 79, 76, 239, 41, 57, 198, 222, 123, 7, 71, 127, 209, 206, 56, 82, 168, 94, 140, 233, 11, 47, 112, 62, 43, 56, 58, 220, 70, 3, 7])));
/// ACF: boa1xqacf0002c4qa38l3ajll4nacj0rngmrag2t8sddat6nclqmpzehqfjtcqk
static immutable ACF = KeyPair(PublicKey(Point([59, 132, 189, 239, 86, 42, 14, 196, 255, 143, 101, 255, 214, 125, 196, 158, 57, 163, 99, 234, 20, 179, 193, 173, 234, 245, 60, 124, 27, 8, 179, 112])), SecretKey(Scalar([175, 58, 238, 185, 61, 165, 154, 46, 92, 137, 42, 204, 208, 217, 196, 145, 30, 105, 0, 108, 62, 160, 146, 109, 194, 77, 199, 231, 68, 48, 255, 14])));
/// ACG: boa1xpacg00f8kc2ml7n09jq2mflr95pgu4m7xf5t03q5h25uvwtx6g57elczx9
static immutable ACG = KeyPair(PublicKey(Point([123, 132, 61, 233, 61, 176, 173, 255, 211, 121, 100, 5, 109, 63, 25, 104, 20, 114, 187, 241, 147, 69, 190, 32, 165, 213, 78, 49, 203, 54, 145, 79])), SecretKey(Scalar([239, 61, 25, 124, 227, 82, 170, 32, 201, 229, 89, 230, 244, 109, 2, 145, 117, 228, 187, 120, 208, 94, 98, 192, 48, 251, 175, 180, 30, 3, 22, 9])));
/// ACH: boa1xpach00v9xekpnfwmk726ejd3050edyuf6mp0mmuhxhwu6v76e82q0tpana
static immutable ACH = KeyPair(PublicKey(Point([123, 139, 189, 236, 41, 179, 96, 205, 46, 221, 188, 173, 102, 77, 139, 232, 252, 180, 156, 78, 182, 23, 239, 124, 185, 174, 238, 105, 158, 214, 78, 160])), SecretKey(Scalar([200, 182, 212, 43, 4, 175, 222, 80, 127, 26, 82, 61, 94, 133, 176, 203, 101, 19, 189, 34, 12, 195, 110, 22, 191, 202, 95, 119, 82, 246, 1, 13])));
/// ACJ: boa1xqacj00na6ztau8ekxrpuj09vjhutdrpsrgqguykhzdy33dglkpkxtrlx3d
static immutable ACJ = KeyPair(PublicKey(Point([59, 137, 61, 243, 238, 132, 190, 240, 249, 177, 134, 30, 73, 229, 100, 175, 197, 180, 97, 128, 208, 4, 112, 150, 184, 154, 72, 197, 168, 253, 131, 99])), SecretKey(Scalar([99, 10, 233, 225, 189, 30, 132, 44, 68, 74, 244, 186, 147, 54, 130, 137, 98, 8, 7, 1, 1, 108, 117, 161, 247, 201, 224, 36, 153, 119, 65, 12])));
/// ACK: boa1xrack009thds6r39qqq322n2xshaurlyv0kve8gqqfpntrqu5rkx6m2sxz6
static immutable ACK = KeyPair(PublicKey(Point([251, 139, 61, 229, 93, 219, 13, 14, 37, 0, 1, 21, 42, 106, 52, 47, 222, 15, 228, 99, 236, 204, 157, 0, 2, 67, 53, 140, 28, 160, 236, 109])), SecretKey(Scalar([145, 145, 92, 211, 66, 167, 112, 129, 71, 49, 182, 243, 199, 193, 168, 250, 245, 160, 254, 108, 38, 45, 207, 209, 127, 78, 230, 169, 109, 35, 116, 11])));
/// ACL: boa1xzacl00q4dnptlqw88dple7ywcxsj38njydc892u8zzxt68ggaasgcdvvrr
static immutable ACL = KeyPair(PublicKey(Point([187, 143, 189, 224, 171, 102, 21, 252, 14, 57, 218, 31, 231, 196, 118, 13, 9, 68, 243, 145, 27, 131, 149, 92, 56, 132, 101, 232, 232, 71, 123, 4])), SecretKey(Scalar([221, 106, 227, 207, 114, 92, 210, 143, 204, 82, 216, 165, 178, 16, 199, 80, 208, 248, 129, 235, 58, 68, 131, 168, 215, 248, 91, 40, 163, 37, 50, 6])));
/// ACM: boa1xqacm00r970fg4ecjrn0pqd8mm7ldyrf0fnqxcvru43p0878dfy3seyv3yl
static immutable ACM = KeyPair(PublicKey(Point([59, 141, 189, 227, 47, 158, 148, 87, 56, 144, 230, 240, 129, 167, 222, 253, 246, 144, 105, 122, 102, 3, 97, 131, 229, 98, 23, 159, 199, 106, 73, 24])), SecretKey(Scalar([239, 227, 58, 239, 190, 221, 161, 59, 177, 142, 246, 6, 250, 217, 156, 35, 14, 189, 8, 45, 9, 3, 119, 146, 84, 85, 198, 111, 227, 111, 210, 6])));
/// ACN: boa1xracn009ctukyn4l8eetwckshhmreedmkp4pxgwdag9339l4753z2s986qp
static immutable ACN = KeyPair(PublicKey(Point([251, 137, 189, 229, 194, 249, 98, 78, 191, 62, 114, 183, 98, 208, 189, 246, 60, 229, 187, 176, 106, 19, 33, 205, 234, 11, 24, 151, 245, 245, 34, 37])), SecretKey(Scalar([72, 206, 88, 199, 53, 80, 249, 182, 156, 118, 194, 184, 41, 210, 74, 196, 62, 62, 95, 250, 125, 25, 79, 169, 136, 211, 16, 171, 181, 65, 158, 6])));
/// ACP: boa1xzacp00cljauqmjculf79vay0cxx9gnne20cpyqplaqze7l9pjsxvylc5rp
static immutable ACP = KeyPair(PublicKey(Point([187, 128, 189, 248, 252, 187, 192, 110, 88, 231, 211, 226, 179, 164, 126, 12, 98, 162, 115, 202, 159, 128, 144, 1, 255, 64, 44, 251, 229, 12, 160, 102])), SecretKey(Scalar([110, 249, 78, 69, 31, 192, 179, 123, 150, 135, 121, 143, 91, 53, 152, 39, 136, 255, 228, 224, 161, 196, 234, 156, 70, 84, 201, 181, 223, 103, 245, 4])));
/// ACQ: boa1xzacq00dch5tuwwd7hxfkdkxfp6x4aetxsxs8qnljwvgkwg5e23kcu9rkth
static immutable ACQ = KeyPair(PublicKey(Point([187, 128, 61, 237, 197, 232, 190, 57, 205, 245, 204, 155, 54, 198, 72, 116, 106, 247, 43, 52, 13, 3, 130, 127, 147, 152, 139, 57, 20, 202, 163, 108])), SecretKey(Scalar([96, 73, 169, 119, 116, 8, 151, 252, 214, 145, 61, 215, 45, 182, 206, 34, 226, 235, 169, 238, 12, 248, 110, 232, 7, 240, 115, 198, 156, 34, 109, 15])));
/// ACR: boa1xzacr00nn30avkwcdtqgy2x623t5umlq0wvehncdq53w8qsd98mnc5att4y
static immutable ACR = KeyPair(PublicKey(Point([187, 129, 189, 243, 156, 95, 214, 89, 216, 106, 192, 130, 40, 218, 84, 87, 78, 111, 224, 123, 153, 155, 207, 13, 5, 34, 227, 130, 13, 41, 247, 60])), SecretKey(Scalar([170, 161, 120, 48, 80, 75, 20, 216, 242, 200, 249, 116, 210, 127, 117, 244, 48, 153, 37, 60, 135, 120, 114, 110, 137, 73, 234, 21, 229, 201, 240, 2])));
/// ACS: boa1xracs00x5m0vkh6t4elu3wvchm8unpgakf55adn0r2l8ptu4694t6l7sm0g
static immutable ACS = KeyPair(PublicKey(Point([251, 136, 61, 230, 166, 222, 203, 95, 75, 174, 127, 200, 185, 152, 190, 207, 201, 133, 29, 178, 105, 78, 182, 111, 26, 190, 112, 175, 149, 209, 106, 189])), SecretKey(Scalar([74, 168, 211, 18, 175, 183, 158, 216, 46, 134, 157, 214, 219, 157, 226, 102, 238, 185, 234, 4, 57, 24, 210, 93, 15, 108, 95, 71, 233, 164, 5, 7])));
/// ACT: boa1xract00pce3ywel83nw3mw3vwcssmzgevxvm5ah3eqny3rjdhhfccsepl5q
static immutable ACT = KeyPair(PublicKey(Point([251, 133, 189, 225, 198, 98, 71, 103, 231, 140, 221, 29, 186, 44, 118, 33, 13, 137, 25, 97, 153, 186, 118, 241, 200, 38, 72, 142, 77, 189, 211, 140])), SecretKey(Scalar([139, 61, 49, 181, 34, 148, 135, 193, 155, 242, 97, 107, 124, 46, 131, 37, 87, 178, 77, 185, 93, 71, 156, 225, 160, 74, 47, 246, 141, 156, 190, 3])));
/// ACU: boa1xpacu004m99yv4x9ch8zzemn6zpkna4cgagqapp37f4394z6hcfvs0nxv5l
static immutable ACU = KeyPair(PublicKey(Point([123, 142, 61, 245, 217, 74, 70, 84, 197, 197, 206, 33, 103, 115, 208, 131, 105, 246, 184, 71, 80, 14, 132, 49, 242, 107, 18, 212, 90, 190, 18, 200])), SecretKey(Scalar([29, 242, 92, 8, 92, 152, 202, 11, 13, 160, 251, 124, 244, 237, 150, 240, 12, 44, 142, 97, 161, 82, 125, 203, 15, 118, 35, 44, 37, 206, 252, 5])));
/// ACV: boa1xzacv00gx7ul4l9v3c2cxdm3rddzw59ugph9p8zgac87tcwjtzgywallaua
static immutable ACV = KeyPair(PublicKey(Point([187, 134, 61, 232, 55, 185, 250, 252, 172, 142, 21, 131, 55, 113, 27, 90, 39, 80, 188, 64, 110, 80, 156, 72, 238, 15, 229, 225, 210, 88, 144, 71])), SecretKey(Scalar([11, 69, 150, 155, 144, 25, 45, 43, 106, 246, 250, 102, 88, 240, 136, 93, 132, 235, 101, 231, 186, 109, 41, 233, 138, 123, 120, 55, 15, 97, 90, 7])));
/// ACW: boa1xpacw0062upm2m7mh7lmrzrcy483l2nlur0uhtmzflmxusjpskytjg5p8y2
static immutable ACW = KeyPair(PublicKey(Point([123, 135, 61, 250, 87, 3, 181, 111, 219, 191, 191, 177, 136, 120, 37, 79, 31, 170, 127, 224, 223, 203, 175, 98, 79, 246, 110, 66, 65, 133, 136, 185])), SecretKey(Scalar([135, 66, 105, 227, 136, 29, 22, 216, 132, 112, 61, 245, 124, 233, 110, 83, 11, 173, 141, 168, 87, 121, 23, 216, 134, 207, 65, 150, 245, 172, 72, 2])));
/// ACX: boa1xzacx007nrntldqnwlzazlsg8ekcfew9qg0pdancegap5nepw3qxslgd5ek
static immutable ACX = KeyPair(PublicKey(Point([187, 131, 61, 254, 152, 230, 191, 180, 19, 119, 197, 209, 126, 8, 62, 109, 132, 229, 197, 2, 30, 22, 246, 120, 202, 58, 26, 79, 33, 116, 64, 104])), SecretKey(Scalar([27, 108, 202, 215, 70, 84, 156, 232, 111, 199, 239, 76, 34, 64, 1, 202, 100, 238, 201, 147, 61, 213, 18, 134, 100, 6, 215, 43, 43, 188, 162, 13])));
/// ACY: boa1xzacy00ftn4hhumuxnw7mewley57scw3nzu22qhl3k73rfk5l3w7sfpt6fg
static immutable ACY = KeyPair(PublicKey(Point([187, 130, 61, 233, 92, 235, 123, 243, 124, 52, 221, 237, 229, 223, 201, 41, 232, 97, 209, 152, 184, 165, 2, 255, 141, 189, 17, 166, 212, 252, 93, 232])), SecretKey(Scalar([17, 176, 138, 60, 189, 76, 188, 184, 45, 49, 71, 238, 82, 46, 254, 23, 137, 113, 207, 223, 168, 152, 119, 217, 186, 179, 208, 85, 120, 82, 87, 7])));
/// ACZ: boa1xzacz00qeej2a0dwmtuy9t2299esjdzd9j2lec3tr0rqlt0la7hzc6gtydw
static immutable ACZ = KeyPair(PublicKey(Point([187, 129, 61, 224, 206, 100, 174, 189, 174, 218, 248, 66, 173, 74, 41, 115, 9, 52, 77, 44, 149, 252, 226, 43, 27, 198, 15, 173, 255, 239, 174, 44])), SecretKey(Scalar([116, 54, 167, 98, 235, 139, 176, 87, 62, 143, 34, 61, 76, 248, 4, 71, 135, 31, 196, 39, 139, 253, 234, 158, 199, 110, 190, 243, 231, 31, 80, 4])));
/// ADA: boa1xzada00alwwg4e22vw3hf6n8qagv8pnr2w58d2nsze5efevtcd03shvjnwt
static immutable ADA = KeyPair(PublicKey(Point([186, 222, 189, 253, 251, 156, 138, 229, 74, 99, 163, 116, 234, 103, 7, 80, 195, 134, 99, 83, 168, 118, 170, 112, 22, 105, 148, 229, 139, 195, 95, 24])), SecretKey(Scalar([10, 158, 17, 192, 166, 76, 244, 198, 17, 163, 91, 121, 152, 144, 243, 151, 78, 99, 158, 132, 114, 234, 163, 192, 153, 96, 29, 196, 246, 141, 173, 13])));
/// ADC: boa1xpadc00yxt3q7zhl234kwr3yu7y9e3p9t8fyksxn27umqekumk5a6hqy6f9
static immutable ADC = KeyPair(PublicKey(Point([122, 220, 61, 228, 50, 226, 15, 10, 255, 84, 107, 103, 14, 36, 231, 136, 92, 196, 37, 89, 210, 75, 64, 211, 87, 185, 176, 102, 220, 221, 169, 221])), SecretKey(Scalar([66, 2, 87, 133, 118, 34, 48, 107, 119, 245, 60, 173, 65, 176, 105, 111, 228, 70, 145, 94, 52, 25, 148, 239, 145, 129, 138, 109, 178, 240, 134, 15])));
/// ADD: boa1xqadd00xmupua4jhha6xn9lzylm5et4zudhmqypd5xvl53he46mpukd3jwu
static immutable ADD = KeyPair(PublicKey(Point([58, 214, 189, 230, 223, 3, 206, 214, 87, 191, 116, 105, 151, 226, 39, 247, 76, 174, 162, 227, 111, 176, 16, 45, 161, 153, 250, 70, 249, 174, 182, 30])), SecretKey(Scalar([126, 149, 181, 77, 60, 228, 248, 84, 22, 14, 232, 20, 19, 64, 34, 221, 249, 59, 165, 172, 209, 108, 43, 97, 13, 60, 251, 20, 150, 209, 17, 8])));
/// ADE: boa1xqade00v5gmgs2ggrs9lwzvz7c62mnhjfa2d86ln4wz48k38pcapgx57xhw
static immutable ADE = KeyPair(PublicKey(Point([58, 220, 189, 236, 162, 54, 136, 41, 8, 28, 11, 247, 9, 130, 246, 52, 173, 206, 242, 79, 84, 211, 235, 243, 171, 133, 83, 218, 39, 14, 58, 20])), SecretKey(Scalar([215, 60, 206, 87, 140, 92, 212, 218, 247, 152, 135, 205, 60, 169, 67, 151, 102, 58, 127, 158, 240, 193, 123, 251, 223, 63, 217, 89, 166, 226, 80, 10])));
/// ADF: boa1xpadf00gz58g4ng2dllh4k7qcqm2y90pmezwgfvzy5uys4reejupwteun89
static immutable ADF = KeyPair(PublicKey(Point([122, 212, 189, 232, 21, 14, 138, 205, 10, 111, 255, 122, 219, 192, 192, 54, 162, 21, 225, 222, 68, 228, 37, 130, 37, 56, 72, 84, 121, 204, 184, 23])), SecretKey(Scalar([125, 22, 211, 128, 157, 41, 43, 201, 251, 1, 41, 32, 144, 171, 226, 145, 113, 115, 71, 131, 214, 155, 96, 177, 128, 17, 185, 28, 228, 211, 217, 12])));
/// ADG: boa1xpadg00qggpqljg6pd96zupz3g57vxmgryd5yr6006crldnhzyqas25nxm9
static immutable ADG = KeyPair(PublicKey(Point([122, 212, 61, 224, 66, 2, 15, 201, 26, 11, 75, 161, 112, 34, 138, 41, 230, 27, 104, 25, 27, 66, 15, 79, 126, 176, 63, 182, 119, 17, 1, 216])), SecretKey(Scalar([114, 229, 120, 17, 177, 208, 67, 172, 105, 107, 96, 235, 225, 199, 0, 73, 205, 81, 109, 196, 254, 82, 159, 4, 255, 120, 190, 155, 18, 234, 114, 1])));
/// ADH: boa1xzadh00uwvyrj3wrg4xkgyu0yafu0ac9p0qwfy9xt6h5ne5kkeh4zqmcds3
static immutable ADH = KeyPair(PublicKey(Point([186, 219, 189, 252, 115, 8, 57, 69, 195, 69, 77, 100, 19, 143, 39, 83, 199, 247, 5, 11, 192, 228, 144, 166, 94, 175, 73, 230, 150, 182, 111, 81])), SecretKey(Scalar([104, 153, 123, 88, 42, 204, 24, 60, 2, 174, 158, 128, 1, 159, 28, 20, 147, 3, 133, 193, 17, 76, 19, 78, 1, 10, 45, 49, 81, 148, 92, 14])));
/// ADJ: boa1xqadj00k5evq56md9gvcpsap3xg65ana5606ekh8f6js7heuyy2a7ntzdmd
static immutable ADJ = KeyPair(PublicKey(Point([58, 217, 61, 246, 166, 88, 10, 107, 109, 42, 25, 128, 195, 161, 137, 145, 170, 118, 125, 166, 159, 172, 218, 231, 78, 165, 15, 95, 60, 33, 21, 223])), SecretKey(Scalar([153, 146, 159, 28, 79, 201, 239, 167, 33, 141, 53, 3, 233, 181, 208, 79, 215, 56, 158, 73, 89, 174, 250, 152, 125, 245, 198, 35, 73, 125, 10, 9])));
/// ADK: boa1xpadk00g6h37v9dw7hrd38q6k00n5c3p3926zdguajmjdnzzuddwgsh3dwm
static immutable ADK = KeyPair(PublicKey(Point([122, 219, 61, 232, 213, 227, 230, 21, 174, 245, 198, 216, 156, 26, 179, 223, 58, 98, 33, 137, 85, 161, 53, 28, 236, 183, 38, 204, 66, 227, 90, 228])), SecretKey(Scalar([78, 251, 8, 215, 243, 61, 18, 155, 191, 235, 201, 163, 113, 69, 102, 244, 132, 208, 234, 60, 149, 73, 38, 90, 160, 216, 205, 86, 102, 171, 174, 14])));
/// ADL: boa1xzadl00yhu9wqujyhxfgt3tnstyudw0d9mmcqswmyp3a4jxuluzz556ffcw
static immutable ADL = KeyPair(PublicKey(Point([186, 223, 189, 228, 191, 10, 224, 114, 68, 185, 146, 133, 197, 115, 130, 201, 198, 185, 237, 46, 247, 128, 65, 219, 32, 99, 218, 200, 220, 255, 4, 42])), SecretKey(Scalar([17, 140, 202, 74, 240, 89, 125, 18, 52, 105, 182, 6, 43, 224, 92, 121, 198, 176, 102, 151, 147, 79, 58, 235, 229, 174, 170, 195, 20, 209, 42, 5])));
/// ADM: boa1xzadm003wrt4gaxk4ncynes5pz7swdxpyurfdra4jx4thtnpme46j2xcpx6
static immutable ADM = KeyPair(PublicKey(Point([186, 221, 189, 241, 112, 215, 84, 116, 214, 172, 240, 73, 230, 20, 8, 189, 7, 52, 193, 39, 6, 150, 143, 181, 145, 170, 187, 174, 97, 222, 107, 169])), SecretKey(Scalar([190, 117, 8, 233, 101, 37, 208, 50, 29, 69, 198, 189, 103, 163, 29, 50, 94, 70, 152, 219, 64, 212, 206, 154, 56, 132, 21, 33, 132, 138, 145, 15])));
/// ADN: boa1xqadn00wv4tupumsu3m6xzxtryshjdfhcqxvvz2jgpq6qhy33y7jx5ye9hg
static immutable ADN = KeyPair(PublicKey(Point([58, 217, 189, 238, 101, 87, 192, 243, 112, 228, 119, 163, 8, 203, 25, 33, 121, 53, 55, 192, 12, 198, 9, 82, 64, 65, 160, 92, 145, 137, 61, 35])), SecretKey(Scalar([62, 119, 37, 0, 149, 233, 184, 121, 51, 214, 59, 244, 5, 239, 21, 12, 233, 167, 91, 155, 168, 24, 92, 163, 164, 148, 234, 76, 6, 31, 55, 4])));
/// ADP: boa1xradp00jen24jja4mm6v03c8387dhqdl8gqxj44kqucxnufkl6enutam3z7
static immutable ADP = KeyPair(PublicKey(Point([250, 208, 189, 242, 204, 213, 89, 75, 181, 222, 244, 199, 199, 7, 137, 252, 219, 129, 191, 58, 0, 105, 86, 182, 7, 48, 105, 241, 54, 254, 179, 62])), SecretKey(Scalar([185, 202, 235, 151, 79, 237, 164, 205, 29, 19, 128, 99, 125, 252, 239, 238, 159, 247, 33, 70, 40, 132, 153, 34, 43, 231, 28, 182, 227, 187, 131, 6])));
/// ADQ: boa1xpadq00gff93tatsn4v5sjxwmgqpnu3jnhghnrwhf56wxu0aj7qk6456p9a
static immutable ADQ = KeyPair(PublicKey(Point([122, 208, 61, 232, 74, 75, 21, 245, 112, 157, 89, 72, 72, 206, 218, 0, 25, 242, 50, 157, 209, 121, 141, 215, 77, 52, 227, 113, 253, 151, 129, 109])), SecretKey(Scalar([133, 209, 115, 145, 66, 234, 23, 227, 83, 153, 149, 32, 96, 217, 230, 230, 172, 117, 129, 25, 153, 54, 84, 118, 117, 235, 239, 234, 98, 198, 10, 14])));
/// ADR: boa1xradr00m2evay3mcajzgjk3zg68wqzmwampz3ujh0f75338mmefxw78pru2
static immutable ADR = KeyPair(PublicKey(Point([250, 209, 189, 251, 86, 89, 210, 71, 120, 236, 132, 137, 90, 34, 70, 142, 224, 11, 110, 238, 194, 40, 242, 87, 122, 125, 72, 196, 251, 222, 82, 103])), SecretKey(Scalar([148, 109, 171, 83, 169, 203, 7, 60, 7, 85, 113, 80, 69, 76, 162, 185, 128, 34, 49, 51, 22, 219, 64, 37, 41, 241, 43, 205, 247, 112, 194, 11])));
/// ADS: boa1xqads00ckxkd76s39mm0ahqgedaeu2dak2ezdnzf32m2fzc5ncl4jy8nyk3
static immutable ADS = KeyPair(PublicKey(Point([58, 216, 61, 248, 177, 172, 223, 106, 17, 46, 246, 254, 220, 8, 203, 123, 158, 41, 189, 178, 178, 38, 204, 73, 138, 182, 164, 139, 20, 158, 63, 89])), SecretKey(Scalar([252, 247, 130, 147, 6, 178, 1, 117, 55, 3, 39, 18, 116, 129, 73, 222, 11, 177, 42, 202, 140, 178, 146, 68, 237, 118, 229, 134, 149, 45, 96, 10])));
/// ADT: boa1xqadt00f068628v5trf94ltqejshph6gdyuyh2j0jp4l3nvv0a3czk9qdv7
static immutable ADT = KeyPair(PublicKey(Point([58, 213, 189, 233, 126, 143, 165, 29, 148, 88, 210, 90, 253, 96, 204, 161, 112, 223, 72, 105, 56, 75, 170, 79, 144, 107, 248, 205, 140, 127, 99, 129])), SecretKey(Scalar([146, 38, 234, 124, 28, 18, 149, 110, 10, 117, 19, 34, 78, 170, 138, 211, 222, 236, 29, 127, 195, 54, 102, 210, 48, 80, 123, 158, 142, 150, 125, 8])));
/// ADU: boa1xqadu00n9w3fxxkk8jpwztthr7ve76vj3jvjcwfxxtdl4z4yvqxgjzux5k4
static immutable ADU = KeyPair(PublicKey(Point([58, 222, 61, 243, 43, 162, 147, 26, 214, 60, 130, 225, 45, 119, 31, 153, 159, 105, 146, 140, 153, 44, 57, 38, 50, 219, 250, 138, 164, 96, 12, 137])), SecretKey(Scalar([132, 219, 87, 26, 99, 251, 56, 219, 205, 203, 23, 46, 98, 2, 116, 193, 171, 32, 222, 16, 183, 194, 150, 235, 108, 208, 170, 107, 191, 148, 107, 10])));
/// ADV: boa1xqadv00y333rvrqfv8dxglzk0kykzdu3n9g5xrcfegftehyyf8w96tq7qca
static immutable ADV = KeyPair(PublicKey(Point([58, 214, 61, 228, 140, 98, 54, 12, 9, 97, 218, 100, 124, 86, 125, 137, 97, 55, 145, 153, 81, 67, 15, 9, 202, 18, 188, 220, 132, 73, 220, 93])), SecretKey(Scalar([200, 167, 216, 61, 66, 131, 115, 64, 224, 219, 242, 12, 181, 252, 158, 47, 12, 123, 55, 11, 32, 102, 238, 68, 66, 200, 12, 111, 7, 119, 14, 7])));
/// ADW: boa1xzadw00r444juhezd25e3rhagzyzwlcqkjzrdns6xzscv9acrqasssu3uhc
static immutable ADW = KeyPair(PublicKey(Point([186, 215, 61, 227, 173, 107, 46, 95, 34, 106, 169, 152, 142, 253, 64, 136, 39, 127, 0, 180, 132, 54, 206, 26, 48, 161, 134, 23, 184, 24, 59, 8])), SecretKey(Scalar([169, 179, 159, 206, 35, 194, 199, 110, 47, 35, 157, 201, 55, 205, 144, 104, 125, 155, 140, 76, 50, 83, 49, 79, 209, 154, 153, 212, 93, 197, 74, 9])));
/// ADX: boa1xpadx0094e6djj0adyhha07425gm7tuafu90su4ql34vskvdgqxfsnj8ptg
static immutable ADX = KeyPair(PublicKey(Point([122, 211, 61, 229, 174, 116, 217, 73, 253, 105, 47, 126, 191, 213, 85, 17, 191, 47, 157, 79, 10, 248, 114, 160, 252, 106, 200, 89, 141, 64, 12, 152])), SecretKey(Scalar([5, 207, 32, 56, 37, 23, 63, 167, 79, 91, 127, 10, 205, 190, 132, 165, 66, 45, 159, 167, 94, 224, 160, 165, 75, 194, 14, 72, 21, 31, 187, 11])));
/// ADY: boa1xpady002yzkspete3pepxsplryk8msl08ve402enxyu0ets079tzvcpeve9
static immutable ADY = KeyPair(PublicKey(Point([122, 210, 61, 234, 32, 173, 0, 229, 121, 136, 114, 19, 64, 63, 25, 44, 125, 195, 239, 59, 51, 87, 171, 51, 49, 56, 252, 174, 15, 241, 86, 38])), SecretKey(Scalar([123, 97, 185, 13, 227, 184, 228, 173, 167, 132, 166, 172, 37, 45, 70, 123, 146, 131, 33, 41, 192, 219, 67, 1, 71, 234, 131, 15, 36, 12, 164, 0])));
/// ADZ: boa1xqadz00wnylg6e97ejxvrd8hzepnnxez2ddl0evvmhtsxxd59papu33687r
static immutable ADZ = KeyPair(PublicKey(Point([58, 209, 61, 238, 153, 62, 141, 100, 190, 204, 140, 193, 180, 247, 22, 67, 57, 155, 34, 83, 91, 247, 229, 140, 221, 215, 3, 25, 180, 40, 122, 30])), SecretKey(Scalar([149, 91, 12, 176, 102, 147, 223, 40, 223, 195, 151, 7, 245, 130, 96, 176, 111, 174, 236, 164, 216, 189, 187, 115, 194, 201, 240, 39, 71, 143, 158, 4])));
/// AEA: boa1xqaea007g9kzytmlpgwfnl5ckknuvkhhcdy6eus0j62q2dej3d6hsfndnl0
static immutable AEA = KeyPair(PublicKey(Point([59, 158, 189, 254, 65, 108, 34, 47, 127, 10, 28, 153, 254, 152, 181, 167, 198, 90, 247, 195, 73, 172, 242, 15, 150, 148, 5, 55, 50, 139, 117, 120])), SecretKey(Scalar([2, 104, 65, 174, 186, 214, 98, 160, 106, 231, 36, 84, 130, 118, 127, 209, 224, 153, 52, 152, 209, 10, 174, 42, 201, 243, 188, 123, 17, 200, 25, 13])));
/// AEC: boa1xraec004rf5rexhsr39wvxc05ylf2prhlhp3g4n0y4rke4wh4cl82a08zhy
static immutable AEC = KeyPair(PublicKey(Point([251, 156, 61, 245, 26, 104, 60, 154, 240, 28, 74, 230, 27, 15, 161, 62, 149, 4, 119, 253, 195, 20, 86, 111, 37, 71, 108, 213, 215, 174, 62, 117])), SecretKey(Scalar([73, 70, 138, 210, 40, 107, 82, 25, 189, 64, 87, 51, 17, 35, 19, 35, 32, 165, 212, 200, 70, 27, 36, 54, 109, 12, 99, 81, 12, 67, 61, 3])));
/// AED: boa1xqaed00zzncaj5z9pt9dju2utdgtqzx7lt9lfkf72askghgk0633vrdp6fr
static immutable AED = KeyPair(PublicKey(Point([59, 150, 189, 226, 20, 241, 217, 80, 69, 10, 202, 217, 113, 92, 91, 80, 176, 8, 222, 250, 203, 244, 217, 62, 87, 97, 100, 93, 22, 126, 163, 22])), SecretKey(Scalar([76, 225, 215, 185, 140, 36, 99, 119, 101, 47, 42, 240, 187, 45, 222, 211, 189, 21, 24, 168, 173, 134, 150, 25, 133, 35, 248, 122, 192, 104, 250, 14])));
/// AEE: boa1xzaee00r5hvafx6qung6y4g0sh9hlcsu0wx8x4dum3gwdy9knzk57jf8lud
static immutable AEE = KeyPair(PublicKey(Point([187, 156, 189, 227, 165, 217, 212, 155, 64, 228, 209, 162, 85, 15, 133, 203, 127, 226, 28, 123, 140, 115, 85, 188, 220, 80, 230, 144, 182, 152, 173, 79])), SecretKey(Scalar([95, 126, 90, 125, 103, 43, 13, 169, 23, 154, 156, 139, 20, 94, 236, 70, 46, 124, 142, 87, 235, 85, 203, 72, 120, 250, 65, 182, 30, 133, 240, 1])));
/// AEF: boa1xqaef00d405d7r6h7yd8hsquxwrgg55504qthg5e0l9luxjsss7u70u9a76
static immutable AEF = KeyPair(PublicKey(Point([59, 148, 189, 237, 171, 232, 223, 15, 87, 241, 26, 123, 192, 28, 51, 134, 132, 82, 148, 125, 64, 187, 162, 153, 127, 203, 254, 26, 80, 132, 61, 207])), SecretKey(Scalar([48, 2, 255, 208, 167, 17, 60, 87, 145, 60, 20, 82, 61, 85, 182, 145, 128, 168, 92, 194, 208, 217, 249, 134, 171, 143, 216, 26, 79, 229, 93, 12])));
/// AEG: boa1xraeg00etcqxdkc5844mp82fny8jd84el8hcccg5re2r09ugtf8uxjagfqh
static immutable AEG = KeyPair(PublicKey(Point([251, 148, 61, 249, 94, 0, 102, 219, 20, 61, 107, 176, 157, 73, 153, 15, 38, 158, 185, 249, 239, 140, 97, 20, 30, 84, 55, 151, 136, 90, 79, 195])), SecretKey(Scalar([154, 186, 147, 172, 117, 112, 141, 132, 211, 133, 32, 240, 90, 176, 79, 16, 221, 49, 55, 105, 182, 151, 115, 134, 208, 44, 253, 207, 50, 15, 22, 12])));
/// AEH: boa1xqaeh00hz8vee4xehm8t46rwuknxdv9eck8spnwwdjll85yjhr3kznsmw8p
static immutable AEH = KeyPair(PublicKey(Point([59, 155, 189, 247, 17, 217, 156, 212, 217, 190, 206, 186, 232, 110, 229, 166, 102, 176, 185, 197, 143, 0, 205, 206, 108, 191, 243, 208, 146, 184, 227, 97])), SecretKey(Scalar([155, 219, 107, 31, 250, 80, 247, 134, 174, 20, 149, 101, 70, 117, 15, 7, 12, 139, 112, 246, 30, 57, 53, 61, 95, 150, 47, 126, 232, 79, 159, 8])));
/// AEJ: boa1xzaej00c9knuk8j9g7wtddqqc2pl3hhc8djm02scfwpz0728nnmyu97zvjx
static immutable AEJ = KeyPair(PublicKey(Point([187, 153, 61, 248, 45, 167, 203, 30, 69, 71, 156, 182, 180, 0, 194, 131, 248, 222, 248, 59, 101, 183, 170, 24, 75, 130, 39, 249, 71, 156, 246, 78])), SecretKey(Scalar([221, 160, 60, 55, 41, 177, 241, 56, 243, 246, 131, 150, 34, 196, 163, 77, 169, 128, 6, 144, 201, 79, 183, 158, 128, 165, 100, 229, 234, 194, 234, 10])));
/// AEK: boa1xraek000fgduxd5ryxl4x2sqfuw7l52s0y6lg68f0pkqhtrgzjpcckdkknc
static immutable AEK = KeyPair(PublicKey(Point([251, 155, 61, 239, 74, 27, 195, 54, 131, 33, 191, 83, 42, 0, 79, 29, 239, 209, 80, 121, 53, 244, 104, 233, 120, 108, 11, 172, 104, 20, 131, 140])), SecretKey(Scalar([74, 62, 29, 118, 210, 163, 224, 119, 55, 116, 185, 124, 190, 149, 6, 100, 144, 166, 119, 78, 209, 169, 10, 36, 16, 13, 1, 250, 99, 18, 168, 7])));
/// AEL: boa1xqael008t0ypxcx4l5nc7h998tjf0umhfa6l796gtr8ljth30sldcglxx8m
static immutable AEL = KeyPair(PublicKey(Point([59, 159, 189, 231, 91, 200, 19, 96, 213, 253, 39, 143, 92, 165, 58, 228, 151, 243, 119, 79, 117, 255, 23, 72, 88, 207, 249, 46, 241, 124, 62, 220])), SecretKey(Scalar([156, 38, 241, 69, 142, 167, 8, 125, 39, 235, 179, 98, 144, 227, 142, 200, 143, 237, 93, 37, 58, 179, 229, 108, 223, 170, 34, 229, 243, 94, 93, 6])));
/// AEM: boa1xzaem006amwwzj8z9l8awdfezz2mnufzhx5tsfs3qfwlh8j7fctl28qqfy9
static immutable AEM = KeyPair(PublicKey(Point([187, 157, 189, 250, 238, 220, 225, 72, 226, 47, 207, 215, 53, 57, 16, 149, 185, 241, 34, 185, 168, 184, 38, 17, 2, 93, 251, 158, 94, 78, 23, 245])), SecretKey(Scalar([134, 190, 212, 71, 222, 224, 218, 192, 175, 108, 208, 239, 28, 69, 172, 190, 72, 72, 132, 173, 148, 45, 219, 107, 210, 244, 72, 151, 119, 107, 163, 2])));
/// AEN: boa1xqaen004c0rgkw6amudn7hul7vhn5hysqzrz44gzxwdrael87yalg83jv2c
static immutable AEN = KeyPair(PublicKey(Point([59, 153, 189, 245, 195, 198, 139, 59, 93, 223, 27, 63, 95, 159, 243, 47, 58, 92, 144, 0, 134, 42, 213, 2, 51, 154, 62, 231, 231, 241, 59, 244])), SecretKey(Scalar([189, 115, 106, 58, 242, 236, 84, 75, 227, 106, 165, 138, 96, 131, 165, 30, 216, 169, 196, 206, 7, 71, 8, 177, 12, 70, 183, 112, 102, 156, 27, 8])));
/// AEP: boa1xzaep00yzjensxmt5he7lfkhm9dl50ms82x2nmxtwvhdmzcwwguyj2rcl95
static immutable AEP = KeyPair(PublicKey(Point([187, 144, 189, 228, 20, 179, 56, 27, 107, 165, 243, 239, 166, 215, 217, 91, 250, 63, 112, 58, 140, 169, 236, 203, 115, 46, 221, 139, 14, 114, 56, 73])), SecretKey(Scalar([254, 177, 155, 70, 195, 2, 8, 214, 190, 92, 18, 78, 54, 97, 219, 198, 8, 205, 18, 241, 74, 110, 234, 202, 203, 70, 244, 42, 65, 40, 138, 9])));
/// AEQ: boa1xzaeq00g8qpn6u02th0uzzu47p9nza30mzc5a9hzesy2qpz6auyyzks600a
static immutable AEQ = KeyPair(PublicKey(Point([187, 144, 61, 232, 56, 3, 61, 113, 234, 93, 223, 193, 11, 149, 240, 75, 49, 118, 47, 216, 177, 78, 150, 226, 204, 8, 160, 4, 90, 239, 8, 65])), SecretKey(Scalar([247, 2, 171, 226, 194, 81, 146, 237, 120, 173, 123, 18, 221, 183, 240, 18, 160, 34, 16, 35, 152, 217, 153, 27, 21, 243, 192, 67, 239, 21, 98, 5])));
/// AER: boa1xzaer0034tfg22atks2tw4v0hqdswxfmd3dzzssuk5uwlqyyzfp2zysdhpt
static immutable AER = KeyPair(PublicKey(Point([187, 145, 189, 241, 170, 210, 133, 43, 171, 180, 20, 183, 85, 143, 184, 27, 7, 25, 59, 108, 90, 33, 66, 28, 181, 56, 239, 128, 132, 18, 66, 161])), SecretKey(Scalar([95, 114, 227, 110, 187, 48, 37, 130, 184, 43, 197, 251, 198, 93, 220, 204, 254, 50, 217, 49, 58, 252, 80, 192, 165, 241, 121, 202, 99, 151, 223, 14])));
/// AES: boa1xpaes00w8c04hekw5w238fckqtac30aks3hux35l305ltacxzv2vvsdg88t
static immutable AES = KeyPair(PublicKey(Point([123, 152, 61, 238, 62, 31, 91, 230, 206, 163, 149, 19, 167, 22, 2, 251, 136, 191, 182, 132, 111, 195, 70, 159, 139, 233, 245, 247, 6, 19, 20, 198])), SecretKey(Scalar([166, 85, 130, 56, 18, 131, 177, 27, 76, 107, 168, 82, 137, 97, 110, 172, 171, 6, 76, 14, 147, 240, 15, 194, 209, 36, 254, 238, 46, 186, 254, 1])));
/// AET: boa1xqaet00lx60k9y8kzggrwf8868p8tnatxlph8ldygcfem7l3cdeavc2c07y
static immutable AET = KeyPair(PublicKey(Point([59, 149, 189, 255, 54, 159, 98, 144, 246, 18, 16, 55, 36, 231, 209, 194, 117, 207, 171, 55, 195, 115, 253, 164, 70, 19, 157, 251, 241, 195, 115, 214])), SecretKey(Scalar([69, 120, 198, 109, 185, 60, 121, 215, 26, 55, 41, 198, 63, 197, 237, 38, 134, 58, 111, 142, 14, 249, 10, 116, 116, 159, 241, 56, 170, 147, 221, 14])));
/// AEU: boa1xraeu00cuvvet79fm70w60nlqqw2a369slrx3qf0y4hw036u88dngtxemmu
static immutable AEU = KeyPair(PublicKey(Point([251, 158, 61, 248, 227, 25, 149, 248, 169, 223, 158, 237, 62, 127, 0, 28, 174, 199, 69, 135, 198, 104, 129, 47, 37, 110, 231, 199, 92, 57, 219, 52])), SecretKey(Scalar([44, 153, 44, 25, 186, 172, 25, 69, 70, 95, 31, 63, 236, 104, 242, 196, 114, 226, 167, 131, 161, 116, 79, 95, 231, 158, 73, 42, 138, 14, 73, 2])));
/// AEV: boa1xqaev00ep9743a94q87nw40fgujegslne706jye7tw3h7pv3ec6wqcyp2x0
static immutable AEV = KeyPair(PublicKey(Point([59, 150, 61, 249, 9, 125, 88, 244, 181, 1, 253, 55, 85, 233, 71, 37, 148, 67, 243, 207, 159, 169, 19, 62, 91, 163, 127, 5, 145, 206, 52, 224])), SecretKey(Scalar([156, 141, 24, 27, 199, 230, 190, 105, 91, 31, 186, 238, 217, 128, 185, 139, 68, 187, 245, 242, 186, 36, 229, 48, 192, 150, 233, 229, 242, 208, 112, 8])));
/// AEW: boa1xzaew007flgag5quayn3s45sfh3kgtg3083fk3re2aem9vuyufjkxtags7h
static immutable AEW = KeyPair(PublicKey(Point([187, 151, 61, 254, 79, 209, 212, 80, 28, 233, 39, 24, 86, 144, 77, 227, 100, 45, 17, 121, 226, 155, 68, 121, 87, 115, 178, 179, 132, 226, 101, 99])), SecretKey(Scalar([191, 212, 188, 91, 89, 223, 49, 17, 141, 84, 109, 201, 95, 222, 96, 245, 251, 99, 174, 67, 151, 3, 3, 107, 117, 75, 4, 219, 93, 214, 73, 4])));
/// AEX: boa1xpaex00ucexwhaph9zz7s7djfgn69zpv6k34uqhj9s26aukh8cjajneyspm
static immutable AEX = KeyPair(PublicKey(Point([123, 147, 61, 252, 198, 76, 235, 244, 55, 40, 133, 232, 121, 178, 74, 39, 162, 136, 44, 213, 163, 94, 2, 242, 44, 21, 174, 242, 215, 62, 37, 217])), SecretKey(Scalar([47, 171, 238, 244, 24, 166, 128, 233, 190, 31, 157, 116, 20, 40, 69, 216, 92, 178, 37, 179, 25, 81, 54, 19, 50, 216, 228, 181, 131, 69, 44, 3])));
/// AEY: boa1xraey00qc6nzq64h35a30v7e0u0ctvs0659qupn6wwp9s8ydsuwnxfz68qd
static immutable AEY = KeyPair(PublicKey(Point([251, 146, 61, 224, 198, 166, 32, 106, 183, 141, 59, 23, 179, 217, 127, 31, 133, 178, 15, 213, 10, 14, 6, 122, 115, 130, 88, 28, 141, 135, 29, 51])), SecretKey(Scalar([132, 43, 31, 153, 28, 6, 91, 154, 178, 49, 24, 250, 8, 84, 105, 183, 145, 107, 68, 11, 147, 100, 149, 22, 223, 39, 3, 116, 58, 4, 107, 14])));
/// AEZ: boa1xraez00qjs38tk54p36hur2v80d9c7d9uhc6js0uw8h6n3kep3fmyw608c5
static immutable AEZ = KeyPair(PublicKey(Point([251, 145, 61, 224, 148, 34, 117, 218, 149, 12, 117, 126, 13, 76, 59, 218, 92, 121, 165, 229, 241, 169, 65, 252, 113, 239, 169, 198, 217, 12, 83, 178])), SecretKey(Scalar([62, 56, 197, 108, 147, 136, 239, 57, 66, 105, 16, 71, 204, 228, 249, 55, 71, 229, 63, 197, 124, 66, 179, 98, 73, 145, 234, 162, 66, 217, 34, 8])));
/// AFA: boa1xzafa008sp5e7xestg32hawclc9vqxeyasxw6cxadf5yl8nftxkg7wf5s9c
static immutable AFA = KeyPair(PublicKey(Point([186, 158, 189, 231, 128, 105, 159, 27, 48, 90, 34, 171, 245, 216, 254, 10, 192, 27, 36, 236, 12, 237, 96, 221, 106, 104, 79, 158, 105, 89, 172, 143])), SecretKey(Scalar([197, 2, 60, 54, 28, 147, 123, 212, 119, 176, 21, 62, 36, 46, 4, 90, 149, 3, 185, 178, 72, 183, 224, 43, 11, 94, 246, 71, 101, 9, 226, 7])));
/// AFC: boa1xqafc0092h8htdwz48aa2cj3hnmw66hhv2ezrn96xra7pdvl2fkn5ntl8em
static immutable AFC = KeyPair(PublicKey(Point([58, 156, 61, 229, 85, 207, 117, 181, 194, 169, 251, 213, 98, 81, 188, 246, 237, 106, 247, 98, 178, 33, 204, 186, 48, 251, 224, 181, 159, 82, 109, 58])), SecretKey(Scalar([236, 153, 162, 53, 142, 89, 124, 16, 63, 99, 171, 243, 122, 2, 78, 12, 243, 78, 216, 54, 70, 142, 201, 16, 204, 216, 172, 19, 101, 230, 204, 4])));
/// AFD: boa1xrafd009zsh6acqvg4zx2lnhus9zuhxqv2sjk7ax0lxsc0d02h8qk5feqqy
static immutable AFD = KeyPair(PublicKey(Point([250, 150, 189, 229, 20, 47, 174, 224, 12, 69, 68, 101, 126, 119, 228, 10, 46, 92, 192, 98, 161, 43, 123, 166, 127, 205, 12, 61, 175, 85, 206, 11])), SecretKey(Scalar([44, 170, 21, 71, 133, 198, 180, 250, 232, 195, 206, 224, 185, 226, 145, 151, 3, 169, 72, 210, 39, 49, 207, 179, 70, 143, 100, 13, 179, 161, 152, 3])));
/// AFE: boa1xrafe00zjt2kfh489hl48a0rtxyjlgjccn9ezt8aagqcek9vk3zmv4qh65z
static immutable AFE = KeyPair(PublicKey(Point([250, 156, 189, 226, 146, 213, 100, 222, 167, 45, 255, 83, 245, 227, 89, 137, 47, 162, 88, 196, 203, 145, 44, 253, 234, 1, 140, 216, 172, 180, 69, 182])), SecretKey(Scalar([35, 53, 196, 191, 161, 119, 18, 221, 97, 58, 232, 150, 121, 220, 238, 245, 16, 118, 252, 7, 32, 94, 223, 103, 227, 146, 154, 163, 46, 176, 70, 11])));
/// AFF: boa1xqaff005dzuval9zgafl9ktu3hykj5c90jkyd4xjr6jcfkg03cdhuyww2p4
static immutable AFF = KeyPair(PublicKey(Point([58, 148, 189, 244, 104, 184, 206, 252, 162, 71, 83, 242, 217, 124, 141, 201, 105, 83, 5, 124, 172, 70, 212, 210, 30, 165, 132, 217, 15, 142, 27, 126])), SecretKey(Scalar([187, 14, 146, 70, 252, 145, 29, 106, 102, 46, 42, 168, 199, 102, 10, 176, 43, 56, 8, 66, 209, 4, 8, 18, 135, 239, 46, 231, 173, 116, 26, 12])));
/// AFG: boa1xpafg00ycvs4zdtr6w99xynpulu64ns3y9nnnwpzvpfpszhal650qxu7wpr
static immutable AFG = KeyPair(PublicKey(Point([122, 148, 61, 228, 195, 33, 81, 53, 99, 211, 138, 83, 18, 97, 231, 249, 170, 206, 17, 33, 103, 57, 184, 34, 96, 82, 24, 10, 253, 254, 168, 240])), SecretKey(Scalar([2, 222, 167, 188, 97, 9, 105, 15, 247, 211, 21, 181, 128, 102, 160, 17, 253, 83, 195, 217, 123, 6, 5, 90, 162, 161, 38, 108, 22, 163, 43, 12])));
/// AFH: boa1xzafh00qp3j7s4uzk4x5u0f44xtt2x6qv6u77mxwjhfcle5dx3w5xyft7xd
static immutable AFH = KeyPair(PublicKey(Point([186, 155, 189, 224, 12, 101, 232, 87, 130, 181, 77, 78, 61, 53, 169, 150, 181, 27, 64, 102, 185, 239, 108, 206, 149, 211, 143, 230, 141, 52, 93, 67])), SecretKey(Scalar([102, 0, 225, 82, 128, 0, 177, 108, 110, 98, 194, 42, 238, 159, 228, 167, 172, 168, 190, 125, 68, 202, 181, 125, 87, 131, 83, 38, 23, 183, 43, 8])));
/// AFJ: boa1xpafj00eytgl390zst7cv80sh3tfuu9ztt66htpfdcmcw5rmh4je6hzajnk
static immutable AFJ = KeyPair(PublicKey(Point([122, 153, 61, 249, 34, 209, 248, 149, 226, 130, 253, 134, 29, 240, 188, 86, 158, 112, 162, 90, 245, 171, 172, 41, 110, 55, 135, 80, 123, 189, 101, 157])), SecretKey(Scalar([216, 42, 117, 187, 162, 15, 51, 211, 46, 248, 236, 113, 133, 43, 105, 111, 253, 13, 116, 165, 178, 167, 179, 233, 158, 174, 0, 240, 217, 177, 186, 12])));
/// AFK: boa1xqafk00c3mhdc5a7cwgjjpmnyxmndme88v0esye92eqk325sjjruxu2pag7
static immutable AFK = KeyPair(PublicKey(Point([58, 155, 61, 248, 142, 238, 220, 83, 190, 195, 145, 41, 7, 115, 33, 183, 54, 239, 39, 59, 31, 152, 19, 37, 86, 65, 104, 170, 144, 148, 135, 195])), SecretKey(Scalar([210, 10, 102, 225, 21, 73, 7, 30, 215, 116, 91, 51, 8, 96, 225, 187, 254, 201, 68, 4, 196, 179, 34, 150, 208, 99, 169, 123, 231, 235, 205, 13])));
/// AFL: boa1xrafl00fnhne9u2ytcpccsjsm0rsh94umt6pzsagrvc2h2w9eflny05jym8
static immutable AFL = KeyPair(PublicKey(Point([250, 159, 189, 233, 157, 231, 146, 241, 68, 94, 3, 140, 66, 80, 219, 199, 11, 150, 188, 218, 244, 17, 67, 168, 27, 48, 171, 169, 197, 202, 127, 50])), SecretKey(Scalar([231, 110, 194, 94, 75, 251, 45, 57, 163, 178, 159, 213, 243, 132, 91, 199, 190, 100, 97, 212, 165, 46, 184, 195, 67, 65, 24, 182, 73, 152, 201, 10])));
/// AFM: boa1xzafm002xpx0wd7xa6s96d8w9mu7hangfrva50jtcl532cpv3z4wsufa438
static immutable AFM = KeyPair(PublicKey(Point([186, 157, 189, 234, 48, 76, 247, 55, 198, 238, 160, 93, 52, 238, 46, 249, 235, 246, 104, 72, 217, 218, 62, 75, 199, 233, 21, 96, 44, 136, 170, 232])), SecretKey(Scalar([252, 96, 208, 50, 246, 60, 169, 134, 151, 86, 170, 133, 93, 217, 63, 1, 107, 127, 135, 173, 48, 169, 243, 75, 118, 128, 76, 204, 31, 232, 125, 4])));
/// AFN: boa1xzafn00fv3gaa8q0m2pfn94m590cxvm93h9pkkk7nw9jkpd48quku087tdn
static immutable AFN = KeyPair(PublicKey(Point([186, 153, 189, 233, 100, 81, 222, 156, 15, 218, 130, 153, 150, 187, 161, 95, 131, 51, 101, 141, 202, 27, 90, 222, 155, 139, 43, 5, 181, 56, 57, 110])), SecretKey(Scalar([2, 22, 50, 153, 124, 109, 196, 34, 82, 137, 80, 26, 208, 204, 52, 59, 152, 120, 113, 179, 200, 68, 86, 139, 235, 90, 137, 240, 51, 95, 228, 10])));
/// AFP: boa1xqafp00d3x3q8azddzpw8uv5m8hpdx2h20mtl7wrns23qcxtjne8xh38r2v
static immutable AFP = KeyPair(PublicKey(Point([58, 144, 189, 237, 137, 162, 3, 244, 77, 104, 130, 227, 241, 148, 217, 238, 22, 153, 87, 83, 246, 191, 249, 195, 156, 21, 16, 96, 203, 148, 242, 115])), SecretKey(Scalar([115, 178, 136, 130, 60, 57, 169, 235, 91, 187, 148, 180, 2, 178, 72, 87, 81, 141, 161, 130, 189, 150, 29, 7, 226, 105, 147, 161, 36, 148, 52, 6])));
/// AFQ: boa1xzafq0097dgvw0jlqsgy8e3t5l6w3yh3aq27h5ua6g0yy05kslzvknc6xzd
static immutable AFQ = KeyPair(PublicKey(Point([186, 144, 61, 229, 243, 80, 199, 62, 95, 4, 16, 67, 230, 43, 167, 244, 232, 146, 241, 232, 21, 235, 211, 157, 210, 30, 66, 62, 150, 135, 196, 203])), SecretKey(Scalar([98, 62, 64, 61, 33, 42, 252, 149, 205, 167, 22, 187, 245, 32, 190, 128, 105, 158, 161, 172, 246, 233, 12, 226, 194, 45, 39, 55, 179, 161, 8, 7])));
/// AFR: boa1xzafr00x8tp9nc73n29vwcu02qkgz6heqj543jnxr9409kz8jlu9w4wpst3
static immutable AFR = KeyPair(PublicKey(Point([186, 145, 189, 230, 58, 194, 89, 227, 209, 154, 138, 199, 99, 143, 80, 44, 129, 106, 249, 4, 169, 88, 202, 102, 25, 106, 242, 216, 71, 151, 248, 87])), SecretKey(Scalar([9, 248, 193, 173, 193, 52, 18, 188, 3, 23, 223, 168, 229, 248, 238, 236, 69, 122, 61, 79, 184, 167, 109, 111, 19, 39, 217, 145, 84, 146, 26, 13])));
/// AFS: boa1xzafs0005gc0sqrlxfurg0z93x5p4alc3sg9zw52ykm0u8tcdjvtgvf24ge
static immutable AFS = KeyPair(PublicKey(Point([186, 152, 61, 239, 162, 48, 248, 0, 127, 50, 120, 52, 60, 69, 137, 168, 26, 247, 248, 140, 16, 81, 58, 138, 37, 182, 254, 29, 120, 108, 152, 180])), SecretKey(Scalar([169, 130, 149, 199, 66, 212, 209, 57, 59, 199, 247, 174, 18, 16, 47, 33, 173, 81, 227, 215, 33, 97, 92, 91, 216, 27, 187, 230, 59, 145, 136, 12])));
/// AFT: boa1xqaft00fsewdzu4vw95fskg2fruvjk53uvzpy6j60pekuu97s0k5wqge2jk
static immutable AFT = KeyPair(PublicKey(Point([58, 149, 189, 233, 134, 92, 209, 114, 172, 113, 104, 152, 89, 10, 72, 248, 201, 90, 145, 227, 4, 18, 106, 90, 120, 115, 110, 112, 190, 131, 237, 71])), SecretKey(Scalar([209, 192, 76, 211, 129, 179, 113, 228, 93, 135, 128, 61, 125, 66, 135, 1, 140, 44, 19, 126, 194, 211, 211, 2, 13, 234, 184, 61, 170, 11, 28, 5])));
/// AFU: boa1xpafu006uqqmp83aunyu0ystxfn3je0twec52cdkrxc3ks9uu3hes2h8gv7
static immutable AFU = KeyPair(PublicKey(Point([122, 158, 61, 250, 224, 1, 176, 158, 61, 228, 201, 199, 146, 11, 50, 103, 25, 101, 235, 118, 113, 69, 97, 182, 25, 177, 27, 64, 188, 228, 111, 152])), SecretKey(Scalar([206, 218, 61, 138, 79, 214, 205, 41, 101, 108, 186, 216, 161, 32, 68, 189, 238, 224, 173, 134, 222, 247, 181, 101, 68, 149, 216, 103, 250, 137, 20, 8])));
/// AFV: boa1xpafv00df72ssxe70t0wqcwguwnkhcpzgxgrrfv5n3fxe6jvc3ea6g0p566
static immutable AFV = KeyPair(PublicKey(Point([122, 150, 61, 237, 79, 149, 8, 27, 62, 122, 222, 224, 97, 200, 227, 167, 107, 224, 34, 65, 144, 49, 165, 148, 156, 82, 108, 234, 76, 196, 115, 221])), SecretKey(Scalar([91, 241, 33, 90, 188, 218, 118, 220, 75, 144, 224, 236, 186, 42, 222, 240, 141, 90, 197, 234, 181, 2, 180, 215, 205, 88, 10, 204, 24, 113, 204, 5])));
/// AFW: boa1xpafw008n3yc4ysmxp3pn52ahqhy2jqvhn9t3acjmp2rypdkxtuu7kma6fh
static immutable AFW = KeyPair(PublicKey(Point([122, 151, 61, 231, 156, 73, 138, 146, 27, 48, 98, 25, 209, 93, 184, 46, 69, 72, 12, 188, 202, 184, 247, 18, 216, 84, 50, 5, 182, 50, 249, 207])), SecretKey(Scalar([137, 186, 79, 245, 80, 78, 100, 116, 88, 194, 151, 124, 247, 158, 189, 170, 33, 205, 13, 65, 118, 90, 250, 245, 85, 10, 45, 104, 239, 121, 143, 13])));
/// AFX: boa1xzafx00lhw2vpjfrwu7qxzpp0mrueq8gjufvcamyemgxzegykk8jx9ynafu
static immutable AFX = KeyPair(PublicKey(Point([186, 147, 61, 255, 187, 148, 192, 201, 35, 119, 60, 3, 8, 33, 126, 199, 204, 128, 232, 151, 18, 204, 119, 100, 206, 208, 97, 101, 4, 181, 143, 35])), SecretKey(Scalar([129, 184, 24, 95, 165, 198, 94, 160, 122, 25, 67, 38, 154, 60, 129, 148, 36, 249, 91, 211, 44, 91, 215, 50, 161, 167, 20, 23, 132, 224, 93, 8])));
/// AFY: boa1xpafy0035qy2xludu2s203rnvj7z62uyq2a0v4kz593lwlx3tx0z5nf8hap
static immutable AFY = KeyPair(PublicKey(Point([122, 146, 61, 241, 160, 8, 163, 127, 141, 226, 160, 167, 196, 115, 100, 188, 45, 43, 132, 2, 186, 246, 86, 194, 161, 99, 247, 124, 209, 89, 158, 42])), SecretKey(Scalar([101, 248, 157, 164, 238, 4, 201, 81, 215, 197, 138, 187, 234, 59, 7, 120, 117, 205, 232, 92, 157, 195, 124, 210, 33, 41, 185, 148, 228, 90, 5, 10])));
/// AFZ: boa1xqafz00c57wsuyj0sda0utdt6rl4mnscx3awwkf5kfwgpl9w73yj6mlyfwd
static immutable AFZ = KeyPair(PublicKey(Point([58, 145, 61, 248, 167, 157, 14, 18, 79, 131, 122, 254, 45, 171, 208, 255, 93, 206, 24, 52, 122, 231, 89, 52, 178, 92, 128, 252, 174, 244, 73, 45])), SecretKey(Scalar([8, 99, 5, 143, 15, 217, 52, 110, 160, 224, 192, 33, 76, 229, 90, 29, 119, 247, 238, 158, 73, 209, 17, 44, 225, 215, 137, 8, 117, 20, 76, 3])));
/// AGA: boa1xraga006f7mgevkp3lul4nk4us83p6vj5lft9plv9tv5wg55zkaxgu3xcaz
static immutable AGA = KeyPair(PublicKey(Point([250, 142, 189, 250, 79, 182, 140, 178, 193, 143, 249, 250, 206, 213, 228, 15, 16, 233, 146, 167, 210, 178, 135, 236, 42, 217, 71, 34, 148, 21, 186, 100])), SecretKey(Scalar([74, 3, 150, 32, 50, 216, 221, 26, 74, 24, 136, 16, 186, 140, 131, 27, 151, 89, 89, 92, 160, 153, 20, 13, 75, 9, 73, 54, 15, 102, 185, 15])));
/// AGC: boa1xqagc009yhfzykvgudu5f8m9xnkhveh8j6qhv9nr6n5rvqstllgysr428eh
static immutable AGC = KeyPair(PublicKey(Point([58, 140, 61, 229, 37, 210, 34, 89, 136, 227, 121, 68, 159, 101, 52, 237, 118, 102, 231, 150, 129, 118, 22, 99, 212, 232, 54, 2, 11, 255, 208, 72])), SecretKey(Scalar([31, 177, 172, 219, 229, 170, 229, 161, 93, 103, 188, 21, 194, 20, 166, 178, 176, 173, 92, 179, 7, 101, 56, 46, 57, 90, 181, 107, 228, 16, 44, 12])));
/// AGD: boa1xpagd00lzv854s600v5sde07q3aczwwt7ml4p973n0x2u9yerd8y5qnql80
static immutable AGD = KeyPair(PublicKey(Point([122, 134, 189, 255, 19, 15, 74, 195, 79, 123, 41, 6, 229, 254, 4, 123, 129, 57, 203, 246, 255, 80, 151, 209, 155, 204, 174, 20, 153, 27, 78, 74])), SecretKey(Scalar([211, 8, 225, 9, 242, 155, 81, 63, 47, 74, 193, 62, 81, 146, 28, 167, 251, 47, 234, 248, 7, 173, 75, 224, 177, 52, 111, 216, 161, 119, 85, 3])));
/// AGE: boa1xqage008mq0mctq8lkk37g74t9j5urja5ky98mn76tax4ks90sx9uel758x
static immutable AGE = KeyPair(PublicKey(Point([58, 140, 189, 231, 216, 31, 188, 44, 7, 253, 173, 31, 35, 213, 89, 101, 78, 14, 93, 165, 136, 83, 238, 126, 210, 250, 106, 218, 5, 124, 12, 94])), SecretKey(Scalar([100, 68, 137, 253, 60, 139, 62, 18, 127, 57, 58, 151, 135, 164, 135, 3, 146, 226, 244, 196, 121, 113, 186, 165, 221, 217, 185, 254, 115, 121, 48, 1])));
/// AGF: boa1xzagf00jjvvrwjrpzlgxwl3vutdzm5cz2e4mjyqnuujryjgx5zmxx4wcary
static immutable AGF = KeyPair(PublicKey(Point([186, 132, 189, 242, 147, 24, 55, 72, 97, 23, 208, 103, 126, 44, 226, 218, 45, 211, 2, 86, 107, 185, 16, 19, 231, 36, 50, 73, 6, 160, 182, 99])), SecretKey(Scalar([86, 239, 16, 160, 130, 121, 81, 5, 56, 101, 69, 204, 166, 232, 51, 173, 53, 197, 134, 78, 132, 206, 139, 245, 148, 211, 247, 55, 87, 53, 81, 13])));
/// AGG: boa1xragg00klnxlzkkgrzqdcxnx8kqwuxzd8jdfe5jewcpl4z2gtxceud7vpfh
static immutable AGG = KeyPair(PublicKey(Point([250, 132, 61, 246, 252, 205, 241, 90, 200, 24, 128, 220, 26, 102, 61, 128, 238, 24, 77, 60, 154, 156, 210, 89, 118, 3, 250, 137, 72, 89, 177, 158])), SecretKey(Scalar([179, 186, 126, 127, 14, 37, 62, 112, 183, 37, 232, 38, 82, 94, 181, 111, 23, 29, 233, 79, 138, 124, 30, 11, 203, 60, 205, 15, 189, 114, 10, 12])));
/// AGH: boa1xragh00y30gelruxnp800xeuezh6fmvqfcn9c53q2gdskagcv48svuyf33q
static immutable AGH = KeyPair(PublicKey(Point([250, 139, 189, 228, 139, 209, 159, 143, 134, 152, 78, 247, 155, 60, 200, 175, 164, 237, 128, 78, 38, 92, 82, 32, 82, 27, 11, 117, 24, 101, 79, 6])), SecretKey(Scalar([6, 75, 44, 167, 252, 128, 37, 210, 83, 40, 149, 182, 113, 235, 74, 27, 115, 179, 65, 187, 12, 48, 187, 75, 203, 247, 184, 147, 183, 213, 211, 0])));
/// AGJ: boa1xragj00lp6k862v8342gpj7gncfam6zkqrk94h72funyy3v4khemkkkqcm2
static immutable AGJ = KeyPair(PublicKey(Point([250, 137, 61, 255, 14, 172, 125, 41, 135, 141, 84, 128, 203, 200, 158, 19, 221, 232, 86, 0, 236, 90, 223, 202, 79, 38, 66, 69, 149, 181, 243, 187])), SecretKey(Scalar([158, 15, 143, 125, 17, 44, 158, 101, 117, 115, 217, 4, 129, 206, 182, 207, 61, 164, 205, 97, 203, 85, 151, 54, 63, 230, 220, 34, 202, 219, 14, 15])));
/// AGK: boa1xpagk00k0xyzugk868tllmtq3hm9xv3yccc56fa4q8t087266js7y6nzr9n
static immutable AGK = KeyPair(PublicKey(Point([122, 139, 61, 246, 121, 136, 46, 34, 199, 209, 215, 255, 237, 96, 141, 246, 83, 50, 36, 198, 49, 77, 39, 181, 1, 214, 243, 249, 90, 212, 161, 226])), SecretKey(Scalar([152, 254, 132, 15, 81, 253, 104, 73, 192, 251, 164, 246, 81, 103, 187, 88, 255, 87, 101, 249, 66, 194, 124, 166, 152, 191, 63, 46, 132, 182, 77, 2])));
/// AGL: boa1xragl00dxlkkqd6jk9tdr7jctk249dm9cs8cmdetf0ukn74egvtczj6jpdd
static immutable AGL = KeyPair(PublicKey(Point([250, 143, 189, 237, 55, 237, 96, 55, 82, 177, 86, 209, 250, 88, 93, 149, 82, 183, 101, 196, 15, 141, 183, 43, 75, 249, 105, 250, 185, 67, 23, 129])), SecretKey(Scalar([152, 0, 71, 195, 144, 199, 173, 92, 18, 111, 159, 9, 17, 39, 232, 202, 110, 120, 162, 11, 83, 209, 182, 23, 63, 219, 121, 249, 20, 236, 180, 10])));
/// AGM: boa1xpagm00rpz5ggy3ev6qhgaqgtcjplk8dgzfzd24n2c84yxuytkn0jqutmq2
static immutable AGM = KeyPair(PublicKey(Point([122, 141, 189, 227, 8, 168, 132, 18, 57, 102, 129, 116, 116, 8, 94, 36, 31, 216, 237, 64, 146, 38, 170, 179, 86, 15, 82, 27, 132, 93, 166, 249])), SecretKey(Scalar([231, 106, 50, 88, 108, 242, 108, 8, 197, 182, 29, 42, 179, 233, 253, 246, 145, 29, 16, 244, 193, 76, 236, 216, 80, 250, 26, 185, 19, 238, 60, 7])));
/// AGN: boa1xpagn0092vwq34n27pw4k9rprtdtgknt2psvn0lvy66uk6nnmweccjyycwz
static immutable AGN = KeyPair(PublicKey(Point([122, 137, 189, 229, 83, 28, 8, 214, 106, 240, 93, 91, 20, 97, 26, 218, 180, 90, 107, 80, 96, 201, 191, 236, 38, 181, 203, 106, 115, 219, 179, 140])), SecretKey(Scalar([80, 73, 192, 144, 184, 84, 143, 235, 133, 245, 57, 174, 160, 69, 246, 110, 179, 55, 228, 162, 15, 74, 32, 240, 99, 155, 153, 161, 28, 121, 67, 6])));
/// AGP: boa1xzagp00n6kd2nw7zwezy263ml0s2l649dqjnd8n4gtmh79j70v6ryqjym4e
static immutable AGP = KeyPair(PublicKey(Point([186, 128, 189, 243, 213, 154, 169, 187, 194, 118, 68, 69, 106, 59, 251, 224, 175, 234, 165, 104, 37, 54, 158, 117, 66, 247, 127, 22, 94, 123, 52, 50])), SecretKey(Scalar([3, 92, 236, 43, 241, 19, 140, 78, 156, 228, 130, 232, 206, 43, 174, 213, 81, 145, 12, 251, 242, 138, 231, 75, 168, 101, 63, 5, 131, 167, 82, 15])));
/// AGQ: boa1xragq00uwmnfdd2eflrr00as38q5e5thx2x3sa9temvj49rlnavkg5pgqwj
static immutable AGQ = KeyPair(PublicKey(Point([250, 128, 61, 252, 118, 230, 150, 181, 89, 79, 198, 55, 191, 176, 137, 193, 76, 209, 119, 50, 141, 24, 116, 171, 206, 217, 42, 148, 127, 159, 89, 100])), SecretKey(Scalar([220, 54, 169, 17, 159, 101, 157, 151, 255, 17, 78, 92, 202, 170, 230, 250, 82, 113, 144, 189, 1, 219, 54, 41, 53, 241, 118, 115, 99, 47, 203, 3])));
/// AGR: boa1xqagr00ux9cpr4mjg4twwug6lj034wmvux253fsgw9g4zc8v8ealxvap2d9
static immutable AGR = KeyPair(PublicKey(Point([58, 129, 189, 252, 49, 112, 17, 215, 114, 69, 86, 231, 113, 26, 252, 159, 26, 187, 108, 225, 149, 72, 166, 8, 113, 81, 81, 96, 236, 62, 123, 243])), SecretKey(Scalar([111, 87, 248, 180, 130, 47, 229, 68, 248, 70, 82, 16, 174, 33, 214, 128, 161, 188, 234, 160, 196, 36, 54, 123, 117, 0, 186, 147, 241, 159, 198, 7])));
/// AGS: boa1xrags003uhfevcvuv87vp3aflnvsdse5rkhumwr2uw38jxgpmlgvv8226nf
static immutable AGS = KeyPair(PublicKey(Point([250, 136, 61, 241, 229, 211, 150, 97, 156, 97, 252, 192, 199, 169, 252, 217, 6, 195, 52, 29, 175, 205, 184, 106, 227, 162, 121, 25, 1, 223, 208, 198])), SecretKey(Scalar([45, 105, 82, 59, 244, 105, 245, 205, 199, 71, 149, 234, 159, 177, 172, 226, 21, 102, 229, 201, 7, 244, 229, 252, 238, 180, 143, 2, 174, 136, 57, 9])));
/// AGT: boa1xpagt00sulw7x82ch3swvvvttgjhteeer3vensn7f6enrwhc5fpmcu4mx6j
static immutable AGT = KeyPair(PublicKey(Point([122, 133, 189, 240, 231, 221, 227, 29, 88, 188, 96, 230, 49, 139, 90, 37, 117, 231, 57, 28, 89, 153, 194, 126, 78, 179, 49, 186, 248, 162, 67, 188])), SecretKey(Scalar([0, 221, 208, 19, 119, 57, 19, 167, 198, 182, 109, 130, 237, 92, 8, 240, 38, 76, 163, 99, 157, 69, 152, 16, 146, 50, 129, 56, 119, 176, 194, 2])));
/// AGU: boa1xragu0082qpz74eqewetsy35m6g92d2x0ly4qf4x9n80r9szr9hmjpjptl6
static immutable AGU = KeyPair(PublicKey(Point([250, 142, 61, 231, 80, 2, 47, 87, 32, 203, 178, 184, 18, 52, 222, 144, 85, 53, 70, 127, 201, 80, 38, 166, 44, 206, 241, 150, 2, 25, 111, 185])), SecretKey(Scalar([234, 203, 205, 223, 140, 180, 39, 181, 49, 45, 105, 189, 126, 167, 95, 206, 113, 251, 142, 216, 118, 86, 9, 167, 170, 173, 31, 47, 214, 251, 141, 0])));
/// AGV: boa1xqagv00whvz7f9yfc9wydkv2u958p4tgcksdc4t80d9mc8fnqw9jkfma09q
static immutable AGV = KeyPair(PublicKey(Point([58, 134, 61, 238, 187, 5, 228, 148, 137, 193, 92, 70, 217, 138, 225, 104, 112, 213, 104, 197, 160, 220, 85, 103, 123, 75, 188, 29, 51, 3, 139, 43])), SecretKey(Scalar([24, 101, 85, 160, 74, 16, 155, 186, 6, 165, 48, 220, 254, 100, 228, 234, 9, 39, 238, 79, 89, 135, 121, 200, 138, 215, 112, 54, 245, 145, 46, 10])));
/// AGW: boa1xpagw00gf69twjywthz3d5mqcmmgzvm65r0l358nu60nh7973ly2ypqujwu
static immutable AGW = KeyPair(PublicKey(Point([122, 135, 61, 232, 78, 138, 183, 72, 142, 93, 197, 22, 211, 96, 198, 246, 129, 51, 122, 160, 223, 248, 208, 243, 230, 159, 59, 248, 190, 143, 200, 162])), SecretKey(Scalar([140, 210, 104, 85, 5, 53, 131, 5, 149, 122, 126, 165, 27, 211, 175, 123, 42, 17, 91, 71, 128, 50, 201, 85, 121, 71, 200, 222, 51, 11, 237, 2])));
/// AGX: boa1xqagx003lxza4ygn9rhmdmd0u36mykp4qa65zgetgqxaugu7jmaewnh05yj
static immutable AGX = KeyPair(PublicKey(Point([58, 131, 61, 241, 249, 133, 218, 145, 19, 40, 239, 182, 237, 175, 228, 117, 178, 88, 53, 7, 117, 65, 35, 43, 64, 13, 222, 35, 158, 150, 251, 151])), SecretKey(Scalar([226, 72, 218, 88, 61, 62, 83, 213, 157, 194, 27, 192, 182, 230, 132, 13, 119, 180, 78, 86, 163, 250, 127, 55, 82, 27, 162, 54, 111, 209, 166, 11])));
/// AGY: boa1xragy00mvupewfmxnt0nr53n29nn0jf4l0lkln0r83a6h2l4235fja6jwl0
static immutable AGY = KeyPair(PublicKey(Point([250, 130, 61, 251, 103, 3, 151, 39, 102, 154, 223, 49, 210, 51, 81, 103, 55, 201, 53, 251, 255, 111, 205, 227, 60, 123, 171, 171, 245, 84, 104, 153])), SecretKey(Scalar([170, 22, 112, 27, 96, 245, 84, 150, 58, 253, 250, 252, 125, 37, 127, 197, 82, 49, 192, 198, 229, 70, 13, 188, 147, 225, 126, 42, 183, 206, 169, 13])));
/// AGZ: boa1xragz00ejvnx2l4akn2fv8qnqzk6was6gv75758fenn45y8mnwsl2yzd6wa
static immutable AGZ = KeyPair(PublicKey(Point([250, 129, 61, 249, 147, 38, 101, 126, 189, 180, 212, 150, 28, 19, 0, 173, 167, 118, 26, 67, 61, 79, 80, 233, 204, 231, 90, 16, 251, 155, 161, 245])), SecretKey(Scalar([61, 216, 217, 47, 238, 94, 54, 93, 38, 104, 45, 244, 118, 181, 92, 178, 233, 101, 131, 55, 209, 199, 176, 198, 100, 2, 85, 25, 103, 195, 153, 3])));
/// AHA: boa1xraha00vayvpvyw6g02lh7luaetdcc88h6ncf7qan9q7p5zyxagr6zlhul2
static immutable AHA = KeyPair(PublicKey(Point([251, 126, 189, 236, 233, 24, 22, 17, 218, 67, 213, 251, 251, 252, 238, 86, 220, 96, 231, 190, 167, 132, 248, 29, 153, 65, 224, 208, 68, 55, 80, 61])), SecretKey(Scalar([158, 245, 239, 7, 176, 158, 77, 237, 107, 194, 171, 159, 119, 147, 200, 174, 171, 113, 159, 177, 103, 65, 13, 22, 32, 171, 85, 125, 210, 207, 83, 14])));
/// AHC: boa1xpahc00ck7a6hpwtrr5xyu7p6phw3m70mjstlmhhkm28rzpj4jh5xvhqm68
static immutable AHC = KeyPair(PublicKey(Point([123, 124, 61, 248, 183, 187, 171, 133, 203, 24, 232, 98, 115, 193, 208, 110, 232, 239, 207, 220, 160, 191, 238, 247, 182, 212, 113, 136, 50, 172, 175, 67])), SecretKey(Scalar([187, 92, 183, 90, 27, 177, 176, 242, 39, 135, 27, 143, 190, 70, 129, 25, 128, 236, 81, 158, 238, 254, 171, 205, 179, 128, 60, 14, 211, 166, 188, 1])));
/// AHD: boa1xrahd000yf99vqmvm0eejy9l6e9gj5vj8ce9t29uxfhvqwpy24klc00ppvr
static immutable AHD = KeyPair(PublicKey(Point([251, 118, 189, 239, 34, 74, 86, 3, 108, 219, 243, 153, 16, 191, 214, 74, 137, 81, 146, 62, 50, 85, 168, 188, 50, 110, 192, 56, 36, 85, 109, 252])), SecretKey(Scalar([139, 104, 160, 30, 13, 106, 4, 12, 179, 111, 251, 46, 150, 162, 78, 186, 181, 114, 140, 171, 138, 81, 68, 147, 220, 83, 69, 187, 196, 16, 85, 9])));
/// AHE: boa1xrahe00m9h3495xz9ht4s8n6yq4w4p7d5zws8xkfa03ed44jlly6uxk85pq
static immutable AHE = KeyPair(PublicKey(Point([251, 124, 189, 251, 45, 227, 82, 208, 194, 45, 215, 88, 30, 122, 32, 42, 234, 135, 205, 160, 157, 3, 154, 201, 235, 227, 150, 214, 178, 255, 201, 174])), SecretKey(Scalar([218, 111, 19, 125, 157, 91, 178, 50, 115, 120, 196, 128, 5, 64, 52, 78, 153, 229, 111, 41, 127, 86, 59, 135, 24, 6, 189, 192, 106, 80, 246, 3])));
/// AHF: boa1xzahf00qwpwa3rcqccx63fj9d9s49xvxvxvtk05kgt58gavqtdpl6hk2tl6
static immutable AHF = KeyPair(PublicKey(Point([187, 116, 189, 224, 112, 93, 216, 143, 0, 198, 13, 168, 166, 69, 105, 97, 82, 153, 134, 97, 152, 187, 62, 150, 66, 232, 116, 117, 128, 91, 67, 253])), SecretKey(Scalar([83, 86, 36, 97, 114, 88, 61, 98, 255, 158, 142, 35, 160, 228, 166, 243, 245, 198, 109, 219, 44, 161, 79, 82, 27, 223, 211, 114, 150, 183, 235, 9])));
/// AHG: boa1xqahg00hmrr0acq0z0yskr9kxad73qdqdnkmrwx6urnznutf3s4vupwdf8y
static immutable AHG = KeyPair(PublicKey(Point([59, 116, 61, 247, 216, 198, 254, 224, 15, 19, 201, 11, 12, 182, 55, 91, 232, 129, 160, 108, 237, 177, 184, 218, 224, 230, 41, 241, 105, 140, 42, 206])), SecretKey(Scalar([125, 204, 19, 167, 192, 252, 154, 240, 137, 14, 179, 209, 162, 171, 241, 219, 170, 64, 163, 107, 145, 119, 164, 192, 33, 228, 191, 44, 77, 197, 147, 6])));
/// AHH: boa1xrahh0003lsda4dvezwhl7mxrcxsy6ueqjln0cdt09h23c4rg3spz48e55u
static immutable AHH = KeyPair(PublicKey(Point([251, 123, 189, 239, 143, 224, 222, 213, 172, 200, 157, 127, 251, 102, 30, 13, 2, 107, 153, 4, 191, 55, 225, 171, 121, 110, 168, 226, 163, 68, 96, 17])), SecretKey(Scalar([170, 255, 189, 19, 119, 14, 107, 19, 252, 175, 123, 16, 40, 6, 92, 149, 100, 103, 25, 187, 136, 140, 54, 119, 116, 123, 251, 44, 248, 203, 215, 9])));
/// AHJ: boa1xrahj00aptddrl46y3u7fmqd45q03mh4p5kjqf7uffrg6agm6ymag5akrap
static immutable AHJ = KeyPair(PublicKey(Point([251, 121, 61, 253, 10, 218, 209, 254, 186, 36, 121, 228, 236, 13, 173, 0, 248, 238, 245, 13, 45, 32, 39, 220, 74, 70, 141, 117, 27, 209, 55, 212])), SecretKey(Scalar([154, 7, 216, 158, 119, 242, 53, 121, 164, 226, 30, 75, 66, 201, 127, 250, 235, 132, 22, 89, 136, 248, 200, 73, 42, 127, 7, 140, 61, 236, 14, 11])));
/// AHK: boa1xzahk00gp6yw52tt4kplcr0arsjv73hev7pwj573hs9z0l5gvzd8gktxse8
static immutable AHK = KeyPair(PublicKey(Point([187, 123, 61, 232, 14, 136, 234, 41, 107, 173, 131, 252, 13, 253, 28, 36, 207, 70, 249, 103, 130, 233, 83, 209, 188, 10, 39, 254, 136, 96, 154, 116])), SecretKey(Scalar([10, 152, 9, 84, 15, 158, 54, 40, 150, 234, 101, 80, 17, 131, 214, 102, 8, 68, 97, 181, 72, 93, 245, 76, 215, 177, 103, 39, 62, 125, 243, 6])));
/// AHL: boa1xpahl00m98gq4nhztw7g0gpqx7kcdvqnz87vyajrt0sr25ucygv5wk5amxl
static immutable AHL = KeyPair(PublicKey(Point([123, 127, 189, 251, 41, 208, 10, 206, 226, 91, 188, 135, 160, 32, 55, 173, 134, 176, 19, 17, 252, 194, 118, 67, 91, 224, 53, 83, 152, 34, 25, 71])), SecretKey(Scalar([144, 131, 52, 17, 77, 64, 171, 94, 102, 212, 98, 214, 240, 245, 149, 1, 131, 13, 235, 231, 44, 185, 239, 91, 171, 33, 133, 96, 39, 109, 73, 0])));
/// AHM: boa1xpahm00dpsl6aznkcmxvgkup997fglgps654k4dshu36cf725z0uu6wr59a
static immutable AHM = KeyPair(PublicKey(Point([123, 125, 189, 237, 12, 63, 174, 138, 118, 198, 204, 196, 91, 129, 41, 124, 148, 125, 1, 134, 169, 91, 85, 176, 191, 35, 172, 39, 202, 160, 159, 206])), SecretKey(Scalar([217, 255, 33, 128, 0, 239, 153, 58, 21, 236, 103, 190, 200, 199, 103, 101, 65, 252, 251, 199, 167, 18, 247, 69, 34, 236, 139, 91, 213, 58, 161, 12])));
/// AHN: boa1xqahn00dr3zjnravx0u98mv2j0xpm446x5s5hk82v2jt8hz8fxcc6gs36wv
static immutable AHN = KeyPair(PublicKey(Point([59, 121, 189, 237, 28, 69, 41, 143, 172, 51, 248, 83, 237, 138, 147, 204, 29, 214, 186, 53, 33, 75, 216, 234, 98, 164, 179, 220, 71, 73, 177, 141])), SecretKey(Scalar([22, 194, 83, 4, 72, 91, 29, 16, 54, 246, 60, 188, 248, 160, 33, 56, 1, 251, 25, 109, 153, 71, 98, 245, 178, 55, 221, 231, 38, 240, 72, 8])));
/// AHP: boa1xzahp00kv30vx0x0w75snlsh4ca38ll6lfarpaafldjr4mad08npxgldxrj
static immutable AHP = KeyPair(PublicKey(Point([187, 112, 189, 246, 100, 94, 195, 60, 207, 119, 169, 9, 254, 23, 174, 59, 19, 255, 250, 250, 122, 48, 247, 169, 251, 100, 58, 239, 173, 121, 230, 19])), SecretKey(Scalar([63, 45, 63, 65, 219, 122, 105, 177, 206, 246, 163, 104, 60, 194, 20, 67, 226, 84, 179, 240, 61, 208, 60, 74, 233, 100, 251, 228, 6, 231, 138, 6])));
/// AHQ: boa1xqahq007yrhs4w2etqcepq55g8h4th9tpwz6n2czugnhc7kl9t2wzd823cs
static immutable AHQ = KeyPair(PublicKey(Point([59, 112, 61, 254, 32, 239, 10, 185, 89, 88, 49, 144, 130, 148, 65, 239, 85, 220, 171, 11, 133, 169, 171, 2, 226, 39, 124, 122, 223, 42, 212, 225])), SecretKey(Scalar([235, 188, 146, 39, 249, 245, 188, 130, 70, 13, 251, 104, 158, 25, 3, 45, 191, 233, 168, 141, 22, 255, 47, 30, 164, 8, 178, 127, 61, 133, 109, 9])));
/// AHR: boa1xpahr0003g8ns4fya8nkpkjhgr7sad8gsmk6wt8qk9qrsf7xl7f8uchl306
static immutable AHR = KeyPair(PublicKey(Point([123, 113, 189, 239, 138, 15, 56, 85, 36, 233, 231, 96, 218, 87, 64, 253, 14, 180, 232, 134, 237, 167, 44, 224, 177, 64, 56, 39, 198, 255, 146, 126])), SecretKey(Scalar([115, 22, 45, 22, 106, 12, 220, 94, 57, 139, 162, 139, 72, 126, 0, 26, 65, 117, 238, 84, 11, 254, 113, 173, 196, 224, 64, 118, 135, 97, 217, 10])));
/// AHS: boa1xzahs006qd04w9dl8pymm62s8v58m5zxlc7nt9hmxhuxpv6nga27z9k9a99
static immutable AHS = KeyPair(PublicKey(Point([187, 120, 61, 250, 3, 95, 87, 21, 191, 56, 73, 189, 233, 80, 59, 40, 125, 208, 70, 254, 61, 53, 150, 251, 53, 248, 96, 179, 83, 71, 85, 225])), SecretKey(Scalar([191, 2, 24, 222, 146, 222, 198, 221, 51, 58, 79, 217, 180, 181, 220, 71, 23, 211, 221, 155, 138, 103, 23, 130, 12, 40, 255, 144, 22, 233, 9, 9])));
/// AHT: boa1xqaht00dp79y0s0j0l6xg4487qhx0mfl8j5x0d2d5n9vchjrvns5cpa8dl4
static immutable AHT = KeyPair(PublicKey(Point([59, 117, 189, 237, 15, 138, 71, 193, 242, 127, 244, 100, 86, 167, 240, 46, 103, 237, 63, 60, 168, 103, 181, 77, 164, 202, 204, 94, 67, 100, 225, 76])), SecretKey(Scalar([250, 220, 88, 47, 232, 69, 185, 155, 181, 15, 228, 155, 228, 39, 78, 249, 161, 249, 220, 211, 231, 157, 28, 77, 14, 182, 243, 87, 24, 170, 19, 2])));
/// AHU: boa1xrahu00sx0ken2y0sracl7d0lsve28vd2qrzpje7u3c9z2fykhduw9usspz
static immutable AHU = KeyPair(PublicKey(Point([251, 126, 61, 240, 51, 237, 153, 168, 143, 128, 251, 143, 249, 175, 252, 25, 149, 29, 141, 80, 6, 32, 203, 62, 228, 112, 81, 41, 36, 181, 219, 199])), SecretKey(Scalar([239, 9, 76, 158, 155, 175, 172, 110, 60, 241, 230, 163, 64, 1, 19, 180, 238, 231, 103, 62, 74, 177, 92, 34, 101, 142, 98, 227, 37, 208, 170, 0])));
/// AHV: boa1xqahv000enu7v29hl8axtvhrat3fquluacps6stth4gyp2gekmm27ffjxtq
static immutable AHV = KeyPair(PublicKey(Point([59, 118, 61, 239, 204, 249, 230, 40, 183, 249, 250, 101, 178, 227, 234, 226, 144, 115, 252, 238, 3, 13, 65, 107, 189, 80, 64, 169, 25, 182, 246, 175])), SecretKey(Scalar([42, 26, 226, 209, 136, 197, 96, 178, 150, 232, 81, 34, 212, 33, 80, 130, 194, 86, 238, 19, 27, 146, 159, 170, 225, 130, 73, 95, 175, 78, 182, 3])));
/// AHW: boa1xqahw00ufpkv6cyx3qqyu0736ehgjsffgucc5aqspavzpmuzmgfvjs002g8
static immutable AHW = KeyPair(PublicKey(Point([59, 119, 61, 252, 72, 108, 205, 96, 134, 136, 0, 78, 63, 209, 214, 110, 137, 65, 41, 71, 49, 138, 116, 16, 15, 88, 32, 239, 130, 218, 18, 201])), SecretKey(Scalar([51, 105, 222, 63, 94, 109, 244, 215, 23, 163, 143, 98, 178, 1, 183, 110, 148, 171, 136, 122, 48, 195, 41, 22, 181, 134, 230, 171, 23, 176, 125, 4])));
/// AHX: boa1xpahx00nytgpfdjg70x2u747zutyc4eh8t7ffwx70hse2nkf558xvfdk8cv
static immutable AHX = KeyPair(PublicKey(Point([123, 115, 61, 243, 34, 208, 20, 182, 72, 243, 204, 174, 122, 190, 23, 22, 76, 87, 55, 58, 252, 148, 184, 222, 125, 225, 149, 78, 201, 165, 14, 102])), SecretKey(Scalar([41, 195, 207, 66, 29, 197, 40, 48, 240, 77, 246, 178, 189, 140, 226, 123, 35, 119, 252, 30, 40, 85, 152, 231, 137, 77, 7, 243, 161, 129, 11, 14])));
/// AHY: boa1xqahy000xwu0f92tk98cdgpeqnq2zqj4fh24k3u8y4was6pqtcqtgvqfn43
static immutable AHY = KeyPair(PublicKey(Point([59, 114, 61, 239, 51, 184, 244, 149, 75, 177, 79, 134, 160, 57, 4, 192, 161, 2, 85, 77, 213, 91, 71, 135, 37, 93, 216, 104, 32, 94, 0, 180])), SecretKey(Scalar([160, 70, 89, 19, 158, 247, 160, 207, 127, 14, 143, 11, 55, 50, 35, 214, 185, 69, 210, 113, 175, 197, 97, 231, 59, 56, 103, 194, 35, 146, 134, 7])));
/// AHZ: boa1xzahz00l0gc4t3xtrgcg0vlfpccprj33rtdnkkl8v8slzq9fcurjq4wl8nx
static immutable AHZ = KeyPair(PublicKey(Point([187, 113, 61, 255, 122, 49, 85, 196, 203, 26, 48, 135, 179, 233, 14, 48, 17, 202, 49, 26, 219, 59, 91, 231, 97, 225, 241, 0, 169, 199, 7, 32])), SecretKey(Scalar([6, 236, 226, 170, 230, 164, 71, 112, 239, 82, 115, 40, 107, 10, 154, 157, 141, 102, 168, 68, 219, 128, 152, 245, 155, 152, 109, 126, 144, 215, 165, 14])));
/// AJA: boa1xpaja00uzs2xm44yavlz2d3u7p4fr8k8utvmylc8vxjuy7xuw9wgs92vesm
static immutable AJA = KeyPair(PublicKey(Point([123, 46, 189, 252, 20, 20, 109, 214, 164, 235, 62, 37, 54, 60, 240, 106, 145, 158, 199, 226, 217, 178, 127, 7, 97, 165, 194, 120, 220, 113, 92, 136])), SecretKey(Scalar([72, 105, 25, 35, 182, 241, 72, 23, 117, 139, 27, 171, 209, 152, 88, 213, 109, 125, 71, 3, 221, 53, 76, 143, 103, 5, 25, 192, 118, 51, 182, 10])));
/// AJC: boa1xrajc004xxdg8mugukt523updl32pcl65jm62h7au58rzs5nf4wjg34lee4
static immutable AJC = KeyPair(PublicKey(Point([251, 44, 61, 245, 49, 154, 131, 239, 136, 229, 151, 69, 71, 129, 111, 226, 160, 227, 250, 164, 183, 165, 95, 221, 229, 14, 49, 66, 147, 77, 93, 36])), SecretKey(Scalar([81, 69, 155, 19, 238, 101, 179, 52, 191, 136, 59, 83, 183, 237, 119, 214, 145, 191, 165, 227, 41, 210, 2, 85, 24, 64, 76, 207, 232, 114, 154, 12])));
/// AJD: boa1xzajd00qmkfnp7jflgr26vsun90rf099nw3jslyq35scxty763lzjhyn936
static immutable AJD = KeyPair(PublicKey(Point([187, 38, 189, 224, 221, 147, 48, 250, 73, 250, 6, 173, 50, 28, 153, 94, 52, 188, 165, 155, 163, 40, 124, 128, 141, 33, 131, 44, 158, 212, 126, 41])), SecretKey(Scalar([62, 170, 192, 13, 69, 56, 100, 247, 34, 217, 79, 170, 175, 91, 147, 2, 7, 212, 182, 214, 61, 233, 69, 242, 215, 181, 201, 54, 222, 41, 16, 13])));
/// AJE: boa1xpaje0065d3ggv7x3zf0p08t25adeq6wslnd42jstet97dzf7czs7xk5hsy
static immutable AJE = KeyPair(PublicKey(Point([123, 44, 189, 250, 163, 98, 132, 51, 198, 136, 146, 240, 188, 235, 85, 58, 220, 131, 78, 135, 230, 218, 170, 80, 94, 86, 95, 52, 73, 246, 5, 15])), SecretKey(Scalar([124, 202, 38, 145, 245, 107, 71, 219, 186, 219, 127, 242, 108, 9, 177, 131, 26, 145, 99, 116, 161, 9, 204, 71, 228, 161, 219, 3, 122, 212, 57, 8])));
/// AJF: boa1xzajf0022lhcvur4n9xvkqjc2yy506reue9t86uwfgwg03pj0vy4j77ec34
static immutable AJF = KeyPair(PublicKey(Point([187, 36, 189, 234, 87, 239, 134, 112, 117, 153, 76, 203, 2, 88, 81, 9, 71, 232, 121, 230, 74, 179, 235, 142, 74, 28, 135, 196, 50, 123, 9, 89])), SecretKey(Scalar([254, 21, 131, 203, 236, 45, 214, 57, 6, 111, 26, 20, 247, 84, 177, 210, 205, 44, 146, 104, 224, 66, 9, 64, 234, 12, 16, 138, 160, 152, 97, 12])));
/// AJG: boa1xqajg00xs7k4ae06l9qhrycsukvqm8su2p94d99su38w7mvtf70q2tnalyf
static immutable AJG = KeyPair(PublicKey(Point([59, 36, 61, 230, 135, 173, 94, 229, 250, 249, 65, 113, 147, 16, 229, 152, 13, 158, 28, 80, 75, 86, 148, 176, 228, 78, 239, 109, 139, 79, 158, 5])), SecretKey(Scalar([187, 244, 196, 33, 19, 55, 249, 37, 116, 161, 146, 219, 118, 118, 135, 248, 20, 46, 17, 247, 25, 229, 14, 92, 17, 254, 185, 77, 81, 0, 189, 0])));
/// AJH: boa1xrajh00as4l8u8jrvjtfqleae59nrzt8vnjpxf8ys6uzzmyarygfc7j2xx5
static immutable AJH = KeyPair(PublicKey(Point([251, 43, 189, 253, 133, 126, 126, 30, 67, 100, 150, 144, 127, 61, 205, 11, 49, 137, 103, 100, 228, 19, 36, 228, 134, 184, 33, 108, 157, 25, 16, 156])), SecretKey(Scalar([204, 90, 128, 217, 17, 26, 218, 86, 166, 37, 4, 10, 166, 249, 149, 64, 195, 124, 99, 240, 72, 166, 223, 121, 103, 211, 176, 162, 76, 70, 176, 8])));
/// AJJ: boa1xpajj00c0nzney2t9aw8pwed7pscg4a8psccmgy50h5udk0y4nv86yxwlxd
static immutable AJJ = KeyPair(PublicKey(Point([123, 41, 61, 248, 124, 197, 60, 145, 75, 47, 92, 112, 187, 45, 240, 97, 132, 87, 167, 12, 49, 141, 160, 148, 125, 233, 198, 217, 228, 172, 216, 125])), SecretKey(Scalar([94, 54, 28, 183, 54, 141, 211, 194, 220, 203, 211, 73, 19, 37, 254, 245, 145, 94, 14, 205, 90, 117, 110, 245, 233, 182, 22, 176, 177, 186, 40, 12])));
/// AJK: boa1xpajk00ecv3smhvxlfkvtts42vuxj92t5v0kazekwv80w3pye5hpu7huc7r
static immutable AJK = KeyPair(PublicKey(Point([123, 43, 61, 249, 195, 35, 13, 221, 134, 250, 108, 197, 174, 21, 83, 56, 105, 21, 75, 163, 31, 110, 139, 54, 115, 14, 247, 68, 36, 205, 46, 30])), SecretKey(Scalar([122, 113, 144, 202, 131, 189, 253, 183, 61, 246, 47, 48, 165, 169, 191, 41, 247, 94, 3, 5, 69, 29, 220, 57, 19, 97, 133, 181, 123, 135, 242, 13])));
/// AJL: boa1xpajl003sm3vk7q6s82jpugn5hqn4wam2ezys00xtskev0fmsh7pvd68t3e
static immutable AJL = KeyPair(PublicKey(Point([123, 47, 189, 241, 134, 226, 203, 120, 26, 129, 213, 32, 241, 19, 165, 193, 58, 187, 187, 86, 68, 72, 61, 230, 92, 45, 150, 61, 59, 133, 252, 22])), SecretKey(Scalar([157, 173, 39, 61, 117, 89, 109, 137, 42, 213, 248, 193, 107, 136, 100, 31, 106, 111, 57, 136, 11, 108, 141, 156, 174, 201, 72, 140, 168, 41, 87, 15])));
/// AJM: boa1xrajm00nnftn30d5765ljpmknl3n6zm3cu5sxj0cdtyftgrcwat6wm46yj8
static immutable AJM = KeyPair(PublicKey(Point([251, 45, 189, 243, 154, 87, 56, 189, 180, 246, 169, 249, 7, 118, 159, 227, 61, 11, 113, 199, 41, 3, 73, 248, 106, 200, 149, 160, 120, 119, 87, 167])), SecretKey(Scalar([230, 119, 7, 168, 215, 186, 245, 153, 32, 190, 238, 214, 38, 43, 248, 116, 129, 12, 1, 28, 196, 151, 162, 143, 9, 63, 154, 151, 36, 77, 239, 11])));
/// AJN: boa1xpajn00n55ds2u40katj92laydcawnf82afr0lcufcget0nf0sykzkpvfn5
static immutable AJN = KeyPair(PublicKey(Point([123, 41, 189, 243, 165, 27, 5, 114, 175, 183, 87, 34, 171, 253, 35, 113, 215, 77, 39, 87, 82, 55, 255, 28, 78, 17, 149, 190, 105, 124, 9, 97])), SecretKey(Scalar([101, 227, 237, 152, 12, 38, 95, 10, 72, 48, 193, 103, 82, 185, 223, 207, 24, 75, 214, 171, 228, 119, 2, 33, 169, 44, 227, 145, 149, 8, 221, 3])));
/// AJP: boa1xpajp00l0fuhanm76gl293v2cwav8s2pmm8z8mfln2dqqj0ccyua29kcpea
static immutable AJP = KeyPair(PublicKey(Point([123, 32, 189, 255, 122, 121, 126, 207, 126, 210, 62, 162, 197, 138, 195, 186, 195, 193, 65, 222, 206, 35, 237, 63, 154, 154, 0, 73, 248, 193, 57, 213])), SecretKey(Scalar([152, 213, 32, 101, 48, 35, 205, 13, 239, 76, 172, 90, 145, 110, 36, 62, 120, 66, 120, 20, 191, 98, 154, 231, 118, 170, 107, 243, 95, 3, 88, 1])));
/// AJQ: boa1xpajq00cel4r6zmmsce357aeftrlhm6ny96caatcwtumsuh5qqnpxncjk3x
static immutable AJQ = KeyPair(PublicKey(Point([123, 32, 61, 248, 207, 234, 61, 11, 123, 134, 51, 26, 123, 185, 74, 199, 251, 239, 83, 33, 117, 142, 245, 120, 114, 249, 184, 114, 244, 0, 38, 19])), SecretKey(Scalar([224, 161, 189, 84, 1, 103, 78, 209, 63, 176, 87, 122, 39, 226, 175, 230, 212, 247, 72, 97, 192, 248, 0, 232, 204, 193, 194, 199, 222, 22, 220, 4])));
/// AJR: boa1xzajr007zyrg2v3p709zxc7p2592pk8wgxdygx0kuhxn76s683htg8hyga5
static immutable AJR = KeyPair(PublicKey(Point([187, 33, 189, 254, 17, 6, 133, 50, 33, 243, 202, 35, 99, 193, 85, 10, 160, 216, 238, 65, 154, 68, 25, 246, 229, 205, 63, 106, 26, 60, 110, 180])), SecretKey(Scalar([43, 10, 179, 108, 117, 119, 226, 3, 30, 23, 152, 99, 29, 237, 168, 209, 62, 179, 100, 222, 50, 159, 243, 0, 93, 218, 206, 170, 85, 58, 68, 13])));
/// AJS: boa1xqajs00sdqw0awqujymf4jqggj63r9tgs5gj79zrc8tckt07tytgzpnl7z7
static immutable AJS = KeyPair(PublicKey(Point([59, 40, 61, 240, 104, 28, 254, 184, 28, 145, 54, 154, 200, 8, 68, 181, 17, 149, 104, 133, 17, 47, 20, 67, 193, 215, 139, 45, 254, 89, 22, 129])), SecretKey(Scalar([14, 31, 227, 24, 166, 76, 142, 125, 101, 114, 166, 134, 186, 250, 243, 54, 39, 231, 86, 185, 63, 76, 245, 47, 101, 57, 251, 148, 134, 161, 7, 7])));
/// AJT: boa1xpajt006kjjpxsay2kt8cq8um8gvll09x8gxm2mxnlya95m4t9gvwpcmqpn
static immutable AJT = KeyPair(PublicKey(Point([123, 37, 189, 250, 180, 164, 19, 67, 164, 85, 150, 124, 0, 252, 217, 208, 207, 253, 229, 49, 208, 109, 171, 102, 159, 201, 210, 211, 117, 89, 80, 199])), SecretKey(Scalar([96, 206, 82, 192, 28, 174, 170, 133, 82, 186, 207, 43, 117, 114, 48, 198, 138, 88, 50, 110, 254, 166, 215, 202, 208, 134, 67, 77, 39, 253, 204, 1])));
/// AJU: boa1xpaju000tmahg3t6xqct4wyzhqkw0gcvuxc94xxqhd9wv0wf985ej66ny23
static immutable AJU = KeyPair(PublicKey(Point([123, 46, 61, 239, 94, 251, 116, 69, 122, 48, 48, 186, 184, 130, 184, 44, 231, 163, 12, 225, 176, 90, 152, 192, 187, 74, 230, 61, 201, 41, 233, 153])), SecretKey(Scalar([149, 226, 182, 182, 54, 117, 150, 216, 104, 194, 201, 85, 238, 105, 0, 166, 103, 184, 211, 13, 30, 227, 190, 35, 28, 191, 155, 64, 240, 206, 222, 1])));
/// AJV: boa1xqajv00k5ky6r8grqv95t42nf2a8j5epqw63z0527rpfyh0urruwwcgm34k
static immutable AJV = KeyPair(PublicKey(Point([59, 38, 61, 246, 165, 137, 161, 157, 3, 3, 11, 69, 213, 83, 74, 186, 121, 83, 33, 3, 181, 17, 62, 138, 240, 194, 146, 93, 252, 24, 248, 231])), SecretKey(Scalar([62, 4, 202, 242, 242, 159, 101, 164, 170, 96, 91, 34, 96, 15, 141, 24, 101, 97, 157, 170, 15, 179, 159, 5, 158, 177, 207, 11, 35, 26, 235, 9])));
/// AJW: boa1xzajw004jxtk95k3ylwjl06a43ya0n6qgew3jmrcvlej4hu3hc5wga47mvk
static immutable AJW = KeyPair(PublicKey(Point([187, 39, 61, 245, 145, 151, 98, 210, 209, 39, 221, 47, 191, 93, 172, 73, 215, 207, 64, 70, 93, 25, 108, 120, 103, 243, 42, 223, 145, 190, 40, 228])), SecretKey(Scalar([236, 140, 223, 188, 195, 83, 198, 194, 245, 220, 153, 245, 129, 53, 129, 155, 83, 142, 35, 94, 8, 151, 105, 149, 203, 199, 233, 72, 30, 208, 121, 8])));
/// AJX: boa1xpajx00g9taukd4ultw4vtgx374z352a5xqw995j6fxldvwulgzrvqmux2y
static immutable AJX = KeyPair(PublicKey(Point([123, 35, 61, 232, 42, 251, 203, 54, 188, 250, 221, 86, 45, 6, 143, 170, 40, 209, 93, 161, 128, 226, 150, 146, 210, 77, 246, 177, 220, 250, 4, 54])), SecretKey(Scalar([54, 182, 252, 75, 65, 178, 221, 131, 147, 131, 62, 28, 76, 6, 174, 17, 28, 57, 38, 251, 24, 36, 231, 232, 139, 180, 43, 20, 33, 25, 173, 13])));
/// AJY: boa1xqajy00mw7srgagzr9cudr0atx07apaafryg0zxkvgs62cedjucgjcqqqv0
static immutable AJY = KeyPair(PublicKey(Point([59, 34, 61, 251, 119, 160, 52, 117, 2, 25, 113, 198, 141, 253, 89, 159, 238, 135, 189, 72, 200, 135, 136, 214, 98, 33, 165, 99, 45, 151, 48, 137])), SecretKey(Scalar([53, 134, 140, 251, 208, 209, 11, 165, 99, 208, 192, 44, 225, 62, 32, 19, 16, 212, 32, 17, 79, 21, 166, 154, 162, 165, 84, 48, 53, 192, 173, 5])));
/// AJZ: boa1xzajz00ncj29vuj873nswuej9446mnljg47zm8gsmfjye56dhqr9vt80l0d
static immutable AJZ = KeyPair(PublicKey(Point([187, 33, 61, 243, 196, 148, 86, 114, 71, 244, 103, 7, 115, 50, 45, 107, 173, 207, 242, 69, 124, 45, 157, 16, 218, 100, 76, 211, 77, 184, 6, 86])), SecretKey(Scalar([200, 130, 96, 32, 23, 227, 202, 244, 11, 224, 41, 111, 197, 8, 239, 82, 149, 227, 41, 223, 157, 43, 76, 62, 183, 69, 170, 32, 223, 72, 43, 8])));
/// AKA: boa1xqaka00xj0s6cpdwaglx2ne2fg5enwan8mjte9zm64sf2uqtt5rkkg25ucp
static immutable AKA = KeyPair(PublicKey(Point([59, 110, 189, 230, 147, 225, 172, 5, 174, 234, 62, 101, 79, 42, 74, 41, 153, 187, 179, 62, 228, 188, 148, 91, 213, 96, 149, 112, 11, 93, 7, 107])), SecretKey(Scalar([77, 242, 109, 14, 79, 32, 64, 251, 82, 147, 226, 193, 220, 26, 175, 165, 188, 252, 204, 70, 182, 35, 155, 100, 121, 36, 190, 176, 67, 56, 21, 8])));
/// AKC: boa1xzakc00zpe0j9pdxv7fdrpfnl5prpfpddneg9um3zzdpw5qdrm6qkyce4ea
static immutable AKC = KeyPair(PublicKey(Point([187, 108, 61, 226, 14, 95, 34, 133, 166, 103, 146, 209, 133, 51, 253, 2, 48, 164, 45, 108, 242, 130, 243, 113, 16, 154, 23, 80, 13, 30, 244, 11])), SecretKey(Scalar([235, 166, 216, 133, 186, 104, 216, 149, 60, 22, 9, 189, 219, 236, 11, 159, 31, 142, 40, 250, 189, 217, 11, 73, 158, 70, 86, 106, 29, 25, 122, 9])));
/// AKD: boa1xqakd005wz3ch6xgu7p60y9tfhwxn7wfwvzdegnprxlvy245472sjl3g9v7
static immutable AKD = KeyPair(PublicKey(Point([59, 102, 189, 244, 112, 163, 139, 232, 200, 231, 131, 167, 144, 171, 77, 220, 105, 249, 201, 115, 4, 220, 162, 97, 25, 190, 194, 42, 180, 175, 149, 9])), SecretKey(Scalar([27, 178, 187, 102, 26, 16, 48, 108, 165, 10, 192, 183, 206, 143, 47, 33, 228, 123, 160, 239, 206, 191, 73, 2, 47, 5, 211, 113, 158, 101, 55, 11])));
/// AKE: boa1xqake0023eg5cnwl9rrw5rrs0x4vucqrwrqxazuu5xq4skymga4wktr363e
static immutable AKE = KeyPair(PublicKey(Point([59, 108, 189, 234, 142, 81, 76, 77, 223, 40, 198, 234, 12, 112, 121, 170, 206, 96, 3, 112, 192, 110, 139, 156, 161, 129, 88, 88, 155, 71, 106, 235])), SecretKey(Scalar([186, 129, 181, 122, 35, 240, 7, 112, 136, 115, 17, 4, 9, 161, 58, 145, 66, 149, 174, 2, 240, 224, 211, 167, 206, 209, 248, 186, 53, 78, 174, 2])));
/// AKF: boa1xzakf00kzvf7rs3zknkfxjmthkhv2raqv4tuf3d2dlcvd7sxm7pfx7rnq70
static immutable AKF = KeyPair(PublicKey(Point([187, 100, 189, 246, 19, 19, 225, 194, 34, 180, 236, 147, 75, 107, 189, 174, 197, 15, 160, 101, 87, 196, 197, 170, 111, 240, 198, 250, 6, 223, 130, 147])), SecretKey(Scalar([251, 232, 121, 86, 211, 72, 24, 18, 123, 59, 198, 21, 153, 225, 91, 11, 10, 151, 5, 22, 131, 61, 10, 80, 138, 138, 164, 88, 235, 140, 104, 10])));
/// AKG: boa1xzakg008pxvxxlpsl29ws38syhr8jjqc00es425q7mfjrp5jaaxcugsz6gc
static immutable AKG = KeyPair(PublicKey(Point([187, 100, 61, 231, 9, 152, 99, 124, 48, 250, 138, 232, 68, 240, 37, 198, 121, 72, 24, 123, 243, 10, 170, 128, 246, 211, 33, 134, 146, 239, 77, 142])), SecretKey(Scalar([170, 28, 59, 157, 153, 138, 69, 78, 157, 157, 164, 54, 6, 236, 199, 106, 249, 99, 41, 35, 112, 223, 33, 186, 15, 53, 79, 113, 210, 178, 112, 6])));
/// AKH: boa1xzakh00sqwzelduwnecke4jmchg5qu8kjl0hqq4ff5f5lh69zgjrkqvgcpa
static immutable AKH = KeyPair(PublicKey(Point([187, 107, 189, 240, 3, 133, 159, 183, 142, 158, 113, 108, 214, 91, 197, 209, 64, 112, 246, 151, 223, 112, 2, 169, 77, 19, 79, 223, 69, 18, 36, 59])), SecretKey(Scalar([121, 154, 66, 198, 40, 64, 154, 133, 76, 250, 170, 215, 187, 156, 248, 222, 72, 34, 32, 235, 34, 227, 241, 233, 45, 35, 56, 178, 210, 9, 107, 0])));
/// AKJ: boa1xqakj00526f4n749phcyl3y2rrczgte0cayfvudn9y8x4qwq27sv63xe5n3
static immutable AKJ = KeyPair(PublicKey(Point([59, 105, 61, 244, 86, 147, 89, 250, 165, 13, 240, 79, 196, 138, 24, 240, 36, 47, 47, 199, 72, 150, 113, 179, 41, 14, 106, 129, 192, 87, 160, 205])), SecretKey(Scalar([76, 149, 62, 148, 37, 148, 177, 243, 203, 28, 32, 134, 60, 237, 28, 90, 50, 98, 114, 168, 202, 168, 33, 152, 213, 64, 163, 244, 28, 10, 64, 1])));
/// AKK: boa1xpakk00fg66g259m77ln7f4mq2p6c3m7049qjq5rqzfgcmtxynjl6j708rz
static immutable AKK = KeyPair(PublicKey(Point([123, 107, 61, 233, 70, 180, 133, 80, 187, 247, 191, 63, 38, 187, 2, 131, 172, 71, 126, 125, 74, 9, 2, 131, 0, 146, 140, 109, 102, 36, 229, 253])), SecretKey(Scalar([73, 190, 247, 85, 51, 179, 245, 120, 118, 45, 89, 45, 163, 159, 125, 165, 163, 116, 20, 42, 176, 191, 227, 123, 86, 23, 96, 233, 119, 70, 19, 12])));
/// AKL: boa1xqakl0090qzp6r3c286724tkqnzc4rly9reatf92dnqn4wk0yn2y60utzcy
static immutable AKL = KeyPair(PublicKey(Point([59, 111, 189, 229, 120, 4, 29, 14, 56, 81, 245, 229, 85, 118, 4, 197, 138, 143, 228, 40, 243, 213, 164, 170, 108, 193, 58, 186, 207, 36, 212, 77])), SecretKey(Scalar([2, 139, 18, 241, 71, 35, 185, 191, 86, 65, 108, 100, 207, 81, 24, 0, 104, 3, 208, 79, 250, 231, 37, 61, 180, 60, 247, 59, 25, 111, 242, 15])));
/// AKM: boa1xqakm00h9flvx5yl3qshe9ex3mjtg4qdwc4rvp3jnxmrx0yn03dygvja2ax
static immutable AKM = KeyPair(PublicKey(Point([59, 109, 189, 247, 42, 126, 195, 80, 159, 136, 33, 124, 151, 38, 142, 228, 180, 84, 13, 118, 42, 54, 6, 50, 153, 182, 51, 60, 147, 124, 90, 68])), SecretKey(Scalar([165, 93, 172, 121, 48, 215, 163, 57, 68, 142, 204, 8, 77, 65, 21, 99, 50, 225, 95, 12, 55, 52, 97, 240, 184, 143, 114, 84, 107, 48, 156, 8])));
/// AKN: boa1xzakn00chuv97zurme337jegcvlerqv5lyc2ataujyk44zse6nvfkk35fc3
static immutable AKN = KeyPair(PublicKey(Point([187, 105, 189, 248, 191, 24, 95, 11, 131, 222, 99, 31, 75, 40, 195, 63, 145, 129, 148, 249, 48, 174, 175, 188, 145, 45, 90, 138, 25, 212, 216, 155])), SecretKey(Scalar([51, 35, 53, 229, 243, 182, 140, 17, 174, 28, 97, 211, 132, 58, 117, 44, 208, 205, 142, 250, 96, 64, 97, 106, 80, 86, 29, 243, 55, 95, 90, 14])));
/// AKP: boa1xrakp00hkhr4kqm20lka5ymvcu7ekdj7cqg5nlnfz43a2t6rjxydqzza3n9
static immutable AKP = KeyPair(PublicKey(Point([251, 96, 189, 247, 181, 199, 91, 3, 106, 127, 237, 218, 19, 108, 199, 61, 155, 54, 94, 192, 17, 73, 254, 105, 21, 99, 213, 47, 67, 145, 136, 208])), SecretKey(Scalar([28, 124, 16, 19, 233, 96, 103, 237, 107, 53, 9, 70, 242, 219, 228, 222, 47, 168, 234, 9, 222, 191, 182, 73, 233, 239, 40, 168, 30, 68, 195, 13])));
/// AKQ: boa1xqakq00yw4kj0lxw85zauu39r8cmg2a86j6ypdscstvfp6s9a4nwkmtr4vq
static immutable AKQ = KeyPair(PublicKey(Point([59, 96, 61, 228, 117, 109, 39, 252, 206, 61, 5, 222, 114, 37, 25, 241, 180, 43, 167, 212, 180, 64, 182, 24, 130, 216, 144, 234, 5, 237, 102, 235])), SecretKey(Scalar([143, 100, 134, 187, 136, 88, 59, 132, 161, 15, 233, 153, 6, 99, 48, 218, 85, 177, 57, 229, 164, 44, 147, 237, 36, 65, 81, 103, 116, 176, 192, 1])));
/// AKR: boa1xzakr00jvj4x50fa4k0fj03c7pzldfmfyc0k5gw00jmjhwgq09tqwjc2yn5
static immutable AKR = KeyPair(PublicKey(Point([187, 97, 189, 242, 100, 170, 106, 61, 61, 173, 158, 153, 62, 56, 240, 69, 246, 167, 105, 38, 31, 106, 33, 207, 124, 183, 43, 185, 0, 121, 86, 7])), SecretKey(Scalar([105, 233, 228, 109, 77, 219, 35, 2, 234, 18, 127, 58, 18, 123, 102, 180, 61, 195, 37, 152, 0, 249, 77, 107, 254, 225, 12, 131, 144, 165, 42, 8])));
/// AKS: boa1xraks00j0tda4hj2m0dg2k8gfkmulvgvhw2s98txhnjdjvhl2wmhwavw2f9
static immutable AKS = KeyPair(PublicKey(Point([251, 104, 61, 242, 122, 219, 218, 222, 74, 219, 218, 133, 88, 232, 77, 183, 207, 177, 12, 187, 149, 2, 157, 102, 188, 228, 217, 50, 255, 83, 183, 119])), SecretKey(Scalar([209, 209, 102, 14, 84, 131, 222, 142, 246, 192, 73, 179, 211, 19, 227, 155, 245, 201, 174, 180, 253, 218, 134, 114, 240, 112, 4, 111, 128, 15, 54, 12])));
/// AKT: boa1xqakt00p7a2qtzwr7e6snprc65g56x9jxe4uh86ecdnm5rsa587775w7a8m
static immutable AKT = KeyPair(PublicKey(Point([59, 101, 189, 225, 247, 84, 5, 137, 195, 246, 117, 9, 132, 120, 213, 17, 77, 24, 178, 54, 107, 203, 159, 89, 195, 103, 186, 14, 29, 161, 253, 239])), SecretKey(Scalar([233, 56, 51, 214, 153, 235, 143, 239, 83, 200, 124, 212, 65, 157, 117, 22, 238, 219, 83, 2, 14, 198, 165, 93, 94, 124, 217, 176, 117, 225, 210, 4])));
/// AKU: boa1xpaku002jgn9vkdp6dau24mc5pn6nwyg887fwj7vqy27rupagjx524ms49a
static immutable AKU = KeyPair(PublicKey(Point([123, 110, 61, 234, 146, 38, 86, 89, 161, 211, 123, 197, 87, 120, 160, 103, 169, 184, 136, 57, 252, 151, 75, 204, 1, 21, 225, 240, 61, 68, 141, 69])), SecretKey(Scalar([99, 62, 210, 193, 210, 128, 221, 6, 94, 182, 30, 78, 100, 58, 164, 189, 239, 212, 21, 223, 122, 165, 115, 170, 211, 126, 195, 191, 51, 237, 144, 7])));
/// AKV: boa1xrakv00tfz29g3zqfaljxj4g3ej7av3txs495lkrlcy89drtcgg3gvyf9tt
static immutable AKV = KeyPair(PublicKey(Point([251, 102, 61, 235, 72, 148, 84, 68, 64, 79, 127, 35, 74, 168, 142, 101, 238, 178, 43, 52, 42, 90, 126, 195, 254, 8, 114, 180, 107, 194, 17, 20])), SecretKey(Scalar([113, 115, 175, 108, 4, 27, 41, 15, 4, 37, 89, 204, 42, 121, 46, 224, 8, 43, 68, 105, 235, 123, 93, 99, 105, 182, 2, 211, 73, 214, 107, 6])));
/// AKW: boa1xpakw000rgjhqm8dwqc3fu6z6h5saaqvc238724hnc2uhx3jfajz2584sq8
static immutable AKW = KeyPair(PublicKey(Point([123, 103, 61, 239, 26, 37, 112, 108, 237, 112, 49, 20, 243, 66, 213, 233, 14, 244, 12, 194, 162, 127, 42, 183, 158, 21, 203, 154, 50, 79, 100, 37])), SecretKey(Scalar([209, 82, 147, 51, 90, 79, 39, 201, 246, 154, 90, 42, 70, 169, 164, 117, 212, 61, 206, 41, 66, 181, 181, 241, 129, 160, 36, 45, 182, 154, 241, 0])));
/// AKX: boa1xzakx000z94mr76sjgtm22yccpjn3znr6w05nsy6ua9rzf3mm53225v02tf
static immutable AKX = KeyPair(PublicKey(Point([187, 99, 61, 239, 17, 107, 177, 251, 80, 146, 23, 181, 40, 152, 192, 101, 56, 138, 99, 211, 159, 73, 192, 154, 231, 74, 49, 38, 59, 221, 34, 165])), SecretKey(Scalar([115, 127, 109, 200, 110, 41, 63, 212, 69, 238, 42, 216, 193, 6, 62, 70, 37, 167, 82, 47, 213, 82, 98, 227, 92, 130, 57, 221, 24, 190, 217, 13])));
/// AKY: boa1xqaky00w5j5v73qz7lm4t5rudeklpkj4pxwtx2uu3kd6d62sx66kzsna0jf
static immutable AKY = KeyPair(PublicKey(Point([59, 98, 61, 238, 164, 168, 207, 68, 2, 247, 247, 85, 208, 124, 110, 109, 240, 218, 85, 9, 156, 179, 43, 156, 141, 155, 166, 233, 80, 54, 181, 97])), SecretKey(Scalar([71, 109, 116, 168, 4, 221, 10, 223, 246, 92, 10, 193, 241, 11, 16, 4, 202, 255, 160, 193, 68, 59, 142, 69, 118, 71, 42, 225, 29, 117, 239, 12])));
/// AKZ: boa1xpakz00ru22f7ldksp4qw87m4dew0m7re7uey5t5fa09hzkwg6pacngh2vk
static immutable AKZ = KeyPair(PublicKey(Point([123, 97, 61, 227, 226, 148, 159, 125, 182, 128, 106, 7, 31, 219, 171, 114, 231, 239, 195, 207, 185, 146, 81, 116, 79, 94, 91, 138, 206, 70, 131, 220])), SecretKey(Scalar([98, 120, 229, 217, 78, 83, 14, 214, 132, 213, 121, 52, 161, 184, 128, 70, 2, 133, 169, 95, 31, 119, 187, 15, 179, 190, 151, 21, 252, 227, 204, 8])));
/// ALA: boa1xqala000z773858rxqgfmd3kjs80wz8z4r4ufk8g7gpmlungr2xukl25uwx
static immutable ALA = KeyPair(PublicKey(Point([59, 254, 189, 239, 23, 189, 19, 208, 227, 48, 16, 157, 182, 54, 148, 14, 247, 8, 226, 168, 235, 196, 216, 232, 242, 3, 191, 242, 104, 26, 141, 203])), SecretKey(Scalar([193, 135, 112, 105, 144, 157, 29, 248, 165, 96, 128, 211, 54, 140, 217, 81, 32, 112, 127, 47, 172, 216, 102, 158, 41, 73, 45, 107, 30, 250, 246, 6])));
/// ALC: boa1xzalc00ghm3euh3vr23apl5qs9s42f52dferevkleedp4r56yw2csmg6sdq
static immutable ALC = KeyPair(PublicKey(Point([187, 252, 61, 232, 190, 227, 158, 94, 44, 26, 163, 208, 254, 128, 129, 97, 85, 38, 138, 106, 114, 60, 178, 223, 206, 90, 26, 142, 154, 35, 149, 136])), SecretKey(Scalar([192, 84, 213, 155, 110, 183, 221, 94, 148, 227, 33, 122, 154, 239, 25, 2, 119, 97, 149, 46, 109, 199, 222, 5, 20, 50, 240, 116, 137, 222, 118, 6])));
/// ALD: boa1xzald00eraze6g7n65q26weqnufm6lu4r4fsthk6v0df2kqhfxdnyl83xww
static immutable ALD = KeyPair(PublicKey(Point([187, 246, 189, 249, 31, 69, 157, 35, 211, 213, 0, 173, 59, 32, 159, 19, 189, 127, 149, 29, 83, 5, 222, 218, 99, 218, 149, 88, 23, 73, 155, 50])), SecretKey(Scalar([244, 168, 216, 244, 25, 128, 23, 230, 52, 140, 190, 141, 254, 66, 175, 189, 66, 234, 226, 235, 239, 106, 77, 176, 146, 101, 147, 88, 13, 56, 46, 1])));
/// ALE: boa1xpale00z3uugh673r0zxgxlanpqrusfg7l7528nppsr4fgsp0443ke82yr0
static immutable ALE = KeyPair(PublicKey(Point([123, 252, 189, 226, 143, 56, 139, 235, 209, 27, 196, 100, 27, 253, 152, 64, 62, 65, 40, 247, 253, 69, 30, 97, 12, 7, 84, 162, 1, 125, 107, 27])), SecretKey(Scalar([68, 252, 96, 11, 144, 71, 99, 81, 23, 60, 84, 158, 73, 212, 38, 53, 223, 157, 181, 225, 131, 165, 139, 104, 149, 152, 150, 163, 99, 10, 61, 1])));
/// ALF: boa1xzalf00nrq57w6fle8mew4yuf76ef5gan387qzqundqutflvmdpdva79yq3
static immutable ALF = KeyPair(PublicKey(Point([187, 244, 189, 243, 24, 41, 231, 105, 63, 201, 247, 151, 84, 156, 79, 181, 148, 209, 29, 156, 79, 224, 8, 28, 155, 65, 197, 167, 236, 219, 66, 214])), SecretKey(Scalar([98, 90, 238, 78, 109, 131, 25, 147, 163, 75, 46, 189, 61, 58, 176, 132, 242, 47, 91, 224, 158, 235, 27, 230, 171, 113, 250, 49, 131, 197, 122, 0])));
/// ALG: boa1xralg006zm3y9g5t9dhja7p2gglqjhwp6d3nd09p0k4ptuq8lgq0jel8yrs
static immutable ALG = KeyPair(PublicKey(Point([251, 244, 61, 250, 22, 226, 66, 162, 139, 43, 111, 46, 248, 42, 66, 62, 9, 93, 193, 211, 99, 54, 188, 161, 125, 170, 21, 240, 7, 250, 0, 249])), SecretKey(Scalar([204, 226, 183, 210, 34, 92, 249, 135, 118, 158, 219, 109, 82, 97, 134, 116, 17, 87, 13, 62, 96, 8, 109, 153, 119, 227, 192, 31, 101, 124, 255, 13])));
/// ALH: boa1xqalh00ty5p2js4fgh03nex2sqc3c0w3wj6jlxjallyn576ww0ghuva382k
static immutable ALH = KeyPair(PublicKey(Point([59, 251, 189, 235, 37, 2, 169, 66, 169, 69, 223, 25, 228, 202, 128, 49, 28, 61, 209, 116, 181, 47, 154, 93, 255, 201, 58, 123, 78, 115, 209, 126])), SecretKey(Scalar([65, 100, 30, 66, 77, 216, 2, 160, 20, 85, 226, 238, 207, 118, 62, 27, 221, 115, 120, 60, 251, 87, 235, 214, 242, 4, 242, 46, 114, 220, 218, 15])));
/// ALJ: boa1xpalj00stvc8mqmzw2cwjjjyup4ejfrkq0uu7yqulrhwedzftkrsg5e0tpw
static immutable ALJ = KeyPair(PublicKey(Point([123, 249, 61, 240, 91, 48, 125, 131, 98, 114, 176, 233, 74, 68, 224, 107, 153, 36, 118, 3, 249, 207, 16, 28, 248, 238, 236, 180, 73, 93, 135, 4])), SecretKey(Scalar([197, 84, 152, 32, 119, 235, 169, 133, 130, 100, 233, 58, 190, 222, 10, 253, 220, 85, 2, 39, 149, 207, 29, 164, 32, 224, 136, 213, 131, 161, 87, 2])));
/// ALK: boa1xpalk00fqdjzcpxg07hjujtm5uvh64zkly7q62ppp4338aaw2jt065at2j3
static immutable ALK = KeyPair(PublicKey(Point([123, 251, 61, 233, 3, 100, 44, 4, 200, 127, 175, 46, 73, 123, 167, 25, 125, 84, 86, 249, 60, 13, 40, 33, 13, 99, 19, 247, 174, 84, 150, 253])), SecretKey(Scalar([29, 94, 190, 45, 173, 102, 18, 57, 58, 214, 138, 41, 21, 128, 248, 94, 4, 224, 196, 163, 109, 80, 196, 175, 104, 190, 92, 64, 253, 224, 48, 4])));
/// ALL: boa1xqall002jlj8q6c4j09k0mwypacu0f56lju8j2s476pp47mtjaxlzgjnyxk
static immutable ALL = KeyPair(PublicKey(Point([59, 255, 189, 234, 151, 228, 112, 107, 21, 147, 203, 103, 237, 196, 15, 113, 199, 166, 154, 252, 184, 121, 42, 21, 246, 130, 26, 251, 107, 151, 77, 241])), SecretKey(Scalar([34, 67, 89, 133, 176, 228, 13, 86, 31, 214, 22, 236, 196, 81, 109, 102, 173, 89, 167, 174, 162, 216, 101, 116, 60, 22, 125, 173, 45, 243, 184, 1])));
/// ALM: boa1xzalm004lx38u0pvhm7ugqdv5p0eztuvqp24wx4ckmvmdd67ghjwys0lpum
static immutable ALM = KeyPair(PublicKey(Point([187, 253, 189, 245, 249, 162, 126, 60, 44, 190, 253, 196, 1, 172, 160, 95, 145, 47, 140, 0, 85, 87, 26, 184, 182, 217, 182, 183, 94, 69, 228, 226])), SecretKey(Scalar([194, 106, 142, 221, 17, 43, 238, 18, 125, 168, 244, 84, 154, 70, 22, 243, 186, 196, 178, 27, 183, 144, 164, 48, 233, 159, 33, 63, 8, 174, 153, 10])));
/// ALN: boa1xpaln00v57882mlnsn5emmnsu0jwdx0w7sn5dj4yq7slqhy4pf0hz04h5r3
static immutable ALN = KeyPair(PublicKey(Point([123, 249, 189, 236, 167, 142, 117, 111, 243, 132, 233, 157, 238, 112, 227, 228, 230, 153, 238, 244, 39, 70, 202, 164, 7, 161, 240, 92, 149, 10, 95, 113])), SecretKey(Scalar([92, 102, 217, 38, 120, 30, 78, 234, 245, 128, 43, 185, 187, 47, 59, 118, 89, 26, 36, 200, 74, 124, 70, 138, 182, 23, 109, 249, 248, 93, 164, 13])));
/// ALP: boa1xpalp00zz7qnjcgl6wjyvna3dfryvtuql5m4l4vpagpw3au2cnczgx6472z
static immutable ALP = KeyPair(PublicKey(Point([123, 240, 189, 226, 23, 129, 57, 97, 31, 211, 164, 70, 79, 177, 106, 70, 70, 47, 128, 253, 55, 95, 213, 129, 234, 2, 232, 247, 138, 196, 240, 36])), SecretKey(Scalar([170, 169, 153, 141, 212, 86, 188, 85, 125, 227, 186, 1, 249, 182, 110, 211, 142, 248, 99, 53, 163, 4, 63, 138, 27, 71, 210, 45, 55, 159, 253, 2])));
/// ALQ: boa1xralq00t65vxtp478c2s6ukula3874e3zzrpq07jwyw74jqkfzmgq2kjhcs
static immutable ALQ = KeyPair(PublicKey(Point([251, 240, 61, 235, 213, 24, 101, 134, 190, 62, 21, 13, 114, 220, 255, 98, 127, 87, 49, 16, 134, 16, 63, 210, 113, 29, 234, 200, 22, 72, 182, 128])), SecretKey(Scalar([3, 39, 78, 125, 186, 146, 81, 145, 65, 106, 254, 219, 198, 232, 235, 66, 251, 229, 209, 10, 85, 121, 244, 82, 24, 197, 16, 67, 126, 58, 193, 11])));
/// ALR: boa1xpalr00xvz797thsgyedfxvz2q45p47vd4dd5vsflhh2l6hratd7602sa4l
static immutable ALR = KeyPair(PublicKey(Point([123, 241, 189, 230, 96, 188, 95, 46, 240, 65, 50, 212, 153, 130, 80, 43, 64, 215, 204, 109, 90, 218, 50, 9, 253, 238, 175, 234, 227, 234, 219, 237])), SecretKey(Scalar([159, 127, 88, 118, 240, 107, 55, 107, 215, 155, 184, 171, 201, 139, 190, 70, 5, 26, 217, 230, 36, 188, 25, 146, 103, 76, 223, 110, 228, 212, 127, 3])));
/// ALS: boa1xpals00a07er9f0mjjnzyq9uc4xdxa9pcw86f0ecxndwtr4q2lxxc8vr4c9
static immutable ALS = KeyPair(PublicKey(Point([123, 248, 61, 253, 127, 178, 50, 165, 251, 148, 166, 34, 0, 188, 197, 76, 211, 116, 161, 195, 143, 164, 191, 56, 52, 218, 229, 142, 160, 87, 204, 108])), SecretKey(Scalar([236, 175, 111, 235, 141, 230, 108, 171, 117, 175, 24, 195, 44, 29, 19, 245, 88, 56, 26, 148, 63, 144, 255, 125, 82, 228, 117, 41, 223, 31, 181, 14])));
/// ALT: boa1xralt00ewdw3z034c5kjh5cqfn6z5s0myph79w8zemqckvacr5z454t7e74
static immutable ALT = KeyPair(PublicKey(Point([251, 245, 189, 249, 115, 93, 17, 62, 53, 197, 45, 43, 211, 0, 76, 244, 42, 65, 251, 32, 111, 226, 184, 226, 206, 193, 139, 51, 184, 29, 5, 90])), SecretKey(Scalar([45, 27, 8, 19, 222, 240, 46, 36, 11, 102, 203, 62, 127, 140, 88, 217, 39, 208, 84, 255, 187, 180, 242, 134, 38, 178, 103, 187, 147, 128, 93, 15])));
/// ALU: boa1xqalu00lkkj60aawhg2aemfyvewupapjsqc7pnekp28y0dhkcn92gc6pdqt
static immutable ALU = KeyPair(PublicKey(Point([59, 254, 61, 255, 181, 165, 167, 247, 174, 186, 21, 220, 237, 36, 102, 93, 192, 244, 50, 128, 49, 224, 207, 54, 10, 142, 71, 182, 246, 196, 202, 164])), SecretKey(Scalar([42, 157, 31, 166, 119, 48, 248, 203, 143, 134, 27, 205, 247, 154, 123, 187, 154, 44, 179, 89, 41, 65, 113, 54, 68, 163, 18, 104, 164, 185, 104, 9])));
/// ALV: boa1xqalv002q7ucpezurhc23790q8mh5cqm8m820zah9p6759ssn8ud2enfdx7
static immutable ALV = KeyPair(PublicKey(Point([59, 246, 61, 234, 7, 185, 128, 228, 92, 29, 240, 168, 248, 175, 1, 247, 122, 96, 27, 62, 206, 167, 139, 183, 40, 117, 234, 22, 16, 153, 248, 213])), SecretKey(Scalar([129, 234, 149, 182, 156, 181, 254, 111, 184, 108, 45, 62, 67, 182, 225, 170, 83, 148, 68, 99, 247, 16, 67, 230, 216, 171, 64, 163, 224, 17, 104, 0])));
/// ALW: boa1xzalw00y99y3ce986p34545gq5cc7r8pq0weevck9p86ln5ssvszvjsvcys
static immutable ALW = KeyPair(PublicKey(Point([187, 247, 61, 228, 41, 73, 28, 100, 167, 208, 99, 90, 86, 136, 5, 49, 143, 12, 225, 3, 221, 156, 179, 22, 40, 79, 175, 206, 144, 131, 32, 38])), SecretKey(Scalar([19, 60, 140, 59, 119, 133, 179, 107, 8, 39, 148, 107, 55, 13, 248, 193, 122, 30, 179, 237, 187, 43, 188, 136, 27, 10, 10, 147, 179, 76, 35, 1])));
/// ALX: boa1xzalx00nvdnud8vp90ly097r8yn9k76d0lzj8d09a7ey7fca4tqkx63zphu
static immutable ALX = KeyPair(PublicKey(Point([187, 243, 61, 243, 99, 103, 198, 157, 129, 43, 254, 71, 151, 195, 57, 38, 91, 123, 77, 127, 197, 35, 181, 229, 239, 178, 79, 39, 29, 170, 193, 99])), SecretKey(Scalar([144, 13, 5, 185, 206, 238, 117, 146, 51, 129, 112, 171, 132, 214, 27, 124, 220, 11, 83, 145, 53, 54, 147, 34, 156, 255, 162, 81, 56, 165, 145, 1])));
/// ALY: boa1xzaly006xch7tqw7lkvkfpduzugczknammr7d9smr6gyxjv4l2p55lryqjt
static immutable ALY = KeyPair(PublicKey(Point([187, 242, 61, 250, 54, 47, 229, 129, 222, 253, 153, 100, 133, 188, 23, 17, 129, 90, 125, 222, 199, 230, 150, 27, 30, 144, 67, 73, 149, 250, 131, 74])), SecretKey(Scalar([207, 134, 254, 157, 72, 164, 152, 232, 89, 215, 137, 179, 5, 174, 52, 55, 251, 109, 145, 30, 174, 9, 222, 80, 221, 117, 225, 140, 248, 148, 35, 8])));
/// ALZ: boa1xralz00hrlswfeqdzp27du09u74x2r459ssccaxn4arq79u5zhu5wd8qmnd
static immutable ALZ = KeyPair(PublicKey(Point([251, 241, 61, 247, 31, 224, 228, 228, 13, 16, 85, 230, 241, 229, 231, 170, 101, 14, 180, 44, 33, 140, 116, 211, 175, 70, 15, 23, 148, 21, 249, 71])), SecretKey(Scalar([161, 116, 91, 91, 237, 130, 178, 106, 175, 2, 100, 62, 232, 196, 231, 104, 98, 156, 231, 104, 168, 5, 74, 228, 156, 134, 229, 1, 126, 210, 13, 0])));
/// AMA: boa1xrama00a8kd8w7kvz2cxauv0fvajx3nl3n3pg549tgfjafaxz7ml7ud36u2
static immutable AMA = KeyPair(PublicKey(Point([251, 190, 189, 253, 61, 154, 119, 122, 204, 18, 176, 110, 241, 143, 75, 59, 35, 70, 127, 140, 226, 20, 82, 165, 90, 19, 46, 167, 166, 23, 183, 255])), SecretKey(Scalar([106, 100, 253, 65, 88, 154, 125, 92, 252, 85, 129, 202, 124, 164, 199, 250, 95, 213, 106, 122, 200, 152, 79, 40, 9, 183, 108, 162, 224, 196, 179, 9])));
/// AMC: boa1xramc002etevydrd6an6rwsccr84t7w02l4kah5505zghe5pvyafy53hwxr
static immutable AMC = KeyPair(PublicKey(Point([251, 188, 61, 234, 202, 242, 194, 52, 109, 215, 103, 161, 186, 24, 192, 207, 85, 249, 207, 87, 235, 110, 222, 148, 125, 4, 139, 230, 129, 97, 58, 146])), SecretKey(Scalar([47, 219, 103, 147, 73, 217, 107, 126, 36, 26, 221, 135, 2, 193, 117, 38, 253, 242, 244, 160, 132, 174, 217, 168, 111, 70, 34, 196, 237, 141, 12, 10])));
/// AMD: boa1xramd00r7t32xsy0yhlzvtkrw6nyd7yaum9lnn32z0wg959q08a4zkcvaxe
static immutable AMD = KeyPair(PublicKey(Point([251, 182, 189, 227, 242, 226, 163, 64, 143, 37, 254, 38, 46, 195, 118, 166, 70, 248, 157, 230, 203, 249, 206, 42, 19, 220, 130, 208, 160, 121, 251, 81])), SecretKey(Scalar([89, 156, 41, 132, 120, 190, 24, 226, 52, 69, 103, 53, 82, 224, 34, 89, 167, 24, 8, 11, 253, 76, 131, 200, 83, 133, 88, 85, 196, 210, 162, 2])));
/// AME: boa1xzame00060a72j5372ehgyvtxy5a6nkl5uaajznuj070xusrswwxyfprymm
static immutable AME = KeyPair(PublicKey(Point([187, 188, 189, 239, 211, 251, 229, 74, 145, 242, 179, 116, 17, 139, 49, 41, 221, 78, 223, 167, 59, 217, 10, 124, 147, 252, 243, 114, 3, 131, 156, 98])), SecretKey(Scalar([48, 110, 246, 175, 185, 199, 105, 33, 196, 226, 123, 97, 150, 172, 4, 2, 46, 72, 112, 105, 5, 122, 233, 135, 240, 143, 34, 183, 12, 235, 25, 0])));
/// AMF: boa1xqamf007y7mftgw00hangjr2dndxtqm88ndwppfupckz9nmdt903zdlavrc
static immutable AMF = KeyPair(PublicKey(Point([59, 180, 189, 254, 39, 182, 149, 161, 207, 125, 251, 52, 72, 106, 108, 218, 101, 131, 103, 60, 218, 224, 133, 60, 14, 44, 34, 207, 109, 89, 95, 17])), SecretKey(Scalar([34, 15, 206, 56, 200, 230, 86, 118, 127, 148, 80, 114, 104, 236, 11, 70, 174, 103, 157, 67, 243, 247, 9, 227, 73, 26, 206, 98, 182, 176, 68, 14])));
/// AMG: boa1xqamg00h8umhrhshlukf0t2hxmx0kp938u7tumcvvjv6u3mcswqqju026dt
static immutable AMG = KeyPair(PublicKey(Point([59, 180, 61, 247, 63, 55, 113, 222, 23, 255, 44, 151, 173, 87, 54, 204, 251, 4, 177, 63, 60, 190, 111, 12, 100, 153, 174, 71, 120, 131, 128, 9])), SecretKey(Scalar([89, 250, 121, 182, 141, 64, 193, 59, 152, 133, 71, 28, 139, 23, 46, 161, 48, 174, 91, 163, 120, 96, 198, 24, 169, 109, 216, 60, 182, 150, 77, 6])));
/// AMH: boa1xzamh00lws8w054h0rum8hetdh35tcmhj55kh2tf7gzg7vq3kc892c9hmhq
static immutable AMH = KeyPair(PublicKey(Point([187, 187, 189, 255, 116, 14, 231, 210, 183, 120, 249, 179, 223, 43, 109, 227, 69, 227, 119, 149, 41, 107, 169, 105, 242, 4, 143, 48, 17, 182, 14, 85])), SecretKey(Scalar([41, 106, 8, 110, 81, 12, 5, 208, 212, 228, 178, 203, 95, 17, 106, 154, 251, 33, 58, 131, 159, 106, 146, 111, 83, 19, 44, 157, 168, 139, 181, 9])));
/// AMJ: boa1xramj00yruyaws38d46ym95q22g5zjeftvhckur32umdhnyeqlns5fvj2a9
static immutable AMJ = KeyPair(PublicKey(Point([251, 185, 61, 228, 31, 9, 215, 66, 39, 109, 116, 77, 150, 128, 82, 145, 65, 75, 41, 91, 47, 139, 112, 113, 87, 54, 219, 204, 153, 7, 231, 10])), SecretKey(Scalar([41, 129, 5, 114, 117, 99, 103, 123, 178, 180, 191, 58, 21, 100, 191, 131, 115, 65, 12, 146, 183, 36, 122, 127, 195, 99, 45, 203, 212, 131, 154, 1])));
/// AMK: boa1xqamk005su0hkesklx3m665vux6n4qz9qy73vfzy2e253xwty9ap6qlwf0s
static immutable AMK = KeyPair(PublicKey(Point([59, 187, 61, 244, 135, 31, 123, 102, 22, 249, 163, 189, 106, 140, 225, 181, 58, 128, 69, 1, 61, 22, 36, 68, 86, 85, 72, 153, 203, 33, 122, 29])), SecretKey(Scalar([155, 68, 140, 237, 16, 52, 154, 177, 248, 123, 67, 243, 49, 2, 55, 108, 44, 50, 101, 1, 38, 65, 215, 155, 158, 223, 111, 72, 163, 134, 133, 6])));
/// AML: boa1xqaml00nkluu8ez7ad7rctp7m3nudmahkzp58vfkpjlfst253y9vyd3hyuc
static immutable AML = KeyPair(PublicKey(Point([59, 191, 189, 243, 183, 249, 195, 228, 94, 235, 124, 60, 44, 62, 220, 103, 198, 239, 183, 176, 131, 67, 177, 54, 12, 190, 152, 45, 84, 137, 10, 194])), SecretKey(Scalar([137, 122, 175, 96, 33, 160, 89, 161, 251, 59, 54, 34, 61, 153, 37, 199, 159, 220, 50, 237, 153, 162, 228, 181, 104, 193, 249, 74, 142, 181, 127, 11])));
/// AMM: boa1xzamm00704580rzhjq5cd6suqrwatq9qlxwta0yhcxtl5vpamwapkh2npyy
static immutable AMM = KeyPair(PublicKey(Point([187, 189, 189, 254, 125, 104, 119, 140, 87, 144, 41, 134, 234, 28, 0, 221, 213, 128, 160, 249, 156, 190, 188, 151, 193, 151, 250, 48, 61, 219, 186, 27])), SecretKey(Scalar([1, 100, 173, 162, 190, 238, 39, 32, 234, 242, 5, 51, 118, 209, 46, 203, 194, 190, 250, 110, 15, 225, 108, 139, 140, 191, 1, 224, 238, 157, 30, 12])));
/// AMN: boa1xzamn00t9690d6hyv8splv0hdnxc92qwkjekfzgr8ajgl9gyrw25cw2s6ny
static immutable AMN = KeyPair(PublicKey(Point([187, 185, 189, 235, 46, 138, 246, 234, 228, 97, 224, 31, 177, 247, 108, 205, 130, 168, 14, 180, 179, 100, 137, 3, 63, 100, 143, 149, 4, 27, 149, 76])), SecretKey(Scalar([241, 54, 215, 70, 219, 13, 162, 239, 78, 218, 201, 31, 122, 83, 208, 105, 191, 117, 150, 2, 100, 146, 62, 131, 165, 98, 113, 175, 98, 222, 6, 3])));
/// AMP: boa1xzamp00kmtulv90es8y3k3wtqc2tgv4wemj38qkz6xmvafdz38gxw9k234l
static immutable AMP = KeyPair(PublicKey(Point([187, 176, 189, 246, 218, 249, 246, 21, 249, 129, 201, 27, 69, 203, 6, 20, 180, 50, 174, 206, 229, 19, 130, 194, 209, 182, 206, 165, 162, 137, 208, 103])), SecretKey(Scalar([57, 96, 196, 140, 61, 54, 172, 25, 18, 249, 12, 97, 240, 231, 70, 253, 95, 65, 252, 57, 201, 52, 121, 157, 44, 190, 163, 132, 88, 68, 192, 10])));
/// AMQ: boa1xpamq00t5rvzjc8zd4y0w7t56l0k7ftk35nh7szg3znkgxlgchfljt82mhf
static immutable AMQ = KeyPair(PublicKey(Point([123, 176, 61, 235, 160, 216, 41, 96, 226, 109, 72, 247, 121, 116, 215, 223, 111, 37, 118, 141, 39, 127, 64, 72, 136, 167, 100, 27, 232, 197, 211, 249])), SecretKey(Scalar([123, 43, 24, 165, 147, 160, 154, 202, 207, 250, 144, 231, 222, 97, 136, 119, 1, 211, 51, 19, 110, 155, 235, 96, 207, 227, 6, 109, 110, 113, 209, 13])));
/// AMR: boa1xqamr00g498x3wrws49emydtxjmtdsak5x0gqnafrtxe30jxlkhsjnf2jd6
static immutable AMR = KeyPair(PublicKey(Point([59, 177, 189, 232, 169, 78, 104, 184, 110, 133, 75, 157, 145, 171, 52, 182, 182, 195, 182, 161, 158, 128, 79, 169, 26, 205, 152, 190, 70, 253, 175, 9])), SecretKey(Scalar([195, 130, 144, 125, 111, 92, 149, 198, 115, 224, 33, 111, 38, 125, 241, 138, 57, 163, 175, 61, 142, 62, 148, 175, 95, 129, 143, 122, 100, 9, 230, 12])));
/// AMS: boa1xzams00etzemen84ejvjd398w2az78ps2xqxhcly70xnajkjxny8q47wcew
static immutable AMS = KeyPair(PublicKey(Point([187, 184, 61, 249, 88, 179, 188, 204, 245, 204, 153, 38, 196, 167, 114, 186, 47, 28, 48, 81, 128, 107, 227, 228, 243, 205, 62, 202, 210, 52, 200, 112])), SecretKey(Scalar([164, 47, 60, 247, 80, 78, 220, 156, 99, 34, 112, 112, 194, 48, 138, 147, 244, 82, 135, 154, 126, 190, 214, 139, 170, 174, 31, 100, 220, 133, 127, 12])));
/// AMT: boa1xzamt00dpf5kppkc6f8z2slnw2tyca9cslmagkzwckwmkjep55z26p0pq8j
static immutable AMT = KeyPair(PublicKey(Point([187, 181, 189, 237, 10, 105, 96, 134, 216, 210, 78, 37, 67, 243, 114, 150, 76, 116, 184, 135, 247, 212, 88, 78, 197, 157, 187, 75, 33, 165, 4, 173])), SecretKey(Scalar([158, 241, 163, 133, 215, 174, 138, 1, 251, 137, 93, 127, 34, 88, 140, 64, 55, 187, 188, 180, 61, 212, 95, 181, 22, 194, 92, 1, 11, 178, 121, 13])));
/// AMU: boa1xqamu006u5yx0lypulqfwqfrgzpwesr0zpu9mehlpft9zl3glraz5vvnhmc
static immutable AMU = KeyPair(PublicKey(Point([59, 190, 61, 250, 229, 8, 103, 252, 129, 231, 192, 151, 1, 35, 64, 130, 236, 192, 111, 16, 120, 93, 230, 255, 10, 86, 81, 126, 40, 248, 250, 42])), SecretKey(Scalar([65, 114, 204, 226, 238, 98, 210, 253, 140, 218, 109, 90, 50, 226, 148, 85, 106, 98, 140, 55, 250, 157, 207, 228, 44, 175, 130, 73, 123, 133, 149, 8])));
/// AMV: boa1xqamv00d6sp32h4derauzej0vr0k7k9h3a62fxxzqyls6cclqsk95qh26sd
static immutable AMV = KeyPair(PublicKey(Point([59, 182, 61, 237, 212, 3, 21, 94, 173, 200, 251, 193, 102, 79, 96, 223, 111, 88, 183, 143, 116, 164, 152, 194, 1, 63, 13, 99, 31, 4, 44, 90])), SecretKey(Scalar([190, 28, 148, 210, 207, 240, 133, 69, 71, 187, 113, 218, 102, 227, 41, 31, 160, 10, 3, 133, 188, 188, 30, 226, 27, 116, 170, 87, 239, 176, 152, 6])));
/// AMW: boa1xzamw006763ktrwdlupxc9ycu68raxyvczxjf8uehux3e2ae2cyrqpmlfgr
static immutable AMW = KeyPair(PublicKey(Point([187, 183, 61, 250, 246, 163, 101, 141, 205, 255, 2, 108, 20, 152, 230, 142, 62, 152, 140, 192, 141, 36, 159, 153, 191, 13, 28, 171, 185, 86, 8, 48])), SecretKey(Scalar([50, 191, 108, 92, 102, 177, 208, 99, 88, 32, 23, 197, 214, 157, 57, 129, 14, 135, 200, 135, 95, 218, 58, 224, 141, 16, 166, 52, 186, 22, 171, 4])));
/// AMX: boa1xzamx00xxwyejtax8plzw5ggar0amnalk5t9hs38a62hjg4x56hxc07cyz3
static immutable AMX = KeyPair(PublicKey(Point([187, 179, 61, 230, 51, 137, 153, 47, 166, 56, 126, 39, 81, 8, 232, 223, 221, 207, 191, 181, 22, 91, 194, 39, 238, 149, 121, 34, 166, 166, 174, 108])), SecretKey(Scalar([181, 39, 4, 47, 202, 224, 79, 105, 166, 225, 228, 244, 60, 103, 57, 117, 33, 52, 52, 158, 74, 116, 2, 142, 188, 116, 102, 173, 255, 137, 95, 7])));
/// AMY: boa1xramy00u4e6mdtz462ay5azkxajf4jm20jvuyf3ug02l9x7tq2d4x5q780e
static immutable AMY = KeyPair(PublicKey(Point([251, 178, 61, 252, 174, 117, 182, 172, 85, 210, 186, 74, 116, 86, 55, 100, 154, 203, 106, 124, 153, 194, 38, 60, 67, 213, 242, 155, 203, 2, 155, 83])), SecretKey(Scalar([91, 178, 19, 250, 216, 126, 255, 199, 77, 20, 209, 34, 153, 195, 128, 74, 10, 154, 14, 11, 90, 249, 133, 159, 236, 80, 140, 183, 130, 218, 208, 1])));
/// AMZ: boa1xqamz00lu3ueef80m65m9rjg3fe9akayn6ye5v6t5unzfjgdmkup7uxj979
static immutable AMZ = KeyPair(PublicKey(Point([59, 177, 61, 255, 228, 121, 156, 164, 239, 222, 169, 178, 142, 72, 138, 114, 94, 219, 164, 158, 137, 154, 51, 75, 167, 38, 36, 201, 13, 221, 184, 31])), SecretKey(Scalar([250, 75, 27, 90, 171, 75, 5, 108, 183, 75, 180, 140, 208, 19, 82, 213, 213, 39, 112, 104, 212, 85, 99, 164, 54, 206, 117, 9, 145, 6, 130, 15])));
/// ANA: boa1xzana00h3chug8me4kjqtq0pp7048r5m06mu5r0m6ekasf5s0dn0yrxjpgc
static immutable ANA = KeyPair(PublicKey(Point([187, 62, 189, 247, 142, 47, 196, 31, 121, 173, 164, 5, 129, 225, 15, 159, 83, 142, 155, 126, 183, 202, 13, 251, 214, 109, 216, 38, 144, 123, 102, 242])), SecretKey(Scalar([209, 232, 90, 58, 13, 47, 250, 217, 149, 200, 144, 199, 201, 255, 162, 126, 149, 12, 139, 105, 69, 232, 236, 153, 241, 56, 121, 17, 196, 86, 252, 13])));
/// ANC: boa1xqanc00kfz3k9dmqy5yk8qpkvtkljruhgx44s0w9s5cm4tpq5dz5sr8dqpj
static immutable ANC = KeyPair(PublicKey(Point([59, 60, 61, 246, 72, 163, 98, 183, 96, 37, 9, 99, 128, 54, 98, 237, 249, 15, 151, 65, 171, 88, 61, 197, 133, 49, 186, 172, 32, 163, 69, 72])), SecretKey(Scalar([190, 240, 14, 54, 190, 70, 211, 35, 227, 175, 110, 205, 170, 156, 228, 113, 205, 42, 202, 243, 201, 43, 186, 189, 4, 43, 201, 45, 86, 57, 216, 11])));
/// AND: boa1xzand00390huy6t2r3sna3yfnvtz69uvaudutg74jz2e5jsyyzxayju3u68
static immutable AND = KeyPair(PublicKey(Point([187, 54, 189, 241, 43, 239, 194, 105, 106, 28, 97, 62, 196, 137, 155, 22, 45, 23, 140, 239, 27, 197, 163, 213, 144, 149, 154, 74, 4, 32, 141, 210])), SecretKey(Scalar([207, 205, 10, 36, 25, 10, 228, 126, 192, 33, 20, 134, 177, 166, 160, 95, 239, 139, 128, 45, 208, 65, 100, 105, 106, 66, 114, 205, 43, 203, 213, 0])));
/// ANE: boa1xzane00terp5uhn2e3g93f69nkvd2sa20v60ee3yqa28pkdhdtr3kge9f5g
static immutable ANE = KeyPair(PublicKey(Point([187, 60, 189, 235, 200, 195, 78, 94, 106, 204, 80, 88, 167, 69, 157, 152, 213, 67, 170, 123, 52, 252, 230, 36, 7, 84, 112, 217, 183, 106, 199, 27])), SecretKey(Scalar([212, 11, 107, 96, 34, 13, 177, 241, 234, 253, 151, 28, 225, 155, 85, 70, 49, 13, 3, 49, 170, 154, 167, 149, 252, 71, 214, 185, 187, 118, 234, 5])));
/// ANF: boa1xranf009rla08g8uhx3z5nuqppr8zte7x004u8jdpdrwykzu5pwjczla5al
static immutable ANF = KeyPair(PublicKey(Point([251, 52, 189, 229, 31, 250, 243, 160, 252, 185, 162, 42, 79, 128, 8, 70, 113, 47, 62, 51, 223, 94, 30, 77, 11, 70, 226, 88, 92, 160, 93, 44])), SecretKey(Scalar([13, 129, 137, 155, 251, 193, 25, 122, 77, 96, 210, 226, 106, 103, 227, 206, 39, 250, 170, 154, 142, 243, 108, 234, 205, 16, 67, 239, 146, 138, 130, 10])));
/// ANG: boa1xpang009a3m2egepv83h37ze02fndkvw7r9aujntd8gesy5tuh0m54947r0
static immutable ANG = KeyPair(PublicKey(Point([123, 52, 61, 229, 236, 118, 172, 163, 33, 97, 227, 120, 248, 89, 122, 147, 54, 217, 142, 240, 203, 222, 74, 107, 105, 209, 152, 18, 139, 229, 223, 186])), SecretKey(Scalar([86, 39, 208, 140, 21, 185, 178, 163, 252, 140, 241, 131, 154, 136, 241, 195, 219, 75, 218, 202, 248, 21, 94, 216, 191, 249, 214, 225, 193, 86, 230, 15])));
/// ANH: boa1xqanh00jtkzwhq2dj7vxw86ge8892x0vhplhg6x369narruvw2frgy9fn64
static immutable ANH = KeyPair(PublicKey(Point([59, 59, 189, 242, 93, 132, 235, 129, 77, 151, 152, 103, 31, 72, 201, 206, 85, 25, 236, 184, 127, 116, 104, 209, 209, 103, 209, 143, 140, 114, 146, 52])), SecretKey(Scalar([16, 168, 165, 37, 8, 174, 39, 19, 59, 149, 18, 192, 36, 155, 4, 131, 56, 114, 158, 2, 197, 212, 2, 126, 74, 94, 162, 143, 184, 253, 42, 8])));
/// ANJ: boa1xpanj008xysa0sx3xwdmwkexusju02tpg3xllzgpw86qtl0c5yh0utv8t78
static immutable ANJ = KeyPair(PublicKey(Point([123, 57, 61, 231, 49, 33, 215, 192, 209, 51, 155, 183, 91, 38, 228, 37, 199, 169, 97, 68, 77, 255, 137, 1, 113, 244, 5, 253, 248, 161, 46, 254])), SecretKey(Scalar([33, 94, 109, 112, 21, 106, 114, 213, 156, 163, 164, 179, 23, 10, 210, 198, 106, 132, 197, 209, 47, 11, 144, 87, 151, 180, 146, 15, 245, 246, 77, 4])));
/// ANK: boa1xpank00zfzmd4t5rqmnrjdnahd7yux25ufcc55vuppmd7zy77tykuwr27a6
static immutable ANK = KeyPair(PublicKey(Point([123, 59, 61, 226, 72, 182, 218, 174, 131, 6, 230, 57, 54, 125, 187, 124, 78, 25, 84, 226, 113, 138, 81, 156, 8, 118, 223, 8, 158, 242, 201, 110])), SecretKey(Scalar([199, 97, 230, 25, 34, 66, 223, 130, 218, 121, 106, 107, 131, 141, 202, 11, 218, 173, 229, 228, 228, 79, 235, 34, 77, 70, 206, 172, 84, 213, 181, 11])));
/// ANL: boa1xzanl002jzkh2jacdgnu5t4ax7wys9k3wtf4cpejvh26fwsw83pm7w83rm6
static immutable ANL = KeyPair(PublicKey(Point([187, 63, 189, 234, 144, 173, 117, 75, 184, 106, 39, 202, 46, 189, 55, 156, 72, 22, 209, 114, 211, 92, 7, 50, 101, 213, 164, 186, 14, 60, 67, 191])), SecretKey(Scalar([63, 101, 193, 149, 81, 113, 65, 169, 216, 1, 162, 194, 26, 146, 133, 154, 12, 9, 138, 210, 72, 73, 243, 41, 83, 92, 251, 199, 5, 181, 80, 8])));
/// ANM: boa1xqanm00knxlwgkmj49vrt5ah05jksv8gzvutmqw2xy9nl23z6e8qjrgcs3r
static immutable ANM = KeyPair(PublicKey(Point([59, 61, 189, 246, 153, 190, 228, 91, 114, 169, 88, 53, 211, 183, 125, 37, 104, 48, 232, 19, 56, 189, 129, 202, 49, 11, 63, 170, 34, 214, 78, 9])), SecretKey(Scalar([112, 93, 254, 29, 97, 51, 216, 231, 19, 153, 153, 200, 145, 233, 107, 182, 54, 151, 196, 243, 181, 69, 21, 131, 64, 75, 164, 46, 139, 203, 120, 1])));
/// ANN: boa1xpann002muz2yfapjsnqazsf3ax27dwppavtp5vzpn2xhhhc5lvd7pf7m8m
static immutable ANN = KeyPair(PublicKey(Point([123, 57, 189, 234, 223, 4, 162, 39, 161, 148, 38, 14, 138, 9, 143, 76, 175, 53, 193, 15, 88, 176, 209, 130, 12, 212, 107, 222, 248, 167, 216, 223])), SecretKey(Scalar([152, 234, 182, 25, 103, 34, 179, 76, 95, 172, 135, 254, 4, 126, 135, 36, 182, 106, 138, 135, 242, 192, 253, 65, 152, 67, 69, 80, 118, 134, 219, 12])));
/// ANP: boa1xqanp00ps5qzltjg69hp54zdmr5tn0ummn04kg7dd2sc4pd4shre6lme374
static immutable ANP = KeyPair(PublicKey(Point([59, 48, 189, 225, 133, 0, 47, 174, 72, 209, 110, 26, 84, 77, 216, 232, 185, 191, 155, 220, 223, 91, 35, 205, 106, 161, 138, 133, 181, 133, 199, 157])), SecretKey(Scalar([177, 127, 31, 147, 42, 25, 203, 167, 245, 160, 13, 22, 135, 103, 149, 174, 18, 193, 24, 102, 108, 65, 6, 85, 45, 92, 58, 15, 251, 30, 119, 10])));
/// ANQ: boa1xzanq00hfl2sj7mka690z55cw07pc0s96p4cam8xtm623zf257u3g50k373
static immutable ANQ = KeyPair(PublicKey(Point([187, 48, 61, 247, 79, 213, 9, 123, 118, 238, 138, 241, 82, 152, 115, 252, 28, 62, 5, 208, 107, 142, 236, 230, 94, 244, 168, 137, 42, 167, 185, 20])), SecretKey(Scalar([5, 109, 176, 10, 9, 84, 178, 92, 152, 116, 149, 210, 8, 235, 212, 200, 71, 178, 231, 129, 12, 10, 188, 17, 243, 14, 90, 145, 200, 253, 18, 1])));
/// ANR: boa1xqanr0078g8eg3d3kwswpc8k3dmqf0696qnpjstjpkg60avrk5uns4hqav7
static immutable ANR = KeyPair(PublicKey(Point([59, 49, 189, 254, 58, 15, 148, 69, 177, 179, 160, 224, 224, 246, 139, 118, 4, 191, 69, 208, 38, 25, 65, 114, 13, 145, 167, 245, 131, 181, 57, 56])), SecretKey(Scalar([144, 118, 90, 90, 221, 120, 195, 43, 71, 146, 84, 195, 10, 150, 130, 33, 173, 238, 169, 6, 32, 145, 135, 144, 196, 110, 108, 80, 219, 223, 158, 13])));
/// ANS: boa1xzans00x48wteuh7fm9m53xvpacy3d9905238ymyq4x083qf2le4kegnfx8
static immutable ANS = KeyPair(PublicKey(Point([187, 56, 61, 230, 169, 220, 188, 242, 254, 78, 203, 186, 68, 204, 15, 112, 72, 180, 165, 125, 21, 19, 147, 100, 5, 76, 243, 196, 9, 87, 243, 91])), SecretKey(Scalar([104, 126, 158, 65, 240, 217, 92, 144, 148, 220, 238, 232, 230, 193, 53, 143, 228, 167, 11, 40, 178, 245, 92, 109, 195, 113, 51, 156, 125, 26, 230, 7])));
/// ANT: boa1xzant008f7qmswwhg2taz4m46368kmhus8q57anu4curk97qw0y5kx3act0
static immutable ANT = KeyPair(PublicKey(Point([187, 53, 189, 231, 79, 129, 184, 57, 215, 66, 151, 209, 87, 117, 212, 116, 123, 110, 252, 129, 193, 79, 118, 124, 174, 56, 59, 23, 192, 115, 201, 75])), SecretKey(Scalar([183, 202, 23, 174, 93, 225, 245, 171, 106, 43, 242, 217, 231, 129, 225, 102, 120, 224, 130, 221, 112, 112, 9, 101, 175, 77, 247, 50, 26, 170, 186, 9])));
/// ANU: boa1xpanu00wpplegkaa8uwzdhwy4628h0lm6he7ee2d33lar80hk0lkvpugk3l
static immutable ANU = KeyPair(PublicKey(Point([123, 62, 61, 238, 8, 127, 148, 91, 189, 63, 28, 38, 221, 196, 174, 148, 123, 191, 251, 213, 243, 236, 229, 77, 140, 127, 209, 157, 247, 179, 255, 102])), SecretKey(Scalar([14, 55, 158, 50, 90, 137, 181, 148, 82, 121, 116, 97, 195, 189, 245, 176, 205, 69, 223, 27, 234, 107, 97, 180, 83, 37, 30, 7, 230, 157, 119, 13])));
/// ANV: boa1xranv00ulvgx5we6sh2wvrk5ftmdllmhu8rl8k977gfupfzjnxldgdldvgx
static immutable ANV = KeyPair(PublicKey(Point([251, 54, 61, 252, 251, 16, 106, 59, 58, 133, 212, 230, 14, 212, 74, 246, 223, 255, 119, 225, 199, 243, 216, 190, 242, 19, 192, 164, 82, 153, 190, 212])), SecretKey(Scalar([186, 214, 133, 108, 110, 20, 250, 192, 149, 52, 238, 238, 65, 144, 207, 23, 73, 25, 36, 228, 157, 168, 51, 155, 195, 8, 167, 196, 177, 251, 242, 13])));
/// ANW: boa1xzanw00dcqq9mh6h0r79vsq6pxfnyy067w7j3aq2kpk3c2222w38z9uqqf6
static immutable ANW = KeyPair(PublicKey(Point([187, 55, 61, 237, 192, 0, 93, 223, 87, 120, 252, 86, 64, 26, 9, 147, 50, 17, 250, 243, 189, 40, 244, 10, 176, 109, 28, 41, 74, 83, 162, 113])), SecretKey(Scalar([125, 133, 149, 148, 74, 32, 42, 94, 235, 156, 144, 119, 221, 108, 137, 28, 247, 191, 211, 130, 235, 82, 147, 48, 129, 113, 156, 216, 77, 225, 82, 14])));
/// ANX: boa1xpanx00spp9x6r5y33s696uex7dnpv4ax76vlnkya6zdz5k8rdxh5ru6d0w
static immutable ANX = KeyPair(PublicKey(Point([123, 51, 61, 240, 8, 74, 109, 14, 132, 140, 97, 162, 235, 153, 55, 155, 48, 178, 189, 55, 180, 207, 206, 196, 238, 132, 209, 82, 199, 27, 77, 122])), SecretKey(Scalar([151, 109, 104, 47, 132, 7, 179, 29, 203, 16, 203, 170, 15, 20, 160, 67, 150, 213, 64, 164, 51, 81, 185, 48, 227, 189, 152, 6, 79, 236, 62, 7])));
/// ANY: boa1xrany00246qdv03k586uzu7jxvt8x9v27u2hp24de8mddwqwjy866wmnchl
static immutable ANY = KeyPair(PublicKey(Point([251, 50, 61, 234, 174, 128, 214, 62, 54, 161, 245, 193, 115, 210, 51, 22, 115, 21, 138, 247, 21, 112, 170, 173, 201, 246, 214, 184, 14, 145, 15, 173])), SecretKey(Scalar([54, 51, 18, 255, 157, 11, 101, 178, 32, 13, 14, 118, 22, 42, 39, 59, 246, 131, 215, 160, 64, 163, 217, 6, 177, 25, 95, 213, 122, 108, 105, 10])));
/// ANZ: boa1xranz00y4cnc7kqhuje7fzj6u0qamx32hl363grtv9u29lv5xh57zkkrnlq
static immutable ANZ = KeyPair(PublicKey(Point([251, 49, 61, 228, 174, 39, 143, 88, 23, 228, 179, 228, 138, 90, 227, 193, 221, 154, 42, 191, 227, 168, 160, 107, 97, 120, 162, 253, 148, 53, 233, 225])), SecretKey(Scalar([213, 244, 202, 220, 104, 253, 91, 110, 63, 135, 196, 206, 240, 134, 141, 209, 82, 83, 131, 189, 50, 168, 102, 56, 209, 65, 242, 186, 61, 105, 140, 1])));
/// APA: boa1xrapa00t294ksge662c2yqfj0jt9z4zjl4q8camcfcwvv5vqlssfsf872hs
static immutable APA = KeyPair(PublicKey(Point([250, 30, 189, 235, 81, 107, 104, 35, 58, 210, 176, 162, 1, 50, 124, 150, 81, 84, 82, 253, 64, 124, 119, 120, 78, 28, 198, 81, 128, 252, 32, 152])), SecretKey(Scalar([148, 240, 170, 222, 144, 137, 75, 78, 129, 158, 255, 149, 110, 142, 159, 13, 14, 246, 179, 133, 92, 111, 148, 94, 254, 15, 231, 56, 139, 245, 165, 12])));
/// APC: boa1xzapc00v4tjnalwqhhxgz2laevat9gjp7p3ln944gj7r5dpv6rsgqj4237j
static immutable APC = KeyPair(PublicKey(Point([186, 28, 61, 236, 170, 229, 62, 253, 192, 189, 204, 129, 43, 253, 203, 58, 178, 162, 65, 240, 99, 249, 150, 181, 68, 188, 58, 52, 44, 208, 224, 128])), SecretKey(Scalar([130, 40, 50, 51, 74, 252, 107, 139, 187, 83, 110, 133, 43, 19, 39, 143, 1, 28, 6, 7, 29, 90, 195, 158, 73, 141, 249, 202, 58, 33, 119, 1])));
/// APD: boa1xzapd00tzq2wq7qxser5gzgd0j85vgpz5yzkrp7xvgfqgajzh6gp6gadmj4
static immutable APD = KeyPair(PublicKey(Point([186, 22, 189, 235, 16, 20, 224, 120, 6, 134, 71, 68, 9, 13, 124, 143, 70, 32, 34, 161, 5, 97, 135, 198, 98, 18, 4, 118, 66, 190, 144, 29])), SecretKey(Scalar([52, 208, 12, 223, 154, 121, 116, 102, 48, 12, 133, 236, 127, 242, 173, 142, 162, 189, 166, 157, 93, 195, 220, 249, 97, 187, 246, 195, 36, 204, 113, 1])));
/// APE: boa1xrape0054zjaestfp35y4cpgp2psa9uqfeuyrhu7lw3uv4v4a7sejqslzar
static immutable APE = KeyPair(PublicKey(Point([250, 28, 189, 244, 168, 165, 220, 193, 105, 12, 104, 74, 224, 40, 10, 131, 14, 151, 128, 78, 120, 65, 223, 158, 251, 163, 198, 85, 149, 239, 161, 153])), SecretKey(Scalar([207, 28, 214, 80, 93, 93, 78, 216, 217, 131, 196, 140, 33, 201, 2, 219, 65, 77, 221, 69, 115, 255, 115, 184, 237, 27, 132, 182, 147, 29, 204, 6])));
/// APF: boa1xrapf00v7t5mmdslmr0pw2d9shex4gsxz5k4s6c5r00ueeesx6z36v6sr7n
static immutable APF = KeyPair(PublicKey(Point([250, 20, 189, 236, 242, 233, 189, 182, 31, 216, 222, 23, 41, 165, 133, 242, 106, 162, 6, 21, 45, 88, 107, 20, 27, 223, 204, 231, 48, 54, 133, 29])), SecretKey(Scalar([223, 110, 69, 139, 152, 150, 83, 179, 232, 34, 74, 188, 21, 214, 137, 176, 201, 8, 157, 137, 83, 26, 254, 29, 121, 26, 203, 127, 165, 48, 49, 9])));
/// APG: boa1xzapg00fy7sl50ktn54rtdyglu3eclg93n0n4d8z06ws27g2aux7km535mk
static immutable APG = KeyPair(PublicKey(Point([186, 20, 61, 233, 39, 161, 250, 62, 203, 157, 42, 53, 180, 136, 255, 35, 156, 125, 5, 140, 223, 58, 180, 226, 126, 157, 5, 121, 10, 239, 13, 235])), SecretKey(Scalar([73, 197, 134, 69, 95, 218, 139, 157, 157, 116, 221, 190, 222, 161, 2, 56, 199, 153, 111, 133, 176, 246, 35, 247, 109, 239, 180, 79, 176, 210, 0, 9])));
/// APH: boa1xqaph005ep34us4ypdqrlgqjsuq3y0gkve6ldnevywnzdcx60ck9gz5ggg4
static immutable APH = KeyPair(PublicKey(Point([58, 27, 189, 244, 200, 99, 94, 66, 164, 11, 64, 63, 160, 18, 135, 1, 18, 61, 22, 102, 117, 246, 207, 44, 35, 166, 38, 224, 218, 126, 44, 84])), SecretKey(Scalar([196, 218, 25, 179, 113, 38, 105, 16, 225, 44, 103, 220, 115, 198, 161, 68, 141, 142, 161, 11, 129, 229, 33, 252, 110, 4, 172, 218, 159, 87, 8, 7])));
/// APJ: boa1xqapj00xtrjkvwfwfh3p0r68s3v52s9yg7qfswevla7sf2edwuk2yhsdgut
static immutable APJ = KeyPair(PublicKey(Point([58, 25, 61, 230, 88, 229, 102, 57, 46, 77, 226, 23, 143, 71, 132, 89, 69, 64, 164, 71, 128, 152, 59, 44, 255, 125, 4, 171, 45, 119, 44, 162])), SecretKey(Scalar([124, 148, 175, 72, 197, 169, 175, 25, 90, 129, 149, 81, 89, 32, 6, 36, 157, 35, 231, 83, 16, 11, 43, 56, 166, 71, 98, 104, 60, 208, 35, 8])));
/// APK: boa1xrapk00mt0kxnkqeqgrgkplngdgs2gkzwu7pzsdjc43wd0vaakntghk3g0e
static immutable APK = KeyPair(PublicKey(Point([250, 27, 61, 251, 91, 236, 105, 216, 25, 2, 6, 139, 7, 243, 67, 81, 5, 34, 194, 119, 60, 17, 65, 178, 197, 98, 230, 189, 157, 237, 166, 180])), SecretKey(Scalar([109, 253, 139, 97, 148, 136, 221, 163, 223, 244, 11, 163, 32, 216, 96, 96, 206, 108, 176, 88, 138, 58, 134, 114, 1, 39, 150, 59, 198, 103, 172, 5])));
/// APL: boa1xrapl00fn28x650mpynalf79q42s96lkk49rmc8jr0jn3sawtm482454l5s
static immutable APL = KeyPair(PublicKey(Point([250, 31, 189, 233, 154, 142, 109, 81, 251, 9, 39, 223, 167, 197, 5, 85, 2, 235, 246, 181, 74, 61, 224, 242, 27, 229, 56, 195, 174, 94, 234, 117])), SecretKey(Scalar([199, 184, 199, 238, 201, 70, 84, 60, 152, 34, 135, 243, 29, 251, 28, 148, 50, 8, 243, 49, 114, 150, 87, 85, 212, 32, 95, 85, 4, 32, 208, 15])));
/// APM: boa1xpapm00p2saxlapnexx4ez7fcdgtha84qyrz63kp022nuem53dh3qn0ctzq
static immutable APM = KeyPair(PublicKey(Point([122, 29, 189, 225, 84, 58, 111, 244, 51, 201, 141, 92, 139, 201, 195, 80, 187, 244, 245, 1, 6, 45, 70, 193, 122, 149, 62, 103, 116, 139, 111, 16])), SecretKey(Scalar([165, 186, 132, 69, 72, 197, 26, 87, 152, 136, 18, 90, 202, 87, 113, 195, 182, 228, 191, 220, 191, 172, 51, 254, 148, 154, 120, 82, 185, 60, 1, 7])));
/// APN: boa1xqapn00kvd2rxr5jddnn5zs0ca7y5s48najsee46edysfqhsgga0uz03tly
static immutable APN = KeyPair(PublicKey(Point([58, 25, 189, 246, 99, 84, 51, 14, 146, 107, 103, 58, 10, 15, 199, 124, 74, 66, 167, 159, 101, 12, 230, 186, 203, 73, 4, 130, 240, 66, 58, 254])), SecretKey(Scalar([157, 158, 2, 163, 65, 31, 174, 107, 72, 52, 51, 241, 197, 12, 233, 178, 18, 202, 26, 15, 62, 28, 137, 52, 166, 63, 9, 9, 172, 99, 191, 15])));
/// APP: boa1xrapp00u5l6l5cludexlp8gya7lh5trfxhvkkradwfttxct6q2a2wklhzdr
static immutable APP = KeyPair(PublicKey(Point([250, 16, 189, 252, 167, 245, 250, 99, 252, 110, 77, 240, 157, 4, 239, 191, 122, 44, 105, 53, 217, 107, 15, 173, 114, 86, 179, 97, 122, 2, 186, 167])), SecretKey(Scalar([107, 2, 20, 73, 90, 106, 37, 107, 2, 122, 112, 17, 189, 104, 19, 245, 230, 230, 147, 45, 112, 71, 38, 14, 141, 237, 37, 83, 175, 10, 78, 8])));
/// APQ: boa1xpapq00ev5lue4jj7r29hxmn875qhqe5pz56u6k4jwt7wh92h9nwjnt30mg
static immutable APQ = KeyPair(PublicKey(Point([122, 16, 61, 249, 101, 63, 204, 214, 82, 240, 212, 91, 155, 115, 63, 168, 11, 131, 52, 8, 169, 174, 106, 213, 147, 151, 231, 92, 170, 185, 102, 233])), SecretKey(Scalar([120, 10, 251, 130, 191, 175, 255, 177, 208, 56, 224, 115, 169, 54, 83, 189, 185, 119, 163, 108, 250, 143, 89, 86, 165, 5, 94, 116, 133, 23, 116, 3])));
/// APR: boa1xpapr00mnnm4f58ly6m9szfev6q80ezmzp853y838u0lyhn4uf847dvqraf
static immutable APR = KeyPair(PublicKey(Point([122, 17, 189, 251, 156, 247, 84, 208, 255, 38, 182, 88, 9, 57, 102, 128, 119, 228, 91, 16, 79, 72, 144, 241, 63, 31, 242, 94, 117, 226, 79, 95])), SecretKey(Scalar([80, 92, 51, 115, 150, 241, 6, 211, 42, 97, 97, 255, 171, 172, 207, 150, 117, 223, 190, 191, 248, 147, 73, 101, 114, 198, 186, 73, 226, 60, 3, 4])));
/// APS: boa1xzaps00a49mg526g6dytsvcpd7yr6dug57vl75ashl776mzx69dv2y3sfgn
static immutable APS = KeyPair(PublicKey(Point([186, 24, 61, 253, 169, 118, 138, 43, 72, 211, 72, 184, 51, 1, 111, 136, 61, 55, 136, 167, 153, 255, 83, 176, 191, 253, 237, 108, 70, 209, 90, 197])), SecretKey(Scalar([11, 58, 104, 26, 96, 122, 172, 175, 60, 205, 116, 90, 188, 34, 50, 149, 20, 23, 88, 192, 180, 50, 88, 109, 232, 58, 26, 65, 124, 0, 148, 4])));
/// APT: boa1xrapt004xqwyra42xtty7v8ksea2yh2fmxqvk3ztl3fv895la98qw8q4j0a
static immutable APT = KeyPair(PublicKey(Point([250, 21, 189, 245, 48, 28, 65, 246, 170, 50, 214, 79, 48, 246, 134, 122, 162, 93, 73, 217, 128, 203, 68, 75, 252, 82, 195, 150, 159, 233, 78, 7])), SecretKey(Scalar([202, 63, 0, 46, 232, 249, 223, 154, 1, 32, 19, 170, 245, 247, 180, 141, 137, 132, 252, 236, 30, 241, 196, 21, 177, 250, 144, 61, 64, 139, 216, 6])));
/// APU: boa1xrapu00akhr0x4rnlzwvs795nzqvseqd3cu5jf2cpl6l48c02k6m604408f
static immutable APU = KeyPair(PublicKey(Point([250, 30, 61, 253, 181, 198, 243, 84, 115, 248, 156, 200, 120, 180, 152, 128, 200, 100, 13, 142, 57, 73, 37, 88, 15, 245, 250, 159, 15, 85, 181, 189])), SecretKey(Scalar([174, 225, 236, 32, 139, 160, 225, 74, 214, 89, 11, 224, 114, 220, 173, 193, 66, 136, 164, 36, 79, 240, 190, 255, 158, 156, 185, 125, 204, 217, 19, 10])));
/// APV: boa1xzapv00jjszmk2eha86kpdenk04fpz6frv0fc3c60f5n3nsr82pzwfg5s03
static immutable APV = KeyPair(PublicKey(Point([186, 22, 61, 242, 148, 5, 187, 43, 55, 233, 245, 96, 183, 51, 179, 234, 144, 139, 73, 27, 30, 156, 71, 26, 122, 105, 56, 206, 3, 58, 130, 39])), SecretKey(Scalar([50, 189, 216, 168, 130, 229, 117, 203, 0, 55, 6, 236, 239, 210, 93, 179, 241, 174, 187, 87, 25, 39, 36, 111, 190, 147, 153, 136, 110, 104, 127, 12])));
/// APW: boa1xpapw00802azvw462t74tmr8075xma744wdug2vhww2eurewceshjmryrgz
static immutable APW = KeyPair(PublicKey(Point([122, 23, 61, 231, 122, 186, 38, 58, 186, 82, 253, 85, 236, 103, 127, 168, 109, 247, 213, 171, 155, 196, 41, 151, 115, 149, 158, 15, 46, 198, 97, 121])), SecretKey(Scalar([179, 222, 2, 254, 181, 56, 103, 21, 48, 61, 66, 79, 150, 232, 65, 73, 235, 93, 64, 195, 84, 212, 225, 117, 83, 145, 214, 49, 171, 162, 143, 3])));
/// APX: boa1xqapx00k2330jychxd9u66pm5ge5jjq6auxwzu77xjcwhcd08r6k6huz29n
static immutable APX = KeyPair(PublicKey(Point([58, 19, 61, 246, 84, 98, 249, 19, 23, 51, 75, 205, 104, 59, 162, 51, 73, 72, 26, 239, 12, 225, 115, 222, 52, 176, 235, 225, 175, 56, 245, 109])), SecretKey(Scalar([229, 206, 176, 29, 106, 14, 193, 4, 224, 223, 150, 178, 75, 233, 90, 4, 174, 155, 177, 155, 212, 249, 53, 246, 160, 76, 155, 164, 24, 170, 18, 10])));
/// APY: boa1xzapy00xumk6dd8lmqwpcpxzth643v7jedct7xn397zg0nna0uxukg8yr5y
static immutable APY = KeyPair(PublicKey(Point([186, 18, 61, 230, 230, 237, 166, 180, 255, 216, 28, 28, 4, 194, 93, 245, 88, 179, 210, 203, 112, 191, 26, 113, 47, 132, 135, 206, 125, 127, 13, 203])), SecretKey(Scalar([104, 62, 121, 130, 138, 150, 214, 226, 97, 89, 163, 72, 232, 213, 192, 135, 13, 224, 29, 45, 154, 190, 85, 110, 65, 161, 116, 89, 24, 250, 147, 14])));
/// APZ: boa1xqapz00dr4l2whkjtrrv5qhmzdzeeu70h434ttrarlz33ell8exe246pqxa
static immutable APZ = KeyPair(PublicKey(Point([58, 17, 61, 237, 29, 126, 167, 94, 210, 88, 198, 202, 2, 251, 19, 69, 156, 243, 207, 189, 99, 85, 172, 125, 31, 197, 24, 231, 255, 62, 77, 149])), SecretKey(Scalar([233, 182, 74, 179, 197, 205, 141, 88, 190, 187, 223, 122, 147, 239, 136, 49, 185, 29, 46, 74, 173, 163, 226, 93, 217, 73, 102, 110, 184, 243, 86, 11])));
/// AQA: boa1xraqa00r8ztzjj89wwd9f4tj36ph39jfd8zkams5r0d7kgj5cecnukgc0k6
static immutable AQA = KeyPair(PublicKey(Point([250, 14, 189, 227, 56, 150, 41, 72, 229, 115, 154, 84, 213, 114, 142, 131, 120, 150, 73, 105, 197, 110, 238, 20, 27, 219, 235, 34, 84, 198, 113, 62])), SecretKey(Scalar([156, 7, 124, 74, 232, 146, 245, 164, 50, 124, 233, 167, 30, 116, 194, 17, 215, 247, 20, 240, 162, 79, 8, 5, 36, 120, 215, 145, 65, 21, 181, 9])));
/// AQC: boa1xraqc00rv4m52fvw0sdmfz783sgufefz6vr4jq2n2r2czsdhm2v4jmzscgr
static immutable AQC = KeyPair(PublicKey(Point([250, 12, 61, 227, 101, 119, 69, 37, 142, 124, 27, 180, 139, 199, 140, 17, 196, 229, 34, 211, 7, 89, 1, 83, 80, 213, 129, 65, 183, 218, 153, 89])), SecretKey(Scalar([252, 110, 191, 171, 110, 153, 137, 33, 176, 136, 161, 129, 11, 102, 39, 228, 82, 118, 154, 242, 7, 2, 236, 222, 95, 47, 30, 175, 212, 161, 27, 5])));
/// AQD: boa1xpaqd00vqalhg45nwq0hsamat3m50wt8dt0lnqmy30qk7hevd4urcxm4084
static immutable AQD = KeyPair(PublicKey(Point([122, 6, 189, 236, 7, 127, 116, 86, 147, 112, 31, 120, 119, 125, 92, 119, 71, 185, 103, 106, 223, 249, 131, 100, 139, 193, 111, 95, 44, 109, 120, 60])), SecretKey(Scalar([39, 108, 77, 194, 201, 129, 173, 239, 175, 120, 203, 78, 57, 149, 227, 38, 233, 1, 254, 106, 78, 98, 227, 151, 9, 16, 59, 105, 159, 205, 128, 9])));
/// AQE: boa1xraqe00sptvumw0vedgx6ket7yl0fgkacmnqp5j9ssl5axmdy3pd524sl4r
static immutable AQE = KeyPair(PublicKey(Point([250, 12, 189, 240, 10, 217, 205, 185, 236, 203, 80, 109, 91, 43, 241, 62, 244, 162, 221, 198, 230, 0, 210, 69, 132, 63, 78, 155, 109, 36, 66, 218])), SecretKey(Scalar([214, 252, 55, 148, 14, 56, 213, 2, 139, 148, 189, 113, 231, 55, 253, 109, 137, 217, 163, 82, 139, 239, 12, 63, 3, 38, 131, 167, 110, 131, 60, 12])));
/// AQF: boa1xraqf00mly09pd50zth8x0xwr8exryw3jku0026m6eh2k6mukhvwkwt9x96
static immutable AQF = KeyPair(PublicKey(Point([250, 4, 189, 251, 249, 30, 80, 182, 143, 18, 238, 115, 60, 206, 25, 242, 97, 145, 209, 149, 184, 247, 171, 91, 214, 110, 171, 107, 124, 181, 216, 235])), SecretKey(Scalar([138, 21, 69, 150, 165, 33, 117, 3, 170, 103, 19, 124, 148, 25, 35, 251, 17, 144, 29, 213, 29, 242, 4, 73, 190, 208, 122, 74, 44, 231, 113, 2])));
/// AQG: boa1xpaqg006yzg64gxdksspregnlpgdw67fc2nye2eg3d7kfmdyvlt9cchglef
static immutable AQG = KeyPair(PublicKey(Point([122, 4, 61, 250, 32, 145, 170, 160, 205, 180, 32, 17, 229, 19, 248, 80, 215, 107, 201, 194, 166, 76, 171, 40, 139, 125, 100, 237, 164, 103, 214, 92])), SecretKey(Scalar([13, 5, 98, 240, 218, 30, 98, 96, 249, 219, 148, 100, 175, 181, 22, 154, 177, 227, 143, 88, 78, 9, 10, 144, 168, 26, 18, 88, 3, 166, 70, 14])));
/// AQH: boa1xpaqh00j6amm5unu56tdg9l2vezq5znhdmkgzlwyydyhw7lvf2vlkq4kwpq
static immutable AQH = KeyPair(PublicKey(Point([122, 11, 189, 242, 215, 119, 186, 114, 124, 166, 150, 212, 23, 234, 102, 68, 10, 10, 119, 110, 236, 129, 125, 196, 35, 73, 119, 123, 236, 74, 153, 251])), SecretKey(Scalar([238, 187, 31, 86, 81, 75, 128, 79, 31, 61, 212, 196, 27, 54, 209, 60, 225, 170, 112, 71, 116, 136, 178, 224, 13, 117, 158, 61, 172, 16, 95, 7])));
/// AQJ: boa1xpaqj00h306phnru408zpahcnr27lqxdapgqr7unjkqpgcerv9u35h7wyjq
static immutable AQJ = KeyPair(PublicKey(Point([122, 9, 61, 247, 139, 244, 27, 204, 124, 171, 206, 32, 246, 248, 152, 213, 239, 128, 205, 232, 80, 1, 251, 147, 149, 128, 20, 99, 35, 97, 121, 26])), SecretKey(Scalar([19, 69, 165, 222, 116, 9, 197, 227, 73, 229, 20, 9, 13, 18, 137, 218, 239, 132, 150, 103, 127, 13, 212, 157, 43, 216, 128, 2, 203, 43, 134, 14])));
/// AQK: boa1xpaqk004r9n2hdg04kk7ynmarcljpyrm7gkurjxpzuclak20g00yc9jvkez
static immutable AQK = KeyPair(PublicKey(Point([122, 11, 61, 245, 25, 102, 171, 181, 15, 173, 173, 226, 79, 125, 30, 63, 32, 144, 123, 242, 45, 193, 200, 193, 23, 49, 254, 217, 79, 67, 222, 76])), SecretKey(Scalar([211, 162, 9, 80, 97, 95, 91, 55, 140, 67, 32, 123, 70, 237, 74, 6, 140, 98, 162, 106, 99, 64, 6, 247, 8, 105, 138, 199, 244, 65, 221, 2])));
/// AQL: boa1xpaql00ftwzek38lp2mjcevkmaed2hx8xwwhmu888gkwqn4luncr7k0fxm6
static immutable AQL = KeyPair(PublicKey(Point([122, 15, 189, 233, 91, 133, 155, 68, 255, 10, 183, 44, 101, 150, 223, 114, 213, 92, 199, 51, 157, 125, 240, 231, 58, 44, 224, 78, 191, 228, 240, 63])), SecretKey(Scalar([46, 129, 115, 200, 32, 100, 97, 164, 229, 141, 2, 38, 13, 108, 89, 173, 12, 76, 199, 201, 148, 74, 48, 127, 167, 152, 60, 108, 111, 111, 171, 3])));
/// AQM: boa1xraqm00chuz9v53yr6tkrh6ensl9zu5czwv4k3zdjkmwprjc3dvgy3ufngh
static immutable AQM = KeyPair(PublicKey(Point([250, 13, 189, 248, 191, 4, 86, 82, 36, 30, 151, 97, 223, 89, 156, 62, 81, 114, 152, 19, 153, 91, 68, 77, 149, 182, 224, 142, 88, 139, 88, 130])), SecretKey(Scalar([160, 120, 98, 163, 228, 27, 88, 195, 254, 84, 138, 175, 86, 27, 20, 108, 126, 216, 136, 172, 223, 125, 243, 26, 185, 185, 113, 63, 198, 41, 30, 4])));
/// AQN: boa1xraqn00km4lj3wjjvu470egvp3k9fcvwj9mdky0xry55hakcydxc764njl2
static immutable AQN = KeyPair(PublicKey(Point([250, 9, 189, 246, 221, 127, 40, 186, 82, 103, 43, 231, 229, 12, 12, 108, 84, 225, 142, 145, 118, 219, 17, 230, 25, 41, 75, 246, 216, 35, 77, 143])), SecretKey(Scalar([139, 54, 153, 150, 246, 62, 97, 106, 63, 200, 17, 173, 101, 39, 127, 255, 235, 206, 137, 179, 176, 27, 72, 160, 24, 226, 214, 235, 38, 109, 168, 2])));
/// AQP: boa1xraqp00cz3gy398d0jjmx9wc96a9ldthp50vqtecl3tk9nyhzdwn2ydaf9y
static immutable AQP = KeyPair(PublicKey(Point([250, 0, 189, 248, 20, 80, 72, 148, 237, 124, 165, 179, 21, 216, 46, 186, 95, 181, 119, 13, 30, 192, 47, 56, 252, 87, 98, 204, 151, 19, 93, 53])), SecretKey(Scalar([216, 82, 191, 81, 210, 68, 191, 12, 194, 190, 253, 212, 49, 95, 31, 246, 157, 42, 30, 33, 99, 43, 199, 54, 143, 70, 140, 219, 184, 98, 235, 13])));
/// AQQ: boa1xraqq0079z0kcp2w5z2md4pkt0a3ytfgt0vrvfzfdqw7022k6gk2qe60yxq
static immutable AQQ = KeyPair(PublicKey(Point([250, 0, 61, 254, 40, 159, 108, 5, 78, 160, 149, 182, 212, 54, 91, 251, 18, 45, 40, 91, 216, 54, 36, 73, 104, 29, 231, 169, 86, 210, 44, 160])), SecretKey(Scalar([220, 18, 67, 83, 7, 229, 225, 151, 137, 221, 30, 93, 150, 8, 129, 43, 179, 81, 67, 114, 65, 105, 99, 4, 186, 68, 69, 124, 102, 121, 196, 10])));
/// AQR: boa1xqaqr00asrqqs22ld9fflluec76d04u5qkkvngelnshr90hxl4h2v9nyp2s
static immutable AQR = KeyPair(PublicKey(Point([58, 1, 189, 253, 128, 192, 8, 41, 95, 105, 82, 159, 255, 153, 199, 180, 215, 215, 148, 5, 172, 201, 163, 63, 156, 46, 50, 190, 230, 253, 110, 166])), SecretKey(Scalar([118, 84, 205, 207, 108, 122, 45, 102, 124, 4, 145, 94, 246, 111, 174, 10, 147, 3, 80, 6, 252, 180, 146, 222, 65, 140, 218, 43, 42, 148, 78, 5])));
/// AQS: boa1xqaqs00suaywprk96pqr3eqwup7ut7zp5lq9xqf5uvltv3ax22wwjkyteqe
static immutable AQS = KeyPair(PublicKey(Point([58, 8, 61, 240, 231, 72, 224, 142, 197, 208, 64, 56, 228, 14, 224, 125, 197, 248, 65, 167, 192, 83, 1, 52, 227, 62, 182, 71, 166, 82, 156, 233])), SecretKey(Scalar([207, 98, 26, 202, 51, 193, 108, 183, 15, 184, 95, 6, 199, 149, 137, 114, 128, 94, 239, 185, 175, 206, 136, 245, 232, 107, 137, 64, 190, 154, 67, 8])));
/// AQT: boa1xpaqt00l7fxg256rektnqncthdjaufszku8dws6uesf2m7kl5kgpszmx0h0
static immutable AQT = KeyPair(PublicKey(Point([122, 5, 189, 255, 242, 76, 133, 83, 67, 205, 151, 48, 79, 11, 187, 101, 222, 38, 2, 183, 14, 215, 67, 92, 204, 18, 173, 250, 223, 165, 144, 24])), SecretKey(Scalar([63, 48, 140, 87, 75, 55, 115, 57, 59, 249, 244, 223, 181, 81, 18, 171, 53, 237, 103, 177, 151, 150, 100, 142, 246, 100, 82, 239, 228, 202, 49, 4])));
/// AQU: boa1xraqu00zpqynrgwvy5r7075cewux3ht7zh5ru6p5wsq98sn3xt66kd5qljq
static immutable AQU = KeyPair(PublicKey(Point([250, 14, 61, 226, 8, 9, 49, 161, 204, 37, 7, 231, 250, 152, 203, 184, 104, 221, 126, 21, 232, 62, 104, 52, 116, 0, 83, 194, 113, 50, 245, 171])), SecretKey(Scalar([158, 130, 213, 156, 171, 85, 17, 179, 113, 62, 127, 137, 210, 60, 238, 46, 130, 51, 216, 0, 122, 250, 139, 30, 184, 209, 247, 145, 39, 122, 46, 0])));
/// AQV: boa1xzaqv00sgxxqrqa6njdptqssu4yl2g59mhc9haa5mlkmhg3wpdtt5e3tqzw
static immutable AQV = KeyPair(PublicKey(Point([186, 6, 61, 240, 65, 140, 1, 131, 186, 156, 154, 21, 130, 16, 229, 73, 245, 34, 133, 221, 240, 91, 247, 180, 223, 237, 187, 162, 46, 11, 86, 186])), SecretKey(Scalar([38, 94, 106, 167, 174, 132, 15, 196, 94, 208, 248, 166, 137, 229, 186, 139, 251, 52, 94, 152, 105, 215, 233, 17, 246, 31, 111, 101, 28, 225, 201, 4])));
/// AQW: boa1xpaqw00rwealvpmyn3rcx5lelatve0zpjtjfg546w6q7t92g36ndk8uxqz4
static immutable AQW = KeyPair(PublicKey(Point([122, 7, 61, 227, 118, 123, 246, 7, 100, 156, 71, 131, 83, 249, 255, 86, 204, 188, 65, 146, 228, 148, 82, 186, 118, 129, 229, 149, 72, 142, 166, 219])), SecretKey(Scalar([83, 189, 169, 55, 12, 244, 214, 28, 3, 253, 81, 237, 110, 164, 100, 127, 41, 237, 247, 19, 235, 76, 61, 35, 68, 8, 35, 60, 108, 182, 48, 6])));
/// AQX: boa1xqaqx00tg9t5n3a32pldpdepq7mw5cr0j9sy4p7q49ul0ceauwapgradjpp
static immutable AQX = KeyPair(PublicKey(Point([58, 3, 61, 235, 65, 87, 73, 199, 177, 80, 126, 208, 183, 33, 7, 182, 234, 96, 111, 145, 96, 74, 135, 192, 169, 121, 247, 227, 61, 227, 186, 20])), SecretKey(Scalar([130, 169, 109, 0, 241, 84, 58, 10, 8, 167, 185, 76, 5, 235, 234, 32, 137, 176, 23, 3, 203, 82, 161, 8, 146, 171, 182, 43, 194, 139, 165, 11])));
/// AQY: boa1xraqy00w47q0han3d6aca4xavyywp6ezn2ca97watcxz79gz3qn7ws4402m
static immutable AQY = KeyPair(PublicKey(Point([250, 2, 61, 238, 175, 128, 251, 246, 113, 110, 187, 142, 212, 221, 97, 8, 224, 235, 34, 154, 177, 210, 249, 221, 94, 12, 47, 21, 2, 136, 39, 231])), SecretKey(Scalar([128, 39, 189, 242, 95, 118, 182, 212, 11, 245, 143, 161, 241, 184, 132, 0, 23, 218, 241, 135, 141, 197, 236, 43, 185, 166, 36, 147, 92, 90, 177, 3])));
/// AQZ: boa1xraqz00nqzaj5rhlxc4z9cjkdzt3d0w8a59v0wed6edt4c3zyu4tvgmqphp
static immutable AQZ = KeyPair(PublicKey(Point([250, 1, 61, 243, 0, 187, 42, 14, 255, 54, 42, 34, 226, 86, 104, 151, 22, 189, 199, 237, 10, 199, 187, 45, 214, 90, 186, 226, 34, 39, 42, 182])), SecretKey(Scalar([101, 64, 12, 229, 23, 72, 64, 167, 179, 165, 249, 203, 18, 7, 242, 218, 23, 145, 39, 119, 44, 179, 4, 204, 53, 159, 5, 163, 1, 32, 36, 1])));
/// ARA: boa1xpara0056v4yfn5xjza0rp265u7udnm99yh5g9tc828tdrjff0kakrahxcp
static immutable ARA = KeyPair(PublicKey(Point([122, 62, 189, 244, 211, 42, 68, 206, 134, 144, 186, 241, 133, 90, 167, 61, 198, 207, 101, 41, 47, 68, 21, 120, 58, 142, 182, 142, 73, 75, 237, 219])), SecretKey(Scalar([154, 31, 192, 45, 18, 121, 1, 8, 113, 243, 68, 157, 62, 164, 22, 255, 194, 20, 141, 251, 220, 128, 203, 12, 93, 182, 244, 153, 234, 249, 66, 0])));
/// ARC: boa1xparc00qvv984ck00trwmfxuvqmmlwsxwzf3al0tsq5k2rw6aw427ct37mj
static immutable ARC = KeyPair(PublicKey(Point([122, 60, 61, 224, 99, 10, 122, 226, 207, 122, 198, 237, 164, 220, 96, 55, 191, 186, 6, 112, 147, 30, 253, 235, 128, 41, 101, 13, 218, 235, 170, 175])), SecretKey(Scalar([48, 164, 3, 243, 38, 230, 25, 218, 76, 28, 230, 15, 58, 230, 210, 114, 46, 112, 108, 121, 242, 152, 204, 25, 44, 235, 22, 137, 193, 23, 6, 12])));
/// ARD: boa1xrard006yhapr2dzttap6yg3l0rv5yf94hdnmmfj5zkwhhyw80sj785segs
static immutable ARD = KeyPair(PublicKey(Point([250, 54, 189, 250, 37, 250, 17, 169, 162, 90, 250, 29, 17, 17, 251, 198, 202, 17, 37, 173, 219, 61, 237, 50, 160, 172, 235, 220, 142, 59, 225, 47])), SecretKey(Scalar([73, 142, 236, 123, 3, 53, 170, 105, 11, 2, 155, 151, 35, 33, 150, 31, 147, 72, 140, 74, 250, 85, 254, 39, 189, 134, 26, 6, 153, 70, 67, 9])));
/// ARE: boa1xrare004q3kxmux3af0umn83wecgpyx6uct6w08pu7pffmtkmappjk06ql8
static immutable ARE = KeyPair(PublicKey(Point([250, 60, 189, 245, 4, 108, 109, 240, 209, 234, 95, 205, 204, 241, 118, 112, 128, 144, 218, 230, 23, 167, 60, 225, 231, 130, 148, 237, 118, 223, 66, 25])), SecretKey(Scalar([59, 234, 147, 81, 59, 162, 159, 109, 53, 7, 237, 75, 200, 204, 2, 108, 173, 51, 64, 244, 28, 83, 21, 49, 11, 54, 185, 165, 89, 243, 158, 8])));
/// ARF: boa1xzarf00n69598yqdmmz5mzfud5a52j00jgfdx7vh4k504jv78w93zxgkg4h
static immutable ARF = KeyPair(PublicKey(Point([186, 52, 189, 243, 209, 104, 83, 144, 13, 222, 197, 77, 137, 60, 109, 59, 69, 73, 239, 146, 18, 211, 121, 151, 173, 168, 250, 201, 158, 59, 139, 17])), SecretKey(Scalar([99, 149, 113, 130, 62, 133, 136, 12, 178, 243, 15, 113, 107, 157, 23, 70, 90, 178, 129, 243, 207, 170, 66, 223, 68, 29, 53, 11, 40, 150, 28, 3])));
/// ARG: boa1xzarg00xpn7aqvx4kwj6tpkny5tvgr5cgxhw8qztf5l5z8e928waz2hv272
static immutable ARG = KeyPair(PublicKey(Point([186, 52, 61, 230, 12, 253, 208, 48, 213, 179, 165, 165, 134, 211, 37, 22, 196, 14, 152, 65, 174, 227, 128, 75, 77, 63, 65, 31, 37, 81, 221, 209])), SecretKey(Scalar([69, 250, 43, 141, 96, 92, 80, 99, 81, 25, 48, 138, 199, 83, 95, 63, 90, 209, 114, 103, 59, 210, 29, 217, 246, 204, 63, 255, 247, 140, 121, 5])));
/// ARH: boa1xqarh00a3z9pcth5vt6v5vtkm65ghgaqk7l8ter4apv543yzfcqgcghrr8z
static immutable ARH = KeyPair(PublicKey(Point([58, 59, 189, 253, 136, 138, 28, 46, 244, 98, 244, 202, 49, 118, 222, 168, 139, 163, 160, 183, 190, 117, 228, 117, 232, 89, 74, 196, 130, 78, 0, 140])), SecretKey(Scalar([130, 52, 63, 17, 92, 174, 54, 120, 138, 173, 12, 94, 235, 39, 13, 115, 40, 109, 221, 125, 48, 137, 197, 112, 51, 39, 106, 138, 177, 24, 49, 2])));
/// ARJ: boa1xqarj00ta5zatu6lntvhfh746mktd87q9sa7m4srh68vdmxjqkwtkhljr69
static immutable ARJ = KeyPair(PublicKey(Point([58, 57, 61, 235, 237, 5, 213, 243, 95, 154, 217, 116, 223, 213, 214, 236, 182, 159, 192, 44, 59, 237, 214, 3, 190, 142, 198, 236, 210, 5, 156, 187])), SecretKey(Scalar([71, 78, 52, 157, 150, 71, 149, 150, 223, 99, 188, 110, 177, 235, 242, 207, 108, 73, 232, 98, 146, 53, 121, 29, 46, 239, 96, 111, 244, 238, 226, 10])));
/// ARK: boa1xrark00m5pn9mgktzzra44gt5ytmul7zlzqlt309r6h2x9jd777xjn8vxjv
static immutable ARK = KeyPair(PublicKey(Point([250, 59, 61, 251, 160, 102, 93, 162, 203, 16, 135, 218, 213, 11, 161, 23, 190, 127, 194, 248, 129, 245, 197, 229, 30, 174, 163, 22, 77, 247, 188, 105])), SecretKey(Scalar([10, 121, 213, 39, 27, 20, 230, 22, 133, 50, 41, 101, 63, 57, 47, 17, 135, 119, 88, 186, 184, 131, 34, 24, 109, 18, 227, 243, 69, 146, 16, 9])));
/// ARL: boa1xparl00ghmujzcsrt8jacj06sdq002s3s4uljceqn98awvy4vsya5qmvqvu
static immutable ARL = KeyPair(PublicKey(Point([122, 63, 189, 232, 190, 249, 33, 98, 3, 89, 229, 220, 73, 250, 131, 64, 247, 170, 17, 133, 121, 249, 99, 32, 153, 79, 215, 48, 149, 100, 9, 218])), SecretKey(Scalar([2, 4, 255, 16, 11, 79, 187, 243, 254, 213, 113, 255, 14, 98, 102, 193, 167, 207, 217, 19, 164, 51, 132, 119, 107, 231, 174, 154, 182, 44, 79, 10])));
/// ARM: boa1xparm009ug63y6j7m2x02jc7qj6c9twty8jvsmyhhdvm9raqg9kvc27amhh
static immutable ARM = KeyPair(PublicKey(Point([122, 61, 189, 229, 226, 53, 18, 106, 94, 218, 140, 245, 75, 30, 4, 181, 130, 173, 203, 33, 228, 200, 108, 151, 187, 89, 178, 143, 160, 65, 108, 204])), SecretKey(Scalar([125, 150, 239, 136, 149, 250, 79, 191, 216, 156, 2, 196, 224, 105, 254, 14, 209, 137, 251, 48, 161, 163, 132, 201, 4, 1, 120, 230, 54, 124, 132, 12])));
/// ARN: boa1xrarn00m9kl4y0u2emkcnhhazt7uwx3qpdl5j46txewrkz3e8lzmkh7h08y
static immutable ARN = KeyPair(PublicKey(Point([250, 57, 189, 251, 45, 191, 82, 63, 138, 206, 237, 137, 222, 253, 18, 253, 199, 26, 32, 11, 127, 73, 87, 75, 54, 92, 59, 10, 57, 63, 197, 187])), SecretKey(Scalar([148, 201, 186, 168, 207, 252, 61, 8, 21, 39, 117, 143, 5, 233, 132, 100, 123, 118, 75, 80, 38, 135, 32, 179, 234, 15, 76, 61, 158, 188, 164, 1])));
/// ARP: boa1xrarp00j0m4qp5qt4ufg52ru469vstp68pelnrnxqr9s5l953tlp6l3n3h4
static immutable ARP = KeyPair(PublicKey(Point([250, 48, 189, 242, 126, 234, 0, 208, 11, 175, 18, 138, 40, 124, 174, 138, 200, 44, 58, 56, 115, 249, 142, 102, 0, 203, 10, 124, 180, 138, 254, 29])), SecretKey(Scalar([60, 87, 120, 36, 203, 31, 99, 47, 100, 97, 123, 80, 90, 98, 0, 169, 18, 158, 17, 161, 127, 198, 148, 133, 88, 8, 116, 152, 170, 93, 110, 14])));
/// ARQ: boa1xrarq004gwkhwz6wqen766svjvdxnn396dr3y0dm4lk2elw8wfr0cxfxva5
static immutable ARQ = KeyPair(PublicKey(Point([250, 48, 61, 245, 67, 173, 119, 11, 78, 6, 103, 237, 106, 12, 147, 26, 105, 206, 37, 211, 71, 18, 61, 187, 175, 236, 172, 253, 199, 114, 70, 252])), SecretKey(Scalar([226, 49, 47, 190, 243, 171, 83, 166, 238, 143, 45, 128, 132, 251, 66, 245, 24, 238, 224, 183, 31, 42, 236, 234, 116, 129, 182, 86, 214, 99, 42, 10])));
/// ARR: boa1xqarr00jd4a8xm4v7pldqjhda45qve4xghtet5wjm70azd6ney35zfj8z0y
static immutable ARR = KeyPair(PublicKey(Point([58, 49, 189, 242, 109, 122, 115, 110, 172, 240, 126, 208, 74, 237, 237, 104, 6, 102, 166, 69, 215, 149, 209, 210, 223, 159, 209, 55, 83, 201, 35, 65])), SecretKey(Scalar([134, 206, 190, 245, 149, 210, 208, 149, 48, 199, 60, 95, 232, 172, 147, 245, 165, 44, 248, 21, 226, 55, 119, 21, 180, 79, 147, 105, 77, 19, 47, 9])));
/// ARS: boa1xrars00y4lpdns4pv28cu33hdqtwd6mm6m00cfm7cyp5wg3vg63ycvccddp
static immutable ARS = KeyPair(PublicKey(Point([250, 56, 61, 228, 175, 194, 217, 194, 161, 98, 143, 142, 70, 55, 104, 22, 230, 235, 123, 214, 222, 252, 39, 126, 193, 3, 71, 34, 44, 70, 162, 76])), SecretKey(Scalar([210, 36, 46, 103, 116, 214, 200, 212, 24, 85, 188, 130, 46, 81, 196, 248, 16, 172, 160, 132, 232, 105, 141, 230, 114, 51, 137, 43, 242, 28, 143, 4])));
/// ART: boa1xpart006ge6mdm5fwnzhwtguc3sc7hq0ndqgu7wwufces9a0kd4xu9d5703
static immutable ART = KeyPair(PublicKey(Point([122, 53, 189, 250, 70, 117, 182, 238, 137, 116, 197, 119, 45, 28, 196, 97, 143, 92, 15, 155, 64, 142, 121, 206, 226, 113, 152, 23, 175, 179, 106, 110])), SecretKey(Scalar([168, 74, 183, 196, 200, 24, 12, 14, 108, 26, 73, 245, 122, 178, 127, 202, 105, 35, 25, 75, 121, 189, 78, 232, 106, 204, 34, 81, 217, 211, 194, 14])));
/// ARU: boa1xzaru00f4hflc2vjle2gp70qfwe8q56esw2w450h5xjsh5rse2sscwyxmka
static immutable ARU = KeyPair(PublicKey(Point([186, 62, 61, 233, 173, 211, 252, 41, 146, 254, 84, 128, 249, 224, 75, 178, 112, 83, 89, 131, 148, 234, 209, 247, 161, 165, 11, 208, 112, 202, 161, 12])), SecretKey(Scalar([120, 93, 80, 97, 2, 15, 223, 33, 79, 30, 141, 14, 51, 55, 68, 160, 6, 7, 103, 61, 141, 213, 44, 214, 203, 240, 12, 121, 181, 77, 255, 4])));
/// ARV: boa1xrarv00ew8fwpk8e6aqn89cdnvsx7av3racl5vk5r79kutj75djjvfgy95w
static immutable ARV = KeyPair(PublicKey(Point([250, 54, 61, 249, 113, 210, 224, 216, 249, 215, 65, 51, 151, 13, 155, 32, 111, 117, 145, 31, 113, 250, 50, 212, 31, 139, 110, 46, 94, 163, 101, 38])), SecretKey(Scalar([88, 9, 247, 50, 14, 216, 65, 51, 47, 205, 238, 93, 151, 66, 221, 197, 181, 33, 90, 182, 24, 223, 154, 6, 184, 171, 17, 68, 174, 96, 65, 13])));
/// ARW: boa1xparw00n7mzdfasjtkpwev3nfc2fuuxyeqpxvkz764qattv594uukr5xefe
static immutable ARW = KeyPair(PublicKey(Point([122, 55, 61, 243, 246, 196, 212, 246, 18, 93, 130, 236, 178, 51, 78, 20, 158, 112, 196, 200, 2, 102, 88, 94, 213, 65, 213, 173, 148, 45, 121, 203])), SecretKey(Scalar([66, 132, 236, 49, 243, 72, 149, 108, 113, 158, 201, 214, 48, 49, 183, 179, 223, 163, 42, 217, 186, 148, 127, 86, 89, 134, 151, 187, 250, 160, 45, 15])));
/// ARX: boa1xzarx00u9t04ue6sky9c9c3ck5q0vswhykh5f0uk69cnrr0s5crlwa60gr7
static immutable ARX = KeyPair(PublicKey(Point([186, 51, 61, 252, 42, 223, 94, 103, 80, 177, 11, 130, 226, 56, 181, 0, 246, 65, 215, 37, 175, 68, 191, 150, 209, 113, 49, 141, 240, 166, 7, 247])), SecretKey(Scalar([60, 196, 246, 59, 218, 133, 193, 108, 38, 134, 159, 235, 100, 31, 193, 17, 62, 129, 208, 108, 212, 59, 128, 183, 86, 215, 17, 73, 72, 20, 206, 3])));
/// ARY: boa1xpary00a0eeuqs86e9ulpzvarkrzsmn79uc2jnazgnmgqz4pnjc072x3jw6
static immutable ARY = KeyPair(PublicKey(Point([122, 50, 61, 253, 126, 115, 192, 64, 250, 201, 121, 240, 137, 157, 29, 134, 40, 110, 126, 47, 48, 169, 79, 162, 68, 246, 128, 10, 161, 156, 176, 255])), SecretKey(Scalar([103, 34, 16, 255, 46, 236, 109, 61, 137, 221, 96, 26, 118, 202, 240, 5, 38, 209, 53, 186, 157, 185, 193, 255, 161, 152, 12, 236, 30, 132, 161, 15])));
/// ARZ: boa1xrarz009h9sre0f8wdef8as9u4w466hp2ksxv7ljawyrx5v6pxgtkr8cf22
static immutable ARZ = KeyPair(PublicKey(Point([250, 49, 61, 229, 185, 96, 60, 189, 39, 115, 114, 147, 246, 5, 229, 93, 93, 106, 225, 85, 160, 102, 123, 242, 235, 136, 51, 81, 154, 9, 144, 187])), SecretKey(Scalar([251, 206, 211, 139, 16, 45, 254, 192, 17, 107, 93, 4, 214, 88, 18, 168, 118, 100, 40, 187, 140, 229, 190, 165, 88, 154, 131, 142, 135, 109, 107, 11])));
/// ASA: boa1xpasa00kwre5tyr7qqjms6aaze4y5nxezh7ytfn6vv8gzhhw7nhhxq7ry37
static immutable ASA = KeyPair(PublicKey(Point([123, 14, 189, 246, 112, 243, 69, 144, 126, 0, 37, 184, 107, 189, 22, 106, 74, 76, 217, 21, 252, 69, 166, 122, 99, 14, 129, 94, 238, 244, 239, 115])), SecretKey(Scalar([159, 212, 137, 77, 50, 242, 199, 206, 123, 74, 101, 235, 239, 11, 1, 70, 21, 116, 23, 179, 89, 71, 248, 209, 124, 231, 187, 94, 57, 41, 212, 3])));
/// ASC: boa1xpasc00m6sjrnph0hj6t96s5remswra2wu90nt0xfpeamtlff8yyc25r4m4
static immutable ASC = KeyPair(PublicKey(Point([123, 12, 61, 251, 212, 36, 57, 134, 239, 188, 180, 178, 234, 20, 30, 119, 7, 15, 170, 119, 10, 249, 173, 230, 72, 115, 221, 175, 233, 73, 200, 76])), SecretKey(Scalar([112, 122, 210, 82, 26, 78, 152, 180, 35, 12, 140, 87, 146, 159, 49, 131, 18, 219, 249, 100, 0, 14, 209, 220, 94, 235, 61, 24, 174, 193, 37, 3])));
/// ASD: boa1xpasd00df4cry4yl0hy8sprnd9afqxwekdx2u3hhnyvw8s060glevx3v99x
static immutable ASD = KeyPair(PublicKey(Point([123, 6, 189, 237, 77, 112, 50, 84, 159, 125, 200, 120, 4, 115, 105, 122, 144, 25, 217, 179, 76, 174, 70, 247, 153, 24, 227, 193, 250, 122, 63, 150])), SecretKey(Scalar([220, 35, 110, 225, 216, 24, 195, 106, 195, 172, 227, 233, 167, 43, 251, 211, 51, 22, 70, 251, 130, 18, 248, 238, 182, 62, 120, 103, 158, 58, 66, 15])));
/// ASE: boa1xqase00dtwk3dutl0c8k7pg4mkax5xswc23fc8cj56a9u6e0qj4a2uqjl00
static immutable ASE = KeyPair(PublicKey(Point([59, 12, 189, 237, 91, 173, 22, 241, 127, 126, 15, 111, 5, 21, 221, 186, 106, 26, 14, 194, 162, 156, 31, 18, 166, 186, 94, 107, 47, 4, 171, 213])), SecretKey(Scalar([43, 32, 102, 140, 220, 238, 51, 106, 178, 118, 229, 119, 130, 85, 216, 129, 50, 201, 102, 102, 81, 34, 224, 166, 222, 92, 162, 192, 95, 64, 144, 13])));
/// ASF: boa1xqasf00xr7aqqfqtav6kvhr0vraxcme028jtehnl66acy7fhy2grxdlymj7
static immutable ASF = KeyPair(PublicKey(Point([59, 4, 189, 230, 31, 186, 0, 36, 11, 235, 53, 102, 92, 111, 96, 250, 108, 111, 47, 81, 228, 188, 222, 127, 214, 187, 130, 121, 55, 34, 144, 51])), SecretKey(Scalar([173, 187, 154, 88, 163, 87, 215, 6, 239, 251, 247, 128, 253, 192, 109, 126, 185, 83, 33, 250, 37, 180, 131, 245, 12, 128, 39, 69, 201, 231, 224, 8])));
/// ASG: boa1xzasg00mfg88wv5gm04zw2d3d95zq7mrya8j5ldujl07hplpjljl7fl2uhy
static immutable ASG = KeyPair(PublicKey(Point([187, 4, 61, 251, 74, 14, 119, 50, 136, 219, 234, 39, 41, 177, 105, 104, 32, 123, 99, 39, 79, 42, 125, 188, 151, 223, 235, 135, 225, 151, 229, 255])), SecretKey(Scalar([24, 1, 229, 106, 64, 73, 72, 110, 237, 248, 1, 255, 81, 200, 202, 84, 171, 211, 154, 34, 102, 45, 238, 62, 190, 199, 197, 122, 191, 172, 32, 1])));
/// ASH: boa1xzash00cqp7z88hlpe7z3tl6tg4z4z6zn4qsau8fzmcuwdmzl7vzc20qqr6
static immutable ASH = KeyPair(PublicKey(Point([187, 11, 189, 248, 0, 124, 35, 158, 255, 14, 124, 40, 175, 250, 90, 42, 42, 139, 66, 157, 65, 14, 240, 233, 22, 241, 199, 55, 98, 255, 152, 44])), SecretKey(Scalar([55, 53, 177, 89, 101, 21, 228, 134, 167, 211, 148, 58, 51, 36, 83, 164, 80, 176, 141, 178, 54, 74, 169, 228, 90, 67, 61, 17, 252, 51, 178, 1])));
/// ASJ: boa1xpasj00etslygpvjryfrskq4c636lty3r7an6y68argq9cv4ngh2z83angg
static immutable ASJ = KeyPair(PublicKey(Point([123, 9, 61, 249, 92, 62, 68, 5, 146, 25, 18, 56, 88, 21, 198, 163, 175, 172, 145, 31, 187, 61, 19, 71, 232, 208, 2, 225, 149, 154, 46, 161])), SecretKey(Scalar([166, 113, 252, 235, 122, 66, 245, 61, 101, 45, 159, 19, 169, 78, 68, 1, 125, 237, 82, 114, 28, 146, 115, 108, 51, 176, 51, 133, 240, 171, 202, 0])));
/// ASK: boa1xqask00arzaeprnaut5f9m4qvaye8e0ykhndhqf9hvuxf4c5nq9dxdl5cj9
static immutable ASK = KeyPair(PublicKey(Point([59, 11, 61, 253, 24, 187, 144, 142, 125, 226, 232, 146, 238, 160, 103, 73, 147, 229, 228, 181, 230, 219, 129, 37, 187, 56, 100, 215, 20, 152, 10, 211])), SecretKey(Scalar([76, 146, 203, 198, 45, 16, 175, 14, 12, 168, 92, 37, 105, 170, 120, 108, 138, 86, 133, 19, 152, 173, 60, 43, 49, 4, 238, 220, 240, 35, 249, 10])));
/// ASL: boa1xpasl00x825qulatg4nn7e26ytgwf77thmuyj0hzn5ujmda54satcmzn6tw
static immutable ASL = KeyPair(PublicKey(Point([123, 15, 189, 230, 58, 168, 14, 127, 171, 69, 103, 63, 101, 90, 34, 208, 228, 251, 203, 190, 248, 73, 62, 226, 157, 57, 45, 183, 180, 172, 58, 188])), SecretKey(Scalar([75, 233, 29, 242, 7, 140, 85, 109, 174, 134, 226, 115, 66, 51, 231, 210, 82, 178, 198, 216, 157, 165, 206, 1, 179, 148, 158, 174, 212, 160, 214, 5])));
/// ASM: boa1xqasm008c762p5ljxqj0ypx8kdgfs3f00p6xm7qx9zdyfgdhwhy4s8jxqcr
static immutable ASM = KeyPair(PublicKey(Point([59, 13, 189, 231, 199, 180, 160, 211, 242, 48, 36, 242, 4, 199, 179, 80, 152, 69, 47, 120, 116, 109, 248, 6, 40, 154, 68, 161, 183, 117, 201, 88])), SecretKey(Scalar([135, 170, 240, 18, 59, 148, 47, 136, 72, 59, 128, 171, 208, 95, 17, 60, 33, 253, 93, 132, 175, 150, 58, 144, 180, 215, 192, 109, 50, 15, 36, 8])));
/// ASN: boa1xqasn00ztewrf2930c00zvt7jlsnpngx7fvvz36m4v6ehjhfgdgmwpghrfa
static immutable ASN = KeyPair(PublicKey(Point([59, 9, 189, 226, 94, 92, 52, 168, 177, 126, 30, 241, 49, 126, 151, 225, 48, 205, 6, 242, 88, 193, 71, 91, 171, 53, 155, 202, 233, 67, 81, 183])), SecretKey(Scalar([91, 73, 44, 236, 167, 239, 128, 161, 38, 22, 5, 166, 183, 158, 97, 17, 193, 185, 46, 233, 215, 181, 50, 163, 68, 76, 198, 88, 61, 206, 81, 13])));
/// ASP: boa1xpasp00jxcjzdju95aghcna7pdrznfcqjh9xjj3gkuwe29cguzf62nasee8
static immutable ASP = KeyPair(PublicKey(Point([123, 0, 189, 242, 54, 36, 38, 203, 133, 167, 81, 124, 79, 190, 11, 70, 41, 167, 0, 149, 202, 105, 74, 40, 183, 29, 149, 23, 8, 224, 147, 165])), SecretKey(Scalar([229, 157, 107, 161, 224, 234, 99, 121, 35, 122, 101, 217, 48, 139, 78, 124, 234, 116, 197, 55, 148, 69, 146, 23, 66, 62, 35, 53, 241, 73, 107, 15])));
/// ASQ: boa1xrasq00vpuj3lhthve5m7g8xacvkma59kvd3ezu7uhquqw6qg20675h99gj
static immutable ASQ = KeyPair(PublicKey(Point([251, 0, 61, 236, 15, 37, 31, 221, 119, 102, 105, 191, 32, 230, 238, 25, 109, 246, 133, 179, 27, 28, 139, 158, 229, 193, 192, 59, 64, 66, 159, 175])), SecretKey(Scalar([229, 251, 98, 79, 128, 205, 254, 190, 153, 135, 197, 114, 192, 54, 101, 119, 12, 138, 181, 116, 41, 191, 92, 104, 134, 145, 87, 141, 163, 174, 146, 10])));
/// ASR: boa1xpasr00u62l0330vwyvvgw8f36hflrgsays8qa45eyekjnxugwfq7x3nvkl
static immutable ASR = KeyPair(PublicKey(Point([123, 1, 189, 252, 210, 190, 248, 197, 236, 113, 24, 196, 56, 233, 142, 174, 159, 141, 16, 233, 32, 112, 118, 180, 201, 51, 105, 76, 220, 67, 146, 15])), SecretKey(Scalar([38, 119, 48, 80, 89, 79, 154, 194, 185, 43, 22, 112, 56, 204, 48, 178, 161, 19, 100, 201, 244, 123, 229, 79, 233, 67, 193, 58, 209, 73, 250, 1])));
/// ASS: boa1xpass00kyvtfauqmt4vjcynrztgwruh85vvc8ftj2jxjscc5wrntydasq5y
static immutable ASS = KeyPair(PublicKey(Point([123, 8, 61, 246, 35, 22, 158, 240, 27, 93, 89, 44, 18, 99, 18, 208, 225, 242, 231, 163, 25, 131, 165, 114, 84, 141, 40, 99, 20, 112, 230, 178])), SecretKey(Scalar([149, 141, 99, 247, 14, 112, 83, 213, 240, 175, 168, 177, 41, 220, 201, 228, 167, 82, 209, 215, 9, 102, 211, 1, 218, 135, 64, 28, 107, 84, 188, 14])));
/// AST: boa1xrast00vxdveln4478y7f75kzg4pnuthfc8xmfvn576zh03kat7lvh2gzq0
static immutable AST = KeyPair(PublicKey(Point([251, 5, 189, 236, 51, 89, 159, 206, 181, 241, 201, 228, 250, 150, 18, 42, 25, 241, 119, 78, 14, 109, 165, 147, 167, 180, 43, 190, 54, 234, 253, 246])), SecretKey(Scalar([198, 227, 217, 172, 161, 133, 230, 35, 97, 161, 186, 188, 142, 35, 88, 19, 75, 167, 76, 76, 204, 211, 20, 30, 45, 17, 242, 199, 148, 171, 210, 10])));
/// ASU: boa1xzasu005yeq7fapma4nrzlgvytzuaddk7uuqagk2t49zgst5a2lsyhknd4q
static immutable ASU = KeyPair(PublicKey(Point([187, 14, 61, 244, 38, 65, 228, 244, 59, 237, 102, 49, 125, 12, 34, 197, 206, 181, 182, 247, 56, 14, 162, 202, 93, 74, 36, 65, 116, 234, 191, 2])), SecretKey(Scalar([242, 163, 89, 159, 75, 160, 251, 231, 186, 96, 113, 67, 197, 153, 142, 5, 245, 139, 100, 1, 23, 135, 180, 108, 138, 138, 23, 157, 200, 38, 206, 14])));
/// ASV: boa1xrasv00ew9fhu8ed9fmn677h6vcus5anju669hqx78zffssjc8qvsgegffu
static immutable ASV = KeyPair(PublicKey(Point([251, 6, 61, 249, 113, 83, 126, 31, 45, 42, 119, 61, 123, 215, 211, 49, 200, 83, 179, 151, 53, 162, 220, 6, 241, 196, 148, 194, 18, 193, 192, 200])), SecretKey(Scalar([145, 120, 17, 9, 6, 185, 253, 5, 128, 204, 115, 204, 104, 173, 65, 149, 126, 163, 120, 205, 82, 92, 63, 196, 96, 63, 161, 220, 237, 174, 195, 13])));
/// ASW: boa1xpasw00e3k7xc4qelc4jh9juy35q9dsz0gvvdk2snxlt58xpkqwn7qyep6x
static immutable ASW = KeyPair(PublicKey(Point([123, 7, 61, 249, 141, 188, 108, 84, 25, 254, 43, 43, 150, 92, 36, 104, 2, 182, 2, 122, 24, 198, 217, 80, 153, 190, 186, 28, 193, 176, 29, 63])), SecretKey(Scalar([95, 96, 10, 65, 234, 245, 73, 178, 3, 95, 144, 22, 191, 243, 217, 233, 148, 28, 30, 52, 32, 123, 114, 132, 29, 157, 198, 147, 60, 250, 51, 9])));
/// ASX: boa1xrasx003wu59dg0up5nt0cvqfg9wlyrfsvuehkr8x4huqjhnqyxcy03rek5
static immutable ASX = KeyPair(PublicKey(Point([251, 3, 61, 241, 119, 40, 86, 161, 252, 13, 38, 183, 225, 128, 74, 10, 239, 144, 105, 131, 57, 155, 216, 103, 53, 111, 192, 74, 243, 1, 13, 130])), SecretKey(Scalar([28, 168, 246, 37, 56, 87, 177, 24, 29, 200, 77, 122, 149, 243, 71, 111, 239, 222, 106, 57, 255, 173, 201, 110, 88, 167, 126, 88, 148, 147, 27, 1])));
/// ASY: boa1xpasy00rz4erd9hdkfx84kduehwwfh27v89ex93728lfa4l4u9w6zrjneq9
static immutable ASY = KeyPair(PublicKey(Point([123, 2, 61, 227, 21, 114, 54, 150, 237, 178, 76, 122, 217, 188, 205, 220, 228, 221, 94, 97, 203, 147, 22, 62, 81, 254, 158, 215, 245, 225, 93, 161])), SecretKey(Scalar([3, 40, 101, 82, 125, 77, 244, 98, 71, 250, 83, 10, 225, 181, 136, 34, 169, 202, 93, 205, 149, 20, 186, 124, 104, 67, 29, 154, 229, 236, 243, 8])));
/// ASZ: boa1xqasz00xqefndcw5dkrh3prexkkfxnlpev3zp6z8d35l34uej5lmz66xsuq
static immutable ASZ = KeyPair(PublicKey(Point([59, 1, 61, 230, 6, 83, 54, 225, 212, 109, 135, 120, 132, 121, 53, 172, 147, 79, 225, 203, 34, 32, 232, 71, 108, 105, 248, 215, 153, 149, 63, 177])), SecretKey(Scalar([44, 209, 216, 251, 208, 148, 243, 6, 235, 98, 36, 71, 213, 157, 55, 139, 12, 228, 100, 43, 241, 222, 127, 183, 38, 133, 129, 134, 220, 202, 128, 4])));
/// ATA: boa1xqata00haa0z6whkp0z6j4w90yhmcqtt09xvd42m6nxve7qpaa8m2elhlfp
static immutable ATA = KeyPair(PublicKey(Point([58, 190, 189, 247, 239, 94, 45, 58, 246, 11, 197, 169, 85, 197, 121, 47, 188, 1, 107, 121, 76, 198, 213, 91, 212, 204, 204, 248, 1, 239, 79, 181])), SecretKey(Scalar([29, 66, 252, 141, 159, 13, 169, 77, 158, 255, 207, 164, 241, 208, 32, 142, 184, 30, 27, 251, 104, 105, 65, 215, 56, 17, 2, 82, 133, 116, 55, 3])));
/// ATC: boa1xzatc00956rhx4mc8mt4t3cugkkcl0jhjn8uppa0vwf5t6qwxyv8j085zkf
static immutable ATC = KeyPair(PublicKey(Point([186, 188, 61, 229, 166, 135, 115, 87, 120, 62, 215, 85, 199, 28, 69, 173, 143, 190, 87, 148, 207, 192, 135, 175, 99, 147, 69, 232, 14, 49, 24, 121])), SecretKey(Scalar([226, 39, 35, 79, 18, 243, 195, 139, 166, 162, 110, 62, 76, 9, 75, 96, 229, 207, 64, 29, 143, 229, 79, 110, 26, 17, 33, 134, 215, 144, 231, 2])));
/// ATD: boa1xratd00p4dkm9efdnuzdcvzq6u5wgww57k04u5xef3wsl32w8w3zj0rc086
static immutable ATD = KeyPair(PublicKey(Point([250, 182, 189, 225, 171, 109, 178, 229, 45, 159, 4, 220, 48, 64, 215, 40, 228, 57, 212, 245, 159, 94, 80, 217, 76, 93, 15, 197, 78, 59, 162, 41])), SecretKey(Scalar([124, 167, 66, 236, 230, 218, 26, 209, 213, 83, 152, 55, 160, 226, 59, 201, 117, 106, 39, 75, 252, 18, 116, 234, 24, 65, 70, 246, 56, 134, 40, 7])));
/// ATE: boa1xrate00e42lzmfqqp379fhsg54jsle4ehnfqgd6ah8cs46sd4fqkvrlylzf
static immutable ATE = KeyPair(PublicKey(Point([250, 188, 189, 249, 170, 190, 45, 164, 0, 12, 124, 84, 222, 8, 165, 101, 15, 230, 185, 188, 210, 4, 55, 93, 185, 241, 10, 234, 13, 170, 65, 102])), SecretKey(Scalar([76, 21, 129, 129, 145, 186, 69, 5, 198, 227, 201, 38, 10, 188, 145, 2, 57, 4, 25, 99, 121, 230, 231, 140, 29, 230, 170, 194, 223, 163, 56, 3])));
/// ATF: boa1xqatf00rmvrncmgky9t55jzvtq5r98puhg0kth5v2e2dxnavxkdlvjygqtf
static immutable ATF = KeyPair(PublicKey(Point([58, 180, 189, 227, 219, 7, 60, 109, 22, 33, 87, 74, 72, 76, 88, 40, 50, 156, 60, 186, 31, 101, 222, 140, 86, 84, 211, 79, 172, 53, 155, 246])), SecretKey(Scalar([199, 234, 173, 222, 106, 252, 122, 153, 79, 160, 201, 26, 198, 132, 55, 111, 214, 59, 242, 130, 116, 175, 140, 90, 18, 34, 250, 11, 242, 70, 135, 1])));
/// ATG: boa1xqatg00ggquke2xuqe5fkkjzgu4tpv3jryfcs74gjatzgrcd4mefw8d2750
static immutable ATG = KeyPair(PublicKey(Point([58, 180, 61, 232, 64, 57, 108, 168, 220, 6, 104, 155, 90, 66, 71, 42, 176, 178, 50, 25, 19, 136, 122, 168, 151, 86, 36, 15, 13, 174, 242, 151])), SecretKey(Scalar([251, 204, 80, 59, 127, 138, 230, 79, 90, 94, 119, 171, 225, 48, 114, 18, 127, 124, 179, 239, 201, 125, 221, 159, 48, 25, 206, 67, 232, 240, 125, 14])));
/// ATH: boa1xzath00mpgc8yu6y3a2mrsldveng8n3lzjn0vm9fuwz5c7w43whfks83pwq
static immutable ATH = KeyPair(PublicKey(Point([186, 187, 189, 251, 10, 48, 114, 115, 68, 143, 85, 177, 195, 237, 102, 102, 131, 206, 63, 20, 166, 246, 108, 169, 227, 133, 76, 121, 213, 139, 174, 155])), SecretKey(Scalar([255, 160, 58, 103, 169, 224, 220, 34, 105, 238, 208, 186, 135, 231, 173, 6, 81, 72, 9, 109, 180, 67, 93, 124, 102, 6, 78, 52, 64, 59, 1, 14])));
/// ATJ: boa1xpatj00ck33pen3d9peqxnv8cvve85k6cdxcy4v57revv956nq9l5vrmw0g
static immutable ATJ = KeyPair(PublicKey(Point([122, 185, 61, 248, 180, 98, 28, 206, 45, 40, 114, 3, 77, 135, 195, 25, 147, 210, 218, 195, 77, 130, 85, 148, 240, 242, 198, 22, 154, 152, 11, 250])), SecretKey(Scalar([1, 66, 113, 247, 4, 165, 238, 221, 101, 30, 41, 186, 11, 93, 249, 251, 16, 47, 188, 47, 26, 165, 239, 81, 188, 169, 45, 221, 14, 38, 169, 5])));
/// ATK: boa1xqatk008fazcjkrrmpldwl7ytp5r6mlh8pglu4kzr4pz65jxc0da2qy43nl
static immutable ATK = KeyPair(PublicKey(Point([58, 187, 61, 231, 79, 69, 137, 88, 99, 216, 126, 215, 127, 196, 88, 104, 61, 111, 247, 56, 81, 254, 86, 194, 29, 66, 45, 82, 70, 195, 219, 213])), SecretKey(Scalar([98, 25, 159, 70, 117, 239, 128, 182, 101, 202, 107, 115, 197, 185, 47, 162, 115, 55, 183, 142, 23, 35, 165, 229, 221, 39, 119, 225, 134, 61, 211, 6])));
/// ATL: boa1xzatl002rrtwu533u3zhh55jfm8zrzk0tx8lvrtsj8ue7g0l975rufkr9y0
static immutable ATL = KeyPair(PublicKey(Point([186, 191, 189, 234, 24, 214, 238, 82, 49, 228, 69, 123, 210, 146, 78, 206, 33, 138, 207, 89, 143, 246, 13, 112, 145, 249, 159, 33, 255, 47, 168, 62])), SecretKey(Scalar([126, 229, 130, 172, 249, 99, 253, 93, 177, 227, 117, 194, 237, 216, 92, 74, 228, 213, 248, 246, 80, 227, 58, 39, 134, 91, 86, 77, 147, 57, 115, 4])));
/// ATM: boa1xpatm00um7em8fqvjvp8a4x6kp5cr8r3mdc047evnec7jzx3gg5x2jj23lw
static immutable ATM = KeyPair(PublicKey(Point([122, 189, 189, 252, 223, 179, 179, 164, 12, 147, 2, 126, 212, 218, 176, 105, 129, 156, 113, 219, 112, 250, 251, 44, 158, 113, 233, 8, 209, 66, 40, 101])), SecretKey(Scalar([29, 134, 204, 21, 239, 130, 148, 40, 2, 70, 110, 223, 57, 194, 126, 48, 215, 67, 249, 179, 47, 18, 123, 74, 71, 90, 86, 105, 113, 203, 33, 9])));
/// ATN: boa1xqatn00zwsfhdtzcsanczj4gwjvksapqe9xcccxjtwfw3fzuralp6vswngl
static immutable ATN = KeyPair(PublicKey(Point([58, 185, 189, 226, 116, 19, 118, 172, 88, 135, 103, 129, 74, 168, 116, 153, 104, 116, 32, 201, 77, 140, 96, 210, 91, 146, 232, 164, 92, 31, 126, 29])), SecretKey(Scalar([1, 237, 106, 162, 91, 11, 182, 17, 133, 16, 43, 223, 153, 151, 10, 80, 95, 239, 55, 165, 201, 31, 86, 15, 184, 215, 46, 6, 246, 169, 86, 12])));
/// ATP: boa1xzatp00cfdr0ny7d3zuzmfjswcwe55kvmawzuzmxpmcu98sucgwdqu5traz
static immutable ATP = KeyPair(PublicKey(Point([186, 176, 189, 248, 75, 70, 249, 147, 205, 136, 184, 45, 166, 80, 118, 29, 154, 82, 204, 223, 92, 46, 11, 102, 14, 241, 194, 158, 28, 194, 28, 208])), SecretKey(Scalar([213, 184, 217, 37, 157, 63, 205, 121, 124, 238, 181, 22, 53, 184, 178, 59, 66, 194, 180, 240, 196, 239, 189, 91, 118, 27, 200, 177, 109, 12, 84, 12])));
/// ATQ: boa1xpatq00hjw2pce2k93l6emkxewqmklxjjvqt4awtmdp2twvzv0l0zm9d8zj
static immutable ATQ = KeyPair(PublicKey(Point([122, 176, 61, 247, 147, 148, 28, 101, 86, 44, 127, 172, 238, 198, 203, 129, 187, 124, 210, 147, 0, 186, 245, 203, 219, 66, 165, 185, 130, 99, 254, 241])), SecretKey(Scalar([47, 108, 132, 33, 56, 127, 126, 191, 200, 221, 101, 190, 118, 145, 141, 249, 136, 146, 13, 149, 145, 75, 136, 225, 107, 39, 28, 8, 32, 99, 79, 2])));
/// ATR: boa1xratr00kpnaxpz2undzkfv866ychyj56ar3vj6gytxhqlzuejgfpvn7rdrl
static immutable ATR = KeyPair(PublicKey(Point([250, 177, 189, 246, 12, 250, 96, 137, 92, 155, 69, 100, 176, 250, 209, 49, 114, 74, 154, 232, 226, 201, 105, 4, 89, 174, 15, 139, 153, 146, 18, 22])), SecretKey(Scalar([177, 106, 11, 3, 80, 225, 79, 252, 93, 164, 164, 188, 229, 216, 154, 89, 253, 69, 142, 187, 17, 57, 188, 102, 136, 129, 100, 78, 231, 180, 157, 3])));
/// ATS: boa1xqats00hqpqzvuv2uguqx3uhh72psv9mscfyv2qvz5rzyuhnwvlpq0xx3k9
static immutable ATS = KeyPair(PublicKey(Point([58, 184, 61, 247, 0, 64, 38, 113, 138, 226, 56, 3, 71, 151, 191, 148, 24, 48, 187, 134, 18, 70, 40, 12, 21, 6, 34, 114, 243, 115, 62, 16])), SecretKey(Scalar([149, 254, 36, 18, 6, 43, 161, 109, 189, 56, 217, 149, 169, 56, 110, 185, 131, 217, 181, 8, 84, 154, 113, 153, 50, 193, 163, 108, 217, 102, 227, 8])));
/// ATT: boa1xpatt004v4upuynz85wj3ux9mrmplfgtl7x5yj50ccmrghej39k4sazsa5h
static immutable ATT = KeyPair(PublicKey(Point([122, 181, 189, 245, 101, 120, 30, 18, 98, 61, 29, 40, 240, 197, 216, 246, 31, 165, 11, 255, 141, 66, 74, 143, 198, 54, 52, 95, 50, 137, 109, 88])), SecretKey(Scalar([116, 185, 180, 142, 213, 118, 146, 173, 42, 171, 11, 88, 28, 122, 186, 132, 106, 53, 239, 141, 16, 159, 238, 154, 64, 20, 248, 112, 144, 11, 45, 13])));
/// ATU: boa1xqatu00uk3n2usyk4nll4qzj69dldgjt5lp73mjrql42pnu2pcykut2hces
static immutable ATU = KeyPair(PublicKey(Point([58, 190, 61, 252, 180, 102, 174, 64, 150, 172, 255, 250, 128, 82, 209, 91, 246, 162, 75, 167, 195, 232, 238, 67, 7, 234, 160, 207, 138, 14, 9, 110])), SecretKey(Scalar([119, 225, 43, 51, 203, 241, 117, 157, 39, 16, 172, 25, 21, 23, 44, 55, 163, 115, 87, 163, 67, 127, 125, 1, 158, 5, 102, 26, 30, 213, 92, 0])));
/// ATV: boa1xzatv007a86sxd4xsx5a8rsg7xsjuwq70jsamhzavump858k0n5jzx9wyj0
static immutable ATV = KeyPair(PublicKey(Point([186, 182, 61, 254, 233, 245, 3, 54, 166, 129, 169, 211, 142, 8, 241, 161, 46, 56, 30, 124, 161, 221, 220, 93, 103, 54, 19, 208, 246, 124, 233, 33])), SecretKey(Scalar([119, 244, 1, 34, 157, 137, 179, 29, 55, 86, 161, 209, 75, 73, 49, 156, 138, 4, 213, 135, 246, 38, 111, 185, 68, 30, 215, 157, 69, 120, 248, 0])));
/// ATW: boa1xpatw00768ua2d3ta7zmxtx5j3l2wqgy0ff5j964lcdujtcr305a6pr3vkl
static immutable ATW = KeyPair(PublicKey(Point([122, 183, 61, 254, 209, 249, 213, 54, 43, 239, 133, 179, 44, 212, 148, 126, 167, 1, 4, 122, 83, 73, 23, 85, 254, 27, 201, 47, 3, 139, 233, 221])), SecretKey(Scalar([117, 85, 136, 55, 175, 143, 80, 8, 71, 141, 246, 90, 205, 149, 24, 142, 21, 40, 65, 34, 191, 16, 74, 145, 115, 167, 19, 62, 235, 5, 221, 10])));
/// ATX: boa1xqatx00urp7jhk3dldfr59deqwd2xlt6hw7m4jg3ygjzm6ye73r92d5lja3
static immutable ATX = KeyPair(PublicKey(Point([58, 179, 61, 252, 24, 125, 43, 218, 45, 251, 82, 58, 21, 185, 3, 154, 163, 125, 122, 187, 189, 186, 201, 17, 34, 36, 45, 232, 153, 244, 70, 85])), SecretKey(Scalar([60, 75, 239, 231, 109, 235, 235, 70, 32, 3, 198, 116, 18, 53, 72, 125, 12, 125, 184, 130, 113, 214, 243, 77, 171, 24, 201, 160, 255, 226, 171, 15])));
/// ATY: boa1xqaty00yg863nxah76qneukkgsx9qfux84gfkrhxvd8yw4zvy24ngnut0xk
static immutable ATY = KeyPair(PublicKey(Point([58, 178, 61, 228, 65, 245, 25, 155, 183, 246, 129, 60, 242, 214, 68, 12, 80, 39, 134, 61, 80, 155, 14, 230, 99, 78, 71, 84, 76, 34, 171, 52])), SecretKey(Scalar([125, 203, 127, 54, 217, 189, 186, 153, 184, 117, 223, 89, 167, 103, 121, 66, 182, 121, 120, 222, 129, 175, 49, 145, 35, 211, 154, 140, 221, 36, 192, 10])));
/// ATZ: boa1xqatz003tntze4cfq4pt44up3and6nher700k4zg33aryeyc7cypkxck6wc
static immutable ATZ = KeyPair(PublicKey(Point([58, 177, 61, 241, 92, 214, 44, 215, 9, 5, 66, 186, 215, 129, 143, 102, 221, 78, 249, 31, 158, 251, 84, 72, 140, 122, 50, 100, 152, 246, 8, 27])), SecretKey(Scalar([220, 143, 147, 219, 214, 191, 224, 27, 119, 68, 52, 64, 77, 194, 207, 210, 168, 164, 164, 193, 240, 88, 234, 20, 27, 125, 193, 168, 149, 135, 220, 0])));
/// AUA: boa1xraua00l8sknq7yy7v2dsqkdaxkmdjcwhvx8d6kfeshpu8pvd2kuzv6rss5
static immutable AUA = KeyPair(PublicKey(Point([251, 206, 189, 255, 60, 45, 48, 120, 132, 243, 20, 216, 2, 205, 233, 173, 182, 203, 14, 187, 12, 118, 234, 201, 204, 46, 30, 28, 44, 106, 173, 193])), SecretKey(Scalar([118, 76, 74, 60, 248, 35, 117, 17, 161, 201, 173, 174, 118, 174, 186, 208, 132, 193, 162, 205, 110, 23, 205, 26, 241, 146, 197, 200, 250, 28, 255, 14])));
/// AUC: boa1xrauc00dllq5zr0t5nwxcclprrpdmshul227mmpg40tzf4ldpqlmc6ezqw3
static immutable AUC = KeyPair(PublicKey(Point([251, 204, 61, 237, 255, 193, 65, 13, 235, 164, 220, 108, 99, 225, 24, 194, 221, 194, 252, 250, 149, 237, 236, 40, 171, 214, 36, 215, 237, 8, 63, 188])), SecretKey(Scalar([240, 226, 26, 113, 8, 252, 123, 87, 193, 180, 0, 20, 81, 187, 102, 138, 103, 153, 200, 199, 107, 246, 150, 103, 119, 76, 53, 17, 251, 49, 123, 4])));
/// AUD: boa1xraud00vlxt6drs4d4kaquf4kg4flvmyq5ekpy07ah3rv2uwcjyt2xa0qjn
static immutable AUD = KeyPair(PublicKey(Point([251, 198, 189, 236, 249, 151, 166, 142, 21, 109, 109, 208, 113, 53, 178, 42, 159, 179, 100, 5, 51, 96, 145, 254, 237, 226, 54, 43, 142, 196, 136, 181])), SecretKey(Scalar([238, 30, 54, 89, 240, 52, 21, 33, 105, 215, 155, 254, 29, 213, 113, 67, 135, 248, 196, 42, 246, 17, 227, 7, 161, 205, 52, 162, 132, 43, 116, 9])));
/// AUE: boa1xzaue0072hy4c4jh56d7mcpy7gmqwxutl7dfd5jcmtr3wx3rl0fvs9nfr9f
static immutable AUE = KeyPair(PublicKey(Point([187, 204, 189, 254, 85, 201, 92, 86, 87, 166, 155, 237, 224, 36, 242, 54, 7, 27, 139, 255, 154, 150, 210, 88, 218, 199, 23, 26, 35, 251, 210, 200])), SecretKey(Scalar([239, 212, 110, 193, 76, 209, 89, 225, 30, 56, 244, 245, 213, 74, 99, 125, 216, 16, 179, 255, 121, 19, 74, 212, 42, 192, 198, 68, 28, 202, 25, 15])));
/// AUF: boa1xqauf00zf0streu2paeqm554trl9s8a9q6sx2ukq9sknd6my7faa5z2re0j
static immutable AUF = KeyPair(PublicKey(Point([59, 196, 189, 226, 75, 224, 177, 231, 138, 15, 114, 13, 210, 149, 88, 254, 88, 31, 165, 6, 160, 101, 114, 192, 44, 45, 54, 235, 100, 242, 123, 218])), SecretKey(Scalar([41, 192, 137, 237, 195, 138, 173, 204, 117, 189, 0, 114, 166, 176, 50, 176, 202, 230, 133, 138, 47, 159, 112, 255, 238, 144, 185, 196, 76, 88, 101, 13])));
/// AUG: boa1xzaug007rryc4r89fax6xhzarmmxyscww72hcjlrw7vzpejq83mg677zwk8
static immutable AUG = KeyPair(PublicKey(Point([187, 196, 61, 254, 24, 201, 138, 140, 229, 79, 77, 163, 92, 93, 30, 246, 98, 67, 14, 119, 149, 124, 75, 227, 119, 152, 32, 230, 64, 60, 118, 141])), SecretKey(Scalar([134, 23, 89, 153, 195, 134, 159, 116, 213, 143, 192, 179, 139, 50, 93, 47, 43, 129, 203, 9, 89, 39, 222, 231, 241, 238, 74, 0, 7, 181, 119, 5])));
/// AUH: boa1xrauh008pzex55me2nw3r9kme8htpwxeueewxx9h9xlc7rza3a0tsun9ykn
static immutable AUH = KeyPair(PublicKey(Point([251, 203, 189, 231, 8, 178, 106, 83, 121, 84, 221, 17, 150, 219, 201, 238, 176, 184, 217, 230, 114, 227, 24, 183, 41, 191, 143, 12, 93, 143, 94, 184])), SecretKey(Scalar([15, 171, 95, 121, 210, 58, 204, 178, 217, 6, 117, 195, 108, 131, 193, 81, 69, 185, 113, 239, 226, 93, 104, 101, 174, 154, 8, 78, 65, 51, 69, 5])));
/// AUJ: boa1xzauj00u2h5q9q3zpqgzpc55zw379cf3wyd39hrytxygg7hphs8w6tf0zes
static immutable AUJ = KeyPair(PublicKey(Point([187, 201, 61, 252, 85, 232, 2, 130, 34, 8, 16, 32, 226, 148, 19, 163, 226, 225, 49, 113, 27, 18, 220, 100, 89, 136, 132, 122, 225, 188, 14, 237])), SecretKey(Scalar([54, 60, 111, 139, 34, 186, 183, 120, 180, 6, 42, 46, 143, 170, 46, 124, 163, 228, 1, 206, 91, 176, 88, 162, 242, 168, 187, 80, 15, 119, 136, 8])));
/// AUK: boa1xqauk003hkfey3xzwed7askggm35857z86q9z40kx0scwdxmvrprscdxnys
static immutable AUK = KeyPair(PublicKey(Point([59, 203, 61, 241, 189, 147, 146, 68, 194, 118, 91, 238, 194, 200, 70, 227, 67, 211, 194, 62, 128, 81, 85, 246, 51, 225, 135, 52, 219, 96, 194, 56])), SecretKey(Scalar([146, 61, 168, 34, 99, 233, 186, 116, 119, 169, 234, 22, 188, 154, 92, 204, 125, 22, 219, 142, 66, 92, 186, 146, 23, 107, 121, 41, 229, 202, 254, 14])));
/// AUL: boa1xqaul00e76nd6jkujlacwc42v94qrcmc3uddu64mmgh7tc5005uhk2e76pw
static immutable AUL = KeyPair(PublicKey(Point([59, 207, 189, 249, 246, 166, 221, 74, 220, 151, 251, 135, 98, 170, 97, 106, 1, 227, 120, 143, 26, 222, 106, 187, 218, 47, 229, 226, 143, 125, 57, 123])), SecretKey(Scalar([147, 226, 30, 80, 150, 167, 83, 50, 68, 97, 35, 178, 35, 97, 161, 119, 90, 117, 232, 54, 171, 12, 126, 97, 40, 163, 142, 32, 245, 230, 109, 10])));
/// AUM: boa1xzaum00up2csz04ahwt8xp5yc7kvzdkx3qcqtryu9dd2mfwzyzu3zscj49y
static immutable AUM = KeyPair(PublicKey(Point([187, 205, 189, 252, 10, 177, 1, 62, 189, 187, 150, 115, 6, 132, 199, 172, 193, 54, 198, 136, 48, 5, 140, 156, 43, 90, 173, 165, 194, 32, 185, 17])), SecretKey(Scalar([137, 206, 116, 69, 64, 88, 230, 126, 125, 219, 58, 141, 120, 139, 135, 66, 183, 45, 1, 153, 60, 214, 193, 216, 138, 222, 38, 172, 214, 211, 53, 12])));
/// AUN: boa1xpaun00lzc7u89458ynyyw5kkphdyrjl6qmsnpms3g65vdghujtl2wzqllr
static immutable AUN = KeyPair(PublicKey(Point([123, 201, 189, 255, 22, 61, 195, 150, 180, 57, 38, 66, 58, 150, 176, 110, 210, 14, 95, 208, 55, 9, 135, 112, 138, 53, 70, 53, 23, 228, 151, 245])), SecretKey(Scalar([15, 118, 97, 198, 58, 128, 246, 128, 126, 92, 54, 3, 231, 240, 161, 221, 179, 255, 164, 199, 24, 218, 78, 89, 75, 73, 152, 203, 230, 190, 74, 10])));
/// AUP: boa1xqaup00d8qh2luzuu0lcarrw49jjzegp7279pme9apghfldrsdscqxgkw85
static immutable AUP = KeyPair(PublicKey(Point([59, 192, 189, 237, 56, 46, 175, 240, 92, 227, 255, 142, 140, 110, 169, 101, 33, 101, 1, 242, 188, 80, 239, 37, 232, 81, 116, 253, 163, 131, 97, 128])), SecretKey(Scalar([177, 183, 64, 240, 112, 55, 190, 45, 79, 92, 181, 76, 236, 93, 219, 17, 135, 130, 0, 90, 131, 198, 194, 203, 81, 16, 49, 159, 61, 171, 217, 12])));
/// AUQ: boa1xpauq00vker5qq5ckt555pdgg5r7reyh6pfcdtm58kn2dq0mjgrj27h77me
static immutable AUQ = KeyPair(PublicKey(Point([123, 192, 61, 236, 182, 71, 64, 2, 152, 178, 233, 74, 5, 168, 69, 7, 225, 228, 151, 208, 83, 134, 175, 116, 61, 166, 166, 129, 251, 146, 7, 37])), SecretKey(Scalar([99, 118, 182, 36, 86, 129, 253, 183, 253, 213, 134, 55, 15, 1, 220, 87, 75, 246, 7, 40, 206, 83, 232, 19, 68, 184, 17, 182, 165, 189, 131, 7])));
/// AUR: boa1xqaur00zjwshm6r55488eesyty537lmcpjm2wwtek8uhhy47ygxdc4233hg
static immutable AUR = KeyPair(PublicKey(Point([59, 193, 189, 226, 147, 161, 125, 232, 116, 165, 78, 124, 230, 4, 89, 41, 31, 127, 120, 12, 182, 167, 57, 121, 177, 249, 123, 146, 190, 34, 12, 220])), SecretKey(Scalar([148, 140, 89, 158, 83, 133, 200, 121, 182, 143, 92, 221, 23, 203, 127, 146, 113, 229, 8, 153, 46, 38, 239, 251, 25, 48, 7, 51, 73, 68, 13, 15])));
/// AUS: boa1xpaus00grlaceah30gjctfy5t7s8rp3dlzn2uhvah2glhjqwcs9ck25y26j
static immutable AUS = KeyPair(PublicKey(Point([123, 200, 61, 232, 31, 251, 140, 246, 241, 122, 37, 133, 164, 148, 95, 160, 113, 134, 45, 248, 166, 174, 93, 157, 186, 145, 251, 200, 14, 196, 11, 139])), SecretKey(Scalar([111, 157, 87, 36, 68, 224, 173, 160, 52, 93, 200, 160, 210, 46, 95, 16, 118, 205, 15, 83, 53, 28, 67, 159, 219, 202, 25, 235, 102, 242, 14, 4])));
/// AUT: boa1xqaut00gclq0jn8yn6qmz2wn82wg2gx2nwx4fwtnm5cg4ncqfcaagvtnm8n
static immutable AUT = KeyPair(PublicKey(Point([59, 197, 189, 232, 199, 192, 249, 76, 228, 158, 129, 177, 41, 211, 58, 156, 133, 32, 202, 155, 141, 84, 185, 115, 221, 48, 138, 207, 0, 78, 59, 212])), SecretKey(Scalar([74, 155, 30, 237, 64, 122, 149, 220, 218, 176, 104, 249, 79, 192, 222, 28, 37, 110, 166, 37, 231, 171, 215, 130, 188, 164, 65, 169, 29, 224, 41, 10])));
/// AUU: boa1xrauu00xuayf50dsrz5hmpt0383tyxwlhp842w4kvg35r43588et223u0kh
static immutable AUU = KeyPair(PublicKey(Point([251, 206, 61, 230, 231, 72, 154, 61, 176, 24, 169, 125, 133, 111, 137, 226, 178, 25, 223, 184, 79, 85, 58, 182, 98, 35, 65, 214, 52, 57, 242, 181])), SecretKey(Scalar([11, 33, 3, 101, 75, 236, 236, 161, 71, 49, 171, 54, 117, 111, 84, 122, 27, 52, 172, 187, 128, 187, 207, 101, 161, 204, 237, 238, 47, 67, 59, 8])));
/// AUV: boa1xqauv0062v47dfl59l866yqd57drde0efpf72nskhcdpuslmv8vu68met7e
static immutable AUV = KeyPair(PublicKey(Point([59, 198, 61, 250, 83, 43, 230, 167, 244, 47, 207, 173, 16, 13, 167, 154, 54, 229, 249, 72, 83, 229, 78, 22, 190, 26, 30, 67, 251, 97, 217, 205])), SecretKey(Scalar([166, 127, 47, 161, 76, 143, 114, 162, 105, 9, 77, 217, 28, 63, 88, 17, 226, 74, 57, 22, 187, 73, 57, 135, 206, 187, 79, 4, 87, 8, 5, 1])));
/// AUW: boa1xqauw00a78npmnj69fnckgzfukn2jgdg3j3rz722cg8v9t9m8hk7utnh2wx
static immutable AUW = KeyPair(PublicKey(Point([59, 199, 61, 253, 241, 230, 29, 206, 90, 42, 103, 139, 32, 73, 229, 166, 169, 33, 168, 140, 162, 49, 121, 74, 194, 14, 194, 172, 187, 61, 237, 238])), SecretKey(Scalar([176, 119, 89, 28, 15, 103, 42, 91, 8, 152, 175, 227, 46, 8, 124, 130, 164, 166, 46, 254, 39, 232, 167, 73, 107, 83, 19, 183, 188, 189, 129, 0])));
/// AUX: boa1xraux00rpx2umk0q6vzvc4djdc3hdy65a4r0qpqfncw4jg5lmgemg594j58
static immutable AUX = KeyPair(PublicKey(Point([251, 195, 61, 227, 9, 149, 205, 217, 224, 211, 4, 204, 85, 178, 110, 35, 118, 147, 84, 237, 70, 240, 4, 9, 158, 29, 89, 34, 159, 218, 51, 180])), SecretKey(Scalar([134, 146, 107, 230, 24, 205, 193, 215, 94, 99, 174, 52, 11, 162, 61, 249, 20, 37, 64, 229, 95, 84, 139, 117, 35, 56, 192, 202, 174, 255, 39, 10])));
/// AUY: boa1xqauy000fqzyzv40u6x2ndp9fqh0vmvu6375mjnwa0lldscmjzmfc62urqn
static immutable AUY = KeyPair(PublicKey(Point([59, 194, 61, 239, 72, 4, 65, 50, 175, 230, 140, 169, 180, 37, 72, 46, 246, 109, 156, 212, 125, 77, 202, 110, 235, 255, 246, 195, 27, 144, 182, 156])), SecretKey(Scalar([94, 216, 223, 185, 4, 230, 96, 65, 14, 39, 219, 191, 57, 150, 207, 0, 139, 132, 8, 1, 99, 97, 164, 7, 187, 144, 225, 27, 57, 35, 72, 11])));
/// AUZ: boa1xzauz00rzpx6f7zy7zmj46m48uan5c04r4hnk4fleraekqxvpa5dxddfetu
static immutable AUZ = KeyPair(PublicKey(Point([187, 193, 61, 227, 16, 77, 164, 248, 68, 240, 183, 42, 235, 117, 63, 59, 58, 97, 245, 29, 111, 59, 85, 63, 200, 251, 155, 0, 204, 15, 104, 211])), SecretKey(Scalar([121, 22, 234, 136, 22, 134, 142, 189, 171, 172, 76, 141, 226, 176, 143, 45, 141, 0, 119, 33, 128, 43, 158, 123, 75, 179, 111, 92, 215, 64, 144, 13])));
/// AVA: boa1xpava00ndad8xye8d7upd0ccuzahgtc73rm0ew9xq38k5rf5jned5czu4ac
static immutable AVA = KeyPair(PublicKey(Point([122, 206, 189, 243, 111, 90, 115, 19, 39, 111, 184, 22, 191, 24, 224, 187, 116, 47, 30, 136, 246, 252, 184, 166, 4, 79, 106, 13, 52, 148, 242, 218])), SecretKey(Scalar([23, 233, 60, 13, 185, 232, 155, 99, 176, 240, 254, 14, 101, 80, 166, 37, 164, 203, 79, 76, 205, 65, 208, 180, 154, 234, 209, 252, 187, 138, 18, 3])));
/// AVC: boa1xravc009pusxvq0zq8yctxaf8hp5asw2c0mqfu9km48ahk5z0ztn6f2v2xl
static immutable AVC = KeyPair(PublicKey(Point([250, 204, 61, 229, 15, 32, 102, 1, 226, 1, 201, 133, 155, 169, 61, 195, 78, 193, 202, 195, 246, 4, 240, 182, 221, 79, 219, 218, 130, 120, 151, 61])), SecretKey(Scalar([139, 91, 228, 39, 17, 15, 159, 79, 234, 161, 5, 174, 152, 179, 185, 10, 249, 81, 230, 101, 51, 239, 181, 186, 60, 220, 86, 33, 63, 166, 11, 6])));
/// AVD: boa1xravd004l5gjp9sk7zcfx54qrkkrqdzyln6u040g7xjcym949f09xsmujap
static immutable AVD = KeyPair(PublicKey(Point([250, 198, 189, 245, 253, 17, 32, 150, 22, 240, 176, 147, 82, 160, 29, 172, 48, 52, 68, 252, 245, 199, 213, 232, 241, 165, 130, 108, 181, 42, 94, 83])), SecretKey(Scalar([118, 51, 214, 1, 84, 81, 105, 49, 42, 186, 59, 92, 184, 212, 37, 53, 197, 128, 122, 80, 182, 230, 233, 41, 123, 142, 215, 136, 103, 13, 120, 9])));
/// AVE: boa1xqave00k9w3n0wfyfglt7e0zlyfh88wf73zkkckmj27z87h6z262qhz0ng0
static immutable AVE = KeyPair(PublicKey(Point([58, 204, 189, 246, 43, 163, 55, 185, 36, 74, 62, 191, 101, 226, 249, 19, 115, 157, 201, 244, 69, 107, 98, 219, 146, 188, 35, 250, 250, 18, 180, 160])), SecretKey(Scalar([70, 167, 209, 105, 41, 106, 237, 230, 30, 101, 105, 59, 199, 15, 28, 207, 211, 209, 56, 115, 175, 168, 30, 14, 247, 122, 56, 129, 183, 53, 227, 5])));
/// AVF: boa1xpavf00gk4q8sjqh5825nhvvpg5hlxcjfz3zwewwewvhmmjy52djvcwvm38
static immutable AVF = KeyPair(PublicKey(Point([122, 196, 189, 232, 181, 64, 120, 72, 23, 161, 213, 73, 221, 140, 10, 41, 127, 155, 18, 72, 162, 39, 101, 206, 203, 153, 125, 238, 68, 162, 155, 38])), SecretKey(Scalar([152, 112, 237, 113, 77, 208, 183, 3, 194, 234, 127, 77, 64, 6, 218, 104, 26, 183, 99, 65, 129, 93, 60, 127, 109, 157, 199, 132, 1, 172, 166, 10])));
/// AVG: boa1xqavg00d3maheys86xlnhnk2efyc9dqyu0ednnthdne50kkrmhwqjfwrknq
static immutable AVG = KeyPair(PublicKey(Point([58, 196, 61, 237, 142, 251, 124, 146, 7, 209, 191, 59, 206, 202, 202, 73, 130, 180, 4, 227, 242, 217, 205, 119, 108, 243, 71, 218, 195, 221, 220, 9])), SecretKey(Scalar([127, 3, 110, 9, 42, 202, 88, 37, 229, 255, 0, 40, 167, 123, 40, 114, 143, 48, 11, 112, 150, 90, 166, 192, 132, 84, 78, 220, 143, 173, 143, 0])));
/// AVH: boa1xzavh00pays5w6rk3pmw9rlpypk685luu6cwzt4g2pjkm2n9va9sxmv3xdn
static immutable AVH = KeyPair(PublicKey(Point([186, 203, 189, 225, 233, 33, 71, 104, 118, 136, 118, 226, 143, 225, 32, 109, 163, 211, 252, 230, 176, 225, 46, 168, 80, 101, 109, 170, 101, 103, 75, 3])), SecretKey(Scalar([246, 115, 240, 215, 187, 150, 118, 100, 16, 235, 199, 203, 141, 220, 55, 212, 217, 65, 46, 23, 41, 152, 107, 233, 98, 39, 130, 198, 50, 227, 103, 3])));
/// AVJ: boa1xqavj00tzf292850s79pjkfwz3232ts3gd54xr33z0q8c3j6kgahweq0wrs
static immutable AVJ = KeyPair(PublicKey(Point([58, 201, 61, 235, 18, 84, 85, 30, 143, 135, 138, 25, 89, 46, 20, 85, 21, 46, 17, 67, 105, 83, 14, 49, 19, 192, 124, 70, 90, 178, 59, 119])), SecretKey(Scalar([77, 88, 244, 128, 18, 88, 250, 191, 235, 95, 100, 242, 146, 114, 244, 115, 15, 232, 195, 18, 43, 100, 237, 155, 133, 212, 54, 156, 244, 91, 242, 1])));
/// AVK: boa1xzavk00l0tzssr8zs5r2kz67krn24dd6a5jrwvqz9hunnusmft0u7cragx9
static immutable AVK = KeyPair(PublicKey(Point([186, 203, 61, 255, 122, 197, 8, 12, 226, 133, 6, 171, 11, 94, 176, 230, 170, 181, 186, 237, 36, 55, 48, 2, 45, 249, 57, 242, 27, 74, 223, 207])), SecretKey(Scalar([16, 167, 29, 191, 67, 176, 128, 108, 68, 55, 144, 192, 68, 235, 196, 126, 205, 181, 64, 190, 83, 60, 171, 102, 26, 68, 123, 134, 69, 110, 158, 10])));
/// AVL: boa1xravl002tzexkyfkv0mzussnechvn34nj8nfjl9u9533d5c7ufpc2twtha4
static immutable AVL = KeyPair(PublicKey(Point([250, 207, 189, 234, 88, 178, 107, 17, 54, 99, 246, 46, 66, 19, 206, 46, 201, 198, 179, 145, 230, 153, 124, 188, 45, 35, 22, 211, 30, 226, 67, 133])), SecretKey(Scalar([161, 251, 83, 112, 59, 163, 22, 48, 204, 127, 238, 157, 134, 123, 51, 183, 215, 56, 60, 205, 166, 80, 173, 31, 123, 238, 39, 121, 251, 101, 6, 6])));
/// AVM: boa1xpavm00wfsuz5fjtm9a69qgqgq4pysc67uwqqpdycscqq82k0knf2pjntn4
static immutable AVM = KeyPair(PublicKey(Point([122, 205, 189, 238, 76, 56, 42, 38, 75, 217, 123, 162, 129, 0, 64, 42, 18, 67, 26, 247, 28, 0, 5, 164, 196, 48, 0, 29, 86, 125, 166, 149])), SecretKey(Scalar([198, 8, 142, 96, 177, 98, 77, 55, 49, 142, 84, 66, 101, 174, 130, 74, 95, 194, 15, 14, 73, 225, 197, 161, 47, 134, 235, 211, 179, 71, 145, 14])));
/// AVN: boa1xqavn00ga9ea6c30gg6e28xyajl7d30r7spq0q0cr3nyk893de94utj76ef
static immutable AVN = KeyPair(PublicKey(Point([58, 201, 189, 232, 233, 115, 221, 98, 47, 66, 53, 149, 28, 196, 236, 191, 230, 197, 227, 244, 2, 7, 129, 248, 28, 102, 75, 28, 177, 110, 75, 94])), SecretKey(Scalar([239, 180, 43, 96, 119, 205, 219, 223, 193, 192, 209, 127, 147, 161, 182, 19, 98, 211, 5, 133, 239, 78, 147, 230, 245, 123, 250, 166, 202, 92, 206, 11])));
/// AVP: boa1xpavp00c95h65r7xr5h0nkmut9xk8extrduwzp7q5d3cxk5f5nteva8x5kk
static immutable AVP = KeyPair(PublicKey(Point([122, 192, 189, 248, 45, 47, 170, 15, 198, 29, 46, 249, 219, 124, 89, 77, 99, 228, 203, 27, 120, 225, 7, 192, 163, 99, 131, 90, 137, 164, 215, 150])), SecretKey(Scalar([102, 25, 164, 17, 78, 26, 78, 76, 32, 171, 111, 101, 0, 39, 200, 120, 85, 212, 117, 99, 66, 121, 76, 77, 146, 216, 14, 241, 22, 89, 41, 5])));
/// AVQ: boa1xqavq00wzufzwxlry3pg750ljqxrkv9xjz5wykys8xpaq0xg4778c88vfhh
static immutable AVQ = KeyPair(PublicKey(Point([58, 192, 61, 238, 23, 18, 39, 27, 227, 36, 66, 143, 81, 255, 144, 12, 59, 48, 166, 144, 168, 226, 88, 144, 57, 131, 208, 60, 200, 175, 188, 124])), SecretKey(Scalar([151, 77, 177, 60, 67, 53, 221, 175, 243, 246, 226, 136, 254, 20, 193, 126, 235, 45, 97, 51, 150, 165, 217, 20, 127, 109, 56, 102, 145, 40, 176, 11])));
/// AVR: boa1xpavr006zpxg0un4ewpdvseav4ha00x4a3rddlv63zvf9lqfrr69jzapa6g
static immutable AVR = KeyPair(PublicKey(Point([122, 193, 189, 250, 16, 76, 135, 242, 117, 203, 130, 214, 67, 61, 101, 111, 215, 188, 213, 236, 70, 214, 253, 154, 136, 152, 146, 252, 9, 24, 244, 89])), SecretKey(Scalar([162, 160, 3, 242, 126, 235, 203, 52, 79, 15, 223, 3, 25, 143, 219, 75, 48, 168, 199, 178, 221, 174, 107, 141, 46, 103, 38, 42, 201, 103, 33, 7])));
/// AVS: boa1xpavs00xln9ly2yrdy7m0jj66jsxe2s3u5w8s980xngzy2tpv5nhkdfuu5z
static immutable AVS = KeyPair(PublicKey(Point([122, 200, 61, 230, 252, 203, 242, 40, 131, 105, 61, 183, 202, 90, 212, 160, 108, 170, 17, 229, 28, 120, 20, 239, 52, 208, 34, 41, 97, 101, 39, 123])), SecretKey(Scalar([59, 238, 198, 137, 33, 123, 201, 224, 168, 246, 158, 208, 113, 80, 227, 202, 138, 126, 176, 230, 123, 28, 243, 184, 253, 122, 0, 50, 102, 111, 215, 5])));
/// AVT: boa1xravt00jdmhyf3pw28w490gx5tjfpyh57tcgpnhmxkvwgy56q33xz890vdz
static immutable AVT = KeyPair(PublicKey(Point([250, 197, 189, 242, 110, 238, 68, 196, 46, 81, 221, 82, 189, 6, 162, 228, 144, 146, 244, 242, 240, 128, 206, 251, 53, 152, 228, 18, 154, 4, 98, 97])), SecretKey(Scalar([248, 38, 108, 237, 140, 10, 206, 170, 234, 21, 35, 33, 56, 66, 182, 1, 217, 111, 128, 120, 198, 134, 207, 19, 132, 67, 195, 180, 225, 175, 70, 9])));
/// AVU: boa1xzavu0026hjaumdghrj4t3n0wl4adr3qghcpujzgtqvj58vvs48hwtw7ywh
static immutable AVU = KeyPair(PublicKey(Point([186, 206, 61, 234, 213, 229, 222, 109, 168, 184, 229, 85, 198, 111, 119, 235, 214, 142, 32, 69, 240, 30, 72, 72, 88, 25, 42, 29, 140, 133, 79, 119])), SecretKey(Scalar([95, 4, 10, 39, 128, 245, 151, 69, 209, 42, 144, 182, 155, 47, 62, 32, 24, 240, 245, 234, 64, 53, 56, 235, 78, 99, 233, 76, 52, 153, 211, 9])));
/// AVV: boa1xravv00gyq4cwe7dzt9cgtuhmsd9srcmvuxqsyxjk07fykkvcmkeg75up49
static immutable AVV = KeyPair(PublicKey(Point([250, 198, 61, 232, 32, 43, 135, 103, 205, 18, 203, 132, 47, 151, 220, 26, 88, 15, 27, 103, 12, 8, 16, 210, 179, 252, 146, 90, 204, 198, 237, 148])), SecretKey(Scalar([249, 148, 83, 100, 221, 43, 171, 157, 108, 36, 87, 129, 52, 187, 99, 231, 144, 45, 59, 98, 126, 132, 207, 78, 49, 3, 51, 172, 75, 69, 141, 11])));
/// AVW: boa1xzavw00fnx4fcvfc7gl4gkfdvdfx5q3g5vqchq3wdwhd7j3luwnnzxtg98g
static immutable AVW = KeyPair(PublicKey(Point([186, 199, 61, 233, 153, 170, 156, 49, 56, 242, 63, 84, 89, 45, 99, 82, 106, 2, 40, 163, 1, 139, 130, 46, 107, 174, 223, 74, 63, 227, 167, 49])), SecretKey(Scalar([58, 8, 109, 227, 84, 186, 14, 229, 255, 90, 234, 221, 164, 71, 22, 30, 205, 233, 133, 134, 193, 210, 245, 178, 69, 158, 227, 233, 218, 167, 27, 10])));
/// AVX: boa1xzavx000p6r4ez9425q57l3lc3xjmpmtjem7kqlecv87leghz03k20ys6df
static immutable AVX = KeyPair(PublicKey(Point([186, 195, 61, 239, 14, 135, 92, 136, 181, 85, 1, 79, 126, 63, 196, 77, 45, 135, 107, 150, 119, 235, 3, 249, 195, 15, 239, 229, 23, 19, 227, 101])), SecretKey(Scalar([10, 80, 160, 157, 241, 181, 15, 48, 144, 50, 98, 90, 91, 76, 14, 132, 228, 206, 246, 182, 162, 42, 4, 160, 155, 202, 148, 51, 49, 175, 234, 4])));
/// AVY: boa1xzavy00j0rt3sxtu4zkvt70kmgcp89f05yp333qtfrx8jwwmt53eul09sla
static immutable AVY = KeyPair(PublicKey(Point([186, 194, 61, 242, 120, 215, 24, 25, 124, 168, 172, 197, 249, 246, 218, 48, 19, 149, 47, 161, 3, 24, 196, 11, 72, 204, 121, 57, 219, 93, 35, 158])), SecretKey(Scalar([41, 94, 218, 43, 110, 113, 154, 163, 59, 180, 114, 174, 250, 176, 29, 223, 218, 249, 214, 183, 93, 67, 135, 181, 56, 123, 3, 113, 121, 148, 48, 10])));
/// AVZ: boa1xravz00dvja26lgjp5vwgjpf6qtmj6ch20jv0kh9dzjfgkkm3gd25j2e4fk
static immutable AVZ = KeyPair(PublicKey(Point([250, 193, 61, 237, 100, 186, 173, 125, 18, 13, 24, 228, 72, 41, 208, 23, 185, 107, 23, 83, 228, 199, 218, 229, 104, 164, 148, 90, 219, 138, 26, 170])), SecretKey(Scalar([220, 87, 39, 214, 0, 135, 171, 12, 179, 233, 78, 67, 234, 27, 28, 97, 194, 227, 185, 218, 122, 16, 178, 244, 21, 42, 76, 61, 103, 124, 102, 4])));
/// AWA: boa1xqawa00mce309am674n6qy5xazt28pqgue64425ldutvv8na5egt60g20v6
static immutable AWA = KeyPair(PublicKey(Point([58, 238, 189, 251, 198, 98, 242, 247, 122, 245, 103, 160, 18, 134, 232, 150, 163, 132, 8, 230, 117, 90, 170, 159, 111, 22, 198, 30, 125, 166, 80, 189])), SecretKey(Scalar([24, 243, 34, 157, 35, 245, 19, 213, 221, 46, 125, 87, 205, 104, 206, 235, 189, 48, 3, 27, 93, 250, 112, 132, 106, 198, 83, 155, 234, 193, 21, 8])));
/// AWC: boa1xqawc00zzhephpm5evdun32jvy8fhr4ws7sxy8m4gwxt9c9ga0q9s8ejpsg
static immutable AWC = KeyPair(PublicKey(Point([58, 236, 61, 226, 21, 242, 27, 135, 116, 203, 27, 201, 197, 82, 97, 14, 155, 142, 174, 135, 160, 98, 31, 117, 67, 140, 178, 224, 168, 235, 192, 88])), SecretKey(Scalar([239, 209, 6, 208, 183, 209, 180, 228, 16, 115, 75, 86, 123, 93, 21, 59, 198, 159, 238, 254, 88, 212, 177, 215, 209, 210, 220, 94, 116, 166, 213, 7])));
/// AWD: boa1xqawd00sm2j9v5nmm0zd6rwjdpnqywq4chu3032mxgz54euwq6pnsdpdmpg
static immutable AWD = KeyPair(PublicKey(Point([58, 230, 189, 240, 218, 164, 86, 82, 123, 219, 196, 221, 13, 210, 104, 102, 2, 56, 21, 197, 249, 23, 197, 91, 50, 5, 74, 231, 142, 6, 131, 56])), SecretKey(Scalar([12, 119, 18, 166, 159, 210, 192, 219, 83, 65, 155, 254, 183, 225, 152, 172, 132, 103, 50, 207, 93, 236, 123, 85, 10, 145, 231, 168, 7, 255, 22, 3])));
/// AWE: boa1xpawe00sthapkkwjgyxsgqhywwpmaj3flz3py3ntcjnhuay0ndzr6k5z8l6
static immutable AWE = KeyPair(PublicKey(Point([122, 236, 189, 240, 93, 250, 27, 89, 210, 65, 13, 4, 2, 228, 115, 131, 190, 202, 41, 248, 162, 18, 70, 107, 196, 167, 126, 116, 143, 155, 68, 61])), SecretKey(Scalar([4, 130, 89, 166, 224, 224, 199, 92, 245, 22, 232, 180, 100, 229, 123, 40, 211, 237, 230, 185, 166, 177, 227, 129, 60, 37, 139, 191, 182, 145, 189, 8])));
/// AWF: boa1xrawf00ek25y9msdw9rdjk44088fgcym3p354ndhlxhrdr220dk75k2kpas
static immutable AWF = KeyPair(PublicKey(Point([250, 228, 189, 249, 178, 168, 66, 238, 13, 113, 70, 217, 90, 181, 121, 206, 148, 96, 155, 136, 99, 74, 205, 183, 249, 174, 54, 141, 74, 123, 109, 234])), SecretKey(Scalar([102, 123, 132, 95, 18, 20, 250, 158, 145, 54, 25, 184, 73, 198, 94, 145, 44, 74, 19, 113, 244, 8, 121, 190, 100, 139, 8, 34, 23, 5, 102, 8])));
/// AWG: boa1xzawg00k0fdmq5jyg96ttyghq47ts9dvyzwd6hqrn2r78cv8wrruuuze0wt
static immutable AWG = KeyPair(PublicKey(Point([186, 228, 61, 246, 122, 91, 176, 82, 68, 65, 116, 181, 145, 23, 5, 124, 184, 21, 172, 32, 156, 221, 92, 3, 154, 135, 227, 225, 135, 112, 199, 206])), SecretKey(Scalar([63, 226, 47, 240, 143, 21, 8, 46, 112, 128, 45, 189, 54, 198, 249, 113, 20, 167, 6, 15, 61, 152, 138, 231, 191, 64, 147, 252, 233, 169, 117, 1])));
/// AWH: boa1xqawh00lur9an296r4ghy0z4k97u0qwz28uc0my8rd8v2dnfjcgx2y0v5ak
static immutable AWH = KeyPair(PublicKey(Point([58, 235, 189, 255, 224, 203, 217, 168, 186, 29, 81, 114, 60, 85, 177, 125, 199, 129, 194, 81, 249, 135, 236, 135, 27, 78, 197, 54, 105, 150, 16, 101])), SecretKey(Scalar([46, 49, 230, 23, 146, 15, 200, 209, 67, 192, 14, 243, 21, 229, 73, 77, 78, 150, 157, 42, 160, 238, 162, 200, 214, 139, 117, 0, 134, 198, 145, 2])));
/// AWJ: boa1xrawj00en5q6cp7p8s6x3tq78qvktccysmrcluh06dhfntz4e5rpyeplgj7
static immutable AWJ = KeyPair(PublicKey(Point([250, 233, 61, 249, 157, 1, 172, 7, 193, 60, 52, 104, 172, 30, 56, 25, 101, 227, 4, 134, 199, 143, 242, 239, 211, 110, 153, 172, 85, 205, 6, 18])), SecretKey(Scalar([172, 14, 218, 130, 94, 247, 72, 77, 252, 69, 109, 118, 209, 70, 98, 133, 99, 110, 208, 211, 62, 25, 82, 99, 189, 28, 227, 239, 23, 235, 128, 13])));
/// AWK: boa1xzawk00wlh2jmj09xz2c3f4wzeehgecj9hp2vq88hksegqt7sl28j52wx75
static immutable AWK = KeyPair(PublicKey(Point([186, 235, 61, 238, 253, 213, 45, 201, 229, 48, 149, 136, 166, 174, 22, 115, 116, 103, 18, 45, 194, 166, 0, 231, 189, 161, 148, 1, 126, 135, 212, 121])), SecretKey(Scalar([147, 114, 216, 57, 203, 54, 78, 170, 92, 100, 105, 210, 125, 178, 254, 98, 166, 151, 238, 218, 219, 242, 186, 231, 90, 226, 46, 41, 140, 120, 199, 0])));
/// AWL: boa1xqawl004gkskm3tqn5k2fxtvw7h9x67yt8l6ftv6uljl4fsr0m8uv4z28d3
static immutable AWL = KeyPair(PublicKey(Point([58, 239, 189, 245, 69, 161, 109, 197, 96, 157, 44, 164, 153, 108, 119, 174, 83, 107, 196, 89, 255, 164, 173, 154, 231, 229, 250, 166, 3, 126, 207, 198])), SecretKey(Scalar([119, 195, 130, 8, 248, 101, 143, 89, 250, 74, 76, 95, 92, 202, 203, 71, 231, 191, 142, 252, 158, 156, 141, 55, 83, 198, 98, 194, 104, 159, 58, 3])));
/// AWM: boa1xzawm00kjjt4l7lyaw4ena9k5lewmr5x6dlkf3m85tee97z4rxlpc3ndet6
static immutable AWM = KeyPair(PublicKey(Point([186, 237, 189, 246, 148, 151, 95, 251, 228, 235, 171, 153, 244, 182, 167, 242, 237, 142, 134, 211, 127, 100, 199, 103, 162, 243, 146, 248, 85, 25, 190, 28])), SecretKey(Scalar([36, 52, 93, 28, 251, 236, 217, 59, 241, 235, 93, 177, 201, 99, 68, 245, 109, 49, 106, 73, 238, 76, 146, 249, 162, 200, 56, 225, 21, 126, 26, 2])));
/// AWN: boa1xzawn00c5u5pmjn2gpjrpz0wpr8ldq0q4mtaqtuctvsqfvp0m5rtx0hruwl
static immutable AWN = KeyPair(PublicKey(Point([186, 233, 189, 248, 167, 40, 29, 202, 106, 64, 100, 48, 137, 238, 8, 207, 246, 129, 224, 174, 215, 208, 47, 152, 91, 32, 4, 176, 47, 221, 6, 179])), SecretKey(Scalar([173, 142, 150, 184, 231, 168, 154, 125, 156, 24, 39, 25, 165, 24, 123, 145, 238, 162, 220, 64, 37, 164, 197, 189, 77, 133, 166, 176, 123, 86, 133, 9])));
/// AWP: boa1xqawp00495swlhfadxs5ucpa8907n8ls35ddh2f68wsk2ygq5jkaqdnfw7c
static immutable AWP = KeyPair(PublicKey(Point([58, 224, 189, 245, 45, 32, 239, 221, 61, 105, 161, 78, 96, 61, 57, 95, 233, 159, 240, 141, 26, 219, 169, 58, 59, 161, 101, 17, 0, 164, 173, 208])), SecretKey(Scalar([47, 41, 27, 146, 132, 24, 23, 160, 109, 232, 197, 179, 225, 158, 173, 26, 65, 248, 184, 56, 142, 36, 194, 251, 250, 132, 207, 232, 53, 35, 168, 0])));
/// AWQ: boa1xrawq000dr28u23zxdmtdmle0zv967p97pzpqseegqa2lh9p7rqd5k3w00v
static immutable AWQ = KeyPair(PublicKey(Point([250, 224, 61, 239, 104, 212, 126, 42, 34, 51, 118, 182, 239, 249, 120, 152, 93, 120, 37, 240, 68, 16, 67, 57, 64, 58, 175, 220, 161, 240, 192, 218])), SecretKey(Scalar([98, 151, 209, 68, 160, 188, 147, 244, 28, 251, 139, 109, 29, 126, 219, 165, 194, 229, 152, 47, 163, 226, 190, 38, 51, 115, 219, 228, 225, 201, 195, 2])));
/// AWR: boa1xpawr00t8yu03d0ym0xvtdu54ttfw3e0r8gl3dgn6lvyp5nmkatszx2vy34
static immutable AWR = KeyPair(PublicKey(Point([122, 225, 189, 235, 57, 56, 248, 181, 228, 219, 204, 197, 183, 148, 170, 214, 151, 71, 47, 25, 209, 248, 181, 19, 215, 216, 64, 210, 123, 183, 87, 1])), SecretKey(Scalar([183, 59, 59, 11, 45, 51, 48, 120, 62, 147, 133, 93, 25, 151, 126, 143, 253, 117, 138, 24, 49, 128, 97, 175, 54, 101, 242, 54, 203, 81, 169, 15])));
/// AWS: boa1xzaws00aqglshwxt5uttmy2sm33kx23en40y97ywc3rklf6ah9afyqa9dkt
static immutable AWS = KeyPair(PublicKey(Point([186, 232, 61, 253, 2, 63, 11, 184, 203, 167, 22, 189, 145, 80, 220, 99, 99, 42, 57, 157, 94, 66, 248, 142, 196, 71, 111, 167, 93, 185, 122, 146])), SecretKey(Scalar([35, 181, 55, 206, 178, 39, 21, 68, 22, 196, 201, 150, 209, 163, 17, 83, 129, 131, 243, 33, 249, 222, 74, 233, 21, 1, 71, 15, 50, 163, 150, 12])));
/// AWT: boa1xrawt00zrkrwdf2rqs973zgjm35ucrvltxhewh25ktr2vyy8amprz3jc99w
static immutable AWT = KeyPair(PublicKey(Point([250, 229, 189, 226, 29, 134, 230, 165, 67, 4, 11, 232, 137, 18, 220, 105, 204, 13, 159, 89, 175, 151, 93, 84, 178, 198, 166, 16, 135, 238, 194, 49])), SecretKey(Scalar([204, 183, 165, 202, 89, 176, 166, 86, 178, 12, 45, 37, 248, 36, 19, 193, 175, 57, 16, 165, 232, 241, 96, 106, 18, 71, 178, 157, 77, 180, 27, 3])));
/// AWU: boa1xzawu00pp9uesgegsdv4z60zn9d4nxrr6skmz65fkxnjechusu5xkasj667
static immutable AWU = KeyPair(PublicKey(Point([186, 238, 61, 225, 9, 121, 152, 35, 40, 131, 89, 81, 105, 226, 153, 91, 89, 152, 99, 212, 45, 177, 106, 137, 177, 167, 44, 226, 252, 135, 40, 107])), SecretKey(Scalar([167, 161, 14, 138, 115, 42, 42, 43, 242, 194, 33, 39, 177, 111, 166, 44, 171, 56, 24, 42, 236, 96, 244, 194, 71, 238, 82, 92, 99, 97, 38, 12])));
/// AWV: boa1xqawv009hmm2vapqhgkwnrssc3g2epptx9ke9yg46xwhd06yxgylxxheh7z
static immutable AWV = KeyPair(PublicKey(Point([58, 230, 61, 229, 190, 246, 166, 116, 32, 186, 44, 233, 142, 16, 196, 80, 172, 132, 43, 49, 109, 146, 145, 21, 209, 157, 118, 191, 68, 50, 9, 243])), SecretKey(Scalar([228, 56, 70, 27, 168, 79, 65, 145, 253, 55, 201, 207, 5, 175, 167, 126, 66, 127, 200, 169, 199, 185, 104, 245, 64, 196, 192, 127, 29, 79, 140, 11])));
/// AWW: boa1xqaww00y0te2lzvqul8hwqthc4w9pjx3hekc4t6u2shjcaqg2h6e620upgd
static immutable AWW = KeyPair(PublicKey(Point([58, 231, 61, 228, 122, 242, 175, 137, 128, 231, 207, 119, 1, 119, 197, 92, 80, 200, 209, 190, 109, 138, 175, 92, 84, 47, 44, 116, 8, 85, 245, 157])), SecretKey(Scalar([159, 179, 52, 214, 200, 242, 111, 97, 194, 47, 107, 68, 214, 108, 108, 242, 15, 173, 155, 45, 78, 194, 161, 42, 178, 98, 70, 163, 60, 206, 35, 10])));
/// AWX: boa1xrawx00ee9dcy5nvsx6h2yp249su2jgpjvxmen486ycrywqmtlc0ygc8pzd
static immutable AWX = KeyPair(PublicKey(Point([250, 227, 61, 249, 201, 91, 130, 82, 108, 129, 181, 117, 16, 42, 169, 97, 197, 73, 1, 147, 13, 188, 206, 167, 209, 48, 50, 56, 27, 95, 240, 242])), SecretKey(Scalar([33, 187, 200, 121, 19, 6, 138, 103, 220, 101, 239, 50, 205, 143, 149, 198, 56, 230, 200, 199, 9, 211, 94, 111, 251, 173, 146, 53, 47, 229, 215, 12])));
/// AWY: boa1xqawy00l3d5m7ha6ygx33n7jlshnp8z78ceh6eqtmsj8g4t70wrqufqmak7
static immutable AWY = KeyPair(PublicKey(Point([58, 226, 61, 255, 139, 105, 191, 95, 186, 34, 13, 24, 207, 210, 252, 47, 48, 156, 94, 62, 51, 125, 100, 11, 220, 36, 116, 85, 126, 123, 134, 14])), SecretKey(Scalar([226, 245, 54, 206, 82, 70, 16, 244, 127, 166, 253, 169, 176, 195, 142, 131, 163, 87, 18, 35, 28, 119, 228, 92, 52, 226, 23, 175, 244, 83, 245, 6])));
/// AWZ: boa1xqawz0089esk869lfjxd49hwuqzd90ca2r95jaw5a07w89kpw2lrw57cfaw
static immutable AWZ = KeyPair(PublicKey(Point([58, 225, 61, 231, 46, 97, 99, 232, 191, 76, 140, 218, 150, 238, 224, 4, 210, 191, 29, 80, 203, 73, 117, 212, 235, 252, 227, 150, 193, 114, 190, 55])), SecretKey(Scalar([4, 120, 130, 204, 69, 91, 227, 5, 58, 124, 106, 60, 128, 101, 224, 71, 165, 117, 64, 14, 229, 92, 77, 128, 90, 53, 223, 91, 161, 218, 241, 7])));
/// AXA: boa1xraxa00k4plkdtf3tyjcs08022ct98zqqrjqdsua7qc2gapqguu2qu0ecns
static immutable AXA = KeyPair(PublicKey(Point([250, 110, 189, 246, 168, 127, 102, 173, 49, 89, 37, 136, 60, 239, 82, 176, 178, 156, 64, 0, 228, 6, 195, 157, 240, 48, 164, 116, 32, 71, 56, 160])), SecretKey(Scalar([4, 57, 126, 139, 82, 129, 69, 118, 156, 155, 127, 79, 248, 253, 196, 29, 106, 180, 15, 70, 86, 203, 123, 77, 163, 89, 80, 81, 4, 3, 20, 8])));
/// AXC: boa1xzaxc00tn4hk454c6p4y6r0cwlg4zxfevmmt35zrs04tgsc2e7ldx2r2uyv
static immutable AXC = KeyPair(PublicKey(Point([186, 108, 61, 235, 157, 111, 106, 210, 184, 208, 106, 77, 13, 248, 119, 209, 81, 25, 57, 102, 246, 184, 208, 67, 131, 234, 180, 67, 10, 207, 190, 211])), SecretKey(Scalar([204, 110, 99, 120, 92, 2, 252, 55, 169, 151, 52, 68, 185, 34, 163, 129, 36, 121, 151, 228, 175, 236, 31, 101, 210, 154, 80, 60, 131, 5, 198, 0])));
/// AXD: boa1xqaxd003rq4q5e9knl9v8jrk40jdj6j6dsytuaqrh322lgegp8l3wkna7ee
static immutable AXD = KeyPair(PublicKey(Point([58, 102, 189, 241, 24, 42, 10, 100, 182, 159, 202, 195, 200, 118, 171, 228, 217, 106, 90, 108, 8, 190, 116, 3, 188, 84, 175, 163, 40, 9, 255, 23])), SecretKey(Scalar([28, 118, 26, 253, 46, 172, 109, 101, 73, 136, 88, 200, 50, 6, 172, 76, 246, 199, 43, 177, 177, 153, 182, 219, 108, 234, 188, 43, 206, 166, 218, 9])));
/// AXE: boa1xqaxe00cqps8ghdh6vtqy6u200a5gney8gvuksffw3hwh4maz8llk932utf
static immutable AXE = KeyPair(PublicKey(Point([58, 108, 189, 248, 0, 96, 116, 93, 183, 211, 22, 2, 107, 138, 123, 251, 68, 79, 36, 58, 25, 203, 65, 41, 116, 110, 235, 215, 125, 17, 255, 251])), SecretKey(Scalar([84, 19, 137, 2, 182, 67, 189, 119, 17, 187, 213, 86, 29, 178, 54, 207, 6, 143, 116, 160, 121, 31, 49, 22, 152, 54, 206, 50, 179, 244, 83, 8])));
/// AXF: boa1xraxf00hwj5xq6gqpp2nexhl7twa6qlgvj83j8ffnwq7lff20q5d5rz5rrh
static immutable AXF = KeyPair(PublicKey(Point([250, 100, 189, 247, 116, 168, 96, 105, 0, 8, 85, 60, 154, 255, 242, 221, 221, 3, 232, 100, 143, 25, 29, 41, 155, 129, 239, 165, 42, 120, 40, 218])), SecretKey(Scalar([163, 33, 160, 88, 64, 3, 84, 141, 14, 153, 232, 191, 224, 189, 253, 116, 2, 232, 194, 82, 51, 188, 140, 215, 89, 47, 96, 193, 18, 11, 224, 8])));
/// AXG: boa1xraxg008gl227l57xnl4m9hxz3tgzcxxljxxck740zfe4aszf62acxpftc3
static immutable AXG = KeyPair(PublicKey(Point([250, 100, 61, 231, 71, 212, 175, 126, 158, 52, 255, 93, 150, 230, 20, 86, 129, 96, 198, 252, 140, 108, 91, 213, 120, 147, 154, 246, 2, 78, 149, 220])), SecretKey(Scalar([234, 110, 128, 86, 64, 248, 177, 130, 61, 228, 231, 1, 53, 34, 178, 110, 124, 108, 238, 156, 145, 138, 84, 63, 131, 27, 19, 2, 108, 218, 191, 5])));
/// AXH: boa1xzaxh00949tmsdq47ca7204ngjqsqrxlrkdfz3ju2gutkvmjq629642n8dp
static immutable AXH = KeyPair(PublicKey(Point([186, 107, 189, 229, 169, 87, 184, 52, 21, 246, 59, 229, 62, 179, 68, 129, 0, 12, 223, 29, 154, 145, 70, 92, 82, 56, 187, 51, 114, 6, 148, 93])), SecretKey(Scalar([246, 158, 15, 175, 11, 63, 79, 76, 174, 229, 140, 80, 94, 239, 43, 84, 124, 199, 194, 204, 117, 138, 122, 69, 63, 57, 77, 49, 213, 218, 151, 3])));
/// AXJ: boa1xqaxj009rt2e6dxjmhj0mdsj2ul9v5jy3m9tae2f6yffdnlgjljjsczmea3
static immutable AXJ = KeyPair(PublicKey(Point([58, 105, 61, 229, 26, 213, 157, 52, 210, 221, 228, 253, 182, 18, 87, 62, 86, 82, 68, 142, 202, 190, 229, 73, 209, 18, 150, 207, 232, 151, 229, 40])), SecretKey(Scalar([150, 181, 41, 222, 244, 43, 160, 94, 239, 221, 154, 100, 214, 46, 135, 156, 14, 46, 194, 179, 15, 238, 60, 53, 146, 13, 131, 98, 223, 169, 95, 14])));
/// AXK: boa1xqaxk006d907yp6a29fk3pvae0ujy5c5ajtwez9kkdqxcayg7nsawx5gss3
static immutable AXK = KeyPair(PublicKey(Point([58, 107, 61, 250, 105, 95, 226, 7, 93, 81, 83, 104, 133, 157, 203, 249, 34, 83, 20, 236, 150, 236, 136, 182, 179, 64, 108, 116, 136, 244, 225, 215])), SecretKey(Scalar([116, 179, 21, 155, 45, 175, 134, 173, 254, 63, 242, 173, 244, 11, 138, 66, 162, 138, 174, 190, 92, 163, 87, 116, 16, 197, 43, 178, 165, 128, 197, 14])));
/// AXL: boa1xqaxl00l48du2rx4epzussydmd5wsjcdzp8az87a9pc3vrzmhkdyvuqz6j9
static immutable AXL = KeyPair(PublicKey(Point([58, 111, 189, 255, 169, 219, 197, 12, 213, 200, 69, 200, 64, 141, 219, 104, 232, 75, 13, 16, 79, 209, 31, 221, 40, 113, 22, 12, 91, 189, 154, 70])), SecretKey(Scalar([221, 185, 160, 132, 92, 247, 35, 61, 237, 6, 30, 172, 111, 173, 168, 159, 192, 128, 159, 215, 110, 153, 69, 102, 146, 86, 127, 140, 242, 166, 23, 12])));
/// AXM: boa1xzaxm00enrxlr7wle4lz9vyglyzuk88xc7cslyev0e8g0f2qlccl73tsr0y
static immutable AXM = KeyPair(PublicKey(Point([186, 109, 189, 249, 152, 205, 241, 249, 223, 205, 126, 34, 176, 136, 249, 5, 203, 28, 230, 199, 177, 15, 147, 44, 126, 78, 135, 165, 64, 254, 49, 255])), SecretKey(Scalar([156, 190, 127, 201, 125, 219, 242, 227, 145, 110, 244, 14, 231, 232, 248, 95, 135, 247, 25, 33, 102, 163, 208, 186, 87, 33, 222, 223, 67, 137, 59, 0])));
/// AXN: boa1xraxn00kevc00tzwknxcqxef7jq9zanvn8squ6y6ktf86y8achzpv5zm59h
static immutable AXN = KeyPair(PublicKey(Point([250, 105, 189, 246, 203, 48, 247, 172, 78, 180, 205, 128, 27, 41, 244, 128, 81, 118, 108, 153, 224, 14, 104, 154, 178, 210, 125, 16, 253, 197, 196, 22])), SecretKey(Scalar([149, 33, 56, 170, 230, 114, 205, 144, 151, 35, 193, 223, 246, 64, 1, 106, 101, 153, 29, 189, 66, 85, 44, 145, 96, 135, 222, 75, 175, 248, 174, 0])));
/// AXP: boa1xpaxp00y9n6jpgj923tqg0zh0smj82x5hgfwg9n2gv485pc0x8s8suyrhqm
static immutable AXP = KeyPair(PublicKey(Point([122, 96, 189, 228, 44, 245, 32, 162, 69, 84, 86, 4, 60, 87, 124, 55, 35, 168, 212, 186, 18, 228, 22, 106, 67, 42, 122, 7, 15, 49, 224, 120])), SecretKey(Scalar([221, 30, 37, 107, 136, 185, 102, 216, 168, 22, 151, 2, 17, 97, 81, 225, 245, 74, 156, 41, 167, 115, 165, 96, 119, 130, 132, 135, 125, 175, 93, 11])));
/// AXQ: boa1xraxq00x70dgguaul05jj6r024fwvk5g623nppuzpnrgqc3tsv3c60ps2hf
static immutable AXQ = KeyPair(PublicKey(Point([250, 96, 61, 230, 243, 218, 132, 115, 188, 251, 233, 41, 104, 111, 85, 82, 230, 90, 136, 210, 163, 48, 135, 130, 12, 198, 128, 98, 43, 131, 35, 141])), SecretKey(Scalar([32, 84, 222, 255, 79, 179, 194, 156, 230, 115, 72, 210, 95, 198, 185, 29, 132, 48, 167, 115, 109, 240, 127, 84, 155, 104, 56, 250, 203, 61, 13, 15])));
/// AXR: boa1xraxr00n02wqwr4ywyrdjjfgdan8zdcezdgavu4z3gnjkugex52m5qc5e05
static immutable AXR = KeyPair(PublicKey(Point([250, 97, 189, 243, 122, 156, 7, 14, 164, 113, 6, 217, 73, 40, 111, 102, 113, 55, 25, 19, 81, 214, 114, 162, 138, 39, 43, 113, 25, 53, 21, 186])), SecretKey(Scalar([99, 81, 224, 249, 225, 107, 78, 89, 38, 56, 255, 25, 102, 160, 7, 3, 12, 66, 195, 133, 91, 144, 66, 71, 198, 147, 80, 64, 187, 148, 185, 12])));
/// AXS: boa1xzaxs00kjlrn9z5p8p798r60zz5elstphzre0ytjdatl2m2ypml9wf5fmdq
static immutable AXS = KeyPair(PublicKey(Point([186, 104, 61, 246, 151, 199, 50, 138, 129, 56, 124, 83, 143, 79, 16, 169, 159, 193, 97, 184, 135, 151, 145, 114, 111, 87, 245, 109, 68, 14, 254, 87])), SecretKey(Scalar([74, 3, 54, 131, 39, 216, 54, 157, 195, 194, 43, 77, 145, 44, 209, 5, 245, 166, 208, 239, 244, 57, 48, 255, 37, 8, 27, 224, 241, 175, 216, 9])));
/// AXT: boa1xqaxt002jc25v9mn8rtlx74g4dm85ly44w4mqdfmdq9x4ttcry6jcxmskca
static immutable AXT = KeyPair(PublicKey(Point([58, 101, 189, 234, 150, 21, 70, 23, 115, 56, 215, 243, 122, 168, 171, 118, 122, 124, 149, 171, 171, 176, 53, 59, 104, 10, 106, 173, 120, 25, 53, 44])), SecretKey(Scalar([10, 96, 30, 69, 56, 51, 170, 243, 136, 90, 70, 148, 38, 233, 88, 64, 101, 44, 147, 2, 35, 72, 12, 220, 60, 83, 102, 16, 123, 27, 70, 12])));
/// AXU: boa1xqaxu0086yf5hnysta3jdx8t07e9mu98tcqlg4zxlmhhx0yn84qukuxjwdy
static immutable AXU = KeyPair(PublicKey(Point([58, 110, 61, 231, 209, 19, 75, 204, 144, 95, 99, 38, 152, 235, 127, 178, 93, 240, 167, 94, 1, 244, 84, 70, 254, 239, 115, 60, 147, 61, 65, 203])), SecretKey(Scalar([207, 32, 170, 75, 215, 23, 165, 124, 156, 70, 23, 207, 20, 155, 119, 247, 49, 199, 20, 9, 198, 17, 213, 100, 78, 76, 216, 253, 18, 196, 64, 0])));
/// AXV: boa1xzaxv00aq7yk4z2pzweptrnym0z70n2muuv6y0arp5hgvem2fc2mqtswpv7
static immutable AXV = KeyPair(PublicKey(Point([186, 102, 61, 253, 7, 137, 106, 137, 65, 19, 178, 21, 142, 100, 219, 197, 231, 205, 91, 231, 25, 162, 63, 163, 13, 46, 134, 103, 106, 78, 21, 176])), SecretKey(Scalar([234, 57, 230, 17, 249, 159, 131, 40, 230, 112, 181, 161, 241, 20, 101, 4, 18, 153, 215, 48, 199, 202, 174, 242, 4, 220, 139, 51, 85, 43, 171, 11])));
/// AXW: boa1xraxw003hxwuntsymzf3vh3wj6z2hqfljrefqwm4txv2v43hxna6uwj9hnp
static immutable AXW = KeyPair(PublicKey(Point([250, 103, 61, 241, 185, 157, 201, 174, 4, 216, 147, 22, 94, 46, 150, 132, 171, 129, 63, 144, 242, 144, 59, 117, 89, 152, 166, 86, 55, 52, 251, 174])), SecretKey(Scalar([53, 53, 95, 143, 55, 38, 197, 139, 138, 151, 4, 93, 73, 140, 107, 166, 168, 239, 200, 141, 129, 75, 184, 189, 234, 9, 76, 98, 168, 65, 61, 4])));
/// AXX: boa1xzaxx00as9k7yr5grhl0hjrpg3qk08gghetv2hap66q3jxuhpqgus5f7ahp
static immutable AXX = KeyPair(PublicKey(Point([186, 99, 61, 253, 129, 109, 226, 14, 136, 29, 254, 251, 200, 97, 68, 65, 103, 157, 8, 190, 86, 197, 95, 161, 214, 129, 25, 27, 151, 8, 17, 200])), SecretKey(Scalar([96, 199, 86, 75, 30, 156, 44, 242, 238, 139, 6, 234, 234, 185, 94, 196, 177, 250, 104, 204, 13, 149, 193, 200, 153, 36, 164, 101, 130, 7, 57, 1])));
/// AXY: boa1xqaxy00cdcuvwvxp0s88ty6g8e7lcesz5vt5d4taeptpvp02ujztc0dtac7
static immutable AXY = KeyPair(PublicKey(Point([58, 98, 61, 248, 110, 56, 199, 48, 193, 124, 14, 117, 147, 72, 62, 125, 252, 102, 2, 163, 23, 70, 213, 125, 200, 86, 22, 5, 234, 228, 132, 188])), SecretKey(Scalar([79, 57, 222, 219, 4, 31, 170, 196, 56, 156, 28, 35, 52, 42, 146, 182, 116, 97, 62, 170, 150, 179, 162, 82, 120, 69, 42, 204, 74, 143, 166, 12])));
/// AXZ: boa1xpaxz009vykc4uer6e8796m37gfc5rr9863vdf8nrqs3qcugt7auj58ksp0
static immutable AXZ = KeyPair(PublicKey(Point([122, 97, 61, 229, 97, 45, 138, 243, 35, 214, 79, 226, 235, 113, 242, 19, 138, 12, 101, 62, 162, 198, 164, 243, 24, 33, 16, 99, 136, 95, 187, 201])), SecretKey(Scalar([68, 23, 6, 164, 46, 9, 228, 230, 154, 230, 118, 135, 120, 20, 254, 166, 94, 125, 95, 121, 164, 253, 47, 36, 177, 196, 186, 1, 43, 206, 32, 5])));
/// AYA: boa1xpaya007e6pvj2q3jszrtyues0hwgfq3w578eyctcdnzw2pgyacj7t7jrw0
static immutable AYA = KeyPair(PublicKey(Point([122, 78, 189, 254, 206, 130, 201, 40, 17, 148, 4, 53, 147, 153, 131, 238, 228, 36, 17, 117, 60, 124, 147, 11, 195, 102, 39, 40, 40, 39, 113, 47])), SecretKey(Scalar([28, 130, 99, 158, 61, 222, 6, 192, 98, 140, 122, 227, 169, 169, 11, 188, 105, 34, 76, 57, 12, 154, 214, 57, 9, 67, 61, 158, 206, 176, 33, 8])));
/// AYC: boa1xrayc00txazyr6nclr9cs99mf9k0y6lpcl50varktnyu5taz7824yhs3j32
static immutable AYC = KeyPair(PublicKey(Point([250, 76, 61, 235, 55, 68, 65, 234, 120, 248, 203, 136, 20, 187, 73, 108, 242, 107, 225, 199, 232, 246, 116, 118, 92, 201, 202, 47, 162, 241, 213, 82])), SecretKey(Scalar([121, 185, 16, 42, 71, 156, 172, 205, 93, 167, 231, 65, 174, 255, 126, 158, 63, 19, 191, 119, 204, 147, 74, 195, 124, 212, 193, 43, 33, 181, 115, 4])));
/// AYD: boa1xpayd006c8c72ay03fpxwl9ng886ad7lsycauw2sw0h9r4wd54racnt5cqr
static immutable AYD = KeyPair(PublicKey(Point([122, 70, 189, 250, 193, 241, 229, 116, 143, 138, 66, 103, 124, 179, 65, 207, 174, 183, 223, 129, 49, 222, 57, 80, 115, 238, 81, 213, 205, 165, 71, 220])), SecretKey(Scalar([175, 164, 83, 7, 74, 192, 32, 144, 54, 92, 100, 11, 175, 218, 32, 76, 91, 46, 107, 231, 153, 27, 169, 91, 188, 49, 172, 85, 133, 25, 10, 13])));
/// AYE: boa1xqaye00gje45twpxx0h8u8eatwmmsn04mkmpwxrrwra2r7uyptgf7fr6g28
static immutable AYE = KeyPair(PublicKey(Point([58, 76, 189, 232, 150, 107, 69, 184, 38, 51, 238, 126, 31, 61, 91, 183, 184, 77, 245, 221, 182, 23, 24, 99, 112, 250, 161, 251, 132, 10, 208, 159])), SecretKey(Scalar([44, 207, 128, 196, 211, 232, 83, 59, 180, 254, 37, 34, 0, 45, 254, 75, 58, 236, 254, 45, 147, 74, 168, 192, 56, 7, 206, 95, 43, 176, 144, 10])));
/// AYF: boa1xrayf00mn0g8m3t0q9u763qrah6s4d6fju6uutkl0z9uhxmlgvyusszw043
static immutable AYF = KeyPair(PublicKey(Point([250, 68, 189, 251, 155, 208, 125, 197, 111, 1, 121, 237, 68, 3, 237, 245, 10, 183, 73, 151, 53, 206, 46, 223, 120, 139, 203, 155, 127, 67, 9, 200])), SecretKey(Scalar([156, 214, 251, 123, 119, 11, 92, 8, 227, 225, 48, 78, 54, 46, 145, 156, 76, 46, 134, 67, 47, 230, 119, 36, 200, 73, 236, 180, 70, 82, 114, 4])));
/// AYG: boa1xzayg00dg6quth20y34j4tjqk9scz2vf267vmljk0qg48h5tqmr9k9wl6ed
static immutable AYG = KeyPair(PublicKey(Point([186, 68, 61, 237, 70, 129, 197, 221, 79, 36, 107, 42, 174, 64, 177, 97, 129, 41, 137, 86, 188, 205, 254, 86, 120, 17, 83, 222, 139, 6, 198, 91])), SecretKey(Scalar([65, 151, 136, 158, 67, 74, 101, 86, 74, 178, 41, 201, 247, 202, 94, 176, 78, 73, 52, 216, 72, 169, 109, 170, 176, 239, 29, 5, 20, 163, 110, 12])));
/// AYH: boa1xqayh00y76kls2t8qduleas0pkk6gjr2y33xp7em495zu5y6eg8czt0q4d7
static immutable AYH = KeyPair(PublicKey(Point([58, 75, 189, 228, 246, 173, 248, 41, 103, 3, 121, 252, 246, 15, 13, 173, 164, 72, 106, 36, 98, 96, 251, 59, 169, 104, 46, 80, 154, 202, 15, 129])), SecretKey(Scalar([207, 179, 176, 237, 149, 241, 205, 83, 9, 3, 105, 93, 69, 0, 244, 166, 58, 11, 11, 165, 92, 203, 82, 140, 77, 124, 191, 245, 24, 210, 225, 0])));
/// AYJ: boa1xzayj009yeg6p485lan6w77kmtp2y9cesv3slvvu9hgedjk766gvspe7nrz
static immutable AYJ = KeyPair(PublicKey(Point([186, 73, 61, 229, 38, 81, 160, 212, 244, 255, 103, 167, 123, 214, 218, 194, 162, 23, 25, 131, 35, 15, 177, 156, 45, 209, 150, 202, 222, 214, 144, 200])), SecretKey(Scalar([70, 213, 218, 146, 188, 146, 178, 174, 247, 130, 14, 146, 227, 143, 111, 91, 107, 208, 164, 8, 49, 46, 92, 86, 162, 194, 50, 122, 193, 108, 128, 1])));
/// AYK: boa1xrayk00fyu3k6w22v8vlky6ykyjd3uma3q7nha3wu97g0epn6jm75pu7l47
static immutable AYK = KeyPair(PublicKey(Point([250, 75, 61, 233, 39, 35, 109, 57, 74, 97, 217, 251, 19, 68, 177, 36, 216, 243, 125, 136, 61, 59, 246, 46, 225, 124, 135, 228, 51, 212, 183, 234])), SecretKey(Scalar([113, 171, 84, 175, 90, 238, 12, 79, 57, 216, 129, 245, 24, 97, 129, 161, 56, 49, 205, 201, 7, 14, 228, 59, 175, 185, 112, 15, 9, 51, 218, 8])));
/// AYL: boa1xzayl007ea0jcy7ef649m7t8uf7wws6ga2jc7q8gttl58vmv8lphslauevt
static immutable AYL = KeyPair(PublicKey(Point([186, 79, 189, 254, 207, 95, 44, 19, 217, 78, 170, 93, 249, 103, 226, 124, 231, 67, 72, 234, 165, 143, 0, 232, 90, 255, 67, 179, 108, 63, 195, 120])), SecretKey(Scalar([166, 33, 83, 62, 171, 81, 35, 242, 54, 69, 246, 172, 122, 113, 176, 18, 201, 10, 220, 143, 98, 33, 37, 36, 233, 66, 182, 60, 101, 69, 196, 10])));
/// AYM: boa1xraym009knpsxzguqz2mzjq78x0n06l9c2m3683346xd4vv3crq5qy7kx2y
static immutable AYM = KeyPair(PublicKey(Point([250, 77, 189, 229, 180, 195, 3, 9, 28, 0, 149, 177, 72, 30, 57, 159, 55, 235, 229, 194, 183, 29, 30, 49, 174, 140, 218, 177, 145, 192, 193, 64])), SecretKey(Scalar([216, 39, 216, 88, 31, 20, 7, 56, 91, 131, 107, 32, 90, 248, 40, 72, 232, 223, 238, 0, 206, 8, 142, 77, 72, 85, 84, 13, 218, 103, 205, 15])));
/// AYN: boa1xqayn007kmwypqljgfgkgau36naqt9c70qmmrfd368xy423fe6uhgyngwgd
static immutable AYN = KeyPair(PublicKey(Point([58, 73, 189, 254, 182, 220, 64, 131, 242, 66, 81, 100, 119, 145, 212, 250, 5, 151, 30, 120, 55, 177, 165, 177, 209, 204, 74, 170, 41, 206, 185, 116])), SecretKey(Scalar([123, 144, 137, 66, 91, 228, 31, 1, 205, 88, 144, 161, 26, 140, 192, 82, 182, 193, 96, 188, 72, 39, 158, 254, 20, 96, 188, 142, 147, 47, 6, 15])));
/// AYP: boa1xqayp00kxu7pnzkp480080jp7zzkt5sycjklvex2zdaglmhm3pdcw5azjnr
static immutable AYP = KeyPair(PublicKey(Point([58, 64, 189, 246, 55, 60, 25, 138, 193, 169, 222, 243, 190, 65, 240, 133, 101, 210, 4, 196, 173, 246, 100, 202, 19, 122, 143, 238, 251, 136, 91, 135])), SecretKey(Scalar([48, 25, 21, 86, 5, 87, 207, 130, 65, 231, 180, 68, 19, 116, 123, 164, 142, 87, 106, 63, 108, 100, 164, 175, 229, 66, 71, 150, 189, 253, 73, 10])));
/// AYQ: boa1xpayq002q5zlzm8hr5t7s523lw2ejpgmzdyz3mj2mj864h6prv566wsgjew
static immutable AYQ = KeyPair(PublicKey(Point([122, 64, 61, 234, 5, 5, 241, 108, 247, 29, 23, 232, 81, 81, 251, 149, 153, 5, 27, 19, 72, 40, 238, 74, 220, 143, 170, 223, 65, 27, 41, 173])), SecretKey(Scalar([122, 86, 209, 120, 205, 55, 76, 44, 226, 111, 140, 183, 175, 67, 14, 20, 130, 120, 169, 3, 168, 103, 253, 122, 243, 229, 175, 57, 42, 167, 226, 3])));
/// AYR: boa1xzayr00t5v20ys00rv65d0q0h4kpjd5h8tpm0lf2q0pu6x76jy07zdae8zv
static immutable AYR = KeyPair(PublicKey(Point([186, 65, 189, 235, 163, 20, 242, 65, 239, 27, 53, 70, 188, 15, 189, 108, 25, 54, 151, 58, 195, 183, 253, 42, 3, 195, 205, 27, 218, 145, 31, 225])), SecretKey(Scalar([219, 72, 248, 229, 23, 59, 11, 136, 135, 123, 164, 248, 28, 87, 214, 117, 160, 239, 104, 51, 76, 179, 56, 99, 63, 149, 147, 136, 19, 151, 91, 9])));
/// AYS: boa1xpays00ermus4kv9xucfysv4nfpcl7r86kxez275gpxz40l46ye0zxxhyuf
static immutable AYS = KeyPair(PublicKey(Point([122, 72, 61, 249, 30, 249, 10, 217, 133, 55, 48, 146, 65, 149, 154, 67, 143, 248, 103, 213, 141, 145, 43, 212, 64, 76, 42, 191, 245, 209, 50, 241])), SecretKey(Scalar([45, 212, 119, 187, 35, 228, 5, 37, 102, 8, 135, 150, 30, 0, 6, 108, 218, 167, 74, 14, 161, 186, 102, 188, 219, 60, 133, 136, 92, 217, 106, 14])));
/// AYT: boa1xqayt00n7yl7d50pmm73w0ykc667kf4xk8h7wnz8k0vtkvw0mq8mjn08upc
static immutable AYT = KeyPair(PublicKey(Point([58, 69, 189, 243, 241, 63, 230, 209, 225, 222, 253, 23, 60, 150, 198, 181, 235, 38, 166, 177, 239, 231, 76, 71, 179, 216, 187, 49, 207, 216, 15, 185])), SecretKey(Scalar([135, 154, 12, 50, 142, 69, 255, 195, 238, 151, 138, 250, 230, 74, 70, 233, 132, 103, 219, 151, 246, 158, 134, 63, 189, 42, 60, 182, 189, 114, 70, 2])));
/// AYU: boa1xpayu00jdw8r4frucwhvhkxm6hupejjh5c3mga7e9689kl6y6az5uccxksx
static immutable AYU = KeyPair(PublicKey(Point([122, 78, 61, 242, 107, 142, 58, 164, 124, 195, 174, 203, 216, 219, 213, 248, 28, 202, 87, 166, 35, 180, 119, 217, 46, 142, 91, 127, 68, 215, 69, 78])), SecretKey(Scalar([61, 61, 171, 65, 94, 33, 12, 249, 228, 140, 26, 171, 8, 69, 82, 40, 24, 18, 20, 29, 193, 213, 112, 139, 26, 176, 124, 47, 185, 128, 203, 1])));
/// AYV: boa1xrayv00yf6mqp7h4hcvhzq0g7tku7x2kdk8p9w6nuvzy6wqw3008g3wf74n
static immutable AYV = KeyPair(PublicKey(Point([250, 70, 61, 228, 78, 182, 0, 250, 245, 190, 25, 113, 1, 232, 242, 237, 207, 25, 86, 109, 142, 18, 187, 83, 227, 4, 77, 56, 14, 139, 222, 116])), SecretKey(Scalar([206, 123, 130, 143, 181, 97, 23, 108, 9, 64, 254, 3, 5, 27, 153, 170, 142, 237, 30, 219, 65, 153, 80, 193, 194, 162, 141, 165, 133, 253, 77, 6])));
/// AYW: boa1xqayw00f6rydlv0d66aqqmw8fe7ed68g2ac6cergpr3qqz5euvc6qq6frur
static immutable AYW = KeyPair(PublicKey(Point([58, 71, 61, 233, 208, 200, 223, 177, 237, 214, 186, 0, 109, 199, 78, 125, 150, 232, 232, 87, 113, 172, 100, 104, 8, 226, 0, 10, 153, 227, 49, 160])), SecretKey(Scalar([49, 178, 126, 9, 43, 29, 0, 75, 141, 184, 181, 241, 54, 33, 62, 82, 228, 117, 21, 156, 72, 153, 164, 204, 166, 13, 87, 119, 178, 185, 46, 11])));
/// AYX: boa1xqayx00kkhzmfvrec3wv54uk3gglzvr2m4jhdrlxd3w5cspss3qlvurnm67
static immutable AYX = KeyPair(PublicKey(Point([58, 67, 61, 246, 181, 197, 180, 176, 121, 196, 92, 202, 87, 150, 138, 17, 241, 48, 106, 221, 101, 118, 143, 230, 108, 93, 76, 64, 48, 132, 65, 246])), SecretKey(Scalar([19, 31, 243, 84, 222, 207, 153, 72, 220, 194, 19, 4, 43, 145, 230, 150, 246, 65, 144, 162, 201, 30, 217, 69, 92, 207, 4, 78, 193, 93, 27, 12])));
/// AYY: boa1xqayy00kny0wmce29y0jv68vq5dkyvfj879hxwu3myu8cktgn23pzuqu5hl
static immutable AYY = KeyPair(PublicKey(Point([58, 66, 61, 246, 153, 30, 237, 227, 42, 41, 31, 38, 104, 236, 5, 27, 98, 49, 50, 63, 139, 115, 59, 145, 217, 56, 124, 89, 104, 154, 162, 17])), SecretKey(Scalar([251, 90, 189, 94, 193, 213, 69, 98, 231, 18, 119, 184, 125, 220, 16, 42, 248, 5, 254, 49, 183, 160, 114, 35, 122, 35, 20, 236, 139, 44, 111, 8])));
/// AYZ: boa1xqayz00qxurl7dxcwfnqfguye90prekpyftnf2lh46hx24246zhd6gvzl9f
static immutable AYZ = KeyPair(PublicKey(Point([58, 65, 61, 224, 55, 7, 255, 52, 216, 114, 102, 4, 163, 132, 201, 94, 17, 230, 193, 34, 87, 52, 171, 247, 174, 174, 101, 85, 85, 208, 174, 221])), SecretKey(Scalar([59, 63, 126, 3, 251, 210, 175, 101, 21, 24, 236, 251, 112, 32, 116, 123, 19, 146, 174, 110, 126, 39, 108, 215, 121, 6, 186, 101, 117, 189, 221, 10])));
/// AZA: boa1xzaza00y7vqg6kqfs4y5nsxxch7s400d6ggggm25wgzte7qqf0wdkvpgyyd
static immutable AZA = KeyPair(PublicKey(Point([186, 46, 189, 228, 243, 0, 141, 88, 9, 133, 73, 73, 192, 198, 197, 253, 10, 189, 237, 210, 16, 132, 109, 84, 114, 4, 188, 248, 0, 75, 220, 219])), SecretKey(Scalar([9, 68, 114, 3, 7, 209, 247, 42, 138, 212, 68, 141, 42, 189, 247, 108, 162, 34, 236, 119, 212, 138, 111, 108, 189, 251, 170, 127, 156, 123, 172, 10])));
/// AZC: boa1xzazc00y5enl4u0u0csqrmsp4k7e6808qtpwttzgutsxlmwnnc5qusxkh4u
static immutable AZC = KeyPair(PublicKey(Point([186, 44, 61, 228, 166, 103, 250, 241, 252, 126, 32, 1, 238, 1, 173, 189, 157, 29, 231, 2, 194, 229, 172, 72, 226, 224, 111, 237, 211, 158, 40, 14])), SecretKey(Scalar([77, 161, 100, 147, 93, 169, 174, 216, 79, 206, 0, 18, 163, 63, 9, 92, 98, 160, 106, 139, 74, 163, 143, 240, 122, 39, 224, 102, 77, 221, 41, 12])));
/// AZD: boa1xrazd00xpspk7nyr74glax7783n0wejnz474sx6x5g0pqv3fzyc76scnfq8
static immutable AZD = KeyPair(PublicKey(Point([250, 38, 189, 230, 12, 3, 111, 76, 131, 245, 81, 254, 155, 222, 60, 102, 247, 102, 83, 21, 125, 88, 27, 70, 162, 30, 16, 50, 41, 17, 49, 237])), SecretKey(Scalar([68, 156, 223, 137, 36, 72, 51, 27, 68, 51, 11, 109, 25, 17, 216, 157, 122, 147, 160, 100, 83, 236, 214, 250, 196, 194, 229, 76, 231, 29, 124, 1])));
/// AZE: boa1xpaze00xuys0dqgzwmvjafv7nzvaawg4tzd0fmup2pyghfmp42zd77lhr3y
static immutable AZE = KeyPair(PublicKey(Point([122, 44, 189, 230, 225, 32, 246, 129, 2, 118, 217, 46, 165, 158, 152, 153, 222, 185, 21, 88, 154, 244, 239, 129, 80, 72, 139, 167, 97, 170, 132, 223])), SecretKey(Scalar([170, 42, 137, 104, 206, 58, 95, 242, 73, 206, 179, 92, 146, 158, 180, 80, 6, 187, 78, 65, 236, 21, 35, 245, 230, 77, 197, 206, 23, 175, 68, 9])));
/// AZF: boa1xqazf00xacy7yql45crfvacgy0smj4ef98z7s84p6k0wvss50564z7pnvjd
static immutable AZF = KeyPair(PublicKey(Point([58, 36, 189, 230, 238, 9, 226, 3, 245, 166, 6, 150, 119, 8, 35, 225, 185, 87, 41, 41, 197, 232, 30, 161, 213, 158, 230, 66, 20, 125, 53, 81])), SecretKey(Scalar([236, 14, 23, 12, 97, 68, 5, 212, 190, 166, 228, 231, 215, 78, 118, 228, 86, 138, 245, 59, 230, 163, 177, 212, 85, 45, 89, 235, 54, 77, 199, 9])));
/// AZG: boa1xzazg00vx7daynud3cz9qndqga67v4krs5296wee02ywgll74zwr5ddefkl
static immutable AZG = KeyPair(PublicKey(Point([186, 36, 61, 236, 55, 155, 210, 79, 141, 142, 4, 80, 77, 160, 71, 117, 230, 86, 195, 133, 20, 93, 59, 57, 122, 136, 228, 127, 254, 168, 156, 58])), SecretKey(Scalar([93, 144, 111, 171, 196, 246, 9, 162, 252, 19, 139, 127, 70, 173, 113, 90, 22, 136, 54, 230, 180, 218, 244, 207, 87, 57, 66, 250, 43, 168, 167, 5])));
/// AZH: boa1xqazh00csl503mqhflk0t9zh6edmh3km2kgzks69eqzzwxkqrqgzkfpnyhr
static immutable AZH = KeyPair(PublicKey(Point([58, 43, 189, 248, 135, 232, 248, 236, 23, 79, 236, 245, 148, 87, 214, 91, 187, 198, 219, 85, 144, 43, 67, 69, 200, 4, 39, 26, 192, 24, 16, 43])), SecretKey(Scalar([175, 128, 2, 65, 193, 173, 118, 116, 68, 224, 124, 143, 71, 95, 217, 142, 157, 227, 5, 221, 255, 200, 226, 247, 129, 250, 173, 203, 192, 255, 107, 13])));
/// AZJ: boa1xzazj00rtumaewys6nfk3hcaud3pgnt3etdqj9x77pyhj6myzlngv9my8j7
static immutable AZJ = KeyPair(PublicKey(Point([186, 41, 61, 227, 95, 55, 220, 184, 144, 212, 211, 104, 223, 29, 227, 98, 20, 77, 113, 202, 218, 9, 20, 222, 240, 73, 121, 107, 100, 23, 230, 134])), SecretKey(Scalar([111, 196, 56, 22, 2, 6, 10, 30, 255, 138, 26, 234, 50, 80, 58, 191, 53, 215, 176, 111, 247, 93, 235, 105, 166, 188, 130, 14, 233, 174, 47, 1])));
/// AZK: boa1xqazk00tfz37jkdmqfnp9r5kshwptw3mt4x8uv984fwfl9qtuyzxqu5cvk3
static immutable AZK = KeyPair(PublicKey(Point([58, 43, 61, 235, 72, 163, 233, 89, 187, 2, 102, 18, 142, 150, 133, 220, 21, 186, 59, 93, 76, 126, 48, 167, 170, 92, 159, 148, 11, 225, 4, 96])), SecretKey(Scalar([90, 18, 117, 72, 57, 251, 233, 75, 63, 100, 203, 40, 165, 249, 29, 56, 102, 177, 92, 215, 176, 68, 140, 208, 161, 88, 214, 74, 115, 220, 52, 14])));
/// AZL: boa1xqazl00nfwzxpjnhmjvz7c96ckt25nvqddnjgf4jq8wr5u0fqqn0xu5nmag
static immutable AZL = KeyPair(PublicKey(Point([58, 47, 189, 243, 75, 132, 96, 202, 119, 220, 152, 47, 96, 186, 197, 150, 170, 77, 128, 107, 103, 36, 38, 178, 1, 220, 58, 113, 233, 0, 38, 243])), SecretKey(Scalar([19, 105, 222, 2, 17, 26, 156, 223, 46, 137, 112, 26, 154, 149, 135, 220, 185, 224, 183, 90, 43, 42, 21, 92, 154, 192, 248, 78, 240, 69, 244, 1])));
/// AZM: boa1xqazm00yuegrvvc4gx6l8y8tecxqgfrxhxxnp7t7878vn9xeavnl5jv35yt
static immutable AZM = KeyPair(PublicKey(Point([58, 45, 189, 228, 230, 80, 54, 51, 21, 65, 181, 243, 144, 235, 206, 12, 4, 36, 102, 185, 141, 48, 249, 126, 63, 142, 201, 148, 217, 235, 39, 250])), SecretKey(Scalar([150, 206, 253, 169, 235, 25, 225, 39, 188, 21, 219, 212, 159, 167, 121, 106, 161, 181, 115, 200, 173, 102, 89, 208, 74, 14, 164, 114, 134, 63, 80, 14])));
/// AZN: boa1xpazn009lmsyg5evqqqvzntkjhdzu6zlu7wgc0xtdhgcsszndaha554f95d
static immutable AZN = KeyPair(PublicKey(Point([122, 41, 189, 229, 254, 224, 68, 83, 44, 0, 0, 193, 77, 118, 149, 218, 46, 104, 95, 231, 156, 140, 60, 203, 109, 209, 136, 64, 83, 111, 111, 218])), SecretKey(Scalar([105, 221, 233, 207, 92, 92, 228, 189, 36, 184, 233, 156, 64, 149, 141, 147, 11, 146, 204, 20, 123, 0, 19, 216, 45, 153, 181, 111, 114, 240, 11, 4])));
/// AZP: boa1xrazp00twuzz6aqpcc29k5sjuujuxmprcpuup9h5qdq6307ruad7ks2ewll
static immutable AZP = KeyPair(PublicKey(Point([250, 32, 189, 235, 119, 4, 45, 116, 1, 198, 20, 91, 82, 18, 231, 37, 195, 108, 35, 192, 121, 192, 150, 244, 3, 65, 168, 191, 195, 231, 91, 235])), SecretKey(Scalar([252, 127, 46, 235, 202, 124, 216, 29, 162, 201, 232, 168, 253, 64, 155, 167, 31, 11, 221, 103, 67, 161, 46, 244, 115, 64, 37, 218, 68, 143, 177, 6])));
/// AZQ: boa1xqazq005vdqzes9nq0nqx6y4ppvmyvwclu9z86scxpz6wxwr8y7n5qg5f82
static immutable AZQ = KeyPair(PublicKey(Point([58, 32, 61, 244, 99, 64, 44, 192, 179, 3, 230, 3, 104, 149, 8, 89, 178, 49, 216, 255, 10, 35, 234, 24, 48, 69, 167, 25, 195, 57, 61, 58])), SecretKey(Scalar([27, 120, 245, 55, 250, 18, 197, 160, 94, 239, 48, 65, 37, 157, 109, 201, 1, 128, 100, 254, 46, 27, 217, 53, 234, 204, 88, 239, 26, 171, 128, 0])));
/// AZR: boa1xqazr009v586szfa3wya26ach24qvldnweve3cqz64zll964qzn8x5g8x72
static immutable AZR = KeyPair(PublicKey(Point([58, 33, 189, 229, 101, 15, 168, 9, 61, 139, 137, 213, 107, 184, 186, 170, 6, 125, 179, 118, 89, 152, 224, 2, 213, 69, 255, 151, 85, 0, 166, 115])), SecretKey(Scalar([86, 205, 32, 175, 212, 7, 54, 219, 221, 92, 151, 236, 95, 209, 82, 10, 169, 147, 210, 61, 61, 27, 51, 18, 199, 86, 11, 211, 233, 138, 146, 10])));
/// AZS: boa1xqazs00psj6met5rfxeqe47305ww6m5n44tal3rlqyktveaelc7rgwvm9yt
static immutable AZS = KeyPair(PublicKey(Point([58, 40, 61, 225, 132, 181, 188, 174, 131, 73, 178, 12, 215, 209, 125, 28, 237, 110, 147, 173, 87, 223, 196, 127, 1, 44, 182, 103, 185, 254, 60, 52])), SecretKey(Scalar([111, 7, 77, 22, 238, 167, 216, 125, 164, 27, 2, 98, 95, 39, 242, 235, 5, 252, 102, 185, 106, 99, 198, 112, 243, 179, 112, 144, 163, 164, 105, 8])));
/// AZT: boa1xpazt00n33tj96tcpd5zf0266lzx39t6ml4cpp380jdwnnxt0fmc7au3u84
static immutable AZT = KeyPair(PublicKey(Point([122, 37, 189, 243, 140, 87, 34, 233, 120, 11, 104, 36, 189, 90, 215, 196, 104, 149, 122, 223, 235, 128, 134, 39, 124, 154, 233, 204, 203, 122, 119, 143])), SecretKey(Scalar([115, 238, 227, 207, 235, 156, 1, 226, 26, 85, 111, 0, 199, 26, 188, 81, 2, 22, 67, 140, 122, 238, 40, 0, 18, 47, 105, 210, 169, 35, 185, 1])));
/// AZU: boa1xzazu00l86xjw4k8s66augqeqhta5vx40pczgpn8msc8anqgyyjuqtp7g3h
static immutable AZU = KeyPair(PublicKey(Point([186, 46, 61, 255, 62, 141, 39, 86, 199, 134, 181, 222, 32, 25, 5, 215, 218, 48, 213, 120, 112, 36, 6, 103, 220, 48, 126, 204, 8, 33, 37, 192])), SecretKey(Scalar([26, 36, 89, 64, 105, 135, 118, 90, 176, 19, 133, 142, 61, 50, 122, 72, 155, 253, 11, 84, 28, 73, 30, 178, 107, 139, 143, 218, 55, 48, 184, 3])));
/// AZV: boa1xrazv00s96uk7rr6ew9vdwxndrjhuj5cqslc5staw4msu5m7wm2s7kkuvx7
static immutable AZV = KeyPair(PublicKey(Point([250, 38, 61, 240, 46, 185, 111, 12, 122, 203, 138, 198, 184, 211, 104, 229, 126, 74, 152, 4, 63, 138, 65, 125, 117, 119, 14, 83, 126, 118, 213, 15])), SecretKey(Scalar([70, 241, 61, 162, 222, 197, 253, 200, 208, 251, 200, 94, 129, 199, 47, 17, 236, 136, 239, 122, 161, 161, 242, 249, 230, 136, 81, 185, 130, 15, 182, 12])));
/// AZW: boa1xrazw004masr4cgtce8x2d3fscuy7cu3n5fqey9wnnp7l4837el36j7ka07
static immutable AZW = KeyPair(PublicKey(Point([250, 39, 61, 245, 223, 96, 58, 225, 11, 198, 78, 101, 54, 41, 134, 56, 79, 99, 145, 157, 18, 12, 144, 174, 156, 195, 239, 212, 241, 246, 127, 29])), SecretKey(Scalar([186, 156, 52, 28, 18, 43, 172, 136, 44, 226, 148, 26, 181, 10, 222, 5, 249, 176, 41, 239, 99, 140, 195, 9, 200, 14, 10, 81, 143, 186, 252, 5])));
/// AZX: boa1xpazx00hp2a9hmphwmkm28vme6tfquxka4jyx76lgtu9vcgmcrfvjk5hax9
static immutable AZX = KeyPair(PublicKey(Point([122, 35, 61, 247, 10, 186, 91, 236, 55, 118, 237, 181, 29, 155, 206, 150, 144, 112, 214, 237, 100, 67, 123, 95, 66, 248, 86, 97, 27, 192, 210, 201])), SecretKey(Scalar([247, 180, 143, 75, 137, 194, 188, 171, 105, 141, 75, 43, 205, 226, 1, 229, 250, 131, 123, 75, 201, 142, 141, 125, 190, 6, 210, 46, 180, 138, 22, 15])));
/// AZY: boa1xpazy00l0n5wkxz340jmkfew5s4jc2hpfal405u6cslng6djj688vzfsxfr
static immutable AZY = KeyPair(PublicKey(Point([122, 34, 61, 255, 124, 232, 235, 24, 81, 171, 229, 187, 39, 46, 164, 43, 44, 42, 225, 79, 127, 87, 211, 154, 196, 63, 52, 105, 178, 150, 142, 118])), SecretKey(Scalar([174, 79, 45, 29, 147, 93, 35, 128, 195, 250, 186, 180, 143, 134, 112, 206, 67, 186, 31, 73, 84, 116, 230, 68, 56, 87, 87, 167, 144, 211, 37, 3])));
/// AZZ: boa1xqazz00hxa5wwvdjxr00xayrx4sc3elcnryuanpq2ejpculmgeajkfms7pf
static immutable AZZ = KeyPair(PublicKey(Point([58, 33, 61, 247, 55, 104, 231, 49, 178, 48, 222, 243, 116, 131, 53, 97, 136, 231, 248, 152, 201, 206, 204, 32, 86, 100, 28, 115, 251, 70, 123, 43])), SecretKey(Scalar([36, 180, 79, 163, 106, 207, 5, 209, 29, 128, 173, 127, 19, 122, 124, 20, 77, 204, 176, 125, 49, 125, 240, 44, 240, 42, 44, 73, 148, 172, 88, 9])));

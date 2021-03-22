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
    switch (index)
    {
    case 0: return A;
    case 1: return B;
    case 2: return C;
    case 3: return D;
    case 4: return E;
    case 5: return F;
    case 6: return G;
    case 7: return H;
    case 8: return I;
    case 9: return J;
    case 10: return K;
    case 11: return L;
    case 12: return M;
    case 13: return N;
    case 14: return O;
    case 15: return P;
    case 16: return Q;
    case 17: return R;
    case 18: return S;
    case 19: return T;
    case 20: return U;
    case 21: return V;
    case 22: return W;
    case 23: return X;
    case 24: return Y;
    case 25: return Z;
    case 26: return AA;
    case 27: return AB;
    case 28: return AC;
    case 29: return AD;
    case 30: return AE;
    case 31: return AF;
    case 32: return AG;
    case 33: return AH;
    case 34: return AI;
    case 35: return AJ;
    case 36: return AK;
    case 37: return AL;
    case 38: return AM;
    case 39: return AN;
    case 40: return AO;
    case 41: return AP;
    case 42: return AQ;
    case 43: return AR;
    case 44: return AS;
    case 45: return AT;
    case 46: return AU;
    case 47: return AV;
    case 48: return AW;
    case 49: return AX;
    case 50: return AY;
    case 51: return AZ;
    case 52: return BA;
    case 53: return BB;
    case 54: return BC;
    case 55: return BD;
    case 56: return BE;
    case 57: return BF;
    case 58: return BG;
    case 59: return BH;
    case 60: return BI;
    case 61: return BJ;
    case 62: return BK;
    case 63: return BL;
    case 64: return BM;
    case 65: return BN;
    case 66: return BO;
    case 67: return BP;
    case 68: return BQ;
    case 69: return BR;
    case 70: return BS;
    case 71: return BT;
    case 72: return BU;
    case 73: return BV;
    case 74: return BW;
    case 75: return BX;
    case 76: return BY;
    case 77: return BZ;
    case 78: return CA;
    case 79: return CB;
    case 80: return CC;
    case 81: return CD;
    case 82: return CE;
    case 83: return CF;
    case 84: return CG;
    case 85: return CH;
    case 86: return CI;
    case 87: return CJ;
    case 88: return CK;
    case 89: return CL;
    case 90: return CM;
    case 91: return CN;
    case 92: return CO;
    case 93: return CP;
    case 94: return CQ;
    case 95: return CR;
    case 96: return CS;
    case 97: return CT;
    case 98: return CU;
    case 99: return CV;
    case 100: return CW;
    case 101: return CX;
    case 102: return CY;
    case 103: return CZ;
    case 104: return DA;
    case 105: return DB;
    case 106: return DC;
    case 107: return DD;
    case 108: return DE;
    case 109: return DF;
    case 110: return DG;
    case 111: return DH;
    case 112: return DI;
    case 113: return DJ;
    case 114: return DK;
    case 115: return DL;
    case 116: return DM;
    case 117: return DN;
    case 118: return DO;
    case 119: return DP;
    case 120: return DQ;
    case 121: return DR;
    case 122: return DS;
    case 123: return DT;
    case 124: return DU;
    case 125: return DV;
    case 126: return DW;
    case 127: return DX;
    case 128: return DY;
    case 129: return DZ;
    case 130: return EA;
    case 131: return EB;
    case 132: return EC;
    case 133: return ED;
    case 134: return EE;
    case 135: return EF;
    case 136: return EG;
    case 137: return EH;
    case 138: return EI;
    case 139: return EJ;
    case 140: return EK;
    case 141: return EL;
    case 142: return EM;
    case 143: return EN;
    case 144: return EO;
    case 145: return EP;
    case 146: return EQ;
    case 147: return ER;
    case 148: return ES;
    case 149: return ET;
    case 150: return EU;
    case 151: return EV;
    case 152: return EW;
    case 153: return EX;
    case 154: return EY;
    case 155: return EZ;
    case 156: return FA;
    case 157: return FB;
    case 158: return FC;
    case 159: return FD;
    case 160: return FE;
    case 161: return FF;
    case 162: return FG;
    case 163: return FH;
    case 164: return FI;
    case 165: return FJ;
    case 166: return FK;
    case 167: return FL;
    case 168: return FM;
    case 169: return FN;
    case 170: return FO;
    case 171: return FP;
    case 172: return FQ;
    case 173: return FR;
    case 174: return FS;
    case 175: return FT;
    case 176: return FU;
    case 177: return FV;
    case 178: return FW;
    case 179: return FX;
    case 180: return FY;
    case 181: return FZ;
    case 182: return GA;
    case 183: return GB;
    case 184: return GC;
    case 185: return GD;
    case 186: return GE;
    case 187: return GF;
    case 188: return GG;
    case 189: return GH;
    case 190: return GI;
    case 191: return GJ;
    case 192: return GK;
    case 193: return GL;
    case 194: return GM;
    case 195: return GN;
    case 196: return GO;
    case 197: return GP;
    case 198: return GQ;
    case 199: return GR;
    case 200: return GS;
    case 201: return GT;
    case 202: return GU;
    case 203: return GV;
    case 204: return GW;
    case 205: return GX;
    case 206: return GY;
    case 207: return GZ;
    case 208: return HA;
    case 209: return HB;
    case 210: return HC;
    case 211: return HD;
    case 212: return HE;
    case 213: return HF;
    case 214: return HG;
    case 215: return HH;
    case 216: return HI;
    case 217: return HJ;
    case 218: return HK;
    case 219: return HL;
    case 220: return HM;
    case 221: return HN;
    case 222: return HO;
    case 223: return HP;
    case 224: return HQ;
    case 225: return HR;
    case 226: return HS;
    case 227: return HT;
    case 228: return HU;
    case 229: return HV;
    case 230: return HW;
    case 231: return HX;
    case 232: return HY;
    case 233: return HZ;
    case 234: return IA;
    case 235: return IB;
    case 236: return IC;
    case 237: return ID;
    case 238: return IE;
    case 239: return IF;
    case 240: return IG;
    case 241: return IH;
    case 242: return II;
    case 243: return IJ;
    case 244: return IK;
    case 245: return IL;
    case 246: return IM;
    case 247: return IN;
    case 248: return IO;
    case 249: return IP;
    case 250: return IQ;
    case 251: return IR;
    case 252: return IS;
    case 253: return IT;
    case 254: return IU;
    case 255: return IV;
    case 256: return IW;
    case 257: return IX;
    case 258: return IY;
    case 259: return IZ;
    case 260: return JA;
    case 261: return JB;
    case 262: return JC;
    case 263: return JD;
    case 264: return JE;
    case 265: return JF;
    case 266: return JG;
    case 267: return JH;
    case 268: return JI;
    case 269: return JJ;
    case 270: return JK;
    case 271: return JL;
    case 272: return JM;
    case 273: return JN;
    case 274: return JO;
    case 275: return JP;
    case 276: return JQ;
    case 277: return JR;
    case 278: return JS;
    case 279: return JT;
    case 280: return JU;
    case 281: return JV;
    case 282: return JW;
    case 283: return JX;
    case 284: return JY;
    case 285: return JZ;
    case 286: return KA;
    case 287: return KB;
    case 288: return KC;
    case 289: return KD;
    case 290: return KE;
    case 291: return KF;
    case 292: return KG;
    case 293: return KH;
    case 294: return KI;
    case 295: return KJ;
    case 296: return KK;
    case 297: return KL;
    case 298: return KM;
    case 299: return KN;
    case 300: return KO;
    case 301: return KP;
    case 302: return KQ;
    case 303: return KR;
    case 304: return KS;
    case 305: return KT;
    case 306: return KU;
    case 307: return KV;
    case 308: return KW;
    case 309: return KX;
    case 310: return KY;
    case 311: return KZ;
    case 312: return LA;
    case 313: return LB;
    case 314: return LC;
    case 315: return LD;
    case 316: return LE;
    case 317: return LF;
    case 318: return LG;
    case 319: return LH;
    case 320: return LI;
    case 321: return LJ;
    case 322: return LK;
    case 323: return LL;
    case 324: return LM;
    case 325: return LN;
    case 326: return LO;
    case 327: return LP;
    case 328: return LQ;
    case 329: return LR;
    case 330: return LS;
    case 331: return LT;
    case 332: return LU;
    case 333: return LV;
    case 334: return LW;
    case 335: return LX;
    case 336: return LY;
    case 337: return LZ;
    case 338: return MA;
    case 339: return MB;
    case 340: return MC;
    case 341: return MD;
    case 342: return ME;
    case 343: return MF;
    case 344: return MG;
    case 345: return MH;
    case 346: return MI;
    case 347: return MJ;
    case 348: return MK;
    case 349: return ML;
    case 350: return MM;
    case 351: return MN;
    case 352: return MO;
    case 353: return MP;
    case 354: return MQ;
    case 355: return MR;
    case 356: return MS;
    case 357: return MT;
    case 358: return MU;
    case 359: return MV;
    case 360: return MW;
    case 361: return MX;
    case 362: return MY;
    case 363: return MZ;
    case 364: return NA;
    case 365: return NB;
    case 366: return NC;
    case 367: return ND;
    case 368: return NE;
    case 369: return NF;
    case 370: return NG;
    case 371: return NH;
    case 372: return NI;
    case 373: return NJ;
    case 374: return NK;
    case 375: return NL;
    case 376: return NM;
    case 377: return NN;
    case 378: return NO;
    case 379: return NP;
    case 380: return NQ;
    case 381: return NR;
    case 382: return NS;
    case 383: return NT;
    case 384: return NU;
    case 385: return NV;
    case 386: return NW;
    case 387: return NX;
    case 388: return NY;
    case 389: return NZ;
    case 390: return OA;
    case 391: return OB;
    case 392: return OC;
    case 393: return OD;
    case 394: return OE;
    case 395: return OF;
    case 396: return OG;
    case 397: return OH;
    case 398: return OI;
    case 399: return OJ;
    case 400: return OK;
    case 401: return OL;
    case 402: return OM;
    case 403: return ON;
    case 404: return OO;
    case 405: return OP;
    case 406: return OQ;
    case 407: return OR;
    case 408: return OS;
    case 409: return OT;
    case 410: return OU;
    case 411: return OV;
    case 412: return OW;
    case 413: return OX;
    case 414: return OY;
    case 415: return OZ;
    case 416: return PA;
    case 417: return PB;
    case 418: return PC;
    case 419: return PD;
    case 420: return PE;
    case 421: return PF;
    case 422: return PG;
    case 423: return PH;
    case 424: return PI;
    case 425: return PJ;
    case 426: return PK;
    case 427: return PL;
    case 428: return PM;
    case 429: return PN;
    case 430: return PO;
    case 431: return PP;
    case 432: return PQ;
    case 433: return PR;
    case 434: return PS;
    case 435: return PT;
    case 436: return PU;
    case 437: return PV;
    case 438: return PW;
    case 439: return PX;
    case 440: return PY;
    case 441: return PZ;
    case 442: return QA;
    case 443: return QB;
    case 444: return QC;
    case 445: return QD;
    case 446: return QE;
    case 447: return QF;
    case 448: return QG;
    case 449: return QH;
    case 450: return QI;
    case 451: return QJ;
    case 452: return QK;
    case 453: return QL;
    case 454: return QM;
    case 455: return QN;
    case 456: return QO;
    case 457: return QP;
    case 458: return QQ;
    case 459: return QR;
    case 460: return QS;
    case 461: return QT;
    case 462: return QU;
    case 463: return QV;
    case 464: return QW;
    case 465: return QX;
    case 466: return QY;
    case 467: return QZ;
    case 468: return RA;
    case 469: return RB;
    case 470: return RC;
    case 471: return RD;
    case 472: return RE;
    case 473: return RF;
    case 474: return RG;
    case 475: return RH;
    case 476: return RI;
    case 477: return RJ;
    case 478: return RK;
    case 479: return RL;
    case 480: return RM;
    case 481: return RN;
    case 482: return RO;
    case 483: return RP;
    case 484: return RQ;
    case 485: return RR;
    case 486: return RS;
    case 487: return RT;
    case 488: return RU;
    case 489: return RV;
    case 490: return RW;
    case 491: return RX;
    case 492: return RY;
    case 493: return RZ;
    case 494: return SA;
    case 495: return SB;
    case 496: return SC;
    case 497: return SD;
    case 498: return SE;
    case 499: return SF;
    case 500: return SG;
    case 501: return SH;
    case 502: return SI;
    case 503: return SJ;
    case 504: return SK;
    case 505: return SL;
    case 506: return SM;
    case 507: return SN;
    case 508: return SO;
    case 509: return SP;
    case 510: return SQ;
    case 511: return SR;
    case 512: return SS;
    case 513: return ST;
    case 514: return SU;
    case 515: return SV;
    case 516: return SW;
    case 517: return SX;
    case 518: return SY;
    case 519: return SZ;
    case 520: return TA;
    case 521: return TB;
    case 522: return TC;
    case 523: return TD;
    case 524: return TE;
    case 525: return TF;
    case 526: return TG;
    case 527: return TH;
    case 528: return TI;
    case 529: return TJ;
    case 530: return TK;
    case 531: return TL;
    case 532: return TM;
    case 533: return TN;
    case 534: return TO;
    case 535: return TP;
    case 536: return TQ;
    case 537: return TR;
    case 538: return TS;
    case 539: return TT;
    case 540: return TU;
    case 541: return TV;
    case 542: return TW;
    case 543: return TX;
    case 544: return TY;
    case 545: return TZ;
    case 546: return UA;
    case 547: return UB;
    case 548: return UC;
    case 549: return UD;
    case 550: return UE;
    case 551: return UF;
    case 552: return UG;
    case 553: return UH;
    case 554: return UI;
    case 555: return UJ;
    case 556: return UK;
    case 557: return UL;
    case 558: return UM;
    case 559: return UN;
    case 560: return UO;
    case 561: return UP;
    case 562: return UQ;
    case 563: return UR;
    case 564: return US;
    case 565: return UT;
    case 566: return UU;
    case 567: return UV;
    case 568: return UW;
    case 569: return UX;
    case 570: return UY;
    case 571: return UZ;
    case 572: return VA;
    case 573: return VB;
    case 574: return VC;
    case 575: return VD;
    case 576: return VE;
    case 577: return VF;
    case 578: return VG;
    case 579: return VH;
    case 580: return VI;
    case 581: return VJ;
    case 582: return VK;
    case 583: return VL;
    case 584: return VM;
    case 585: return VN;
    case 586: return VO;
    case 587: return VP;
    case 588: return VQ;
    case 589: return VR;
    case 590: return VS;
    case 591: return VT;
    case 592: return VU;
    case 593: return VV;
    case 594: return VW;
    case 595: return VX;
    case 596: return VY;
    case 597: return VZ;
    case 598: return WA;
    case 599: return WB;
    case 600: return WC;
    case 601: return WD;
    case 602: return WE;
    case 603: return WF;
    case 604: return WG;
    case 605: return WH;
    case 606: return WI;
    case 607: return WJ;
    case 608: return WK;
    case 609: return WL;
    case 610: return WM;
    case 611: return WN;
    case 612: return WO;
    case 613: return WP;
    case 614: return WQ;
    case 615: return WR;
    case 616: return WS;
    case 617: return WT;
    case 618: return WU;
    case 619: return WV;
    case 620: return WW;
    case 621: return WX;
    case 622: return WY;
    case 623: return WZ;
    case 624: return XA;
    case 625: return XB;
    case 626: return XC;
    case 627: return XD;
    case 628: return XE;
    case 629: return XF;
    case 630: return XG;
    case 631: return XH;
    case 632: return XI;
    case 633: return XJ;
    case 634: return XK;
    case 635: return XL;
    case 636: return XM;
    case 637: return XN;
    case 638: return XO;
    case 639: return XP;
    case 640: return XQ;
    case 641: return XR;
    case 642: return XS;
    case 643: return XT;
    case 644: return XU;
    case 645: return XV;
    case 646: return XW;
    case 647: return XX;
    case 648: return XY;
    case 649: return XZ;
    case 650: return YA;
    case 651: return YB;
    case 652: return YC;
    case 653: return YD;
    case 654: return YE;
    case 655: return YF;
    case 656: return YG;
    case 657: return YH;
    case 658: return YI;
    case 659: return YJ;
    case 660: return YK;
    case 661: return YL;
    case 662: return YM;
    case 663: return YN;
    case 664: return YO;
    case 665: return YP;
    case 666: return YQ;
    case 667: return YR;
    case 668: return YS;
    case 669: return YT;
    case 670: return YU;
    case 671: return YV;
    case 672: return YW;
    case 673: return YX;
    case 674: return YY;
    case 675: return YZ;
    case 676: return ZA;
    case 677: return ZB;
    case 678: return ZC;
    case 679: return ZD;
    case 680: return ZE;
    case 681: return ZF;
    case 682: return ZG;
    case 683: return ZH;
    case 684: return ZI;
    case 685: return ZJ;
    case 686: return ZK;
    case 687: return ZL;
    case 688: return ZM;
    case 689: return ZN;
    case 690: return ZO;
    case 691: return ZP;
    case 692: return ZQ;
    case 693: return ZR;
    case 694: return ZS;
    case 695: return ZT;
    case 696: return ZU;
    case 697: return ZV;
    case 698: return ZW;
    case 699: return ZX;
    case 700: return ZY;
    case 701: return ZZ;
    case 702: return AAA;
    case 703: return AAB;
    case 704: return AAC;
    case 705: return AAD;
    case 706: return AAE;
    case 707: return AAF;
    case 708: return AAG;
    case 709: return AAH;
    case 710: return AAI;
    case 711: return AAJ;
    case 712: return AAK;
    case 713: return AAL;
    case 714: return AAM;
    case 715: return AAN;
    case 716: return AAO;
    case 717: return AAP;
    case 718: return AAQ;
    case 719: return AAR;
    case 720: return AAS;
    case 721: return AAT;
    case 722: return AAU;
    case 723: return AAV;
    case 724: return AAW;
    case 725: return AAX;
    case 726: return AAY;
    case 727: return AAZ;
    case 728: return ABA;
    case 729: return ABB;
    case 730: return ABC;
    case 731: return ABD;
    case 732: return ABE;
    case 733: return ABF;
    case 734: return ABG;
    case 735: return ABH;
    case 736: return ABI;
    case 737: return ABJ;
    case 738: return ABK;
    case 739: return ABL;
    case 740: return ABM;
    case 741: return ABN;
    case 742: return ABO;
    case 743: return ABP;
    case 744: return ABQ;
    case 745: return ABR;
    case 746: return ABS;
    case 747: return ABT;
    case 748: return ABU;
    case 749: return ABV;
    case 750: return ABW;
    case 751: return ABX;
    case 752: return ABY;
    case 753: return ABZ;
    case 754: return ACA;
    case 755: return ACB;
    case 756: return ACC;
    case 757: return ACD;
    case 758: return ACE;
    case 759: return ACF;
    case 760: return ACG;
    case 761: return ACH;
    case 762: return ACI;
    case 763: return ACJ;
    case 764: return ACK;
    case 765: return ACL;
    case 766: return ACM;
    case 767: return ACN;
    case 768: return ACO;
    case 769: return ACP;
    case 770: return ACQ;
    case 771: return ACR;
    case 772: return ACS;
    case 773: return ACT;
    case 774: return ACU;
    case 775: return ACV;
    case 776: return ACW;
    case 777: return ACX;
    case 778: return ACY;
    case 779: return ACZ;
    case 780: return ADA;
    case 781: return ADB;
    case 782: return ADC;
    case 783: return ADD;
    case 784: return ADE;
    case 785: return ADF;
    case 786: return ADG;
    case 787: return ADH;
    case 788: return ADI;
    case 789: return ADJ;
    case 790: return ADK;
    case 791: return ADL;
    case 792: return ADM;
    case 793: return ADN;
    case 794: return ADO;
    case 795: return ADP;
    case 796: return ADQ;
    case 797: return ADR;
    case 798: return ADS;
    case 799: return ADT;
    case 800: return ADU;
    case 801: return ADV;
    case 802: return ADW;
    case 803: return ADX;
    case 804: return ADY;
    case 805: return ADZ;
    case 806: return AEA;
    case 807: return AEB;
    case 808: return AEC;
    case 809: return AED;
    case 810: return AEE;
    case 811: return AEF;
    case 812: return AEG;
    case 813: return AEH;
    case 814: return AEI;
    case 815: return AEJ;
    case 816: return AEK;
    case 817: return AEL;
    case 818: return AEM;
    case 819: return AEN;
    case 820: return AEO;
    case 821: return AEP;
    case 822: return AEQ;
    case 823: return AER;
    case 824: return AES;
    case 825: return AET;
    case 826: return AEU;
    case 827: return AEV;
    case 828: return AEW;
    case 829: return AEX;
    case 830: return AEY;
    case 831: return AEZ;
    case 832: return AFA;
    case 833: return AFB;
    case 834: return AFC;
    case 835: return AFD;
    case 836: return AFE;
    case 837: return AFF;
    case 838: return AFG;
    case 839: return AFH;
    case 840: return AFI;
    case 841: return AFJ;
    case 842: return AFK;
    case 843: return AFL;
    case 844: return AFM;
    case 845: return AFN;
    case 846: return AFO;
    case 847: return AFP;
    case 848: return AFQ;
    case 849: return AFR;
    case 850: return AFS;
    case 851: return AFT;
    case 852: return AFU;
    case 853: return AFV;
    case 854: return AFW;
    case 855: return AFX;
    case 856: return AFY;
    case 857: return AFZ;
    case 858: return AGA;
    case 859: return AGB;
    case 860: return AGC;
    case 861: return AGD;
    case 862: return AGE;
    case 863: return AGF;
    case 864: return AGG;
    case 865: return AGH;
    case 866: return AGI;
    case 867: return AGJ;
    case 868: return AGK;
    case 869: return AGL;
    case 870: return AGM;
    case 871: return AGN;
    case 872: return AGO;
    case 873: return AGP;
    case 874: return AGQ;
    case 875: return AGR;
    case 876: return AGS;
    case 877: return AGT;
    case 878: return AGU;
    case 879: return AGV;
    case 880: return AGW;
    case 881: return AGX;
    case 882: return AGY;
    case 883: return AGZ;
    case 884: return AHA;
    case 885: return AHB;
    case 886: return AHC;
    case 887: return AHD;
    case 888: return AHE;
    case 889: return AHF;
    case 890: return AHG;
    case 891: return AHH;
    case 892: return AHI;
    case 893: return AHJ;
    case 894: return AHK;
    case 895: return AHL;
    case 896: return AHM;
    case 897: return AHN;
    case 898: return AHO;
    case 899: return AHP;
    case 900: return AHQ;
    case 901: return AHR;
    case 902: return AHS;
    case 903: return AHT;
    case 904: return AHU;
    case 905: return AHV;
    case 906: return AHW;
    case 907: return AHX;
    case 908: return AHY;
    case 909: return AHZ;
    case 910: return AIA;
    case 911: return AIB;
    case 912: return AIC;
    case 913: return AID;
    case 914: return AIE;
    case 915: return AIF;
    case 916: return AIG;
    case 917: return AIH;
    case 918: return AII;
    case 919: return AIJ;
    case 920: return AIK;
    case 921: return AIL;
    case 922: return AIM;
    case 923: return AIN;
    case 924: return AIO;
    case 925: return AIP;
    case 926: return AIQ;
    case 927: return AIR;
    case 928: return AIS;
    case 929: return AIT;
    case 930: return AIU;
    case 931: return AIV;
    case 932: return AIW;
    case 933: return AIX;
    case 934: return AIY;
    case 935: return AIZ;
    case 936: return AJA;
    case 937: return AJB;
    case 938: return AJC;
    case 939: return AJD;
    case 940: return AJE;
    case 941: return AJF;
    case 942: return AJG;
    case 943: return AJH;
    case 944: return AJI;
    case 945: return AJJ;
    case 946: return AJK;
    case 947: return AJL;
    case 948: return AJM;
    case 949: return AJN;
    case 950: return AJO;
    case 951: return AJP;
    case 952: return AJQ;
    case 953: return AJR;
    case 954: return AJS;
    case 955: return AJT;
    case 956: return AJU;
    case 957: return AJV;
    case 958: return AJW;
    case 959: return AJX;
    case 960: return AJY;
    case 961: return AJZ;
    case 962: return AKA;
    case 963: return AKB;
    case 964: return AKC;
    case 965: return AKD;
    case 966: return AKE;
    case 967: return AKF;
    case 968: return AKG;
    case 969: return AKH;
    case 970: return AKI;
    case 971: return AKJ;
    case 972: return AKK;
    case 973: return AKL;
    case 974: return AKM;
    case 975: return AKN;
    case 976: return AKO;
    case 977: return AKP;
    case 978: return AKQ;
    case 979: return AKR;
    case 980: return AKS;
    case 981: return AKT;
    case 982: return AKU;
    case 983: return AKV;
    case 984: return AKW;
    case 985: return AKX;
    case 986: return AKY;
    case 987: return AKZ;
    case 988: return ALA;
    case 989: return ALB;
    case 990: return ALC;
    case 991: return ALD;
    case 992: return ALE;
    case 993: return ALF;
    case 994: return ALG;
    case 995: return ALH;
    case 996: return ALI;
    case 997: return ALJ;
    case 998: return ALK;
    case 999: return ALL;
    case 1000: return ALM;
    case 1001: return ALN;
    case 1002: return ALO;
    case 1003: return ALP;
    case 1004: return ALQ;
    case 1005: return ALR;
    case 1006: return ALS;
    case 1007: return ALT;
    case 1008: return ALU;
    case 1009: return ALV;
    case 1010: return ALW;
    case 1011: return ALX;
    case 1012: return ALY;
    case 1013: return ALZ;
    case 1014: return AMA;
    case 1015: return AMB;
    case 1016: return AMC;
    case 1017: return AMD;
    case 1018: return AME;
    case 1019: return AMF;
    case 1020: return AMG;
    case 1021: return AMH;
    case 1022: return AMI;
    case 1023: return AMJ;
    case 1024: return AMK;
    case 1025: return AML;
    case 1026: return AMM;
    case 1027: return AMN;
    case 1028: return AMO;
    case 1029: return AMP;
    case 1030: return AMQ;
    case 1031: return AMR;
    case 1032: return AMS;
    case 1033: return AMT;
    case 1034: return AMU;
    case 1035: return AMV;
    case 1036: return AMW;
    case 1037: return AMX;
    case 1038: return AMY;
    case 1039: return AMZ;
    case 1040: return ANA;
    case 1041: return ANB;
    case 1042: return ANC;
    case 1043: return AND;
    case 1044: return ANE;
    case 1045: return ANF;
    case 1046: return ANG;
    case 1047: return ANH;
    case 1048: return ANI;
    case 1049: return ANJ;
    case 1050: return ANK;
    case 1051: return ANL;
    case 1052: return ANM;
    case 1053: return ANN;
    case 1054: return ANO;
    case 1055: return ANP;
    case 1056: return ANQ;
    case 1057: return ANR;
    case 1058: return ANS;
    case 1059: return ANT;
    case 1060: return ANU;
    case 1061: return ANV;
    case 1062: return ANW;
    case 1063: return ANX;
    case 1064: return ANY;
    case 1065: return ANZ;
    case 1066: return AOA;
    case 1067: return AOB;
    case 1068: return AOC;
    case 1069: return AOD;
    case 1070: return AOE;
    case 1071: return AOF;
    case 1072: return AOG;
    case 1073: return AOH;
    case 1074: return AOI;
    case 1075: return AOJ;
    case 1076: return AOK;
    case 1077: return AOL;
    case 1078: return AOM;
    case 1079: return AON;
    case 1080: return AOO;
    case 1081: return AOP;
    case 1082: return AOQ;
    case 1083: return AOR;
    case 1084: return AOS;
    case 1085: return AOT;
    case 1086: return AOU;
    case 1087: return AOV;
    case 1088: return AOW;
    case 1089: return AOX;
    case 1090: return AOY;
    case 1091: return AOZ;
    case 1092: return APA;
    case 1093: return APB;
    case 1094: return APC;
    case 1095: return APD;
    case 1096: return APE;
    case 1097: return APF;
    case 1098: return APG;
    case 1099: return APH;
    case 1100: return API;
    case 1101: return APJ;
    case 1102: return APK;
    case 1103: return APL;
    case 1104: return APM;
    case 1105: return APN;
    case 1106: return APO;
    case 1107: return APP;
    case 1108: return APQ;
    case 1109: return APR;
    case 1110: return APS;
    case 1111: return APT;
    case 1112: return APU;
    case 1113: return APV;
    case 1114: return APW;
    case 1115: return APX;
    case 1116: return APY;
    case 1117: return APZ;
    case 1118: return AQA;
    case 1119: return AQB;
    case 1120: return AQC;
    case 1121: return AQD;
    case 1122: return AQE;
    case 1123: return AQF;
    case 1124: return AQG;
    case 1125: return AQH;
    case 1126: return AQI;
    case 1127: return AQJ;
    case 1128: return AQK;
    case 1129: return AQL;
    case 1130: return AQM;
    case 1131: return AQN;
    case 1132: return AQO;
    case 1133: return AQP;
    case 1134: return AQQ;
    case 1135: return AQR;
    case 1136: return AQS;
    case 1137: return AQT;
    case 1138: return AQU;
    case 1139: return AQV;
    case 1140: return AQW;
    case 1141: return AQX;
    case 1142: return AQY;
    case 1143: return AQZ;
    case 1144: return ARA;
    case 1145: return ARB;
    case 1146: return ARC;
    case 1147: return ARD;
    case 1148: return ARE;
    case 1149: return ARF;
    case 1150: return ARG;
    case 1151: return ARH;
    case 1152: return ARI;
    case 1153: return ARJ;
    case 1154: return ARK;
    case 1155: return ARL;
    case 1156: return ARM;
    case 1157: return ARN;
    case 1158: return ARO;
    case 1159: return ARP;
    case 1160: return ARQ;
    case 1161: return ARR;
    case 1162: return ARS;
    case 1163: return ART;
    case 1164: return ARU;
    case 1165: return ARV;
    case 1166: return ARW;
    case 1167: return ARX;
    case 1168: return ARY;
    case 1169: return ARZ;
    case 1170: return ASA;
    case 1171: return ASB;
    case 1172: return ASC;
    case 1173: return ASD;
    case 1174: return ASE;
    case 1175: return ASF;
    case 1176: return ASG;
    case 1177: return ASH;
    case 1178: return ASI;
    case 1179: return ASJ;
    case 1180: return ASK;
    case 1181: return ASL;
    case 1182: return ASM;
    case 1183: return ASN;
    case 1184: return ASO;
    case 1185: return ASP;
    case 1186: return ASQ;
    case 1187: return ASR;
    case 1188: return ASS;
    case 1189: return AST;
    case 1190: return ASU;
    case 1191: return ASV;
    case 1192: return ASW;
    case 1193: return ASX;
    case 1194: return ASY;
    case 1195: return ASZ;
    case 1196: return ATA;
    case 1197: return ATB;
    case 1198: return ATC;
    case 1199: return ATD;
    case 1200: return ATE;
    case 1201: return ATF;
    case 1202: return ATG;
    case 1203: return ATH;
    case 1204: return ATI;
    case 1205: return ATJ;
    case 1206: return ATK;
    case 1207: return ATL;
    case 1208: return ATM;
    case 1209: return ATN;
    case 1210: return ATO;
    case 1211: return ATP;
    case 1212: return ATQ;
    case 1213: return ATR;
    case 1214: return ATS;
    case 1215: return ATT;
    case 1216: return ATU;
    case 1217: return ATV;
    case 1218: return ATW;
    case 1219: return ATX;
    case 1220: return ATY;
    case 1221: return ATZ;
    case 1222: return AUA;
    case 1223: return AUB;
    case 1224: return AUC;
    case 1225: return AUD;
    case 1226: return AUE;
    case 1227: return AUF;
    case 1228: return AUG;
    case 1229: return AUH;
    case 1230: return AUI;
    case 1231: return AUJ;
    case 1232: return AUK;
    case 1233: return AUL;
    case 1234: return AUM;
    case 1235: return AUN;
    case 1236: return AUO;
    case 1237: return AUP;
    case 1238: return AUQ;
    case 1239: return AUR;
    case 1240: return AUS;
    case 1241: return AUT;
    case 1242: return AUU;
    case 1243: return AUV;
    case 1244: return AUW;
    case 1245: return AUX;
    case 1246: return AUY;
    case 1247: return AUZ;
    case 1248: return AVA;
    case 1249: return AVB;
    case 1250: return AVC;
    case 1251: return AVD;
    case 1252: return AVE;
    case 1253: return AVF;
    case 1254: return AVG;
    case 1255: return AVH;
    case 1256: return AVI;
    case 1257: return AVJ;
    case 1258: return AVK;
    case 1259: return AVL;
    case 1260: return AVM;
    case 1261: return AVN;
    case 1262: return AVO;
    case 1263: return AVP;
    case 1264: return AVQ;
    case 1265: return AVR;
    case 1266: return AVS;
    case 1267: return AVT;
    case 1268: return AVU;
    case 1269: return AVV;
    case 1270: return AVW;
    case 1271: return AVX;
    case 1272: return AVY;
    case 1273: return AVZ;
    case 1274: return AWA;
    case 1275: return AWB;
    case 1276: return AWC;
    case 1277: return AWD;
    case 1278: return AWE;
    case 1279: return AWF;
    case 1280: return AWG;
    case 1281: return AWH;
    case 1282: return AWI;
    case 1283: return AWJ;
    case 1284: return AWK;
    case 1285: return AWL;
    case 1286: return AWM;
    case 1287: return AWN;
    case 1288: return AWO;
    case 1289: return AWP;
    case 1290: return AWQ;
    case 1291: return AWR;
    case 1292: return AWS;
    case 1293: return AWT;
    case 1294: return AWU;
    case 1295: return AWV;
    case 1296: return AWW;
    case 1297: return AWX;
    case 1298: return AWY;
    case 1299: return AWZ;
    case 1300: return AXA;
    case 1301: return AXB;
    case 1302: return AXC;
    case 1303: return AXD;
    case 1304: return AXE;
    case 1305: return AXF;
    case 1306: return AXG;
    case 1307: return AXH;
    case 1308: return AXI;
    case 1309: return AXJ;
    case 1310: return AXK;
    case 1311: return AXL;
    case 1312: return AXM;
    case 1313: return AXN;
    case 1314: return AXO;
    case 1315: return AXP;
    case 1316: return AXQ;
    case 1317: return AXR;
    case 1318: return AXS;
    case 1319: return AXT;
    case 1320: return AXU;
    case 1321: return AXV;
    case 1322: return AXW;
    case 1323: return AXX;
    case 1324: return AXY;
    case 1325: return AXZ;
    case 1326: return AYA;
    case 1327: return AYB;
    case 1328: return AYC;
    case 1329: return AYD;
    case 1330: return AYE;
    case 1331: return AYF;
    case 1332: return AYG;
    case 1333: return AYH;
    case 1334: return AYI;
    case 1335: return AYJ;
    case 1336: return AYK;
    case 1337: return AYL;
    case 1338: return AYM;
    case 1339: return AYN;
    case 1340: return AYO;
    case 1341: return AYP;
    case 1342: return AYQ;
    case 1343: return AYR;
    case 1344: return AYS;
    case 1345: return AYT;
    case 1346: return AYU;
    case 1347: return AYV;
    case 1348: return AYW;
    case 1349: return AYX;
    case 1350: return AYY;
    case 1351: return AYZ;
    case 1352: return AZA;
    case 1353: return AZB;
    case 1354: return AZC;
    case 1355: return AZD;
    case 1356: return AZE;
    case 1357: return AZF;
    case 1358: return AZG;
    case 1359: return AZH;
    case 1360: return AZI;
    case 1361: return AZJ;
    case 1362: return AZK;
    case 1363: return AZL;
    case 1364: return AZM;
    case 1365: return AZN;
    case 1366: return AZO;
    case 1367: return AZP;
    case 1368: return AZQ;
    case 1369: return AZR;
    case 1370: return AZS;
    case 1371: return AZT;
    case 1372: return AZU;
    case 1373: return AZV;
    case 1374: return AZW;
    case 1375: return AZX;
    case 1376: return AZY;
    case 1377: return AZZ;
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

    Address: GDGENES4KXH7RQJELTONR7HSVISVSQ5POSVBEWLR6EEIIL72H24IEDT4

*******************************************************************************/

static immutable Genesis = KeyPair(
    PublicKey(Point([204, 70, 146, 92, 85, 207, 248, 193, 36, 92, 220, 216, 252, 242, 170, 37, 89, 67, 175, 116, 170, 18, 89, 113, 241, 8, 132, 47, 250, 62, 184, 130])),
    SecretKey(Scalar([57, 34, 14, 84, 18, 175, 101, 64, 121, 181, 212, 78, 23, 148, 180, 7, 9, 105, 237, 155, 78, 161, 191, 27, 97, 130, 209, 44, 202, 245, 208, 13])));


/*******************************************************************************

    Commons Budget KeyPair used in unittests

    In unittests, we need the commons budget key pair to be known for us to be
    able to write tests.
    In the real network, there are different values.

    Note that while this is a well-known keys, it is not part of the
    range returned by `byRange`, nor can it be indexed by `size_t`,
    to avoid it being mistakenly used.

    Address: GDCOMMO272NFWHV5TQAIQFEDLQZLBMVVOJTHC3F567ZX4ZSRQQQWGLI3

*******************************************************************************/

static immutable CommonsBudget = KeyPair(
    PublicKey(Point([196, 230, 49, 218, 254, 154, 91, 30, 189, 156, 0, 136, 20, 131, 92, 50, 176, 178, 181, 114, 102, 113, 108, 189, 247, 243, 126, 102, 81, 132, 33, 99])),
    SecretKey(Scalar([177, 62, 40, 215, 115, 236, 122, 8, 22, 109, 42, 57, 44, 73, 121, 175, 60, 1, 135, 69, 17, 1, 104, 238, 0, 153, 89, 28, 249, 67, 42, 7])));


/*******************************************************************************

    Key pairs used for Enrollments in the genesis block

    Note that despite mining for a few days, NODE0, NODE1, NODE8, NODE9 were
    not found.

*******************************************************************************/

/// NODE2: GDNODE2JBW65U6WVIOESR3OTJUFOHPHTEIL4GQINDB3MVB645KXAHG73
static immutable NODE2 = KeyPair(
    PublicKey(Point([218, 225, 147, 73, 13, 189, 218, 122, 213, 67, 137, 40, 237, 211, 77, 10, 227, 188, 243, 34, 23, 195, 65, 13, 24, 118, 202, 135, 220, 234, 174, 3])),
    SecretKey(Scalar([235, 179, 46, 185, 245, 191, 31, 208, 161, 209, 24, 204, 112, 33, 42, 108, 209, 64, 61, 44, 197, 122, 48, 125, 200, 139, 49, 146, 185, 206, 227, 13])));

/// NODE3: GDNODE3OVP5Z6WN43WU4JKVDJ6OS2WGZZ3PLR3XFEY7C2SV2DTZT27NU
static immutable NODE3 = KeyPair(
    PublicKey(Point([218, 225, 147, 110, 171, 251, 159, 89, 188, 221, 169, 196, 170, 163, 79, 157, 45, 88, 217, 206, 222, 184, 238, 229, 38, 62, 45, 74, 186, 28, 243, 61])),
    SecretKey(Scalar([19, 34, 116, 81, 73, 134, 255, 118, 5, 93, 182, 15, 92, 106, 229, 22, 144, 172, 196, 111, 11, 226, 96, 190, 48, 207, 14, 79, 198, 249, 63, 11])));

/// NODE4: GDNODE4XYKLOKSF6OAZR5XXR6ATSE5UFTUZLCHHTFJMOEELFSEMDNQO2
static immutable NODE4 = KeyPair(
    PublicKey(Point([218, 225, 147, 151, 194, 150, 229, 72, 190, 112, 51, 30, 222, 241, 240, 39, 34, 118, 133, 157, 50, 177, 28, 243, 42, 88, 226, 17, 101, 145, 24, 54])),
    SecretKey(Scalar([168, 154, 0, 25, 100, 201, 78, 145, 43, 136, 103, 92, 74, 231, 144, 74, 215, 226, 131, 164, 151, 41, 164, 254, 231, 212, 216, 201, 57, 72, 183, 13])));

/// NODE5: GDNODE5EDFDRT5YGK2MOZ2E3EKW76CB6NYPRAUX2CW2UMT423LWWDSMG
static immutable NODE5 = KeyPair(
    PublicKey(Point([218, 225, 147, 164, 25, 71, 25, 247, 6, 86, 152, 236, 232, 155, 34, 173, 255, 8, 62, 110, 31, 16, 82, 250, 21, 181, 70, 79, 154, 218, 237, 97])),
    SecretKey(Scalar([95, 61, 156, 216, 72, 217, 131, 208, 146, 17, 251, 178, 120, 62, 198, 104, 3, 40, 210, 10, 244, 28, 62, 198, 115, 172, 247, 247, 69, 68, 249, 14])));

/// NODE6: GDNODE6M7LJF3DCJ2KAIBNXKHKIDATFT7TMXCBPELHEPEFCZN3IX2G3K
static immutable NODE6 = KeyPair(
    PublicKey(Point([218, 225, 147, 204, 250, 210, 93, 140, 73, 210, 128, 128, 182, 234, 58, 144, 48, 76, 179, 252, 217, 113, 5, 228, 89, 200, 242, 20, 89, 110, 209, 125])),
    SecretKey(Scalar([153, 5, 199, 249, 62, 121, 232, 14, 54, 80, 152, 14, 196, 96, 3, 104, 145, 249, 124, 15, 228, 151, 47, 94, 243, 163, 246, 116, 178, 187, 146, 15])));

/// NODE7: GDNODE7P5SNNH2YVUOVCDSJHQB3DL64V76QUSE2V5YRNY6HGK4YN6ZQQ
static immutable NODE7 = KeyPair(
    PublicKey(Point([218, 225, 147, 239, 236, 154, 211, 235, 21, 163, 170, 33, 201, 39, 128, 118, 53, 251, 149, 255, 161, 73, 19, 85, 238, 34, 220, 120, 230, 87, 48, 223])),
    SecretKey(Scalar([179, 140, 94, 203, 162, 206, 19, 164, 103, 79, 120, 70, 54, 75, 95, 43, 254, 78, 142, 180, 48, 94, 207, 53, 145, 159, 181, 214, 137, 231, 240, 11])));

/*******************************************************************************

    All well-known keypairs

    The pattern is as follow:
    Keys are in the range `[A,Z]`, `[AA,ZZ]` and `[AAA,AZZ]`, for a total of
    1,377 keys (26 + 26 * 26 * 2 - 1), as we needed more than 1,000 keys.
    Keys have been mined to be easily recognizable in logs, as such, their
    public keys starts with `GD`, followed by their name, followed by `22`.
    For example, `A` is `GDA22...` and `ABC` is `GDABC22...`.

*******************************************************************************/

/// A: GDA22T4I2OTZTFQBUY36GXJOPREZ5HZFG2RII5ERMUNXZ2NFSZDADLGE
static immutable A = KeyPair(PublicKey(Point([193, 173, 79, 136, 211, 167, 153, 150, 1, 166, 55, 227, 93, 46, 124, 73, 158, 159, 37, 54, 162, 132, 116, 145, 101, 27, 124, 233, 165, 150, 70, 1])), SecretKey(Scalar([248, 130, 93, 62, 53, 179, 173, 120, 11, 152, 198, 207, 234, 88, 97, 195, 57, 167, 194, 56, 223, 70, 182, 117, 202, 185, 121, 12, 224, 103, 2, 8])));
/// B: GDB22M5UAZHVWEJXEOXGCF74E6I7BG4FFTRPY4MR34PMWXYQO4C5TOCZ
static immutable B = KeyPair(PublicKey(Point([195, 173, 51, 180, 6, 79, 91, 17, 55, 35, 174, 97, 23, 252, 39, 145, 240, 155, 133, 44, 226, 252, 113, 145, 223, 30, 203, 95, 16, 119, 5, 217])), SecretKey(Scalar([168, 34, 98, 92, 201, 211, 165, 249, 132, 230, 55, 248, 127, 234, 22, 197, 2, 115, 70, 89, 129, 95, 96, 118, 127, 90, 154, 140, 93, 217, 231, 14])));
/// C: GDC22IU5SMDOPSBERBEJYPUXX2UMRGMY6FM5ZR2JTCGWCVOVXCQONFHF
static immutable C = KeyPair(PublicKey(Point([197, 173, 34, 157, 147, 6, 231, 200, 36, 136, 72, 156, 62, 151, 190, 168, 200, 153, 152, 241, 89, 220, 199, 73, 152, 141, 97, 85, 213, 184, 160, 230])), SecretKey(Scalar([243, 11, 110, 225, 45, 227, 123, 105, 127, 53, 87, 47, 140, 17, 52, 84, 248, 71, 176, 64, 122, 33, 176, 208, 226, 131, 174, 79, 158, 77, 34, 0])));
/// D: GDD22AVDLXTVAMXXQ7VEUXBLA3R22BI5DABWK2OJCX2NRHOIP62LRLEP
static immutable D = KeyPair(PublicKey(Point([199, 173, 2, 163, 93, 231, 80, 50, 247, 135, 234, 74, 92, 43, 6, 227, 173, 5, 29, 24, 3, 101, 105, 201, 21, 244, 216, 157, 200, 127, 180, 184])), SecretKey(Scalar([26, 98, 99, 65, 67, 11, 157, 171, 115, 219, 109, 42, 224, 50, 247, 91, 222, 203, 36, 253, 130, 74, 214, 240, 42, 215, 148, 120, 203, 200, 84, 1])));
/// E: GDE22RMGV3PUO3TAUHTR5MIGBQTHKNQH3HEGLIA5UTHH2UE5C4DOGZWA
static immutable E = KeyPair(PublicKey(Point([201, 173, 69, 134, 174, 223, 71, 110, 96, 161, 231, 30, 177, 6, 12, 38, 117, 54, 7, 217, 200, 101, 160, 29, 164, 206, 125, 80, 157, 23, 6, 227])), SecretKey(Scalar([13, 114, 140, 50, 17, 204, 232, 14, 14, 189, 212, 52, 171, 180, 85, 38, 138, 241, 1, 25, 236, 35, 2, 227, 148, 232, 198, 75, 106, 226, 96, 10])));
/// F: GDF223S2GGK3PNUHN2AYTXTUWJR3YIKBYCJ5MDIRGLCR6DDQ6VL3X6VR
static immutable F = KeyPair(PublicKey(Point([203, 173, 110, 90, 49, 149, 183, 182, 135, 110, 129, 137, 222, 116, 178, 99, 188, 33, 65, 192, 147, 214, 13, 17, 50, 197, 31, 12, 112, 245, 87, 187])), SecretKey(Scalar([89, 70, 177, 165, 49, 103, 182, 197, 89, 110, 194, 0, 80, 89, 107, 237, 192, 20, 162, 239, 236, 207, 94, 109, 44, 72, 196, 68, 12, 65, 52, 12])));
/// G: GDG22ZCXN24CGKQPB7BILOO3O3MVLJCMIBUQQOAYIHC236FQPUB5ZCPL
static immutable G = KeyPair(PublicKey(Point([205, 173, 100, 87, 110, 184, 35, 42, 15, 15, 194, 133, 185, 219, 118, 217, 85, 164, 76, 64, 105, 8, 56, 24, 65, 197, 173, 248, 176, 125, 3, 220])), SecretKey(Scalar([207, 43, 226, 9, 153, 203, 79, 202, 114, 171, 200, 243, 216, 3, 77, 215, 9, 196, 187, 40, 113, 232, 146, 21, 132, 31, 122, 137, 214, 24, 213, 3])));
/// H: GDH22JXAGAOHMFBAOP5BXU7O6OPNAWELDV5W4WESTDV6LRKVQX5XLALO
static immutable H = KeyPair(PublicKey(Point([207, 173, 38, 224, 48, 28, 118, 20, 32, 115, 250, 27, 211, 238, 243, 158, 208, 88, 139, 29, 123, 110, 88, 146, 152, 235, 229, 197, 85, 133, 251, 117])), SecretKey(Scalar([248, 248, 39, 28, 141, 206, 202, 229, 37, 130, 129, 98, 164, 76, 26, 228, 20, 54, 210, 120, 59, 77, 144, 106, 53, 198, 109, 124, 62, 147, 46, 11])));
/// I: GDI22SF3IWKPWJ7CNCDAVBRWVIOHLI2MWRB5RJI3RLOQ5IE5G5H75MS3
static immutable I = KeyPair(PublicKey(Point([209, 173, 72, 187, 69, 148, 251, 39, 226, 104, 134, 10, 134, 54, 170, 28, 117, 163, 76, 180, 67, 216, 165, 27, 138, 221, 14, 160, 157, 55, 79, 254])), SecretKey(Scalar([18, 75, 252, 239, 118, 243, 225, 132, 130, 143, 161, 221, 127, 80, 250, 78, 188, 134, 215, 173, 182, 160, 139, 242, 230, 188, 227, 169, 195, 233, 10, 11])));
/// J: GDJ22OCH34M3HVRIAAHUJVJBNEOOIAJH4YVRUHRDP3AY7M3KMWHLA5CP
static immutable J = KeyPair(PublicKey(Point([211, 173, 56, 71, 223, 25, 179, 214, 40, 0, 15, 68, 213, 33, 105, 28, 228, 1, 39, 230, 43, 26, 30, 35, 126, 193, 143, 179, 106, 101, 142, 176])), SecretKey(Scalar([122, 195, 171, 183, 26, 66, 158, 44, 79, 58, 113, 158, 0, 144, 125, 72, 3, 70, 32, 90, 32, 217, 247, 204, 28, 35, 163, 242, 71, 188, 94, 0])));
/// K: GDK22F4BRUOUYXXSN2CJFVQR3LAMC4YE5CTXK75XG7IAKAA7XOU5DERX
static immutable K = KeyPair(PublicKey(Point([213, 173, 23, 129, 141, 29, 76, 94, 242, 110, 132, 146, 214, 17, 218, 192, 193, 115, 4, 232, 167, 117, 127, 183, 55, 208, 5, 0, 31, 187, 169, 209])), SecretKey(Scalar([82, 95, 232, 108, 253, 170, 104, 79, 163, 223, 30, 7, 242, 234, 198, 26, 133, 70, 51, 95, 91, 78, 150, 199, 172, 207, 35, 153, 107, 209, 127, 3])));
/// L: GDL22QXPCWVOTEKA65UUV4SVKP4E6VYCV27DE2LTTCTQRPNUJXR257TG
static immutable L = KeyPair(PublicKey(Point([215, 173, 66, 239, 21, 170, 233, 145, 64, 247, 105, 74, 242, 85, 83, 248, 79, 87, 2, 174, 190, 50, 105, 115, 152, 167, 8, 189, 180, 77, 227, 174])), SecretKey(Scalar([220, 250, 250, 95, 140, 146, 255, 239, 141, 132, 253, 255, 85, 47, 207, 56, 39, 231, 53, 228, 25, 157, 202, 12, 218, 19, 134, 37, 211, 168, 68, 0])));
/// M: GDM224YG2DAUBLWFSYQFDNO3NCIP26HZOBJUR4XGZGEMH4OPVXR7MS3P
static immutable M = KeyPair(PublicKey(Point([217, 173, 115, 6, 208, 193, 64, 174, 197, 150, 32, 81, 181, 219, 104, 144, 253, 120, 249, 112, 83, 72, 242, 230, 201, 136, 195, 241, 207, 173, 227, 246])), SecretKey(Scalar([150, 87, 196, 25, 58, 213, 9, 156, 2, 54, 95, 7, 83, 52, 116, 216, 191, 194, 76, 111, 225, 128, 5, 31, 66, 38, 210, 112, 141, 226, 209, 3])));
/// N: GDN22T2Z3JP6TBODD6TZBZSSSSFLL6D2UZ75AZBSTSHBV53WMXIEX6DL
static immutable N = KeyPair(PublicKey(Point([219, 173, 79, 89, 218, 95, 233, 133, 195, 31, 167, 144, 230, 82, 148, 138, 181, 248, 122, 166, 127, 208, 100, 50, 156, 142, 26, 247, 118, 101, 208, 75])), SecretKey(Scalar([149, 154, 218, 220, 182, 62, 31, 74, 137, 97, 155, 81, 14, 123, 233, 173, 30, 174, 111, 241, 14, 122, 139, 94, 38, 206, 71, 188, 124, 125, 175, 6])));
/// O: GDO22ORPRQUGPUZSF442NSYUVW4ZKFS6KW5XKKGAAYDLASU6CLO3V5YU
static immutable O = KeyPair(PublicKey(Point([221, 173, 58, 47, 140, 40, 103, 211, 50, 47, 57, 166, 203, 20, 173, 185, 149, 22, 94, 85, 187, 117, 40, 192, 6, 6, 176, 74, 158, 18, 221, 186])), SecretKey(Scalar([227, 61, 149, 153, 21, 74, 157, 31, 210, 209, 210, 123, 75, 181, 21, 42, 112, 221, 254, 70, 200, 147, 52, 236, 63, 198, 151, 224, 85, 54, 128, 13])));
/// P: GDP222CSQ6K65HZI64C5PI35PGYOA36BGVQZCKTKITI64KQWRTXHRVYI
static immutable P = KeyPair(PublicKey(Point([223, 173, 104, 82, 135, 149, 238, 159, 40, 247, 5, 215, 163, 125, 121, 176, 224, 111, 193, 53, 97, 145, 42, 106, 68, 209, 238, 42, 22, 140, 238, 120])), SecretKey(Scalar([134, 44, 171, 231, 87, 220, 104, 196, 249, 46, 80, 209, 75, 115, 33, 175, 9, 128, 192, 89, 76, 113, 240, 91, 163, 164, 213, 82, 176, 39, 92, 1])));
/// Q: GDQ223DL4XJPWZJWD5LEADX7AKP6GVYVPV437EYRLL3P36GZPK7EQERA
static immutable Q = KeyPair(PublicKey(Point([225, 173, 108, 107, 229, 210, 251, 101, 54, 31, 86, 64, 14, 255, 2, 159, 227, 87, 21, 125, 121, 191, 147, 17, 90, 246, 253, 248, 217, 122, 190, 72])), SecretKey(Scalar([254, 30, 199, 22, 148, 223, 84, 170, 24, 90, 195, 48, 86, 83, 20, 103, 141, 221, 134, 20, 207, 163, 141, 40, 66, 124, 71, 182, 249, 144, 220, 8])));
/// R: GDR22YHYZZRWLS6LUYZFUOMIW2MRI6U4TLWAQWIOOYV2PQHBRH62IQ5G
static immutable R = KeyPair(PublicKey(Point([227, 173, 96, 248, 206, 99, 101, 203, 203, 166, 50, 90, 57, 136, 182, 153, 20, 122, 156, 154, 236, 8, 89, 14, 118, 43, 167, 192, 225, 137, 253, 164])), SecretKey(Scalar([148, 127, 181, 90, 69, 235, 85, 97, 170, 50, 132, 130, 112, 15, 55, 12, 16, 17, 149, 152, 33, 192, 238, 37, 6, 72, 169, 20, 12, 119, 121, 12])));
/// S: GDS22K6WFIETNZDSLIINCDIND7RJSB5CFL2MHYQP4A64SSQMBS5SQIYU
static immutable S = KeyPair(PublicKey(Point([229, 173, 43, 214, 42, 9, 54, 228, 114, 90, 16, 209, 13, 13, 31, 226, 153, 7, 162, 42, 244, 195, 226, 15, 224, 61, 201, 74, 12, 12, 187, 40])), SecretKey(Scalar([140, 237, 130, 117, 92, 99, 20, 96, 166, 222, 91, 32, 11, 137, 166, 255, 207, 180, 53, 27, 153, 240, 239, 204, 154, 158, 176, 46, 3, 110, 170, 4])));
/// T: GDT22LIJKU45USVNRTMTCCNMFZ56B7HAL2ATTAJ2RESVJU4TLJ2CNPH2
static immutable T = KeyPair(PublicKey(Point([231, 173, 45, 9, 85, 57, 218, 74, 173, 140, 217, 49, 9, 172, 46, 123, 224, 252, 224, 94, 129, 57, 129, 58, 137, 37, 84, 211, 147, 90, 116, 38])), SecretKey(Scalar([147, 225, 221, 32, 159, 148, 208, 131, 130, 82, 96, 229, 22, 23, 190, 229, 204, 149, 190, 234, 164, 132, 68, 90, 15, 168, 248, 168, 190, 11, 130, 4])));
/// U: GDU22Z7KUSOKYWI2YIYONWPP2BKLTKR2GQ6RLJP6S5BJ3IPTMSDJIC6R
static immutable U = KeyPair(PublicKey(Point([233, 173, 103, 234, 164, 156, 172, 89, 26, 194, 48, 230, 217, 239, 208, 84, 185, 170, 58, 52, 61, 21, 165, 254, 151, 66, 157, 161, 243, 100, 134, 148])), SecretKey(Scalar([237, 121, 76, 245, 142, 137, 53, 251, 237, 107, 162, 168, 145, 48, 68, 155, 156, 154, 134, 135, 30, 39, 2, 221, 224, 26, 28, 31, 113, 133, 221, 4])));
/// V: GDV22OJCVFBDT5IA2PSXZINDBMN5F3FQ5OGS2YFJZ7IXML27VYT3FTJW
static immutable V = KeyPair(PublicKey(Point([235, 173, 57, 34, 169, 66, 57, 245, 0, 211, 229, 124, 161, 163, 11, 27, 210, 236, 176, 235, 141, 45, 96, 169, 207, 209, 118, 47, 95, 174, 39, 178])), SecretKey(Scalar([46, 239, 56, 215, 137, 230, 190, 200, 25, 171, 66, 239, 195, 221, 220, 206, 154, 36, 117, 244, 54, 89, 188, 214, 53, 8, 214, 182, 213, 116, 68, 14])));
/// W: GDW22CSWLKKGKBSWX4JMIA45D5TQGX6FPILFF4B5YHI6RFRFDWQWPAY5
static immutable W = KeyPair(PublicKey(Point([237, 173, 10, 86, 90, 148, 101, 6, 86, 191, 18, 196, 3, 157, 31, 103, 3, 95, 197, 122, 22, 82, 240, 61, 193, 209, 232, 150, 37, 29, 161, 103])), SecretKey(Scalar([75, 33, 177, 253, 57, 212, 242, 195, 118, 127, 12, 34, 58, 21, 105, 16, 7, 100, 71, 248, 52, 202, 162, 34, 8, 214, 230, 111, 53, 109, 40, 3])));
/// X: GDX22HLAEIGVJUERYAUT6MGZV7UFECZUAR4CRKNQ66OYERA2RNR33PPZ
static immutable X = KeyPair(PublicKey(Point([239, 173, 29, 96, 34, 13, 84, 208, 145, 192, 41, 63, 48, 217, 175, 232, 82, 11, 52, 4, 120, 40, 169, 176, 247, 157, 130, 68, 26, 139, 99, 189])), SecretKey(Scalar([196, 148, 229, 135, 94, 211, 255, 61, 173, 75, 137, 100, 178, 0, 17, 10, 126, 103, 82, 41, 214, 146, 125, 62, 61, 248, 36, 114, 253, 170, 126, 15])));
/// Y: GDY22TXFFTRPKIB4BI5ZUDMIGXDR5OXSEWBONX64MTP7CHG2CBP5O7SZ
static immutable Y = KeyPair(PublicKey(Point([241, 173, 78, 229, 44, 226, 245, 32, 60, 10, 59, 154, 13, 136, 53, 199, 30, 186, 242, 37, 130, 230, 223, 220, 100, 223, 241, 28, 218, 16, 95, 215])), SecretKey(Scalar([117, 6, 204, 94, 203, 77, 86, 17, 108, 233, 11, 128, 41, 112, 121, 112, 75, 253, 243, 87, 43, 201, 151, 118, 44, 189, 24, 50, 220, 4, 240, 9])));
/// Z: GDZ22FEX447447OWO6RHIR257Y32TCNGAGE4OAVMVUFUMP4BLKFPWWJV
static immutable Z = KeyPair(PublicKey(Point([243, 173, 20, 151, 231, 63, 206, 125, 214, 119, 162, 116, 71, 93, 254, 55, 169, 137, 166, 1, 137, 199, 2, 172, 173, 11, 70, 63, 129, 90, 138, 251])), SecretKey(Scalar([43, 18, 140, 52, 88, 127, 186, 77, 203, 101, 181, 136, 31, 45, 153, 133, 25, 57, 32, 95, 210, 217, 241, 42, 205, 202, 134, 177, 15, 141, 133, 15])));
/// AA: GDAA22CSRSJDWXPPL3WOFDABSQKIYTBRT3HQTNPLC5D67TPT2CHYECKB
static immutable AA = KeyPair(PublicKey(Point([192, 13, 104, 82, 140, 146, 59, 93, 239, 94, 236, 226, 140, 1, 148, 20, 140, 76, 49, 158, 207, 9, 181, 235, 23, 71, 239, 205, 243, 208, 143, 130])), SecretKey(Scalar([127, 77, 167, 165, 155, 92, 128, 200, 70, 105, 144, 239, 223, 24, 208, 74, 129, 74, 105, 55, 194, 66, 35, 243, 17, 3, 240, 129, 72, 254, 84, 9])));
/// AB: GDAB22UZFEG73XXXF5FNAQ7TNME2LH26NQBIP6LG3HIBZPOT5ZMOGQ4O
static immutable AB = KeyPair(PublicKey(Point([192, 29, 106, 153, 41, 13, 253, 222, 247, 47, 74, 208, 67, 243, 107, 9, 165, 159, 94, 108, 2, 135, 249, 102, 217, 208, 28, 189, 211, 238, 88, 227])), SecretKey(Scalar([86, 33, 111, 70, 6, 166, 234, 3, 49, 134, 128, 11, 120, 61, 49, 114, 148, 5, 8, 254, 254, 166, 64, 40, 67, 166, 125, 193, 20, 11, 8, 7])));
/// AC: GDAC22PUCZ6IAAPRK4D2SLBGEVIGYPJYDXPYM7TP5VMVLH3Q7LCC2FQU
static immutable AC = KeyPair(PublicKey(Point([192, 45, 105, 244, 22, 124, 128, 1, 241, 87, 7, 169, 44, 38, 37, 80, 108, 61, 56, 29, 223, 134, 126, 111, 237, 89, 85, 159, 112, 250, 196, 45])), SecretKey(Scalar([206, 72, 93, 93, 242, 240, 32, 242, 26, 135, 234, 230, 151, 25, 255, 21, 208, 152, 243, 23, 231, 54, 146, 56, 3, 2, 235, 68, 232, 235, 33, 4])));
/// AD: GDAD22XGREJKB2VQKSAFNT5SIF3YMI2EH4UI6FR4EQBB6ZR7H7HI47ZJ
static immutable AD = KeyPair(PublicKey(Point([192, 61, 106, 230, 137, 18, 160, 234, 176, 84, 128, 86, 207, 178, 65, 119, 134, 35, 68, 63, 40, 143, 22, 60, 36, 2, 31, 102, 63, 63, 206, 142])), SecretKey(Scalar([114, 255, 51, 99, 194, 207, 21, 2, 230, 15, 230, 96, 221, 133, 126, 248, 254, 252, 224, 11, 108, 116, 91, 48, 170, 164, 141, 144, 242, 195, 94, 6])));
/// AE: GDAE22J2STMGY322H5AEMBNZXDCT4YYZTTEKVN3BQ2OPO4WEI652LBMV
static immutable AE = KeyPair(PublicKey(Point([192, 77, 105, 58, 148, 216, 108, 111, 90, 63, 64, 70, 5, 185, 184, 197, 62, 99, 25, 156, 200, 170, 183, 97, 134, 156, 247, 114, 196, 71, 187, 165])), SecretKey(Scalar([181, 23, 64, 77, 104, 230, 72, 97, 241, 218, 196, 44, 154, 20, 77, 15, 151, 228, 31, 90, 224, 48, 194, 134, 26, 157, 226, 250, 205, 81, 48, 10])));
/// AF: GDAF22Y3P6GUC5YOGOLKQU6DD3GHEA26C2X7V6JDSBA7YBLDSV6Y47JB
static immutable AF = KeyPair(PublicKey(Point([192, 93, 107, 27, 127, 141, 65, 119, 14, 51, 150, 168, 83, 195, 30, 204, 114, 3, 94, 22, 175, 250, 249, 35, 144, 65, 252, 5, 99, 149, 125, 142])), SecretKey(Scalar([35, 60, 224, 81, 126, 23, 200, 157, 248, 253, 155, 126, 17, 96, 28, 26, 105, 138, 184, 109, 128, 170, 206, 55, 147, 70, 8, 0, 69, 223, 111, 4])));
/// AG: GDAG22QYNJUSHT5UOZMI5PRSTRLX2W4ITJGXIZ7C2FE2JYUXCKHQAIDL
static immutable AG = KeyPair(PublicKey(Point([192, 109, 106, 24, 106, 105, 35, 207, 180, 118, 88, 142, 190, 50, 156, 87, 125, 91, 136, 154, 77, 116, 103, 226, 209, 73, 164, 226, 151, 18, 143, 0])), SecretKey(Scalar([194, 7, 234, 134, 242, 241, 150, 218, 27, 81, 73, 54, 120, 56, 116, 38, 174, 210, 103, 8, 120, 124, 251, 27, 98, 77, 133, 67, 106, 121, 216, 10])));
/// AH: GDAH22JYD3BZA4KRAQNVLZKFR23PN2ILQ44ZJ6D37RSPH2OHH6T6JKJV
static immutable AH = KeyPair(PublicKey(Point([192, 125, 105, 56, 30, 195, 144, 113, 81, 4, 27, 85, 229, 69, 142, 182, 246, 233, 11, 135, 57, 148, 248, 123, 252, 100, 243, 233, 199, 63, 167, 228])), SecretKey(Scalar([54, 151, 128, 44, 12, 110, 191, 195, 236, 151, 182, 191, 159, 104, 85, 148, 18, 46, 143, 227, 83, 88, 74, 220, 36, 153, 63, 181, 131, 236, 3, 15])));
/// AI: GDAI22GR7LU6J26QMFW55AIBLYR474ZIR3JJ5F43BXYPH6H2NLYT5X2C
static immutable AI = KeyPair(PublicKey(Point([192, 141, 104, 209, 250, 233, 228, 235, 208, 97, 109, 222, 129, 1, 94, 35, 207, 243, 40, 142, 210, 158, 151, 155, 13, 240, 243, 248, 250, 106, 241, 62])), SecretKey(Scalar([117, 17, 217, 67, 181, 111, 17, 99, 6, 237, 82, 247, 222, 146, 148, 234, 149, 75, 192, 17, 236, 250, 139, 129, 48, 250, 234, 151, 196, 254, 52, 5])));
/// AJ: GDAJ22R2CPQSWXWVALM3FKV2PDFIFSU3CZU6ZMVYJJX7CPGHPKHT63GV
static immutable AJ = KeyPair(PublicKey(Point([192, 157, 106, 58, 19, 225, 43, 94, 213, 2, 217, 178, 170, 186, 120, 202, 130, 202, 155, 22, 105, 236, 178, 184, 74, 111, 241, 60, 199, 122, 143, 63])), SecretKey(Scalar([87, 95, 23, 30, 87, 84, 246, 45, 150, 181, 198, 253, 226, 28, 239, 107, 186, 67, 43, 145, 31, 24, 212, 25, 233, 227, 151, 36, 159, 74, 249, 12])));
/// AK: GDAK22EVVVPJ6472TRHB52E6MEBPNPYEF5ZRM3OI4ND6QLI2M5MQASNN
static immutable AK = KeyPair(PublicKey(Point([192, 173, 104, 149, 173, 94, 159, 115, 250, 156, 78, 30, 232, 158, 97, 2, 246, 191, 4, 47, 115, 22, 109, 200, 227, 71, 232, 45, 26, 103, 89, 0])), SecretKey(Scalar([51, 36, 73, 175, 73, 36, 79, 152, 17, 207, 124, 139, 255, 27, 38, 113, 143, 131, 190, 66, 167, 74, 61, 61, 78, 254, 189, 210, 107, 167, 160, 11])));
/// AL: GDAL22FRWLXKJPBF7E5GZKL7YGUIWW5GFBDL45ARTHJ7J5EUHD62O5EE
static immutable AL = KeyPair(PublicKey(Point([192, 189, 104, 177, 178, 238, 164, 188, 37, 249, 58, 108, 169, 127, 193, 168, 139, 91, 166, 40, 70, 190, 116, 17, 153, 211, 244, 244, 148, 56, 253, 167])), SecretKey(Scalar([222, 28, 212, 5, 26, 171, 95, 144, 60, 81, 17, 113, 167, 33, 136, 20, 211, 82, 230, 235, 139, 169, 252, 151, 57, 212, 194, 174, 210, 90, 190, 12])));
/// AM: GDAM22XZHFKSQV5JBWQFSBEOER5UCBBBGOCDJGVYMWUGSE2QFSWTMSU6
static immutable AM = KeyPair(PublicKey(Point([192, 205, 106, 249, 57, 85, 40, 87, 169, 13, 160, 89, 4, 142, 36, 123, 65, 4, 33, 51, 132, 52, 154, 184, 101, 168, 105, 19, 80, 44, 173, 54])), SecretKey(Scalar([118, 131, 129, 118, 32, 217, 240, 113, 138, 226, 25, 107, 189, 187, 68, 119, 81, 136, 126, 94, 209, 57, 42, 136, 162, 36, 149, 248, 217, 215, 94, 13])));
/// AN: GDAN22K33XH4EFUI4YI4CNPTSV7BYOPP7HBERIPKE7EFCICWXGEHR43F
static immutable AN = KeyPair(PublicKey(Point([192, 221, 105, 91, 221, 207, 194, 22, 136, 230, 17, 193, 53, 243, 149, 126, 28, 57, 239, 249, 194, 72, 161, 234, 39, 200, 81, 32, 86, 185, 136, 120])), SecretKey(Scalar([18, 165, 182, 149, 79, 24, 9, 115, 244, 81, 74, 226, 59, 201, 252, 96, 237, 172, 61, 114, 173, 26, 142, 228, 55, 45, 35, 64, 11, 250, 157, 7])));
/// AO: GDAO227EYDXBGIVSQIU5IIEH3YWJSXVNARQR3DXNJF5YZSVEM7CULGOA
static immutable AO = KeyPair(PublicKey(Point([192, 237, 107, 228, 192, 238, 19, 34, 178, 130, 41, 212, 32, 135, 222, 44, 153, 94, 173, 4, 97, 29, 142, 237, 73, 123, 140, 202, 164, 103, 197, 69])), SecretKey(Scalar([121, 47, 75, 206, 188, 242, 37, 157, 148, 186, 68, 2, 189, 81, 177, 43, 192, 60, 173, 170, 59, 95, 73, 218, 109, 253, 209, 242, 187, 72, 26, 1])));
/// AP: GDAP22HZNGXSKPP36Z7BHNIQZCYTO3LGYBYJXOMZJF67UXMAF2AWYW3Y
static immutable AP = KeyPair(PublicKey(Point([192, 253, 104, 249, 105, 175, 37, 61, 251, 246, 126, 19, 181, 16, 200, 177, 55, 109, 102, 192, 112, 155, 185, 153, 73, 125, 250, 93, 128, 46, 129, 108])), SecretKey(Scalar([28, 63, 252, 105, 169, 157, 3, 206, 136, 70, 28, 71, 25, 176, 235, 131, 197, 196, 137, 239, 74, 56, 127, 252, 168, 120, 176, 169, 188, 130, 4, 9])));
/// AQ: GDAQ225DOYKZV4UARDVKVLUMQT33KQ5KU6ALKYTSOFKR5WND4EOWMAGM
static immutable AQ = KeyPair(PublicKey(Point([193, 13, 107, 163, 118, 21, 154, 242, 128, 136, 234, 170, 174, 140, 132, 247, 181, 67, 170, 167, 128, 181, 98, 114, 113, 85, 30, 217, 163, 225, 29, 102])), SecretKey(Scalar([100, 201, 202, 117, 179, 56, 253, 66, 56, 107, 175, 98, 28, 59, 65, 203, 248, 250, 44, 0, 147, 241, 189, 233, 82, 34, 253, 36, 225, 175, 127, 2])));
/// AR: GDAR222AFKGHZ4SKRXKTXPBFLEOIMY2OQHVR334JTBUXYVQ5ATPGIUTW
static immutable AR = KeyPair(PublicKey(Point([193, 29, 107, 64, 42, 140, 124, 242, 74, 141, 213, 59, 188, 37, 89, 28, 134, 99, 78, 129, 235, 29, 239, 137, 152, 105, 124, 86, 29, 4, 222, 100])), SecretKey(Scalar([87, 10, 166, 221, 39, 121, 128, 29, 109, 42, 43, 113, 85, 38, 236, 29, 68, 66, 42, 63, 59, 233, 54, 122, 115, 159, 208, 72, 11, 154, 229, 3])));
/// AS: GDAS22MZ5OX5RSKQXMDOYFZCBEFPPRYBLFMS3AKGRDCHGMGPG4SZAKBW
static immutable AS = KeyPair(PublicKey(Point([193, 45, 105, 153, 235, 175, 216, 201, 80, 187, 6, 236, 23, 34, 9, 10, 247, 199, 1, 89, 89, 45, 129, 70, 136, 196, 115, 48, 207, 55, 37, 144])), SecretKey(Scalar([102, 87, 18, 137, 119, 40, 41, 223, 122, 156, 124, 67, 213, 110, 101, 161, 16, 201, 28, 200, 73, 128, 104, 40, 2, 47, 198, 59, 175, 34, 72, 3])));
/// AT: GDAT22UMIFFC7F52WBS22M2JS4STARAENE2CWB6YLEIYAEETG6C625KZ
static immutable AT = KeyPair(PublicKey(Point([193, 61, 106, 140, 65, 74, 47, 151, 186, 176, 101, 173, 51, 73, 151, 37, 48, 68, 4, 105, 52, 43, 7, 216, 89, 17, 128, 16, 147, 55, 133, 237])), SecretKey(Scalar([4, 52, 109, 180, 101, 248, 132, 142, 198, 239, 212, 148, 126, 212, 179, 94, 248, 85, 189, 90, 244, 216, 140, 107, 167, 132, 199, 154, 62, 232, 68, 6])));
/// AU: GDAU22OVWQHNEHETOXNCFSFKHKP6SMQQZDH2DCSBVKO4JRSJRPCD4GUF
static immutable AU = KeyPair(PublicKey(Point([193, 77, 105, 213, 180, 14, 210, 28, 147, 117, 218, 34, 200, 170, 58, 159, 233, 50, 16, 200, 207, 161, 138, 65, 170, 157, 196, 198, 73, 139, 196, 62])), SecretKey(Scalar([45, 223, 135, 89, 141, 250, 2, 182, 48, 54, 253, 207, 199, 84, 193, 84, 66, 230, 214, 144, 135, 190, 25, 162, 21, 81, 241, 252, 32, 59, 145, 7])));
/// AV: GDAV22BRC3YDCZG2E4UVIKEXFL2GSMCMH7F5HIMEF6Q2W76F42PXU26M
static immutable AV = KeyPair(PublicKey(Point([193, 93, 104, 49, 22, 240, 49, 100, 218, 39, 41, 84, 40, 151, 42, 244, 105, 48, 76, 63, 203, 211, 161, 132, 47, 161, 171, 127, 197, 230, 159, 122])), SecretKey(Scalar([183, 252, 226, 113, 243, 231, 214, 153, 36, 54, 103, 101, 167, 245, 170, 229, 231, 81, 108, 136, 213, 143, 55, 172, 179, 198, 193, 185, 231, 195, 121, 9])));
/// AW: GDAW22PN645DVUZERNWET74GKYGUFE3EHCALZ2F6EXAQNPNFRQJGZWGG
static immutable AW = KeyPair(PublicKey(Point([193, 109, 105, 237, 247, 58, 58, 211, 36, 139, 108, 73, 255, 134, 86, 13, 66, 147, 100, 56, 128, 188, 232, 190, 37, 193, 6, 189, 165, 140, 18, 108])), SecretKey(Scalar([169, 192, 150, 82, 51, 243, 247, 230, 42, 135, 203, 249, 79, 205, 149, 231, 205, 152, 221, 79, 135, 241, 34, 212, 150, 53, 233, 66, 204, 141, 250, 14])));
/// AX: GDAX22ME3JFHO5CM6EEWUUT5N635H2TYEKSL4EKDZKQ2EH565E4C4HHL
static immutable AX = KeyPair(PublicKey(Point([193, 125, 105, 132, 218, 74, 119, 116, 76, 241, 9, 106, 82, 125, 111, 183, 211, 234, 120, 34, 164, 190, 17, 67, 202, 161, 162, 31, 190, 233, 56, 46])), SecretKey(Scalar([60, 148, 136, 41, 110, 235, 124, 236, 235, 231, 197, 93, 46, 52, 68, 151, 193, 18, 19, 173, 176, 165, 39, 214, 56, 212, 76, 148, 39, 240, 189, 6])));
/// AY: GDAY224JFB2FS6KTWKYJXMVFQZXWRXLYY7PAWIHKTYZUHAXUGEUJFIXB
static immutable AY = KeyPair(PublicKey(Point([193, 141, 107, 137, 40, 116, 89, 121, 83, 178, 176, 155, 178, 165, 134, 111, 104, 221, 120, 199, 222, 11, 32, 234, 158, 51, 67, 130, 244, 49, 40, 146])), SecretKey(Scalar([60, 244, 237, 67, 23, 172, 91, 174, 102, 107, 43, 75, 16, 189, 241, 177, 58, 183, 89, 224, 121, 47, 164, 181, 3, 96, 238, 185, 161, 221, 60, 0])));
/// AZ: GDAZ22XM4IG4VA7MMKR2MADC6BFYPG5XFONBRDNBV5X4W33YARJT5ZQA
static immutable AZ = KeyPair(PublicKey(Point([193, 157, 106, 236, 226, 13, 202, 131, 236, 98, 163, 166, 0, 98, 240, 75, 135, 155, 183, 43, 154, 24, 141, 161, 175, 111, 203, 111, 120, 4, 83, 62])), SecretKey(Scalar([202, 130, 247, 1, 71, 18, 159, 248, 23, 182, 117, 150, 24, 12, 0, 221, 123, 160, 181, 191, 128, 41, 30, 96, 155, 244, 178, 61, 51, 26, 255, 3])));
/// BA: GDBA22ZINETGB2RF3LBSEVCD53PGINCNNRTAOOUTHMGAOK3ER25IFPTJ
static immutable BA = KeyPair(PublicKey(Point([194, 13, 107, 40, 105, 38, 96, 234, 37, 218, 195, 34, 84, 67, 238, 222, 100, 52, 77, 108, 102, 7, 58, 147, 59, 12, 7, 43, 100, 142, 186, 130])), SecretKey(Scalar([43, 59, 177, 67, 133, 27, 25, 86, 109, 163, 107, 36, 214, 77, 5, 158, 36, 237, 165, 168, 236, 134, 19, 62, 5, 15, 106, 255, 120, 63, 24, 4])));
/// BB: GDBB22O45H2X2XTEBTVC2BGGLKQORXHU3IKPD34RNVMO2DEHWX2WXSQI
static immutable BB = KeyPair(PublicKey(Point([194, 29, 105, 220, 233, 245, 125, 94, 100, 12, 234, 45, 4, 198, 90, 160, 232, 220, 244, 218, 20, 241, 239, 145, 109, 88, 237, 12, 135, 181, 245, 107])), SecretKey(Scalar([47, 117, 171, 70, 44, 241, 194, 186, 77, 76, 238, 24, 92, 162, 217, 223, 193, 240, 167, 222, 10, 97, 247, 83, 78, 84, 188, 147, 52, 204, 50, 1])));
/// BC: GDBC22WMEHBUYEOA5YLYYQ5HT5CQNSABMCA6PS66BIV2E25QCDPLU4N6
static immutable BC = KeyPair(PublicKey(Point([194, 45, 106, 204, 33, 195, 76, 17, 192, 238, 23, 140, 67, 167, 159, 69, 6, 200, 1, 96, 129, 231, 203, 222, 10, 43, 162, 107, 176, 16, 222, 186])), SecretKey(Scalar([22, 92, 109, 96, 41, 50, 20, 14, 222, 150, 198, 122, 246, 174, 69, 237, 122, 224, 97, 113, 23, 210, 195, 144, 220, 110, 141, 5, 167, 17, 18, 1])));
/// BD: GDBD225UT747SMBIDFKRA2D6WKX4VX33DEEMSPYKRMNECQ4WNR5YR5E2
static immutable BD = KeyPair(PublicKey(Point([194, 61, 107, 180, 159, 249, 249, 48, 40, 25, 85, 16, 104, 126, 178, 175, 202, 223, 123, 25, 8, 201, 63, 10, 139, 26, 65, 67, 150, 108, 123, 136])), SecretKey(Scalar([165, 185, 182, 240, 15, 35, 48, 172, 12, 163, 157, 159, 229, 63, 142, 63, 149, 179, 75, 224, 208, 185, 4, 14, 8, 64, 23, 21, 48, 201, 86, 12])));
/// BE: GDBE227IN2P4WF3BTQNON6IWJD2FH7X37R46H3WGG4SQWXSPH5LBZY6F
static immutable BE = KeyPair(PublicKey(Point([194, 77, 107, 232, 110, 159, 203, 23, 97, 156, 26, 230, 249, 22, 72, 244, 83, 254, 251, 252, 121, 227, 238, 198, 55, 37, 11, 94, 79, 63, 86, 28])), SecretKey(Scalar([220, 64, 217, 221, 6, 199, 28, 208, 171, 135, 102, 248, 9, 7, 4, 132, 43, 42, 155, 148, 231, 78, 38, 180, 9, 226, 24, 109, 161, 40, 208, 2])));
/// BF: GDBF22UXELMHTSI2ZBBFFRJOTNTW35LIQZBY6ISUIPG7QPZCKIZTJYHM
static immutable BF = KeyPair(PublicKey(Point([194, 93, 106, 151, 34, 216, 121, 201, 26, 200, 66, 82, 197, 46, 155, 103, 109, 245, 104, 134, 67, 143, 34, 84, 67, 205, 248, 63, 34, 82, 51, 52])), SecretKey(Scalar([20, 60, 85, 62, 176, 176, 9, 9, 149, 105, 57, 228, 229, 207, 218, 150, 251, 91, 248, 153, 176, 238, 111, 153, 211, 199, 225, 225, 211, 249, 105, 14])));
/// BG: GDBG22AWIE6MC37NI57VISHLD5QOWBOR2TLPPRJD4F7BNU75Z3TB5ZC4
static immutable BG = KeyPair(PublicKey(Point([194, 109, 104, 22, 65, 60, 193, 111, 237, 71, 127, 84, 72, 235, 31, 96, 235, 5, 209, 212, 214, 247, 197, 35, 225, 126, 22, 211, 253, 206, 230, 30])), SecretKey(Scalar([221, 52, 64, 158, 250, 37, 215, 61, 71, 39, 25, 166, 151, 148, 46, 142, 97, 80, 237, 114, 198, 238, 239, 230, 57, 197, 65, 224, 179, 191, 97, 9])));
/// BH: GDBH2245PVS5MK5I4J3V23ALEJTAAILWNYRIQMBGLEYTJ2E3YNU3RFEZ
static immutable BH = KeyPair(PublicKey(Point([194, 125, 107, 157, 125, 101, 214, 43, 168, 226, 119, 93, 108, 11, 34, 102, 0, 33, 118, 110, 34, 136, 48, 38, 89, 49, 52, 232, 155, 195, 105, 184])), SecretKey(Scalar([50, 74, 189, 240, 144, 168, 68, 8, 25, 81, 77, 121, 64, 178, 70, 75, 150, 33, 252, 241, 100, 40, 52, 58, 133, 81, 212, 147, 173, 94, 21, 15])));
/// BI: GDBI22ZZZ7QY42HZSJ4PSA4NVBXE5AKVKPSZ3YECKGMKCWO2OOKKI4D7
static immutable BI = KeyPair(PublicKey(Point([194, 141, 107, 57, 207, 225, 142, 104, 249, 146, 120, 249, 3, 141, 168, 110, 78, 129, 85, 83, 229, 157, 224, 130, 81, 152, 161, 89, 218, 115, 148, 164])), SecretKey(Scalar([94, 97, 9, 139, 170, 230, 77, 109, 227, 171, 176, 195, 232, 59, 132, 230, 254, 53, 20, 209, 103, 96, 80, 86, 53, 140, 169, 15, 52, 132, 19, 3])));
/// BJ: GDBJ22U7A27EHYYABKH7EFGIGVNAUTHMF2QDNHQ2UV2RQLG4MH5CC525
static immutable BJ = KeyPair(PublicKey(Point([194, 157, 106, 159, 6, 190, 67, 227, 0, 10, 143, 242, 20, 200, 53, 90, 10, 76, 236, 46, 160, 54, 158, 26, 165, 117, 24, 44, 220, 97, 250, 33])), SecretKey(Scalar([151, 131, 185, 183, 52, 235, 148, 69, 144, 11, 227, 158, 120, 236, 223, 251, 201, 66, 78, 171, 9, 140, 189, 187, 164, 96, 162, 123, 211, 203, 117, 14])));
/// BK: GDBK22YPHAK65TSBGS6HKKCPBU4OCA7AUG5FY3WLED4EMQX5JSUNEHMU
static immutable BK = KeyPair(PublicKey(Point([194, 173, 107, 15, 56, 21, 238, 206, 65, 52, 188, 117, 40, 79, 13, 56, 225, 3, 224, 161, 186, 92, 110, 203, 32, 248, 70, 66, 253, 76, 168, 210])), SecretKey(Scalar([229, 250, 196, 112, 79, 186, 114, 150, 74, 133, 123, 130, 197, 22, 224, 118, 45, 226, 33, 202, 107, 39, 75, 180, 249, 58, 191, 28, 229, 52, 157, 1])));
/// BL: GDBL224RYE7BIU4JA33UDJJ6Q7FXNKQHBIXKEZ3U6HWRUHGLLWEEE65D
static immutable BL = KeyPair(PublicKey(Point([194, 189, 107, 145, 193, 62, 20, 83, 137, 6, 247, 65, 165, 62, 135, 203, 118, 170, 7, 10, 46, 162, 103, 116, 241, 237, 26, 28, 203, 93, 136, 66])), SecretKey(Scalar([94, 80, 249, 76, 93, 72, 238, 114, 182, 11, 167, 54, 97, 99, 204, 64, 135, 95, 68, 44, 51, 195, 228, 49, 115, 21, 180, 114, 157, 140, 207, 13])));
/// BM: GDBM22QZQONRKVAXZSBBFMDKD27EXWBFSGUFUZ4WTIEVVD3YWCLLQI6Z
static immutable BM = KeyPair(PublicKey(Point([194, 205, 106, 25, 131, 155, 21, 84, 23, 204, 130, 18, 176, 106, 30, 190, 75, 216, 37, 145, 168, 90, 103, 150, 154, 9, 90, 143, 120, 176, 150, 184])), SecretKey(Scalar([5, 202, 169, 216, 60, 63, 253, 1, 16, 254, 76, 26, 221, 250, 100, 24, 89, 9, 214, 174, 201, 141, 90, 154, 97, 239, 147, 158, 177, 135, 225, 6])));
/// BN: GDBN22CO66UCREOXK4NZSWZP57JW3LR5R35YHDUNECDNC3DTC36HGW6L
static immutable BN = KeyPair(PublicKey(Point([194, 221, 104, 78, 247, 168, 40, 145, 215, 87, 27, 153, 91, 47, 239, 211, 109, 174, 61, 142, 251, 131, 142, 141, 32, 134, 209, 108, 115, 22, 252, 115])), SecretKey(Scalar([31, 219, 229, 6, 29, 173, 236, 137, 140, 41, 107, 82, 228, 92, 208, 92, 32, 133, 195, 22, 53, 20, 241, 90, 137, 185, 235, 107, 92, 129, 198, 1])));
/// BO: GDBO22LMSJAQKLNMBRTFYJGDB3JJE3D4GRXRFAN6625PCT54UHMU7LMT
static immutable BO = KeyPair(PublicKey(Point([194, 237, 105, 108, 146, 65, 5, 45, 172, 12, 102, 92, 36, 195, 14, 210, 146, 108, 124, 52, 111, 18, 129, 190, 246, 186, 241, 79, 188, 161, 217, 79])), SecretKey(Scalar([3, 67, 1, 64, 111, 152, 169, 49, 37, 243, 139, 154, 142, 107, 185, 33, 224, 58, 22, 147, 112, 77, 249, 248, 148, 233, 242, 132, 55, 174, 66, 1])));
/// BP: GDBP22LYPUP23LUEFFO37XYYPN7WFI4D6W2EUB5CWCW6NKHFLLG24AKK
static immutable BP = KeyPair(PublicKey(Point([194, 253, 105, 120, 125, 31, 173, 174, 132, 41, 93, 191, 223, 24, 123, 127, 98, 163, 131, 245, 180, 74, 7, 162, 176, 173, 230, 168, 229, 90, 205, 174])), SecretKey(Scalar([20, 188, 60, 170, 60, 39, 143, 166, 68, 15, 12, 89, 60, 112, 192, 195, 216, 252, 189, 15, 15, 237, 154, 76, 185, 131, 234, 165, 159, 239, 21, 1])));
/// BQ: GDBQ22W7O37CHCEH5OB5WGFQNRLD5F3LAJEMEYZR2AVO5GWEPD4NIP32
static immutable BQ = KeyPair(PublicKey(Point([195, 13, 106, 223, 118, 254, 35, 136, 135, 235, 131, 219, 24, 176, 108, 86, 62, 151, 107, 2, 72, 194, 99, 49, 208, 42, 238, 154, 196, 120, 248, 212])), SecretKey(Scalar([210, 17, 11, 76, 100, 222, 15, 78, 51, 246, 52, 135, 116, 170, 86, 173, 255, 169, 221, 221, 64, 242, 118, 105, 177, 17, 83, 98, 25, 7, 106, 0])));
/// BR: GDBR22ODAAUFYMO7PXZK3KAQX6P6RFXMHRLFR6OXXTWWIX33DPAOTUSQ
static immutable BR = KeyPair(PublicKey(Point([195, 29, 105, 195, 0, 40, 92, 49, 223, 125, 242, 173, 168, 16, 191, 159, 232, 150, 236, 60, 86, 88, 249, 215, 188, 237, 100, 95, 123, 27, 192, 233])), SecretKey(Scalar([22, 103, 38, 221, 110, 139, 180, 63, 117, 244, 102, 90, 229, 217, 60, 191, 13, 236, 77, 8, 2, 169, 18, 216, 103, 87, 253, 130, 96, 221, 251, 3])));
/// BS: GDBS22QU4MIQHKXSXMECUZY2ENFLVFJYK4SNAUEEM5YXPUGFWMJRMPXT
static immutable BS = KeyPair(PublicKey(Point([195, 45, 106, 20, 227, 17, 3, 170, 242, 187, 8, 42, 103, 26, 35, 74, 186, 149, 56, 87, 36, 208, 80, 132, 103, 113, 119, 208, 197, 179, 19, 22])), SecretKey(Scalar([92, 61, 56, 92, 201, 105, 67, 37, 99, 255, 40, 220, 0, 45, 243, 122, 134, 37, 191, 117, 250, 180, 188, 79, 162, 99, 174, 36, 107, 85, 106, 14])));
/// BT: GDBT22ZLZ3RU6CLRSS6MSUUKX2HDZX3E3YQSGGAYP4DRSXRG2YB2HACS
static immutable BT = KeyPair(PublicKey(Point([195, 61, 107, 43, 206, 227, 79, 9, 113, 148, 188, 201, 82, 138, 190, 142, 60, 223, 100, 222, 33, 35, 24, 24, 127, 7, 25, 94, 38, 214, 3, 163])), SecretKey(Scalar([4, 83, 61, 10, 5, 241, 134, 64, 255, 216, 32, 244, 248, 147, 112, 74, 75, 69, 105, 246, 159, 141, 240, 185, 32, 127, 146, 230, 5, 131, 136, 8])));
/// BU: GDBU22JF3IB6O22EJPOQ5EMJHT6CVRNZDV5N432Q5YIQQGSQ3Y5GFAWY
static immutable BU = KeyPair(PublicKey(Point([195, 77, 105, 37, 218, 3, 231, 107, 68, 75, 221, 14, 145, 137, 60, 252, 42, 197, 185, 29, 122, 222, 111, 80, 238, 17, 8, 26, 80, 222, 58, 98])), SecretKey(Scalar([155, 110, 244, 238, 242, 40, 56, 181, 187, 117, 223, 132, 154, 198, 204, 119, 226, 249, 18, 195, 127, 94, 60, 135, 107, 25, 191, 212, 151, 176, 66, 6])));
/// BV: GDBV22V4ACZ4GJ27LQCXHCRTUHIWTNLJRHXHXR7JMGZMOCQKMDVATYMF
static immutable BV = KeyPair(PublicKey(Point([195, 93, 106, 188, 0, 179, 195, 39, 95, 92, 5, 115, 138, 51, 161, 209, 105, 181, 105, 137, 238, 123, 199, 233, 97, 178, 199, 10, 10, 96, 234, 9])), SecretKey(Scalar([60, 166, 177, 182, 175, 120, 122, 55, 186, 109, 64, 73, 218, 211, 122, 229, 63, 156, 161, 10, 125, 115, 206, 28, 183, 40, 66, 189, 197, 105, 119, 6])));
/// BW: GDBW224IH2CQUPW74JZNUF3W5JWCPELUDWN25KEJWOHZP3GZQ54AETE5
static immutable BW = KeyPair(PublicKey(Point([195, 109, 107, 136, 62, 133, 10, 62, 223, 226, 114, 218, 23, 118, 234, 108, 39, 145, 116, 29, 155, 174, 168, 137, 179, 143, 151, 236, 217, 135, 120, 2])), SecretKey(Scalar([155, 117, 120, 175, 197, 35, 223, 161, 117, 14, 25, 165, 49, 41, 153, 52, 25, 18, 239, 128, 217, 101, 72, 205, 110, 11, 67, 169, 154, 53, 137, 10])));
/// BX: GDBX22CDYZWKDLZPSZJBXULDYUGGSJCJ6MDTBDH3M7ZEM7UQ4FCG7GS7
static immutable BX = KeyPair(PublicKey(Point([195, 125, 104, 67, 198, 108, 161, 175, 47, 150, 82, 27, 209, 99, 197, 12, 105, 36, 73, 243, 7, 48, 140, 251, 103, 242, 70, 126, 144, 225, 68, 111])), SecretKey(Scalar([238, 90, 27, 93, 133, 122, 140, 51, 95, 129, 6, 235, 231, 45, 191, 193, 173, 31, 59, 142, 177, 159, 172, 21, 73, 151, 158, 101, 26, 141, 248, 11])));
/// BY: GDBY22JSCQBXCZ33FWNNULOZHCRGO4NALG7D7335YA74YC3K3RSXRGEX
static immutable BY = KeyPair(PublicKey(Point([195, 141, 105, 50, 20, 3, 113, 103, 123, 45, 154, 218, 45, 217, 56, 162, 103, 113, 160, 89, 190, 63, 239, 125, 192, 63, 204, 11, 106, 220, 101, 120])), SecretKey(Scalar([190, 105, 202, 230, 211, 124, 45, 192, 140, 150, 167, 236, 54, 209, 230, 99, 172, 2, 131, 29, 85, 93, 104, 94, 244, 88, 17, 39, 255, 228, 0, 9])));
/// BZ: GDBZ22S2V4Z4M2MMKDEBLPR7BUMSV4GEDZGSNUJTXXVALDGW6OHGQ3I5
static immutable BZ = KeyPair(PublicKey(Point([195, 157, 106, 90, 175, 51, 198, 105, 140, 80, 200, 21, 190, 63, 13, 25, 42, 240, 196, 30, 77, 38, 209, 51, 189, 234, 5, 140, 214, 243, 142, 104])), SecretKey(Scalar([156, 29, 235, 216, 215, 253, 117, 168, 231, 139, 199, 27, 62, 201, 233, 116, 249, 40, 17, 198, 83, 54, 211, 21, 52, 137, 31, 216, 240, 84, 146, 9])));
/// CA: GDCA226R6BOJUYHPWTNJEC6Q3PHCRC6VV3VVEF52R5625DKEYKJ63QJX
static immutable CA = KeyPair(PublicKey(Point([196, 13, 107, 209, 240, 92, 154, 96, 239, 180, 218, 146, 11, 208, 219, 206, 40, 139, 213, 174, 235, 82, 23, 186, 143, 125, 174, 141, 68, 194, 147, 237])), SecretKey(Scalar([208, 118, 18, 178, 118, 230, 201, 60, 210, 198, 75, 176, 241, 89, 123, 25, 253, 192, 102, 33, 82, 218, 161, 72, 140, 121, 77, 138, 2, 214, 255, 13])));
/// CB: GDCB22NHYOCTVHBEGILGG2NNBAAMMZMPBND5H7YMQB6QHSNCFNXNJV7U
static immutable CB = KeyPair(PublicKey(Point([196, 29, 105, 167, 195, 133, 58, 156, 36, 50, 22, 99, 105, 173, 8, 0, 198, 101, 143, 11, 71, 211, 255, 12, 128, 125, 3, 201, 162, 43, 110, 212])), SecretKey(Scalar([92, 162, 59, 224, 133, 209, 19, 57, 14, 138, 203, 174, 247, 208, 55, 184, 204, 59, 9, 155, 219, 121, 145, 31, 244, 54, 154, 83, 172, 229, 185, 13])));
/// CC: GDCC22KSWMQFEZ5YCZ7X5MZPNOUTHDRTA2FZ7WX6UX5T7UXLSY4JIUAK
static immutable CC = KeyPair(PublicKey(Point([196, 45, 105, 82, 179, 32, 82, 103, 184, 22, 127, 126, 179, 47, 107, 169, 51, 142, 51, 6, 139, 159, 218, 254, 165, 251, 63, 210, 235, 150, 56, 148])), SecretKey(Scalar([219, 139, 180, 172, 85, 162, 180, 2, 98, 181, 8, 247, 163, 184, 81, 225, 155, 100, 160, 7, 168, 159, 92, 55, 237, 196, 29, 145, 131, 49, 143, 5])));
/// CD: GDCD22TH5KFVQUFIDHNQ5KFSBA5UIGNSE7ZAHAMTESDDLSFYXC6S7QLW
static immutable CD = KeyPair(PublicKey(Point([196, 61, 106, 103, 234, 139, 88, 80, 168, 25, 219, 14, 168, 178, 8, 59, 68, 25, 178, 39, 242, 3, 129, 147, 36, 134, 53, 200, 184, 184, 189, 47])), SecretKey(Scalar([217, 10, 49, 249, 240, 163, 155, 219, 129, 128, 39, 228, 83, 203, 140, 76, 55, 178, 77, 238, 43, 107, 66, 108, 98, 91, 30, 249, 79, 149, 222, 2])));
/// CE: GDCE225ZEKEDPT5CR65MYXEBZ375OOKVBI2SUUU4LMKNEIT6RD5UOLTU
static immutable CE = KeyPair(PublicKey(Point([196, 77, 107, 185, 34, 136, 55, 207, 162, 143, 186, 204, 92, 129, 206, 255, 215, 57, 85, 10, 53, 42, 82, 156, 91, 20, 210, 34, 126, 136, 251, 71])), SecretKey(Scalar([128, 20, 93, 84, 153, 15, 4, 54, 228, 161, 234, 201, 225, 42, 25, 183, 12, 236, 111, 6, 199, 86, 85, 229, 47, 81, 228, 210, 23, 30, 197, 3])));
/// CF: GDCF22YXZSBKBEAG77CZ37EQVUA4BB7JQUPHT3QE5QDYCPYTUMTEOWXV
static immutable CF = KeyPair(PublicKey(Point([196, 93, 107, 23, 204, 130, 160, 144, 6, 255, 197, 157, 252, 144, 173, 1, 192, 135, 233, 133, 30, 121, 238, 4, 236, 7, 129, 63, 19, 163, 38, 71])), SecretKey(Scalar([108, 84, 40, 69, 104, 222, 123, 220, 212, 76, 205, 46, 67, 238, 74, 106, 227, 71, 7, 32, 127, 241, 76, 167, 142, 121, 111, 193, 38, 159, 99, 14])));
/// CG: GDCG227O2PROL6BHYDBQF2S3FEOJQZ4FLTY44EL3G267AN5GR7LEGMVC
static immutable CG = KeyPair(PublicKey(Point([196, 109, 107, 238, 211, 226, 229, 248, 39, 192, 195, 2, 234, 91, 41, 28, 152, 103, 133, 92, 241, 206, 17, 123, 54, 189, 240, 55, 166, 143, 214, 67])), SecretKey(Scalar([20, 104, 220, 239, 202, 140, 176, 248, 106, 82, 121, 63, 85, 140, 134, 2, 201, 247, 187, 31, 227, 63, 61, 232, 89, 209, 228, 220, 18, 195, 196, 7])));
/// CH: GDCH22LTCWZZP7L67HNXL3GWT4JD3HIQ63XSAYO3HAUO4P4ILFPRW6BL
static immutable CH = KeyPair(PublicKey(Point([196, 125, 105, 115, 21, 179, 151, 253, 126, 249, 219, 117, 236, 214, 159, 18, 61, 157, 16, 246, 239, 32, 97, 219, 56, 40, 238, 63, 136, 89, 95, 27])), SecretKey(Scalar([133, 14, 18, 224, 59, 81, 36, 48, 35, 162, 195, 183, 176, 24, 111, 179, 40, 67, 231, 145, 65, 243, 218, 205, 86, 22, 30, 16, 103, 129, 152, 1])));
/// CI: GDCI22DXZYNWABHLVWUKTXEZZNLJCKSWE7SXSVUY4TMTTSITIR4MCAW4
static immutable CI = KeyPair(PublicKey(Point([196, 141, 104, 119, 206, 27, 96, 4, 235, 173, 168, 169, 220, 153, 203, 86, 145, 42, 86, 39, 229, 121, 86, 152, 228, 217, 57, 201, 19, 68, 120, 193])), SecretKey(Scalar([163, 65, 125, 110, 200, 141, 5, 92, 66, 59, 62, 228, 137, 90, 137, 179, 169, 35, 69, 206, 112, 224, 93, 252, 9, 89, 209, 40, 160, 71, 182, 0])));
/// CJ: GDCJ22BKGZN3OAT6BY2J2ITRGM7NOJBHP6CI547C7OEY434HDF62TN66
static immutable CJ = KeyPair(PublicKey(Point([196, 157, 104, 42, 54, 91, 183, 2, 126, 14, 52, 157, 34, 113, 51, 62, 215, 36, 39, 127, 132, 142, 243, 226, 251, 137, 142, 111, 135, 25, 125, 169])), SecretKey(Scalar([58, 18, 23, 85, 168, 76, 12, 16, 203, 158, 109, 41, 7, 138, 211, 19, 23, 47, 245, 72, 47, 91, 223, 240, 249, 209, 133, 240, 241, 165, 84, 2])));
/// CK: GDCK22ER3L7EANNRCORVZ2MNPU6EKYXWN4CGWNCFDAF3ILXLCM24PKVK
static immutable CK = KeyPair(PublicKey(Point([196, 173, 104, 145, 218, 254, 64, 53, 177, 19, 163, 92, 233, 141, 125, 60, 69, 98, 246, 111, 4, 107, 52, 69, 24, 11, 180, 46, 235, 19, 53, 199])), SecretKey(Scalar([249, 235, 207, 181, 64, 109, 0, 122, 149, 23, 130, 120, 182, 77, 170, 86, 10, 150, 108, 46, 199, 90, 16, 42, 16, 148, 239, 6, 208, 20, 74, 3])));
/// CL: GDCL22VHZ37TLK24VNF4TZ2BVVNVABWGWHI6XVCTQ5WWX7GSGBRQ56GH
static immutable CL = KeyPair(PublicKey(Point([196, 189, 106, 167, 206, 255, 53, 171, 92, 171, 75, 201, 231, 65, 173, 91, 80, 6, 198, 177, 209, 235, 212, 83, 135, 109, 107, 252, 210, 48, 99, 14])), SecretKey(Scalar([157, 30, 29, 30, 188, 74, 238, 227, 68, 53, 56, 116, 139, 157, 227, 16, 215, 239, 10, 209, 105, 9, 70, 139, 223, 190, 232, 122, 15, 202, 228, 8])));
/// CM: GDCM224S6P5LAPG2RGECOJTLV7UF2UU7ZLZGWXCIUDGAWCXQ6AIQNVFD
static immutable CM = KeyPair(PublicKey(Point([196, 205, 107, 146, 243, 250, 176, 60, 218, 137, 136, 39, 38, 107, 175, 232, 93, 82, 159, 202, 242, 107, 92, 72, 160, 204, 11, 10, 240, 240, 17, 6])), SecretKey(Scalar([63, 122, 123, 243, 161, 149, 190, 213, 88, 62, 244, 204, 82, 113, 60, 18, 130, 252, 249, 151, 191, 167, 241, 242, 197, 207, 160, 119, 87, 184, 236, 0])));
/// CN: GDCN22RDJJCWLV2FBXWUGTIJIWRIK2QYEKU4H7ZB5H23WLZ4MSOABY6P
static immutable CN = KeyPair(PublicKey(Point([196, 221, 106, 35, 74, 69, 101, 215, 69, 13, 237, 67, 77, 9, 69, 162, 133, 106, 24, 34, 169, 195, 255, 33, 233, 245, 187, 47, 60, 100, 156, 0])), SecretKey(Scalar([53, 82, 23, 31, 203, 140, 239, 102, 111, 25, 231, 210, 196, 19, 123, 56, 48, 57, 38, 248, 201, 49, 94, 197, 76, 81, 80, 49, 10, 212, 167, 2])));
/// CO: GDCO226DELI5C7EQLEGSU6DYUHZ4HPGSO5LNIINEJE6KR6THZJHA5XZP
static immutable CO = KeyPair(PublicKey(Point([196, 237, 107, 195, 34, 209, 209, 124, 144, 89, 13, 42, 120, 120, 161, 243, 195, 188, 210, 119, 86, 212, 33, 164, 73, 60, 168, 250, 103, 202, 78, 14])), SecretKey(Scalar([76, 51, 64, 58, 147, 136, 27, 12, 233, 114, 30, 65, 177, 233, 72, 152, 253, 62, 121, 167, 91, 12, 41, 62, 212, 223, 106, 11, 79, 172, 30, 4])));
/// CP: GDCP22CBNL6MY7RUNUPFJSZ7S36FNLUZCWDD4AP65UXR43XAKBGYPNPD
static immutable CP = KeyPair(PublicKey(Point([196, 253, 104, 65, 106, 252, 204, 126, 52, 109, 30, 84, 203, 63, 150, 252, 86, 174, 153, 21, 134, 62, 1, 254, 237, 47, 30, 110, 224, 80, 77, 135])), SecretKey(Scalar([161, 167, 66, 180, 109, 87, 82, 152, 214, 216, 79, 20, 192, 100, 148, 227, 20, 203, 101, 41, 171, 240, 24, 146, 27, 189, 81, 67, 82, 155, 69, 15])));
/// CQ: GDCQ22PCECWHSCGR455GB3XBRNMTQTGNOGSDDYUPMBNRTHJXREW2CDM2
static immutable CQ = KeyPair(PublicKey(Point([197, 13, 105, 226, 32, 172, 121, 8, 209, 231, 122, 96, 238, 225, 139, 89, 56, 76, 205, 113, 164, 49, 226, 143, 96, 91, 25, 157, 55, 137, 45, 161])), SecretKey(Scalar([94, 239, 157, 220, 88, 102, 195, 185, 49, 188, 243, 29, 101, 144, 238, 248, 160, 2, 48, 55, 65, 172, 217, 16, 7, 109, 44, 25, 74, 247, 226, 14])));
/// CR: GDCR2223YDT5VE7RLWZHQRN4PG6YJTV5RSRMKMTDBUNRS5CGZX2H3D6X
static immutable CR = KeyPair(PublicKey(Point([197, 29, 107, 91, 192, 231, 218, 147, 241, 93, 178, 120, 69, 188, 121, 189, 132, 206, 189, 140, 162, 197, 50, 99, 13, 27, 25, 116, 70, 205, 244, 125])), SecretKey(Scalar([45, 14, 12, 167, 132, 174, 45, 102, 112, 42, 131, 210, 202, 91, 163, 184, 98, 16, 20, 108, 244, 251, 137, 1, 99, 249, 100, 155, 183, 46, 181, 1])));
/// CS: GDCS22V33OI6X2I3V73MY4QG4CKD6NVCXOKHSWT4RVI2KMTUYUN5SGJ7
static immutable CS = KeyPair(PublicKey(Point([197, 45, 106, 187, 219, 145, 235, 233, 27, 175, 246, 204, 114, 6, 224, 148, 63, 54, 162, 187, 148, 121, 90, 124, 141, 81, 165, 50, 116, 197, 27, 217])), SecretKey(Scalar([4, 161, 202, 175, 83, 123, 88, 198, 7, 23, 220, 40, 190, 117, 54, 67, 11, 201, 142, 9, 11, 75, 18, 237, 110, 154, 28, 58, 130, 14, 144, 4])));
/// CT: GDCT22NFHH73MSVONTWMXJ6HCZ4XLWQT4LTSJOQOIXFAI7TLCFOHGKTA
static immutable CT = KeyPair(PublicKey(Point([197, 61, 105, 165, 57, 255, 182, 74, 174, 108, 236, 203, 167, 199, 22, 121, 117, 218, 19, 226, 231, 36, 186, 14, 69, 202, 4, 126, 107, 17, 92, 115])), SecretKey(Scalar([199, 198, 96, 100, 132, 25, 200, 90, 138, 68, 191, 129, 119, 190, 70, 77, 19, 115, 25, 65, 139, 48, 159, 109, 248, 197, 139, 25, 159, 161, 219, 7])));
/// CU: GDCU22LFJXO7B3KXFY3QC6R3QIG3ZNEN3NGF3KXRLQ3GGBMDBR3XXPGP
static immutable CU = KeyPair(PublicKey(Point([197, 77, 105, 101, 77, 221, 240, 237, 87, 46, 55, 1, 122, 59, 130, 13, 188, 180, 141, 219, 76, 93, 170, 241, 92, 54, 99, 5, 131, 12, 119, 123])), SecretKey(Scalar([99, 232, 111, 84, 5, 139, 209, 42, 146, 66, 225, 54, 149, 47, 86, 30, 103, 26, 145, 163, 133, 231, 177, 70, 236, 166, 237, 193, 64, 47, 82, 11])));
/// CV: GDCV22YBOCEFEIPRLRR52C6UX3YYULRYNCR4DTL7T7L66GVUPU62CLCA
static immutable CV = KeyPair(PublicKey(Point([197, 93, 107, 1, 112, 136, 82, 33, 241, 92, 99, 221, 11, 212, 190, 241, 138, 46, 56, 104, 163, 193, 205, 127, 159, 215, 239, 26, 180, 125, 61, 161])), SecretKey(Scalar([243, 168, 29, 104, 171, 150, 9, 189, 16, 207, 156, 118, 212, 33, 251, 19, 51, 24, 78, 202, 84, 134, 141, 136, 243, 237, 20, 38, 11, 199, 142, 1])));
/// CW: GDCW22TJZMMEYLWDHEFLSGYKZBRPZFZS62AMKKV2GQJAHARK7FURMEU7
static immutable CW = KeyPair(PublicKey(Point([197, 109, 106, 105, 203, 24, 76, 46, 195, 57, 10, 185, 27, 10, 200, 98, 252, 151, 50, 246, 128, 197, 42, 186, 52, 18, 3, 130, 42, 249, 105, 22])), SecretKey(Scalar([153, 202, 78, 209, 115, 154, 97, 62, 169, 82, 174, 184, 111, 146, 196, 88, 3, 17, 180, 26, 190, 137, 42, 226, 94, 164, 158, 201, 195, 58, 200, 7])));
/// CX: GDCX22PZIU5P5SG5BJPY4UZ5L5SY5SHLLDSZ7VKIBMCHQVV7EBAZT667
static immutable CX = KeyPair(PublicKey(Point([197, 125, 105, 249, 69, 58, 254, 200, 221, 10, 95, 142, 83, 61, 95, 101, 142, 200, 235, 88, 229, 159, 213, 72, 11, 4, 120, 86, 191, 32, 65, 153])), SecretKey(Scalar([73, 200, 0, 71, 147, 125, 242, 56, 180, 122, 132, 137, 239, 48, 181, 47, 177, 29, 154, 216, 252, 106, 72, 170, 87, 25, 55, 183, 201, 155, 36, 14])));
/// CY: GDCY222WDBYWERFZTYT25DYXQRNQTSVIQGQDKKNLNOW2XDZYPBWXJ67X
static immutable CY = KeyPair(PublicKey(Point([197, 141, 107, 86, 24, 113, 98, 68, 185, 158, 39, 174, 143, 23, 132, 91, 9, 202, 168, 129, 160, 53, 41, 171, 107, 173, 171, 143, 56, 120, 109, 116])), SecretKey(Scalar([146, 238, 196, 205, 241, 3, 26, 52, 177, 160, 7, 100, 124, 247, 96, 64, 220, 11, 248, 75, 72, 230, 6, 189, 30, 183, 86, 243, 54, 57, 46, 10])));
/// CZ: GDCZ22CK2B2RGEEUUBJ2GHWWEUPVBLGJZRYNH66M3UILM37QGPHS5A5B
static immutable CZ = KeyPair(PublicKey(Point([197, 157, 104, 74, 208, 117, 19, 16, 148, 160, 83, 163, 30, 214, 37, 31, 80, 172, 201, 204, 112, 211, 251, 204, 221, 16, 182, 111, 240, 51, 207, 46])), SecretKey(Scalar([11, 113, 105, 219, 170, 39, 209, 28, 63, 20, 192, 151, 244, 243, 17, 28, 92, 128, 9, 147, 159, 244, 74, 113, 253, 37, 232, 180, 116, 30, 223, 6])));
/// DA: GDDA22Z2YAXVBWVMTQD77GDDUVZKQYDUFKPSDUAHO7NMKYCK3KWCBYS7
static immutable DA = KeyPair(PublicKey(Point([198, 13, 107, 58, 192, 47, 80, 218, 172, 156, 7, 255, 152, 99, 165, 114, 168, 96, 116, 42, 159, 33, 208, 7, 119, 218, 197, 96, 74, 218, 172, 32])), SecretKey(Scalar([112, 2, 66, 250, 219, 237, 53, 139, 33, 20, 38, 221, 71, 221, 196, 155, 8, 66, 215, 23, 182, 248, 253, 157, 202, 201, 160, 230, 50, 194, 140, 4])));
/// DB: GDDB22BXJCGHL7MDT5OSH2AT5LGXQSY2B3B2WU3NV73JCGNUOBOXGUHV
static immutable DB = KeyPair(PublicKey(Point([198, 29, 104, 55, 72, 140, 117, 253, 131, 159, 93, 35, 232, 19, 234, 205, 120, 75, 26, 14, 195, 171, 83, 109, 175, 246, 145, 25, 180, 112, 93, 115])), SecretKey(Scalar([251, 174, 228, 108, 8, 236, 106, 184, 246, 27, 55, 114, 225, 226, 137, 119, 137, 27, 243, 23, 30, 24, 252, 201, 178, 107, 219, 208, 1, 32, 11, 4])));
/// DC: GDDC22WTCGELM5WEUYMZU2VCKGCCTKUSL7BJPAYVOXKCKGTULTCQVGMI
static immutable DC = KeyPair(PublicKey(Point([198, 45, 106, 211, 17, 136, 182, 118, 196, 166, 25, 154, 106, 162, 81, 132, 41, 170, 146, 95, 194, 151, 131, 21, 117, 212, 37, 26, 116, 92, 197, 10])), SecretKey(Scalar([112, 19, 59, 177, 142, 118, 140, 232, 93, 203, 71, 163, 165, 8, 23, 102, 137, 54, 166, 184, 146, 56, 184, 2, 145, 120, 104, 182, 92, 241, 116, 15])));
/// DD: GDDD22JUT32HEXVO3JA4TGMY7SNGR3X3FYNQGDKZ5UCEUQMLBFUVVONP
static immutable DD = KeyPair(PublicKey(Point([198, 61, 105, 52, 158, 244, 114, 94, 174, 218, 65, 201, 153, 152, 252, 154, 104, 238, 251, 46, 27, 3, 13, 89, 237, 4, 74, 65, 139, 9, 105, 90])), SecretKey(Scalar([83, 6, 204, 148, 101, 89, 152, 231, 178, 52, 138, 65, 50, 157, 82, 51, 155, 9, 159, 36, 124, 179, 26, 49, 174, 35, 201, 10, 9, 188, 163, 0])));
/// DE: GDDE22HJ4M6NGKYKSAT5L5MMDV74KD4ZW4YACEIEOXR7XXIVNCWUOIHV
static immutable DE = KeyPair(PublicKey(Point([198, 77, 104, 233, 227, 60, 211, 43, 10, 144, 39, 213, 245, 140, 29, 127, 197, 15, 153, 183, 48, 1, 17, 4, 117, 227, 251, 221, 21, 104, 173, 71])), SecretKey(Scalar([251, 75, 70, 50, 5, 175, 99, 61, 49, 95, 70, 75, 68, 92, 197, 37, 130, 117, 189, 188, 160, 144, 236, 133, 155, 79, 207, 219, 43, 82, 102, 13])));
/// DF: GDDF22QZ5ZR22KGEOAGRLYT2GE5CIZUPQZOZYCFCN6OHK2GAIJWD2W6J
static immutable DF = KeyPair(PublicKey(Point([198, 93, 106, 25, 238, 99, 173, 40, 196, 112, 13, 21, 226, 122, 49, 58, 36, 102, 143, 134, 93, 156, 8, 162, 111, 156, 117, 104, 192, 66, 108, 61])), SecretKey(Scalar([210, 22, 186, 187, 227, 171, 95, 30, 143, 118, 117, 208, 134, 156, 38, 173, 60, 145, 232, 66, 231, 100, 209, 235, 80, 238, 161, 249, 199, 139, 163, 14])));
/// DG: GDDG222YNCYZEZRAVEH62W4C55G6OI5DBHAYQ64ITU525U7YEUCTFE6W
static immutable DG = KeyPair(PublicKey(Point([198, 109, 107, 88, 104, 177, 146, 102, 32, 169, 15, 237, 91, 130, 239, 77, 231, 35, 163, 9, 193, 136, 123, 136, 157, 59, 174, 211, 248, 37, 5, 50])), SecretKey(Scalar([248, 238, 211, 4, 79, 214, 151, 15, 161, 166, 4, 173, 154, 143, 242, 219, 191, 155, 12, 100, 95, 170, 113, 39, 101, 166, 148, 169, 96, 165, 121, 1])));
/// DH: GDDH22WDKWYMUUJRGBLL23II5BLLTYGWX4Z5CZRT4R2K6OKBY47CDYAM
static immutable DH = KeyPair(PublicKey(Point([198, 125, 106, 195, 85, 176, 202, 81, 49, 48, 86, 189, 109, 8, 232, 86, 185, 224, 214, 191, 51, 209, 102, 51, 228, 116, 175, 57, 65, 199, 62, 33])), SecretKey(Scalar([134, 133, 57, 177, 238, 228, 185, 85, 209, 144, 133, 56, 245, 204, 96, 104, 154, 97, 161, 177, 87, 125, 32, 219, 207, 204, 113, 145, 92, 115, 52, 12])));
/// DI: GDDI22X3S6I5J3AUZ4ZZBRUOGLSKSFLGGKAQXS66EETQLFSUMUZH2DZD
static immutable DI = KeyPair(PublicKey(Point([198, 141, 106, 251, 151, 145, 212, 236, 20, 207, 51, 144, 198, 142, 50, 228, 169, 21, 102, 50, 129, 11, 203, 222, 33, 39, 5, 150, 84, 101, 50, 125])), SecretKey(Scalar([31, 251, 240, 152, 23, 134, 95, 182, 127, 135, 89, 129, 84, 50, 151, 82, 33, 81, 218, 90, 248, 47, 102, 239, 214, 95, 238, 122, 213, 17, 38, 9])));
/// DJ: GDDJ222CIWHFH5SRRTFEKRZZUJL7RZBKJBP3BHNL6Z63LDG3LTHJFPJR
static immutable DJ = KeyPair(PublicKey(Point([198, 157, 107, 66, 69, 142, 83, 246, 81, 140, 202, 69, 71, 57, 162, 87, 248, 228, 42, 72, 95, 176, 157, 171, 246, 125, 181, 140, 219, 92, 206, 146])), SecretKey(Scalar([117, 142, 143, 227, 124, 110, 193, 156, 62, 239, 161, 36, 163, 54, 14, 82, 92, 178, 62, 183, 67, 216, 155, 41, 19, 24, 11, 239, 9, 162, 5, 2])));
/// DK: GDDK227IWOQR3QPEMN7MELPYJIFI3DCO4ZMMXK6KH65LW36RN36XPYYB
static immutable DK = KeyPair(PublicKey(Point([198, 173, 107, 232, 179, 161, 29, 193, 228, 99, 126, 194, 45, 248, 74, 10, 141, 140, 78, 230, 88, 203, 171, 202, 63, 186, 187, 111, 209, 110, 253, 119])), SecretKey(Scalar([196, 167, 159, 103, 183, 37, 190, 229, 165, 34, 129, 24, 246, 44, 141, 120, 4, 187, 19, 63, 85, 94, 29, 60, 18, 72, 11, 8, 92, 138, 55, 9])));
/// DL: GDDL22J3R2FVBAJK22LQ4EVRY65CGMRMNS4FGQDA75RFJNGW2YZKCDOR
static immutable DL = KeyPair(PublicKey(Point([198, 189, 105, 59, 142, 139, 80, 129, 42, 214, 151, 14, 18, 177, 199, 186, 35, 50, 44, 108, 184, 83, 64, 96, 255, 98, 84, 180, 214, 214, 50, 161])), SecretKey(Scalar([68, 35, 156, 47, 47, 22, 218, 33, 210, 240, 64, 101, 22, 152, 185, 147, 177, 91, 136, 156, 185, 102, 205, 211, 151, 91, 102, 5, 16, 96, 28, 5])));
/// DM: GDDM22QLGEUT3NGR2IRHTBG7B6I5IMOTM2DC7GKGULEZUP4VOD7C6P3W
static immutable DM = KeyPair(PublicKey(Point([198, 205, 106, 11, 49, 41, 61, 180, 209, 210, 34, 121, 132, 223, 15, 145, 212, 49, 211, 102, 134, 47, 153, 70, 162, 201, 154, 63, 149, 112, 254, 47])), SecretKey(Scalar([229, 154, 195, 148, 19, 180, 84, 51, 94, 63, 243, 139, 83, 129, 232, 248, 165, 241, 235, 84, 19, 114, 134, 167, 242, 101, 68, 143, 53, 218, 210, 10])));
/// DN: GDDN22ED26RGXO6Q46I3PAXSRUASV5ZJ33W5M3NNBDY4ERIIK65IQTE4
static immutable DN = KeyPair(PublicKey(Point([198, 221, 104, 131, 215, 162, 107, 187, 208, 231, 145, 183, 130, 242, 141, 1, 42, 247, 41, 222, 237, 214, 109, 173, 8, 241, 194, 69, 8, 87, 186, 136])), SecretKey(Scalar([212, 110, 106, 166, 47, 50, 31, 88, 24, 141, 220, 158, 91, 42, 93, 65, 109, 31, 28, 115, 34, 214, 21, 182, 133, 1, 182, 215, 167, 14, 131, 8])));
/// DO: GDDO22ISEKKGSKJ7SQQD3KSGAFOVPOEPD4RFTV25CDWH6ZCP3UH4UACF
static immutable DO = KeyPair(PublicKey(Point([198, 237, 105, 18, 34, 148, 105, 41, 63, 148, 32, 61, 170, 70, 1, 93, 87, 184, 143, 31, 34, 89, 215, 93, 16, 236, 127, 100, 79, 221, 15, 202])), SecretKey(Scalar([209, 105, 193, 159, 141, 46, 244, 52, 176, 68, 23, 34, 208, 54, 22, 102, 66, 76, 68, 168, 22, 46, 131, 137, 155, 194, 92, 47, 112, 85, 185, 14])));
/// DP: GDDP22WRKELJWU2BXFYSVCLAVUXGXMEEOXHJCJOTPRAZJMCNJAECYKIW
static immutable DP = KeyPair(PublicKey(Point([198, 253, 106, 209, 81, 22, 155, 83, 65, 185, 113, 42, 137, 96, 173, 46, 107, 176, 132, 117, 206, 145, 37, 211, 124, 65, 148, 176, 77, 72, 8, 44])), SecretKey(Scalar([66, 40, 61, 206, 34, 16, 145, 32, 182, 134, 120, 149, 17, 133, 182, 139, 168, 4, 159, 217, 47, 68, 11, 41, 7, 57, 199, 132, 14, 128, 94, 0])));
/// DQ: GDDQ223RSNQP2RSA6WG2JB3KRWCD7K5UQ2LKWQVYVT3MESTGDF32XEWH
static immutable DQ = KeyPair(PublicKey(Point([199, 13, 107, 113, 147, 96, 253, 70, 64, 245, 141, 164, 135, 106, 141, 132, 63, 171, 180, 134, 150, 171, 66, 184, 172, 246, 194, 74, 102, 25, 119, 171])), SecretKey(Scalar([17, 18, 10, 225, 103, 169, 40, 235, 223, 127, 20, 78, 100, 246, 122, 98, 37, 218, 34, 232, 70, 42, 139, 10, 158, 228, 132, 151, 175, 245, 120, 14])));
/// DR: GDDR224QWUU4CWIJPUYOQDG5MQN4T466IHR7FWZIC5G2SUY22GBQUL7X
static immutable DR = KeyPair(PublicKey(Point([199, 29, 107, 144, 181, 41, 193, 89, 9, 125, 48, 232, 12, 221, 100, 27, 201, 243, 222, 65, 227, 242, 219, 40, 23, 77, 169, 83, 26, 209, 131, 10])), SecretKey(Scalar([211, 137, 53, 25, 102, 82, 158, 214, 163, 76, 79, 61, 149, 163, 150, 190, 16, 164, 231, 194, 223, 240, 118, 175, 134, 121, 136, 27, 78, 195, 83, 7])));
/// DS: GDDS223KPKODQCT2YJ2M6D4S5NTCVGUMZSMK3GRV6H6TDAU4TCBZOFSW
static immutable DS = KeyPair(PublicKey(Point([199, 45, 107, 106, 122, 156, 56, 10, 122, 194, 116, 207, 15, 146, 235, 102, 42, 154, 140, 204, 152, 173, 154, 53, 241, 253, 49, 130, 156, 152, 131, 151])), SecretKey(Scalar([33, 237, 166, 193, 43, 188, 23, 53, 153, 153, 43, 97, 103, 217, 220, 54, 141, 85, 199, 153, 169, 157, 175, 59, 24, 237, 58, 142, 181, 220, 151, 6])));
/// DT: GDDT22MLIUEEEVDCQ7ESW67N5FCT72AJYDDD2AJXVXFQQIXZSD4SIPU6
static immutable DT = KeyPair(PublicKey(Point([199, 61, 105, 139, 69, 8, 66, 84, 98, 135, 201, 43, 123, 237, 233, 69, 63, 232, 9, 192, 198, 61, 1, 55, 173, 203, 8, 34, 249, 144, 249, 36])), SecretKey(Scalar([146, 52, 181, 250, 247, 240, 148, 217, 69, 234, 80, 239, 103, 248, 157, 98, 180, 58, 197, 205, 54, 43, 12, 112, 158, 25, 220, 245, 101, 119, 98, 10])));
/// DU: GDDU22M6M6L3KM3WUJ4EO53HYVKRK5W5CJAKNGATIB3GJ4W6YZFXLDPV
static immutable DU = KeyPair(PublicKey(Point([199, 77, 105, 158, 103, 151, 181, 51, 118, 162, 120, 71, 119, 103, 197, 85, 21, 118, 221, 18, 64, 166, 152, 19, 64, 118, 100, 242, 222, 198, 75, 117])), SecretKey(Scalar([38, 104, 37, 111, 43, 154, 2, 154, 243, 105, 196, 15, 191, 125, 43, 162, 60, 156, 88, 115, 108, 240, 81, 100, 178, 156, 180, 30, 197, 83, 93, 15])));
/// DV: GDDV224UKVFMJENBKQCMXWJG7PWZAVFI4GRYEL4HXI34ELTZ6VI2KGKF
static immutable DV = KeyPair(PublicKey(Point([199, 93, 107, 148, 85, 74, 196, 145, 161, 84, 4, 203, 217, 38, 251, 237, 144, 84, 168, 225, 163, 130, 47, 135, 186, 55, 194, 46, 121, 245, 81, 165])), SecretKey(Scalar([41, 124, 249, 61, 101, 30, 209, 217, 132, 22, 231, 0, 14, 224, 108, 220, 130, 123, 134, 160, 81, 18, 229, 17, 93, 151, 128, 190, 96, 23, 57, 7])));
/// DW: GDDW22EPSQP4FO5C7HZ7QQDBWLLENMAZHLXACWGVP73TXETO7JLCQW7E
static immutable DW = KeyPair(PublicKey(Point([199, 109, 104, 143, 148, 31, 194, 187, 162, 249, 243, 248, 64, 97, 178, 214, 70, 176, 25, 58, 238, 1, 88, 213, 127, 247, 59, 146, 110, 250, 86, 40])), SecretKey(Scalar([108, 237, 103, 109, 250, 238, 243, 121, 194, 172, 100, 33, 151, 114, 231, 166, 62, 126, 199, 176, 82, 193, 172, 151, 130, 206, 227, 238, 138, 250, 253, 10])));
/// DX: GDDX22TOARTPZBXW3KEQH4SOKYWKNFANUXNZODUJE2R2MVKS5TFACE7Q
static immutable DX = KeyPair(PublicKey(Point([199, 125, 106, 110, 4, 102, 252, 134, 246, 218, 137, 3, 242, 78, 86, 44, 166, 148, 13, 165, 219, 151, 14, 137, 38, 163, 166, 85, 82, 236, 202, 1])), SecretKey(Scalar([80, 187, 96, 65, 6, 239, 86, 122, 2, 95, 243, 192, 34, 86, 15, 48, 37, 123, 213, 179, 220, 226, 104, 82, 133, 183, 79, 118, 186, 253, 229, 13])));
/// DY: GDDY225YFX3Y7Z6ZOEBJ6BXDVMYNVLFUWJAKYGQ6GLSIWKMQGERYMF72
static immutable DY = KeyPair(PublicKey(Point([199, 141, 107, 184, 45, 247, 143, 231, 217, 113, 2, 159, 6, 227, 171, 48, 218, 172, 180, 178, 64, 172, 26, 30, 50, 228, 139, 41, 144, 49, 35, 134])), SecretKey(Scalar([234, 164, 72, 125, 156, 72, 166, 212, 11, 42, 200, 136, 133, 199, 118, 63, 248, 22, 157, 239, 82, 94, 143, 159, 164, 164, 196, 4, 67, 250, 254, 15])));
/// DZ: GDDZ22RAHG3KEGRBPHJEH3OWNPS4MTI36SY2E2OHNWWRKREKGA7NVMNF
static immutable DZ = KeyPair(PublicKey(Point([199, 157, 106, 32, 57, 182, 162, 26, 33, 121, 210, 67, 237, 214, 107, 229, 198, 77, 27, 244, 177, 162, 105, 199, 109, 173, 21, 68, 138, 48, 62, 218])), SecretKey(Scalar([79, 18, 168, 86, 184, 188, 101, 136, 142, 213, 222, 129, 70, 148, 68, 38, 49, 122, 99, 36, 147, 168, 59, 194, 3, 146, 13, 130, 138, 156, 17, 14])));
/// EA: GDEA2236PCEZEBMDYXQPNSQF6WWEJOLIVJHWZSMCGDWHEZSJ626JHPSG
static immutable EA = KeyPair(PublicKey(Point([200, 13, 107, 126, 120, 137, 146, 5, 131, 197, 224, 246, 202, 5, 245, 172, 68, 185, 104, 170, 79, 108, 201, 130, 48, 236, 114, 102, 73, 246, 188, 147])), SecretKey(Scalar([33, 23, 168, 21, 79, 107, 248, 194, 135, 43, 189, 223, 116, 80, 97, 145, 86, 57, 175, 151, 83, 38, 144, 193, 65, 148, 208, 39, 70, 139, 14, 5])));
/// EB: GDEB22FZEC6KOOTH5QQANENWDVACMC2TF2RLI5Q7ZOORZBEBOHBTSNQ3
static immutable EB = KeyPair(PublicKey(Point([200, 29, 104, 185, 32, 188, 167, 58, 103, 236, 32, 6, 145, 182, 29, 64, 38, 11, 83, 46, 162, 180, 118, 31, 203, 157, 28, 132, 129, 113, 195, 57])), SecretKey(Scalar([136, 128, 248, 126, 61, 74, 120, 181, 39, 227, 229, 15, 183, 213, 222, 184, 188, 146, 138, 139, 142, 253, 71, 66, 104, 35, 38, 117, 117, 62, 114, 6])));
/// EC: GDEC22XOTR3MCNTJQ6K4URBUMRLVPLTYMIRZVNCY4FSQLJIIGSX2VGVZ
static immutable EC = KeyPair(PublicKey(Point([200, 45, 106, 238, 156, 118, 193, 54, 105, 135, 149, 202, 68, 52, 100, 87, 87, 174, 120, 98, 35, 154, 180, 88, 225, 101, 5, 165, 8, 52, 175, 170])), SecretKey(Scalar([70, 208, 196, 155, 145, 64, 192, 234, 30, 115, 123, 140, 106, 40, 244, 147, 34, 51, 105, 7, 158, 18, 235, 166, 57, 239, 209, 252, 59, 232, 253, 15])));
/// ED: GDED22MIVBF4HR66ZTRUB4Q4CUSRJAUBKYIUOVEI2GLA5474VKH3AJ5P
static immutable ED = KeyPair(PublicKey(Point([200, 61, 105, 136, 168, 75, 195, 199, 222, 204, 227, 64, 242, 28, 21, 37, 20, 130, 129, 86, 17, 71, 84, 136, 209, 150, 14, 243, 252, 170, 143, 176])), SecretKey(Scalar([219, 151, 2, 144, 63, 215, 115, 65, 197, 108, 221, 183, 17, 167, 11, 31, 106, 37, 128, 237, 129, 218, 214, 220, 122, 226, 161, 34, 156, 188, 245, 6])));
/// EE: GDEE227SMJVY63P5UX2TYVMEJSQ22P7GWT3OY7VIP74HP5PG7PECSDUD
static immutable EE = KeyPair(PublicKey(Point([200, 77, 107, 242, 98, 107, 143, 109, 253, 165, 245, 60, 85, 132, 76, 161, 173, 63, 230, 180, 246, 236, 126, 168, 127, 248, 119, 245, 230, 251, 200, 41])), SecretKey(Scalar([55, 100, 15, 115, 14, 183, 42, 131, 48, 199, 140, 46, 12, 1, 13, 2, 172, 144, 194, 153, 151, 155, 115, 95, 227, 76, 148, 160, 79, 243, 102, 7])));
/// EF: GDEF22BU2DJ4KRDRQDOZBQV7N37BN75VXMOP6NUQR46BQF5EEGER73GH
static immutable EF = KeyPair(PublicKey(Point([200, 93, 104, 52, 208, 211, 197, 68, 113, 128, 221, 144, 194, 191, 110, 254, 22, 255, 181, 187, 28, 255, 54, 144, 143, 60, 24, 23, 164, 33, 137, 31])), SecretKey(Scalar([146, 95, 149, 104, 44, 79, 70, 165, 12, 17, 63, 51, 31, 208, 169, 12, 210, 98, 218, 159, 156, 57, 101, 164, 88, 57, 86, 84, 113, 56, 49, 6])));
/// EG: GDEG22TUL6WLXY6YSZJ34SZY3I6FDEDJNXQRN45CFAICH7AXZAZTYQFW
static immutable EG = KeyPair(PublicKey(Point([200, 109, 106, 116, 95, 172, 187, 227, 216, 150, 83, 190, 75, 56, 218, 60, 81, 144, 105, 109, 225, 22, 243, 162, 40, 16, 35, 252, 23, 200, 51, 60])), SecretKey(Scalar([204, 86, 165, 254, 54, 90, 200, 149, 92, 227, 163, 84, 157, 134, 251, 141, 58, 37, 187, 213, 136, 0, 152, 102, 253, 135, 217, 107, 177, 51, 56, 2])));
/// EH: GDEH22ZCQJMLYE5L26JPA3RZFB7DHV75YBMT3ZHTAZXXLYPRALDMKHNI
static immutable EH = KeyPair(PublicKey(Point([200, 125, 107, 34, 130, 88, 188, 19, 171, 215, 146, 240, 110, 57, 40, 126, 51, 215, 253, 192, 89, 61, 228, 243, 6, 111, 117, 225, 241, 2, 198, 197])), SecretKey(Scalar([35, 153, 125, 250, 77, 147, 133, 123, 0, 215, 94, 1, 204, 12, 37, 83, 25, 106, 69, 58, 118, 97, 241, 45, 146, 83, 47, 90, 91, 142, 72, 4])));
/// EI: GDEI227VNQKCGLIE3H5YH2CYWYMBST6436J554UQ5AVJLAAZZ3ODVVZX
static immutable EI = KeyPair(PublicKey(Point([200, 141, 107, 245, 108, 20, 35, 45, 4, 217, 251, 131, 232, 88, 182, 24, 25, 79, 220, 223, 147, 222, 242, 144, 232, 42, 149, 128, 25, 206, 220, 58])), SecretKey(Scalar([27, 61, 40, 222, 15, 67, 60, 223, 128, 160, 134, 4, 40, 248, 6, 17, 32, 31, 168, 147, 209, 215, 150, 78, 226, 209, 212, 238, 213, 77, 255, 10])));
/// EJ: GDEJ22CGF7IUZMCEFKR6LJONWBAYTGRIYB7WHYN5NPXUE265AD753VIO
static immutable EJ = KeyPair(PublicKey(Point([200, 157, 104, 70, 47, 209, 76, 176, 68, 42, 163, 229, 165, 205, 176, 65, 137, 154, 40, 192, 127, 99, 225, 189, 107, 239, 66, 107, 221, 0, 255, 221])), SecretKey(Scalar([215, 127, 167, 198, 91, 56, 85, 145, 39, 142, 3, 200, 97, 107, 117, 85, 33, 121, 67, 182, 93, 177, 90, 196, 230, 38, 206, 246, 8, 58, 63, 12])));
/// EK: GDEK22PU6T222E5O5FNMNYJ7QLDJNM75ZIXYDVBUD6IPGDC6YFEL4YOJ
static immutable EK = KeyPair(PublicKey(Point([200, 173, 105, 244, 244, 245, 173, 19, 174, 233, 90, 198, 225, 63, 130, 198, 150, 179, 253, 202, 47, 129, 212, 52, 31, 144, 243, 12, 94, 193, 72, 190])), SecretKey(Scalar([3, 25, 43, 51, 45, 160, 37, 253, 131, 17, 121, 251, 33, 180, 121, 186, 253, 57, 158, 203, 133, 7, 41, 232, 140, 85, 30, 241, 44, 22, 187, 9])));
/// EL: GDEL22ZMUAAYMDA3FMOMJJUP5N6TLNMEYQC2ZA6AD4BDAQF67VJFJ57H
static immutable EL = KeyPair(PublicKey(Point([200, 189, 107, 44, 160, 1, 134, 12, 27, 43, 28, 196, 166, 143, 235, 125, 53, 181, 132, 196, 5, 172, 131, 192, 31, 2, 48, 64, 190, 253, 82, 84])), SecretKey(Scalar([115, 123, 253, 151, 19, 105, 121, 32, 208, 67, 204, 220, 90, 37, 173, 70, 252, 144, 153, 110, 173, 152, 124, 118, 231, 235, 115, 189, 203, 81, 83, 15])));
/// EM: GDEM22SPPAHLLF3FSRG3ZJEDCVDNXZI77XUEW7DCFEJ5UVW5FBJNNJR7
static immutable EM = KeyPair(PublicKey(Point([200, 205, 106, 79, 120, 14, 181, 151, 101, 148, 77, 188, 164, 131, 21, 70, 219, 229, 31, 253, 232, 75, 124, 98, 41, 19, 218, 86, 221, 40, 82, 214])), SecretKey(Scalar([242, 228, 38, 32, 253, 20, 28, 139, 245, 106, 195, 85, 173, 229, 43, 172, 27, 85, 173, 32, 243, 85, 51, 57, 170, 41, 135, 221, 235, 240, 201, 9])));
/// EN: GDEN22QQHJX2FMFA6EOAQDUM2DTEKHNR64FVAAGL5OQLIRBQ7K2AZZCK
static immutable EN = KeyPair(PublicKey(Point([200, 221, 106, 16, 58, 111, 162, 176, 160, 241, 28, 8, 14, 140, 208, 230, 69, 29, 177, 247, 11, 80, 0, 203, 235, 160, 180, 68, 48, 250, 180, 12])), SecretKey(Scalar([61, 65, 80, 103, 169, 117, 243, 222, 11, 85, 199, 37, 109, 63, 139, 198, 67, 248, 64, 16, 179, 167, 216, 22, 92, 174, 85, 222, 79, 96, 20, 12])));
/// EO: GDEO22J3MMI4BR5H3P2XTDHAIS2OGDJJI66MPBW3KPTAUAUACGKINGBX
static immutable EO = KeyPair(PublicKey(Point([200, 237, 105, 59, 99, 17, 192, 199, 167, 219, 245, 121, 140, 224, 68, 180, 227, 13, 41, 71, 188, 199, 134, 219, 83, 230, 10, 2, 128, 17, 148, 134])), SecretKey(Scalar([130, 117, 131, 87, 107, 67, 88, 114, 222, 179, 47, 149, 4, 106, 255, 52, 178, 85, 104, 69, 11, 70, 190, 237, 144, 132, 249, 54, 162, 17, 21, 14])));
/// EP: GDEP22PTJDO2NI4C72GYIPDNHMQUTWGJORLXXCUJORJYYRCAZQUFGWTL
static immutable EP = KeyPair(PublicKey(Point([200, 253, 105, 243, 72, 221, 166, 163, 130, 254, 141, 132, 60, 109, 59, 33, 73, 216, 201, 116, 87, 123, 138, 137, 116, 83, 140, 68, 64, 204, 40, 83])), SecretKey(Scalar([92, 41, 242, 108, 226, 145, 180, 144, 76, 90, 167, 51, 80, 88, 158, 163, 223, 133, 204, 68, 148, 73, 216, 17, 152, 205, 37, 238, 12, 231, 236, 1])));
/// EQ: GDEQ22QQJ4VGP2F5SXFIE46IU6DQLRDCOJ4P6IU2D6BFJNSIM66LT3SV
static immutable EQ = KeyPair(PublicKey(Point([201, 13, 106, 16, 79, 42, 103, 232, 189, 149, 202, 130, 115, 200, 167, 135, 5, 196, 98, 114, 120, 255, 34, 154, 31, 130, 84, 182, 72, 103, 188, 185])), SecretKey(Scalar([124, 84, 143, 221, 123, 22, 230, 31, 172, 224, 41, 45, 186, 25, 215, 138, 93, 77, 100, 128, 33, 225, 2, 112, 22, 115, 126, 6, 171, 192, 146, 7])));
/// ER: GDER225J42AZIFRLC7D2C7OGCGJF3JQCVK6QVFY6CVOJO5OJNG5HKR2D
static immutable ER = KeyPair(PublicKey(Point([201, 29, 107, 169, 230, 129, 148, 22, 43, 23, 199, 161, 125, 198, 17, 146, 93, 166, 2, 170, 189, 10, 151, 30, 21, 92, 151, 117, 201, 105, 186, 117])), SecretKey(Scalar([90, 76, 164, 251, 161, 87, 242, 243, 231, 145, 87, 76, 176, 183, 56, 193, 28, 39, 99, 40, 41, 57, 171, 176, 29, 18, 43, 195, 60, 26, 186, 14])));
/// ES: GDES22QMNKZUCBDYOIGAQTVYNT6PFC5C5D6DTAXDQPMQWKZ73D36UU5L
static immutable ES = KeyPair(PublicKey(Point([201, 45, 106, 12, 106, 179, 65, 4, 120, 114, 12, 8, 78, 184, 108, 252, 242, 139, 162, 232, 252, 57, 130, 227, 131, 217, 11, 43, 63, 216, 247, 234])), SecretKey(Scalar([139, 49, 223, 183, 209, 26, 230, 129, 252, 85, 52, 69, 38, 142, 194, 112, 39, 242, 101, 36, 3, 232, 35, 161, 56, 154, 234, 33, 6, 159, 49, 11])));
/// ET: GDET22FUV4EETOS4IZSANGPFWXBEDSJ3F7TUMW64O4RF7DOVAOP52WOJ
static immutable ET = KeyPair(PublicKey(Point([201, 61, 104, 180, 175, 8, 73, 186, 92, 70, 100, 6, 153, 229, 181, 194, 65, 201, 59, 47, 231, 70, 91, 220, 119, 34, 95, 141, 213, 3, 159, 221])), SecretKey(Scalar([81, 181, 183, 186, 179, 10, 168, 197, 47, 102, 98, 113, 71, 49, 148, 235, 197, 39, 175, 213, 72, 72, 127, 65, 13, 134, 64, 146, 61, 92, 98, 0])));
/// EU: GDEU22CUZ6KMO7A6GZROEXRSSS3A3H4IMQHF6FU4ZGXV5H55UVGZW32T
static immutable EU = KeyPair(PublicKey(Point([201, 77, 104, 84, 207, 148, 199, 124, 30, 54, 98, 226, 94, 50, 148, 182, 13, 159, 136, 100, 14, 95, 22, 156, 201, 175, 94, 159, 189, 165, 77, 155])), SecretKey(Scalar([139, 31, 177, 13, 55, 118, 61, 41, 161, 17, 102, 21, 126, 82, 233, 227, 123, 120, 162, 171, 134, 127, 237, 213, 134, 143, 137, 91, 53, 87, 176, 10])));
/// EV: GDEV22XP4BKK4PIO5JS7P6Q4ACMGDEAVRVOPROMLPOHBB7IYXPQ7DDCY
static immutable EV = KeyPair(PublicKey(Point([201, 93, 106, 239, 224, 84, 174, 61, 14, 234, 101, 247, 250, 28, 0, 152, 97, 144, 21, 141, 92, 248, 185, 139, 123, 142, 16, 253, 24, 187, 225, 241])), SecretKey(Scalar([90, 56, 53, 29, 23, 114, 78, 232, 199, 112, 22, 52, 92, 65, 205, 207, 61, 142, 116, 118, 145, 172, 154, 227, 158, 122, 194, 203, 101, 159, 233, 0])));
/// EW: GDEW22JYCU2TIQVLNIMTRDJMIODG63HCEANZ7CJ6H7XDA6SSPHFLJOYK
static immutable EW = KeyPair(PublicKey(Point([201, 109, 105, 56, 21, 53, 52, 66, 171, 106, 25, 56, 141, 44, 67, 134, 111, 108, 226, 32, 27, 159, 137, 62, 63, 238, 48, 122, 82, 121, 202, 180])), SecretKey(Scalar([27, 120, 75, 204, 26, 254, 139, 57, 150, 228, 202, 227, 147, 31, 33, 205, 57, 12, 78, 138, 89, 83, 103, 179, 160, 42, 138, 227, 60, 60, 61, 15])));
/// EX: GDEX22ZZUFSDRGPSLVCLEYNJIJ5C62ERBRQ6BGZF3FTRDDSAK2CBZJJ5
static immutable EX = KeyPair(PublicKey(Point([201, 125, 107, 57, 161, 100, 56, 153, 242, 93, 68, 178, 97, 169, 66, 122, 47, 104, 145, 12, 97, 224, 155, 37, 217, 103, 17, 142, 64, 86, 132, 28])), SecretKey(Scalar([94, 190, 42, 135, 238, 223, 142, 68, 155, 228, 132, 140, 170, 40, 44, 24, 110, 212, 6, 226, 86, 126, 169, 215, 120, 209, 93, 244, 191, 89, 108, 7])));
/// EY: GDEY22AUAS74ABAIEHTUHAGUPFTPKYRHPQH5MEGUDK22R26JOHNETKYU
static immutable EY = KeyPair(PublicKey(Point([201, 141, 104, 20, 4, 191, 192, 4, 8, 33, 231, 67, 128, 212, 121, 102, 245, 98, 39, 124, 15, 214, 16, 212, 26, 181, 168, 235, 201, 113, 218, 73])), SecretKey(Scalar([108, 11, 115, 228, 116, 226, 192, 4, 20, 93, 102, 69, 90, 60, 129, 27, 160, 115, 116, 22, 187, 73, 240, 218, 187, 29, 104, 72, 78, 65, 16, 0])));
/// EZ: GDEZ22BFNIOTDK2L5IQ3KYJ6VR2ERD444SF26KMA5ZLFJMIDQZMXUXEF
static immutable EZ = KeyPair(PublicKey(Point([201, 157, 104, 37, 106, 29, 49, 171, 75, 234, 33, 181, 97, 62, 172, 116, 72, 143, 156, 228, 139, 175, 41, 128, 238, 86, 84, 177, 3, 134, 89, 122])), SecretKey(Scalar([78, 23, 137, 162, 112, 70, 136, 62, 178, 254, 147, 105, 136, 89, 155, 124, 166, 87, 115, 2, 195, 216, 83, 244, 33, 194, 67, 195, 144, 211, 78, 11])));
/// FA: GDFA22QBRD3ATXJM4HKRP7HFQK24HQJKGROGFRLKCUXCEH57SKHY3C3L
static immutable FA = KeyPair(PublicKey(Point([202, 13, 106, 1, 136, 246, 9, 221, 44, 225, 213, 23, 252, 229, 130, 181, 195, 193, 42, 52, 92, 98, 197, 106, 21, 46, 34, 31, 191, 146, 143, 141])), SecretKey(Scalar([43, 205, 94, 36, 111, 182, 145, 49, 50, 125, 161, 138, 228, 186, 12, 199, 161, 14, 145, 74, 21, 44, 114, 42, 237, 39, 57, 200, 179, 150, 6, 12])));
/// FB: GDFB223WWGF7ZBULKHM3XXFVNEI7DYYKOBLCEUNZHHZOR7SMACPCYFKO
static immutable FB = KeyPair(PublicKey(Point([202, 29, 107, 118, 177, 139, 252, 134, 139, 81, 217, 187, 220, 181, 105, 17, 241, 227, 10, 112, 86, 34, 81, 185, 57, 242, 232, 254, 76, 0, 158, 44])), SecretKey(Scalar([32, 193, 87, 34, 2, 143, 138, 171, 183, 57, 55, 76, 31, 178, 135, 134, 139, 43, 47, 202, 228, 202, 61, 54, 157, 86, 80, 54, 215, 170, 241, 11])));
/// FC: GDFC22DVVU73NVWAKTBOXOTIKZGAGKVSIZRHAKOF4VHLKBGIWF56ANTU
static immutable FC = KeyPair(PublicKey(Point([202, 45, 104, 117, 173, 63, 182, 214, 192, 84, 194, 235, 186, 104, 86, 76, 3, 42, 178, 70, 98, 112, 41, 197, 229, 78, 181, 4, 200, 177, 123, 224])), SecretKey(Scalar([35, 221, 12, 33, 38, 81, 13, 162, 241, 22, 55, 133, 37, 10, 205, 239, 16, 35, 67, 136, 156, 50, 222, 131, 113, 197, 120, 40, 43, 182, 48, 15])));
/// FD: GDFD22YGNC5BAQNK2ZOWOCUA2UDT2B72KRVP32G4AA7ANMOKOMLBK2Z3
static immutable FD = KeyPair(PublicKey(Point([202, 61, 107, 6, 104, 186, 16, 65, 170, 214, 93, 103, 10, 128, 213, 7, 61, 7, 250, 84, 106, 253, 232, 220, 0, 62, 6, 177, 202, 115, 22, 21])), SecretKey(Scalar([16, 153, 104, 12, 80, 132, 72, 68, 197, 189, 163, 172, 97, 67, 206, 66, 59, 225, 250, 35, 88, 242, 55, 77, 35, 89, 194, 6, 108, 70, 188, 3])));
/// FE: GDFE22EEQPU6B4RLF46JL26AR6DOBJEAGAJKV2BNI5R5QIJMVM3RSV5J
static immutable FE = KeyPair(PublicKey(Point([202, 77, 104, 132, 131, 233, 224, 242, 43, 47, 60, 149, 235, 192, 143, 134, 224, 164, 128, 48, 18, 170, 232, 45, 71, 99, 216, 33, 44, 171, 55, 25])), SecretKey(Scalar([62, 10, 182, 240, 65, 148, 45, 185, 191, 111, 118, 150, 11, 230, 48, 38, 240, 247, 60, 119, 243, 24, 163, 173, 170, 146, 129, 160, 144, 173, 49, 8])));
/// FF: GDFF22RG7LORBP7J7JIIMZZXQR7SG6TUEY7B6IRUNALSLW2H52GNYYAI
static immutable FF = KeyPair(PublicKey(Point([202, 93, 106, 38, 250, 221, 16, 191, 233, 250, 80, 134, 103, 55, 132, 127, 35, 122, 116, 38, 62, 31, 34, 52, 104, 23, 37, 219, 71, 238, 140, 220])), SecretKey(Scalar([246, 226, 206, 166, 206, 28, 196, 235, 72, 58, 80, 236, 36, 224, 218, 36, 182, 30, 100, 244, 50, 111, 65, 219, 104, 124, 225, 241, 110, 247, 22, 3])));
/// FG: GDFG22KTONX2ZZ46V4NLRK4QO6MZO6XTLD3W2JP4OAEQ54N36LA4T7T2
static immutable FG = KeyPair(PublicKey(Point([202, 109, 105, 83, 115, 111, 172, 231, 158, 175, 26, 184, 171, 144, 119, 153, 151, 122, 243, 88, 247, 109, 37, 252, 112, 9, 14, 241, 187, 242, 193, 201])), SecretKey(Scalar([5, 205, 134, 104, 98, 201, 11, 18, 10, 168, 87, 232, 154, 8, 8, 14, 125, 91, 102, 137, 10, 231, 121, 26, 192, 20, 229, 159, 20, 150, 254, 5])));
/// FH: GDFH22QJPN6Z7FCG4ALQVPUEWLDEHBDW6EPTF4BXVPRBRWT5EF5TGRDW
static immutable FH = KeyPair(PublicKey(Point([202, 125, 106, 9, 123, 125, 159, 148, 70, 224, 23, 10, 190, 132, 178, 198, 67, 132, 118, 241, 31, 50, 240, 55, 171, 226, 24, 218, 125, 33, 123, 51])), SecretKey(Scalar([220, 23, 224, 191, 41, 51, 154, 70, 230, 31, 18, 53, 120, 143, 115, 31, 31, 251, 130, 93, 9, 44, 155, 92, 40, 9, 62, 75, 185, 175, 183, 8])));
/// FI: GDFI22JCJDDGSHYXIJAIFIGDFUCRSTSCC3QCC7S2W3EBJ3H4PCCYRAVO
static immutable FI = KeyPair(PublicKey(Point([202, 141, 105, 34, 72, 198, 105, 31, 23, 66, 64, 130, 160, 195, 45, 5, 25, 78, 66, 22, 224, 33, 126, 90, 182, 200, 20, 236, 252, 120, 133, 136])), SecretKey(Scalar([69, 126, 224, 88, 117, 104, 250, 222, 240, 193, 219, 86, 55, 42, 158, 175, 174, 91, 110, 197, 212, 78, 224, 136, 108, 164, 92, 106, 239, 230, 109, 14])));
/// FJ: GDFJ22OQS4RZZ3VVXLN7FKQBTDLC7HZNQCUVMLFOUW7RRPD5FGOXF736
static immutable FJ = KeyPair(PublicKey(Point([202, 157, 105, 208, 151, 35, 156, 238, 181, 186, 219, 242, 170, 1, 152, 214, 47, 159, 45, 128, 169, 86, 44, 174, 165, 191, 24, 188, 125, 41, 157, 114])), SecretKey(Scalar([108, 188, 176, 190, 25, 177, 200, 132, 127, 64, 127, 4, 57, 171, 76, 190, 31, 64, 100, 124, 249, 154, 55, 117, 228, 178, 36, 116, 175, 140, 71, 8])));
/// FK: GDFK227SPUIAWN4YQ33IYG3FFKQZUOWOR6I37VOASLYTPVHAR4MN6MGY
static immutable FK = KeyPair(PublicKey(Point([202, 173, 107, 242, 125, 16, 11, 55, 152, 134, 246, 140, 27, 101, 42, 161, 154, 58, 206, 143, 145, 191, 213, 192, 146, 241, 55, 212, 224, 143, 24, 223])), SecretKey(Scalar([109, 105, 98, 44, 102, 67, 215, 132, 21, 98, 231, 113, 105, 148, 184, 141, 250, 203, 237, 236, 28, 93, 134, 47, 19, 239, 218, 224, 143, 202, 25, 14])));
/// FL: GDFL22F66YX5XJ4STOPSCHDVQ745XSA2GCN4BBXU65WRWDG2Q5227JBK
static immutable FL = KeyPair(PublicKey(Point([202, 189, 104, 190, 246, 47, 219, 167, 146, 155, 159, 33, 28, 117, 135, 249, 219, 200, 26, 48, 155, 192, 134, 244, 247, 109, 27, 12, 218, 135, 117, 175])), SecretKey(Scalar([148, 163, 98, 254, 82, 26, 6, 192, 175, 100, 182, 241, 187, 233, 95, 199, 170, 219, 100, 244, 241, 206, 167, 25, 219, 15, 93, 209, 215, 219, 108, 8])));
/// FM: GDFM22EQBCTFL6VLDLIAXHFJSUQR575SP2CKLWXVKYYVOOCX373LNXL6
static immutable FM = KeyPair(PublicKey(Point([202, 205, 104, 144, 8, 166, 85, 250, 171, 26, 208, 11, 156, 169, 149, 33, 30, 255, 178, 126, 132, 165, 218, 245, 86, 49, 87, 56, 87, 223, 246, 182])), SecretKey(Scalar([216, 39, 23, 13, 27, 123, 196, 109, 113, 187, 66, 44, 252, 159, 2, 71, 224, 252, 21, 232, 161, 133, 27, 197, 184, 2, 32, 107, 119, 121, 43, 3])));
/// FN: GDFN22B3W5UO4ZQRFCH6XUM37AV4BQKHIY5E67DDXZLWR6ANMEPQYX5A
static immutable FN = KeyPair(PublicKey(Point([202, 221, 104, 59, 183, 104, 238, 102, 17, 40, 143, 235, 209, 155, 248, 43, 192, 193, 71, 70, 58, 79, 124, 99, 190, 87, 104, 248, 13, 97, 31, 12])), SecretKey(Scalar([12, 6, 164, 12, 221, 1, 210, 253, 65, 67, 251, 102, 164, 45, 179, 44, 23, 233, 28, 207, 135, 98, 221, 198, 156, 141, 162, 242, 95, 23, 186, 7])));
/// FO: GDFO22ZWT7SX5WWGIIQLXV6Y6SPEJDWP2NXVMHEDN63JVQDZQ3K2GSOR
static immutable FO = KeyPair(PublicKey(Point([202, 237, 107, 54, 159, 229, 126, 218, 198, 66, 32, 187, 215, 216, 244, 158, 68, 142, 207, 211, 111, 86, 28, 131, 111, 182, 154, 192, 121, 134, 213, 163])), SecretKey(Scalar([60, 191, 12, 222, 8, 152, 108, 88, 23, 252, 31, 202, 220, 114, 126, 98, 137, 85, 4, 243, 55, 43, 247, 116, 72, 30, 255, 183, 91, 33, 64, 11])));
/// FP: GDFP22R4G35TU4XEO53QVJWLDRFR6GPHQJUZPPHC4CWLLPUKCX5HQJUR
static immutable FP = KeyPair(PublicKey(Point([202, 253, 106, 60, 54, 251, 58, 114, 228, 119, 119, 10, 166, 203, 28, 75, 31, 25, 231, 130, 105, 151, 188, 226, 224, 172, 181, 190, 138, 21, 250, 120])), SecretKey(Scalar([201, 60, 136, 181, 155, 232, 218, 129, 181, 105, 197, 120, 167, 13, 129, 29, 190, 105, 204, 57, 80, 100, 218, 240, 28, 194, 47, 128, 168, 175, 171, 5])));
/// FQ: GDFQ22IM7TSPZFZJBE4NHMOMOQZ2ZB77QA3PNSNTV7VEO5JNXFM562ED
static immutable FQ = KeyPair(PublicKey(Point([203, 13, 105, 12, 252, 228, 252, 151, 41, 9, 56, 211, 177, 204, 116, 51, 172, 135, 255, 128, 54, 246, 201, 179, 175, 234, 71, 117, 45, 185, 89, 223])), SecretKey(Scalar([91, 199, 191, 163, 224, 63, 43, 240, 170, 81, 249, 105, 170, 230, 103, 126, 95, 161, 16, 131, 130, 119, 174, 202, 0, 146, 25, 111, 197, 251, 150, 6])));
/// FR: GDFR22KEYGSVW2NOSI5PZHVEVJXQEWYKGEJH3BLMD5GVRFIKAHIFO7DI
static immutable FR = KeyPair(PublicKey(Point([203, 29, 105, 68, 193, 165, 91, 105, 174, 146, 58, 252, 158, 164, 170, 111, 2, 91, 10, 49, 18, 125, 133, 108, 31, 77, 88, 149, 10, 1, 208, 87])), SecretKey(Scalar([73, 86, 20, 251, 141, 182, 209, 253, 176, 70, 19, 69, 181, 214, 210, 32, 162, 187, 171, 91, 239, 32, 208, 204, 193, 99, 94, 17, 217, 148, 109, 8])));
/// FS: GDFS22LQPXSY2F2BLN2JKJ22N54QCE2LIIXUARLTITUORCQN42Y5XKKC
static immutable FS = KeyPair(PublicKey(Point([203, 45, 105, 112, 125, 229, 141, 23, 65, 91, 116, 149, 39, 90, 111, 121, 1, 19, 75, 66, 47, 64, 69, 115, 68, 232, 232, 138, 13, 230, 177, 219])), SecretKey(Scalar([160, 178, 235, 18, 155, 52, 62, 248, 91, 198, 2, 41, 161, 36, 8, 37, 46, 151, 6, 79, 222, 2, 3, 190, 199, 100, 227, 51, 61, 137, 219, 5])));
/// FT: GDFT22OIN3LYE4WTAQZA6WAINGVKO25X6MIFV7QEYCJCTGW7BYIWFJEV
static immutable FT = KeyPair(PublicKey(Point([203, 61, 105, 200, 110, 215, 130, 114, 211, 4, 50, 15, 88, 8, 105, 170, 167, 107, 183, 243, 16, 90, 254, 4, 192, 146, 41, 154, 223, 14, 17, 98])), SecretKey(Scalar([213, 249, 237, 243, 111, 29, 151, 134, 62, 25, 149, 90, 167, 120, 37, 48, 42, 153, 231, 204, 8, 84, 25, 147, 187, 9, 67, 35, 249, 23, 103, 15])));
/// FU: GDFU22MPMZ6TZXLH7BBTPZC5EDLU6P2AEBBX6D3CNPKS56QS3US2DDSV
static immutable FU = KeyPair(PublicKey(Point([203, 77, 105, 143, 102, 125, 60, 221, 103, 248, 67, 55, 228, 93, 32, 215, 79, 63, 64, 32, 67, 127, 15, 98, 107, 213, 46, 250, 18, 221, 37, 161])), SecretKey(Scalar([244, 115, 236, 36, 66, 113, 231, 203, 52, 154, 111, 77, 55, 90, 1, 5, 135, 176, 52, 201, 17, 173, 85, 243, 61, 40, 105, 225, 216, 152, 234, 7])));
/// FV: GDFV22GNFZTCRV6O6G7VM74DADXCA6GXFZFSXENBZEYKGX5MEWXPICBB
static immutable FV = KeyPair(PublicKey(Point([203, 93, 104, 205, 46, 102, 40, 215, 206, 241, 191, 86, 127, 131, 0, 238, 32, 120, 215, 46, 75, 43, 145, 161, 201, 48, 163, 95, 172, 37, 174, 244])), SecretKey(Scalar([80, 103, 9, 156, 181, 7, 138, 220, 193, 182, 215, 218, 174, 56, 139, 142, 12, 206, 198, 155, 114, 230, 72, 105, 169, 64, 21, 65, 1, 246, 108, 6])));
/// FW: GDFW22U24FFLC3VEDH4N4YQR4CGNLP2M3QOIM53XX7H3HTFVVL7WUCGA
static immutable FW = KeyPair(PublicKey(Point([203, 109, 106, 154, 225, 74, 177, 110, 164, 25, 248, 222, 98, 17, 224, 140, 213, 191, 76, 220, 28, 134, 119, 119, 191, 207, 179, 204, 181, 170, 255, 106])), SecretKey(Scalar([103, 36, 160, 144, 23, 169, 16, 159, 208, 76, 87, 213, 197, 67, 135, 38, 63, 185, 172, 99, 30, 25, 218, 173, 239, 128, 36, 229, 74, 76, 28, 8])));
/// FX: GDFX226GQM7QEWLZIWSSJKHNEI624W64LUDLEJS2S55YRS2YCJ4LUVE4
static immutable FX = KeyPair(PublicKey(Point([203, 125, 107, 198, 131, 63, 2, 89, 121, 69, 165, 36, 168, 237, 34, 61, 174, 91, 220, 93, 6, 178, 38, 90, 151, 123, 136, 203, 88, 18, 120, 186])), SecretKey(Scalar([144, 87, 217, 7, 192, 62, 105, 158, 191, 87, 253, 232, 206, 154, 148, 101, 105, 54, 246, 18, 98, 60, 69, 156, 231, 236, 121, 88, 248, 183, 49, 10])));
/// FY: GDFY22NSY6DVGVKFFOVTMZX526JWNECPYO2V7NSDMGZB53J7O7HCG7FL
static immutable FY = KeyPair(PublicKey(Point([203, 141, 105, 178, 199, 135, 83, 85, 69, 43, 171, 54, 102, 253, 215, 147, 102, 144, 79, 195, 181, 95, 182, 67, 97, 178, 30, 237, 63, 119, 206, 35])), SecretKey(Scalar([211, 212, 27, 109, 255, 122, 159, 97, 170, 30, 107, 135, 173, 153, 37, 237, 157, 76, 42, 176, 4, 237, 135, 247, 59, 56, 44, 217, 182, 127, 149, 7])));
/// FZ: GDFZ22PK2MTE3UH67MVTZ5VJ4HMWC6YS5IBXRTFOHZ2UAXCX3YT6MWXA
static immutable FZ = KeyPair(PublicKey(Point([203, 157, 105, 234, 211, 38, 77, 208, 254, 251, 43, 60, 246, 169, 225, 217, 97, 123, 18, 234, 3, 120, 204, 174, 62, 117, 64, 92, 87, 222, 39, 230])), SecretKey(Scalar([7, 234, 104, 108, 51, 49, 43, 99, 201, 160, 47, 162, 150, 159, 176, 171, 76, 160, 182, 232, 1, 23, 76, 184, 18, 202, 185, 235, 44, 33, 84, 5])));
/// GA: GDGA22WANZQLSEXLOTUG36GJFREUTWQNFW6KVLNDGYM7LYFAN3LY7NMX
static immutable GA = KeyPair(PublicKey(Point([204, 13, 106, 192, 110, 96, 185, 18, 235, 116, 232, 109, 248, 201, 44, 73, 73, 218, 13, 45, 188, 170, 173, 163, 54, 25, 245, 224, 160, 110, 215, 143])), SecretKey(Scalar([28, 218, 86, 224, 168, 50, 21, 18, 62, 227, 25, 193, 57, 210, 123, 11, 238, 44, 176, 120, 137, 108, 130, 23, 181, 54, 76, 114, 233, 206, 50, 5])));
/// GB: GDGB22RHLTNSFJRVOBOKIKGEHF5ZNM75GQM6ZJSBBZGN2ADLXPMPSQT7
static immutable GB = KeyPair(PublicKey(Point([204, 29, 106, 39, 92, 219, 34, 166, 53, 112, 92, 164, 40, 196, 57, 123, 150, 179, 253, 52, 25, 236, 166, 65, 14, 76, 221, 0, 107, 187, 216, 249])), SecretKey(Scalar([203, 42, 138, 159, 207, 168, 240, 26, 219, 143, 96, 15, 250, 231, 175, 115, 244, 163, 174, 220, 116, 183, 142, 222, 242, 169, 112, 79, 244, 92, 216, 4])));
/// GC: GDGC225GKML3GB5J7LNFIACWHUQOK5BHOLG5W3MMXQSIOQ44XCEYR3DT
static immutable GC = KeyPair(PublicKey(Point([204, 45, 107, 166, 83, 23, 179, 7, 169, 250, 218, 84, 0, 86, 61, 32, 229, 116, 39, 114, 205, 219, 109, 140, 188, 36, 135, 67, 156, 184, 137, 136])), SecretKey(Scalar([147, 33, 176, 87, 232, 143, 249, 214, 99, 226, 22, 15, 55, 96, 130, 65, 172, 41, 35, 120, 114, 79, 213, 214, 78, 0, 6, 172, 106, 17, 239, 10])));
/// GD: GDGD22JLY7RHQZUA36XMGA6BXLQI537LQIT3P2QT5CIH2WTRBMPUMGPM
static immutable GD = KeyPair(PublicKey(Point([204, 61, 105, 43, 199, 226, 120, 102, 128, 223, 174, 195, 3, 193, 186, 224, 142, 239, 235, 130, 39, 183, 234, 19, 232, 144, 125, 90, 113, 11, 31, 70])), SecretKey(Scalar([251, 128, 90, 121, 235, 71, 25, 190, 185, 19, 25, 54, 47, 62, 85, 236, 37, 251, 170, 129, 119, 201, 26, 240, 197, 1, 36, 85, 79, 9, 228, 2])));
/// GE: GDGE22E2UDJGDJBX4N6ILWBHDLADPUGQKSNDU4JZC2JI2OGCG7L5URIN
static immutable GE = KeyPair(PublicKey(Point([204, 77, 104, 154, 160, 210, 97, 164, 55, 227, 124, 133, 216, 39, 26, 192, 55, 208, 208, 84, 154, 58, 113, 57, 22, 146, 141, 56, 194, 55, 215, 218])), SecretKey(Scalar([2, 45, 250, 33, 142, 201, 168, 42, 119, 240, 114, 239, 152, 254, 21, 46, 45, 224, 243, 115, 99, 67, 100, 125, 135, 200, 38, 85, 246, 5, 23, 11])));
/// GF: GDGF22BTBJHA4E2CO5GKDWIHTK3OSAT7PS327OYHIYR7A7UEGBP6U6UL
static immutable GF = KeyPair(PublicKey(Point([204, 93, 104, 51, 10, 78, 14, 19, 66, 119, 76, 161, 217, 7, 154, 182, 233, 2, 127, 124, 183, 175, 187, 7, 70, 35, 240, 126, 132, 48, 95, 234])), SecretKey(Scalar([85, 162, 155, 219, 218, 234, 78, 253, 36, 25, 89, 228, 140, 39, 132, 127, 36, 204, 174, 116, 102, 34, 84, 22, 124, 110, 99, 82, 221, 228, 116, 9])));
/// GG: GDGG226GL7VVM5S7UZATD53XDNYAQUHW2CZSRDUIOJSCANWGC3OTU3KM
static immutable GG = KeyPair(PublicKey(Point([204, 109, 107, 198, 95, 235, 86, 118, 95, 166, 65, 49, 247, 119, 27, 112, 8, 80, 246, 208, 179, 40, 142, 136, 114, 100, 32, 54, 198, 22, 221, 58])), SecretKey(Scalar([197, 42, 130, 204, 62, 98, 55, 2, 254, 178, 39, 131, 137, 171, 99, 254, 107, 76, 206, 82, 39, 207, 18, 180, 251, 94, 192, 29, 5, 66, 239, 15])));
/// GH: GDGH22UTXU7NXNSGZGIWGC7WXQG3TPOXM2AJR37TGGIHX7IXWMWNM3BB
static immutable GH = KeyPair(PublicKey(Point([204, 125, 106, 147, 189, 62, 219, 182, 70, 201, 145, 99, 11, 246, 188, 13, 185, 189, 215, 102, 128, 152, 239, 243, 49, 144, 123, 253, 23, 179, 44, 214])), SecretKey(Scalar([200, 240, 119, 24, 252, 75, 132, 109, 12, 8, 43, 255, 210, 49, 108, 16, 218, 254, 20, 182, 212, 69, 84, 10, 124, 203, 182, 226, 52, 192, 238, 3])));
/// GI: GDGI22KVWEGCCUPEIZABLPTF672PSSYEH2HXPLTMR3ZZCPNPXJIGSRFC
static immutable GI = KeyPair(PublicKey(Point([204, 141, 105, 85, 177, 12, 33, 81, 228, 70, 64, 21, 190, 101, 247, 244, 249, 75, 4, 62, 143, 119, 174, 108, 142, 243, 145, 61, 175, 186, 80, 105])), SecretKey(Scalar([73, 134, 144, 200, 64, 11, 160, 196, 137, 146, 160, 98, 35, 251, 193, 92, 106, 204, 106, 167, 174, 60, 230, 196, 254, 32, 111, 232, 143, 142, 168, 9])));
/// GJ: GDGJ22QONNCQNQM7UDSIDFSZMA4QNARDYZLU3YCIYJOID473TVE42VUX
static immutable GJ = KeyPair(PublicKey(Point([204, 157, 106, 14, 107, 69, 6, 193, 159, 160, 228, 129, 150, 89, 96, 57, 6, 130, 35, 198, 87, 77, 224, 72, 194, 92, 129, 243, 251, 157, 73, 205])), SecretKey(Scalar([169, 97, 2, 60, 67, 203, 248, 116, 89, 60, 132, 217, 154, 96, 130, 174, 208, 58, 25, 55, 5, 164, 228, 190, 125, 87, 72, 158, 137, 77, 242, 6])));
/// GK: GDGK22HC2PMYSY7FAABQ4ONOXGCVAXFG3BOFVHC6TF3HFJS7HO3QYKRT
static immutable GK = KeyPair(PublicKey(Point([204, 173, 104, 226, 211, 217, 137, 99, 229, 0, 3, 14, 57, 174, 185, 133, 80, 92, 166, 216, 92, 90, 156, 94, 153, 118, 114, 166, 95, 59, 183, 12])), SecretKey(Scalar([64, 48, 219, 184, 134, 214, 249, 209, 54, 243, 155, 190, 151, 96, 238, 207, 107, 155, 136, 72, 147, 120, 147, 163, 16, 44, 51, 146, 162, 28, 133, 15])));
/// GL: GDGL22W6OQO4BUXFUXJF64D4SIVY5WND7K44QDYAIVCRAH3AWTFLKNDC
static immutable GL = KeyPair(PublicKey(Point([204, 189, 106, 222, 116, 29, 192, 210, 229, 165, 210, 95, 112, 124, 146, 43, 142, 217, 163, 250, 185, 200, 15, 0, 69, 69, 16, 31, 96, 180, 202, 181])), SecretKey(Scalar([24, 221, 196, 115, 165, 59, 123, 39, 109, 187, 156, 100, 192, 43, 15, 162, 172, 55, 170, 147, 11, 41, 32, 185, 141, 67, 241, 217, 12, 147, 20, 7])));
/// GM: GDGM22DHLJFRF275MPG7G3SRP4NFRIZGPDQRHRYQLFYQPW7UOSYW3UXM
static immutable GM = KeyPair(PublicKey(Point([204, 205, 104, 103, 90, 75, 18, 235, 253, 99, 205, 243, 110, 81, 127, 26, 88, 163, 38, 120, 225, 19, 199, 16, 89, 113, 7, 219, 244, 116, 177, 109])), SecretKey(Scalar([133, 176, 45, 152, 1, 217, 88, 126, 112, 145, 240, 201, 30, 10, 208, 204, 140, 58, 230, 187, 60, 23, 56, 182, 6, 120, 158, 201, 222, 221, 241, 6])));
/// GN: GDGN22TZ7EZNW2FI5B24UKDEX26RTZU43KVH2H6TD4BN65SILB2R7VQH
static immutable GN = KeyPair(PublicKey(Point([204, 221, 106, 121, 249, 50, 219, 104, 168, 232, 117, 202, 40, 100, 190, 189, 25, 230, 156, 218, 170, 125, 31, 211, 31, 2, 223, 118, 72, 88, 117, 31])), SecretKey(Scalar([0, 104, 119, 148, 118, 164, 244, 19, 207, 23, 105, 149, 68, 73, 225, 55, 115, 204, 28, 117, 253, 134, 181, 121, 65, 217, 207, 216, 202, 166, 170, 8])));
/// GO: GDGO22XXOD2XNODESGKFO4LLH3M22WNCCFNWD5UUZ2KAMQBU65WQDQT7
static immutable GO = KeyPair(PublicKey(Point([204, 237, 106, 247, 112, 245, 118, 184, 100, 145, 148, 87, 113, 107, 62, 217, 173, 89, 162, 17, 91, 97, 246, 148, 206, 148, 6, 64, 52, 247, 109, 1])), SecretKey(Scalar([197, 150, 160, 59, 29, 47, 196, 76, 123, 38, 89, 133, 221, 253, 242, 212, 216, 209, 53, 144, 203, 85, 100, 5, 198, 103, 93, 135, 40, 39, 193, 1])));
/// GP: GDGP22Q7O2IX4G2KJ3IUJIUW6YWS6FTZALKN3FOZ3IMCK7RE3XZFSUIL
static immutable GP = KeyPair(PublicKey(Point([204, 253, 106, 31, 118, 145, 126, 27, 74, 78, 209, 68, 162, 150, 246, 45, 47, 22, 121, 2, 212, 221, 149, 217, 218, 24, 37, 126, 36, 221, 242, 89])), SecretKey(Scalar([214, 203, 196, 181, 53, 181, 72, 149, 30, 58, 213, 115, 148, 151, 11, 44, 212, 30, 124, 201, 6, 185, 39, 224, 131, 89, 105, 14, 248, 82, 190, 9])));
/// GQ: GDGQ22MMT4CKR2N7XFYBOLBL3NSESNOSQF25BOCIDYG6EGPSJBB6B3MX
static immutable GQ = KeyPair(PublicKey(Point([205, 13, 105, 140, 159, 4, 168, 233, 191, 185, 112, 23, 44, 43, 219, 100, 73, 53, 210, 129, 117, 208, 184, 72, 30, 13, 226, 25, 242, 72, 67, 224])), SecretKey(Scalar([37, 248, 241, 5, 150, 122, 142, 99, 234, 184, 232, 47, 15, 66, 234, 162, 247, 219, 141, 227, 152, 45, 201, 233, 31, 44, 7, 163, 9, 123, 199, 7])));
/// GR: GDGR22D5Z2MMCFNU2RUGO7FOWRMR234SEEBJDSSFPVSB432Z5CIYH34T
static immutable GR = KeyPair(PublicKey(Point([205, 29, 104, 125, 206, 152, 193, 21, 180, 212, 104, 103, 124, 174, 180, 89, 29, 111, 146, 33, 2, 145, 202, 69, 125, 100, 30, 111, 89, 232, 145, 131])), SecretKey(Scalar([131, 251, 223, 108, 176, 159, 43, 41, 253, 30, 189, 247, 114, 169, 68, 55, 7, 197, 241, 182, 155, 78, 115, 135, 36, 197, 195, 230, 9, 143, 75, 14])));
/// GS: GDGS22URLTMJOPLHN4EH7LKVKZF4ZHXKTXXG2IUNXD75AQOWBXV5GJK5
static immutable GS = KeyPair(PublicKey(Point([205, 45, 106, 145, 92, 216, 151, 61, 103, 111, 8, 127, 173, 85, 86, 75, 204, 158, 234, 157, 238, 109, 34, 141, 184, 255, 208, 65, 214, 13, 235, 211])), SecretKey(Scalar([47, 68, 72, 69, 24, 239, 120, 199, 133, 67, 236, 156, 131, 181, 40, 144, 23, 82, 204, 42, 217, 187, 251, 226, 202, 237, 99, 3, 226, 68, 150, 4])));
/// GT: GDGT22CIBE2AY2IQ2AGC3MQMHYB6WN6OO2VEUS2SX2CJNP6APTN46ZGT
static immutable GT = KeyPair(PublicKey(Point([205, 61, 104, 72, 9, 52, 12, 105, 16, 208, 12, 45, 178, 12, 62, 3, 235, 55, 206, 118, 170, 74, 75, 82, 190, 132, 150, 191, 192, 124, 219, 207])), SecretKey(Scalar([233, 238, 128, 57, 186, 132, 241, 87, 112, 185, 133, 249, 11, 251, 29, 143, 205, 234, 12, 0, 208, 114, 233, 164, 205, 64, 75, 17, 204, 93, 158, 15])));
/// GU: GDGU22H7OWTDRGY4TWNJRXJMD2A5VLOGP77QII6OQ72GRYBINN33SOU4
static immutable GU = KeyPair(PublicKey(Point([205, 77, 104, 255, 117, 166, 56, 155, 28, 157, 154, 152, 221, 44, 30, 129, 218, 173, 198, 127, 255, 4, 35, 206, 135, 244, 104, 224, 40, 107, 119, 185])), SecretKey(Scalar([164, 155, 164, 119, 159, 85, 246, 10, 194, 228, 85, 222, 243, 25, 182, 120, 51, 142, 176, 57, 121, 178, 18, 219, 236, 40, 40, 173, 69, 197, 42, 2])));
/// GV: GDGV22HZQP5A5ATK7GAIM4W6PLHGBAX2GZONNEAAFBWUC2HZ47ZPBZCY
static immutable GV = KeyPair(PublicKey(Point([205, 93, 104, 249, 131, 250, 14, 130, 106, 249, 128, 134, 114, 222, 122, 206, 96, 130, 250, 54, 92, 214, 144, 0, 40, 109, 65, 104, 249, 231, 242, 240])), SecretKey(Scalar([150, 46, 250, 201, 243, 104, 192, 239, 214, 70, 233, 76, 117, 232, 145, 6, 233, 54, 255, 182, 75, 147, 14, 178, 40, 172, 224, 112, 129, 136, 151, 6])));
/// GW: GDGW223SHKKAYJKHI73VV2DFXDTCCWMUVZ7QWSYHKUEMMI5X443XFT37
static immutable GW = KeyPair(PublicKey(Point([205, 109, 107, 114, 58, 148, 12, 37, 71, 71, 247, 90, 232, 101, 184, 230, 33, 89, 148, 174, 127, 11, 75, 7, 85, 8, 198, 35, 183, 231, 55, 114])), SecretKey(Scalar([9, 194, 234, 22, 13, 176, 175, 55, 175, 53, 190, 195, 181, 120, 61, 87, 113, 98, 119, 25, 65, 103, 89, 49, 9, 29, 177, 63, 169, 149, 226, 7])));
/// GX: GDGX22BPMQMATMN2WDKL7EZPY6A7TM2GAPV65QYP2PUC2UED2WIE6ESJ
static immutable GX = KeyPair(PublicKey(Point([205, 125, 104, 47, 100, 24, 9, 177, 186, 176, 212, 191, 147, 47, 199, 129, 249, 179, 70, 3, 235, 238, 195, 15, 211, 232, 45, 80, 131, 213, 144, 79])), SecretKey(Scalar([187, 133, 114, 20, 245, 191, 254, 56, 75, 30, 44, 45, 13, 0, 79, 124, 252, 223, 153, 121, 160, 182, 150, 32, 29, 56, 145, 103, 17, 196, 225, 15])));
/// GY: GDGY22FI2OJPQVIWSPQ5LJ4GGNBQUQWRA5VWQHQU7EREW2FQLJKZQRG7
static immutable GY = KeyPair(PublicKey(Point([205, 141, 104, 168, 211, 146, 248, 85, 22, 147, 225, 213, 167, 134, 51, 67, 10, 66, 209, 7, 107, 104, 30, 20, 249, 34, 75, 104, 176, 90, 85, 152])), SecretKey(Scalar([92, 251, 239, 15, 170, 62, 35, 15, 247, 103, 174, 67, 64, 95, 146, 39, 205, 224, 205, 164, 185, 212, 142, 209, 234, 222, 234, 27, 122, 95, 214, 15])));
/// GZ: GDGZ224Z6CXR6IYDA5CCO3GRCHTNZGQSHEFJBGJRUHLZDVE7N7NKX6B7
static immutable GZ = KeyPair(PublicKey(Point([205, 157, 107, 153, 240, 175, 31, 35, 3, 7, 68, 39, 108, 209, 17, 230, 220, 154, 18, 57, 10, 144, 153, 49, 161, 215, 145, 212, 159, 111, 218, 171])), SecretKey(Scalar([193, 210, 173, 198, 121, 167, 253, 3, 102, 160, 203, 7, 34, 251, 253, 84, 2, 8, 208, 38, 33, 14, 157, 174, 138, 15, 117, 60, 248, 147, 170, 9])));
/// HA: GDHA22SMQVGEZVEGHPMMPDDM6IXPA44ZRSDTL76LWQZ5ISRLP66272GM
static immutable HA = KeyPair(PublicKey(Point([206, 13, 106, 76, 133, 76, 76, 212, 134, 59, 216, 199, 140, 108, 242, 46, 240, 115, 153, 140, 135, 53, 255, 203, 180, 51, 212, 74, 43, 127, 189, 175])), SecretKey(Scalar([102, 50, 8, 178, 174, 49, 45, 105, 219, 151, 45, 29, 14, 240, 18, 232, 168, 65, 253, 186, 86, 231, 4, 252, 94, 242, 91, 85, 22, 31, 108, 7])));
/// HB: GDHB22ZTDIRHAQXCT2Q7TAZRJEZ2I2G5VKWSHX3R2VETKRHWQUEOYXSZ
static immutable HB = KeyPair(PublicKey(Point([206, 29, 107, 51, 26, 34, 112, 66, 226, 158, 161, 249, 131, 49, 73, 51, 164, 104, 221, 170, 173, 35, 223, 113, 213, 73, 53, 68, 246, 133, 8, 236])), SecretKey(Scalar([12, 226, 2, 68, 74, 60, 236, 224, 28, 122, 157, 190, 105, 122, 176, 54, 141, 52, 139, 17, 126, 157, 181, 7, 38, 90, 127, 29, 18, 148, 24, 11])));
/// HC: GDHC22QPNY5IENU6EWJO3REB7IMVG2C5QJVKXGTUIW3GP7GSLYZA6Y7R
static immutable HC = KeyPair(PublicKey(Point([206, 45, 106, 15, 110, 58, 130, 54, 158, 37, 146, 237, 196, 129, 250, 25, 83, 104, 93, 130, 106, 171, 154, 116, 69, 182, 103, 252, 210, 94, 50, 15])), SecretKey(Scalar([249, 101, 64, 163, 44, 184, 126, 143, 117, 140, 144, 175, 180, 246, 161, 158, 229, 118, 92, 127, 147, 108, 158, 221, 121, 100, 250, 78, 244, 205, 80, 0])));
/// HD: GDHD22JY4EON2WB6EFEOQ7OA7QJHDGL5SLHBOURDSRFOGJOMWGBK3NJW
static immutable HD = KeyPair(PublicKey(Point([206, 61, 105, 56, 225, 28, 221, 88, 62, 33, 72, 232, 125, 192, 252, 18, 113, 153, 125, 146, 206, 23, 82, 35, 148, 74, 227, 37, 204, 177, 130, 173])), SecretKey(Scalar([90, 226, 255, 89, 58, 97, 62, 173, 41, 86, 31, 83, 10, 239, 244, 70, 108, 245, 200, 178, 110, 31, 83, 57, 241, 102, 139, 76, 190, 34, 213, 15])));
/// HE: GDHE22ZRDS3PJBSFQUFDVV7HTB7JTB7XXS2BE5PYIUZSQDR4ZQFKSVY2
static immutable HE = KeyPair(PublicKey(Point([206, 77, 107, 49, 28, 182, 244, 134, 69, 133, 10, 58, 215, 231, 152, 126, 153, 135, 247, 188, 180, 18, 117, 248, 69, 51, 40, 14, 60, 204, 10, 169])), SecretKey(Scalar([238, 253, 213, 184, 8, 70, 176, 64, 68, 118, 251, 179, 221, 43, 107, 126, 82, 154, 23, 116, 55, 31, 159, 139, 120, 19, 86, 170, 54, 62, 186, 3])));
/// HF: GDHF22BCPSEGIGDS5LB2L4B7TXC3547SFDQ45XDGSYDUY4HSGXKXQDJL
static immutable HF = KeyPair(PublicKey(Point([206, 93, 104, 34, 124, 136, 100, 24, 114, 234, 195, 165, 240, 63, 157, 197, 190, 243, 242, 40, 225, 206, 220, 102, 150, 7, 76, 112, 242, 53, 213, 120])), SecretKey(Scalar([206, 72, 161, 39, 216, 123, 252, 29, 226, 241, 194, 235, 75, 54, 39, 139, 208, 241, 180, 24, 175, 195, 98, 90, 236, 12, 109, 252, 0, 115, 68, 9])));
/// HG: GDHG22ALBBFJN2OHOL3OWFZFWRZ6I4DPMMSQF5GNVIG3R25M3HYGYOKD
static immutable HG = KeyPair(PublicKey(Point([206, 109, 104, 11, 8, 74, 150, 233, 199, 114, 246, 235, 23, 37, 180, 115, 228, 112, 111, 99, 37, 2, 244, 205, 170, 13, 184, 235, 172, 217, 240, 108])), SecretKey(Scalar([11, 156, 7, 36, 49, 244, 125, 153, 95, 8, 231, 230, 182, 168, 6, 223, 180, 232, 121, 57, 217, 183, 65, 165, 233, 139, 68, 98, 180, 69, 139, 13])));
/// HH: GDHH22UXT6T7C2PKRPLYHPE3A2DR3MCXMSCGFQIR7TWS3AEPOVTZKH7B
static immutable HH = KeyPair(PublicKey(Point([206, 125, 106, 151, 159, 167, 241, 105, 234, 139, 215, 131, 188, 155, 6, 135, 29, 176, 87, 100, 132, 98, 193, 17, 252, 237, 45, 128, 143, 117, 103, 149])), SecretKey(Scalar([74, 187, 177, 134, 148, 53, 171, 238, 54, 103, 119, 70, 167, 34, 82, 1, 191, 56, 137, 101, 202, 97, 50, 206, 204, 141, 178, 66, 225, 164, 8, 10])));
/// HI: GDHI22DUG5FASUNYBBRKKBTWF6P2WHDM7XQETGFAWH7BZ5QOHUPKKGDQ
static immutable HI = KeyPair(PublicKey(Point([206, 141, 104, 116, 55, 74, 9, 81, 184, 8, 98, 165, 6, 118, 47, 159, 171, 28, 108, 253, 224, 73, 152, 160, 177, 254, 28, 246, 14, 61, 30, 165])), SecretKey(Scalar([197, 191, 177, 53, 29, 111, 169, 56, 103, 115, 172, 135, 153, 238, 232, 107, 30, 9, 201, 124, 29, 169, 232, 240, 200, 208, 34, 115, 45, 250, 127, 7])));
/// HJ: GDHJ22QY46PWINOTKA6ZSW3MXFA6EOY7PCZS5S4SS6GBWCZZ3SK3HHPL
static immutable HJ = KeyPair(PublicKey(Point([206, 157, 106, 24, 231, 159, 100, 53, 211, 80, 61, 153, 91, 108, 185, 65, 226, 59, 31, 120, 179, 46, 203, 146, 151, 140, 27, 11, 57, 220, 149, 179])), SecretKey(Scalar([251, 100, 213, 197, 50, 44, 98, 75, 180, 214, 22, 4, 152, 227, 104, 242, 116, 72, 104, 255, 252, 117, 73, 218, 95, 229, 213, 149, 21, 8, 144, 3])));
/// HK: GDHK22QHLNBSIPKG7TQ2C3ID7VXRT3WBR4KF6SRCT5KYRANORMOAKSNH
static immutable HK = KeyPair(PublicKey(Point([206, 173, 106, 7, 91, 67, 36, 61, 70, 252, 225, 161, 109, 3, 253, 111, 25, 238, 193, 143, 20, 95, 74, 34, 159, 85, 136, 129, 174, 139, 28, 5])), SecretKey(Scalar([35, 151, 241, 86, 102, 181, 89, 132, 197, 194, 240, 57, 81, 230, 28, 157, 9, 12, 13, 245, 49, 48, 164, 27, 171, 108, 13, 119, 61, 172, 231, 3])));
/// HL: GDHL22PRCBJ4BJ6AVPVXBRA6KCGDNSDO3K2EJFRE3YHZGMW5F7AL7Y7A
static immutable HL = KeyPair(PublicKey(Point([206, 189, 105, 241, 16, 83, 192, 167, 192, 171, 235, 112, 196, 30, 80, 140, 54, 200, 110, 218, 180, 68, 150, 36, 222, 15, 147, 50, 221, 47, 192, 191])), SecretKey(Scalar([98, 153, 127, 199, 218, 80, 13, 194, 216, 16, 126, 44, 122, 47, 181, 220, 221, 242, 25, 164, 161, 166, 202, 176, 215, 86, 72, 94, 192, 200, 129, 11])));
/// HM: GDHM22EK7DPABH2YNVKXDKRLVFPQ2QOQINZK4TA2FXN7KMKZUXNGLLGO
static immutable HM = KeyPair(PublicKey(Point([206, 205, 104, 138, 248, 222, 0, 159, 88, 109, 85, 113, 170, 43, 169, 95, 13, 65, 208, 67, 114, 174, 76, 26, 45, 219, 245, 49, 89, 165, 218, 101])), SecretKey(Scalar([63, 250, 69, 53, 2, 132, 187, 15, 223, 60, 222, 6, 78, 102, 10, 255, 62, 17, 189, 177, 191, 250, 11, 90, 29, 248, 7, 205, 162, 113, 148, 9])));
/// HN: GDHN22VZ54DANBEQAEFNJOKEKFBVO6OBYG7YKQ5ST53RI23CKKZGSAQ5
static immutable HN = KeyPair(PublicKey(Point([206, 221, 106, 185, 239, 6, 6, 132, 144, 1, 10, 212, 185, 68, 81, 67, 87, 121, 193, 193, 191, 133, 67, 178, 159, 119, 20, 107, 98, 82, 178, 105])), SecretKey(Scalar([7, 202, 89, 148, 227, 171, 214, 150, 191, 167, 176, 152, 222, 95, 162, 139, 178, 7, 163, 69, 225, 205, 181, 21, 197, 130, 22, 71, 195, 38, 122, 14])));
/// HO: GDHO22U7OOTJSKHL4YBKTJLW7VVDXQLQTECCS3B2JXJ634PBC2HAYSEC
static immutable HO = KeyPair(PublicKey(Point([206, 237, 106, 159, 115, 166, 153, 40, 235, 230, 2, 169, 165, 118, 253, 106, 59, 193, 112, 153, 4, 41, 108, 58, 77, 211, 237, 241, 225, 22, 142, 12])), SecretKey(Scalar([80, 68, 46, 96, 202, 85, 242, 224, 107, 186, 147, 138, 184, 212, 190, 176, 162, 5, 218, 156, 118, 238, 169, 21, 32, 147, 227, 66, 199, 4, 211, 7])));
/// HP: GDHP22ABZQJE3K57PJPTGQWI3XTZFQ4VWOMCV3V2HX5UNUR5O4VT6VO4
static immutable HP = KeyPair(PublicKey(Point([206, 253, 104, 1, 204, 18, 77, 171, 191, 122, 95, 51, 66, 200, 221, 231, 146, 195, 149, 179, 152, 42, 238, 186, 61, 251, 70, 210, 61, 119, 43, 63])), SecretKey(Scalar([88, 122, 22, 117, 173, 88, 119, 122, 104, 184, 133, 167, 147, 160, 127, 167, 241, 9, 66, 35, 56, 180, 47, 197, 51, 44, 93, 157, 105, 2, 16, 12])));
/// HQ: GDHQ22ICZMESL33Z52TCO2NCFUZRYHKTHOKJGIVV2XTORHAZV4XQSSMI
static immutable HQ = KeyPair(PublicKey(Point([207, 13, 105, 2, 203, 9, 37, 239, 121, 238, 166, 39, 105, 162, 45, 51, 28, 29, 83, 59, 148, 147, 34, 181, 213, 230, 232, 156, 25, 175, 47, 9])), SecretKey(Scalar([165, 141, 160, 80, 193, 119, 83, 224, 255, 69, 114, 166, 172, 84, 183, 198, 165, 82, 214, 107, 24, 95, 9, 124, 124, 163, 48, 8, 59, 187, 134, 10])));
/// HR: GDHR22PYWWW2VABK65CPK2DXAKV6SJLMWG34UNATFRLLTDTRXI4OMTEG
static immutable HR = KeyPair(PublicKey(Point([207, 29, 105, 248, 181, 173, 170, 128, 42, 247, 68, 245, 104, 119, 2, 171, 233, 37, 108, 177, 183, 202, 52, 19, 44, 86, 185, 142, 113, 186, 56, 230])), SecretKey(Scalar([33, 135, 219, 5, 178, 160, 96, 189, 227, 146, 159, 159, 52, 126, 192, 1, 186, 234, 244, 98, 127, 223, 55, 184, 80, 66, 189, 192, 93, 184, 40, 15])));
/// HS: GDHS22ZSRPNTHMQXLUGDR6YTPW2JVAPRP4QZ2KPFD4I6DMW7ABX45DO3
static immutable HS = KeyPair(PublicKey(Point([207, 45, 107, 50, 139, 219, 51, 178, 23, 93, 12, 56, 251, 19, 125, 180, 154, 129, 241, 127, 33, 157, 41, 229, 31, 17, 225, 178, 223, 0, 111, 206])), SecretKey(Scalar([226, 200, 36, 199, 101, 101, 77, 107, 229, 53, 22, 12, 131, 165, 38, 92, 162, 109, 225, 47, 115, 82, 196, 163, 5, 253, 126, 195, 172, 194, 111, 10])));
/// HT: GDHT22X2VBW7UH5PDO4EYE6454P3AFCFUCQCSUBWA7MV2ZBIOSAH3AYD
static immutable HT = KeyPair(PublicKey(Point([207, 61, 106, 250, 168, 109, 250, 31, 175, 27, 184, 76, 19, 220, 239, 31, 176, 20, 69, 160, 160, 41, 80, 54, 7, 217, 93, 100, 40, 116, 128, 125])), SecretKey(Scalar([73, 182, 211, 236, 27, 169, 244, 232, 120, 127, 162, 53, 254, 130, 66, 104, 4, 158, 137, 4, 58, 180, 142, 220, 32, 54, 135, 4, 217, 20, 90, 9])));
/// HU: GDHU22LS5BBED6FAPVN6MXCOWEN7HX6BBA3BOIEEHVPTQDND6DJLGRIS
static immutable HU = KeyPair(PublicKey(Point([207, 77, 105, 114, 232, 66, 65, 248, 160, 125, 91, 230, 92, 78, 177, 27, 243, 223, 193, 8, 54, 23, 32, 132, 61, 95, 56, 13, 163, 240, 210, 179])), SecretKey(Scalar([37, 197, 229, 60, 88, 8, 133, 204, 31, 64, 129, 95, 209, 158, 155, 23, 203, 120, 209, 200, 165, 240, 253, 223, 92, 119, 249, 53, 91, 6, 127, 7])));
/// HV: GDHV22PDDOZKGNBNFI2ZAO33ANLE6FSR7265FXS7J6A2FKTTANNFAJHZ
static immutable HV = KeyPair(PublicKey(Point([207, 93, 105, 227, 27, 178, 163, 52, 45, 42, 53, 144, 59, 123, 3, 86, 79, 22, 81, 254, 189, 210, 222, 95, 79, 129, 162, 170, 115, 3, 90, 80])), SecretKey(Scalar([239, 20, 159, 238, 101, 230, 104, 60, 152, 229, 13, 51, 103, 113, 209, 29, 210, 205, 195, 113, 121, 157, 34, 247, 29, 21, 148, 69, 119, 189, 161, 3])));
/// HW: GDHW22VBIMJPEVVOQYQRTXBXK2HUTOWU55XPD3TATRM74VE3ALDC6DAD
static immutable HW = KeyPair(PublicKey(Point([207, 109, 106, 161, 67, 18, 242, 86, 174, 134, 33, 25, 220, 55, 86, 143, 73, 186, 212, 239, 110, 241, 238, 96, 156, 89, 254, 84, 155, 2, 198, 47])), SecretKey(Scalar([45, 188, 37, 161, 59, 190, 92, 43, 226, 230, 35, 11, 99, 44, 106, 251, 175, 144, 225, 53, 57, 5, 32, 176, 181, 93, 25, 217, 72, 139, 176, 1])));
/// HX: GDHX22UVGVA4EZOJBP5WNV3NSTKZ7WYCJDGEOB45IEOWDGX55F4OAZ5R
static immutable HX = KeyPair(PublicKey(Point([207, 125, 106, 149, 53, 65, 194, 101, 201, 11, 251, 102, 215, 109, 148, 213, 159, 219, 2, 72, 204, 71, 7, 157, 65, 29, 97, 154, 253, 233, 120, 224])), SecretKey(Scalar([77, 200, 138, 39, 178, 230, 182, 158, 122, 232, 8, 250, 34, 136, 43, 126, 127, 135, 153, 80, 179, 234, 7, 125, 11, 183, 81, 68, 217, 151, 230, 15])));
/// HY: GDHY22X5ADEJM6BV4DYTK7K2BUXDXIRJZLEBXYRQURUBPSZAEVUSES4N
static immutable HY = KeyPair(PublicKey(Point([207, 141, 106, 253, 0, 200, 150, 120, 53, 224, 241, 53, 125, 90, 13, 46, 59, 162, 41, 202, 200, 27, 226, 48, 164, 104, 23, 203, 32, 37, 105, 34])), SecretKey(Scalar([41, 76, 117, 176, 164, 149, 223, 81, 50, 239, 235, 229, 31, 59, 80, 134, 192, 224, 221, 152, 192, 157, 99, 123, 38, 120, 10, 156, 176, 54, 5, 12])));
/// HZ: GDHZ225OAINCCO3PERD5HBGMLLJM6H7W65KIKTYEGGDWADERJQTLLRZS
static immutable HZ = KeyPair(PublicKey(Point([207, 157, 107, 174, 2, 26, 33, 59, 111, 36, 71, 211, 132, 204, 90, 210, 207, 31, 246, 247, 84, 133, 79, 4, 49, 135, 96, 12, 145, 76, 38, 181])), SecretKey(Scalar([12, 213, 128, 143, 169, 83, 200, 241, 47, 168, 220, 211, 107, 239, 181, 225, 38, 81, 171, 211, 61, 133, 189, 180, 120, 112, 252, 226, 142, 218, 218, 1])));
/// IA: GDIA22P6N47ED5UDFNOPX52HHRM5PSIXNCW26ZDVFXREQ36WKKKD4ISM
static immutable IA = KeyPair(PublicKey(Point([208, 13, 105, 254, 111, 62, 65, 246, 131, 43, 92, 251, 247, 71, 60, 89, 215, 201, 23, 104, 173, 175, 100, 117, 45, 226, 72, 111, 214, 82, 148, 62])), SecretKey(Scalar([156, 76, 102, 218, 138, 54, 32, 28, 182, 5, 154, 189, 191, 229, 123, 74, 168, 215, 64, 190, 193, 35, 222, 221, 254, 99, 15, 94, 70, 32, 9, 13])));
/// IB: GDIB22YKODAOPAIKOVHGJONBEILVYFXZMJ436CGFLOEHD6IKPZOHRH7F
static immutable IB = KeyPair(PublicKey(Point([208, 29, 107, 10, 112, 192, 231, 129, 10, 117, 78, 100, 185, 161, 34, 23, 92, 22, 249, 98, 121, 191, 8, 197, 91, 136, 113, 249, 10, 126, 92, 120])), SecretKey(Scalar([67, 231, 95, 53, 65, 73, 28, 193, 160, 40, 33, 151, 51, 0, 91, 249, 46, 203, 156, 207, 220, 77, 247, 162, 95, 170, 218, 94, 250, 105, 51, 3])));
/// IC: GDIC22NDI6MAG6BBEDMVWTITI22CTFZDHT326BWRFBQLD3ZFQS2MOVVY
static immutable IC = KeyPair(PublicKey(Point([208, 45, 105, 163, 71, 152, 3, 120, 33, 32, 217, 91, 77, 19, 70, 180, 41, 151, 35, 60, 247, 175, 6, 209, 40, 96, 177, 239, 37, 132, 180, 199])), SecretKey(Scalar([185, 166, 199, 20, 232, 232, 188, 176, 80, 200, 243, 159, 73, 6, 133, 142, 31, 120, 68, 117, 215, 98, 71, 20, 179, 75, 235, 225, 214, 117, 225, 7])));
/// ID: GDID22IN3USZ2V2G6P7U5D2AWX4TPXIREEKZX6LJHGG737LFJISNLERQ
static immutable ID = KeyPair(PublicKey(Point([208, 61, 105, 13, 221, 37, 157, 87, 70, 243, 255, 78, 143, 64, 181, 249, 55, 221, 17, 33, 21, 155, 249, 105, 57, 141, 253, 253, 101, 74, 36, 213])), SecretKey(Scalar([129, 76, 90, 133, 32, 93, 32, 173, 255, 65, 216, 61, 29, 233, 46, 214, 253, 118, 69, 18, 109, 61, 191, 219, 240, 172, 112, 240, 138, 164, 136, 12])));
/// IE: GDIE22YXXGKU7KY66JTOGDPUE4HRAA5GGKZ5F5BFAB3ZZDKGH6K5BWCE
static immutable IE = KeyPair(PublicKey(Point([208, 77, 107, 23, 185, 149, 79, 171, 30, 242, 102, 227, 13, 244, 39, 15, 16, 3, 166, 50, 179, 210, 244, 37, 0, 119, 156, 141, 70, 63, 149, 208])), SecretKey(Scalar([30, 192, 85, 101, 215, 91, 189, 73, 21, 255, 135, 217, 168, 136, 58, 185, 151, 64, 65, 110, 4, 240, 211, 44, 140, 219, 183, 221, 37, 71, 82, 8])));
/// IF: GDIF22UHOBRT7LNQRJSOOK2XUJESBUKK3Y5CNGSREMXB7XCZIBXMWHBK
static immutable IF = KeyPair(PublicKey(Point([208, 93, 106, 135, 112, 99, 63, 173, 176, 138, 100, 231, 43, 87, 162, 73, 32, 209, 74, 222, 58, 38, 154, 81, 35, 46, 31, 220, 89, 64, 110, 203])), SecretKey(Scalar([104, 111, 122, 9, 106, 235, 212, 65, 66, 121, 100, 98, 217, 144, 217, 181, 19, 81, 122, 214, 159, 219, 17, 169, 93, 50, 11, 204, 181, 24, 1, 15])));
/// IG: GDIG22RG724N7XAPBCCI5UBTNIHUHXPE4DYHGOWJ36BWVXK3KRDUSMKF
static immutable IG = KeyPair(PublicKey(Point([208, 109, 106, 38, 254, 184, 223, 220, 15, 8, 132, 142, 208, 51, 106, 15, 67, 221, 228, 224, 240, 115, 58, 201, 223, 131, 106, 221, 91, 84, 71, 73])), SecretKey(Scalar([228, 29, 60, 18, 172, 89, 184, 248, 72, 26, 86, 104, 124, 202, 145, 206, 5, 217, 247, 180, 108, 74, 140, 192, 192, 213, 42, 10, 111, 30, 234, 0])));
/// IH: GDIH22XPD2QBTFTS4ODMWZN7L4563CX5D3DC4JSOZMPNVKB4F26OVYAW
static immutable IH = KeyPair(PublicKey(Point([208, 125, 106, 239, 30, 160, 25, 150, 114, 227, 134, 203, 101, 191, 95, 59, 237, 138, 253, 30, 198, 46, 38, 78, 203, 30, 218, 168, 60, 46, 188, 234])), SecretKey(Scalar([98, 140, 197, 57, 226, 227, 46, 125, 236, 112, 59, 149, 72, 202, 148, 202, 72, 107, 135, 121, 223, 59, 180, 145, 174, 78, 160, 70, 176, 6, 2, 6])));
/// II: GDII22PSP5XLMLYPQVQK6VJABSLE7Y27XJDKXKIEW6C4RNMXL6FAUL6G
static immutable II = KeyPair(PublicKey(Point([208, 141, 105, 242, 127, 110, 182, 47, 15, 133, 96, 175, 85, 32, 12, 150, 79, 227, 95, 186, 70, 171, 169, 4, 183, 133, 200, 181, 151, 95, 138, 10])), SecretKey(Scalar([240, 98, 208, 179, 180, 236, 55, 41, 170, 96, 147, 222, 234, 80, 195, 174, 242, 42, 57, 85, 60, 174, 178, 207, 17, 172, 110, 0, 20, 118, 135, 15])));
/// IJ: GDIJ223J4ORBBWOK2EM5JS6GXQERTJ4GLZTRNJCZ6MQZHUZH7CAPWQT7
static immutable IJ = KeyPair(PublicKey(Point([208, 157, 107, 105, 227, 162, 16, 217, 202, 209, 25, 212, 203, 198, 188, 9, 25, 167, 134, 94, 103, 22, 164, 89, 243, 33, 147, 211, 39, 248, 128, 251])), SecretKey(Scalar([77, 105, 161, 135, 200, 196, 135, 57, 82, 82, 100, 70, 135, 35, 54, 254, 224, 156, 28, 170, 180, 129, 28, 62, 115, 251, 238, 248, 17, 45, 185, 11])));
/// IK: GDIK22FPCEHBL42MBML3MKF76FFAL4BSL4LA2MVJOYI2SA22XESGHJOL
static immutable IK = KeyPair(PublicKey(Point([208, 173, 104, 175, 17, 14, 21, 243, 76, 11, 23, 182, 40, 191, 241, 74, 5, 240, 50, 95, 22, 13, 50, 169, 118, 17, 169, 3, 90, 185, 36, 99])), SecretKey(Scalar([10, 10, 177, 51, 47, 203, 16, 147, 9, 72, 110, 112, 134, 180, 178, 159, 118, 158, 85, 68, 84, 159, 131, 85, 79, 255, 69, 102, 188, 139, 95, 11])));
/// IL: GDIL227PDVWCV32SAHVEOQXUZ4T7E2TMB35TP72P62XAVHR5UDYXBZYT
static immutable IL = KeyPair(PublicKey(Point([208, 189, 107, 239, 29, 108, 42, 239, 82, 1, 234, 71, 66, 244, 207, 39, 242, 106, 108, 14, 251, 55, 255, 79, 246, 174, 10, 158, 61, 160, 241, 112])), SecretKey(Scalar([6, 44, 93, 19, 153, 42, 118, 41, 50, 81, 134, 105, 85, 42, 48, 50, 17, 45, 99, 50, 25, 163, 127, 68, 135, 31, 107, 16, 3, 181, 239, 13])));
/// IM: GDIM22LORLXTSLCSNNHSHBEYHEVRNB5YJGEAAJEWKFNDUVVQEN2R5B32
static immutable IM = KeyPair(PublicKey(Point([208, 205, 105, 110, 138, 239, 57, 44, 82, 107, 79, 35, 132, 152, 57, 43, 22, 135, 184, 73, 136, 0, 36, 150, 81, 90, 58, 86, 176, 35, 117, 30])), SecretKey(Scalar([9, 100, 44, 187, 233, 31, 26, 205, 96, 102, 94, 199, 38, 165, 62, 16, 69, 88, 103, 71, 74, 23, 228, 26, 196, 250, 208, 22, 182, 119, 92, 12])));
/// IN: GDIN225YRLZTNHGTOPHWWXICV3KUASYZ72F4HEHOLEFZ7LS7UJEEIGTC
static immutable IN = KeyPair(PublicKey(Point([208, 221, 107, 184, 138, 243, 54, 156, 211, 115, 207, 107, 93, 2, 174, 213, 64, 75, 25, 254, 139, 195, 144, 238, 89, 11, 159, 174, 95, 162, 72, 68])), SecretKey(Scalar([25, 154, 241, 205, 8, 102, 90, 160, 135, 206, 41, 42, 194, 28, 103, 194, 12, 213, 79, 214, 71, 35, 250, 177, 250, 81, 66, 243, 3, 137, 239, 4])));
/// IO: GDIO22XOFYK2MBKFBFJK3WO4GQVVE7OWN4YUCQRMEIGGJY5N5LS357LJ
static immutable IO = KeyPair(PublicKey(Point([208, 237, 106, 238, 46, 21, 166, 5, 69, 9, 82, 173, 217, 220, 52, 43, 82, 125, 214, 111, 49, 65, 66, 44, 34, 12, 100, 227, 173, 234, 229, 190])), SecretKey(Scalar([103, 106, 99, 252, 97, 40, 139, 49, 67, 150, 119, 187, 208, 101, 80, 227, 5, 99, 21, 221, 20, 66, 15, 41, 116, 246, 239, 146, 131, 238, 206, 9])));
/// IP: GDIP22F6YT7ZSREZOJNUSA5KQ74JPAYHC4RCH7WHO7GNYBZHI6UTD3MN
static immutable IP = KeyPair(PublicKey(Point([208, 253, 104, 190, 196, 255, 153, 68, 153, 114, 91, 73, 3, 170, 135, 248, 151, 131, 7, 23, 34, 35, 254, 199, 119, 204, 220, 7, 39, 71, 169, 49])), SecretKey(Scalar([14, 244, 34, 151, 8, 37, 176, 61, 5, 164, 17, 54, 12, 3, 49, 106, 91, 85, 74, 230, 99, 109, 85, 87, 44, 70, 31, 78, 1, 56, 55, 12])));
/// IQ: GDIQ22ZSHC525JULNSXZHBRXKYUD5L6ZU34NILUZYYESYQXDI7YFACFV
static immutable IQ = KeyPair(PublicKey(Point([209, 13, 107, 50, 56, 187, 174, 166, 139, 108, 175, 147, 134, 55, 86, 40, 62, 175, 217, 166, 248, 212, 46, 153, 198, 9, 44, 66, 227, 71, 240, 80])), SecretKey(Scalar([231, 57, 111, 227, 173, 181, 62, 28, 2, 249, 168, 94, 56, 111, 241, 49, 90, 78, 18, 130, 129, 60, 47, 112, 183, 87, 68, 54, 215, 76, 131, 6])));
/// IR: GDIR224PELEYWI7337P2N2OVWMQJYLDZCDI4XTJCTKKAVETSOBFKKFY2
static immutable IR = KeyPair(PublicKey(Point([209, 29, 107, 143, 34, 201, 139, 35, 251, 223, 223, 166, 233, 213, 179, 32, 156, 44, 121, 16, 209, 203, 205, 34, 154, 148, 10, 146, 114, 112, 74, 165])), SecretKey(Scalar([182, 91, 20, 72, 237, 17, 137, 220, 244, 224, 152, 10, 178, 44, 244, 220, 103, 74, 4, 201, 237, 64, 10, 169, 46, 76, 22, 113, 209, 189, 185, 5])));
/// IS: GDIS22HOCDNVHCSBXXEXPOQ6VZGKRBDVQTNYLZZUXRCMEC4TDBCDR5PZ
static immutable IS = KeyPair(PublicKey(Point([209, 45, 104, 238, 16, 219, 83, 138, 65, 189, 201, 119, 186, 30, 174, 76, 168, 132, 117, 132, 219, 133, 231, 52, 188, 68, 194, 11, 147, 24, 68, 56])), SecretKey(Scalar([253, 108, 11, 242, 239, 164, 54, 52, 224, 144, 12, 111, 132, 69, 69, 246, 200, 237, 152, 63, 34, 209, 67, 3, 241, 176, 160, 154, 246, 19, 33, 7])));
/// IT: GDIT22GBF3OM2W7UPELTOD7NKBFUITZCJW3YZ4JJSKF3E5ULEZHST2GR
static immutable IT = KeyPair(PublicKey(Point([209, 61, 104, 193, 46, 220, 205, 91, 244, 121, 23, 55, 15, 237, 80, 75, 68, 79, 34, 77, 183, 140, 241, 41, 146, 139, 178, 118, 139, 38, 79, 41])), SecretKey(Scalar([138, 178, 117, 6, 102, 255, 141, 253, 97, 128, 63, 54, 124, 110, 228, 151, 10, 77, 128, 126, 26, 3, 213, 147, 20, 32, 34, 202, 64, 16, 80, 14])));
/// IU: GDIU22EGRSVERIO2VFSNXRZOCA2QIYETFDTHDXBETQ6Y75DGAYAXJYRK
static immutable IU = KeyPair(PublicKey(Point([209, 77, 104, 134, 140, 170, 72, 161, 218, 169, 100, 219, 199, 46, 16, 53, 4, 96, 147, 40, 230, 113, 220, 36, 156, 61, 143, 244, 102, 6, 1, 116])), SecretKey(Scalar([7, 141, 163, 206, 41, 81, 151, 33, 221, 226, 183, 25, 16, 226, 155, 199, 144, 157, 5, 32, 1, 190, 43, 30, 87, 40, 7, 189, 15, 66, 87, 8])));
/// IV: GDIV22OXDE5HXEANT5AXCJ2KB7EVYMXKYGZ6IETSDHITQY64DI7OZFFC
static immutable IV = KeyPair(PublicKey(Point([209, 93, 105, 215, 25, 58, 123, 144, 13, 159, 65, 113, 39, 74, 15, 201, 92, 50, 234, 193, 179, 228, 18, 114, 25, 209, 56, 99, 220, 26, 62, 236])), SecretKey(Scalar([69, 233, 205, 90, 126, 40, 64, 241, 176, 89, 189, 171, 234, 169, 154, 193, 231, 238, 82, 240, 15, 138, 197, 70, 210, 111, 233, 46, 137, 186, 31, 0])));
/// IW: GDIW22NMBZQRUVDGJ62LQX4I2OQUF3R4JV6FCXQSV2UDSEOULIEY4PQX
static immutable IW = KeyPair(PublicKey(Point([209, 109, 105, 172, 14, 97, 26, 84, 102, 79, 180, 184, 95, 136, 211, 161, 66, 238, 60, 77, 124, 81, 94, 18, 174, 168, 57, 17, 212, 90, 9, 142])), SecretKey(Scalar([249, 176, 94, 74, 233, 29, 236, 191, 4, 113, 131, 146, 84, 91, 82, 197, 211, 77, 92, 117, 223, 164, 123, 57, 197, 77, 52, 220, 224, 199, 140, 1])));
/// IX: GDIX22SU2OBCBLRUEI57OJJKQKUUYDD5SOPNWMBCE2QC4THXBEHI6N6B
static immutable IX = KeyPair(PublicKey(Point([209, 125, 106, 84, 211, 130, 32, 174, 52, 34, 59, 247, 37, 42, 130, 169, 76, 12, 125, 147, 158, 219, 48, 34, 38, 160, 46, 76, 247, 9, 14, 143])), SecretKey(Scalar([160, 174, 79, 53, 40, 118, 95, 121, 138, 16, 206, 104, 123, 183, 86, 55, 6, 13, 48, 109, 157, 31, 24, 59, 0, 149, 251, 109, 59, 133, 200, 2])));
/// IY: GDIY22PDPGBGC7DO2LERCGCWI35OFCN5MLQ7SU7LIR74KH5ZCANHJFOC
static immutable IY = KeyPair(PublicKey(Point([209, 141, 105, 227, 121, 130, 97, 124, 110, 210, 201, 17, 24, 86, 70, 250, 226, 137, 189, 98, 225, 249, 83, 235, 68, 127, 197, 31, 185, 16, 26, 116])), SecretKey(Scalar([159, 105, 11, 172, 202, 87, 15, 206, 202, 200, 96, 65, 75, 231, 35, 215, 145, 199, 156, 64, 104, 169, 20, 42, 145, 227, 240, 129, 112, 221, 172, 11])));
/// IZ: GDIZ22U3HYJZXEYVZXEN353XXPVBXTYGCGT3TYRV7YTE6KRLVO4G3FTF
static immutable IZ = KeyPair(PublicKey(Point([209, 157, 106, 155, 62, 19, 155, 147, 21, 205, 200, 221, 247, 119, 187, 234, 27, 207, 6, 17, 167, 185, 226, 53, 254, 38, 79, 42, 43, 171, 184, 109])), SecretKey(Scalar([243, 60, 121, 235, 67, 125, 216, 76, 188, 19, 181, 246, 104, 159, 154, 107, 47, 193, 90, 109, 195, 156, 133, 156, 211, 53, 215, 50, 113, 197, 19, 11])));
/// JA: GDJA22FHJ6AYB4HYS2MI6LVNYGUUUOCBUVZDBL7NBJRL66TOORSH7OLH
static immutable JA = KeyPair(PublicKey(Point([210, 13, 104, 167, 79, 129, 128, 240, 248, 150, 152, 143, 46, 173, 193, 169, 74, 56, 65, 165, 114, 48, 175, 237, 10, 98, 191, 122, 110, 116, 100, 127])), SecretKey(Scalar([83, 168, 103, 189, 163, 225, 225, 151, 236, 244, 221, 235, 16, 26, 234, 150, 113, 203, 74, 101, 104, 19, 255, 163, 231, 74, 80, 41, 79, 104, 80, 10])));
/// JB: GDJB22Z3E5NFHK7EZYE5H3Z2K34JCBF2VGELITGAOXTAR4PUUVLHURTA
static immutable JB = KeyPair(PublicKey(Point([210, 29, 107, 59, 39, 90, 83, 171, 228, 206, 9, 211, 239, 58, 86, 248, 145, 4, 186, 169, 136, 180, 76, 192, 117, 230, 8, 241, 244, 165, 86, 122])), SecretKey(Scalar([118, 208, 70, 66, 117, 114, 234, 243, 29, 119, 80, 225, 36, 36, 34, 181, 99, 122, 4, 109, 110, 148, 125, 188, 58, 123, 147, 7, 18, 181, 149, 9])));
/// JC: GDJC22DRGRU4TSM2MRWG6VTXCVYXZIFU6WWHZ5BHKQ6M73ZKOI424UI6
static immutable JC = KeyPair(PublicKey(Point([210, 45, 104, 113, 52, 105, 201, 201, 154, 100, 108, 111, 86, 119, 21, 113, 124, 160, 180, 245, 172, 124, 244, 39, 84, 60, 207, 239, 42, 114, 57, 174])), SecretKey(Scalar([197, 153, 162, 78, 54, 231, 221, 165, 21, 190, 18, 82, 30, 15, 103, 14, 238, 104, 192, 90, 158, 235, 246, 90, 104, 197, 161, 162, 163, 152, 45, 8])));
/// JD: GDJD22MA7OR5HZL2TQHMFFTCW7WQME6RHY2GTBFCY7L5SQCJ3AXGY4EL
static immutable JD = KeyPair(PublicKey(Point([210, 61, 105, 128, 251, 163, 211, 229, 122, 156, 14, 194, 150, 98, 183, 237, 6, 19, 209, 62, 52, 105, 132, 162, 199, 215, 217, 64, 73, 216, 46, 108])), SecretKey(Scalar([246, 0, 223, 144, 0, 188, 144, 89, 174, 117, 102, 174, 123, 222, 120, 86, 234, 102, 207, 214, 71, 131, 45, 174, 154, 99, 122, 9, 40, 169, 114, 10])));
/// JE: GDJE22RIW2ASKZFPEWKBYPYE46ZM757GZJFNVOE5VJ5XHMCFLVXNUOD7
static immutable JE = KeyPair(PublicKey(Point([210, 77, 106, 40, 182, 129, 37, 100, 175, 37, 148, 28, 63, 4, 231, 178, 207, 247, 230, 202, 74, 218, 184, 157, 170, 123, 115, 176, 69, 93, 110, 218])), SecretKey(Scalar([37, 252, 106, 117, 113, 235, 97, 216, 227, 198, 109, 48, 136, 130, 125, 122, 100, 90, 236, 237, 219, 72, 33, 32, 140, 148, 133, 80, 241, 230, 9, 5])));
/// JF: GDJF22SUW35X547MMWPHJQDZOB7UYN254SRCQ7SH2NNSRCMJLPBLUY4O
static immutable JF = KeyPair(PublicKey(Point([210, 93, 106, 84, 182, 251, 126, 243, 236, 101, 158, 116, 192, 121, 112, 127, 76, 55, 93, 228, 162, 40, 126, 71, 211, 91, 40, 137, 137, 91, 194, 186])), SecretKey(Scalar([223, 176, 115, 114, 180, 246, 237, 237, 23, 198, 26, 232, 33, 5, 178, 183, 54, 126, 197, 98, 224, 151, 82, 92, 189, 117, 252, 47, 237, 225, 243, 1])));
/// JG: GDJG22XJ4LWGQ2VWRHRNSWNZY2DRWUYQEJ2H77WVWZSEQKVSPWH4EEX6
static immutable JG = KeyPair(PublicKey(Point([210, 109, 106, 233, 226, 236, 104, 106, 182, 137, 226, 217, 89, 185, 198, 135, 27, 83, 16, 34, 116, 127, 254, 213, 182, 100, 72, 42, 178, 125, 143, 194])), SecretKey(Scalar([57, 113, 180, 3, 24, 28, 66, 65, 248, 236, 119, 166, 115, 108, 25, 225, 149, 143, 149, 218, 182, 10, 241, 122, 100, 8, 18, 36, 155, 47, 2, 9])));
/// JH: GDJH22RGI63PSYMTIUJJM5MGCHJE6XPM3LQ3HBA5JJTXKFUFNNSUJ7KZ
static immutable JH = KeyPair(PublicKey(Point([210, 125, 106, 38, 71, 182, 249, 97, 147, 69, 18, 150, 117, 134, 17, 210, 79, 93, 236, 218, 225, 179, 132, 29, 74, 103, 117, 22, 133, 107, 101, 68])), SecretKey(Scalar([231, 135, 230, 221, 55, 17, 138, 123, 111, 247, 167, 74, 177, 40, 18, 105, 59, 28, 24, 34, 69, 93, 118, 43, 66, 202, 112, 48, 209, 165, 200, 14])));
/// JI: GDJI22X3CMBMGLGE66HN2NZO3GNMMCJBKMFKPUXJMIEA6DSEBA3WIQLA
static immutable JI = KeyPair(PublicKey(Point([210, 141, 106, 251, 19, 2, 195, 44, 196, 247, 142, 221, 55, 46, 217, 154, 198, 9, 33, 83, 10, 167, 210, 233, 98, 8, 15, 14, 68, 8, 55, 100])), SecretKey(Scalar([251, 199, 72, 239, 194, 14, 211, 230, 33, 128, 184, 86, 91, 207, 49, 129, 43, 33, 196, 88, 234, 171, 17, 172, 73, 131, 33, 5, 52, 76, 201, 9])));
/// JJ: GDJJ225ID7FAGCFZFHOYPGARIKIAOAOJ72HM3O4IPUNWLJVBC3GM7FMH
static immutable JJ = KeyPair(PublicKey(Point([210, 157, 107, 168, 31, 202, 3, 8, 185, 41, 221, 135, 152, 17, 66, 144, 7, 1, 201, 254, 142, 205, 187, 136, 125, 27, 101, 166, 161, 22, 204, 207])), SecretKey(Scalar([244, 162, 89, 5, 150, 24, 93, 250, 170, 81, 46, 64, 191, 91, 20, 221, 131, 27, 149, 173, 239, 73, 245, 147, 80, 215, 20, 105, 187, 112, 7, 2])));
/// JK: GDJK22N67FFRIOWGURTFKKWJZ46BHRERWDMQOKG6ACEL2FU4POMKZHA4
static immutable JK = KeyPair(PublicKey(Point([210, 173, 105, 190, 249, 75, 20, 58, 198, 164, 102, 85, 42, 201, 207, 60, 19, 196, 145, 176, 217, 7, 40, 222, 0, 136, 189, 22, 156, 123, 152, 172])), SecretKey(Scalar([204, 121, 0, 10, 100, 92, 25, 124, 247, 109, 80, 173, 6, 189, 201, 129, 94, 78, 45, 145, 204, 87, 235, 168, 8, 54, 168, 190, 232, 110, 183, 15])));
/// JL: GDJL22M6OIVL5FPUVQJEK4ULMN2FG6JUPL4N4XNYYBSWR3HDZ7LWDZYI
static immutable JL = KeyPair(PublicKey(Point([210, 189, 105, 158, 114, 42, 190, 149, 244, 172, 18, 69, 114, 139, 99, 116, 83, 121, 52, 122, 248, 222, 93, 184, 192, 101, 104, 236, 227, 207, 215, 97])), SecretKey(Scalar([218, 186, 20, 106, 7, 112, 31, 165, 75, 232, 185, 204, 15, 10, 124, 160, 99, 112, 241, 140, 212, 242, 72, 102, 25, 226, 253, 155, 46, 233, 84, 7])));
/// JM: GDJM22NVWWVQG4BPMHFJHOYW55Q5NAXX4K2OOM7ZTQYGLZNZMKAX2PS7
static immutable JM = KeyPair(PublicKey(Point([210, 205, 105, 181, 181, 171, 3, 112, 47, 97, 202, 147, 187, 22, 239, 97, 214, 130, 247, 226, 180, 231, 51, 249, 156, 48, 101, 229, 185, 98, 129, 125])), SecretKey(Scalar([16, 1, 68, 103, 188, 182, 144, 161, 47, 190, 207, 161, 240, 233, 52, 60, 26, 64, 235, 164, 159, 34, 43, 105, 174, 31, 118, 40, 32, 174, 157, 4])));
/// JN: GDJN22WMICWUWMSJAVI23OUSW4RLGEU2YKQ4WHN5HFSKLV5MWNQIBE3L
static immutable JN = KeyPair(PublicKey(Point([210, 221, 106, 204, 64, 173, 75, 50, 73, 5, 81, 173, 186, 146, 183, 34, 179, 18, 154, 194, 161, 203, 29, 189, 57, 100, 165, 215, 172, 179, 96, 128])), SecretKey(Scalar([6, 240, 46, 103, 60, 123, 248, 188, 157, 238, 57, 77, 228, 231, 66, 154, 108, 99, 239, 133, 146, 4, 150, 98, 231, 39, 21, 38, 237, 183, 83, 15])));
/// JO: GDJO22L5GXXN275BQ2IVDMWJNHQYC6HSWAL4YRGPESHNTKO5H6HEZFUY
static immutable JO = KeyPair(PublicKey(Point([210, 237, 105, 125, 53, 238, 221, 127, 161, 134, 145, 81, 178, 201, 105, 225, 129, 120, 242, 176, 23, 204, 68, 207, 36, 142, 217, 169, 221, 63, 142, 76])), SecretKey(Scalar([97, 152, 115, 117, 26, 71, 27, 110, 72, 107, 73, 123, 56, 217, 83, 72, 81, 173, 209, 242, 90, 106, 87, 115, 115, 44, 86, 102, 234, 36, 168, 9])));
/// JP: GDJP22XXTSV64OYYEQH6D254GG6VJXUKX3LGP6Z5S2RFXRVDV4LZJ2H6
static immutable JP = KeyPair(PublicKey(Point([210, 253, 106, 247, 156, 171, 238, 59, 24, 36, 15, 225, 235, 188, 49, 189, 84, 222, 138, 190, 214, 103, 251, 61, 150, 162, 91, 198, 163, 175, 23, 148])), SecretKey(Scalar([31, 221, 22, 54, 112, 174, 18, 30, 196, 134, 189, 97, 23, 245, 119, 36, 59, 232, 69, 11, 220, 73, 43, 173, 240, 121, 40, 16, 158, 88, 123, 14])));
/// JQ: GDJQ2266FAUKMFQ2V2WZKX3BZBUNWNKZG5UABKVUWI7SZ4MZFHXFOKNI
static immutable JQ = KeyPair(PublicKey(Point([211, 13, 107, 222, 40, 40, 166, 22, 26, 174, 173, 149, 95, 97, 200, 104, 219, 53, 89, 55, 104, 0, 170, 180, 178, 63, 44, 241, 153, 41, 238, 87])), SecretKey(Scalar([9, 20, 174, 103, 55, 24, 47, 143, 114, 178, 73, 1, 53, 175, 84, 99, 174, 36, 214, 89, 43, 94, 118, 44, 229, 191, 165, 159, 226, 86, 165, 10])));
/// JR: GDJR22S3KTBERWQOFBFDRZTGGOCGN44CHP2WHHLP2ZUOSIO2MM27ASVJ
static immutable JR = KeyPair(PublicKey(Point([211, 29, 106, 91, 84, 194, 72, 218, 14, 40, 74, 56, 230, 102, 51, 132, 102, 243, 130, 59, 245, 99, 157, 111, 214, 104, 233, 33, 218, 99, 53, 240])), SecretKey(Scalar([72, 199, 84, 45, 210, 239, 12, 108, 127, 195, 93, 179, 225, 14, 150, 202, 250, 80, 137, 14, 209, 253, 129, 57, 151, 109, 238, 216, 219, 106, 107, 14])));
/// JS: GDJS22AOIOZA4UBMSJSO3X25D2IVTMMCEEUJZD46SMMP7WC6RGYGLRWU
static immutable JS = KeyPair(PublicKey(Point([211, 45, 104, 14, 67, 178, 14, 80, 44, 146, 100, 237, 223, 93, 30, 145, 89, 177, 130, 33, 40, 156, 143, 158, 147, 24, 255, 216, 94, 137, 176, 101])), SecretKey(Scalar([41, 178, 249, 187, 120, 181, 194, 241, 173, 5, 50, 239, 231, 41, 180, 202, 35, 246, 70, 56, 45, 169, 242, 43, 145, 182, 213, 8, 198, 39, 160, 15])));
/// JT: GDJT22H6LCQB6TOMM5FUBNNCSOXKIATJMYLUWA4FEYBVXVEKAJLZVBQY
static immutable JT = KeyPair(PublicKey(Point([211, 61, 104, 254, 88, 160, 31, 77, 204, 103, 75, 64, 181, 162, 147, 174, 164, 2, 105, 102, 23, 75, 3, 133, 38, 3, 91, 212, 138, 2, 87, 154])), SecretKey(Scalar([97, 127, 42, 87, 139, 113, 188, 39, 20, 190, 26, 36, 39, 225, 82, 233, 235, 197, 111, 133, 196, 178, 10, 164, 117, 253, 42, 79, 220, 12, 233, 7])));
/// JU: GDJU22B4MLCVQDQATI7ZCWVROZBSPAI3TBZ26PH6WQGO2AF7ZRJEMWST
static immutable JU = KeyPair(PublicKey(Point([211, 77, 104, 60, 98, 197, 88, 14, 0, 154, 63, 145, 90, 177, 118, 67, 39, 129, 27, 152, 115, 175, 60, 254, 180, 12, 237, 0, 191, 204, 82, 70])), SecretKey(Scalar([133, 126, 81, 187, 210, 123, 107, 109, 238, 15, 92, 16, 86, 255, 38, 152, 163, 149, 70, 87, 43, 238, 96, 189, 35, 17, 133, 79, 176, 134, 97, 1])));
/// JV: GDJV223SKMUN4H2JOZ2APGBEX2YWK4RPO6CWNXK5IKOZAIPAA5DLIA46
static immutable JV = KeyPair(PublicKey(Point([211, 93, 107, 114, 83, 40, 222, 31, 73, 118, 116, 7, 152, 36, 190, 177, 101, 114, 47, 119, 133, 102, 221, 93, 66, 157, 144, 33, 224, 7, 70, 180])), SecretKey(Scalar([158, 136, 10, 175, 161, 84, 105, 195, 132, 105, 208, 74, 25, 40, 125, 68, 182, 205, 125, 103, 130, 165, 251, 164, 4, 62, 69, 216, 95, 136, 52, 7])));
/// JW: GDJW22DE6VPWSA74NZ4XXEVYUZLWAJQYJA4KNMIVV6EF74MMR4OQ3R4N
static immutable JW = KeyPair(PublicKey(Point([211, 109, 104, 100, 245, 95, 105, 3, 252, 110, 121, 123, 146, 184, 166, 87, 96, 38, 24, 72, 56, 166, 177, 21, 175, 136, 95, 241, 140, 143, 29, 13])), SecretKey(Scalar([212, 185, 36, 67, 109, 85, 112, 34, 87, 13, 4, 165, 198, 30, 119, 61, 151, 122, 192, 83, 40, 27, 68, 127, 1, 212, 188, 11, 75, 233, 23, 12])));
/// JX: GDJX22Q5A7NCOZPFPH7LYNZB7KKTSM5SNEHLSITD5CYHFIFKOX2FBPPG
static immutable JX = KeyPair(PublicKey(Point([211, 125, 106, 29, 7, 218, 39, 101, 229, 121, 254, 188, 55, 33, 250, 149, 57, 51, 178, 105, 14, 185, 34, 99, 232, 176, 114, 160, 170, 117, 244, 80])), SecretKey(Scalar([143, 195, 85, 69, 106, 110, 26, 91, 90, 100, 89, 213, 221, 46, 55, 157, 34, 28, 196, 20, 120, 54, 127, 193, 51, 223, 10, 112, 102, 188, 227, 10])));
/// JY: GDJY22XODHDU57DFHDVFBNVCDVBO7YWYEJMTYUVCOFPTWSEGJ4NJ5NQU
static immutable JY = KeyPair(PublicKey(Point([211, 141, 106, 238, 25, 199, 78, 252, 101, 56, 234, 80, 182, 162, 29, 66, 239, 226, 216, 34, 89, 60, 82, 162, 113, 95, 59, 72, 134, 79, 26, 158])), SecretKey(Scalar([169, 199, 226, 178, 235, 163, 235, 7, 153, 79, 217, 197, 96, 227, 51, 45, 102, 98, 237, 158, 216, 93, 219, 215, 211, 14, 225, 80, 123, 103, 208, 15])));
/// JZ: GDJZ22FSRLG4IWZX2BAV5NHBNBQPQ3X5DFGSK5555AXAF7CUBUP46EL6
static immutable JZ = KeyPair(PublicKey(Point([211, 157, 104, 178, 138, 205, 196, 91, 55, 208, 65, 94, 180, 225, 104, 96, 248, 110, 253, 25, 77, 37, 119, 189, 232, 46, 2, 252, 84, 13, 31, 207])), SecretKey(Scalar([84, 114, 239, 218, 80, 104, 252, 22, 188, 63, 28, 223, 153, 80, 31, 58, 137, 252, 248, 10, 165, 247, 194, 213, 47, 166, 147, 190, 180, 90, 197, 7])));
/// KA: GDKA22IPALGOBTE76XTTRSIA6MUPDDQ6YHS5JPZRVC2KADCZED2GRCU7
static immutable KA = KeyPair(PublicKey(Point([212, 13, 105, 15, 2, 204, 224, 204, 159, 245, 231, 56, 201, 0, 243, 40, 241, 142, 30, 193, 229, 212, 191, 49, 168, 180, 160, 12, 89, 32, 244, 104])), SecretKey(Scalar([151, 33, 108, 110, 77, 72, 31, 243, 34, 194, 116, 249, 170, 11, 26, 196, 61, 10, 206, 142, 131, 93, 153, 40, 100, 252, 8, 181, 248, 78, 200, 1])));
/// KB: GDKB22UMA7GN6PV7ZL74BGBKEL43HH6IC4AZ6ZM2GQTEOHLDPKUI6GKT
static immutable KB = KeyPair(PublicKey(Point([212, 29, 106, 140, 7, 204, 223, 62, 191, 202, 255, 192, 152, 42, 34, 249, 179, 159, 200, 23, 1, 159, 101, 154, 52, 38, 71, 29, 99, 122, 168, 143])), SecretKey(Scalar([40, 248, 54, 226, 52, 1, 63, 173, 43, 245, 214, 59, 209, 81, 126, 129, 156, 79, 92, 212, 227, 196, 176, 47, 59, 80, 62, 109, 153, 55, 177, 7])));
/// KC: GDKC22OB7DGAXRXNAH4EGNMY3NKHK6IKWJ6WFNRZMUSUUSTEKHK3OHZ6
static immutable KC = KeyPair(PublicKey(Point([212, 45, 105, 193, 248, 204, 11, 198, 237, 1, 248, 67, 53, 152, 219, 84, 117, 121, 10, 178, 125, 98, 182, 57, 101, 37, 74, 74, 100, 81, 213, 183])), SecretKey(Scalar([43, 198, 245, 196, 191, 28, 17, 200, 213, 53, 157, 118, 14, 1, 90, 72, 134, 91, 235, 195, 28, 230, 66, 203, 138, 210, 139, 46, 192, 76, 157, 1])));
/// KD: GDKD22P36WJDHD5QPDVH2GK5Q5SP2FYGTZFDA7IFZRPUIMUYXHPNWREM
static immutable KD = KeyPair(PublicKey(Point([212, 61, 105, 251, 245, 146, 51, 143, 176, 120, 234, 125, 25, 93, 135, 100, 253, 23, 6, 158, 74, 48, 125, 5, 204, 95, 68, 50, 152, 185, 222, 219])), SecretKey(Scalar([66, 20, 178, 240, 165, 131, 175, 44, 104, 144, 232, 29, 4, 41, 253, 8, 30, 124, 144, 128, 42, 53, 63, 174, 18, 223, 215, 64, 123, 106, 52, 12])));
/// KE: GDKE22VNJLTRR56ALVBWNCLIG6LYD42DCAGZVHHELCPNGN5JUQBXDL3O
static immutable KE = KeyPair(PublicKey(Point([212, 77, 106, 173, 74, 231, 24, 247, 192, 93, 67, 102, 137, 104, 55, 151, 129, 243, 67, 16, 13, 154, 156, 228, 88, 158, 211, 55, 169, 164, 3, 113])), SecretKey(Scalar([208, 55, 14, 142, 208, 190, 189, 226, 37, 60, 173, 79, 137, 169, 57, 214, 61, 255, 236, 106, 117, 88, 97, 237, 250, 112, 137, 127, 85, 99, 107, 1])));
/// KF: GDKF22JV7JBRUJSEWLNEZG3HKLEFFI6PHSVS4JIB6RVQ4BZXEL5SI7A7
static immutable KF = KeyPair(PublicKey(Point([212, 93, 105, 53, 250, 67, 26, 38, 68, 178, 218, 76, 155, 103, 82, 200, 82, 163, 207, 60, 171, 46, 37, 1, 244, 107, 14, 7, 55, 34, 251, 36])), SecretKey(Scalar([161, 84, 36, 65, 158, 28, 167, 52, 96, 143, 235, 77, 63, 161, 152, 148, 168, 157, 170, 164, 76, 202, 14, 138, 151, 123, 118, 77, 65, 64, 67, 15])));
/// KG: GDKG22TF7PART6AZF3FTU453GB5Q4YR4LPFJFLR7Z3TEWMPFZPP32MLJ
static immutable KG = KeyPair(PublicKey(Point([212, 109, 106, 101, 251, 193, 25, 248, 25, 46, 203, 58, 115, 187, 48, 123, 14, 98, 60, 91, 202, 146, 174, 63, 206, 230, 75, 49, 229, 203, 223, 189])), SecretKey(Scalar([93, 96, 53, 24, 177, 76, 203, 119, 72, 99, 203, 108, 81, 25, 159, 31, 139, 118, 18, 201, 136, 233, 23, 82, 117, 222, 33, 87, 21, 83, 91, 1])));
/// KH: GDKH22XQISV2WS6SJ7X7L4QHDGHTEITLMR6X2VMVYX7KVU5PQP75ZY2L
static immutable KH = KeyPair(PublicKey(Point([212, 125, 106, 240, 68, 171, 171, 75, 210, 79, 239, 245, 242, 7, 25, 143, 50, 34, 107, 100, 125, 125, 85, 149, 197, 254, 170, 211, 175, 131, 255, 220])), SecretKey(Scalar([250, 67, 31, 229, 57, 86, 200, 196, 87, 24, 196, 68, 136, 221, 42, 7, 182, 69, 105, 69, 72, 181, 160, 80, 94, 202, 14, 85, 99, 227, 206, 9])));
/// KI: GDKI22DAC32ZCPFAB34M6CGZAH3WQED3V7IKUIOSNIRSAKTYAT3WXKIG
static immutable KI = KeyPair(PublicKey(Point([212, 141, 104, 96, 22, 245, 145, 60, 160, 14, 248, 207, 8, 217, 1, 247, 104, 16, 123, 175, 208, 170, 33, 210, 106, 35, 32, 42, 120, 4, 247, 107])), SecretKey(Scalar([177, 125, 6, 55, 190, 177, 235, 103, 36, 237, 129, 193, 184, 67, 153, 229, 130, 160, 250, 136, 200, 55, 72, 249, 122, 51, 223, 190, 1, 172, 138, 7])));
/// KJ: GDKJ222J6MF2MKURJNZRR7HCJGRHGRWIZ5I2GRS64S4PRIL3SAVVZZ4F
static immutable KJ = KeyPair(PublicKey(Point([212, 157, 107, 73, 243, 11, 166, 42, 145, 75, 115, 24, 252, 226, 73, 162, 115, 70, 200, 207, 81, 163, 70, 94, 228, 184, 248, 161, 123, 144, 43, 92])), SecretKey(Scalar([198, 88, 145, 46, 77, 217, 74, 209, 65, 61, 220, 184, 77, 86, 235, 24, 237, 163, 244, 87, 204, 213, 35, 40, 185, 12, 114, 80, 59, 181, 236, 1])));
/// KK: GDKK22FED64HAROSMU55CHFV4RFPX5LWNIT2EAJRPIHN27EFLMHM4GMM
static immutable KK = KeyPair(PublicKey(Point([212, 173, 104, 164, 31, 184, 112, 69, 210, 101, 59, 209, 28, 181, 228, 74, 251, 245, 118, 106, 39, 162, 1, 49, 122, 14, 221, 124, 133, 91, 14, 206])), SecretKey(Scalar([190, 124, 96, 249, 223, 27, 171, 51, 144, 202, 79, 35, 66, 75, 52, 8, 140, 70, 159, 89, 181, 99, 77, 22, 19, 200, 30, 223, 159, 65, 126, 12])));
/// KL: GDKL22C5XX5A22PSRFX6CIUF2WIVY6ZOHWQ5LH5R56NDHRU23Q7GZUVF
static immutable KL = KeyPair(PublicKey(Point([212, 189, 104, 93, 189, 250, 13, 105, 242, 137, 111, 225, 34, 133, 213, 145, 92, 123, 46, 61, 161, 213, 159, 177, 239, 154, 51, 198, 154, 220, 62, 108])), SecretKey(Scalar([192, 43, 246, 158, 73, 61, 189, 183, 86, 191, 207, 190, 134, 10, 216, 188, 44, 172, 177, 205, 40, 111, 191, 181, 37, 165, 37, 57, 189, 13, 149, 6])));
/// KM: GDKM22ZL33P5ZLSFZDNDBM6TEN4A7PPH5ZDEFIODXXFCYD53MQ5ZQ4JF
static immutable KM = KeyPair(PublicKey(Point([212, 205, 107, 43, 222, 223, 220, 174, 69, 200, 218, 48, 179, 211, 35, 120, 15, 189, 231, 238, 70, 66, 161, 195, 189, 202, 44, 15, 187, 100, 59, 152])), SecretKey(Scalar([40, 232, 72, 80, 163, 88, 207, 8, 127, 166, 27, 30, 235, 91, 242, 40, 34, 252, 85, 30, 97, 216, 232, 170, 93, 16, 205, 2, 245, 184, 146, 12])));
/// KN: GDKN22WBGLVL2RCBPTHEVEKREK3IUUC2XTIXPYDSQQEQ27UCP7FXMCLX
static immutable KN = KeyPair(PublicKey(Point([212, 221, 106, 193, 50, 234, 189, 68, 65, 124, 206, 74, 145, 81, 34, 182, 138, 80, 90, 188, 209, 119, 224, 114, 132, 9, 13, 126, 130, 127, 203, 118])), SecretKey(Scalar([181, 223, 134, 167, 182, 109, 90, 86, 40, 56, 224, 64, 41, 222, 122, 173, 100, 170, 78, 175, 180, 7, 152, 55, 2, 131, 168, 99, 238, 41, 99, 0])));
/// KO: GDKO226766XOM4OZPMTB2JWHQFADMVTDAT532CO3TRF6NFCEAHEXUFMS
static immutable KO = KeyPair(PublicKey(Point([212, 237, 107, 223, 247, 174, 230, 113, 217, 123, 38, 29, 38, 199, 129, 64, 54, 86, 99, 4, 251, 189, 9, 219, 156, 75, 230, 148, 68, 1, 201, 122])), SecretKey(Scalar([14, 103, 72, 244, 178, 235, 152, 211, 104, 22, 136, 25, 225, 21, 18, 6, 121, 194, 202, 203, 242, 244, 224, 19, 114, 100, 226, 186, 124, 242, 192, 8])));
/// KP: GDKP22XAJJHWNNEKS7HX5WXYDKNA4DJI7NHSISQ3A3LLPUQI2PGSUIUU
static immutable KP = KeyPair(PublicKey(Point([212, 253, 106, 224, 74, 79, 102, 180, 138, 151, 207, 126, 218, 248, 26, 154, 14, 13, 40, 251, 79, 36, 74, 27, 6, 214, 183, 210, 8, 211, 205, 42])), SecretKey(Scalar([133, 3, 120, 28, 152, 194, 10, 46, 229, 232, 17, 112, 226, 163, 70, 146, 32, 6, 69, 168, 85, 220, 10, 55, 166, 132, 61, 171, 44, 195, 218, 14])));
/// KQ: GDKQ224HXIIABIPE3MFZDAOGDZQV5MZ6YDYRBN565IUMPN5E5THSZHIM
static immutable KQ = KeyPair(PublicKey(Point([213, 13, 107, 135, 186, 16, 0, 161, 228, 219, 11, 145, 129, 198, 30, 97, 94, 179, 62, 192, 241, 16, 183, 190, 234, 40, 199, 183, 164, 236, 207, 44])), SecretKey(Scalar([49, 247, 212, 186, 44, 34, 49, 33, 170, 121, 187, 209, 37, 131, 139, 164, 22, 6, 40, 231, 0, 243, 109, 171, 47, 139, 210, 8, 189, 138, 44, 2])));
/// KR: GDKR225L2MBV4UULJ3BYT7BCM2WVKHPVCPK66MAFFXEZQXCIO4IHD7LR
static immutable KR = KeyPair(PublicKey(Point([213, 29, 107, 171, 211, 3, 94, 82, 139, 78, 195, 137, 252, 34, 102, 173, 85, 29, 245, 19, 213, 239, 48, 5, 45, 201, 152, 92, 72, 119, 16, 113])), SecretKey(Scalar([60, 250, 171, 88, 47, 250, 241, 31, 219, 155, 230, 255, 251, 237, 45, 115, 97, 220, 126, 220, 217, 224, 202, 208, 113, 165, 253, 52, 148, 224, 199, 4])));
/// KS: GDKS22FEF2TLLMI7BRLIEFRWA6OZ27WSKJOUHJAKDGYJ4I2PJWI4SFWF
static immutable KS = KeyPair(PublicKey(Point([213, 45, 104, 164, 46, 166, 181, 177, 31, 12, 86, 130, 22, 54, 7, 157, 157, 126, 210, 82, 93, 67, 164, 10, 25, 176, 158, 35, 79, 77, 145, 201])), SecretKey(Scalar([204, 72, 208, 91, 132, 106, 126, 217, 59, 130, 204, 146, 34, 63, 110, 139, 210, 194, 37, 73, 178, 204, 62, 251, 177, 229, 120, 235, 33, 232, 13, 2])));
/// KT: GDKT22BUR4VDDI4V4YDNVMLQQTTFSD6DXNS27DEUNY4Y6LK54YOM4BAJ
static immutable KT = KeyPair(PublicKey(Point([213, 61, 104, 52, 143, 42, 49, 163, 149, 230, 6, 218, 177, 112, 132, 230, 89, 15, 195, 187, 101, 175, 140, 148, 110, 57, 143, 45, 93, 230, 28, 206])), SecretKey(Scalar([111, 59, 140, 237, 129, 9, 141, 241, 132, 48, 5, 69, 14, 97, 196, 245, 2, 99, 148, 238, 76, 59, 78, 25, 157, 4, 2, 39, 244, 202, 179, 8])));
/// KU: GDKU22KIHSABWBDM5K23QSMFO3AD7AYBCA7PHJASEAY543ZUS4AMJEBZ
static immutable KU = KeyPair(PublicKey(Point([213, 77, 105, 72, 60, 128, 27, 4, 108, 234, 181, 184, 73, 133, 118, 192, 63, 131, 1, 16, 62, 243, 164, 18, 32, 49, 222, 111, 52, 151, 0, 196])), SecretKey(Scalar([116, 4, 126, 239, 165, 210, 231, 41, 94, 171, 231, 157, 2, 77, 114, 221, 185, 116, 251, 244, 214, 95, 162, 218, 70, 127, 55, 180, 34, 110, 148, 13])));
/// KV: GDKV225TXPB4NHU57HLWVFFX6JZRSR7ENBM2NPAVNQLWTA7UBNN24XIV
static immutable KV = KeyPair(PublicKey(Point([213, 93, 107, 179, 187, 195, 198, 158, 157, 249, 215, 106, 148, 183, 242, 115, 25, 71, 228, 104, 89, 166, 188, 21, 108, 23, 105, 131, 244, 11, 91, 174])), SecretKey(Scalar([194, 196, 255, 187, 67, 204, 115, 20, 127, 90, 91, 135, 72, 177, 198, 105, 181, 184, 79, 146, 132, 223, 236, 6, 127, 44, 255, 9, 56, 213, 114, 5])));
/// KW: GDKW22DRCL2C2YAC3UOLN4Z7PXTHO7D7FUU4VOJD5EWASLZ2NZHC2ZDM
static immutable KW = KeyPair(PublicKey(Point([213, 109, 104, 113, 18, 244, 45, 96, 2, 221, 28, 182, 243, 63, 125, 230, 119, 124, 127, 45, 41, 202, 185, 35, 233, 44, 9, 47, 58, 110, 78, 45])), SecretKey(Scalar([219, 183, 146, 105, 234, 70, 35, 139, 212, 83, 140, 111, 205, 138, 46, 118, 84, 129, 61, 202, 218, 91, 52, 107, 156, 68, 10, 85, 108, 160, 186, 14])));
/// KX: GDKX22A2XGQACNDX6DL4TY4WQP6V2UPNWGF74ECOTVK7NOO5V4QOREDK
static immutable KX = KeyPair(PublicKey(Point([213, 125, 104, 26, 185, 160, 1, 52, 119, 240, 215, 201, 227, 150, 131, 253, 93, 81, 237, 177, 139, 254, 16, 78, 157, 85, 246, 185, 221, 175, 32, 232])), SecretKey(Scalar([215, 76, 252, 27, 201, 212, 178, 184, 30, 188, 12, 173, 55, 124, 4, 57, 77, 194, 119, 105, 222, 123, 32, 117, 30, 33, 97, 27, 206, 188, 230, 14])));
/// KY: GDKY22JHHL4IM7LQODIBJX6QJMDMXUU3NYNSZBO5VB2L6RQUEOSZVSJ6
static immutable KY = KeyPair(PublicKey(Point([213, 141, 105, 39, 58, 248, 134, 125, 112, 112, 208, 20, 223, 208, 75, 6, 203, 210, 155, 110, 27, 44, 133, 221, 168, 116, 191, 70, 20, 35, 165, 154])), SecretKey(Scalar([232, 219, 190, 235, 203, 174, 98, 141, 228, 20, 128, 23, 147, 197, 66, 60, 100, 179, 119, 131, 160, 91, 155, 208, 135, 235, 26, 48, 141, 74, 26, 15])));
/// KZ: GDKZ22M3OTYHX6KUAWRLH43M5GZ5CS5IDU52XISOKNTUGJ2ZRKDV5FFN
static immutable KZ = KeyPair(PublicKey(Point([213, 157, 105, 155, 116, 240, 123, 249, 84, 5, 162, 179, 243, 108, 233, 179, 209, 75, 168, 29, 59, 171, 162, 78, 83, 103, 67, 39, 89, 138, 135, 94])), SecretKey(Scalar([121, 95, 217, 60, 65, 159, 214, 125, 94, 73, 107, 228, 164, 249, 122, 218, 180, 142, 122, 227, 81, 38, 229, 55, 238, 145, 20, 23, 207, 11, 192, 15])));
/// LA: GDLA227STOHI7BY5OZYPRUTP33DGRQHV6QVGJM67W6ZUDWTBKEDTC2HZ
static immutable LA = KeyPair(PublicKey(Point([214, 13, 107, 242, 155, 142, 143, 135, 29, 118, 112, 248, 210, 111, 222, 198, 104, 192, 245, 244, 42, 100, 179, 223, 183, 179, 65, 218, 97, 81, 7, 49])), SecretKey(Scalar([143, 198, 132, 142, 118, 25, 187, 30, 216, 213, 213, 152, 217, 50, 127, 134, 236, 42, 41, 107, 88, 122, 215, 210, 190, 123, 156, 230, 102, 171, 117, 15])));
/// LB: GDLB22D345WJWBITKUOU6K3KEPVHQQ6MAFUFBZPX2WMM267UUNLDL36O
static immutable LB = KeyPair(PublicKey(Point([214, 29, 104, 123, 231, 108, 155, 5, 19, 85, 29, 79, 43, 106, 35, 234, 120, 67, 204, 1, 104, 80, 229, 247, 213, 152, 205, 123, 244, 163, 86, 53])), SecretKey(Scalar([235, 233, 171, 103, 35, 243, 234, 133, 49, 172, 27, 138, 230, 250, 56, 145, 31, 123, 140, 210, 80, 55, 70, 162, 242, 94, 73, 147, 62, 72, 108, 4])));
/// LC: GDLC22GWGCDMCT5AEGM4KU2SZD7DKJEQOTD4P4NGHQCIV2HT22KXSKTZ
static immutable LC = KeyPair(PublicKey(Point([214, 45, 104, 214, 48, 134, 193, 79, 160, 33, 153, 197, 83, 82, 200, 254, 53, 36, 144, 116, 199, 199, 241, 166, 60, 4, 138, 232, 243, 214, 149, 121])), SecretKey(Scalar([155, 48, 129, 168, 103, 247, 25, 252, 31, 90, 49, 145, 89, 24, 118, 15, 35, 136, 1, 188, 15, 90, 235, 136, 204, 121, 245, 200, 77, 26, 168, 9])));
/// LD: GDLD22CVZMU7NFVMT7V7HNOVRO7HC54ZLV3Z5QSWHJE622R5FK4ZG7Q6
static immutable LD = KeyPair(PublicKey(Point([214, 61, 104, 85, 203, 41, 246, 150, 172, 159, 235, 243, 181, 213, 139, 190, 113, 119, 153, 93, 119, 158, 194, 86, 58, 73, 237, 106, 61, 42, 185, 147])), SecretKey(Scalar([155, 218, 166, 214, 111, 87, 74, 185, 31, 227, 111, 4, 211, 211, 18, 145, 228, 83, 20, 217, 21, 51, 209, 184, 67, 137, 170, 2, 193, 191, 218, 0])));
/// LE: GDLE22U2QSPKXK3YH3C6ODVH5BVZ75WCIFFGNF57D5ERDZUNGIEY7GFR
static immutable LE = KeyPair(PublicKey(Point([214, 77, 106, 154, 132, 158, 171, 171, 120, 62, 197, 231, 14, 167, 232, 107, 159, 246, 194, 65, 74, 102, 151, 191, 31, 73, 17, 230, 141, 50, 9, 143])), SecretKey(Scalar([219, 254, 31, 159, 75, 76, 105, 107, 139, 203, 65, 54, 134, 18, 115, 160, 75, 41, 232, 93, 104, 114, 27, 158, 177, 112, 233, 248, 12, 81, 200, 14])));
/// LF: GDLF22BRSTVNYBUKK6JLMJXYLNKIG55NCYSHJDVHDGFIBMMMETBCOK7T
static immutable LF = KeyPair(PublicKey(Point([214, 93, 104, 49, 148, 234, 220, 6, 138, 87, 146, 182, 38, 248, 91, 84, 131, 119, 173, 22, 36, 116, 142, 167, 25, 138, 128, 177, 140, 36, 194, 39])), SecretKey(Scalar([21, 192, 106, 116, 134, 79, 68, 131, 112, 135, 244, 49, 168, 225, 133, 161, 118, 233, 91, 238, 218, 65, 69, 60, 249, 101, 36, 9, 230, 202, 64, 7])));
/// LG: GDLG22BWUC3MZQXRXVQT23RKKP2NEZTHNK57JAYYGX5LQL2AJVXJSQJR
static immutable LG = KeyPair(PublicKey(Point([214, 109, 104, 54, 160, 182, 204, 194, 241, 189, 97, 61, 110, 42, 83, 244, 210, 102, 103, 106, 187, 244, 131, 24, 53, 250, 184, 47, 64, 77, 110, 153])), SecretKey(Scalar([207, 7, 21, 51, 236, 61, 53, 60, 145, 168, 83, 61, 183, 52, 207, 213, 118, 168, 29, 15, 219, 33, 3, 2, 215, 249, 29, 235, 157, 65, 77, 10])));
/// LH: GDLH22QIN2ZJ7R6FAKS2H5BNJTY3AKBWGF5C7QOHORMWRDLX2T5SAJUO
static immutable LH = KeyPair(PublicKey(Point([214, 125, 106, 8, 110, 178, 159, 199, 197, 2, 165, 163, 244, 45, 76, 241, 176, 40, 54, 49, 122, 47, 193, 199, 116, 89, 104, 141, 119, 212, 251, 32])), SecretKey(Scalar([173, 66, 139, 39, 59, 28, 210, 212, 241, 190, 13, 75, 34, 248, 129, 145, 45, 98, 215, 18, 177, 224, 250, 43, 44, 44, 4, 9, 108, 91, 111, 2])));
/// LI: GDLI22CWE5DBNF6VZX35PPCCHVE7TCP4AXXNIOM4GY2NW26SQLU6KDYJ
static immutable LI = KeyPair(PublicKey(Point([214, 141, 104, 86, 39, 70, 22, 151, 213, 205, 247, 215, 188, 66, 61, 73, 249, 137, 252, 5, 238, 212, 57, 156, 54, 52, 219, 107, 210, 130, 233, 229])), SecretKey(Scalar([75, 6, 84, 223, 25, 57, 54, 86, 148, 33, 213, 37, 136, 254, 158, 77, 116, 212, 237, 200, 150, 174, 101, 99, 1, 66, 0, 114, 133, 31, 98, 4])));
/// LJ: GDLJ224UR7R7YIK3E7LJNHHKTIUO7YBOB2Y3AI635YXLIKR7C3WFANX5
static immutable LJ = KeyPair(PublicKey(Point([214, 157, 107, 148, 143, 227, 252, 33, 91, 39, 214, 150, 156, 234, 154, 40, 239, 224, 46, 14, 177, 176, 35, 219, 238, 46, 180, 42, 63, 22, 236, 80])), SecretKey(Scalar([139, 111, 230, 63, 254, 116, 83, 196, 44, 25, 156, 83, 165, 39, 248, 222, 54, 171, 225, 24, 250, 9, 163, 74, 52, 29, 90, 36, 63, 254, 134, 11])));
/// LK: GDLK22UIWZSUWULBKME47BPH6QZWNR7IKTSFTX7I7ZWWJVJIX4ZEVKTT
static immutable LK = KeyPair(PublicKey(Point([214, 173, 106, 136, 182, 101, 75, 81, 97, 83, 9, 207, 133, 231, 244, 51, 102, 199, 232, 84, 228, 89, 223, 232, 254, 109, 100, 213, 40, 191, 50, 74])), SecretKey(Scalar([238, 41, 171, 43, 5, 134, 187, 4, 129, 137, 191, 145, 136, 207, 23, 151, 150, 107, 133, 39, 66, 242, 88, 30, 182, 82, 252, 227, 192, 20, 7, 1])));
/// LL: GDLL22OZI666Y3WRSQXMYG2AWR5XJKUJACTUSNQVBYPDQRJZ5FTTKQWI
static immutable LL = KeyPair(PublicKey(Point([214, 189, 105, 217, 71, 189, 236, 110, 209, 148, 46, 204, 27, 64, 180, 123, 116, 170, 137, 0, 167, 73, 54, 21, 14, 30, 56, 69, 57, 233, 103, 53])), SecretKey(Scalar([228, 158, 201, 212, 165, 8, 44, 206, 166, 232, 229, 114, 156, 216, 51, 252, 132, 74, 171, 178, 23, 242, 23, 184, 8, 118, 112, 13, 217, 251, 248, 5])));
/// LM: GDLM2254FSQV2F7A6E7CQMRKLVYS4X44LULYIUOR46UFXPIADLYNLBCR
static immutable LM = KeyPair(PublicKey(Point([214, 205, 107, 188, 44, 161, 93, 23, 224, 241, 62, 40, 50, 42, 93, 113, 46, 95, 156, 93, 23, 132, 81, 209, 231, 168, 91, 189, 0, 26, 240, 213])), SecretKey(Scalar([45, 39, 164, 175, 105, 47, 116, 149, 241, 64, 142, 238, 118, 65, 157, 184, 53, 232, 7, 130, 213, 140, 13, 14, 81, 146, 95, 84, 73, 123, 105, 9])));
/// LN: GDLN22DPDFI35GJVGZOFPXJKMJRFRHXPX6UDOPGN6BIIGWK6UVIMSUDN
static immutable LN = KeyPair(PublicKey(Point([214, 221, 104, 111, 25, 81, 190, 153, 53, 54, 92, 87, 221, 42, 98, 98, 88, 158, 239, 191, 168, 55, 60, 205, 240, 80, 131, 89, 94, 165, 80, 201])), SecretKey(Scalar([207, 72, 190, 68, 161, 126, 202, 26, 160, 75, 103, 219, 84, 241, 110, 197, 131, 173, 249, 177, 112, 29, 50, 225, 189, 59, 195, 114, 40, 35, 151, 12])));
/// LO: GDLO22JVEIFUJGZKCN7C26B5RWA2DYIYRY543QU5RSVSN5DBJNUQDNJV
static immutable LO = KeyPair(PublicKey(Point([214, 237, 105, 53, 34, 11, 68, 155, 42, 19, 126, 45, 120, 61, 141, 129, 161, 225, 24, 142, 59, 205, 194, 157, 140, 171, 38, 244, 97, 75, 105, 1])), SecretKey(Scalar([215, 221, 134, 177, 228, 62, 78, 171, 166, 236, 100, 110, 251, 171, 233, 242, 138, 97, 109, 109, 225, 192, 90, 79, 26, 77, 47, 22, 150, 162, 86, 7])));
/// LP: GDLP22ABHZXODJBHD3ZF75VTWLY2LR2VCZUDQSQDTFCXVMMHGVHJAV4W
static immutable LP = KeyPair(PublicKey(Point([214, 253, 104, 1, 62, 110, 225, 164, 39, 30, 242, 95, 246, 179, 178, 241, 165, 199, 85, 22, 104, 56, 74, 3, 153, 69, 122, 177, 135, 53, 78, 144])), SecretKey(Scalar([203, 155, 15, 181, 226, 127, 231, 159, 135, 136, 194, 23, 146, 126, 210, 34, 145, 11, 254, 36, 87, 85, 253, 114, 21, 207, 228, 101, 133, 242, 174, 11])));
/// LQ: GDLQ22PB5IIJFOCPAJ7D255EHOYJQT5MVVPDTSO7MU25RDR6YPI7P7F2
static immutable LQ = KeyPair(PublicKey(Point([215, 13, 105, 225, 234, 16, 146, 184, 79, 2, 126, 61, 119, 164, 59, 176, 152, 79, 172, 173, 94, 57, 201, 223, 101, 53, 216, 142, 62, 195, 209, 247])), SecretKey(Scalar([9, 10, 26, 47, 134, 32, 255, 32, 132, 236, 98, 205, 10, 160, 103, 124, 48, 22, 142, 145, 51, 52, 253, 184, 151, 247, 178, 38, 28, 187, 172, 0])));
/// LR: GDLR22VE6EATXXMCKDLSRFJ2E5PUNJZSSZQAV476Y3FDAI5IPIJ343L7
static immutable LR = KeyPair(PublicKey(Point([215, 29, 106, 164, 241, 1, 59, 221, 130, 80, 215, 40, 149, 58, 39, 95, 70, 167, 50, 150, 96, 10, 243, 254, 198, 202, 48, 35, 168, 122, 19, 190])), SecretKey(Scalar([63, 8, 37, 0, 100, 215, 112, 29, 89, 26, 190, 38, 40, 243, 9, 213, 113, 22, 213, 206, 26, 160, 247, 125, 102, 168, 43, 8, 228, 80, 218, 14])));
/// LS: GDLS22ETB4JE6BIDQTU46SAFUBMTEGEAKSGOK3BJV3WHTL5CREYVI3KK
static immutable LS = KeyPair(PublicKey(Point([215, 45, 104, 147, 15, 18, 79, 5, 3, 132, 233, 207, 72, 5, 160, 89, 50, 24, 128, 84, 140, 229, 108, 41, 174, 236, 121, 175, 162, 137, 49, 84])), SecretKey(Scalar([81, 72, 185, 145, 254, 210, 60, 171, 94, 233, 199, 132, 111, 100, 212, 153, 186, 38, 210, 81, 213, 5, 239, 24, 166, 162, 191, 174, 133, 255, 199, 5])));
/// LT: GDLT2252V7V5ZLG3CH2HHZCRFYMEVVV42ORCCAMMNSFSW7V74UORB32O
static immutable LT = KeyPair(PublicKey(Point([215, 61, 107, 186, 175, 235, 220, 172, 219, 17, 244, 115, 228, 81, 46, 24, 74, 214, 188, 211, 162, 33, 1, 140, 108, 139, 43, 126, 191, 229, 29, 16])), SecretKey(Scalar([126, 135, 7, 254, 231, 93, 241, 176, 222, 83, 59, 165, 208, 158, 77, 187, 213, 96, 47, 149, 118, 22, 79, 164, 211, 127, 21, 74, 18, 44, 6, 12])));
/// LU: GDLU22RHMOJMHUNA3ET3UBRBE2EEXPIS456BMBHQHXVBWVSUMEXRVRUU
static immutable LU = KeyPair(PublicKey(Point([215, 77, 106, 39, 99, 146, 195, 209, 160, 217, 39, 186, 6, 33, 38, 136, 75, 189, 18, 231, 124, 22, 4, 240, 61, 234, 27, 86, 84, 97, 47, 26])), SecretKey(Scalar([91, 125, 203, 112, 61, 101, 144, 97, 36, 40, 66, 245, 123, 166, 214, 74, 152, 160, 110, 109, 255, 87, 111, 138, 144, 207, 104, 217, 99, 72, 138, 7])));
/// LV: GDLV22P6XI4SR6ZRHU454E6POHHVDK4KCFIYB7HD5MEFLDJQDFI6RGU4
static immutable LV = KeyPair(PublicKey(Point([215, 93, 105, 254, 186, 57, 40, 251, 49, 61, 57, 222, 19, 207, 113, 207, 81, 171, 138, 17, 81, 128, 252, 227, 235, 8, 85, 141, 48, 25, 81, 232])), SecretKey(Scalar([4, 172, 69, 149, 194, 71, 25, 73, 207, 175, 247, 77, 58, 0, 159, 176, 14, 105, 48, 202, 236, 63, 67, 35, 42, 85, 179, 110, 98, 113, 37, 11])));
/// LW: GDLW22LEUDLSSKEFG3J6FL2PHBBICYX62MLQLSNNNW3X3UWIWN5F5QY5
static immutable LW = KeyPair(PublicKey(Point([215, 109, 105, 100, 160, 215, 41, 40, 133, 54, 211, 226, 175, 79, 56, 66, 129, 98, 254, 211, 23, 5, 201, 173, 109, 183, 125, 210, 200, 179, 122, 94])), SecretKey(Scalar([52, 86, 114, 23, 37, 215, 2, 37, 172, 131, 227, 209, 215, 51, 165, 23, 151, 98, 6, 190, 179, 74, 236, 158, 98, 217, 34, 111, 40, 198, 42, 11])));
/// LX: GDLX22EZEZO4VFNE56BRJTBPL4GDVV6EP7FOX7DWPQCFT4UFZS4W6ZSX
static immutable LX = KeyPair(PublicKey(Point([215, 125, 104, 153, 38, 93, 202, 149, 164, 239, 131, 20, 204, 47, 95, 12, 58, 215, 196, 127, 202, 235, 252, 118, 124, 4, 89, 242, 133, 204, 185, 111])), SecretKey(Scalar([182, 101, 79, 7, 9, 37, 10, 88, 164, 61, 97, 155, 12, 88, 66, 146, 145, 19, 171, 179, 119, 22, 5, 205, 72, 196, 42, 131, 84, 145, 50, 5])));
/// LY: GDLY22KB2XTC4RCDVYSL5X5SIUA3ZXR3LQNDGKGDMVVV7FOHOHBXZODL
static immutable LY = KeyPair(PublicKey(Point([215, 141, 105, 65, 213, 230, 46, 68, 67, 174, 36, 190, 223, 178, 69, 1, 188, 222, 59, 92, 26, 51, 40, 195, 101, 107, 95, 149, 199, 113, 195, 124])), SecretKey(Scalar([171, 18, 221, 48, 93, 246, 45, 163, 23, 218, 241, 160, 138, 134, 121, 241, 142, 112, 132, 150, 240, 228, 120, 175, 87, 175, 209, 72, 160, 61, 121, 13])));
/// LZ: GDLZ22GXR5MT3NZPGR3CBWHZBO6SJ7OU5WJPBUKZLTFT5DJAE5NYCOM6
static immutable LZ = KeyPair(PublicKey(Point([215, 157, 104, 215, 143, 89, 61, 183, 47, 52, 118, 32, 216, 249, 11, 189, 36, 253, 212, 237, 146, 240, 209, 89, 92, 203, 62, 141, 32, 39, 91, 129])), SecretKey(Scalar([97, 60, 113, 129, 201, 121, 131, 86, 31, 183, 51, 2, 62, 212, 28, 85, 147, 12, 16, 101, 244, 55, 53, 213, 41, 169, 110, 106, 231, 24, 173, 0])));
/// MA: GDMA22R3E4I465MSZUTER6DWWFQJCVZPHRDE4NCKMKNEGWBAWFPAATY5
static immutable MA = KeyPair(PublicKey(Point([216, 13, 106, 59, 39, 17, 207, 117, 146, 205, 38, 72, 248, 118, 177, 96, 145, 87, 47, 60, 70, 78, 52, 74, 98, 154, 67, 88, 32, 177, 94, 0])), SecretKey(Scalar([249, 32, 99, 103, 91, 60, 83, 71, 214, 192, 4, 42, 3, 70, 255, 175, 26, 211, 68, 215, 19, 119, 91, 213, 34, 75, 36, 11, 51, 27, 52, 14])));
/// MB: GDMB222EE2DLEJPK4IQETPCWPBLDQKRZ72J6XQOYJROAIVXZ2WYMOGDH
static immutable MB = KeyPair(PublicKey(Point([216, 29, 107, 68, 38, 134, 178, 37, 234, 226, 32, 73, 188, 86, 120, 86, 56, 42, 57, 254, 147, 235, 193, 216, 76, 92, 4, 86, 249, 213, 176, 199])), SecretKey(Scalar([178, 234, 100, 111, 136, 248, 223, 126, 42, 5, 180, 161, 195, 177, 231, 12, 218, 84, 149, 149, 47, 228, 202, 119, 39, 191, 11, 133, 23, 143, 237, 14])));
/// MC: GDMC22COICKZW4P72AZHEU3ZW55ZKGDQ6GE7GVRVO55DPHHYET627RMD
static immutable MC = KeyPair(PublicKey(Point([216, 45, 104, 78, 64, 149, 155, 113, 255, 208, 50, 114, 83, 121, 183, 123, 149, 24, 112, 241, 137, 243, 86, 53, 119, 122, 55, 156, 248, 36, 253, 175])), SecretKey(Scalar([217, 179, 111, 53, 197, 246, 214, 48, 61, 77, 106, 154, 175, 200, 117, 138, 48, 98, 88, 236, 38, 42, 148, 139, 140, 245, 34, 92, 19, 113, 220, 6])));
/// MD: GDMD22D6RJN2QHLWESVJCSAQGULJUQU2CUKVC42I6M7O5UAVBZKBS6IS
static immutable MD = KeyPair(PublicKey(Point([216, 61, 104, 126, 138, 91, 168, 29, 118, 36, 170, 145, 72, 16, 53, 22, 154, 66, 154, 21, 21, 81, 115, 72, 243, 62, 238, 208, 21, 14, 84, 25])), SecretKey(Scalar([205, 75, 59, 56, 161, 46, 190, 95, 149, 191, 15, 66, 206, 41, 246, 160, 172, 161, 224, 99, 98, 157, 164, 159, 82, 149, 199, 67, 16, 151, 7, 8])));
/// ME: GDME22YK25PGJJ735V4U2REFHHOJSUO6PFXS24BINDG5WWZAQI255LD7
static immutable ME = KeyPair(PublicKey(Point([216, 77, 107, 10, 215, 94, 100, 167, 251, 237, 121, 77, 68, 133, 57, 220, 153, 81, 222, 121, 111, 45, 112, 40, 104, 205, 219, 91, 32, 130, 53, 222])), SecretKey(Scalar([60, 48, 101, 102, 154, 74, 59, 13, 156, 185, 196, 181, 83, 48, 230, 183, 244, 0, 109, 68, 158, 208, 33, 82, 210, 73, 39, 112, 111, 12, 192, 0])));
/// MF: GDMF22XJLXZJTOIJCAJXJGEYVWHNLKDOEVK3IG7KPABX6OZ7YKMATYTH
static immutable MF = KeyPair(PublicKey(Point([216, 93, 106, 233, 93, 242, 153, 185, 9, 16, 19, 116, 152, 152, 173, 142, 213, 168, 110, 37, 85, 180, 27, 234, 120, 3, 127, 59, 63, 194, 152, 9])), SecretKey(Scalar([62, 232, 27, 160, 7, 13, 30, 121, 125, 101, 182, 184, 155, 158, 64, 62, 25, 33, 254, 104, 177, 215, 177, 205, 145, 178, 102, 42, 115, 59, 48, 4])));
/// MG: GDMG22CUW46PSUQTYPJZ5ELB2NHKQN3JMYQKEBJPBCCS6QLLVFC67CX4
static immutable MG = KeyPair(PublicKey(Point([216, 109, 104, 84, 183, 60, 249, 82, 19, 195, 211, 158, 145, 97, 211, 78, 168, 55, 105, 102, 32, 162, 5, 47, 8, 133, 47, 65, 107, 169, 69, 239])), SecretKey(Scalar([41, 205, 146, 3, 122, 246, 157, 141, 187, 154, 146, 33, 100, 98, 108, 253, 160, 174, 135, 145, 20, 205, 150, 129, 168, 103, 211, 233, 234, 223, 100, 1])));
/// MH: GDMH22HAYE7Q64HQHOV3KVQWIO3Q45HN6DWMS5FRUKHCJVRNKXINIVKW
static immutable MH = KeyPair(PublicKey(Point([216, 125, 104, 224, 193, 63, 15, 112, 240, 59, 171, 181, 86, 22, 67, 183, 14, 116, 237, 240, 236, 201, 116, 177, 162, 142, 36, 214, 45, 85, 208, 212])), SecretKey(Scalar([71, 109, 3, 150, 45, 112, 176, 131, 172, 189, 243, 94, 57, 5, 153, 240, 31, 229, 63, 187, 161, 114, 122, 35, 3, 79, 199, 215, 222, 107, 163, 12])));
/// MI: GDMI22LYJWCJZPXOJZKYTCEMWPFNSS6XYE4P4YKB657GKX4EGSRUKKI3
static immutable MI = KeyPair(PublicKey(Point([216, 141, 105, 120, 77, 132, 156, 190, 238, 78, 85, 137, 136, 140, 179, 202, 217, 75, 215, 193, 56, 254, 97, 65, 247, 126, 101, 95, 132, 52, 163, 69])), SecretKey(Scalar([108, 38, 245, 70, 81, 116, 210, 227, 60, 16, 220, 97, 196, 246, 138, 122, 244, 68, 95, 119, 216, 9, 159, 176, 137, 201, 171, 74, 129, 99, 85, 7])));
/// MJ: GDMJ22RSHLC36VPODNDXS4XIJ6ZYLSIEXLI2LW54DG4VXAWSBGBTJIY7
static immutable MJ = KeyPair(PublicKey(Point([216, 157, 106, 50, 58, 197, 191, 85, 238, 27, 71, 121, 114, 232, 79, 179, 133, 201, 4, 186, 209, 165, 219, 188, 25, 185, 91, 130, 210, 9, 131, 52])), SecretKey(Scalar([202, 236, 120, 245, 24, 209, 118, 40, 126, 240, 130, 227, 62, 225, 205, 145, 136, 54, 103, 31, 29, 209, 132, 217, 140, 111, 10, 80, 240, 19, 114, 8])));
/// MK: GDMK222KST3XSPAQDI5N5CAC77P2WMTLDU3WXEMOZ7OIG7KYIOLFFJCC
static immutable MK = KeyPair(PublicKey(Point([216, 173, 107, 74, 148, 247, 121, 60, 16, 26, 58, 222, 136, 2, 255, 223, 171, 50, 107, 29, 55, 107, 145, 142, 207, 220, 131, 125, 88, 67, 150, 82])), SecretKey(Scalar([118, 161, 154, 25, 45, 139, 29, 135, 175, 66, 246, 37, 117, 48, 235, 136, 97, 199, 34, 142, 28, 84, 83, 133, 125, 249, 87, 240, 62, 108, 151, 8])));
/// ML: GDML22TRR7V4NXGA3Z3RLFUKX2C2KET3QTYL3N77G2KHMG7VHI27SCAR
static immutable ML = KeyPair(PublicKey(Point([216, 189, 106, 113, 143, 235, 198, 220, 192, 222, 119, 21, 150, 138, 190, 133, 165, 18, 123, 132, 240, 189, 183, 255, 54, 148, 118, 27, 245, 58, 53, 249])), SecretKey(Scalar([165, 80, 233, 15, 173, 120, 185, 164, 93, 174, 246, 92, 164, 168, 12, 118, 243, 94, 250, 206, 135, 147, 4, 239, 94, 110, 20, 92, 36, 10, 96, 2])));
/// MM: GDMM22HU5TXNS3OZPYCZGI37BMDC2TAOA2PQEECEWKN3ZCPOMTHNZJV3
static immutable MM = KeyPair(PublicKey(Point([216, 205, 104, 244, 236, 238, 217, 109, 217, 126, 5, 147, 35, 127, 11, 6, 45, 76, 14, 6, 159, 2, 16, 68, 178, 155, 188, 137, 238, 100, 206, 220])), SecretKey(Scalar([3, 162, 254, 230, 81, 197, 230, 178, 193, 171, 250, 55, 108, 30, 60, 187, 115, 17, 3, 178, 45, 112, 8, 192, 65, 121, 248, 54, 28, 45, 126, 10])));
/// MN: GDMN22ULV6PLE2YCYMCMQ67RG776ZVTLDZLOYUOFY2JB4P52QPTA7P6V
static immutable MN = KeyPair(PublicKey(Point([216, 221, 106, 139, 175, 158, 178, 107, 2, 195, 4, 200, 123, 241, 55, 255, 236, 214, 107, 30, 86, 236, 81, 197, 198, 146, 30, 63, 186, 131, 230, 15])), SecretKey(Scalar([158, 208, 173, 181, 60, 228, 28, 186, 60, 95, 142, 135, 15, 63, 98, 60, 93, 88, 80, 52, 65, 44, 5, 172, 206, 250, 104, 64, 65, 52, 39, 8])));
/// MO: GDMO22FMGD4RRTRBRG4HZPQEMPPSXNTOKQ2AYBVTD5PPWES42LOEYPU3
static immutable MO = KeyPair(PublicKey(Point([216, 237, 104, 172, 48, 249, 24, 206, 33, 137, 184, 124, 190, 4, 99, 223, 43, 182, 110, 84, 52, 12, 6, 179, 31, 94, 251, 18, 92, 210, 220, 76])), SecretKey(Scalar([204, 201, 9, 99, 174, 43, 28, 228, 47, 95, 115, 84, 144, 16, 231, 85, 235, 115, 195, 15, 168, 188, 251, 124, 106, 229, 110, 192, 7, 7, 235, 3])));
/// MP: GDMP22CUMHJY2VQT535HVNKMBQPXRSBF3ZVXDLNOHGTUVFIKKENLQINB
static immutable MP = KeyPair(PublicKey(Point([216, 253, 104, 84, 97, 211, 141, 86, 19, 238, 250, 122, 181, 76, 12, 31, 120, 200, 37, 222, 107, 113, 173, 174, 57, 167, 74, 149, 10, 81, 26, 184])), SecretKey(Scalar([84, 60, 33, 22, 21, 183, 205, 61, 167, 182, 243, 123, 87, 191, 243, 43, 174, 218, 8, 182, 251, 226, 42, 231, 92, 192, 138, 240, 17, 146, 145, 8])));
/// MQ: GDMQ22TXLVTJQF7A7FTOQQ22OKGABPJPP6DCN2V7MDTWK6RIYJYCOYXA
static immutable MQ = KeyPair(PublicKey(Point([217, 13, 106, 119, 93, 102, 152, 23, 224, 249, 102, 232, 67, 90, 114, 140, 0, 189, 47, 127, 134, 38, 234, 191, 96, 231, 101, 122, 40, 194, 112, 39])), SecretKey(Scalar([90, 177, 8, 115, 197, 193, 71, 113, 150, 95, 88, 117, 201, 126, 48, 240, 125, 159, 169, 48, 145, 181, 189, 37, 224, 17, 2, 122, 9, 36, 84, 13])));
/// MR: GDMR22JZZRLQGXFR4KL2DV3KPUOMFBDEGCHVBJTHWY6WG5SQQQHFIMAY
static immutable MR = KeyPair(PublicKey(Point([217, 29, 105, 57, 204, 87, 3, 92, 177, 226, 151, 161, 215, 106, 125, 28, 194, 132, 100, 48, 143, 80, 166, 103, 182, 61, 99, 118, 80, 132, 14, 84])), SecretKey(Scalar([213, 60, 30, 93, 60, 20, 79, 164, 146, 85, 190, 48, 217, 50, 65, 248, 202, 9, 75, 56, 63, 113, 59, 119, 11, 200, 18, 37, 87, 102, 203, 7])));
/// MS: GDMS22LPIEUQXKLKM5BD3I6BGH3BZE5CHZ6JTQYFPWMIXDXOVRNRJGG6
static immutable MS = KeyPair(PublicKey(Point([217, 45, 105, 111, 65, 41, 11, 169, 106, 103, 66, 61, 163, 193, 49, 246, 28, 147, 162, 62, 124, 153, 195, 5, 125, 152, 139, 142, 238, 172, 91, 20])), SecretKey(Scalar([225, 137, 215, 108, 67, 12, 174, 229, 226, 38, 45, 132, 212, 66, 224, 116, 122, 107, 193, 157, 62, 179, 28, 216, 10, 113, 192, 100, 123, 169, 112, 15])));
/// MT: GDMT22U3CX6TPG5EHR73TWNEWQTK7CSFPBHBT7V5FJTOSGXJP7LCY4SL
static immutable MT = KeyPair(PublicKey(Point([217, 61, 106, 155, 21, 253, 55, 155, 164, 60, 127, 185, 217, 164, 180, 38, 175, 138, 69, 120, 78, 25, 254, 189, 42, 102, 233, 26, 233, 127, 214, 44])), SecretKey(Scalar([25, 25, 104, 17, 242, 245, 51, 227, 47, 123, 168, 186, 22, 181, 130, 255, 122, 137, 192, 72, 222, 57, 217, 197, 39, 237, 77, 252, 241, 217, 163, 10])));
/// MU: GDMU227Z6EZAG3U32W3P3QLQV4IWUBI7TXHDP3NGOJ5ZTROUIQMFXNOE
static immutable MU = KeyPair(PublicKey(Point([217, 77, 107, 249, 241, 50, 3, 110, 155, 213, 182, 253, 193, 112, 175, 17, 106, 5, 31, 157, 206, 55, 237, 166, 114, 123, 153, 197, 212, 68, 24, 91])), SecretKey(Scalar([241, 181, 88, 113, 20, 211, 50, 188, 197, 60, 221, 13, 238, 48, 100, 99, 199, 135, 250, 204, 49, 215, 234, 126, 253, 221, 210, 67, 92, 94, 124, 3])));
/// MV: GDMV22H73CJDCZ7FE6XFYAMAAQTJA6EBZTSOQMUHX3W5O5VO7OYYLJIB
static immutable MV = KeyPair(PublicKey(Point([217, 93, 104, 255, 216, 146, 49, 103, 229, 39, 174, 92, 1, 128, 4, 38, 144, 120, 129, 204, 228, 232, 50, 135, 190, 237, 215, 118, 174, 251, 177, 133])), SecretKey(Scalar([112, 72, 109, 36, 35, 139, 252, 54, 213, 88, 34, 195, 243, 204, 235, 118, 236, 136, 229, 151, 6, 216, 131, 98, 44, 133, 86, 175, 34, 34, 215, 3])));
/// MW: GDMW22QGN4DEDJFNANKUMF4GU2ZIONATFHS6VXAMMCHMIBBB4H26CWMW
static immutable MW = KeyPair(PublicKey(Point([217, 109, 106, 6, 111, 6, 65, 164, 173, 3, 85, 70, 23, 134, 166, 178, 135, 52, 19, 41, 229, 234, 220, 12, 96, 142, 196, 4, 33, 225, 245, 225])), SecretKey(Scalar([30, 88, 50, 41, 79, 73, 172, 204, 19, 56, 22, 37, 47, 203, 27, 239, 249, 206, 26, 167, 12, 117, 60, 244, 158, 39, 193, 85, 244, 215, 252, 0])));
/// MX: GDMX22ALQHXGK5DUMXTKBVCT2LZKLUO6MPEL5DQ5I6J4MRPNUCNZVL6G
static immutable MX = KeyPair(PublicKey(Point([217, 125, 104, 11, 129, 238, 101, 116, 116, 101, 230, 160, 212, 83, 210, 242, 165, 209, 222, 99, 200, 190, 142, 29, 71, 147, 198, 69, 237, 160, 155, 154])), SecretKey(Scalar([102, 153, 84, 137, 126, 186, 254, 49, 184, 244, 54, 219, 95, 63, 173, 11, 174, 221, 128, 100, 48, 27, 211, 43, 175, 42, 127, 48, 233, 79, 145, 13])));
/// MY: GDMY22WEKWAHGLCWJSPKQ452XSSDS4EPE7LXMVOI6LT7P3T426MS37OS
static immutable MY = KeyPair(PublicKey(Point([217, 141, 106, 196, 85, 128, 115, 44, 86, 76, 158, 168, 115, 186, 188, 164, 57, 112, 143, 39, 215, 118, 85, 200, 242, 231, 247, 238, 124, 215, 153, 45])), SecretKey(Scalar([72, 83, 41, 112, 76, 252, 83, 201, 19, 125, 32, 205, 42, 213, 227, 7, 33, 10, 4, 24, 217, 40, 47, 73, 50, 99, 189, 136, 220, 17, 226, 15])));
/// MZ: GDMZ22EMSCUUBJX2SWL5S7UFFGZITZTNQFNEKT6LHQX4CDWFJBAAEX6M
static immutable MZ = KeyPair(PublicKey(Point([217, 157, 104, 140, 144, 169, 64, 166, 250, 149, 151, 217, 126, 133, 41, 178, 137, 230, 109, 129, 90, 69, 79, 203, 60, 47, 193, 14, 197, 72, 64, 2])), SecretKey(Scalar([134, 78, 156, 1, 90, 142, 153, 35, 201, 196, 94, 138, 145, 56, 85, 27, 197, 198, 44, 235, 110, 215, 177, 72, 61, 147, 207, 143, 215, 4, 120, 5])));
/// NA: GDNA22II4PDPYVYBMHX47Y3YKTIC3AMTPLJCKBEW23E43F53CKOFEJFF
static immutable NA = KeyPair(PublicKey(Point([218, 13, 105, 8, 227, 198, 252, 87, 1, 97, 239, 207, 227, 120, 84, 208, 45, 129, 147, 122, 210, 37, 4, 150, 214, 201, 205, 151, 187, 18, 156, 82])), SecretKey(Scalar([90, 101, 204, 120, 160, 118, 177, 202, 20, 25, 161, 71, 182, 92, 28, 231, 2, 237, 111, 214, 104, 48, 36, 156, 64, 245, 53, 45, 53, 53, 113, 12])));
/// NB: GDNB22VX2EEFPROFUESUZXFIWOZGJTET6KSNEZ5QVWBJJSMHWXVYLSP7
static immutable NB = KeyPair(PublicKey(Point([218, 29, 106, 183, 209, 8, 87, 197, 197, 161, 37, 76, 220, 168, 179, 178, 100, 204, 147, 242, 164, 210, 103, 176, 173, 130, 148, 201, 135, 181, 235, 133])), SecretKey(Scalar([36, 112, 104, 112, 205, 45, 63, 142, 76, 135, 240, 205, 223, 29, 133, 195, 87, 254, 122, 196, 246, 125, 111, 253, 85, 16, 113, 199, 175, 212, 95, 11])));
/// NC: GDNC225NCW3NQPYCJCPUHKOEHVKUQ3AZ2DFXGLZ6IZMGBHPUUJAAPNI7
static immutable NC = KeyPair(PublicKey(Point([218, 45, 107, 173, 21, 182, 216, 63, 2, 72, 159, 67, 169, 196, 61, 85, 72, 108, 25, 208, 203, 115, 47, 62, 70, 88, 96, 157, 244, 162, 64, 7])), SecretKey(Scalar([203, 198, 5, 159, 86, 82, 83, 187, 32, 250, 20, 45, 244, 252, 193, 196, 9, 231, 21, 104, 65, 230, 170, 12, 198, 96, 26, 98, 203, 157, 255, 13])));
/// ND: GDND225V3VFKWXHRNVG4252MAHLVTIBRONIJYNI3SOBYNIYQ6B2FEG2A
static immutable ND = KeyPair(PublicKey(Point([218, 61, 107, 181, 221, 74, 171, 92, 241, 109, 77, 205, 119, 76, 1, 215, 89, 160, 49, 115, 80, 156, 53, 27, 147, 131, 134, 163, 16, 240, 116, 82])), SecretKey(Scalar([248, 47, 245, 47, 91, 152, 213, 198, 178, 227, 239, 83, 188, 112, 14, 246, 58, 7, 152, 248, 163, 162, 224, 61, 18, 174, 27, 254, 179, 64, 240, 8])));
/// NE: GDNE22DVMAGKIZJ3SUNMXUUJBM4RVGSFXX6RHURE6CQSG5YHZMXQLZKR
static immutable NE = KeyPair(PublicKey(Point([218, 77, 104, 117, 96, 12, 164, 101, 59, 149, 26, 203, 210, 137, 11, 57, 26, 154, 69, 189, 253, 19, 210, 36, 240, 161, 35, 119, 7, 203, 47, 5])), SecretKey(Scalar([169, 60, 9, 106, 14, 112, 16, 238, 131, 42, 224, 24, 107, 163, 238, 206, 109, 127, 65, 96, 220, 139, 145, 177, 126, 170, 116, 132, 129, 66, 88, 1])));
/// NF: GDNF22ZK7X22B2VJQYD5TCL2FNSCHJF23PLIDCN33NBWNTSFMK4Z6RDS
static immutable NF = KeyPair(PublicKey(Point([218, 93, 107, 42, 253, 245, 160, 234, 169, 134, 7, 217, 137, 122, 43, 100, 35, 164, 186, 219, 214, 129, 137, 187, 219, 67, 102, 206, 69, 98, 185, 159])), SecretKey(Scalar([28, 82, 94, 16, 62, 190, 227, 93, 229, 227, 69, 111, 196, 52, 78, 173, 104, 113, 27, 65, 174, 172, 79, 155, 105, 32, 128, 24, 200, 66, 76, 13])));
/// NG: GDNG22KRYM3SOALIQZGJVRE5EWYUUK2YD2SMOUGL7KTVUUPH57IOMWPY
static immutable NG = KeyPair(PublicKey(Point([218, 109, 105, 81, 195, 55, 39, 1, 104, 134, 76, 154, 196, 157, 37, 177, 74, 43, 88, 30, 164, 199, 80, 203, 250, 167, 90, 81, 231, 239, 208, 230])), SecretKey(Scalar([196, 232, 114, 154, 142, 253, 103, 162, 243, 97, 156, 171, 50, 50, 73, 59, 34, 57, 136, 116, 199, 226, 130, 196, 103, 4, 216, 247, 43, 199, 246, 6])));
/// NH: GDNH22DK3G473FZKLE22GPTMUEAUSMVDML6DEMI7KY5JLI264IABBBRM
static immutable NH = KeyPair(PublicKey(Point([218, 125, 104, 106, 217, 185, 253, 151, 42, 89, 53, 163, 62, 108, 161, 1, 73, 50, 163, 98, 252, 50, 49, 31, 86, 58, 149, 163, 94, 226, 0, 16])), SecretKey(Scalar([160, 56, 11, 35, 230, 103, 160, 192, 30, 172, 210, 86, 142, 169, 10, 129, 248, 27, 154, 182, 218, 218, 33, 178, 80, 127, 118, 157, 48, 215, 70, 10])));
/// NI: GDNI2247MVRZMYJMOMXXFTG7A4H6WYCNR32POQIZVMSEFHE6QEVLEJDD
static immutable NI = KeyPair(PublicKey(Point([218, 141, 107, 159, 101, 99, 150, 97, 44, 115, 47, 114, 204, 223, 7, 15, 235, 96, 77, 142, 244, 247, 65, 25, 171, 36, 66, 156, 158, 129, 42, 178])), SecretKey(Scalar([35, 59, 115, 91, 142, 218, 239, 67, 227, 254, 134, 83, 50, 187, 53, 90, 10, 36, 202, 228, 58, 54, 20, 227, 198, 86, 84, 240, 232, 106, 14, 9])));
/// NJ: GDNJ222DRU5Z4Q2VJPEHBYA5YU3AKC7QP6IGFHWCWBCIHVUCJP5OW4SN
static immutable NJ = KeyPair(PublicKey(Point([218, 157, 107, 67, 141, 59, 158, 67, 85, 75, 200, 112, 224, 29, 197, 54, 5, 11, 240, 127, 144, 98, 158, 194, 176, 68, 131, 214, 130, 75, 250, 235])), SecretKey(Scalar([84, 52, 140, 37, 59, 32, 217, 38, 204, 212, 174, 150, 212, 176, 204, 149, 143, 163, 134, 158, 94, 24, 88, 66, 179, 131, 34, 18, 134, 182, 130, 2])));
/// NK: GDNK22TGASQE5DIM7TADTQ3UEVZ5QPER6UKQQ7QAPY5XFMNAJOL4JJHH
static immutable NK = KeyPair(PublicKey(Point([218, 173, 106, 102, 4, 160, 78, 141, 12, 252, 192, 57, 195, 116, 37, 115, 216, 60, 145, 245, 21, 8, 126, 0, 126, 59, 114, 177, 160, 75, 151, 196])), SecretKey(Scalar([225, 30, 1, 251, 57, 65, 141, 249, 246, 186, 252, 227, 98, 253, 46, 40, 128, 94, 178, 54, 86, 167, 228, 13, 69, 1, 98, 179, 76, 222, 225, 14])));
/// NL: GDNL22PC3UICVUI4B4W7XA6JOD7KLERTUAUZEWZX6DVWG3GGPXCW27SH
static immutable NL = KeyPair(PublicKey(Point([218, 189, 105, 226, 221, 16, 42, 209, 28, 15, 45, 251, 131, 201, 112, 254, 165, 146, 51, 160, 41, 146, 91, 55, 240, 235, 99, 108, 198, 125, 197, 109])), SecretKey(Scalar([79, 208, 214, 136, 168, 79, 140, 206, 202, 208, 6, 110, 195, 235, 215, 35, 246, 206, 136, 174, 55, 175, 6, 202, 191, 171, 248, 6, 91, 132, 221, 13])));
/// NM: GDNM22KLU6NMLZ2DPHYP2CK4LLX2YA2TOYB7WUEVSAYISZ3WXJPQB2TM
static immutable NM = KeyPair(PublicKey(Point([218, 205, 105, 75, 167, 154, 197, 231, 67, 121, 240, 253, 9, 92, 90, 239, 172, 3, 83, 118, 3, 251, 80, 149, 144, 48, 137, 103, 118, 186, 95, 0])), SecretKey(Scalar([58, 124, 194, 133, 57, 115, 218, 109, 149, 231, 168, 105, 176, 81, 32, 228, 128, 187, 240, 196, 226, 118, 11, 136, 15, 157, 38, 6, 204, 43, 24, 10])));
/// NN: GDNN224F2BVIXI6VYY75HFXPTHXYQFK4FH5BIKMEWDDEV7HA2ZEW5HVX
static immutable NN = KeyPair(PublicKey(Point([218, 221, 107, 133, 208, 106, 139, 163, 213, 198, 63, 211, 150, 239, 153, 239, 136, 21, 92, 41, 250, 20, 41, 132, 176, 198, 74, 252, 224, 214, 73, 110])), SecretKey(Scalar([28, 178, 187, 163, 198, 224, 73, 156, 138, 81, 210, 176, 186, 226, 37, 43, 6, 228, 202, 102, 201, 221, 233, 52, 136, 82, 96, 200, 87, 15, 50, 12])));
/// NO: GDNO222YKSTIMPYCDYUAOD7ANTMS2HXWMDM7YB6YMB36NACYALK6372O
static immutable NO = KeyPair(PublicKey(Point([218, 237, 107, 88, 84, 166, 134, 63, 2, 30, 40, 7, 15, 224, 108, 217, 45, 30, 246, 96, 217, 252, 7, 216, 96, 119, 230, 128, 88, 2, 213, 237])), SecretKey(Scalar([221, 197, 51, 228, 36, 242, 10, 102, 80, 241, 169, 37, 130, 95, 148, 155, 26, 105, 164, 5, 69, 75, 80, 13, 87, 64, 194, 152, 172, 147, 115, 13])));
/// NP: GDNP22EKXWRQLWUUIQRL57S6SJBGELUKJ3G43ZN4ETMZPX3JINXIDRI5
static immutable NP = KeyPair(PublicKey(Point([218, 253, 104, 138, 189, 163, 5, 218, 148, 68, 34, 190, 254, 94, 146, 66, 98, 46, 138, 78, 205, 205, 229, 188, 36, 217, 151, 223, 105, 67, 110, 129])), SecretKey(Scalar([109, 137, 5, 105, 208, 91, 224, 5, 3, 224, 115, 163, 138, 198, 42, 106, 126, 128, 15, 129, 229, 250, 132, 149, 214, 34, 174, 166, 178, 106, 196, 9])));
/// NQ: GDNQ22HH7ASVUWJD5DWC6G5JSFZQS4QFUUV2BEP7H2LPJDYG2LOBIZDV
static immutable NQ = KeyPair(PublicKey(Point([219, 13, 104, 231, 248, 37, 90, 89, 35, 232, 236, 47, 27, 169, 145, 115, 9, 114, 5, 165, 43, 160, 145, 255, 62, 150, 244, 143, 6, 210, 220, 20])), SecretKey(Scalar([73, 19, 251, 38, 84, 117, 96, 9, 173, 132, 161, 99, 164, 119, 118, 162, 95, 254, 78, 150, 125, 60, 178, 122, 229, 87, 43, 201, 125, 250, 63, 13])));
/// NR: GDNR22MZTZY2JAXCHHU5X6WI2YS7HRLAVAXPDZ56Y5KPENTFVPDPALKN
static immutable NR = KeyPair(PublicKey(Point([219, 29, 105, 153, 158, 113, 164, 130, 226, 57, 233, 219, 250, 200, 214, 37, 243, 197, 96, 168, 46, 241, 231, 190, 199, 84, 242, 54, 101, 171, 198, 240])), SecretKey(Scalar([236, 231, 225, 247, 111, 169, 172, 101, 147, 52, 55, 100, 58, 99, 141, 77, 163, 43, 248, 43, 155, 2, 164, 36, 131, 120, 214, 79, 96, 128, 89, 0])));
/// NS: GDNS22J5ZLVVEAYWWUUJHVO4LDARW4WA234NZU4QYKFMWLQMWGFAM3VN
static immutable NS = KeyPair(PublicKey(Point([219, 45, 105, 61, 202, 235, 82, 3, 22, 181, 40, 147, 213, 220, 88, 193, 27, 114, 192, 214, 248, 220, 211, 144, 194, 138, 203, 46, 12, 177, 138, 6])), SecretKey(Scalar([133, 145, 79, 215, 29, 103, 244, 2, 206, 148, 134, 71, 196, 67, 20, 169, 227, 252, 216, 88, 229, 87, 224, 79, 241, 7, 14, 59, 144, 144, 113, 13])));
/// NT: GDNT22EMUJ7Z43UDBNKD2QPK4GDC3VEWMSVZFT4YSIT3TLSNBAHWQFDP
static immutable NT = KeyPair(PublicKey(Point([219, 61, 104, 140, 162, 127, 158, 110, 131, 11, 84, 61, 65, 234, 225, 134, 45, 212, 150, 100, 171, 146, 207, 152, 146, 39, 185, 174, 77, 8, 15, 104])), SecretKey(Scalar([218, 99, 235, 252, 236, 195, 85, 10, 198, 189, 232, 196, 95, 14, 18, 249, 16, 14, 190, 76, 165, 3, 31, 77, 85, 164, 220, 110, 158, 227, 168, 2])));
/// NU: GDNU22CRDIAGHLGHONYGOKKSIZTCD3Y6SHNIEDHHPKAWJTZZNEYSMF6Z
static immutable NU = KeyPair(PublicKey(Point([219, 77, 104, 81, 26, 0, 99, 172, 199, 115, 112, 103, 41, 82, 70, 102, 33, 239, 30, 145, 218, 130, 12, 231, 122, 129, 100, 207, 57, 105, 49, 38])), SecretKey(Scalar([61, 12, 142, 249, 234, 164, 196, 188, 231, 31, 232, 14, 90, 26, 171, 135, 200, 209, 250, 97, 106, 80, 62, 232, 152, 85, 215, 80, 22, 94, 71, 0])));
/// NV: GDNV22ZF7VWXJFISLQL6H7OIZ7ALVA2GCU2MMD7LEVK4ZENGXJYZCLO2
static immutable NV = KeyPair(PublicKey(Point([219, 93, 107, 37, 253, 109, 116, 149, 18, 92, 23, 227, 253, 200, 207, 192, 186, 131, 70, 21, 52, 198, 15, 235, 37, 85, 204, 145, 166, 186, 113, 145])), SecretKey(Scalar([49, 10, 124, 166, 208, 85, 5, 220, 162, 197, 91, 45, 232, 144, 240, 158, 245, 137, 32, 165, 56, 104, 214, 240, 157, 47, 95, 49, 132, 45, 107, 11])));
/// NW: GDNW223RRPEDRGFBWGZEH34MH4NPVBSQWZNMZ3DDLFEJYDEEEOVKD5XG
static immutable NW = KeyPair(PublicKey(Point([219, 109, 107, 113, 139, 200, 56, 152, 161, 177, 178, 67, 239, 140, 63, 26, 250, 134, 80, 182, 90, 204, 236, 99, 89, 72, 156, 12, 132, 35, 170, 161])), SecretKey(Scalar([9, 151, 175, 126, 152, 61, 96, 103, 254, 50, 58, 111, 148, 155, 86, 153, 221, 98, 234, 55, 224, 55, 163, 70, 117, 175, 50, 227, 0, 111, 36, 7])));
/// NX: GDNX22X5YVO3LSXISLXS5KZXOJVMT6MXFDORSMQZITULQTDBNKADWSSN
static immutable NX = KeyPair(PublicKey(Point([219, 125, 106, 253, 197, 93, 181, 202, 232, 146, 239, 46, 171, 55, 114, 106, 201, 249, 151, 40, 221, 25, 50, 25, 68, 232, 184, 76, 97, 106, 128, 59])), SecretKey(Scalar([135, 145, 247, 227, 220, 145, 0, 1, 107, 122, 212, 224, 186, 150, 66, 250, 154, 230, 230, 14, 17, 202, 246, 217, 194, 140, 65, 222, 222, 51, 148, 4])));
/// NY: GDNY22WMQSVTJYMSYKUEMM3O7UTB5XJDAWPLOCTB234UHAPJHEQVON52
static immutable NY = KeyPair(PublicKey(Point([219, 141, 106, 204, 132, 171, 52, 225, 146, 194, 168, 70, 51, 110, 253, 38, 30, 221, 35, 5, 158, 183, 10, 97, 214, 249, 67, 129, 233, 57, 33, 87])), SecretKey(Scalar([26, 161, 5, 28, 61, 152, 215, 140, 165, 116, 145, 172, 27, 35, 195, 138, 206, 121, 118, 250, 31, 246, 104, 46, 55, 2, 136, 224, 96, 205, 239, 0])));
/// NZ: GDNZ22EJPMHDHCPGODZPDZVM4HFFY2AAMTVV53TVAZ3SYHTQHL4DDNEN
static immutable NZ = KeyPair(PublicKey(Point([219, 157, 104, 137, 123, 14, 51, 137, 230, 112, 242, 241, 230, 172, 225, 202, 92, 104, 0, 100, 235, 94, 238, 117, 6, 119, 44, 30, 112, 58, 248, 49])), SecretKey(Scalar([194, 30, 175, 34, 83, 46, 103, 210, 155, 8, 37, 27, 164, 233, 71, 75, 15, 75, 10, 68, 18, 31, 152, 38, 71, 56, 227, 204, 142, 49, 63, 14])));
/// OA: GDOA22575Q4U2RI7LV6QGKBNSFCI2GEPCNMWI744Y7NY3GZ3T6FTCIQO
static immutable OA = KeyPair(PublicKey(Point([220, 13, 107, 191, 236, 57, 77, 69, 31, 93, 125, 3, 40, 45, 145, 68, 141, 24, 143, 19, 89, 100, 127, 156, 199, 219, 141, 155, 59, 159, 139, 49])), SecretKey(Scalar([12, 143, 133, 117, 115, 203, 89, 167, 56, 208, 108, 141, 185, 25, 245, 196, 46, 206, 80, 193, 93, 238, 148, 226, 133, 204, 44, 92, 67, 82, 135, 10])));
/// OB: GDOB22JFGAA6FGFXUTUOJ6MAAAEZKLUUGSSXJSJOOFLUMTILW6HE7UJH
static immutable OB = KeyPair(PublicKey(Point([220, 29, 105, 37, 48, 1, 226, 152, 183, 164, 232, 228, 249, 128, 0, 9, 149, 46, 148, 52, 165, 116, 201, 46, 113, 87, 70, 77, 11, 183, 142, 79])), SecretKey(Scalar([52, 196, 21, 163, 130, 81, 70, 249, 21, 203, 189, 20, 183, 191, 240, 64, 140, 110, 213, 127, 214, 5, 252, 212, 9, 130, 150, 171, 55, 10, 191, 15])));
/// OC: GDOC22ZA6AUS6WSEPVUOB3AGX6AZTK4CSGEIWJILDI6N474L7YEMMZFS
static immutable OC = KeyPair(PublicKey(Point([220, 45, 107, 32, 240, 41, 47, 90, 68, 125, 104, 224, 236, 6, 191, 129, 153, 171, 130, 145, 136, 139, 37, 11, 26, 60, 222, 127, 139, 254, 8, 198])), SecretKey(Scalar([49, 170, 194, 208, 237, 226, 71, 21, 26, 152, 176, 129, 161, 123, 202, 45, 46, 68, 61, 110, 141, 40, 79, 204, 144, 208, 144, 224, 5, 81, 44, 5])));
/// OD: GDOD22T42X7RTCOBWKBSZ6ABF45VWKYDC4IZZITRS2E6R3VQGF7C77HF
static immutable OD = KeyPair(PublicKey(Point([220, 61, 106, 124, 213, 255, 25, 137, 193, 178, 131, 44, 248, 1, 47, 59, 91, 43, 3, 23, 17, 156, 162, 113, 150, 137, 232, 238, 176, 49, 126, 47])), SecretKey(Scalar([167, 55, 118, 227, 15, 72, 177, 237, 13, 141, 17, 195, 0, 22, 91, 143, 189, 235, 99, 202, 248, 36, 142, 103, 89, 199, 165, 99, 153, 224, 10, 9])));
/// OE: GDOE227AC32CR7USTDZ3HAIYJKJO5OZBHT5EQRKODOB3DYIOWTPXRVZR
static immutable OE = KeyPair(PublicKey(Point([220, 77, 107, 224, 22, 244, 40, 254, 146, 152, 243, 179, 129, 24, 74, 146, 238, 187, 33, 60, 250, 72, 69, 78, 27, 131, 177, 225, 14, 180, 223, 120])), SecretKey(Scalar([141, 113, 1, 225, 160, 204, 11, 70, 183, 136, 39, 150, 195, 48, 219, 25, 33, 225, 76, 145, 10, 96, 66, 141, 182, 150, 133, 247, 59, 72, 37, 6])));
/// OF: GDOF22VWBID32CWZYNCNCAM7WZLFBE7RZBXH5TDBKC4MNDMG3NJNFTSQ
static immutable OF = KeyPair(PublicKey(Point([220, 93, 106, 182, 10, 7, 189, 10, 217, 195, 68, 209, 1, 159, 182, 86, 80, 147, 241, 200, 110, 126, 204, 97, 80, 184, 198, 141, 134, 219, 82, 210])), SecretKey(Scalar([181, 179, 71, 231, 209, 244, 204, 85, 105, 123, 100, 48, 176, 21, 187, 105, 120, 32, 147, 136, 99, 144, 237, 185, 154, 31, 109, 178, 9, 78, 192, 14])));
/// OG: GDOG223U45F2ADI6HO7T5EJBLUHGGHVCQG77ISNVLHY5SF2B2CJK7BYV
static immutable OG = KeyPair(PublicKey(Point([220, 109, 107, 116, 231, 75, 160, 13, 30, 59, 191, 62, 145, 33, 93, 14, 99, 30, 162, 129, 191, 244, 73, 181, 89, 241, 217, 23, 65, 208, 146, 175])), SecretKey(Scalar([111, 215, 9, 46, 158, 67, 225, 146, 228, 164, 109, 9, 213, 241, 215, 252, 126, 173, 162, 232, 202, 213, 165, 52, 153, 14, 218, 165, 208, 170, 190, 14])));
/// OH: GDOH22OUPPIZFU2ZLHREU65BMT5BGLQUDXZYOXUIKAODA3HHC6PNOCQP
static immutable OH = KeyPair(PublicKey(Point([220, 125, 105, 212, 123, 209, 146, 211, 89, 89, 226, 74, 123, 161, 100, 250, 19, 46, 20, 29, 243, 135, 94, 136, 80, 28, 48, 108, 231, 23, 158, 215])), SecretKey(Scalar([30, 127, 111, 117, 252, 58, 200, 230, 104, 143, 63, 102, 248, 230, 39, 240, 3, 28, 75, 183, 69, 79, 235, 111, 92, 114, 176, 4, 218, 208, 153, 14])));
/// OI: GDOI22LCOYATHPEAH3CDSFUHGJLNTZ3GZEGSEZUS3BDE5SMSVOQ3SKGX
static immutable OI = KeyPair(PublicKey(Point([220, 141, 105, 98, 118, 1, 51, 188, 128, 62, 196, 57, 22, 135, 50, 86, 217, 231, 102, 201, 13, 34, 102, 146, 216, 70, 78, 201, 146, 171, 161, 185])), SecretKey(Scalar([255, 186, 136, 25, 75, 10, 225, 5, 84, 224, 28, 154, 73, 175, 224, 28, 59, 234, 49, 14, 32, 200, 125, 67, 121, 10, 226, 35, 77, 105, 184, 12])));
/// OJ: GDOJ22ACNKZP5DO7353EYTRKJ5QDSDF4BGTJGV6EC5U6LBME6SXZPXS2
static immutable OJ = KeyPair(PublicKey(Point([220, 157, 104, 2, 106, 178, 254, 141, 223, 223, 118, 76, 78, 42, 79, 96, 57, 12, 188, 9, 166, 147, 87, 196, 23, 105, 229, 133, 132, 244, 175, 151])), SecretKey(Scalar([30, 245, 122, 162, 209, 210, 103, 89, 124, 203, 61, 188, 195, 24, 164, 221, 119, 34, 29, 25, 203, 30, 222, 206, 91, 160, 59, 5, 105, 90, 67, 11])));
/// OK: GDOK223I5KPF35RIDW5DU3PKVIFSRRMHGUBHJ57WWBQZA5HDUHO6DQAE
static immutable OK = KeyPair(PublicKey(Point([220, 173, 107, 104, 234, 158, 93, 246, 40, 29, 186, 58, 109, 234, 170, 11, 40, 197, 135, 53, 2, 116, 247, 246, 176, 97, 144, 116, 227, 161, 221, 225])), SecretKey(Scalar([99, 188, 101, 159, 107, 152, 162, 30, 249, 33, 35, 61, 119, 40, 101, 226, 170, 197, 67, 254, 144, 208, 170, 105, 201, 250, 100, 35, 66, 126, 164, 13])));
/// OL: GDOL22EPE65R3XKLPF4LS4JCUONJP56FHSPUAA5QV3PNRUQH53GPTDOO
static immutable OL = KeyPair(PublicKey(Point([220, 189, 104, 143, 39, 187, 29, 221, 75, 121, 120, 185, 113, 34, 163, 154, 151, 247, 197, 60, 159, 64, 3, 176, 174, 222, 216, 210, 7, 238, 204, 249])), SecretKey(Scalar([165, 82, 16, 45, 131, 22, 191, 200, 132, 15, 84, 204, 48, 166, 150, 249, 85, 230, 131, 23, 114, 200, 165, 28, 187, 93, 252, 206, 59, 147, 121, 2])));
/// OM: GDOM22YPJOV6X5BDZISTV3ZNCKIR6DDITWYMNOCQTBPJ4FC4P7NAIUVM
static immutable OM = KeyPair(PublicKey(Point([220, 205, 107, 15, 75, 171, 235, 244, 35, 202, 37, 58, 239, 45, 18, 145, 31, 12, 104, 157, 176, 198, 184, 80, 152, 94, 158, 20, 92, 127, 218, 4])), SecretKey(Scalar([190, 236, 67, 152, 94, 167, 169, 32, 250, 179, 94, 158, 127, 76, 225, 246, 46, 40, 14, 36, 253, 81, 179, 15, 252, 69, 211, 205, 59, 27, 179, 6])));
/// ON: GDON22TOIUA7U33CXI2QF7X6DHEXOWUOHWCA56UUYDJZKIZCQQGQEA7A
static immutable ON = KeyPair(PublicKey(Point([220, 221, 106, 110, 69, 1, 250, 111, 98, 186, 53, 2, 254, 254, 25, 201, 119, 90, 142, 61, 132, 14, 250, 148, 192, 211, 149, 35, 34, 132, 13, 2])), SecretKey(Scalar([93, 204, 70, 134, 112, 132, 237, 64, 155, 140, 168, 5, 149, 240, 59, 85, 198, 44, 179, 133, 76, 119, 165, 192, 119, 20, 254, 178, 155, 106, 35, 14])));
/// OO: GDOO22T7JGO4JL7O4HHQC2KRCFJAZRQ7PR5LFTLHKGWOM4CG33HNFP4F
static immutable OO = KeyPair(PublicKey(Point([220, 237, 106, 127, 73, 157, 196, 175, 238, 225, 207, 1, 105, 81, 17, 82, 12, 198, 31, 124, 122, 178, 205, 103, 81, 172, 230, 112, 70, 222, 206, 210])), SecretKey(Scalar([250, 37, 178, 93, 224, 24, 205, 246, 225, 98, 165, 190, 167, 112, 202, 52, 238, 23, 253, 203, 10, 49, 174, 254, 14, 71, 204, 165, 174, 121, 213, 12])));
/// OP: GDOP22MSACJX7P3ZJDNOT7LLK6MBS5XF3TCUYAW5IJIJJVD5B3N3V4CM
static immutable OP = KeyPair(PublicKey(Point([220, 253, 105, 146, 0, 147, 127, 191, 121, 72, 218, 233, 253, 107, 87, 152, 25, 118, 229, 220, 197, 76, 2, 221, 66, 80, 148, 212, 125, 14, 219, 186])), SecretKey(Scalar([26, 49, 68, 48, 62, 152, 224, 167, 250, 4, 184, 140, 229, 29, 64, 122, 114, 10, 199, 69, 165, 216, 209, 16, 166, 11, 109, 14, 65, 74, 210, 8])));
/// OQ: GDOQ227H5VL6Y673GDEHLDJXM6Y7UYNCEMCCLBBHS6R5B7P2JHXXP5KY
static immutable OQ = KeyPair(PublicKey(Point([221, 13, 107, 231, 237, 87, 236, 123, 251, 48, 200, 117, 141, 55, 103, 177, 250, 97, 162, 35, 4, 37, 132, 39, 151, 163, 208, 253, 250, 73, 239, 119])), SecretKey(Scalar([201, 92, 195, 32, 238, 39, 41, 178, 172, 141, 254, 253, 97, 209, 196, 36, 137, 113, 88, 136, 248, 187, 235, 31, 83, 183, 85, 172, 148, 204, 15, 8])));
/// OR: GDOR225XGSYLRXV4SA3EMJ2PBPRU75Q54B7HB2MO5HLQYVRS5T42BI2Y
static immutable OR = KeyPair(PublicKey(Point([221, 29, 107, 183, 52, 176, 184, 222, 188, 144, 54, 70, 39, 79, 11, 227, 79, 246, 29, 224, 126, 112, 233, 142, 233, 215, 12, 86, 50, 236, 249, 160])), SecretKey(Scalar([228, 176, 170, 159, 14, 252, 52, 103, 244, 250, 43, 160, 100, 174, 84, 206, 247, 132, 9, 29, 62, 35, 175, 107, 253, 121, 211, 184, 234, 4, 198, 14])));
/// OS: GDOS22F3FGEBWFXIQUOK34FM3ESEQ62VSU2ZS6RAFUVU7JA7ELCSTTBY
static immutable OS = KeyPair(PublicKey(Point([221, 45, 104, 187, 41, 136, 27, 22, 232, 133, 28, 173, 240, 172, 217, 36, 72, 123, 85, 149, 53, 153, 122, 32, 45, 43, 79, 164, 31, 34, 197, 41])), SecretKey(Scalar([147, 241, 66, 227, 16, 24, 101, 129, 248, 207, 189, 97, 158, 117, 70, 1, 178, 220, 33, 120, 199, 209, 110, 139, 43, 174, 246, 26, 153, 2, 202, 1])));
/// OT: GDOT22UGXX7ZKHPEMFMB5RHJ42RNXRNYJWTVM6YICTJUTMISAJHICIWV
static immutable OT = KeyPair(PublicKey(Point([221, 61, 106, 134, 189, 255, 149, 29, 228, 97, 88, 30, 196, 233, 230, 162, 219, 197, 184, 77, 167, 86, 123, 8, 20, 211, 73, 177, 18, 2, 78, 129])), SecretKey(Scalar([42, 61, 114, 98, 202, 120, 31, 103, 123, 179, 131, 206, 184, 69, 148, 218, 205, 67, 151, 167, 111, 249, 151, 235, 120, 72, 220, 200, 52, 25, 52, 6])));
/// OU: GDOU22MLCDAIVYQRCPGPY6NJMAETHGSVLH3GKFNCOIIJ2WF5ONA4XEWR
static immutable OU = KeyPair(PublicKey(Point([221, 77, 105, 139, 16, 192, 138, 226, 17, 19, 204, 252, 121, 169, 96, 9, 51, 154, 85, 89, 246, 101, 21, 162, 114, 16, 157, 88, 189, 115, 65, 203])), SecretKey(Scalar([54, 101, 252, 81, 24, 32, 201, 148, 127, 191, 252, 175, 27, 22, 182, 172, 5, 37, 250, 202, 51, 197, 158, 82, 169, 209, 42, 68, 73, 229, 189, 12])));
/// OV: GDOV22ZYJ4OQHH6YDBLGRAICMASXMB2JUKULQ5I3UE7DBBMWXTZWXWLO
static immutable OV = KeyPair(PublicKey(Point([221, 93, 107, 56, 79, 29, 3, 159, 216, 24, 86, 104, 129, 2, 96, 37, 118, 7, 73, 162, 168, 184, 117, 27, 161, 62, 48, 133, 150, 188, 243, 107])), SecretKey(Scalar([5, 54, 230, 113, 26, 81, 112, 94, 229, 63, 59, 138, 24, 175, 48, 137, 124, 217, 123, 238, 73, 190, 148, 145, 52, 118, 47, 128, 175, 94, 122, 3])));
/// OW: GDOW22GFR5AFZUK6NSAX4PY7IE4N67JN2EFTBI3DXK4A7XYPLNH3ZKKW
static immutable OW = KeyPair(PublicKey(Point([221, 109, 104, 197, 143, 64, 92, 209, 94, 108, 129, 126, 63, 31, 65, 56, 223, 125, 45, 209, 11, 48, 163, 99, 186, 184, 15, 223, 15, 91, 79, 188])), SecretKey(Scalar([47, 46, 93, 90, 74, 101, 142, 36, 10, 225, 227, 49, 84, 200, 110, 24, 45, 81, 232, 211, 185, 129, 176, 16, 110, 208, 161, 135, 201, 36, 86, 14])));
/// OX: GDOX22SXJ4DPSITTU2P3JPQCVUF6DZWVUGBTNFVJNO72RG7EVJZYDRTV
static immutable OX = KeyPair(PublicKey(Point([221, 125, 106, 87, 79, 6, 249, 34, 115, 166, 159, 180, 190, 2, 173, 11, 225, 230, 213, 161, 131, 54, 150, 169, 107, 191, 168, 155, 228, 170, 115, 129])), SecretKey(Scalar([198, 42, 54, 242, 31, 239, 78, 149, 7, 3, 109, 200, 188, 66, 218, 141, 108, 128, 137, 162, 245, 207, 95, 32, 34, 113, 251, 133, 8, 178, 154, 4])));
/// OY: GDOY22KEXZVF2CALYJBNVHGHSIUTBDOKKITXCRFQK3NT5J2U5EWPEY5G
static immutable OY = KeyPair(PublicKey(Point([221, 141, 105, 68, 190, 106, 93, 8, 11, 194, 66, 218, 156, 199, 146, 41, 48, 141, 202, 82, 39, 113, 68, 176, 86, 219, 62, 167, 84, 233, 44, 242])), SecretKey(Scalar([34, 243, 101, 248, 174, 198, 136, 39, 73, 119, 17, 216, 135, 224, 156, 23, 159, 5, 23, 0, 245, 176, 176, 159, 86, 178, 193, 145, 129, 74, 180, 9])));
/// OZ: GDOZ22PRXK4LVLLAHYY2NLLNTBCAP7NYHOPTRBRN2TFNP6OGKKAU3LQ7
static immutable OZ = KeyPair(PublicKey(Point([221, 157, 105, 241, 186, 184, 186, 173, 96, 62, 49, 166, 173, 109, 152, 68, 7, 253, 184, 59, 159, 56, 134, 45, 212, 202, 215, 249, 198, 82, 129, 77])), SecretKey(Scalar([239, 152, 147, 210, 99, 77, 149, 180, 3, 151, 24, 73, 63, 235, 166, 116, 26, 162, 98, 2, 65, 0, 75, 227, 58, 26, 213, 90, 124, 197, 242, 5])));
/// PA: GDPA22XWR7XAOLTSC7KVMN37RS22HQI3TD4LPS2HQGJ4BPVP6UG37ZY6
static immutable PA = KeyPair(PublicKey(Point([222, 13, 106, 246, 143, 238, 7, 46, 114, 23, 213, 86, 55, 127, 140, 181, 163, 193, 27, 152, 248, 183, 203, 71, 129, 147, 192, 190, 175, 245, 13, 191])), SecretKey(Scalar([22, 74, 94, 9, 119, 195, 112, 118, 57, 222, 86, 62, 149, 153, 120, 201, 255, 248, 17, 111, 153, 170, 97, 117, 158, 243, 138, 10, 206, 159, 189, 5])));
/// PB: GDPB225IUNQBFWI4SLA7M6XPJ244BLU2PENUCHO26I33BQKBYXTKW5X5
static immutable PB = KeyPair(PublicKey(Point([222, 29, 107, 168, 163, 96, 18, 217, 28, 146, 193, 246, 122, 239, 78, 185, 192, 174, 154, 121, 27, 65, 29, 218, 242, 55, 176, 193, 65, 197, 230, 171])), SecretKey(Scalar([116, 186, 164, 246, 0, 14, 150, 64, 185, 193, 32, 149, 245, 248, 170, 40, 16, 2, 91, 68, 101, 35, 212, 222, 85, 12, 173, 55, 244, 44, 245, 13])));
/// PC: GDPC22ZLHKTPADXHNRNFCD45QGPQ6V47B6AXUZAOSYAR3YASZZYIE5TL
static immutable PC = KeyPair(PublicKey(Point([222, 45, 107, 43, 58, 166, 240, 14, 231, 108, 90, 81, 15, 157, 129, 159, 15, 87, 159, 15, 129, 122, 100, 14, 150, 1, 29, 224, 18, 206, 112, 130])), SecretKey(Scalar([119, 204, 250, 201, 197, 35, 226, 21, 45, 52, 203, 142, 186, 242, 28, 205, 122, 175, 215, 9, 175, 252, 171, 159, 240, 208, 49, 152, 18, 23, 48, 0])));
/// PD: GDPD22VIU3N3LIHVDLWCI3H53I36S4DV3TM74ZI52OO2SA74NWW6CJUX
static immutable PD = KeyPair(PublicKey(Point([222, 61, 106, 168, 166, 219, 181, 160, 245, 26, 236, 36, 108, 253, 218, 55, 233, 112, 117, 220, 217, 254, 101, 29, 211, 157, 169, 3, 252, 109, 173, 225])), SecretKey(Scalar([224, 55, 239, 142, 7, 57, 53, 171, 154, 82, 102, 25, 24, 165, 78, 12, 25, 67, 232, 13, 1, 30, 210, 78, 197, 7, 111, 59, 135, 65, 61, 7])));
/// PE: GDPE22WX4EQL6CHIDGM4EOSJ6TVJYFWRXSPTSYSXKYGH7L6C5VMV2ENT
static immutable PE = KeyPair(PublicKey(Point([222, 77, 106, 215, 225, 32, 191, 8, 232, 25, 153, 194, 58, 73, 244, 234, 156, 22, 209, 188, 159, 57, 98, 87, 86, 12, 127, 175, 194, 237, 89, 93])), SecretKey(Scalar([43, 61, 131, 30, 57, 122, 92, 163, 82, 225, 112, 167, 215, 39, 113, 153, 137, 15, 101, 71, 251, 59, 102, 51, 7, 145, 88, 50, 216, 220, 38, 4])));
/// PF: GDPF22NIFMWUJREZOH3JMO2KQF7WYH2Q24XOSOOQK4LQLJJMAGMYS7QO
static immutable PF = KeyPair(PublicKey(Point([222, 93, 105, 168, 43, 45, 68, 196, 153, 113, 246, 150, 59, 74, 129, 127, 108, 31, 80, 215, 46, 233, 57, 208, 87, 23, 5, 165, 44, 1, 153, 137])), SecretKey(Scalar([120, 70, 20, 207, 8, 80, 209, 226, 2, 209, 242, 209, 96, 85, 178, 188, 105, 32, 143, 4, 139, 212, 178, 230, 232, 161, 158, 223, 69, 219, 120, 2])));
/// PG: GDPG22YJVEYQCWX2DOZJSLYKKZWT7KFBLH5K6EN7VIDR2MMUAWFYFLOT
static immutable PG = KeyPair(PublicKey(Point([222, 109, 107, 9, 169, 49, 1, 90, 250, 27, 178, 153, 47, 10, 86, 109, 63, 168, 161, 89, 250, 175, 17, 191, 170, 7, 29, 49, 148, 5, 139, 130])), SecretKey(Scalar([153, 38, 98, 121, 163, 194, 249, 158, 133, 155, 252, 63, 62, 92, 46, 147, 208, 153, 231, 5, 209, 59, 183, 99, 254, 44, 34, 207, 252, 138, 148, 8])));
/// PH: GDPH227KHSBAXRZYEVWXMEMNLSGOGAXP7ZNQV56E4CW3XJSOIA3X3UJB
static immutable PH = KeyPair(PublicKey(Point([222, 125, 107, 234, 60, 130, 11, 199, 56, 37, 109, 118, 17, 141, 92, 140, 227, 2, 239, 254, 91, 10, 247, 196, 224, 173, 187, 166, 78, 64, 55, 125])), SecretKey(Scalar([161, 21, 9, 76, 190, 75, 192, 251, 173, 70, 72, 254, 192, 234, 199, 25, 14, 148, 242, 236, 240, 169, 103, 49, 176, 81, 254, 223, 205, 68, 180, 8])));
/// PI: GDPI227YBMKMEBHS5KXX27LJSMTHISBLW2L6GZXYXCGTPTCIFYG6UM6I
static immutable PI = KeyPair(PublicKey(Point([222, 141, 107, 248, 11, 20, 194, 4, 242, 234, 175, 125, 125, 105, 147, 38, 116, 72, 43, 182, 151, 227, 102, 248, 184, 141, 55, 204, 72, 46, 13, 234])), SecretKey(Scalar([109, 89, 18, 71, 163, 227, 166, 163, 124, 206, 39, 123, 191, 15, 252, 194, 233, 79, 128, 255, 144, 51, 33, 156, 68, 140, 5, 28, 141, 244, 24, 7])));
/// PJ: GDPJ22XBTUMU5OPD7ZQWOQR527Z6R6VKPO6EBVQPKA2SOTT7ALOHW4ET
static immutable PJ = KeyPair(PublicKey(Point([222, 157, 106, 225, 157, 25, 78, 185, 227, 254, 97, 103, 66, 61, 215, 243, 232, 250, 170, 123, 188, 64, 214, 15, 80, 53, 39, 78, 127, 2, 220, 123])), SecretKey(Scalar([128, 246, 245, 38, 109, 119, 120, 166, 48, 110, 7, 163, 131, 173, 35, 113, 197, 107, 231, 3, 9, 117, 31, 92, 20, 46, 114, 49, 28, 252, 221, 10])));
/// PK: GDPK22CEUOEAVX5RECZIUXWT4GU3K3CODFNZLPGKLPUWCCUGSFESLETT
static immutable PK = KeyPair(PublicKey(Point([222, 173, 104, 68, 163, 136, 10, 223, 177, 32, 178, 138, 94, 211, 225, 169, 181, 108, 78, 25, 91, 149, 188, 202, 91, 233, 97, 10, 134, 145, 73, 37])), SecretKey(Scalar([68, 22, 119, 116, 31, 135, 136, 170, 87, 173, 21, 22, 235, 181, 100, 148, 113, 78, 123, 241, 64, 224, 192, 209, 92, 124, 4, 7, 228, 24, 98, 15])));
/// PL: GDPL22AERID5KZXIYEUY7OV6SOMD33SKUKN3BJRENEFWQIZT3V46HPKO
static immutable PL = KeyPair(PublicKey(Point([222, 189, 104, 4, 138, 7, 213, 102, 232, 193, 41, 143, 186, 190, 147, 152, 61, 238, 74, 162, 155, 176, 166, 36, 105, 11, 104, 35, 51, 221, 121, 227])), SecretKey(Scalar([175, 74, 24, 188, 244, 137, 159, 30, 188, 167, 53, 214, 158, 231, 255, 101, 179, 210, 140, 104, 169, 25, 234, 114, 99, 213, 101, 26, 193, 111, 89, 0])));
/// PM: GDPM22TQBJ6I24KDXC3P4DJLMHY66F57JOLZDSJJ44WEBRKAM6SOOZSX
static immutable PM = KeyPair(PublicKey(Point([222, 205, 106, 112, 10, 124, 141, 113, 67, 184, 182, 254, 13, 43, 97, 241, 239, 23, 191, 75, 151, 145, 201, 41, 231, 44, 64, 197, 64, 103, 164, 231])), SecretKey(Scalar([185, 255, 108, 87, 175, 206, 13, 3, 210, 89, 20, 151, 167, 35, 149, 24, 16, 168, 167, 93, 43, 203, 105, 140, 118, 244, 92, 12, 156, 84, 52, 8])));
/// PN: GDPN22XBQWXRUS6D23HFSXFMQP6FWV3KBAQILPENWW5DPLNJLMTVE2LQ
static immutable PN = KeyPair(PublicKey(Point([222, 221, 106, 225, 133, 175, 26, 75, 195, 214, 206, 89, 92, 172, 131, 252, 91, 87, 106, 8, 32, 133, 188, 141, 181, 186, 55, 173, 169, 91, 39, 82])), SecretKey(Scalar([164, 114, 41, 27, 88, 35, 201, 31, 140, 79, 163, 156, 28, 229, 27, 167, 156, 113, 82, 68, 22, 71, 97, 217, 156, 11, 135, 195, 122, 197, 214, 4])));
/// PO: GDPO22YRJ4E2EBSJNGJADCUUENRHG2MDSUQ6RBLVBEPDQXSV7CNCCHK6
static immutable PO = KeyPair(PublicKey(Point([222, 237, 107, 17, 79, 9, 162, 6, 73, 105, 146, 1, 138, 148, 35, 98, 115, 105, 131, 149, 33, 232, 133, 117, 9, 30, 56, 94, 85, 248, 154, 33])), SecretKey(Scalar([55, 220, 17, 180, 28, 196, 128, 85, 150, 246, 235, 230, 41, 41, 176, 189, 255, 255, 39, 174, 153, 222, 19, 75, 178, 2, 90, 55, 86, 151, 30, 15])));
/// PP: GDPP22CHB6T33FMJXY7WDMON2GK6AMN5U2N6GIQTBD4OQA2YR5754HCY
static immutable PP = KeyPair(PublicKey(Point([222, 253, 104, 71, 15, 167, 189, 149, 137, 190, 63, 97, 177, 205, 209, 149, 224, 49, 189, 166, 155, 227, 34, 19, 8, 248, 232, 3, 88, 143, 127, 222])), SecretKey(Scalar([216, 124, 71, 66, 220, 206, 63, 255, 69, 109, 167, 96, 141, 197, 29, 147, 202, 17, 142, 238, 79, 251, 133, 93, 239, 186, 60, 187, 254, 58, 191, 13])));
/// PQ: GDPQ22HMTU643HONQDRNZWVE2U5YPKP3SWESVJGQQXQVFFM4MQE6BCRX
static immutable PQ = KeyPair(PublicKey(Point([223, 13, 104, 236, 157, 61, 205, 157, 205, 128, 226, 220, 218, 164, 213, 59, 135, 169, 251, 149, 137, 42, 164, 208, 133, 225, 82, 149, 156, 100, 9, 224])), SecretKey(Scalar([176, 145, 74, 134, 26, 42, 132, 110, 28, 122, 211, 252, 188, 134, 44, 229, 222, 155, 158, 202, 222, 119, 42, 105, 19, 120, 21, 185, 154, 50, 165, 10])));
/// PR: GDPR22MKR5WUWI2FKHBQ3C5DCJOL3KU6XLYOMIU3EMUJJRQBJ44IGNS2
static immutable PR = KeyPair(PublicKey(Point([223, 29, 105, 138, 143, 109, 75, 35, 69, 81, 195, 13, 139, 163, 18, 92, 189, 170, 158, 186, 240, 230, 34, 155, 35, 40, 148, 198, 1, 79, 56, 131])), SecretKey(Scalar([48, 45, 54, 161, 96, 126, 79, 50, 89, 108, 23, 208, 126, 196, 77, 106, 96, 93, 27, 28, 242, 205, 127, 98, 215, 221, 59, 125, 5, 37, 12, 4])));
/// PS: GDPS22QCM7YFTZ5SLKY4TNI2JZKPNRVYRULXDYGTMOVTOAMHITLO3V7W
static immutable PS = KeyPair(PublicKey(Point([223, 45, 106, 2, 103, 240, 89, 231, 178, 90, 177, 201, 181, 26, 78, 84, 246, 198, 184, 141, 23, 113, 224, 211, 99, 171, 55, 1, 135, 68, 214, 237])), SecretKey(Scalar([229, 226, 67, 70, 146, 150, 199, 171, 118, 91, 33, 95, 165, 65, 133, 245, 230, 26, 17, 158, 173, 181, 84, 26, 120, 122, 76, 182, 196, 47, 85, 8])));
/// PT: GDPT223F4IOVL7XHR3U73726T4VWRBT45F537U336GSWCTYQ5KGWJVSZ
static immutable PT = KeyPair(PublicKey(Point([223, 61, 107, 101, 226, 29, 85, 254, 231, 142, 233, 253, 255, 94, 159, 43, 104, 134, 124, 233, 123, 191, 211, 123, 241, 165, 97, 79, 16, 234, 141, 100])), SecretKey(Scalar([139, 105, 227, 33, 162, 237, 51, 190, 124, 158, 114, 82, 169, 36, 189, 200, 98, 218, 107, 128, 41, 54, 104, 132, 199, 180, 42, 61, 92, 86, 46, 6])));
/// PU: GDPU22YAXD27EXEOSXUSRDOMP7LZQDFVZ5ECG5RI2C35Q3YAI25ZKDH3
static immutable PU = KeyPair(PublicKey(Point([223, 77, 107, 0, 184, 245, 242, 92, 142, 149, 233, 40, 141, 204, 127, 215, 152, 12, 181, 207, 72, 35, 118, 40, 208, 183, 216, 111, 0, 70, 187, 149])), SecretKey(Scalar([17, 227, 20, 71, 143, 6, 212, 44, 49, 196, 40, 75, 83, 4, 203, 153, 211, 167, 182, 114, 132, 9, 60, 29, 247, 97, 117, 87, 182, 176, 149, 11])));
/// PV: GDPV22U7BF2F2PNVP7SPQ3VVN6XCKEUVPSI5UATNZKXP6MZANRVTC4PZ
static immutable PV = KeyPair(PublicKey(Point([223, 93, 106, 159, 9, 116, 93, 61, 181, 127, 228, 248, 110, 181, 111, 174, 37, 18, 149, 124, 145, 218, 2, 109, 202, 174, 255, 51, 32, 108, 107, 49])), SecretKey(Scalar([89, 135, 208, 98, 58, 74, 203, 157, 13, 250, 38, 157, 149, 17, 50, 40, 194, 94, 136, 239, 134, 220, 233, 59, 190, 160, 202, 139, 171, 84, 121, 12])));
/// PW: GDPW22FKAALSR4NHRHQH7BNEI66G4GPCWMWWGNVESPY6C7IACUOWRF3C
static immutable PW = KeyPair(PublicKey(Point([223, 109, 104, 170, 0, 23, 40, 241, 167, 137, 224, 127, 133, 164, 71, 188, 110, 25, 226, 179, 45, 99, 54, 164, 147, 241, 225, 125, 0, 21, 29, 104])), SecretKey(Scalar([194, 23, 100, 98, 218, 33, 86, 211, 152, 99, 40, 172, 207, 188, 226, 169, 14, 80, 42, 200, 215, 131, 11, 49, 222, 96, 46, 141, 32, 137, 11, 0])));
/// PX: GDPX22Z74C7BJYZHIIFUWG3YCFD67FWRW36CVDV53GS2CFK6INFLNBGH
static immutable PX = KeyPair(PublicKey(Point([223, 125, 107, 63, 224, 190, 20, 227, 39, 66, 11, 75, 27, 120, 17, 71, 239, 150, 209, 182, 252, 42, 142, 189, 217, 165, 161, 21, 94, 67, 74, 182])), SecretKey(Scalar([195, 82, 76, 105, 240, 88, 131, 10, 26, 247, 18, 199, 213, 90, 202, 23, 229, 227, 199, 64, 175, 211, 5, 223, 115, 253, 236, 144, 61, 1, 103, 1])));
/// PY: GDPY2243EF24ZA72PSHAEL7R3WTU4ZKY3XNPRPYUCPOD7IXF4OMC2Z2M
static immutable PY = KeyPair(PublicKey(Point([223, 141, 107, 155, 33, 117, 204, 131, 250, 124, 142, 2, 47, 241, 221, 167, 78, 101, 88, 221, 218, 248, 191, 20, 19, 220, 63, 162, 229, 227, 152, 45])), SecretKey(Scalar([72, 123, 121, 126, 153, 158, 75, 107, 95, 121, 12, 124, 19, 119, 231, 244, 80, 154, 252, 20, 179, 251, 29, 203, 242, 82, 73, 158, 107, 31, 141, 8])));
/// PZ: GDPZ22O2DI642G4KXKTOOISOIKVBBDGNB2IO3YLLEEXRMNFO4MIHS5RP
static immutable PZ = KeyPair(PublicKey(Point([223, 157, 105, 218, 26, 61, 205, 27, 138, 186, 166, 231, 34, 78, 66, 170, 16, 140, 205, 14, 144, 237, 225, 107, 33, 47, 22, 52, 174, 227, 16, 121])), SecretKey(Scalar([175, 180, 67, 226, 9, 54, 129, 32, 227, 82, 122, 162, 156, 64, 44, 32, 206, 125, 64, 46, 254, 109, 135, 45, 82, 103, 170, 237, 198, 220, 38, 7])));
/// QA: GDQA22E3DTDEMGCCYG7IJCJS6UVXSMGS3BZ5TUH6PFOHLZNC77BQXJCZ
static immutable QA = KeyPair(PublicKey(Point([224, 13, 104, 155, 28, 198, 70, 24, 66, 193, 190, 132, 137, 50, 245, 43, 121, 48, 210, 216, 115, 217, 208, 254, 121, 92, 117, 229, 162, 255, 195, 11])), SecretKey(Scalar([110, 165, 237, 197, 87, 90, 201, 207, 193, 41, 173, 174, 202, 189, 15, 11, 130, 61, 112, 121, 152, 8, 42, 172, 245, 208, 213, 103, 170, 221, 187, 7])));
/// QB: GDQB22VHXJXTCTBK6OGUDHWFHTVSSOLNP4AZI2LMDKD6M6YFQC3EQSDS
static immutable QB = KeyPair(PublicKey(Point([224, 29, 106, 167, 186, 111, 49, 76, 42, 243, 141, 65, 158, 197, 60, 235, 41, 57, 109, 127, 1, 148, 105, 108, 26, 135, 230, 123, 5, 128, 182, 72])), SecretKey(Scalar([103, 151, 60, 170, 74, 135, 162, 8, 243, 45, 167, 134, 49, 195, 96, 100, 176, 155, 195, 245, 99, 185, 88, 243, 218, 85, 186, 72, 57, 245, 248, 10])));
/// QC: GDQC22NOWH65ZNT4I36QWGSRL7UUVB5F4YSRNOMOR57P5UEQRNRZBSHU
static immutable QC = KeyPair(PublicKey(Point([224, 45, 105, 174, 177, 253, 220, 182, 124, 70, 253, 11, 26, 81, 95, 233, 74, 135, 165, 230, 37, 22, 185, 142, 143, 126, 254, 208, 144, 139, 99, 144])), SecretKey(Scalar([92, 223, 21, 162, 64, 81, 72, 152, 109, 137, 0, 203, 185, 109, 80, 203, 64, 7, 156, 169, 50, 253, 206, 19, 181, 132, 26, 214, 24, 166, 197, 14])));
/// QD: GDQD22EMIRP7N5VZYKBPE5Q7KQURN6UNLZRYRWCPHMSKQVIE2EGFV5ZC
static immutable QD = KeyPair(PublicKey(Point([224, 61, 104, 140, 68, 95, 246, 246, 185, 194, 130, 242, 118, 31, 84, 41, 22, 250, 141, 94, 99, 136, 216, 79, 59, 36, 168, 85, 4, 209, 12, 90])), SecretKey(Scalar([128, 239, 169, 117, 191, 187, 42, 174, 226, 112, 158, 176, 51, 250, 108, 71, 163, 150, 184, 175, 239, 192, 49, 184, 218, 34, 223, 36, 142, 137, 49, 1])));
/// QE: GDQE22TNSGJM54SVCFXDZPXRK5CVCZQZNEEDYOOFESALZVQFT5FXOVNJ
static immutable QE = KeyPair(PublicKey(Point([224, 77, 106, 109, 145, 146, 206, 242, 85, 17, 110, 60, 190, 241, 87, 69, 81, 102, 25, 105, 8, 60, 57, 197, 36, 128, 188, 214, 5, 159, 75, 119])), SecretKey(Scalar([179, 211, 173, 69, 158, 21, 31, 135, 105, 24, 134, 70, 141, 84, 172, 108, 224, 117, 52, 34, 11, 246, 31, 36, 147, 126, 0, 130, 229, 193, 68, 4])));
/// QF: GDQF22RRNFNH3JJH6ZTKGGF3WDFW22ADQ2SSJMBT26YJC6KYKFJIAXSK
static immutable QF = KeyPair(PublicKey(Point([224, 93, 106, 49, 105, 90, 125, 165, 39, 246, 102, 163, 24, 187, 176, 203, 109, 104, 3, 134, 165, 36, 176, 51, 215, 176, 145, 121, 88, 81, 82, 128])), SecretKey(Scalar([194, 115, 169, 162, 11, 123, 199, 115, 30, 80, 192, 143, 238, 145, 249, 160, 115, 198, 31, 150, 90, 245, 202, 142, 25, 151, 52, 43, 67, 233, 192, 9])));
/// QG: GDQG22QHE74F5YTWKZBK6FRECFSJGZIRZPVII5IO2WQT6L6WVCZAACMX
static immutable QG = KeyPair(PublicKey(Point([224, 109, 106, 7, 39, 248, 94, 226, 118, 86, 66, 175, 22, 36, 17, 100, 147, 101, 17, 203, 234, 132, 117, 14, 213, 161, 63, 47, 214, 168, 178, 0])), SecretKey(Scalar([18, 83, 128, 232, 33, 207, 207, 179, 10, 186, 176, 1, 11, 95, 163, 245, 165, 218, 250, 249, 8, 252, 138, 202, 76, 80, 201, 125, 89, 196, 141, 4])));
/// QH: GDQH22IRWAQTBKY2WE4ZUV4ALEAF2EJ4FZ5T6RTVP4H5AB5RQ35TCSXN
static immutable QH = KeyPair(PublicKey(Point([224, 125, 105, 17, 176, 33, 48, 171, 26, 177, 57, 154, 87, 128, 89, 0, 93, 17, 60, 46, 123, 63, 70, 117, 127, 15, 208, 7, 177, 134, 251, 49])), SecretKey(Scalar([143, 28, 150, 246, 74, 5, 21, 189, 141, 58, 3, 221, 117, 196, 6, 170, 98, 30, 4, 226, 163, 158, 28, 157, 187, 109, 74, 91, 184, 72, 243, 7])));
/// QI: GDQI22D3UNG4T5GHCAY5FC47X5GMV2UGR4DT72MBQ7BG2BQAGQWVAVXN
static immutable QI = KeyPair(PublicKey(Point([224, 141, 104, 123, 163, 77, 201, 244, 199, 16, 49, 210, 139, 159, 191, 76, 202, 234, 134, 143, 7, 63, 233, 129, 135, 194, 109, 6, 0, 52, 45, 80])), SecretKey(Scalar([26, 235, 49, 229, 165, 19, 202, 222, 98, 10, 206, 109, 253, 2, 91, 204, 114, 117, 201, 165, 12, 129, 241, 102, 0, 144, 89, 17, 177, 153, 79, 1])));
/// QJ: GDQJ224SDWD2WK6FI4BWCSLDFODVAIVPTAM4XBI73ZXKJRJK7CHTO27S
static immutable QJ = KeyPair(PublicKey(Point([224, 157, 107, 146, 29, 135, 171, 43, 197, 71, 3, 97, 73, 99, 43, 135, 80, 34, 175, 152, 25, 203, 133, 31, 222, 110, 164, 197, 42, 248, 143, 55])), SecretKey(Scalar([27, 6, 230, 95, 3, 178, 144, 46, 255, 176, 167, 150, 170, 98, 62, 5, 189, 232, 181, 179, 12, 143, 48, 233, 133, 245, 215, 81, 10, 38, 30, 1])));
/// QK: GDQK22FO5IVSHO5Y5AQXIAKO6JN7O6322H2UKUEFUKDVC4AVMVBVOTYM
static immutable QK = KeyPair(PublicKey(Point([224, 173, 104, 174, 234, 43, 35, 187, 184, 232, 33, 116, 1, 78, 242, 91, 247, 123, 122, 209, 245, 69, 80, 133, 162, 135, 81, 112, 21, 101, 67, 87])), SecretKey(Scalar([233, 29, 3, 218, 59, 190, 185, 217, 188, 14, 229, 9, 249, 90, 242, 248, 214, 144, 226, 190, 154, 99, 122, 32, 232, 54, 52, 152, 67, 173, 141, 15])));
/// QL: GDQL2246YF57B233OFLGI2DZ3OEHJWCKJ4BFBK4NCDRXXHKKTSKYOWWB
static immutable QL = KeyPair(PublicKey(Point([224, 189, 107, 158, 193, 123, 240, 235, 123, 113, 86, 100, 104, 121, 219, 136, 116, 216, 74, 79, 2, 80, 171, 141, 16, 227, 123, 157, 74, 156, 149, 135])), SecretKey(Scalar([222, 242, 55, 84, 214, 170, 82, 135, 39, 119, 188, 104, 113, 215, 95, 242, 29, 60, 179, 232, 136, 81, 27, 20, 252, 237, 207, 46, 108, 97, 196, 4])));
/// QM: GDQM225EJHWUXS7N5LLUAINTCMZEB2ER2WSJSBZIICE2HZ4HP52HNXCA
static immutable QM = KeyPair(PublicKey(Point([224, 205, 107, 164, 73, 237, 75, 203, 237, 234, 215, 64, 33, 179, 19, 50, 64, 232, 145, 213, 164, 153, 7, 40, 64, 137, 163, 231, 135, 127, 116, 118])), SecretKey(Scalar([40, 175, 207, 69, 208, 100, 216, 163, 44, 109, 74, 235, 110, 4, 137, 36, 90, 158, 5, 164, 230, 201, 27, 167, 110, 104, 155, 143, 221, 111, 249, 6])));
/// QN: GDQN22PQZI2CZKXHZRH6TFYP3POP73D2HPUF7JH7T4RMWGA7GVXHXCTI
static immutable QN = KeyPair(PublicKey(Point([224, 221, 105, 240, 202, 52, 44, 170, 231, 204, 79, 233, 151, 15, 219, 220, 255, 236, 122, 59, 232, 95, 164, 255, 159, 34, 203, 24, 31, 53, 110, 123])), SecretKey(Scalar([237, 145, 39, 183, 131, 218, 200, 4, 30, 127, 100, 86, 130, 229, 214, 255, 213, 160, 241, 53, 137, 25, 7, 47, 184, 18, 138, 120, 167, 15, 43, 15])));
/// QO: GDQO22XEXCK46LVQDVNJYEUUNWIXFS6GB2XXKK2AKWEZALXYEIRY7ADA
static immutable QO = KeyPair(PublicKey(Point([224, 237, 106, 228, 184, 149, 207, 46, 176, 29, 90, 156, 18, 148, 109, 145, 114, 203, 198, 14, 175, 117, 43, 64, 85, 137, 144, 46, 248, 34, 35, 143])), SecretKey(Scalar([190, 98, 225, 160, 71, 254, 146, 51, 205, 23, 204, 54, 205, 239, 106, 227, 52, 19, 117, 103, 234, 156, 25, 193, 163, 171, 89, 115, 147, 217, 76, 10])));
/// QP: GDQP22IUGMJOEECSID22RFCRSXYY64OHURQCMMZDIVSQ6ISSZLP3Q4CQ
static immutable QP = KeyPair(PublicKey(Point([224, 253, 105, 20, 51, 18, 226, 16, 82, 64, 245, 168, 148, 81, 149, 241, 143, 113, 199, 164, 96, 38, 51, 35, 69, 101, 15, 34, 82, 202, 223, 184])), SecretKey(Scalar([15, 194, 118, 244, 34, 1, 137, 197, 28, 140, 215, 16, 107, 60, 254, 44, 50, 133, 101, 191, 141, 162, 249, 17, 23, 143, 233, 192, 224, 86, 125, 14])));
/// QQ: GDQQ22O2NX4PNCKBTH4H5BC7EJKHF5VZV2DXMOZOH5AE3ZJ2ZWN7S6BY
static immutable QQ = KeyPair(PublicKey(Point([225, 13, 105, 218, 109, 248, 246, 137, 65, 153, 248, 126, 132, 95, 34, 84, 114, 246, 185, 174, 135, 118, 59, 46, 63, 64, 77, 229, 58, 205, 155, 249])), SecretKey(Scalar([42, 38, 67, 123, 100, 48, 16, 106, 117, 251, 100, 246, 92, 218, 73, 36, 42, 111, 182, 95, 96, 86, 224, 4, 140, 1, 48, 124, 221, 102, 255, 15])));
/// QR: GDQR227WCS2RALXMM6RQR7A664E5CHJ36PUZ5J547DXZGDGHM6JSYGDH
static immutable QR = KeyPair(PublicKey(Point([225, 29, 107, 246, 20, 181, 16, 46, 236, 103, 163, 8, 252, 30, 247, 9, 209, 29, 59, 243, 233, 158, 167, 188, 248, 239, 147, 12, 199, 103, 147, 44])), SecretKey(Scalar([254, 224, 86, 246, 99, 76, 7, 67, 66, 126, 225, 132, 45, 193, 108, 244, 74, 151, 39, 188, 162, 14, 106, 101, 87, 190, 110, 113, 245, 187, 75, 5])));
/// QS: GDQS22GQ77M46CO4E6MT3VZYONPLQVNDCQIC4QSGHIRPZCCSRRSGSHOL
static immutable QS = KeyPair(PublicKey(Point([225, 45, 104, 208, 255, 217, 207, 9, 220, 39, 153, 61, 215, 56, 115, 94, 184, 85, 163, 20, 16, 46, 66, 70, 58, 34, 252, 136, 82, 140, 100, 105])), SecretKey(Scalar([120, 215, 84, 54, 145, 161, 255, 18, 154, 54, 241, 156, 164, 183, 217, 116, 217, 0, 43, 65, 31, 191, 116, 51, 5, 116, 8, 85, 251, 104, 17, 12])));
/// QT: GDQT22F6IKYPSHRCBS6U3HATUZH4PZ2TPJ4YXVST4RCHIILNJDLUMAXZ
static immutable QT = KeyPair(PublicKey(Point([225, 61, 104, 190, 66, 176, 249, 30, 34, 12, 189, 77, 156, 19, 166, 79, 199, 231, 83, 122, 121, 139, 214, 83, 228, 68, 116, 33, 109, 72, 215, 70])), SecretKey(Scalar([110, 105, 157, 78, 223, 67, 181, 73, 99, 127, 18, 184, 99, 21, 136, 175, 20, 112, 29, 244, 92, 219, 24, 86, 79, 217, 90, 255, 200, 254, 218, 5])));
/// QU: GDQU22QMSTGK26IUTFUM43YIOYIX6K3TKOLQK576ZH47RM6BLKL2PELI
static immutable QU = KeyPair(PublicKey(Point([225, 77, 106, 12, 148, 204, 173, 121, 20, 153, 104, 206, 111, 8, 118, 17, 127, 43, 115, 83, 151, 5, 119, 254, 201, 249, 248, 179, 193, 90, 151, 167])), SecretKey(Scalar([155, 218, 233, 154, 186, 133, 244, 184, 227, 203, 37, 109, 82, 178, 23, 83, 184, 197, 25, 234, 69, 210, 99, 55, 128, 60, 32, 2, 163, 251, 189, 3])));
/// QV: GDQV22EF3IWZ2JON2D4WG7CF5254LOYYJRGYDFAZIV35CXUWQKGFU36K
static immutable QV = KeyPair(PublicKey(Point([225, 93, 104, 133, 218, 45, 157, 37, 205, 208, 249, 99, 124, 69, 238, 187, 197, 187, 24, 76, 77, 129, 148, 25, 69, 119, 209, 94, 150, 130, 140, 90])), SecretKey(Scalar([44, 109, 208, 137, 118, 23, 222, 108, 217, 14, 181, 123, 42, 1, 37, 70, 135, 83, 220, 124, 43, 188, 51, 91, 149, 136, 247, 83, 92, 22, 102, 3])));
/// QW: GDQW22XIOGU3WBKYE6LTC5MZUGJ5PM5SE75K7RFJUR3NIYRP4ZM7BVZD
static immutable QW = KeyPair(PublicKey(Point([225, 109, 106, 232, 113, 169, 187, 5, 88, 39, 151, 49, 117, 153, 161, 147, 215, 179, 178, 39, 250, 175, 196, 169, 164, 118, 212, 98, 47, 230, 89, 240])), SecretKey(Scalar([61, 99, 246, 116, 6, 193, 133, 101, 117, 192, 89, 167, 158, 248, 12, 188, 173, 95, 184, 238, 146, 150, 246, 191, 158, 195, 39, 194, 88, 168, 226, 4])));
/// QX: GDQX22FZVYSNIAPJQYREH3OURIDE66EZZK3YZLVGX5A5CNDL5RWUX5JB
static immutable QX = KeyPair(PublicKey(Point([225, 125, 104, 185, 174, 36, 212, 1, 233, 134, 34, 67, 237, 212, 138, 6, 79, 120, 153, 202, 183, 140, 174, 166, 191, 65, 209, 52, 107, 236, 109, 75])), SecretKey(Scalar([70, 24, 198, 137, 242, 219, 10, 105, 72, 252, 93, 84, 102, 144, 176, 23, 20, 1, 142, 176, 89, 71, 83, 119, 137, 140, 0, 121, 164, 76, 61, 9])));
/// QY: GDQY22OZ5U4GEPEB5PRA5FZHPFXR56RF52OHBOCWCCFYT3BAVJ5HXG7O
static immutable QY = KeyPair(PublicKey(Point([225, 141, 105, 217, 237, 56, 98, 60, 129, 235, 226, 14, 151, 39, 121, 111, 30, 250, 37, 238, 156, 112, 184, 86, 16, 139, 137, 236, 32, 170, 122, 123])), SecretKey(Scalar([21, 52, 196, 180, 132, 37, 7, 7, 208, 146, 208, 162, 78, 206, 63, 184, 189, 152, 28, 187, 249, 221, 82, 195, 122, 132, 78, 109, 76, 200, 127, 10])));
/// QZ: GDQZ22BMDOXPJ5LLYNCHII2L2PE4DDQ4YHV7VZOGXZMY5CT7HZQF2AQB
static immutable QZ = KeyPair(PublicKey(Point([225, 157, 104, 44, 27, 174, 244, 245, 107, 195, 68, 116, 35, 75, 211, 201, 193, 142, 28, 193, 235, 250, 229, 198, 190, 89, 142, 138, 127, 62, 96, 93])), SecretKey(Scalar([172, 167, 82, 137, 141, 175, 208, 77, 33, 92, 152, 30, 90, 13, 119, 153, 213, 206, 13, 141, 113, 178, 116, 16, 90, 31, 238, 240, 249, 104, 45, 5])));
/// RA: GDRA22KNCQGEMMHGWOVPCQPQWYYHX7LAQTMSFON25YEL4SKR2AZ5GEQV
static immutable RA = KeyPair(PublicKey(Point([226, 13, 105, 77, 20, 12, 70, 48, 230, 179, 170, 241, 65, 240, 182, 48, 123, 253, 96, 132, 217, 34, 185, 186, 238, 8, 190, 73, 81, 208, 51, 211])), SecretKey(Scalar([167, 132, 37, 218, 187, 225, 124, 68, 80, 254, 202, 34, 211, 190, 136, 115, 132, 97, 21, 168, 236, 3, 173, 116, 250, 246, 178, 14, 40, 16, 240, 1])));
/// RB: GDRB22BWZKNFLQKJHI2YXBXTKSJPTLH6CS4BXQVWNK6MKK4GSA7SZTJA
static immutable RB = KeyPair(PublicKey(Point([226, 29, 104, 54, 202, 154, 85, 193, 73, 58, 53, 139, 134, 243, 84, 146, 249, 172, 254, 20, 184, 27, 194, 182, 106, 188, 197, 43, 134, 144, 63, 44])), SecretKey(Scalar([252, 5, 167, 173, 143, 141, 113, 19, 191, 109, 153, 111, 82, 105, 116, 221, 0, 134, 145, 114, 135, 98, 219, 29, 202, 19, 69, 72, 166, 203, 91, 14])));
/// RC: GDRC22QMAPVZHGOTRHQ64AWL7KDT7GA62MH3H623BGAK536JAYOMMCKS
static immutable RC = KeyPair(PublicKey(Point([226, 45, 106, 12, 3, 235, 147, 153, 211, 137, 225, 238, 2, 203, 250, 135, 63, 152, 30, 211, 15, 179, 251, 91, 9, 128, 174, 239, 201, 6, 28, 198])), SecretKey(Scalar([102, 128, 181, 126, 234, 191, 45, 14, 137, 226, 176, 158, 99, 192, 94, 221, 128, 84, 84, 125, 206, 123, 123, 250, 247, 113, 222, 128, 158, 206, 222, 9])));
/// RD: GDRD223AOB2LIIWEAPWM67IFYNJZPZE7ZXS57L37XBQVP5SVLNXUXFYF
static immutable RD = KeyPair(PublicKey(Point([226, 61, 107, 96, 112, 116, 180, 34, 196, 3, 236, 207, 125, 5, 195, 83, 151, 228, 159, 205, 229, 223, 175, 127, 184, 97, 87, 246, 85, 91, 111, 75])), SecretKey(Scalar([194, 181, 168, 68, 8, 219, 184, 254, 1, 34, 60, 190, 227, 10, 207, 15, 154, 232, 221, 49, 18, 141, 157, 167, 35, 39, 70, 86, 196, 243, 221, 9])));
/// RE: GDRE22IYUEW7J235OGFLI5L5VICDJILYAOZPMBD7UIBF7F5E6SRWFRWL
static immutable RE = KeyPair(PublicKey(Point([226, 77, 105, 24, 161, 45, 244, 235, 125, 113, 138, 180, 117, 125, 170, 4, 52, 161, 120, 3, 178, 246, 4, 127, 162, 2, 95, 151, 164, 244, 163, 98])), SecretKey(Scalar([237, 216, 89, 163, 98, 130, 8, 6, 48, 181, 121, 175, 52, 205, 133, 113, 135, 212, 221, 253, 88, 198, 105, 30, 46, 221, 220, 197, 42, 190, 234, 1])));
/// RF: GDRF227V2VJY333YLRAFHC7HSEDJMJJLW3YNIOWAGG2PSAHJKI2GN2CQ
static immutable RF = KeyPair(PublicKey(Point([226, 93, 107, 245, 213, 83, 141, 239, 120, 92, 64, 83, 139, 231, 145, 6, 150, 37, 43, 182, 240, 212, 58, 192, 49, 180, 249, 0, 233, 82, 52, 102])), SecretKey(Scalar([150, 187, 225, 122, 255, 84, 78, 128, 68, 42, 27, 152, 17, 2, 71, 238, 135, 212, 172, 254, 35, 41, 71, 165, 201, 155, 165, 208, 45, 39, 153, 8])));
/// RG: GDRG222M5JBP7Q2WPS6Y33YTP3V5WQVNOTPDWDMN454RXNPTJOE26MOM
static immutable RG = KeyPair(PublicKey(Point([226, 109, 107, 76, 234, 66, 255, 195, 86, 124, 189, 141, 239, 19, 126, 235, 219, 66, 173, 116, 222, 59, 13, 141, 231, 121, 27, 181, 243, 75, 137, 175])), SecretKey(Scalar([117, 207, 109, 239, 139, 132, 230, 23, 157, 209, 58, 85, 233, 94, 92, 159, 199, 176, 38, 177, 169, 223, 124, 52, 108, 117, 171, 253, 148, 201, 79, 12])));
/// RH: GDRH22NRBC53AKTN6WSKILURQHNI2UTPHFISWRINE4TKIC2REGDP6KHA
static immutable RH = KeyPair(PublicKey(Point([226, 125, 105, 177, 8, 187, 176, 42, 109, 245, 164, 164, 46, 145, 129, 218, 141, 82, 111, 57, 81, 43, 69, 13, 39, 38, 164, 11, 81, 33, 134, 255])), SecretKey(Scalar([183, 211, 239, 193, 16, 188, 124, 165, 199, 196, 0, 228, 205, 241, 55, 182, 91, 121, 8, 44, 66, 11, 13, 142, 227, 100, 162, 192, 125, 136, 126, 14])));
/// RI: GDRI22QLYE2MPTEOVNHLRZCCDMEMXVMI3WJ5SKNRZOCEFGHSDIMJ62PE
static immutable RI = KeyPair(PublicKey(Point([226, 141, 106, 11, 193, 52, 199, 204, 142, 171, 78, 184, 228, 66, 27, 8, 203, 213, 136, 221, 147, 217, 41, 177, 203, 132, 66, 152, 242, 26, 24, 159])), SecretKey(Scalar([33, 28, 110, 106, 199, 99, 231, 134, 239, 81, 35, 12, 178, 83, 50, 113, 50, 246, 51, 35, 240, 248, 95, 155, 4, 53, 184, 152, 133, 44, 84, 15])));
/// RJ: GDRJ22KJOIEXST2APZM6EUXZV2LR7ZB2KRJ4OY3SU63RZL3VQWJJDVTJ
static immutable RJ = KeyPair(PublicKey(Point([226, 157, 105, 73, 114, 9, 121, 79, 64, 126, 89, 226, 82, 249, 174, 151, 31, 228, 58, 84, 83, 199, 99, 114, 167, 183, 28, 175, 117, 133, 146, 145])), SecretKey(Scalar([217, 44, 149, 249, 255, 174, 2, 37, 80, 15, 45, 192, 140, 230, 64, 157, 233, 133, 74, 175, 73, 214, 76, 2, 181, 216, 161, 139, 30, 174, 10, 10])));
/// RK: GDRK22BVKULO7OEGZJSBC5X5QL4LNFHQ4O5CVQ744TEL6TBQVYYNPESX
static immutable RK = KeyPair(PublicKey(Point([226, 173, 104, 53, 85, 22, 239, 184, 134, 202, 100, 17, 118, 253, 130, 248, 182, 148, 240, 227, 186, 42, 195, 252, 228, 200, 191, 76, 48, 174, 48, 215])), SecretKey(Scalar([213, 96, 74, 207, 123, 171, 95, 84, 65, 153, 101, 250, 165, 108, 49, 245, 130, 35, 91, 183, 53, 40, 18, 172, 216, 191, 194, 194, 108, 43, 250, 15])));
/// RL: GDRL22O7JUAHP5QUXL2DTP5GUB4CK2F7QQLWU4PSXNARWHOG7VCMJ4E7
static immutable RL = KeyPair(PublicKey(Point([226, 189, 105, 223, 77, 0, 119, 246, 20, 186, 244, 57, 191, 166, 160, 120, 37, 104, 191, 132, 23, 106, 113, 242, 187, 65, 27, 29, 198, 253, 68, 196])), SecretKey(Scalar([15, 89, 143, 221, 186, 24, 11, 120, 127, 87, 232, 232, 231, 37, 152, 215, 201, 200, 199, 234, 88, 110, 63, 155, 6, 34, 225, 196, 4, 193, 43, 12])));
/// RM: GDRM22E7RVMU3AZVWV6EH4HUHMCU4VSQ6PINSUAWXPORASKE45ZKYTXF
static immutable RM = KeyPair(PublicKey(Point([226, 205, 104, 159, 141, 89, 77, 131, 53, 181, 124, 67, 240, 244, 59, 5, 78, 86, 80, 243, 208, 217, 80, 22, 187, 221, 16, 73, 68, 231, 114, 172])), SecretKey(Scalar([129, 97, 155, 226, 195, 143, 38, 154, 143, 101, 118, 148, 170, 241, 98, 56, 21, 243, 85, 173, 90, 139, 230, 2, 96, 176, 232, 62, 110, 41, 167, 1])));
/// RN: GDRN22QPEBMG2IB3MDDY7NXWZUL3RDNOBTAH4ARKDWYTI4KIK236IWY5
static immutable RN = KeyPair(PublicKey(Point([226, 221, 106, 15, 32, 88, 109, 32, 59, 96, 199, 143, 182, 246, 205, 23, 184, 141, 174, 12, 192, 126, 2, 42, 29, 177, 52, 113, 72, 86, 183, 228])), SecretKey(Scalar([8, 228, 204, 114, 63, 242, 238, 134, 236, 235, 233, 219, 191, 133, 10, 136, 115, 210, 240, 54, 140, 97, 225, 245, 142, 103, 171, 73, 205, 163, 166, 1])));
/// RO: GDRO22D2JYMRA57TCULSJMVZJ53G3AYCRRWSHFF7Z2D5LVJNSGN4WGPX
static immutable RO = KeyPair(PublicKey(Point([226, 237, 104, 122, 78, 25, 16, 119, 243, 21, 23, 36, 178, 185, 79, 118, 109, 131, 2, 140, 109, 35, 148, 191, 206, 135, 213, 213, 45, 145, 155, 203])), SecretKey(Scalar([212, 189, 191, 220, 135, 120, 10, 26, 235, 168, 205, 44, 228, 175, 141, 142, 53, 189, 224, 237, 57, 63, 213, 166, 27, 10, 138, 99, 255, 135, 246, 11])));
/// RP: GDRP22J6HWMOKYVSGXKNEU4VT43YGYBOHPXJ7N7S6ABI7D3LQ6OPCRQP
static immutable RP = KeyPair(PublicKey(Point([226, 253, 105, 62, 61, 152, 229, 98, 178, 53, 212, 210, 83, 149, 159, 55, 131, 96, 46, 59, 238, 159, 183, 242, 240, 2, 143, 143, 107, 135, 156, 241])), SecretKey(Scalar([154, 169, 233, 247, 204, 242, 225, 96, 63, 40, 65, 102, 202, 34, 252, 143, 5, 128, 112, 218, 30, 246, 154, 115, 4, 179, 0, 174, 131, 92, 46, 14])));
/// RQ: GDRQ222OTRQ55MMEMDYCRKCUIOELYXLXQJTITK52GLMCVHZLPUULZOZP
static immutable RQ = KeyPair(PublicKey(Point([227, 13, 107, 78, 156, 97, 222, 177, 132, 96, 240, 40, 168, 84, 67, 136, 188, 93, 119, 130, 102, 137, 171, 186, 50, 216, 42, 159, 43, 125, 40, 188])), SecretKey(Scalar([131, 32, 81, 59, 217, 216, 25, 187, 181, 155, 254, 199, 0, 93, 101, 252, 18, 237, 105, 71, 88, 66, 219, 162, 85, 148, 151, 253, 175, 77, 19, 0])));
/// RR: GDRR22DDYA7DCUK4ZOETKFDYAVVIM4RBXMYWDIXPXFIHQPAPMGXSVAM5
static immutable RR = KeyPair(PublicKey(Point([227, 29, 104, 99, 192, 62, 49, 81, 92, 203, 137, 53, 20, 120, 5, 106, 134, 114, 33, 187, 49, 97, 162, 239, 185, 80, 120, 60, 15, 97, 175, 42])), SecretKey(Scalar([144, 134, 104, 240, 77, 205, 248, 80, 35, 102, 115, 204, 240, 172, 239, 146, 212, 149, 123, 100, 77, 239, 61, 189, 236, 38, 84, 184, 59, 220, 241, 10])));
/// RS: GDRS22YXCY33Z7ITBH2GVP4B4ZSBTAGILNEDQONEBJ3WWFLG4FWHXKUY
static immutable RS = KeyPair(PublicKey(Point([227, 45, 107, 23, 22, 55, 188, 253, 19, 9, 244, 106, 191, 129, 230, 100, 25, 128, 200, 91, 72, 56, 57, 164, 10, 119, 107, 21, 102, 225, 108, 123])), SecretKey(Scalar([193, 20, 50, 166, 66, 242, 100, 146, 6, 189, 171, 4, 224, 134, 18, 237, 189, 122, 164, 238, 159, 136, 82, 142, 22, 152, 192, 39, 236, 209, 148, 7])));
/// RT: GDRT22DJ4JDWO6YDNCTOHTD5MYJ2RRPOOUDIML2TN625N36XF2SPT2JL
static immutable RT = KeyPair(PublicKey(Point([227, 61, 104, 105, 226, 71, 103, 123, 3, 104, 166, 227, 204, 125, 102, 19, 168, 197, 238, 117, 6, 134, 47, 83, 111, 181, 214, 239, 215, 46, 164, 249])), SecretKey(Scalar([240, 215, 161, 244, 241, 27, 246, 41, 226, 121, 29, 83, 24, 123, 252, 105, 9, 142, 130, 45, 157, 113, 88, 238, 184, 32, 89, 196, 151, 1, 19, 15])));
/// RU: GDRU22EG4NO7TR7P5RKF25YVWP7TQGEGCPC6AU25MUG3H4T5TKED43VD
static immutable RU = KeyPair(PublicKey(Point([227, 77, 104, 134, 227, 93, 249, 199, 239, 236, 84, 93, 119, 21, 179, 255, 56, 24, 134, 19, 197, 224, 83, 93, 101, 13, 179, 242, 125, 154, 136, 62])), SecretKey(Scalar([110, 223, 209, 85, 215, 145, 204, 152, 36, 165, 173, 158, 181, 118, 235, 115, 66, 191, 36, 228, 253, 100, 126, 197, 208, 237, 77, 7, 124, 159, 177, 8])));
/// RV: GDRV22AGTCICIKCWVDSGX73MRWROSGMHTDG3QW7FSSBK77CXS2UYJIOG
static immutable RV = KeyPair(PublicKey(Point([227, 93, 104, 6, 152, 144, 36, 40, 86, 168, 228, 107, 255, 108, 141, 162, 233, 25, 135, 152, 205, 184, 91, 229, 148, 130, 175, 252, 87, 150, 169, 132])), SecretKey(Scalar([206, 125, 192, 223, 133, 194, 80, 225, 115, 190, 68, 7, 53, 26, 85, 31, 72, 146, 61, 3, 82, 44, 5, 29, 9, 195, 59, 242, 159, 6, 248, 2])));
/// RW: GDRW22ET7TUUHKWEBMUAPDZLROBQYOY3UAIDMG72CRVMSZAVI7DNKY7M
static immutable RW = KeyPair(PublicKey(Point([227, 109, 104, 147, 252, 233, 67, 170, 196, 11, 40, 7, 143, 43, 139, 131, 12, 59, 27, 160, 16, 54, 27, 250, 20, 106, 201, 100, 21, 71, 198, 213])), SecretKey(Scalar([29, 174, 177, 35, 128, 223, 63, 6, 213, 5, 176, 177, 131, 222, 248, 105, 84, 83, 39, 10, 63, 133, 61, 226, 122, 18, 113, 45, 132, 209, 48, 15])));
/// RX: GDRX22BVGCD5AKZNDCTGMECABHW4HN36Z763XIVY3UJTU2IF4ICGWBW6
static immutable RX = KeyPair(PublicKey(Point([227, 125, 104, 53, 48, 135, 208, 43, 45, 24, 166, 102, 16, 64, 9, 237, 195, 183, 126, 207, 253, 187, 162, 184, 221, 19, 58, 105, 5, 226, 4, 107])), SecretKey(Scalar([87, 28, 185, 176, 17, 206, 162, 45, 155, 113, 112, 144, 194, 124, 53, 145, 101, 206, 87, 225, 81, 142, 62, 161, 130, 56, 76, 167, 229, 210, 94, 12])));
/// RY: GDRY2236ZNAOZQY5PRGHIFWZ77XMGTZG2QSXUANDSQOGZLCPMOMZ2YAX
static immutable RY = KeyPair(PublicKey(Point([227, 141, 107, 126, 203, 64, 236, 195, 29, 124, 76, 116, 22, 217, 255, 238, 195, 79, 38, 212, 37, 122, 1, 163, 148, 28, 108, 172, 79, 99, 153, 157])), SecretKey(Scalar([255, 68, 222, 143, 181, 133, 249, 98, 167, 122, 249, 152, 101, 38, 131, 221, 109, 144, 29, 20, 20, 123, 78, 77, 2, 107, 163, 142, 127, 23, 56, 6])));
/// RZ: GDRZ22LSZE3ZFQIIBVUASDH6GEDHAYYXYB5O74U6KEEY5Z2H74AD7E65
static immutable RZ = KeyPair(PublicKey(Point([227, 157, 105, 114, 201, 55, 146, 193, 8, 13, 104, 9, 12, 254, 49, 6, 112, 99, 23, 192, 122, 239, 242, 158, 81, 9, 142, 231, 71, 255, 0, 63])), SecretKey(Scalar([42, 16, 230, 180, 134, 52, 6, 137, 171, 43, 3, 125, 180, 25, 61, 172, 52, 94, 215, 17, 111, 204, 190, 48, 72, 219, 90, 43, 197, 50, 37, 3])));
/// SA: GDSA22GWXQ7TK7X2FV2Q6AYFZR234J6JRZ5CWEJMMYBHFIZCZFUHVFHT
static immutable SA = KeyPair(PublicKey(Point([228, 13, 104, 214, 188, 63, 53, 126, 250, 45, 117, 15, 3, 5, 204, 117, 190, 39, 201, 142, 122, 43, 17, 44, 102, 2, 114, 163, 34, 201, 104, 122])), SecretKey(Scalar([101, 215, 109, 176, 222, 115, 20, 27, 124, 175, 173, 33, 33, 55, 108, 137, 226, 97, 108, 168, 2, 37, 188, 65, 81, 20, 169, 129, 45, 182, 77, 8])));
/// SB: GDSB22MLTAQ7KYDELFIDHJFTSEAZZ42GRHFFJFRAQJYVBYLEMJP4XVCF
static immutable SB = KeyPair(PublicKey(Point([228, 29, 105, 139, 152, 33, 245, 96, 100, 89, 80, 51, 164, 179, 145, 1, 156, 243, 70, 137, 202, 84, 150, 32, 130, 113, 80, 225, 100, 98, 95, 203])), SecretKey(Scalar([16, 145, 18, 18, 3, 71, 113, 158, 165, 134, 55, 56, 176, 216, 91, 214, 245, 66, 173, 49, 207, 182, 185, 27, 8, 95, 178, 219, 72, 85, 226, 10])));
/// SC: GDSC22XAAWFGKYAJRLXCZ6GUEHAQ45JE43EP7XW52XGEDZEJEK5E5I73
static immutable SC = KeyPair(PublicKey(Point([228, 45, 106, 224, 5, 138, 101, 96, 9, 138, 238, 44, 248, 212, 33, 193, 14, 117, 36, 230, 200, 255, 222, 221, 213, 204, 65, 228, 137, 34, 186, 78])), SecretKey(Scalar([16, 46, 14, 87, 2, 218, 61, 178, 168, 162, 203, 212, 75, 13, 98, 39, 127, 227, 81, 249, 253, 144, 37, 14, 132, 158, 231, 84, 191, 243, 24, 8])));
/// SD: GDSD226XQWS7IUSTDJ7ESM4ZDIRIK7HFD3UGUFH7QW222EKWFPDVV37Z
static immutable SD = KeyPair(PublicKey(Point([228, 61, 107, 215, 133, 165, 244, 82, 83, 26, 126, 73, 51, 153, 26, 34, 133, 124, 229, 30, 232, 106, 20, 255, 133, 181, 173, 17, 86, 43, 199, 90])), SecretKey(Scalar([216, 159, 87, 137, 29, 69, 84, 154, 62, 17, 78, 71, 16, 219, 23, 76, 222, 232, 24, 25, 91, 147, 25, 7, 109, 41, 183, 253, 25, 178, 28, 2])));
/// SE: GDSE225STMDY2BJ4GTDEMY5VOV2NJTUNG7AWWVRY42FNFQ7IBLERTY5S
static immutable SE = KeyPair(PublicKey(Point([228, 77, 107, 178, 155, 7, 141, 5, 60, 52, 198, 70, 99, 181, 117, 116, 212, 206, 141, 55, 193, 107, 86, 56, 230, 138, 210, 195, 232, 10, 201, 25])), SecretKey(Scalar([228, 151, 245, 157, 162, 37, 50, 94, 137, 147, 184, 183, 80, 172, 50, 132, 190, 242, 222, 212, 234, 205, 118, 41, 35, 23, 242, 80, 122, 40, 23, 2])));
/// SF: GDSF22X4ZK2NJXYCNFFZ2SAI6YCSAQL7T3S2XIROVSPLBCEVTDVGGCYD
static immutable SF = KeyPair(PublicKey(Point([228, 93, 106, 252, 202, 180, 212, 223, 2, 105, 75, 157, 72, 8, 246, 5, 32, 65, 127, 158, 229, 171, 162, 46, 172, 158, 176, 136, 149, 152, 234, 99])), SecretKey(Scalar([101, 17, 94, 112, 214, 192, 38, 144, 172, 185, 28, 253, 192, 132, 33, 184, 51, 150, 157, 254, 44, 105, 18, 199, 220, 128, 45, 4, 33, 206, 88, 11])));
/// SG: GDSG22QUUAXHYIFOGGNHQEATLTEJXBJ3PVNXXRQ43EKWUDOWB3QO2FHG
static immutable SG = KeyPair(PublicKey(Point([228, 109, 106, 20, 160, 46, 124, 32, 174, 49, 154, 120, 16, 19, 92, 200, 155, 133, 59, 125, 91, 123, 198, 28, 217, 21, 106, 13, 214, 14, 224, 237])), SecretKey(Scalar([234, 128, 104, 200, 93, 204, 191, 137, 112, 148, 121, 142, 4, 124, 11, 154, 114, 191, 152, 105, 42, 176, 221, 180, 251, 212, 118, 235, 198, 251, 41, 4])));
/// SH: GDSH22QOMUXTRPHHOK2WF5RGXDK3ITCWAWEYCCZ6TRFZA25725CIDV5P
static immutable SH = KeyPair(PublicKey(Point([228, 125, 106, 14, 101, 47, 56, 188, 231, 114, 181, 98, 246, 38, 184, 213, 180, 76, 86, 5, 137, 129, 11, 62, 156, 75, 144, 107, 191, 215, 68, 129])), SecretKey(Scalar([12, 149, 241, 11, 197, 55, 113, 187, 156, 207, 37, 106, 37, 240, 3, 212, 161, 143, 39, 174, 106, 216, 215, 232, 177, 236, 114, 211, 128, 151, 75, 6])));
/// SI: GDSI22WDVGDIT37TVF2OTAHPI6ZZUTYUOY553SEJRETZN7AWMFD4UZO4
static immutable SI = KeyPair(PublicKey(Point([228, 141, 106, 195, 169, 134, 137, 239, 243, 169, 116, 233, 128, 239, 71, 179, 154, 79, 20, 118, 59, 221, 200, 137, 137, 39, 150, 252, 22, 97, 71, 202])), SecretKey(Scalar([76, 222, 255, 234, 150, 230, 81, 179, 73, 17, 46, 169, 103, 135, 1, 55, 134, 79, 229, 211, 83, 219, 249, 61, 183, 204, 182, 197, 126, 39, 171, 1])));
/// SJ: GDSJ22Q5ZPW5DBJGXQDB5JBT5HNXKZHFUCUBQ3CFYSEEV2TG2AM2HREB
static immutable SJ = KeyPair(PublicKey(Point([228, 157, 106, 29, 203, 237, 209, 133, 38, 188, 6, 30, 164, 51, 233, 219, 117, 100, 229, 160, 168, 24, 108, 69, 196, 136, 74, 234, 102, 208, 25, 163])), SecretKey(Scalar([252, 108, 160, 238, 151, 12, 135, 68, 44, 192, 62, 117, 54, 230, 230, 2, 131, 23, 145, 154, 171, 3, 173, 108, 37, 72, 41, 12, 164, 48, 90, 12])));
/// SK: GDSK225P56PTTTXLKP5M3PZ6U2PUGF3UOLAF53RC2OONP2HXOKVBKSXD
static immutable SK = KeyPair(PublicKey(Point([228, 173, 107, 175, 239, 159, 57, 206, 235, 83, 250, 205, 191, 62, 166, 159, 67, 23, 116, 114, 192, 94, 238, 34, 211, 156, 215, 232, 247, 114, 170, 21])), SecretKey(Scalar([70, 48, 233, 145, 73, 40, 220, 246, 75, 101, 42, 53, 53, 110, 73, 209, 233, 135, 66, 234, 143, 111, 184, 30, 46, 172, 243, 215, 102, 75, 126, 10])));
/// SL: GDSL22YJR5GWEOUKXTT5YHDRLUPL7WXBAOINCFCRTNN47WRY5NHK6JDN
static immutable SL = KeyPair(PublicKey(Point([228, 189, 107, 9, 143, 77, 98, 58, 138, 188, 231, 220, 28, 113, 93, 30, 191, 218, 225, 3, 144, 209, 20, 81, 155, 91, 207, 218, 56, 235, 78, 175])), SecretKey(Scalar([77, 15, 149, 166, 113, 27, 135, 135, 29, 198, 255, 118, 15, 133, 26, 198, 211, 140, 52, 71, 57, 147, 150, 146, 10, 196, 173, 103, 4, 94, 51, 1])));
/// SM: GDSM227SVZ6CWQRRN6NYUZM4BPJ35DET66M2HK7TGGVJADO7RM3PC4E4
static immutable SM = KeyPair(PublicKey(Point([228, 205, 107, 242, 174, 124, 43, 66, 49, 111, 155, 138, 101, 156, 11, 211, 190, 140, 147, 247, 153, 163, 171, 243, 49, 170, 144, 13, 223, 139, 54, 241])), SecretKey(Scalar([14, 123, 248, 168, 76, 11, 244, 22, 85, 210, 121, 72, 89, 249, 236, 25, 167, 122, 218, 11, 47, 104, 21, 64, 135, 188, 98, 46, 49, 166, 133, 13])));
/// SN: GDSN22UPL5M3CFRFT4ASHZXLMXJZFWKGLOMM4KLV5GQBEON4KLE2S65P
static immutable SN = KeyPair(PublicKey(Point([228, 221, 106, 143, 95, 89, 177, 22, 37, 159, 1, 35, 230, 235, 101, 211, 146, 217, 70, 91, 152, 206, 41, 117, 233, 160, 18, 57, 188, 82, 201, 169])), SecretKey(Scalar([137, 157, 108, 182, 85, 81, 65, 229, 57, 73, 167, 162, 2, 217, 62, 101, 250, 241, 104, 38, 211, 8, 186, 194, 48, 222, 127, 218, 27, 186, 131, 3])));
/// SO: GDSO22EFATQCRMEGWKWHB72LFGIVSQAE2G42BKWRSTKEWEHLKNRIBLS6
static immutable SO = KeyPair(PublicKey(Point([228, 237, 104, 133, 4, 224, 40, 176, 134, 178, 172, 112, 255, 75, 41, 145, 89, 64, 4, 209, 185, 160, 170, 209, 148, 212, 75, 16, 235, 83, 98, 128])), SecretKey(Scalar([141, 146, 51, 134, 35, 240, 58, 118, 110, 3, 25, 177, 188, 17, 226, 101, 49, 94, 181, 107, 80, 187, 252, 204, 77, 230, 23, 252, 179, 113, 164, 4])));
/// SP: GDSP22VDS6KW3I42LISFZZJO5UPH3JQSRPERZLOWI6MFFEJX4AWERD5G
static immutable SP = KeyPair(PublicKey(Point([228, 253, 106, 163, 151, 149, 109, 163, 154, 90, 36, 92, 229, 46, 237, 30, 125, 166, 18, 139, 201, 28, 173, 214, 71, 152, 82, 145, 55, 224, 44, 72])), SecretKey(Scalar([182, 36, 50, 148, 240, 184, 201, 191, 34, 229, 61, 204, 200, 159, 207, 15, 117, 156, 158, 8, 173, 148, 55, 219, 220, 223, 128, 175, 156, 36, 85, 12])));
/// SQ: GDSQ22P3M5QQNYZOVDD26UQLASEANPRV5A33LDTZBVU4EVJA7OWFKI4S
static immutable SQ = KeyPair(PublicKey(Point([229, 13, 105, 251, 103, 97, 6, 227, 46, 168, 199, 175, 82, 11, 4, 136, 6, 190, 53, 232, 55, 181, 142, 121, 13, 105, 194, 85, 32, 251, 172, 85])), SecretKey(Scalar([108, 140, 191, 66, 189, 167, 106, 20, 225, 212, 24, 204, 173, 248, 119, 131, 108, 33, 130, 90, 7, 142, 106, 99, 2, 200, 122, 146, 200, 1, 27, 8])));
/// SR: GDSR22K55JHV7PWIPG4XPEAITQJE2PHGVLE6OFU5KQQ63MFEHA5XGEJJ
static immutable SR = KeyPair(PublicKey(Point([229, 29, 105, 93, 234, 79, 95, 190, 200, 121, 185, 119, 144, 8, 156, 18, 77, 60, 230, 170, 201, 231, 22, 157, 84, 33, 237, 176, 164, 56, 59, 115])), SecretKey(Scalar([106, 202, 217, 207, 77, 78, 162, 245, 219, 200, 174, 214, 169, 153, 251, 56, 91, 86, 87, 146, 91, 71, 13, 124, 135, 157, 216, 244, 186, 103, 135, 0])));
/// SS: GDSS22Y44BMWLRRLNQLPH7FVJJCOIVH7NGDC7CHXYO52WBYPHNJN2OOC
static immutable SS = KeyPair(PublicKey(Point([229, 45, 107, 28, 224, 89, 101, 198, 43, 108, 22, 243, 252, 181, 74, 68, 228, 84, 255, 105, 134, 47, 136, 247, 195, 187, 171, 7, 15, 59, 82, 221])), SecretKey(Scalar([223, 215, 110, 159, 10, 146, 87, 74, 24, 124, 254, 186, 228, 55, 120, 49, 119, 152, 11, 8, 61, 32, 255, 170, 190, 29, 255, 2, 141, 151, 155, 2])));
/// ST: GDST22ISE7RRLCACHA2HC7DB44BSRG27IJ62GGP2KJ5YNY276CEHMV3A
static immutable ST = KeyPair(PublicKey(Point([229, 61, 105, 18, 39, 227, 21, 136, 2, 56, 52, 113, 124, 97, 231, 3, 40, 155, 95, 66, 125, 163, 25, 250, 82, 123, 134, 227, 95, 240, 136, 118])), SecretKey(Scalar([102, 142, 205, 6, 128, 20, 162, 184, 83, 76, 126, 218, 170, 56, 52, 107, 153, 242, 29, 231, 248, 1, 107, 103, 63, 33, 39, 251, 2, 51, 241, 8])));
/// SU: GDSU22DPRMBRAJSD5F5BNFRDKD2TSR4AKTYRWRP47SUNJCZ4MQKNMK36
static immutable SU = KeyPair(PublicKey(Point([229, 77, 104, 111, 139, 3, 16, 38, 67, 233, 122, 22, 150, 35, 80, 245, 57, 71, 128, 84, 241, 27, 69, 252, 252, 168, 212, 139, 60, 100, 20, 214])), SecretKey(Scalar([215, 117, 5, 141, 250, 105, 104, 131, 41, 251, 36, 133, 39, 174, 156, 149, 220, 21, 218, 97, 206, 20, 241, 38, 119, 176, 95, 191, 162, 252, 99, 7])));
/// SV: GDSV22CNDR374FBVRJMGK4B6J2JTTZOPSSW5CSCI3AYV6A524A7VJVGP
static immutable SV = KeyPair(PublicKey(Point([229, 93, 104, 77, 28, 119, 254, 20, 53, 138, 88, 101, 112, 62, 78, 147, 57, 229, 207, 148, 173, 209, 72, 72, 216, 49, 95, 3, 186, 224, 63, 84])), SecretKey(Scalar([89, 199, 183, 0, 167, 145, 145, 153, 126, 154, 217, 220, 155, 93, 19, 69, 228, 250, 50, 184, 207, 9, 253, 242, 136, 105, 21, 182, 38, 25, 21, 7])));
/// SW: GDSW22LBP7BDUE6CIADXVJTG6FPZONK6VCX466IGYVFVYN7MVPT6Q2A4
static immutable SW = KeyPair(PublicKey(Point([229, 109, 105, 97, 127, 194, 58, 19, 194, 64, 7, 122, 166, 102, 241, 95, 151, 53, 94, 168, 175, 207, 121, 6, 197, 75, 92, 55, 236, 171, 231, 232])), SecretKey(Scalar([197, 253, 56, 38, 78, 187, 85, 205, 159, 101, 22, 82, 248, 188, 178, 23, 90, 187, 27, 125, 176, 216, 181, 65, 17, 99, 184, 150, 169, 139, 217, 8])));
/// SX: GDSX22GGUIDZHHWUO6IOKTJ4KUX235ZDYL2Y3P6POLTD2MMHA33QHUDN
static immutable SX = KeyPair(PublicKey(Point([229, 125, 104, 198, 162, 7, 147, 158, 212, 119, 144, 229, 77, 60, 85, 47, 173, 247, 35, 194, 245, 141, 191, 207, 114, 230, 61, 49, 135, 6, 247, 3])), SecretKey(Scalar([6, 230, 196, 156, 110, 237, 28, 117, 160, 139, 133, 64, 109, 58, 246, 29, 104, 158, 106, 203, 35, 173, 113, 198, 140, 109, 248, 42, 196, 45, 138, 1])));
/// SY: GDSY22UFFCJYH7QG6WQ5MBKA6ATSL7CIYAZQJZ4SCMYCFZTBOL4KWPMC
static immutable SY = KeyPair(PublicKey(Point([229, 141, 106, 133, 40, 147, 131, 254, 6, 245, 161, 214, 5, 64, 240, 39, 37, 252, 72, 192, 51, 4, 231, 146, 19, 48, 34, 230, 97, 114, 248, 171])), SecretKey(Scalar([220, 153, 216, 170, 198, 148, 142, 21, 61, 80, 109, 241, 177, 117, 201, 112, 206, 235, 217, 168, 58, 92, 54, 92, 88, 194, 102, 238, 72, 160, 56, 1])));
/// SZ: GDSZ226HLYO7EHG4PDWKXDMPNVZR4OEPTZPDXRU4A5Z5APXWN6EI75L4
static immutable SZ = KeyPair(PublicKey(Point([229, 157, 107, 199, 94, 29, 242, 28, 220, 120, 236, 171, 141, 143, 109, 115, 30, 56, 143, 158, 94, 59, 198, 156, 7, 115, 208, 62, 246, 111, 136, 143])), SecretKey(Scalar([199, 11, 135, 183, 191, 78, 229, 128, 183, 191, 130, 125, 147, 51, 86, 254, 40, 224, 243, 41, 181, 65, 73, 179, 172, 23, 175, 164, 57, 194, 105, 15])));
/// TA: GDTA22SFXBC5A4GT646SS6POREZ2G3JVUQEEOLZSBXCPUPJ24VEZBASC
static immutable TA = KeyPair(PublicKey(Point([230, 13, 106, 69, 184, 69, 208, 112, 211, 247, 61, 41, 121, 238, 137, 51, 163, 109, 53, 164, 8, 71, 47, 50, 13, 196, 250, 61, 58, 229, 73, 144])), SecretKey(Scalar([25, 44, 209, 222, 85, 225, 39, 232, 209, 62, 104, 171, 142, 188, 71, 155, 244, 83, 82, 188, 185, 86, 228, 220, 103, 243, 85, 44, 117, 255, 144, 11])));
/// TB: GDTB224QBJZGAH7ISJT2QIS3GV26DOHG54W5CUPUR5GY5Z2PO6SM5U7D
static immutable TB = KeyPair(PublicKey(Point([230, 29, 107, 144, 10, 114, 96, 31, 232, 146, 103, 168, 34, 91, 53, 117, 225, 184, 230, 239, 45, 209, 81, 244, 143, 77, 142, 231, 79, 119, 164, 206])), SecretKey(Scalar([129, 202, 219, 163, 25, 104, 116, 203, 68, 10, 131, 254, 40, 39, 74, 31, 28, 193, 89, 102, 79, 132, 185, 100, 53, 7, 254, 169, 222, 78, 212, 14])));
/// TC: GDTC22NVCWS6WMHFUZGHKGYJQ4PG7C2FR2KVTGCEUNKH7VAL4KACM6JE
static immutable TC = KeyPair(PublicKey(Point([230, 45, 105, 181, 21, 165, 235, 48, 229, 166, 76, 117, 27, 9, 135, 30, 111, 139, 69, 142, 149, 89, 152, 68, 163, 84, 127, 212, 11, 226, 128, 38])), SecretKey(Scalar([12, 92, 166, 150, 66, 199, 211, 162, 141, 51, 55, 43, 244, 144, 45, 33, 172, 103, 28, 243, 218, 160, 181, 57, 153, 99, 47, 69, 140, 173, 0, 12])));
/// TD: GDTD22ES3WQMO7DQ5C5SRSONIN232C3PNX3GA7VK3HIVH3JBTSUGRI2Y
static immutable TD = KeyPair(PublicKey(Point([230, 61, 104, 146, 221, 160, 199, 124, 112, 232, 187, 40, 201, 205, 67, 117, 189, 11, 111, 109, 246, 96, 126, 170, 217, 209, 83, 237, 33, 156, 168, 104])), SecretKey(Scalar([205, 8, 255, 99, 212, 149, 10, 18, 14, 10, 175, 138, 254, 74, 189, 50, 22, 209, 149, 185, 142, 180, 106, 78, 206, 42, 190, 19, 81, 115, 15, 7])));
/// TE: GDTE22BTVJH6JJFJWZVRAON2X4HSCUWMSFPLDJETVK7O3XQ7OCSRL24H
static immutable TE = KeyPair(PublicKey(Point([230, 77, 104, 51, 170, 79, 228, 164, 169, 182, 107, 16, 57, 186, 191, 15, 33, 82, 204, 145, 94, 177, 164, 147, 170, 190, 237, 222, 31, 112, 165, 21])), SecretKey(Scalar([163, 132, 54, 1, 249, 152, 107, 153, 246, 212, 76, 186, 147, 85, 206, 156, 118, 222, 212, 80, 160, 58, 105, 45, 249, 210, 1, 99, 216, 32, 10, 10])));
/// TF: GDTF22PBXHQCPE3NLODER26CPX3DQIISI4I7K3YBWBZPQJOZM2WBWK4Z
static immutable TF = KeyPair(PublicKey(Point([230, 93, 105, 225, 185, 224, 39, 147, 109, 91, 134, 72, 235, 194, 125, 246, 56, 33, 18, 71, 17, 245, 111, 1, 176, 114, 248, 37, 217, 102, 172, 27])), SecretKey(Scalar([179, 236, 249, 125, 178, 134, 143, 230, 74, 60, 127, 5, 49, 207, 213, 14, 37, 170, 29, 52, 26, 56, 53, 185, 42, 15, 185, 143, 23, 78, 64, 8])));
/// TG: GDTG227MRBPUJC3DM3US4UMWZEWULHOTZ5FBLVX65QT3ANVBFYXZEERV
static immutable TG = KeyPair(PublicKey(Point([230, 109, 107, 236, 136, 95, 68, 139, 99, 102, 233, 46, 81, 150, 201, 45, 69, 157, 211, 207, 74, 21, 214, 254, 236, 39, 176, 54, 161, 46, 47, 146])), SecretKey(Scalar([81, 108, 31, 110, 226, 115, 27, 63, 72, 139, 180, 11, 204, 185, 225, 9, 201, 111, 142, 235, 3, 218, 103, 240, 141, 119, 153, 228, 5, 66, 64, 3])));
/// TH: GDTH222LOG3XT2MPJYKON5HFERDUGR7JI23UJMFSKKQZLRBPDPUKPNSC
static immutable TH = KeyPair(PublicKey(Point([230, 125, 107, 75, 113, 183, 121, 233, 143, 78, 20, 230, 244, 229, 36, 71, 67, 71, 233, 70, 183, 68, 176, 178, 82, 161, 149, 196, 47, 27, 232, 167])), SecretKey(Scalar([61, 144, 198, 235, 208, 80, 116, 186, 96, 181, 87, 24, 20, 253, 64, 241, 14, 35, 101, 105, 109, 198, 253, 2, 89, 141, 11, 43, 11, 72, 206, 8])));
/// TI: GDTI22CZOCCMO3YG6WVQXFA7WNBIU7H2KSNURELIEKFYESIUVX3DHIOD
static immutable TI = KeyPair(PublicKey(Point([230, 141, 104, 89, 112, 132, 199, 111, 6, 245, 171, 11, 148, 31, 179, 66, 138, 124, 250, 84, 155, 72, 145, 104, 34, 139, 130, 73, 20, 173, 246, 51])), SecretKey(Scalar([40, 102, 102, 219, 136, 67, 59, 250, 164, 167, 29, 138, 16, 36, 69, 96, 28, 39, 100, 187, 8, 125, 116, 199, 8, 175, 59, 160, 28, 46, 194, 12])));
/// TJ: GDTJ22VD6KFMY4FQKSZTMPJISGJV4OX2HQ5HWLFWGMC7DPE4OTAUTBL6
static immutable TJ = KeyPair(PublicKey(Point([230, 157, 106, 163, 242, 138, 204, 112, 176, 84, 179, 54, 61, 40, 145, 147, 94, 58, 250, 60, 58, 123, 44, 182, 51, 5, 241, 188, 156, 116, 193, 73])), SecretKey(Scalar([145, 227, 13, 156, 179, 120, 114, 115, 41, 216, 65, 144, 33, 73, 163, 96, 211, 23, 11, 124, 62, 6, 87, 208, 27, 32, 156, 43, 232, 168, 167, 5])));
/// TK: GDTK22KZN6EPR7AMBVEYPWXXZC4AZZK3RCECGT6WJC5UYVS7OKUFK5BM
static immutable TK = KeyPair(PublicKey(Point([230, 173, 105, 89, 111, 136, 248, 252, 12, 13, 73, 135, 218, 247, 200, 184, 12, 229, 91, 136, 136, 35, 79, 214, 72, 187, 76, 86, 95, 114, 168, 85])), SecretKey(Scalar([152, 60, 215, 34, 177, 81, 206, 21, 201, 18, 20, 145, 207, 246, 234, 203, 192, 89, 222, 12, 231, 172, 159, 210, 214, 225, 25, 248, 75, 97, 221, 3])));
/// TL: GDTL22ZJDC44AJTOSEQF2U54E3VLUKQNHEK3HZEXIC6ZJ35K3D257DXZ
static immutable TL = KeyPair(PublicKey(Point([230, 189, 107, 41, 24, 185, 192, 38, 110, 145, 32, 93, 83, 188, 38, 234, 186, 42, 13, 57, 21, 179, 228, 151, 64, 189, 148, 239, 170, 216, 245, 223])), SecretKey(Scalar([165, 2, 76, 73, 59, 40, 134, 132, 166, 188, 90, 213, 29, 118, 64, 27, 164, 204, 20, 0, 15, 39, 159, 29, 37, 168, 213, 125, 101, 213, 119, 11])));
/// TM: GDTM22ZSRSBQFVTVOE2ENNTVPMLCJSY26EWS3APLVZCY5SOBBK44PIFM
static immutable TM = KeyPair(PublicKey(Point([230, 205, 107, 50, 140, 131, 2, 214, 117, 113, 52, 70, 182, 117, 123, 22, 36, 203, 26, 241, 45, 45, 129, 235, 174, 69, 142, 201, 193, 10, 185, 199])), SecretKey(Scalar([72, 212, 145, 240, 209, 135, 131, 179, 104, 166, 75, 30, 172, 76, 0, 152, 89, 140, 30, 6, 154, 163, 106, 54, 93, 95, 76, 81, 249, 3, 165, 12])));
/// TN: GDTN223OJE5Y7DGTXC7UK36MCIMBPL6BY76BZCNGXXUDLLHBUE3FXQ2Z
static immutable TN = KeyPair(PublicKey(Point([230, 221, 107, 110, 73, 59, 143, 140, 211, 184, 191, 69, 111, 204, 18, 24, 23, 175, 193, 199, 252, 28, 137, 166, 189, 232, 53, 172, 225, 161, 54, 91])), SecretKey(Scalar([42, 123, 66, 195, 178, 234, 50, 156, 184, 228, 26, 13, 244, 42, 62, 93, 197, 204, 15, 206, 106, 227, 240, 42, 95, 154, 252, 126, 155, 228, 215, 1])));
/// TO: GDTO22M6VWRKDTJXURKILLV4WDFONAELN7IGULWRBHSOB5WR6CXLWXKM
static immutable TO = KeyPair(PublicKey(Point([230, 237, 105, 158, 173, 162, 161, 205, 55, 164, 84, 133, 174, 188, 176, 202, 230, 128, 139, 111, 208, 106, 46, 209, 9, 228, 224, 246, 209, 240, 174, 187])), SecretKey(Scalar([51, 221, 173, 218, 31, 62, 175, 186, 102, 155, 83, 242, 146, 156, 61, 67, 2, 209, 230, 85, 128, 98, 159, 14, 161, 211, 246, 168, 27, 129, 228, 7])));
/// TP: GDTP227NGRIAGSTYHMM4OPDUY3PXH6PZ4KJPTA6RULEBFDBFSTFEPNZA
static immutable TP = KeyPair(PublicKey(Point([230, 253, 107, 237, 52, 80, 3, 74, 120, 59, 25, 199, 60, 116, 198, 223, 115, 249, 249, 226, 146, 249, 131, 209, 162, 200, 18, 140, 37, 148, 202, 71])), SecretKey(Scalar([145, 132, 240, 234, 89, 122, 244, 108, 161, 1, 33, 98, 202, 38, 38, 237, 103, 19, 146, 112, 32, 55, 208, 76, 250, 115, 22, 84, 57, 48, 99, 4])));
/// TQ: GDTQ22GQYDIDZRMAJNT2OYH442BTRBX2YQUTIDT7FRVRATNORKCPQC7Y
static immutable TQ = KeyPair(PublicKey(Point([231, 13, 104, 208, 192, 208, 60, 197, 128, 75, 103, 167, 96, 252, 230, 131, 56, 134, 250, 196, 41, 52, 14, 127, 44, 107, 16, 77, 174, 138, 132, 248])), SecretKey(Scalar([102, 251, 202, 230, 110, 87, 159, 128, 240, 44, 255, 150, 179, 249, 116, 86, 209, 126, 176, 231, 33, 0, 179, 145, 174, 79, 15, 20, 16, 160, 18, 10])));
/// TR: GDTR22CEQTPTIRH5DCUZCSUNNTZXCFADXJKLV4Z3RRTPYYAYK5SMU5CA
static immutable TR = KeyPair(PublicKey(Point([231, 29, 104, 68, 132, 223, 52, 68, 253, 24, 169, 145, 74, 141, 108, 243, 113, 20, 3, 186, 84, 186, 243, 59, 140, 102, 252, 96, 24, 87, 100, 202])), SecretKey(Scalar([206, 109, 216, 101, 32, 199, 197, 230, 213, 209, 111, 178, 222, 192, 137, 81, 157, 112, 134, 4, 107, 229, 11, 243, 226, 199, 137, 210, 245, 222, 26, 1])));
/// TS: GDTS22KFWOYKOI2HUJDXNB5A24RN7VSMGC4355RAE3YN2MQ2HLPJJQ6S
static immutable TS = KeyPair(PublicKey(Point([231, 45, 105, 69, 179, 176, 167, 35, 71, 162, 71, 118, 135, 160, 215, 34, 223, 214, 76, 48, 185, 190, 246, 32, 38, 240, 221, 50, 26, 58, 222, 148])), SecretKey(Scalar([187, 251, 163, 39, 125, 70, 219, 2, 151, 217, 85, 81, 18, 236, 230, 117, 175, 70, 134, 81, 241, 86, 228, 245, 207, 118, 22, 113, 1, 136, 23, 4])));
/// TT: GDTT22ZKP4T6ZHQVBK3YKLCUR2IWG36A7EHC24VNNIYEVIX5Z3EA7G2D
static immutable TT = KeyPair(PublicKey(Point([231, 61, 107, 42, 127, 39, 236, 158, 21, 10, 183, 133, 44, 84, 142, 145, 99, 111, 192, 249, 14, 45, 114, 173, 106, 48, 74, 162, 253, 206, 200, 15])), SecretKey(Scalar([131, 113, 214, 199, 95, 213, 27, 0, 241, 17, 127, 199, 103, 243, 249, 47, 17, 29, 158, 78, 87, 99, 41, 234, 14, 75, 100, 104, 180, 227, 212, 9])));
/// TU: GDTU22BPM6UXQNEO7QRQCK4IZ3LHSOYEZDF5IQFRCO5XEH6Q7ZUBUKPD
static immutable TU = KeyPair(PublicKey(Point([231, 77, 104, 47, 103, 169, 120, 52, 142, 252, 35, 1, 43, 136, 206, 214, 121, 59, 4, 200, 203, 212, 64, 177, 19, 187, 114, 31, 208, 254, 104, 26])), SecretKey(Scalar([122, 179, 30, 156, 39, 75, 45, 66, 226, 34, 244, 152, 235, 139, 218, 211, 10, 27, 76, 223, 70, 29, 92, 161, 149, 85, 114, 109, 105, 170, 33, 10])));
/// TV: GDTV222CYXX4PDSZ5LRM26BIVDYHPUECVPQU2G6V6LV7NFW4REIB67UX
static immutable TV = KeyPair(PublicKey(Point([231, 93, 107, 66, 197, 239, 199, 142, 89, 234, 226, 205, 120, 40, 168, 240, 119, 208, 130, 171, 225, 77, 27, 213, 242, 235, 246, 150, 220, 137, 16, 31])), SecretKey(Scalar([21, 148, 19, 43, 67, 148, 134, 139, 50, 79, 58, 58, 193, 224, 250, 30, 178, 134, 144, 220, 161, 138, 184, 12, 81, 230, 183, 47, 217, 218, 194, 10])));
/// TW: GDTW22FCTFPAOCUG5UBFE6KTRW7TBU5JKUL2Z4N3HKRP3OWXBNDZRBKE
static immutable TW = KeyPair(PublicKey(Point([231, 109, 104, 162, 153, 94, 7, 10, 134, 237, 2, 82, 121, 83, 141, 191, 48, 211, 169, 85, 23, 172, 241, 187, 58, 162, 253, 186, 215, 11, 71, 152])), SecretKey(Scalar([211, 72, 11, 171, 166, 249, 226, 13, 22, 166, 112, 138, 214, 213, 117, 42, 112, 249, 72, 92, 135, 216, 20, 220, 107, 203, 123, 118, 226, 42, 170, 10])));
/// TX: GDTX22FGAOWR6CLMX3R4HF6PMH73KVS4OBTSKHXNPX2XQEWX2VBXPJM7
static immutable TX = KeyPair(PublicKey(Point([231, 125, 104, 166, 3, 173, 31, 9, 108, 190, 227, 195, 151, 207, 97, 255, 181, 86, 92, 112, 103, 37, 30, 237, 125, 245, 120, 18, 215, 213, 67, 119])), SecretKey(Scalar([62, 48, 232, 87, 62, 190, 85, 167, 138, 105, 169, 190, 39, 50, 175, 76, 106, 29, 74, 207, 24, 51, 165, 76, 19, 83, 243, 204, 121, 65, 100, 13])));
/// TY: GDTY22RUKDVOZETSVAJLD2I3ONIEIMCNVYHLKTFOEUVTKMOBWPGSDW3C
static immutable TY = KeyPair(PublicKey(Point([231, 141, 106, 52, 80, 234, 236, 146, 114, 168, 18, 177, 233, 27, 115, 80, 68, 48, 77, 174, 14, 181, 76, 174, 37, 43, 53, 49, 193, 179, 205, 33])), SecretKey(Scalar([47, 100, 238, 179, 239, 151, 29, 175, 54, 71, 166, 198, 68, 156, 152, 69, 69, 236, 105, 168, 32, 254, 142, 173, 226, 212, 175, 60, 241, 13, 34, 5])));
/// TZ: GDTZ22Z5CVKYDYVV6AQSL7DSNVHMKPRWDLL5XECQ6DYKGRRBX6EBCEFX
static immutable TZ = KeyPair(PublicKey(Point([231, 157, 107, 61, 21, 85, 129, 226, 181, 240, 33, 37, 252, 114, 109, 78, 197, 62, 54, 26, 215, 219, 144, 80, 240, 240, 163, 70, 33, 191, 136, 17])), SecretKey(Scalar([15, 134, 24, 174, 231, 81, 160, 235, 239, 149, 185, 212, 91, 193, 202, 42, 223, 209, 92, 254, 62, 181, 144, 182, 235, 152, 8, 125, 206, 127, 208, 11])));
/// UA: GDUA22BVCXC5EWA3BW2EBXYTMG4LGHNLBFK7WPUFDBIGJNZY6563HFTD
static immutable UA = KeyPair(PublicKey(Point([232, 13, 104, 53, 21, 197, 210, 88, 27, 13, 180, 64, 223, 19, 97, 184, 179, 29, 171, 9, 85, 251, 62, 133, 24, 80, 100, 183, 56, 247, 125, 179])), SecretKey(Scalar([236, 87, 56, 178, 53, 21, 221, 105, 95, 135, 109, 83, 11, 10, 246, 127, 79, 207, 249, 255, 206, 47, 123, 108, 205, 123, 122, 132, 151, 150, 21, 14])));
/// UB: GDUB22VFRFOEEGDEKFJCWB27HD3MBIOJ6XMNFFYN2AWNGCOWA2S2WUNB
static immutable UB = KeyPair(PublicKey(Point([232, 29, 106, 165, 137, 92, 66, 24, 100, 81, 82, 43, 7, 95, 56, 246, 192, 161, 201, 245, 216, 210, 151, 13, 208, 44, 211, 9, 214, 6, 165, 171])), SecretKey(Scalar([163, 93, 223, 162, 219, 140, 11, 96, 83, 92, 202, 13, 213, 8, 53, 79, 25, 26, 123, 238, 190, 255, 121, 68, 249, 237, 51, 247, 19, 201, 20, 11])));
/// UC: GDUC22UVTMZNN4XO2R64KT2YEXCSWLRY2DO22TGTBDPDOU7ZJWNA77DD
static immutable UC = KeyPair(PublicKey(Point([232, 45, 106, 149, 155, 50, 214, 242, 238, 212, 125, 197, 79, 88, 37, 197, 43, 46, 56, 208, 221, 173, 76, 211, 8, 222, 55, 83, 249, 77, 154, 15])), SecretKey(Scalar([95, 146, 132, 239, 12, 44, 186, 240, 10, 25, 97, 178, 139, 225, 224, 83, 40, 172, 251, 221, 190, 124, 93, 73, 104, 180, 126, 42, 159, 88, 135, 2])));
/// UD: GDUD22Y3BX3YFCXAGQDQENQ5EJWJMWKXMSQZJMDZRFX3BE7VH22C7TLU
static immutable UD = KeyPair(PublicKey(Point([232, 61, 107, 27, 13, 247, 130, 138, 224, 52, 7, 2, 54, 29, 34, 108, 150, 89, 87, 100, 161, 148, 176, 121, 137, 111, 176, 147, 245, 62, 180, 47])), SecretKey(Scalar([219, 251, 51, 90, 7, 192, 22, 139, 166, 165, 119, 13, 212, 37, 88, 167, 16, 115, 213, 101, 8, 164, 175, 130, 40, 114, 37, 112, 90, 208, 49, 7])));
/// UE: GDUE22VH7L4OE4WDX5ZAJR3XB2NWW3YNXFYCGVWC7QESA2PIQOHWGIGB
static immutable UE = KeyPair(PublicKey(Point([232, 77, 106, 167, 250, 248, 226, 114, 195, 191, 114, 4, 199, 119, 14, 155, 107, 111, 13, 185, 112, 35, 86, 194, 252, 9, 32, 105, 232, 131, 143, 99])), SecretKey(Scalar([127, 39, 239, 172, 169, 184, 209, 119, 29, 94, 245, 15, 189, 154, 207, 50, 182, 60, 220, 48, 207, 167, 36, 130, 7, 116, 146, 59, 188, 236, 62, 13])));
/// UF: GDUF22R726TNCOX5RWEY7C7GQF5KZVCUUSQVRAD5262O3TGZALMVP53K
static immutable UF = KeyPair(PublicKey(Point([232, 93, 106, 63, 215, 166, 209, 58, 253, 141, 137, 143, 139, 230, 129, 122, 172, 212, 84, 164, 161, 88, 128, 125, 215, 180, 237, 204, 217, 2, 217, 87])), SecretKey(Scalar([231, 234, 73, 98, 160, 244, 100, 115, 102, 148, 124, 143, 197, 57, 61, 120, 131, 130, 199, 179, 163, 213, 165, 5, 171, 111, 198, 111, 202, 248, 2, 6])));
/// UG: GDUG22IRFERRSLZ2HQU5YBWJSACQJHUFPQAZNGGHPF3OIQYX42NP2KFN
static immutable UG = KeyPair(PublicKey(Point([232, 109, 105, 17, 41, 35, 25, 47, 58, 60, 41, 220, 6, 201, 144, 5, 4, 158, 133, 124, 1, 150, 152, 199, 121, 118, 228, 67, 23, 230, 154, 253])), SecretKey(Scalar([101, 19, 168, 16, 194, 114, 19, 80, 226, 142, 39, 125, 56, 151, 27, 5, 127, 173, 215, 251, 241, 197, 56, 48, 88, 224, 153, 186, 26, 43, 118, 9])));
/// UH: GDUH22TDMMGOC3XQ2IY4PVP3FGYKRDZZZO4JESZTB7OHG7OQYXVYIYFA
static immutable UH = KeyPair(PublicKey(Point([232, 125, 106, 99, 99, 12, 225, 110, 240, 210, 49, 199, 213, 251, 41, 176, 168, 143, 57, 203, 184, 146, 75, 51, 15, 220, 115, 125, 208, 197, 235, 132])), SecretKey(Scalar([94, 27, 189, 57, 56, 42, 132, 9, 117, 244, 125, 13, 170, 172, 30, 76, 241, 83, 217, 157, 11, 186, 226, 52, 91, 102, 152, 40, 203, 235, 246, 13])));
/// UI: GDUI22JUCEPHWQ5BLMVQG3XGHS4TGK7DHB6RV3I4X6QBIQXFNFZRXXDB
static immutable UI = KeyPair(PublicKey(Point([232, 141, 105, 52, 17, 30, 123, 67, 161, 91, 43, 3, 110, 230, 60, 185, 51, 43, 227, 56, 125, 26, 237, 28, 191, 160, 20, 66, 229, 105, 115, 27])), SecretKey(Scalar([107, 123, 241, 243, 124, 53, 141, 49, 119, 5, 54, 61, 108, 108, 241, 171, 79, 236, 157, 40, 181, 202, 207, 9, 57, 109, 98, 228, 185, 180, 127, 2])));
/// UJ: GDUJ226QFGTQKQJ4ZJ6RTP45AY2XB43AIOHH774UXAGOICS2YPGLGOII
static immutable UJ = KeyPair(PublicKey(Point([232, 157, 107, 208, 41, 167, 5, 65, 60, 202, 125, 25, 191, 157, 6, 53, 112, 243, 96, 67, 142, 127, 255, 148, 184, 12, 228, 10, 90, 195, 204, 179])), SecretKey(Scalar([255, 183, 58, 49, 248, 217, 193, 1, 28, 140, 221, 253, 36, 190, 62, 60, 50, 242, 179, 65, 49, 230, 92, 74, 172, 143, 15, 31, 57, 243, 121, 0])));
/// UK: GDUK22MASFCJN7OCANQOKXQWEH5HRPCMXREF22ZHN47HSFI2PJ346XAY
static immutable UK = KeyPair(PublicKey(Point([232, 173, 105, 128, 145, 68, 150, 253, 194, 3, 96, 229, 94, 22, 33, 250, 120, 188, 76, 188, 72, 93, 107, 39, 111, 62, 121, 21, 26, 122, 119, 207])), SecretKey(Scalar([219, 94, 201, 120, 199, 168, 42, 3, 245, 104, 182, 52, 78, 45, 161, 103, 8, 120, 62, 73, 55, 173, 145, 207, 52, 180, 139, 120, 5, 22, 224, 1])));
/// UL: GDUL22U64J7SUWIYNFMVOZN34EE5WVAZAJJFBGB3HWNH32UBTNICFJJX
static immutable UL = KeyPair(PublicKey(Point([232, 189, 106, 158, 226, 127, 42, 89, 24, 105, 89, 87, 101, 187, 225, 9, 219, 84, 25, 2, 82, 80, 152, 59, 61, 154, 125, 234, 129, 155, 80, 34])), SecretKey(Scalar([116, 82, 3, 157, 199, 36, 65, 116, 110, 63, 103, 78, 230, 192, 143, 148, 194, 56, 141, 46, 66, 82, 112, 75, 154, 51, 23, 200, 74, 72, 155, 15])));
/// UM: GDUM22EUPOHCIWPW6E5AOUVRCMT5KIDHEZKSKW6DJOEBL5WQC7LPB4AF
static immutable UM = KeyPair(PublicKey(Point([232, 205, 104, 148, 123, 142, 36, 89, 246, 241, 58, 7, 82, 177, 19, 39, 213, 32, 103, 38, 85, 37, 91, 195, 75, 136, 21, 246, 208, 23, 214, 240])), SecretKey(Scalar([1, 207, 157, 5, 219, 9, 217, 145, 46, 67, 187, 202, 53, 144, 240, 137, 76, 199, 161, 40, 222, 171, 183, 38, 155, 227, 145, 133, 85, 110, 47, 12])));
/// UN: GDUN22XAWS5P2QIWZJ4COBFX7GCI3QYE27F3JHY4SY6JKCGZKVVRIDOK
static immutable UN = KeyPair(PublicKey(Point([232, 221, 106, 224, 180, 186, 253, 65, 22, 202, 120, 39, 4, 183, 249, 132, 141, 195, 4, 215, 203, 180, 159, 28, 150, 60, 149, 8, 217, 85, 107, 20])), SecretKey(Scalar([88, 97, 19, 189, 118, 215, 242, 169, 42, 186, 110, 34, 134, 131, 150, 178, 237, 10, 26, 233, 21, 255, 219, 185, 42, 93, 230, 41, 44, 203, 223, 3])));
/// UO: GDUO22EUSMDG2JCMY56TXEX4NPKK2KL3BQ3BPKTVH65N27XCDRIKFGST
static immutable UO = KeyPair(PublicKey(Point([232, 237, 104, 148, 147, 6, 109, 36, 76, 199, 125, 59, 146, 252, 107, 212, 173, 41, 123, 12, 54, 23, 170, 117, 63, 186, 221, 126, 226, 28, 80, 162])), SecretKey(Scalar([245, 171, 160, 186, 78, 10, 144, 175, 209, 201, 81, 40, 251, 25, 34, 123, 226, 19, 120, 169, 246, 202, 241, 232, 58, 182, 198, 13, 238, 188, 158, 7])));
/// UP: GDUP22UNKSWY7Y7LZZTAEGPHB74IQKHAOZ6JMELJRJKRHJ63GHQ4TFTJ
static immutable UP = KeyPair(PublicKey(Point([232, 253, 106, 141, 84, 173, 143, 227, 235, 206, 102, 2, 25, 231, 15, 248, 136, 40, 224, 118, 124, 150, 17, 105, 138, 85, 19, 167, 219, 49, 225, 201])), SecretKey(Scalar([92, 123, 230, 204, 167, 192, 11, 201, 154, 248, 156, 102, 173, 64, 29, 196, 25, 64, 55, 164, 6, 107, 183, 252, 126, 139, 110, 53, 175, 93, 11, 7])));
/// UQ: GDUQ227SLCX3XDQDQEQ3OCVO34NNJXZINB7C62D45XT5WCVNW2LS4IAT
static immutable UQ = KeyPair(PublicKey(Point([233, 13, 107, 242, 88, 175, 187, 142, 3, 129, 33, 183, 10, 174, 223, 26, 212, 223, 40, 104, 126, 47, 104, 124, 237, 231, 219, 10, 173, 182, 151, 46])), SecretKey(Scalar([65, 157, 224, 29, 96, 27, 149, 63, 102, 0, 78, 67, 0, 122, 139, 163, 40, 60, 123, 16, 111, 79, 251, 82, 100, 10, 118, 181, 31, 118, 81, 0])));
/// UR: GDUR22NDD73MFUP6BCDLO2WNGMAOWPHKOZIP6SKHA2DUJ5F25HBSMSVV
static immutable UR = KeyPair(PublicKey(Point([233, 29, 105, 163, 31, 246, 194, 209, 254, 8, 134, 183, 106, 205, 51, 0, 235, 60, 234, 118, 80, 255, 73, 71, 6, 135, 68, 244, 186, 233, 195, 38])), SecretKey(Scalar([85, 118, 171, 39, 68, 58, 195, 175, 56, 74, 57, 27, 39, 81, 72, 76, 218, 30, 69, 170, 107, 8, 70, 107, 124, 212, 189, 69, 12, 144, 61, 2])));
/// US: GDUS22SBDN2J3RXIQGQC3JD23MWMZNVTDCGAYK3JFNTYB4HRKYCSY3XS
static immutable US = KeyPair(PublicKey(Point([233, 45, 106, 65, 27, 116, 157, 198, 232, 129, 160, 45, 164, 122, 219, 44, 204, 182, 179, 24, 140, 12, 43, 105, 43, 103, 128, 240, 241, 86, 5, 44])), SecretKey(Scalar([166, 190, 22, 156, 165, 137, 241, 36, 1, 123, 148, 236, 22, 97, 54, 172, 202, 170, 188, 55, 98, 101, 178, 89, 181, 32, 14, 70, 128, 145, 151, 4])));
/// UT: GDUT22OZ4A4Q6P7LT2YCQ7NU33E2B6IGUCWXDTBGX5XUFS5VHIYT4AID
static immutable UT = KeyPair(PublicKey(Point([233, 61, 105, 217, 224, 57, 15, 63, 235, 158, 176, 40, 125, 180, 222, 201, 160, 249, 6, 160, 173, 113, 204, 38, 191, 111, 66, 203, 181, 58, 49, 62])), SecretKey(Scalar([197, 236, 226, 211, 64, 131, 126, 179, 85, 9, 11, 2, 115, 171, 235, 234, 124, 151, 234, 93, 15, 24, 230, 250, 67, 25, 197, 178, 85, 163, 250, 6])));
/// UU: GDUU22S34MEY2IVIYVXXVSMFBXK6DDSSXQ4RC5DXMSRMC6JMWDBF6SRB
static immutable UU = KeyPair(PublicKey(Point([233, 77, 106, 91, 227, 9, 141, 34, 168, 197, 111, 122, 201, 133, 13, 213, 225, 142, 82, 188, 57, 17, 116, 119, 100, 162, 193, 121, 44, 176, 194, 95])), SecretKey(Scalar([178, 8, 78, 48, 161, 120, 172, 84, 103, 224, 214, 110, 120, 104, 70, 98, 154, 233, 198, 41, 178, 228, 193, 12, 100, 140, 53, 50, 118, 253, 237, 9])));
/// UV: GDUV22BXRHHAHX6XX75XMIX3DI6M2N5D4DUWFHRU4WXGWJQ2JJ5MGV5V
static immutable UV = KeyPair(PublicKey(Point([233, 93, 104, 55, 137, 206, 3, 223, 215, 191, 251, 118, 34, 251, 26, 60, 205, 55, 163, 224, 233, 98, 158, 52, 229, 174, 107, 38, 26, 74, 122, 195])), SecretKey(Scalar([47, 108, 82, 188, 75, 177, 216, 127, 80, 94, 100, 249, 247, 123, 18, 28, 77, 118, 103, 1, 173, 141, 30, 62, 129, 242, 74, 115, 181, 137, 216, 12])));
/// UW: GDUW22EDUFS4H4JEWSM7WM3VJYSRDNAXCQTPOQDP3IFR6ZMUPCR5T35M
static immutable UW = KeyPair(PublicKey(Point([233, 109, 104, 131, 161, 101, 195, 241, 36, 180, 153, 251, 51, 117, 78, 37, 17, 180, 23, 20, 38, 247, 64, 111, 218, 11, 31, 101, 148, 120, 163, 217])), SecretKey(Scalar([154, 35, 87, 15, 21, 108, 225, 211, 172, 6, 53, 16, 109, 109, 183, 92, 24, 116, 146, 101, 38, 252, 146, 112, 197, 47, 129, 121, 251, 211, 97, 13])));
/// UX: GDUX22L4MZGMJ3T5GKTWIVSGLNEFHMENIYJY5E2IGXKJX6DAFABDOMOL
static immutable UX = KeyPair(PublicKey(Point([233, 125, 105, 124, 102, 76, 196, 238, 125, 50, 167, 100, 86, 70, 91, 72, 83, 176, 141, 70, 19, 142, 147, 72, 53, 212, 155, 248, 96, 40, 2, 55])), SecretKey(Scalar([84, 46, 238, 79, 187, 47, 83, 9, 18, 28, 240, 71, 78, 38, 33, 99, 233, 216, 90, 77, 104, 201, 55, 9, 87, 7, 207, 70, 148, 26, 240, 15])));
/// UY: GDUY22HGV6UD3S3L3W46D3GEMX6TFM2TK6WUCPC3F4C3G2XHYBR53WPM
static immutable UY = KeyPair(PublicKey(Point([233, 141, 104, 230, 175, 168, 61, 203, 107, 221, 185, 225, 236, 196, 101, 253, 50, 179, 83, 87, 173, 65, 60, 91, 47, 5, 179, 106, 231, 192, 99, 221])), SecretKey(Scalar([19, 128, 4, 184, 186, 213, 237, 130, 80, 107, 215, 198, 75, 116, 238, 254, 78, 28, 168, 152, 126, 128, 165, 0, 24, 49, 90, 148, 39, 17, 226, 13])));
/// UZ: GDUZ224EYPD564KUBUIYMQL42L42AQI5QCBPO6B6JTLCYUZIVXNO4VX6
static immutable UZ = KeyPair(PublicKey(Point([233, 157, 107, 132, 195, 199, 223, 113, 84, 13, 17, 134, 65, 124, 210, 249, 160, 65, 29, 128, 130, 247, 120, 62, 76, 214, 44, 83, 40, 173, 218, 238])), SecretKey(Scalar([26, 181, 43, 221, 57, 133, 21, 31, 171, 36, 135, 1, 229, 182, 82, 1, 251, 149, 250, 28, 234, 98, 86, 19, 190, 220, 99, 200, 194, 94, 197, 9])));
/// VA: GDVA22744AWAZ6OTGO4RPLXTEIW4VZ6XAGNAKCIBWNXUYXEEUIQKQVGF
static immutable VA = KeyPair(PublicKey(Point([234, 13, 107, 252, 224, 44, 12, 249, 211, 51, 185, 23, 174, 243, 34, 45, 202, 231, 215, 1, 154, 5, 9, 1, 179, 111, 76, 92, 132, 162, 32, 168])), SecretKey(Scalar([35, 16, 98, 218, 118, 191, 252, 194, 16, 238, 175, 198, 244, 187, 142, 240, 193, 131, 28, 157, 97, 53, 145, 28, 146, 102, 25, 99, 195, 226, 218, 10])));
/// VB: GDVB22AGXQKUA4ZOAV5WWC4EN6ZUTNU766X546IA37DM5H4WPGJMKB4I
static immutable VB = KeyPair(PublicKey(Point([234, 29, 104, 6, 188, 21, 64, 115, 46, 5, 123, 107, 11, 132, 111, 179, 73, 182, 159, 247, 175, 222, 121, 0, 223, 198, 206, 159, 150, 121, 146, 197])), SecretKey(Scalar([213, 33, 206, 0, 154, 208, 5, 40, 72, 51, 55, 229, 56, 1, 249, 193, 130, 237, 56, 43, 239, 22, 187, 255, 213, 66, 217, 113, 179, 174, 71, 1])));
/// VC: GDVC22N5Y6E3GJ563PSPYUKJO5HLSW26L3DETCGITVR6IGI63E5AAEPP
static immutable VC = KeyPair(PublicKey(Point([234, 45, 105, 189, 199, 137, 179, 39, 190, 219, 228, 252, 81, 73, 119, 78, 185, 91, 94, 94, 198, 73, 136, 200, 157, 99, 228, 25, 30, 217, 58, 0])), SecretKey(Scalar([148, 190, 96, 133, 5, 149, 150, 93, 158, 219, 153, 249, 51, 218, 83, 40, 172, 86, 204, 241, 197, 190, 124, 233, 215, 215, 236, 148, 29, 91, 59, 10])));
/// VD: GDVD22R5C56CXPMOQ3NAR6PX5MGTZKJAUXH6FHXGQMPFPAV2TDQRBOC5
static immutable VD = KeyPair(PublicKey(Point([234, 61, 106, 61, 23, 124, 43, 189, 142, 134, 218, 8, 249, 247, 235, 13, 60, 169, 32, 165, 207, 226, 158, 230, 131, 30, 87, 130, 186, 152, 225, 16])), SecretKey(Scalar([22, 154, 73, 152, 152, 79, 248, 237, 239, 181, 248, 226, 121, 145, 138, 230, 242, 206, 211, 245, 86, 35, 108, 234, 182, 37, 60, 101, 251, 112, 82, 2])));
/// VE: GDVE22OFFX2E2ZBDE6HBJH44PNCCBFYPY52MGJLS4FR3S2ZKWC6DX7XJ
static immutable VE = KeyPair(PublicKey(Point([234, 77, 105, 197, 45, 244, 77, 100, 35, 39, 142, 20, 159, 156, 123, 68, 32, 151, 15, 199, 116, 195, 37, 114, 225, 99, 185, 107, 42, 176, 188, 59])), SecretKey(Scalar([9, 129, 199, 195, 139, 55, 114, 16, 108, 163, 207, 36, 122, 79, 168, 40, 80, 111, 184, 10, 83, 148, 242, 229, 120, 61, 11, 120, 243, 57, 62, 12])));
/// VF: GDVF22QXMABFCTGI3WD373V3RMOUVNHLYK6EUGU3X763IHBS7QPKDKJ4
static immutable VF = KeyPair(PublicKey(Point([234, 93, 106, 23, 96, 2, 81, 76, 200, 221, 135, 191, 238, 187, 139, 29, 74, 180, 235, 194, 188, 74, 26, 155, 191, 253, 180, 28, 50, 252, 30, 161])), SecretKey(Scalar([226, 221, 185, 31, 182, 98, 171, 48, 253, 94, 153, 162, 63, 165, 184, 155, 223, 158, 223, 249, 50, 156, 46, 99, 130, 247, 106, 110, 186, 102, 171, 2])));
/// VG: GDVG22YCBCEO4WTTZ5IBDPJ4N4ACCT46SEAQLNJJVFV2CKN3IJ776QUQ
static immutable VG = KeyPair(PublicKey(Point([234, 109, 107, 2, 8, 136, 238, 90, 115, 207, 80, 17, 189, 60, 111, 0, 33, 79, 158, 145, 1, 5, 181, 41, 169, 107, 161, 41, 187, 66, 127, 255])), SecretKey(Scalar([57, 215, 201, 148, 229, 77, 31, 71, 208, 23, 73, 30, 64, 157, 78, 75, 163, 138, 48, 224, 221, 221, 107, 57, 13, 57, 238, 12, 34, 34, 41, 6])));
/// VH: GDVH22YEOBCW65TVD34YOWAJRNH334OTSWIZOJKUHP3VVC5HWHWMB5QQ
static immutable VH = KeyPair(PublicKey(Point([234, 125, 107, 4, 112, 69, 111, 118, 117, 30, 249, 135, 88, 9, 139, 79, 189, 241, 211, 149, 145, 151, 37, 84, 59, 247, 90, 139, 167, 177, 236, 192])), SecretKey(Scalar([125, 132, 45, 180, 153, 236, 154, 143, 47, 175, 183, 50, 174, 174, 77, 153, 139, 105, 140, 240, 194, 51, 210, 126, 204, 226, 253, 55, 176, 210, 37, 6])));
/// VI: GDVI22NWEWOI7IFWLDF77BSZC5KYHMMBNPSVHQTL2IBRRCR5Z7G2ULWG
static immutable VI = KeyPair(PublicKey(Point([234, 141, 105, 182, 37, 156, 143, 160, 182, 88, 203, 255, 134, 89, 23, 85, 131, 177, 129, 107, 229, 83, 194, 107, 210, 3, 24, 138, 61, 207, 205, 170])), SecretKey(Scalar([134, 109, 177, 121, 225, 224, 46, 85, 29, 74, 48, 202, 157, 77, 212, 254, 115, 41, 213, 101, 129, 71, 64, 119, 38, 210, 118, 216, 230, 199, 14, 15])));
/// VJ: GDVJ22W5SI5TAHBIM33OFWWBGZQMPXX4KZWB4VA4JD745RINOTBCXXIH
static immutable VJ = KeyPair(PublicKey(Point([234, 157, 106, 221, 146, 59, 48, 28, 40, 102, 246, 226, 218, 193, 54, 96, 199, 222, 252, 86, 108, 30, 84, 28, 72, 255, 206, 197, 13, 116, 194, 43])), SecretKey(Scalar([247, 73, 130, 191, 182, 251, 151, 70, 190, 234, 240, 225, 39, 150, 97, 14, 14, 176, 150, 232, 124, 229, 208, 134, 165, 252, 112, 59, 225, 167, 199, 9])));
/// VK: GDVK22Y7YJLNQNGIRHN4TX53MWMJON44YAPZA4ARVB5L5YZ5H2UVV5GD
static immutable VK = KeyPair(PublicKey(Point([234, 173, 107, 31, 194, 86, 216, 52, 200, 137, 219, 201, 223, 187, 101, 152, 151, 55, 156, 192, 31, 144, 112, 17, 168, 122, 190, 227, 61, 62, 169, 90])), SecretKey(Scalar([225, 189, 40, 78, 224, 243, 26, 197, 129, 116, 2, 167, 1, 201, 249, 233, 237, 115, 163, 39, 45, 172, 127, 156, 234, 51, 95, 198, 211, 233, 59, 3])));
/// VL: GDVL22S6ROYKW3R2UTVLPK6BGQ4OK6G7QRQUP3D6RZ4R2ADL4YZFZSMG
static immutable VL = KeyPair(PublicKey(Point([234, 189, 106, 94, 139, 176, 171, 110, 58, 164, 234, 183, 171, 193, 52, 56, 229, 120, 223, 132, 97, 71, 236, 126, 142, 121, 29, 0, 107, 230, 50, 92])), SecretKey(Scalar([194, 87, 199, 175, 129, 6, 167, 68, 213, 155, 115, 113, 42, 69, 195, 160, 144, 66, 14, 24, 83, 71, 198, 20, 249, 18, 233, 249, 145, 75, 66, 8])));
/// VM: GDVM22IA55BKWQTIXANKOJ674O7S26B25ZQKKIHKK2G7DGLHY3SOXYME
static immutable VM = KeyPair(PublicKey(Point([234, 205, 105, 0, 239, 66, 171, 66, 104, 184, 26, 167, 39, 223, 227, 191, 45, 120, 58, 238, 96, 165, 32, 234, 86, 141, 241, 153, 103, 198, 228, 235])), SecretKey(Scalar([63, 222, 36, 29, 160, 230, 140, 211, 166, 5, 8, 90, 69, 207, 12, 208, 143, 217, 194, 48, 217, 229, 198, 17, 209, 132, 155, 63, 133, 153, 207, 12])));
/// VN: GDVN22ZOOZZXO63TGMCY3G3TJRP4ROQ6Z4TJWBHY5UEQYVXANHICXTAR
static immutable VN = KeyPair(PublicKey(Point([234, 221, 107, 46, 118, 115, 119, 123, 115, 51, 5, 141, 155, 115, 76, 95, 200, 186, 30, 207, 38, 155, 4, 248, 237, 9, 12, 86, 224, 105, 208, 43])), SecretKey(Scalar([180, 92, 160, 51, 30, 196, 47, 64, 255, 183, 6, 120, 19, 213, 242, 234, 251, 186, 137, 0, 135, 239, 18, 87, 116, 44, 153, 211, 189, 166, 152, 5])));
/// VO: GDVO22VZ4YYMKENETLNTDZN4N2HXOHNULNDPUMP5OYWBPCCB7OPJPL33
static immutable VO = KeyPair(PublicKey(Point([234, 237, 106, 185, 230, 48, 197, 17, 164, 154, 219, 49, 229, 188, 110, 143, 119, 29, 180, 91, 70, 250, 49, 253, 118, 44, 23, 136, 65, 251, 158, 151])), SecretKey(Scalar([117, 193, 179, 216, 196, 89, 47, 5, 191, 162, 224, 209, 5, 78, 2, 232, 32, 55, 64, 209, 48, 212, 219, 187, 77, 22, 169, 48, 64, 126, 213, 14])));
/// VP: GDVP22IWFDYBD5F24LRZ6HBV3HA3E4YRGGTY3XAPEN2O7X7IAH3NB6MW
static immutable VP = KeyPair(PublicKey(Point([234, 253, 105, 22, 40, 240, 17, 244, 186, 226, 227, 159, 28, 53, 217, 193, 178, 115, 17, 49, 167, 141, 220, 15, 35, 116, 239, 223, 232, 1, 246, 208])), SecretKey(Scalar([142, 24, 186, 97, 187, 120, 242, 178, 164, 187, 199, 172, 8, 122, 117, 3, 121, 230, 160, 112, 5, 51, 20, 0, 120, 78, 21, 198, 198, 150, 143, 8])));
/// VQ: GDVQ22MVY6MG27JVC5KKUGKZUPMKO2Z7BOT7FNJNTEUCB4GTQLYF3E2U
static immutable VQ = KeyPair(PublicKey(Point([235, 13, 105, 149, 199, 152, 109, 125, 53, 23, 84, 170, 25, 89, 163, 216, 167, 107, 63, 11, 167, 242, 181, 45, 153, 40, 32, 240, 211, 130, 240, 93])), SecretKey(Scalar([177, 80, 120, 0, 43, 53, 251, 104, 99, 242, 240, 196, 128, 64, 6, 220, 196, 92, 217, 213, 78, 172, 71, 155, 51, 48, 230, 70, 182, 111, 229, 0])));
/// VR: GDVR22Z62VHQUU7CVAAG2YZ2IX4LJ47SC6JN45A574CYAFNEV2SI75C6
static immutable VR = KeyPair(PublicKey(Point([235, 29, 107, 62, 213, 79, 10, 83, 226, 168, 0, 109, 99, 58, 69, 248, 180, 243, 242, 23, 146, 222, 116, 29, 255, 5, 128, 21, 164, 174, 164, 143])), SecretKey(Scalar([24, 246, 155, 36, 224, 209, 154, 28, 12, 126, 108, 23, 148, 29, 12, 208, 93, 86, 14, 17, 2, 113, 218, 91, 136, 45, 26, 134, 24, 48, 107, 7])));
/// VS: GDVS22PKB5XV6KDYXJACKGKOLNK7X5KWU4KZV4DCVJ5SJ3V76B67EFXY
static immutable VS = KeyPair(PublicKey(Point([235, 45, 105, 234, 15, 111, 95, 40, 120, 186, 64, 37, 25, 78, 91, 85, 251, 245, 86, 167, 21, 154, 240, 98, 170, 123, 36, 238, 191, 240, 125, 242])), SecretKey(Scalar([127, 48, 142, 102, 11, 25, 15, 145, 99, 243, 227, 15, 228, 62, 178, 171, 199, 157, 127, 127, 43, 60, 61, 245, 171, 208, 119, 123, 101, 254, 112, 12])));
/// VT: GDVT22YZYX32MFXWZRQPCLVVFWIAY72AN6UKEFHF5RILUS7LKW7HARYV
static immutable VT = KeyPair(PublicKey(Point([235, 61, 107, 25, 197, 247, 166, 22, 246, 204, 96, 241, 46, 181, 45, 144, 12, 127, 64, 111, 168, 162, 20, 229, 236, 80, 186, 75, 235, 85, 190, 112])), SecretKey(Scalar([153, 40, 17, 58, 178, 223, 173, 166, 203, 95, 76, 223, 239, 137, 214, 67, 115, 188, 197, 10, 13, 218, 227, 148, 33, 92, 246, 196, 14, 84, 57, 3])));
/// VU: GDVU22YML7B6OGEYQ35YXHK7C264H4TLOA46VCFTLAUBTJZJTEQ27Y5P
static immutable VU = KeyPair(PublicKey(Point([235, 77, 107, 12, 95, 195, 231, 24, 152, 134, 251, 139, 157, 95, 22, 189, 195, 242, 107, 112, 57, 234, 136, 179, 88, 40, 25, 167, 41, 153, 33, 175])), SecretKey(Scalar([234, 243, 233, 241, 192, 101, 20, 176, 120, 62, 149, 111, 11, 205, 169, 143, 44, 78, 77, 140, 77, 141, 185, 23, 224, 14, 75, 26, 61, 228, 199, 6])));
/// VV: GDVV226NTM2LX7C7SARL6CN3R6VHHS7UYW5NQFSJRHRCIPFL55J6JMLJ
static immutable VV = KeyPair(PublicKey(Point([235, 93, 107, 205, 155, 52, 187, 252, 95, 144, 34, 191, 9, 187, 143, 170, 115, 203, 244, 197, 186, 216, 22, 73, 137, 226, 36, 60, 171, 239, 83, 228])), SecretKey(Scalar([183, 231, 178, 213, 34, 220, 55, 84, 165, 49, 221, 25, 107, 161, 254, 81, 133, 159, 9, 51, 239, 58, 64, 134, 193, 109, 83, 126, 96, 192, 8, 15])));
/// VW: GDVW22WTWQHL4KBZMQOKD26U4UJLPTXGHHJNR2HXYPTATAA3GRJOJTM5
static immutable VW = KeyPair(PublicKey(Point([235, 109, 106, 211, 180, 14, 190, 40, 57, 100, 28, 161, 235, 212, 229, 18, 183, 206, 230, 57, 210, 216, 232, 247, 195, 230, 9, 128, 27, 52, 82, 228])), SecretKey(Scalar([118, 174, 13, 37, 78, 84, 105, 51, 60, 197, 90, 87, 47, 68, 149, 133, 39, 8, 0, 0, 251, 213, 232, 197, 180, 64, 134, 235, 204, 160, 205, 12])));
/// VX: GDVX222RWF6V5XDCDJ6BHLOVWOBTGOVLRA3JTG22Q5FAADZHL7AKAP3B
static immutable VX = KeyPair(PublicKey(Point([235, 125, 107, 81, 177, 125, 94, 220, 98, 26, 124, 19, 173, 213, 179, 131, 51, 58, 171, 136, 54, 153, 155, 90, 135, 74, 0, 15, 39, 95, 192, 160])), SecretKey(Scalar([144, 47, 125, 217, 113, 220, 12, 194, 38, 237, 255, 46, 134, 218, 150, 52, 193, 141, 154, 102, 137, 97, 227, 129, 179, 4, 198, 137, 135, 173, 110, 0])));
/// VY: GDVY22SBF7OM3MS2D6MFSUZSTJMB7SZMLYFJ43B4D2K7SQXVKPRC7HN3
static immutable VY = KeyPair(PublicKey(Point([235, 141, 106, 65, 47, 220, 205, 178, 90, 31, 152, 89, 83, 50, 154, 88, 31, 203, 44, 94, 10, 158, 108, 60, 30, 149, 249, 66, 245, 83, 226, 47])), SecretKey(Scalar([1, 157, 42, 87, 227, 46, 0, 75, 154, 63, 194, 205, 46, 137, 50, 162, 169, 159, 187, 53, 211, 90, 132, 122, 13, 108, 118, 117, 193, 126, 226, 8])));
/// VZ: GDVZ22KBL2XFXXLAXXAJWTRFWLPL3SL4JEK6Q4F5HL57GMGI6IUTVIAY
static immutable VZ = KeyPair(PublicKey(Point([235, 157, 105, 65, 94, 174, 91, 221, 96, 189, 192, 155, 78, 37, 178, 222, 189, 201, 124, 73, 21, 232, 112, 189, 58, 251, 243, 48, 200, 242, 41, 58])), SecretKey(Scalar([226, 136, 41, 55, 0, 134, 143, 197, 65, 166, 44, 193, 193, 124, 223, 143, 36, 2, 245, 85, 36, 168, 142, 106, 239, 99, 178, 187, 53, 253, 151, 7])));
/// WA: GDWA22CH6RPZTXF6LWEA7AMP55FRJJCMJUR7N2IF6JJ22W7KC6XSHBVX
static immutable WA = KeyPair(PublicKey(Point([236, 13, 104, 71, 244, 95, 153, 220, 190, 93, 136, 15, 129, 143, 239, 75, 20, 164, 76, 77, 35, 246, 233, 5, 242, 83, 173, 91, 234, 23, 175, 35])), SecretKey(Scalar([177, 99, 176, 54, 124, 242, 146, 162, 73, 102, 88, 31, 56, 175, 200, 0, 221, 202, 35, 235, 124, 120, 27, 71, 177, 8, 162, 0, 178, 141, 130, 3])));
/// WB: GDWB224TIJV3OTELYKZPCQKTUXY6TVUPTZPGYRJ25A7DUP47FQGDH6AR
static immutable WB = KeyPair(PublicKey(Point([236, 29, 107, 147, 66, 107, 183, 76, 139, 194, 178, 241, 65, 83, 165, 241, 233, 214, 143, 158, 94, 108, 69, 58, 232, 62, 58, 63, 159, 44, 12, 51])), SecretKey(Scalar([121, 120, 68, 254, 102, 2, 202, 234, 49, 97, 52, 151, 13, 40, 212, 43, 143, 214, 66, 254, 4, 222, 210, 97, 240, 240, 22, 230, 236, 147, 74, 2])));
/// WC: GDWC22GHZUKA45SVVCORVMJF5IQUDH6CI4JRMX4CSFLYMPL5X7UX2UCT
static immutable WC = KeyPair(PublicKey(Point([236, 45, 104, 199, 205, 20, 14, 118, 85, 168, 157, 26, 177, 37, 234, 33, 65, 159, 194, 71, 19, 22, 95, 130, 145, 87, 134, 61, 125, 191, 233, 125])), SecretKey(Scalar([236, 147, 16, 39, 218, 42, 10, 210, 79, 112, 136, 153, 246, 165, 198, 103, 5, 127, 191, 227, 175, 128, 255, 140, 80, 59, 30, 178, 67, 24, 160, 13])));
/// WD: GDWD22TFLAAMHMUYMB2IE6JPPBWLIHR7646Z2OXAF4OBWVHR4YPOFLI3
static immutable WD = KeyPair(PublicKey(Point([236, 61, 106, 101, 88, 0, 195, 178, 152, 96, 116, 130, 121, 47, 120, 108, 180, 30, 63, 247, 61, 157, 58, 224, 47, 28, 27, 84, 241, 230, 30, 226])), SecretKey(Scalar([187, 83, 9, 100, 143, 227, 144, 141, 177, 212, 69, 248, 56, 57, 22, 144, 107, 208, 59, 121, 151, 30, 155, 131, 243, 227, 218, 141, 90, 239, 164, 3])));
/// WE: GDWE22K6QMDGW363MLYMGO5M3JMNAE437AG7UMR6FHN6XJVYKHEZ6NGS
static immutable WE = KeyPair(PublicKey(Point([236, 77, 105, 94, 131, 6, 107, 111, 219, 98, 240, 195, 59, 172, 218, 88, 208, 19, 155, 248, 13, 250, 50, 62, 41, 219, 235, 166, 184, 81, 201, 159])), SecretKey(Scalar([161, 160, 220, 80, 21, 159, 50, 138, 15, 115, 13, 219, 195, 90, 253, 10, 219, 89, 251, 199, 255, 109, 8, 68, 159, 152, 35, 164, 198, 227, 212, 1])));
/// WF: GDWF223MMJWUZYZR5A5LFB6LZCRFNXEGHRRSW3234MZ64RTQKN34353B
static immutable WF = KeyPair(PublicKey(Point([236, 93, 107, 108, 98, 109, 76, 227, 49, 232, 58, 178, 135, 203, 200, 162, 86, 220, 134, 60, 99, 43, 111, 91, 227, 51, 238, 70, 112, 83, 119, 205])), SecretKey(Scalar([196, 252, 37, 135, 3, 101, 216, 222, 37, 154, 126, 51, 245, 243, 47, 117, 169, 235, 192, 198, 230, 8, 140, 62, 250, 225, 145, 19, 80, 179, 142, 2])));
/// WG: GDWG22F72SMRHIID2FTFX44MM74QBNN7V6TVO2IZUCNQNWCQKJUG7ZG7
static immutable WG = KeyPair(PublicKey(Point([236, 109, 104, 191, 212, 153, 19, 161, 3, 209, 102, 91, 243, 140, 103, 249, 0, 181, 191, 175, 167, 87, 105, 25, 160, 155, 6, 216, 80, 82, 104, 111])), SecretKey(Scalar([141, 111, 154, 81, 205, 82, 196, 101, 166, 90, 104, 64, 244, 239, 110, 246, 102, 9, 224, 184, 5, 150, 219, 80, 72, 251, 231, 62, 111, 226, 155, 5])));
/// WH: GDWH22WHRGRXNGM2VG77O26BBJWP4KXINQOYSGP5FSNF6OLQIQZTE2TY
static immutable WH = KeyPair(PublicKey(Point([236, 125, 106, 199, 137, 163, 118, 153, 154, 169, 191, 247, 107, 193, 10, 108, 254, 42, 232, 108, 29, 137, 25, 253, 44, 154, 95, 57, 112, 68, 51, 50])), SecretKey(Scalar([224, 142, 254, 16, 56, 12, 150, 9, 168, 116, 140, 27, 109, 191, 104, 7, 118, 164, 99, 96, 1, 25, 129, 141, 204, 215, 64, 108, 218, 220, 134, 4])));
/// WI: GDWI22DIW27DCZ6XVDHZ7VBSY72YLJ5I5EQ53NQFNBXYUQZ6HAK6RF2M
static immutable WI = KeyPair(PublicKey(Point([236, 141, 104, 104, 182, 190, 49, 103, 215, 168, 207, 159, 212, 50, 199, 245, 133, 167, 168, 233, 33, 221, 182, 5, 104, 111, 138, 67, 62, 56, 21, 232])), SecretKey(Scalar([217, 145, 242, 175, 14, 57, 236, 61, 178, 218, 255, 239, 40, 115, 52, 193, 232, 32, 30, 38, 204, 48, 206, 184, 37, 29, 188, 47, 86, 18, 192, 6])));
/// WJ: GDWJ22EYN6PWKPRLJGTKWZ2KEOZ5YXFLXTXPF7J3IIPP5ZL4M3ZBONVT
static immutable WJ = KeyPair(PublicKey(Point([236, 157, 104, 152, 111, 159, 101, 62, 43, 73, 166, 171, 103, 74, 35, 179, 220, 92, 171, 188, 238, 242, 253, 59, 66, 30, 254, 229, 124, 102, 242, 23])), SecretKey(Scalar([236, 146, 203, 209, 189, 204, 93, 50, 68, 247, 76, 50, 5, 223, 80, 230, 9, 34, 22, 33, 137, 152, 191, 106, 229, 17, 252, 41, 96, 19, 224, 10])));
/// WK: GDWK227DALTQTN5UGIUCNUZ5ANJ2ZOF3WRRTRB6ZXQCP6MZQGMSPUAGH
static immutable WK = KeyPair(PublicKey(Point([236, 173, 107, 227, 2, 231, 9, 183, 180, 50, 40, 38, 211, 61, 3, 83, 172, 184, 187, 180, 99, 56, 135, 217, 188, 4, 255, 51, 48, 51, 36, 250])), SecretKey(Scalar([146, 183, 254, 242, 122, 65, 191, 174, 6, 221, 30, 183, 168, 100, 232, 246, 237, 139, 41, 49, 225, 38, 15, 177, 57, 64, 51, 118, 141, 191, 71, 15])));
/// WL: GDWL22324V7T7VVI4TP7JYRI24XAUBFCNNFKJZJKHRTB576WYLDHTODC
static immutable WL = KeyPair(PublicKey(Point([236, 189, 107, 122, 229, 127, 63, 214, 168, 228, 223, 244, 226, 40, 215, 46, 10, 4, 162, 107, 74, 164, 229, 42, 60, 102, 30, 255, 214, 194, 198, 121])), SecretKey(Scalar([56, 40, 204, 224, 66, 74, 212, 152, 9, 218, 131, 153, 66, 155, 56, 196, 134, 47, 206, 35, 160, 175, 103, 178, 177, 162, 132, 40, 180, 34, 77, 1])));
/// WM: GDWM227HZX3EPAOUAUWOH74WFBYOZ3KZBIQHD46OJU5OUJRDKXCYQXHU
static immutable WM = KeyPair(PublicKey(Point([236, 205, 107, 231, 205, 246, 71, 129, 212, 5, 44, 227, 255, 150, 40, 112, 236, 237, 89, 10, 32, 113, 243, 206, 77, 58, 234, 38, 35, 85, 197, 136])), SecretKey(Scalar([241, 98, 127, 223, 152, 154, 16, 1, 192, 202, 191, 136, 37, 75, 161, 106, 221, 255, 163, 65, 56, 190, 137, 175, 200, 115, 180, 204, 57, 150, 188, 3])));
/// WN: GDWN226T6BKV4EU5VSGZ7CAPNI7BYJLGTL4CSA4DTVTCGWXPV6NZZGJA
static immutable WN = KeyPair(PublicKey(Point([236, 221, 107, 211, 240, 85, 94, 18, 157, 172, 141, 159, 136, 15, 106, 62, 28, 37, 102, 154, 248, 41, 3, 131, 157, 102, 35, 90, 239, 175, 155, 156])), SecretKey(Scalar([81, 247, 152, 49, 118, 179, 235, 138, 194, 25, 95, 50, 207, 235, 121, 180, 248, 206, 44, 92, 187, 248, 140, 146, 26, 182, 85, 53, 214, 198, 21, 6])));
/// WO: GDWO22ETR66BARH4UJ654NPXPI6GBMG4AFMZTH3VDIN2XVJWIXNE6KAX
static immutable WO = KeyPair(PublicKey(Point([236, 237, 104, 147, 143, 188, 16, 68, 252, 162, 125, 222, 53, 247, 122, 60, 96, 176, 220, 1, 89, 153, 159, 117, 26, 27, 171, 213, 54, 69, 218, 79])), SecretKey(Scalar([191, 47, 239, 46, 219, 166, 62, 130, 24, 58, 89, 206, 51, 87, 214, 117, 223, 75, 251, 112, 240, 194, 174, 170, 21, 90, 121, 50, 149, 162, 31, 3])));
/// WP: GDWP22J2FFU22OSI75PCFM3W43LIL4KMAXO73BBPEABF3TGZGCDQM5F5
static immutable WP = KeyPair(PublicKey(Point([236, 253, 105, 58, 41, 105, 173, 58, 72, 255, 94, 34, 179, 118, 230, 214, 133, 241, 76, 5, 221, 253, 132, 47, 32, 2, 93, 204, 217, 48, 135, 6])), SecretKey(Scalar([111, 205, 43, 80, 199, 6, 195, 165, 119, 68, 224, 52, 184, 137, 29, 106, 174, 16, 39, 114, 32, 60, 117, 151, 134, 177, 113, 254, 216, 113, 120, 11])));
/// WQ: GDWQ22AFRAWC23PGZTFS7ET6II63FDAHJZ7FNCC5KCT2CJUVV2G75YKU
static immutable WQ = KeyPair(PublicKey(Point([237, 13, 104, 5, 136, 44, 45, 109, 230, 204, 203, 47, 146, 126, 66, 61, 178, 140, 7, 78, 126, 86, 136, 93, 80, 167, 161, 38, 149, 174, 141, 254])), SecretKey(Scalar([153, 83, 139, 220, 38, 209, 162, 151, 199, 154, 165, 87, 49, 125, 28, 247, 75, 115, 218, 34, 220, 117, 36, 238, 233, 229, 121, 143, 193, 254, 231, 9])));
/// WR: GDWR22BBFYINHK2IPE2JBCLUS6YSSZMA435EQQOACQMS7QDORHXVTA73
static immutable WR = KeyPair(PublicKey(Point([237, 29, 104, 33, 46, 16, 211, 171, 72, 121, 52, 144, 137, 116, 151, 177, 41, 101, 128, 230, 250, 72, 65, 192, 20, 25, 47, 192, 110, 137, 239, 89])), SecretKey(Scalar([111, 68, 10, 160, 175, 96, 145, 94, 248, 70, 170, 144, 40, 192, 160, 4, 107, 15, 110, 103, 253, 148, 248, 101, 252, 58, 199, 55, 123, 38, 178, 8])));
/// WS: GDWS22HGAE5CENNADQYC3QTDV3ZKWCBLL4JFSZDKO4OBP7M4IIU5CZRK
static immutable WS = KeyPair(PublicKey(Point([237, 45, 104, 230, 1, 58, 34, 53, 160, 28, 48, 45, 194, 99, 174, 242, 171, 8, 43, 95, 18, 89, 100, 106, 119, 28, 23, 253, 156, 66, 41, 209])), SecretKey(Scalar([68, 99, 135, 89, 33, 0, 73, 181, 100, 154, 192, 2, 11, 187, 107, 104, 233, 125, 74, 125, 87, 215, 207, 118, 113, 114, 212, 88, 79, 113, 228, 11])));
/// WT: GDWT22TQC26RDXM362CQAPQ4G3JAVSGDH5KKMXBVRGVSVLOPI2LCWKBB
static immutable WT = KeyPair(PublicKey(Point([237, 61, 106, 112, 22, 189, 17, 221, 155, 246, 133, 0, 62, 28, 54, 210, 10, 200, 195, 63, 84, 166, 92, 53, 137, 171, 42, 173, 207, 70, 150, 43])), SecretKey(Scalar([33, 199, 214, 61, 149, 169, 129, 201, 143, 65, 49, 151, 133, 187, 44, 204, 178, 69, 61, 253, 146, 139, 134, 197, 2, 122, 152, 37, 76, 125, 95, 12])));
/// WU: GDWU22G3TPDLAYL2QVGYT3TF3KRMPHWRGGY3XUCB3GCJHMB2HPOOR4Z3
static immutable WU = KeyPair(PublicKey(Point([237, 77, 104, 219, 155, 198, 176, 97, 122, 133, 77, 137, 238, 101, 218, 162, 199, 158, 209, 49, 177, 187, 208, 65, 217, 132, 147, 176, 58, 59, 220, 232])), SecretKey(Scalar([199, 110, 20, 187, 158, 96, 242, 251, 148, 205, 15, 51, 62, 246, 207, 232, 121, 105, 144, 148, 107, 73, 24, 152, 4, 76, 83, 200, 46, 51, 216, 5])));
/// WV: GDWV227IZK47V5FOGQ3ZPVSZEACWX72GXND5OB75EEW7GFMJ3UYZROFG
static immutable WV = KeyPair(PublicKey(Point([237, 93, 107, 232, 202, 185, 250, 244, 174, 52, 55, 151, 214, 89, 32, 5, 107, 255, 70, 187, 71, 215, 7, 253, 33, 45, 243, 21, 137, 221, 49, 152])), SecretKey(Scalar([18, 177, 1, 147, 236, 228, 190, 246, 128, 228, 201, 241, 194, 77, 171, 194, 202, 193, 86, 217, 24, 16, 239, 143, 99, 183, 250, 17, 37, 49, 138, 11])));
/// WW: GDWW22E5OE7YFRMBW7QUDLOCD3D5NEXSJ3CEMYYVFOCKBYKK2QDHSR7W
static immutable WW = KeyPair(PublicKey(Point([237, 109, 104, 157, 113, 63, 130, 197, 129, 183, 225, 65, 173, 194, 30, 199, 214, 146, 242, 78, 196, 70, 99, 21, 43, 132, 160, 225, 74, 212, 6, 121])), SecretKey(Scalar([51, 183, 86, 243, 121, 172, 57, 82, 17, 117, 138, 238, 195, 114, 119, 74, 152, 91, 176, 167, 220, 63, 25, 70, 8, 87, 96, 6, 197, 48, 233, 14])));
/// WX: GDWX22QELCANOVC34M5RZ5EK4YNVRNQX6B6D55F44QYSZS7O5ODF2TJ4
static immutable WX = KeyPair(PublicKey(Point([237, 125, 106, 4, 88, 128, 215, 84, 91, 227, 59, 28, 244, 138, 230, 27, 88, 182, 23, 240, 124, 62, 244, 188, 228, 49, 44, 203, 238, 235, 134, 93])), SecretKey(Scalar([55, 214, 178, 223, 49, 179, 220, 194, 54, 231, 2, 32, 89, 2, 8, 213, 100, 4, 155, 102, 188, 217, 211, 141, 167, 205, 144, 71, 142, 0, 190, 7])));
/// WY: GDWY223SF6CUZOL63NHLB4QFBY3XECSL3TZHSLM22HLSFBTEIYLN4GZN
static immutable WY = KeyPair(PublicKey(Point([237, 141, 107, 114, 47, 133, 76, 185, 126, 219, 78, 176, 242, 5, 14, 55, 114, 10, 75, 220, 242, 121, 45, 154, 209, 215, 34, 134, 100, 70, 22, 222])), SecretKey(Scalar([52, 67, 128, 91, 13, 192, 101, 8, 194, 194, 139, 159, 112, 114, 133, 199, 28, 241, 31, 124, 31, 233, 152, 157, 28, 126, 11, 25, 52, 86, 165, 1])));
/// WZ: GDWZ22HJ6Q4BX3QU4IYXRUFQ63LTYIAOSPUJQDOV2S3F33P2ETN66MCI
static immutable WZ = KeyPair(PublicKey(Point([237, 157, 104, 233, 244, 56, 27, 238, 20, 226, 49, 120, 208, 176, 246, 215, 60, 32, 14, 147, 232, 152, 13, 213, 212, 182, 93, 237, 250, 36, 219, 239])), SecretKey(Scalar([253, 30, 197, 214, 171, 130, 199, 251, 86, 33, 141, 17, 184, 247, 18, 47, 86, 62, 156, 179, 251, 182, 206, 93, 64, 69, 51, 136, 118, 194, 236, 8])));
/// XA: GDXA2273SMBAZEZZXCBXWHS3QQV36RSPWKHNZFWMVPWLRQF7HLOXMEWF
static immutable XA = KeyPair(PublicKey(Point([238, 13, 107, 251, 147, 2, 12, 147, 57, 184, 131, 123, 30, 91, 132, 43, 191, 70, 79, 178, 142, 220, 150, 204, 171, 236, 184, 192, 191, 58, 221, 118])), SecretKey(Scalar([196, 79, 86, 252, 1, 146, 130, 246, 176, 205, 145, 43, 144, 237, 159, 226, 232, 39, 24, 234, 116, 221, 130, 255, 126, 219, 192, 216, 147, 27, 33, 14])));
/// XB: GDXB22MC5TYSUMYXDNGCY76XXWVJVKP73QVKUMAYOHFYHE5GKL5W7ABM
static immutable XB = KeyPair(PublicKey(Point([238, 29, 105, 130, 236, 241, 42, 51, 23, 27, 76, 44, 127, 215, 189, 170, 154, 169, 255, 220, 42, 170, 48, 24, 113, 203, 131, 147, 166, 82, 251, 111])), SecretKey(Scalar([198, 123, 13, 45, 58, 2, 142, 8, 32, 251, 177, 225, 250, 128, 78, 15, 195, 103, 180, 186, 71, 0, 88, 110, 68, 103, 124, 15, 48, 132, 118, 3])));
/// XC: GDXC22UHZ42MTGRMXUVMONGRYZ32C7V7LCB42GQQGRNTA6EVZEZTK3II
static immutable XC = KeyPair(PublicKey(Point([238, 45, 106, 135, 207, 52, 201, 154, 44, 189, 42, 199, 52, 209, 198, 119, 161, 126, 191, 88, 131, 205, 26, 16, 52, 91, 48, 120, 149, 201, 51, 53])), SecretKey(Scalar([132, 153, 21, 45, 125, 79, 173, 126, 219, 48, 58, 229, 14, 211, 229, 181, 82, 131, 154, 1, 254, 64, 192, 194, 0, 17, 191, 183, 132, 154, 118, 5])));
/// XD: GDXD22VZHA3LFUJQZQYVT4ZWI3RQIHSOIOIZKFFW7UUC7WMX5VE4GS3Z
static immutable XD = KeyPair(PublicKey(Point([238, 61, 106, 185, 56, 54, 178, 209, 48, 204, 49, 89, 243, 54, 70, 227, 4, 30, 78, 67, 145, 149, 20, 182, 253, 40, 47, 217, 151, 237, 73, 195])), SecretKey(Scalar([123, 127, 13, 105, 4, 122, 81, 175, 137, 59, 38, 203, 27, 192, 140, 197, 61, 137, 239, 149, 129, 8, 128, 218, 240, 37, 53, 80, 158, 254, 47, 11])));
/// XE: GDXE22TAPUWKKQISG7S5TYRP4KDYMQOQJRKFOAKBGCB4QXYBCVRDXA3S
static immutable XE = KeyPair(PublicKey(Point([238, 77, 106, 96, 125, 44, 165, 65, 18, 55, 229, 217, 226, 47, 226, 135, 134, 65, 208, 76, 84, 87, 1, 65, 48, 131, 200, 95, 1, 21, 98, 59])), SecretKey(Scalar([245, 185, 40, 231, 243, 69, 122, 37, 214, 135, 14, 48, 226, 178, 104, 248, 112, 1, 163, 223, 2, 96, 49, 248, 60, 137, 69, 162, 123, 112, 236, 8])));
/// XF: GDXF22TD2YIIAPWJEVYUI4BBP6QKNNCFURDGBLPNE4WNJQMO4SMJGHRD
static immutable XF = KeyPair(PublicKey(Point([238, 93, 106, 99, 214, 16, 128, 62, 201, 37, 113, 68, 112, 33, 127, 160, 166, 180, 69, 164, 70, 96, 173, 237, 39, 44, 212, 193, 142, 228, 152, 147])), SecretKey(Scalar([179, 85, 228, 134, 148, 8, 228, 61, 251, 200, 220, 37, 72, 102, 229, 241, 197, 185, 6, 220, 169, 183, 119, 73, 3, 49, 182, 85, 188, 23, 38, 10])));
/// XG: GDXG22XJTPNCH7KI5JLMLXPWKTDOPK66CN2GEJ4PDW7JJULB66266LT4
static immutable XG = KeyPair(PublicKey(Point([238, 109, 106, 233, 155, 218, 35, 253, 72, 234, 86, 197, 221, 246, 84, 198, 231, 171, 222, 19, 116, 98, 39, 143, 29, 190, 148, 209, 97, 247, 181, 239])), SecretKey(Scalar([45, 21, 181, 30, 111, 12, 244, 129, 17, 13, 16, 121, 110, 50, 232, 133, 16, 89, 168, 31, 16, 78, 225, 106, 121, 144, 96, 248, 184, 60, 208, 2])));
/// XH: GDXH22NNL4JIUACHQLC3BBWUKN64VL4BJUDCBXXLKGEE2PPMOBRTYHJG
static immutable XH = KeyPair(PublicKey(Point([238, 125, 105, 173, 95, 18, 138, 0, 71, 130, 197, 176, 134, 212, 83, 125, 202, 175, 129, 77, 6, 32, 222, 235, 81, 136, 77, 61, 236, 112, 99, 60])), SecretKey(Scalar([34, 228, 130, 180, 6, 246, 73, 157, 99, 215, 180, 98, 181, 65, 186, 68, 25, 38, 35, 20, 51, 40, 87, 151, 83, 44, 153, 219, 235, 113, 59, 9])));
/// XI: GDXI22U2YCN64HECCCEJZOY4WRUYBPK3OEJCG5QWIOENVVLRHR6SDIDG
static immutable XI = KeyPair(PublicKey(Point([238, 141, 106, 154, 192, 155, 238, 28, 130, 16, 136, 156, 187, 28, 180, 105, 128, 189, 91, 113, 18, 35, 118, 22, 67, 136, 218, 213, 113, 60, 125, 33])), SecretKey(Scalar([15, 29, 0, 122, 69, 166, 106, 241, 51, 11, 68, 134, 131, 126, 202, 26, 196, 14, 190, 250, 236, 131, 35, 123, 87, 171, 117, 73, 33, 202, 12, 3])));
/// XJ: GDXJ22SXXAIM5UWNXQYMNYDZEXMVV4GM66EUSSEKIZNARYAVQZVWKVUQ
static immutable XJ = KeyPair(PublicKey(Point([238, 157, 106, 87, 184, 16, 206, 210, 205, 188, 48, 198, 224, 121, 37, 217, 90, 240, 204, 247, 137, 73, 72, 138, 70, 90, 8, 224, 21, 134, 107, 101])), SecretKey(Scalar([130, 122, 165, 25, 228, 198, 196, 110, 148, 150, 217, 107, 170, 29, 120, 205, 53, 228, 253, 133, 254, 6, 7, 50, 246, 120, 119, 108, 146, 79, 106, 12])));
/// XK: GDXK22BGNKPYHPLLE5CQDFUY5ELOFT5OAXH7HBQ7ZWBNMNIS4MJANR4P
static immutable XK = KeyPair(PublicKey(Point([238, 173, 104, 38, 106, 159, 131, 189, 107, 39, 69, 1, 150, 152, 233, 22, 226, 207, 174, 5, 207, 243, 134, 31, 205, 130, 214, 53, 18, 227, 18, 6])), SecretKey(Scalar([49, 169, 24, 112, 66, 102, 249, 208, 255, 55, 115, 58, 209, 56, 94, 229, 146, 177, 114, 139, 122, 89, 192, 210, 10, 89, 193, 229, 207, 26, 12, 8])));
/// XL: GDXL22DTDSK7JLTS6HYJBPNKCMYWOLGBHN7S76DJRE6DEFXB6L2EZ2XH
static immutable XL = KeyPair(PublicKey(Point([238, 189, 104, 115, 28, 149, 244, 174, 114, 241, 240, 144, 189, 170, 19, 49, 103, 44, 193, 59, 127, 47, 248, 105, 137, 60, 50, 22, 225, 242, 244, 76])), SecretKey(Scalar([6, 64, 209, 148, 8, 107, 172, 31, 104, 97, 63, 140, 251, 71, 15, 51, 196, 131, 122, 106, 225, 108, 243, 198, 21, 156, 242, 202, 47, 148, 88, 6])));
/// XM: GDXM22PJZVA5EDF3SIPN74EXSBOOFBQ3EHEKLQZJDBKZPGOJKOAHOP4M
static immutable XM = KeyPair(PublicKey(Point([238, 205, 105, 233, 205, 65, 210, 12, 187, 146, 30, 223, 240, 151, 144, 92, 226, 134, 27, 33, 200, 165, 195, 41, 24, 85, 151, 153, 201, 83, 128, 119])), SecretKey(Scalar([76, 64, 4, 234, 238, 67, 237, 129, 40, 17, 167, 21, 31, 213, 50, 192, 188, 11, 211, 87, 147, 155, 78, 181, 117, 44, 142, 105, 218, 190, 105, 0])));
/// XN: GDXN22TQMYZKBLZB3QRN4IP7FNCAQ532MJZOOQARS43KBITWYS7TZTYK
static immutable XN = KeyPair(PublicKey(Point([238, 221, 106, 112, 102, 50, 160, 175, 33, 220, 34, 222, 33, 255, 43, 68, 8, 119, 122, 98, 114, 231, 64, 17, 151, 54, 160, 162, 118, 196, 191, 60])), SecretKey(Scalar([111, 6, 98, 247, 222, 63, 175, 56, 253, 36, 203, 246, 97, 134, 145, 219, 247, 0, 252, 59, 15, 96, 6, 21, 227, 140, 223, 255, 187, 135, 221, 5])));
/// XO: GDXO22HKFAB7CPZ56ZFIE2NOPJWQ3VSHZAZYAFJRQRO57M55LDITYGFY
static immutable XO = KeyPair(PublicKey(Point([238, 237, 104, 234, 40, 3, 241, 63, 61, 246, 74, 130, 105, 174, 122, 109, 13, 214, 71, 200, 51, 128, 21, 49, 132, 93, 223, 179, 189, 88, 209, 60])), SecretKey(Scalar([101, 252, 72, 249, 130, 107, 53, 57, 146, 254, 138, 30, 119, 65, 54, 10, 118, 235, 58, 202, 127, 194, 32, 77, 120, 81, 126, 248, 200, 220, 39, 1])));
/// XP: GDXP22VWAWIAMBJ2ZSXID5T6A5TLDBAZNW2D4AEGKPAHC2JN6S3RJHFH
static immutable XP = KeyPair(PublicKey(Point([238, 253, 106, 182, 5, 144, 6, 5, 58, 204, 174, 129, 246, 126, 7, 102, 177, 132, 25, 109, 180, 62, 0, 134, 83, 192, 113, 105, 45, 244, 183, 20])), SecretKey(Scalar([115, 117, 117, 188, 38, 220, 180, 2, 125, 1, 70, 112, 254, 132, 99, 160, 85, 91, 118, 122, 189, 2, 104, 154, 61, 8, 121, 99, 132, 151, 4, 13])));
/// XQ: GDXQ22SPNE24SZ77AXFZCT2TK2LRSUQD3DLCAGTYB4QTSIFPVVYCGOZC
static immutable XQ = KeyPair(PublicKey(Point([239, 13, 106, 79, 105, 53, 201, 103, 255, 5, 203, 145, 79, 83, 86, 151, 25, 82, 3, 216, 214, 32, 26, 120, 15, 33, 57, 32, 175, 173, 112, 35])), SecretKey(Scalar([248, 31, 247, 180, 230, 166, 118, 232, 149, 71, 117, 69, 79, 82, 240, 236, 134, 249, 107, 60, 221, 243, 182, 175, 46, 243, 39, 235, 66, 13, 230, 3])));
/// XR: GDXR22NYNGXE7WBTTXRIULS2BDHQN6WXEQLHNK4KZXD7K33W45FORGPI
static immutable XR = KeyPair(PublicKey(Point([239, 29, 105, 184, 105, 174, 79, 216, 51, 157, 226, 138, 46, 90, 8, 207, 6, 250, 215, 36, 22, 118, 171, 138, 205, 199, 245, 111, 118, 231, 74, 232])), SecretKey(Scalar([78, 92, 19, 166, 234, 143, 188, 109, 171, 20, 164, 234, 162, 208, 78, 26, 7, 151, 95, 6, 169, 66, 73, 62, 229, 28, 132, 81, 132, 251, 183, 8])));
/// XS: GDXS22H6TEGPDKL2IJMBRFYQ5ESI6QT7YB4WJ4HGER5NC3SGOXVVIH5A
static immutable XS = KeyPair(PublicKey(Point([239, 45, 104, 254, 153, 12, 241, 169, 122, 66, 88, 24, 151, 16, 233, 36, 143, 66, 127, 192, 121, 100, 240, 230, 36, 122, 209, 110, 70, 117, 235, 84])), SecretKey(Scalar([87, 56, 236, 42, 129, 7, 253, 233, 19, 175, 141, 198, 16, 4, 61, 170, 87, 141, 242, 149, 250, 250, 202, 246, 143, 37, 220, 151, 3, 95, 136, 7])));
/// XT: GDXT22OQGOMEB4T3EDCVDHQQHO6PS3WP6YXUTBUXUX23EXGXVSOBJETD
static immutable XT = KeyPair(PublicKey(Point([239, 61, 105, 208, 51, 152, 64, 242, 123, 32, 197, 81, 158, 16, 59, 188, 249, 110, 207, 246, 47, 73, 134, 151, 165, 245, 178, 92, 215, 172, 156, 20])), SecretKey(Scalar([214, 108, 228, 202, 239, 215, 254, 235, 144, 56, 136, 2, 109, 75, 114, 210, 107, 234, 240, 187, 221, 233, 26, 3, 242, 119, 57, 69, 146, 56, 63, 3])));
/// XU: GDXU225FIGINH7ZTBN3DCPOIIBDV5UBHCFAMXJZPUKDHBQMKEOCTJUE7
static immutable XU = KeyPair(PublicKey(Point([239, 77, 107, 165, 65, 144, 211, 255, 51, 11, 118, 49, 61, 200, 64, 71, 94, 208, 39, 17, 64, 203, 167, 47, 162, 134, 112, 193, 138, 35, 133, 52])), SecretKey(Scalar([205, 200, 54, 140, 188, 3, 175, 100, 17, 127, 33, 101, 62, 227, 219, 10, 95, 246, 180, 8, 200, 205, 132, 2, 101, 182, 87, 95, 50, 156, 88, 6])));
/// XV: GDXV22YYSAB3M2GT4VSDWNI3GETMBNIKYYPLCLUGD4LJFF7N3K52LSFW
static immutable XV = KeyPair(PublicKey(Point([239, 93, 107, 24, 144, 3, 182, 104, 211, 229, 100, 59, 53, 27, 49, 38, 192, 181, 10, 198, 30, 177, 46, 134, 31, 22, 146, 151, 237, 218, 187, 165])), SecretKey(Scalar([12, 122, 141, 73, 152, 219, 6, 135, 162, 248, 160, 221, 34, 22, 103, 125, 221, 175, 29, 120, 254, 121, 174, 169, 83, 217, 194, 6, 45, 45, 10, 5])));
/// XW: GDXW22UDWRF4XBNPWYG22DMZCAPORCTNS2AFSURZAIJTRTSOM2IYUXPP
static immutable XW = KeyPair(PublicKey(Point([239, 109, 106, 131, 180, 75, 203, 133, 175, 182, 13, 173, 13, 153, 16, 30, 232, 138, 109, 150, 128, 89, 82, 57, 2, 19, 56, 206, 78, 102, 145, 138])), SecretKey(Scalar([23, 214, 225, 77, 78, 42, 62, 108, 179, 239, 219, 59, 116, 105, 139, 20, 233, 43, 27, 192, 139, 233, 66, 207, 92, 234, 214, 218, 154, 186, 56, 13])));
/// XX: GDXX22ZWPWEBKUIM6YREEQ6GSN4H3QGHHKE6BZ4JTZBEI4GC4OTIO6TP
static immutable XX = KeyPair(PublicKey(Point([239, 125, 107, 54, 125, 136, 21, 81, 12, 246, 34, 66, 67, 198, 147, 120, 125, 192, 199, 58, 137, 224, 231, 137, 158, 66, 68, 112, 194, 227, 166, 135])), SecretKey(Scalar([153, 159, 158, 140, 11, 55, 132, 98, 133, 66, 39, 60, 195, 193, 91, 205, 158, 147, 2, 36, 39, 237, 207, 219, 46, 148, 56, 124, 103, 93, 30, 14])));
/// XY: GDXY22WIF57FHO6EXNK2ZR2OQ7AV7QCNQ37UPGF6VAN35ENBFWJ7O454
static immutable XY = KeyPair(PublicKey(Point([239, 141, 106, 200, 47, 126, 83, 187, 196, 187, 85, 172, 199, 78, 135, 193, 95, 192, 77, 134, 255, 71, 152, 190, 168, 27, 190, 145, 161, 45, 147, 247])), SecretKey(Scalar([239, 10, 12, 51, 85, 54, 224, 1, 226, 145, 35, 120, 177, 155, 6, 124, 241, 32, 74, 83, 59, 155, 54, 184, 12, 223, 88, 134, 239, 109, 204, 8])));
/// XZ: GDXZ227UVYUFZXAQORRFGLKWT73RDS66ZGF7EEKJXMJDISH57LE2IHLC
static immutable XZ = KeyPair(PublicKey(Point([239, 157, 107, 244, 174, 40, 92, 220, 16, 116, 98, 83, 45, 86, 159, 247, 17, 203, 222, 201, 139, 242, 17, 73, 187, 18, 52, 72, 253, 250, 201, 164])), SecretKey(Scalar([136, 9, 60, 170, 210, 17, 24, 205, 24, 95, 204, 61, 187, 154, 64, 236, 165, 103, 237, 244, 22, 24, 118, 23, 224, 204, 37, 190, 232, 231, 181, 12])));
/// YA: GDYA22FJ4PWT34S7L3BROQ4IPUXF6CYWRASXQQSD3VJ2HK4RQOGVWFBF
static immutable YA = KeyPair(PublicKey(Point([240, 13, 104, 169, 227, 237, 61, 242, 95, 94, 195, 23, 67, 136, 125, 46, 95, 11, 22, 136, 37, 120, 66, 67, 221, 83, 163, 171, 145, 131, 141, 91])), SecretKey(Scalar([206, 54, 208, 125, 216, 233, 42, 221, 224, 2, 67, 77, 233, 213, 220, 214, 66, 134, 104, 120, 21, 108, 194, 203, 60, 199, 228, 156, 206, 141, 46, 4])));
/// YB: GDYB22POMCK5EC6LGKLTT3WD66CPUHTEIRXWAC4YJI7AYLKAXMGOJBR7
static immutable YB = KeyPair(PublicKey(Point([240, 29, 105, 238, 96, 149, 210, 11, 203, 50, 151, 57, 238, 195, 247, 132, 250, 30, 100, 68, 111, 96, 11, 152, 74, 62, 12, 45, 64, 187, 12, 228])), SecretKey(Scalar([229, 17, 239, 198, 149, 147, 100, 72, 225, 102, 43, 212, 3, 149, 100, 197, 42, 246, 35, 47, 236, 247, 57, 76, 230, 213, 11, 150, 148, 236, 87, 0])));
/// YC: GDYC22UITIQ5WCPL7VHU5OGKASIYY5T5EO6J5PPKJTBC4LYMO64AHSFU
static immutable YC = KeyPair(PublicKey(Point([240, 45, 106, 136, 154, 33, 219, 9, 235, 253, 79, 78, 184, 202, 4, 145, 140, 118, 125, 35, 188, 158, 189, 234, 76, 194, 46, 47, 12, 119, 184, 3])), SecretKey(Scalar([199, 15, 178, 94, 9, 124, 255, 175, 15, 85, 118, 199, 111, 251, 118, 241, 196, 144, 164, 137, 108, 53, 104, 96, 61, 53, 208, 242, 170, 163, 18, 10])));
/// YD: GDYD22OASFOKGY3NFEYAWZ5FCFAA73FFVVGWQVPOVLSHYKEEXPZFEXSO
static immutable YD = KeyPair(PublicKey(Point([240, 61, 105, 192, 145, 92, 163, 99, 109, 41, 48, 11, 103, 165, 17, 64, 15, 236, 165, 173, 77, 104, 85, 238, 170, 228, 124, 40, 132, 187, 242, 82])), SecretKey(Scalar([17, 128, 9, 123, 180, 183, 93, 73, 154, 11, 162, 11, 102, 244, 138, 120, 24, 186, 178, 179, 65, 108, 10, 148, 88, 142, 208, 177, 189, 15, 70, 2])));
/// YE: GDYE22E6TPSNYJLLABOS3TBDSALX6ZE5MIOZ43NHG5L4XLHF3HZZQGVK
static immutable YE = KeyPair(PublicKey(Point([240, 77, 104, 158, 155, 228, 220, 37, 107, 0, 93, 45, 204, 35, 144, 23, 127, 100, 157, 98, 29, 158, 109, 167, 55, 87, 203, 172, 229, 217, 243, 152])), SecretKey(Scalar([254, 161, 135, 99, 165, 163, 20, 67, 240, 101, 133, 48, 86, 102, 112, 126, 81, 222, 73, 8, 67, 147, 164, 54, 57, 72, 221, 136, 40, 107, 86, 7])));
/// YF: GDYF22JUQJTUZXLXF3L4WIBUZWWE4YJWL555JMUZY2XMTCA5D5ZCZB35
static immutable YF = KeyPair(PublicKey(Point([240, 93, 105, 52, 130, 103, 76, 221, 119, 46, 215, 203, 32, 52, 205, 172, 78, 97, 54, 95, 123, 212, 178, 153, 198, 174, 201, 136, 29, 31, 114, 44])), SecretKey(Scalar([9, 159, 134, 215, 12, 71, 197, 172, 221, 112, 231, 66, 211, 63, 48, 16, 140, 192, 189, 159, 73, 142, 210, 86, 108, 162, 49, 217, 237, 58, 199, 14])));
/// YG: GDYG22X3KYRSG3PWU7G5GEX2NNZ3PI27TSSCIQEOEECA6WLKF7CGIJUU
static immutable YG = KeyPair(PublicKey(Point([240, 109, 106, 251, 86, 35, 35, 109, 246, 167, 205, 211, 18, 250, 107, 115, 183, 163, 95, 156, 164, 36, 64, 142, 33, 4, 15, 89, 106, 47, 196, 100])), SecretKey(Scalar([42, 201, 40, 110, 96, 118, 250, 20, 187, 213, 191, 44, 38, 41, 69, 95, 11, 124, 221, 91, 128, 156, 163, 70, 4, 12, 127, 20, 76, 118, 176, 9])));
/// YH: GDYH22M2ZREX42OWKX7FNH4XMN7SJPVTQIPHYSYYWSGMR56WUUFHU4HR
static immutable YH = KeyPair(PublicKey(Point([240, 125, 105, 154, 204, 73, 126, 105, 214, 85, 254, 86, 159, 151, 99, 127, 36, 190, 179, 130, 30, 124, 75, 24, 180, 140, 200, 247, 214, 165, 10, 122])), SecretKey(Scalar([73, 161, 194, 31, 166, 53, 88, 42, 203, 246, 188, 215, 154, 54, 6, 129, 216, 153, 22, 206, 63, 50, 246, 124, 125, 220, 15, 67, 93, 67, 114, 7])));
/// YI: GDYI22JOZPFFDGKRSCEK2P3DUB2ZEUC6VL55QHNBWTECIRPENXFHSYUV
static immutable YI = KeyPair(PublicKey(Point([240, 141, 105, 46, 203, 202, 81, 153, 81, 144, 136, 173, 63, 99, 160, 117, 146, 80, 94, 170, 251, 216, 29, 161, 180, 200, 36, 69, 228, 109, 202, 121])), SecretKey(Scalar([61, 4, 247, 25, 70, 146, 191, 149, 198, 77, 196, 190, 246, 218, 70, 73, 160, 19, 82, 229, 19, 110, 203, 246, 30, 81, 196, 129, 247, 75, 86, 9])));
/// YJ: GDYJ22DA3X5VIXPIZQ7JIW2CGSADY7R3O42JUQHNC5BB2KXQOGSCTTKJ
static immutable YJ = KeyPair(PublicKey(Point([240, 157, 104, 96, 221, 251, 84, 93, 232, 204, 62, 148, 91, 66, 52, 128, 60, 126, 59, 119, 52, 154, 64, 237, 23, 66, 29, 42, 240, 113, 164, 41])), SecretKey(Scalar([39, 168, 177, 21, 52, 6, 196, 74, 202, 193, 96, 182, 99, 120, 180, 190, 158, 86, 217, 191, 70, 212, 102, 144, 60, 249, 29, 147, 152, 0, 179, 0])));
/// YK: GDYK22HAQGXO4A5I5XWVZV7ML4FNSVN3EB6BGUJKLMM3AMLM53JROT7C
static immutable YK = KeyPair(PublicKey(Point([240, 173, 104, 224, 129, 174, 238, 3, 168, 237, 237, 92, 215, 236, 95, 10, 217, 85, 187, 32, 124, 19, 81, 42, 91, 25, 176, 49, 108, 238, 211, 23])), SecretKey(Scalar([88, 67, 188, 114, 79, 61, 32, 68, 32, 11, 196, 18, 203, 146, 104, 127, 157, 240, 3, 196, 241, 213, 238, 37, 103, 157, 217, 204, 223, 91, 176, 2])));
/// YL: GDYL22TBMXYWH5BXRVVNJ6SF26A5LQ2PTPREJPMVLTPGRBZKEJIX75HP
static immutable YL = KeyPair(PublicKey(Point([240, 189, 106, 97, 101, 241, 99, 244, 55, 141, 106, 212, 250, 69, 215, 129, 213, 195, 79, 155, 226, 68, 189, 149, 92, 222, 104, 135, 42, 34, 81, 127])), SecretKey(Scalar([152, 212, 112, 137, 114, 217, 203, 115, 83, 97, 134, 88, 177, 233, 229, 187, 44, 122, 203, 168, 96, 82, 72, 160, 174, 71, 76, 220, 183, 125, 146, 14])));
/// YM: GDYM22RJTUNMDOIZLNEDQQC5EPPQRGXNCH26J5FHXJUWIBLEM7T5PD4J
static immutable YM = KeyPair(PublicKey(Point([240, 205, 106, 41, 157, 26, 193, 185, 25, 91, 72, 56, 64, 93, 35, 223, 8, 154, 237, 17, 245, 228, 244, 167, 186, 105, 100, 5, 100, 103, 231, 215])), SecretKey(Scalar([216, 94, 49, 64, 158, 47, 55, 16, 54, 45, 9, 163, 230, 211, 213, 98, 162, 193, 219, 77, 241, 18, 74, 240, 197, 125, 43, 245, 77, 170, 82, 8])));
/// YN: GDYN22HRQFKFP2AGHLHAOVXZ2IKBU3Q2JLGRZJTVMMZ2R5WNPTD5MFIN
static immutable YN = KeyPair(PublicKey(Point([240, 221, 104, 241, 129, 84, 87, 232, 6, 58, 206, 7, 86, 249, 210, 20, 26, 110, 26, 74, 205, 28, 166, 117, 99, 51, 168, 246, 205, 124, 199, 214])), SecretKey(Scalar([22, 157, 89, 107, 164, 72, 202, 238, 130, 95, 39, 199, 44, 40, 41, 158, 198, 196, 14, 20, 144, 28, 32, 31, 87, 84, 128, 30, 63, 242, 47, 9])));
/// YO: GDYO226PQZKSJWPM7OBSNHMBBFM746YA6ADXTOBQANDNOCDJ5RRCRW4Y
static immutable YO = KeyPair(PublicKey(Point([240, 237, 107, 207, 134, 85, 36, 217, 236, 251, 131, 38, 157, 129, 9, 89, 254, 123, 0, 240, 7, 121, 184, 48, 3, 70, 215, 8, 105, 236, 98, 40])), SecretKey(Scalar([140, 40, 226, 8, 14, 190, 104, 102, 72, 228, 174, 70, 81, 238, 89, 102, 86, 230, 41, 48, 29, 89, 60, 60, 228, 82, 151, 137, 163, 71, 95, 13])));
/// YP: GDYP223JUGYJIKZWPOTBPZZH5THVCFJSDJEMBKXECSR7O4RBN35DSI2A
static immutable YP = KeyPair(PublicKey(Point([240, 253, 107, 105, 161, 176, 148, 43, 54, 123, 166, 23, 231, 39, 236, 207, 81, 21, 50, 26, 72, 192, 170, 228, 20, 163, 247, 114, 33, 110, 250, 57])), SecretKey(Scalar([177, 120, 191, 98, 247, 59, 78, 210, 69, 175, 28, 21, 102, 181, 191, 75, 25, 222, 5, 35, 48, 4, 222, 20, 199, 179, 136, 1, 26, 112, 176, 5])));
/// YQ: GDYQ22KP66G7GFJQDJ4MQ34YIYFEHLSD3ODACOXE346VQUS4DINU662H
static immutable YQ = KeyPair(PublicKey(Point([241, 13, 105, 79, 247, 141, 243, 21, 48, 26, 120, 200, 111, 152, 70, 10, 67, 174, 67, 219, 134, 1, 58, 228, 223, 61, 88, 82, 92, 26, 27, 79])), SecretKey(Scalar([246, 64, 88, 117, 253, 239, 61, 139, 238, 122, 129, 80, 238, 153, 135, 45, 55, 55, 239, 62, 19, 137, 37, 202, 147, 167, 196, 77, 235, 49, 40, 6])));
/// YR: GDYR225EKSNW7ZFDPEECG7VLVGWHQRGFUUNPFCR2A4NQDILTJ4P5KYS2
static immutable YR = KeyPair(PublicKey(Point([241, 29, 107, 164, 84, 155, 111, 228, 163, 121, 8, 35, 126, 171, 169, 172, 120, 68, 197, 165, 26, 242, 138, 58, 7, 27, 1, 161, 115, 79, 31, 213])), SecretKey(Scalar([246, 245, 247, 85, 134, 229, 60, 176, 37, 27, 178, 229, 173, 78, 52, 156, 135, 252, 223, 31, 61, 215, 32, 10, 159, 182, 45, 76, 78, 112, 100, 10])));
/// YS: GDYS22KOZIE5QGTMPUOTDK34GEJOSIWD3XH3P7IFST4VEFY64T2TQGT5
static immutable YS = KeyPair(PublicKey(Point([241, 45, 105, 78, 202, 9, 216, 26, 108, 125, 29, 49, 171, 124, 49, 18, 233, 34, 195, 221, 207, 183, 253, 5, 148, 249, 82, 23, 30, 228, 245, 56])), SecretKey(Scalar([40, 210, 230, 56, 120, 79, 118, 73, 229, 8, 163, 100, 55, 120, 236, 162, 89, 82, 161, 56, 70, 140, 37, 241, 183, 39, 224, 47, 250, 93, 236, 0])));
/// YT: GDYT22YHASP3H6ORXVMRMB6RLMHFW7QFWSGSG7XQBJ7DIRS5NRTJRY5H
static immutable YT = KeyPair(PublicKey(Point([241, 61, 107, 7, 4, 159, 179, 249, 209, 189, 89, 22, 7, 209, 91, 14, 91, 126, 5, 180, 141, 35, 126, 240, 10, 126, 52, 70, 93, 108, 102, 152])), SecretKey(Scalar([162, 197, 44, 125, 204, 154, 212, 99, 235, 30, 37, 92, 16, 148, 77, 30, 191, 63, 42, 175, 243, 120, 167, 148, 109, 164, 85, 129, 176, 168, 100, 10])));
/// YU: GDYU224XHXAUIZQ46G2QILLDOJ3FIT5VQRXNJMURIYE4EQ7QIGCZJ3VG
static immutable YU = KeyPair(PublicKey(Point([241, 77, 107, 151, 61, 193, 68, 102, 28, 241, 181, 4, 45, 99, 114, 118, 84, 79, 181, 132, 110, 212, 178, 145, 70, 9, 194, 67, 240, 65, 133, 148])), SecretKey(Scalar([209, 229, 224, 118, 106, 50, 130, 60, 59, 130, 234, 96, 64, 120, 11, 126, 151, 116, 29, 224, 86, 100, 234, 175, 202, 179, 70, 16, 6, 226, 242, 15])));
/// YV: GDYV22DLGNBR6RXBVAEYSGBB7M5N53OPWJXKN4YE3KKDYTRXMW4SAP6O
static immutable YV = KeyPair(PublicKey(Point([241, 93, 104, 107, 51, 67, 31, 70, 225, 168, 9, 137, 24, 33, 251, 58, 222, 237, 207, 178, 110, 166, 243, 4, 218, 148, 60, 78, 55, 101, 185, 32])), SecretKey(Scalar([50, 201, 186, 116, 186, 81, 81, 37, 218, 249, 103, 136, 97, 136, 245, 34, 153, 43, 221, 128, 132, 188, 224, 195, 125, 98, 78, 89, 147, 105, 205, 3])));
/// YW: GDYW22BVVJAABHCHIERS45UBTG6BO4F2R6EPBIFZKX4JC7KEDML3WRTX
static immutable YW = KeyPair(PublicKey(Point([241, 109, 104, 53, 170, 64, 0, 156, 71, 65, 35, 46, 118, 129, 153, 188, 23, 112, 186, 143, 136, 240, 160, 185, 85, 248, 145, 125, 68, 27, 23, 187])), SecretKey(Scalar([221, 61, 65, 81, 97, 139, 8, 250, 241, 216, 62, 11, 105, 1, 146, 247, 88, 15, 166, 237, 165, 139, 124, 107, 113, 31, 213, 103, 30, 100, 242, 6])));
/// YX: GDYX22CLF3DOQGZKFR5FBPJIDCI5Y2DHHTBTBRYEVB7YXS4LSCIMATIA
static immutable YX = KeyPair(PublicKey(Point([241, 125, 104, 75, 46, 198, 232, 27, 42, 44, 122, 80, 189, 40, 24, 145, 220, 104, 103, 60, 195, 48, 199, 4, 168, 127, 139, 203, 139, 144, 144, 192])), SecretKey(Scalar([223, 55, 175, 191, 218, 139, 62, 195, 107, 237, 94, 246, 106, 72, 50, 74, 183, 153, 218, 125, 235, 136, 211, 68, 53, 163, 53, 249, 236, 208, 204, 4])));
/// YY: GDYY22NZFNHR5CFQQSNZJ2RCSGM4E5H2NWXQTOSWKJYGAMTCYPKDZVTK
static immutable YY = KeyPair(PublicKey(Point([241, 141, 105, 185, 43, 79, 30, 136, 176, 132, 155, 148, 234, 34, 145, 153, 194, 116, 250, 109, 175, 9, 186, 86, 82, 112, 96, 50, 98, 195, 212, 60])), SecretKey(Scalar([37, 112, 40, 38, 107, 72, 133, 73, 14, 136, 126, 245, 81, 177, 237, 41, 131, 173, 212, 119, 29, 21, 114, 62, 141, 63, 146, 25, 213, 143, 238, 3])));
/// YZ: GDYZ22EE5UM5UFZQEGL2BRHNJ3GKKQ3RPU67DGH3XXTHQTCN7MKJR5VU
static immutable YZ = KeyPair(PublicKey(Point([241, 157, 104, 132, 237, 25, 218, 23, 48, 33, 151, 160, 196, 237, 78, 204, 165, 67, 113, 125, 61, 241, 152, 251, 189, 230, 120, 76, 77, 251, 20, 152])), SecretKey(Scalar([2, 109, 246, 122, 3, 59, 1, 56, 74, 200, 84, 235, 89, 136, 219, 145, 70, 67, 54, 204, 70, 82, 113, 9, 238, 207, 176, 43, 25, 128, 160, 6])));
/// ZA: GDZA2226II6RREYZSG2XAGX2OUJE5E5BUSZDMEUJMZ655BFMRQYX6DYV
static immutable ZA = KeyPair(PublicKey(Point([242, 13, 107, 94, 66, 61, 24, 147, 25, 145, 181, 112, 26, 250, 117, 18, 78, 147, 161, 164, 178, 54, 18, 137, 102, 125, 222, 132, 172, 140, 49, 127])), SecretKey(Scalar([80, 252, 122, 162, 228, 117, 168, 162, 212, 190, 134, 3, 116, 41, 23, 184, 72, 166, 85, 82, 211, 192, 171, 196, 223, 94, 152, 178, 96, 98, 68, 1])));
/// ZB: GDZB22SOED4V4OKZA56N2UNWDJ24QU2MVD2GAJBAMCRRQORZEAZMKKEE
static immutable ZB = KeyPair(PublicKey(Point([242, 29, 106, 78, 32, 249, 94, 57, 89, 7, 124, 221, 81, 182, 26, 117, 200, 83, 76, 168, 244, 96, 36, 32, 96, 163, 24, 58, 57, 32, 50, 197])), SecretKey(Scalar([19, 125, 147, 197, 94, 180, 164, 40, 214, 43, 227, 66, 63, 245, 225, 240, 215, 183, 238, 237, 141, 115, 75, 236, 99, 197, 163, 90, 36, 207, 154, 10])));
/// ZC: GDZC22BSQT3KTWFCO6UITTLS6GUBP6NNT4WBVQOTEI7E5DLS533J6IOB
static immutable ZC = KeyPair(PublicKey(Point([242, 45, 104, 50, 132, 246, 169, 216, 162, 119, 168, 137, 205, 114, 241, 168, 23, 249, 173, 159, 44, 26, 193, 211, 34, 62, 78, 141, 114, 238, 246, 159])), SecretKey(Scalar([145, 40, 64, 20, 71, 194, 163, 74, 67, 216, 150, 128, 112, 66, 58, 88, 196, 119, 251, 100, 70, 97, 113, 179, 168, 154, 140, 31, 124, 169, 42, 10])));
/// ZD: GDZD22LKYQLALFV7VDV2RLODJHMMSL2NQEFRUWX2UUNP7RIWGGIPMVOH
static immutable ZD = KeyPair(PublicKey(Point([242, 61, 105, 106, 196, 22, 5, 150, 191, 168, 235, 168, 173, 195, 73, 216, 201, 47, 77, 129, 11, 26, 90, 250, 165, 26, 255, 197, 22, 49, 144, 246])), SecretKey(Scalar([98, 131, 201, 107, 50, 98, 187, 120, 99, 227, 216, 155, 40, 209, 43, 203, 205, 28, 54, 14, 137, 57, 16, 152, 80, 151, 177, 115, 148, 97, 113, 11])));
/// ZE: GDZE22HBAUYQ7K634CYCAAQRTCGEYANNQGTSEYXR7HXPMJMPJM45TVWX
static immutable ZE = KeyPair(PublicKey(Point([242, 77, 104, 225, 5, 49, 15, 171, 219, 224, 176, 32, 2, 17, 152, 140, 76, 1, 173, 129, 167, 34, 98, 241, 249, 238, 246, 37, 143, 75, 57, 217])), SecretKey(Scalar([60, 214, 250, 101, 155, 84, 154, 146, 14, 36, 199, 194, 56, 33, 219, 140, 223, 101, 10, 159, 87, 81, 53, 22, 177, 188, 186, 92, 1, 227, 83, 5])));
/// ZF: GDZF22KRPFFUTUG4ZWJSKAAXCF2SAOCW3BQIWIJDSHVJXJYIGGL6IW4F
static immutable ZF = KeyPair(PublicKey(Point([242, 93, 105, 81, 121, 75, 73, 208, 220, 205, 147, 37, 0, 23, 17, 117, 32, 56, 86, 216, 96, 139, 33, 35, 145, 234, 155, 167, 8, 49, 151, 228])), SecretKey(Scalar([78, 233, 14, 0, 243, 138, 122, 230, 197, 82, 17, 44, 122, 77, 248, 140, 14, 135, 218, 134, 191, 240, 118, 231, 152, 61, 200, 238, 35, 102, 105, 9])));
/// ZG: GDZG22JUVFI5JI3YUCYJWYNV4T3QY3MI7C3EP7WVFCXTXW53H4GYEGZ4
static immutable ZG = KeyPair(PublicKey(Point([242, 109, 105, 52, 169, 81, 212, 163, 120, 160, 176, 155, 97, 181, 228, 247, 12, 109, 136, 248, 182, 71, 254, 213, 40, 175, 59, 219, 187, 63, 13, 130])), SecretKey(Scalar([6, 112, 4, 171, 132, 209, 14, 89, 105, 204, 114, 236, 162, 147, 240, 99, 23, 61, 5, 10, 113, 132, 222, 159, 10, 84, 107, 169, 3, 63, 164, 11])));
/// ZH: GDZH22RWN6R3B6XKSYE5LI5GD54SDAJWEUFYPT7U3RDDEZHEIZABOBAU
static immutable ZH = KeyPair(PublicKey(Point([242, 125, 106, 54, 111, 163, 176, 250, 234, 150, 9, 213, 163, 166, 31, 121, 33, 129, 54, 37, 11, 135, 207, 244, 220, 70, 50, 100, 228, 70, 64, 23])), SecretKey(Scalar([114, 167, 202, 215, 175, 130, 148, 95, 85, 24, 175, 139, 77, 55, 210, 138, 30, 231, 105, 48, 129, 136, 60, 19, 233, 72, 30, 85, 36, 161, 136, 0])));
/// ZI: GDZI22HV24Y6VANC4ETKEKZ6JIMDP5F5MWWBOCHSKVCPHXO5XZMYAARG
static immutable ZI = KeyPair(PublicKey(Point([242, 141, 104, 245, 215, 49, 234, 129, 162, 225, 38, 162, 43, 62, 74, 24, 55, 244, 189, 101, 172, 23, 8, 242, 85, 68, 243, 221, 221, 190, 89, 128])), SecretKey(Scalar([9, 213, 211, 4, 6, 136, 57, 35, 50, 200, 153, 16, 68, 153, 217, 76, 1, 222, 128, 51, 182, 100, 140, 59, 65, 159, 234, 101, 27, 209, 83, 1])));
/// ZJ: GDZJ22OMTBVVMOB4CKX74SDYDSEHSL5IMN77OIO4EYF7JV4K3D6P2PFK
static immutable ZJ = KeyPair(PublicKey(Point([242, 157, 105, 204, 152, 107, 86, 56, 60, 18, 175, 254, 72, 120, 28, 136, 121, 47, 168, 99, 127, 247, 33, 220, 38, 11, 244, 215, 138, 216, 252, 253])), SecretKey(Scalar([163, 169, 222, 95, 51, 120, 202, 116, 225, 253, 180, 69, 253, 66, 75, 214, 222, 88, 98, 106, 162, 45, 194, 106, 220, 83, 133, 109, 106, 207, 133, 6])));
/// ZK: GDZK22NL27TZL75FU7HKW2ZIPJJRSGAZ7R37NAR2NLGKK7QGMUVYCLGN
static immutable ZK = KeyPair(PublicKey(Point([242, 173, 105, 171, 215, 231, 149, 255, 165, 167, 206, 171, 107, 40, 122, 83, 25, 24, 25, 252, 119, 246, 130, 58, 106, 204, 165, 126, 6, 101, 43, 129])), SecretKey(Scalar([69, 228, 120, 114, 10, 33, 131, 253, 83, 40, 93, 225, 85, 75, 212, 118, 145, 176, 93, 46, 171, 59, 97, 202, 113, 158, 133, 67, 208, 91, 114, 11])));
/// ZL: GDZL22S6ICKA3KJ55OGS4SUFSVC3T54OSZT4ZNCO6QDJCTS2FQIH2QOU
static immutable ZL = KeyPair(PublicKey(Point([242, 189, 106, 94, 64, 148, 13, 169, 61, 235, 141, 46, 74, 133, 149, 69, 185, 247, 142, 150, 103, 204, 180, 78, 244, 6, 145, 78, 90, 44, 16, 125])), SecretKey(Scalar([80, 113, 205, 156, 175, 52, 30, 94, 221, 58, 242, 19, 229, 170, 159, 45, 168, 29, 69, 128, 240, 144, 19, 191, 22, 5, 84, 71, 46, 51, 215, 1])));
/// ZM: GDZM22BA2O3VMV4UYJO64ONU6XQEEQSK7U5YBSSKFRIALHEZS4HYFXH4
static immutable ZM = KeyPair(PublicKey(Point([242, 205, 104, 32, 211, 183, 86, 87, 148, 194, 93, 238, 57, 180, 245, 224, 66, 66, 74, 253, 59, 128, 202, 74, 44, 80, 5, 156, 153, 151, 15, 130])), SecretKey(Scalar([111, 147, 229, 234, 75, 206, 33, 174, 32, 63, 209, 206, 109, 145, 81, 92, 19, 1, 79, 2, 32, 114, 134, 110, 133, 99, 71, 80, 156, 241, 114, 10])));
/// ZN: GDZN22RUY2JZ7CPRTJ36Q3FA5ZJ6OLQCZM6APD5WRVU7VUSKVRBNXKEX
static immutable ZN = KeyPair(PublicKey(Point([242, 221, 106, 52, 198, 147, 159, 137, 241, 154, 119, 232, 108, 160, 238, 83, 231, 46, 2, 203, 60, 7, 143, 182, 141, 105, 250, 210, 74, 172, 66, 219])), SecretKey(Scalar([139, 149, 30, 199, 14, 176, 222, 225, 236, 99, 124, 50, 242, 115, 41, 117, 19, 193, 99, 102, 153, 188, 42, 151, 199, 73, 35, 205, 233, 76, 87, 12])));
/// ZO: GDZO22IJMY6JW6WD65DHU2D6ZL6E655FG46Y2MXZPVLDQBOFUDPD5I3C
static immutable ZO = KeyPair(PublicKey(Point([242, 237, 105, 9, 102, 60, 155, 122, 195, 247, 70, 122, 104, 126, 202, 252, 79, 119, 165, 55, 61, 141, 50, 249, 125, 86, 56, 5, 197, 160, 222, 62])), SecretKey(Scalar([235, 21, 61, 250, 245, 253, 219, 56, 82, 184, 114, 197, 224, 231, 73, 110, 92, 31, 209, 138, 142, 36, 74, 131, 227, 117, 30, 58, 148, 241, 194, 9])));
/// ZP: GDZP225E3WMKZBAIJJU26BBAB6ONWI2JCV2DXLWL4MIYU2TMA6KXAXBJ
static immutable ZP = KeyPair(PublicKey(Point([242, 253, 107, 164, 221, 152, 172, 132, 8, 74, 105, 175, 4, 32, 15, 156, 219, 35, 73, 21, 116, 59, 174, 203, 227, 17, 138, 106, 108, 7, 149, 112])), SecretKey(Scalar([140, 32, 239, 227, 61, 179, 231, 219, 182, 223, 164, 200, 160, 58, 16, 3, 133, 226, 107, 114, 235, 149, 211, 82, 216, 101, 109, 155, 217, 128, 168, 6])));
/// ZQ: GDZQ22L4PG3G3VPFQKPIV4VKP72P6U5T7HW5XIL63UYI2A2QP2CQOGVQ
static immutable ZQ = KeyPair(PublicKey(Point([243, 13, 105, 124, 121, 182, 109, 213, 229, 130, 158, 138, 242, 170, 127, 244, 255, 83, 179, 249, 237, 219, 161, 126, 221, 48, 141, 3, 80, 126, 133, 7])), SecretKey(Scalar([102, 134, 71, 188, 8, 95, 240, 167, 134, 140, 13, 109, 152, 68, 95, 47, 125, 38, 185, 75, 148, 115, 84, 162, 31, 237, 22, 229, 93, 251, 128, 10])));
/// ZR: GDZR22DPLZYSHR7VV2R4Z6OGZWBE44SQCJC6DOMFBOPGQU4HTRG2PUXU
static immutable ZR = KeyPair(PublicKey(Point([243, 29, 104, 111, 94, 113, 35, 199, 245, 174, 163, 204, 249, 198, 205, 130, 78, 114, 80, 18, 69, 225, 185, 133, 11, 158, 104, 83, 135, 156, 77, 167])), SecretKey(Scalar([63, 115, 240, 121, 65, 166, 139, 156, 38, 140, 248, 48, 127, 152, 44, 34, 45, 50, 173, 12, 233, 103, 91, 104, 230, 225, 117, 74, 168, 170, 246, 10])));
/// ZS: GDZS22HHRWL5ZEXOGCWTAZW3QNRVTNYEW6JNEDSORZFCHBUC256PRFLK
static immutable ZS = KeyPair(PublicKey(Point([243, 45, 104, 231, 141, 151, 220, 146, 238, 48, 173, 48, 102, 219, 131, 99, 89, 183, 4, 183, 146, 210, 14, 78, 142, 74, 35, 134, 130, 215, 124, 248])), SecretKey(Scalar([218, 3, 255, 81, 49, 193, 224, 101, 219, 73, 12, 157, 49, 155, 171, 254, 171, 113, 176, 112, 236, 30, 70, 93, 86, 128, 154, 45, 220, 67, 129, 8])));
/// ZT: GDZT227VKQ2AB5PRWFWYQGERC3FTE2QLJQOX3Y6L4LYRCDWUZ42GJNKM
static immutable ZT = KeyPair(PublicKey(Point([243, 61, 107, 245, 84, 52, 0, 245, 241, 177, 109, 136, 24, 145, 22, 203, 50, 106, 11, 76, 29, 125, 227, 203, 226, 241, 17, 14, 212, 207, 52, 100])), SecretKey(Scalar([120, 77, 120, 229, 245, 164, 142, 17, 91, 96, 14, 191, 101, 231, 17, 1, 199, 218, 163, 120, 246, 115, 217, 94, 130, 72, 120, 205, 148, 116, 65, 0])));
/// ZU: GDZU22GAMOWLEYJZCS3D2J4BPMTOHCXSPX5MLBPU4OEK23CTX3BZGQPZ
static immutable ZU = KeyPair(PublicKey(Point([243, 77, 104, 192, 99, 172, 178, 97, 57, 20, 182, 61, 39, 129, 123, 38, 227, 138, 242, 125, 250, 197, 133, 244, 227, 136, 173, 108, 83, 190, 195, 147])), SecretKey(Scalar([58, 213, 74, 102, 90, 246, 216, 80, 103, 121, 98, 18, 68, 218, 23, 21, 173, 122, 229, 210, 98, 69, 101, 59, 42, 249, 153, 103, 51, 196, 131, 9])));
/// ZV: GDZV22CM2PHAY56A7RCKHVCSJVEFNVFS7A5NESOFQXOI7BJNCAGBM7KN
static immutable ZV = KeyPair(PublicKey(Point([243, 93, 104, 76, 211, 206, 12, 119, 192, 252, 68, 163, 212, 82, 77, 72, 86, 212, 178, 248, 58, 210, 73, 197, 133, 220, 143, 133, 45, 16, 12, 22])), SecretKey(Scalar([79, 223, 138, 193, 238, 171, 38, 155, 148, 87, 211, 42, 93, 90, 240, 235, 65, 89, 173, 19, 31, 156, 144, 150, 87, 217, 134, 182, 39, 11, 134, 1])));
/// ZW: GDZW22V6U6XG5RUNKC7LYS56APPRG2CVQPL6BS2T3BWDQ4H6LEKOQAP5
static immutable ZW = KeyPair(PublicKey(Point([243, 109, 106, 190, 167, 174, 110, 198, 141, 80, 190, 188, 75, 190, 3, 223, 19, 104, 85, 131, 215, 224, 203, 83, 216, 108, 56, 112, 254, 89, 20, 232])), SecretKey(Scalar([59, 131, 121, 231, 19, 212, 69, 77, 208, 106, 180, 31, 66, 255, 242, 236, 170, 144, 97, 100, 170, 67, 183, 82, 69, 199, 33, 197, 64, 88, 231, 0])));
/// ZX: GDZX22HN67MF7HJSR6O6M42ZSQH5S2VPYOBCZNYCTUKUO76LPELM2WF3
static immutable ZX = KeyPair(PublicKey(Point([243, 125, 104, 237, 247, 216, 95, 157, 50, 143, 157, 230, 115, 89, 148, 15, 217, 106, 175, 195, 130, 44, 183, 2, 157, 21, 71, 127, 203, 121, 22, 205])), SecretKey(Scalar([135, 251, 157, 128, 37, 99, 190, 237, 166, 167, 222, 64, 249, 205, 177, 193, 252, 150, 113, 176, 139, 229, 94, 239, 21, 125, 33, 165, 88, 88, 5, 13])));
/// ZY: GDZY22SNM6N46UQU2JE4RRAPYAFEF2UZJUI2EP2PWDN334O36OGNCCIJ
static immutable ZY = KeyPair(PublicKey(Point([243, 141, 106, 77, 103, 155, 207, 82, 20, 210, 73, 200, 196, 15, 192, 10, 66, 234, 153, 77, 17, 162, 63, 79, 176, 219, 189, 241, 219, 243, 140, 209])), SecretKey(Scalar([160, 205, 88, 105, 254, 5, 188, 0, 59, 191, 95, 9, 64, 56, 167, 17, 189, 103, 233, 85, 237, 55, 48, 215, 244, 228, 27, 161, 208, 78, 212, 13])));
/// ZZ: GDZZ227MNHIYTHXMRYQGQFGHGGNKPQKNLFJUALWYZZE6TGXS7VX2N3Y2
static immutable ZZ = KeyPair(PublicKey(Point([243, 157, 107, 236, 105, 209, 137, 158, 236, 142, 32, 104, 20, 199, 49, 154, 167, 193, 77, 89, 83, 64, 46, 216, 206, 73, 233, 154, 242, 253, 111, 166])), SecretKey(Scalar([202, 156, 189, 234, 27, 106, 118, 83, 38, 229, 109, 49, 218, 98, 122, 42, 23, 225, 113, 254, 60, 143, 199, 235, 235, 180, 88, 29, 51, 117, 224, 4])));
/// AAA: GDAAA22OPJQTKTO4EPFMXSQVX6LTJIYXVD22FYQJVAGYFJYLPUPMT7PJ
static immutable AAA = KeyPair(PublicKey(Point([192, 0, 107, 78, 122, 97, 53, 77, 220, 35, 202, 203, 202, 21, 191, 151, 52, 163, 23, 168, 245, 162, 226, 9, 168, 13, 130, 167, 11, 125, 30, 201])), SecretKey(Scalar([77, 26, 181, 210, 175, 94, 169, 104, 172, 205, 198, 210, 170, 180, 225, 76, 110, 32, 29, 78, 143, 203, 83, 223, 40, 243, 95, 125, 44, 240, 36, 4])));
/// AAB: GDAAB22XHGI3KIY6WFP632USGHPX4WCNNT46RP3WHIXVJUMJNQKX5PPP
static immutable AAB = KeyPair(PublicKey(Point([192, 0, 235, 87, 57, 145, 181, 35, 30, 177, 95, 237, 234, 146, 49, 223, 126, 88, 77, 108, 249, 232, 191, 118, 58, 47, 84, 209, 137, 108, 21, 126])), SecretKey(Scalar([156, 12, 134, 174, 37, 241, 146, 45, 241, 159, 229, 252, 90, 194, 26, 248, 202, 204, 119, 41, 221, 123, 83, 196, 230, 190, 111, 219, 2, 150, 69, 7])));
/// AAC: GDAAC22HIPQ4N5BOR4QBWA7MZXQRA63AGOG35BSWCXN7OZ6IBAIH62LE
static immutable AAC = KeyPair(PublicKey(Point([192, 1, 107, 71, 67, 225, 198, 244, 46, 143, 32, 27, 3, 236, 205, 225, 16, 123, 96, 51, 141, 190, 134, 86, 21, 219, 247, 103, 200, 8, 16, 127])), SecretKey(Scalar([141, 196, 27, 227, 168, 160, 201, 203, 203, 132, 102, 38, 126, 150, 205, 224, 159, 68, 49, 200, 64, 39, 246, 38, 66, 62, 123, 19, 147, 11, 102, 12])));
/// AAD: GDAAD224L6QV6G4RH32ENMRDUDXP6667FEW6MSNT67YBIQ4EGJ2PA44W
static immutable AAD = KeyPair(PublicKey(Point([192, 1, 235, 92, 95, 161, 95, 27, 145, 62, 244, 70, 178, 35, 160, 238, 255, 123, 223, 41, 45, 230, 73, 179, 247, 240, 20, 67, 132, 50, 116, 240])), SecretKey(Scalar([180, 202, 85, 217, 206, 4, 202, 255, 172, 203, 161, 214, 38, 85, 134, 39, 104, 232, 197, 14, 236, 214, 41, 189, 140, 10, 177, 251, 66, 30, 169, 8])));
/// AAE: GDAAE22XTD6EBBWDS3STPF4RO6QFCEY77LSSUSL4BVNW3YCYHQUUWCHH
static immutable AAE = KeyPair(PublicKey(Point([192, 2, 107, 87, 152, 252, 64, 134, 195, 150, 229, 55, 151, 145, 119, 160, 81, 19, 31, 250, 229, 42, 73, 124, 13, 91, 109, 224, 88, 60, 41, 75])), SecretKey(Scalar([232, 164, 190, 228, 209, 232, 176, 203, 87, 25, 123, 64, 117, 144, 51, 5, 246, 249, 61, 119, 80, 74, 43, 245, 166, 200, 130, 87, 163, 128, 56, 8])));
/// AAF: GDAAF22I262U43EPOBW5LL7AA4IUPNKAZWAKTLTLEWGO5KQYNOL74E4O
static immutable AAF = KeyPair(PublicKey(Point([192, 2, 235, 72, 215, 181, 78, 108, 143, 112, 109, 213, 175, 224, 7, 17, 71, 181, 64, 205, 128, 169, 174, 107, 37, 140, 238, 170, 24, 107, 151, 254])), SecretKey(Scalar([241, 207, 67, 80, 121, 42, 206, 164, 245, 1, 88, 157, 2, 21, 156, 159, 55, 45, 174, 198, 95, 147, 228, 89, 208, 238, 179, 206, 179, 103, 76, 4])));
/// AAG: GDAAG22REMVQE2KIX6EYNX2XMNNA7B4MHJFMHXGXWULM6BJINHW65OSR
static immutable AAG = KeyPair(PublicKey(Point([192, 3, 107, 81, 35, 43, 2, 105, 72, 191, 137, 134, 223, 87, 99, 90, 15, 135, 140, 58, 74, 195, 220, 215, 181, 22, 207, 5, 40, 105, 237, 238])), SecretKey(Scalar([117, 212, 29, 160, 110, 110, 1, 233, 35, 23, 62, 2, 241, 250, 179, 233, 55, 72, 179, 39, 170, 239, 27, 197, 9, 81, 161, 160, 218, 79, 107, 9])));
/// AAH: GDAAH22MXGWZ3KZVAVKKIJ23O3FKLIM22JQFY3PD2YS5HRFYRNOHJG4U
static immutable AAH = KeyPair(PublicKey(Point([192, 3, 235, 76, 185, 173, 157, 171, 53, 5, 84, 164, 39, 91, 118, 202, 165, 161, 154, 210, 96, 92, 109, 227, 214, 37, 211, 196, 184, 139, 92, 116])), SecretKey(Scalar([37, 14, 43, 77, 74, 229, 61, 219, 86, 70, 211, 122, 242, 126, 126, 15, 168, 129, 238, 214, 199, 19, 43, 142, 143, 150, 222, 191, 162, 165, 48, 3])));
/// AAI: GDAAI22VYVHLBY6EDELEM5VC7BVFKNBN7DFPI42Z23HE23RKIUWRSFV5
static immutable AAI = KeyPair(PublicKey(Point([192, 4, 107, 85, 197, 78, 176, 227, 196, 25, 22, 70, 118, 162, 248, 106, 85, 52, 45, 248, 202, 244, 115, 89, 214, 206, 77, 110, 42, 69, 45, 25])), SecretKey(Scalar([177, 60, 177, 136, 195, 252, 66, 39, 143, 86, 10, 134, 96, 253, 172, 158, 250, 82, 164, 226, 63, 40, 148, 80, 46, 250, 144, 33, 18, 156, 81, 5])));
/// AAJ: GDAAJ22TWKT2NO4OJFG45RUCC2WSSUB27M4NJKY52UGS6Y74J7RYRQB5
static immutable AAJ = KeyPair(PublicKey(Point([192, 4, 235, 83, 178, 167, 166, 187, 142, 73, 77, 206, 198, 130, 22, 173, 41, 80, 58, 251, 56, 212, 171, 29, 213, 13, 47, 99, 252, 79, 227, 136])), SecretKey(Scalar([113, 86, 13, 13, 187, 199, 39, 11, 253, 28, 93, 216, 64, 244, 210, 94, 45, 218, 175, 157, 181, 31, 66, 130, 75, 213, 23, 102, 29, 218, 73, 14])));
/// AAK: GDAAK223LNTJ2H5D3ZYOOLVKBD6XDEJWA6WAVBORX57EHCZDCGJMU2WH
static immutable AAK = KeyPair(PublicKey(Point([192, 5, 107, 91, 91, 102, 157, 31, 163, 222, 112, 231, 46, 170, 8, 253, 113, 145, 54, 7, 172, 10, 133, 209, 191, 126, 67, 139, 35, 17, 146, 202])), SecretKey(Scalar([106, 174, 188, 92, 90, 157, 215, 22, 142, 246, 1, 140, 227, 19, 25, 135, 11, 31, 136, 79, 238, 77, 5, 83, 33, 124, 2, 94, 210, 183, 15, 4])));
/// AAL: GDAAL22YGXUQOUTSRAB5KWPAGMARDEL4QD54EWMWY2CQ2PB5UB4OTGSO
static immutable AAL = KeyPair(PublicKey(Point([192, 5, 235, 88, 53, 233, 7, 82, 114, 136, 3, 213, 89, 224, 51, 1, 17, 145, 124, 128, 251, 194, 89, 150, 198, 133, 13, 60, 61, 160, 120, 233])), SecretKey(Scalar([164, 78, 73, 47, 90, 17, 226, 214, 103, 210, 173, 22, 194, 140, 5, 162, 233, 103, 109, 236, 27, 187, 88, 79, 53, 36, 102, 200, 157, 233, 21, 15])));
/// AAM: GDAAM22FQP236UM2YUU2HCKS33VACXZWEHG2GQKHSHDYNGJEP6GCWWZ3
static immutable AAM = KeyPair(PublicKey(Point([192, 6, 107, 69, 131, 245, 191, 81, 154, 197, 41, 163, 137, 82, 222, 234, 1, 95, 54, 33, 205, 163, 65, 71, 145, 199, 134, 153, 36, 127, 140, 43])), SecretKey(Scalar([162, 34, 134, 65, 154, 44, 187, 21, 253, 222, 197, 153, 246, 65, 87, 200, 133, 220, 44, 214, 163, 133, 102, 175, 40, 29, 140, 64, 70, 187, 127, 9])));
/// AAN: GDAAN22MLW3ZOKMKGMZTSZ4E4HSSGNFTH5SMLI775VSTNVYIU2OSW3GQ
static immutable AAN = KeyPair(PublicKey(Point([192, 6, 235, 76, 93, 183, 151, 41, 138, 51, 51, 57, 103, 132, 225, 229, 35, 52, 179, 63, 100, 197, 163, 255, 237, 101, 54, 215, 8, 166, 157, 43])), SecretKey(Scalar([56, 194, 31, 107, 33, 39, 12, 186, 149, 227, 100, 71, 233, 255, 87, 6, 33, 182, 102, 106, 181, 90, 68, 70, 110, 147, 102, 56, 175, 58, 41, 3])));
/// AAO: GDAAO22MLQVARY5KBPLRMNEMEDUWVCOTB52UMX4DSOCWQONVNUNOFPSL
static immutable AAO = KeyPair(PublicKey(Point([192, 7, 107, 76, 92, 42, 8, 227, 170, 11, 215, 22, 52, 140, 32, 233, 106, 137, 211, 15, 117, 70, 95, 131, 147, 133, 104, 57, 181, 109, 26, 226])), SecretKey(Scalar([3, 66, 88, 249, 238, 127, 15, 46, 115, 110, 145, 141, 1, 64, 76, 189, 16, 29, 170, 21, 145, 46, 225, 54, 124, 11, 163, 59, 3, 76, 225, 2])));
/// AAP: GDAAP22XTMKUOTNPNPJTWOWOOQL3JGZTGM7XE2OZFVZHBOSOYD7G7YMJ
static immutable AAP = KeyPair(PublicKey(Point([192, 7, 235, 87, 155, 21, 71, 77, 175, 107, 211, 59, 58, 206, 116, 23, 180, 155, 51, 51, 63, 114, 105, 217, 45, 114, 112, 186, 78, 192, 254, 111])), SecretKey(Scalar([60, 44, 144, 143, 176, 176, 183, 151, 70, 130, 35, 236, 26, 36, 186, 114, 44, 129, 40, 129, 198, 229, 246, 107, 128, 231, 57, 29, 120, 103, 14, 11])));
/// AAQ: GDAAQ225LN6JPE6KGK3CAINZOCCWOVRWXF7BZQNAFAWIDN3GZKDG2HG3
static immutable AAQ = KeyPair(PublicKey(Point([192, 8, 107, 93, 91, 124, 151, 147, 202, 50, 182, 32, 33, 185, 112, 133, 103, 86, 54, 185, 126, 28, 193, 160, 40, 44, 129, 183, 102, 202, 134, 109])), SecretKey(Scalar([117, 6, 234, 9, 108, 167, 192, 119, 64, 245, 216, 202, 76, 214, 160, 236, 201, 210, 215, 33, 104, 228, 50, 142, 190, 44, 98, 23, 7, 133, 174, 15])));
/// AAR: GDAAR225EOBNE5QMIBKZR7SAIFZHMIJWO3GMMMR6Y5CR7DZFXLQNG7KC
static immutable AAR = KeyPair(PublicKey(Point([192, 8, 235, 93, 35, 130, 210, 118, 12, 64, 85, 152, 254, 64, 65, 114, 118, 33, 54, 118, 204, 198, 50, 62, 199, 69, 31, 143, 37, 186, 224, 211])), SecretKey(Scalar([248, 208, 106, 81, 73, 3, 17, 73, 30, 112, 122, 91, 64, 29, 140, 0, 82, 137, 61, 6, 219, 233, 73, 195, 209, 147, 163, 5, 40, 113, 47, 14])));
/// AAS: GDAAS22ANB2IVHU5CATMZTY7QRVNN7JBKONGJT4JU2I2ICXFZUQIVW67
static immutable AAS = KeyPair(PublicKey(Point([192, 9, 107, 64, 104, 116, 138, 158, 157, 16, 38, 204, 207, 31, 132, 106, 214, 253, 33, 83, 154, 100, 207, 137, 166, 145, 164, 10, 229, 205, 32, 138])), SecretKey(Scalar([154, 30, 64, 155, 18, 219, 84, 11, 121, 25, 93, 15, 5, 171, 255, 98, 236, 215, 194, 49, 235, 152, 253, 207, 122, 225, 253, 252, 166, 181, 162, 1])));
/// AAT: GDAAT222QSA2WHREJAL4XXT7KV7GB6EIFQLYXKAGJE7XOGLXSPOJ3EBC
static immutable AAT = KeyPair(PublicKey(Point([192, 9, 235, 90, 132, 129, 171, 30, 36, 72, 23, 203, 222, 127, 85, 126, 96, 248, 136, 44, 23, 139, 168, 6, 73, 63, 119, 25, 119, 147, 220, 157])), SecretKey(Scalar([191, 249, 196, 170, 235, 103, 118, 214, 168, 15, 45, 127, 144, 243, 164, 216, 253, 54, 181, 205, 38, 27, 245, 119, 193, 237, 215, 47, 16, 41, 124, 8])));
/// AAU: GDAAU22BD5OJYFSOOCSOBKKCABJX4FUMS2DOV4L7QVH624PSKKMBKT3C
static immutable AAU = KeyPair(PublicKey(Point([192, 10, 107, 65, 31, 92, 156, 22, 78, 112, 164, 224, 169, 66, 0, 83, 126, 22, 140, 150, 134, 234, 241, 127, 133, 79, 237, 113, 242, 82, 152, 21])), SecretKey(Scalar([33, 17, 227, 239, 255, 134, 0, 148, 67, 47, 46, 183, 94, 136, 52, 44, 123, 13, 224, 175, 244, 54, 83, 177, 169, 76, 244, 191, 56, 219, 36, 1])));
/// AAV: GDAAV22RIIFQ3L47FOY2EQQ3XTSDZFCJGSKCXH3WS5LTZQE2UBRCJFOL
static immutable AAV = KeyPair(PublicKey(Point([192, 10, 235, 81, 66, 11, 13, 175, 159, 43, 177, 162, 66, 27, 188, 228, 60, 148, 73, 52, 148, 43, 159, 118, 151, 87, 60, 192, 154, 160, 98, 36])), SecretKey(Scalar([190, 62, 62, 123, 159, 193, 65, 160, 200, 158, 44, 215, 158, 105, 180, 109, 50, 132, 53, 53, 11, 152, 178, 131, 133, 72, 132, 174, 168, 113, 39, 2])));
/// AAW: GDAAW22QOD7C2TLH57FKZQJTM6ASUFFR6A7BPZHB2DPY7STTK4DWVEDJ
static immutable AAW = KeyPair(PublicKey(Point([192, 11, 107, 80, 112, 254, 45, 77, 103, 239, 202, 172, 193, 51, 103, 129, 42, 20, 177, 240, 62, 23, 228, 225, 208, 223, 143, 202, 115, 87, 7, 106])), SecretKey(Scalar([127, 161, 235, 16, 123, 222, 130, 177, 139, 189, 103, 179, 147, 145, 205, 69, 250, 173, 66, 43, 106, 193, 3, 50, 84, 234, 194, 251, 144, 126, 75, 4])));
/// AAX: GDAAX22SK5U4QA4MZCHZCQOPTWXW7MO6D3TWKEHSDE6ICJPVLQGW7IZE
static immutable AAX = KeyPair(PublicKey(Point([192, 11, 235, 82, 87, 105, 200, 3, 140, 200, 143, 145, 65, 207, 157, 175, 111, 177, 222, 30, 231, 101, 16, 242, 25, 60, 129, 37, 245, 92, 13, 111])), SecretKey(Scalar([200, 100, 195, 27, 252, 84, 113, 212, 98, 166, 15, 141, 154, 68, 138, 229, 57, 75, 139, 93, 93, 150, 154, 204, 62, 218, 144, 25, 95, 39, 6, 14])));
/// AAY: GDAAY22X6KCAQIHHS57X5YJQKHIRLIPJX4X452W37C3E7JM2VSTHFGDH
static immutable AAY = KeyPair(PublicKey(Point([192, 12, 107, 87, 242, 132, 8, 32, 231, 151, 127, 126, 225, 48, 81, 209, 21, 161, 233, 191, 47, 206, 234, 219, 248, 182, 79, 165, 154, 172, 166, 114])), SecretKey(Scalar([50, 186, 121, 25, 59, 106, 137, 227, 9, 44, 109, 122, 222, 218, 173, 253, 195, 93, 43, 86, 214, 235, 141, 36, 24, 241, 34, 84, 90, 203, 111, 12])));
/// AAZ: GDAAZ22RPXSBNMOE5KRGGA75TZ3R6HWFMEPUTQY3ODC4BORCLIEQCJGK
static immutable AAZ = KeyPair(PublicKey(Point([192, 12, 235, 81, 125, 228, 22, 177, 196, 234, 162, 99, 3, 253, 158, 119, 31, 30, 197, 97, 31, 73, 195, 27, 112, 197, 192, 186, 34, 90, 9, 1])), SecretKey(Scalar([164, 132, 106, 225, 8, 53, 114, 35, 17, 172, 148, 215, 162, 149, 119, 236, 187, 1, 21, 157, 32, 3, 180, 203, 208, 205, 243, 216, 18, 20, 129, 5])));
/// ABA: GDABA22XPTLXLDIVGFHJ65OUKKW6FFA4BFTZMHFSZER5XMDICUKZTNWM
static immutable ABA = KeyPair(PublicKey(Point([192, 16, 107, 87, 124, 215, 117, 141, 21, 49, 78, 159, 117, 212, 82, 173, 226, 148, 28, 9, 103, 150, 28, 178, 201, 35, 219, 176, 104, 21, 21, 153])), SecretKey(Scalar([56, 29, 61, 233, 139, 14, 19, 27, 78, 157, 56, 72, 224, 161, 149, 38, 86, 177, 5, 216, 155, 13, 53, 35, 111, 49, 75, 165, 213, 168, 2, 7])));
/// ABB: GDABB22XU3U56G54TFQJWLLSTDFSMLTWEDL7AOQYYT2SPIQACH2GJMUM
static immutable ABB = KeyPair(PublicKey(Point([192, 16, 235, 87, 166, 233, 223, 27, 188, 153, 96, 155, 45, 114, 152, 203, 38, 46, 118, 32, 215, 240, 58, 24, 196, 245, 39, 162, 0, 17, 244, 100])), SecretKey(Scalar([62, 132, 85, 50, 120, 51, 125, 188, 128, 123, 177, 84, 1, 168, 49, 9, 226, 26, 168, 146, 72, 129, 97, 114, 9, 77, 82, 173, 17, 94, 83, 10])));
/// ABC: GDABC22T7L5OTEZ5CZOLKC5B2EWBAUSMGT42CURGJQMK4FLN47LMW3QJ
static immutable ABC = KeyPair(PublicKey(Point([192, 17, 107, 83, 250, 250, 233, 147, 61, 22, 92, 181, 11, 161, 209, 44, 16, 82, 76, 52, 249, 161, 82, 38, 76, 24, 174, 21, 109, 231, 214, 203])), SecretKey(Scalar([131, 240, 5, 109, 205, 23, 21, 53, 151, 216, 215, 174, 145, 93, 13, 132, 126, 175, 137, 89, 166, 73, 10, 57, 169, 3, 225, 87, 201, 134, 94, 9])));
/// ABD: GDABD22EQWNT2IR7HJFF76HV5EOKCJAOAC6ZE72JEGDOQINBWRW2QNP2
static immutable ABD = KeyPair(PublicKey(Point([192, 17, 235, 68, 133, 155, 61, 34, 63, 58, 74, 95, 248, 245, 233, 28, 161, 36, 14, 0, 189, 146, 127, 73, 33, 134, 232, 33, 161, 180, 109, 168])), SecretKey(Scalar([28, 97, 230, 210, 128, 210, 233, 189, 206, 113, 128, 71, 173, 24, 85, 127, 140, 185, 187, 29, 255, 233, 166, 123, 249, 127, 250, 39, 90, 247, 103, 11])));
/// ABE: GDABE226G4KN4VCOMY34MWKL7K5T5OTX5BFRXDA3MTJYOIOXW5TBVRTO
static immutable ABE = KeyPair(PublicKey(Point([192, 18, 107, 94, 55, 20, 222, 84, 78, 102, 55, 198, 89, 75, 250, 187, 62, 186, 119, 232, 75, 27, 140, 27, 100, 211, 135, 33, 215, 183, 102, 26])), SecretKey(Scalar([181, 249, 58, 252, 245, 133, 215, 253, 42, 88, 25, 107, 144, 61, 22, 150, 60, 100, 218, 101, 170, 28, 77, 91, 155, 48, 44, 209, 15, 51, 238, 15])));
/// ABF: GDABF2232GT2XEH3OZ6W6YG6QHUPEIFVQKRBTHYAOLOCYDOPYFB5A7IU
static immutable ABF = KeyPair(PublicKey(Point([192, 18, 235, 91, 209, 167, 171, 144, 251, 118, 125, 111, 96, 222, 129, 232, 242, 32, 181, 130, 162, 25, 159, 0, 114, 220, 44, 13, 207, 193, 67, 208])), SecretKey(Scalar([229, 98, 87, 68, 188, 16, 89, 186, 237, 100, 253, 139, 78, 112, 142, 3, 13, 186, 107, 154, 17, 135, 245, 138, 53, 249, 87, 77, 126, 217, 123, 9])));
/// ABG: GDABG22GIJUUGGNHCGBR3M324D72M2UQYUJ5YYZSPJ3Z7IH24DEVZGCI
static immutable ABG = KeyPair(PublicKey(Point([192, 19, 107, 70, 66, 105, 67, 25, 167, 17, 131, 29, 179, 122, 224, 255, 166, 106, 144, 197, 19, 220, 99, 50, 122, 119, 159, 160, 250, 224, 201, 92])), SecretKey(Scalar([186, 53, 1, 216, 96, 62, 222, 20, 236, 81, 146, 218, 152, 109, 12, 40, 148, 189, 58, 166, 67, 105, 204, 168, 152, 238, 234, 91, 120, 60, 68, 3])));
/// ABH: GDABH22NAUZD2LB5QYYJHSOILCF4A22P6WLJMFALU56HUQFIQHI7ONXJ
static immutable ABH = KeyPair(PublicKey(Point([192, 19, 235, 77, 5, 50, 61, 44, 61, 134, 48, 147, 201, 200, 88, 139, 192, 107, 79, 245, 150, 150, 20, 11, 167, 124, 122, 64, 168, 129, 209, 247])), SecretKey(Scalar([118, 136, 203, 154, 227, 119, 159, 216, 6, 33, 203, 2, 46, 145, 45, 184, 122, 180, 168, 65, 59, 255, 119, 0, 35, 254, 3, 75, 108, 239, 131, 13])));
/// ABI: GDABI227NXDRBH6GVLYZWL7TM6QLB3MYCTWIWDWAWTSGXV6ZI7OIHNIV
static immutable ABI = KeyPair(PublicKey(Point([192, 20, 107, 95, 109, 199, 16, 159, 198, 170, 241, 155, 47, 243, 103, 160, 176, 237, 152, 20, 236, 139, 14, 192, 180, 228, 107, 215, 217, 71, 220, 131])), SecretKey(Scalar([25, 138, 5, 214, 176, 219, 99, 36, 12, 75, 116, 17, 27, 149, 252, 32, 199, 148, 38, 144, 216, 215, 114, 42, 251, 136, 128, 136, 225, 47, 70, 7])));
/// ABJ: GDABJ226S6HMZTQ44XCN4ZMBBQ4ODD5QCOA7KC6BYGGCX2KGK3OEAAYP
static immutable ABJ = KeyPair(PublicKey(Point([192, 20, 235, 94, 151, 142, 204, 206, 28, 229, 196, 222, 101, 129, 12, 56, 225, 143, 176, 19, 129, 245, 11, 193, 193, 140, 43, 233, 70, 86, 220, 64])), SecretKey(Scalar([179, 99, 184, 115, 21, 190, 183, 178, 137, 42, 23, 172, 79, 230, 117, 43, 58, 20, 201, 23, 100, 56, 235, 168, 220, 248, 140, 40, 246, 135, 210, 5])));
/// ABK: GDABK22H2VFMBG32X4M6SLVJPMKHPKNXLP327UMDFK5YWLJWFU27B5OO
static immutable ABK = KeyPair(PublicKey(Point([192, 21, 107, 71, 213, 74, 192, 155, 122, 191, 25, 233, 46, 169, 123, 20, 119, 169, 183, 91, 247, 175, 209, 131, 42, 187, 139, 45, 54, 45, 53, 240])), SecretKey(Scalar([211, 202, 124, 39, 164, 202, 221, 120, 13, 129, 233, 1, 83, 106, 209, 116, 165, 64, 211, 226, 11, 119, 43, 5, 42, 47, 220, 18, 190, 93, 101, 0])));
/// ABL: GDABL22UJ65TCNV4Q6IXOHZGRPU56SDOIM7LJ44NWJ4VDLHU7U6UN23H
static immutable ABL = KeyPair(PublicKey(Point([192, 21, 235, 84, 79, 187, 49, 54, 188, 135, 145, 119, 31, 38, 139, 233, 223, 72, 110, 67, 62, 180, 243, 141, 178, 121, 81, 172, 244, 253, 61, 70])), SecretKey(Scalar([187, 92, 213, 246, 90, 92, 252, 189, 50, 85, 172, 153, 216, 225, 132, 13, 173, 36, 12, 32, 33, 169, 61, 224, 91, 189, 49, 41, 71, 142, 220, 8])));
/// ABM: GDABM22HT3AK3FQX77HB6OE6CF5X324XR2RL5NPN6LUVAWYWWVR3KK6I
static immutable ABM = KeyPair(PublicKey(Point([192, 22, 107, 71, 158, 192, 173, 150, 23, 255, 206, 31, 56, 158, 17, 123, 125, 235, 151, 142, 162, 190, 181, 237, 242, 233, 80, 91, 22, 181, 99, 181])), SecretKey(Scalar([54, 9, 52, 106, 58, 222, 232, 203, 196, 101, 17, 12, 213, 70, 11, 212, 209, 118, 229, 17, 195, 140, 100, 54, 197, 123, 35, 86, 7, 155, 174, 6])));
/// ABN: GDABN22HP2O6RRLIARG4ECMQXYFTCN6M4F5R73FVMIT2VP5TXEYP6BGA
static immutable ABN = KeyPair(PublicKey(Point([192, 22, 235, 71, 126, 157, 232, 197, 104, 4, 77, 194, 9, 144, 190, 11, 49, 55, 204, 225, 123, 31, 236, 181, 98, 39, 170, 191, 179, 185, 48, 255])), SecretKey(Scalar([186, 169, 65, 243, 164, 33, 193, 121, 86, 89, 247, 15, 27, 159, 247, 196, 166, 253, 67, 253, 248, 141, 190, 74, 64, 57, 113, 60, 250, 111, 14, 1])));
/// ABO: GDABO22FWQX6JXRG7MC4CSBOSVA2FGFPMDBUZM4U47C4QZDPIADNMUGT
static immutable ABO = KeyPair(PublicKey(Point([192, 23, 107, 69, 180, 47, 228, 222, 38, 251, 5, 193, 72, 46, 149, 65, 162, 152, 175, 96, 195, 76, 179, 148, 231, 197, 200, 100, 111, 64, 6, 214])), SecretKey(Scalar([39, 202, 26, 32, 206, 227, 179, 85, 170, 231, 91, 126, 167, 117, 92, 189, 249, 30, 98, 77, 40, 236, 22, 9, 175, 145, 25, 123, 168, 247, 180, 4])));
/// ABP: GDABP22BYJCXVZKO42VSYUFUXWNA7RSA2TPUBVUC4JQ33FHN6HVMS4Q7
static immutable ABP = KeyPair(PublicKey(Point([192, 23, 235, 65, 194, 69, 122, 229, 78, 230, 171, 44, 80, 180, 189, 154, 15, 198, 64, 212, 223, 64, 214, 130, 226, 97, 189, 148, 237, 241, 234, 201])), SecretKey(Scalar([100, 43, 77, 236, 199, 217, 139, 62, 9, 250, 83, 120, 226, 228, 22, 60, 63, 166, 178, 38, 48, 224, 140, 168, 176, 120, 168, 253, 113, 255, 215, 12])));
/// ABQ: GDABQ22L2APXNQLQUQC23X33OZPK2UP57M23KJH5T74SL37CWWRMNPTT
static immutable ABQ = KeyPair(PublicKey(Point([192, 24, 107, 75, 208, 31, 118, 193, 112, 164, 5, 173, 223, 123, 118, 94, 173, 81, 253, 251, 53, 181, 36, 253, 159, 249, 37, 239, 226, 181, 162, 198])), SecretKey(Scalar([198, 75, 255, 155, 19, 3, 60, 72, 146, 154, 184, 235, 236, 123, 67, 99, 24, 37, 244, 55, 87, 124, 37, 184, 240, 24, 114, 62, 0, 226, 2, 2])));
/// ABR: GDABR22ALL3UECLUGQISSKRD2S7RKOVAJFXEMK7I7M4BOKHMXGG27BNK
static immutable ABR = KeyPair(PublicKey(Point([192, 24, 235, 64, 90, 247, 66, 9, 116, 52, 17, 41, 42, 35, 212, 191, 21, 58, 160, 73, 110, 70, 43, 232, 251, 56, 23, 40, 236, 185, 141, 175])), SecretKey(Scalar([148, 166, 220, 142, 98, 43, 109, 238, 160, 221, 133, 106, 160, 132, 16, 107, 191, 24, 157, 240, 16, 107, 243, 242, 108, 23, 211, 208, 156, 115, 218, 7])));
/// ABS: GDABS22UYH3EHS2QDC32FUBYFKNA2SHTVBAKYNZ7UAETABBSBCGTI5ZE
static immutable ABS = KeyPair(PublicKey(Point([192, 25, 107, 84, 193, 246, 67, 203, 80, 24, 183, 162, 208, 56, 42, 154, 13, 72, 243, 168, 64, 172, 55, 63, 160, 9, 48, 4, 50, 8, 141, 52])), SecretKey(Scalar([31, 105, 125, 119, 177, 172, 63, 207, 237, 240, 32, 221, 1, 135, 114, 21, 249, 21, 223, 33, 99, 244, 116, 117, 136, 114, 22, 127, 253, 15, 218, 9])));
/// ABT: GDABT22T2YWLAM3PCTJMHL3REVH6IDHISAHJLI7RZE2U5TMMBEKXIA6Q
static immutable ABT = KeyPair(PublicKey(Point([192, 25, 235, 83, 214, 44, 176, 51, 111, 20, 210, 195, 175, 113, 37, 79, 228, 12, 232, 144, 14, 149, 163, 241, 201, 53, 78, 205, 140, 9, 21, 116])), SecretKey(Scalar([242, 251, 4, 6, 12, 10, 88, 189, 52, 117, 242, 246, 180, 192, 40, 118, 196, 85, 104, 238, 80, 237, 197, 227, 189, 166, 212, 161, 8, 129, 79, 3])));
/// ABU: GDABU22RXWDXN5IHNTD2ZUL3BEO2AC5J5VO7D2LFLIM4VAJHSRILJSHS
static immutable ABU = KeyPair(PublicKey(Point([192, 26, 107, 81, 189, 135, 118, 245, 7, 108, 199, 172, 209, 123, 9, 29, 160, 11, 169, 237, 93, 241, 233, 101, 90, 25, 202, 129, 39, 148, 80, 180])), SecretKey(Scalar([99, 106, 216, 37, 109, 23, 108, 247, 171, 208, 224, 245, 41, 65, 65, 136, 90, 212, 104, 133, 212, 229, 0, 229, 120, 230, 96, 222, 202, 182, 243, 12])));
/// ABV: GDABV22HFYZISVZ755NRXPDXIH2U5AXNXWKJ4XJN4H3OGPCDZ5BA4C7T
static immutable ABV = KeyPair(PublicKey(Point([192, 26, 235, 71, 46, 50, 137, 87, 63, 239, 91, 27, 188, 119, 65, 245, 78, 130, 237, 189, 148, 158, 93, 45, 225, 246, 227, 60, 67, 207, 66, 14])), SecretKey(Scalar([172, 172, 138, 251, 2, 242, 152, 42, 41, 137, 233, 193, 229, 203, 83, 181, 172, 252, 122, 106, 147, 235, 95, 144, 68, 255, 122, 35, 199, 119, 76, 12])));
/// ABW: GDABW22HB67UI3D2OQSOMXC6KP7PUZVPOT6WS2D6ZNLO757HKAYYMYHF
static immutable ABW = KeyPair(PublicKey(Point([192, 27, 107, 71, 15, 191, 68, 108, 122, 116, 36, 230, 92, 94, 83, 254, 250, 102, 175, 116, 253, 105, 104, 126, 203, 86, 239, 247, 231, 80, 49, 134])), SecretKey(Scalar([74, 134, 187, 130, 210, 119, 93, 4, 46, 91, 212, 198, 72, 92, 203, 89, 134, 22, 204, 103, 13, 135, 57, 238, 185, 179, 128, 243, 171, 209, 202, 9])));
/// ABX: GDABX22XI3XW2WN54A7BTQBVEU3JPLHCJA63GE575HRCFMZTRLEUDFQR
static immutable ABX = KeyPair(PublicKey(Point([192, 27, 235, 87, 70, 239, 109, 89, 189, 224, 62, 25, 192, 53, 37, 54, 151, 172, 226, 72, 61, 179, 19, 191, 233, 226, 34, 179, 51, 138, 201, 65])), SecretKey(Scalar([163, 173, 103, 34, 55, 98, 24, 20, 33, 239, 31, 246, 96, 220, 25, 186, 169, 231, 95, 93, 107, 210, 137, 172, 253, 225, 38, 216, 41, 94, 182, 3])));
/// ABY: GDABY22QVRJHFJSRDZK44YQVIPGZHG3W4J54J64ITL4U5GY6S3FYXHES
static immutable ABY = KeyPair(PublicKey(Point([192, 28, 107, 80, 172, 82, 114, 166, 81, 30, 85, 206, 98, 21, 67, 205, 147, 155, 118, 226, 123, 196, 251, 136, 154, 249, 78, 155, 30, 150, 203, 139])), SecretKey(Scalar([186, 64, 144, 50, 214, 62, 242, 230, 222, 181, 207, 152, 71, 252, 81, 55, 125, 12, 242, 200, 90, 137, 5, 121, 251, 141, 95, 35, 137, 229, 31, 9])));
/// ABZ: GDABZ22RZWP5TMQMEUWPRELBCWAKNVBBZYB6ZNXVBXHOZETCHFJPIE7I
static immutable ABZ = KeyPair(PublicKey(Point([192, 28, 235, 81, 205, 159, 217, 178, 12, 37, 44, 248, 145, 97, 21, 128, 166, 212, 33, 206, 3, 236, 182, 245, 13, 206, 236, 146, 98, 57, 82, 244])), SecretKey(Scalar([56, 255, 20, 43, 85, 21, 92, 220, 131, 93, 237, 103, 219, 93, 233, 196, 21, 228, 127, 153, 217, 207, 217, 31, 254, 140, 3, 171, 149, 185, 55, 13])));
/// ACA: GDACA226EREPRZSELCBQ2MK6UITCKTN2CIJ3XSMRVZTLBKMEFABUU2MS
static immutable ACA = KeyPair(PublicKey(Point([192, 32, 107, 94, 36, 72, 248, 230, 68, 88, 131, 13, 49, 94, 162, 38, 37, 77, 186, 18, 19, 187, 201, 145, 174, 102, 176, 169, 132, 40, 3, 74])), SecretKey(Scalar([195, 174, 101, 24, 52, 201, 122, 22, 232, 237, 226, 148, 112, 30, 231, 38, 121, 27, 212, 38, 120, 212, 62, 121, 135, 130, 91, 54, 237, 33, 37, 13])));
/// ACB: GDACB22YCU4K32FYPBGNW33MAX2WCELMETK32LAIQLWOJ5MBJPDYFOV2
static immutable ACB = KeyPair(PublicKey(Point([192, 32, 235, 88, 21, 56, 173, 232, 184, 120, 76, 219, 111, 108, 5, 245, 97, 17, 108, 36, 213, 189, 44, 8, 130, 236, 228, 245, 129, 75, 199, 130])), SecretKey(Scalar([206, 57, 77, 59, 33, 132, 233, 208, 120, 28, 206, 220, 90, 35, 144, 173, 139, 28, 130, 173, 68, 195, 197, 154, 41, 110, 141, 190, 195, 238, 51, 14])));
/// ACC: GDACC222RJ5WY3MHPITPAOYSW3IT72BL5EYNITBKZENESM6GF52YYGEJ
static immutable ACC = KeyPair(PublicKey(Point([192, 33, 107, 90, 138, 123, 108, 109, 135, 122, 38, 240, 59, 18, 182, 209, 63, 232, 43, 233, 48, 212, 76, 42, 201, 26, 73, 51, 198, 47, 117, 140])), SecretKey(Scalar([53, 124, 47, 69, 181, 46, 189, 219, 189, 17, 96, 170, 51, 194, 131, 25, 92, 192, 189, 121, 231, 233, 57, 192, 181, 52, 21, 232, 89, 51, 165, 4])));
/// ACD: GDACD22I7KQ7UXHEU3AHOFD4PXQULMPLKYI7PGPEESET2JFG5ADQSJCS
static immutable ACD = KeyPair(PublicKey(Point([192, 33, 235, 72, 250, 161, 250, 92, 228, 166, 192, 119, 20, 124, 125, 225, 69, 177, 235, 86, 17, 247, 153, 228, 36, 137, 61, 36, 166, 232, 7, 9])), SecretKey(Scalar([131, 250, 102, 237, 130, 162, 36, 179, 195, 51, 28, 98, 39, 179, 51, 40, 182, 245, 7, 17, 106, 39, 254, 6, 192, 143, 111, 15, 7, 161, 140, 10])));
/// ACE: GDACE22YD6TVCDE3LGLTKAMBM2TTD3DOLTYBUNRXHLPEXX36X3L65O6O
static immutable ACE = KeyPair(PublicKey(Point([192, 34, 107, 88, 31, 167, 81, 12, 155, 89, 151, 53, 1, 129, 102, 167, 49, 236, 110, 92, 240, 26, 54, 55, 58, 222, 75, 223, 126, 190, 215, 238])), SecretKey(Scalar([37, 19, 188, 29, 43, 206, 121, 15, 169, 5, 6, 212, 186, 84, 40, 119, 17, 212, 59, 27, 100, 112, 85, 202, 205, 123, 204, 225, 84, 147, 46, 6])));
/// ACF: GDACF22GZEUP6VL4PW6UHYWAB3MIIN5A5N4BEAYXDSRWPXYHBKZGWEDC
static immutable ACF = KeyPair(PublicKey(Point([192, 34, 235, 70, 201, 40, 255, 85, 124, 125, 189, 67, 226, 192, 14, 216, 132, 55, 160, 235, 120, 18, 3, 23, 28, 163, 103, 223, 7, 10, 178, 107])), SecretKey(Scalar([57, 154, 221, 76, 37, 245, 107, 224, 155, 178, 253, 227, 89, 38, 108, 177, 243, 156, 252, 191, 103, 145, 38, 192, 159, 233, 97, 233, 137, 63, 207, 12])));
/// ACG: GDACG22QLLEY3MAJ26RLJHFVOM2GNARPUV2W7BFPBYGJK37ZJ2F3CDDA
static immutable ACG = KeyPair(PublicKey(Point([192, 35, 107, 80, 90, 201, 141, 176, 9, 215, 162, 180, 156, 181, 115, 52, 102, 130, 47, 165, 117, 111, 132, 175, 14, 12, 149, 111, 249, 78, 139, 177])), SecretKey(Scalar([107, 251, 6, 223, 9, 147, 255, 120, 93, 21, 156, 203, 245, 225, 188, 196, 125, 27, 30, 235, 86, 54, 15, 229, 9, 134, 246, 51, 158, 216, 155, 1])));
/// ACH: GDACH22BACASBBL6ILNHN2LIBBWGTP72LRTO5LI5CNQBDXN7SGOMCF4L
static immutable ACH = KeyPair(PublicKey(Point([192, 35, 235, 65, 0, 129, 32, 133, 126, 66, 218, 118, 233, 104, 8, 108, 105, 191, 250, 92, 102, 238, 173, 29, 19, 96, 17, 221, 191, 145, 156, 193])), SecretKey(Scalar([227, 202, 193, 38, 118, 238, 105, 115, 225, 18, 93, 76, 164, 24, 100, 243, 13, 54, 120, 150, 97, 120, 15, 160, 235, 156, 80, 137, 33, 221, 90, 12])));
/// ACI: GDACI22YSVNGW5GVSYVGMF7ALHNRV4SNPGBYEGAF2SWRWUJHFVOW5HD5
static immutable ACI = KeyPair(PublicKey(Point([192, 36, 107, 88, 149, 90, 107, 116, 213, 150, 42, 102, 23, 224, 89, 219, 26, 242, 77, 121, 131, 130, 24, 5, 212, 173, 27, 81, 39, 45, 93, 110])), SecretKey(Scalar([170, 250, 26, 47, 45, 35, 175, 53, 157, 225, 107, 244, 77, 153, 34, 58, 232, 18, 242, 133, 213, 190, 237, 167, 235, 203, 17, 156, 79, 106, 105, 11])));
/// ACJ: GDACJ22OXMOVJDBS7XH4AJQFIDZQGHRFBFJDFVQBFGEBGEHVQ4TKHP5F
static immutable ACJ = KeyPair(PublicKey(Point([192, 36, 235, 78, 187, 29, 84, 140, 50, 253, 207, 192, 38, 5, 64, 243, 3, 30, 37, 9, 82, 50, 214, 1, 41, 136, 19, 16, 245, 135, 38, 163])), SecretKey(Scalar([7, 51, 132, 102, 242, 238, 133, 147, 210, 178, 219, 129, 123, 191, 161, 80, 15, 252, 147, 0, 155, 31, 133, 77, 150, 66, 23, 90, 43, 7, 148, 14])));
/// ACK: GDACK22SW7MR3XWS4PKYPYID25RYVEJOXLEIDMNST4F6FXAK32NYP3GU
static immutable ACK = KeyPair(PublicKey(Point([192, 37, 107, 82, 183, 217, 29, 222, 210, 227, 213, 135, 225, 3, 215, 99, 138, 145, 46, 186, 200, 129, 177, 178, 159, 11, 226, 220, 10, 222, 155, 135])), SecretKey(Scalar([42, 60, 231, 235, 224, 98, 25, 219, 188, 244, 153, 20, 225, 139, 219, 116, 10, 19, 232, 13, 159, 89, 126, 243, 180, 207, 12, 85, 160, 220, 20, 0])));
/// ACL: GDACL22UYMRBACDPOTCBOVDPM6IM67YT4XYZRLOSG6XULUMUD67XJ6ED
static immutable ACL = KeyPair(PublicKey(Point([192, 37, 235, 84, 195, 34, 16, 8, 111, 116, 196, 23, 84, 111, 103, 144, 207, 127, 19, 229, 241, 152, 173, 210, 55, 175, 69, 209, 148, 31, 191, 116])), SecretKey(Scalar([118, 149, 127, 247, 165, 72, 132, 207, 135, 89, 47, 109, 102, 13, 227, 249, 242, 109, 116, 202, 193, 231, 124, 223, 205, 133, 35, 148, 105, 51, 174, 2])));
/// ACM: GDACM22SD2AAORP6YZT7NKGCO7LVRGWXJSVATYQ3ILOYP7Z6UJVJBHA5
static immutable ACM = KeyPair(PublicKey(Point([192, 38, 107, 82, 30, 128, 7, 69, 254, 198, 103, 246, 168, 194, 119, 215, 88, 154, 215, 76, 170, 9, 226, 27, 66, 221, 135, 255, 62, 162, 106, 144])), SecretKey(Scalar([140, 38, 118, 172, 253, 30, 121, 134, 28, 75, 98, 3, 86, 136, 234, 46, 89, 119, 91, 212, 42, 72, 127, 191, 159, 114, 255, 222, 88, 30, 247, 4])));
/// ACN: GDACN22ADK3B33ZCLABCIWQQTI7M2SBSXL4P2MUFRPOSCGOTDEJ5KXLD
static immutable ACN = KeyPair(PublicKey(Point([192, 38, 235, 64, 26, 182, 29, 239, 34, 88, 2, 36, 90, 16, 154, 62, 205, 72, 50, 186, 248, 253, 50, 133, 139, 221, 33, 25, 211, 25, 19, 213])), SecretKey(Scalar([171, 84, 59, 23, 213, 161, 107, 100, 125, 135, 4, 112, 108, 183, 97, 139, 142, 90, 194, 196, 121, 216, 22, 27, 38, 238, 70, 140, 81, 54, 99, 14])));
/// ACO: GDACO22KNXY45CLK4XG3RS5MYJCTIJ52FALQNDG3UEXXJBDUFFRIRE3Y
static immutable ACO = KeyPair(PublicKey(Point([192, 39, 107, 74, 109, 241, 206, 137, 106, 229, 205, 184, 203, 172, 194, 69, 52, 39, 186, 40, 23, 6, 140, 219, 161, 47, 116, 132, 116, 41, 98, 136])), SecretKey(Scalar([120, 6, 35, 88, 221, 239, 42, 234, 36, 234, 61, 154, 49, 195, 29, 196, 211, 134, 87, 129, 42, 202, 36, 67, 202, 69, 143, 137, 124, 30, 96, 9])));
/// ACP: GDACP22WFZRNFWWKIVLXG5FKTKETYXS6OALSSYSZGVK7CNFV7XLNGFG4
static immutable ACP = KeyPair(PublicKey(Point([192, 39, 235, 86, 46, 98, 210, 218, 202, 69, 87, 115, 116, 170, 154, 137, 60, 94, 94, 112, 23, 41, 98, 89, 53, 85, 241, 52, 181, 253, 214, 211])), SecretKey(Scalar([106, 25, 76, 252, 139, 20, 31, 113, 184, 59, 81, 193, 25, 52, 13, 117, 228, 23, 238, 0, 119, 245, 129, 88, 46, 29, 1, 235, 90, 46, 212, 3])));
/// ACQ: GDACQ22VPVCEEX5OMW52FJGMLMWRJSY3ZTRJBKX2IRHCO4ZP6MUAGMR5
static immutable ACQ = KeyPair(PublicKey(Point([192, 40, 107, 85, 125, 68, 66, 95, 174, 101, 187, 162, 164, 204, 91, 45, 20, 203, 27, 204, 226, 144, 170, 250, 68, 78, 39, 115, 47, 243, 40, 3])), SecretKey(Scalar([232, 124, 13, 182, 102, 9, 28, 102, 37, 49, 207, 223, 183, 193, 64, 207, 166, 170, 222, 107, 15, 120, 220, 87, 77, 245, 72, 97, 204, 114, 167, 8])));
/// ACR: GDACR22KZAL6XEPSND3UZI2FR43ZBUZDOYEXXCLWL3ES6NP2M5U2YFZV
static immutable ACR = KeyPair(PublicKey(Point([192, 40, 235, 74, 200, 23, 235, 145, 242, 104, 247, 76, 163, 69, 143, 55, 144, 211, 35, 118, 9, 123, 137, 118, 94, 201, 47, 53, 250, 103, 105, 172])), SecretKey(Scalar([115, 51, 103, 165, 103, 67, 244, 168, 51, 152, 53, 19, 145, 186, 251, 84, 126, 202, 250, 40, 204, 29, 254, 200, 149, 172, 122, 139, 173, 34, 52, 7])));
/// ACS: GDACS22HGVBSSFELKTIKBJMULO3X4IGJFLFSIMPUEFO4RYB222LX64IC
static immutable ACS = KeyPair(PublicKey(Point([192, 41, 107, 71, 53, 67, 41, 20, 139, 84, 208, 160, 165, 148, 91, 183, 126, 32, 201, 42, 203, 36, 49, 244, 33, 93, 200, 224, 58, 214, 151, 127])), SecretKey(Scalar([20, 3, 148, 213, 37, 48, 142, 19, 69, 130, 4, 141, 68, 60, 127, 7, 223, 78, 215, 108, 106, 155, 185, 156, 221, 112, 61, 236, 143, 104, 87, 12])));
/// ACT: GDACT22DCATIRI3EUNZGUBFAE53CYOW2WXTGEEYUNX7G5QQNAPA3LCFF
static immutable ACT = KeyPair(PublicKey(Point([192, 41, 235, 67, 16, 38, 136, 163, 100, 163, 114, 106, 4, 160, 39, 118, 44, 58, 218, 181, 230, 98, 19, 20, 109, 254, 110, 194, 13, 3, 193, 181])), SecretKey(Scalar([20, 25, 206, 39, 51, 188, 170, 69, 101, 65, 114, 136, 212, 67, 129, 45, 134, 212, 237, 179, 172, 211, 161, 59, 102, 78, 21, 114, 14, 59, 38, 7])));
/// ACU: GDACU22IEPD7AQYMNXZ2UCI4TMKJHWWDMHOA3YSZGRSERAESHYHQTSJD
static immutable ACU = KeyPair(PublicKey(Point([192, 42, 107, 72, 35, 199, 240, 67, 12, 109, 243, 170, 9, 28, 155, 20, 147, 218, 195, 97, 220, 13, 226, 89, 52, 100, 72, 128, 146, 62, 15, 9])), SecretKey(Scalar([66, 106, 180, 34, 148, 66, 217, 145, 143, 192, 133, 247, 19, 251, 73, 206, 205, 29, 203, 55, 147, 252, 228, 240, 27, 0, 172, 165, 58, 213, 215, 1])));
/// ACV: GDACV22K4CSQEPVV4Q4VY6IBZPK6PESFQQGH4W2HINRCMNNXPUGENXMG
static immutable ACV = KeyPair(PublicKey(Point([192, 42, 235, 74, 224, 165, 2, 62, 181, 228, 57, 92, 121, 1, 203, 213, 231, 146, 69, 132, 12, 126, 91, 71, 67, 98, 38, 53, 183, 125, 12, 70])), SecretKey(Scalar([104, 133, 52, 9, 239, 186, 164, 50, 67, 30, 140, 190, 198, 49, 207, 218, 160, 133, 156, 121, 80, 40, 250, 128, 163, 144, 253, 188, 220, 67, 195, 14])));
/// ACW: GDACW22U2MEYLQRVLIIF53DFXBULDSQSZ6XJMKRNVW4K4IHHSBQMBPRT
static immutable ACW = KeyPair(PublicKey(Point([192, 43, 107, 84, 211, 9, 133, 194, 53, 90, 16, 94, 236, 101, 184, 104, 177, 202, 18, 207, 174, 150, 42, 45, 173, 184, 174, 32, 231, 144, 96, 192])), SecretKey(Scalar([235, 137, 228, 116, 163, 109, 77, 21, 79, 68, 40, 211, 132, 29, 210, 195, 131, 218, 91, 151, 125, 118, 66, 26, 86, 135, 159, 212, 52, 66, 126, 5])));
/// ACX: GDACX22PBOUPOOHWAPU4FEWCB6IZA3E2WAKBUIVX2RNONPUXPY372XFG
static immutable ACX = KeyPair(PublicKey(Point([192, 43, 235, 79, 11, 168, 247, 56, 246, 3, 233, 194, 146, 194, 15, 145, 144, 108, 154, 176, 20, 26, 34, 183, 212, 90, 230, 190, 151, 126, 55, 253])), SecretKey(Scalar([128, 11, 7, 141, 205, 235, 231, 21, 21, 184, 137, 86, 19, 139, 80, 62, 74, 59, 123, 0, 125, 47, 176, 204, 54, 26, 154, 190, 32, 234, 58, 4])));
/// ACY: GDACY22RLLW4ZAFRF2EY72ELC5RTZ45Y6WEF2A2ODECNFM7GXT2RCC75
static immutable ACY = KeyPair(PublicKey(Point([192, 44, 107, 81, 90, 237, 204, 128, 177, 46, 137, 143, 232, 139, 23, 99, 60, 243, 184, 245, 136, 93, 3, 78, 25, 4, 210, 179, 230, 188, 245, 17])), SecretKey(Scalar([161, 65, 250, 126, 100, 33, 35, 41, 85, 207, 9, 96, 174, 176, 95, 59, 240, 155, 75, 238, 34, 99, 82, 176, 177, 142, 115, 135, 117, 249, 49, 1])));
/// ACZ: GDACZ22RMNWFVQLEUQV4H6DZBUWCAH6P4OLO6MZZNFYGHUZRTFE6XHJ2
static immutable ACZ = KeyPair(PublicKey(Point([192, 44, 235, 81, 99, 108, 90, 193, 100, 164, 43, 195, 248, 121, 13, 44, 32, 31, 207, 227, 150, 239, 51, 57, 105, 112, 99, 211, 49, 153, 73, 235])), SecretKey(Scalar([104, 129, 160, 228, 196, 137, 42, 88, 162, 230, 164, 206, 16, 67, 144, 64, 217, 230, 166, 246, 73, 122, 136, 87, 94, 57, 160, 255, 202, 54, 100, 11])));
/// ADA: GDADA22HB2YBIS3RKW6M7EJYD5CYEGCI5SKRCFOF44N37YUX7HMOHWQU
static immutable ADA = KeyPair(PublicKey(Point([192, 48, 107, 71, 14, 176, 20, 75, 113, 85, 188, 207, 145, 56, 31, 69, 130, 24, 72, 236, 149, 17, 21, 197, 231, 27, 191, 226, 151, 249, 216, 227])), SecretKey(Scalar([168, 60, 163, 111, 30, 178, 235, 108, 106, 40, 196, 54, 178, 222, 69, 139, 220, 96, 98, 166, 2, 230, 16, 160, 14, 255, 17, 170, 135, 22, 47, 10])));
/// ADB: GDADB22ZGSGXWQCRWUSFQKOG7LAPMYAQGYB6WEVHCJ5UDJCVFUV5UJWN
static immutable ADB = KeyPair(PublicKey(Point([192, 48, 235, 89, 52, 141, 123, 64, 81, 181, 36, 88, 41, 198, 250, 192, 246, 96, 16, 54, 3, 235, 18, 167, 18, 123, 65, 164, 85, 45, 43, 218])), SecretKey(Scalar([244, 117, 131, 69, 26, 14, 113, 181, 152, 1, 254, 235, 156, 226, 76, 46, 48, 208, 71, 11, 159, 200, 165, 58, 217, 54, 91, 27, 68, 66, 255, 14])));
/// ADC: GDADC22CRY42STR5E4UDGQDUC7L6Q7CUUX2K22B4FSBKITYFIWWXN3LO
static immutable ADC = KeyPair(PublicKey(Point([192, 49, 107, 66, 142, 57, 169, 78, 61, 39, 40, 51, 64, 116, 23, 215, 232, 124, 84, 165, 244, 173, 104, 60, 44, 130, 164, 79, 5, 69, 173, 118])), SecretKey(Scalar([215, 123, 56, 24, 137, 0, 135, 254, 13, 181, 77, 126, 84, 140, 52, 236, 225, 20, 180, 224, 108, 175, 229, 42, 204, 17, 160, 121, 21, 177, 73, 15])));
/// ADD: GDADD227IGAHPW7MOC7KDWTJOM3Q7SE7XR5H6JM7EFB5SOAKJ7J6KHGR
static immutable ADD = KeyPair(PublicKey(Point([192, 49, 235, 95, 65, 128, 119, 219, 236, 112, 190, 161, 218, 105, 115, 55, 15, 200, 159, 188, 122, 127, 37, 159, 33, 67, 217, 56, 10, 79, 211, 229])), SecretKey(Scalar([159, 167, 234, 171, 140, 190, 101, 178, 30, 86, 2, 158, 254, 79, 171, 76, 57, 71, 165, 18, 95, 125, 27, 131, 4, 110, 196, 33, 150, 123, 32, 11])));
/// ADE: GDADE22YIQGD3FTYTFHI5VAHXZOAJJQKYXOB45BWOZNJ4TRK4W6FNUBF
static immutable ADE = KeyPair(PublicKey(Point([192, 50, 107, 88, 68, 12, 61, 150, 120, 153, 78, 142, 212, 7, 190, 92, 4, 166, 10, 197, 220, 30, 116, 54, 118, 90, 158, 78, 42, 229, 188, 86])), SecretKey(Scalar([45, 108, 178, 115, 145, 179, 191, 192, 138, 140, 14, 118, 44, 36, 22, 179, 230, 126, 136, 193, 141, 222, 45, 9, 145, 198, 60, 120, 200, 82, 198, 6])));
/// ADF: GDADF22RRWNPHC3CCZOEHL6D5SKZYGB3J6DUZ6FKGHM27OVEBBUBTOAI
static immutable ADF = KeyPair(PublicKey(Point([192, 50, 235, 81, 141, 154, 243, 139, 98, 22, 92, 67, 175, 195, 236, 149, 156, 24, 59, 79, 135, 76, 248, 170, 49, 217, 175, 186, 164, 8, 104, 25])), SecretKey(Scalar([107, 203, 225, 70, 29, 142, 59, 211, 19, 162, 114, 242, 95, 18, 92, 214, 60, 193, 238, 120, 75, 51, 15, 164, 174, 240, 182, 173, 206, 107, 32, 3])));
/// ADG: GDADG22OHN4CZQDKL67Z25GGIHGVZGVNVSWHTLBQSENZ5S262ZNS3C3G
static immutable ADG = KeyPair(PublicKey(Point([192, 51, 107, 78, 59, 120, 44, 192, 106, 95, 191, 157, 116, 198, 65, 205, 92, 154, 173, 172, 172, 121, 172, 48, 145, 27, 158, 203, 94, 214, 91, 45])), SecretKey(Scalar([83, 178, 16, 127, 132, 59, 255, 39, 204, 194, 184, 67, 154, 143, 4, 11, 206, 12, 18, 212, 117, 238, 158, 187, 74, 99, 136, 183, 29, 177, 170, 9])));
/// ADH: GDADH226JWGV4RGHJCGEHIDKIW4RA52MVIRXSBOH3OMTE5R5GYRPIQH3
static immutable ADH = KeyPair(PublicKey(Point([192, 51, 235, 94, 77, 141, 94, 68, 199, 72, 140, 67, 160, 106, 69, 185, 16, 119, 76, 170, 35, 121, 5, 199, 219, 153, 50, 118, 61, 54, 34, 244])), SecretKey(Scalar([165, 229, 51, 234, 111, 252, 11, 99, 147, 176, 228, 47, 224, 217, 46, 14, 65, 230, 19, 184, 211, 55, 212, 183, 39, 48, 205, 5, 20, 17, 216, 3])));
/// ADI: GDADI22BW7E6YF3IRCDXWKSFAP5T5ZGC37T7V2MSHEOQKXI6QJBYEUMA
static immutable ADI = KeyPair(PublicKey(Point([192, 52, 107, 65, 183, 201, 236, 23, 104, 136, 135, 123, 42, 69, 3, 251, 62, 228, 194, 223, 231, 250, 233, 146, 57, 29, 5, 93, 30, 130, 67, 130])), SecretKey(Scalar([47, 253, 182, 3, 65, 96, 56, 131, 192, 118, 202, 224, 118, 190, 163, 191, 65, 30, 170, 49, 82, 105, 50, 48, 148, 45, 215, 106, 126, 113, 61, 5])));
/// ADJ: GDADJ22GV5AVH6WGYBRPAMBK5DVYTWIARCMALEZZXWQWDKOPT6T2SJTH
static immutable ADJ = KeyPair(PublicKey(Point([192, 52, 235, 70, 175, 65, 83, 250, 198, 192, 98, 240, 48, 42, 232, 235, 137, 217, 0, 136, 152, 5, 147, 57, 189, 161, 97, 169, 207, 159, 167, 169])), SecretKey(Scalar([12, 74, 62, 226, 114, 123, 204, 117, 180, 201, 47, 106, 28, 205, 230, 242, 106, 114, 164, 227, 2, 208, 37, 93, 15, 50, 223, 127, 136, 0, 139, 4])));
/// ADK: GDADK22OTHZORQKZ5FPGOEEAP63KDB3R3GF42QX6TDFMMEGRZZVVFKSX
static immutable ADK = KeyPair(PublicKey(Point([192, 53, 107, 78, 153, 242, 232, 193, 89, 233, 94, 103, 16, 128, 127, 182, 161, 135, 113, 217, 139, 205, 66, 254, 152, 202, 198, 16, 209, 206, 107, 82])), SecretKey(Scalar([189, 132, 240, 72, 76, 141, 179, 51, 154, 136, 86, 184, 166, 26, 36, 187, 14, 111, 86, 156, 54, 240, 33, 246, 221, 7, 242, 191, 23, 39, 14, 10])));
/// ADL: GDADL22YMWID3KPHIK3IA7ORDUC2UZWY7X5QKN2VQZAASURRSY63XTYY
static immutable ADL = KeyPair(PublicKey(Point([192, 53, 235, 88, 101, 144, 61, 169, 231, 66, 182, 128, 125, 209, 29, 5, 170, 102, 216, 253, 251, 5, 55, 85, 134, 64, 9, 82, 49, 150, 61, 187])), SecretKey(Scalar([134, 238, 106, 165, 252, 205, 34, 33, 67, 139, 166, 31, 153, 6, 170, 198, 255, 136, 152, 185, 53, 188, 255, 146, 233, 231, 12, 12, 214, 48, 196, 7])));
/// ADM: GDADM22Q2PHEM52KTDKCVIRK5QQZ4JX5GFRIG2WJMFBBMAHDQNGLJ7X7
static immutable ADM = KeyPair(PublicKey(Point([192, 54, 107, 80, 211, 206, 70, 119, 74, 152, 212, 42, 162, 42, 236, 33, 158, 38, 253, 49, 98, 131, 106, 201, 97, 66, 22, 0, 227, 131, 76, 180])), SecretKey(Scalar([13, 131, 84, 94, 141, 89, 250, 9, 39, 243, 168, 117, 130, 132, 143, 102, 170, 56, 243, 66, 238, 106, 10, 145, 80, 109, 189, 9, 25, 73, 50, 7])));
/// ADN: GDADN22JZYUWTAY6KOS6OKUMO5HRWQHG2YZ6GYZP7FC2AVMCDSBK7ZVC
static immutable ADN = KeyPair(PublicKey(Point([192, 54, 235, 73, 206, 41, 105, 131, 30, 83, 165, 231, 42, 140, 119, 79, 27, 64, 230, 214, 51, 227, 99, 47, 249, 69, 160, 85, 130, 28, 130, 175])), SecretKey(Scalar([75, 34, 113, 255, 7, 143, 88, 83, 166, 140, 32, 21, 151, 200, 64, 122, 231, 86, 251, 58, 177, 36, 215, 236, 7, 242, 209, 100, 147, 39, 138, 0])));
/// ADO: GDADO224Q5SFXUUN5F5ZKBIGWMAOAFA6U56GDQDKWUG3F3WTKKUDSZAF
static immutable ADO = KeyPair(PublicKey(Point([192, 55, 107, 92, 135, 100, 91, 210, 141, 233, 123, 149, 5, 6, 179, 0, 224, 20, 30, 167, 124, 97, 192, 106, 181, 13, 178, 238, 211, 82, 168, 57])), SecretKey(Scalar([97, 151, 59, 72, 118, 185, 119, 9, 212, 79, 41, 65, 212, 167, 189, 54, 224, 65, 216, 104, 45, 187, 76, 153, 158, 17, 40, 104, 148, 164, 19, 10])));
/// ADP: GDADP22LLY3XJFRH6GNM53QZAIMXMQA6Z2NE4ZLT6IYJNEQMU6ICTG2P
static immutable ADP = KeyPair(PublicKey(Point([192, 55, 235, 75, 94, 55, 116, 150, 39, 241, 154, 206, 238, 25, 2, 25, 118, 64, 30, 206, 154, 78, 101, 115, 242, 48, 150, 146, 12, 167, 144, 41])), SecretKey(Scalar([222, 22, 233, 151, 86, 137, 79, 144, 5, 227, 2, 183, 63, 115, 185, 232, 95, 229, 203, 65, 139, 3, 85, 228, 74, 3, 193, 221, 36, 34, 212, 14])));
/// ADQ: GDADQ22U77JHTOWIVNPNKY66XHTSDUF7N6H6RFSJOHHEQU5ZK4FBKLAT
static immutable ADQ = KeyPair(PublicKey(Point([192, 56, 107, 84, 255, 210, 121, 186, 200, 171, 94, 213, 99, 222, 185, 231, 33, 208, 191, 111, 143, 232, 150, 73, 113, 206, 72, 83, 185, 87, 10, 21])), SecretKey(Scalar([48, 126, 160, 117, 162, 145, 53, 147, 217, 194, 152, 178, 165, 6, 183, 132, 14, 137, 227, 157, 71, 60, 75, 153, 55, 8, 34, 65, 6, 110, 139, 8])));
/// ADR: GDADR22JJBZGQAP6UXBKIDO4FHC62AQP3BN7C3OBSXTCCTKUWJVYIEWA
static immutable ADR = KeyPair(PublicKey(Point([192, 56, 235, 73, 72, 114, 104, 1, 254, 165, 194, 164, 13, 220, 41, 197, 237, 2, 15, 216, 91, 241, 109, 193, 149, 230, 33, 77, 84, 178, 107, 132])), SecretKey(Scalar([203, 30, 76, 208, 53, 157, 70, 10, 72, 231, 107, 25, 38, 133, 112, 48, 89, 74, 253, 126, 112, 148, 137, 74, 177, 22, 71, 181, 87, 34, 196, 3])));
/// ADS: GDADS22FXBZO5KSSH4KVY2I3MALLSGRYJGDUSW6O5RLTNV7JQRFZFIYS
static immutable ADS = KeyPair(PublicKey(Point([192, 57, 107, 69, 184, 114, 238, 170, 82, 63, 21, 92, 105, 27, 96, 22, 185, 26, 56, 73, 135, 73, 91, 206, 236, 87, 54, 215, 233, 132, 75, 146])), SecretKey(Scalar([31, 94, 234, 75, 204, 133, 102, 12, 97, 19, 207, 148, 254, 93, 169, 198, 154, 173, 240, 20, 63, 253, 243, 184, 229, 176, 197, 171, 128, 48, 140, 0])));
/// ADT: GDADT22CVFGYUE3PAX23U7U6Q7ISRZHUZYXQPOZ6SRDIIS7AGMBYWEBX
static immutable ADT = KeyPair(PublicKey(Point([192, 57, 235, 66, 169, 77, 138, 19, 111, 5, 245, 186, 126, 158, 135, 209, 40, 228, 244, 206, 47, 7, 187, 62, 148, 70, 132, 75, 224, 51, 3, 139])), SecretKey(Scalar([37, 118, 143, 185, 178, 16, 249, 212, 81, 161, 194, 174, 204, 236, 88, 56, 25, 218, 121, 55, 74, 154, 179, 166, 114, 224, 145, 168, 87, 183, 204, 13])));
/// ADU: GDADU22Y5JZDRK7HWYQGUTIDLF2YQF2YMBDZPOXIE7BIJKK367FIVGJS
static immutable ADU = KeyPair(PublicKey(Point([192, 58, 107, 88, 234, 114, 56, 171, 231, 182, 32, 106, 77, 3, 89, 117, 136, 23, 88, 96, 71, 151, 186, 232, 39, 194, 132, 169, 91, 247, 202, 138])), SecretKey(Scalar([226, 141, 244, 217, 252, 77, 63, 101, 88, 242, 248, 189, 223, 56, 156, 32, 30, 86, 104, 134, 59, 182, 47, 93, 239, 190, 57, 9, 139, 177, 174, 9])));
/// ADV: GDADV22ZTKYKV2E2FHCXHJJW3DBAN7G42FPPDKAGCJDRRBYQYPNHEKZI
static immutable ADV = KeyPair(PublicKey(Point([192, 58, 235, 89, 154, 176, 170, 232, 154, 41, 197, 115, 165, 54, 216, 194, 6, 252, 220, 209, 94, 241, 168, 6, 18, 71, 24, 135, 16, 195, 218, 114])), SecretKey(Scalar([84, 67, 233, 77, 37, 169, 109, 194, 125, 106, 77, 157, 47, 178, 14, 214, 175, 189, 202, 85, 55, 231, 70, 142, 20, 109, 181, 230, 195, 221, 70, 9])));
/// ADW: GDADW22D4ZXROZEKCT5XYTY5BZNUEORVC43CXZKOXKMLVTF6ASVR643H
static immutable ADW = KeyPair(PublicKey(Point([192, 59, 107, 67, 230, 111, 23, 100, 138, 20, 251, 124, 79, 29, 14, 91, 66, 58, 53, 23, 54, 43, 229, 78, 186, 152, 186, 204, 190, 4, 171, 31])), SecretKey(Scalar([106, 42, 229, 28, 202, 124, 181, 68, 47, 248, 104, 232, 86, 112, 117, 3, 49, 255, 171, 27, 239, 244, 3, 33, 101, 170, 4, 152, 202, 205, 199, 12])));
/// ADX: GDADX22Y2CUX6UACOFSBJLIGLMK2ET7NLKNA7FZZV5OPTCI2F2SUZHMI
static immutable ADX = KeyPair(PublicKey(Point([192, 59, 235, 88, 208, 169, 127, 80, 2, 113, 100, 20, 173, 6, 91, 21, 162, 79, 237, 90, 154, 15, 151, 57, 175, 92, 249, 137, 26, 46, 165, 76])), SecretKey(Scalar([162, 168, 58, 73, 122, 134, 176, 24, 195, 28, 13, 86, 158, 198, 150, 135, 245, 197, 223, 50, 140, 105, 134, 81, 172, 216, 149, 72, 52, 222, 143, 6])));
/// ADY: GDADY22NVRNQUFABTD5N6RSXVYUUB5PXTLV62O5NMVF2SWNVLXMKLYUD
static immutable ADY = KeyPair(PublicKey(Point([192, 60, 107, 77, 172, 91, 10, 20, 1, 152, 250, 223, 70, 87, 174, 41, 64, 245, 247, 154, 235, 237, 59, 173, 101, 75, 169, 89, 181, 93, 216, 165])), SecretKey(Scalar([166, 64, 162, 215, 215, 168, 214, 27, 159, 85, 32, 226, 231, 140, 224, 174, 139, 97, 157, 57, 61, 143, 75, 254, 151, 48, 134, 83, 209, 227, 46, 14])));
/// ADZ: GDADZ22OXMGOILDHLKBJDACOSONXECD57MRVRYMD4XTF7PGNCSZW5Q44
static immutable ADZ = KeyPair(PublicKey(Point([192, 60, 235, 78, 187, 12, 228, 44, 103, 90, 130, 145, 128, 78, 147, 155, 114, 8, 125, 251, 35, 88, 225, 131, 229, 230, 95, 188, 205, 20, 179, 110])), SecretKey(Scalar([31, 163, 48, 5, 202, 165, 44, 249, 244, 72, 2, 221, 171, 245, 117, 75, 103, 218, 25, 181, 23, 82, 32, 192, 186, 68, 44, 96, 208, 247, 82, 9])));
/// AEA: GDAEA223DEEM3L7XNPSMD46BE47ZY5LGJXJQ7IVHQ6KQFLGZAYI4VXIS
static immutable AEA = KeyPair(PublicKey(Point([192, 64, 107, 91, 25, 8, 205, 175, 247, 107, 228, 193, 243, 193, 39, 63, 156, 117, 102, 77, 211, 15, 162, 167, 135, 149, 2, 172, 217, 6, 17, 202])), SecretKey(Scalar([142, 202, 153, 41, 214, 252, 23, 70, 182, 49, 10, 30, 116, 73, 43, 60, 175, 19, 167, 124, 107, 187, 240, 30, 29, 255, 188, 54, 132, 214, 144, 2])));
/// AEB: GDAEB22XVDT4EPDGTZVV56YYGA2T3O4DHDS55OXXIK2CKID6WARX27KB
static immutable AEB = KeyPair(PublicKey(Point([192, 64, 235, 87, 168, 231, 194, 60, 102, 158, 107, 94, 251, 24, 48, 53, 61, 187, 131, 56, 229, 222, 186, 247, 66, 180, 37, 32, 126, 176, 35, 125])), SecretKey(Scalar([144, 123, 150, 214, 230, 124, 9, 15, 242, 116, 29, 1, 159, 218, 103, 176, 190, 128, 83, 66, 79, 132, 93, 245, 226, 147, 234, 206, 113, 164, 209, 7])));
/// AEC: GDAEC222XMUJ43N7GLABI7AJS2Z76TVRJV4PSTDXFZXX5JOOZM4O7W5G
static immutable AEC = KeyPair(PublicKey(Point([192, 65, 107, 90, 187, 40, 158, 109, 191, 50, 192, 20, 124, 9, 150, 179, 255, 78, 177, 77, 120, 249, 76, 119, 46, 111, 126, 165, 206, 203, 56, 239])), SecretKey(Scalar([30, 115, 177, 189, 125, 138, 9, 8, 185, 130, 207, 143, 65, 242, 82, 0, 57, 71, 35, 252, 163, 254, 183, 157, 240, 209, 231, 6, 58, 73, 116, 8])));
/// AED: GDAED22A7M6XHOQKTOK74GCA5OFDRMMNHHQHWMVWZEVVQCGTN2YQ7UVZ
static immutable AED = KeyPair(PublicKey(Point([192, 65, 235, 64, 251, 61, 115, 186, 10, 155, 149, 254, 24, 64, 235, 138, 56, 177, 141, 57, 224, 123, 50, 182, 201, 43, 88, 8, 211, 110, 177, 15])), SecretKey(Scalar([140, 64, 76, 51, 36, 238, 149, 100, 103, 227, 105, 3, 121, 126, 237, 197, 5, 66, 21, 175, 179, 189, 246, 151, 94, 172, 88, 152, 170, 206, 125, 2])));
/// AEE: GDAEE224J5YT2D6M6BPEVCDFCUDLS4IP4SO44GBIO7TBJHPJQWEO5PU6
static immutable AEE = KeyPair(PublicKey(Point([192, 66, 107, 92, 79, 113, 61, 15, 204, 240, 94, 74, 136, 101, 21, 6, 185, 113, 15, 228, 157, 206, 24, 40, 119, 230, 20, 157, 233, 133, 136, 238])), SecretKey(Scalar([22, 43, 18, 248, 81, 83, 224, 145, 199, 115, 233, 47, 250, 13, 190, 135, 6, 114, 131, 8, 158, 40, 180, 186, 35, 20, 172, 244, 49, 8, 21, 2])));
/// AEF: GDAEF222OVCOWXCN6S5TTSQ7XSLG2ELT3E7ECH2CG3A2XFZTXUYMNBW4
static immutable AEF = KeyPair(PublicKey(Point([192, 66, 235, 90, 117, 68, 235, 92, 77, 244, 187, 57, 202, 31, 188, 150, 109, 17, 115, 217, 62, 65, 31, 66, 54, 193, 171, 151, 51, 189, 48, 198])), SecretKey(Scalar([6, 164, 167, 179, 232, 197, 30, 90, 251, 228, 135, 213, 103, 91, 150, 190, 201, 22, 68, 145, 242, 155, 98, 200, 158, 228, 147, 179, 69, 117, 149, 3])));
/// AEG: GDAEG22PBZALDYGNJNOFW2VEWA7G3VZCS2YCDP74AA2EXAO5U55WIQMX
static immutable AEG = KeyPair(PublicKey(Point([192, 67, 107, 79, 14, 64, 177, 224, 205, 75, 92, 91, 106, 164, 176, 62, 109, 215, 34, 150, 176, 33, 191, 252, 0, 52, 75, 129, 221, 167, 123, 100])), SecretKey(Scalar([16, 170, 228, 163, 243, 141, 247, 116, 14, 225, 115, 144, 112, 91, 255, 5, 105, 170, 207, 166, 45, 172, 67, 72, 77, 1, 238, 178, 71, 223, 247, 15])));
/// AEH: GDAEH22LMMJJPLDD6432H5IJJGYR6CRE73LJOU24PY3AICSF5UWM76XB
static immutable AEH = KeyPair(PublicKey(Point([192, 67, 235, 75, 99, 18, 151, 172, 99, 247, 55, 163, 245, 9, 73, 177, 31, 10, 36, 254, 214, 151, 83, 92, 126, 54, 4, 10, 69, 237, 44, 207])), SecretKey(Scalar([112, 53, 99, 248, 91, 51, 71, 72, 31, 222, 28, 251, 238, 105, 59, 238, 209, 48, 95, 206, 78, 81, 143, 128, 32, 30, 91, 54, 233, 168, 212, 15])));
/// AEI: GDAEI227TISQXU4JWSJWO3MF35TV4WBBWFFU3YN7GZYJIIWDDR2JBQFK
static immutable AEI = KeyPair(PublicKey(Point([192, 68, 107, 95, 154, 37, 11, 211, 137, 180, 147, 103, 109, 133, 223, 103, 94, 88, 33, 177, 75, 77, 225, 191, 54, 112, 148, 34, 195, 28, 116, 144])), SecretKey(Scalar([154, 20, 234, 25, 90, 133, 91, 191, 253, 251, 2, 218, 201, 230, 32, 5, 39, 131, 202, 164, 210, 164, 100, 87, 83, 145, 234, 138, 10, 94, 70, 2])));
/// AEJ: GDAEJ22YSKT7QN63O2VFKI3ZY754RTK2UUYWQOBXYAM2AR7GQ5JFWC5O
static immutable AEJ = KeyPair(PublicKey(Point([192, 68, 235, 88, 146, 167, 248, 55, 219, 118, 170, 85, 35, 121, 199, 251, 200, 205, 90, 165, 49, 104, 56, 55, 192, 25, 160, 71, 230, 135, 82, 91])), SecretKey(Scalar([218, 141, 158, 62, 1, 73, 60, 53, 56, 76, 41, 14, 91, 217, 32, 172, 96, 226, 53, 99, 162, 28, 26, 35, 251, 210, 74, 3, 58, 18, 58, 12])));
/// AEK: GDAEK22LAQAAWG6KZQFQZZF7QXLKDXP5KNSYBONTQOZUUPAXB4KAZPWS
static immutable AEK = KeyPair(PublicKey(Point([192, 69, 107, 75, 4, 0, 11, 27, 202, 204, 11, 12, 228, 191, 133, 214, 161, 221, 253, 83, 101, 128, 185, 179, 131, 179, 74, 60, 23, 15, 20, 12])), SecretKey(Scalar([20, 221, 120, 12, 59, 9, 245, 25, 190, 156, 208, 75, 94, 205, 61, 154, 108, 38, 201, 254, 82, 173, 189, 12, 140, 98, 63, 13, 184, 232, 88, 7])));
/// AEL: GDAEL22THWDGLA4W24TY4BBIURDQPEAAUCE6BPYYSCG2ZPDW2UDFVEDN
static immutable AEL = KeyPair(PublicKey(Point([192, 69, 235, 83, 61, 134, 101, 131, 150, 215, 39, 142, 4, 40, 164, 71, 7, 144, 0, 160, 137, 224, 191, 24, 144, 141, 172, 188, 118, 213, 6, 90])), SecretKey(Scalar([157, 22, 19, 129, 189, 106, 232, 218, 198, 92, 195, 91, 71, 15, 189, 43, 72, 216, 94, 151, 251, 124, 252, 230, 97, 121, 5, 44, 116, 186, 36, 1])));
/// AEM: GDAEM2227DLINMIVX7267DFXSGS5YVQPFUPAP7Y742TQZUG64E7PQULH
static immutable AEM = KeyPair(PublicKey(Point([192, 70, 107, 90, 248, 214, 134, 177, 21, 191, 245, 239, 140, 183, 145, 165, 220, 86, 15, 45, 30, 7, 255, 31, 230, 167, 12, 208, 222, 225, 62, 248])), SecretKey(Scalar([148, 9, 242, 177, 239, 244, 96, 195, 93, 72, 120, 35, 12, 91, 71, 113, 106, 183, 223, 159, 2, 119, 175, 190, 119, 195, 182, 201, 146, 242, 231, 8])));
/// AEN: GDAEN22DFATTAGSXP4NDA33AYSHH76OUQIOPLQTTJSCQU35ZHXCOYW6G
static immutable AEN = KeyPair(PublicKey(Point([192, 70, 235, 67, 40, 39, 48, 26, 87, 127, 26, 48, 111, 96, 196, 142, 127, 249, 212, 130, 28, 245, 194, 115, 76, 133, 10, 111, 185, 61, 196, 236])), SecretKey(Scalar([102, 134, 12, 225, 91, 255, 11, 20, 115, 99, 255, 41, 35, 40, 92, 247, 195, 205, 217, 221, 160, 20, 221, 249, 135, 185, 1, 170, 109, 163, 224, 5])));
/// AEO: GDAEO22JC43XFNUR42G7WIRBFHHD6JZHW3CVDCASHQAIL2JPD623NG42
static immutable AEO = KeyPair(PublicKey(Point([192, 71, 107, 73, 23, 55, 114, 182, 145, 230, 141, 251, 34, 33, 41, 206, 63, 39, 39, 182, 197, 81, 136, 18, 60, 0, 133, 233, 47, 31, 181, 182])), SecretKey(Scalar([207, 129, 164, 2, 45, 93, 216, 129, 110, 217, 64, 101, 223, 106, 202, 180, 152, 146, 71, 87, 252, 12, 200, 187, 65, 224, 227, 163, 214, 110, 203, 11])));
/// AEP: GDAEP22ROMMI6JRRB5YEOSEWWE35Q4B5Q6CPUR5W6GHVYH6D2VPKJSUH
static immutable AEP = KeyPair(PublicKey(Point([192, 71, 235, 81, 115, 24, 143, 38, 49, 15, 112, 71, 72, 150, 177, 55, 216, 112, 61, 135, 132, 250, 71, 182, 241, 143, 92, 31, 195, 213, 94, 164])), SecretKey(Scalar([178, 223, 191, 238, 28, 253, 197, 219, 245, 82, 159, 214, 146, 94, 136, 215, 152, 116, 27, 236, 177, 177, 200, 20, 250, 51, 71, 250, 0, 171, 43, 14])));
/// AEQ: GDAEQ22UHBGHJ3QISQSWKDRNBV5D5DLQ6HEW4EL3CWNLZQWJWVKWSD4Q
static immutable AEQ = KeyPair(PublicKey(Point([192, 72, 107, 84, 56, 76, 116, 238, 8, 148, 37, 101, 14, 45, 13, 122, 62, 141, 112, 241, 201, 110, 17, 123, 21, 154, 188, 194, 201, 181, 85, 105])), SecretKey(Scalar([24, 129, 90, 70, 74, 149, 155, 6, 36, 221, 1, 0, 6, 9, 250, 44, 149, 196, 227, 50, 93, 74, 157, 122, 17, 7, 129, 243, 122, 103, 225, 5])));
/// AER: GDAER22HE5E7V6MOH3H5MCD7X4QFPRQXXOIVOVOOSJK64WSQE7CQITZC
static immutable AER = KeyPair(PublicKey(Point([192, 72, 235, 71, 39, 73, 250, 249, 142, 62, 207, 214, 8, 127, 191, 32, 87, 198, 23, 187, 145, 87, 85, 206, 146, 85, 238, 90, 80, 39, 197, 4])), SecretKey(Scalar([148, 96, 194, 243, 64, 111, 182, 57, 70, 9, 226, 233, 162, 38, 165, 213, 122, 51, 232, 94, 30, 73, 219, 39, 43, 217, 194, 121, 39, 189, 22, 11])));
/// AES: GDAES22MFRCFBTKCK4RQ5STDS5MM5ACFKB42EHLVELZEL2CCCHL4HNHL
static immutable AES = KeyPair(PublicKey(Point([192, 73, 107, 76, 44, 68, 80, 205, 66, 87, 35, 14, 202, 99, 151, 88, 206, 128, 69, 80, 121, 162, 29, 117, 34, 242, 69, 232, 66, 17, 215, 195])), SecretKey(Scalar([243, 222, 236, 107, 10, 138, 74, 145, 131, 243, 107, 121, 210, 71, 67, 242, 202, 46, 155, 127, 235, 166, 77, 16, 75, 231, 200, 88, 152, 221, 67, 2])));
/// AET: GDAET22E5WCW4F4L4EIJ6D7SIZK26VIBM5ZNYMVQNANC5HQSTWYFXPNQ
static immutable AET = KeyPair(PublicKey(Point([192, 73, 235, 68, 237, 133, 110, 23, 139, 225, 16, 159, 15, 242, 70, 85, 175, 85, 1, 103, 114, 220, 50, 176, 104, 26, 46, 158, 18, 157, 176, 91])), SecretKey(Scalar([138, 218, 122, 101, 191, 169, 127, 88, 113, 15, 174, 187, 143, 150, 171, 83, 141, 194, 7, 61, 213, 212, 72, 70, 4, 227, 84, 26, 138, 53, 219, 0])));
/// AEU: GDAEU22AWJH2LT2XSLKHI47T5QWOYJ66BSLJN2BVWZCC62MVLR3ZWUEG
static immutable AEU = KeyPair(PublicKey(Point([192, 74, 107, 64, 178, 79, 165, 207, 87, 146, 212, 116, 115, 243, 236, 44, 236, 39, 222, 12, 150, 150, 232, 53, 182, 68, 47, 105, 149, 92, 119, 155])), SecretKey(Scalar([100, 139, 99, 134, 215, 25, 9, 166, 72, 13, 31, 211, 47, 116, 97, 48, 122, 33, 248, 156, 219, 89, 43, 18, 254, 99, 110, 151, 214, 159, 245, 15])));
/// AEV: GDAEV22627GR5TPZCGRXBVHS5HVLLHA4WFT3E77F7PQRZOWGTBPW455X
static immutable AEV = KeyPair(PublicKey(Point([192, 74, 235, 94, 215, 205, 30, 205, 249, 17, 163, 112, 212, 242, 233, 234, 181, 156, 28, 177, 103, 178, 127, 229, 251, 225, 28, 186, 198, 152, 95, 110])), SecretKey(Scalar([6, 109, 215, 197, 220, 118, 235, 239, 103, 142, 11, 84, 3, 239, 63, 163, 158, 177, 235, 247, 212, 6, 206, 45, 167, 184, 54, 119, 243, 55, 98, 12])));
/// AEW: GDAEW22RXI3DN7JOTMZX5TDSBSTAFPLVQ3FZB4PNDNLHB35EDSV6C2XJ
static immutable AEW = KeyPair(PublicKey(Point([192, 75, 107, 81, 186, 54, 54, 253, 46, 155, 51, 126, 204, 114, 12, 166, 2, 189, 117, 134, 203, 144, 241, 237, 27, 86, 112, 239, 164, 28, 171, 225])), SecretKey(Scalar([29, 46, 159, 13, 215, 98, 251, 83, 56, 98, 0, 58, 13, 163, 111, 232, 207, 26, 10, 215, 234, 25, 175, 55, 172, 125, 36, 18, 156, 182, 76, 1])));
/// AEX: GDAEX22DBVHOHN4YYVXNVCTMQCU72TBDIM67SO66QZ6A3DDD7UMV7Y2M
static immutable AEX = KeyPair(PublicKey(Point([192, 75, 235, 67, 13, 78, 227, 183, 152, 197, 110, 218, 138, 108, 128, 169, 253, 76, 35, 67, 61, 249, 59, 222, 134, 124, 13, 140, 99, 253, 25, 95])), SecretKey(Scalar([238, 6, 112, 198, 244, 171, 206, 192, 23, 64, 181, 155, 206, 216, 232, 224, 28, 146, 79, 209, 145, 180, 45, 114, 124, 215, 160, 138, 80, 183, 61, 9])));
/// AEY: GDAEY22AHBJ4HCATGB4FWC6IO6XWDUMZAU4UHC43ZENL2UX3FK4GVVS2
static immutable AEY = KeyPair(PublicKey(Point([192, 76, 107, 64, 56, 83, 195, 136, 19, 48, 120, 91, 11, 200, 119, 175, 97, 209, 153, 5, 57, 67, 139, 155, 201, 26, 189, 82, 251, 42, 184, 106])), SecretKey(Scalar([138, 219, 193, 94, 22, 94, 210, 63, 21, 245, 129, 254, 143, 52, 43, 126, 38, 232, 141, 81, 198, 248, 152, 128, 136, 175, 70, 121, 86, 51, 154, 10])));
/// AEZ: GDAEZ22YL7YPSBKSBFIK536EGNEDBE7ECVEM445FBDW7VJ2USGJR5GNO
static immutable AEZ = KeyPair(PublicKey(Point([192, 76, 235, 88, 95, 240, 249, 5, 82, 9, 80, 174, 239, 196, 51, 72, 48, 147, 228, 21, 72, 206, 115, 165, 8, 237, 250, 167, 84, 145, 147, 30])), SecretKey(Scalar([15, 186, 78, 198, 135, 94, 16, 220, 71, 67, 103, 94, 178, 57, 71, 41, 36, 115, 43, 224, 76, 144, 180, 169, 14, 44, 247, 152, 125, 90, 223, 7])));
/// AFA: GDAFA22JWOXDMS54P56AZRSLHCBMNPRB334LQ6HJNE5RIN54COVOZ7YB
static immutable AFA = KeyPair(PublicKey(Point([192, 80, 107, 73, 179, 174, 54, 75, 188, 127, 124, 12, 198, 75, 56, 130, 198, 190, 33, 222, 248, 184, 120, 233, 105, 59, 20, 55, 188, 19, 170, 236])), SecretKey(Scalar([13, 249, 125, 76, 45, 249, 245, 181, 77, 253, 60, 237, 227, 74, 173, 223, 41, 107, 82, 215, 131, 139, 188, 241, 90, 241, 217, 167, 172, 213, 175, 2])));
/// AFB: GDAFB22MGC6RES3SMWKERAXTHFBLMJXTQVGD6DRWQSCRK6XT4ARZCXYH
static immutable AFB = KeyPair(PublicKey(Point([192, 80, 235, 76, 48, 189, 18, 75, 114, 101, 148, 72, 130, 243, 57, 66, 182, 38, 243, 133, 76, 63, 14, 54, 132, 133, 21, 122, 243, 224, 35, 145])), SecretKey(Scalar([172, 156, 157, 31, 131, 14, 103, 156, 5, 161, 15, 77, 232, 213, 162, 238, 58, 125, 108, 137, 131, 154, 110, 45, 222, 140, 139, 233, 88, 84, 245, 7])));
/// AFC: GDAFC22WKOY2ECIUFHSFBHDY5GP6RX66LLC3Z37WTGMJ3E5LIPKRTVRX
static immutable AFC = KeyPair(PublicKey(Point([192, 81, 107, 86, 83, 177, 162, 9, 20, 41, 228, 80, 156, 120, 233, 159, 232, 223, 222, 90, 197, 188, 239, 246, 153, 152, 157, 147, 171, 67, 213, 25])), SecretKey(Scalar([179, 249, 228, 140, 190, 136, 176, 127, 37, 221, 160, 144, 239, 112, 152, 2, 129, 119, 137, 115, 119, 10, 96, 129, 242, 51, 42, 197, 0, 134, 212, 12])));
/// AFD: GDAFD22EMPQXZ5ZBEP4FE2CS5Q2V4323ILTIUOKY5CYB63EGIGTA5PSQ
static immutable AFD = KeyPair(PublicKey(Point([192, 81, 235, 68, 99, 225, 124, 247, 33, 35, 248, 82, 104, 82, 236, 53, 94, 111, 91, 66, 230, 138, 57, 88, 232, 176, 31, 108, 134, 65, 166, 14])), SecretKey(Scalar([198, 180, 246, 154, 151, 124, 143, 245, 222, 12, 30, 31, 141, 110, 154, 123, 247, 46, 83, 22, 157, 60, 151, 181, 113, 183, 198, 30, 26, 168, 247, 7])));
/// AFE: GDAFE226GDHFEWFLIFGPFHNDNNXVLUFX2PKWXMKVLOPVI52ADI2M67EU
static immutable AFE = KeyPair(PublicKey(Point([192, 82, 107, 94, 48, 206, 82, 88, 171, 65, 76, 242, 157, 163, 107, 111, 85, 208, 183, 211, 213, 107, 177, 85, 91, 159, 84, 119, 64, 26, 52, 207])), SecretKey(Scalar([224, 110, 136, 65, 185, 205, 242, 192, 84, 189, 123, 186, 38, 188, 135, 126, 139, 207, 127, 197, 45, 233, 4, 99, 183, 4, 131, 218, 1, 241, 54, 2])));
/// AFF: GDAFF2276YRNGGV2MPINCDM4H3UN7JD4JFSN3IVATBOYQN7KUTPLEA6J
static immutable AFF = KeyPair(PublicKey(Point([192, 82, 235, 95, 246, 34, 211, 26, 186, 99, 208, 209, 13, 156, 62, 232, 223, 164, 124, 73, 100, 221, 162, 160, 152, 93, 136, 55, 234, 164, 222, 178])), SecretKey(Scalar([28, 37, 53, 163, 90, 82, 79, 33, 26, 116, 138, 234, 17, 62, 97, 121, 61, 183, 135, 193, 134, 30, 134, 202, 6, 25, 62, 53, 83, 219, 184, 7])));
/// AFG: GDAFG22HKDOPLX257PVW2DGRXJYE4SLEIDHD77GYSJ6WLRYD5QGLIXFV
static immutable AFG = KeyPair(PublicKey(Point([192, 83, 107, 71, 80, 220, 245, 223, 93, 251, 235, 109, 12, 209, 186, 112, 78, 73, 100, 64, 206, 63, 252, 216, 146, 125, 101, 199, 3, 236, 12, 180])), SecretKey(Scalar([234, 163, 222, 33, 144, 215, 236, 86, 13, 164, 82, 249, 112, 239, 135, 149, 221, 21, 88, 214, 106, 243, 193, 201, 78, 72, 154, 164, 188, 147, 238, 0])));
/// AFH: GDAFH22BJRTR6WDTSMCMLLJQMZ7LYJGULYTFLXIVR64WKLBSWGOK7XSG
static immutable AFH = KeyPair(PublicKey(Point([192, 83, 235, 65, 76, 103, 31, 88, 115, 147, 4, 197, 173, 48, 102, 126, 188, 36, 212, 94, 38, 85, 221, 21, 143, 185, 101, 44, 50, 177, 156, 175])), SecretKey(Scalar([131, 186, 6, 132, 30, 230, 235, 147, 49, 183, 12, 151, 34, 89, 106, 235, 204, 251, 164, 254, 243, 32, 28, 113, 82, 96, 153, 115, 86, 15, 46, 10])));
/// AFI: GDAFI22354EUJOOVG5TFBDEJBVO6J65MOGQLTV662PIBLPDLT4S66HBD
static immutable AFI = KeyPair(PublicKey(Point([192, 84, 107, 91, 239, 9, 68, 185, 213, 55, 102, 80, 140, 137, 13, 93, 228, 251, 172, 113, 160, 185, 215, 222, 211, 208, 21, 188, 107, 159, 37, 239])), SecretKey(Scalar([225, 157, 100, 75, 101, 193, 30, 10, 87, 87, 57, 98, 93, 126, 254, 230, 125, 162, 87, 147, 23, 147, 213, 57, 231, 81, 17, 162, 13, 144, 61, 8])));
/// AFJ: GDAFJ22FCWAZNINH2YXEJNNAIDFG5UNBAJSUM6TAGHHOBZLTY2ZLB6ON
static immutable AFJ = KeyPair(PublicKey(Point([192, 84, 235, 69, 21, 129, 150, 161, 167, 214, 46, 68, 181, 160, 64, 202, 110, 209, 161, 2, 101, 70, 122, 96, 49, 206, 224, 229, 115, 198, 178, 176])), SecretKey(Scalar([126, 220, 88, 167, 113, 161, 76, 42, 21, 187, 15, 95, 186, 198, 18, 138, 42, 63, 81, 42, 112, 202, 36, 185, 135, 105, 185, 29, 185, 70, 222, 11])));
/// AFK: GDAFK22E27SGG4LCA4L6H2K4UQJ24OQH3XKQIT6MDO3KE5PURBWBJKYO
static immutable AFK = KeyPair(PublicKey(Point([192, 85, 107, 68, 215, 228, 99, 113, 98, 7, 23, 227, 233, 92, 164, 19, 174, 58, 7, 221, 213, 4, 79, 204, 27, 182, 162, 117, 244, 136, 108, 20])), SecretKey(Scalar([232, 243, 76, 203, 14, 117, 2, 191, 68, 154, 104, 7, 95, 78, 148, 11, 73, 252, 194, 104, 126, 197, 53, 240, 153, 157, 234, 169, 127, 147, 12, 1])));
/// AFL: GDAFL22GY6YU7JC2VM344XSP7FQXVH2FVRGH3VPJB54L425VV6VDGJ25
static immutable AFL = KeyPair(PublicKey(Point([192, 85, 235, 70, 199, 177, 79, 164, 90, 171, 55, 206, 94, 79, 249, 97, 122, 159, 69, 172, 76, 125, 213, 233, 15, 120, 190, 107, 181, 175, 170, 51])), SecretKey(Scalar([46, 168, 1, 196, 242, 193, 63, 123, 163, 213, 98, 209, 223, 156, 15, 178, 193, 132, 40, 220, 145, 177, 241, 250, 28, 47, 201, 223, 144, 212, 20, 2])));
/// AFM: GDAFM22FJMUA3PDEJC2USBPBOHU6GGFUGLZJXPS2LKEXUTKMBAKSZKUL
static immutable AFM = KeyPair(PublicKey(Point([192, 86, 107, 69, 75, 40, 13, 188, 100, 72, 181, 73, 5, 225, 113, 233, 227, 24, 180, 50, 242, 155, 190, 90, 90, 137, 122, 77, 76, 8, 21, 44])), SecretKey(Scalar([126, 192, 255, 21, 118, 179, 136, 187, 86, 194, 184, 158, 163, 194, 175, 143, 163, 236, 54, 155, 68, 94, 70, 219, 75, 58, 213, 9, 36, 187, 26, 0])));
/// AFN: GDAFN22JTT4CJ5HAHW7EI7YBCEAWLMTVDEEJ2NUJ7KLSIPALFCUH7SV7
static immutable AFN = KeyPair(PublicKey(Point([192, 86, 235, 73, 156, 248, 36, 244, 224, 61, 190, 68, 127, 1, 17, 1, 101, 178, 117, 25, 8, 157, 54, 137, 250, 151, 36, 60, 11, 40, 168, 127])), SecretKey(Scalar([119, 5, 51, 47, 1, 50, 239, 36, 122, 92, 177, 32, 87, 124, 15, 107, 83, 72, 135, 166, 199, 140, 217, 176, 143, 73, 185, 122, 171, 114, 86, 14])));
/// AFO: GDAFO22AMQ6AUOCQW6NXLZD4GIR72ZWFM4JKVPVBVLEQBNHTLAQLYQ57
static immutable AFO = KeyPair(PublicKey(Point([192, 87, 107, 64, 100, 60, 10, 56, 80, 183, 155, 117, 228, 124, 50, 35, 253, 102, 197, 103, 18, 170, 190, 161, 170, 201, 0, 180, 243, 88, 32, 188])), SecretKey(Scalar([110, 173, 220, 171, 240, 22, 161, 11, 89, 40, 50, 235, 165, 73, 203, 199, 210, 192, 223, 145, 149, 45, 4, 165, 72, 170, 99, 237, 238, 202, 28, 14])));
/// AFP: GDAFP22YDRHJE7BGLNUROAKQA47EYA3RBPYQ2WN3M65EZ5KGV3GUET3Q
static immutable AFP = KeyPair(PublicKey(Point([192, 87, 235, 88, 28, 78, 146, 124, 38, 91, 105, 23, 1, 80, 7, 62, 76, 3, 113, 11, 241, 13, 89, 187, 103, 186, 76, 245, 70, 174, 205, 66])), SecretKey(Scalar([159, 161, 60, 240, 85, 116, 165, 95, 125, 244, 149, 140, 143, 6, 6, 213, 201, 165, 25, 119, 123, 250, 66, 230, 122, 3, 96, 153, 28, 26, 222, 13])));
/// AFQ: GDAFQ22UHKPQ3SHFYXAW6PIRCWXMDMPQ7OTF5JJOTQAV5CFDKMEZYUGE
static immutable AFQ = KeyPair(PublicKey(Point([192, 88, 107, 84, 58, 159, 13, 200, 229, 197, 193, 111, 61, 17, 21, 174, 193, 177, 240, 251, 166, 94, 165, 46, 156, 1, 94, 136, 163, 83, 9, 156])), SecretKey(Scalar([169, 202, 191, 191, 39, 58, 139, 213, 202, 253, 189, 247, 227, 77, 61, 222, 101, 7, 137, 139, 53, 171, 169, 47, 184, 90, 95, 234, 32, 203, 217, 0])));
/// AFR: GDAFR22EUHHLJZPLNXQEWOOQTTG5ER3TKYCFABLZHDJQ2EF7K6IILTBE
static immutable AFR = KeyPair(PublicKey(Point([192, 88, 235, 68, 161, 206, 180, 229, 235, 109, 224, 75, 57, 208, 156, 205, 210, 71, 115, 86, 4, 80, 5, 121, 56, 211, 13, 16, 191, 87, 144, 133])), SecretKey(Scalar([206, 150, 14, 254, 74, 176, 109, 58, 25, 10, 80, 198, 51, 182, 253, 38, 211, 52, 230, 134, 224, 56, 236, 166, 32, 234, 86, 169, 136, 178, 120, 15])));
/// AFS: GDAFS22JFUS4IQACXVIFERM4KIQBAGPXV3H3DMTTRSU63ZBTX7AFLHDC
static immutable AFS = KeyPair(PublicKey(Point([192, 89, 107, 73, 45, 37, 196, 64, 2, 189, 80, 82, 69, 156, 82, 32, 16, 25, 247, 174, 207, 177, 178, 115, 140, 169, 237, 228, 51, 191, 192, 85])), SecretKey(Scalar([94, 193, 229, 241, 159, 34, 171, 76, 87, 201, 8, 99, 25, 147, 148, 70, 29, 181, 93, 82, 253, 121, 84, 32, 66, 35, 223, 196, 84, 237, 178, 14])));
/// AFT: GDAFT226OLQL2O64RZP5ODLR6JFLXNHOVLEMT42Y4QAWNL6M2CM5WT6J
static immutable AFT = KeyPair(PublicKey(Point([192, 89, 235, 94, 114, 224, 189, 59, 220, 142, 95, 215, 13, 113, 242, 74, 187, 180, 238, 170, 200, 201, 243, 88, 228, 1, 102, 175, 204, 208, 153, 219])), SecretKey(Scalar([192, 38, 82, 50, 2, 48, 151, 139, 0, 96, 42, 101, 177, 249, 65, 223, 187, 39, 2, 103, 80, 169, 126, 148, 22, 41, 87, 80, 215, 183, 201, 3])));
/// AFU: GDAFU22DFGDCSPXDCMGII6NOIZZVBICWWZPAS5X7VKIKWUWPLEEE7A6X
static immutable AFU = KeyPair(PublicKey(Point([192, 90, 107, 67, 41, 134, 41, 62, 227, 19, 12, 132, 121, 174, 70, 115, 80, 160, 86, 182, 94, 9, 118, 255, 170, 144, 171, 82, 207, 89, 8, 79])), SecretKey(Scalar([243, 124, 129, 10, 253, 158, 94, 73, 61, 157, 192, 61, 98, 179, 90, 19, 16, 78, 59, 5, 178, 160, 80, 179, 228, 49, 178, 176, 236, 152, 254, 3])));
/// AFV: GDAFV22Q6Y6XRYLE5KM2R7DQITFIHJRPFQYUHWYD4U62DHMEFSO7UL54
static immutable AFV = KeyPair(PublicKey(Point([192, 90, 235, 80, 246, 61, 120, 225, 100, 234, 153, 168, 252, 112, 68, 202, 131, 166, 47, 44, 49, 67, 219, 3, 229, 61, 161, 157, 132, 44, 157, 250])), SecretKey(Scalar([255, 36, 132, 230, 82, 202, 165, 8, 98, 155, 144, 29, 164, 148, 20, 44, 89, 130, 49, 77, 211, 70, 153, 47, 251, 22, 85, 64, 21, 81, 16, 0])));
/// AFW: GDAFW22CRYWE6PC3RE7LAWSUYPLLJOLNZHPTPXQFY4MCRSEF7P4EQENQ
static immutable AFW = KeyPair(PublicKey(Point([192, 91, 107, 66, 142, 44, 79, 60, 91, 137, 62, 176, 90, 84, 195, 214, 180, 185, 109, 201, 223, 55, 222, 5, 199, 24, 40, 200, 133, 251, 248, 72])), SecretKey(Scalar([219, 80, 255, 33, 192, 172, 82, 214, 188, 101, 45, 253, 40, 49, 37, 182, 152, 18, 201, 31, 76, 57, 213, 214, 104, 173, 29, 125, 75, 240, 59, 2])));
/// AFX: GDAFX22DGEIWOZ7WEUNQ266VDGZR2PYDRKSFTD6LIUQHCIJ5WGGRGA3X
static immutable AFX = KeyPair(PublicKey(Point([192, 91, 235, 67, 49, 17, 103, 103, 246, 37, 27, 13, 123, 213, 25, 179, 29, 63, 3, 138, 164, 89, 143, 203, 69, 32, 113, 33, 61, 177, 141, 19])), SecretKey(Scalar([76, 132, 125, 117, 59, 143, 72, 38, 32, 159, 159, 128, 254, 87, 55, 248, 177, 231, 17, 206, 182, 107, 233, 0, 139, 208, 67, 98, 65, 175, 92, 6])));
/// AFY: GDAFY22YNYRQ43AWO4DCFADCYKJYPAYGFOOSDXPEAYDDRJISGF5NHRSM
static immutable AFY = KeyPair(PublicKey(Point([192, 92, 107, 88, 110, 35, 14, 108, 22, 119, 6, 34, 128, 98, 194, 147, 135, 131, 6, 43, 157, 33, 221, 228, 6, 6, 56, 165, 18, 49, 122, 211])), SecretKey(Scalar([9, 255, 144, 150, 13, 221, 181, 63, 147, 186, 232, 70, 193, 226, 229, 68, 45, 77, 175, 143, 44, 74, 221, 177, 46, 224, 83, 51, 16, 19, 26, 9])));
/// AFZ: GDAFZ22OJHIELP37Q7UGEJVACFQ7A6W5HV377XL4FA4C5KMTPBKVTKC6
static immutable AFZ = KeyPair(PublicKey(Point([192, 92, 235, 78, 73, 208, 69, 191, 127, 135, 232, 98, 38, 160, 17, 97, 240, 122, 221, 61, 119, 255, 221, 124, 40, 56, 46, 169, 147, 120, 85, 89])), SecretKey(Scalar([1, 212, 129, 49, 95, 162, 77, 246, 80, 191, 25, 164, 234, 77, 253, 89, 103, 123, 224, 9, 38, 242, 250, 113, 248, 251, 68, 167, 199, 79, 63, 8])));
/// AGA: GDAGA22LJEJL6SFJ7HHZSVGDWOX3HA3QVMZUM5HQZ2VAGRMR6AF6TRN4
static immutable AGA = KeyPair(PublicKey(Point([192, 96, 107, 75, 73, 18, 191, 72, 169, 249, 207, 153, 84, 195, 179, 175, 179, 131, 112, 171, 51, 70, 116, 240, 206, 170, 3, 69, 145, 240, 11, 233])), SecretKey(Scalar([155, 87, 36, 244, 220, 239, 165, 47, 75, 228, 165, 46, 254, 78, 249, 155, 101, 156, 140, 136, 231, 98, 211, 5, 72, 36, 179, 80, 145, 164, 252, 8])));
/// AGB: GDAGB22PE3Y36XQX2SHECKRXLBOQK6Z5LRIHVM67QWT6NOMNMIJOUELT
static immutable AGB = KeyPair(PublicKey(Point([192, 96, 235, 79, 38, 241, 191, 94, 23, 212, 142, 65, 42, 55, 88, 93, 5, 123, 61, 92, 80, 122, 179, 223, 133, 167, 230, 185, 141, 98, 18, 234])), SecretKey(Scalar([131, 44, 68, 137, 234, 187, 44, 159, 171, 11, 5, 207, 133, 198, 61, 204, 187, 132, 110, 148, 39, 105, 129, 193, 241, 127, 110, 65, 58, 250, 117, 12])));
/// AGC: GDAGC22EJMEI336BGTRDARH3JPK4DFHW6TBIYFT5CX2374IGFROZQ6WL
static immutable AGC = KeyPair(PublicKey(Point([192, 97, 107, 68, 75, 8, 141, 239, 193, 52, 226, 48, 68, 251, 75, 213, 193, 148, 246, 244, 194, 140, 22, 125, 21, 245, 191, 241, 6, 44, 93, 152])), SecretKey(Scalar([107, 145, 158, 195, 142, 20, 68, 233, 15, 215, 157, 237, 25, 124, 18, 75, 71, 104, 108, 180, 17, 62, 29, 37, 150, 158, 125, 226, 25, 183, 125, 13])));
/// AGD: GDAGD22XPTOX5ULUULIFMQAGKJIIFP2WWGWAY3FR5QDBZ6US7CJD7G7L
static immutable AGD = KeyPair(PublicKey(Point([192, 97, 235, 87, 124, 221, 126, 209, 116, 162, 208, 86, 64, 6, 82, 80, 130, 191, 86, 177, 172, 12, 108, 177, 236, 6, 28, 250, 146, 248, 146, 63])), SecretKey(Scalar([5, 206, 65, 238, 209, 50, 41, 55, 118, 121, 202, 60, 242, 63, 195, 34, 93, 132, 214, 101, 248, 13, 94, 202, 109, 82, 0, 146, 170, 211, 205, 0])));
/// AGE: GDAGE22LNF25K4QI6HODLBQGHWVSR7TGL5Y7FQ2GCI77VK3TTS6VPSCK
static immutable AGE = KeyPair(PublicKey(Point([192, 98, 107, 75, 105, 117, 213, 114, 8, 241, 220, 53, 134, 6, 61, 171, 40, 254, 102, 95, 113, 242, 195, 70, 18, 63, 250, 171, 115, 156, 189, 87])), SecretKey(Scalar([61, 253, 49, 174, 48, 243, 187, 97, 123, 224, 230, 104, 230, 97, 215, 177, 223, 196, 221, 240, 172, 180, 42, 175, 154, 9, 23, 247, 149, 221, 89, 7])));
/// AGF: GDAGF22VPSPKKTQMTRFAA3Z6VPQZQT2LD3VP2VGGDIWLME67FOQUG4A2
static immutable AGF = KeyPair(PublicKey(Point([192, 98, 235, 85, 124, 158, 165, 78, 12, 156, 74, 0, 111, 62, 171, 225, 152, 79, 75, 30, 234, 253, 84, 198, 26, 44, 182, 19, 223, 43, 161, 67])), SecretKey(Scalar([122, 139, 186, 48, 67, 232, 190, 196, 243, 221, 165, 5, 125, 230, 217, 74, 13, 88, 81, 182, 18, 220, 180, 8, 60, 210, 64, 109, 64, 121, 80, 2])));
/// AGG: GDAGG22BQCBWLUKPOUSM7MUK24DNBZFKZGH4HLGE32BEK6L5RPUPAXLY
static immutable AGG = KeyPair(PublicKey(Point([192, 99, 107, 65, 128, 131, 101, 209, 79, 117, 36, 207, 178, 138, 215, 6, 208, 228, 170, 201, 143, 195, 172, 196, 222, 130, 69, 121, 125, 139, 232, 240])), SecretKey(Scalar([219, 206, 185, 103, 199, 255, 200, 251, 105, 63, 11, 193, 81, 99, 198, 25, 185, 46, 154, 235, 115, 0, 102, 139, 204, 1, 241, 48, 158, 0, 28, 1])));
/// AGH: GDAGH22QMO3H3WPCLG7KLD4FZ55IXI3K2XSMUGK4G3XE2TX4VFIMNOVD
static immutable AGH = KeyPair(PublicKey(Point([192, 99, 235, 80, 99, 182, 125, 217, 226, 89, 190, 165, 143, 133, 207, 122, 139, 163, 106, 213, 228, 202, 25, 92, 54, 238, 77, 78, 252, 169, 80, 198])), SecretKey(Scalar([250, 252, 220, 156, 37, 153, 199, 244, 227, 89, 74, 134, 112, 225, 76, 37, 160, 25, 68, 72, 150, 186, 244, 4, 235, 35, 226, 60, 202, 171, 64, 6])));
/// AGI: GDAGI227RDTLBLERX53H32BRPIIXA46QS4DA6BU5C74DIFGYZKWQZFIN
static immutable AGI = KeyPair(PublicKey(Point([192, 100, 107, 95, 136, 230, 176, 172, 145, 191, 118, 125, 232, 49, 122, 17, 112, 115, 208, 151, 6, 15, 6, 157, 23, 248, 52, 20, 216, 202, 173, 12])), SecretKey(Scalar([15, 104, 115, 176, 163, 47, 108, 57, 157, 216, 201, 0, 98, 82, 118, 38, 7, 94, 117, 213, 224, 142, 198, 70, 198, 207, 24, 94, 174, 49, 39, 1])));
/// AGJ: GDAGJ22K7CE5APRSOXFROTKCXXKFG2PYV2EF32RSD2RRKJTAWPNS4UAN
static immutable AGJ = KeyPair(PublicKey(Point([192, 100, 235, 74, 248, 137, 208, 62, 50, 117, 203, 23, 77, 66, 189, 212, 83, 105, 248, 174, 136, 93, 234, 50, 30, 163, 21, 38, 96, 179, 219, 46])), SecretKey(Scalar([50, 20, 155, 124, 144, 137, 242, 35, 214, 94, 100, 244, 236, 191, 101, 131, 163, 220, 195, 195, 95, 220, 66, 31, 141, 245, 108, 183, 63, 13, 248, 0])));
/// AGK: GDAGK22C5IJIIR356UDEDUMDDEZHSTPDH6IFO4AGHDTMGGO4LUC2ZJUN
static immutable AGK = KeyPair(PublicKey(Point([192, 101, 107, 66, 234, 18, 132, 71, 125, 245, 6, 65, 209, 131, 25, 50, 121, 77, 227, 63, 144, 87, 112, 6, 56, 230, 195, 25, 220, 93, 5, 172])), SecretKey(Scalar([8, 5, 255, 214, 75, 97, 21, 92, 163, 37, 203, 155, 229, 212, 14, 102, 181, 147, 164, 162, 248, 49, 198, 105, 226, 166, 135, 213, 119, 118, 255, 15])));
/// AGL: GDAGL22KBHAALAS46FHCDJYFS37HFC3OV2PYUXWQEKBCBRWUOE7XPJGB
static immutable AGL = KeyPair(PublicKey(Point([192, 101, 235, 74, 9, 192, 5, 130, 92, 241, 78, 33, 167, 5, 150, 254, 114, 139, 110, 174, 159, 138, 94, 208, 34, 130, 32, 198, 212, 113, 63, 119])), SecretKey(Scalar([144, 167, 186, 154, 147, 60, 148, 5, 12, 244, 1, 47, 164, 77, 120, 33, 159, 57, 93, 181, 186, 179, 175, 217, 126, 112, 207, 60, 221, 25, 189, 5])));
/// AGM: GDAGM22J2NDH7LYP46ZMN2XIIBHTFRIKNGSAL3TH5RV2SSF6DAHHEFVQ
static immutable AGM = KeyPair(PublicKey(Point([192, 102, 107, 73, 211, 70, 127, 175, 15, 231, 178, 198, 234, 232, 64, 79, 50, 197, 10, 105, 164, 5, 238, 103, 236, 107, 169, 72, 190, 24, 14, 114])), SecretKey(Scalar([202, 115, 105, 182, 102, 0, 175, 144, 142, 33, 66, 66, 215, 3, 149, 235, 252, 19, 67, 52, 68, 9, 242, 136, 239, 116, 95, 106, 217, 176, 62, 1])));
/// AGN: GDAGN22UO7X2R2F6JVUXAH23SWMLMWDKN6UFFJUXWRH77NATW7B5BXHV
static immutable AGN = KeyPair(PublicKey(Point([192, 102, 235, 84, 119, 239, 168, 232, 190, 77, 105, 112, 31, 91, 149, 152, 182, 88, 106, 111, 168, 82, 166, 151, 180, 79, 255, 180, 19, 183, 195, 208])), SecretKey(Scalar([211, 191, 220, 141, 209, 222, 14, 118, 199, 211, 65, 199, 193, 210, 225, 41, 10, 89, 104, 125, 147, 38, 4, 75, 86, 131, 18, 254, 245, 172, 9, 0])));
/// AGO: GDAGO2276TKALHSGWCZZBDYXQC4J6YWPUIVND7OQ66NGLJ57ZHYCS47A
static immutable AGO = KeyPair(PublicKey(Point([192, 103, 107, 95, 244, 212, 5, 158, 70, 176, 179, 144, 143, 23, 128, 184, 159, 98, 207, 162, 42, 209, 253, 208, 247, 154, 101, 167, 191, 201, 240, 41])), SecretKey(Scalar([14, 17, 170, 45, 134, 228, 113, 2, 72, 72, 215, 201, 70, 112, 255, 168, 11, 173, 23, 161, 188, 130, 214, 248, 208, 118, 70, 242, 117, 91, 234, 10])));
/// AGP: GDAGP226YZKLQBUXZXRWYDDCOINJPJIRZ4ADIP2I75LMRTSRCWE7RRZX
static immutable AGP = KeyPair(PublicKey(Point([192, 103, 235, 94, 198, 84, 184, 6, 151, 205, 227, 108, 12, 98, 114, 26, 151, 165, 17, 207, 0, 52, 63, 72, 255, 86, 200, 206, 81, 21, 137, 248])), SecretKey(Scalar([141, 71, 233, 214, 83, 90, 191, 130, 138, 157, 251, 52, 30, 72, 110, 122, 168, 121, 131, 17, 48, 93, 83, 44, 239, 117, 80, 212, 196, 96, 48, 9])));
/// AGQ: GDAGQ22ZL2IS4JGWAHTH36ENQXXET3VXICNBMQDSCDPTBKRYWEMKLJ7S
static immutable AGQ = KeyPair(PublicKey(Point([192, 104, 107, 89, 94, 145, 46, 36, 214, 1, 230, 125, 248, 141, 133, 238, 73, 238, 183, 64, 154, 22, 64, 114, 16, 223, 48, 170, 56, 177, 24, 165])), SecretKey(Scalar([218, 86, 177, 3, 131, 182, 35, 115, 223, 115, 60, 10, 231, 130, 157, 228, 77, 128, 34, 70, 217, 134, 122, 137, 255, 81, 200, 211, 20, 98, 120, 12])));
/// AGR: GDAGR22ETHGWLCXLQSHRISPTTSRUYMH7DW6GXQCSPNJZ375Y43I4SUIK
static immutable AGR = KeyPair(PublicKey(Point([192, 104, 235, 68, 153, 205, 101, 138, 235, 132, 143, 20, 73, 243, 156, 163, 76, 48, 255, 29, 188, 107, 192, 82, 123, 83, 157, 255, 184, 230, 209, 201])), SecretKey(Scalar([86, 208, 161, 19, 221, 91, 118, 233, 208, 219, 42, 134, 62, 145, 12, 169, 133, 77, 106, 66, 85, 33, 162, 37, 25, 17, 178, 153, 46, 7, 93, 11])));
/// AGS: GDAGS222VFDKCT2MIFAHPJVSZHTKUHMUSE55LRFNYDZSAOPQSAL47WFD
static immutable AGS = KeyPair(PublicKey(Point([192, 105, 107, 90, 169, 70, 161, 79, 76, 65, 64, 119, 166, 178, 201, 230, 170, 29, 148, 145, 59, 213, 196, 173, 192, 243, 32, 57, 240, 144, 23, 207])), SecretKey(Scalar([84, 96, 227, 226, 149, 143, 16, 85, 194, 124, 87, 211, 4, 219, 97, 160, 55, 225, 159, 45, 213, 240, 103, 230, 202, 189, 150, 213, 42, 232, 157, 12])));
/// AGT: GDAGT22SYPYIJY3SJ3MENXA7IWM25YKJA4FXMN3SUFIT6TMX2HPPGVJP
static immutable AGT = KeyPair(PublicKey(Point([192, 105, 235, 82, 195, 240, 132, 227, 114, 78, 216, 70, 220, 31, 69, 153, 174, 225, 73, 7, 11, 118, 55, 114, 161, 81, 63, 77, 151, 209, 222, 243])), SecretKey(Scalar([222, 66, 56, 157, 221, 210, 34, 220, 191, 85, 21, 127, 111, 59, 159, 185, 250, 143, 7, 253, 40, 222, 66, 106, 101, 21, 83, 235, 11, 128, 77, 10])));
/// AGU: GDAGU22HDXG6ONVGYYFDAEOHD3WNRVCW7A5BOO7262NIY2WH6WZ53DB7
static immutable AGU = KeyPair(PublicKey(Point([192, 106, 107, 71, 29, 205, 231, 54, 166, 198, 10, 48, 17, 199, 30, 236, 216, 212, 86, 248, 58, 23, 59, 250, 246, 154, 140, 106, 199, 245, 179, 221])), SecretKey(Scalar([27, 192, 2, 42, 162, 40, 65, 0, 36, 11, 7, 228, 111, 222, 211, 123, 177, 204, 129, 83, 120, 26, 53, 121, 213, 33, 11, 190, 18, 54, 159, 7])));
/// AGV: GDAGV22L3B564NENZKF7AUIUFKY562LAHZD7ETNKFHWD25QE4AOBDT57
static immutable AGV = KeyPair(PublicKey(Point([192, 106, 235, 75, 216, 123, 238, 52, 141, 202, 139, 240, 81, 20, 42, 177, 223, 105, 96, 62, 71, 242, 77, 170, 41, 236, 61, 118, 4, 224, 28, 17])), SecretKey(Scalar([69, 133, 92, 99, 238, 255, 253, 158, 73, 121, 216, 124, 7, 247, 249, 240, 147, 27, 224, 104, 92, 169, 173, 68, 76, 254, 168, 6, 244, 119, 106, 1])));
/// AGW: GDAGW22HPUXMHOTDFWIELRVHF2B3E4LILAONYT4J2SJLV54V5QU3UVUN
static immutable AGW = KeyPair(PublicKey(Point([192, 107, 107, 71, 125, 46, 195, 186, 99, 45, 144, 69, 198, 167, 46, 131, 178, 113, 104, 88, 28, 220, 79, 137, 212, 146, 186, 247, 149, 236, 41, 186])), SecretKey(Scalar([198, 172, 239, 169, 101, 150, 99, 177, 41, 150, 158, 42, 55, 45, 145, 17, 244, 160, 210, 85, 152, 208, 180, 219, 78, 69, 172, 106, 25, 107, 103, 0])));
/// AGX: GDAGX22L67NXA46DHXJLY3IKT7AQEW5TDBQRUAONOXL7IZNB3YDT7AG3
static immutable AGX = KeyPair(PublicKey(Point([192, 107, 235, 75, 247, 219, 112, 115, 195, 61, 210, 188, 109, 10, 159, 193, 2, 91, 179, 24, 97, 26, 1, 205, 117, 215, 244, 101, 161, 222, 7, 63])), SecretKey(Scalar([51, 234, 79, 72, 103, 63, 97, 213, 68, 94, 126, 91, 206, 112, 144, 59, 128, 193, 199, 37, 178, 27, 216, 22, 197, 87, 113, 183, 234, 117, 52, 1])));
/// AGY: GDAGY227QLVX65KRBK764VTDLZHRF526ZIHWLPHCSHZADFVTWFMPGYXI
static immutable AGY = KeyPair(PublicKey(Point([192, 108, 107, 95, 130, 235, 127, 117, 81, 10, 191, 238, 86, 99, 94, 79, 18, 247, 94, 202, 15, 101, 188, 226, 145, 242, 1, 150, 179, 177, 88, 243])), SecretKey(Scalar([158, 51, 63, 195, 167, 233, 196, 215, 221, 24, 191, 107, 14, 213, 161, 135, 50, 220, 189, 60, 225, 246, 97, 13, 25, 135, 60, 194, 117, 165, 113, 0])));
/// AGZ: GDAGZ22WX3AIK6TE7SVX3C53UBWNSGT553VTXZBWBXVJZ6VXARZRDPBW
static immutable AGZ = KeyPair(PublicKey(Point([192, 108, 235, 86, 190, 192, 133, 122, 100, 252, 171, 125, 139, 187, 160, 108, 217, 26, 125, 238, 235, 59, 228, 54, 13, 234, 156, 250, 183, 4, 115, 17])), SecretKey(Scalar([249, 62, 165, 41, 249, 23, 1, 112, 227, 73, 109, 152, 194, 149, 21, 194, 102, 155, 154, 146, 170, 198, 139, 74, 51, 90, 40, 59, 114, 23, 95, 3])));
/// AHA: GDAHA22XND76VB35LQV3GR7IRNYSQY6LNBPFXILMFZWK5OKVLYFKMQEK
static immutable AHA = KeyPair(PublicKey(Point([192, 112, 107, 87, 104, 255, 234, 135, 125, 92, 43, 179, 71, 232, 139, 113, 40, 99, 203, 104, 94, 91, 161, 108, 46, 108, 174, 185, 85, 94, 10, 166])), SecretKey(Scalar([36, 195, 226, 55, 22, 62, 27, 211, 37, 109, 178, 176, 29, 185, 49, 119, 166, 75, 181, 182, 32, 6, 37, 59, 19, 177, 214, 18, 168, 108, 211, 5])));
/// AHB: GDAHB22XAHEROME3DFGR3D4DIJX6KTPHHSBQRYZT76WQRR5E3U2NGEYM
static immutable AHB = KeyPair(PublicKey(Point([192, 112, 235, 87, 1, 201, 23, 48, 155, 25, 77, 29, 143, 131, 66, 111, 229, 77, 231, 60, 131, 8, 227, 51, 255, 173, 8, 199, 164, 221, 52, 211])), SecretKey(Scalar([128, 61, 40, 223, 254, 144, 139, 235, 79, 96, 39, 48, 189, 251, 230, 54, 161, 121, 92, 226, 58, 155, 153, 33, 115, 238, 8, 37, 230, 20, 141, 3])));
/// AHC: GDAHC22VGSTN3DTKRSJFLSWS67O6MTYSHX7QC77KVEAWJV62VGKYTXZE
static immutable AHC = KeyPair(PublicKey(Point([192, 113, 107, 85, 52, 166, 221, 142, 106, 140, 146, 85, 202, 210, 247, 221, 230, 79, 18, 61, 255, 1, 127, 234, 169, 1, 100, 215, 218, 169, 149, 137])), SecretKey(Scalar([57, 49, 153, 27, 248, 219, 241, 52, 13, 177, 42, 172, 63, 159, 7, 150, 123, 169, 66, 222, 23, 240, 164, 48, 29, 114, 102, 65, 125, 74, 19, 12])));
/// AHD: GDAHD22WJU2WPTOOTE4KS5IXQJAHZZ6ADHY6A2VUDXT74OBLVNET255H
static immutable AHD = KeyPair(PublicKey(Point([192, 113, 235, 86, 77, 53, 103, 205, 206, 153, 56, 169, 117, 23, 130, 64, 124, 231, 192, 25, 241, 224, 106, 180, 29, 231, 254, 56, 43, 171, 73, 61])), SecretKey(Scalar([242, 32, 82, 153, 92, 100, 120, 110, 2, 215, 222, 46, 192, 206, 15, 150, 55, 164, 161, 46, 247, 231, 84, 241, 12, 26, 246, 248, 87, 29, 168, 11])));
/// AHE: GDAHE22Q7B3NQOOCR6PMSSCOJHX2MPNGAIBSOWO5YE2ARBFJJJFNUMN4
static immutable AHE = KeyPair(PublicKey(Point([192, 114, 107, 80, 248, 118, 216, 57, 194, 143, 158, 201, 72, 78, 73, 239, 166, 61, 166, 2, 3, 39, 89, 221, 193, 52, 8, 132, 169, 74, 74, 218])), SecretKey(Scalar([33, 17, 71, 254, 63, 12, 96, 79, 82, 31, 136, 244, 110, 119, 96, 42, 159, 96, 133, 245, 194, 253, 73, 146, 66, 190, 73, 29, 105, 148, 103, 1])));
/// AHF: GDAHF223BDFGPKLNKYZBDMSZ5K7XM7Y7RQ7NUPHDYIUVSDYY7BYPXQHS
static immutable AHF = KeyPair(PublicKey(Point([192, 114, 235, 91, 8, 202, 103, 169, 109, 86, 50, 17, 178, 89, 234, 191, 118, 127, 31, 140, 62, 218, 60, 227, 194, 41, 89, 15, 24, 248, 112, 251])), SecretKey(Scalar([250, 63, 178, 57, 195, 197, 234, 83, 85, 70, 17, 42, 208, 160, 160, 154, 165, 161, 18, 217, 161, 68, 155, 168, 254, 80, 24, 208, 175, 85, 141, 5])));
/// AHG: GDAHG22OP3YRYNG4763HP4CMIA23SNA3CALMGFC7B6XOFOI5HF2TXLBP
static immutable AHG = KeyPair(PublicKey(Point([192, 115, 107, 78, 126, 241, 28, 52, 220, 255, 182, 119, 240, 76, 64, 53, 185, 52, 27, 16, 22, 195, 20, 95, 15, 174, 226, 185, 29, 57, 117, 59])), SecretKey(Scalar([161, 187, 65, 197, 172, 186, 46, 231, 134, 191, 159, 27, 240, 64, 68, 167, 125, 52, 25, 108, 127, 91, 194, 85, 132, 132, 235, 214, 102, 201, 61, 9])));
/// AHH: GDAHH22QX5LRIZTCCREH54JWKI3WV7CCC5QKHC5PMUQ2S7JBMAZM4WJ5
static immutable AHH = KeyPair(PublicKey(Point([192, 115, 235, 80, 191, 87, 20, 102, 98, 20, 72, 126, 241, 54, 82, 55, 106, 252, 66, 23, 96, 163, 139, 175, 101, 33, 169, 125, 33, 96, 50, 206])), SecretKey(Scalar([76, 162, 12, 245, 115, 199, 126, 54, 78, 231, 22, 89, 82, 182, 174, 111, 208, 152, 50, 198, 82, 37, 14, 162, 23, 161, 145, 153, 170, 51, 250, 0])));
/// AHI: GDAHI22GIN2KYK53WKAKRO7XNNU2UWGBC5N363TNX2O45ED4VXXMVK3J
static immutable AHI = KeyPair(PublicKey(Point([192, 116, 107, 70, 67, 116, 172, 43, 187, 178, 128, 168, 187, 247, 107, 105, 170, 88, 193, 23, 91, 191, 110, 109, 190, 157, 206, 144, 124, 173, 238, 202])), SecretKey(Scalar([208, 189, 205, 210, 157, 149, 64, 74, 35, 0, 49, 184, 235, 68, 178, 210, 173, 254, 104, 187, 105, 55, 110, 209, 200, 126, 92, 252, 100, 243, 142, 5])));
/// AHJ: GDAHJ22HZGHK337GF53XI6NLNSRYRNFYRP33CEF5NGLTAZWIGYGJWTAX
static immutable AHJ = KeyPair(PublicKey(Point([192, 116, 235, 71, 201, 142, 173, 239, 230, 47, 119, 116, 121, 171, 108, 163, 136, 180, 184, 139, 247, 177, 16, 189, 105, 151, 48, 102, 200, 54, 12, 155])), SecretKey(Scalar([32, 36, 176, 177, 77, 52, 235, 81, 201, 144, 88, 229, 221, 239, 252, 157, 124, 168, 33, 118, 29, 3, 179, 36, 152, 211, 53, 90, 63, 3, 5, 0])));
/// AHK: GDAHK22RFGSQX5C4BOUPOJ5C5QTHEFUTSEFOKYUYSQISEDLBS4AC32RH
static immutable AHK = KeyPair(PublicKey(Point([192, 117, 107, 81, 41, 165, 11, 244, 92, 11, 168, 247, 39, 162, 236, 38, 114, 22, 147, 145, 10, 229, 98, 152, 148, 17, 34, 13, 97, 151, 0, 45])), SecretKey(Scalar([3, 7, 178, 183, 74, 99, 143, 2, 3, 68, 154, 232, 245, 103, 122, 173, 103, 178, 97, 78, 35, 44, 153, 54, 194, 87, 79, 86, 72, 94, 87, 14])));
/// AHL: GDAHL22Z2JGZ4G4UV743NCH7VSHI77BY3JKM53HENQE3SM5QLXT6O6BK
static immutable AHL = KeyPair(PublicKey(Point([192, 117, 235, 89, 210, 77, 158, 27, 148, 175, 249, 182, 136, 255, 172, 142, 143, 252, 56, 218, 84, 206, 236, 228, 108, 9, 185, 51, 176, 93, 231, 231])), SecretKey(Scalar([80, 156, 62, 47, 14, 90, 9, 162, 234, 216, 186, 217, 62, 207, 83, 123, 212, 171, 245, 237, 166, 90, 135, 157, 203, 148, 204, 130, 4, 90, 46, 8])));
/// AHM: GDAHM22CE5CFUOEE2QXR3D6DCLHPEAEFDW6CJDT2IVGTEI3FQ3XZL5CW
static immutable AHM = KeyPair(PublicKey(Point([192, 118, 107, 66, 39, 68, 90, 56, 132, 212, 47, 29, 143, 195, 18, 206, 242, 0, 133, 29, 188, 36, 142, 122, 69, 77, 50, 35, 101, 134, 239, 149])), SecretKey(Scalar([159, 54, 49, 73, 143, 182, 179, 21, 155, 31, 178, 141, 115, 145, 249, 191, 65, 230, 166, 141, 9, 161, 114, 248, 94, 16, 16, 233, 249, 51, 81, 0])));
/// AHN: GDAHN22Y7EAPV3RGHCVQNQTTWDE5R2MPOBCOIJDRIATRNN75HUE6ONFA
static immutable AHN = KeyPair(PublicKey(Point([192, 118, 235, 88, 249, 0, 250, 238, 38, 56, 171, 6, 194, 115, 176, 201, 216, 233, 143, 112, 68, 228, 36, 113, 64, 39, 22, 183, 253, 61, 9, 231])), SecretKey(Scalar([168, 172, 30, 249, 75, 255, 112, 75, 229, 199, 135, 40, 85, 102, 242, 27, 10, 16, 7, 51, 60, 156, 147, 29, 186, 48, 97, 98, 59, 108, 90, 0])));
/// AHO: GDAHO22A2UWBZP2NGND427VEF33ZOTCO5243ANIYCZCLKG4ZVHUGWDCW
static immutable AHO = KeyPair(PublicKey(Point([192, 119, 107, 64, 213, 44, 28, 191, 77, 51, 71, 205, 126, 164, 46, 247, 151, 76, 78, 238, 185, 176, 53, 24, 22, 68, 181, 27, 153, 169, 232, 107])), SecretKey(Scalar([89, 245, 106, 170, 2, 211, 7, 125, 155, 51, 230, 165, 90, 18, 192, 201, 91, 228, 136, 201, 0, 158, 92, 171, 159, 116, 128, 39, 13, 209, 23, 1])));
/// AHP: GDAHP22HWXYAIIVVDFSYXO4H4RILDWXWUOCGVBLNTP47TIDZG7D47XMA
static immutable AHP = KeyPair(PublicKey(Point([192, 119, 235, 71, 181, 240, 4, 34, 181, 25, 101, 139, 187, 135, 228, 80, 177, 218, 246, 163, 132, 106, 133, 109, 155, 249, 249, 160, 121, 55, 199, 207])), SecretKey(Scalar([45, 153, 139, 19, 110, 249, 211, 211, 45, 122, 161, 219, 244, 182, 146, 223, 243, 195, 143, 114, 43, 5, 81, 93, 94, 46, 247, 91, 112, 70, 134, 11])));
/// AHQ: GDAHQ22XF2DRGDN3X2HECPAHOWZR5EXWNT3RPTUIQKOAJJVDXV3PVCIL
static immutable AHQ = KeyPair(PublicKey(Point([192, 120, 107, 87, 46, 135, 19, 13, 187, 190, 142, 65, 60, 7, 117, 179, 30, 146, 246, 108, 247, 23, 206, 136, 130, 156, 4, 166, 163, 189, 118, 250])), SecretKey(Scalar([237, 200, 156, 47, 116, 141, 41, 255, 82, 221, 182, 180, 15, 204, 216, 51, 39, 50, 201, 159, 36, 146, 6, 108, 102, 175, 205, 85, 0, 156, 65, 2])));
/// AHR: GDAHR22JSPJGPWOWTOA4K34772TJPP6BKHPZMUPXTPLVYQHPG46ZMKNZ
static immutable AHR = KeyPair(PublicKey(Point([192, 120, 235, 73, 147, 210, 103, 217, 214, 155, 129, 197, 111, 159, 254, 166, 151, 191, 193, 81, 223, 150, 81, 247, 155, 215, 92, 64, 239, 55, 61, 150])), SecretKey(Scalar([76, 244, 38, 35, 96, 191, 88, 237, 103, 218, 210, 7, 12, 9, 218, 244, 128, 7, 199, 153, 175, 206, 150, 166, 82, 157, 13, 214, 27, 248, 205, 2])));
/// AHS: GDAHS22PQNKUQNBLUAO4XYAFB46SQAMR3OAPCSTKM5O55OHPGGOJLJXR
static immutable AHS = KeyPair(PublicKey(Point([192, 121, 107, 79, 131, 85, 72, 52, 43, 160, 29, 203, 224, 5, 15, 61, 40, 1, 145, 219, 128, 241, 74, 106, 103, 93, 222, 184, 239, 49, 156, 149])), SecretKey(Scalar([82, 209, 181, 143, 7, 145, 27, 186, 117, 72, 46, 214, 41, 57, 218, 132, 254, 36, 205, 235, 18, 150, 153, 95, 113, 96, 165, 224, 66, 107, 193, 6])));
/// AHT: GDAHT222YXPSFVORSYWSGVKG35LD7MZA73OQXLSJGD777ZVN322FPBXL
static immutable AHT = KeyPair(PublicKey(Point([192, 121, 235, 90, 197, 223, 34, 213, 209, 150, 45, 35, 85, 70, 223, 86, 63, 179, 32, 254, 221, 11, 174, 73, 48, 255, 255, 230, 173, 222, 180, 87])), SecretKey(Scalar([118, 207, 59, 57, 33, 170, 211, 245, 223, 158, 157, 148, 32, 197, 154, 250, 118, 85, 237, 146, 31, 39, 147, 123, 203, 100, 93, 147, 223, 126, 226, 10])));
/// AHU: GDAHU22YLS2OWUPGMKCTCD4XXOZGNAXFRSJGDQ5SBCEL2T7YZ2XONGFX
static immutable AHU = KeyPair(PublicKey(Point([192, 122, 107, 88, 92, 180, 235, 81, 230, 98, 133, 49, 15, 151, 187, 178, 102, 130, 229, 140, 146, 97, 195, 178, 8, 136, 189, 79, 248, 206, 174, 230])), SecretKey(Scalar([235, 44, 43, 56, 104, 160, 81, 58, 165, 5, 103, 163, 251, 62, 45, 12, 64, 145, 224, 207, 41, 80, 234, 230, 242, 129, 231, 247, 19, 57, 99, 0])));
/// AHV: GDAHV22G6267CJG23FCJFNQVJEEW6J63N4DWELQOTKJELZU6E5BN5EEI
static immutable AHV = KeyPair(PublicKey(Point([192, 122, 235, 70, 246, 189, 241, 36, 218, 217, 68, 146, 182, 21, 73, 9, 111, 39, 219, 111, 7, 98, 46, 14, 154, 146, 69, 230, 158, 39, 66, 222])), SecretKey(Scalar([45, 44, 208, 204, 114, 113, 118, 62, 240, 42, 45, 194, 126, 125, 67, 101, 224, 103, 93, 177, 253, 239, 190, 160, 162, 237, 158, 9, 218, 10, 159, 11])));
/// AHW: GDAHW22XR66S5JREKWOXILOBFGHYYZQ7MK73QAO53FBLSPHAFSA3WT4Y
static immutable AHW = KeyPair(PublicKey(Point([192, 123, 107, 87, 143, 189, 46, 166, 36, 85, 157, 116, 45, 193, 41, 143, 140, 102, 31, 98, 191, 184, 1, 221, 217, 66, 185, 60, 224, 44, 129, 187])), SecretKey(Scalar([100, 184, 71, 102, 162, 255, 45, 71, 238, 216, 27, 176, 165, 9, 179, 180, 253, 167, 219, 252, 232, 102, 143, 65, 47, 112, 45, 85, 205, 110, 236, 1])));
/// AHX: GDAHX22HVNRUOQQYCW2BM47ULF5OSW2YBZLK4SJVMLSNCWRBNATM3J2K
static immutable AHX = KeyPair(PublicKey(Point([192, 123, 235, 71, 171, 99, 71, 66, 24, 21, 180, 22, 115, 244, 89, 122, 233, 91, 88, 14, 86, 174, 73, 53, 98, 228, 209, 90, 33, 104, 38, 205])), SecretKey(Scalar([129, 34, 10, 223, 255, 4, 125, 179, 139, 110, 245, 223, 170, 69, 79, 225, 218, 211, 192, 207, 14, 237, 190, 131, 185, 73, 95, 183, 149, 176, 43, 12])));
/// AHY: GDAHY22AIF7JBDYPCAXK2ISKEXXVPR6WTOSRUOK6366IE5WZFB6LWZO6
static immutable AHY = KeyPair(PublicKey(Point([192, 124, 107, 64, 65, 126, 144, 143, 15, 16, 46, 173, 34, 74, 37, 239, 87, 199, 214, 155, 165, 26, 57, 94, 223, 188, 130, 118, 217, 40, 124, 187])), SecretKey(Scalar([238, 232, 56, 255, 10, 90, 238, 159, 104, 87, 110, 177, 99, 242, 81, 176, 35, 93, 72, 110, 139, 143, 129, 49, 237, 139, 29, 75, 114, 149, 228, 10])));
/// AHZ: GDAHZ22TC6BWEBP6ZO7IAR5RF5NBSOR7PNWEASX6R2AX5HXBA22KZ6TM
static immutable AHZ = KeyPair(PublicKey(Point([192, 124, 235, 83, 23, 131, 98, 5, 254, 203, 190, 128, 71, 177, 47, 90, 25, 58, 63, 123, 108, 64, 74, 254, 142, 129, 126, 158, 225, 6, 180, 172])), SecretKey(Scalar([114, 168, 44, 42, 44, 216, 104, 196, 167, 125, 176, 141, 186, 210, 67, 253, 146, 162, 0, 240, 212, 100, 104, 63, 213, 64, 9, 222, 252, 150, 30, 13])));
/// AIA: GDAIA22O5RECRHGRJRVOKLIIV4EKJFIIET4W4G4XUOUDCJHOW3NZXRD5
static immutable AIA = KeyPair(PublicKey(Point([192, 128, 107, 78, 236, 72, 40, 156, 209, 76, 106, 229, 45, 8, 175, 8, 164, 149, 8, 36, 249, 110, 27, 151, 163, 168, 49, 36, 238, 182, 219, 155])), SecretKey(Scalar([209, 89, 78, 63, 22, 207, 206, 199, 199, 68, 119, 41, 247, 106, 250, 197, 36, 140, 232, 41, 75, 228, 127, 56, 73, 65, 93, 156, 61, 210, 58, 2])));
/// AIB: GDAIB22GFBJTLFB5GZPA37FBUETAYULGPHDO5LJDWMD7LRAGHVR65W7M
static immutable AIB = KeyPair(PublicKey(Point([192, 128, 235, 70, 40, 83, 53, 148, 61, 54, 94, 13, 252, 161, 161, 38, 12, 81, 102, 121, 198, 238, 173, 35, 179, 7, 245, 196, 6, 61, 99, 238])), SecretKey(Scalar([200, 5, 149, 169, 55, 175, 16, 65, 9, 90, 255, 126, 174, 71, 233, 165, 163, 100, 188, 43, 244, 255, 27, 88, 144, 137, 39, 151, 196, 215, 157, 0])));
/// AIC: GDAIC22NFVPV6SHNOQ66O4I5LXCBP2EEX3EFDPHZVVZH5JHY6ZARZDNW
static immutable AIC = KeyPair(PublicKey(Point([192, 129, 107, 77, 45, 95, 95, 72, 237, 116, 61, 231, 113, 29, 93, 196, 23, 232, 132, 190, 200, 81, 188, 249, 173, 114, 126, 164, 248, 246, 65, 28])), SecretKey(Scalar([112, 108, 120, 203, 64, 194, 156, 212, 203, 227, 93, 128, 236, 18, 71, 182, 202, 5, 94, 48, 199, 234, 225, 69, 199, 238, 106, 214, 241, 37, 207, 15])));
/// AID: GDAID222BBRIBZR63BLITJLTTNZ4ZFO6PVCU3UHYA3QQ4QVUNK2UWVNP
static immutable AID = KeyPair(PublicKey(Point([192, 129, 235, 90, 8, 98, 128, 230, 62, 216, 86, 137, 165, 115, 155, 115, 204, 149, 222, 125, 69, 77, 208, 248, 6, 225, 14, 66, 180, 106, 181, 75])), SecretKey(Scalar([72, 248, 66, 47, 20, 102, 55, 113, 11, 154, 115, 43, 106, 204, 199, 57, 195, 46, 26, 36, 38, 6, 59, 107, 63, 200, 80, 57, 230, 156, 226, 10])));
/// AIE: GDAIE226RTZXQH6XQZJKXCWR7RT55IHOD6QRYN56QPDZ2DISQP7ZDRWL
static immutable AIE = KeyPair(PublicKey(Point([192, 130, 107, 94, 140, 243, 120, 31, 215, 134, 82, 171, 138, 209, 252, 103, 222, 160, 238, 31, 161, 28, 55, 190, 131, 199, 157, 13, 18, 131, 255, 145])), SecretKey(Scalar([79, 236, 153, 21, 16, 217, 21, 135, 74, 251, 125, 97, 152, 61, 190, 6, 31, 162, 173, 105, 179, 168, 95, 69, 130, 104, 134, 246, 223, 5, 83, 2])));
/// AIF: GDAIF22KG7JYZY6XYDMB4PKTALCG6PQGYEFKL3HWRBJY7RWM3M7FXQ4T
static immutable AIF = KeyPair(PublicKey(Point([192, 130, 235, 74, 55, 211, 140, 227, 215, 192, 216, 30, 61, 83, 2, 196, 111, 62, 6, 193, 10, 165, 236, 246, 136, 83, 143, 198, 204, 219, 62, 91])), SecretKey(Scalar([133, 9, 218, 186, 116, 111, 117, 186, 161, 160, 241, 234, 82, 226, 140, 244, 55, 141, 107, 4, 46, 183, 164, 12, 41, 145, 243, 44, 185, 160, 216, 10])));
/// AIG: GDAIG22MUCWJFOW2BR7OKXMZDGW2D5ZF3FBK5YN6JUQD757GUFZW2QIV
static immutable AIG = KeyPair(PublicKey(Point([192, 131, 107, 76, 160, 172, 146, 186, 218, 12, 126, 229, 93, 153, 25, 173, 161, 247, 37, 217, 66, 174, 225, 190, 77, 32, 63, 247, 230, 161, 115, 109])), SecretKey(Scalar([163, 114, 16, 128, 243, 9, 91, 113, 236, 145, 87, 84, 169, 30, 33, 134, 245, 114, 210, 246, 140, 39, 168, 48, 72, 244, 175, 127, 79, 230, 190, 13])));
/// AIH: GDAIH22J7HU7PFZTIWBD5JQJPJFK4UTAYYSFJDSBQZQ47JXNPRISFCH2
static immutable AIH = KeyPair(PublicKey(Point([192, 131, 235, 73, 249, 233, 247, 151, 51, 69, 130, 62, 166, 9, 122, 74, 174, 82, 96, 198, 36, 84, 142, 65, 134, 97, 207, 166, 237, 124, 81, 34])), SecretKey(Scalar([117, 186, 5, 215, 24, 237, 158, 8, 174, 126, 90, 70, 147, 250, 190, 224, 53, 40, 120, 227, 215, 31, 104, 14, 128, 231, 116, 117, 55, 159, 53, 11])));
/// AII: GDAII22B5DUC4JUPKDN7FHXDSBTX2IVDKXQ7JGDJX7B2PL2FJPBKH5XF
static immutable AII = KeyPair(PublicKey(Point([192, 132, 107, 65, 232, 232, 46, 38, 143, 80, 219, 242, 158, 227, 144, 103, 125, 34, 163, 85, 225, 244, 152, 105, 191, 195, 167, 175, 69, 75, 194, 163])), SecretKey(Scalar([70, 225, 177, 202, 186, 48, 197, 29, 57, 122, 128, 109, 178, 206, 16, 35, 19, 193, 135, 54, 4, 121, 39, 108, 184, 24, 52, 114, 170, 7, 165, 10])));
/// AIJ: GDAIJ22ZPKUZIRYPADANQR3IG2G4Z2TJ4YINISWNATKPZV76YV2DN2Z4
static immutable AIJ = KeyPair(PublicKey(Point([192, 132, 235, 89, 122, 169, 148, 71, 15, 0, 192, 216, 71, 104, 54, 141, 204, 234, 105, 230, 16, 212, 74, 205, 4, 212, 252, 215, 254, 197, 116, 54])), SecretKey(Scalar([57, 56, 53, 247, 207, 3, 231, 141, 197, 43, 17, 58, 250, 179, 71, 203, 2, 209, 216, 219, 93, 55, 70, 32, 177, 227, 135, 119, 248, 189, 100, 2])));
/// AIK: GDAIK223KFTDWHQQ66J425FYOCK523UVN75AY76GX767BWHUB2ECPEKQ
static immutable AIK = KeyPair(PublicKey(Point([192, 133, 107, 91, 81, 102, 59, 30, 16, 247, 147, 205, 116, 184, 112, 149, 221, 110, 149, 111, 250, 12, 127, 198, 191, 253, 240, 216, 244, 14, 136, 39])), SecretKey(Scalar([113, 81, 77, 173, 48, 25, 132, 38, 235, 187, 100, 166, 208, 82, 177, 75, 120, 43, 143, 195, 193, 250, 143, 109, 172, 86, 10, 159, 239, 43, 75, 1])));
/// AIL: GDAIL22YD57XR5GBBSL2KVCUPQPCPDHOJGEFN46APDGMBWKGI5NRGHGC
static immutable AIL = KeyPair(PublicKey(Point([192, 133, 235, 88, 31, 127, 120, 244, 193, 12, 151, 165, 84, 84, 124, 30, 39, 140, 238, 73, 136, 86, 243, 192, 120, 204, 192, 217, 70, 71, 91, 19])), SecretKey(Scalar([177, 143, 54, 51, 197, 244, 206, 107, 85, 113, 105, 193, 194, 111, 157, 72, 43, 40, 45, 232, 51, 53, 33, 55, 188, 149, 0, 148, 19, 215, 164, 6])));
/// AIM: GDAIM22DUM5AOSLRMLNH2ENP3INRD3Y4YIBSCHZFINRZJXKFFTY64CFB
static immutable AIM = KeyPair(PublicKey(Point([192, 134, 107, 67, 163, 58, 7, 73, 113, 98, 218, 125, 17, 175, 218, 27, 17, 239, 28, 194, 3, 33, 31, 37, 67, 99, 148, 221, 69, 44, 241, 238])), SecretKey(Scalar([74, 220, 91, 113, 113, 1, 50, 168, 34, 76, 123, 221, 111, 10, 114, 78, 251, 98, 103, 242, 58, 169, 113, 211, 75, 15, 116, 44, 96, 197, 10, 10])));
/// AIN: GDAIN22S6PDYJYPDACIL5MDOOULPOCPXR5Z7EOBVEBDXMM3DEM37IANF
static immutable AIN = KeyPair(PublicKey(Point([192, 134, 235, 82, 243, 199, 132, 225, 227, 0, 144, 190, 176, 110, 117, 22, 247, 9, 247, 143, 115, 242, 56, 53, 32, 71, 118, 51, 99, 35, 55, 244])), SecretKey(Scalar([80, 6, 214, 19, 192, 247, 255, 53, 216, 145, 126, 42, 121, 198, 253, 81, 65, 63, 157, 145, 222, 218, 114, 177, 152, 153, 210, 136, 67, 83, 172, 8])));
/// AIO: GDAIO22Z2OLXI55HOKBOWOSFPWWSZAT2JB65WPO6F55X26VSG3ZVPJUE
static immutable AIO = KeyPair(PublicKey(Point([192, 135, 107, 89, 211, 151, 116, 119, 167, 114, 130, 235, 58, 69, 125, 173, 44, 130, 122, 72, 125, 219, 61, 222, 47, 123, 125, 122, 178, 54, 243, 87])), SecretKey(Scalar([239, 246, 15, 149, 64, 43, 71, 161, 181, 246, 100, 243, 225, 78, 61, 130, 201, 55, 230, 164, 43, 161, 60, 44, 168, 55, 57, 8, 204, 126, 65, 4])));
/// AIP: GDAIP22XWPW3OSBU7P3DILZ5DJ77QXK6JUYMXOR5LVD6MZ2LTXU5VIJT
static immutable AIP = KeyPair(PublicKey(Point([192, 135, 235, 87, 179, 237, 183, 72, 52, 251, 246, 52, 47, 61, 26, 127, 248, 93, 94, 77, 48, 203, 186, 61, 93, 71, 230, 103, 75, 157, 233, 218])), SecretKey(Scalar([48, 209, 13, 55, 107, 234, 93, 101, 197, 92, 235, 108, 53, 176, 174, 182, 137, 249, 22, 162, 237, 117, 64, 210, 20, 101, 0, 19, 78, 46, 17, 5])));
/// AIQ: GDAIQ22AMITPM6REMWZYTB5WYOGSSXDBMXCNBF4KWSYZZT76WFGKVKDL
static immutable AIQ = KeyPair(PublicKey(Point([192, 136, 107, 64, 98, 38, 246, 122, 36, 101, 179, 137, 135, 182, 195, 141, 41, 92, 97, 101, 196, 208, 151, 138, 180, 177, 156, 207, 254, 177, 76, 170])), SecretKey(Scalar([96, 58, 17, 116, 161, 25, 237, 177, 244, 83, 96, 173, 65, 155, 169, 245, 98, 24, 90, 99, 100, 210, 54, 252, 187, 110, 79, 241, 141, 99, 83, 11])));
/// AIR: GDAIR22OYTULGHUR3CMKH77EBB5O7DHDV2457ISSPDJGJPJR46YSUSWG
static immutable AIR = KeyPair(PublicKey(Point([192, 136, 235, 78, 196, 232, 179, 30, 145, 216, 152, 163, 255, 228, 8, 122, 239, 140, 227, 174, 185, 223, 162, 82, 120, 210, 100, 189, 49, 231, 177, 42])), SecretKey(Scalar([29, 86, 38, 0, 40, 31, 37, 86, 11, 60, 72, 1, 74, 88, 0, 42, 205, 32, 210, 127, 67, 19, 70, 218, 156, 175, 147, 170, 203, 57, 51, 0])));
/// AIS: GDAIS22FDA5SRKZHEJ3Q4LHDU5UCCYGD257PU5FBMSSQYNB42URFRWJH
static immutable AIS = KeyPair(PublicKey(Point([192, 137, 107, 69, 24, 59, 40, 171, 39, 34, 119, 14, 44, 227, 167, 104, 33, 96, 195, 215, 126, 250, 116, 161, 100, 165, 12, 52, 60, 213, 34, 88])), SecretKey(Scalar([75, 230, 226, 124, 161, 192, 120, 232, 114, 228, 161, 198, 222, 70, 208, 34, 134, 145, 253, 252, 153, 138, 226, 121, 53, 230, 71, 170, 185, 72, 59, 4])));
/// AIT: GDAIT22B6S2J25I3WT4T2JCVEG5E262WVG2H6LGNIGOXISB6DLRFDVOM
static immutable AIT = KeyPair(PublicKey(Point([192, 137, 235, 65, 244, 180, 157, 117, 27, 180, 249, 61, 36, 85, 33, 186, 77, 123, 86, 169, 180, 127, 44, 205, 65, 157, 116, 72, 62, 26, 226, 81])), SecretKey(Scalar([246, 101, 158, 243, 225, 224, 11, 250, 53, 233, 251, 213, 107, 23, 187, 213, 18, 194, 89, 181, 163, 235, 17, 161, 40, 126, 31, 115, 47, 189, 142, 5])));
/// AIU: GDAIU22FBAXOHD3XLOGG53YQG2TQAND4WWJJDH4M54JDGEDFG6N75W2P
static immutable AIU = KeyPair(PublicKey(Point([192, 138, 107, 69, 8, 46, 227, 143, 119, 91, 140, 110, 239, 16, 54, 167, 0, 52, 124, 181, 146, 145, 159, 140, 239, 18, 51, 16, 101, 55, 155, 254])), SecretKey(Scalar([177, 103, 59, 215, 252, 133, 69, 28, 209, 197, 53, 168, 247, 201, 28, 64, 95, 61, 196, 68, 123, 115, 66, 3, 26, 163, 60, 107, 21, 212, 0, 7])));
/// AIV: GDAIV22KKFABAO2OUBI3YTGVSOAOZ7CPJ7YRPBDSN3UGPNNHI6HIBCK3
static immutable AIV = KeyPair(PublicKey(Point([192, 138, 235, 74, 81, 64, 16, 59, 78, 160, 81, 188, 76, 213, 147, 128, 236, 252, 79, 79, 241, 23, 132, 114, 110, 232, 103, 181, 167, 71, 142, 128])), SecretKey(Scalar([202, 75, 98, 29, 188, 71, 112, 92, 193, 176, 195, 1, 169, 166, 158, 135, 224, 131, 102, 153, 161, 138, 41, 218, 249, 146, 254, 2, 187, 36, 127, 10])));
/// AIW: GDAIW22F2QMBDDUPIRJHK4FRJ7QL2M7OHOSAKD7DJ5ZY3MGO4VOXBMLG
static immutable AIW = KeyPair(PublicKey(Point([192, 139, 107, 69, 212, 24, 17, 142, 143, 68, 82, 117, 112, 177, 79, 224, 189, 51, 238, 59, 164, 5, 15, 227, 79, 115, 141, 176, 206, 229, 93, 112])), SecretKey(Scalar([97, 215, 98, 208, 226, 34, 225, 121, 34, 106, 13, 192, 143, 200, 86, 22, 28, 132, 95, 68, 218, 171, 49, 166, 171, 140, 126, 44, 30, 18, 53, 14])));
/// AIX: GDAIX22L56UENAPNHO6VGU7WUNTXHZUSDH5V4G2HHFGNRRR262VFASQ4
static immutable AIX = KeyPair(PublicKey(Point([192, 139, 235, 75, 239, 168, 70, 129, 237, 59, 189, 83, 83, 246, 163, 103, 115, 230, 146, 25, 251, 94, 27, 71, 57, 76, 216, 198, 58, 246, 170, 80])), SecretKey(Scalar([129, 1, 95, 16, 166, 160, 70, 65, 158, 42, 127, 222, 130, 190, 58, 130, 35, 159, 45, 220, 3, 52, 70, 140, 11, 90, 174, 154, 82, 201, 144, 2])));
/// AIY: GDAIY22EFTBADKLFRGAE3CEGT2T7B3P4DVERTRTTUZGFHBJYMWU57SGD
static immutable AIY = KeyPair(PublicKey(Point([192, 140, 107, 68, 44, 194, 1, 169, 101, 137, 128, 77, 136, 134, 158, 167, 240, 237, 252, 29, 73, 25, 198, 115, 166, 76, 83, 133, 56, 101, 169, 223])), SecretKey(Scalar([80, 230, 91, 169, 65, 138, 40, 234, 140, 52, 205, 33, 229, 60, 129, 145, 148, 0, 133, 250, 27, 245, 248, 147, 116, 220, 208, 230, 218, 199, 232, 6])));
/// AIZ: GDAIZ22WR53FYYC4QEXF2CLUS5G2SSJDI6MRYOWDQ2FEEO4GPSJTICKB
static immutable AIZ = KeyPair(PublicKey(Point([192, 140, 235, 86, 143, 118, 92, 96, 92, 129, 46, 93, 9, 116, 151, 77, 169, 73, 35, 71, 153, 28, 58, 195, 134, 138, 66, 59, 134, 124, 147, 52])), SecretKey(Scalar([204, 82, 158, 199, 242, 32, 110, 172, 251, 234, 218, 112, 78, 95, 28, 100, 21, 96, 214, 38, 188, 221, 178, 131, 230, 226, 184, 83, 210, 255, 69, 0])));
/// AJA: GDAJA22LROLGY336AEON6DRFE7SNTCYEQO5O2IDFLCWA5VVLSL2SBGIC
static immutable AJA = KeyPair(PublicKey(Point([192, 144, 107, 75, 139, 150, 108, 111, 126, 1, 28, 223, 14, 37, 39, 228, 217, 139, 4, 131, 186, 237, 32, 101, 88, 172, 14, 214, 171, 146, 245, 32])), SecretKey(Scalar([66, 114, 194, 147, 170, 93, 169, 102, 5, 95, 89, 220, 147, 141, 132, 174, 22, 200, 182, 226, 112, 46, 77, 174, 189, 137, 220, 27, 188, 194, 94, 2])));
/// AJB: GDAJB22N3QXDIOBTO3XGRTLFXLQUMCLT7W4VXFQ7R7SLODGP6L6XLPMX
static immutable AJB = KeyPair(PublicKey(Point([192, 144, 235, 77, 220, 46, 52, 56, 51, 118, 238, 104, 205, 101, 186, 225, 70, 9, 115, 253, 185, 91, 150, 31, 143, 228, 183, 12, 207, 242, 253, 117])), SecretKey(Scalar([158, 93, 231, 190, 247, 191, 176, 166, 36, 54, 77, 33, 83, 6, 155, 59, 24, 105, 116, 134, 98, 125, 90, 192, 172, 123, 74, 234, 93, 204, 89, 10])));
/// AJC: GDAJC225BECY7WTE6DXZZA45J5M4VNKL45LWSSEK6IKG4G2KRXMKS66F
static immutable AJC = KeyPair(PublicKey(Point([192, 145, 107, 93, 9, 5, 143, 218, 100, 240, 239, 156, 131, 157, 79, 89, 202, 181, 75, 231, 87, 105, 72, 138, 242, 20, 110, 27, 74, 141, 216, 169])), SecretKey(Scalar([122, 41, 75, 116, 64, 211, 149, 216, 148, 95, 92, 99, 7, 212, 5, 139, 219, 56, 94, 249, 222, 63, 46, 136, 220, 173, 200, 141, 161, 248, 253, 0])));
/// AJD: GDAJD22THJMI7SKT3TQ54XA35NLUAYT2DJWPVPTW54GOXXG3W67OXQ2I
static immutable AJD = KeyPair(PublicKey(Point([192, 145, 235, 83, 58, 88, 143, 201, 83, 220, 225, 222, 92, 27, 235, 87, 64, 98, 122, 26, 108, 250, 190, 118, 239, 12, 235, 220, 219, 183, 190, 235])), SecretKey(Scalar([253, 58, 144, 10, 100, 97, 38, 138, 216, 93, 26, 112, 144, 151, 196, 30, 12, 44, 180, 148, 67, 179, 141, 55, 136, 3, 129, 127, 248, 85, 88, 8])));
/// AJE: GDAJE22R4UVI53DVRLA72S4JTCTWJQYBNL4ACSIYRYCD64IVVV2GCMZ2
static immutable AJE = KeyPair(PublicKey(Point([192, 146, 107, 81, 229, 42, 142, 236, 117, 138, 193, 253, 75, 137, 152, 167, 100, 195, 1, 106, 248, 1, 73, 24, 142, 4, 63, 113, 21, 173, 116, 97])), SecretKey(Scalar([250, 249, 55, 116, 117, 21, 172, 64, 128, 226, 35, 243, 114, 109, 88, 208, 247, 39, 122, 70, 56, 57, 7, 53, 107, 55, 237, 151, 125, 189, 32, 4])));
/// AJF: GDAJF2224JZZWXHYRG6FFTZTUWBQRFN4F3QS22TGLZWFPB6J7WK2BGO7
static immutable AJF = KeyPair(PublicKey(Point([192, 146, 235, 90, 226, 115, 155, 92, 248, 137, 188, 82, 207, 51, 165, 131, 8, 149, 188, 46, 225, 45, 106, 102, 94, 108, 87, 135, 201, 253, 149, 160])), SecretKey(Scalar([213, 7, 100, 116, 38, 50, 46, 177, 126, 81, 220, 149, 147, 13, 179, 141, 224, 81, 13, 100, 204, 123, 219, 228, 33, 11, 153, 3, 78, 84, 39, 4])));
/// AJG: GDAJG22OFHLM7O56EU6K5QM2ZUMS4ZLBF4KRSNV6GS3UEMINQ7OU5VLK
static immutable AJG = KeyPair(PublicKey(Point([192, 147, 107, 78, 41, 214, 207, 187, 190, 37, 60, 174, 193, 154, 205, 25, 46, 101, 97, 47, 21, 25, 54, 190, 52, 183, 66, 49, 13, 135, 221, 78])), SecretKey(Scalar([247, 114, 153, 60, 188, 25, 147, 29, 241, 34, 61, 164, 246, 185, 238, 130, 93, 83, 62, 160, 107, 68, 219, 34, 198, 18, 139, 204, 117, 96, 196, 4])));
/// AJH: GDAJH22RWPK25IOTE75RZO7JUWH3IKEVUF5NG5HTCAO7IT7PHIDMYQTQ
static immutable AJH = KeyPair(PublicKey(Point([192, 147, 235, 81, 179, 213, 174, 161, 211, 39, 251, 28, 187, 233, 165, 143, 180, 40, 149, 161, 122, 211, 116, 243, 16, 29, 244, 79, 239, 58, 6, 204])), SecretKey(Scalar([197, 28, 187, 176, 247, 85, 5, 8, 211, 178, 62, 96, 123, 178, 235, 215, 205, 79, 30, 79, 212, 126, 65, 47, 138, 237, 27, 104, 17, 135, 75, 3])));
/// AJI: GDAJI223HLDIG2X33PBNNRRXG62UVOINYZ5OSZBCJRJZQL6BDMRVTKVH
static immutable AJI = KeyPair(PublicKey(Point([192, 148, 107, 91, 58, 198, 131, 106, 251, 219, 194, 214, 198, 55, 55, 181, 74, 185, 13, 198, 122, 233, 100, 34, 76, 83, 152, 47, 193, 27, 35, 89])), SecretKey(Scalar([240, 96, 54, 227, 32, 208, 119, 81, 101, 72, 64, 30, 171, 39, 27, 146, 253, 161, 151, 44, 57, 147, 66, 131, 28, 147, 73, 2, 198, 70, 195, 8])));
/// AJJ: GDAJJ22WWMIEFAXKDDDRSNJMVY37HY7IBCUDKUCKHJEVW5RAQAOUEKYS
static immutable AJJ = KeyPair(PublicKey(Point([192, 148, 235, 86, 179, 16, 66, 130, 234, 24, 199, 25, 53, 44, 174, 55, 243, 227, 232, 8, 168, 53, 80, 74, 58, 73, 91, 118, 32, 128, 29, 66])), SecretKey(Scalar([70, 199, 247, 29, 83, 210, 35, 78, 120, 185, 155, 54, 171, 175, 88, 236, 22, 24, 195, 110, 185, 132, 101, 40, 228, 4, 22, 215, 154, 120, 48, 5])));
/// AJK: GDAJK222BKAANHYVA6HZ6A2GJMSQ3JBBK2KPJPSPQSSTJZOEGQWXKB4B
static immutable AJK = KeyPair(PublicKey(Point([192, 149, 107, 90, 10, 128, 6, 159, 21, 7, 143, 159, 3, 70, 75, 37, 13, 164, 33, 86, 148, 244, 190, 79, 132, 165, 52, 229, 196, 52, 45, 117])), SecretKey(Scalar([44, 56, 67, 110, 91, 183, 24, 241, 235, 86, 66, 22, 61, 88, 27, 27, 100, 66, 244, 37, 137, 2, 86, 38, 151, 23, 218, 222, 19, 201, 16, 6])));
/// AJL: GDAJL22PPG23LRDTQJFIVREXIA2OPRJYKHYCOTJF7PWZJ5SEQKHFQUFK
static immutable AJL = KeyPair(PublicKey(Point([192, 149, 235, 79, 121, 181, 181, 196, 115, 130, 74, 138, 196, 151, 64, 52, 231, 197, 56, 81, 240, 39, 77, 37, 251, 237, 148, 246, 68, 130, 142, 88])), SecretKey(Scalar([165, 174, 101, 214, 219, 175, 41, 242, 158, 193, 47, 209, 252, 199, 16, 221, 165, 118, 113, 245, 216, 207, 112, 43, 58, 33, 238, 30, 162, 239, 162, 12])));
/// AJM: GDAJM22BL2QVCMPD3ROHQ7HOF2RAE2DUJYYWGDESMLBEZXHSTMVP3NQF
static immutable AJM = KeyPair(PublicKey(Point([192, 150, 107, 65, 94, 161, 81, 49, 227, 220, 92, 120, 124, 238, 46, 162, 2, 104, 116, 78, 49, 99, 12, 146, 98, 194, 76, 220, 242, 155, 42, 253])), SecretKey(Scalar([185, 154, 229, 224, 79, 93, 144, 25, 246, 246, 246, 120, 188, 32, 217, 133, 86, 46, 73, 123, 153, 31, 255, 26, 178, 51, 125, 151, 146, 190, 18, 0])));
/// AJN: GDAJN22PUCGVJJBPKBEUP6EW27LBWJPMOHCET62UOCMASX3RZGMOYGG7
static immutable AJN = KeyPair(PublicKey(Point([192, 150, 235, 79, 160, 141, 84, 164, 47, 80, 73, 71, 248, 150, 215, 214, 27, 37, 236, 113, 196, 73, 251, 84, 112, 152, 9, 95, 113, 201, 152, 236])), SecretKey(Scalar([94, 208, 158, 165, 116, 86, 75, 204, 12, 72, 186, 62, 137, 209, 3, 51, 231, 236, 196, 151, 181, 175, 17, 148, 145, 201, 204, 18, 253, 155, 159, 9])));
/// AJO: GDAJO22F4X6P36SFHARL42OXML2JZR4F6NMLQY4YQO627DIGMKJ6DGZ7
static immutable AJO = KeyPair(PublicKey(Point([192, 151, 107, 69, 229, 252, 253, 250, 69, 56, 34, 190, 105, 215, 98, 244, 156, 199, 133, 243, 88, 184, 99, 152, 131, 189, 175, 141, 6, 98, 147, 225])), SecretKey(Scalar([12, 205, 53, 143, 7, 195, 232, 99, 218, 108, 48, 30, 152, 0, 31, 16, 115, 248, 220, 179, 26, 57, 229, 88, 53, 134, 245, 179, 102, 63, 81, 0])));
/// AJP: GDAJP22QN32T2OG26ZJ3BOAE4BHQQ4EZ63IUWEX6JAERJ7E63P7CHNA2
static immutable AJP = KeyPair(PublicKey(Point([192, 151, 235, 80, 110, 245, 61, 56, 218, 246, 83, 176, 184, 4, 224, 79, 8, 112, 153, 246, 209, 75, 18, 254, 72, 9, 20, 252, 158, 219, 254, 35])), SecretKey(Scalar([134, 187, 131, 99, 143, 159, 176, 8, 175, 124, 10, 208, 83, 163, 12, 83, 46, 226, 27, 192, 198, 113, 138, 244, 168, 20, 98, 83, 152, 204, 216, 12])));
/// AJQ: GDAJQ225U2JT3SOGA3573JJXNAPRSWFVALIERJL4EC7RNIYCWU4K65YL
static immutable AJQ = KeyPair(PublicKey(Point([192, 152, 107, 93, 166, 147, 61, 201, 198, 6, 251, 253, 165, 55, 104, 31, 25, 88, 181, 2, 208, 72, 165, 124, 32, 191, 22, 163, 2, 181, 56, 175])), SecretKey(Scalar([140, 107, 99, 18, 216, 207, 237, 88, 78, 98, 171, 85, 6, 174, 106, 188, 5, 136, 163, 207, 221, 104, 139, 171, 210, 221, 133, 250, 201, 142, 239, 9])));
/// AJR: GDAJR22AVRSW65VLGPCE7H3WHJY3HL3XCVSGCLNJKL437LT66FUMNKD4
static immutable AJR = KeyPair(PublicKey(Point([192, 152, 235, 64, 172, 101, 111, 118, 171, 51, 196, 79, 159, 118, 58, 113, 179, 175, 119, 21, 100, 97, 45, 169, 82, 249, 191, 174, 126, 241, 104, 198])), SecretKey(Scalar([33, 89, 66, 47, 181, 102, 47, 40, 250, 182, 156, 214, 87, 102, 26, 67, 177, 21, 80, 185, 232, 52, 60, 224, 203, 144, 27, 53, 233, 11, 223, 7])));
/// AJS: GDAJS22UR6QSE5AQZ2WRCDZVHRQQXD7B7UTQS23PH6QKGNJGHKWVZNJX
static immutable AJS = KeyPair(PublicKey(Point([192, 153, 107, 84, 143, 161, 34, 116, 16, 206, 173, 17, 15, 53, 60, 97, 11, 143, 225, 253, 39, 9, 107, 111, 63, 160, 163, 53, 38, 58, 173, 92])), SecretKey(Scalar([1, 178, 216, 82, 196, 134, 105, 83, 133, 213, 123, 186, 255, 108, 62, 153, 40, 140, 143, 122, 168, 79, 75, 124, 147, 195, 99, 218, 81, 198, 189, 12])));
/// AJT: GDAJT22EPNJKZDQ57O3JAUP24TV7V2QSSBJF6TMV3O4IGCXDZZHAOICK
static immutable AJT = KeyPair(PublicKey(Point([192, 153, 235, 68, 123, 82, 172, 142, 29, 251, 182, 144, 81, 250, 228, 235, 250, 234, 18, 144, 82, 95, 77, 149, 219, 184, 131, 10, 227, 206, 78, 7])), SecretKey(Scalar([175, 2, 163, 24, 150, 217, 224, 221, 199, 198, 237, 215, 126, 8, 32, 86, 57, 230, 90, 89, 176, 68, 163, 198, 36, 112, 228, 71, 242, 9, 129, 7])));
/// AJU: GDAJU22373B4GBYCUL2LVTJ5B5ARHNZL3LP5D4XIKYVKC6FJ5RLKRCIE
static immutable AJU = KeyPair(PublicKey(Point([192, 154, 107, 91, 254, 195, 195, 7, 2, 162, 244, 186, 205, 61, 15, 65, 19, 183, 43, 218, 223, 209, 242, 232, 86, 42, 161, 120, 169, 236, 86, 168])), SecretKey(Scalar([44, 177, 96, 57, 78, 128, 1, 250, 87, 142, 104, 96, 95, 68, 168, 70, 212, 13, 81, 118, 248, 167, 128, 90, 31, 67, 162, 177, 150, 195, 170, 11])));
/// AJV: GDAJV22VVMGQNVUPPMVKA2Y4ZHY6TE4RAW6DVWVYULD35G2X4TXPNJBD
static immutable AJV = KeyPair(PublicKey(Point([192, 154, 235, 85, 171, 13, 6, 214, 143, 123, 42, 160, 107, 28, 201, 241, 233, 147, 145, 5, 188, 58, 218, 184, 162, 199, 190, 155, 87, 228, 238, 246])), SecretKey(Scalar([239, 59, 122, 58, 207, 139, 37, 249, 26, 0, 102, 194, 88, 90, 32, 15, 48, 69, 156, 239, 194, 145, 71, 57, 250, 54, 132, 14, 38, 196, 244, 13])));
/// AJW: GDAJW22F2C623YOSZHAW4VKDQ57B47ZNWZ5UPMKYWKBEFNYGJWMOFBAA
static immutable AJW = KeyPair(PublicKey(Point([192, 155, 107, 69, 208, 189, 173, 225, 210, 201, 193, 110, 85, 67, 135, 126, 30, 127, 45, 182, 123, 71, 177, 88, 178, 130, 66, 183, 6, 77, 152, 226])), SecretKey(Scalar([83, 166, 192, 53, 135, 129, 232, 168, 201, 156, 234, 183, 71, 206, 173, 64, 29, 196, 130, 146, 182, 130, 209, 27, 76, 137, 104, 32, 174, 240, 135, 3])));
/// AJX: GDAJX22RCZNFTWY7DPRVF77SWY5SFWAJC7NBXILU7NLFSK436PX247WW
static immutable AJX = KeyPair(PublicKey(Point([192, 155, 235, 81, 22, 90, 89, 219, 31, 27, 227, 82, 255, 242, 182, 59, 34, 216, 9, 23, 218, 27, 161, 116, 251, 86, 89, 43, 155, 243, 239, 174])), SecretKey(Scalar([38, 58, 7, 34, 140, 158, 30, 28, 178, 211, 53, 152, 144, 227, 238, 41, 170, 220, 120, 10, 104, 225, 250, 118, 133, 112, 253, 122, 160, 254, 221, 10])));
/// AJY: GDAJY224AWH5DTA5OHETDDBJLDJYPWRNUZHRSFXLJWSK2KKLHMV5Y2LM
static immutable AJY = KeyPair(PublicKey(Point([192, 156, 107, 92, 5, 143, 209, 204, 29, 113, 201, 49, 140, 41, 88, 211, 135, 218, 45, 166, 79, 25, 22, 235, 77, 164, 173, 41, 75, 59, 43, 220])), SecretKey(Scalar([178, 173, 61, 252, 172, 166, 225, 232, 59, 182, 196, 47, 31, 58, 63, 114, 5, 249, 151, 78, 244, 249, 151, 62, 216, 33, 218, 252, 104, 29, 225, 9])));
/// AJZ: GDAJZ226DGXKUKV37CVK6Q5HO72PEXXRMOI2RG7HGDU546SOVAT47RDP
static immutable AJZ = KeyPair(PublicKey(Point([192, 156, 235, 94, 25, 174, 170, 42, 187, 248, 170, 175, 67, 167, 119, 244, 242, 94, 241, 99, 145, 168, 155, 231, 48, 233, 222, 122, 78, 168, 39, 207])), SecretKey(Scalar([192, 18, 129, 231, 213, 57, 83, 1, 21, 251, 71, 14, 185, 165, 158, 193, 108, 146, 208, 172, 101, 118, 223, 213, 77, 174, 23, 17, 125, 19, 226, 2])));
/// AKA: GDAKA22MIJPMLZ3CPS6TU5UWIO55WIYSELS6M3HAP42JP3OSD7NUBXBX
static immutable AKA = KeyPair(PublicKey(Point([192, 160, 107, 76, 66, 94, 197, 231, 98, 124, 189, 58, 118, 150, 67, 187, 219, 35, 18, 34, 229, 230, 108, 224, 127, 52, 151, 237, 210, 31, 219, 64])), SecretKey(Scalar([157, 134, 246, 166, 58, 211, 106, 203, 252, 29, 126, 55, 101, 191, 32, 132, 83, 210, 42, 195, 67, 169, 217, 245, 114, 151, 37, 242, 217, 51, 250, 3])));
/// AKB: GDAKB22B7KD6XY6SBQ64YVOM7J3HRP6ZWJLHW45Z5A56GAPUTA74CHSA
static immutable AKB = KeyPair(PublicKey(Point([192, 160, 235, 65, 250, 135, 235, 227, 210, 12, 61, 204, 85, 204, 250, 118, 120, 191, 217, 178, 86, 123, 115, 185, 232, 59, 227, 1, 244, 152, 63, 193])), SecretKey(Scalar([2, 254, 88, 132, 33, 6, 154, 177, 59, 71, 51, 10, 160, 14, 110, 133, 56, 8, 86, 125, 220, 21, 231, 126, 37, 120, 32, 154, 80, 52, 163, 5])));
/// AKC: GDAKC22NC2PGJ2Z2YIXNPE63VM7WFBHAS7VWT2H5JMMILNHRRXAIXHAI
static immutable AKC = KeyPair(PublicKey(Point([192, 161, 107, 77, 22, 158, 100, 235, 58, 194, 46, 215, 147, 219, 171, 63, 98, 132, 224, 151, 235, 105, 232, 253, 75, 24, 133, 180, 241, 141, 192, 139])), SecretKey(Scalar([217, 211, 130, 246, 157, 201, 255, 101, 160, 159, 42, 243, 207, 245, 208, 181, 35, 89, 174, 166, 202, 127, 224, 174, 84, 160, 110, 13, 68, 81, 51, 6])));
/// AKD: GDAKD22KUAU2PXAYEXFDIJ6IPF7YNPQVW5AZUZ7YLSCWQ5BH2ZL6V5NB
static immutable AKD = KeyPair(PublicKey(Point([192, 161, 235, 74, 160, 41, 167, 220, 24, 37, 202, 52, 39, 200, 121, 127, 134, 190, 21, 183, 65, 154, 103, 248, 92, 133, 104, 116, 39, 214, 87, 234])), SecretKey(Scalar([115, 180, 209, 63, 40, 134, 111, 246, 99, 244, 66, 20, 123, 119, 168, 136, 153, 186, 190, 183, 239, 161, 78, 190, 66, 110, 171, 198, 9, 167, 188, 7])));
/// AKE: GDAKE22EBNFQXBFF6I7LF3CURQSSKH3GQT2Q46PYFFBCRGIHPFVDAUE4
static immutable AKE = KeyPair(PublicKey(Point([192, 162, 107, 68, 11, 75, 11, 132, 165, 242, 62, 178, 236, 84, 140, 37, 37, 31, 102, 132, 245, 14, 121, 248, 41, 66, 40, 153, 7, 121, 106, 48])), SecretKey(Scalar([38, 47, 45, 232, 252, 145, 44, 159, 197, 129, 179, 70, 127, 133, 217, 220, 23, 230, 137, 75, 86, 140, 138, 247, 234, 234, 72, 90, 242, 230, 45, 14])));
/// AKF: GDAKF22P6FTJYBG4C3ECXQQUZP47SJYSEUIPMSRQR6C3RCJ2JEJTDO6P
static immutable AKF = KeyPair(PublicKey(Point([192, 162, 235, 79, 241, 102, 156, 4, 220, 22, 200, 43, 194, 20, 203, 249, 249, 39, 18, 37, 16, 246, 74, 48, 143, 133, 184, 137, 58, 73, 19, 49])), SecretKey(Scalar([191, 80, 229, 91, 221, 135, 230, 176, 124, 231, 17, 63, 224, 77, 254, 123, 189, 49, 104, 100, 33, 102, 79, 236, 97, 108, 148, 112, 135, 164, 237, 8])));
/// AKG: GDAKG22ULLY2W2NOREVG2ZMFHPEVZHYFEXRCGCYPNEB3TDU3RGIPUWN3
static immutable AKG = KeyPair(PublicKey(Point([192, 163, 107, 84, 90, 241, 171, 105, 174, 137, 42, 109, 101, 133, 59, 201, 92, 159, 5, 37, 226, 35, 11, 15, 105, 3, 185, 142, 155, 137, 144, 250])), SecretKey(Scalar([70, 194, 55, 114, 241, 156, 70, 112, 162, 10, 222, 214, 219, 236, 61, 29, 117, 177, 147, 126, 233, 41, 182, 214, 123, 243, 24, 125, 34, 194, 218, 8])));
/// AKH: GDAKH2244P7HLM4RHD7A6KTJPWT47KTZJTDRPLJWP6FCSFMIFO7XWY6M
static immutable AKH = KeyPair(PublicKey(Point([192, 163, 235, 92, 227, 254, 117, 179, 145, 56, 254, 15, 42, 105, 125, 167, 207, 170, 121, 76, 199, 23, 173, 54, 127, 138, 41, 21, 136, 43, 191, 123])), SecretKey(Scalar([249, 164, 160, 133, 116, 168, 102, 125, 124, 240, 175, 153, 47, 157, 207, 80, 34, 236, 36, 0, 91, 219, 34, 151, 156, 232, 244, 72, 211, 24, 12, 10])));
/// AKI: GDAKI22VM3LEWPTGUQE46XAYIXCF2WYKSQ5AELQOPLOUYH5Z5JWMYJRN
static immutable AKI = KeyPair(PublicKey(Point([192, 164, 107, 85, 102, 214, 75, 62, 102, 164, 9, 207, 92, 24, 69, 196, 93, 91, 10, 148, 58, 2, 46, 14, 122, 221, 76, 31, 185, 234, 108, 204])), SecretKey(Scalar([119, 196, 5, 122, 79, 9, 24, 192, 113, 164, 44, 48, 235, 126, 108, 169, 229, 2, 164, 46, 247, 120, 158, 128, 224, 160, 162, 199, 122, 71, 49, 12])));
/// AKJ: GDAKJ22ZXVXM2V2TWWUG2GLEFLTRDYMHZZ3A4DHTPCY6RV7POX4CFSIY
static immutable AKJ = KeyPair(PublicKey(Point([192, 164, 235, 89, 189, 110, 205, 87, 83, 181, 168, 109, 25, 100, 42, 231, 17, 225, 135, 206, 118, 14, 12, 243, 120, 177, 232, 215, 239, 117, 248, 34])), SecretKey(Scalar([139, 147, 188, 103, 167, 18, 64, 51, 41, 212, 141, 69, 152, 50, 93, 107, 42, 139, 80, 127, 112, 147, 68, 183, 241, 71, 150, 87, 170, 116, 198, 6])));
/// AKK: GDAKK22NIGND3UV5EHMOTZESLZBI6HYW23SSDTS6JA3DG7BSEQV43RJJ
static immutable AKK = KeyPair(PublicKey(Point([192, 165, 107, 77, 65, 154, 61, 210, 189, 33, 216, 233, 228, 146, 94, 66, 143, 31, 22, 214, 229, 33, 206, 94, 72, 54, 51, 124, 50, 36, 43, 205])), SecretKey(Scalar([32, 134, 125, 54, 234, 122, 251, 219, 23, 86, 183, 51, 68, 133, 215, 57, 156, 99, 126, 70, 180, 113, 30, 182, 33, 249, 211, 188, 80, 65, 85, 2])));
/// AKL: GDAKL225AWIGGQHCE6TPF55QXCFQMQNOTUEP3ZGLQ52XPAUC6KMS62AG
static immutable AKL = KeyPair(PublicKey(Point([192, 165, 235, 93, 5, 144, 99, 64, 226, 39, 166, 242, 247, 176, 184, 139, 6, 65, 174, 157, 8, 253, 228, 203, 135, 117, 119, 130, 130, 242, 153, 47])), SecretKey(Scalar([105, 30, 245, 159, 218, 26, 241, 90, 212, 7, 234, 232, 160, 116, 38, 81, 170, 113, 207, 137, 151, 13, 169, 166, 122, 14, 236, 95, 149, 163, 184, 9])));
/// AKM: GDAKM22WQ4WGLESMBZWVDCC7IP2EEWVU6ZXFANQSMB6PX5JD4OYRJLXG
static immutable AKM = KeyPair(PublicKey(Point([192, 166, 107, 86, 135, 44, 101, 146, 76, 14, 109, 81, 136, 95, 67, 244, 66, 90, 180, 246, 110, 80, 54, 18, 96, 124, 251, 245, 35, 227, 177, 20])), SecretKey(Scalar([194, 31, 116, 0, 139, 186, 148, 29, 87, 240, 106, 212, 73, 192, 3, 164, 45, 26, 12, 219, 175, 139, 17, 193, 77, 177, 251, 192, 90, 58, 187, 5])));
/// AKN: GDAKN22HRMQMZ7MZKXGJLN6NWUM2UJK37OS47ERS236WS77NDSPTBFCX
static immutable AKN = KeyPair(PublicKey(Point([192, 166, 235, 71, 139, 32, 204, 253, 153, 85, 204, 149, 183, 205, 181, 25, 170, 37, 91, 251, 165, 207, 146, 50, 214, 253, 105, 127, 237, 28, 159, 48])), SecretKey(Scalar([56, 224, 168, 55, 61, 186, 87, 238, 185, 36, 52, 150, 169, 48, 176, 205, 74, 7, 100, 135, 24, 100, 221, 10, 2, 235, 83, 88, 0, 226, 189, 0])));
/// AKO: GDAKO22F7GWNXUS2JDQVHHWINP2DLS6CWFPUVQTYEDOIZQMA7225O3FR
static immutable AKO = KeyPair(PublicKey(Point([192, 167, 107, 69, 249, 172, 219, 210, 90, 72, 225, 83, 158, 200, 107, 244, 53, 203, 194, 177, 95, 74, 194, 120, 32, 220, 140, 193, 128, 254, 181, 215])), SecretKey(Scalar([211, 217, 65, 40, 26, 52, 222, 200, 194, 17, 87, 179, 8, 149, 216, 165, 195, 19, 204, 242, 151, 184, 96, 235, 173, 186, 8, 149, 153, 232, 246, 13])));
/// AKP: GDAKP22DQA32IIW5JO7RE4LJF4TWUJ3ZR42IRZI4QJQDYVT7NHIZRYDC
static immutable AKP = KeyPair(PublicKey(Point([192, 167, 235, 67, 128, 55, 164, 34, 221, 75, 191, 18, 113, 105, 47, 39, 106, 39, 121, 143, 52, 136, 229, 28, 130, 96, 60, 86, 127, 105, 209, 152])), SecretKey(Scalar([89, 101, 88, 52, 151, 42, 248, 168, 179, 186, 50, 166, 112, 195, 144, 0, 63, 99, 127, 134, 17, 153, 160, 54, 17, 220, 246, 157, 171, 157, 3, 0])));
/// AKQ: GDAKQ22HWW5NYECIJQURXDANJPWSTLB6VIZLWI5VZIGYW2V24AYDH2UG
static immutable AKQ = KeyPair(PublicKey(Point([192, 168, 107, 71, 181, 186, 220, 16, 72, 76, 41, 27, 140, 13, 75, 237, 41, 172, 62, 170, 50, 187, 35, 181, 202, 13, 139, 106, 186, 224, 48, 51])), SecretKey(Scalar([21, 29, 51, 156, 158, 72, 213, 84, 108, 167, 74, 80, 219, 101, 118, 146, 203, 194, 231, 66, 95, 238, 231, 180, 29, 247, 208, 202, 12, 102, 200, 0])));
/// AKR: GDAKR22RP66MBVAQ23XLG3X4JVYCU3AOIH5R4JZJ5YXJRJS3NY32JZTL
static immutable AKR = KeyPair(PublicKey(Point([192, 168, 235, 81, 127, 188, 192, 212, 16, 214, 238, 179, 110, 252, 77, 112, 42, 108, 14, 65, 251, 30, 39, 41, 238, 46, 152, 166, 91, 110, 55, 164])), SecretKey(Scalar([192, 80, 123, 129, 67, 111, 126, 93, 245, 154, 10, 188, 51, 68, 162, 195, 131, 193, 44, 67, 124, 104, 223, 88, 178, 241, 148, 30, 158, 77, 121, 7])));
/// AKS: GDAKS223N4DSYPRI62YAN4QFOK4MXTSGCRMTC4S5CG2NMDN5E5TL3PQS
static immutable AKS = KeyPair(PublicKey(Point([192, 169, 107, 91, 111, 7, 44, 62, 40, 246, 176, 6, 242, 5, 114, 184, 203, 206, 70, 20, 89, 49, 114, 93, 17, 180, 214, 13, 189, 39, 102, 189])), SecretKey(Scalar([85, 96, 254, 120, 8, 186, 176, 167, 214, 30, 125, 215, 79, 159, 53, 149, 209, 192, 31, 210, 18, 162, 98, 77, 80, 200, 98, 6, 255, 226, 195, 14])));
/// AKT: GDAKT22HSA5QHBSCZDJSB7B5JMS4KDTP5CGAM6JFXLFS2VDJIUIRUHSH
static immutable AKT = KeyPair(PublicKey(Point([192, 169, 235, 71, 144, 59, 3, 134, 66, 200, 211, 32, 252, 61, 75, 37, 197, 14, 111, 232, 140, 6, 121, 37, 186, 203, 45, 84, 105, 69, 17, 26])), SecretKey(Scalar([237, 83, 58, 56, 30, 226, 153, 144, 201, 113, 202, 149, 50, 187, 217, 116, 15, 98, 61, 90, 66, 114, 160, 136, 177, 190, 11, 226, 163, 31, 216, 15])));
/// AKU: GDAKU22CRH67IP7LDEUUR4S7ZBBMFDJVSW4ZXOBLFQIN2LZ2NHFKG7AQ
static immutable AKU = KeyPair(PublicKey(Point([192, 170, 107, 66, 137, 253, 244, 63, 235, 25, 41, 72, 242, 95, 200, 66, 194, 141, 53, 149, 185, 155, 184, 43, 44, 16, 221, 47, 58, 105, 202, 163])), SecretKey(Scalar([203, 195, 174, 200, 37, 134, 113, 107, 148, 129, 228, 255, 13, 107, 67, 226, 214, 200, 224, 200, 201, 82, 172, 150, 225, 178, 22, 18, 80, 56, 230, 4])));
/// AKV: GDAKV22RMAIVQF4GE3Y5ETVUXL45LVRCDRDFWSUIGOSKUM4ZDZWP555N
static immutable AKV = KeyPair(PublicKey(Point([192, 170, 235, 81, 96, 17, 88, 23, 134, 38, 241, 210, 78, 180, 186, 249, 213, 214, 34, 28, 70, 91, 74, 136, 51, 164, 170, 51, 153, 30, 108, 254])), SecretKey(Scalar([94, 162, 31, 122, 19, 115, 183, 69, 22, 24, 128, 9, 108, 224, 42, 119, 129, 223, 130, 94, 96, 136, 55, 176, 151, 138, 215, 240, 225, 181, 145, 12])));
/// AKW: GDAKW2273JAKCW3X2TBIRMUDYFQ67XAA4FMJZ5DFKBPRD6ABYFU2VIUC
static immutable AKW = KeyPair(PublicKey(Point([192, 171, 107, 95, 218, 64, 161, 91, 119, 212, 194, 136, 178, 131, 193, 97, 239, 220, 0, 225, 88, 156, 244, 101, 80, 95, 17, 248, 1, 193, 105, 170])), SecretKey(Scalar([243, 156, 140, 126, 208, 89, 3, 132, 193, 5, 245, 234, 213, 111, 52, 137, 108, 34, 240, 178, 138, 176, 170, 11, 157, 253, 166, 230, 9, 33, 63, 11])));
/// AKX: GDAKX22GXWO7ZY3H4SV576MJ7ULUWI747EMZJCXWOJL6KYLMBGBO6D6T
static immutable AKX = KeyPair(PublicKey(Point([192, 171, 235, 70, 189, 157, 252, 227, 103, 228, 171, 223, 249, 137, 253, 23, 75, 35, 252, 249, 25, 148, 138, 246, 114, 87, 229, 97, 108, 9, 130, 239])), SecretKey(Scalar([253, 209, 37, 164, 214, 57, 46, 124, 129, 57, 22, 32, 120, 155, 208, 69, 69, 81, 181, 123, 22, 78, 32, 99, 255, 225, 97, 89, 15, 191, 117, 5])));
/// AKY: GDAKY22JCRCS63R3SGPIMGBPOIG7PTDHJOCOXS47JZZYOZV6SNJYQPKH
static immutable AKY = KeyPair(PublicKey(Point([192, 172, 107, 73, 20, 69, 47, 110, 59, 145, 158, 134, 24, 47, 114, 13, 247, 204, 103, 75, 132, 235, 203, 159, 78, 115, 135, 102, 190, 147, 83, 136])), SecretKey(Scalar([65, 142, 24, 229, 157, 199, 111, 123, 19, 242, 127, 183, 211, 183, 29, 169, 221, 145, 137, 175, 227, 238, 123, 189, 175, 156, 88, 73, 52, 151, 68, 15])));
/// AKZ: GDAKZ226565PCDQ6RDPNUWRZSYB2ZGZDP2JBL4AOK3MNGOAP2FTKHAVI
static immutable AKZ = KeyPair(PublicKey(Point([192, 172, 235, 94, 239, 186, 241, 14, 30, 136, 222, 218, 90, 57, 150, 3, 172, 155, 35, 126, 146, 21, 240, 14, 86, 216, 211, 56, 15, 209, 102, 163])), SecretKey(Scalar([215, 83, 71, 185, 237, 52, 72, 220, 41, 21, 169, 49, 11, 96, 162, 111, 94, 121, 77, 145, 195, 58, 132, 80, 191, 106, 147, 131, 171, 253, 69, 7])));
/// ALA: GDALA227H7OGQIPMGFN5SWIP3F6YQLFFZHLONVM3WIRFV7MKSUHKWMCH
static immutable ALA = KeyPair(PublicKey(Point([192, 176, 107, 95, 63, 220, 104, 33, 236, 49, 91, 217, 89, 15, 217, 125, 136, 44, 165, 201, 214, 230, 213, 155, 178, 34, 90, 253, 138, 149, 14, 171])), SecretKey(Scalar([119, 50, 23, 250, 27, 163, 103, 19, 46, 47, 115, 250, 194, 207, 53, 119, 226, 90, 45, 0, 73, 46, 35, 96, 83, 87, 13, 24, 97, 69, 72, 10])));
/// ALB: GDALB22E4YVDQ5LW2JMAPVAYZBBK6433WUVQIHDJBUUJNCBTVLDCRNNE
static immutable ALB = KeyPair(PublicKey(Point([192, 176, 235, 68, 230, 42, 56, 117, 118, 210, 88, 7, 212, 24, 200, 66, 175, 115, 123, 181, 43, 4, 28, 105, 13, 40, 150, 136, 51, 170, 198, 40])), SecretKey(Scalar([85, 230, 220, 143, 160, 170, 118, 109, 125, 253, 76, 27, 23, 171, 27, 69, 210, 16, 204, 192, 246, 9, 239, 78, 105, 251, 234, 114, 125, 173, 254, 6])));
/// ALC: GDALC22JEW72QR6BKEVUPUM3EF65H2HMT2G6RIBT47WQEV5HKQO4M5SL
static immutable ALC = KeyPair(PublicKey(Point([192, 177, 107, 73, 37, 191, 168, 71, 193, 81, 43, 71, 209, 155, 33, 125, 211, 232, 236, 158, 141, 232, 160, 51, 231, 237, 2, 87, 167, 84, 29, 198])), SecretKey(Scalar([237, 104, 176, 187, 23, 216, 250, 140, 157, 59, 186, 190, 106, 212, 23, 161, 13, 171, 9, 117, 6, 4, 153, 23, 40, 177, 196, 130, 146, 138, 169, 2])));
/// ALD: GDALD22Y3YGMAH22BOLXSFSPBEAM6C2BUJOY3MZATW57BWIZQCOPJTQU
static immutable ALD = KeyPair(PublicKey(Point([192, 177, 235, 88, 222, 12, 192, 31, 90, 11, 151, 121, 22, 79, 9, 0, 207, 11, 65, 162, 93, 141, 179, 32, 157, 187, 240, 217, 25, 128, 156, 244])), SecretKey(Scalar([200, 188, 181, 208, 16, 67, 149, 202, 59, 110, 17, 48, 0, 160, 122, 81, 241, 137, 138, 200, 197, 246, 40, 210, 149, 79, 99, 238, 29, 204, 251, 0])));
/// ALE: GDALE22SDVKMHZBDGHID7FDNP7KH5ZSJNBGEVJDJSKQGUNFEJRRWL7QD
static immutable ALE = KeyPair(PublicKey(Point([192, 178, 107, 82, 29, 84, 195, 228, 35, 49, 208, 63, 148, 109, 127, 212, 126, 230, 73, 104, 76, 74, 164, 105, 146, 160, 106, 52, 164, 76, 99, 101])), SecretKey(Scalar([196, 226, 215, 235, 65, 24, 89, 183, 114, 85, 89, 240, 174, 178, 25, 138, 92, 25, 146, 39, 134, 120, 29, 91, 103, 106, 154, 212, 34, 61, 223, 3])));
/// ALF: GDALF22CU4DGWJ35OYFBQOWTIJSE6ZD7YH3HD2L23WJODZUAGS2U2KKF
static immutable ALF = KeyPair(PublicKey(Point([192, 178, 235, 66, 167, 6, 107, 39, 125, 118, 10, 24, 58, 211, 66, 100, 79, 100, 127, 193, 246, 113, 233, 122, 221, 146, 225, 230, 128, 52, 181, 77])), SecretKey(Scalar([7, 166, 231, 45, 37, 3, 204, 214, 198, 200, 162, 245, 252, 146, 176, 146, 154, 4, 229, 6, 128, 49, 174, 255, 6, 158, 79, 161, 101, 149, 26, 1])));
/// ALG: GDALG22A7KRUNSFH5EHW27MN3IOXZ32JTWXB57OVGH6CZVVFJ37YJ45L
static immutable ALG = KeyPair(PublicKey(Point([192, 179, 107, 64, 250, 163, 70, 200, 167, 233, 15, 109, 125, 141, 218, 29, 124, 239, 73, 157, 174, 30, 253, 213, 49, 252, 44, 214, 165, 78, 255, 132])), SecretKey(Scalar([23, 242, 40, 68, 129, 219, 247, 102, 244, 60, 121, 27, 34, 217, 240, 137, 170, 161, 88, 169, 235, 68, 228, 162, 66, 178, 64, 137, 1, 164, 240, 1])));
/// ALH: GDALH22GRY3UHBKVS7WIMN6JALP6R3GSVZLKMROCV2U3CJKFKIK4KU27
static immutable ALH = KeyPair(PublicKey(Point([192, 179, 235, 70, 142, 55, 67, 133, 85, 151, 236, 134, 55, 201, 2, 223, 232, 236, 210, 174, 86, 166, 69, 194, 174, 169, 177, 37, 69, 82, 21, 197])), SecretKey(Scalar([102, 125, 78, 114, 165, 231, 226, 70, 49, 168, 38, 56, 108, 244, 31, 206, 122, 78, 212, 157, 20, 99, 239, 3, 92, 144, 71, 105, 236, 157, 119, 7])));
/// ALI: GDALI22VNZQLMUKFYBBDSDFB6WK36T7EF3QFKS6BPLDSGJNGLIWWVWQ4
static immutable ALI = KeyPair(PublicKey(Point([192, 180, 107, 85, 110, 96, 182, 81, 69, 192, 66, 57, 12, 161, 245, 149, 191, 79, 228, 46, 224, 85, 75, 193, 122, 199, 35, 37, 166, 90, 45, 106])), SecretKey(Scalar([148, 130, 134, 17, 139, 84, 113, 39, 222, 230, 227, 14, 28, 4, 44, 164, 193, 38, 206, 101, 139, 248, 62, 44, 212, 189, 63, 135, 2, 24, 241, 4])));
/// ALJ: GDALJ22CREWCZ7EFAKSYULWPEJY7XVQY3V7SLVIJGSHSV6QUE65FWGEB
static immutable ALJ = KeyPair(PublicKey(Point([192, 180, 235, 66, 137, 44, 44, 252, 133, 2, 165, 138, 46, 207, 34, 113, 251, 214, 24, 221, 127, 37, 213, 9, 52, 143, 42, 250, 20, 39, 186, 91])), SecretKey(Scalar([208, 172, 204, 210, 212, 104, 210, 102, 181, 154, 3, 254, 213, 244, 121, 249, 37, 2, 181, 4, 25, 248, 38, 101, 91, 128, 64, 240, 110, 240, 125, 5])));
/// ALK: GDALK22ATMIQQCZT3RTYHF2QL6UZ4NL5KFKSETI267YWCIN4MLDMO525
static immutable ALK = KeyPair(PublicKey(Point([192, 181, 107, 64, 155, 17, 8, 11, 51, 220, 103, 131, 151, 80, 95, 169, 158, 53, 125, 81, 85, 34, 77, 26, 247, 241, 97, 33, 188, 98, 198, 199])), SecretKey(Scalar([25, 62, 226, 200, 235, 49, 158, 64, 146, 61, 91, 84, 39, 243, 3, 5, 110, 117, 139, 33, 232, 121, 12, 22, 57, 102, 65, 49, 221, 226, 201, 4])));
/// ALL: GDALL2234HGNOZCPN66BNAPEW5GUMPWCXUWKR52CTKA4WD3KNJKSEDWR
static immutable ALL = KeyPair(PublicKey(Point([192, 181, 235, 91, 225, 204, 215, 100, 79, 111, 188, 22, 129, 228, 183, 77, 70, 62, 194, 189, 44, 168, 247, 66, 154, 129, 203, 15, 106, 106, 85, 34])), SecretKey(Scalar([96, 189, 196, 7, 117, 111, 104, 27, 206, 3, 225, 149, 83, 122, 15, 116, 242, 1, 238, 34, 113, 32, 50, 135, 96, 137, 93, 69, 251, 188, 143, 4])));
/// ALM: GDALM22WGDR5LGK2ECNF5UIG7A745OBGJA2VKAMIQHQM4H2P4BQBYA7T
static immutable ALM = KeyPair(PublicKey(Point([192, 182, 107, 86, 48, 227, 213, 153, 90, 32, 154, 94, 209, 6, 248, 63, 206, 184, 38, 72, 53, 85, 1, 136, 129, 224, 206, 31, 79, 224, 96, 28])), SecretKey(Scalar([117, 226, 248, 66, 8, 137, 247, 203, 171, 37, 106, 129, 115, 232, 11, 189, 139, 194, 37, 238, 108, 27, 15, 199, 27, 193, 44, 205, 58, 157, 137, 1])));
/// ALN: GDALN22S63VQIHNNZYQVPIUXJPMYKVLMIGRC6URIOYYID7G4QCC7MIRF
static immutable ALN = KeyPair(PublicKey(Point([192, 182, 235, 82, 246, 235, 4, 29, 173, 206, 33, 87, 162, 151, 75, 217, 133, 85, 108, 65, 162, 47, 82, 40, 118, 48, 129, 252, 220, 128, 133, 246])), SecretKey(Scalar([117, 167, 81, 129, 247, 6, 208, 225, 65, 4, 91, 97, 73, 123, 29, 4, 246, 29, 58, 34, 241, 143, 51, 48, 204, 137, 76, 147, 235, 177, 220, 12])));
/// ALO: GDALO22U7B52UPVUWUDG4KTLYZF74M2TDYMOYQ4BB3OOT4JTENQBGG7D
static immutable ALO = KeyPair(PublicKey(Point([192, 183, 107, 84, 248, 123, 170, 62, 180, 181, 6, 110, 42, 107, 198, 75, 254, 51, 83, 30, 24, 236, 67, 129, 14, 220, 233, 241, 51, 35, 96, 19])), SecretKey(Scalar([165, 68, 242, 194, 13, 100, 96, 165, 189, 0, 202, 74, 161, 38, 127, 48, 214, 109, 19, 169, 14, 212, 119, 222, 181, 150, 82, 219, 0, 128, 204, 8])));
/// ALP: GDALP22X26AV2OQSJVF3YPDMOCGKVHCY2S42C4VY3ZZIC22CDEZA3TJP
static immutable ALP = KeyPair(PublicKey(Point([192, 183, 235, 87, 215, 129, 93, 58, 18, 77, 75, 188, 60, 108, 112, 140, 170, 156, 88, 212, 185, 161, 114, 184, 222, 114, 129, 107, 66, 25, 50, 13])), SecretKey(Scalar([198, 49, 189, 231, 172, 104, 88, 218, 50, 56, 69, 71, 72, 197, 156, 225, 50, 10, 16, 23, 36, 192, 120, 0, 158, 139, 141, 246, 39, 133, 116, 11])));
/// ALQ: GDALQ22WYBS6FR2NVHU4FAVPV5KMPHYJMZDVYZZRAOCPU5GIWNV36YXA
static immutable ALQ = KeyPair(PublicKey(Point([192, 184, 107, 86, 192, 101, 226, 199, 77, 169, 233, 194, 130, 175, 175, 84, 199, 159, 9, 102, 71, 92, 103, 49, 3, 132, 250, 116, 200, 179, 107, 191])), SecretKey(Scalar([118, 178, 116, 199, 72, 98, 232, 109, 124, 220, 244, 150, 198, 203, 31, 194, 33, 134, 164, 87, 142, 92, 5, 20, 250, 115, 46, 202, 73, 38, 88, 4])));
/// ALR: GDALR22TCN5RE54JQGXTIIJDEOXNRDQNW4QOHO3RK2OJ3FQYM4D4SZRN
static immutable ALR = KeyPair(PublicKey(Point([192, 184, 235, 83, 19, 123, 18, 119, 137, 129, 175, 52, 33, 35, 35, 174, 216, 142, 13, 183, 32, 227, 187, 113, 86, 156, 157, 150, 24, 103, 7, 201])), SecretKey(Scalar([153, 164, 118, 210, 49, 55, 72, 116, 7, 72, 241, 198, 149, 135, 223, 128, 239, 42, 212, 235, 225, 244, 234, 134, 0, 10, 219, 142, 184, 114, 115, 4])));
/// ALS: GDALS22S76GY24MRCRSCTRLROHDIKHURFPKMHU5RCYY47XEWARVTD3TE
static immutable ALS = KeyPair(PublicKey(Point([192, 185, 107, 82, 255, 141, 141, 113, 145, 20, 100, 41, 197, 113, 113, 198, 133, 30, 145, 43, 212, 195, 211, 177, 22, 49, 207, 220, 150, 4, 107, 49])), SecretKey(Scalar([169, 72, 213, 227, 152, 175, 244, 133, 219, 178, 88, 6, 181, 37, 186, 104, 215, 156, 33, 180, 42, 86, 79, 228, 58, 243, 123, 139, 88, 253, 234, 6])));
/// ALT: GDALT223U6XV52BPDE64C5F373P6SJWHEPJ67APOVTBOD6WRKWT77VAS
static immutable ALT = KeyPair(PublicKey(Point([192, 185, 235, 91, 167, 175, 94, 232, 47, 25, 61, 193, 116, 187, 254, 223, 233, 38, 199, 35, 211, 239, 129, 238, 172, 194, 225, 250, 209, 85, 167, 255])), SecretKey(Scalar([109, 233, 26, 170, 30, 114, 168, 121, 107, 47, 99, 203, 228, 187, 218, 44, 32, 17, 207, 252, 42, 150, 92, 153, 155, 83, 168, 103, 147, 175, 133, 5])));
/// ALU: GDALU22JXPS2F63XTXD5P2YRIO4DLIPB65PCKKXAYRPF43Z6MDZ4DCCL
static immutable ALU = KeyPair(PublicKey(Point([192, 186, 107, 73, 187, 229, 162, 251, 119, 157, 199, 215, 235, 17, 67, 184, 53, 161, 225, 247, 94, 37, 42, 224, 196, 94, 94, 111, 62, 96, 243, 193])), SecretKey(Scalar([145, 17, 247, 152, 217, 198, 146, 195, 219, 245, 137, 161, 138, 52, 4, 30, 125, 172, 214, 221, 187, 218, 22, 179, 71, 164, 11, 117, 72, 180, 253, 8])));
/// ALV: GDALV22GGTV4AJT3HEJ3DKSHW22SFVPJRIY3EUVUDDUJXBSO4RTWJNGR
static immutable ALV = KeyPair(PublicKey(Point([192, 186, 235, 70, 52, 235, 192, 38, 123, 57, 19, 177, 170, 71, 182, 181, 34, 213, 233, 138, 49, 178, 82, 180, 24, 232, 155, 134, 78, 228, 103, 100])), SecretKey(Scalar([251, 241, 190, 187, 76, 14, 127, 13, 78, 72, 92, 195, 63, 106, 44, 54, 27, 228, 46, 133, 107, 141, 174, 118, 151, 108, 195, 228, 25, 250, 51, 14])));
/// ALW: GDALW222N3K76I4WWO5HDT2GRKHWLCZMUABZWMZWYBXCERJXSCZGJHZU
static immutable ALW = KeyPair(PublicKey(Point([192, 187, 107, 90, 110, 213, 255, 35, 150, 179, 186, 113, 207, 70, 138, 143, 101, 139, 44, 160, 3, 155, 51, 54, 192, 110, 34, 69, 55, 144, 178, 100])), SecretKey(Scalar([189, 214, 70, 121, 52, 81, 245, 171, 191, 135, 153, 155, 254, 171, 65, 208, 67, 115, 123, 230, 45, 177, 99, 105, 237, 213, 31, 177, 15, 54, 232, 0])));
/// ALX: GDALX22ZIMYEMJVTZ2EL5B2DH4MQ3OAHKBZP22UUJXVMHF5LMAU5MBYI
static immutable ALX = KeyPair(PublicKey(Point([192, 187, 235, 89, 67, 48, 70, 38, 179, 206, 136, 190, 135, 67, 63, 25, 13, 184, 7, 80, 114, 253, 106, 148, 77, 234, 195, 151, 171, 96, 41, 214])), SecretKey(Scalar([21, 241, 146, 199, 13, 133, 197, 166, 211, 7, 20, 78, 31, 12, 76, 193, 178, 207, 242, 247, 95, 172, 213, 161, 144, 157, 235, 59, 203, 111, 108, 9])));
/// ALY: GDALY22L3AQSQDBPCRM472GTJS7NQB3PXA52IO7BVWWHRQAIQU7AV5TO
static immutable ALY = KeyPair(PublicKey(Point([192, 188, 107, 75, 216, 33, 40, 12, 47, 20, 89, 207, 232, 211, 76, 190, 216, 7, 111, 184, 59, 164, 59, 225, 173, 172, 120, 192, 8, 133, 62, 10])), SecretKey(Scalar([182, 7, 88, 146, 7, 61, 141, 21, 114, 35, 187, 202, 138, 85, 125, 4, 32, 55, 106, 139, 17, 80, 58, 183, 242, 58, 133, 28, 180, 155, 208, 15])));
/// ALZ: GDALZ22YVUIJPKVUEJYFBALERQQVCXHUUMTHR56ECOLHQCT5ZZDRFSI2
static immutable ALZ = KeyPair(PublicKey(Point([192, 188, 235, 88, 173, 16, 151, 170, 180, 34, 112, 80, 129, 100, 140, 33, 81, 92, 244, 163, 38, 120, 247, 196, 19, 150, 120, 10, 125, 206, 71, 18])), SecretKey(Scalar([128, 125, 251, 216, 78, 102, 33, 113, 168, 177, 49, 124, 79, 163, 38, 215, 166, 140, 187, 34, 152, 85, 60, 158, 194, 72, 21, 140, 204, 88, 33, 6])));
/// AMA: GDAMA22OMTICB7URQWLMDYZEH3SUHZO7B5HBZXTFLOFWV5GOVTMLKFI3
static immutable AMA = KeyPair(PublicKey(Point([192, 192, 107, 78, 100, 208, 32, 254, 145, 133, 150, 193, 227, 36, 62, 229, 67, 229, 223, 15, 78, 28, 222, 101, 91, 139, 106, 244, 206, 172, 216, 181])), SecretKey(Scalar([32, 173, 9, 177, 46, 84, 229, 175, 63, 230, 229, 157, 217, 205, 23, 44, 85, 56, 84, 26, 41, 53, 126, 247, 89, 130, 187, 253, 116, 178, 118, 6])));
/// AMB: GDAMB22PK6BMZI5IUVYQMLN4PRDZBCH3XXXGQMNWREC5VM53EG3RVO7Y
static immutable AMB = KeyPair(PublicKey(Point([192, 192, 235, 79, 87, 130, 204, 163, 168, 165, 113, 6, 45, 188, 124, 71, 144, 136, 251, 189, 238, 104, 49, 182, 137, 5, 218, 179, 187, 33, 183, 26])), SecretKey(Scalar([43, 37, 141, 55, 173, 4, 84, 182, 99, 213, 43, 228, 61, 93, 166, 154, 101, 217, 38, 46, 155, 21, 159, 63, 152, 244, 171, 57, 211, 207, 176, 3])));
/// AMC: GDAMC22YE32XEQWDNQPI3W4TEVZJDDG2GHOK6GZ3IIYTHGLZ7A7AE5ZW
static immutable AMC = KeyPair(PublicKey(Point([192, 193, 107, 88, 38, 245, 114, 66, 195, 108, 30, 141, 219, 147, 37, 114, 145, 140, 218, 49, 220, 175, 27, 59, 66, 49, 51, 153, 121, 248, 62, 2])), SecretKey(Scalar([41, 42, 85, 172, 120, 70, 202, 177, 195, 50, 152, 219, 213, 76, 236, 168, 53, 243, 218, 56, 9, 117, 168, 114, 47, 99, 84, 95, 181, 72, 14, 0])));
/// AMD: GDAMD22FMFGAPGC6R5UBGF7PIWX25PYP3JCZZX3GPCMCAQAHHFH4NN3G
static immutable AMD = KeyPair(PublicKey(Point([192, 193, 235, 69, 97, 76, 7, 152, 94, 143, 104, 19, 23, 239, 69, 175, 174, 191, 15, 218, 69, 156, 223, 102, 120, 152, 32, 64, 7, 57, 79, 198])), SecretKey(Scalar([192, 23, 71, 29, 17, 9, 221, 221, 36, 241, 140, 251, 248, 107, 104, 58, 84, 166, 37, 241, 129, 87, 124, 207, 45, 45, 87, 245, 224, 228, 100, 1])));
/// AME: GDAME22GJCQUQQFAKV7WQV3ZWG2VCT4DK6ITVB54CWPAEG5TQBOHT7I7
static immutable AME = KeyPair(PublicKey(Point([192, 194, 107, 70, 72, 161, 72, 64, 160, 85, 127, 104, 87, 121, 177, 181, 81, 79, 131, 87, 145, 58, 135, 188, 21, 158, 2, 27, 179, 128, 92, 121])), SecretKey(Scalar([115, 18, 204, 47, 126, 99, 66, 125, 31, 203, 115, 42, 96, 247, 76, 155, 166, 63, 240, 95, 152, 139, 211, 87, 110, 215, 255, 87, 2, 220, 113, 11])));
/// AMF: GDAMF22DE6QJJCB57SUZNAKGXDIWYT4MRHZ26N5Y7INLIYG7IP5H6S5B
static immutable AMF = KeyPair(PublicKey(Point([192, 194, 235, 67, 39, 160, 148, 136, 61, 252, 169, 150, 129, 70, 184, 209, 108, 79, 140, 137, 243, 175, 55, 184, 250, 26, 180, 96, 223, 67, 250, 127])), SecretKey(Scalar([38, 169, 192, 22, 118, 126, 136, 101, 84, 81, 209, 121, 66, 179, 119, 234, 189, 47, 133, 86, 202, 213, 52, 219, 26, 64, 164, 130, 116, 37, 238, 14])));
/// AMG: GDAMG225ZYZ6ICWOBPWLAGM5KMVL35XDRSWE22CRB2SDVLUIL4QKGNZF
static immutable AMG = KeyPair(PublicKey(Point([192, 195, 107, 93, 206, 51, 228, 10, 206, 11, 236, 176, 25, 157, 83, 42, 189, 246, 227, 140, 172, 77, 104, 81, 14, 164, 58, 174, 136, 95, 32, 163])), SecretKey(Scalar([60, 78, 90, 105, 145, 33, 15, 167, 229, 49, 125, 172, 255, 110, 185, 111, 153, 225, 203, 100, 241, 123, 171, 190, 150, 11, 92, 47, 66, 213, 221, 15])));
/// AMH: GDAMH22NZLCDDAH7PLRVOCSRD77WSH5JHHAXKKJLRM2ROKNICS77NSR5
static immutable AMH = KeyPair(PublicKey(Point([192, 195, 235, 77, 202, 196, 49, 128, 255, 122, 227, 87, 10, 81, 31, 255, 105, 31, 169, 57, 193, 117, 41, 43, 139, 53, 23, 41, 168, 20, 191, 246])), SecretKey(Scalar([255, 143, 8, 212, 73, 75, 82, 194, 67, 41, 101, 109, 86, 242, 0, 170, 81, 255, 150, 61, 121, 50, 138, 87, 131, 162, 155, 246, 151, 115, 218, 0])));
/// AMI: GDAMI22EUFUXSI6V26MMG23VY6EFMEESZPZOY3KPVAL6MOIGIIYKRH44
static immutable AMI = KeyPair(PublicKey(Point([192, 196, 107, 68, 161, 105, 121, 35, 213, 215, 152, 195, 107, 117, 199, 136, 86, 16, 146, 203, 242, 236, 109, 79, 168, 23, 230, 57, 6, 66, 48, 168])), SecretKey(Scalar([209, 54, 149, 42, 163, 165, 6, 168, 74, 128, 20, 245, 218, 212, 246, 148, 204, 90, 212, 29, 224, 125, 205, 89, 45, 6, 163, 4, 197, 183, 75, 3])));
/// AMJ: GDAMJ22NKUZN7C3WOVIYP2WKAYILOJOWAWZPPPD2GV4VPCH6MUN3AMJT
static immutable AMJ = KeyPair(PublicKey(Point([192, 196, 235, 77, 85, 50, 223, 139, 118, 117, 81, 135, 234, 202, 6, 16, 183, 37, 214, 5, 178, 247, 188, 122, 53, 121, 87, 136, 254, 101, 27, 176])), SecretKey(Scalar([216, 239, 144, 219, 192, 236, 191, 141, 244, 103, 85, 188, 104, 144, 4, 79, 51, 113, 108, 161, 82, 248, 129, 239, 237, 125, 105, 11, 254, 26, 20, 2])));
/// AMK: GDAMK22N5HRW224P7CRC7Z6SEKNL6FRKAMCJIR7BE5TKR52VEV4DRLJ6
static immutable AMK = KeyPair(PublicKey(Point([192, 197, 107, 77, 233, 227, 109, 107, 143, 248, 162, 47, 231, 210, 34, 154, 191, 22, 42, 3, 4, 148, 71, 225, 39, 102, 168, 247, 85, 37, 120, 56])), SecretKey(Scalar([102, 58, 96, 110, 35, 44, 174, 97, 125, 84, 217, 57, 180, 158, 151, 156, 238, 170, 224, 152, 176, 38, 126, 136, 123, 205, 29, 131, 182, 6, 70, 3])));
/// AML: GDAML225T7JZESVT7D45UI2U2EZ2YB27QVG5LE2A3AEWBFFXRUYTZC4U
static immutable AML = KeyPair(PublicKey(Point([192, 197, 235, 93, 159, 211, 146, 74, 179, 248, 249, 218, 35, 84, 209, 51, 172, 7, 95, 133, 77, 213, 147, 64, 216, 9, 96, 148, 183, 141, 49, 60])), SecretKey(Scalar([158, 166, 229, 210, 204, 241, 135, 226, 72, 207, 205, 66, 249, 159, 234, 82, 151, 71, 178, 9, 211, 180, 151, 246, 246, 229, 125, 115, 251, 177, 226, 12])));
/// AMM: GDAMM22GAOGXG7LQTSQ7FQSJUZ2T45O4NYCXDJ2L3QB3HRMHWX6REMY6
static immutable AMM = KeyPair(PublicKey(Point([192, 198, 107, 70, 3, 141, 115, 125, 112, 156, 161, 242, 194, 73, 166, 117, 62, 117, 220, 110, 5, 113, 167, 75, 220, 3, 179, 197, 135, 181, 253, 18])), SecretKey(Scalar([10, 169, 106, 57, 16, 98, 102, 181, 179, 253, 89, 219, 85, 173, 212, 90, 155, 138, 104, 55, 72, 53, 151, 74, 33, 101, 152, 28, 86, 97, 116, 1])));
/// AMN: GDAMN22ZRJHWFMU67RUZ4WPASNEIAMHXZ5Z3WY5MYDIEB5AKND4EVE2G
static immutable AMN = KeyPair(PublicKey(Point([192, 198, 235, 89, 138, 79, 98, 178, 158, 252, 105, 158, 89, 224, 147, 72, 128, 48, 247, 207, 115, 187, 99, 172, 192, 208, 64, 244, 10, 104, 248, 74])), SecretKey(Scalar([150, 133, 115, 59, 71, 39, 168, 247, 177, 185, 49, 189, 99, 153, 235, 207, 138, 154, 163, 175, 12, 12, 125, 74, 55, 141, 46, 130, 94, 146, 51, 7])));
/// AMO: GDAMO22MQFNTO74WQ57RCYC5CV6YYC2IODOZCNBHMVJAL72OVW7XKS6Y
static immutable AMO = KeyPair(PublicKey(Point([192, 199, 107, 76, 129, 91, 55, 127, 150, 135, 127, 17, 96, 93, 21, 125, 140, 11, 72, 112, 221, 145, 52, 39, 101, 82, 5, 255, 78, 173, 191, 117])), SecretKey(Scalar([184, 111, 131, 13, 54, 174, 44, 236, 126, 187, 169, 142, 172, 204, 189, 141, 185, 254, 127, 236, 232, 20, 60, 201, 60, 0, 238, 144, 244, 225, 139, 3])));
/// AMP: GDAMP223ZLC3Q57CRHE5NXMGGHHOSUNSKBEV263RNASXYWXLAHIX6RSJ
static immutable AMP = KeyPair(PublicKey(Point([192, 199, 235, 91, 202, 197, 184, 119, 226, 137, 201, 214, 221, 134, 49, 206, 233, 81, 178, 80, 73, 93, 123, 113, 104, 37, 124, 90, 235, 1, 209, 127])), SecretKey(Scalar([80, 151, 26, 5, 178, 245, 205, 174, 176, 137, 98, 91, 3, 176, 184, 214, 104, 109, 114, 250, 58, 124, 215, 202, 95, 45, 250, 235, 98, 198, 111, 15])));
/// AMQ: GDAMQ22V2EXLX2HVXQEIJUSTER7BDX3WJPZ3S7OMPSPUGILDLZZO5D6W
static immutable AMQ = KeyPair(PublicKey(Point([192, 200, 107, 85, 209, 46, 187, 232, 245, 188, 8, 132, 210, 83, 36, 126, 17, 223, 118, 75, 243, 185, 125, 204, 124, 159, 67, 33, 99, 94, 114, 238])), SecretKey(Scalar([233, 103, 82, 232, 23, 1, 75, 200, 214, 139, 199, 231, 204, 153, 106, 240, 214, 74, 1, 134, 129, 0, 27, 143, 254, 185, 17, 47, 70, 253, 75, 11])));
/// AMR: GDAMR22TEVI4QXHA6XDK4HGN2I6YEJ7ME3AF6ISIBNARI7Q33SMZMHTV
static immutable AMR = KeyPair(PublicKey(Point([192, 200, 235, 83, 37, 81, 200, 92, 224, 245, 198, 174, 28, 205, 210, 61, 130, 39, 236, 38, 192, 95, 34, 72, 11, 65, 20, 126, 27, 220, 153, 150])), SecretKey(Scalar([69, 60, 135, 145, 148, 250, 107, 166, 79, 216, 2, 169, 46, 113, 255, 181, 147, 59, 52, 42, 15, 230, 25, 232, 69, 89, 51, 181, 70, 54, 109, 5])));
/// AMS: GDAMS22E2B5P7ZFZM5ZJWO2DTDR2E4UAS4R76OXG4WBAZ5GKU7TM54S6
static immutable AMS = KeyPair(PublicKey(Point([192, 201, 107, 68, 208, 122, 255, 228, 185, 103, 114, 155, 59, 67, 152, 227, 162, 114, 128, 151, 35, 255, 58, 230, 229, 130, 12, 244, 202, 167, 230, 206])), SecretKey(Scalar([109, 156, 126, 59, 133, 125, 15, 145, 174, 70, 27, 170, 97, 216, 108, 243, 221, 161, 68, 49, 131, 106, 215, 239, 174, 76, 94, 135, 19, 95, 9, 8])));
/// AMT: GDAMT22DIADX3KANGXNYICHRGJQB4AXJT3JPODDBQJHFCKXKHMNGFGAP
static immutable AMT = KeyPair(PublicKey(Point([192, 201, 235, 67, 64, 7, 125, 168, 13, 53, 219, 132, 8, 241, 50, 96, 30, 2, 233, 158, 210, 247, 12, 97, 130, 78, 81, 42, 234, 59, 26, 98])), SecretKey(Scalar([141, 147, 2, 68, 72, 25, 165, 156, 238, 97, 92, 232, 80, 168, 48, 73, 241, 128, 196, 187, 150, 242, 136, 248, 230, 187, 183, 225, 175, 132, 59, 10])));
/// AMU: GDAMU22DCSL2CVULSCTBWUI6Z4B4SNIVTNIU3SA44RJ7RELM2GWA6PY3
static immutable AMU = KeyPair(PublicKey(Point([192, 202, 107, 67, 20, 151, 161, 86, 139, 144, 166, 27, 81, 30, 207, 3, 201, 53, 21, 155, 81, 77, 200, 28, 228, 83, 248, 145, 108, 209, 172, 15])), SecretKey(Scalar([225, 14, 202, 35, 149, 102, 39, 165, 17, 226, 42, 129, 235, 251, 48, 217, 69, 207, 21, 74, 125, 255, 113, 29, 76, 202, 71, 105, 214, 189, 55, 6])));
/// AMV: GDAMV22LMYBJJW4YVE76P6VCJGG3XPQJJ67IJYM5YYVBVZKSVO3FIBT5
static immutable AMV = KeyPair(PublicKey(Point([192, 202, 235, 75, 102, 2, 148, 219, 152, 169, 63, 231, 250, 162, 73, 141, 187, 190, 9, 79, 190, 132, 225, 157, 198, 42, 26, 229, 82, 171, 182, 84])), SecretKey(Scalar([169, 71, 34, 106, 161, 217, 165, 155, 69, 155, 107, 127, 55, 186, 50, 119, 66, 7, 87, 212, 44, 76, 51, 220, 238, 13, 98, 24, 105, 197, 106, 8])));
/// AMW: GDAMW22LONCPQYVO5NVFOJ24A3ZZLR3YB3G6D2D2DPP4LOUET67HFWWK
static immutable AMW = KeyPair(PublicKey(Point([192, 203, 107, 75, 115, 68, 248, 98, 174, 235, 106, 87, 39, 92, 6, 243, 149, 199, 120, 14, 205, 225, 232, 122, 27, 223, 197, 186, 132, 159, 190, 114])), SecretKey(Scalar([40, 221, 44, 36, 54, 118, 231, 231, 253, 35, 138, 145, 82, 138, 252, 27, 165, 69, 193, 149, 197, 50, 73, 53, 15, 144, 42, 112, 158, 218, 19, 12])));
/// AMX: GDAMX224GASLDFZYCOBSUTJDADT75NIQYO5IZO77OWZRKSXEKAT6YKYI
static immutable AMX = KeyPair(PublicKey(Point([192, 203, 235, 92, 48, 36, 177, 151, 56, 19, 131, 42, 77, 35, 0, 231, 254, 181, 16, 195, 186, 140, 187, 255, 117, 179, 21, 74, 228, 80, 39, 236])), SecretKey(Scalar([62, 2, 168, 205, 239, 211, 215, 108, 98, 37, 132, 207, 40, 98, 11, 220, 7, 214, 208, 217, 77, 41, 111, 28, 76, 183, 144, 75, 164, 141, 60, 4])));
/// AMY: GDAMY22LBKIS5XFTQZQ3EZS7GA2WWGF56OVBS4KRRM6R7S47EBABWHP7
static immutable AMY = KeyPair(PublicKey(Point([192, 204, 107, 75, 10, 145, 46, 220, 179, 134, 97, 178, 102, 95, 48, 53, 107, 24, 189, 243, 170, 25, 113, 81, 139, 61, 31, 203, 159, 32, 64, 27])), SecretKey(Scalar([235, 157, 160, 207, 149, 179, 43, 25, 123, 60, 100, 32, 118, 202, 77, 118, 236, 221, 95, 40, 157, 178, 140, 247, 44, 204, 85, 129, 30, 206, 176, 7])));
/// AMZ: GDAMZ22SOAZX3CMZIXKP4EQELJTOPE5N6ZT5CAT4MCFQ7DXUAMDGFPQ5
static immutable AMZ = KeyPair(PublicKey(Point([192, 204, 235, 82, 112, 51, 125, 137, 153, 69, 212, 254, 18, 4, 90, 102, 231, 147, 173, 246, 103, 209, 2, 124, 96, 139, 15, 142, 244, 3, 6, 98])), SecretKey(Scalar([17, 109, 112, 14, 52, 44, 101, 197, 165, 163, 61, 218, 248, 66, 51, 235, 82, 58, 160, 192, 204, 92, 80, 238, 137, 103, 34, 216, 168, 27, 128, 0])));
/// ANA: GDANA22K3FA4NPFCSURXUQHGQILI3EHAEOGQYBJSRR6RPNDMLWF565V3
static immutable ANA = KeyPair(PublicKey(Point([192, 208, 107, 74, 217, 65, 198, 188, 162, 149, 35, 122, 64, 230, 130, 22, 141, 144, 224, 35, 141, 12, 5, 50, 140, 125, 23, 180, 108, 93, 139, 223])), SecretKey(Scalar([198, 119, 132, 44, 88, 246, 74, 42, 61, 174, 171, 124, 105, 37, 141, 54, 54, 135, 163, 54, 71, 21, 102, 159, 31, 109, 46, 52, 118, 51, 74, 6])));
/// ANB: GDANB22DEXBRXBNXMYOBHRXLNQVUAIASVWMMH4NZTLNVSIL3CQJJSQCA
static immutable ANB = KeyPair(PublicKey(Point([192, 208, 235, 67, 37, 195, 27, 133, 183, 102, 28, 19, 198, 235, 108, 43, 64, 32, 18, 173, 152, 195, 241, 185, 154, 219, 89, 33, 123, 20, 18, 153])), SecretKey(Scalar([19, 126, 75, 250, 145, 110, 245, 123, 55, 216, 139, 58, 61, 143, 27, 202, 81, 145, 248, 248, 55, 28, 233, 159, 242, 154, 85, 71, 79, 97, 47, 12])));
/// ANC: GDANC22BQ6LPW3ZQY5ZEYYSRM7WD7UXAEKRZHXEB5V2SQVFZSYAOAL7F
static immutable ANC = KeyPair(PublicKey(Point([192, 209, 107, 65, 135, 150, 251, 111, 48, 199, 114, 76, 98, 81, 103, 236, 63, 210, 224, 34, 163, 147, 220, 129, 237, 117, 40, 84, 185, 150, 0, 224])), SecretKey(Scalar([99, 26, 41, 112, 50, 86, 44, 79, 95, 69, 46, 44, 5, 113, 128, 178, 233, 98, 32, 68, 113, 249, 1, 169, 235, 229, 90, 241, 13, 10, 89, 4])));
/// AND: GDAND22MWGBET4GZD6OR7VR34EQXKHTA22VROM3C3VJ6GVUJFH2YOK7R
static immutable AND = KeyPair(PublicKey(Point([192, 209, 235, 76, 177, 130, 73, 240, 217, 31, 157, 31, 214, 59, 225, 33, 117, 30, 96, 214, 171, 23, 51, 98, 221, 83, 227, 86, 137, 41, 245, 135])), SecretKey(Scalar([197, 18, 37, 141, 213, 154, 38, 55, 77, 30, 41, 187, 140, 97, 11, 217, 129, 128, 9, 153, 6, 65, 154, 232, 58, 30, 101, 202, 152, 22, 6, 0])));
/// ANE: GDANE22AU2QRTNYPO46RXWD2EM46EWGJCCMMTMRGZMDJ7V6U25DOZA7F
static immutable ANE = KeyPair(PublicKey(Point([192, 210, 107, 64, 166, 161, 25, 183, 15, 119, 61, 27, 216, 122, 35, 57, 226, 88, 201, 16, 152, 201, 178, 38, 203, 6, 159, 215, 212, 215, 70, 236])), SecretKey(Scalar([135, 114, 46, 90, 10, 68, 93, 124, 138, 8, 126, 7, 0, 73, 158, 1, 128, 239, 61, 143, 87, 113, 9, 56, 52, 38, 222, 118, 111, 250, 137, 6])));
/// ANF: GDANF22M5XHAK2XRUCMBJSOIDV4PZLHMVYQD552GHIYYJZFBET34Y6RG
static immutable ANF = KeyPair(PublicKey(Point([192, 210, 235, 76, 237, 206, 5, 106, 241, 160, 152, 20, 201, 200, 29, 120, 252, 172, 236, 174, 32, 62, 247, 70, 58, 49, 132, 228, 161, 36, 247, 204])), SecretKey(Scalar([77, 89, 250, 38, 56, 46, 157, 112, 80, 160, 101, 84, 7, 100, 116, 247, 17, 26, 86, 158, 211, 173, 95, 239, 50, 171, 22, 47, 43, 175, 39, 6])));
/// ANG: GDANG22KNC5XCFAPEQJMCET4K4SNUJAP2ITKV7NABQFZ2DCX6UTHPNBH
static immutable ANG = KeyPair(PublicKey(Point([192, 211, 107, 74, 104, 187, 113, 20, 15, 36, 18, 193, 18, 124, 87, 36, 218, 36, 15, 210, 38, 170, 253, 160, 12, 11, 157, 12, 87, 245, 38, 119])), SecretKey(Scalar([123, 203, 100, 220, 147, 104, 40, 213, 154, 203, 6, 46, 22, 208, 220, 120, 164, 156, 251, 168, 23, 48, 219, 3, 176, 211, 214, 121, 152, 36, 95, 2])));
/// ANH: GDANH22U7KTVSEFGAUEUSERH7AJ422EUAPMGYIA5KMGZHXN7SDU5AFZK
static immutable ANH = KeyPair(PublicKey(Point([192, 211, 235, 84, 250, 167, 89, 16, 166, 5, 9, 73, 18, 39, 248, 19, 205, 104, 148, 3, 216, 108, 32, 29, 83, 13, 147, 221, 191, 144, 233, 208])), SecretKey(Scalar([189, 203, 130, 88, 4, 126, 2, 82, 93, 30, 183, 196, 9, 145, 67, 231, 243, 115, 154, 4, 220, 35, 150, 4, 230, 88, 247, 185, 127, 30, 139, 13])));
/// ANI: GDANI22J7AHIYYI4H6R57WVM2XROWR3JLMV77XX5EDDDVHECIWWFS3CI
static immutable ANI = KeyPair(PublicKey(Point([192, 212, 107, 73, 248, 14, 140, 97, 28, 63, 163, 223, 218, 172, 213, 226, 235, 71, 105, 91, 43, 255, 222, 253, 32, 198, 58, 156, 130, 69, 172, 89])), SecretKey(Scalar([114, 88, 18, 170, 109, 162, 27, 60, 166, 212, 138, 24, 10, 236, 33, 232, 34, 188, 185, 163, 72, 80, 185, 74, 226, 13, 225, 28, 192, 35, 2, 0])));
/// ANJ: GDANJ22GGF7BED4WCMPFAOUUKYVLMT5L6U5MZYO5SUGM42LMSQAHBVKW
static immutable ANJ = KeyPair(PublicKey(Point([192, 212, 235, 70, 49, 126, 18, 15, 150, 19, 30, 80, 58, 148, 86, 42, 182, 79, 171, 245, 58, 204, 225, 221, 149, 12, 206, 105, 108, 148, 0, 112])), SecretKey(Scalar([95, 154, 8, 42, 201, 248, 177, 13, 184, 155, 28, 242, 136, 174, 118, 3, 138, 42, 23, 29, 96, 251, 63, 134, 161, 36, 221, 109, 139, 79, 230, 0])));
/// ANK: GDANK227NG6EWHFVNVHEYLHJDQ5GOO72DB7LUFVX377ED7UTB7ASP4QO
static immutable ANK = KeyPair(PublicKey(Point([192, 213, 107, 95, 105, 188, 75, 28, 181, 109, 78, 76, 44, 233, 28, 58, 103, 59, 250, 24, 126, 186, 22, 183, 223, 254, 65, 254, 147, 15, 193, 39])), SecretKey(Scalar([80, 80, 45, 26, 204, 5, 66, 187, 226, 68, 123, 188, 228, 86, 118, 40, 172, 29, 10, 152, 178, 177, 19, 228, 71, 9, 150, 209, 246, 107, 104, 5])));
/// ANL: GDANL223S5D2275LIUDRCAFRS63U6XATLGGZWMGWRNTUL2FUAWO73SHB
static immutable ANL = KeyPair(PublicKey(Point([192, 213, 235, 91, 151, 71, 173, 127, 171, 69, 7, 17, 0, 177, 151, 183, 79, 92, 19, 89, 141, 155, 48, 214, 139, 103, 69, 232, 180, 5, 157, 253])), SecretKey(Scalar([214, 41, 115, 243, 168, 51, 129, 70, 242, 99, 167, 207, 166, 68, 33, 110, 92, 154, 249, 94, 100, 128, 242, 248, 8, 73, 227, 172, 230, 248, 153, 14])));
/// ANM: GDANM22C4KZKIPVM4I4L2U72DNT74ZTHLEK4JIJBDFQLIVRZ4F77M6BP
static immutable ANM = KeyPair(PublicKey(Point([192, 214, 107, 66, 226, 178, 164, 62, 172, 226, 56, 189, 83, 250, 27, 103, 254, 102, 103, 89, 21, 196, 161, 33, 25, 96, 180, 86, 57, 225, 127, 246])), SecretKey(Scalar([250, 178, 104, 42, 233, 145, 164, 145, 158, 194, 246, 24, 224, 29, 137, 220, 129, 136, 180, 230, 239, 72, 223, 170, 195, 194, 24, 224, 193, 72, 73, 7])));
/// ANN: GDANN22P3LOEVPJJ25R2A3XTMEYXQV24QDKEABNRZSIQUYDKM4WEIWWB
static immutable ANN = KeyPair(PublicKey(Point([192, 214, 235, 79, 218, 220, 74, 189, 41, 215, 99, 160, 110, 243, 97, 49, 120, 87, 92, 128, 212, 64, 5, 177, 204, 145, 10, 96, 106, 103, 44, 68])), SecretKey(Scalar([119, 20, 139, 157, 155, 137, 209, 124, 25, 160, 174, 181, 18, 224, 106, 207, 8, 253, 224, 204, 140, 41, 221, 121, 212, 196, 177, 55, 57, 195, 101, 9])));
/// ANO: GDANO22ZIHVMQ2HO3WMMFMNBFUUNHTGDK4KPAWQKCU6IZ3SO3RQO7WPQ
static immutable ANO = KeyPair(PublicKey(Point([192, 215, 107, 89, 65, 234, 200, 104, 238, 221, 152, 194, 177, 161, 45, 40, 211, 204, 195, 87, 20, 240, 90, 10, 21, 60, 140, 238, 78, 220, 96, 239])), SecretKey(Scalar([214, 255, 162, 131, 72, 12, 36, 20, 138, 49, 12, 204, 36, 98, 180, 230, 220, 137, 71, 24, 168, 139, 67, 16, 21, 144, 117, 103, 87, 17, 190, 10])));
/// ANP: GDANP22QKIUIL5LWA7UAKHX7OD3Z7AYW4EKXRPCSGPDWZAOT4AFMOMZM
static immutable ANP = KeyPair(PublicKey(Point([192, 215, 235, 80, 82, 40, 133, 245, 118, 7, 232, 5, 30, 255, 112, 247, 159, 131, 22, 225, 21, 120, 188, 82, 51, 199, 108, 129, 211, 224, 10, 199])), SecretKey(Scalar([133, 20, 27, 23, 15, 75, 157, 227, 173, 125, 241, 177, 27, 101, 141, 20, 165, 134, 220, 70, 46, 64, 63, 239, 251, 255, 17, 251, 222, 168, 45, 0])));
/// ANQ: GDANQ22HIDOKWSG5ZGPVC5ZNIRBV4VTCSFTFOZN5FVGJK5235QLO3F46
static immutable ANQ = KeyPair(PublicKey(Point([192, 216, 107, 71, 64, 220, 171, 72, 221, 201, 159, 81, 119, 45, 68, 67, 94, 86, 98, 145, 102, 87, 101, 189, 45, 76, 149, 119, 91, 236, 22, 237])), SecretKey(Scalar([50, 193, 99, 203, 106, 45, 101, 161, 101, 35, 81, 171, 65, 7, 232, 73, 226, 113, 26, 123, 10, 243, 124, 44, 211, 10, 64, 136, 190, 76, 128, 2])));
/// ANR: GDANR22MRQNDETPG47HOQU3LNKSKEGOC2GMQCRHDUQANP35B23DRPS2A
static immutable ANR = KeyPair(PublicKey(Point([192, 216, 235, 76, 140, 26, 50, 77, 230, 231, 206, 232, 83, 107, 106, 164, 162, 25, 194, 209, 153, 1, 68, 227, 164, 0, 215, 239, 161, 214, 199, 23])), SecretKey(Scalar([8, 109, 144, 99, 91, 199, 41, 124, 143, 254, 20, 221, 21, 80, 14, 101, 225, 125, 0, 159, 171, 200, 16, 121, 179, 60, 101, 248, 22, 255, 53, 5])));
/// ANS: GDANS22GV26IKPI75VMWKJL4XKQNFXJMJXSARHLAJSZZ7RVBF5YT4OQQ
static immutable ANS = KeyPair(PublicKey(Point([192, 217, 107, 70, 174, 188, 133, 61, 31, 237, 89, 101, 37, 124, 186, 160, 210, 221, 44, 77, 228, 8, 157, 96, 76, 179, 159, 198, 161, 47, 113, 62])), SecretKey(Scalar([198, 130, 132, 165, 196, 116, 119, 224, 209, 99, 17, 119, 32, 175, 218, 51, 82, 42, 15, 110, 104, 203, 92, 236, 250, 176, 22, 199, 209, 119, 81, 13])));
/// ANT: GDANT22UZSKA3PRGCZHZXORPVEAU4TQN2YC6I5RPHGJB3EOY6MBX7IFU
static immutable ANT = KeyPair(PublicKey(Point([192, 217, 235, 84, 204, 148, 13, 190, 38, 22, 79, 155, 186, 47, 169, 1, 78, 78, 13, 214, 5, 228, 118, 47, 57, 146, 29, 145, 216, 243, 3, 127])), SecretKey(Scalar([218, 29, 206, 3, 14, 100, 201, 98, 120, 0, 22, 74, 220, 31, 252, 185, 29, 81, 63, 28, 170, 115, 193, 199, 217, 10, 67, 137, 74, 85, 24, 0])));
/// ANU: GDANU22HQREY4Q5UPMUGHCN5LPPV2NYO3UV6XYSG3C4IYJ5NP7EYIUGX
static immutable ANU = KeyPair(PublicKey(Point([192, 218, 107, 71, 132, 73, 142, 67, 180, 123, 40, 99, 137, 189, 91, 223, 93, 55, 14, 221, 43, 235, 226, 70, 216, 184, 140, 39, 173, 127, 201, 132])), SecretKey(Scalar([134, 103, 236, 193, 134, 230, 135, 29, 126, 229, 169, 53, 161, 136, 25, 30, 252, 145, 40, 108, 59, 90, 196, 200, 71, 184, 199, 148, 227, 103, 187, 8])));
/// ANV: GDANV22WMPQPL6ZQVMEQHXC5YO3IGP3B3OCL2JT5R7ROB4PWSII7FW6Z
static immutable ANV = KeyPair(PublicKey(Point([192, 218, 235, 86, 99, 224, 245, 251, 48, 171, 9, 3, 220, 93, 195, 182, 131, 63, 97, 219, 132, 189, 38, 125, 143, 226, 224, 241, 246, 146, 17, 242])), SecretKey(Scalar([22, 93, 120, 177, 187, 183, 184, 241, 111, 238, 75, 103, 39, 60, 150, 63, 162, 25, 175, 40, 200, 227, 79, 192, 152, 225, 65, 92, 170, 57, 238, 8])));
/// ANW: GDANW22I56OOEWTHQFHFYW77PSAO7JHMXLBKZVFJFEPRSV366ISRXRNE
static immutable ANW = KeyPair(PublicKey(Point([192, 219, 107, 72, 239, 156, 226, 90, 103, 129, 78, 92, 91, 255, 124, 128, 239, 164, 236, 186, 194, 172, 212, 169, 41, 31, 25, 87, 126, 242, 37, 27])), SecretKey(Scalar([236, 22, 39, 131, 60, 15, 26, 29, 232, 1, 35, 78, 19, 113, 221, 237, 130, 28, 69, 127, 218, 235, 15, 153, 211, 35, 106, 41, 40, 222, 80, 4])));
/// ANX: GDANX22KUOWBYEK42IS5FRNN4PCMVAIPPEXWZGA6O4TVOMYRVVSLNGJA
static immutable ANX = KeyPair(PublicKey(Point([192, 219, 235, 74, 163, 172, 28, 17, 92, 210, 37, 210, 197, 173, 227, 196, 202, 129, 15, 121, 47, 108, 152, 30, 119, 39, 87, 51, 17, 173, 100, 182])), SecretKey(Scalar([19, 239, 198, 126, 58, 251, 36, 91, 6, 254, 240, 146, 162, 192, 172, 50, 198, 107, 103, 12, 7, 206, 32, 2, 83, 114, 11, 145, 35, 31, 154, 11])));
/// ANY: GDANY22NHDMQ2BBXPPAPZSWL2LHL6D735FKPRZH773RZULI2LCVUQGTJ
static immutable ANY = KeyPair(PublicKey(Point([192, 220, 107, 77, 56, 217, 13, 4, 55, 123, 192, 252, 202, 203, 210, 206, 191, 15, 251, 233, 84, 248, 228, 255, 254, 227, 154, 45, 26, 88, 171, 72])), SecretKey(Scalar([26, 215, 75, 88, 101, 240, 152, 230, 93, 251, 124, 33, 197, 4, 126, 100, 220, 131, 100, 72, 248, 252, 156, 147, 133, 119, 101, 81, 9, 171, 156, 8])));
/// ANZ: GDANZ22V73QL73S2FCNA5BT23ICJ7FNVEQPQSDYS2I6UFJKFEQFBVN5S
static immutable ANZ = KeyPair(PublicKey(Point([192, 220, 235, 85, 254, 224, 191, 238, 90, 40, 154, 14, 134, 122, 218, 4, 159, 149, 181, 36, 31, 9, 15, 18, 210, 61, 66, 165, 69, 36, 10, 26])), SecretKey(Scalar([196, 28, 13, 175, 202, 208, 137, 11, 112, 248, 75, 204, 173, 122, 113, 245, 213, 133, 71, 42, 33, 22, 49, 241, 111, 171, 115, 183, 43, 2, 127, 15])));
/// AOA: GDAOA2242JYX4LN52GHYPA6RXEBH6FF6QVMNEVOCXFUP2K2QUZ4OM3TH
static immutable AOA = KeyPair(PublicKey(Point([192, 224, 107, 92, 210, 113, 126, 45, 189, 209, 143, 135, 131, 209, 185, 2, 127, 20, 190, 133, 88, 210, 85, 194, 185, 104, 253, 43, 80, 166, 120, 230])), SecretKey(Scalar([29, 247, 139, 87, 211, 199, 6, 198, 131, 115, 130, 15, 126, 202, 37, 210, 143, 166, 18, 57, 212, 208, 254, 147, 54, 179, 117, 147, 5, 204, 51, 4])));
/// AOB: GDAOB22R4QHJVMOFJK4RKXW3EZKJJ5WBOUJOA4PCH726WHGV6GYWHGQF
static immutable AOB = KeyPair(PublicKey(Point([192, 224, 235, 81, 228, 14, 154, 177, 197, 74, 185, 21, 94, 219, 38, 84, 148, 246, 193, 117, 18, 224, 113, 226, 63, 245, 235, 28, 213, 241, 177, 99])), SecretKey(Scalar([69, 146, 36, 90, 151, 114, 226, 138, 231, 152, 226, 240, 162, 38, 221, 101, 237, 223, 248, 213, 123, 17, 37, 218, 63, 74, 176, 77, 217, 37, 189, 15])));
/// AOC: GDAOC22FDNZPKSTPRXGNTNGG2ZWVO6CXSZ2M4RNYSUK3L7VSFNGRFGDD
static immutable AOC = KeyPair(PublicKey(Point([192, 225, 107, 69, 27, 114, 245, 74, 111, 141, 204, 217, 180, 198, 214, 109, 87, 120, 87, 150, 116, 206, 69, 184, 149, 21, 181, 254, 178, 43, 77, 18])), SecretKey(Scalar([243, 66, 61, 71, 204, 210, 115, 53, 206, 159, 90, 38, 86, 197, 229, 181, 252, 157, 31, 92, 167, 42, 218, 232, 20, 89, 140, 82, 245, 139, 134, 6])));
/// AOD: GDAOD22EINSURCXPEXCYZ6YSYIKY3ZH5WSJQCOGFEUO7BDO2XLTYN75B
static immutable AOD = KeyPair(PublicKey(Point([192, 225, 235, 68, 67, 101, 72, 138, 239, 37, 197, 140, 251, 18, 194, 21, 141, 228, 253, 180, 147, 1, 56, 197, 37, 29, 240, 141, 218, 186, 231, 134])), SecretKey(Scalar([156, 185, 135, 38, 14, 174, 111, 74, 30, 150, 227, 46, 21, 242, 182, 20, 140, 77, 123, 133, 195, 37, 188, 136, 136, 176, 51, 153, 194, 73, 66, 14])));
/// AOE: GDAOE22S27EEVQ3F7TVEGEQOAVN4PJ2K6LIB5XXHEHCARZUANDDN3KTP
static immutable AOE = KeyPair(PublicKey(Point([192, 226, 107, 82, 215, 200, 74, 195, 101, 252, 234, 67, 18, 14, 5, 91, 199, 167, 74, 242, 208, 30, 222, 231, 33, 196, 8, 230, 128, 104, 198, 221])), SecretKey(Scalar([184, 90, 152, 102, 166, 121, 152, 144, 23, 194, 237, 56, 183, 238, 250, 159, 87, 123, 126, 102, 174, 72, 121, 62, 130, 236, 52, 178, 64, 85, 242, 0])));
/// AOF: GDAOF22P6XKYUC4ZOXDFV6PMNYJHI4WEM7YQBER2LPHDLBGAJXOYYBY2
static immutable AOF = KeyPair(PublicKey(Point([192, 226, 235, 79, 245, 213, 138, 11, 153, 117, 198, 90, 249, 236, 110, 18, 116, 114, 196, 103, 241, 0, 146, 58, 91, 206, 53, 132, 192, 77, 221, 140])), SecretKey(Scalar([178, 33, 43, 19, 46, 25, 9, 115, 69, 255, 154, 94, 99, 134, 89, 11, 213, 52, 186, 18, 27, 244, 236, 207, 179, 131, 166, 24, 213, 33, 19, 10])));
/// AOG: GDAOG22OP7YJT5NZACK47EBQ7CYMWJWRKPKEREFUKZKYS7HMVNCCDMUZ
static immutable AOG = KeyPair(PublicKey(Point([192, 227, 107, 78, 127, 240, 153, 245, 185, 0, 149, 207, 144, 48, 248, 176, 203, 38, 209, 83, 212, 72, 144, 180, 86, 85, 137, 124, 236, 171, 68, 33])), SecretKey(Scalar([42, 21, 56, 57, 191, 216, 124, 46, 180, 142, 51, 209, 140, 65, 125, 58, 97, 45, 157, 18, 111, 152, 144, 4, 3, 65, 163, 225, 19, 228, 222, 11])));
/// AOH: GDAOH22XRTM7USMJOEVKFEMAVDFJ2FMC6T2PCFCFPGYFHMJPCCGZOWNA
static immutable AOH = KeyPair(PublicKey(Point([192, 227, 235, 87, 140, 217, 250, 73, 137, 113, 42, 162, 145, 128, 168, 202, 157, 21, 130, 244, 244, 241, 20, 69, 121, 176, 83, 177, 47, 16, 141, 151])), SecretKey(Scalar([207, 193, 206, 143, 32, 66, 5, 123, 95, 220, 219, 12, 192, 187, 106, 53, 133, 176, 254, 178, 150, 102, 222, 65, 149, 55, 201, 253, 20, 19, 93, 12])));
/// AOI: GDAOI22P7KG5BRCQLXCTGYXPBSIAWQOC7UI4HHWQNQJDIXXLQ4UJJ45B
static immutable AOI = KeyPair(PublicKey(Point([192, 228, 107, 79, 250, 141, 208, 196, 80, 93, 197, 51, 98, 239, 12, 144, 11, 65, 194, 253, 17, 195, 158, 208, 108, 18, 52, 94, 235, 135, 40, 148])), SecretKey(Scalar([136, 207, 59, 134, 108, 48, 116, 112, 49, 135, 111, 70, 119, 202, 9, 92, 218, 237, 23, 19, 123, 196, 157, 194, 46, 82, 169, 131, 182, 63, 20, 14])));
/// AOJ: GDAOJ22RFL4W56XDR33QQC6F3IYPSSYXXZF2WA76RTTVZZYRGNGV35YZ
static immutable AOJ = KeyPair(PublicKey(Point([192, 228, 235, 81, 42, 249, 110, 250, 227, 142, 247, 8, 11, 197, 218, 48, 249, 75, 23, 190, 75, 171, 3, 254, 140, 231, 92, 231, 17, 51, 77, 93])), SecretKey(Scalar([83, 162, 73, 12, 121, 9, 92, 158, 7, 170, 237, 245, 7, 237, 25, 201, 62, 72, 141, 89, 197, 13, 94, 54, 247, 244, 185, 242, 141, 174, 10, 3])));
/// AOK: GDAOK22EWWJ2GRL3XMJ2C5PZPXYPW3QLBKXKSKLIOX5CYH3ZNER55EV4
static immutable AOK = KeyPair(PublicKey(Point([192, 229, 107, 68, 181, 147, 163, 69, 123, 187, 19, 161, 117, 249, 125, 240, 251, 110, 11, 10, 174, 169, 41, 104, 117, 250, 44, 31, 121, 105, 35, 222])), SecretKey(Scalar([82, 20, 87, 23, 239, 12, 253, 73, 41, 207, 136, 100, 44, 94, 193, 231, 245, 105, 23, 38, 160, 203, 35, 158, 236, 149, 145, 25, 18, 80, 212, 7])));
/// AOL: GDAOL22CL4M2SG6D23JOS53CSQQUWW4MHVYARKK7MIFD3UYQS4QOFQY2
static immutable AOL = KeyPair(PublicKey(Point([192, 229, 235, 66, 95, 25, 169, 27, 195, 214, 210, 233, 119, 98, 148, 33, 75, 91, 140, 61, 112, 8, 169, 95, 98, 10, 61, 211, 16, 151, 32, 226])), SecretKey(Scalar([0, 203, 187, 109, 137, 102, 131, 13, 119, 48, 104, 197, 116, 134, 68, 114, 96, 101, 31, 48, 27, 196, 222, 168, 22, 128, 133, 176, 160, 0, 177, 13])));
/// AOM: GDAOM22KKE6QKNUZYTLEPRZ5E3HXYACETBL27T5L6XIQ7TFKR4FZRKJG
static immutable AOM = KeyPair(PublicKey(Point([192, 230, 107, 74, 81, 61, 5, 54, 153, 196, 214, 71, 199, 61, 38, 207, 124, 0, 68, 152, 87, 175, 207, 171, 245, 209, 15, 204, 170, 143, 11, 152])), SecretKey(Scalar([182, 171, 237, 58, 226, 177, 98, 96, 243, 138, 130, 62, 173, 45, 182, 76, 34, 208, 191, 182, 28, 209, 1, 81, 104, 110, 22, 68, 224, 173, 233, 7])));
/// AON: GDAON22P4D5Z343XPOEO3KZDV67HZX5FESOLIHE3O62GRVAYQDACH3LA
static immutable AON = KeyPair(PublicKey(Point([192, 230, 235, 79, 224, 251, 157, 243, 119, 123, 136, 237, 171, 35, 175, 190, 124, 223, 165, 36, 156, 180, 28, 155, 119, 180, 104, 212, 24, 128, 192, 35])), SecretKey(Scalar([125, 39, 192, 128, 117, 138, 227, 206, 87, 168, 77, 143, 156, 253, 127, 172, 130, 145, 90, 147, 120, 144, 239, 199, 0, 68, 120, 63, 23, 169, 213, 7])));
/// AOO: GDAOO22UQI3PCEW4GTK27HLCTGTFT2DCS5AHUQ47BIQXEOKIYFGV6SON
static immutable AOO = KeyPair(PublicKey(Point([192, 231, 107, 84, 130, 54, 241, 18, 220, 52, 213, 175, 157, 98, 153, 166, 89, 232, 98, 151, 64, 122, 67, 159, 10, 33, 114, 57, 72, 193, 77, 95])), SecretKey(Scalar([51, 111, 123, 64, 79, 72, 41, 252, 12, 63, 107, 184, 207, 95, 41, 186, 180, 88, 213, 166, 127, 121, 186, 8, 62, 83, 75, 155, 194, 30, 214, 10])));
/// AOP: GDAOP22TV52YZDRLX4ST3HCYUCQXD4XL2DSPNWPYHYTD66DXL67DF4JD
static immutable AOP = KeyPair(PublicKey(Point([192, 231, 235, 83, 175, 117, 140, 142, 43, 191, 37, 61, 156, 88, 160, 161, 113, 242, 235, 208, 228, 246, 217, 248, 62, 38, 63, 120, 119, 95, 190, 50])), SecretKey(Scalar([208, 245, 252, 159, 139, 240, 65, 105, 94, 24, 151, 75, 132, 79, 249, 196, 126, 251, 135, 15, 51, 175, 2, 107, 57, 166, 34, 66, 142, 58, 95, 1])));
/// AOQ: GDAOQ22WQ2HOJZM2RC4TQYWJHBQI3ATMQB7AGLNDTOBR64WJWHDSUEJP
static immutable AOQ = KeyPair(PublicKey(Point([192, 232, 107, 86, 134, 142, 228, 229, 154, 136, 185, 56, 98, 201, 56, 96, 141, 130, 108, 128, 126, 3, 45, 163, 155, 131, 31, 114, 201, 177, 199, 42])), SecretKey(Scalar([102, 254, 255, 232, 29, 137, 102, 12, 125, 211, 127, 169, 85, 153, 10, 4, 71, 240, 176, 233, 19, 4, 55, 106, 164, 129, 79, 98, 197, 142, 69, 14])));
/// AOR: GDAOR22AVYAANFUCQWJZQDBJSKASRERIN55LX6AE5W6V7XOBSQ3JNJIG
static immutable AOR = KeyPair(PublicKey(Point([192, 232, 235, 64, 174, 0, 6, 150, 130, 133, 147, 152, 12, 41, 146, 129, 40, 146, 40, 111, 122, 187, 248, 4, 237, 189, 95, 221, 193, 148, 54, 150])), SecretKey(Scalar([22, 32, 33, 222, 248, 133, 169, 224, 140, 231, 76, 80, 74, 54, 49, 27, 144, 252, 162, 187, 144, 115, 213, 219, 197, 36, 157, 35, 226, 23, 46, 13])));
/// AOS: GDAOS22OTVJJH5I2HIF2JFCBYVWGZJQSVF7D2UCJDQOEUSKSJAY43YVE
static immutable AOS = KeyPair(PublicKey(Point([192, 233, 107, 78, 157, 82, 147, 245, 26, 58, 11, 164, 148, 65, 197, 108, 108, 166, 18, 169, 126, 61, 80, 73, 28, 28, 74, 73, 82, 72, 49, 205])), SecretKey(Scalar([21, 198, 247, 41, 76, 200, 40, 219, 105, 191, 236, 246, 246, 52, 0, 166, 143, 20, 163, 137, 95, 101, 30, 198, 132, 107, 205, 227, 225, 96, 241, 5])));
/// AOT: GDAOT223327S7MC7ZF77WWIAC7OKG4DKRHKA4OFSPHTVZUQVIOEDN4OP
static immutable AOT = KeyPair(PublicKey(Point([192, 233, 235, 91, 222, 191, 47, 176, 95, 201, 127, 251, 89, 0, 23, 220, 163, 112, 106, 137, 212, 14, 56, 178, 121, 231, 92, 210, 21, 67, 136, 54])), SecretKey(Scalar([132, 176, 80, 157, 23, 74, 245, 13, 238, 91, 225, 71, 89, 252, 15, 210, 203, 226, 29, 113, 152, 102, 99, 46, 208, 165, 12, 59, 140, 176, 11, 10])));
/// AOU: GDAOU226N3LAZP2AKEXW2SH3YQJBSALVTNEQSFKO7PYSCQ2WXHZPPOPX
static immutable AOU = KeyPair(PublicKey(Point([192, 234, 107, 94, 110, 214, 12, 191, 64, 81, 47, 109, 72, 251, 196, 18, 25, 1, 117, 155, 73, 9, 21, 78, 251, 241, 33, 67, 86, 185, 242, 247])), SecretKey(Scalar([47, 208, 56, 116, 6, 81, 25, 176, 210, 120, 35, 68, 60, 126, 247, 21, 61, 96, 204, 141, 167, 71, 253, 39, 145, 247, 48, 181, 184, 58, 18, 5])));
/// AOV: GDAOV22AQZMWETSHVB2LJWJYBMNLT73DBQ5UVNXA2GW326OJH5MJ4GNQ
static immutable AOV = KeyPair(PublicKey(Point([192, 234, 235, 64, 134, 89, 98, 78, 71, 168, 116, 180, 217, 56, 11, 26, 185, 255, 99, 12, 59, 74, 182, 224, 209, 173, 189, 121, 201, 63, 88, 158])), SecretKey(Scalar([200, 246, 38, 95, 181, 151, 37, 139, 152, 234, 161, 29, 139, 189, 191, 122, 155, 16, 209, 179, 106, 118, 232, 217, 172, 220, 20, 129, 240, 71, 11, 3])));
/// AOW: GDAOW22FYTATBC3A36OUFOZEQ7PVSXB7IMBG2ZWPCAVTBFNQLTWZCLHW
static immutable AOW = KeyPair(PublicKey(Point([192, 235, 107, 69, 196, 193, 48, 139, 96, 223, 157, 66, 187, 36, 135, 223, 89, 92, 63, 67, 2, 109, 102, 207, 16, 43, 48, 149, 176, 92, 237, 145])), SecretKey(Scalar([222, 54, 168, 22, 135, 195, 56, 119, 171, 104, 54, 192, 180, 82, 239, 69, 108, 49, 228, 152, 170, 27, 38, 92, 152, 39, 206, 205, 123, 13, 185, 1])));
/// AOX: GDAOX22IMRU56AFUPSVVX7AK7VL32MLC4LKRV3K4FSKCUCWJOSY54RYF
static immutable AOX = KeyPair(PublicKey(Point([192, 235, 235, 72, 100, 105, 223, 0, 180, 124, 171, 91, 252, 10, 253, 87, 189, 49, 98, 226, 213, 26, 237, 92, 44, 148, 42, 10, 201, 116, 177, 222])), SecretKey(Scalar([180, 226, 105, 243, 149, 117, 101, 72, 143, 98, 162, 241, 225, 240, 244, 140, 155, 219, 242, 216, 54, 142, 131, 68, 10, 148, 110, 208, 233, 153, 151, 9])));
/// AOY: GDAOY22QBTD4XQX3Y7YUAR3BI3ZPLB5YT7WPKBMCNN4BYZBDKN5YJ7WU
static immutable AOY = KeyPair(PublicKey(Point([192, 236, 107, 80, 12, 199, 203, 194, 251, 199, 241, 64, 71, 97, 70, 242, 245, 135, 184, 159, 236, 245, 5, 130, 107, 120, 28, 100, 35, 83, 123, 132])), SecretKey(Scalar([197, 81, 68, 33, 19, 206, 210, 242, 44, 97, 39, 120, 227, 215, 228, 220, 193, 134, 147, 46, 123, 136, 62, 90, 161, 162, 65, 148, 107, 109, 64, 5])));
/// AOZ: GDAOZ22IUVBU4UZLI6MFNHIAZYMNN7C2H4DVPTW3JC43WGLWQ6GWYDEQ
static immutable AOZ = KeyPair(PublicKey(Point([192, 236, 235, 72, 165, 67, 78, 83, 43, 71, 152, 86, 157, 0, 206, 24, 214, 252, 90, 63, 7, 87, 206, 219, 72, 185, 187, 25, 118, 135, 141, 108])), SecretKey(Scalar([224, 244, 242, 163, 82, 195, 0, 87, 37, 235, 168, 201, 248, 6, 110, 236, 58, 220, 72, 203, 142, 68, 251, 186, 170, 96, 85, 174, 151, 243, 92, 4])));
/// APA: GDAPA22NJPUQ4KD76EKPFMTAOVNO4G5FW3QQYKSCAH2SV6ZNJ76JOXHI
static immutable APA = KeyPair(PublicKey(Point([192, 240, 107, 77, 75, 233, 14, 40, 127, 241, 20, 242, 178, 96, 117, 90, 238, 27, 165, 182, 225, 12, 42, 66, 1, 245, 42, 251, 45, 79, 252, 151])), SecretKey(Scalar([138, 8, 81, 44, 240, 242, 74, 142, 188, 191, 62, 82, 6, 76, 8, 117, 179, 199, 112, 255, 93, 245, 130, 116, 199, 197, 139, 92, 89, 120, 103, 15])));
/// APB: GDAPB22QSLYDHKUWLATXVO2XMHNCBKY3D4I7XK7PUBBDPZHHZES4OLYR
static immutable APB = KeyPair(PublicKey(Point([192, 240, 235, 80, 146, 240, 51, 170, 150, 88, 39, 122, 187, 87, 97, 218, 32, 171, 27, 31, 17, 251, 171, 239, 160, 66, 55, 228, 231, 201, 37, 199])), SecretKey(Scalar([159, 5, 2, 160, 83, 34, 164, 252, 120, 223, 223, 167, 189, 231, 225, 249, 204, 25, 144, 109, 99, 227, 29, 80, 253, 76, 127, 48, 17, 199, 6, 11])));
/// APC: GDAPC22IQM6U4MH57VVNHYKJCPOBC6ZJ332ZCGIMALEKCLPQCRFGAO3R
static immutable APC = KeyPair(PublicKey(Point([192, 241, 107, 72, 131, 61, 78, 48, 253, 253, 106, 211, 225, 73, 19, 220, 17, 123, 41, 222, 245, 145, 25, 12, 2, 200, 161, 45, 240, 20, 74, 96])), SecretKey(Scalar([154, 221, 21, 113, 147, 192, 101, 161, 149, 194, 229, 60, 78, 63, 172, 149, 76, 112, 225, 207, 226, 80, 156, 154, 110, 86, 120, 123, 53, 135, 6, 11])));
/// APD: GDAPD22DXB5KDPWKJB7ORC2KDDBHFXC4WRTURMTRYLSLQN6M5S4QTDMO
static immutable APD = KeyPair(PublicKey(Point([192, 241, 235, 67, 184, 122, 161, 190, 202, 72, 126, 232, 139, 74, 24, 194, 114, 220, 92, 180, 103, 72, 178, 113, 194, 228, 184, 55, 204, 236, 185, 9])), SecretKey(Scalar([26, 151, 197, 114, 255, 98, 11, 240, 141, 15, 165, 63, 177, 179, 119, 236, 19, 176, 216, 84, 86, 45, 68, 10, 49, 94, 34, 217, 184, 165, 129, 5])));
/// APE: GDAPE22BY3G7E2GMGDUVGVASUSYT7TZ6B3H2EJNGTXOBC7IL44Q2Z66R
static immutable APE = KeyPair(PublicKey(Point([192, 242, 107, 65, 198, 205, 242, 104, 204, 48, 233, 83, 84, 18, 164, 177, 63, 207, 62, 14, 207, 162, 37, 166, 157, 220, 17, 125, 11, 231, 33, 172])), SecretKey(Scalar([192, 251, 182, 84, 18, 35, 88, 111, 69, 134, 199, 69, 135, 217, 39, 15, 98, 162, 216, 154, 210, 196, 29, 191, 11, 93, 50, 76, 67, 119, 147, 3])));
/// APF: GDAPF22FWOVKPNLKC5ZG2EYQHLP6T4DXW5URIP63O5BA34EV45OJGEG5
static immutable APF = KeyPair(PublicKey(Point([192, 242, 235, 69, 179, 170, 167, 181, 106, 23, 114, 109, 19, 16, 58, 223, 233, 240, 119, 183, 105, 20, 63, 219, 119, 66, 13, 240, 149, 231, 92, 147])), SecretKey(Scalar([213, 64, 193, 17, 57, 183, 18, 152, 81, 207, 155, 177, 107, 97, 111, 216, 169, 39, 255, 205, 70, 205, 12, 74, 109, 143, 147, 74, 102, 121, 123, 3])));
/// APG: GDAPG2274XVXHE45COHPBPOD75OIXUDLFSPMRGKDTSGSIDPHYUP4RAXZ
static immutable APG = KeyPair(PublicKey(Point([192, 243, 107, 95, 229, 235, 115, 147, 157, 19, 142, 240, 189, 195, 255, 92, 139, 208, 107, 44, 158, 200, 153, 67, 156, 141, 36, 13, 231, 197, 31, 200])), SecretKey(Scalar([45, 144, 34, 143, 248, 235, 136, 214, 129, 47, 120, 27, 143, 109, 59, 231, 254, 118, 193, 249, 219, 105, 237, 78, 232, 227, 145, 188, 173, 22, 125, 1])));
/// APH: GDAPH223GYHAM577RVQ2E3JTGUR6ATUGFQOQKPGUT7RQ5KYYWFMIYLNR
static immutable APH = KeyPair(PublicKey(Point([192, 243, 235, 91, 54, 14, 6, 119, 255, 141, 97, 162, 109, 51, 53, 35, 224, 78, 134, 44, 29, 5, 60, 212, 159, 227, 14, 171, 24, 177, 88, 140])), SecretKey(Scalar([220, 48, 226, 142, 170, 161, 130, 158, 109, 139, 149, 103, 73, 107, 171, 13, 146, 72, 80, 52, 117, 100, 162, 191, 170, 157, 57, 149, 175, 31, 12, 12])));
/// API: GDAPI223GGZAYRGAR5ZEOV4KXJKQYPAD5IYOG2MRSVAVT5KQANUAZGRN
static immutable API = KeyPair(PublicKey(Point([192, 244, 107, 91, 49, 178, 12, 68, 192, 143, 114, 71, 87, 138, 186, 85, 12, 60, 3, 234, 48, 227, 105, 145, 149, 65, 89, 245, 80, 3, 104, 12])), SecretKey(Scalar([21, 74, 241, 3, 191, 171, 213, 215, 202, 175, 245, 179, 148, 65, 38, 125, 194, 166, 103, 25, 85, 101, 254, 208, 63, 95, 68, 156, 79, 173, 146, 5])));
/// APJ: GDAPJ22WBSGWLFIFELTMOT7IVTEKSDBAAZTLBTKIRFKGNWYCCFHPECHY
static immutable APJ = KeyPair(PublicKey(Point([192, 244, 235, 86, 12, 141, 101, 149, 5, 34, 230, 199, 79, 232, 172, 200, 169, 12, 32, 6, 102, 176, 205, 72, 137, 84, 102, 219, 2, 17, 78, 242])), SecretKey(Scalar([109, 137, 165, 38, 219, 41, 87, 181, 242, 246, 245, 157, 251, 96, 225, 190, 106, 38, 122, 250, 111, 8, 217, 185, 118, 152, 148, 196, 159, 173, 252, 15])));
/// APK: GDAPK22ICQGN3KCICDCWMQVE3J2YTA2O6TPAHUYQI4HE6RPM5FGTG347
static immutable APK = KeyPair(PublicKey(Point([192, 245, 107, 72, 20, 12, 221, 168, 72, 16, 197, 102, 66, 164, 218, 117, 137, 131, 78, 244, 222, 3, 211, 16, 71, 14, 79, 69, 236, 233, 77, 51])), SecretKey(Scalar([126, 189, 53, 200, 45, 38, 130, 233, 74, 53, 131, 211, 138, 207, 102, 49, 113, 72, 77, 72, 60, 144, 44, 165, 248, 202, 195, 100, 88, 88, 214, 10])));
/// APL: GDAPL22AIYGFYCAOYVVAPAWKECEH3HNVX527SO6UQP5QK2TTXO52PJE7
static immutable APL = KeyPair(PublicKey(Point([192, 245, 235, 64, 70, 12, 92, 8, 14, 197, 106, 7, 130, 202, 32, 136, 125, 157, 181, 191, 117, 249, 59, 212, 131, 251, 5, 106, 115, 187, 187, 167])), SecretKey(Scalar([154, 213, 212, 32, 182, 46, 3, 152, 83, 70, 11, 165, 193, 35, 81, 243, 204, 44, 117, 96, 235, 233, 108, 92, 24, 107, 138, 79, 108, 87, 176, 7])));
/// APM: GDAPM22G42WS7P2ONAXIQPGRWCI6R37YRVVI7BPTXZ7GITTM5R2H5RKS
static immutable APM = KeyPair(PublicKey(Point([192, 246, 107, 70, 230, 173, 47, 191, 78, 104, 46, 136, 60, 209, 176, 145, 232, 239, 248, 141, 106, 143, 133, 243, 190, 126, 100, 78, 108, 236, 116, 126])), SecretKey(Scalar([72, 78, 206, 32, 33, 203, 232, 45, 97, 213, 247, 26, 181, 154, 208, 195, 83, 140, 196, 110, 24, 67, 9, 252, 64, 104, 155, 51, 98, 43, 153, 5])));
/// APN: GDAPN22X33WJ545AFBH7K7AODAGSRWLJXMFCAI6H6BHIULU27MSQUBOU
static immutable APN = KeyPair(PublicKey(Point([192, 246, 235, 87, 222, 236, 158, 243, 160, 40, 79, 245, 124, 14, 24, 13, 40, 217, 105, 187, 10, 32, 35, 199, 240, 78, 138, 46, 154, 251, 37, 10])), SecretKey(Scalar([192, 187, 14, 197, 248, 17, 161, 15, 9, 59, 125, 36, 61, 66, 26, 203, 238, 78, 223, 223, 171, 217, 67, 62, 27, 129, 229, 150, 25, 218, 174, 11])));
/// APO: GDAPO22UA2XW63JJGXNU5PZYLHHTYQDUCQK7EZFD3W4SBEEBJU76RP42
static immutable APO = KeyPair(PublicKey(Point([192, 247, 107, 84, 6, 175, 111, 109, 41, 53, 219, 78, 191, 56, 89, 207, 60, 64, 116, 20, 21, 242, 100, 163, 221, 185, 32, 144, 129, 77, 63, 232])), SecretKey(Scalar([188, 161, 21, 249, 102, 230, 142, 167, 138, 78, 33, 148, 55, 227, 201, 24, 79, 84, 16, 110, 154, 24, 57, 146, 41, 166, 173, 170, 29, 202, 117, 10])));
/// APP: GDAPP22EWNX6AEOY4G3GDSY5HWUNDZSHJVCZT4JT3ZAAAHLITZTHEY35
static immutable APP = KeyPair(PublicKey(Point([192, 247, 235, 68, 179, 111, 224, 17, 216, 225, 182, 97, 203, 29, 61, 168, 209, 230, 71, 77, 69, 153, 241, 51, 222, 64, 0, 29, 104, 158, 102, 114])), SecretKey(Scalar([149, 147, 164, 227, 27, 66, 136, 184, 60, 184, 250, 150, 223, 61, 209, 23, 155, 67, 54, 78, 118, 102, 190, 201, 201, 12, 64, 207, 239, 48, 55, 8])));
/// APQ: GDAPQ22CPI64IUENSYFBO537WAC3KWFTUKDPTOYJALDX3QPP3O27AQEV
static immutable APQ = KeyPair(PublicKey(Point([192, 248, 107, 66, 122, 61, 196, 80, 141, 150, 10, 23, 119, 127, 176, 5, 181, 88, 179, 162, 134, 249, 187, 9, 2, 199, 125, 193, 239, 219, 181, 240])), SecretKey(Scalar([111, 154, 132, 84, 132, 235, 31, 215, 133, 13, 153, 159, 214, 46, 67, 103, 131, 114, 78, 174, 8, 237, 52, 43, 70, 115, 118, 3, 167, 228, 155, 2])));
/// APR: GDAPR222CFLPF4EJ7DBQ47QIBYD2IFNP3XV363YK3JACHU3X3MDRWFI2
static immutable APR = KeyPair(PublicKey(Point([192, 248, 235, 90, 17, 86, 242, 240, 137, 248, 195, 14, 126, 8, 14, 7, 164, 21, 175, 221, 235, 191, 111, 10, 218, 64, 35, 211, 119, 219, 7, 27])), SecretKey(Scalar([12, 76, 100, 173, 161, 99, 253, 246, 17, 197, 51, 231, 92, 192, 101, 33, 134, 67, 76, 51, 30, 194, 198, 63, 129, 10, 60, 52, 21, 92, 39, 0])));
/// APS: GDAPS22DMIBXC4P5CZBKNDUNZBOSSJ4HFAPFNPEH7QVN4SIJUGA7KWZX
static immutable APS = KeyPair(PublicKey(Point([192, 249, 107, 67, 98, 3, 113, 113, 253, 22, 66, 166, 142, 141, 200, 93, 41, 39, 135, 40, 30, 86, 188, 135, 252, 42, 222, 73, 9, 161, 129, 245])), SecretKey(Scalar([180, 22, 201, 255, 49, 42, 206, 154, 88, 205, 71, 248, 180, 250, 138, 248, 54, 138, 227, 78, 138, 227, 43, 255, 135, 243, 119, 138, 234, 213, 104, 15])));
/// APT: GDAPT226SURDCVUR46MFCS3LPQ524I7WZ4DBEXTGFWEDQGBORO52IHOB
static immutable APT = KeyPair(PublicKey(Point([192, 249, 235, 94, 149, 34, 49, 86, 145, 231, 152, 81, 75, 107, 124, 59, 174, 35, 246, 207, 6, 18, 94, 102, 45, 136, 56, 24, 46, 139, 187, 164])), SecretKey(Scalar([180, 195, 31, 147, 174, 6, 104, 250, 57, 64, 219, 126, 38, 21, 72, 41, 47, 183, 113, 157, 172, 248, 146, 105, 125, 26, 8, 161, 62, 163, 212, 7])));
/// APU: GDAPU2276NPK5I5KA4ZO3LDOIIINLHSB3MDJTPT3PED3X4P5GN5KTUOG
static immutable APU = KeyPair(PublicKey(Point([192, 250, 107, 95, 243, 94, 174, 163, 170, 7, 50, 237, 172, 110, 66, 16, 213, 158, 65, 219, 6, 153, 190, 123, 121, 7, 187, 241, 253, 51, 122, 169])), SecretKey(Scalar([161, 84, 19, 57, 220, 217, 253, 100, 105, 180, 176, 23, 170, 83, 213, 177, 249, 212, 198, 196, 196, 132, 9, 155, 202, 205, 140, 242, 237, 245, 42, 10])));
/// APV: GDAPV22IRXFEG45NKK7GJURIFZ5YN6IL437CHLZP4YNGCDJEGWU3VVAX
static immutable APV = KeyPair(PublicKey(Point([192, 250, 235, 72, 141, 202, 67, 115, 173, 82, 190, 100, 210, 40, 46, 123, 134, 249, 11, 230, 254, 35, 175, 47, 230, 26, 97, 13, 36, 53, 169, 186])), SecretKey(Scalar([74, 119, 215, 201, 203, 186, 166, 233, 76, 44, 167, 145, 58, 116, 57, 123, 61, 154, 154, 35, 253, 145, 65, 244, 40, 231, 19, 226, 52, 240, 146, 10])));
/// APW: GDAPW22IGAHPQQ6QQA7RKMCKHXEJGEUQMVKUSZUTUYCB4D5NFX7B6PMM
static immutable APW = KeyPair(PublicKey(Point([192, 251, 107, 72, 48, 14, 248, 67, 208, 128, 63, 21, 48, 74, 61, 200, 147, 18, 144, 101, 85, 73, 102, 147, 166, 4, 30, 15, 173, 45, 254, 31])), SecretKey(Scalar([105, 0, 214, 226, 201, 233, 239, 111, 226, 120, 26, 108, 61, 218, 53, 27, 4, 66, 234, 203, 186, 137, 43, 175, 6, 95, 59, 195, 245, 213, 217, 13])));
/// APX: GDAPX223PFUKCZSDSJ3RZM67PDQ7IL24ZBROG5VXOWK5XLP5FYR6JQN7
static immutable APX = KeyPair(PublicKey(Point([192, 251, 235, 91, 121, 104, 161, 102, 67, 146, 119, 28, 179, 223, 120, 225, 244, 47, 92, 200, 98, 227, 118, 183, 117, 149, 219, 173, 253, 46, 35, 228])), SecretKey(Scalar([14, 230, 104, 44, 54, 70, 177, 99, 203, 140, 120, 243, 196, 221, 253, 228, 236, 63, 31, 208, 168, 103, 61, 13, 43, 66, 69, 6, 175, 126, 200, 6])));
/// APY: GDAPY22TYHSCKH7GNRE5EGYIC6IKUCHGHF4VIDNOZ4HMSBNFXFVL6VMQ
static immutable APY = KeyPair(PublicKey(Point([192, 252, 107, 83, 193, 228, 37, 31, 230, 108, 73, 210, 27, 8, 23, 144, 170, 8, 230, 57, 121, 84, 13, 174, 207, 14, 201, 5, 165, 185, 106, 191])), SecretKey(Scalar([225, 108, 102, 251, 3, 81, 227, 115, 43, 32, 153, 236, 182, 223, 135, 101, 86, 206, 133, 83, 3, 255, 138, 60, 149, 105, 130, 241, 54, 62, 214, 10])));
/// APZ: GDAPZ22MFXT7PF5A7C6LOAHIBUM2POPPZNRHKSCGUUOMOP356CVGL2JM
static immutable APZ = KeyPair(PublicKey(Point([192, 252, 235, 76, 45, 231, 247, 151, 160, 248, 188, 183, 0, 232, 13, 25, 167, 185, 239, 203, 98, 117, 72, 70, 165, 28, 199, 63, 125, 240, 170, 101])), SecretKey(Scalar([115, 38, 64, 206, 138, 144, 14, 131, 250, 197, 101, 199, 222, 234, 126, 26, 210, 231, 73, 242, 37, 46, 140, 5, 174, 120, 203, 244, 238, 246, 111, 14])));
/// AQA: GDAQA22PRQMOXKIH6E4BRFSA5ZSPAGYKZSHG64F7ZDY5D7QMOTNW7HEZ
static immutable AQA = KeyPair(PublicKey(Point([193, 0, 107, 79, 140, 24, 235, 169, 7, 241, 56, 24, 150, 64, 238, 100, 240, 27, 10, 204, 142, 111, 112, 191, 200, 241, 209, 254, 12, 116, 219, 111])), SecretKey(Scalar([156, 208, 82, 39, 131, 72, 64, 141, 23, 147, 156, 166, 76, 156, 174, 186, 82, 191, 23, 163, 143, 201, 35, 167, 225, 234, 63, 94, 79, 11, 190, 13])));
/// AQB: GDAQB22AEV4UKDMTFB4VDOWXULJ3XQH67PCZ355RWENAI2EJM3QAGCRB
static immutable AQB = KeyPair(PublicKey(Point([193, 0, 235, 64, 37, 121, 69, 13, 147, 40, 121, 81, 186, 215, 162, 211, 187, 192, 254, 251, 197, 157, 247, 177, 177, 26, 4, 104, 137, 102, 224, 3])), SecretKey(Scalar([214, 130, 16, 8, 76, 93, 146, 96, 177, 3, 209, 136, 60, 54, 163, 75, 21, 65, 172, 188, 220, 177, 235, 75, 173, 25, 0, 166, 224, 252, 15, 1])));
/// AQC: GDAQC22EO73YAXMYWM3IG73RVXTMOQCL37OBQLVGXE7WOGNMYGQSSDTZ
static immutable AQC = KeyPair(PublicKey(Point([193, 1, 107, 68, 119, 247, 128, 93, 152, 179, 54, 131, 127, 113, 173, 230, 199, 64, 75, 223, 220, 24, 46, 166, 185, 63, 103, 25, 172, 193, 161, 41])), SecretKey(Scalar([182, 111, 4, 143, 91, 248, 15, 37, 212, 206, 110, 234, 201, 210, 136, 247, 112, 103, 79, 148, 67, 6, 198, 71, 127, 145, 199, 124, 25, 237, 149, 4])));
/// AQD: GDAQD2273V2J6OMER2AJIKZERGJS6I2LVUF53TZHMVGEDQ2353XAQBCR
static immutable AQD = KeyPair(PublicKey(Point([193, 1, 235, 95, 221, 116, 159, 57, 132, 142, 128, 148, 43, 36, 137, 147, 47, 35, 75, 173, 11, 221, 207, 39, 101, 76, 65, 195, 91, 238, 238, 8])), SecretKey(Scalar([229, 99, 75, 191, 124, 238, 115, 34, 220, 171, 73, 223, 44, 84, 127, 93, 201, 112, 29, 95, 159, 32, 68, 241, 243, 249, 90, 197, 83, 240, 185, 5])));
/// AQE: GDAQE22RDTHX4NUBAA5PFRG57HSVJNLR3YP2DE7DAONCPXBUGBC47KJC
static immutable AQE = KeyPair(PublicKey(Point([193, 2, 107, 81, 28, 207, 126, 54, 129, 0, 58, 242, 196, 221, 249, 229, 84, 181, 113, 222, 31, 161, 147, 227, 3, 154, 39, 220, 52, 48, 69, 207])), SecretKey(Scalar([12, 61, 83, 135, 138, 36, 163, 90, 23, 103, 48, 192, 105, 160, 141, 23, 38, 54, 63, 18, 108, 74, 187, 169, 247, 232, 225, 100, 95, 55, 159, 10])));
/// AQF: GDAQF22WKA4S25AZYHA7RFP43NCPWTAAN2FIXQWN3HU4ACFJ2YRYZBWW
static immutable AQF = KeyPair(PublicKey(Point([193, 2, 235, 86, 80, 57, 45, 116, 25, 193, 193, 248, 149, 252, 219, 68, 251, 76, 0, 110, 138, 139, 194, 205, 217, 233, 192, 8, 169, 214, 35, 140])), SecretKey(Scalar([157, 61, 206, 42, 157, 58, 139, 20, 187, 180, 55, 202, 101, 148, 33, 55, 86, 30, 6, 91, 29, 33, 91, 187, 159, 56, 3, 67, 22, 192, 54, 10])));
/// AQG: GDAQG22B6MLY6R3Z2KP32XYFTO3AYDN75VB46VCFJ2K22WTTDTTBABFO
static immutable AQG = KeyPair(PublicKey(Point([193, 3, 107, 65, 243, 23, 143, 71, 121, 210, 159, 189, 95, 5, 155, 182, 12, 13, 191, 237, 67, 207, 84, 69, 78, 149, 173, 90, 115, 28, 230, 16])), SecretKey(Scalar([169, 43, 140, 243, 130, 116, 211, 132, 45, 176, 218, 159, 119, 21, 92, 139, 1, 44, 24, 253, 156, 32, 3, 28, 32, 90, 90, 149, 100, 129, 182, 14])));
/// AQH: GDAQH22JJ5GLUTW3TERABZ4HGZWFVEXIJEPTNM5UFBKAO3TO52KU6TCS
static immutable AQH = KeyPair(PublicKey(Point([193, 3, 235, 73, 79, 76, 186, 78, 219, 153, 34, 0, 231, 135, 54, 108, 90, 146, 232, 73, 31, 54, 179, 180, 40, 84, 7, 110, 110, 238, 149, 79])), SecretKey(Scalar([93, 250, 122, 200, 127, 255, 251, 74, 235, 249, 74, 254, 148, 130, 138, 169, 162, 92, 240, 21, 159, 115, 31, 99, 165, 79, 107, 87, 101, 183, 203, 8])));
/// AQI: GDAQI22D6AFAT6KIHP7RIF25MDLYFWD5JNT6KKQVPJTCUWPISVSLQJCF
static immutable AQI = KeyPair(PublicKey(Point([193, 4, 107, 67, 240, 10, 9, 249, 72, 59, 255, 20, 23, 93, 96, 215, 130, 216, 125, 75, 103, 229, 42, 21, 122, 102, 42, 89, 232, 149, 100, 184])), SecretKey(Scalar([103, 237, 108, 106, 32, 122, 251, 96, 142, 219, 190, 124, 90, 195, 38, 201, 195, 120, 122, 153, 213, 10, 73, 197, 106, 109, 223, 154, 91, 43, 116, 15])));
/// AQJ: GDAQJ22NVUZPNBTD2AI4A2UO3AJMB4LUDW6UM7PBIDS7PIDN4PVN3WAU
static immutable AQJ = KeyPair(PublicKey(Point([193, 4, 235, 77, 173, 50, 246, 134, 99, 208, 17, 192, 106, 142, 216, 18, 192, 241, 116, 29, 189, 70, 125, 225, 64, 229, 247, 160, 109, 227, 234, 221])), SecretKey(Scalar([141, 86, 3, 66, 66, 141, 75, 234, 134, 127, 79, 83, 34, 68, 110, 180, 155, 187, 186, 135, 48, 255, 171, 16, 85, 215, 98, 22, 17, 18, 21, 13])));
/// AQK: GDAQK22G327E6M6K7SYPA5GILTTQM67NL47S2AHW7N7PFJVH7GDZRZDX
static immutable AQK = KeyPair(PublicKey(Point([193, 5, 107, 70, 222, 190, 79, 51, 202, 252, 176, 240, 116, 200, 92, 231, 6, 123, 237, 95, 63, 45, 0, 246, 251, 126, 242, 166, 167, 249, 135, 152])), SecretKey(Scalar([82, 58, 57, 139, 227, 231, 62, 103, 140, 144, 20, 83, 159, 148, 106, 56, 231, 69, 73, 196, 64, 1, 197, 177, 252, 202, 160, 70, 127, 217, 117, 12])));
/// AQL: GDAQL22TPU7QYJEFHASBQ3B7RPOO4R5I5U3T4VIIU5USNZDFTQMFSS3S
static immutable AQL = KeyPair(PublicKey(Point([193, 5, 235, 83, 125, 63, 12, 36, 133, 56, 36, 24, 108, 63, 139, 220, 238, 71, 168, 237, 55, 62, 85, 8, 167, 105, 38, 228, 101, 156, 24, 89])), SecretKey(Scalar([14, 208, 12, 197, 133, 77, 156, 236, 232, 188, 223, 135, 53, 191, 142, 235, 47, 30, 54, 243, 197, 5, 36, 62, 129, 24, 169, 10, 76, 31, 44, 0])));
/// AQM: GDAQM22PFZH3FT6B43U63PXQA2NOVEIANTEVZ5DYLLDK5RNMBCCFZI47
static immutable AQM = KeyPair(PublicKey(Point([193, 6, 107, 79, 46, 79, 178, 207, 193, 230, 233, 237, 190, 240, 6, 154, 234, 145, 0, 108, 201, 92, 244, 120, 90, 198, 174, 197, 172, 8, 132, 92])), SecretKey(Scalar([215, 78, 120, 225, 207, 86, 133, 32, 255, 128, 247, 203, 44, 227, 0, 218, 200, 68, 237, 174, 195, 3, 41, 223, 196, 98, 75, 119, 186, 62, 251, 15])));
/// AQN: GDAQN222FWNW7IL4X7O6EBZHKNLRC5O42W4C43CUE7JTHTMDEIS7ZRE4
static immutable AQN = KeyPair(PublicKey(Point([193, 6, 235, 90, 45, 155, 111, 161, 124, 191, 221, 226, 7, 39, 83, 87, 17, 117, 220, 213, 184, 46, 108, 84, 39, 211, 51, 205, 131, 34, 37, 252])), SecretKey(Scalar([141, 243, 201, 8, 70, 68, 245, 77, 177, 206, 222, 158, 91, 207, 221, 105, 89, 125, 22, 102, 16, 43, 18, 199, 119, 150, 197, 99, 206, 45, 18, 14])));
/// AQO: GDAQO22KBEZYIIVKJAMRLI5BGULJG3JEZLTHLQBTX65LFPGCRMKV5BEX
static immutable AQO = KeyPair(PublicKey(Point([193, 7, 107, 74, 9, 51, 132, 34, 170, 72, 25, 21, 163, 161, 53, 22, 147, 109, 36, 202, 230, 117, 192, 51, 191, 186, 178, 188, 194, 139, 21, 94])), SecretKey(Scalar([155, 24, 210, 232, 131, 235, 193, 99, 81, 109, 194, 80, 201, 238, 149, 95, 206, 2, 195, 122, 49, 91, 131, 40, 128, 14, 227, 98, 57, 114, 91, 7])));
/// AQP: GDAQP22FQMIUYEWLYFPARNMD4XI6NZ75CN77DDAA2B5VTMUWXBNW3WLS
static immutable AQP = KeyPair(PublicKey(Point([193, 7, 235, 69, 131, 17, 76, 18, 203, 193, 94, 8, 181, 131, 229, 209, 230, 231, 253, 19, 127, 241, 140, 0, 208, 123, 89, 178, 150, 184, 91, 109])), SecretKey(Scalar([35, 45, 182, 194, 17, 184, 69, 6, 63, 226, 176, 83, 145, 54, 224, 61, 105, 53, 56, 113, 171, 156, 238, 132, 87, 217, 15, 9, 195, 163, 221, 1])));
/// AQQ: GDAQQ22IOTI5C65C22FQQTFO4MGTOHCCZK5I2HQZ2IMGC2VPUHJZUQLN
static immutable AQQ = KeyPair(PublicKey(Point([193, 8, 107, 72, 116, 209, 209, 123, 162, 214, 139, 8, 76, 174, 227, 13, 55, 28, 66, 202, 186, 141, 30, 25, 210, 24, 97, 106, 175, 161, 211, 154])), SecretKey(Scalar([212, 9, 140, 105, 233, 241, 140, 31, 7, 87, 203, 249, 54, 188, 242, 16, 14, 229, 166, 159, 25, 157, 225, 186, 55, 178, 33, 21, 192, 118, 72, 12])));
/// AQR: GDAQR22FLGWL6F2BH4AIOWSJGYVQMFHQ3KNDVY7K37A2W4RBWUEK5T24
static immutable AQR = KeyPair(PublicKey(Point([193, 8, 235, 69, 89, 172, 191, 23, 65, 63, 0, 135, 90, 73, 54, 43, 6, 20, 240, 218, 154, 58, 227, 234, 223, 193, 171, 114, 33, 181, 8, 174])), SecretKey(Scalar([78, 98, 42, 231, 165, 170, 127, 194, 14, 112, 92, 40, 223, 136, 13, 22, 83, 201, 158, 245, 96, 220, 213, 118, 252, 232, 218, 179, 220, 252, 173, 3])));
/// AQS: GDAQS22PRS7USPSRBUCMJI3LGXN2Y24ZRKHEVTYV7SC6CJFAC6YEG3JN
static immutable AQS = KeyPair(PublicKey(Point([193, 9, 107, 79, 140, 191, 73, 62, 81, 13, 4, 196, 163, 107, 53, 219, 172, 107, 153, 138, 142, 74, 207, 21, 252, 133, 225, 36, 160, 23, 176, 67])), SecretKey(Scalar([74, 71, 81, 122, 84, 236, 13, 1, 196, 201, 153, 177, 200, 13, 244, 181, 215, 23, 162, 162, 206, 48, 126, 32, 112, 224, 59, 148, 29, 116, 76, 15])));
/// AQT: GDAQT22XMDQBQYGZ3X42U3LOR7WJOESV5U4GBKGHYMRDUMJWIYTGKHTL
static immutable AQT = KeyPair(PublicKey(Point([193, 9, 235, 87, 96, 224, 24, 96, 217, 221, 249, 170, 109, 110, 143, 236, 151, 18, 85, 237, 56, 96, 168, 199, 195, 34, 58, 49, 54, 70, 38, 101])), SecretKey(Scalar([179, 215, 248, 99, 95, 229, 129, 194, 30, 208, 22, 90, 45, 199, 160, 161, 232, 123, 160, 250, 169, 241, 65, 74, 170, 171, 234, 93, 48, 120, 116, 8])));
/// AQU: GDAQU22X5TRE5JG556DZ3IR6SFJQYXVSD5WQYLUEDGSD5QRBU62PUSFR
static immutable AQU = KeyPair(PublicKey(Point([193, 10, 107, 87, 236, 226, 78, 164, 221, 239, 135, 157, 162, 62, 145, 83, 12, 94, 178, 31, 109, 12, 46, 132, 25, 164, 62, 194, 33, 167, 180, 250])), SecretKey(Scalar([209, 120, 248, 114, 231, 210, 124, 203, 40, 126, 81, 124, 15, 127, 65, 195, 248, 79, 195, 33, 216, 23, 159, 251, 30, 45, 121, 64, 80, 122, 115, 12])));
/// AQV: GDAQV22MIGO5KWBI6AJCBM7AWTPXLHDYPWXM2KI5RKFMSFUASPH3OVZW
static immutable AQV = KeyPair(PublicKey(Point([193, 10, 235, 76, 65, 157, 213, 88, 40, 240, 18, 32, 179, 224, 180, 223, 117, 156, 120, 125, 174, 205, 41, 29, 138, 138, 201, 22, 128, 147, 207, 183])), SecretKey(Scalar([219, 140, 116, 179, 122, 106, 203, 176, 129, 135, 239, 31, 151, 241, 206, 17, 156, 228, 208, 179, 171, 124, 79, 234, 4, 114, 184, 91, 211, 185, 241, 7])));
/// AQW: GDAQW22MSOZ4AD26UENPOEFHRMNSPOTQYU7M7A6NP6EQ7J6X6JUDXL6J
static immutable AQW = KeyPair(PublicKey(Point([193, 11, 107, 76, 147, 179, 192, 15, 94, 161, 26, 247, 16, 167, 139, 27, 39, 186, 112, 197, 62, 207, 131, 205, 127, 137, 15, 167, 215, 242, 104, 59])), SecretKey(Scalar([57, 152, 28, 48, 67, 91, 239, 97, 172, 24, 131, 191, 225, 146, 188, 26, 185, 138, 165, 224, 25, 215, 190, 22, 141, 171, 42, 67, 158, 28, 212, 12])));
/// AQX: GDAQX22V5KTG3YKWXTUMVPMFTM2XWWGICJ7ODUOZRP25NWZPC5FVEG2U
static immutable AQX = KeyPair(PublicKey(Point([193, 11, 235, 85, 234, 166, 109, 225, 86, 188, 232, 202, 189, 133, 155, 53, 123, 88, 200, 18, 126, 225, 209, 217, 139, 245, 214, 219, 47, 23, 75, 82])), SecretKey(Scalar([29, 213, 124, 41, 37, 50, 58, 182, 79, 129, 240, 178, 240, 36, 243, 176, 69, 9, 251, 168, 64, 2, 7, 192, 26, 125, 113, 47, 75, 164, 221, 13])));
/// AQY: GDAQY222XOX2ZXURQYQM6G4WOO7CR4MU552R55VLMV6Q4HLCVAW4HF4R
static immutable AQY = KeyPair(PublicKey(Point([193, 12, 107, 90, 187, 175, 172, 222, 145, 134, 32, 207, 27, 150, 115, 190, 40, 241, 148, 239, 117, 30, 246, 171, 101, 125, 14, 29, 98, 168, 45, 195])), SecretKey(Scalar([240, 151, 125, 15, 50, 177, 176, 156, 171, 55, 186, 144, 115, 205, 133, 49, 51, 98, 46, 32, 182, 95, 128, 167, 175, 61, 155, 61, 208, 248, 69, 4])));
/// AQZ: GDAQZ227LNDWRBFGFDSOEZGLBJD3LDEACX6YRHUKUUB4PC2V7MMVJXDH
static immutable AQZ = KeyPair(PublicKey(Point([193, 12, 235, 95, 91, 71, 104, 132, 166, 40, 228, 226, 100, 203, 10, 71, 181, 140, 128, 21, 253, 136, 158, 138, 165, 3, 199, 139, 85, 251, 25, 84])), SecretKey(Scalar([131, 174, 67, 210, 199, 108, 29, 75, 158, 10, 11, 57, 44, 96, 60, 106, 147, 180, 166, 227, 11, 186, 226, 244, 15, 16, 229, 108, 144, 46, 59, 7])));
/// ARA: GDARA222ZT3LZMYP2VIZRGNTBUQTCOBRCFCUMTQACUNHE7TUPGMYOGAM
static immutable ARA = KeyPair(PublicKey(Point([193, 16, 107, 90, 204, 246, 188, 179, 15, 213, 81, 152, 153, 179, 13, 33, 49, 56, 49, 17, 69, 70, 78, 0, 21, 26, 114, 126, 116, 121, 153, 135])), SecretKey(Scalar([174, 213, 211, 21, 213, 10, 139, 231, 95, 146, 99, 64, 64, 252, 14, 187, 60, 247, 100, 36, 101, 131, 118, 187, 148, 169, 172, 153, 120, 155, 18, 6])));
/// ARB: GDARB22BQ7B53QGSH5J4RIIKDJBZWAIKYKQ5Y532OYUZA3U3PL4VZXSK
static immutable ARB = KeyPair(PublicKey(Point([193, 16, 235, 65, 135, 195, 221, 192, 210, 63, 83, 200, 161, 10, 26, 67, 155, 1, 10, 194, 161, 220, 119, 122, 118, 41, 144, 110, 155, 122, 249, 92])), SecretKey(Scalar([129, 1, 230, 1, 83, 176, 195, 168, 154, 142, 114, 215, 82, 36, 195, 102, 207, 13, 5, 202, 139, 234, 122, 178, 39, 251, 88, 105, 26, 51, 143, 4])));
/// ARC: GDARC225O5FBA5JNRQOECYHJTLN2TJ74377CXUE7KRYCE6WN7XX5Y336
static immutable ARC = KeyPair(PublicKey(Point([193, 17, 107, 93, 119, 74, 16, 117, 45, 140, 28, 65, 96, 233, 154, 219, 169, 167, 252, 223, 254, 43, 208, 159, 84, 112, 34, 122, 205, 253, 239, 220])), SecretKey(Scalar([190, 131, 103, 46, 211, 11, 217, 209, 175, 203, 154, 112, 36, 88, 41, 153, 195, 123, 60, 238, 11, 153, 206, 189, 107, 222, 123, 19, 170, 20, 154, 6])));
/// ARD: GDARD226C7MLKMQMZREDIGMQ4EEWELSCACKUO4GLFAHTCXMBJ3CK6SIH
static immutable ARD = KeyPair(PublicKey(Point([193, 17, 235, 94, 23, 216, 181, 50, 12, 204, 72, 52, 25, 144, 225, 9, 98, 46, 66, 0, 149, 71, 112, 203, 40, 15, 49, 93, 129, 78, 196, 175])), SecretKey(Scalar([153, 56, 206, 190, 177, 174, 15, 228, 242, 62, 139, 51, 34, 44, 227, 123, 83, 117, 53, 88, 212, 10, 70, 115, 133, 111, 35, 68, 29, 147, 157, 3])));
/// ARE: GDARE22KIVBF53YSIRJ4UXP7U3SXKZO72XZHCRCDFVOYHUTREKGR2MRI
static immutable ARE = KeyPair(PublicKey(Point([193, 18, 107, 74, 69, 66, 94, 239, 18, 68, 83, 202, 93, 255, 166, 229, 117, 101, 223, 213, 242, 113, 68, 67, 45, 93, 131, 210, 113, 34, 141, 29])), SecretKey(Scalar([55, 119, 60, 178, 129, 35, 121, 142, 180, 210, 147, 227, 75, 179, 195, 125, 192, 251, 79, 149, 5, 237, 221, 201, 107, 139, 210, 45, 45, 207, 185, 15])));
/// ARF: GDARF22YEJBCUUWGK7FX7UISNMKJ3CNNRWOSQDH63J2TQG4HA25KGTBT
static immutable ARF = KeyPair(PublicKey(Point([193, 18, 235, 88, 34, 66, 42, 82, 198, 87, 203, 127, 209, 18, 107, 20, 157, 137, 173, 141, 157, 40, 12, 254, 218, 117, 56, 27, 135, 6, 186, 163])), SecretKey(Scalar([186, 179, 254, 36, 223, 101, 213, 248, 30, 20, 148, 103, 94, 224, 115, 173, 2, 230, 221, 168, 68, 251, 11, 49, 133, 178, 114, 106, 249, 60, 65, 6])));
/// ARG: GDARG22D7ORMOI6AZ6YKYD3F435HHYWIGUUJ3STJACJALQNJQUMEW4CP
static immutable ARG = KeyPair(PublicKey(Point([193, 19, 107, 67, 251, 162, 199, 35, 192, 207, 176, 172, 15, 101, 230, 250, 115, 226, 200, 53, 40, 157, 202, 105, 0, 146, 5, 193, 169, 133, 24, 75])), SecretKey(Scalar([142, 245, 58, 184, 127, 183, 114, 88, 250, 81, 23, 226, 56, 200, 196, 18, 5, 133, 170, 98, 183, 241, 96, 117, 74, 34, 49, 212, 56, 84, 12, 7])));
/// ARH: GDARH22MJPMBZGNAXXMRP74R4T7HZISW7BTCPTAEFHOAQT2YVCML74U2
static immutable ARH = KeyPair(PublicKey(Point([193, 19, 235, 76, 75, 216, 28, 153, 160, 189, 217, 23, 255, 145, 228, 254, 124, 162, 86, 248, 102, 39, 204, 4, 41, 220, 8, 79, 88, 168, 152, 191])), SecretKey(Scalar([160, 72, 190, 76, 91, 171, 80, 76, 23, 194, 137, 246, 215, 237, 66, 238, 187, 159, 67, 128, 170, 129, 23, 123, 107, 180, 71, 250, 51, 202, 250, 0])));
/// ARI: GDARI22J7BOH7RIH2VP6IWVTY4FWPHNIK7WFPOV5YM6EBIJRM55DU7TG
static immutable ARI = KeyPair(PublicKey(Point([193, 20, 107, 73, 248, 92, 127, 197, 7, 213, 95, 228, 90, 179, 199, 11, 103, 157, 168, 87, 236, 87, 186, 189, 195, 60, 64, 161, 49, 103, 122, 58])), SecretKey(Scalar([43, 25, 19, 120, 8, 191, 184, 73, 91, 148, 190, 253, 167, 136, 174, 112, 44, 8, 146, 145, 111, 144, 18, 161, 255, 150, 235, 139, 102, 237, 199, 2])));
/// ARJ: GDARJ22DRFU6UYJ5BWCDNL4O47FB7QEFNPSFZCJYR3HOAOPNPL7JCKY4
static immutable ARJ = KeyPair(PublicKey(Point([193, 20, 235, 67, 137, 105, 234, 97, 61, 13, 132, 54, 175, 142, 231, 202, 31, 192, 133, 107, 228, 92, 137, 56, 142, 206, 224, 57, 237, 122, 254, 145])), SecretKey(Scalar([128, 99, 61, 9, 149, 235, 80, 81, 86, 135, 230, 160, 207, 78, 11, 58, 249, 1, 106, 133, 94, 88, 227, 49, 38, 126, 36, 46, 201, 147, 53, 15])));
/// ARK: GDARK22YPTA5Z5CQF5DILYNM2HJQGJ6IWYUITXFIFUDV7FNI7RPCDLNW
static immutable ARK = KeyPair(PublicKey(Point([193, 21, 107, 88, 124, 193, 220, 244, 80, 47, 70, 133, 225, 172, 209, 211, 3, 39, 200, 182, 40, 137, 220, 168, 45, 7, 95, 149, 168, 252, 94, 33])), SecretKey(Scalar([250, 69, 22, 215, 124, 65, 146, 135, 187, 38, 181, 83, 103, 157, 9, 154, 187, 65, 156, 77, 148, 141, 116, 151, 179, 9, 220, 140, 125, 159, 28, 4])));
/// ARL: GDARL2254VDOFZG66O6NS7FCPLBGTR5PYZOW6RGN2CCWLQKOL5EUP4QZ
static immutable ARL = KeyPair(PublicKey(Point([193, 21, 235, 93, 229, 70, 226, 228, 222, 243, 188, 217, 124, 162, 122, 194, 105, 199, 175, 198, 93, 111, 68, 205, 208, 133, 101, 193, 78, 95, 73, 71])), SecretKey(Scalar([69, 80, 61, 88, 70, 133, 59, 170, 247, 30, 152, 44, 210, 135, 100, 179, 135, 139, 154, 134, 230, 248, 33, 185, 4, 48, 250, 174, 29, 104, 136, 8])));
/// ARM: GDARM22OF2B7ZG3EN65K65UCCBZ6TKDFKSP4PWV6T74GWFWVUA3ZZ3TX
static immutable ARM = KeyPair(PublicKey(Point([193, 22, 107, 78, 46, 131, 252, 155, 100, 111, 186, 175, 118, 130, 16, 115, 233, 168, 101, 84, 159, 199, 218, 190, 159, 248, 107, 22, 213, 160, 55, 156])), SecretKey(Scalar([168, 138, 142, 120, 30, 45, 99, 115, 250, 30, 0, 119, 225, 12, 230, 28, 231, 81, 94, 241, 232, 152, 161, 250, 205, 33, 63, 162, 94, 150, 112, 3])));
/// ARN: GDARN22GSFEVPZ7WGWRVORDKBZXOZCUV3IYOOTENYLD2K7DR6DUGG2XZ
static immutable ARN = KeyPair(PublicKey(Point([193, 22, 235, 70, 145, 73, 87, 231, 246, 53, 163, 87, 68, 106, 14, 110, 236, 138, 149, 218, 48, 231, 76, 141, 194, 199, 165, 124, 113, 240, 232, 99])), SecretKey(Scalar([117, 218, 161, 56, 23, 215, 158, 199, 241, 1, 37, 18, 241, 69, 245, 27, 33, 165, 255, 140, 147, 142, 243, 116, 26, 180, 2, 63, 115, 170, 236, 10])));
/// ARO: GDARO22I4SQHZUY2XPFSVDWEFRX3IAWQKVH6MFK7CH3XW6BPSS7EYML4
static immutable ARO = KeyPair(PublicKey(Point([193, 23, 107, 72, 228, 160, 124, 211, 26, 187, 203, 42, 142, 196, 44, 111, 180, 2, 208, 85, 79, 230, 21, 95, 17, 247, 123, 120, 47, 148, 190, 76])), SecretKey(Scalar([198, 208, 221, 192, 79, 76, 170, 73, 52, 36, 0, 56, 68, 174, 251, 106, 104, 9, 106, 110, 71, 174, 180, 227, 120, 199, 154, 63, 216, 107, 161, 1])));
/// ARP: GDARP22Y3YFLLTOZIOGSLCX62ZWVK74ZNJKV4BYMFPYW32OGGR46XWJQ
static immutable ARP = KeyPair(PublicKey(Point([193, 23, 235, 88, 222, 10, 181, 205, 217, 67, 141, 37, 138, 254, 214, 109, 85, 127, 153, 106, 85, 94, 7, 12, 43, 241, 109, 233, 198, 52, 121, 235])), SecretKey(Scalar([117, 25, 222, 205, 73, 210, 28, 130, 223, 115, 80, 166, 117, 12, 138, 98, 91, 5, 51, 253, 113, 251, 110, 186, 35, 204, 195, 147, 63, 78, 149, 15])));
/// ARQ: GDARQ22PX76P2XPHUML4FF6XC2HE5LOWZOAJXZEH4PMXX63ZGWRGUVYP
static immutable ARQ = KeyPair(PublicKey(Point([193, 24, 107, 79, 191, 252, 253, 93, 231, 163, 23, 194, 151, 215, 22, 142, 78, 173, 214, 203, 128, 155, 228, 135, 227, 217, 123, 251, 121, 53, 162, 106])), SecretKey(Scalar([232, 225, 133, 225, 144, 245, 231, 172, 233, 99, 228, 81, 103, 147, 81, 24, 148, 195, 60, 167, 202, 33, 54, 236, 171, 56, 86, 62, 100, 253, 212, 6])));
/// ARR: GDARR225QRVHVWIAGKYNSW67WP6VH2ZBG6JBXDDVUTI6A3LI4TZDFWCF
static immutable ARR = KeyPair(PublicKey(Point([193, 24, 235, 93, 132, 106, 122, 217, 0, 50, 176, 217, 91, 223, 179, 253, 83, 235, 33, 55, 146, 27, 140, 117, 164, 209, 224, 109, 104, 228, 242, 50])), SecretKey(Scalar([196, 71, 99, 87, 87, 76, 75, 145, 221, 88, 181, 109, 105, 58, 126, 65, 122, 167, 239, 14, 29, 52, 180, 72, 129, 119, 54, 151, 222, 211, 188, 3])));
/// ARS: GDARS22BPMTFLIX4VCQOUESGIZVJGGMYQHPWT4Q7IAZH2I2FP55DXVH3
static immutable ARS = KeyPair(PublicKey(Point([193, 25, 107, 65, 123, 38, 85, 162, 252, 168, 160, 234, 18, 70, 70, 106, 147, 25, 152, 129, 223, 105, 242, 31, 64, 50, 125, 35, 69, 127, 122, 59])), SecretKey(Scalar([92, 94, 135, 149, 66, 109, 196, 21, 150, 153, 40, 117, 16, 139, 0, 246, 129, 148, 150, 2, 199, 149, 156, 130, 78, 83, 60, 100, 209, 50, 46, 11])));
/// ART: GDART224CAX7JQ6VPOQ75MSCE2NO42UGIYJI3DKQTVRM2KALQCYZPTZ6
static immutable ART = KeyPair(PublicKey(Point([193, 25, 235, 92, 16, 47, 244, 195, 213, 123, 161, 254, 178, 66, 38, 154, 238, 106, 134, 70, 18, 141, 141, 80, 157, 98, 205, 40, 11, 128, 177, 151])), SecretKey(Scalar([18, 53, 126, 47, 158, 195, 185, 111, 117, 3, 250, 58, 122, 14, 161, 21, 39, 13, 32, 84, 48, 188, 49, 200, 109, 239, 239, 131, 45, 169, 217, 0])));
/// ARU: GDARU2232R4H2YYUQ52ONNGNGJ7ONSSM5SLNS4KTZMTMVVLLEOOQZSOO
static immutable ARU = KeyPair(PublicKey(Point([193, 26, 107, 91, 212, 120, 125, 99, 20, 135, 116, 230, 180, 205, 50, 126, 230, 202, 76, 236, 150, 217, 113, 83, 203, 38, 202, 213, 107, 35, 157, 12])), SecretKey(Scalar([98, 16, 225, 214, 228, 192, 207, 56, 94, 187, 99, 113, 152, 79, 60, 241, 73, 189, 115, 207, 156, 70, 210, 30, 117, 69, 198, 14, 178, 249, 39, 6])));
/// ARV: GDARV225F6CDD67SLSKC3YA6WLMYGR7FNC3CTGNH23QQB6O54VLVUCFR
static immutable ARV = KeyPair(PublicKey(Point([193, 26, 235, 93, 47, 132, 49, 251, 242, 92, 148, 45, 224, 30, 178, 217, 131, 71, 229, 104, 182, 41, 153, 167, 214, 225, 0, 249, 221, 229, 87, 90])), SecretKey(Scalar([126, 109, 52, 9, 49, 223, 106, 89, 171, 215, 223, 25, 62, 164, 142, 185, 47, 14, 51, 236, 113, 88, 65, 250, 15, 101, 182, 84, 40, 122, 245, 1])));
/// ARW: GDARW22HSY3TEBWKLZUSFKFQ2BW2C3L7NFNPKNFFEQTHRMCN3BEJ7O7D
static immutable ARW = KeyPair(PublicKey(Point([193, 27, 107, 71, 150, 55, 50, 6, 202, 94, 105, 34, 168, 176, 208, 109, 161, 109, 127, 105, 90, 245, 52, 165, 36, 38, 120, 176, 77, 216, 72, 159])), SecretKey(Scalar([50, 119, 219, 253, 174, 205, 63, 59, 30, 108, 190, 103, 98, 180, 9, 175, 249, 123, 52, 61, 109, 6, 110, 122, 91, 247, 249, 111, 247, 179, 244, 13])));
/// ARX: GDARX2226OZY73L6MYQL5ZYVGIX4R5PP234LUVLHJULNPM6F4274NGLL
static immutable ARX = KeyPair(PublicKey(Point([193, 27, 235, 90, 243, 179, 143, 237, 126, 102, 32, 190, 231, 21, 50, 47, 200, 245, 239, 214, 248, 186, 85, 103, 77, 22, 215, 179, 197, 230, 191, 198])), SecretKey(Scalar([255, 212, 83, 159, 252, 181, 98, 197, 177, 229, 112, 69, 171, 81, 177, 70, 20, 83, 146, 191, 99, 251, 23, 228, 138, 112, 221, 176, 90, 0, 201, 3])));
/// ARY: GDARY22DUERLTPFXCOWOXXLUTPMNHSZRBKSA7NAKZOFQEBUWCCAPNILY
static immutable ARY = KeyPair(PublicKey(Point([193, 28, 107, 67, 161, 34, 185, 188, 183, 19, 172, 235, 221, 116, 155, 216, 211, 203, 49, 10, 164, 15, 180, 10, 203, 139, 2, 6, 150, 16, 128, 246])), SecretKey(Scalar([110, 158, 180, 77, 136, 191, 50, 112, 113, 122, 137, 143, 2, 240, 135, 63, 238, 145, 166, 63, 184, 182, 94, 47, 156, 27, 253, 71, 188, 198, 168, 1])));
/// ARZ: GDARZ22XFYWC6A5JOTL5W54DN3YNNI6EB2MNAYD5WW6SACACEBWYQ6DX
static immutable ARZ = KeyPair(PublicKey(Point([193, 28, 235, 87, 46, 44, 47, 3, 169, 116, 215, 219, 119, 131, 110, 240, 214, 163, 196, 14, 152, 208, 96, 125, 181, 189, 32, 8, 2, 32, 109, 136])), SecretKey(Scalar([82, 86, 56, 4, 183, 69, 73, 157, 83, 68, 86, 32, 95, 255, 3, 154, 239, 63, 87, 227, 66, 29, 147, 20, 207, 151, 67, 42, 246, 70, 190, 14])));
/// ASA: GDASA22MUKOVE3M7YMJTZ73VCBGWIVIBPN7GQAHNADEOXX3WRSK3X4EO
static immutable ASA = KeyPair(PublicKey(Point([193, 32, 107, 76, 162, 157, 82, 109, 159, 195, 19, 60, 255, 117, 16, 77, 100, 85, 1, 123, 126, 104, 0, 237, 0, 200, 235, 223, 118, 140, 149, 187])), SecretKey(Scalar([243, 244, 120, 118, 52, 205, 42, 68, 194, 55, 146, 220, 0, 140, 98, 223, 29, 28, 225, 28, 208, 1, 146, 97, 158, 12, 71, 162, 167, 48, 208, 8])));
/// ASB: GDASB22IFHI5WWDAGIFJ4FKJN4DR7AHW5G6OYG45SI4FBYVRL5XZV7JQ
static immutable ASB = KeyPair(PublicKey(Point([193, 32, 235, 72, 41, 209, 219, 88, 96, 50, 10, 158, 21, 73, 111, 7, 31, 128, 246, 233, 188, 236, 27, 157, 146, 56, 80, 226, 177, 95, 111, 154])), SecretKey(Scalar([28, 74, 56, 96, 188, 197, 40, 78, 232, 207, 141, 98, 183, 206, 111, 108, 199, 80, 12, 8, 222, 43, 34, 18, 160, 215, 246, 121, 250, 4, 88, 12])));
/// ASC: GDASC22NNPVYV44XSFXWVS4IT4CYHBDRVOYZE6NLAVBWUJWOUKJLA3JJ
static immutable ASC = KeyPair(PublicKey(Point([193, 33, 107, 77, 107, 235, 138, 243, 151, 145, 111, 106, 203, 136, 159, 5, 131, 132, 113, 171, 177, 146, 121, 171, 5, 67, 106, 38, 206, 162, 146, 176])), SecretKey(Scalar([125, 23, 179, 210, 236, 215, 146, 243, 173, 51, 99, 87, 122, 83, 79, 213, 238, 246, 226, 198, 123, 162, 227, 11, 1, 174, 178, 156, 163, 232, 235, 10])));
/// ASD: GDASD226M4TNXGWAFUPBCJB46C6FXYCSMFG6WTF4PKEWSW4IGVNNKCNI
static immutable ASD = KeyPair(PublicKey(Point([193, 33, 235, 94, 103, 38, 219, 154, 192, 45, 30, 17, 36, 60, 240, 188, 91, 224, 82, 97, 77, 235, 76, 188, 122, 137, 105, 91, 136, 53, 90, 213])), SecretKey(Scalar([229, 107, 151, 43, 118, 161, 72, 248, 48, 23, 14, 199, 97, 104, 124, 57, 208, 72, 59, 76, 106, 199, 48, 133, 3, 71, 93, 202, 249, 163, 16, 2])));
/// ASE: GDASE22KVF4SNP3QKDRFSIFV7O6MXNJNMBDQJCW3UCTG4KS25W4XPSIY
static immutable ASE = KeyPair(PublicKey(Point([193, 34, 107, 74, 169, 121, 38, 191, 112, 80, 226, 89, 32, 181, 251, 188, 203, 181, 45, 96, 71, 4, 138, 219, 160, 166, 110, 42, 90, 237, 185, 119])), SecretKey(Scalar([171, 149, 144, 166, 176, 81, 36, 23, 193, 43, 247, 186, 78, 207, 244, 163, 119, 223, 202, 218, 58, 143, 240, 176, 59, 222, 57, 250, 244, 54, 202, 9])));
/// ASF: GDASF22XTPWBPCOCJMZINFC3AXD77W7DKME4OGW3EGGJ263HGBQU7KL7
static immutable ASF = KeyPair(PublicKey(Point([193, 34, 235, 87, 155, 236, 23, 137, 194, 75, 50, 134, 148, 91, 5, 199, 255, 219, 227, 83, 9, 199, 26, 219, 33, 140, 157, 123, 103, 48, 97, 79])), SecretKey(Scalar([242, 250, 185, 202, 124, 59, 117, 154, 90, 218, 32, 56, 55, 188, 187, 222, 188, 76, 158, 111, 120, 183, 204, 158, 29, 86, 159, 203, 40, 163, 59, 4])));
/// ASG: GDASG224O5EF54K4LHKS3VWGHSOOC2NTYQQRS3ZN555LBWBCRULZXP75
static immutable ASG = KeyPair(PublicKey(Point([193, 35, 107, 92, 119, 72, 94, 241, 92, 89, 213, 45, 214, 198, 60, 156, 225, 105, 179, 196, 33, 25, 111, 45, 239, 122, 176, 216, 34, 141, 23, 155])), SecretKey(Scalar([11, 16, 135, 110, 166, 246, 212, 180, 77, 136, 182, 124, 7, 140, 199, 14, 21, 104, 132, 245, 75, 221, 176, 251, 83, 43, 112, 59, 169, 203, 173, 14])));
/// ASH: GDASH222ZAOU47A2LIOXEQSPJJ4I7NQV7QL75KTAODYYK4BHC6IXSINQ
static immutable ASH = KeyPair(PublicKey(Point([193, 35, 235, 90, 200, 29, 78, 124, 26, 90, 29, 114, 66, 79, 74, 120, 143, 182, 21, 252, 23, 254, 170, 96, 112, 241, 133, 112, 39, 23, 145, 121])), SecretKey(Scalar([27, 53, 62, 5, 11, 151, 242, 172, 238, 231, 67, 115, 199, 76, 64, 108, 187, 0, 65, 173, 74, 216, 197, 196, 190, 8, 69, 196, 248, 197, 171, 10])));
/// ASI: GDASI22GCS3OGZJ3AQ4OVH32H2TIVDP3FBZADEFVD3JR4EH536CG2GWB
static immutable ASI = KeyPair(PublicKey(Point([193, 36, 107, 70, 20, 182, 227, 101, 59, 4, 56, 234, 159, 122, 62, 166, 138, 141, 251, 40, 114, 1, 144, 181, 30, 211, 30, 16, 253, 223, 132, 109])), SecretKey(Scalar([119, 93, 64, 207, 85, 136, 4, 196, 3, 19, 75, 16, 187, 185, 41, 51, 243, 75, 135, 24, 174, 184, 32, 165, 48, 116, 133, 113, 21, 155, 35, 10])));
/// ASJ: GDASJ22YQU52MH6M2BFP4LZH2LG7ZYQ6NRZ2KGCTHOFT47YD6LNLKSUB
static immutable ASJ = KeyPair(PublicKey(Point([193, 36, 235, 88, 133, 59, 166, 31, 204, 208, 74, 254, 47, 39, 210, 205, 252, 226, 30, 108, 115, 165, 24, 83, 59, 139, 62, 127, 3, 242, 218, 181])), SecretKey(Scalar([57, 102, 114, 173, 45, 87, 120, 241, 255, 189, 155, 238, 23, 209, 147, 154, 42, 139, 88, 59, 83, 55, 84, 177, 63, 248, 47, 227, 61, 179, 244, 9])));
/// ASK: GDASK224RDZHQSKVPW2KT33P3ILZQH7AXFBIRR6JS6PEMD7FHBCFMWTO
static immutable ASK = KeyPair(PublicKey(Point([193, 37, 107, 92, 136, 242, 120, 73, 85, 125, 180, 169, 239, 111, 218, 23, 152, 31, 224, 185, 66, 136, 199, 201, 151, 158, 70, 15, 229, 56, 68, 86])), SecretKey(Scalar([99, 13, 83, 143, 91, 214, 231, 105, 202, 203, 163, 230, 81, 160, 248, 194, 224, 169, 145, 226, 246, 155, 68, 111, 139, 148, 188, 41, 81, 76, 1, 12])));
/// ASL: GDASL22CFRITZA36HC62FFTESD2RHSUBEJGJPZKTOIRD7YOQDJM4VQUF
static immutable ASL = KeyPair(PublicKey(Point([193, 37, 235, 66, 44, 81, 60, 131, 126, 56, 189, 162, 150, 100, 144, 245, 19, 202, 129, 34, 76, 151, 229, 83, 114, 34, 63, 225, 208, 26, 89, 202])), SecretKey(Scalar([21, 176, 65, 112, 113, 86, 117, 101, 146, 167, 13, 143, 43, 39, 127, 60, 23, 253, 100, 203, 29, 225, 101, 109, 42, 209, 241, 189, 185, 46, 245, 15])));
/// ASM: GDASM22Z4DQP6GNBAGY6VIIU5GH7MYPGTFHW6BH4SSLHRV4WAKJYXVVB
static immutable ASM = KeyPair(PublicKey(Point([193, 38, 107, 89, 224, 224, 255, 25, 161, 1, 177, 234, 161, 20, 233, 143, 246, 97, 230, 153, 79, 111, 4, 252, 148, 150, 120, 215, 150, 2, 147, 139])), SecretKey(Scalar([220, 181, 20, 112, 132, 173, 242, 233, 46, 223, 80, 116, 80, 32, 23, 127, 17, 28, 99, 29, 56, 27, 241, 175, 34, 179, 128, 243, 173, 33, 59, 7])));
/// ASN: GDASN223YMJXIBK2OQ2VYC375G76LH4FH62ZCPY2BG4XK3U6O767O7RX
static immutable ASN = KeyPair(PublicKey(Point([193, 38, 235, 91, 195, 19, 116, 5, 90, 116, 53, 92, 11, 127, 233, 191, 229, 159, 133, 63, 181, 145, 63, 26, 9, 185, 117, 110, 158, 119, 253, 247])), SecretKey(Scalar([28, 157, 239, 48, 26, 178, 158, 103, 102, 129, 178, 115, 18, 187, 75, 142, 225, 194, 133, 95, 102, 118, 199, 148, 9, 63, 69, 66, 164, 27, 166, 6])));
/// ASO: GDASO22QXXMXOSSIT2AQ6CR33DUVPQ754DHAJIW3J72Y623JBNYSYLPE
static immutable ASO = KeyPair(PublicKey(Point([193, 39, 107, 80, 189, 217, 119, 74, 72, 158, 129, 15, 10, 59, 216, 233, 87, 195, 253, 224, 206, 4, 162, 219, 79, 245, 143, 107, 105, 11, 113, 44])), SecretKey(Scalar([187, 61, 55, 254, 100, 15, 76, 7, 116, 57, 208, 22, 218, 37, 32, 182, 244, 173, 109, 98, 111, 252, 84, 66, 102, 102, 174, 163, 8, 233, 178, 7])));
/// ASP: GDASP227UTPH3SLFQXW3TYZYPXV7A3VLO3BS26MA4ERAZ7GZMDB2FFL7
static immutable ASP = KeyPair(PublicKey(Point([193, 39, 235, 95, 164, 222, 125, 201, 101, 133, 237, 185, 227, 56, 125, 235, 240, 110, 171, 118, 195, 45, 121, 128, 225, 34, 12, 252, 217, 96, 195, 162])), SecretKey(Scalar([198, 53, 12, 180, 88, 52, 211, 23, 152, 87, 64, 22, 142, 247, 24, 216, 9, 39, 145, 163, 167, 245, 12, 238, 86, 52, 83, 210, 215, 105, 77, 3])));
/// ASQ: GDASQ227XVUTG4W7IJHD4SMI7WMCDSB7ZUPNLLGQ7NUFS45H33TJPD7V
static immutable ASQ = KeyPair(PublicKey(Point([193, 40, 107, 95, 189, 105, 51, 114, 223, 66, 78, 62, 73, 136, 253, 152, 33, 200, 63, 205, 30, 213, 172, 208, 251, 104, 89, 115, 167, 222, 230, 151])), SecretKey(Scalar([175, 232, 170, 240, 192, 230, 157, 157, 58, 126, 95, 152, 163, 55, 47, 137, 161, 139, 40, 81, 122, 239, 241, 95, 173, 91, 140, 55, 201, 33, 165, 5])));
/// ASR: GDASR22OQTOP7BRWNFRIOYGK5Q4IHSKVHVZF4CUNFPRWZRAFYS2GRPKR
static immutable ASR = KeyPair(PublicKey(Point([193, 40, 235, 78, 132, 220, 255, 134, 54, 105, 98, 135, 96, 202, 236, 56, 131, 201, 85, 61, 114, 94, 10, 141, 43, 227, 108, 196, 5, 196, 180, 104])), SecretKey(Scalar([9, 179, 7, 170, 19, 156, 153, 29, 103, 79, 253, 238, 211, 92, 114, 214, 67, 220, 72, 101, 76, 40, 223, 5, 207, 61, 228, 78, 196, 107, 64, 3])));
/// ASS: GDASS22SJQHT6D4L2GBO2DKTDKUSEWTV7S25QEGZY2HRHUXFHMPF2J5P
static immutable ASS = KeyPair(PublicKey(Point([193, 41, 107, 82, 76, 15, 63, 15, 139, 209, 130, 237, 13, 83, 26, 169, 34, 90, 117, 252, 181, 216, 16, 217, 198, 143, 19, 210, 229, 59, 30, 93])), SecretKey(Scalar([10, 34, 115, 87, 34, 192, 57, 38, 200, 75, 90, 7, 30, 178, 109, 69, 70, 195, 218, 83, 249, 111, 120, 119, 86, 119, 18, 14, 25, 3, 208, 7])));
/// AST: GDAST22NWIOJF6MIAO5WFUNGOC5ZJXVOEXSXS4FB53B5JBL4ZPMIE7KZ
static immutable AST = KeyPair(PublicKey(Point([193, 41, 235, 77, 178, 28, 146, 249, 136, 3, 187, 98, 209, 166, 112, 187, 148, 222, 174, 37, 229, 121, 112, 161, 238, 195, 212, 133, 124, 203, 216, 130])), SecretKey(Scalar([39, 35, 145, 31, 252, 174, 196, 208, 72, 132, 239, 110, 132, 113, 99, 71, 146, 133, 235, 173, 88, 34, 146, 140, 186, 23, 225, 76, 230, 240, 11, 0])));
/// ASU: GDASU22LIQKLLXCPKJEDMTJIINMC4HKHGV3U4UNICO6IDE54JTEVAWZI
static immutable ASU = KeyPair(PublicKey(Point([193, 42, 107, 75, 68, 20, 181, 220, 79, 82, 72, 54, 77, 40, 67, 88, 46, 29, 71, 53, 119, 78, 81, 168, 19, 188, 129, 147, 188, 76, 201, 80])), SecretKey(Scalar([192, 233, 16, 172, 44, 87, 84, 94, 244, 251, 124, 206, 110, 201, 37, 255, 157, 102, 38, 106, 124, 176, 243, 238, 74, 10, 11, 26, 176, 112, 13, 15])));
/// ASV: GDASV22FBVFR3YWXFY6C7YVDVSIMOCGIRLBHZMUIFXVMMZ7W7YVA777M
static immutable ASV = KeyPair(PublicKey(Point([193, 42, 235, 69, 13, 75, 29, 226, 215, 46, 60, 47, 226, 163, 172, 144, 199, 8, 200, 138, 194, 124, 178, 136, 45, 234, 198, 103, 246, 254, 42, 15])), SecretKey(Scalar([106, 142, 191, 146, 12, 234, 233, 42, 245, 82, 101, 39, 125, 17, 243, 184, 70, 109, 159, 203, 192, 242, 122, 66, 86, 18, 67, 94, 169, 52, 227, 10])));
/// ASW: GDASW22C4WS44D3C4OZFYMYTJZEYXZTN6RJ6X3WK6ESSPGHCASEJ2FKS
static immutable ASW = KeyPair(PublicKey(Point([193, 43, 107, 66, 229, 165, 206, 15, 98, 227, 178, 92, 51, 19, 78, 73, 139, 230, 109, 244, 83, 235, 238, 202, 241, 37, 39, 152, 226, 4, 136, 157])), SecretKey(Scalar([143, 128, 92, 85, 213, 61, 167, 198, 1, 251, 207, 32, 102, 231, 231, 88, 173, 13, 101, 224, 235, 243, 213, 147, 173, 173, 67, 185, 173, 17, 247, 0])));
/// ASX: GDASX22J3AFKQT2LGHUPPNXNSOVEZU5X7M3ZV43U5SGGCP2XEVMSUJXL
static immutable ASX = KeyPair(PublicKey(Point([193, 43, 235, 73, 216, 10, 168, 79, 75, 49, 232, 247, 182, 237, 147, 170, 76, 211, 183, 251, 55, 154, 243, 116, 236, 140, 97, 63, 87, 37, 89, 42])), SecretKey(Scalar([28, 243, 105, 0, 85, 164, 158, 74, 73, 26, 175, 126, 100, 1, 156, 224, 246, 199, 109, 10, 20, 88, 109, 54, 82, 58, 208, 214, 220, 39, 43, 4])));
/// ASY: GDASY227QAJCFRQ4ZJZTBCXY35BU3NHMQRT2VZDTURYUBBPES7N5DPJP
static immutable ASY = KeyPair(PublicKey(Point([193, 44, 107, 95, 128, 18, 34, 198, 28, 202, 115, 48, 138, 248, 223, 67, 77, 180, 236, 132, 103, 170, 228, 115, 164, 113, 64, 133, 228, 151, 219, 209])), SecretKey(Scalar([36, 206, 198, 183, 11, 188, 7, 21, 252, 68, 179, 99, 188, 212, 86, 140, 241, 107, 240, 249, 216, 188, 3, 185, 50, 82, 212, 223, 142, 171, 190, 4])));
/// ASZ: GDASZ22FWWQDQABI6X63NXRXNHT64STI3QF2K5ZHOGOYGWC7XRKVPQZX
static immutable ASZ = KeyPair(PublicKey(Point([193, 44, 235, 69, 181, 160, 56, 0, 40, 245, 253, 182, 222, 55, 105, 231, 238, 74, 104, 220, 11, 165, 119, 39, 113, 157, 131, 88, 95, 188, 85, 87])), SecretKey(Scalar([129, 39, 204, 90, 18, 159, 101, 234, 174, 250, 159, 249, 250, 218, 215, 103, 230, 184, 35, 19, 226, 58, 179, 243, 116, 113, 75, 237, 194, 137, 57, 15])));
/// ATA: GDATA22JGCHHXAS7OFMTPNGWWPQROBHHQDVBTEEXY74TKXA3GIWH6USZ
static immutable ATA = KeyPair(PublicKey(Point([193, 48, 107, 73, 48, 142, 123, 130, 95, 113, 89, 55, 180, 214, 179, 225, 23, 4, 231, 128, 234, 25, 144, 151, 199, 249, 53, 92, 27, 50, 44, 127])), SecretKey(Scalar([118, 23, 62, 110, 174, 168, 154, 96, 181, 193, 191, 229, 254, 204, 153, 117, 163, 54, 230, 146, 53, 237, 233, 122, 17, 143, 39, 94, 185, 114, 215, 15])));
/// ATB: GDATB22HT3F7I6GVHEBXFFSR3TNDF4LLZMCTQTRKF5XEFABBCSRHPZ5D
static immutable ATB = KeyPair(PublicKey(Point([193, 48, 235, 71, 158, 203, 244, 120, 213, 57, 3, 114, 150, 81, 220, 218, 50, 241, 107, 203, 5, 56, 78, 42, 47, 110, 66, 128, 33, 20, 162, 119])), SecretKey(Scalar([40, 155, 50, 195, 115, 252, 14, 11, 61, 170, 113, 21, 194, 15, 136, 109, 103, 151, 233, 162, 249, 239, 38, 238, 112, 87, 246, 55, 39, 117, 43, 10])));
/// ATC: GDATC22M3WXNYFX2N765NFZI7QJE2HSBO47URCQB7HZ25DNGQ52QOZ44
static immutable ATC = KeyPair(PublicKey(Point([193, 49, 107, 76, 221, 174, 220, 22, 250, 111, 253, 214, 151, 40, 252, 18, 77, 30, 65, 119, 63, 72, 138, 1, 249, 243, 174, 141, 166, 135, 117, 7])), SecretKey(Scalar([200, 71, 32, 97, 154, 131, 85, 100, 220, 152, 18, 60, 99, 20, 155, 167, 40, 252, 57, 71, 21, 91, 32, 227, 144, 194, 225, 27, 140, 67, 186, 14])));
/// ATD: GDATD22AXKWTAOVQ3NKTCVSGJXQGFXAP2A2NELGS6UIKJZFU46KMPDVJ
static immutable ATD = KeyPair(PublicKey(Point([193, 49, 235, 64, 186, 173, 48, 58, 176, 219, 85, 49, 86, 70, 77, 224, 98, 220, 15, 208, 52, 210, 44, 210, 245, 16, 164, 228, 180, 231, 148, 199])), SecretKey(Scalar([136, 113, 150, 141, 230, 186, 112, 100, 213, 128, 55, 96, 250, 171, 38, 100, 95, 93, 186, 125, 78, 155, 92, 73, 237, 140, 163, 158, 213, 152, 176, 3])));
/// ATE: GDATE22IM7ZGWAYK54DVMK6SZBAPUJPYTELWUN462FA2FVIKPM5KLUTG
static immutable ATE = KeyPair(PublicKey(Point([193, 50, 107, 72, 103, 242, 107, 3, 10, 239, 7, 86, 43, 210, 200, 64, 250, 37, 248, 153, 23, 106, 55, 158, 209, 65, 162, 213, 10, 123, 58, 165])), SecretKey(Scalar([59, 249, 24, 20, 70, 55, 214, 155, 174, 192, 137, 133, 70, 217, 105, 235, 248, 5, 37, 46, 113, 99, 75, 246, 91, 80, 64, 27, 8, 0, 156, 0])));
/// ATF: GDATF22ULSKTCAZU7S2VJSOLNODWNZDW2Q7ALK2XS6LUBDPMDUGP6ZSP
static immutable ATF = KeyPair(PublicKey(Point([193, 50, 235, 84, 92, 149, 49, 3, 52, 252, 181, 84, 201, 203, 107, 135, 102, 228, 118, 212, 62, 5, 171, 87, 151, 151, 64, 141, 236, 29, 12, 255])), SecretKey(Scalar([11, 17, 49, 245, 252, 137, 175, 29, 61, 11, 46, 35, 198, 218, 148, 175, 145, 153, 20, 193, 92, 122, 141, 202, 244, 118, 219, 47, 65, 36, 114, 9])));
/// ATG: GDATG22UITMGOY74MI6PYCQX4JANSSDCRN6OCIQFJJTS3EZ2AW24FG3F
static immutable ATG = KeyPair(PublicKey(Point([193, 51, 107, 84, 68, 216, 103, 99, 252, 98, 60, 252, 10, 23, 226, 64, 217, 72, 98, 139, 124, 225, 34, 5, 74, 103, 45, 147, 58, 5, 181, 194])), SecretKey(Scalar([31, 107, 131, 179, 202, 160, 115, 25, 255, 76, 79, 53, 172, 183, 41, 248, 187, 229, 103, 26, 228, 3, 58, 70, 6, 175, 117, 108, 18, 174, 146, 0])));
/// ATH: GDATH22HPC6C5ZTRPXMRJ264DSMHEH6ZC6F7LXVGSROBCL2AUP4VIHJY
static immutable ATH = KeyPair(PublicKey(Point([193, 51, 235, 71, 120, 188, 46, 230, 113, 125, 217, 20, 235, 220, 28, 152, 114, 31, 217, 23, 139, 245, 222, 166, 148, 92, 17, 47, 64, 163, 249, 84])), SecretKey(Scalar([11, 15, 227, 227, 115, 75, 190, 169, 48, 155, 71, 124, 16, 127, 127, 158, 231, 98, 122, 29, 168, 16, 135, 3, 200, 236, 103, 22, 234, 79, 5, 12])));
/// ATI: GDATI22ETGNMF6DZ33IRDXPLHMH5QK4TPDMUTDXLRHCHH2IE35JN3T7B
static immutable ATI = KeyPair(PublicKey(Point([193, 52, 107, 68, 153, 154, 194, 248, 121, 222, 209, 17, 221, 235, 59, 15, 216, 43, 147, 120, 217, 73, 142, 235, 137, 196, 115, 233, 4, 223, 82, 221])), SecretKey(Scalar([54, 142, 235, 253, 201, 208, 123, 166, 211, 122, 137, 241, 154, 74, 45, 206, 209, 169, 77, 222, 203, 190, 194, 12, 119, 247, 215, 125, 69, 210, 182, 1])));
/// ATJ: GDATJ22GO4NNRRHPZSDTFLXYOLBUSR3FEIEFBTHPADC2UZ4RY53ORUXE
static immutable ATJ = KeyPair(PublicKey(Point([193, 52, 235, 70, 119, 26, 216, 196, 239, 204, 135, 50, 174, 248, 114, 195, 73, 71, 101, 34, 8, 80, 204, 239, 0, 197, 170, 103, 145, 199, 118, 232])), SecretKey(Scalar([48, 26, 167, 211, 95, 198, 232, 141, 151, 100, 193, 227, 129, 143, 250, 88, 202, 130, 253, 159, 225, 207, 35, 58, 8, 248, 108, 50, 229, 113, 80, 14])));
/// ATK: GDATK22IHB7WCO2ISWVWXGLXYCPB4SSMHSCFZDZAHVYWNPN7EHNPHSFT
static immutable ATK = KeyPair(PublicKey(Point([193, 53, 107, 72, 56, 127, 97, 59, 72, 149, 171, 107, 153, 119, 192, 158, 30, 74, 76, 60, 132, 92, 143, 32, 61, 113, 102, 189, 191, 33, 218, 243])), SecretKey(Scalar([251, 124, 194, 236, 110, 180, 243, 191, 151, 57, 21, 26, 43, 77, 180, 169, 253, 119, 82, 36, 132, 126, 250, 13, 22, 98, 174, 222, 229, 83, 119, 5])));
/// ATL: GDATL22BGCXT4JGMYCAGAUZBCZ5JBARRWH6N2WTNQ4THOE4MBKBVXAXO
static immutable ATL = KeyPair(PublicKey(Point([193, 53, 235, 65, 48, 175, 62, 36, 204, 192, 128, 96, 83, 33, 22, 122, 144, 130, 49, 177, 252, 221, 90, 109, 135, 38, 119, 19, 140, 10, 131, 91])), SecretKey(Scalar([164, 13, 14, 49, 39, 92, 152, 100, 248, 79, 7, 53, 171, 158, 49, 187, 74, 223, 183, 222, 156, 213, 47, 25, 112, 47, 120, 151, 98, 136, 60, 14])));
/// ATM: GDATM226OHEPDWAR3GKUTVY4MDCNI4QLKBS5LROB5IR2EPMOXG5SQFML
static immutable ATM = KeyPair(PublicKey(Point([193, 54, 107, 94, 113, 200, 241, 216, 17, 217, 149, 73, 215, 28, 96, 196, 212, 114, 11, 80, 101, 213, 197, 193, 234, 35, 162, 61, 142, 185, 187, 40])), SecretKey(Scalar([246, 132, 29, 115, 91, 251, 196, 113, 101, 222, 201, 140, 47, 61, 253, 160, 174, 14, 68, 14, 103, 79, 158, 243, 119, 134, 149, 74, 179, 159, 49, 10])));
/// ATN: GDATN22T4BNIM6QY3PDQJO43UX6SDK2PDSWOQY2LDJHDYYAVAOFU54TY
static immutable ATN = KeyPair(PublicKey(Point([193, 54, 235, 83, 224, 90, 134, 122, 24, 219, 199, 4, 187, 155, 165, 253, 33, 171, 79, 28, 172, 232, 99, 75, 26, 78, 60, 96, 21, 3, 139, 78])), SecretKey(Scalar([174, 189, 72, 186, 33, 245, 41, 84, 45, 123, 94, 14, 149, 165, 123, 12, 252, 156, 163, 170, 205, 139, 21, 245, 96, 142, 210, 3, 147, 78, 214, 13])));
/// ATO: GDATO22PECRSOP33BGMN2NWKPZWBSPP5FOMR4DT2J67FRNCIY5U2OIJ5
static immutable ATO = KeyPair(PublicKey(Point([193, 55, 107, 79, 32, 163, 39, 63, 123, 9, 152, 221, 54, 202, 126, 108, 25, 61, 253, 43, 153, 30, 14, 122, 79, 190, 88, 180, 72, 199, 105, 167])), SecretKey(Scalar([59, 44, 64, 188, 51, 3, 144, 124, 189, 183, 41, 246, 75, 252, 202, 42, 136, 55, 121, 125, 252, 74, 103, 62, 52, 195, 141, 144, 248, 141, 91, 9])));
/// ATP: GDATP22VQM5QQ7TW7P3BGSGRL5OVQAHOWRFQFVEMGOEEUIXMBTL4NUR4
static immutable ATP = KeyPair(PublicKey(Point([193, 55, 235, 85, 131, 59, 8, 126, 118, 251, 246, 19, 72, 209, 95, 93, 88, 0, 238, 180, 75, 2, 212, 140, 51, 136, 74, 34, 236, 12, 215, 198])), SecretKey(Scalar([47, 175, 24, 19, 183, 177, 99, 137, 16, 41, 104, 46, 241, 1, 87, 25, 31, 252, 106, 70, 237, 109, 34, 51, 123, 239, 139, 99, 118, 1, 66, 7])));
/// ATQ: GDATQ22IOQOLNYJ7DPDX2XXU6IVFOAEV32W54XDIULF2ELPEMGYFZ7EE
static immutable ATQ = KeyPair(PublicKey(Point([193, 56, 107, 72, 116, 28, 182, 225, 63, 27, 199, 125, 94, 244, 242, 42, 87, 0, 149, 222, 173, 222, 92, 104, 162, 203, 162, 45, 228, 97, 176, 92])), SecretKey(Scalar([157, 114, 58, 98, 250, 140, 113, 206, 19, 168, 250, 8, 182, 31, 142, 237, 183, 181, 4, 59, 66, 113, 233, 97, 118, 231, 87, 199, 70, 84, 88, 10])));
/// ATR: GDATR22JVMSLXVELUVYK5PHH2WTW7UJXZ5YBTLSHACKZOGJWHURY646I
static immutable ATR = KeyPair(PublicKey(Point([193, 56, 235, 73, 171, 36, 187, 212, 139, 165, 112, 174, 188, 231, 213, 167, 111, 209, 55, 207, 112, 25, 174, 71, 0, 149, 151, 25, 54, 61, 35, 143])), SecretKey(Scalar([121, 98, 110, 28, 50, 132, 161, 54, 76, 255, 117, 163, 199, 98, 99, 69, 113, 68, 88, 235, 29, 141, 203, 86, 183, 63, 56, 75, 88, 226, 12, 3])));
/// ATS: GDATS22GOMR2RQPSYPO6IHQXW2A4YMFOWNOW6OFKLAYLC5X7Z6QRHNKT
static immutable ATS = KeyPair(PublicKey(Point([193, 57, 107, 70, 115, 35, 168, 193, 242, 195, 221, 228, 30, 23, 182, 129, 204, 48, 174, 179, 93, 111, 56, 170, 88, 48, 177, 118, 255, 207, 161, 19])), SecretKey(Scalar([7, 92, 46, 25, 60, 212, 191, 185, 241, 252, 37, 27, 130, 247, 151, 44, 91, 67, 250, 17, 4, 189, 156, 170, 71, 113, 185, 174, 200, 139, 15, 7])));
/// ATT: GDATT225LVNVLGM4HJOJAQIB74HXNOJIE67AWZDUKRQ3CSIIACCCGRGF
static immutable ATT = KeyPair(PublicKey(Point([193, 57, 235, 93, 93, 91, 85, 153, 156, 58, 92, 144, 65, 1, 255, 15, 118, 185, 40, 39, 190, 11, 100, 116, 84, 97, 177, 73, 8, 0, 132, 35])), SecretKey(Scalar([255, 33, 253, 97, 95, 119, 125, 138, 239, 128, 95, 78, 134, 143, 150, 119, 160, 18, 22, 16, 83, 14, 176, 13, 182, 225, 109, 105, 112, 16, 120, 10])));
/// ATU: GDATU22WT4EHVEX7GN6ENFCT6H6KFW4QM6SLKERGQVYQUF7K7OGLVR2E
static immutable ATU = KeyPair(PublicKey(Point([193, 58, 107, 86, 159, 8, 122, 146, 255, 51, 124, 70, 148, 83, 241, 252, 162, 219, 144, 103, 164, 181, 18, 38, 133, 113, 10, 23, 234, 251, 140, 186])), SecretKey(Scalar([253, 107, 1, 55, 103, 186, 235, 222, 219, 44, 149, 209, 80, 99, 128, 100, 9, 108, 149, 236, 231, 212, 209, 56, 198, 21, 87, 38, 235, 196, 128, 4])));
/// ATV: GDATV223TBL63BS35GM2WUXVS6DLFBTWIRL6VTA74VQBXFP3TRHDFSQQ
static immutable ATV = KeyPair(PublicKey(Point([193, 58, 235, 91, 152, 87, 237, 134, 91, 233, 153, 171, 82, 245, 151, 134, 178, 134, 118, 68, 87, 234, 204, 31, 229, 96, 27, 149, 251, 156, 78, 50])), SecretKey(Scalar([192, 164, 222, 1, 235, 215, 180, 167, 193, 35, 113, 158, 41, 186, 201, 84, 222, 239, 220, 204, 115, 246, 78, 6, 167, 8, 142, 104, 217, 170, 54, 2])));
/// ATW: GDATW22BRTLSMAGSLXLMR6QNI5GPYFO33TA6HYV3SCHETJ4GOHBQGL3Y
static immutable ATW = KeyPair(PublicKey(Point([193, 59, 107, 65, 140, 215, 38, 0, 210, 93, 214, 200, 250, 13, 71, 76, 252, 21, 219, 220, 193, 227, 226, 187, 144, 142, 73, 167, 134, 113, 195, 3])), SecretKey(Scalar([249, 124, 232, 152, 102, 27, 8, 0, 90, 112, 7, 243, 110, 154, 214, 223, 26, 17, 39, 128, 141, 187, 175, 143, 231, 157, 169, 58, 220, 6, 209, 7])));
/// ATX: GDATX223FZXM2DRILZOM2DXEFD26OB32EGJBUKIM6PIAILDPXXWOYIOH
static immutable ATX = KeyPair(PublicKey(Point([193, 59, 235, 91, 46, 110, 205, 14, 40, 94, 92, 205, 14, 228, 40, 245, 231, 7, 122, 33, 146, 26, 41, 12, 243, 208, 4, 44, 111, 189, 236, 236])), SecretKey(Scalar([118, 217, 69, 142, 28, 164, 169, 5, 133, 86, 181, 220, 136, 142, 224, 252, 141, 87, 157, 26, 237, 56, 10, 131, 122, 23, 86, 65, 85, 246, 115, 6])));
/// ATY: GDATY22NUXL6BDUPWOEPLYMBWKDVKWO5JHYZHKGPY3I476BS3FYNKVTW
static immutable ATY = KeyPair(PublicKey(Point([193, 60, 107, 77, 165, 215, 224, 142, 143, 179, 136, 245, 225, 129, 178, 135, 85, 89, 221, 73, 241, 147, 168, 207, 198, 209, 207, 248, 50, 217, 112, 213])), SecretKey(Scalar([100, 205, 112, 222, 10, 191, 140, 182, 89, 189, 180, 185, 123, 182, 246, 87, 126, 87, 111, 69, 180, 225, 38, 47, 255, 161, 172, 182, 204, 149, 66, 5])));
/// ATZ: GDATZ222DMZCDQB7AWJRPUX6NZGJQ6XMMODBX3BQNMBTLRAWZMWGSOQE
static immutable ATZ = KeyPair(PublicKey(Point([193, 60, 235, 90, 27, 50, 33, 192, 63, 5, 147, 23, 210, 254, 110, 76, 152, 122, 236, 99, 134, 27, 236, 48, 107, 3, 53, 196, 22, 203, 44, 105])), SecretKey(Scalar([6, 216, 144, 93, 187, 235, 157, 65, 184, 32, 71, 195, 252, 135, 215, 108, 129, 39, 49, 62, 206, 195, 89, 238, 126, 192, 231, 114, 223, 46, 23, 2])));
/// AUA: GDAUA223O2MSML2GQHUULH45XKSJSQQKK2HQ3LV7DROVFBJTY2PTSJ54
static immutable AUA = KeyPair(PublicKey(Point([193, 64, 107, 91, 118, 153, 38, 47, 70, 129, 233, 69, 159, 157, 186, 164, 153, 66, 10, 86, 143, 13, 174, 191, 28, 93, 82, 133, 51, 198, 159, 57])), SecretKey(Scalar([136, 237, 212, 135, 42, 185, 132, 147, 196, 149, 228, 105, 80, 50, 224, 138, 176, 0, 88, 124, 123, 29, 199, 74, 241, 28, 232, 175, 202, 91, 82, 0])));
/// AUB: GDAUB22XNR5KIXS4EJBSEALLGIHLSFAJ5HXY6LT74IQCIDC34CIJABIO
static immutable AUB = KeyPair(PublicKey(Point([193, 64, 235, 87, 108, 122, 164, 94, 92, 34, 67, 34, 1, 107, 50, 14, 185, 20, 9, 233, 239, 143, 46, 127, 226, 32, 36, 12, 91, 224, 144, 144])), SecretKey(Scalar([13, 122, 110, 133, 42, 198, 136, 149, 103, 170, 187, 114, 183, 148, 130, 240, 206, 150, 232, 214, 205, 122, 239, 165, 14, 65, 164, 213, 10, 253, 68, 12])));
/// AUC: GDAUC22CUGUUGKUSIRRRRR5CMX3DU4RTA4XQYONLDOJJUSOFER4F6626
static immutable AUC = KeyPair(PublicKey(Point([193, 65, 107, 66, 161, 169, 67, 42, 146, 68, 99, 24, 199, 162, 101, 246, 58, 114, 51, 7, 47, 12, 57, 171, 27, 146, 154, 73, 197, 36, 120, 95])), SecretKey(Scalar([24, 246, 245, 102, 143, 242, 143, 14, 164, 95, 174, 172, 226, 208, 85, 14, 161, 135, 88, 64, 36, 228, 138, 122, 46, 158, 26, 193, 60, 217, 195, 3])));
/// AUD: GDAUD22NFVOQSPFKNH5ULY6VYWFT4WE6WTHWVEGQPVMEQKYQHSUF54YY
static immutable AUD = KeyPair(PublicKey(Point([193, 65, 235, 77, 45, 93, 9, 60, 170, 105, 251, 69, 227, 213, 197, 139, 62, 88, 158, 180, 207, 106, 144, 208, 125, 88, 72, 43, 16, 60, 168, 94])), SecretKey(Scalar([210, 64, 107, 183, 47, 21, 214, 17, 90, 122, 93, 67, 78, 168, 153, 49, 142, 74, 155, 120, 24, 230, 117, 226, 176, 209, 235, 13, 237, 22, 168, 9])));
/// AUE: GDAUE22MNVV2UAGULAKGSDJPWFV46BHV55RZ57LAPNN35FXNICMK4F3O
static immutable AUE = KeyPair(PublicKey(Point([193, 66, 107, 76, 109, 107, 170, 0, 212, 88, 20, 105, 13, 47, 177, 107, 207, 4, 245, 239, 99, 158, 253, 96, 123, 91, 190, 150, 237, 64, 152, 174])), SecretKey(Scalar([249, 36, 151, 170, 251, 90, 2, 224, 96, 145, 209, 7, 238, 176, 34, 30, 248, 8, 174, 180, 21, 205, 37, 100, 78, 141, 128, 186, 158, 18, 134, 14])));
/// AUF: GDAUF22FNK7AQYSXRTWSLJF6ITMYLSW4V3V7EVGAS6VCRZXER7FW4EWB
static immutable AUF = KeyPair(PublicKey(Point([193, 66, 235, 69, 106, 190, 8, 98, 87, 140, 237, 37, 164, 190, 68, 217, 133, 202, 220, 174, 235, 242, 84, 192, 151, 170, 40, 230, 228, 143, 203, 110])), SecretKey(Scalar([185, 64, 17, 177, 213, 59, 29, 217, 6, 16, 190, 95, 73, 88, 50, 98, 159, 117, 181, 55, 220, 137, 27, 25, 195, 212, 83, 227, 15, 11, 58, 6])));
/// AUG: GDAUG22CLGOCLQTSWUU2GCJWSSROFUJ7ST6I26WUXLAGABXPK57S5T7K
static immutable AUG = KeyPair(PublicKey(Point([193, 67, 107, 66, 89, 156, 37, 194, 114, 181, 41, 163, 9, 54, 148, 162, 226, 209, 63, 148, 252, 141, 122, 212, 186, 192, 96, 6, 239, 87, 127, 46])), SecretKey(Scalar([154, 15, 52, 243, 177, 188, 214, 177, 235, 120, 220, 190, 236, 64, 6, 125, 124, 97, 120, 158, 50, 122, 38, 164, 157, 39, 38, 56, 251, 211, 200, 10])));
/// AUH: GDAUH225J2TXVWZQUM726QLXDXCF5HUERT5YQBCKYZC6D2MK5V3ESHE7
static immutable AUH = KeyPair(PublicKey(Point([193, 67, 235, 93, 78, 167, 122, 219, 48, 163, 63, 175, 65, 119, 29, 196, 94, 158, 132, 140, 251, 136, 4, 74, 198, 69, 225, 233, 138, 237, 118, 73])), SecretKey(Scalar([109, 12, 15, 176, 112, 0, 219, 191, 54, 124, 236, 68, 45, 88, 41, 48, 119, 47, 206, 192, 89, 126, 65, 87, 239, 42, 75, 8, 36, 50, 117, 7])));
/// AUI: GDAUI22LFBHX5UHQ7GCXKTGMDU3HO25V7S3LY5SI6YLA7UTWYZL2ZPAY
static immutable AUI = KeyPair(PublicKey(Point([193, 68, 107, 75, 40, 79, 126, 208, 240, 249, 133, 117, 76, 204, 29, 54, 119, 107, 181, 252, 182, 188, 118, 72, 246, 22, 15, 210, 118, 198, 87, 172])), SecretKey(Scalar([92, 212, 46, 89, 22, 52, 102, 55, 169, 65, 62, 2, 244, 246, 251, 30, 56, 172, 27, 212, 165, 204, 94, 217, 131, 240, 22, 226, 25, 176, 4, 14])));
/// AUJ: GDAUJ22GNRNRQDTPWOWID6PMILUJSCSASNXVYS2YUYF273JGXJM2BANV
static immutable AUJ = KeyPair(PublicKey(Point([193, 68, 235, 70, 108, 91, 24, 14, 111, 179, 172, 129, 249, 236, 66, 232, 153, 10, 64, 147, 111, 92, 75, 88, 166, 11, 175, 237, 38, 186, 89, 160])), SecretKey(Scalar([162, 14, 76, 131, 81, 188, 193, 208, 228, 186, 148, 105, 211, 168, 63, 147, 107, 65, 116, 103, 38, 225, 46, 65, 102, 205, 159, 79, 173, 184, 217, 8])));
/// AUK: GDAUK2225ETUGDMQTFS7EZA66EAGSX4YJMA7U5JRA4HDAAUMTL6OCZLV
static immutable AUK = KeyPair(PublicKey(Point([193, 69, 107, 90, 233, 39, 67, 13, 144, 153, 101, 242, 100, 30, 241, 0, 105, 95, 152, 75, 1, 250, 117, 49, 7, 14, 48, 2, 140, 154, 252, 225])), SecretKey(Scalar([194, 204, 216, 5, 94, 72, 146, 225, 98, 118, 204, 135, 71, 110, 193, 75, 188, 186, 35, 8, 40, 105, 241, 52, 47, 60, 161, 244, 65, 156, 171, 1])));
/// AUL: GDAUL22EJXXHABJSOU2DWLVDT7HGNBLXQNO5IOR4TW3VIXH6WWR7BMWQ
static immutable AUL = KeyPair(PublicKey(Point([193, 69, 235, 68, 77, 238, 112, 5, 50, 117, 52, 59, 46, 163, 159, 206, 102, 133, 119, 131, 93, 212, 58, 60, 157, 183, 84, 92, 254, 181, 163, 240])), SecretKey(Scalar([231, 110, 118, 182, 228, 59, 143, 18, 42, 123, 233, 241, 240, 81, 1, 107, 210, 224, 67, 38, 241, 197, 129, 214, 136, 228, 148, 8, 27, 153, 25, 13])));
/// AUM: GDAUM22Y7PWXGXH2QYTXZTS5HAZU2Z6JG6S4IPE3F4AFRTNZ72ADFLVQ
static immutable AUM = KeyPair(PublicKey(Point([193, 70, 107, 88, 251, 237, 115, 92, 250, 134, 39, 124, 206, 93, 56, 51, 77, 103, 201, 55, 165, 196, 60, 155, 47, 0, 88, 205, 185, 254, 128, 50])), SecretKey(Scalar([36, 47, 66, 92, 41, 48, 173, 182, 45, 167, 57, 143, 116, 44, 45, 57, 16, 237, 182, 239, 73, 126, 5, 133, 89, 59, 98, 103, 50, 139, 10, 0])));
/// AUN: GDAUN22TUU4DEQTPZU35QXTFJAR7UH5PM5NFPFRMRB4PU7NOIAYHEBOK
static immutable AUN = KeyPair(PublicKey(Point([193, 70, 235, 83, 165, 56, 50, 66, 111, 205, 55, 216, 94, 101, 72, 35, 250, 31, 175, 103, 90, 87, 150, 44, 136, 120, 250, 125, 174, 64, 48, 114])), SecretKey(Scalar([78, 195, 214, 209, 245, 84, 30, 149, 236, 154, 92, 173, 135, 206, 137, 164, 119, 46, 216, 239, 115, 186, 59, 178, 238, 73, 169, 179, 200, 80, 168, 1])));
/// AUO: GDAUO22SS3EBRZ3HUNX7RMQ6WP4U7TVWF72QVRVINJB5FD6HSKTHC355
static immutable AUO = KeyPair(PublicKey(Point([193, 71, 107, 82, 150, 200, 24, 231, 103, 163, 111, 248, 178, 30, 179, 249, 79, 206, 182, 47, 245, 10, 198, 168, 106, 67, 210, 143, 199, 146, 166, 113])), SecretKey(Scalar([111, 53, 149, 49, 85, 74, 150, 146, 191, 233, 193, 148, 25, 171, 92, 118, 47, 71, 137, 193, 100, 189, 14, 0, 116, 101, 102, 111, 39, 248, 188, 10])));
/// AUP: GDAUP22HYZFHYTP6RZQ7EVR4A4XFEBTHWA32TJ2K4BLR73GVF42UKIUI
static immutable AUP = KeyPair(PublicKey(Point([193, 71, 235, 71, 198, 74, 124, 77, 254, 142, 97, 242, 86, 60, 7, 46, 82, 6, 103, 176, 55, 169, 167, 74, 224, 87, 31, 236, 213, 47, 53, 69])), SecretKey(Scalar([89, 87, 42, 148, 228, 130, 61, 95, 205, 48, 109, 170, 143, 39, 134, 216, 85, 245, 118, 69, 124, 100, 49, 221, 70, 78, 69, 252, 123, 124, 63, 9])));
/// AUQ: GDAUQ222YPWTXZWROGANFDCQ23545NF6M6IWENELWOFRJTO533RQMSO2
static immutable AUQ = KeyPair(PublicKey(Point([193, 72, 107, 90, 195, 237, 59, 230, 209, 113, 128, 210, 140, 80, 214, 251, 206, 180, 190, 103, 145, 98, 52, 139, 179, 139, 20, 205, 221, 222, 227, 6])), SecretKey(Scalar([188, 92, 255, 170, 255, 91, 4, 205, 40, 92, 125, 177, 229, 109, 194, 120, 153, 190, 74, 146, 10, 132, 185, 144, 124, 120, 86, 170, 208, 217, 86, 4])));
/// AUR: GDAUR22JUEMIOUWADV64IOOZ2JWM5VKBF3FKRL4SSFQGT7KULT2FQP32
static immutable AUR = KeyPair(PublicKey(Point([193, 72, 235, 73, 161, 24, 135, 82, 192, 29, 125, 196, 57, 217, 210, 108, 206, 213, 65, 46, 202, 168, 175, 146, 145, 96, 105, 253, 84, 92, 244, 88])), SecretKey(Scalar([136, 245, 236, 145, 161, 146, 167, 154, 171, 191, 136, 176, 253, 135, 194, 171, 153, 184, 205, 199, 129, 92, 143, 125, 3, 19, 200, 214, 223, 225, 85, 3])));
/// AUS: GDAUS22LHCHGGXS2QCHNDCTEP2JFK6AKVMP5TEJDTYIPKOK6A5XDV5IZ
static immutable AUS = KeyPair(PublicKey(Point([193, 73, 107, 75, 56, 142, 99, 94, 90, 128, 142, 209, 138, 100, 126, 146, 85, 120, 10, 171, 31, 217, 145, 35, 158, 16, 245, 57, 94, 7, 110, 58])), SecretKey(Scalar([13, 114, 37, 35, 80, 247, 224, 162, 227, 70, 128, 217, 232, 251, 213, 1, 86, 30, 85, 61, 196, 229, 254, 230, 189, 185, 163, 233, 22, 104, 6, 5])));
/// AUT: GDAUT22AKXXLJK4ORWDJOGCBJGVU7EC7X56SE463SOOZ7WUBFDWEJE7L
static immutable AUT = KeyPair(PublicKey(Point([193, 73, 235, 64, 85, 238, 180, 171, 142, 141, 134, 151, 24, 65, 73, 171, 79, 144, 95, 191, 125, 34, 115, 219, 147, 157, 159, 218, 129, 40, 236, 68])), SecretKey(Scalar([106, 184, 7, 14, 224, 51, 4, 21, 59, 144, 234, 68, 154, 102, 238, 1, 238, 15, 241, 121, 41, 29, 16, 62, 91, 195, 160, 44, 68, 107, 213, 9])));
/// AUU: GDAUU22QJMFVWZYDQEHARGIGLXBKVY67XISOUW7BK25VFAIQ6D2H373J
static immutable AUU = KeyPair(PublicKey(Point([193, 74, 107, 80, 75, 11, 91, 103, 3, 129, 14, 8, 153, 6, 93, 194, 170, 227, 223, 186, 36, 234, 91, 225, 86, 187, 82, 129, 16, 240, 244, 125])), SecretKey(Scalar([33, 240, 220, 2, 233, 76, 84, 42, 10, 150, 134, 193, 192, 253, 30, 87, 247, 107, 224, 158, 23, 128, 69, 112, 183, 11, 187, 127, 10, 221, 59, 3])));
/// AUV: GDAUV227IU5P6UVN62SIZBGO5CMN4DHOUG5AURKYNIJJTEHNFMBS2PAZ
static immutable AUV = KeyPair(PublicKey(Point([193, 74, 235, 95, 69, 58, 255, 82, 173, 246, 164, 140, 132, 206, 232, 152, 222, 12, 238, 161, 186, 10, 69, 88, 106, 18, 153, 144, 237, 43, 3, 45])), SecretKey(Scalar([187, 10, 89, 220, 217, 84, 200, 134, 9, 134, 232, 87, 79, 195, 169, 75, 46, 138, 217, 53, 156, 206, 165, 8, 203, 81, 2, 185, 73, 108, 26, 2])));
/// AUW: GDAUW22XWCRIYRI3XI4ZCF6KI7MU3SHVA6LY46PQP4TJJY6IXAAIM5TB
static immutable AUW = KeyPair(PublicKey(Point([193, 75, 107, 87, 176, 162, 140, 69, 27, 186, 57, 145, 23, 202, 71, 217, 77, 200, 245, 7, 151, 142, 121, 240, 127, 38, 148, 227, 200, 184, 0, 134])), SecretKey(Scalar([198, 116, 194, 243, 175, 250, 234, 64, 17, 169, 156, 253, 14, 117, 63, 224, 3, 50, 55, 200, 197, 3, 111, 163, 118, 180, 67, 130, 14, 227, 74, 6])));
/// AUX: GDAUX22MNN6YUW3PM2ILDUEJY7L74VGDXR577HX5QXYZSEWNDKE6R7GS
static immutable AUX = KeyPair(PublicKey(Point([193, 75, 235, 76, 107, 125, 138, 91, 111, 102, 144, 177, 208, 137, 199, 215, 254, 84, 195, 188, 123, 255, 158, 253, 133, 241, 153, 18, 205, 26, 137, 232])), SecretKey(Scalar([42, 11, 13, 117, 182, 63, 165, 64, 142, 91, 21, 66, 155, 167, 110, 161, 185, 23, 42, 224, 213, 102, 175, 86, 111, 153, 191, 16, 136, 135, 210, 5])));
/// AUY: GDAUY22J3WELIDIQ7KCOYRDBVWKTINH44AKWDBXE52XG6TYEPDZNA5HC
static immutable AUY = KeyPair(PublicKey(Point([193, 76, 107, 73, 221, 136, 180, 13, 16, 250, 132, 236, 68, 97, 173, 149, 52, 52, 252, 224, 21, 97, 134, 228, 238, 174, 111, 79, 4, 120, 242, 208])), SecretKey(Scalar([166, 89, 247, 123, 107, 232, 92, 200, 173, 19, 6, 253, 157, 164, 254, 237, 86, 206, 221, 140, 224, 8, 183, 110, 173, 38, 67, 21, 244, 35, 243, 7])));
/// AUZ: GDAUZ22NUDAO3FCEKKWVO3DQTPQYIVKGSA3MMPYRTH2Y43P77ICSVKMX
static immutable AUZ = KeyPair(PublicKey(Point([193, 76, 235, 77, 160, 192, 237, 148, 68, 82, 173, 87, 108, 112, 155, 225, 132, 85, 70, 144, 54, 198, 63, 17, 153, 245, 142, 109, 255, 250, 5, 42])), SecretKey(Scalar([64, 52, 28, 64, 54, 187, 178, 30, 2, 111, 83, 52, 186, 103, 17, 40, 78, 213, 175, 93, 39, 16, 105, 182, 62, 227, 247, 188, 92, 7, 99, 12])));
/// AVA: GDAVA22GAR6IWPFYJE2SBB75BDF3AJHCNDBEIG4C5Z2YGQMJK7YOY2DO
static immutable AVA = KeyPair(PublicKey(Point([193, 80, 107, 70, 4, 124, 139, 60, 184, 73, 53, 32, 135, 253, 8, 203, 176, 36, 226, 104, 194, 68, 27, 130, 238, 117, 131, 65, 137, 87, 240, 236])), SecretKey(Scalar([179, 46, 99, 75, 54, 151, 213, 79, 79, 211, 120, 174, 0, 64, 122, 36, 4, 196, 199, 116, 206, 8, 79, 148, 147, 228, 99, 158, 57, 222, 68, 15])));
/// AVB: GDAVB2232R3QDCCQ6MCGYY3YCEOPEA3EXDMVCYQLZJJ7GE3ZPO45NTGE
static immutable AVB = KeyPair(PublicKey(Point([193, 80, 235, 91, 212, 119, 1, 136, 80, 243, 4, 108, 99, 120, 17, 28, 242, 3, 100, 184, 217, 81, 98, 11, 202, 83, 243, 19, 121, 123, 185, 214])), SecretKey(Scalar([186, 41, 218, 236, 138, 128, 157, 55, 250, 127, 96, 157, 3, 244, 248, 63, 208, 240, 242, 94, 226, 18, 39, 72, 95, 105, 41, 183, 182, 230, 193, 5])));
/// AVC: GDAVC22UJRFYFNWYOUBHKVUYD4Z4KF7FWQOLJCBLIEJAGGY3Y2EEK2EY
static immutable AVC = KeyPair(PublicKey(Point([193, 81, 107, 84, 76, 75, 130, 182, 216, 117, 2, 117, 86, 152, 31, 51, 197, 23, 229, 180, 28, 180, 136, 43, 65, 18, 3, 27, 27, 198, 136, 69])), SecretKey(Scalar([183, 240, 54, 109, 81, 65, 226, 112, 4, 104, 146, 137, 81, 140, 200, 95, 77, 101, 128, 142, 109, 80, 41, 30, 242, 240, 37, 234, 1, 170, 230, 7])));
/// AVD: GDAVD226KCMCPE3DPRQKPPJGV46VZAMDO6GX7B66XA2M3QUIW7BO2CKT
static immutable AVD = KeyPair(PublicKey(Point([193, 81, 235, 94, 80, 152, 39, 147, 99, 124, 96, 167, 189, 38, 175, 61, 92, 129, 131, 119, 141, 127, 135, 222, 184, 52, 205, 194, 136, 183, 194, 237])), SecretKey(Scalar([193, 113, 245, 231, 205, 15, 237, 96, 111, 141, 107, 107, 236, 240, 103, 17, 163, 47, 101, 76, 6, 210, 46, 147, 74, 89, 16, 156, 30, 4, 212, 15])));
/// AVE: GDAVE22V35W5RXZO4H4C5S3JMMVBTBK52QDI4CFCHQAS7DL7563XZIRH
static immutable AVE = KeyPair(PublicKey(Point([193, 82, 107, 85, 223, 109, 216, 223, 46, 225, 248, 46, 203, 105, 99, 42, 25, 133, 93, 212, 6, 142, 8, 162, 60, 1, 47, 141, 127, 239, 183, 124])), SecretKey(Scalar([145, 83, 62, 210, 26, 63, 177, 129, 225, 161, 252, 227, 95, 78, 2, 223, 176, 185, 137, 203, 195, 215, 195, 156, 183, 57, 182, 202, 26, 161, 148, 1])));
/// AVF: GDAVF224XBVZRZOXL67DSIMZKA73HSCSJ6EHZKF376C4WQUBC5Y5XRVE
static immutable AVF = KeyPair(PublicKey(Point([193, 82, 235, 92, 184, 107, 152, 229, 215, 95, 190, 57, 33, 153, 80, 63, 179, 200, 82, 79, 136, 124, 168, 187, 255, 133, 203, 66, 129, 23, 113, 219])), SecretKey(Scalar([167, 205, 182, 61, 108, 221, 66, 200, 225, 141, 213, 234, 99, 99, 86, 209, 53, 205, 230, 21, 121, 226, 197, 224, 111, 77, 196, 199, 105, 183, 159, 5])));
/// AVG: GDAVG22QXKMA45ZKDD33XUHKXS5CUORWZQG2YPQMAMFHBJJ5KEXPPTAP
static immutable AVG = KeyPair(PublicKey(Point([193, 83, 107, 80, 186, 152, 14, 119, 42, 24, 247, 187, 208, 234, 188, 186, 42, 58, 54, 204, 13, 172, 62, 12, 3, 10, 112, 165, 61, 81, 46, 247])), SecretKey(Scalar([144, 33, 48, 67, 204, 126, 66, 140, 49, 168, 98, 16, 179, 152, 243, 145, 81, 64, 247, 146, 78, 135, 86, 92, 104, 251, 100, 170, 107, 123, 102, 10])));
/// AVH: GDAVH22Q6XSA3AWVHWRZSKMVHNVRGSAPESQGMYP4ANFYSVI7ZJ2EBCHB
static immutable AVH = KeyPair(PublicKey(Point([193, 83, 235, 80, 245, 228, 13, 130, 213, 61, 163, 153, 41, 149, 59, 107, 19, 72, 15, 36, 160, 102, 97, 252, 3, 75, 137, 85, 31, 202, 116, 64])), SecretKey(Scalar([229, 106, 248, 183, 118, 69, 253, 11, 173, 109, 213, 108, 110, 30, 45, 168, 85, 222, 81, 97, 241, 254, 75, 136, 53, 52, 163, 189, 204, 82, 235, 7])));
/// AVI: GDAVI22GCHNWDEGZ5DBIHBUVS3C7PAJQIWP2B3RF3LUKPZRDWPMG7BT6
static immutable AVI = KeyPair(PublicKey(Point([193, 84, 107, 70, 17, 219, 97, 144, 217, 232, 194, 131, 134, 149, 150, 197, 247, 129, 48, 69, 159, 160, 238, 37, 218, 232, 167, 230, 35, 179, 216, 111])), SecretKey(Scalar([209, 227, 242, 50, 172, 60, 103, 63, 9, 137, 78, 29, 252, 167, 150, 197, 105, 12, 100, 116, 145, 4, 110, 106, 27, 119, 122, 156, 130, 15, 184, 8])));
/// AVJ: GDAVJ222BU556VNXBJ55I6RWJ4IWN26MHS4QJHAYO2KSC6ZIHHZWTPVA
static immutable AVJ = KeyPair(PublicKey(Point([193, 84, 235, 90, 13, 59, 223, 85, 183, 10, 123, 212, 122, 54, 79, 17, 102, 235, 204, 60, 185, 4, 156, 24, 118, 149, 33, 123, 40, 57, 243, 105])), SecretKey(Scalar([103, 184, 110, 175, 116, 180, 90, 45, 118, 147, 62, 233, 19, 220, 95, 85, 146, 62, 107, 108, 32, 170, 16, 44, 48, 133, 29, 213, 225, 48, 134, 5])));
/// AVK: GDAVK22WWWC4DKA335P5X4FYMCD7OMN67YFJIYIS5KLQ425DLRZAJ5QT
static immutable AVK = KeyPair(PublicKey(Point([193, 85, 107, 86, 181, 133, 193, 168, 27, 223, 95, 219, 240, 184, 96, 135, 247, 49, 190, 254, 10, 148, 97, 18, 234, 151, 14, 107, 163, 92, 114, 4])), SecretKey(Scalar([43, 41, 252, 75, 43, 220, 5, 225, 47, 223, 11, 32, 69, 124, 156, 105, 115, 42, 135, 172, 209, 23, 130, 255, 155, 48, 49, 5, 234, 205, 253, 12])));
/// AVL: GDAVL22V6Y7BVNWE45JJINVJ32CVMJAHO2YXPPBWTT4EHCBKMSQZLKU2
static immutable AVL = KeyPair(PublicKey(Point([193, 85, 235, 85, 246, 62, 26, 182, 196, 231, 82, 148, 54, 169, 222, 133, 86, 36, 7, 118, 177, 119, 188, 54, 156, 248, 67, 136, 42, 100, 161, 149])), SecretKey(Scalar([167, 161, 54, 92, 33, 174, 23, 237, 166, 245, 168, 138, 112, 128, 167, 103, 122, 84, 237, 159, 127, 248, 70, 74, 184, 41, 233, 147, 211, 20, 30, 14])));
/// AVM: GDAVM22YM2ECWIHJRH7EQ2M4TIHTPLETDQ6MVGVH6D7VW3XGYH6IHDCW
static immutable AVM = KeyPair(PublicKey(Point([193, 86, 107, 88, 102, 136, 43, 32, 233, 137, 254, 72, 105, 156, 154, 15, 55, 172, 147, 28, 60, 202, 154, 167, 240, 255, 91, 110, 230, 193, 252, 131])), SecretKey(Scalar([119, 140, 41, 88, 162, 93, 221, 209, 186, 150, 227, 90, 25, 251, 88, 63, 218, 77, 113, 182, 181, 231, 157, 16, 9, 218, 43, 30, 65, 190, 44, 15])));
/// AVN: GDAVN22KA7UIGDC4HM5D4AUJHDXWIGTGZ5PJVH7JBGL5EXXTSSCPZVA4
static immutable AVN = KeyPair(PublicKey(Point([193, 86, 235, 74, 7, 232, 131, 12, 92, 59, 58, 62, 2, 137, 56, 239, 100, 26, 102, 207, 94, 154, 159, 233, 9, 151, 210, 94, 243, 148, 132, 252])), SecretKey(Scalar([98, 185, 123, 160, 182, 217, 121, 75, 89, 90, 78, 108, 100, 57, 152, 84, 116, 246, 237, 43, 54, 104, 126, 64, 3, 164, 141, 50, 197, 48, 244, 13])));
/// AVO: GDAVO22ZEYQE4VTB5M462FWCUTTDTGZNAVAZA4RRWZGHJYORYHLCHNF7
static immutable AVO = KeyPair(PublicKey(Point([193, 87, 107, 89, 38, 32, 78, 86, 97, 235, 57, 237, 22, 194, 164, 230, 57, 155, 45, 5, 65, 144, 114, 49, 182, 76, 116, 225, 209, 193, 214, 35])), SecretKey(Scalar([247, 233, 110, 239, 46, 180, 23, 116, 235, 213, 210, 79, 49, 83, 135, 27, 168, 174, 132, 197, 83, 168, 39, 191, 53, 157, 33, 213, 175, 225, 74, 7])));
/// AVP: GDAVP22YCZXMPOOBRWBO3D4KJG6Q4DEVO7AKYYEQADGH5TZLEXCD4K3L
static immutable AVP = KeyPair(PublicKey(Point([193, 87, 235, 88, 22, 110, 199, 185, 193, 141, 130, 237, 143, 138, 73, 189, 14, 12, 149, 119, 192, 172, 96, 144, 0, 204, 126, 207, 43, 37, 196, 62])), SecretKey(Scalar([122, 4, 184, 254, 111, 22, 145, 252, 186, 30, 126, 215, 90, 49, 2, 25, 94, 242, 211, 2, 174, 229, 84, 171, 250, 182, 171, 219, 154, 137, 15, 3])));
/// AVQ: GDAVQ22TT3B2I4SYWJ7HQYEHCDUMMFQDZXJTYV3NMIEHIZQKL7B24PAL
static immutable AVQ = KeyPair(PublicKey(Point([193, 88, 107, 83, 158, 195, 164, 114, 88, 178, 126, 120, 96, 135, 16, 232, 198, 22, 3, 205, 211, 60, 87, 109, 98, 8, 116, 102, 10, 95, 195, 174])), SecretKey(Scalar([222, 171, 109, 139, 181, 79, 143, 26, 146, 219, 2, 203, 183, 83, 254, 178, 35, 123, 148, 23, 3, 69, 57, 40, 47, 205, 63, 246, 69, 160, 211, 12])));
/// AVR: GDAVR22FW3YZYXWZFLXFSYE6E27DEX7VMECU25543AZEFOEDSSIY7YG2
static immutable AVR = KeyPair(PublicKey(Point([193, 88, 235, 69, 182, 241, 156, 94, 217, 42, 238, 89, 96, 158, 38, 190, 50, 95, 245, 97, 5, 77, 119, 188, 216, 50, 66, 184, 131, 148, 145, 143])), SecretKey(Scalar([33, 252, 155, 194, 5, 195, 202, 142, 132, 205, 15, 168, 193, 125, 46, 155, 255, 206, 108, 21, 9, 134, 35, 242, 89, 74, 148, 14, 168, 59, 86, 4])));
/// AVS: GDAVS22B4QFOCOZGWQFSFLEHBZT6IFUBNDPKLIZORRGKHOW2SAHLUHCH
static immutable AVS = KeyPair(PublicKey(Point([193, 89, 107, 65, 228, 10, 225, 59, 38, 180, 11, 34, 172, 135, 14, 103, 228, 22, 129, 104, 222, 165, 163, 46, 140, 76, 163, 186, 218, 144, 14, 186])), SecretKey(Scalar([71, 3, 84, 81, 198, 24, 17, 156, 140, 27, 211, 123, 84, 66, 68, 36, 32, 15, 225, 25, 82, 179, 68, 137, 120, 89, 183, 58, 242, 230, 62, 15])));
/// AVT: GDAVT22CKOUPUQYMHNFLKJML6F2HWB4H64B67KAFUGKO5EXBXEABQDWC
static immutable AVT = KeyPair(PublicKey(Point([193, 89, 235, 66, 83, 168, 250, 67, 12, 59, 74, 181, 37, 139, 241, 116, 123, 7, 135, 247, 3, 239, 168, 5, 161, 148, 238, 146, 225, 185, 0, 24])), SecretKey(Scalar([165, 52, 98, 175, 29, 111, 202, 144, 72, 139, 224, 143, 241, 190, 146, 33, 161, 104, 3, 198, 110, 191, 79, 156, 182, 45, 242, 158, 244, 110, 211, 3])));
/// AVU: GDAVU22BHZWIBKFT7LWKIPFQ3BWHDOEGZIBF6LC3XFCBHVFKZ32LILBL
static immutable AVU = KeyPair(PublicKey(Point([193, 90, 107, 65, 62, 108, 128, 168, 179, 250, 236, 164, 60, 176, 216, 108, 113, 184, 134, 202, 2, 95, 44, 91, 185, 68, 19, 212, 170, 206, 244, 180])), SecretKey(Scalar([28, 25, 109, 134, 221, 234, 85, 85, 178, 98, 247, 208, 45, 203, 142, 176, 141, 106, 89, 97, 140, 208, 225, 29, 55, 252, 215, 32, 55, 102, 32, 8])));
/// AVV: GDAVV22YQXW5PRJ4K2FTWMPOMQFADWGAXLYYNSVFEZUEH45XDYTEVF6J
static immutable AVV = KeyPair(PublicKey(Point([193, 90, 235, 88, 133, 237, 215, 197, 60, 86, 139, 59, 49, 238, 100, 10, 1, 216, 192, 186, 241, 134, 202, 165, 38, 104, 67, 243, 183, 30, 38, 74])), SecretKey(Scalar([71, 248, 93, 22, 182, 146, 203, 141, 141, 213, 106, 43, 37, 174, 124, 180, 115, 124, 253, 12, 58, 184, 40, 235, 74, 240, 211, 107, 106, 202, 115, 13])));
/// AVW: GDAVW22I7KPWG2CLBB7ZXV4CRD7DYZUUQJABOIANKJ7AZ6JMQL534NXR
static immutable AVW = KeyPair(PublicKey(Point([193, 91, 107, 72, 250, 159, 99, 104, 75, 8, 127, 155, 215, 130, 136, 254, 60, 102, 148, 130, 64, 23, 32, 13, 82, 126, 12, 249, 44, 130, 251, 190])), SecretKey(Scalar([127, 196, 7, 204, 117, 252, 241, 191, 58, 236, 151, 185, 247, 139, 196, 44, 237, 234, 83, 149, 111, 219, 251, 72, 126, 86, 227, 219, 40, 178, 83, 14])));
/// AVX: GDAVX22KJ2RQUWI5PXGCHPS3UJDLPVGEMWOB5LDIPOWBQODDSYWHMISL
static immutable AVX = KeyPair(PublicKey(Point([193, 91, 235, 74, 78, 163, 10, 89, 29, 125, 204, 35, 190, 91, 162, 70, 183, 212, 196, 101, 156, 30, 172, 104, 123, 172, 24, 56, 99, 150, 44, 118])), SecretKey(Scalar([132, 251, 176, 57, 181, 133, 18, 71, 94, 183, 29, 248, 115, 223, 38, 38, 108, 61, 189, 80, 76, 237, 232, 238, 41, 59, 135, 49, 65, 52, 160, 10])));
/// AVY: GDAVY226JSMQQYCOVKTR3GVQ5W3GUOT7MFQGBMSA2BGOKRRZWFATAJZF
static immutable AVY = KeyPair(PublicKey(Point([193, 92, 107, 94, 76, 153, 8, 96, 78, 170, 167, 29, 154, 176, 237, 182, 106, 58, 127, 97, 96, 96, 178, 64, 208, 76, 229, 70, 57, 177, 65, 48])), SecretKey(Scalar([215, 8, 76, 253, 236, 94, 157, 148, 61, 248, 130, 160, 223, 54, 30, 49, 171, 83, 231, 139, 179, 61, 217, 233, 214, 4, 193, 190, 241, 222, 107, 5])));
/// AVZ: GDAVZ22N7OHP3QGYIXHPGBQJEQ6LKNKXJLN3BMRRFL6LTDRWGQXRLEZK
static immutable AVZ = KeyPair(PublicKey(Point([193, 92, 235, 77, 251, 142, 253, 192, 216, 69, 206, 243, 6, 9, 36, 60, 181, 53, 87, 74, 219, 176, 178, 49, 42, 252, 185, 142, 54, 52, 47, 21])), SecretKey(Scalar([9, 212, 250, 77, 164, 65, 195, 28, 202, 91, 56, 136, 197, 197, 2, 117, 55, 3, 133, 160, 113, 69, 64, 91, 229, 85, 187, 112, 146, 131, 91, 8])));
/// AWA: GDAWA22WS27CO6YIMNELMDBDM4URQVFMXBBKHRJJMSWFAJNQNAAQYCT3
static immutable AWA = KeyPair(PublicKey(Point([193, 96, 107, 86, 150, 190, 39, 123, 8, 99, 72, 182, 12, 35, 103, 41, 24, 84, 172, 184, 66, 163, 197, 41, 100, 172, 80, 37, 176, 104, 1, 12])), SecretKey(Scalar([135, 67, 114, 179, 203, 15, 167, 123, 10, 19, 83, 164, 126, 54, 237, 45, 159, 83, 174, 3, 21, 49, 80, 200, 201, 86, 194, 196, 143, 51, 234, 9])));
/// AWB: GDAWB22P5PSGUOJRMQ5CU3AGUJNNXJGGLRGLR646YN5NEWQEGOV3QC3F
static immutable AWB = KeyPair(PublicKey(Point([193, 96, 235, 79, 235, 228, 106, 57, 49, 100, 58, 42, 108, 6, 162, 90, 219, 164, 198, 92, 76, 184, 251, 158, 195, 122, 210, 90, 4, 51, 171, 184])), SecretKey(Scalar([243, 80, 132, 59, 55, 111, 150, 80, 190, 73, 12, 120, 110, 86, 143, 202, 13, 54, 0, 64, 216, 228, 69, 132, 157, 47, 52, 212, 168, 144, 168, 10])));
/// AWC: GDAWC22QMQXAFAUN5D4LRCWEQDWSMXXSYITLWWRFLHK3MFQ5BTJKEPYW
static immutable AWC = KeyPair(PublicKey(Point([193, 97, 107, 80, 100, 46, 2, 130, 141, 232, 248, 184, 138, 196, 128, 237, 38, 94, 242, 194, 38, 187, 90, 37, 89, 213, 182, 22, 29, 12, 210, 162])), SecretKey(Scalar([249, 168, 98, 119, 255, 157, 30, 175, 237, 30, 224, 173, 143, 244, 230, 205, 39, 59, 63, 236, 247, 119, 247, 102, 229, 255, 24, 110, 237, 124, 238, 9])));
/// AWD: GDAWD22ELV5DCSJHLSJSF63JFP5ZFXZWNR76FMCHCATE6CUV4UZA4OFH
static immutable AWD = KeyPair(PublicKey(Point([193, 97, 235, 68, 93, 122, 49, 73, 39, 92, 147, 34, 251, 105, 43, 251, 146, 223, 54, 108, 127, 226, 176, 71, 16, 38, 79, 10, 149, 229, 50, 14])), SecretKey(Scalar([211, 41, 0, 43, 36, 143, 199, 57, 189, 189, 15, 172, 30, 196, 79, 71, 66, 126, 228, 2, 146, 229, 60, 145, 244, 18, 240, 186, 194, 39, 153, 6])));
/// AWE: GDAWE22UII4NLZ75IXH26JD7XAH5NSFZAOF4DAQ6PLBY3PSRUFEND3BA
static immutable AWE = KeyPair(PublicKey(Point([193, 98, 107, 84, 66, 56, 213, 231, 253, 69, 207, 175, 36, 127, 184, 15, 214, 200, 185, 3, 139, 193, 130, 30, 122, 195, 141, 190, 81, 161, 72, 209])), SecretKey(Scalar([213, 189, 217, 175, 25, 89, 233, 242, 60, 131, 138, 240, 17, 149, 220, 35, 181, 198, 74, 186, 184, 224, 67, 249, 150, 247, 130, 196, 26, 208, 199, 0])));
/// AWF: GDAWF222PYOAWABEXT3DNMCCDBYX4DSAUBJ5IFPELXHNNRJBFKDLD2FA
static immutable AWF = KeyPair(PublicKey(Point([193, 98, 235, 90, 126, 28, 11, 0, 36, 188, 246, 54, 176, 66, 24, 113, 126, 14, 64, 160, 83, 212, 21, 228, 93, 206, 214, 197, 33, 42, 134, 177])), SecretKey(Scalar([220, 147, 59, 194, 160, 174, 138, 181, 237, 160, 200, 73, 43, 105, 217, 111, 41, 146, 37, 251, 53, 201, 197, 128, 227, 82, 42, 146, 110, 149, 164, 3])));
/// AWG: GDAWG226PIPNWQE43TVZ353CDQSAFJBR2D2Y5ADLKTHZV7O5TBVDNF3P
static immutable AWG = KeyPair(PublicKey(Point([193, 99, 107, 94, 122, 30, 219, 64, 156, 220, 235, 157, 247, 98, 28, 36, 2, 164, 49, 208, 245, 142, 128, 107, 84, 207, 154, 253, 221, 152, 106, 54])), SecretKey(Scalar([12, 32, 148, 14, 232, 54, 199, 169, 74, 70, 144, 110, 132, 87, 238, 181, 84, 60, 140, 123, 174, 35, 22, 35, 64, 223, 102, 141, 59, 101, 192, 13])));
/// AWH: GDAWH22UM3PMQS7POJGEXJRQAEIJGULKAKVDUNJU6SBG2MFI7W3DXKVK
static immutable AWH = KeyPair(PublicKey(Point([193, 99, 235, 84, 102, 222, 200, 75, 239, 114, 76, 75, 166, 48, 1, 16, 147, 81, 106, 2, 170, 58, 53, 52, 244, 130, 109, 48, 168, 253, 182, 59])), SecretKey(Scalar([42, 247, 230, 101, 221, 238, 87, 14, 76, 62, 125, 164, 204, 17, 120, 204, 241, 68, 160, 255, 230, 193, 4, 11, 176, 183, 33, 245, 203, 201, 241, 11])));
/// AWI: GDAWI22WAR42W6QN44EJVR7J4MMCFFY4EJRXPU6BGGKV7DBCQEIBHXEP
static immutable AWI = KeyPair(PublicKey(Point([193, 100, 107, 86, 4, 121, 171, 122, 13, 231, 8, 154, 199, 233, 227, 24, 34, 151, 28, 34, 99, 119, 211, 193, 49, 149, 95, 140, 34, 129, 16, 19])), SecretKey(Scalar([34, 26, 232, 80, 219, 47, 6, 229, 180, 79, 187, 26, 151, 48, 132, 226, 18, 110, 89, 92, 178, 44, 82, 53, 89, 2, 114, 210, 171, 45, 132, 8])));
/// AWJ: GDAWJ2247FOQKGQS52UXI4RN5W2LJGRVKPKMFHGA2PTPJDTWSET6P62F
static immutable AWJ = KeyPair(PublicKey(Point([193, 100, 235, 92, 249, 93, 5, 26, 18, 238, 169, 116, 114, 45, 237, 180, 180, 154, 53, 83, 212, 194, 156, 192, 211, 230, 244, 142, 118, 145, 39, 231])), SecretKey(Scalar([15, 77, 32, 226, 163, 219, 0, 157, 4, 191, 18, 216, 45, 144, 31, 136, 241, 92, 180, 74, 184, 36, 204, 254, 137, 121, 194, 221, 187, 70, 54, 14])));
/// AWK: GDAWK22TIXENY2WSKKKFC3ZRG3SKQU77QDBOGNGJ7PQ7UGKRG5BRB5H5
static immutable AWK = KeyPair(PublicKey(Point([193, 101, 107, 83, 69, 200, 220, 106, 210, 82, 148, 81, 111, 49, 54, 228, 168, 83, 255, 128, 194, 227, 52, 201, 251, 225, 250, 25, 81, 55, 67, 16])), SecretKey(Scalar([89, 61, 115, 115, 51, 243, 145, 19, 188, 50, 52, 117, 109, 8, 107, 113, 41, 115, 43, 161, 32, 1, 69, 211, 135, 0, 48, 29, 60, 5, 94, 5])));
/// AWL: GDAWL22EPZB57QIM4WZBMEF7AKHTCBYWV2OICS5L2IFO5WRDEOYDH75C
static immutable AWL = KeyPair(PublicKey(Point([193, 101, 235, 68, 126, 67, 223, 193, 12, 229, 178, 22, 16, 191, 2, 143, 49, 7, 22, 174, 156, 129, 75, 171, 210, 10, 238, 218, 35, 35, 176, 51])), SecretKey(Scalar([37, 33, 204, 23, 55, 101, 38, 34, 193, 13, 210, 196, 57, 151, 168, 17, 29, 31, 95, 200, 245, 73, 191, 228, 101, 237, 177, 218, 19, 246, 219, 14])));
/// AWM: GDAWM22DVNVBGPJCSLGPI2SZ5JNKVOH2ODAXIP7NGMPXCZP2X2SK7YVO
static immutable AWM = KeyPair(PublicKey(Point([193, 102, 107, 67, 171, 106, 19, 61, 34, 146, 204, 244, 106, 89, 234, 90, 170, 184, 250, 112, 193, 116, 63, 237, 51, 31, 113, 101, 250, 190, 164, 175])), SecretKey(Scalar([25, 109, 138, 51, 35, 254, 61, 17, 182, 120, 240, 198, 3, 126, 156, 136, 213, 81, 219, 156, 85, 197, 121, 252, 146, 112, 153, 28, 208, 21, 42, 3])));
/// AWN: GDAWN22PRDBYHLCOQJCJDBPSLBVGVWTTEJ6PZR5ICRC5GE4ZA6HDOKZJ
static immutable AWN = KeyPair(PublicKey(Point([193, 102, 235, 79, 136, 195, 131, 172, 78, 130, 68, 145, 133, 242, 88, 106, 106, 218, 115, 34, 124, 252, 199, 168, 20, 69, 211, 19, 153, 7, 142, 55])), SecretKey(Scalar([234, 199, 249, 123, 133, 54, 99, 56, 221, 99, 234, 148, 137, 76, 160, 120, 65, 190, 70, 61, 40, 159, 252, 39, 25, 182, 50, 3, 185, 200, 150, 10])));
/// AWO: GDAWO22JNIE76SHWL7I55MXGBOO6UBTA6WZTBRRE6EKRM3FXE4FHVVRV
static immutable AWO = KeyPair(PublicKey(Point([193, 103, 107, 73, 106, 9, 255, 72, 246, 95, 209, 222, 178, 230, 11, 157, 234, 6, 96, 245, 179, 48, 198, 36, 241, 21, 22, 108, 183, 39, 10, 122])), SecretKey(Scalar([149, 193, 36, 205, 214, 43, 249, 193, 245, 135, 193, 39, 172, 161, 244, 125, 120, 151, 128, 158, 19, 94, 10, 179, 66, 16, 236, 56, 200, 54, 195, 0])));
/// AWP: GDAWP22SHZAEJJWICP2JHUAGTW7J2SA2QWVWAYWLMZQHRKE5W74BXBTG
static immutable AWP = KeyPair(PublicKey(Point([193, 103, 235, 82, 62, 64, 68, 166, 200, 19, 244, 147, 208, 6, 157, 190, 157, 72, 26, 133, 171, 96, 98, 203, 102, 96, 120, 168, 157, 183, 248, 27])), SecretKey(Scalar([217, 54, 134, 74, 255, 111, 172, 191, 182, 135, 94, 181, 134, 221, 149, 90, 210, 156, 120, 17, 239, 160, 63, 182, 201, 112, 206, 182, 69, 101, 98, 6])));
/// AWQ: GDAWQ22ZR4BA3IK3SEEVMJGWKKJBLKYISJL44BGZ67VCYJSM3HITV7UD
static immutable AWQ = KeyPair(PublicKey(Point([193, 104, 107, 89, 143, 2, 13, 161, 91, 145, 9, 86, 36, 214, 82, 146, 21, 171, 8, 146, 87, 206, 4, 217, 247, 234, 44, 38, 76, 217, 209, 58])), SecretKey(Scalar([237, 113, 177, 33, 150, 230, 142, 151, 201, 135, 201, 20, 132, 127, 242, 242, 110, 8, 113, 87, 31, 156, 89, 98, 132, 225, 22, 187, 178, 243, 58, 9])));
/// AWR: GDAWR22ZH3MXQVJ3RJHXWGVGAFSVYSOJS2HE6BHFAIZYVPHQ4FSRHAWV
static immutable AWR = KeyPair(PublicKey(Point([193, 104, 235, 89, 62, 217, 120, 85, 59, 138, 79, 123, 26, 166, 1, 101, 92, 73, 201, 150, 142, 79, 4, 229, 2, 51, 138, 188, 240, 225, 101, 19])), SecretKey(Scalar([232, 208, 173, 105, 35, 15, 117, 72, 112, 142, 204, 50, 185, 129, 64, 222, 11, 96, 133, 207, 226, 162, 39, 156, 103, 24, 223, 253, 50, 84, 162, 5])));
/// AWS: GDAWS22XVSNVALRBWRTM24TP7A57EPNOV7MNV3KKDDGSEMNJLMNFYSZV
static immutable AWS = KeyPair(PublicKey(Point([193, 105, 107, 87, 172, 155, 80, 46, 33, 180, 102, 205, 114, 111, 248, 59, 242, 61, 174, 175, 216, 218, 237, 74, 24, 205, 34, 49, 169, 91, 26, 92])), SecretKey(Scalar([52, 143, 195, 235, 216, 60, 238, 95, 196, 180, 110, 50, 3, 96, 197, 133, 35, 209, 144, 157, 118, 164, 230, 136, 225, 108, 254, 167, 191, 153, 64, 2])));
/// AWT: GDAWT22NBEPLTUJMBL2IAVNCARGP6MIXTEV63PWBSQEDOTL52GD4W3YF
static immutable AWT = KeyPair(PublicKey(Point([193, 105, 235, 77, 9, 30, 185, 209, 44, 10, 244, 128, 85, 162, 4, 76, 255, 49, 23, 153, 43, 237, 190, 193, 148, 8, 55, 77, 125, 209, 135, 203])), SecretKey(Scalar([72, 149, 75, 99, 49, 66, 141, 185, 105, 89, 251, 80, 111, 15, 184, 24, 92, 92, 76, 147, 223, 209, 62, 32, 75, 158, 234, 90, 63, 233, 32, 14])));
/// AWU: GDAWU22K5WAAQCFENVCSUYMUGN5GR7MFR6GV2W2ZXQ6ZSYU6OFEWWPDZ
static immutable AWU = KeyPair(PublicKey(Point([193, 106, 107, 74, 237, 128, 8, 8, 164, 109, 69, 42, 97, 148, 51, 122, 104, 253, 133, 143, 141, 93, 91, 89, 188, 61, 153, 98, 158, 113, 73, 107])), SecretKey(Scalar([8, 208, 234, 210, 111, 13, 235, 128, 120, 56, 71, 45, 224, 220, 219, 76, 88, 248, 125, 92, 234, 237, 174, 56, 204, 172, 65, 33, 176, 208, 122, 2])));
/// AWV: GDAWV22QWQGMYGYQPMBSELDFYFKDK2PG2CHJLEMM35PF3OJ66BIVOM24
static immutable AWV = KeyPair(PublicKey(Point([193, 106, 235, 80, 180, 12, 204, 27, 16, 123, 3, 34, 44, 101, 193, 84, 53, 105, 230, 208, 142, 149, 145, 140, 223, 94, 93, 185, 62, 240, 81, 87])), SecretKey(Scalar([124, 163, 68, 213, 250, 172, 9, 61, 175, 131, 12, 9, 99, 242, 181, 102, 121, 13, 93, 205, 245, 218, 130, 217, 52, 158, 183, 65, 235, 131, 114, 10])));
/// AWW: GDAWW22QGIQIKWZ6DLE3SUV6GY7C2PSI25EWNQULPYG3ZLGUS73LD3LY
static immutable AWW = KeyPair(PublicKey(Point([193, 107, 107, 80, 50, 32, 133, 91, 62, 26, 201, 185, 82, 190, 54, 62, 45, 62, 72, 215, 73, 102, 194, 139, 126, 13, 188, 172, 212, 151, 246, 177])), SecretKey(Scalar([204, 64, 169, 165, 1, 44, 65, 5, 74, 125, 110, 80, 211, 254, 108, 205, 33, 0, 63, 152, 84, 5, 150, 23, 66, 232, 169, 246, 52, 87, 53, 5])));
/// AWX: GDAWX22TE6IF375V4S3OOPVS6X3IVQVP334CGTFY243FD6QARNHTKORK
static immutable AWX = KeyPair(PublicKey(Point([193, 107, 235, 83, 39, 144, 93, 255, 181, 228, 182, 231, 62, 178, 245, 246, 138, 194, 175, 222, 248, 35, 76, 184, 215, 54, 81, 250, 0, 139, 79, 53])), SecretKey(Scalar([90, 195, 251, 215, 153, 102, 11, 58, 65, 84, 195, 16, 201, 213, 67, 56, 182, 72, 193, 232, 59, 78, 138, 52, 215, 86, 138, 252, 0, 91, 124, 14])));
/// AWY: GDAWY22C657RTLVSVT4Q2ITB63HLHCBJRUKIOANKKX54RUEFNJXN3PKA
static immutable AWY = KeyPair(PublicKey(Point([193, 108, 107, 66, 247, 127, 25, 174, 178, 172, 249, 13, 34, 97, 246, 206, 179, 136, 41, 141, 20, 135, 1, 170, 85, 251, 200, 208, 133, 106, 110, 221])), SecretKey(Scalar([200, 171, 252, 136, 132, 175, 250, 112, 187, 98, 143, 139, 67, 238, 131, 112, 118, 20, 11, 206, 209, 83, 41, 98, 252, 244, 38, 250, 188, 111, 100, 15])));
/// AWZ: GDAWZ226RR5YMSUISIT32TB6HVHJ33WXSTPZZSZUZXFRGSM54QVUJVUW
static immutable AWZ = KeyPair(PublicKey(Point([193, 108, 235, 94, 140, 123, 134, 74, 136, 146, 39, 189, 76, 62, 61, 78, 157, 238, 215, 148, 223, 156, 203, 52, 205, 203, 19, 73, 157, 228, 43, 68])), SecretKey(Scalar([69, 117, 16, 15, 86, 136, 51, 77, 83, 10, 76, 149, 184, 27, 115, 216, 167, 168, 165, 150, 85, 48, 13, 240, 179, 231, 134, 115, 231, 97, 92, 11])));
/// AXA: GDAXA22XW64CUFKEVL62VLL67VHSNSGMXCUEHGVH4HKSTJTUYQWRS6HA
static immutable AXA = KeyPair(PublicKey(Point([193, 112, 107, 87, 183, 184, 42, 21, 68, 170, 253, 170, 173, 126, 253, 79, 38, 200, 204, 184, 168, 67, 154, 167, 225, 213, 41, 166, 116, 196, 45, 25])), SecretKey(Scalar([227, 190, 67, 131, 6, 247, 94, 25, 104, 70, 181, 80, 202, 173, 139, 50, 171, 54, 164, 196, 210, 200, 42, 71, 62, 8, 116, 82, 122, 66, 16, 5])));
/// AXB: GDAXB22M4DVAH4P3SNGJPDDO2HAA7EG6VBJAAJT2PZALICZYCWAPGWDL
static immutable AXB = KeyPair(PublicKey(Point([193, 112, 235, 76, 224, 234, 3, 241, 251, 147, 76, 151, 140, 110, 209, 192, 15, 144, 222, 168, 82, 0, 38, 122, 126, 64, 180, 11, 56, 21, 128, 243])), SecretKey(Scalar([185, 172, 198, 66, 170, 0, 10, 98, 163, 223, 155, 226, 151, 136, 40, 182, 42, 107, 14, 8, 31, 162, 119, 125, 115, 60, 218, 131, 0, 207, 135, 7])));
/// AXC: GDAXC22PV576PBAZJAPFEGJRFB77QPLO3ACW2UWGF2QSE7ICT6K4DLQG
static immutable AXC = KeyPair(PublicKey(Point([193, 113, 107, 79, 175, 127, 231, 132, 25, 72, 30, 82, 25, 49, 40, 127, 248, 61, 110, 216, 5, 109, 82, 198, 46, 161, 34, 125, 2, 159, 149, 193])), SecretKey(Scalar([232, 170, 115, 105, 244, 111, 208, 115, 249, 233, 70, 15, 11, 137, 46, 91, 123, 7, 133, 111, 9, 37, 129, 237, 29, 186, 16, 228, 37, 76, 239, 14])));
/// AXD: GDAXD22G3WESIATYZIT5O3I7Z4ZJKHZ2UICHKYJSQJQHFWJIMBA4H35O
static immutable AXD = KeyPair(PublicKey(Point([193, 113, 235, 70, 221, 137, 36, 2, 120, 202, 39, 215, 109, 31, 207, 50, 149, 31, 58, 162, 4, 117, 97, 50, 130, 96, 114, 217, 40, 96, 65, 195])), SecretKey(Scalar([169, 113, 144, 171, 7, 106, 113, 16, 138, 220, 33, 58, 174, 226, 198, 189, 163, 197, 229, 131, 233, 13, 151, 73, 148, 251, 56, 50, 229, 127, 243, 9])));
/// AXE: GDAXE22RUF743O53H6K65AV7MU6LLA5OYZVIOPRGNUEVAMXZJUYOLFM6
static immutable AXE = KeyPair(PublicKey(Point([193, 114, 107, 81, 161, 127, 205, 187, 187, 63, 149, 238, 130, 191, 101, 60, 181, 131, 174, 198, 106, 135, 62, 38, 109, 9, 80, 50, 249, 77, 48, 229])), SecretKey(Scalar([0, 6, 82, 171, 125, 45, 145, 160, 45, 37, 31, 30, 47, 62, 149, 115, 162, 202, 107, 136, 156, 131, 232, 210, 0, 172, 143, 75, 138, 29, 151, 7])));
/// AXF: GDAXF226OIL744I26LFST5X3MYCZCAJTNVO5H3IUUS35MZPFJZZRXYT7
static immutable AXF = KeyPair(PublicKey(Point([193, 114, 235, 94, 114, 23, 254, 113, 26, 242, 203, 41, 246, 251, 102, 5, 145, 1, 51, 109, 93, 211, 237, 20, 164, 183, 214, 101, 229, 78, 115, 27])), SecretKey(Scalar([39, 243, 22, 24, 240, 246, 198, 28, 85, 43, 250, 106, 247, 90, 68, 96, 145, 200, 240, 47, 172, 249, 238, 93, 242, 100, 29, 207, 114, 215, 207, 10])));
/// AXG: GDAXG22MGP4VT56XGMUQNJMR5WHWJ52BQV2YJBBS3BPJHELJ2NCA3T3O
static immutable AXG = KeyPair(PublicKey(Point([193, 115, 107, 76, 51, 249, 89, 247, 215, 51, 41, 6, 165, 145, 237, 143, 100, 247, 65, 133, 117, 132, 132, 50, 216, 94, 147, 145, 105, 211, 68, 13])), SecretKey(Scalar([202, 67, 229, 189, 192, 236, 125, 244, 102, 229, 188, 155, 76, 49, 20, 8, 28, 26, 133, 233, 101, 170, 31, 240, 8, 177, 140, 196, 206, 114, 152, 14])));
/// AXH: GDAXH22OXR64Z3UNA3VRT2RTTNNARVXLGWV3FIOTMVUHXE2HF3UGTBR5
static immutable AXH = KeyPair(PublicKey(Point([193, 115, 235, 78, 188, 125, 204, 238, 141, 6, 235, 25, 234, 51, 155, 90, 8, 214, 235, 53, 171, 178, 161, 211, 101, 104, 123, 147, 71, 46, 232, 105])), SecretKey(Scalar([196, 139, 165, 64, 255, 202, 20, 116, 79, 85, 63, 224, 210, 230, 24, 137, 216, 67, 122, 253, 46, 123, 74, 134, 100, 62, 119, 7, 182, 146, 138, 15])));
/// AXI: GDAXI22EKLH5XQT5T7ZUFMXUKTY3SGKRUMZDYYWO7ARQTO3BQILSRYZX
static immutable AXI = KeyPair(PublicKey(Point([193, 116, 107, 68, 82, 207, 219, 194, 125, 159, 243, 66, 178, 244, 84, 241, 185, 25, 81, 163, 50, 60, 98, 206, 248, 35, 9, 187, 97, 130, 23, 40])), SecretKey(Scalar([116, 146, 0, 81, 107, 152, 21, 24, 189, 16, 125, 10, 160, 15, 238, 187, 149, 229, 172, 89, 158, 131, 183, 198, 135, 94, 107, 131, 88, 159, 71, 5])));
/// AXJ: GDAXJ22ISNDI3YU67DHTZNZQKA6RZB37CBVQYJWLG3V2LJ26MADOGV2S
static immutable AXJ = KeyPair(PublicKey(Point([193, 116, 235, 72, 147, 70, 141, 226, 158, 248, 207, 60, 183, 48, 80, 61, 28, 135, 127, 16, 107, 12, 38, 203, 54, 235, 165, 167, 94, 96, 6, 227])), SecretKey(Scalar([32, 241, 242, 27, 238, 155, 162, 248, 97, 89, 80, 159, 156, 92, 75, 55, 243, 216, 97, 236, 155, 35, 134, 127, 20, 14, 115, 68, 49, 153, 118, 6])));
/// AXK: GDAXK22QGGBEOEEPDJODT3QQOYTRB74WTDEFRZSTOF25R6WPXPHT5D6C
static immutable AXK = KeyPair(PublicKey(Point([193, 117, 107, 80, 49, 130, 71, 16, 143, 26, 92, 57, 238, 16, 118, 39, 16, 255, 150, 152, 200, 88, 230, 83, 113, 117, 216, 250, 207, 187, 207, 62])), SecretKey(Scalar([158, 86, 172, 118, 121, 117, 137, 51, 145, 80, 184, 116, 61, 124, 163, 104, 101, 14, 65, 121, 105, 71, 183, 212, 173, 6, 181, 2, 162, 153, 162, 1])));
/// AXL: GDAXL22K4FMKVAVDJWEGDFIMARYKURDROKZ3SYPTG4PZHLZDF5RL2U7S
static immutable AXL = KeyPair(PublicKey(Point([193, 117, 235, 74, 225, 88, 170, 130, 163, 77, 136, 97, 149, 12, 4, 112, 170, 68, 113, 114, 179, 185, 97, 243, 55, 31, 147, 175, 35, 47, 98, 189])), SecretKey(Scalar([36, 243, 217, 203, 233, 151, 231, 126, 125, 41, 18, 35, 68, 6, 129, 118, 225, 159, 164, 151, 7, 234, 9, 33, 24, 153, 140, 172, 14, 253, 9, 10])));
/// AXM: GDAXM22EJPKONO7IF34GE6JWKVI7OQ26Q4R6INFRTT2S5SC5QGECPYPG
static immutable AXM = KeyPair(PublicKey(Point([193, 118, 107, 68, 75, 212, 230, 187, 232, 46, 248, 98, 121, 54, 85, 81, 247, 67, 94, 135, 35, 228, 52, 177, 156, 245, 46, 200, 93, 129, 136, 39])), SecretKey(Scalar([26, 80, 57, 11, 89, 173, 191, 216, 89, 13, 54, 211, 239, 6, 58, 4, 122, 31, 132, 250, 74, 219, 136, 226, 131, 213, 68, 90, 103, 72, 249, 1])));
/// AXN: GDAXN22OAC7JFSJEQ6VHCAU4XOQM2ZVKMW33UDEULN6RWVBV5YN4YNI2
static immutable AXN = KeyPair(PublicKey(Point([193, 118, 235, 78, 0, 190, 146, 201, 36, 135, 170, 113, 2, 156, 187, 160, 205, 102, 170, 101, 183, 186, 12, 148, 91, 125, 27, 84, 53, 238, 27, 204])), SecretKey(Scalar([90, 89, 138, 213, 58, 28, 43, 97, 229, 18, 62, 146, 42, 135, 97, 3, 220, 59, 91, 106, 88, 31, 83, 223, 58, 193, 234, 6, 97, 191, 54, 2])));
/// AXO: GDAXO22BAG3GYAD4U6TXJFQ3BQMFPVQAT6MAB2Z54HQVWH7MWBAMQYEJ
static immutable AXO = KeyPair(PublicKey(Point([193, 119, 107, 65, 1, 182, 108, 0, 124, 167, 167, 116, 150, 27, 12, 24, 87, 214, 0, 159, 152, 0, 235, 61, 225, 225, 91, 31, 236, 176, 64, 200])), SecretKey(Scalar([181, 201, 181, 196, 109, 113, 139, 224, 249, 3, 44, 101, 202, 215, 220, 13, 181, 207, 118, 143, 43, 17, 152, 16, 183, 49, 86, 121, 123, 193, 184, 1])));
/// AXP: GDAXP22SLAMJ6K72ZO5OHQOGGX4FX66DHMVUJZJDADMXSY5AI7MGNH3C
static immutable AXP = KeyPair(PublicKey(Point([193, 119, 235, 82, 88, 24, 159, 43, 250, 203, 186, 227, 193, 198, 53, 248, 91, 251, 195, 59, 43, 68, 229, 35, 0, 217, 121, 99, 160, 71, 216, 102])), SecretKey(Scalar([65, 22, 130, 137, 172, 85, 225, 65, 145, 190, 202, 176, 229, 9, 191, 150, 155, 6, 26, 18, 84, 50, 150, 94, 26, 178, 223, 212, 165, 192, 73, 10])));
/// AXQ: GDAXQ22AZL4RQ57BWB4YCHJZST733ET2HDCHW52DFFHDFD4R722PQARQ
static immutable AXQ = KeyPair(PublicKey(Point([193, 120, 107, 64, 202, 249, 24, 119, 225, 176, 121, 129, 29, 57, 148, 255, 189, 146, 122, 56, 196, 123, 119, 67, 41, 78, 50, 143, 145, 254, 180, 248])), SecretKey(Scalar([132, 74, 146, 239, 123, 83, 122, 84, 181, 236, 197, 37, 101, 21, 84, 123, 76, 211, 22, 85, 141, 115, 86, 92, 56, 217, 22, 79, 28, 156, 101, 13])));
/// AXR: GDAXR22B6SZBIWE3W6UNGOUW626HKOONMAQCCNNS5Z2NY4AHQYO2KIPW
static immutable AXR = KeyPair(PublicKey(Point([193, 120, 235, 65, 244, 178, 20, 88, 155, 183, 168, 211, 58, 150, 246, 188, 117, 57, 205, 96, 32, 33, 53, 178, 238, 116, 220, 112, 7, 134, 29, 165])), SecretKey(Scalar([112, 2, 147, 16, 235, 194, 93, 241, 40, 52, 28, 21, 228, 197, 63, 139, 240, 28, 97, 55, 132, 4, 64, 158, 65, 21, 102, 113, 25, 139, 192, 15])));
/// AXS: GDAXS22BSYGQD2QSU7T6JQCSL27VLYXRKPGRLHP2DBX57JTOX5CFXWGM
static immutable AXS = KeyPair(PublicKey(Point([193, 121, 107, 65, 150, 13, 1, 234, 18, 167, 231, 228, 192, 82, 94, 191, 85, 226, 241, 83, 205, 21, 157, 250, 24, 111, 223, 166, 110, 191, 68, 91])), SecretKey(Scalar([205, 185, 235, 157, 39, 17, 196, 231, 218, 47, 188, 75, 91, 146, 231, 117, 164, 129, 242, 166, 81, 109, 76, 29, 225, 250, 66, 87, 43, 105, 165, 5])));
/// AXT: GDAXT223IDX6AWJCQQT4Y2JA6OD3OSIXJQXXIFJIJXWZSCYCBZ534LMO
static immutable AXT = KeyPair(PublicKey(Point([193, 121, 235, 91, 64, 239, 224, 89, 34, 132, 39, 204, 105, 32, 243, 135, 183, 73, 23, 76, 47, 116, 21, 40, 77, 237, 153, 11, 2, 14, 123, 190])), SecretKey(Scalar([230, 231, 158, 208, 110, 191, 215, 36, 61, 124, 175, 91, 236, 118, 82, 139, 38, 18, 64, 247, 110, 228, 144, 131, 221, 176, 249, 102, 69, 162, 235, 15])));
/// AXU: GDAXU22X4GPJPKK54MOIQJSB4MOHXVTEDQ3YP4VQHVBU2UQR2FL6KUPT
static immutable AXU = KeyPair(PublicKey(Point([193, 122, 107, 87, 225, 158, 151, 169, 93, 227, 28, 136, 38, 65, 227, 28, 123, 214, 100, 28, 55, 135, 242, 176, 61, 67, 77, 82, 17, 209, 87, 229])), SecretKey(Scalar([251, 177, 248, 114, 122, 198, 127, 204, 255, 163, 65, 82, 205, 140, 205, 140, 151, 71, 4, 19, 24, 96, 83, 197, 237, 108, 243, 39, 33, 139, 48, 3])));
/// AXV: GDAXV22IKIDHHMZHLZU2COKS7EEB3J7UJP3J6H6PNSHTGIG6FPAQ6BOW
static immutable AXV = KeyPair(PublicKey(Point([193, 122, 235, 72, 82, 6, 115, 179, 39, 94, 105, 161, 57, 82, 249, 8, 29, 167, 244, 75, 246, 159, 31, 207, 108, 143, 51, 32, 222, 43, 193, 15])), SecretKey(Scalar([216, 242, 84, 112, 242, 153, 63, 188, 159, 235, 198, 48, 212, 99, 17, 29, 9, 63, 141, 231, 2, 101, 53, 171, 1, 22, 110, 73, 133, 216, 77, 15])));
/// AXW: GDAXW22U3IHNJ3TO2TQBDXYFCGW5CK766OKXTNPPBH3EOE5QUKN3QVIL
static immutable AXW = KeyPair(PublicKey(Point([193, 123, 107, 84, 218, 14, 212, 238, 110, 212, 224, 17, 223, 5, 17, 173, 209, 43, 254, 243, 149, 121, 181, 239, 9, 246, 71, 19, 176, 162, 155, 184])), SecretKey(Scalar([237, 255, 48, 112, 84, 157, 108, 189, 79, 212, 181, 240, 183, 38, 238, 51, 7, 94, 139, 104, 8, 133, 98, 13, 0, 194, 253, 207, 39, 93, 244, 0])));
/// AXX: GDAXX22DZSUJ3UOOS2DF637WCN5MS7THXXGLOMIXJ5ILBPY2D72NO2SH
static immutable AXX = KeyPair(PublicKey(Point([193, 123, 235, 67, 204, 168, 157, 209, 206, 150, 134, 95, 111, 246, 19, 122, 201, 126, 103, 189, 204, 183, 49, 23, 79, 80, 176, 191, 26, 31, 244, 215])), SecretKey(Scalar([1, 54, 76, 221, 123, 92, 154, 135, 200, 62, 255, 243, 161, 243, 225, 146, 213, 80, 148, 159, 220, 200, 50, 242, 127, 150, 34, 25, 109, 229, 37, 11])));
/// AXY: GDAXY22JBJICDOFNGADE6W7FG6K6LWIWCQ2RCCZ7V6F53QLR5O3XPIMA
static immutable AXY = KeyPair(PublicKey(Point([193, 124, 107, 73, 10, 80, 33, 184, 173, 48, 6, 79, 91, 229, 55, 149, 229, 217, 22, 20, 53, 17, 11, 63, 175, 139, 221, 193, 113, 235, 183, 119])), SecretKey(Scalar([96, 18, 174, 191, 39, 136, 206, 57, 171, 46, 224, 203, 133, 240, 76, 50, 2, 248, 63, 81, 144, 70, 218, 31, 82, 250, 130, 35, 104, 102, 70, 15])));
/// AXZ: GDAXZ22JLFTEIAXACUZ2TOZPXROQJ2YPCCDBR6GHORJTCD5MBKU5SOVF
static immutable AXZ = KeyPair(PublicKey(Point([193, 124, 235, 73, 89, 102, 68, 2, 224, 21, 51, 169, 187, 47, 188, 93, 4, 235, 15, 16, 134, 24, 248, 199, 116, 83, 49, 15, 172, 10, 169, 217])), SecretKey(Scalar([252, 17, 131, 255, 158, 94, 142, 122, 18, 225, 123, 152, 5, 82, 187, 225, 84, 84, 18, 109, 135, 207, 247, 68, 240, 211, 136, 164, 249, 47, 144, 13])));
/// AYA: GDAYA22FJPXI7SQWZM4Q4PMFDQZ4FHO25WEOWXZXZUGYPWVVAFRJFFTY
static immutable AYA = KeyPair(PublicKey(Point([193, 128, 107, 69, 75, 238, 143, 202, 22, 203, 57, 14, 61, 133, 28, 51, 194, 157, 218, 237, 136, 235, 95, 55, 205, 13, 135, 218, 181, 1, 98, 146])), SecretKey(Scalar([170, 71, 146, 76, 34, 138, 166, 150, 77, 59, 134, 252, 96, 71, 183, 138, 245, 108, 26, 186, 91, 210, 161, 193, 132, 83, 187, 171, 234, 184, 212, 6])));
/// AYB: GDAYB22RCALA7YKVJSONV5YQA6CJQ2OVQQUN5MIDSURFWLKXZL45S7TB
static immutable AYB = KeyPair(PublicKey(Point([193, 128, 235, 81, 16, 22, 15, 225, 85, 76, 156, 218, 247, 16, 7, 132, 152, 105, 213, 132, 40, 222, 177, 3, 149, 34, 91, 45, 87, 202, 249, 217])), SecretKey(Scalar([153, 123, 255, 57, 70, 53, 87, 153, 201, 229, 201, 217, 107, 179, 22, 204, 87, 154, 163, 68, 126, 63, 252, 16, 166, 16, 87, 44, 97, 116, 114, 0])));
/// AYC: GDAYC222VZV2DVVWWRDWDRRWOSH5L5UKZHQOSSBDUSW6YPFMK4DUF4AQ
static immutable AYC = KeyPair(PublicKey(Point([193, 129, 107, 90, 174, 107, 161, 214, 182, 180, 71, 97, 198, 54, 116, 143, 213, 246, 138, 201, 224, 233, 72, 35, 164, 173, 236, 60, 172, 87, 7, 66])), SecretKey(Scalar([217, 239, 250, 221, 118, 51, 235, 212, 132, 8, 127, 106, 109, 153, 204, 116, 171, 46, 49, 4, 239, 52, 106, 74, 15, 214, 116, 205, 66, 234, 107, 5])));
/// AYD: GDAYD22WYRRNDHOUGLR6OIYTHMND3XAAGHLTXPTLUGOFYMXAAWIRLGXI
static immutable AYD = KeyPair(PublicKey(Point([193, 129, 235, 86, 196, 98, 209, 157, 212, 50, 227, 231, 35, 19, 59, 26, 61, 220, 0, 49, 215, 59, 190, 107, 161, 156, 92, 50, 224, 5, 145, 21])), SecretKey(Scalar([212, 71, 48, 175, 118, 228, 173, 19, 70, 237, 74, 230, 172, 203, 245, 48, 52, 74, 248, 231, 232, 151, 163, 22, 158, 190, 68, 128, 254, 35, 177, 11])));
/// AYE: GDAYE22QXR3IRO6BRX5IRZ4GXK4WEVDVUNWNFKJYRIAFEBPTJIUH3Y6J
static immutable AYE = KeyPair(PublicKey(Point([193, 130, 107, 80, 188, 118, 136, 187, 193, 141, 250, 136, 231, 134, 186, 185, 98, 84, 117, 163, 108, 210, 169, 56, 138, 0, 82, 5, 243, 74, 40, 125])), SecretKey(Scalar([112, 115, 146, 55, 153, 131, 1, 208, 241, 52, 190, 130, 186, 226, 53, 14, 10, 234, 200, 241, 94, 227, 224, 139, 76, 161, 217, 62, 107, 75, 63, 2])));
/// AYF: GDAYF22Q22JIZEFABPR3DVA6EBHV6ZA4I3DPBZYRRB4HKDBXG4VYGIDY
static immutable AYF = KeyPair(PublicKey(Point([193, 130, 235, 80, 214, 146, 140, 144, 160, 11, 227, 177, 212, 30, 32, 79, 95, 100, 28, 70, 198, 240, 231, 17, 136, 120, 117, 12, 55, 55, 43, 131])), SecretKey(Scalar([92, 210, 5, 202, 2, 145, 32, 230, 65, 180, 69, 90, 101, 20, 46, 165, 5, 76, 35, 212, 87, 41, 59, 255, 80, 138, 245, 66, 188, 157, 241, 7])));
/// AYG: GDAYG22FNB22NZH2ZZWEWBEKW33T7QBZ5WKSBDQUV7R34MOMZEIWXQU4
static immutable AYG = KeyPair(PublicKey(Point([193, 131, 107, 69, 104, 117, 166, 228, 250, 206, 108, 75, 4, 138, 182, 247, 63, 192, 57, 237, 149, 32, 142, 20, 175, 227, 190, 49, 204, 201, 17, 107])), SecretKey(Scalar([205, 145, 192, 119, 2, 150, 83, 7, 130, 17, 79, 82, 235, 4, 229, 145, 18, 171, 253, 16, 190, 75, 75, 203, 47, 133, 252, 143, 129, 44, 24, 4])));
/// AYH: GDAYH22FIFEQOBLK434IPXRJFDVRWNRZ3MDRVAOYEV6MXOAT46RZJ4HY
static immutable AYH = KeyPair(PublicKey(Point([193, 131, 235, 69, 65, 73, 7, 5, 106, 230, 248, 135, 222, 41, 40, 235, 27, 54, 57, 219, 7, 26, 129, 216, 37, 124, 203, 184, 19, 231, 163, 148])), SecretKey(Scalar([118, 167, 81, 90, 40, 102, 250, 43, 177, 18, 91, 13, 234, 29, 72, 71, 17, 255, 233, 206, 193, 113, 144, 161, 186, 196, 241, 174, 120, 212, 248, 10])));
/// AYI: GDAYI22H5S7S3YJ3HN65Y4LGWBT52ZJ5PJI4QFCHKEE3TBQW6CRWTSET
static immutable AYI = KeyPair(PublicKey(Point([193, 132, 107, 71, 236, 191, 45, 225, 59, 59, 125, 220, 113, 102, 176, 103, 221, 101, 61, 122, 81, 200, 20, 71, 81, 9, 185, 134, 22, 240, 163, 105])), SecretKey(Scalar([101, 249, 239, 203, 145, 4, 136, 9, 230, 161, 72, 206, 237, 184, 0, 178, 136, 36, 254, 221, 216, 82, 237, 7, 120, 86, 82, 7, 69, 249, 103, 5])));
/// AYJ: GDAYJ22QT7EWMWQ7YZHKED4FSAJYPADGLN34MINB7WX3DOQFXUIWKPUU
static immutable AYJ = KeyPair(PublicKey(Point([193, 132, 235, 80, 159, 201, 102, 90, 31, 198, 78, 162, 15, 133, 144, 19, 135, 128, 102, 91, 119, 198, 33, 161, 253, 175, 177, 186, 5, 189, 17, 101])), SecretKey(Scalar([0, 124, 13, 21, 234, 96, 239, 16, 42, 231, 18, 100, 5, 12, 39, 99, 168, 209, 31, 168, 135, 196, 0, 221, 97, 182, 241, 208, 76, 129, 88, 6])));
/// AYK: GDAYK22JHOJ3HR3RRBUUBU5P75RPKS7BXK5I4GGP7QECVMSGX45XEMIP
static immutable AYK = KeyPair(PublicKey(Point([193, 133, 107, 73, 59, 147, 179, 199, 113, 136, 105, 64, 211, 175, 255, 98, 245, 75, 225, 186, 186, 142, 24, 207, 252, 8, 42, 178, 70, 191, 59, 114])), SecretKey(Scalar([180, 168, 213, 121, 74, 36, 187, 20, 36, 21, 142, 84, 226, 215, 111, 150, 192, 184, 204, 216, 249, 119, 198, 129, 248, 219, 210, 233, 165, 243, 119, 10])));
/// AYL: GDAYL22M6EBOT5FYWFTYYC2VXIV27UPGO4V2NWX2TZVKTOQW7H5JFZEA
static immutable AYL = KeyPair(PublicKey(Point([193, 133, 235, 76, 241, 2, 233, 244, 184, 177, 103, 140, 11, 85, 186, 43, 175, 209, 230, 119, 43, 166, 218, 250, 158, 106, 169, 186, 22, 249, 250, 146])), SecretKey(Scalar([189, 237, 48, 215, 100, 180, 242, 198, 224, 136, 67, 106, 251, 220, 168, 25, 106, 97, 198, 85, 228, 152, 64, 169, 231, 211, 51, 184, 245, 201, 204, 6])));
/// AYM: GDAYM22IA463ZYNNTLJ5XJYJK2T6SOL3ZEU3WQZPBFIPDTQE3NQAU5BG
static immutable AYM = KeyPair(PublicKey(Point([193, 134, 107, 72, 7, 61, 188, 225, 173, 154, 211, 219, 167, 9, 86, 167, 233, 57, 123, 201, 41, 187, 67, 47, 9, 80, 241, 206, 4, 219, 96, 10])), SecretKey(Scalar([13, 25, 65, 195, 122, 59, 49, 240, 63, 133, 199, 3, 220, 97, 89, 176, 70, 76, 6, 25, 100, 212, 171, 249, 120, 211, 32, 121, 193, 41, 167, 7])));
/// AYN: GDAYN22KGDLYQV3IAZCM7BQFN6OGYB4VHLRB3SJXUQP5XES5STHPJ4BY
static immutable AYN = KeyPair(PublicKey(Point([193, 134, 235, 74, 48, 215, 136, 87, 104, 6, 68, 207, 134, 5, 111, 156, 108, 7, 149, 58, 226, 29, 201, 55, 164, 31, 219, 146, 93, 148, 206, 244])), SecretKey(Scalar([71, 88, 192, 217, 125, 125, 176, 161, 22, 24, 217, 14, 183, 216, 75, 209, 19, 189, 248, 158, 45, 16, 34, 179, 227, 34, 3, 253, 201, 59, 191, 15])));
/// AYO: GDAYO22VERQ6SADHFLIS67BM2YOBDEWU6UM7NRFHX2DT6HYT2UXTYV7L
static immutable AYO = KeyPair(PublicKey(Point([193, 135, 107, 85, 36, 97, 233, 0, 103, 42, 209, 47, 124, 44, 214, 28, 17, 146, 212, 245, 25, 246, 196, 167, 190, 135, 63, 31, 19, 213, 47, 60])), SecretKey(Scalar([194, 206, 210, 207, 29, 151, 157, 98, 7, 37, 246, 127, 219, 139, 33, 245, 19, 134, 10, 246, 207, 2, 32, 166, 8, 219, 176, 185, 50, 221, 105, 11])));
/// AYP: GDAYP22TSVWN5Y5KHMDBIZCSGKCSNYMJ3ZOBW3V2GCUZJKFYPEUCRLJP
static immutable AYP = KeyPair(PublicKey(Point([193, 135, 235, 83, 149, 108, 222, 227, 170, 59, 6, 20, 100, 82, 50, 133, 38, 225, 137, 222, 92, 27, 110, 186, 48, 169, 148, 168, 184, 121, 40, 40])), SecretKey(Scalar([160, 12, 210, 9, 211, 172, 50, 243, 254, 218, 141, 54, 154, 114, 93, 125, 168, 130, 176, 155, 118, 189, 109, 141, 150, 69, 222, 27, 126, 167, 200, 3])));
/// AYQ: GDAYQ22DB5LGVNYYPT5TUEWNE7QDWLM67OVIKL7ZUZOUKPGH6CPGSLJO
static immutable AYQ = KeyPair(PublicKey(Point([193, 136, 107, 67, 15, 86, 106, 183, 24, 124, 251, 58, 18, 205, 39, 224, 59, 45, 158, 251, 170, 133, 47, 249, 166, 93, 69, 60, 199, 240, 158, 105])), SecretKey(Scalar([198, 177, 225, 112, 57, 148, 21, 95, 171, 57, 208, 216, 247, 66, 246, 141, 42, 220, 37, 15, 139, 79, 154, 26, 174, 23, 157, 64, 93, 63, 188, 9])));
/// AYR: GDAYR22VOYDG4RU4XF6N5KAIBAH3IV5IVTHDQIWHTX6XG2BHTMDG643Y
static immutable AYR = KeyPair(PublicKey(Point([193, 136, 235, 85, 118, 6, 110, 70, 156, 185, 124, 222, 168, 8, 8, 15, 180, 87, 168, 172, 206, 56, 34, 199, 157, 253, 115, 104, 39, 155, 6, 111])), SecretKey(Scalar([165, 56, 97, 208, 240, 179, 134, 48, 158, 190, 98, 250, 135, 89, 241, 1, 76, 175, 10, 53, 133, 229, 216, 65, 198, 116, 28, 235, 83, 124, 109, 5])));
/// AYS: GDAYS22K55ATTFLFXRNG75642I6SYFHFZAOTORNELW22XALNQ4LBTBS4
static immutable AYS = KeyPair(PublicKey(Point([193, 137, 107, 74, 239, 65, 57, 149, 101, 188, 90, 111, 247, 220, 210, 61, 44, 20, 229, 200, 29, 55, 69, 164, 93, 181, 171, 129, 109, 135, 22, 25])), SecretKey(Scalar([251, 114, 7, 208, 253, 251, 57, 47, 143, 127, 120, 152, 112, 22, 126, 166, 254, 136, 246, 156, 52, 18, 240, 149, 190, 110, 216, 142, 152, 77, 223, 15])));
/// AYT: GDAYT22L67ONCCNZCKCBUIIVZKZXR5UUTHMEYSJZ7T6G6QF4PK76SVFI
static immutable AYT = KeyPair(PublicKey(Point([193, 137, 235, 75, 247, 220, 209, 9, 185, 18, 132, 26, 33, 21, 202, 179, 120, 246, 148, 153, 216, 76, 73, 57, 252, 252, 111, 64, 188, 122, 191, 233])), SecretKey(Scalar([78, 226, 14, 136, 132, 183, 195, 191, 75, 65, 196, 18, 49, 168, 47, 255, 237, 21, 167, 191, 64, 155, 76, 12, 221, 31, 166, 97, 226, 27, 128, 7])));
/// AYU: GDAYU22PMPYS7JHGQSD4OG2IIMBEHM77YGBMBPBPJVSK3OMDMDHEETVL
static immutable AYU = KeyPair(PublicKey(Point([193, 138, 107, 79, 99, 241, 47, 164, 230, 132, 135, 199, 27, 72, 67, 2, 67, 179, 255, 193, 130, 192, 188, 47, 77, 100, 173, 185, 131, 96, 206, 66])), SecretKey(Scalar([1, 184, 125, 227, 20, 227, 28, 18, 230, 218, 5, 82, 90, 210, 122, 157, 80, 4, 134, 7, 66, 0, 22, 229, 181, 236, 13, 192, 147, 150, 223, 6])));
/// AYV: GDAYV22XMUUACES5OQLLVH2ZC5IZBJHB3GIRT2YDESCYCELMFHTJHRXS
static immutable AYV = KeyPair(PublicKey(Point([193, 138, 235, 87, 101, 40, 1, 18, 93, 116, 22, 186, 159, 89, 23, 81, 144, 164, 225, 217, 145, 25, 235, 3, 36, 133, 129, 17, 108, 41, 230, 147])), SecretKey(Scalar([75, 246, 8, 111, 150, 19, 40, 254, 94, 176, 82, 197, 51, 156, 1, 13, 108, 104, 125, 226, 210, 100, 142, 181, 227, 52, 172, 207, 147, 123, 131, 11])));
/// AYW: GDAYW22PKAKKBBQIRBRSEC2VC7KQJI6XTVJU3VHNKMIW2ENERUBM7SUW
static immutable AYW = KeyPair(PublicKey(Point([193, 139, 107, 79, 80, 20, 160, 134, 8, 136, 99, 34, 11, 85, 23, 213, 4, 163, 215, 157, 83, 77, 212, 237, 83, 17, 109, 17, 164, 141, 2, 207])), SecretKey(Scalar([111, 182, 7, 135, 5, 139, 33, 228, 95, 195, 142, 147, 89, 214, 205, 128, 5, 30, 76, 221, 53, 164, 115, 217, 121, 69, 30, 71, 50, 74, 79, 3])));
/// AYX: GDAYX22FLJBRZ66IM3XWSH57VHRWGJH44CUMWAOOCRN6KEUTULJQNUMK
static immutable AYX = KeyPair(PublicKey(Point([193, 139, 235, 69, 90, 67, 28, 251, 200, 102, 239, 105, 31, 191, 169, 227, 99, 36, 252, 224, 168, 203, 1, 206, 20, 91, 229, 18, 147, 162, 211, 6])), SecretKey(Scalar([63, 146, 252, 196, 123, 219, 217, 58, 129, 112, 163, 193, 205, 190, 217, 138, 234, 55, 9, 128, 48, 224, 159, 178, 35, 72, 162, 166, 91, 123, 207, 1])));
/// AYY: GDAYY225PBIWCDXJRPBK3S6PWOZRWY2QQVEOPOFXN4NVDGMZTZX4PPFU
static immutable AYY = KeyPair(PublicKey(Point([193, 140, 107, 93, 120, 81, 97, 14, 233, 139, 194, 173, 203, 207, 179, 179, 27, 99, 80, 133, 72, 231, 184, 183, 111, 27, 81, 153, 153, 158, 111, 199])), SecretKey(Scalar([20, 120, 201, 142, 86, 95, 40, 107, 238, 60, 57, 238, 182, 65, 135, 41, 139, 1, 62, 84, 157, 148, 42, 62, 108, 88, 64, 136, 219, 64, 47, 0])));
/// AYZ: GDAYZ22NOG5P7FS7F3YCL3NQQ3X23FOSMEAD2OHJ2UROMHDUWJNHWDSV
static immutable AYZ = KeyPair(PublicKey(Point([193, 140, 235, 77, 113, 186, 255, 150, 95, 46, 240, 37, 237, 176, 134, 239, 173, 149, 210, 97, 0, 61, 56, 233, 213, 34, 230, 28, 116, 178, 90, 123])), SecretKey(Scalar([212, 63, 91, 135, 34, 236, 172, 205, 9, 147, 28, 105, 161, 12, 92, 140, 40, 214, 187, 125, 120, 223, 130, 184, 3, 200, 43, 118, 95, 171, 200, 0])));
/// AZA: GDAZA227ICCJFLRRZORXZ2Q4A2Z3QGT3HLVUJOU32N2EQFOZU55U36ME
static immutable AZA = KeyPair(PublicKey(Point([193, 144, 107, 95, 64, 132, 146, 174, 49, 203, 163, 124, 234, 28, 6, 179, 184, 26, 123, 58, 235, 68, 186, 155, 211, 116, 72, 21, 217, 167, 123, 77])), SecretKey(Scalar([221, 133, 199, 191, 125, 168, 179, 139, 20, 84, 223, 144, 138, 238, 182, 40, 229, 200, 49, 57, 116, 214, 70, 145, 122, 135, 159, 119, 181, 162, 58, 8])));
/// AZB: GDAZB22Q6DDLPPNV52SB5BANCPEFGTON73SXMD5RJRHEGVYYCY5ZH44Y
static immutable AZB = KeyPair(PublicKey(Point([193, 144, 235, 80, 240, 198, 183, 189, 181, 238, 164, 30, 132, 13, 19, 200, 83, 77, 205, 254, 229, 118, 15, 177, 76, 78, 67, 87, 24, 22, 59, 147])), SecretKey(Scalar([94, 124, 161, 113, 112, 237, 30, 209, 192, 228, 233, 13, 34, 85, 208, 104, 214, 226, 154, 220, 230, 254, 251, 216, 233, 84, 76, 124, 66, 217, 111, 7])));
/// AZC: GDAZC2255LDLICQSKAIHCBLYITX2W25D5K5WYETLORWQUPWSJGPTTUFC
static immutable AZC = KeyPair(PublicKey(Point([193, 145, 107, 93, 234, 198, 180, 10, 18, 80, 16, 113, 5, 120, 68, 239, 171, 107, 163, 234, 187, 108, 18, 107, 116, 109, 10, 62, 210, 73, 159, 57])), SecretKey(Scalar([134, 166, 230, 40, 176, 141, 133, 82, 201, 125, 200, 241, 247, 182, 111, 94, 46, 86, 140, 178, 10, 24, 66, 126, 184, 159, 111, 230, 27, 89, 86, 12])));
/// AZD: GDAZD22M4R2A2KEUJHPJBEJF6BPSDKCFHE4GQFNC6HVPGHNN3RKN4XG2
static immutable AZD = KeyPair(PublicKey(Point([193, 145, 235, 76, 228, 116, 13, 40, 148, 73, 222, 144, 145, 37, 240, 95, 33, 168, 69, 57, 56, 104, 21, 162, 241, 234, 243, 29, 173, 220, 84, 222])), SecretKey(Scalar([206, 118, 44, 169, 210, 72, 12, 97, 240, 238, 42, 28, 184, 86, 72, 198, 196, 48, 46, 41, 42, 249, 205, 72, 156, 175, 92, 117, 38, 156, 40, 11])));
/// AZE: GDAZE22M665V6C5YMLBUMFUOGPFO36DY3H7WO2VH6JJVYVNGGJ4FPDT3
static immutable AZE = KeyPair(PublicKey(Point([193, 146, 107, 76, 247, 187, 95, 11, 184, 98, 195, 70, 22, 142, 51, 202, 237, 248, 120, 217, 255, 103, 106, 167, 242, 83, 92, 85, 166, 50, 120, 87])), SecretKey(Scalar([94, 119, 141, 224, 8, 49, 197, 110, 211, 227, 113, 29, 12, 202, 2, 140, 196, 22, 194, 105, 28, 157, 91, 108, 244, 38, 50, 191, 189, 19, 2, 5])));
/// AZF: GDAZF22UVENGB4OZBTO3QLCHJ4ONE47LZNMUGWLNVAVEMIT43TFBXLSP
static immutable AZF = KeyPair(PublicKey(Point([193, 146, 235, 84, 169, 26, 96, 241, 217, 12, 221, 184, 44, 71, 79, 28, 210, 115, 235, 203, 89, 67, 89, 109, 168, 42, 70, 34, 124, 220, 202, 27])), SecretKey(Scalar([154, 117, 82, 1, 147, 166, 205, 1, 106, 195, 207, 22, 100, 224, 25, 53, 247, 161, 88, 53, 180, 128, 86, 1, 192, 110, 54, 227, 108, 168, 218, 7])));
/// AZG: GDAZG22D3FCJYTYREHCXDCPEWOJ3ILG3M5PVGV7RMGCLKCAAA5GC37TW
static immutable AZG = KeyPair(PublicKey(Point([193, 147, 107, 67, 217, 68, 156, 79, 17, 33, 197, 113, 137, 228, 179, 147, 180, 44, 219, 103, 95, 83, 87, 241, 97, 132, 181, 8, 0, 7, 76, 45])), SecretKey(Scalar([252, 54, 123, 100, 250, 39, 24, 84, 60, 158, 231, 49, 12, 128, 3, 137, 135, 242, 30, 3, 255, 247, 178, 172, 87, 154, 220, 84, 84, 238, 114, 5])));
/// AZH: GDAZH22YM4QGZTHTTABHVGAZTHDPHX266JFV6YOLH3P4YOZTJEZ64ZG4
static immutable AZH = KeyPair(PublicKey(Point([193, 147, 235, 88, 103, 32, 108, 204, 243, 152, 2, 122, 152, 25, 153, 198, 243, 223, 94, 242, 75, 95, 97, 203, 62, 223, 204, 59, 51, 73, 51, 238])), SecretKey(Scalar([72, 132, 187, 127, 159, 186, 10, 89, 215, 187, 107, 61, 77, 180, 48, 160, 136, 7, 246, 142, 112, 160, 211, 100, 155, 223, 138, 13, 0, 97, 69, 5])));
/// AZI: GDAZI22WY3T7VOQEMLE6RBKGXJV5NW25IDGNSBOWPJ5CGQULJVAQ5NUQ
static immutable AZI = KeyPair(PublicKey(Point([193, 148, 107, 86, 198, 231, 250, 186, 4, 98, 201, 232, 133, 70, 186, 107, 214, 219, 93, 64, 204, 217, 5, 214, 122, 122, 35, 66, 139, 77, 65, 14])), SecretKey(Scalar([130, 199, 208, 27, 230, 255, 41, 16, 7, 162, 20, 217, 10, 230, 77, 1, 225, 225, 197, 40, 23, 58, 73, 28, 121, 147, 228, 184, 2, 129, 180, 15])));
/// AZJ: GDAZJ22O7UVAHIYAJLKSEEXWVKWRHFTHLBVL754IUY6EQZ6VVTUDGJZE
static immutable AZJ = KeyPair(PublicKey(Point([193, 148, 235, 78, 253, 42, 3, 163, 0, 74, 213, 34, 18, 246, 170, 173, 19, 150, 103, 88, 106, 191, 247, 136, 166, 60, 72, 103, 213, 172, 232, 51])), SecretKey(Scalar([211, 71, 49, 194, 148, 232, 101, 86, 92, 219, 214, 122, 86, 185, 127, 158, 253, 69, 162, 254, 4, 182, 0, 215, 232, 156, 71, 232, 92, 5, 148, 10])));
/// AZK: GDAZK22KPCWJB3KA2H56WDNE7FLZUVMK6AF6FSMMTVRT5KQK5UVFH376
static immutable AZK = KeyPair(PublicKey(Point([193, 149, 107, 74, 120, 172, 144, 237, 64, 209, 251, 235, 13, 164, 249, 87, 154, 85, 138, 240, 11, 226, 201, 140, 157, 99, 62, 170, 10, 237, 42, 83])), SecretKey(Scalar([108, 99, 138, 248, 91, 186, 141, 113, 199, 25, 34, 122, 107, 41, 75, 89, 60, 172, 199, 117, 164, 13, 3, 102, 24, 225, 153, 219, 233, 93, 206, 14])));
/// AZL: GDAZL2246VV6XKR2R6QB345R3E6565QTZUEZFC7ZI7AQPJCZYRWDRF6K
static immutable AZL = KeyPair(PublicKey(Point([193, 149, 235, 92, 245, 107, 235, 170, 58, 143, 160, 29, 243, 177, 217, 61, 223, 118, 19, 205, 9, 146, 139, 249, 71, 193, 7, 164, 89, 196, 108, 56])), SecretKey(Scalar([218, 163, 142, 50, 135, 49, 34, 142, 11, 221, 81, 124, 20, 147, 54, 235, 3, 203, 177, 205, 25, 161, 93, 101, 21, 1, 30, 151, 117, 151, 141, 12])));
/// AZM: GDAZM22UZ5LO2643UHGZRELQUMMUVZGS4E4LMDWJTAGZSTDTABFCYRKG
static immutable AZM = KeyPair(PublicKey(Point([193, 150, 107, 84, 207, 86, 237, 123, 155, 161, 205, 152, 145, 112, 163, 25, 74, 228, 210, 225, 56, 182, 14, 201, 152, 13, 153, 76, 115, 0, 74, 44])), SecretKey(Scalar([248, 38, 132, 44, 133, 56, 97, 201, 109, 211, 219, 149, 68, 155, 45, 75, 15, 114, 130, 6, 126, 230, 209, 48, 193, 65, 100, 161, 46, 182, 57, 2])));
/// AZN: GDAZN22VOUHFPBDUDWR5NYK7KDZF2F4UKLOPR6BAUZ2NWJCNUSGBHBUX
static immutable AZN = KeyPair(PublicKey(Point([193, 150, 235, 85, 117, 14, 87, 132, 116, 29, 163, 214, 225, 95, 80, 242, 93, 23, 148, 82, 220, 248, 248, 32, 166, 116, 219, 36, 77, 164, 140, 19])), SecretKey(Scalar([86, 172, 159, 13, 67, 12, 146, 60, 253, 199, 167, 150, 166, 218, 91, 148, 207, 10, 185, 13, 8, 237, 104, 44, 59, 171, 15, 114, 198, 201, 8, 14])));
/// AZO: GDAZO22TCX3DQR3XKJGIN5POV7BXENBS7CU5QUBUHW5M5RSAAFJ6LFR7
static immutable AZO = KeyPair(PublicKey(Point([193, 151, 107, 83, 21, 246, 56, 71, 119, 82, 76, 134, 245, 238, 175, 195, 114, 52, 50, 248, 169, 216, 80, 52, 61, 186, 206, 198, 64, 1, 83, 229])), SecretKey(Scalar([32, 1, 41, 59, 136, 152, 206, 99, 115, 122, 233, 29, 108, 238, 170, 183, 154, 172, 35, 148, 86, 163, 219, 0, 188, 181, 86, 239, 133, 205, 37, 1])));
/// AZP: GDAZP22XDOROABAGNH6PW6EZJPMNA3PKR4L47DPP6SECOQVDCJIDIBAQ
static immutable AZP = KeyPair(PublicKey(Point([193, 151, 235, 87, 27, 162, 224, 4, 6, 105, 252, 251, 120, 153, 75, 216, 208, 109, 234, 143, 23, 207, 141, 239, 244, 136, 39, 66, 163, 18, 80, 52])), SecretKey(Scalar([59, 66, 136, 93, 172, 46, 240, 244, 239, 23, 60, 211, 21, 0, 241, 125, 80, 109, 170, 140, 124, 199, 168, 39, 8, 172, 105, 196, 247, 191, 41, 13])));
/// AZQ: GDAZQ22SIX2M3QZYNUWXXXORIOBT2SRDD523MROEBXL5GZBO7IFVB3S3
static immutable AZQ = KeyPair(PublicKey(Point([193, 152, 107, 82, 69, 244, 205, 195, 56, 109, 45, 123, 221, 209, 67, 131, 61, 74, 35, 31, 117, 182, 69, 196, 13, 215, 211, 100, 46, 250, 11, 80])), SecretKey(Scalar([28, 156, 31, 201, 78, 117, 233, 70, 182, 138, 211, 222, 56, 105, 181, 174, 129, 67, 16, 40, 246, 195, 183, 110, 221, 49, 37, 149, 243, 0, 89, 9])));
/// AZR: GDAZR2266UF6GTVRNYEZ7AWDCJF7A66O5WR6KAYZYFFH33F65CSJE2YI
static immutable AZR = KeyPair(PublicKey(Point([193, 152, 235, 94, 245, 11, 227, 78, 177, 110, 9, 159, 130, 195, 18, 75, 240, 123, 206, 237, 163, 229, 3, 25, 193, 74, 125, 236, 190, 232, 164, 146])), SecretKey(Scalar([150, 175, 33, 95, 16, 176, 239, 36, 162, 208, 31, 109, 11, 102, 72, 65, 135, 74, 8, 168, 51, 143, 80, 4, 169, 210, 192, 38, 40, 147, 169, 5])));
/// AZS: GDAZS223FMO5NQV2WV2QXLGJCHPVYKUM76A6D2SQ674OL45OJVE4UZCD
static immutable AZS = KeyPair(PublicKey(Point([193, 153, 107, 91, 43, 29, 214, 194, 186, 181, 117, 11, 172, 201, 17, 223, 92, 42, 140, 255, 129, 225, 234, 80, 247, 248, 229, 243, 174, 77, 73, 202])), SecretKey(Scalar([182, 226, 119, 21, 188, 123, 7, 56, 12, 234, 121, 143, 108, 63, 25, 85, 226, 159, 21, 128, 114, 85, 69, 215, 249, 29, 234, 179, 103, 29, 75, 1])));
/// AZT: GDAZT22ZMUJTAQ3ALSY43RY2AA6Q4AY7AZIDJSUWH63MUBKGA65G26ZY
static immutable AZT = KeyPair(PublicKey(Point([193, 153, 235, 89, 101, 19, 48, 67, 96, 92, 177, 205, 199, 26, 0, 61, 14, 3, 31, 6, 80, 52, 202, 150, 63, 182, 202, 5, 70, 7, 186, 109])), SecretKey(Scalar([203, 252, 69, 74, 121, 31, 190, 130, 29, 35, 194, 78, 228, 47, 30, 206, 91, 156, 31, 211, 196, 180, 245, 211, 128, 250, 78, 148, 7, 156, 156, 4])));
/// AZU: GDAZU22GO7JERGJS4S7YA6KHBPE5OCFXANPJNWEKXFBJCLY5C6AQMAOE
static immutable AZU = KeyPair(PublicKey(Point([193, 154, 107, 70, 119, 210, 72, 153, 50, 228, 191, 128, 121, 71, 11, 201, 215, 8, 183, 3, 94, 150, 216, 138, 185, 66, 145, 47, 29, 23, 129, 6])), SecretKey(Scalar([65, 113, 14, 17, 141, 244, 30, 169, 53, 186, 16, 111, 196, 181, 206, 81, 85, 158, 51, 42, 238, 73, 158, 59, 49, 20, 160, 137, 59, 24, 99, 0])));
/// AZV: GDAZV22A5SJLCD2NZWEY4XPI7JEWKWNXOCAA7YTYRDQHQN2UU7RWFU54
static immutable AZV = KeyPair(PublicKey(Point([193, 154, 235, 64, 236, 146, 177, 15, 77, 205, 137, 142, 93, 232, 250, 73, 101, 89, 183, 112, 128, 15, 226, 120, 136, 224, 120, 55, 84, 167, 227, 98])), SecretKey(Scalar([7, 53, 229, 3, 213, 114, 1, 29, 107, 91, 137, 82, 151, 18, 52, 159, 164, 45, 23, 94, 239, 80, 18, 66, 60, 26, 71, 73, 2, 178, 188, 7])));
/// AZW: GDAZW22V4WVQ6Y6ILIKY3BNODEWBXXK5VY2B3HACFM6VWV4JEEAPDHCC
static immutable AZW = KeyPair(PublicKey(Point([193, 155, 107, 85, 229, 171, 15, 99, 200, 90, 21, 141, 133, 174, 25, 44, 27, 221, 93, 174, 52, 29, 156, 2, 43, 61, 91, 87, 137, 33, 0, 241])), SecretKey(Scalar([175, 187, 192, 190, 116, 184, 99, 231, 84, 222, 114, 44, 250, 148, 174, 158, 81, 43, 132, 99, 70, 30, 22, 17, 95, 238, 42, 132, 95, 159, 206, 0])));
/// AZX: GDAZX22OAWFGAIMQCIKS24Q7IV34HY2CBDWEXP4N4HKUFU4LQYPKQF6D
static immutable AZX = KeyPair(PublicKey(Point([193, 155, 235, 78, 5, 138, 96, 33, 144, 18, 21, 45, 114, 31, 69, 119, 195, 227, 66, 8, 236, 75, 191, 141, 225, 213, 66, 211, 139, 134, 30, 168])), SecretKey(Scalar([155, 151, 33, 177, 118, 136, 166, 111, 10, 68, 20, 71, 161, 179, 175, 192, 198, 75, 55, 132, 26, 83, 225, 31, 240, 181, 146, 223, 60, 163, 211, 9])));
/// AZY: GDAZY22VGG66CVA5KOZOWYQVEW3MH52WEKG3MLS3ZCB6BEMM7FWVO6JJ
static immutable AZY = KeyPair(PublicKey(Point([193, 156, 107, 85, 49, 189, 225, 84, 29, 83, 178, 235, 98, 21, 37, 182, 195, 247, 86, 34, 141, 182, 46, 91, 200, 131, 224, 145, 140, 249, 109, 87])), SecretKey(Scalar([194, 245, 117, 76, 81, 225, 22, 57, 6, 206, 125, 3, 243, 190, 251, 43, 111, 163, 79, 163, 50, 170, 80, 64, 36, 4, 204, 182, 135, 246, 184, 1])));
/// AZZ: GDAZZ2224RWM56WYBYWFH674YCG6WPT5HXX2CR7CJ42TUDG6RLHQH66J
static immutable AZZ = KeyPair(PublicKey(Point([193, 156, 235, 90, 228, 108, 206, 250, 216, 14, 44, 83, 251, 252, 192, 141, 235, 62, 125, 61, 239, 161, 71, 226, 79, 53, 58, 12, 222, 138, 207, 3])), SecretKey(Scalar([25, 115, 222, 75, 37, 76, 156, 1, 245, 176, 62, 200, 183, 61, 34, 138, 95, 5, 236, 102, 148, 175, 36, 179, 12, 202, 68, 156, 205, 51, 218, 3])));

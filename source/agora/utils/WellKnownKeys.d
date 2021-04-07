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

    Address: genesis1xrxydyju2h8l3sfytnwd3l8j4gj4jsa0wj4pykt37yyggtl686ugyrhdg2p

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

    Address: commons1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskxywrcal

*******************************************************************************/

static immutable CommonsBudget = KeyPair(
    PublicKey(Point([196, 230, 49, 218, 254, 154, 91, 30, 189, 156, 0, 136, 20, 131, 92, 50, 176, 178, 181, 114, 102, 113, 108, 189, 247, 243, 126, 102, 81, 132, 33, 99])),
    SecretKey(Scalar([177, 62, 40, 215, 115, 236, 122, 8, 22, 109, 42, 57, 44, 73, 121, 175, 60, 1, 135, 69, 17, 1, 104, 238, 0, 153, 89, 28, 249, 67, 42, 7])));


/*******************************************************************************

    Key pairs used for Enrollments in the genesis block

    Note that despite mining for a few days, NODE0, NODE1, NODE8, NODE9 were
    not found.

*******************************************************************************/

/// NODE2("node2"): node21xrdwry6fpk7a57k4gwyj3mwnf59w808nygtuxsgdrpmv4p7ua2hqx277esm
static immutable NODE2 = KeyPair(
    PublicKey(Point([218, 225, 147, 73, 13, 189, 218, 122, 213, 67, 137, 40, 237, 211, 77, 10, 227, 188, 243, 34, 23, 195, 65, 13, 24, 118, 202, 135, 220, 234, 174, 3])),
    SecretKey(Scalar([235, 179, 46, 185, 245, 191, 31, 208, 161, 209, 24, 204, 112, 33, 42, 108, 209, 64, 61, 44, 197, 122, 48, 125, 200, 139, 49, 146, 185, 206, 227, 13])));

/// NODE3("node3"): node31xrdwrymw40ae7kdumk5uf24rf7wj6kxeem0t3mh9yclz6j46rnen6zwz30l
static immutable NODE3 = KeyPair(
    PublicKey(Point([218, 225, 147, 110, 171, 251, 159, 89, 188, 221, 169, 196, 170, 163, 79, 157, 45, 88, 217, 206, 222, 184, 238, 229, 38, 62, 45, 74, 186, 28, 243, 61])),
    SecretKey(Scalar([19, 34, 116, 81, 73, 134, 255, 118, 5, 93, 182, 15, 92, 106, 229, 22, 144, 172, 196, 111, 11, 226, 96, 190, 48, 207, 14, 79, 198, 249, 63, 11])));

/// NODE4("node4"): node41xrdwryuhc2tw2j97wqe3ahh37qnjya59n5etz88n9fvwyyt9jyvrvmr7sj6
static immutable NODE4 = KeyPair(
    PublicKey(Point([218, 225, 147, 151, 194, 150, 229, 72, 190, 112, 51, 30, 222, 241, 240, 39, 34, 118, 133, 157, 50, 177, 28, 243, 42, 88, 226, 17, 101, 145, 24, 54])),
    SecretKey(Scalar([168, 154, 0, 25, 100, 201, 78, 145, 43, 136, 103, 92, 74, 231, 144, 74, 215, 226, 131, 164, 151, 41, 164, 254, 231, 212, 216, 201, 57, 72, 183, 13])));

/// NODE5("node5"): node51xrdwryayr9r3nacx26vwe6ymy2kl7zp7dc03q5h6zk65vnu6mtkkz7lupme
static immutable NODE5 = KeyPair(
    PublicKey(Point([218, 225, 147, 164, 25, 71, 25, 247, 6, 86, 152, 236, 232, 155, 34, 173, 255, 8, 62, 110, 31, 16, 82, 250, 21, 181, 70, 79, 154, 218, 237, 97])),
    SecretKey(Scalar([95, 61, 156, 216, 72, 217, 131, 208, 146, 17, 251, 178, 120, 62, 198, 104, 3, 40, 210, 10, 244, 28, 62, 198, 115, 172, 247, 247, 69, 68, 249, 14])));

/// NODE6("node6"): node61xrdwry7vltf9mrzf62qgpdh282grqn9nlnvhzp0yt8y0y9zedmgh69z4je9
static immutable NODE6 = KeyPair(
    PublicKey(Point([218, 225, 147, 204, 250, 210, 93, 140, 73, 210, 128, 128, 182, 234, 58, 144, 48, 76, 179, 252, 217, 113, 5, 228, 89, 200, 242, 20, 89, 110, 209, 125])),
    SecretKey(Scalar([153, 5, 199, 249, 62, 121, 232, 14, 54, 80, 152, 14, 196, 96, 3, 104, 145, 249, 124, 15, 228, 151, 47, 94, 243, 163, 246, 116, 178, 187, 146, 15])));

/// NODE7("node7"): node71xrdwryl0ajdd86c45w4zrjf8spmrt7u4l7s5jy64ac3dc78x2ucd7lcuaz7
static immutable NODE7 = KeyPair(
    PublicKey(Point([218, 225, 147, 239, 236, 154, 211, 235, 21, 163, 170, 33, 201, 39, 128, 118, 53, 251, 149, 255, 161, 73, 19, 85, 238, 34, 220, 120, 230, 87, 48, 223])),
    SecretKey(Scalar([179, 140, 94, 203, 162, 206, 19, 164, 103, 79, 120, 70, 54, 75, 95, 43, 254, 78, 142, 180, 48, 94, 207, 53, 145, 159, 181, 214, 137, 231, 240, 11])));

/*******************************************************************************

    All well-known keypairs

    The pattern is as follow:
    Keys are in the range `[a,z]`, `[aa,zz]` and `[aaa,zzz]`, for a total of
    1,377 keys (26 + 26 * 26 * 2 - 1), as we needed more than 1,000 keys.
    Keys have been mined to be easily recognizable in logs, as such, their
    public keys starts with `GD`, followed by their name, followed by `22`.
    For example, `a` is `gda1...` and `abc` is `gdabc1...`.

*******************************************************************************/

/// A("gda"): gda1xrq66nug6wnen9sp5cm7xhfw03yea8e9x63ggay3v5dhe6d9jerqzvfwms9
static immutable A = KeyPair(PublicKey(Point([193, 173, 79, 136, 211, 167, 153, 150, 1, 166, 55, 227, 93, 46, 124, 73, 158, 159, 37, 54, 162, 132, 116, 145, 101, 27, 124, 233, 165, 150, 70, 1])), SecretKey(Scalar([248, 130, 93, 62, 53, 179, 173, 120, 11, 152, 198, 207, 234, 88, 97, 195, 57, 167, 194, 56, 223, 70, 182, 117, 202, 185, 121, 12, 224, 103, 2, 8])));
/// B("gdb"): gdb1xrp66va5qe84kyfhywhxz9luy7glpxu99n30cuv3mu0vkhcswuzajnk2hfe
static immutable B = KeyPair(PublicKey(Point([195, 173, 51, 180, 6, 79, 91, 17, 55, 35, 174, 97, 23, 252, 39, 145, 240, 155, 133, 44, 226, 252, 113, 145, 223, 30, 203, 95, 16, 119, 5, 217])), SecretKey(Scalar([168, 34, 98, 92, 201, 211, 165, 249, 132, 230, 55, 248, 127, 234, 22, 197, 2, 115, 70, 89, 129, 95, 96, 118, 127, 90, 154, 140, 93, 217, 231, 14])));
/// C("gdc"): gdc1xrz66g5ajvrw0jpy3pyfc05hh65v3xvc79vae36fnzxkz4w4hzswvlcx7ya
static immutable C = KeyPair(PublicKey(Point([197, 173, 34, 157, 147, 6, 231, 200, 36, 136, 72, 156, 62, 151, 190, 168, 200, 153, 152, 241, 89, 220, 199, 73, 152, 141, 97, 85, 213, 184, 160, 230])), SecretKey(Scalar([243, 11, 110, 225, 45, 227, 123, 105, 127, 53, 87, 47, 140, 17, 52, 84, 248, 71, 176, 64, 122, 33, 176, 208, 226, 131, 174, 79, 158, 77, 34, 0])));
/// D("gdd"): gdd1xrr66q4rthn4qvhhsl4y5hptqm366pgarqpk26wfzh6d38wg076tsa3njrv
static immutable D = KeyPair(PublicKey(Point([199, 173, 2, 163, 93, 231, 80, 50, 247, 135, 234, 74, 92, 43, 6, 227, 173, 5, 29, 24, 3, 101, 105, 201, 21, 244, 216, 157, 200, 127, 180, 184])), SecretKey(Scalar([26, 98, 99, 65, 67, 11, 157, 171, 115, 219, 109, 42, 224, 50, 247, 91, 222, 203, 36, 253, 130, 74, 214, 240, 42, 215, 148, 120, 203, 200, 84, 1])));
/// E("gde"): gde1xry663vx4m05wmnq58n3avgxpsn82ds8m8yxtgqa5n8865yazurwx93ckrd
static immutable E = KeyPair(PublicKey(Point([201, 173, 69, 134, 174, 223, 71, 110, 96, 161, 231, 30, 177, 6, 12, 38, 117, 54, 7, 217, 200, 101, 160, 29, 164, 206, 125, 80, 157, 23, 6, 227])), SecretKey(Scalar([13, 114, 140, 50, 17, 204, 232, 14, 14, 189, 212, 52, 171, 180, 85, 38, 138, 241, 1, 25, 236, 35, 2, 227, 148, 232, 198, 75, 106, 226, 96, 10])));
/// F("gdf"): gdf1xr966mj6xx2m0d58d6qcnhn5kf3mcg2pczfavrg3xtz37rrs74tmkvf34mu
static immutable F = KeyPair(PublicKey(Point([203, 173, 110, 90, 49, 149, 183, 182, 135, 110, 129, 137, 222, 116, 178, 99, 188, 33, 65, 192, 147, 214, 13, 17, 50, 197, 31, 12, 112, 245, 87, 187])), SecretKey(Scalar([89, 70, 177, 165, 49, 103, 182, 197, 89, 110, 194, 0, 80, 89, 107, 237, 192, 20, 162, 239, 236, 207, 94, 109, 44, 72, 196, 68, 12, 65, 52, 12])));
/// G("gdg"): gdg1xrx66ezhd6uzx2s0plpgtwwmwmv4tfzvgp5sswqcg8z6m79s05pac4htyxu
static immutable G = KeyPair(PublicKey(Point([205, 173, 100, 87, 110, 184, 35, 42, 15, 15, 194, 133, 185, 219, 118, 217, 85, 164, 76, 64, 105, 8, 56, 24, 65, 197, 173, 248, 176, 125, 3, 220])), SecretKey(Scalar([207, 43, 226, 9, 153, 203, 79, 202, 114, 171, 200, 243, 216, 3, 77, 215, 9, 196, 187, 40, 113, 232, 146, 21, 132, 31, 122, 137, 214, 24, 213, 3])));
/// H("gdh"): gdh1xr866fhqxqw8v9pqw0aph5lw7w0dqkytr4akukyjnr47t324shah2vteg6m
static immutable H = KeyPair(PublicKey(Point([207, 173, 38, 224, 48, 28, 118, 20, 32, 115, 250, 27, 211, 238, 243, 158, 208, 88, 139, 29, 123, 110, 88, 146, 152, 235, 229, 197, 85, 133, 251, 117])), SecretKey(Scalar([248, 248, 39, 28, 141, 206, 202, 229, 37, 130, 129, 98, 164, 76, 26, 228, 20, 54, 210, 120, 59, 77, 144, 106, 53, 198, 109, 124, 62, 147, 46, 11])));
/// I("gdi"): gdi1xrg66j9mgk20kflzdzrq4p3k4gw8tg6vk3pa3fgm3twsagyaxa8lujwgz4u
static immutable I = KeyPair(PublicKey(Point([209, 173, 72, 187, 69, 148, 251, 39, 226, 104, 134, 10, 134, 54, 170, 28, 117, 163, 76, 180, 67, 216, 165, 27, 138, 221, 14, 160, 157, 55, 79, 254])), SecretKey(Scalar([18, 75, 252, 239, 118, 243, 225, 132, 130, 143, 161, 221, 127, 80, 250, 78, 188, 134, 215, 173, 182, 160, 139, 242, 230, 188, 227, 169, 195, 233, 10, 11])));
/// J("gdj"): gdj1xrf66wz8muvm843gqq85f4fpdywwgqf8uc43583r0mqclvm2vk8tqca7na9
static immutable J = KeyPair(PublicKey(Point([211, 173, 56, 71, 223, 25, 179, 214, 40, 0, 15, 68, 213, 33, 105, 28, 228, 1, 39, 230, 43, 26, 30, 35, 126, 193, 143, 179, 106, 101, 142, 176])), SecretKey(Scalar([122, 195, 171, 183, 26, 66, 158, 44, 79, 58, 113, 158, 0, 144, 125, 72, 3, 70, 32, 90, 32, 217, 247, 204, 28, 35, 163, 242, 71, 188, 94, 0])));
/// K("gdk"): gdk1xr2669up35w5chhjd6zf94s3mtqvzucyaznh2lahxlgq2qqlhw5azhu229k
static immutable K = KeyPair(PublicKey(Point([213, 173, 23, 129, 141, 29, 76, 94, 242, 110, 132, 146, 214, 17, 218, 192, 193, 115, 4, 232, 167, 117, 127, 183, 55, 208, 5, 0, 31, 187, 169, 209])), SecretKey(Scalar([82, 95, 232, 108, 253, 170, 104, 79, 163, 223, 30, 7, 242, 234, 198, 26, 133, 70, 51, 95, 91, 78, 150, 199, 172, 207, 35, 153, 107, 209, 127, 3])));
/// L("gdl"): gdl1xrt66sh0zk4wny2q7a554uj420uy74cz46lry6tnnzns30d5fh36ua0wlz9
static immutable L = KeyPair(PublicKey(Point([215, 173, 66, 239, 21, 170, 233, 145, 64, 247, 105, 74, 242, 85, 83, 248, 79, 87, 2, 174, 190, 50, 105, 115, 152, 167, 8, 189, 180, 77, 227, 174])), SecretKey(Scalar([220, 250, 250, 95, 140, 146, 255, 239, 141, 132, 253, 255, 85, 47, 207, 56, 39, 231, 53, 228, 25, 157, 202, 12, 218, 19, 134, 37, 211, 168, 68, 0])));
/// M("gdm"): gdm1xrv66ucx6rq5ptk9jcs9rdwmdzg0678ewpf53uhxexyv8uw04h3lvjsuts3
static immutable M = KeyPair(PublicKey(Point([217, 173, 115, 6, 208, 193, 64, 174, 197, 150, 32, 81, 181, 219, 104, 144, 253, 120, 249, 112, 83, 72, 242, 230, 201, 136, 195, 241, 207, 173, 227, 246])), SecretKey(Scalar([150, 87, 196, 25, 58, 213, 9, 156, 2, 54, 95, 7, 83, 52, 116, 216, 191, 194, 76, 111, 225, 128, 5, 31, 66, 38, 210, 112, 141, 226, 209, 3])));
/// N("gdn"): gdn1xrd66n6emf07npwrr7nepejjjj9tt7r65elaqepjnj8p4amkvhgykg5gg22
static immutable N = KeyPair(PublicKey(Point([219, 173, 79, 89, 218, 95, 233, 133, 195, 31, 167, 144, 230, 82, 148, 138, 181, 248, 122, 166, 127, 208, 100, 50, 156, 142, 26, 247, 118, 101, 208, 75])), SecretKey(Scalar([149, 154, 218, 220, 182, 62, 31, 74, 137, 97, 155, 81, 14, 123, 233, 173, 30, 174, 111, 241, 14, 122, 139, 94, 38, 206, 71, 188, 124, 125, 175, 6])));
/// O("gdo"): gdo1xrw66w303s5x05ej9uu6djc54kue29j72kah22xqqcrtqj57ztwm52ana02
static immutable O = KeyPair(PublicKey(Point([221, 173, 58, 47, 140, 40, 103, 211, 50, 47, 57, 166, 203, 20, 173, 185, 149, 22, 94, 85, 187, 117, 40, 192, 6, 6, 176, 74, 158, 18, 221, 186])), SecretKey(Scalar([227, 61, 149, 153, 21, 74, 157, 31, 210, 209, 210, 123, 75, 181, 21, 42, 112, 221, 254, 70, 200, 147, 52, 236, 63, 198, 151, 224, 85, 54, 128, 13])));
/// P("gdp"): gdp1xr0666zjs727a8eg7uza0gma0xcwqm7px4sez2n2gng7u2sk3nh8scs2wy7
static immutable P = KeyPair(PublicKey(Point([223, 173, 104, 82, 135, 149, 238, 159, 40, 247, 5, 215, 163, 125, 121, 176, 224, 111, 193, 53, 97, 145, 42, 106, 68, 209, 238, 42, 22, 140, 238, 120])), SecretKey(Scalar([134, 44, 171, 231, 87, 220, 104, 196, 249, 46, 80, 209, 75, 115, 33, 175, 9, 128, 192, 89, 76, 113, 240, 91, 163, 164, 213, 82, 176, 39, 92, 1])));
/// Q("gdq"): gdq1xrs66mrtuhf0kefkratyqrhlq207x4c404umlyc3ttm0m7xe02lys7kjwvk
static immutable Q = KeyPair(PublicKey(Point([225, 173, 108, 107, 229, 210, 251, 101, 54, 31, 86, 64, 14, 255, 2, 159, 227, 87, 21, 125, 121, 191, 147, 17, 90, 246, 253, 248, 217, 122, 190, 72])), SecretKey(Scalar([254, 30, 199, 22, 148, 223, 84, 170, 24, 90, 195, 48, 86, 83, 20, 103, 141, 221, 134, 20, 207, 163, 141, 40, 66, 124, 71, 182, 249, 144, 220, 8])));
/// R("gdr"): gdr1xr366c8cee3ktj7t5ce95wvgk6v3g75untkqskgwwc460s8p3876gnwdd3d
static immutable R = KeyPair(PublicKey(Point([227, 173, 96, 248, 206, 99, 101, 203, 203, 166, 50, 90, 57, 136, 182, 153, 20, 122, 156, 154, 236, 8, 89, 14, 118, 43, 167, 192, 225, 137, 253, 164])), SecretKey(Scalar([148, 127, 181, 90, 69, 235, 85, 97, 170, 50, 132, 130, 112, 15, 55, 12, 16, 17, 149, 152, 33, 192, 238, 37, 6, 72, 169, 20, 12, 119, 121, 12])));
/// S("gds"): gds1xrj6627k9gynderjtggdzrgdrl3fjpaz9t6v8cs0uq7ujjsvpjajsvlexqm
static immutable S = KeyPair(PublicKey(Point([229, 173, 43, 214, 42, 9, 54, 228, 114, 90, 16, 209, 13, 13, 31, 226, 153, 7, 162, 42, 244, 195, 226, 15, 224, 61, 201, 74, 12, 12, 187, 40])), SecretKey(Scalar([140, 237, 130, 117, 92, 99, 20, 96, 166, 222, 91, 32, 11, 137, 166, 255, 207, 180, 53, 27, 153, 240, 239, 204, 154, 158, 176, 46, 3, 110, 170, 4])));
/// T("gdt"): gdt1xrn66tgf25ua5j4d3nvnzzdv9ea7pl8qt6qnnqf63yj4f5untf6zvt3qfwk
static immutable T = KeyPair(PublicKey(Point([231, 173, 45, 9, 85, 57, 218, 74, 173, 140, 217, 49, 9, 172, 46, 123, 224, 252, 224, 94, 129, 57, 129, 58, 137, 37, 84, 211, 147, 90, 116, 38])), SecretKey(Scalar([147, 225, 221, 32, 159, 148, 208, 131, 130, 82, 96, 229, 22, 23, 190, 229, 204, 149, 190, 234, 164, 132, 68, 90, 15, 168, 248, 168, 190, 11, 130, 4])));
/// U("gdu"): gdu1xr566el25jw2ckg6cgcwdk006p2tn236xs73tf07japfmg0nvjrfg9puhq9
static immutable U = KeyPair(PublicKey(Point([233, 173, 103, 234, 164, 156, 172, 89, 26, 194, 48, 230, 217, 239, 208, 84, 185, 170, 58, 52, 61, 21, 165, 254, 151, 66, 157, 161, 243, 100, 134, 148])), SecretKey(Scalar([237, 121, 76, 245, 142, 137, 53, 251, 237, 107, 162, 168, 145, 48, 68, 155, 156, 154, 134, 135, 30, 39, 2, 221, 224, 26, 28, 31, 113, 133, 221, 4])));
/// V("gdv"): gdv1xr466wfz49prnagq60jhegdrpvda9m9sawxj6c9felghvt6l4cnmyd7vy4v
static immutable V = KeyPair(PublicKey(Point([235, 173, 57, 34, 169, 66, 57, 245, 0, 211, 229, 124, 161, 163, 11, 27, 210, 236, 176, 235, 141, 45, 96, 169, 207, 209, 118, 47, 95, 174, 39, 178])), SecretKey(Scalar([46, 239, 56, 215, 137, 230, 190, 200, 25, 171, 66, 239, 195, 221, 220, 206, 154, 36, 117, 244, 54, 89, 188, 214, 53, 8, 214, 182, 213, 116, 68, 14])));
/// W("gdw"): gdw1xrk66zjkt22x2pjkhufvgquaransxh790gt99upac8g73939rkskwvdhrqa
static immutable W = KeyPair(PublicKey(Point([237, 173, 10, 86, 90, 148, 101, 6, 86, 191, 18, 196, 3, 157, 31, 103, 3, 95, 197, 122, 22, 82, 240, 61, 193, 209, 232, 150, 37, 29, 161, 103])), SecretKey(Scalar([75, 33, 177, 253, 57, 212, 242, 195, 118, 127, 12, 34, 58, 21, 105, 16, 7, 100, 71, 248, 52, 202, 162, 34, 8, 214, 230, 111, 53, 109, 40, 3])));
/// X("gdx"): gdx1xrh668tqygx4f5y3cq5n7vxe4l59yze5q3uz32ds77wcy3q63d3m6r7msfk
static immutable X = KeyPair(PublicKey(Point([239, 173, 29, 96, 34, 13, 84, 208, 145, 192, 41, 63, 48, 217, 175, 232, 82, 11, 52, 4, 120, 40, 169, 176, 247, 157, 130, 68, 26, 139, 99, 189])), SecretKey(Scalar([196, 148, 229, 135, 94, 211, 255, 61, 173, 75, 137, 100, 178, 0, 17, 10, 126, 103, 82, 41, 214, 146, 125, 62, 61, 248, 36, 114, 253, 170, 126, 15])));
/// Y("gdy"): gdy1xrc66nh99n302gpupgae5rvgxhr3awhjykpwdh7uvn0lz8x6zp0awn76ss2
static immutable Y = KeyPair(PublicKey(Point([241, 173, 78, 229, 44, 226, 245, 32, 60, 10, 59, 154, 13, 136, 53, 199, 30, 186, 242, 37, 130, 230, 223, 220, 100, 223, 241, 28, 218, 16, 95, 215])), SecretKey(Scalar([117, 6, 204, 94, 203, 77, 86, 17, 108, 233, 11, 128, 41, 112, 121, 112, 75, 253, 243, 87, 43, 201, 151, 118, 44, 189, 24, 50, 220, 4, 240, 9])));
/// Z("gdz"): gdz1xre669yhuuluulwkw738g36alcm6nzdxqxyuwq4v4595v0upt290k5t8pq9
static immutable Z = KeyPair(PublicKey(Point([243, 173, 20, 151, 231, 63, 206, 125, 214, 119, 162, 116, 71, 93, 254, 55, 169, 137, 166, 1, 137, 199, 2, 172, 173, 11, 70, 63, 129, 90, 138, 251])), SecretKey(Scalar([43, 18, 140, 52, 88, 127, 186, 77, 203, 101, 181, 136, 31, 45, 153, 133, 25, 57, 32, 95, 210, 217, 241, 42, 205, 202, 134, 177, 15, 141, 133, 15])));
/// AA("gdaa"): gdaa1xrqq66zj3jfrkh00tmkw9rqpjs2gcnp3nm8snd0tzar7ln0n6z8cyjy6wy6
static immutable AA = KeyPair(PublicKey(Point([192, 13, 104, 82, 140, 146, 59, 93, 239, 94, 236, 226, 140, 1, 148, 20, 140, 76, 49, 158, 207, 9, 181, 235, 23, 71, 239, 205, 243, 208, 143, 130])), SecretKey(Scalar([127, 77, 167, 165, 155, 92, 128, 200, 70, 105, 144, 239, 223, 24, 208, 74, 129, 74, 105, 55, 194, 66, 35, 243, 17, 3, 240, 129, 72, 254, 84, 9])));
/// AB("gdab"): gdab1xrqp665e9yxlmhhh9a9dqslndvy6t867dspg07txm8gpe0wnaevwxhfnar0
static immutable AB = KeyPair(PublicKey(Point([192, 29, 106, 153, 41, 13, 253, 222, 247, 47, 74, 208, 67, 243, 107, 9, 165, 159, 94, 108, 2, 135, 249, 102, 217, 208, 28, 189, 211, 238, 88, 227])), SecretKey(Scalar([86, 33, 111, 70, 6, 166, 234, 3, 49, 134, 128, 11, 120, 61, 49, 114, 148, 5, 8, 254, 254, 166, 64, 40, 67, 166, 125, 193, 20, 11, 8, 7])));
/// AC("gdac"): gdac1xrqz6605ze7gqq032ur6jtpxy4gxc0fcrh0cvln0a4v4t8msltzz68za2qm
static immutable AC = KeyPair(PublicKey(Point([192, 45, 105, 244, 22, 124, 128, 1, 241, 87, 7, 169, 44, 38, 37, 80, 108, 61, 56, 29, 223, 134, 126, 111, 237, 89, 85, 159, 112, 250, 196, 45])), SecretKey(Scalar([206, 72, 93, 93, 242, 240, 32, 242, 26, 135, 234, 230, 151, 25, 255, 21, 208, 152, 243, 23, 231, 54, 146, 56, 3, 2, 235, 68, 232, 235, 33, 4])));
/// AD("gdad"): gdad1xrqr66hx3yf2p64s2jq9dnajg9mcvg6y8u5g793uyspp7e3l8l8guu9q4vg
static immutable AD = KeyPair(PublicKey(Point([192, 61, 106, 230, 137, 18, 160, 234, 176, 84, 128, 86, 207, 178, 65, 119, 134, 35, 68, 63, 40, 143, 22, 60, 36, 2, 31, 102, 63, 63, 206, 142])), SecretKey(Scalar([114, 255, 51, 99, 194, 207, 21, 2, 230, 15, 230, 96, 221, 133, 126, 248, 254, 252, 224, 11, 108, 116, 91, 48, 170, 164, 141, 144, 242, 195, 94, 6])));
/// AE("gdae"): gdae1xrqy66f6jnvxcm668aqyvpdehrznuccenny24dmps6w0wukyg7a62qrrvxj
static immutable AE = KeyPair(PublicKey(Point([192, 77, 105, 58, 148, 216, 108, 111, 90, 63, 64, 70, 5, 185, 184, 197, 62, 99, 25, 156, 200, 170, 183, 97, 134, 156, 247, 114, 196, 71, 187, 165])), SecretKey(Scalar([181, 23, 64, 77, 104, 230, 72, 97, 241, 218, 196, 44, 154, 20, 77, 15, 151, 228, 31, 90, 224, 48, 194, 134, 26, 157, 226, 250, 205, 81, 48, 10])));
/// AF("gdaf"): gdaf1xrq966cm07x5zacwxwt2s57rrmx8yq67z6hl47frjpqlcptrj47cupa5ts4
static immutable AF = KeyPair(PublicKey(Point([192, 93, 107, 27, 127, 141, 65, 119, 14, 51, 150, 168, 83, 195, 30, 204, 114, 3, 94, 22, 175, 250, 249, 35, 144, 65, 252, 5, 99, 149, 125, 142])), SecretKey(Scalar([35, 60, 224, 81, 126, 23, 200, 157, 248, 253, 155, 126, 17, 96, 28, 26, 105, 138, 184, 109, 128, 170, 206, 55, 147, 70, 8, 0, 69, 223, 111, 4])));
/// AG("gdag"): gdag1xrqx66scdf5j8na5wevga03jn3th6kugnfxhgelz69y6fc5hz28sqllslkf
static immutable AG = KeyPair(PublicKey(Point([192, 109, 106, 24, 106, 105, 35, 207, 180, 118, 88, 142, 190, 50, 156, 87, 125, 91, 136, 154, 77, 116, 103, 226, 209, 73, 164, 226, 151, 18, 143, 0])), SecretKey(Scalar([194, 7, 234, 134, 242, 241, 150, 218, 27, 81, 73, 54, 120, 56, 116, 38, 174, 210, 103, 8, 120, 124, 251, 27, 98, 77, 133, 67, 106, 121, 216, 10])));
/// AH("gdah"): gdah1xrq866fcrmpequ23qsd4te2936m0d6gtsuuef7rml3j086w887n7g7x30ta
static immutable AH = KeyPair(PublicKey(Point([192, 125, 105, 56, 30, 195, 144, 113, 81, 4, 27, 85, 229, 69, 142, 182, 246, 233, 11, 135, 57, 148, 248, 123, 252, 100, 243, 233, 199, 63, 167, 228])), SecretKey(Scalar([54, 151, 128, 44, 12, 110, 191, 195, 236, 151, 182, 191, 159, 104, 85, 148, 18, 46, 143, 227, 83, 88, 74, 220, 36, 153, 63, 181, 131, 236, 3, 15])));
/// AI("gdai"): gdai1xrqg66x3lt57f67sv9kaaqgptc3ulueg3mffa9umphc08786dtcnurgpn56
static immutable AI = KeyPair(PublicKey(Point([192, 141, 104, 209, 250, 233, 228, 235, 208, 97, 109, 222, 129, 1, 94, 35, 207, 243, 40, 142, 210, 158, 151, 155, 13, 240, 243, 248, 250, 106, 241, 62])), SecretKey(Scalar([117, 17, 217, 67, 181, 111, 17, 99, 6, 237, 82, 247, 222, 146, 148, 234, 149, 75, 192, 17, 236, 250, 139, 129, 48, 250, 234, 151, 196, 254, 52, 5])));
/// AJ("gdaj"): gdaj1xrqf6636z0sjkhk4qtvm92460r9g9j5mze57ev4cffhlz0x8028n7r9rkcn
static immutable AJ = KeyPair(PublicKey(Point([192, 157, 106, 58, 19, 225, 43, 94, 213, 2, 217, 178, 170, 186, 120, 202, 130, 202, 155, 22, 105, 236, 178, 184, 74, 111, 241, 60, 199, 122, 143, 63])), SecretKey(Scalar([87, 95, 23, 30, 87, 84, 246, 45, 150, 181, 198, 253, 226, 28, 239, 107, 186, 67, 43, 145, 31, 24, 212, 25, 233, 227, 151, 36, 159, 74, 249, 12])));
/// AK("gdak"): gdak1xrq266y4440f7ul6n38pa6y7vyp0d0cy9ae3vmwgudr7stg6vavsqntmyma
static immutable AK = KeyPair(PublicKey(Point([192, 173, 104, 149, 173, 94, 159, 115, 250, 156, 78, 30, 232, 158, 97, 2, 246, 191, 4, 47, 115, 22, 109, 200, 227, 71, 232, 45, 26, 103, 89, 0])), SecretKey(Scalar([51, 36, 73, 175, 73, 36, 79, 152, 17, 207, 124, 139, 255, 27, 38, 113, 143, 131, 190, 66, 167, 74, 61, 61, 78, 254, 189, 210, 107, 167, 160, 11])));
/// AL("gdal"): gdal1xrqt6693kth2f0p9lyaxe2tlcx5gkkax9prtuaq3n8flfay58r76wdcljv5
static immutable AL = KeyPair(PublicKey(Point([192, 189, 104, 177, 178, 238, 164, 188, 37, 249, 58, 108, 169, 127, 193, 168, 139, 91, 166, 40, 70, 190, 116, 17, 153, 211, 244, 244, 148, 56, 253, 167])), SecretKey(Scalar([222, 28, 212, 5, 26, 171, 95, 144, 60, 81, 17, 113, 167, 33, 136, 20, 211, 82, 230, 235, 139, 169, 252, 151, 57, 212, 194, 174, 210, 90, 190, 12])));
/// AM("gdam"): gdam1xrqv66he892js4afpks9jpywy3a5zpppxwzrfx4cvk5xjy6s9jknvfa2jhv
static immutable AM = KeyPair(PublicKey(Point([192, 205, 106, 249, 57, 85, 40, 87, 169, 13, 160, 89, 4, 142, 36, 123, 65, 4, 33, 51, 132, 52, 154, 184, 101, 168, 105, 19, 80, 44, 173, 54])), SecretKey(Scalar([118, 131, 129, 118, 32, 217, 240, 113, 138, 226, 25, 107, 189, 187, 68, 119, 81, 136, 126, 94, 209, 57, 42, 136, 162, 36, 149, 248, 217, 215, 94, 13])));
/// AN("gdan"): gdan1xrqd662mmh8uy95gucguzd0nj4lpcw00l8py3g02yly9zgzkhxy8sv3s3lf
static immutable AN = KeyPair(PublicKey(Point([192, 221, 105, 91, 221, 207, 194, 22, 136, 230, 17, 193, 53, 243, 149, 126, 28, 57, 239, 249, 194, 72, 161, 234, 39, 200, 81, 32, 86, 185, 136, 120])), SecretKey(Scalar([18, 165, 182, 149, 79, 24, 9, 115, 244, 81, 74, 226, 59, 201, 252, 96, 237, 172, 61, 114, 173, 26, 142, 228, 55, 45, 35, 64, 11, 250, 157, 7])));
/// AO("gdao"): gdao1xrqw66lycrhpxg4jsg5aggy8mckfjh4dq3s3mrhdf9acej4yvlz52dxfww8
static immutable AO = KeyPair(PublicKey(Point([192, 237, 107, 228, 192, 238, 19, 34, 178, 130, 41, 212, 32, 135, 222, 44, 153, 94, 173, 4, 97, 29, 142, 237, 73, 123, 140, 202, 164, 103, 197, 69])), SecretKey(Scalar([121, 47, 75, 206, 188, 242, 37, 157, 148, 186, 68, 2, 189, 81, 177, 43, 192, 60, 173, 170, 59, 95, 73, 218, 109, 253, 209, 242, 187, 72, 26, 1])));
/// AP("gdap"): gdap1xrq0668edxhj200m7elp8dgsezcnwmtxcpcfhwvef97l5hvq96qkcth7was
static immutable AP = KeyPair(PublicKey(Point([192, 253, 104, 249, 105, 175, 37, 61, 251, 246, 126, 19, 181, 16, 200, 177, 55, 109, 102, 192, 112, 155, 185, 153, 73, 125, 250, 93, 128, 46, 129, 108])), SecretKey(Scalar([28, 63, 252, 105, 169, 157, 3, 206, 136, 70, 28, 71, 25, 176, 235, 131, 197, 196, 137, 239, 74, 56, 127, 252, 168, 120, 176, 169, 188, 130, 4, 9])));
/// AQ("gdaq"): gdaq1xrqs66arwc2e4u5q3r424t5vsnmm2sa257qt2cnjw923akdruywkv2trs0t
static immutable AQ = KeyPair(PublicKey(Point([193, 13, 107, 163, 118, 21, 154, 242, 128, 136, 234, 170, 174, 140, 132, 247, 181, 67, 170, 167, 128, 181, 98, 114, 113, 85, 30, 217, 163, 225, 29, 102])), SecretKey(Scalar([100, 201, 202, 117, 179, 56, 253, 66, 56, 107, 175, 98, 28, 59, 65, 203, 248, 250, 44, 0, 147, 241, 189, 233, 82, 34, 253, 36, 225, 175, 127, 2])));
/// AR("gdar"): gdar1xrq3666q92x8euj23h2nh0p9tywgvc6ws843mmufnp5hc4saqn0xgkmqjl7
static immutable AR = KeyPair(PublicKey(Point([193, 29, 107, 64, 42, 140, 124, 242, 74, 141, 213, 59, 188, 37, 89, 28, 134, 99, 78, 129, 235, 29, 239, 137, 152, 105, 124, 86, 29, 4, 222, 100])), SecretKey(Scalar([87, 10, 166, 221, 39, 121, 128, 29, 109, 42, 43, 113, 85, 38, 236, 29, 68, 66, 42, 63, 59, 233, 54, 122, 115, 159, 208, 72, 11, 154, 229, 3])));
/// AS("gdas"): gdas1xrqj66veawha3j2shvrwc9ezpy9003cpt9vjmq2x3rz8xvx0xujeqvg6wxe
static immutable AS = KeyPair(PublicKey(Point([193, 45, 105, 153, 235, 175, 216, 201, 80, 187, 6, 236, 23, 34, 9, 10, 247, 199, 1, 89, 89, 45, 129, 70, 136, 196, 115, 48, 207, 55, 37, 144])), SecretKey(Scalar([102, 87, 18, 137, 119, 40, 41, 223, 122, 156, 124, 67, 213, 110, 101, 161, 16, 201, 28, 200, 73, 128, 104, 40, 2, 47, 198, 59, 175, 34, 72, 3])));
/// AT("gdat"): gdat1xrqn665vg99zl9a6kpj66v6fjujnq3qydy6zkp7ctygcqyynx7z76vr7g5v
static immutable AT = KeyPair(PublicKey(Point([193, 61, 106, 140, 65, 74, 47, 151, 186, 176, 101, 173, 51, 73, 151, 37, 48, 68, 4, 105, 52, 43, 7, 216, 89, 17, 128, 16, 147, 55, 133, 237])), SecretKey(Scalar([4, 52, 109, 180, 101, 248, 132, 142, 198, 239, 212, 148, 126, 212, 179, 94, 248, 85, 189, 90, 244, 216, 140, 107, 167, 132, 199, 154, 62, 232, 68, 6])));
/// AU("gdau"): gdau1xrq566w4ks8dy8ynwhdz9j928207jvsser86rzjp42wuf3jf30zruhsxk4e
static immutable AU = KeyPair(PublicKey(Point([193, 77, 105, 213, 180, 14, 210, 28, 147, 117, 218, 34, 200, 170, 58, 159, 233, 50, 16, 200, 207, 161, 138, 65, 170, 157, 196, 198, 73, 139, 196, 62])), SecretKey(Scalar([45, 223, 135, 89, 141, 250, 2, 182, 48, 54, 253, 207, 199, 84, 193, 84, 66, 230, 214, 144, 135, 190, 25, 162, 21, 81, 241, 252, 32, 59, 145, 7])));
/// AV("gdav"): gdav1xrq466p3zmcrzex6yu54g2yh9t6xjvzv8l9a8gvy97s6kl79u60h5nt2qdx
static immutable AV = KeyPair(PublicKey(Point([193, 93, 104, 49, 22, 240, 49, 100, 218, 39, 41, 84, 40, 151, 42, 244, 105, 48, 76, 63, 203, 211, 161, 132, 47, 161, 171, 127, 197, 230, 159, 122])), SecretKey(Scalar([183, 252, 226, 113, 243, 231, 214, 153, 36, 54, 103, 101, 167, 245, 170, 229, 231, 81, 108, 136, 213, 143, 55, 172, 179, 198, 193, 185, 231, 195, 121, 9])));
/// AW("gdaw"): gdaw1xrqk660d7uar45ey3dkynlux2cx59ymy8zqte697yhqsd0d93sfxc3gqhu0
static immutable AW = KeyPair(PublicKey(Point([193, 109, 105, 237, 247, 58, 58, 211, 36, 139, 108, 73, 255, 134, 86, 13, 66, 147, 100, 56, 128, 188, 232, 190, 37, 193, 6, 189, 165, 140, 18, 108])), SecretKey(Scalar([169, 192, 150, 82, 51, 243, 247, 230, 42, 135, 203, 249, 79, 205, 149, 231, 205, 152, 221, 79, 135, 241, 34, 212, 150, 53, 233, 66, 204, 141, 250, 14])));
/// AX("gdax"): gdax1xrqh66vymf98wazv7yyk55nad7ma86ncy2jtuy2re2s6y8a7ayuzuamu5ke
static immutable AX = KeyPair(PublicKey(Point([193, 125, 105, 132, 218, 74, 119, 116, 76, 241, 9, 106, 82, 125, 111, 183, 211, 234, 120, 34, 164, 190, 17, 67, 202, 161, 162, 31, 190, 233, 56, 46])), SecretKey(Scalar([60, 148, 136, 41, 110, 235, 124, 236, 235, 231, 197, 93, 46, 52, 68, 151, 193, 18, 19, 173, 176, 165, 39, 214, 56, 212, 76, 148, 39, 240, 189, 6])));
/// AY("gday"): gday1xrqc66uf9p69j72nk2cfhv49sehk3htccl0qkg82nce58qh5xy5fy4vdpaw
static immutable AY = KeyPair(PublicKey(Point([193, 141, 107, 137, 40, 116, 89, 121, 83, 178, 176, 155, 178, 165, 134, 111, 104, 221, 120, 199, 222, 11, 32, 234, 158, 51, 67, 130, 244, 49, 40, 146])), SecretKey(Scalar([60, 244, 237, 67, 23, 172, 91, 174, 102, 107, 43, 75, 16, 189, 241, 177, 58, 183, 89, 224, 121, 47, 164, 181, 3, 96, 238, 185, 161, 221, 60, 0])));
/// AZ("gdaz"): gdaz1xrqe66hvugxu4qlvv236vqrz7p9c0xah9wdp3rdp4ahukmmcq3fnuquhtwh
static immutable AZ = KeyPair(PublicKey(Point([193, 157, 106, 236, 226, 13, 202, 131, 236, 98, 163, 166, 0, 98, 240, 75, 135, 155, 183, 43, 154, 24, 141, 161, 175, 111, 203, 111, 120, 4, 83, 62])), SecretKey(Scalar([202, 130, 247, 1, 71, 18, 159, 248, 23, 182, 117, 150, 24, 12, 0, 221, 123, 160, 181, 191, 128, 41, 30, 96, 155, 244, 178, 61, 51, 26, 255, 3])));
/// BA("gdba"): gdba1xrpq66egdynxp639mtpjy4zram0xgdzdd3nqww5n8vxqw2my36agyf95ar0
static immutable BA = KeyPair(PublicKey(Point([194, 13, 107, 40, 105, 38, 96, 234, 37, 218, 195, 34, 84, 67, 238, 222, 100, 52, 77, 108, 102, 7, 58, 147, 59, 12, 7, 43, 100, 142, 186, 130])), SecretKey(Scalar([43, 59, 177, 67, 133, 27, 25, 86, 109, 163, 107, 36, 214, 77, 5, 158, 36, 237, 165, 168, 236, 134, 19, 62, 5, 15, 106, 255, 120, 63, 24, 4])));
/// BB("gdbb"): gdbb1xrpp66wua86h6hnypn4z6pxxt2sw3h85mg20rmu3d4vw6ry8kh6kkapwpk5
static immutable BB = KeyPair(PublicKey(Point([194, 29, 105, 220, 233, 245, 125, 94, 100, 12, 234, 45, 4, 198, 90, 160, 232, 220, 244, 218, 20, 241, 239, 145, 109, 88, 237, 12, 135, 181, 245, 107])), SecretKey(Scalar([47, 117, 171, 70, 44, 241, 194, 186, 77, 76, 238, 24, 92, 162, 217, 223, 193, 240, 167, 222, 10, 97, 247, 83, 78, 84, 188, 147, 52, 204, 50, 1])));
/// BC("gdbc"): gdbc1xrpz66kvy8p5cywqactccsa8nazsdjqpvzq70j77pg46y6aszr0t5479e0z
static immutable BC = KeyPair(PublicKey(Point([194, 45, 106, 204, 33, 195, 76, 17, 192, 238, 23, 140, 67, 167, 159, 69, 6, 200, 1, 96, 129, 231, 203, 222, 10, 43, 162, 107, 176, 16, 222, 186])), SecretKey(Scalar([22, 92, 109, 96, 41, 50, 20, 14, 222, 150, 198, 122, 246, 174, 69, 237, 122, 224, 97, 113, 23, 210, 195, 144, 220, 110, 141, 5, 167, 17, 18, 1])));
/// BD("gdbd"): gdbd1xrpr66a5nluljvpgr923q6r7k2hu4hmmryyvj0c23vdyzsukd3acsx9m7p6
static immutable BD = KeyPair(PublicKey(Point([194, 61, 107, 180, 159, 249, 249, 48, 40, 25, 85, 16, 104, 126, 178, 175, 202, 223, 123, 25, 8, 201, 63, 10, 139, 26, 65, 67, 150, 108, 123, 136])), SecretKey(Scalar([165, 185, 182, 240, 15, 35, 48, 172, 12, 163, 157, 159, 229, 63, 142, 63, 149, 179, 75, 224, 208, 185, 4, 14, 8, 64, 23, 21, 48, 201, 86, 12])));
/// BE("gdbe"): gdbe1xrpy66lgd60uk9mpnsdwd7gkfr698lhml3u78mkxxujskhj08atpc8lnt55
static immutable BE = KeyPair(PublicKey(Point([194, 77, 107, 232, 110, 159, 203, 23, 97, 156, 26, 230, 249, 22, 72, 244, 83, 254, 251, 252, 121, 227, 238, 198, 55, 37, 11, 94, 79, 63, 86, 28])), SecretKey(Scalar([220, 64, 217, 221, 6, 199, 28, 208, 171, 135, 102, 248, 9, 7, 4, 132, 43, 42, 155, 148, 231, 78, 38, 180, 9, 226, 24, 109, 161, 40, 208, 2])));
/// BF("gdbf"): gdbf1xrp9665hytv8njg6epp993fwndnkmatgsepc7gj5g0xls0ez2gengfzgcqp
static immutable BF = KeyPair(PublicKey(Point([194, 93, 106, 151, 34, 216, 121, 201, 26, 200, 66, 82, 197, 46, 155, 103, 109, 245, 104, 134, 67, 143, 34, 84, 67, 205, 248, 63, 34, 82, 51, 52])), SecretKey(Scalar([20, 60, 85, 62, 176, 176, 9, 9, 149, 105, 57, 228, 229, 207, 218, 150, 251, 91, 248, 153, 176, 238, 111, 153, 211, 199, 225, 225, 211, 249, 105, 14])));
/// BG("gdbg"): gdbg1xrpx66qkgy7vzmldgal4gj8traswkpw36nt003fru9lpd5laemnpuj9hllh
static immutable BG = KeyPair(PublicKey(Point([194, 109, 104, 22, 65, 60, 193, 111, 237, 71, 127, 84, 72, 235, 31, 96, 235, 5, 209, 212, 214, 247, 197, 35, 225, 126, 22, 211, 253, 206, 230, 30])), SecretKey(Scalar([221, 52, 64, 158, 250, 37, 215, 61, 71, 39, 25, 166, 151, 148, 46, 142, 97, 80, 237, 114, 198, 238, 239, 230, 57, 197, 65, 224, 179, 191, 97, 9])));
/// BH("gdbh"): gdbh1xrp866ua04jav2agufm46mqtyfnqqgtkdc3gsvpxtycnf6ymcd5msxsjjd2
static immutable BH = KeyPair(PublicKey(Point([194, 125, 107, 157, 125, 101, 214, 43, 168, 226, 119, 93, 108, 11, 34, 102, 0, 33, 118, 110, 34, 136, 48, 38, 89, 49, 52, 232, 155, 195, 105, 184])), SecretKey(Scalar([50, 74, 189, 240, 144, 168, 68, 8, 25, 81, 77, 121, 64, 178, 70, 75, 150, 33, 252, 241, 100, 40, 52, 58, 133, 81, 212, 147, 173, 94, 21, 15])));
/// BI("gdbi"): gdbi1xrpg66eeelscu68ejfu0jqud4phyaq2420jemcyz2xv2zkw6ww22gm03q56
static immutable BI = KeyPair(PublicKey(Point([194, 141, 107, 57, 207, 225, 142, 104, 249, 146, 120, 249, 3, 141, 168, 110, 78, 129, 85, 83, 229, 157, 224, 130, 81, 152, 161, 89, 218, 115, 148, 164])), SecretKey(Scalar([94, 97, 9, 139, 170, 230, 77, 109, 227, 171, 176, 195, 232, 59, 132, 230, 254, 53, 20, 209, 103, 96, 80, 86, 53, 140, 169, 15, 52, 132, 19, 3])));
/// BJ("gdbj"): gdbj1xrpf665lq6ly8ccqp28ly9xgx4dq5n8v96srd8s65463stxuv8azz7h0kcw
static immutable BJ = KeyPair(PublicKey(Point([194, 157, 106, 159, 6, 190, 67, 227, 0, 10, 143, 242, 20, 200, 53, 90, 10, 76, 236, 46, 160, 54, 158, 26, 165, 117, 24, 44, 220, 97, 250, 33])), SecretKey(Scalar([151, 131, 185, 183, 52, 235, 148, 69, 144, 11, 227, 158, 120, 236, 223, 251, 201, 66, 78, 171, 9, 140, 189, 187, 164, 96, 162, 123, 211, 203, 117, 14])));
/// BK("gdbk"): gdbk1xrp266c08q27anjpxj7822z0p5uwzqlq5xa9cmktyruyvshafj5dyc04yj2
static immutable BK = KeyPair(PublicKey(Point([194, 173, 107, 15, 56, 21, 238, 206, 65, 52, 188, 117, 40, 79, 13, 56, 225, 3, 224, 161, 186, 92, 110, 203, 32, 248, 70, 66, 253, 76, 168, 210])), SecretKey(Scalar([229, 250, 196, 112, 79, 186, 114, 150, 74, 133, 123, 130, 197, 22, 224, 118, 45, 226, 33, 202, 107, 39, 75, 180, 249, 58, 191, 28, 229, 52, 157, 1])));
/// BL("gdbl"): gdbl1xrpt66u3cylpg5ufqmm5rff7sl9hd2s8pgh2yem578k358xttkyyyddrpzu
static immutable BL = KeyPair(PublicKey(Point([194, 189, 107, 145, 193, 62, 20, 83, 137, 6, 247, 65, 165, 62, 135, 203, 118, 170, 7, 10, 46, 162, 103, 116, 241, 237, 26, 28, 203, 93, 136, 66])), SecretKey(Scalar([94, 80, 249, 76, 93, 72, 238, 114, 182, 11, 167, 54, 97, 99, 204, 64, 135, 95, 68, 44, 51, 195, 228, 49, 115, 21, 180, 114, 157, 140, 207, 13])));
/// BM("gdbm"): gdbm1xrpv66seswd324qhejpp9vr2r6lyhkp9jx595eukngy44rmckztts3ulx0a
static immutable BM = KeyPair(PublicKey(Point([194, 205, 106, 25, 131, 155, 21, 84, 23, 204, 130, 18, 176, 106, 30, 190, 75, 216, 37, 145, 168, 90, 103, 150, 154, 9, 90, 143, 120, 176, 150, 184])), SecretKey(Scalar([5, 202, 169, 216, 60, 63, 253, 1, 16, 254, 76, 26, 221, 250, 100, 24, 89, 9, 214, 174, 201, 141, 90, 154, 97, 239, 147, 158, 177, 135, 225, 6])));
/// BN("gdbn"): gdbn1xrpd66zw775z3ywh2udejke0alfkmt3a3mac8r5dyzrdzmrnzm78xw85pcr
static immutable BN = KeyPair(PublicKey(Point([194, 221, 104, 78, 247, 168, 40, 145, 215, 87, 27, 153, 91, 47, 239, 211, 109, 174, 61, 142, 251, 131, 142, 141, 32, 134, 209, 108, 115, 22, 252, 115])), SecretKey(Scalar([31, 219, 229, 6, 29, 173, 236, 137, 140, 41, 107, 82, 228, 92, 208, 92, 32, 133, 195, 22, 53, 20, 241, 90, 137, 185, 235, 107, 92, 129, 198, 1])));
/// BO("gdbo"): gdbo1xrpw66tvjfqs2tdvp3n9cfxrpmffymrux3h39qd776a0znau58v57dej957
static immutable BO = KeyPair(PublicKey(Point([194, 237, 105, 108, 146, 65, 5, 45, 172, 12, 102, 92, 36, 195, 14, 210, 146, 108, 124, 52, 111, 18, 129, 190, 246, 186, 241, 79, 188, 161, 217, 79])), SecretKey(Scalar([3, 67, 1, 64, 111, 152, 169, 49, 37, 243, 139, 154, 142, 107, 185, 33, 224, 58, 22, 147, 112, 77, 249, 248, 148, 233, 242, 132, 55, 174, 66, 1])));
/// BP("gdbp"): gdbp1xrp066tc0506mt5y99wmlhcc0dlk9gur7k6y5pazkzk7d289ttx6u0pw8tn
static immutable BP = KeyPair(PublicKey(Point([194, 253, 105, 120, 125, 31, 173, 174, 132, 41, 93, 191, 223, 24, 123, 127, 98, 163, 131, 245, 180, 74, 7, 162, 176, 173, 230, 168, 229, 90, 205, 174])), SecretKey(Scalar([20, 188, 60, 170, 60, 39, 143, 166, 68, 15, 12, 89, 60, 112, 192, 195, 216, 252, 189, 15, 15, 237, 154, 76, 185, 131, 234, 165, 159, 239, 21, 1])));
/// BQ("gdbq"): gdbq1xrps66klwmlz8zy8awpakx9sd3tra9mtqfyvyce36q4waxky0rudgaddfh8
static immutable BQ = KeyPair(PublicKey(Point([195, 13, 106, 223, 118, 254, 35, 136, 135, 235, 131, 219, 24, 176, 108, 86, 62, 151, 107, 2, 72, 194, 99, 49, 208, 42, 238, 154, 196, 120, 248, 212])), SecretKey(Scalar([210, 17, 11, 76, 100, 222, 15, 78, 51, 246, 52, 135, 116, 170, 86, 173, 255, 169, 221, 221, 64, 242, 118, 105, 177, 17, 83, 98, 25, 7, 106, 0])));
/// BR("gdbr"): gdbr1xrp366wrqq59cvwl0he2m2qsh70739hv83t937whhnkkghmmr0qwjj2prvk
static immutable BR = KeyPair(PublicKey(Point([195, 29, 105, 195, 0, 40, 92, 49, 223, 125, 242, 173, 168, 16, 191, 159, 232, 150, 236, 60, 86, 88, 249, 215, 188, 237, 100, 95, 123, 27, 192, 233])), SecretKey(Scalar([22, 103, 38, 221, 110, 139, 180, 63, 117, 244, 102, 90, 229, 217, 60, 191, 13, 236, 77, 8, 2, 169, 18, 216, 103, 87, 253, 130, 96, 221, 251, 3])));
/// BS("gdbs"): gdbs1xrpj66s5uvgs82hjhvyz5ec6yd9t49fc2ujdq5yyvach05x9kvf3vqdxdgl
static immutable BS = KeyPair(PublicKey(Point([195, 45, 106, 20, 227, 17, 3, 170, 242, 187, 8, 42, 103, 26, 35, 74, 186, 149, 56, 87, 36, 208, 80, 132, 103, 113, 119, 208, 197, 179, 19, 22])), SecretKey(Scalar([92, 61, 56, 92, 201, 105, 67, 37, 99, 255, 40, 220, 0, 45, 243, 122, 134, 37, 191, 117, 250, 180, 188, 79, 162, 99, 174, 36, 107, 85, 106, 14])));
/// BT("gdbt"): gdbt1xrpn66etem357zt3jj7vj552h68rehmymcsjxxqc0ur3jh3x6cp6xf484zt
static immutable BT = KeyPair(PublicKey(Point([195, 61, 107, 43, 206, 227, 79, 9, 113, 148, 188, 201, 82, 138, 190, 142, 60, 223, 100, 222, 33, 35, 24, 24, 127, 7, 25, 94, 38, 214, 3, 163])), SecretKey(Scalar([4, 83, 61, 10, 5, 241, 134, 64, 255, 216, 32, 244, 248, 147, 112, 74, 75, 69, 105, 246, 159, 141, 240, 185, 32, 127, 146, 230, 5, 131, 136, 8])));
/// BU("gdbu"): gdbu1xrp566f9mgp7w66yf0wsayvf8n7z43der4adum6sacgssxjsmcaxyzqcevl
static immutable BU = KeyPair(PublicKey(Point([195, 77, 105, 37, 218, 3, 231, 107, 68, 75, 221, 14, 145, 137, 60, 252, 42, 197, 185, 29, 122, 222, 111, 80, 238, 17, 8, 26, 80, 222, 58, 98])), SecretKey(Scalar([155, 110, 244, 238, 242, 40, 56, 181, 187, 117, 223, 132, 154, 198, 204, 119, 226, 249, 18, 195, 127, 94, 60, 135, 107, 25, 191, 212, 151, 176, 66, 6])));
/// BV("gdbv"): gdbv1xrp4664uqzeuxf6ltszh8z3n58gkndtf38h8h3lfvxevwzs2vr4qjlfgxln
static immutable BV = KeyPair(PublicKey(Point([195, 93, 106, 188, 0, 179, 195, 39, 95, 92, 5, 115, 138, 51, 161, 209, 105, 181, 105, 137, 238, 123, 199, 233, 97, 178, 199, 10, 10, 96, 234, 9])), SecretKey(Scalar([60, 166, 177, 182, 175, 120, 122, 55, 186, 109, 64, 73, 218, 211, 122, 229, 63, 156, 161, 10, 125, 115, 206, 28, 183, 40, 66, 189, 197, 105, 119, 6])));
/// BW("gdbw"): gdbw1xrpk66ug86zs50klufed59mkafkz0yt5rkd6a2yfkw8e0mxesauqyz5vgzv
static immutable BW = KeyPair(PublicKey(Point([195, 109, 107, 136, 62, 133, 10, 62, 223, 226, 114, 218, 23, 118, 234, 108, 39, 145, 116, 29, 155, 174, 168, 137, 179, 143, 151, 236, 217, 135, 120, 2])), SecretKey(Scalar([155, 117, 120, 175, 197, 35, 223, 161, 117, 14, 25, 165, 49, 41, 153, 52, 25, 18, 239, 128, 217, 101, 72, 205, 110, 11, 67, 169, 154, 53, 137, 10])));
/// BX("gdbx"): gdbx1xrph66zrcek2rte0jefph5trc5xxjfzf7vrnpr8mvleyvl5su9zx7n0le3q
static immutable BX = KeyPair(PublicKey(Point([195, 125, 104, 67, 198, 108, 161, 175, 47, 150, 82, 27, 209, 99, 197, 12, 105, 36, 73, 243, 7, 48, 140, 251, 103, 242, 70, 126, 144, 225, 68, 111])), SecretKey(Scalar([238, 90, 27, 93, 133, 122, 140, 51, 95, 129, 6, 235, 231, 45, 191, 193, 173, 31, 59, 142, 177, 159, 172, 21, 73, 151, 158, 101, 26, 141, 248, 11])));
/// BY("gdby"): gdby1xrpc66fjzsphzemm9kdd5twe8z3xwudqtxlrlmmacqluczm2m3jhsttnxdx
static immutable BY = KeyPair(PublicKey(Point([195, 141, 105, 50, 20, 3, 113, 103, 123, 45, 154, 218, 45, 217, 56, 162, 103, 113, 160, 89, 190, 63, 239, 125, 192, 63, 204, 11, 106, 220, 101, 120])), SecretKey(Scalar([190, 105, 202, 230, 211, 124, 45, 192, 140, 150, 167, 236, 54, 209, 230, 99, 172, 2, 131, 29, 85, 93, 104, 94, 244, 88, 17, 39, 255, 228, 0, 9])));
/// BZ("gdbz"): gdbz1xrpe66j64ueuv6vv2rypt03lp5vj4uxyrexjd5fnhh4qtrxk7w8xsxes2wf
static immutable BZ = KeyPair(PublicKey(Point([195, 157, 106, 90, 175, 51, 198, 105, 140, 80, 200, 21, 190, 63, 13, 25, 42, 240, 196, 30, 77, 38, 209, 51, 189, 234, 5, 140, 214, 243, 142, 104])), SecretKey(Scalar([156, 29, 235, 216, 215, 253, 117, 168, 231, 139, 199, 27, 62, 201, 233, 116, 249, 40, 17, 198, 83, 54, 211, 21, 52, 137, 31, 216, 240, 84, 146, 9])));
/// CA("gdca"): gdca1xrzq66737pwf5c80kndfyz7sm08z3z744m44y9a63a76ar2yc2f76tcaefj
static immutable CA = KeyPair(PublicKey(Point([196, 13, 107, 209, 240, 92, 154, 96, 239, 180, 218, 146, 11, 208, 219, 206, 40, 139, 213, 174, 235, 82, 23, 186, 143, 125, 174, 141, 68, 194, 147, 237])), SecretKey(Scalar([208, 118, 18, 178, 118, 230, 201, 60, 210, 198, 75, 176, 241, 89, 123, 25, 253, 192, 102, 33, 82, 218, 161, 72, 140, 121, 77, 138, 2, 214, 255, 13])));
/// CB("gdcb"): gdcb1xrzp66d8cwzn48pyxgtxx6ddpqqvvev0pdra8lcvsp7s8jdz9dhdgzkr47v
static immutable CB = KeyPair(PublicKey(Point([196, 29, 105, 167, 195, 133, 58, 156, 36, 50, 22, 99, 105, 173, 8, 0, 198, 101, 143, 11, 71, 211, 255, 12, 128, 125, 3, 201, 162, 43, 110, 212])), SecretKey(Scalar([92, 162, 59, 224, 133, 209, 19, 57, 14, 138, 203, 174, 247, 208, 55, 184, 204, 59, 9, 155, 219, 121, 145, 31, 244, 54, 154, 83, 172, 229, 185, 13])));
/// CC("gdcc"): gdcc1xrzz662jkvs9yeaczelhave0dw5n8r3nq69elkh75hanl5htjcufgxlcqe5
static immutable CC = KeyPair(PublicKey(Point([196, 45, 105, 82, 179, 32, 82, 103, 184, 22, 127, 126, 179, 47, 107, 169, 51, 142, 51, 6, 139, 159, 218, 254, 165, 251, 63, 210, 235, 150, 56, 148])), SecretKey(Scalar([219, 139, 180, 172, 85, 162, 180, 2, 98, 181, 8, 247, 163, 184, 81, 225, 155, 100, 160, 7, 168, 159, 92, 55, 237, 196, 29, 145, 131, 49, 143, 5])));
/// CD("gdcd"): gdcd1xrzr66n8a294s59gr8dsa29jpqa5gxdjyleq8qvnyjrrtj9chz7j7xhe0c7
static immutable CD = KeyPair(PublicKey(Point([196, 61, 106, 103, 234, 139, 88, 80, 168, 25, 219, 14, 168, 178, 8, 59, 68, 25, 178, 39, 242, 3, 129, 147, 36, 134, 53, 200, 184, 184, 189, 47])), SecretKey(Scalar([217, 10, 49, 249, 240, 163, 155, 219, 129, 128, 39, 228, 83, 203, 140, 76, 55, 178, 77, 238, 43, 107, 66, 108, 98, 91, 30, 249, 79, 149, 222, 2])));
/// CE("gdce"): gdce1xrzy66aey2yr0naz37avchypemlaww24pg6j555utv2dygn73ra5w03awny
static immutable CE = KeyPair(PublicKey(Point([196, 77, 107, 185, 34, 136, 55, 207, 162, 143, 186, 204, 92, 129, 206, 255, 215, 57, 85, 10, 53, 42, 82, 156, 91, 20, 210, 34, 126, 136, 251, 71])), SecretKey(Scalar([128, 20, 93, 84, 153, 15, 4, 54, 228, 161, 234, 201, 225, 42, 25, 183, 12, 236, 111, 6, 199, 86, 85, 229, 47, 81, 228, 210, 23, 30, 197, 3])));
/// CF("gdcf"): gdcf1xrz966chejp2pyqxllzemlys45qupplfs508nmsyasrcz0cn5vnywdxur7k
static immutable CF = KeyPair(PublicKey(Point([196, 93, 107, 23, 204, 130, 160, 144, 6, 255, 197, 157, 252, 144, 173, 1, 192, 135, 233, 133, 30, 121, 238, 4, 236, 7, 129, 63, 19, 163, 38, 71])), SecretKey(Scalar([108, 84, 40, 69, 104, 222, 123, 220, 212, 76, 205, 46, 67, 238, 74, 106, 227, 71, 7, 32, 127, 241, 76, 167, 142, 121, 111, 193, 38, 159, 99, 14])));
/// CG("gdcg"): gdcg1xrzx66lw603wt7p8crps96jm9ywfseu9tncuuytmx67lqdax3ltyxckjupm
static immutable CG = KeyPair(PublicKey(Point([196, 109, 107, 238, 211, 226, 229, 248, 39, 192, 195, 2, 234, 91, 41, 28, 152, 103, 133, 92, 241, 206, 17, 123, 54, 189, 240, 55, 166, 143, 214, 67])), SecretKey(Scalar([20, 104, 220, 239, 202, 140, 176, 248, 106, 82, 121, 63, 85, 140, 134, 2, 201, 247, 187, 31, 227, 63, 61, 232, 89, 209, 228, 220, 18, 195, 196, 7])));
/// CH("gdch"): gdch1xrz866tnzkee0lt7l8dhtmxknufrm8gs7mhjqcwm8q5wu0ugt903kfmru0f
static immutable CH = KeyPair(PublicKey(Point([196, 125, 105, 115, 21, 179, 151, 253, 126, 249, 219, 117, 236, 214, 159, 18, 61, 157, 16, 246, 239, 32, 97, 219, 56, 40, 238, 63, 136, 89, 95, 27])), SecretKey(Scalar([133, 14, 18, 224, 59, 81, 36, 48, 35, 162, 195, 183, 176, 24, 111, 179, 40, 67, 231, 145, 65, 243, 218, 205, 86, 22, 30, 16, 103, 129, 152, 1])));
/// CI("gdci"): gdci1xrzg66rhecdkqp8t4k52nhyeedtfz2jkyljhj45cunvnnjgng3uvzshd2jp
static immutable CI = KeyPair(PublicKey(Point([196, 141, 104, 119, 206, 27, 96, 4, 235, 173, 168, 169, 220, 153, 203, 86, 145, 42, 86, 39, 229, 121, 86, 152, 228, 217, 57, 201, 19, 68, 120, 193])), SecretKey(Scalar([163, 65, 125, 110, 200, 141, 5, 92, 66, 59, 62, 228, 137, 90, 137, 179, 169, 35, 69, 206, 112, 224, 93, 252, 9, 89, 209, 40, 160, 71, 182, 0])));
/// CJ("gdcj"): gdcj1xrzf66p2xedmwqn7pc6f6gn3xvldwfp807zgaulzlwycumu8r976j2y3ue2
static immutable CJ = KeyPair(PublicKey(Point([196, 157, 104, 42, 54, 91, 183, 2, 126, 14, 52, 157, 34, 113, 51, 62, 215, 36, 39, 127, 132, 142, 243, 226, 251, 137, 142, 111, 135, 25, 125, 169])), SecretKey(Scalar([58, 18, 23, 85, 168, 76, 12, 16, 203, 158, 109, 41, 7, 138, 211, 19, 23, 47, 245, 72, 47, 91, 223, 240, 249, 209, 133, 240, 241, 165, 84, 2])));
/// CK("gdck"): gdck1xrz266y3mtlyqdd3zw34e6vd057y2chkduzxkdz9rq9mgthtzv6uw8x3c09
static immutable CK = KeyPair(PublicKey(Point([196, 173, 104, 145, 218, 254, 64, 53, 177, 19, 163, 92, 233, 141, 125, 60, 69, 98, 246, 111, 4, 107, 52, 69, 24, 11, 180, 46, 235, 19, 53, 199])), SecretKey(Scalar([249, 235, 207, 181, 64, 109, 0, 122, 149, 23, 130, 120, 182, 77, 170, 86, 10, 150, 108, 46, 199, 90, 16, 42, 16, 148, 239, 6, 208, 20, 74, 3])));
/// CL("gdcl"): gdcl1xrzt6648emlnt26u4d9une6p44d4qpkxk8g7h4znsakkhlxjxp3suyqtv33
static immutable CL = KeyPair(PublicKey(Point([196, 189, 106, 167, 206, 255, 53, 171, 92, 171, 75, 201, 231, 65, 173, 91, 80, 6, 198, 177, 209, 235, 212, 83, 135, 109, 107, 252, 210, 48, 99, 14])), SecretKey(Scalar([157, 30, 29, 30, 188, 74, 238, 227, 68, 53, 56, 116, 139, 157, 227, 16, 215, 239, 10, 209, 105, 9, 70, 139, 223, 190, 232, 122, 15, 202, 228, 8])));
/// CM("gdcm"): gdcm1xrzv66uj70atq0x63xyzwfnt4l59655letexkhzg5rxqkzhs7qgsvrr3mul
static immutable CM = KeyPair(PublicKey(Point([196, 205, 107, 146, 243, 250, 176, 60, 218, 137, 136, 39, 38, 107, 175, 232, 93, 82, 159, 202, 242, 107, 92, 72, 160, 204, 11, 10, 240, 240, 17, 6])), SecretKey(Scalar([63, 122, 123, 243, 161, 149, 190, 213, 88, 62, 244, 204, 82, 113, 60, 18, 130, 252, 249, 151, 191, 167, 241, 242, 197, 207, 160, 119, 87, 184, 236, 0])));
/// CN("gdcn"): gdcn1xrzd663rffzkt469phk5xngfgk3g26scy25u8lepa86mkteuvjwqqc98my5
static immutable CN = KeyPair(PublicKey(Point([196, 221, 106, 35, 74, 69, 101, 215, 69, 13, 237, 67, 77, 9, 69, 162, 133, 106, 24, 34, 169, 195, 255, 33, 233, 245, 187, 47, 60, 100, 156, 0])), SecretKey(Scalar([53, 82, 23, 31, 203, 140, 239, 102, 111, 25, 231, 210, 196, 19, 123, 56, 48, 57, 38, 248, 201, 49, 94, 197, 76, 81, 80, 49, 10, 212, 167, 2])));
/// CO("gdco"): gdco1xrzw667rytgazlystyxj57rc58eu80xjwatdggdyfy7237n8ef8quvljgce
static immutable CO = KeyPair(PublicKey(Point([196, 237, 107, 195, 34, 209, 209, 124, 144, 89, 13, 42, 120, 120, 161, 243, 195, 188, 210, 119, 86, 212, 33, 164, 73, 60, 168, 250, 103, 202, 78, 14])), SecretKey(Scalar([76, 51, 64, 58, 147, 136, 27, 12, 233, 114, 30, 65, 177, 233, 72, 152, 253, 62, 121, 167, 91, 12, 41, 62, 212, 223, 106, 11, 79, 172, 30, 4])));
/// CP("gdcp"): gdcp1xrz066zpdt7vcl35d509fjeljm79dt5ezkrruq07a5h3umhq2pxcwca2xnr
static immutable CP = KeyPair(PublicKey(Point([196, 253, 104, 65, 106, 252, 204, 126, 52, 109, 30, 84, 203, 63, 150, 252, 86, 174, 153, 21, 134, 62, 1, 254, 237, 47, 30, 110, 224, 80, 77, 135])), SecretKey(Scalar([161, 167, 66, 180, 109, 87, 82, 152, 214, 216, 79, 20, 192, 100, 148, 227, 20, 203, 101, 41, 171, 240, 24, 146, 27, 189, 81, 67, 82, 155, 69, 15])));
/// CQ("gdcq"): gdcq1xrzs660zyzk8jzx3uaaxpmhp3dvnsnxdwxjrrc50vpd3n8fh3yk6zrsvug6
static immutable CQ = KeyPair(PublicKey(Point([197, 13, 105, 226, 32, 172, 121, 8, 209, 231, 122, 96, 238, 225, 139, 89, 56, 76, 205, 113, 164, 49, 226, 143, 96, 91, 25, 157, 55, 137, 45, 161])), SecretKey(Scalar([94, 239, 157, 220, 88, 102, 195, 185, 49, 188, 243, 29, 101, 144, 238, 248, 160, 2, 48, 55, 65, 172, 217, 16, 7, 109, 44, 25, 74, 247, 226, 14])));
/// CR("gdcr"): gdcr1xrz3666mcrna4yl3tke8s3du0x7cfn4a3j3v2vnrp5d3jazxeh686vfmgj2
static immutable CR = KeyPair(PublicKey(Point([197, 29, 107, 91, 192, 231, 218, 147, 241, 93, 178, 120, 69, 188, 121, 189, 132, 206, 189, 140, 162, 197, 50, 99, 13, 27, 25, 116, 70, 205, 244, 125])), SecretKey(Scalar([45, 14, 12, 167, 132, 174, 45, 102, 112, 42, 131, 210, 202, 91, 163, 184, 98, 16, 20, 108, 244, 251, 137, 1, 99, 249, 100, 155, 183, 46, 181, 1])));
/// CS("gdcs"): gdcs1xrzj664mmwg7h6gm4lmvcusxuz2r7d4zhw28jknu34g62vn5c5dajgzc7a7
static immutable CS = KeyPair(PublicKey(Point([197, 45, 106, 187, 219, 145, 235, 233, 27, 175, 246, 204, 114, 6, 224, 148, 63, 54, 162, 187, 148, 121, 90, 124, 141, 81, 165, 50, 116, 197, 27, 217])), SecretKey(Scalar([4, 161, 202, 175, 83, 123, 88, 198, 7, 23, 220, 40, 190, 117, 54, 67, 11, 201, 142, 9, 11, 75, 18, 237, 110, 154, 28, 58, 130, 14, 144, 4])));
/// CT("gdct"): gdct1xrzn66d988lmvj4wdnkvhf78zeuhtksnutnjfwswgh9qglntz9w8xgv87p8
static immutable CT = KeyPair(PublicKey(Point([197, 61, 105, 165, 57, 255, 182, 74, 174, 108, 236, 203, 167, 199, 22, 121, 117, 218, 19, 226, 231, 36, 186, 14, 69, 202, 4, 126, 107, 17, 92, 115])), SecretKey(Scalar([199, 198, 96, 100, 132, 25, 200, 90, 138, 68, 191, 129, 119, 190, 70, 77, 19, 115, 25, 65, 139, 48, 159, 109, 248, 197, 139, 25, 159, 161, 219, 7])));
/// CU("gdcu"): gdcu1xrz566t9fhwlpm2h9cmsz73msgxmedydmdx9m2h3tsmxxpvrp3mhkky5ux5
static immutable CU = KeyPair(PublicKey(Point([197, 77, 105, 101, 77, 221, 240, 237, 87, 46, 55, 1, 122, 59, 130, 13, 188, 180, 141, 219, 76, 93, 170, 241, 92, 54, 99, 5, 131, 12, 119, 123])), SecretKey(Scalar([99, 232, 111, 84, 5, 139, 209, 42, 146, 66, 225, 54, 149, 47, 86, 30, 103, 26, 145, 163, 133, 231, 177, 70, 236, 166, 237, 193, 64, 47, 82, 11])));
/// CV("gdcv"): gdcv1xrz466cpwzy9yg03t33a6z75hmcc5t3cdz3urntlnlt77x450576zta4adv
static immutable CV = KeyPair(PublicKey(Point([197, 93, 107, 1, 112, 136, 82, 33, 241, 92, 99, 221, 11, 212, 190, 241, 138, 46, 56, 104, 163, 193, 205, 127, 159, 215, 239, 26, 180, 125, 61, 161])), SecretKey(Scalar([243, 168, 29, 104, 171, 150, 9, 189, 16, 207, 156, 118, 212, 33, 251, 19, 51, 24, 78, 202, 84, 134, 141, 136, 243, 237, 20, 38, 11, 199, 142, 1])));
/// CW("gdcw"): gdcw1xrzk66nfevvyctkr8y9tjxc2ep30e9ej76qv2246xsfq8q32l953vt4fp09
static immutable CW = KeyPair(PublicKey(Point([197, 109, 106, 105, 203, 24, 76, 46, 195, 57, 10, 185, 27, 10, 200, 98, 252, 151, 50, 246, 128, 197, 42, 186, 52, 18, 3, 130, 42, 249, 105, 22])), SecretKey(Scalar([153, 202, 78, 209, 115, 154, 97, 62, 169, 82, 174, 184, 111, 146, 196, 88, 3, 17, 180, 26, 190, 137, 42, 226, 94, 164, 158, 201, 195, 58, 200, 7])));
/// CX("gdcx"): gdcx1xrzh660eg5a0ajxapf0cu5eatajcaj8ttrjel42gpvz8s44lypqejztw88f
static immutable CX = KeyPair(PublicKey(Point([197, 125, 105, 249, 69, 58, 254, 200, 221, 10, 95, 142, 83, 61, 95, 101, 142, 200, 235, 88, 229, 159, 213, 72, 11, 4, 120, 86, 191, 32, 65, 153])), SecretKey(Scalar([73, 200, 0, 71, 147, 125, 242, 56, 180, 122, 132, 137, 239, 48, 181, 47, 177, 29, 154, 216, 252, 106, 72, 170, 87, 25, 55, 183, 201, 155, 36, 14])));
/// CY("gdcy"): gdcy1xrzc666krpcky39encn6archs3dsnj4gsxsr22dtdwk6hrec0pkhghez2rn
static immutable CY = KeyPair(PublicKey(Point([197, 141, 107, 86, 24, 113, 98, 68, 185, 158, 39, 174, 143, 23, 132, 91, 9, 202, 168, 129, 160, 53, 41, 171, 107, 173, 171, 143, 56, 120, 109, 116])), SecretKey(Scalar([146, 238, 196, 205, 241, 3, 26, 52, 177, 160, 7, 100, 124, 247, 96, 64, 220, 11, 248, 75, 72, 230, 6, 189, 30, 183, 86, 243, 54, 57, 46, 10])));
/// CZ("gdcz"): gdcz1xrze66z26p63xyy55pf6x8kky504ptxfe3cd877vm5gtvmlsx08juk3t9d5
static immutable CZ = KeyPair(PublicKey(Point([197, 157, 104, 74, 208, 117, 19, 16, 148, 160, 83, 163, 30, 214, 37, 31, 80, 172, 201, 204, 112, 211, 251, 204, 221, 16, 182, 111, 240, 51, 207, 46])), SecretKey(Scalar([11, 113, 105, 219, 170, 39, 209, 28, 63, 20, 192, 151, 244, 243, 17, 28, 92, 128, 9, 147, 159, 244, 74, 113, 253, 37, 232, 180, 116, 30, 223, 6])));
/// DA("gdda"): gdda1xrrq66e6cqh4pk4vnsrllxrr54e2scr5920jr5q8wldv2cz2m2kzq7upyhs
static immutable DA = KeyPair(PublicKey(Point([198, 13, 107, 58, 192, 47, 80, 218, 172, 156, 7, 255, 152, 99, 165, 114, 168, 96, 116, 42, 159, 33, 208, 7, 119, 218, 197, 96, 74, 218, 172, 32])), SecretKey(Scalar([112, 2, 66, 250, 219, 237, 53, 139, 33, 20, 38, 221, 71, 221, 196, 155, 8, 66, 215, 23, 182, 248, 253, 157, 202, 201, 160, 230, 50, 194, 140, 4])));
/// DB("gddb"): gddb1xrrp66phfzx8tlvrnawj86qnatxhsjc6pmp6k5md4lmfzxd5wpwhx3v43l5
static immutable DB = KeyPair(PublicKey(Point([198, 29, 104, 55, 72, 140, 117, 253, 131, 159, 93, 35, 232, 19, 234, 205, 120, 75, 26, 14, 195, 171, 83, 109, 175, 246, 145, 25, 180, 112, 93, 115])), SecretKey(Scalar([251, 174, 228, 108, 8, 236, 106, 184, 246, 27, 55, 114, 225, 226, 137, 119, 137, 27, 243, 23, 30, 24, 252, 201, 178, 107, 219, 208, 1, 32, 11, 4])));
/// DC("gddc"): gddc1xrrz66knzxytvaky5cve564z2xzzn25jtlpf0qc4wh2z2xn5tnzs5qhpm2x
static immutable DC = KeyPair(PublicKey(Point([198, 45, 106, 211, 17, 136, 182, 118, 196, 166, 25, 154, 106, 162, 81, 132, 41, 170, 146, 95, 194, 151, 131, 21, 117, 212, 37, 26, 116, 92, 197, 10])), SecretKey(Scalar([112, 19, 59, 177, 142, 118, 140, 232, 93, 203, 71, 163, 165, 8, 23, 102, 137, 54, 166, 184, 146, 56, 184, 2, 145, 120, 104, 182, 92, 241, 116, 15])));
/// DD("gddd"): gddd1xrrr66f5nm68yh4wmfqunxvcljdx3mhm9cdsxr2ea5zy5svtp9545hvw0xf
static immutable DD = KeyPair(PublicKey(Point([198, 61, 105, 52, 158, 244, 114, 94, 174, 218, 65, 201, 153, 152, 252, 154, 104, 238, 251, 46, 27, 3, 13, 89, 237, 4, 74, 65, 139, 9, 105, 90])), SecretKey(Scalar([83, 6, 204, 148, 101, 89, 152, 231, 178, 52, 138, 65, 50, 157, 82, 51, 155, 9, 159, 36, 124, 179, 26, 49, 174, 35, 201, 10, 9, 188, 163, 0])));
/// DE("gdde"): gdde1xrry668fuv7dx2c2jqnatavvr4lu2ruekucqzygywh3lhhg4dzk5w2m2mph
static immutable DE = KeyPair(PublicKey(Point([198, 77, 104, 233, 227, 60, 211, 43, 10, 144, 39, 213, 245, 140, 29, 127, 197, 15, 153, 183, 48, 1, 17, 4, 117, 227, 251, 221, 21, 104, 173, 71])), SecretKey(Scalar([251, 75, 70, 50, 5, 175, 99, 61, 49, 95, 70, 75, 68, 92, 197, 37, 130, 117, 189, 188, 160, 144, 236, 133, 155, 79, 207, 219, 43, 82, 102, 13])));
/// DF("gddf"): gddf1xrr966seae3662xywqx3tcn6xyazge50sewecz9zd7w826xqgfkr64sp0uk
static immutable DF = KeyPair(PublicKey(Point([198, 93, 106, 25, 238, 99, 173, 40, 196, 112, 13, 21, 226, 122, 49, 58, 36, 102, 143, 134, 93, 156, 8, 162, 111, 156, 117, 104, 192, 66, 108, 61])), SecretKey(Scalar([210, 22, 186, 187, 227, 171, 95, 30, 143, 118, 117, 208, 134, 156, 38, 173, 60, 145, 232, 66, 231, 100, 209, 235, 80, 238, 161, 249, 199, 139, 163, 14])));
/// DG("gddg"): gddg1xrrx666cdzceye3q4y876kuzaax7wgarp8qcs7ugn5a6a5lcy5znyc9d7yz
static immutable DG = KeyPair(PublicKey(Point([198, 109, 107, 88, 104, 177, 146, 102, 32, 169, 15, 237, 91, 130, 239, 77, 231, 35, 163, 9, 193, 136, 123, 136, 157, 59, 174, 211, 248, 37, 5, 50])), SecretKey(Scalar([248, 238, 211, 4, 79, 214, 151, 15, 161, 166, 4, 173, 154, 143, 242, 219, 191, 155, 12, 100, 95, 170, 113, 39, 101, 166, 148, 169, 96, 165, 121, 1])));
/// DH("gddh"): gddh1xrr866kr2kcv55f3xptt6mggapttncxkhueaze3nu3627w2pculzznyr6c0
static immutable DH = KeyPair(PublicKey(Point([198, 125, 106, 195, 85, 176, 202, 81, 49, 48, 86, 189, 109, 8, 232, 86, 185, 224, 214, 191, 51, 209, 102, 51, 228, 116, 175, 57, 65, 199, 62, 33])), SecretKey(Scalar([134, 133, 57, 177, 238, 228, 185, 85, 209, 144, 133, 56, 245, 204, 96, 104, 154, 97, 161, 177, 87, 125, 32, 219, 207, 204, 113, 145, 92, 115, 52, 12])));
/// DI("gddi"): gddi1xrrg66hmj7gafmq5eueep35wxtj2j9txx2qshj77yynst9j5v5e86h4zudw
static immutable DI = KeyPair(PublicKey(Point([198, 141, 106, 251, 151, 145, 212, 236, 20, 207, 51, 144, 198, 142, 50, 228, 169, 21, 102, 50, 129, 11, 203, 222, 33, 39, 5, 150, 84, 101, 50, 125])), SecretKey(Scalar([31, 251, 240, 152, 23, 134, 95, 182, 127, 135, 89, 129, 84, 50, 151, 82, 33, 81, 218, 90, 248, 47, 102, 239, 214, 95, 238, 122, 213, 17, 38, 9])));
/// DJ("gddj"): gddj1xrrf666zgk898aj33n9y23ee5ftl3ep2fp0mp8dt7e7mtrxmtn8fyw3dgpe
static immutable DJ = KeyPair(PublicKey(Point([198, 157, 107, 66, 69, 142, 83, 246, 81, 140, 202, 69, 71, 57, 162, 87, 248, 228, 42, 72, 95, 176, 157, 171, 246, 125, 181, 140, 219, 92, 206, 146])), SecretKey(Scalar([117, 142, 143, 227, 124, 110, 193, 156, 62, 239, 161, 36, 163, 54, 14, 82, 92, 178, 62, 183, 67, 216, 155, 41, 19, 24, 11, 239, 9, 162, 5, 2])));
/// DK("gddk"): gddk1xrr266lgkws3ms0yvdlvyt0cfg9gmrzwuevvh27287atkm73dm7hwt70jrj
static immutable DK = KeyPair(PublicKey(Point([198, 173, 107, 232, 179, 161, 29, 193, 228, 99, 126, 194, 45, 248, 74, 10, 141, 140, 78, 230, 88, 203, 171, 202, 63, 186, 187, 111, 209, 110, 253, 119])), SecretKey(Scalar([196, 167, 159, 103, 183, 37, 190, 229, 165, 34, 129, 24, 246, 44, 141, 120, 4, 187, 19, 63, 85, 94, 29, 60, 18, 72, 11, 8, 92, 138, 55, 9])));
/// DL("gddl"): gddl1xrrt66fm3694pqf266tsuy43c7azxv3vdju9xsrqla39fdxk6ce2zzujj3s
static immutable DL = KeyPair(PublicKey(Point([198, 189, 105, 59, 142, 139, 80, 129, 42, 214, 151, 14, 18, 177, 199, 186, 35, 50, 44, 108, 184, 83, 64, 96, 255, 98, 84, 180, 214, 214, 50, 161])), SecretKey(Scalar([68, 35, 156, 47, 47, 22, 218, 33, 210, 240, 64, 101, 22, 152, 185, 147, 177, 91, 136, 156, 185, 102, 205, 211, 151, 91, 102, 5, 16, 96, 28, 5])));
/// DM("gddm"): gddm1xrrv66stxy5nmdx36g38npxlp7gagvwnv6rzlx2x5tye50u4wrlz7ydx8ch
static immutable DM = KeyPair(PublicKey(Point([198, 205, 106, 11, 49, 41, 61, 180, 209, 210, 34, 121, 132, 223, 15, 145, 212, 49, 211, 102, 134, 47, 153, 70, 162, 201, 154, 63, 149, 112, 254, 47])), SecretKey(Scalar([229, 154, 195, 148, 19, 180, 84, 51, 94, 63, 243, 139, 83, 129, 232, 248, 165, 241, 235, 84, 19, 114, 134, 167, 242, 101, 68, 143, 53, 218, 210, 10])));
/// DN("gddn"): gddn1xrrd66yr673xhw7su7gm0qhj35qj4aefmmkavmddprcuy3gg27agsj96ytj
static immutable DN = KeyPair(PublicKey(Point([198, 221, 104, 131, 215, 162, 107, 187, 208, 231, 145, 183, 130, 242, 141, 1, 42, 247, 41, 222, 237, 214, 109, 173, 8, 241, 194, 69, 8, 87, 186, 136])), SecretKey(Scalar([212, 110, 106, 166, 47, 50, 31, 88, 24, 141, 220, 158, 91, 42, 93, 65, 109, 31, 28, 115, 34, 214, 21, 182, 133, 1, 182, 215, 167, 14, 131, 8])));
/// DO("gddo"): gddo1xrrw66gjy22xj2fljssrm2jxq9w40wy0ru39n46azrk87ez0m58u5jqf7r4
static immutable DO = KeyPair(PublicKey(Point([198, 237, 105, 18, 34, 148, 105, 41, 63, 148, 32, 61, 170, 70, 1, 93, 87, 184, 143, 31, 34, 89, 215, 93, 16, 236, 127, 100, 79, 221, 15, 202])), SecretKey(Scalar([209, 105, 193, 159, 141, 46, 244, 52, 176, 68, 23, 34, 208, 54, 22, 102, 66, 76, 68, 168, 22, 46, 131, 137, 155, 194, 92, 47, 112, 85, 185, 14])));
/// DP("gddp"): gddp1xrr066k32ytfk56ph9cj4ztq45hxhvyywh8fzfwn03qefvzdfqyzcet67fm
static immutable DP = KeyPair(PublicKey(Point([198, 253, 106, 209, 81, 22, 155, 83, 65, 185, 113, 42, 137, 96, 173, 46, 107, 176, 132, 117, 206, 145, 37, 211, 124, 65, 148, 176, 77, 72, 8, 44])), SecretKey(Scalar([66, 40, 61, 206, 34, 16, 145, 32, 182, 134, 120, 149, 17, 133, 182, 139, 168, 4, 159, 217, 47, 68, 11, 41, 7, 57, 199, 132, 14, 128, 94, 0])));
/// DQ("gddq"): gddq1xrrs66m3jds063jq7kx6fpm23kzrl2a5s6t2ks4c4nmvyjnxr9m6kanz9tq
static immutable DQ = KeyPair(PublicKey(Point([199, 13, 107, 113, 147, 96, 253, 70, 64, 245, 141, 164, 135, 106, 141, 132, 63, 171, 180, 134, 150, 171, 66, 184, 172, 246, 194, 74, 102, 25, 119, 171])), SecretKey(Scalar([17, 18, 10, 225, 103, 169, 40, 235, 223, 127, 20, 78, 100, 246, 122, 98, 37, 218, 34, 232, 70, 42, 139, 10, 158, 228, 132, 151, 175, 245, 120, 14])));
/// DR("gddr"): gddr1xrr366usk55uzkgf05cwsrxavsdunu77g83l9kegzax6j5c66xps52yyx8l
static immutable DR = KeyPair(PublicKey(Point([199, 29, 107, 144, 181, 41, 193, 89, 9, 125, 48, 232, 12, 221, 100, 27, 201, 243, 222, 65, 227, 242, 219, 40, 23, 77, 169, 83, 26, 209, 131, 10])), SecretKey(Scalar([211, 137, 53, 25, 102, 82, 158, 214, 163, 76, 79, 61, 149, 163, 150, 190, 16, 164, 231, 194, 223, 240, 118, 175, 134, 121, 136, 27, 78, 195, 83, 7])));
/// DS("gdds"): gdds1xrrj66m202wrszn6cf6v7rujadnz4x5vejv2mx34787nrq5unzpewaxnnvs
static immutable DS = KeyPair(PublicKey(Point([199, 45, 107, 106, 122, 156, 56, 10, 122, 194, 116, 207, 15, 146, 235, 102, 42, 154, 140, 204, 152, 173, 154, 53, 241, 253, 49, 130, 156, 152, 131, 151])), SecretKey(Scalar([33, 237, 166, 193, 43, 188, 23, 53, 153, 153, 43, 97, 103, 217, 220, 54, 141, 85, 199, 153, 169, 157, 175, 59, 24, 237, 58, 142, 181, 220, 151, 6])));
/// DT("gddt"): gddt1xrrn66vtg5yyy4rzslyjk7lda9znl6qfcrrr6qfh4h9ssghejrujg4ttk7v
static immutable DT = KeyPair(PublicKey(Point([199, 61, 105, 139, 69, 8, 66, 84, 98, 135, 201, 43, 123, 237, 233, 69, 63, 232, 9, 192, 198, 61, 1, 55, 173, 203, 8, 34, 249, 144, 249, 36])), SecretKey(Scalar([146, 52, 181, 250, 247, 240, 148, 217, 69, 234, 80, 239, 103, 248, 157, 98, 180, 58, 197, 205, 54, 43, 12, 112, 158, 25, 220, 245, 101, 119, 98, 10])));
/// DU("gddu"): gddu1xrr566v7v7tm2vmk5fuywam8c4232akazfq2dxqngpmxfuk7ce9h2qdz2na
static immutable DU = KeyPair(PublicKey(Point([199, 77, 105, 158, 103, 151, 181, 51, 118, 162, 120, 71, 119, 103, 197, 85, 21, 118, 221, 18, 64, 166, 152, 19, 64, 118, 100, 242, 222, 198, 75, 117])), SecretKey(Scalar([38, 104, 37, 111, 43, 154, 2, 154, 243, 105, 196, 15, 191, 125, 43, 162, 60, 156, 88, 115, 108, 240, 81, 100, 178, 156, 180, 30, 197, 83, 93, 15])));
/// DV("gddv"): gddv1xrr466u5249vfydp2szvhkfxl0keq49gux3cytu8hgmuytne74g62yez356
static immutable DV = KeyPair(PublicKey(Point([199, 93, 107, 148, 85, 74, 196, 145, 161, 84, 4, 203, 217, 38, 251, 237, 144, 84, 168, 225, 163, 130, 47, 135, 186, 55, 194, 46, 121, 245, 81, 165])), SecretKey(Scalar([41, 124, 249, 61, 101, 30, 209, 217, 132, 22, 231, 0, 14, 224, 108, 220, 130, 123, 134, 160, 81, 18, 229, 17, 93, 151, 128, 190, 96, 23, 57, 7])));
/// DW("gddw"): gddw1xrrk66y0js0u9wazl8elssrpkttydvqe8thqzkx40lmnhynwlftzsq742ss
static immutable DW = KeyPair(PublicKey(Point([199, 109, 104, 143, 148, 31, 194, 187, 162, 249, 243, 248, 64, 97, 178, 214, 70, 176, 25, 58, 238, 1, 88, 213, 127, 247, 59, 146, 110, 250, 86, 40])), SecretKey(Scalar([108, 237, 103, 109, 250, 238, 243, 121, 194, 172, 100, 33, 151, 114, 231, 166, 62, 126, 199, 176, 82, 193, 172, 151, 130, 206, 227, 238, 138, 250, 253, 10])));
/// DX("gddx"): gddx1xrrh66nwq3n0ephkm2ys8ujw2ck2d9qd5hdewr5fy636v42jan9qzmf9c3l
static immutable DX = KeyPair(PublicKey(Point([199, 125, 106, 110, 4, 102, 252, 134, 246, 218, 137, 3, 242, 78, 86, 44, 166, 148, 13, 165, 219, 151, 14, 137, 38, 163, 166, 85, 82, 236, 202, 1])), SecretKey(Scalar([80, 187, 96, 65, 6, 239, 86, 122, 2, 95, 243, 192, 34, 86, 15, 48, 37, 123, 213, 179, 220, 226, 104, 82, 133, 183, 79, 118, 186, 253, 229, 13])));
/// DY("gddy"): gddy1xrrc66ac9hmcle7ewypf7phr4vcd4t95kfq2cxs7xtjgk2vsxy3cvtzarg3
static immutable DY = KeyPair(PublicKey(Point([199, 141, 107, 184, 45, 247, 143, 231, 217, 113, 2, 159, 6, 227, 171, 48, 218, 172, 180, 178, 64, 172, 26, 30, 50, 228, 139, 41, 144, 49, 35, 134])), SecretKey(Scalar([234, 164, 72, 125, 156, 72, 166, 212, 11, 42, 200, 136, 133, 199, 118, 63, 248, 22, 157, 239, 82, 94, 143, 159, 164, 164, 196, 4, 67, 250, 254, 15])));
/// DZ("gddz"): gddz1xrre663q8xm2yx3p08fy8mwkd0juvngm7jc6y6w8dkk323y2xqld5ee2tg4
static immutable DZ = KeyPair(PublicKey(Point([199, 157, 106, 32, 57, 182, 162, 26, 33, 121, 210, 67, 237, 214, 107, 229, 198, 77, 27, 244, 177, 162, 105, 199, 109, 173, 21, 68, 138, 48, 62, 218])), SecretKey(Scalar([79, 18, 168, 86, 184, 188, 101, 136, 142, 213, 222, 129, 70, 148, 68, 38, 49, 122, 99, 36, 147, 168, 59, 194, 3, 146, 13, 130, 138, 156, 17, 14])));
/// EA("gdea"): gdea1xryq66m70zyeypvrchs0djs97kkyfwtg4f8kejvzxrk8yejf767fx7pgc8m
static immutable EA = KeyPair(PublicKey(Point([200, 13, 107, 126, 120, 137, 146, 5, 131, 197, 224, 246, 202, 5, 245, 172, 68, 185, 104, 170, 79, 108, 201, 130, 48, 236, 114, 102, 73, 246, 188, 147])), SecretKey(Scalar([33, 23, 168, 21, 79, 107, 248, 194, 135, 43, 189, 223, 116, 80, 97, 145, 86, 57, 175, 151, 83, 38, 144, 193, 65, 148, 208, 39, 70, 139, 14, 5])));
/// EB("gdeb"): gdeb1xryp669eyz72wwn8assqdydkr4qzvz6n963tgasleww3epypw8pnj7zj4lh
static immutable EB = KeyPair(PublicKey(Point([200, 29, 104, 185, 32, 188, 167, 58, 103, 236, 32, 6, 145, 182, 29, 64, 38, 11, 83, 46, 162, 180, 118, 31, 203, 157, 28, 132, 129, 113, 195, 57])), SecretKey(Scalar([136, 128, 248, 126, 61, 74, 120, 181, 39, 227, 229, 15, 183, 213, 222, 184, 188, 146, 138, 139, 142, 253, 71, 66, 104, 35, 38, 117, 117, 62, 114, 6])));
/// EC("gdec"): gdec1xryz66hwn3mvzdnfs72u53p5v3t40tncvg3e4dzcu9jstfggxjh65ze4he8
static immutable EC = KeyPair(PublicKey(Point([200, 45, 106, 238, 156, 118, 193, 54, 105, 135, 149, 202, 68, 52, 100, 87, 87, 174, 120, 98, 35, 154, 180, 88, 225, 101, 5, 165, 8, 52, 175, 170])), SecretKey(Scalar([70, 208, 196, 155, 145, 64, 192, 234, 30, 115, 123, 140, 106, 40, 244, 147, 34, 51, 105, 7, 158, 18, 235, 166, 57, 239, 209, 252, 59, 232, 253, 15])));
/// ED("gded"): gded1xryr66vg4p9u8377en35pusuz5j3fq5p2cg5w4yg6xtqaulu428mqhyu5ze
static immutable ED = KeyPair(PublicKey(Point([200, 61, 105, 136, 168, 75, 195, 199, 222, 204, 227, 64, 242, 28, 21, 37, 20, 130, 129, 86, 17, 71, 84, 136, 209, 150, 14, 243, 252, 170, 143, 176])), SecretKey(Scalar([219, 151, 2, 144, 63, 215, 115, 65, 197, 108, 221, 183, 17, 167, 11, 31, 106, 37, 128, 237, 129, 218, 214, 220, 122, 226, 161, 34, 156, 188, 245, 6])));
/// EE("gdee"): gdee1xryy66ljvf4c7m0a5h6nc4vyfjs660lxknmwcl4g0lu80a0xl0yzjg338z5
static immutable EE = KeyPair(PublicKey(Point([200, 77, 107, 242, 98, 107, 143, 109, 253, 165, 245, 60, 85, 132, 76, 161, 173, 63, 230, 180, 246, 236, 126, 168, 127, 248, 119, 245, 230, 251, 200, 41])), SecretKey(Scalar([55, 100, 15, 115, 14, 183, 42, 131, 48, 199, 140, 46, 12, 1, 13, 2, 172, 144, 194, 153, 151, 155, 115, 95, 227, 76, 148, 160, 79, 243, 102, 7])));
/// EF("gdef"): gdef1xry966p56rfu23r3srweps4ldmlpdla4hvw07d5s3u7ps9ayyxy373p2f3r
static immutable EF = KeyPair(PublicKey(Point([200, 93, 104, 52, 208, 211, 197, 68, 113, 128, 221, 144, 194, 191, 110, 254, 22, 255, 181, 187, 28, 255, 54, 144, 143, 60, 24, 23, 164, 33, 137, 31])), SecretKey(Scalar([146, 95, 149, 104, 44, 79, 70, 165, 12, 17, 63, 51, 31, 208, 169, 12, 210, 98, 218, 159, 156, 57, 101, 164, 88, 57, 86, 84, 113, 56, 49, 6])));
/// EG("gdeg"): gdeg1xryx66n5t7kthc7cjefmujecmg79ryrfdhs3duaz9qgz8lqheqenceccw3c
static immutable EG = KeyPair(PublicKey(Point([200, 109, 106, 116, 95, 172, 187, 227, 216, 150, 83, 190, 75, 56, 218, 60, 81, 144, 105, 109, 225, 22, 243, 162, 40, 16, 35, 252, 23, 200, 51, 60])), SecretKey(Scalar([204, 86, 165, 254, 54, 90, 200, 149, 92, 227, 163, 84, 157, 134, 251, 141, 58, 37, 187, 213, 136, 0, 152, 102, 253, 135, 217, 107, 177, 51, 56, 2])));
/// EH("gdeh"): gdeh1xry866ezsfvtcyat67f0qm3e9plr84lacpvnme8nqehhtc03qtrv2zeptrk
static immutable EH = KeyPair(PublicKey(Point([200, 125, 107, 34, 130, 88, 188, 19, 171, 215, 146, 240, 110, 57, 40, 126, 51, 215, 253, 192, 89, 61, 228, 243, 6, 111, 117, 225, 241, 2, 198, 197])), SecretKey(Scalar([35, 153, 125, 250, 77, 147, 133, 123, 0, 215, 94, 1, 204, 12, 37, 83, 25, 106, 69, 58, 118, 97, 241, 45, 146, 83, 47, 90, 91, 142, 72, 4])));
/// EI("gdei"): gdei1xryg66l4ds2zxtgym8ac86zckcvpjn7um7faau5saq4ftqqeemwr5cvyugn
static immutable EI = KeyPair(PublicKey(Point([200, 141, 107, 245, 108, 20, 35, 45, 4, 217, 251, 131, 232, 88, 182, 24, 25, 79, 220, 223, 147, 222, 242, 144, 232, 42, 149, 128, 25, 206, 220, 58])), SecretKey(Scalar([27, 61, 40, 222, 15, 67, 60, 223, 128, 160, 134, 4, 40, 248, 6, 17, 32, 31, 168, 147, 209, 215, 150, 78, 226, 209, 212, 238, 213, 77, 255, 10])));
/// EJ("gdej"): gdej1xryf66zx9lg5evzy9237tfwdkpqcnx3gcplk8cdad0h5y67aqrla6z9dt7d
static immutable EJ = KeyPair(PublicKey(Point([200, 157, 104, 70, 47, 209, 76, 176, 68, 42, 163, 229, 165, 205, 176, 65, 137, 154, 40, 192, 127, 99, 225, 189, 107, 239, 66, 107, 221, 0, 255, 221])), SecretKey(Scalar([215, 127, 167, 198, 91, 56, 85, 145, 39, 142, 3, 200, 97, 107, 117, 85, 33, 121, 67, 182, 93, 177, 90, 196, 230, 38, 206, 246, 8, 58, 63, 12])));
/// EK("gdek"): gdek1xry266057n666yawa9dvdcflstrfdvlaeghcr4p5r7g0xrz7c9ytuvwfxva
static immutable EK = KeyPair(PublicKey(Point([200, 173, 105, 244, 244, 245, 173, 19, 174, 233, 90, 198, 225, 63, 130, 198, 150, 179, 253, 202, 47, 129, 212, 52, 31, 144, 243, 12, 94, 193, 72, 190])), SecretKey(Scalar([3, 25, 43, 51, 45, 160, 37, 253, 131, 17, 121, 251, 33, 180, 121, 186, 253, 57, 158, 203, 133, 7, 41, 232, 140, 85, 30, 241, 44, 22, 187, 9])));
/// EL("gdel"): gdel1xryt66ev5qqcvrqm9vwvff50ad7ntdvycsz6eq7qruprqs97l4f9g6fwamc
static immutable EL = KeyPair(PublicKey(Point([200, 189, 107, 44, 160, 1, 134, 12, 27, 43, 28, 196, 166, 143, 235, 125, 53, 181, 132, 196, 5, 172, 131, 192, 31, 2, 48, 64, 190, 253, 82, 84])), SecretKey(Scalar([115, 123, 253, 151, 19, 105, 121, 32, 208, 67, 204, 220, 90, 37, 173, 70, 252, 144, 153, 110, 173, 152, 124, 118, 231, 235, 115, 189, 203, 81, 83, 15])));
/// EM("gdem"): gdem1xryv66j00q8tt9m9j3xmefyrz4rdhegllh5yklrz9yfa54ka9pfdvjz5qj9
static immutable EM = KeyPair(PublicKey(Point([200, 205, 106, 79, 120, 14, 181, 151, 101, 148, 77, 188, 164, 131, 21, 70, 219, 229, 31, 253, 232, 75, 124, 98, 41, 19, 218, 86, 221, 40, 82, 214])), SecretKey(Scalar([242, 228, 38, 32, 253, 20, 28, 139, 245, 106, 195, 85, 173, 229, 43, 172, 27, 85, 173, 32, 243, 85, 51, 57, 170, 41, 135, 221, 235, 240, 201, 9])));
/// EN("gden"): gden1xryd66ss8fh69v9q7ywqsr5v6rny28d37u94qqxtawstg3psl26qc9htt36
static immutable EN = KeyPair(PublicKey(Point([200, 221, 106, 16, 58, 111, 162, 176, 160, 241, 28, 8, 14, 140, 208, 230, 69, 29, 177, 247, 11, 80, 0, 203, 235, 160, 180, 68, 48, 250, 180, 12])), SecretKey(Scalar([61, 65, 80, 103, 169, 117, 243, 222, 11, 85, 199, 37, 109, 63, 139, 198, 67, 248, 64, 16, 179, 167, 216, 22, 92, 174, 85, 222, 79, 96, 20, 12])));
/// EO("gdeo"): gdeo1xryw66fmvvgup3a8m06hnr8qgj6wxrffg77v0pkm20nq5q5qzx2gvdyw53c
static immutable EO = KeyPair(PublicKey(Point([200, 237, 105, 59, 99, 17, 192, 199, 167, 219, 245, 121, 140, 224, 68, 180, 227, 13, 41, 71, 188, 199, 134, 219, 83, 230, 10, 2, 128, 17, 148, 134])), SecretKey(Scalar([130, 117, 131, 87, 107, 67, 88, 114, 222, 179, 47, 149, 4, 106, 255, 52, 178, 85, 104, 69, 11, 70, 190, 237, 144, 132, 249, 54, 162, 17, 21, 14])));
/// EP("gdep"): gdep1xry0660nfrw6dguzl6xcg0rd8vs5nkxfw3thhz5fw3fcc3zqes59xxtp4zj
static immutable EP = KeyPair(PublicKey(Point([200, 253, 105, 243, 72, 221, 166, 163, 130, 254, 141, 132, 60, 109, 59, 33, 73, 216, 201, 116, 87, 123, 138, 137, 116, 83, 140, 68, 64, 204, 40, 83])), SecretKey(Scalar([92, 41, 242, 108, 226, 145, 180, 144, 76, 90, 167, 51, 80, 88, 158, 163, 223, 133, 204, 68, 148, 73, 216, 17, 152, 205, 37, 238, 12, 231, 236, 1])));
/// EQ("gdeq"): gdeq1xrys66ssfu4x069ajh9gyu7g57rst3rzwfu07g56r7p9fdjgv77tjkqlcmd
static immutable EQ = KeyPair(PublicKey(Point([201, 13, 106, 16, 79, 42, 103, 232, 189, 149, 202, 130, 115, 200, 167, 135, 5, 196, 98, 114, 120, 255, 34, 154, 31, 130, 84, 182, 72, 103, 188, 185])), SecretKey(Scalar([124, 84, 143, 221, 123, 22, 230, 31, 172, 224, 41, 45, 186, 25, 215, 138, 93, 77, 100, 128, 33, 225, 2, 112, 22, 115, 126, 6, 171, 192, 146, 7])));
/// ER("gder"): gder1xry366afu6qeg93tzlr6zlwxzxf9mfsz427s49c7z4wfwawfdxa82ctmdjn
static immutable ER = KeyPair(PublicKey(Point([201, 29, 107, 169, 230, 129, 148, 22, 43, 23, 199, 161, 125, 198, 17, 146, 93, 166, 2, 170, 189, 10, 151, 30, 21, 92, 151, 117, 201, 105, 186, 117])), SecretKey(Scalar([90, 76, 164, 251, 161, 87, 242, 243, 231, 145, 87, 76, 176, 183, 56, 193, 28, 39, 99, 40, 41, 57, 171, 176, 29, 18, 43, 195, 60, 26, 186, 14])));
/// ES("gdes"): gdes1xryj66svd2e5zprcwgxqsn4cdn709zazar7rnqhrs0vsk2elmrm75z4ylp5
static immutable ES = KeyPair(PublicKey(Point([201, 45, 106, 12, 106, 179, 65, 4, 120, 114, 12, 8, 78, 184, 108, 252, 242, 139, 162, 232, 252, 57, 130, 227, 131, 217, 11, 43, 63, 216, 247, 234])), SecretKey(Scalar([139, 49, 223, 183, 209, 26, 230, 129, 252, 85, 52, 69, 38, 142, 194, 112, 39, 242, 101, 36, 3, 232, 35, 161, 56, 154, 234, 33, 6, 159, 49, 11])));
/// ET("gdet"): gdet1xryn66954uyynwjugejqdx09khpyrjfm9ln5vk7uwu39lrw4qw0a63c7dme
static immutable ET = KeyPair(PublicKey(Point([201, 61, 104, 180, 175, 8, 73, 186, 92, 70, 100, 6, 153, 229, 181, 194, 65, 201, 59, 47, 231, 70, 91, 220, 119, 34, 95, 141, 213, 3, 159, 221])), SecretKey(Scalar([81, 181, 183, 186, 179, 10, 168, 197, 47, 102, 98, 113, 71, 49, 148, 235, 197, 39, 175, 213, 72, 72, 127, 65, 13, 134, 64, 146, 61, 92, 98, 0])));
/// EU("gdeu"): gdeu1xry566z5e72vwlq7xe3wyh3jjjmqm8ugvs89795uexh4a8aa54xek26tzff
static immutable EU = KeyPair(PublicKey(Point([201, 77, 104, 84, 207, 148, 199, 124, 30, 54, 98, 226, 94, 50, 148, 182, 13, 159, 136, 100, 14, 95, 22, 156, 201, 175, 94, 159, 189, 165, 77, 155])), SecretKey(Scalar([139, 31, 177, 13, 55, 118, 61, 41, 161, 17, 102, 21, 126, 82, 233, 227, 123, 120, 162, 171, 134, 127, 237, 213, 134, 143, 137, 91, 53, 87, 176, 10])));
/// EV("gdev"): gdev1xry466h0up22u0gwafjl07suqzvxryq434w03wvt0w8pplgch0slzjs4syv
static immutable EV = KeyPair(PublicKey(Point([201, 93, 106, 239, 224, 84, 174, 61, 14, 234, 101, 247, 250, 28, 0, 152, 97, 144, 21, 141, 92, 248, 185, 139, 123, 142, 16, 253, 24, 187, 225, 241])), SecretKey(Scalar([90, 56, 53, 29, 23, 114, 78, 232, 199, 112, 22, 52, 92, 65, 205, 207, 61, 142, 116, 118, 145, 172, 154, 227, 158, 122, 194, 203, 101, 159, 233, 0])));
/// EW("gdew"): gdew1xryk66fcz56ngs4tdgvn3rfvgwrx7m8zyqdelzf78lhrq7jj089tgj3wax9
static immutable EW = KeyPair(PublicKey(Point([201, 109, 105, 56, 21, 53, 52, 66, 171, 106, 25, 56, 141, 44, 67, 134, 111, 108, 226, 32, 27, 159, 137, 62, 63, 238, 48, 122, 82, 121, 202, 180])), SecretKey(Scalar([27, 120, 75, 204, 26, 254, 139, 57, 150, 228, 202, 227, 147, 31, 33, 205, 57, 12, 78, 138, 89, 83, 103, 179, 160, 42, 138, 227, 60, 60, 61, 15])));
/// EX("gdex"): gdex1xryh66ee59jr3x0jt4ztycdfgfaz76y3p3s7pxe9m9n3rrjq26zpc6w35lj
static immutable EX = KeyPair(PublicKey(Point([201, 125, 107, 57, 161, 100, 56, 153, 242, 93, 68, 178, 97, 169, 66, 122, 47, 104, 145, 12, 97, 224, 155, 37, 217, 103, 17, 142, 64, 86, 132, 28])), SecretKey(Scalar([94, 190, 42, 135, 238, 223, 142, 68, 155, 228, 132, 140, 170, 40, 44, 24, 110, 212, 6, 226, 86, 126, 169, 215, 120, 209, 93, 244, 191, 89, 108, 7])));
/// EY("gdey"): gdey1xryc66q5qjluqpqgy8n58qx509n02c380s8avyx5r266367fw8dyj6cj05v
static immutable EY = KeyPair(PublicKey(Point([201, 141, 104, 20, 4, 191, 192, 4, 8, 33, 231, 67, 128, 212, 121, 102, 245, 98, 39, 124, 15, 214, 16, 212, 26, 181, 168, 235, 201, 113, 218, 73])), SecretKey(Scalar([108, 11, 115, 228, 116, 226, 192, 4, 20, 93, 102, 69, 90, 60, 129, 27, 160, 115, 116, 22, 187, 73, 240, 218, 187, 29, 104, 72, 78, 65, 16, 0])));
/// EZ("gdez"): gdez1xrye66p9dgwnr26tagsm2cf7436y3ruuuj9672vqaet9fvgrsevh5rxyex2
static immutable EZ = KeyPair(PublicKey(Point([201, 157, 104, 37, 106, 29, 49, 171, 75, 234, 33, 181, 97, 62, 172, 116, 72, 143, 156, 228, 139, 175, 41, 128, 238, 86, 84, 177, 3, 134, 89, 122])), SecretKey(Scalar([78, 23, 137, 162, 112, 70, 136, 62, 178, 254, 147, 105, 136, 89, 155, 124, 166, 87, 115, 2, 195, 216, 83, 244, 33, 194, 67, 195, 144, 211, 78, 11])));
/// FA("gdfa"): gdfa1xr9q66sp3rmqnhfvu8230l89s26u8sf2x3wx93t2z5hzy8alj28c64zjagz
static immutable FA = KeyPair(PublicKey(Point([202, 13, 106, 1, 136, 246, 9, 221, 44, 225, 213, 23, 252, 229, 130, 181, 195, 193, 42, 52, 92, 98, 197, 106, 21, 46, 34, 31, 191, 146, 143, 141])), SecretKey(Scalar([43, 205, 94, 36, 111, 182, 145, 49, 50, 125, 161, 138, 228, 186, 12, 199, 161, 14, 145, 74, 21, 44, 114, 42, 237, 39, 57, 200, 179, 150, 6, 12])));
/// FB("gdfb"): gdfb1xr9p66mkkx9lep5t28vmhh94dyglrcc2wptzy5de88ew3ljvqz0zcqw7jn3
static immutable FB = KeyPair(PublicKey(Point([202, 29, 107, 118, 177, 139, 252, 134, 139, 81, 217, 187, 220, 181, 105, 17, 241, 227, 10, 112, 86, 34, 81, 185, 57, 242, 232, 254, 76, 0, 158, 44])), SecretKey(Scalar([32, 193, 87, 34, 2, 143, 138, 171, 183, 57, 55, 76, 31, 178, 135, 134, 139, 43, 47, 202, 228, 202, 61, 54, 157, 86, 80, 54, 215, 170, 241, 11])));
/// FC("gdfc"): gdfc1xr9z66r445lmd4kq2npwhwng2exqx24jge38q2w9u48t2pxgk9a7qtru4g8
static immutable FC = KeyPair(PublicKey(Point([202, 45, 104, 117, 173, 63, 182, 214, 192, 84, 194, 235, 186, 104, 86, 76, 3, 42, 178, 70, 98, 112, 41, 197, 229, 78, 181, 4, 200, 177, 123, 224])), SecretKey(Scalar([35, 221, 12, 33, 38, 81, 13, 162, 241, 22, 55, 133, 37, 10, 205, 239, 16, 35, 67, 136, 156, 50, 222, 131, 113, 197, 120, 40, 43, 182, 48, 15])));
/// FD("gdfd"): gdfd1xr9r66cxdzapqsd26ewkwz5q65rn6pl62340m6xuqqlqdvw2wvtp2at3xdw
static immutable FD = KeyPair(PublicKey(Point([202, 61, 107, 6, 104, 186, 16, 65, 170, 214, 93, 103, 10, 128, 213, 7, 61, 7, 250, 84, 106, 253, 232, 220, 0, 62, 6, 177, 202, 115, 22, 21])), SecretKey(Scalar([16, 153, 104, 12, 80, 132, 72, 68, 197, 189, 163, 172, 97, 67, 206, 66, 59, 225, 250, 35, 88, 242, 55, 77, 35, 89, 194, 6, 108, 70, 188, 3])));
/// FE("gdfe"): gdfe1xr9y66yys057pu3t9u7ft67q37rwpfyqxqf246pdga3asgfv4vm3jfxpe3h
static immutable FE = KeyPair(PublicKey(Point([202, 77, 104, 132, 131, 233, 224, 242, 43, 47, 60, 149, 235, 192, 143, 134, 224, 164, 128, 48, 18, 170, 232, 45, 71, 99, 216, 33, 44, 171, 55, 25])), SecretKey(Scalar([62, 10, 182, 240, 65, 148, 45, 185, 191, 111, 118, 150, 11, 230, 48, 38, 240, 247, 60, 119, 243, 24, 163, 173, 170, 146, 129, 160, 144, 173, 49, 8])));
/// FF("gdff"): gdff1xr99663xltw3p0lflfggveehs3ljx7n5yclp7g35dqtjtk68a6xdcrw93c5
static immutable FF = KeyPair(PublicKey(Point([202, 93, 106, 38, 250, 221, 16, 191, 233, 250, 80, 134, 103, 55, 132, 127, 35, 122, 116, 38, 62, 31, 34, 52, 104, 23, 37, 219, 71, 238, 140, 220])), SecretKey(Scalar([246, 226, 206, 166, 206, 28, 196, 235, 72, 58, 80, 236, 36, 224, 218, 36, 182, 30, 100, 244, 50, 111, 65, 219, 104, 124, 225, 241, 110, 247, 22, 3])));
/// FG("gdfg"): gdfg1xr9x662nwdh6eeu74udt32usw7vew7hntrmk6f0uwqysaudm7tqujnd5ahr
static immutable FG = KeyPair(PublicKey(Point([202, 109, 105, 83, 115, 111, 172, 231, 158, 175, 26, 184, 171, 144, 119, 153, 151, 122, 243, 88, 247, 109, 37, 252, 112, 9, 14, 241, 187, 242, 193, 201])), SecretKey(Scalar([5, 205, 134, 104, 98, 201, 11, 18, 10, 168, 87, 232, 154, 8, 8, 14, 125, 91, 102, 137, 10, 231, 121, 26, 192, 20, 229, 159, 20, 150, 254, 5])));
/// FH("gdfh"): gdfh1xr9866sf0d7el9zxuqts405yktry8prk7y0n9uph403p3knay9anxax0jt9
static immutable FH = KeyPair(PublicKey(Point([202, 125, 106, 9, 123, 125, 159, 148, 70, 224, 23, 10, 190, 132, 178, 198, 67, 132, 118, 241, 31, 50, 240, 55, 171, 226, 24, 218, 125, 33, 123, 51])), SecretKey(Scalar([220, 23, 224, 191, 41, 51, 154, 70, 230, 31, 18, 53, 120, 143, 115, 31, 31, 251, 130, 93, 9, 44, 155, 92, 40, 9, 62, 75, 185, 175, 183, 8])));
/// FI("gdfi"): gdfi1xr9g66fzfrrxj8chgfqg9gxr95z3jnjzzmszzlj6kmypfm8u0zzcsh0qdkg
static immutable FI = KeyPair(PublicKey(Point([202, 141, 105, 34, 72, 198, 105, 31, 23, 66, 64, 130, 160, 195, 45, 5, 25, 78, 66, 22, 224, 33, 126, 90, 182, 200, 20, 236, 252, 120, 133, 136])), SecretKey(Scalar([69, 126, 224, 88, 117, 104, 250, 222, 240, 193, 219, 86, 55, 42, 158, 175, 174, 91, 110, 197, 212, 78, 224, 136, 108, 164, 92, 106, 239, 230, 109, 14])));
/// FJ("gdfj"): gdfj1xr9f66wsju3eem44htdl92spnrtzl8edsz54vt9w5kl330ra9xwhyevm3gg
static immutable FJ = KeyPair(PublicKey(Point([202, 157, 105, 208, 151, 35, 156, 238, 181, 186, 219, 242, 170, 1, 152, 214, 47, 159, 45, 128, 169, 86, 44, 174, 165, 191, 24, 188, 125, 41, 157, 114])), SecretKey(Scalar([108, 188, 176, 190, 25, 177, 200, 132, 127, 64, 127, 4, 57, 171, 76, 190, 31, 64, 100, 124, 249, 154, 55, 117, 228, 178, 36, 116, 175, 140, 71, 8])));
/// FK("gdfk"): gdfk1xr9266lj05gqkducsmmgcxm992se5wkw37gml4wqjtcn048q3uvd7mfq0de
static immutable FK = KeyPair(PublicKey(Point([202, 173, 107, 242, 125, 16, 11, 55, 152, 134, 246, 140, 27, 101, 42, 161, 154, 58, 206, 143, 145, 191, 213, 192, 146, 241, 55, 212, 224, 143, 24, 223])), SecretKey(Scalar([109, 105, 98, 44, 102, 67, 215, 132, 21, 98, 231, 113, 105, 148, 184, 141, 250, 203, 237, 236, 28, 93, 134, 47, 19, 239, 218, 224, 143, 202, 25, 14])));
/// FL("gdfl"): gdfl1xr9t66977chahfujnw0jz8r4sluahjq6xzdupph57ak3krx6sa6679vxzw6
static immutable FL = KeyPair(PublicKey(Point([202, 189, 104, 190, 246, 47, 219, 167, 146, 155, 159, 33, 28, 117, 135, 249, 219, 200, 26, 48, 155, 192, 134, 244, 247, 109, 27, 12, 218, 135, 117, 175])), SecretKey(Scalar([148, 163, 98, 254, 82, 26, 6, 192, 175, 100, 182, 241, 187, 233, 95, 199, 170, 219, 100, 244, 241, 206, 167, 25, 219, 15, 93, 209, 215, 219, 108, 8])));
/// FM("gdfm"): gdfm1xr9v66yspzn9t74trtgqh89fj5s3alaj06z2tkh42cc4wwzhmlmtv5tjx4w
static immutable FM = KeyPair(PublicKey(Point([202, 205, 104, 144, 8, 166, 85, 250, 171, 26, 208, 11, 156, 169, 149, 33, 30, 255, 178, 126, 132, 165, 218, 245, 86, 49, 87, 56, 87, 223, 246, 182])), SecretKey(Scalar([216, 39, 23, 13, 27, 123, 196, 109, 113, 187, 66, 44, 252, 159, 2, 71, 224, 252, 21, 232, 161, 133, 27, 197, 184, 2, 32, 107, 119, 121, 43, 3])));
/// FN("gdfn"): gdfn1xr9d66pmka5wues39z87h5vmlq4ups28gcay7lrrhetk37qdvy0scrct2t0
static immutable FN = KeyPair(PublicKey(Point([202, 221, 104, 59, 183, 104, 238, 102, 17, 40, 143, 235, 209, 155, 248, 43, 192, 193, 71, 70, 58, 79, 124, 99, 190, 87, 104, 248, 13, 97, 31, 12])), SecretKey(Scalar([12, 6, 164, 12, 221, 1, 210, 253, 65, 67, 251, 102, 164, 45, 179, 44, 23, 233, 28, 207, 135, 98, 221, 198, 156, 141, 162, 242, 95, 23, 186, 7])));
/// FO("gdfo"): gdfo1xr9w66eknljhakkxggsth47c7j0yfrk06dh4v8yrd7mf4sresm26xuz89j6
static immutable FO = KeyPair(PublicKey(Point([202, 237, 107, 54, 159, 229, 126, 218, 198, 66, 32, 187, 215, 216, 244, 158, 68, 142, 207, 211, 111, 86, 28, 131, 111, 182, 154, 192, 121, 134, 213, 163])), SecretKey(Scalar([60, 191, 12, 222, 8, 152, 108, 88, 23, 252, 31, 202, 220, 114, 126, 98, 137, 85, 4, 243, 55, 43, 247, 116, 72, 30, 255, 183, 91, 33, 64, 11])));
/// FP("gdfp"): gdfp1xr90663uxman5uhywams4fktr3937x08sf5e008zuzktt052zha8salvesx
static immutable FP = KeyPair(PublicKey(Point([202, 253, 106, 60, 54, 251, 58, 114, 228, 119, 119, 10, 166, 203, 28, 75, 31, 25, 231, 130, 105, 151, 188, 226, 224, 172, 181, 190, 138, 21, 250, 120])), SecretKey(Scalar([201, 60, 136, 181, 155, 232, 218, 129, 181, 105, 197, 120, 167, 13, 129, 29, 190, 105, 204, 57, 80, 100, 218, 240, 28, 194, 47, 128, 168, 175, 171, 5])));
/// FQ("gdfq"): gdfq1xr9s66gvlnj0e9efpyud8vwvwse6epllsqm0djdn4l4ywafdh9va78378nq
static immutable FQ = KeyPair(PublicKey(Point([203, 13, 105, 12, 252, 228, 252, 151, 41, 9, 56, 211, 177, 204, 116, 51, 172, 135, 255, 128, 54, 246, 201, 179, 175, 234, 71, 117, 45, 185, 89, 223])), SecretKey(Scalar([91, 199, 191, 163, 224, 63, 43, 240, 170, 81, 249, 105, 170, 230, 103, 126, 95, 161, 16, 131, 130, 119, 174, 202, 0, 146, 25, 111, 197, 251, 150, 6])));
/// FR("gdfr"): gdfr1xr93662ycxj4k6dwjga0e84y4fhsykc2xyf8mptvrax439g2q8g9w5hmrc0
static immutable FR = KeyPair(PublicKey(Point([203, 29, 105, 68, 193, 165, 91, 105, 174, 146, 58, 252, 158, 164, 170, 111, 2, 91, 10, 49, 18, 125, 133, 108, 31, 77, 88, 149, 10, 1, 208, 87])), SecretKey(Scalar([73, 86, 20, 251, 141, 182, 209, 253, 176, 70, 19, 69, 181, 214, 210, 32, 162, 187, 171, 91, 239, 32, 208, 204, 193, 99, 94, 17, 217, 148, 109, 8])));
/// FS("gdfs"): gdfs1xr9j66ts0hjc696ptd6f2f66dauszy6tggh5q3tngn5w3zsdu6cakj0t2gh
static immutable FS = KeyPair(PublicKey(Point([203, 45, 105, 112, 125, 229, 141, 23, 65, 91, 116, 149, 39, 90, 111, 121, 1, 19, 75, 66, 47, 64, 69, 115, 68, 232, 232, 138, 13, 230, 177, 219])), SecretKey(Scalar([160, 178, 235, 18, 155, 52, 62, 248, 91, 198, 2, 41, 161, 36, 8, 37, 46, 151, 6, 79, 222, 2, 3, 190, 199, 100, 227, 51, 61, 137, 219, 5])));
/// FT("gdft"): gdft1xr9n66wgdmtcyuknqseq7kqgdx42w6ah7vg94lsyczfznxklpcgkyn3rmpc
static immutable FT = KeyPair(PublicKey(Point([203, 61, 105, 200, 110, 215, 130, 114, 211, 4, 50, 15, 88, 8, 105, 170, 167, 107, 183, 243, 16, 90, 254, 4, 192, 146, 41, 154, 223, 14, 17, 98])), SecretKey(Scalar([213, 249, 237, 243, 111, 29, 151, 134, 62, 25, 149, 90, 167, 120, 37, 48, 42, 153, 231, 204, 8, 84, 25, 147, 187, 9, 67, 35, 249, 23, 103, 15])));
/// FU("gdfu"): gdfu1xr9566v0ve7neht8lppn0ezayrt5706qypph7rmzd02ja7sjm5j6zg2szdq
static immutable FU = KeyPair(PublicKey(Point([203, 77, 105, 143, 102, 125, 60, 221, 103, 248, 67, 55, 228, 93, 32, 215, 79, 63, 64, 32, 67, 127, 15, 98, 107, 213, 46, 250, 18, 221, 37, 161])), SecretKey(Scalar([244, 115, 236, 36, 66, 113, 231, 203, 52, 154, 111, 77, 55, 90, 1, 5, 135, 176, 52, 201, 17, 173, 85, 243, 61, 40, 105, 225, 216, 152, 234, 7])));
/// FV("gdfv"): gdfv1xr9466xd9enz347w7xl4vlurqrhzq7xh9e9jhydpeyc2xhavykh0gzlt0j0
static immutable FV = KeyPair(PublicKey(Point([203, 93, 104, 205, 46, 102, 40, 215, 206, 241, 191, 86, 127, 131, 0, 238, 32, 120, 215, 46, 75, 43, 145, 161, 201, 48, 163, 95, 172, 37, 174, 244])), SecretKey(Scalar([80, 103, 9, 156, 181, 7, 138, 220, 193, 182, 215, 218, 174, 56, 139, 142, 12, 206, 198, 155, 114, 230, 72, 105, 169, 64, 21, 65, 1, 246, 108, 6])));
/// FW("gdfw"): gdfw1xr9k6656u99tzm4yr8uducs3uzxdt06vmswgvamhhl8m8n944tlk5yr4ahj
static immutable FW = KeyPair(PublicKey(Point([203, 109, 106, 154, 225, 74, 177, 110, 164, 25, 248, 222, 98, 17, 224, 140, 213, 191, 76, 220, 28, 134, 119, 119, 191, 207, 179, 204, 181, 170, 255, 106])), SecretKey(Scalar([103, 36, 160, 144, 23, 169, 16, 159, 208, 76, 87, 213, 197, 67, 135, 38, 63, 185, 172, 99, 30, 25, 218, 173, 239, 128, 36, 229, 74, 76, 28, 8])));
/// FX("gdfx"): gdfx1xr9h667xsvlsyktegkjjf28dyg76uk7ut5rtyfj6jaac3j6czfut5asg8zv
static immutable FX = KeyPair(PublicKey(Point([203, 125, 107, 198, 131, 63, 2, 89, 121, 69, 165, 36, 168, 237, 34, 61, 174, 91, 220, 93, 6, 178, 38, 90, 151, 123, 136, 203, 88, 18, 120, 186])), SecretKey(Scalar([144, 87, 217, 7, 192, 62, 105, 158, 191, 87, 253, 232, 206, 154, 148, 101, 105, 54, 246, 18, 98, 60, 69, 156, 231, 236, 121, 88, 248, 183, 49, 10])));
/// FY("gdfy"): gdfy1xr9c66djc7r4x4299w4nveha67fkdyz0cw64ldjrvxepamflwl8zxq3pzgx
static immutable FY = KeyPair(PublicKey(Point([203, 141, 105, 178, 199, 135, 83, 85, 69, 43, 171, 54, 102, 253, 215, 147, 102, 144, 79, 195, 181, 95, 182, 67, 97, 178, 30, 237, 63, 119, 206, 35])), SecretKey(Scalar([211, 212, 27, 109, 255, 122, 159, 97, 170, 30, 107, 135, 173, 153, 37, 237, 157, 76, 42, 176, 4, 237, 135, 247, 59, 56, 44, 217, 182, 127, 149, 7])));
/// FZ("gdfz"): gdfz1xr9e66026vnym587lv4nea4fu8vkz7cjagph3n9w8e65qhzhmcn7vyg9xwn
static immutable FZ = KeyPair(PublicKey(Point([203, 157, 105, 234, 211, 38, 77, 208, 254, 251, 43, 60, 246, 169, 225, 217, 97, 123, 18, 234, 3, 120, 204, 174, 62, 117, 64, 92, 87, 222, 39, 230])), SecretKey(Scalar([7, 234, 104, 108, 51, 49, 43, 99, 201, 160, 47, 162, 150, 159, 176, 171, 76, 160, 182, 232, 1, 23, 76, 184, 18, 202, 185, 235, 44, 33, 84, 5])));
/// GA("gdga"): gdga1xrxq66kqdestjyhtwn5xm7xf93y5nksd9k724tdrxcvltc9qdmtc7vygwwp
static immutable GA = KeyPair(PublicKey(Point([204, 13, 106, 192, 110, 96, 185, 18, 235, 116, 232, 109, 248, 201, 44, 73, 73, 218, 13, 45, 188, 170, 173, 163, 54, 25, 245, 224, 160, 110, 215, 143])), SecretKey(Scalar([28, 218, 86, 224, 168, 50, 21, 18, 62, 227, 25, 193, 57, 210, 123, 11, 238, 44, 176, 120, 137, 108, 130, 23, 181, 54, 76, 114, 233, 206, 50, 5])));
/// GB("gdgb"): gdgb1xrxp6638tndj9f34wpw2g2xy89aedvlaxsv7efjppexd6qrth0v0jrkhdzl
static immutable GB = KeyPair(PublicKey(Point([204, 29, 106, 39, 92, 219, 34, 166, 53, 112, 92, 164, 40, 196, 57, 123, 150, 179, 253, 52, 25, 236, 166, 65, 14, 76, 221, 0, 107, 187, 216, 249])), SecretKey(Scalar([203, 42, 138, 159, 207, 168, 240, 26, 219, 143, 96, 15, 250, 231, 175, 115, 244, 163, 174, 220, 116, 183, 142, 222, 242, 169, 112, 79, 244, 92, 216, 4])));
/// GC("gdgc"): gdgc1xrxz66ax2vtmxpafltd9gqzk85sw2ap8wtxakmvvhsjgwsuuhzycssq7xv3
static immutable GC = KeyPair(PublicKey(Point([204, 45, 107, 166, 83, 23, 179, 7, 169, 250, 218, 84, 0, 86, 61, 32, 229, 116, 39, 114, 205, 219, 109, 140, 188, 36, 135, 67, 156, 184, 137, 136])), SecretKey(Scalar([147, 33, 176, 87, 232, 143, 249, 214, 99, 226, 22, 15, 55, 96, 130, 65, 172, 41, 35, 120, 114, 79, 213, 214, 78, 0, 6, 172, 106, 17, 239, 10])));
/// GD("gdgd"): gdgd1xrxr66ftcl38se5qm7hvxq7phtsgamltsgnm06snazg86kn3pv05vpd4c8v
static immutable GD = KeyPair(PublicKey(Point([204, 61, 105, 43, 199, 226, 120, 102, 128, 223, 174, 195, 3, 193, 186, 224, 142, 239, 235, 130, 39, 183, 234, 19, 232, 144, 125, 90, 113, 11, 31, 70])), SecretKey(Scalar([251, 128, 90, 121, 235, 71, 25, 190, 185, 19, 25, 54, 47, 62, 85, 236, 37, 251, 170, 129, 119, 201, 26, 240, 197, 1, 36, 85, 79, 9, 228, 2])));
/// GE("gdge"): gdge1xrxy66y65rfxrfphud7gtkp8rtqr05xs2jdr5ufez6fg6wxzxlta5vwqg83
static immutable GE = KeyPair(PublicKey(Point([204, 77, 104, 154, 160, 210, 97, 164, 55, 227, 124, 133, 216, 39, 26, 192, 55, 208, 208, 84, 154, 58, 113, 57, 22, 146, 141, 56, 194, 55, 215, 218])), SecretKey(Scalar([2, 45, 250, 33, 142, 201, 168, 42, 119, 240, 114, 239, 152, 254, 21, 46, 45, 224, 243, 115, 99, 67, 100, 125, 135, 200, 38, 85, 246, 5, 23, 11])));
/// GF("gdgf"): gdgf1xrx966pnpf8quy6zwax2rkg8n2mwjqnl0jm6lwc8gc3lql5yxp075tp54uw
static immutable GF = KeyPair(PublicKey(Point([204, 93, 104, 51, 10, 78, 14, 19, 66, 119, 76, 161, 217, 7, 154, 182, 233, 2, 127, 124, 183, 175, 187, 7, 70, 35, 240, 126, 132, 48, 95, 234])), SecretKey(Scalar([85, 162, 155, 219, 218, 234, 78, 253, 36, 25, 89, 228, 140, 39, 132, 127, 36, 204, 174, 116, 102, 34, 84, 22, 124, 110, 99, 82, 221, 228, 116, 9])));
/// GG("gdgg"): gdgg1xrxx667xtl44vajl5eqnramhrdcqs58k6zej3r5gwfjzqdkxzmwn5aw9ad3
static immutable GG = KeyPair(PublicKey(Point([204, 109, 107, 198, 95, 235, 86, 118, 95, 166, 65, 49, 247, 119, 27, 112, 8, 80, 246, 208, 179, 40, 142, 136, 114, 100, 32, 54, 198, 22, 221, 58])), SecretKey(Scalar([197, 42, 130, 204, 62, 98, 55, 2, 254, 178, 39, 131, 137, 171, 99, 254, 107, 76, 206, 82, 39, 207, 18, 180, 251, 94, 192, 29, 5, 66, 239, 15])));
/// GH("gdgh"): gdgh1xrx8665nh5ldhdjxexgkxzlkhsxmn0whv6qf3mlnxxg8hlghkvkdvn5f87h
static immutable GH = KeyPair(PublicKey(Point([204, 125, 106, 147, 189, 62, 219, 182, 70, 201, 145, 99, 11, 246, 188, 13, 185, 189, 215, 102, 128, 152, 239, 243, 49, 144, 123, 253, 23, 179, 44, 214])), SecretKey(Scalar([200, 240, 119, 24, 252, 75, 132, 109, 12, 8, 43, 255, 210, 49, 108, 16, 218, 254, 20, 182, 212, 69, 84, 10, 124, 203, 182, 226, 52, 192, 238, 3])));
/// GI("gdgi"): gdgi1xrxg6624kyxzz50ygeqpt0n97l60jjcy868h0tnv3meez0d0hfgxjgnavzq
static immutable GI = KeyPair(PublicKey(Point([204, 141, 105, 85, 177, 12, 33, 81, 228, 70, 64, 21, 190, 101, 247, 244, 249, 75, 4, 62, 143, 119, 174, 108, 142, 243, 145, 61, 175, 186, 80, 105])), SecretKey(Scalar([73, 134, 144, 200, 64, 11, 160, 196, 137, 146, 160, 98, 35, 251, 193, 92, 106, 204, 106, 167, 174, 60, 230, 196, 254, 32, 111, 232, 143, 142, 168, 9])));
/// GJ("gdgj"): gdgj1xrxf66swddzsdsvl5rjgr9jevqusdq3rcet5mczgcfwgrulmn4yu6fzutla
static immutable GJ = KeyPair(PublicKey(Point([204, 157, 106, 14, 107, 69, 6, 193, 159, 160, 228, 129, 150, 89, 96, 57, 6, 130, 35, 198, 87, 77, 224, 72, 194, 92, 129, 243, 251, 157, 73, 205])), SecretKey(Scalar([169, 97, 2, 60, 67, 203, 248, 116, 89, 60, 132, 217, 154, 96, 130, 174, 208, 58, 25, 55, 5, 164, 228, 190, 125, 87, 72, 158, 137, 77, 242, 6])));
/// GK("gdgk"): gdgk1xrx2668z60vcjcl9qqpsuwdwhxz4qh9xmpw948z7n9m89fjl8wmsct7qdxk
static immutable GK = KeyPair(PublicKey(Point([204, 173, 104, 226, 211, 217, 137, 99, 229, 0, 3, 14, 57, 174, 185, 133, 80, 92, 166, 216, 92, 90, 156, 94, 153, 118, 114, 166, 95, 59, 183, 12])), SecretKey(Scalar([64, 48, 219, 184, 134, 214, 249, 209, 54, 243, 155, 190, 151, 96, 238, 207, 107, 155, 136, 72, 147, 120, 147, 163, 16, 44, 51, 146, 162, 28, 133, 15])));
/// GL("gdgl"): gdgl1xrxt66k7wswup5h95hf97urujg4cakdrl2uusrcqg4z3q8mqkn9t2yudzze
static immutable GL = KeyPair(PublicKey(Point([204, 189, 106, 222, 116, 29, 192, 210, 229, 165, 210, 95, 112, 124, 146, 43, 142, 217, 163, 250, 185, 200, 15, 0, 69, 69, 16, 31, 96, 180, 202, 181])), SecretKey(Scalar([24, 221, 196, 115, 165, 59, 123, 39, 109, 187, 156, 100, 192, 43, 15, 162, 172, 55, 170, 147, 11, 41, 32, 185, 141, 67, 241, 217, 12, 147, 20, 7])));
/// GM("gdgm"): gdgm1xrxv66r8tf9396lav0xlxmj30ud93gex0rs383cst9cs0kl5wjck63zydfk
static immutable GM = KeyPair(PublicKey(Point([204, 205, 104, 103, 90, 75, 18, 235, 253, 99, 205, 243, 110, 81, 127, 26, 88, 163, 38, 120, 225, 19, 199, 16, 89, 113, 7, 219, 244, 116, 177, 109])), SecretKey(Scalar([133, 176, 45, 152, 1, 217, 88, 126, 112, 145, 240, 201, 30, 10, 208, 204, 140, 58, 230, 187, 60, 23, 56, 182, 6, 120, 158, 201, 222, 221, 241, 6])));
/// GN("gdgn"): gdgn1xrxd66nelyedk69gap6u52ryh673ne5um248687nrupd7ajgtp637rqvc45
static immutable GN = KeyPair(PublicKey(Point([204, 221, 106, 121, 249, 50, 219, 104, 168, 232, 117, 202, 40, 100, 190, 189, 25, 230, 156, 218, 170, 125, 31, 211, 31, 2, 223, 118, 72, 88, 117, 31])), SecretKey(Scalar([0, 104, 119, 148, 118, 164, 244, 19, 207, 23, 105, 149, 68, 73, 225, 55, 115, 204, 28, 117, 253, 134, 181, 121, 65, 217, 207, 216, 202, 166, 170, 8])));
/// GO("gdgo"): gdgo1xrxw66hhwr6hdwryjx29wutt8mv66kdzz9dkra55e62qvsp57akszxk43hv
static immutable GO = KeyPair(PublicKey(Point([204, 237, 106, 247, 112, 245, 118, 184, 100, 145, 148, 87, 113, 107, 62, 217, 173, 89, 162, 17, 91, 97, 246, 148, 206, 148, 6, 64, 52, 247, 109, 1])), SecretKey(Scalar([197, 150, 160, 59, 29, 47, 196, 76, 123, 38, 89, 133, 221, 253, 242, 212, 216, 209, 53, 144, 203, 85, 100, 5, 198, 103, 93, 135, 40, 39, 193, 1])));
/// GP("gdgp"): gdgp1xrx066slw6ghux62fmg5fg5k7ckj79neqt2dm9wemgvz2l3ymhe9j5307kf
static immutable GP = KeyPair(PublicKey(Point([204, 253, 106, 31, 118, 145, 126, 27, 74, 78, 209, 68, 162, 150, 246, 45, 47, 22, 121, 2, 212, 221, 149, 217, 218, 24, 37, 126, 36, 221, 242, 89])), SecretKey(Scalar([214, 203, 196, 181, 53, 181, 72, 149, 30, 58, 213, 115, 148, 151, 11, 44, 212, 30, 124, 201, 6, 185, 39, 224, 131, 89, 105, 14, 248, 82, 190, 9])));
/// GQ("gdgq"): gdgq1xrxs66vvnuz236dlh9cpwtptmdjyjdwjs96apwzgrcx7yx0jfpp7qnx7627
static immutable GQ = KeyPair(PublicKey(Point([205, 13, 105, 140, 159, 4, 168, 233, 191, 185, 112, 23, 44, 43, 219, 100, 73, 53, 210, 129, 117, 208, 184, 72, 30, 13, 226, 25, 242, 72, 67, 224])), SecretKey(Scalar([37, 248, 241, 5, 150, 122, 142, 99, 234, 184, 232, 47, 15, 66, 234, 162, 247, 219, 141, 227, 152, 45, 201, 233, 31, 44, 7, 163, 9, 123, 199, 7])));
/// GR("gdgr"): gdgr1xrx366rae6vvz9d5635xwl9wk3v36mujyypfrjj904jpum6eazgcxlqa3ld
static immutable GR = KeyPair(PublicKey(Point([205, 29, 104, 125, 206, 152, 193, 21, 180, 212, 104, 103, 124, 174, 180, 89, 29, 111, 146, 33, 2, 145, 202, 69, 125, 100, 30, 111, 89, 232, 145, 131])), SecretKey(Scalar([131, 251, 223, 108, 176, 159, 43, 41, 253, 30, 189, 247, 114, 169, 68, 55, 7, 197, 241, 182, 155, 78, 115, 135, 36, 197, 195, 230, 9, 143, 75, 14])));
/// GS("gdgs"): gdgs1xrxj6653tnvfw0t8duy8lt242e9ue8h2nhhx6g5dhrlaqswkph4axusavku
static immutable GS = KeyPair(PublicKey(Point([205, 45, 106, 145, 92, 216, 151, 61, 103, 111, 8, 127, 173, 85, 86, 75, 204, 158, 234, 157, 238, 109, 34, 141, 184, 255, 208, 65, 214, 13, 235, 211])), SecretKey(Scalar([47, 68, 72, 69, 24, 239, 120, 199, 133, 67, 236, 156, 131, 181, 40, 144, 23, 82, 204, 42, 217, 187, 251, 226, 202, 237, 99, 3, 226, 68, 150, 4])));
/// GT("gdgt"): gdgt1xrxn66zgpy6qc6gs6qxzmvsv8cp7kd7ww64y5j6jh6zfd07q0ndu7cm7h2t
static immutable GT = KeyPair(PublicKey(Point([205, 61, 104, 72, 9, 52, 12, 105, 16, 208, 12, 45, 178, 12, 62, 3, 235, 55, 206, 118, 170, 74, 75, 82, 190, 132, 150, 191, 192, 124, 219, 207])), SecretKey(Scalar([233, 238, 128, 57, 186, 132, 241, 87, 112, 185, 133, 249, 11, 251, 29, 143, 205, 234, 12, 0, 208, 114, 233, 164, 205, 64, 75, 17, 204, 93, 158, 15])));
/// GU("gdgu"): gdgu1xrx5668lwknr3xcunkdf3hfvr6qa4twx0llsgg7wsl6x3cpgddmmj6v6wqh
static immutable GU = KeyPair(PublicKey(Point([205, 77, 104, 255, 117, 166, 56, 155, 28, 157, 154, 152, 221, 44, 30, 129, 218, 173, 198, 127, 255, 4, 35, 206, 135, 244, 104, 224, 40, 107, 119, 185])), SecretKey(Scalar([164, 155, 164, 119, 159, 85, 246, 10, 194, 228, 85, 222, 243, 25, 182, 120, 51, 142, 176, 57, 121, 178, 18, 219, 236, 40, 40, 173, 69, 197, 42, 2])));
/// GV("gdgv"): gdgv1xrx4668es0aqaqn2lxqgvuk70t8xpqh6xewddyqq9pk5z68eule0qc27f3e
static immutable GV = KeyPair(PublicKey(Point([205, 93, 104, 249, 131, 250, 14, 130, 106, 249, 128, 134, 114, 222, 122, 206, 96, 130, 250, 54, 92, 214, 144, 0, 40, 109, 65, 104, 249, 231, 242, 240])), SecretKey(Scalar([150, 46, 250, 201, 243, 104, 192, 239, 214, 70, 233, 76, 117, 232, 145, 6, 233, 54, 255, 182, 75, 147, 14, 178, 40, 172, 224, 112, 129, 136, 151, 6])));
/// GW("gdgw"): gdgw1xrxk66mj822qcf28glm446r9hrnzzkv54elskjc825yvvgahuumhyrd5v0j
static immutable GW = KeyPair(PublicKey(Point([205, 109, 107, 114, 58, 148, 12, 37, 71, 71, 247, 90, 232, 101, 184, 230, 33, 89, 148, 174, 127, 11, 75, 7, 85, 8, 198, 35, 183, 231, 55, 114])), SecretKey(Scalar([9, 194, 234, 22, 13, 176, 175, 55, 175, 53, 190, 195, 181, 120, 61, 87, 113, 98, 119, 25, 65, 103, 89, 49, 9, 29, 177, 63, 169, 149, 226, 7])));
/// GX("gdgx"): gdgx1xrxh66p0vsvqnvd6kr2tlye0c7qlnv6xq047asc0605z65yr6kgy7990uya
static immutable GX = KeyPair(PublicKey(Point([205, 125, 104, 47, 100, 24, 9, 177, 186, 176, 212, 191, 147, 47, 199, 129, 249, 179, 70, 3, 235, 238, 195, 15, 211, 232, 45, 80, 131, 213, 144, 79])), SecretKey(Scalar([187, 133, 114, 20, 245, 191, 254, 56, 75, 30, 44, 45, 13, 0, 79, 124, 252, 223, 153, 121, 160, 182, 150, 32, 29, 56, 145, 103, 17, 196, 225, 15])));
/// GY("gdgy"): gdgy1xrxc669g6wf0s4gkj0satfuxxdps5sk3qa4ks8s5ly3yk69stf2eslse3ns
static immutable GY = KeyPair(PublicKey(Point([205, 141, 104, 168, 211, 146, 248, 85, 22, 147, 225, 213, 167, 134, 51, 67, 10, 66, 209, 7, 107, 104, 30, 20, 249, 34, 75, 104, 176, 90, 85, 152])), SecretKey(Scalar([92, 251, 239, 15, 170, 62, 35, 15, 247, 103, 174, 67, 64, 95, 146, 39, 205, 224, 205, 164, 185, 212, 142, 209, 234, 222, 234, 27, 122, 95, 214, 15])));
/// GZ("gdgz"): gdgz1xrxe66ue7zh37gcrqazzwmx3z8ndexsj8y9fpxf358ter4yldld2kttqzd8
static immutable GZ = KeyPair(PublicKey(Point([205, 157, 107, 153, 240, 175, 31, 35, 3, 7, 68, 39, 108, 209, 17, 230, 220, 154, 18, 57, 10, 144, 153, 49, 161, 215, 145, 212, 159, 111, 218, 171])), SecretKey(Scalar([193, 210, 173, 198, 121, 167, 253, 3, 102, 160, 203, 7, 34, 251, 253, 84, 2, 8, 208, 38, 33, 14, 157, 174, 138, 15, 117, 60, 248, 147, 170, 9])));
/// HA("gdha"): gdha1xr8q66jvs4xye4yx80vv0rrv7gh0quue3jrntl7tkseagj3t077672thzyy
static immutable HA = KeyPair(PublicKey(Point([206, 13, 106, 76, 133, 76, 76, 212, 134, 59, 216, 199, 140, 108, 242, 46, 240, 115, 153, 140, 135, 53, 255, 203, 180, 51, 212, 74, 43, 127, 189, 175])), SecretKey(Scalar([102, 50, 8, 178, 174, 49, 45, 105, 219, 151, 45, 29, 14, 240, 18, 232, 168, 65, 253, 186, 86, 231, 4, 252, 94, 242, 91, 85, 22, 31, 108, 7])));
/// HB("gdhb"): gdhb1xr8p66enrg38qshzn6slnqe3fye6g6xa42kj8hm364yn238ks5ywcktgpjz
static immutable HB = KeyPair(PublicKey(Point([206, 29, 107, 51, 26, 34, 112, 66, 226, 158, 161, 249, 131, 49, 73, 51, 164, 104, 221, 170, 173, 35, 223, 113, 213, 73, 53, 68, 246, 133, 8, 236])), SecretKey(Scalar([12, 226, 2, 68, 74, 60, 236, 224, 28, 122, 157, 190, 105, 122, 176, 54, 141, 52, 139, 17, 126, 157, 181, 7, 38, 90, 127, 29, 18, 148, 24, 11])));
/// HC("gdhc"): gdhc1xr8z66s0dcagyd57ykfwm3yplgv4x6zasf42hxn5gkmx0lxjtceq7ck26zr
static immutable HC = KeyPair(PublicKey(Point([206, 45, 106, 15, 110, 58, 130, 54, 158, 37, 146, 237, 196, 129, 250, 25, 83, 104, 93, 130, 106, 171, 154, 116, 69, 182, 103, 252, 210, 94, 50, 15])), SecretKey(Scalar([249, 101, 64, 163, 44, 184, 126, 143, 117, 140, 144, 175, 180, 246, 161, 158, 229, 118, 92, 127, 147, 108, 158, 221, 121, 100, 250, 78, 244, 205, 80, 0])));
/// HD("gdhd"): gdhd1xr8r66fcuywd6kp7y9ywslwqlsf8rxtajt8pw53rj39wxfwvkxp2679qk85
static immutable HD = KeyPair(PublicKey(Point([206, 61, 105, 56, 225, 28, 221, 88, 62, 33, 72, 232, 125, 192, 252, 18, 113, 153, 125, 146, 206, 23, 82, 35, 148, 74, 227, 37, 204, 177, 130, 173])), SecretKey(Scalar([90, 226, 255, 89, 58, 97, 62, 173, 41, 86, 31, 83, 10, 239, 244, 70, 108, 245, 200, 178, 110, 31, 83, 57, 241, 102, 139, 76, 190, 34, 213, 15])));
/// HE("gdhe"): gdhe1xr8y66e3rjm0fpj9s59r44l8nplfnplhhj6pya0cg5ejsr3ues92j793ejn
static immutable HE = KeyPair(PublicKey(Point([206, 77, 107, 49, 28, 182, 244, 134, 69, 133, 10, 58, 215, 231, 152, 126, 153, 135, 247, 188, 180, 18, 117, 248, 69, 51, 40, 14, 60, 204, 10, 169])), SecretKey(Scalar([238, 253, 213, 184, 8, 70, 176, 64, 68, 118, 251, 179, 221, 43, 107, 126, 82, 154, 23, 116, 55, 31, 159, 139, 120, 19, 86, 170, 54, 62, 186, 3])));
/// HF("gdhf"): gdhf1xr8966pz0jyxgxrjatp6tuplnhzmaulj9rsuahrxjcr5cu8jxh2hsmyrgw3
static immutable HF = KeyPair(PublicKey(Point([206, 93, 104, 34, 124, 136, 100, 24, 114, 234, 195, 165, 240, 63, 157, 197, 190, 243, 242, 40, 225, 206, 220, 102, 150, 7, 76, 112, 242, 53, 213, 120])), SecretKey(Scalar([206, 72, 161, 39, 216, 123, 252, 29, 226, 241, 194, 235, 75, 54, 39, 139, 208, 241, 180, 24, 175, 195, 98, 90, 236, 12, 109, 252, 0, 115, 68, 9])));
/// HG("gdhg"): gdhg1xr8x66qtpp9fd6w8wtmwk9e9k3e7gur0vvjs9axd4gxm36avm8cxc95l6yz
static immutable HG = KeyPair(PublicKey(Point([206, 109, 104, 11, 8, 74, 150, 233, 199, 114, 246, 235, 23, 37, 180, 115, 228, 112, 111, 99, 37, 2, 244, 205, 170, 13, 184, 235, 172, 217, 240, 108])), SecretKey(Scalar([11, 156, 7, 36, 49, 244, 125, 153, 95, 8, 231, 230, 182, 168, 6, 223, 180, 232, 121, 57, 217, 183, 65, 165, 233, 139, 68, 98, 180, 69, 139, 13])));
/// HH("gdhh"): gdhh1xr88665hn7nlz60230tc80ymq6r3mvzhvjzx9sg3lnkjmqy0w4ne2znealk
static immutable HH = KeyPair(PublicKey(Point([206, 125, 106, 151, 159, 167, 241, 105, 234, 139, 215, 131, 188, 155, 6, 135, 29, 176, 87, 100, 132, 98, 193, 17, 252, 237, 45, 128, 143, 117, 103, 149])), SecretKey(Scalar([74, 187, 177, 134, 148, 53, 171, 238, 54, 103, 119, 70, 167, 34, 82, 1, 191, 56, 137, 101, 202, 97, 50, 206, 204, 141, 178, 66, 225, 164, 8, 10])));
/// HI("gdhi"): gdhi1xr8g66r5xa9qj5dcpp322pnk9706k8rvlhsynx9qk8lpeasw85022kxs82f
static immutable HI = KeyPair(PublicKey(Point([206, 141, 104, 116, 55, 74, 9, 81, 184, 8, 98, 165, 6, 118, 47, 159, 171, 28, 108, 253, 224, 73, 152, 160, 177, 254, 28, 246, 14, 61, 30, 165])), SecretKey(Scalar([197, 191, 177, 53, 29, 111, 169, 56, 103, 115, 172, 135, 153, 238, 232, 107, 30, 9, 201, 124, 29, 169, 232, 240, 200, 208, 34, 115, 45, 250, 127, 7])));
/// HJ("gdhj"): gdhj1xr8f66scu70kgdwn2q7ejkmvh9q7ywcl0zejajujj7xpkzeemj2mxvrrehr
static immutable HJ = KeyPair(PublicKey(Point([206, 157, 106, 24, 231, 159, 100, 53, 211, 80, 61, 153, 91, 108, 185, 65, 226, 59, 31, 120, 179, 46, 203, 146, 151, 140, 27, 11, 57, 220, 149, 179])), SecretKey(Scalar([251, 100, 213, 197, 50, 44, 98, 75, 180, 214, 22, 4, 152, 227, 104, 242, 116, 72, 104, 255, 252, 117, 73, 218, 95, 229, 213, 149, 21, 8, 144, 3])));
/// HK("gdhk"): gdhk1xr8266s8tdpjg02xlns6zmgrl4h3nmkp3u297j3zna2c3qdw3vwq2p7t0ny
static immutable HK = KeyPair(PublicKey(Point([206, 173, 106, 7, 91, 67, 36, 61, 70, 252, 225, 161, 109, 3, 253, 111, 25, 238, 193, 143, 20, 95, 74, 34, 159, 85, 136, 129, 174, 139, 28, 5])), SecretKey(Scalar([35, 151, 241, 86, 102, 181, 89, 132, 197, 194, 240, 57, 81, 230, 28, 157, 9, 12, 13, 245, 49, 48, 164, 27, 171, 108, 13, 119, 61, 172, 231, 3])));
/// HL("gdhl"): gdhl1xr8t6603zpfupf7q404hp3q72zxrdjrwm26yf93ymc8exvka9lqt70vrl8y
static immutable HL = KeyPair(PublicKey(Point([206, 189, 105, 241, 16, 83, 192, 167, 192, 171, 235, 112, 196, 30, 80, 140, 54, 200, 110, 218, 180, 68, 150, 36, 222, 15, 147, 50, 221, 47, 192, 191])), SecretKey(Scalar([98, 153, 127, 199, 218, 80, 13, 194, 216, 16, 126, 44, 122, 47, 181, 220, 221, 242, 25, 164, 161, 166, 202, 176, 215, 86, 72, 94, 192, 200, 129, 11])));
/// HM("gdhm"): gdhm1xr8v66y2lr0qp86cd42hr23t490s6swsgde2unq69hdl2v2e5hdx2mddkgk
static immutable HM = KeyPair(PublicKey(Point([206, 205, 104, 138, 248, 222, 0, 159, 88, 109, 85, 113, 170, 43, 169, 95, 13, 65, 208, 67, 114, 174, 76, 26, 45, 219, 245, 49, 89, 165, 218, 101])), SecretKey(Scalar([63, 250, 69, 53, 2, 132, 187, 15, 223, 60, 222, 6, 78, 102, 10, 255, 62, 17, 189, 177, 191, 250, 11, 90, 29, 248, 7, 205, 162, 113, 148, 9])));
/// HN("gdhn"): gdhn1xr8d664eaurqdpysqy9dfw2y29p4w7wpcxlc2sajnam3g6mz22exjjd37h9
static immutable HN = KeyPair(PublicKey(Point([206, 221, 106, 185, 239, 6, 6, 132, 144, 1, 10, 212, 185, 68, 81, 67, 87, 121, 193, 193, 191, 133, 67, 178, 159, 119, 20, 107, 98, 82, 178, 105])), SecretKey(Scalar([7, 202, 89, 148, 227, 171, 214, 150, 191, 167, 176, 152, 222, 95, 162, 139, 178, 7, 163, 69, 225, 205, 181, 21, 197, 130, 22, 71, 195, 38, 122, 14])));
/// HO("gdho"): gdho1xr8w665lwwnfj28tucp2nftkl44rhstsnyzzjmp6fhf7mu0pz68qc4rmyg9
static immutable HO = KeyPair(PublicKey(Point([206, 237, 106, 159, 115, 166, 153, 40, 235, 230, 2, 169, 165, 118, 253, 106, 59, 193, 112, 153, 4, 41, 108, 58, 77, 211, 237, 241, 225, 22, 142, 12])), SecretKey(Scalar([80, 68, 46, 96, 202, 85, 242, 224, 107, 186, 147, 138, 184, 212, 190, 176, 162, 5, 218, 156, 118, 238, 169, 21, 32, 147, 227, 66, 199, 4, 211, 7])));
/// HP("gdhp"): gdhp1xr8066qpesfym2al0f0nxskgmhne9su4kwvz4m468ha5d53awu4n7qk0zex
static immutable HP = KeyPair(PublicKey(Point([206, 253, 104, 1, 204, 18, 77, 171, 191, 122, 95, 51, 66, 200, 221, 231, 146, 195, 149, 179, 152, 42, 238, 186, 61, 251, 70, 210, 61, 119, 43, 63])), SecretKey(Scalar([88, 122, 22, 117, 173, 88, 119, 122, 104, 184, 133, 167, 147, 160, 127, 167, 241, 9, 66, 35, 56, 180, 47, 197, 51, 44, 93, 157, 105, 2, 16, 12])));
/// HQ("gdhq"): gdhq1xr8s66gzevyjtmmea6nzw6dz95e3c82n8w2fxg446hnw38qe4uhsj8wdlmh
static immutable HQ = KeyPair(PublicKey(Point([207, 13, 105, 2, 203, 9, 37, 239, 121, 238, 166, 39, 105, 162, 45, 51, 28, 29, 83, 59, 148, 147, 34, 181, 213, 230, 232, 156, 25, 175, 47, 9])), SecretKey(Scalar([165, 141, 160, 80, 193, 119, 83, 224, 255, 69, 114, 166, 172, 84, 183, 198, 165, 82, 214, 107, 24, 95, 9, 124, 124, 163, 48, 8, 59, 187, 134, 10])));
/// HR("gdhr"): gdhr1xr83660ckkk64qp27az026rhq247jftvkxmu5dqn93ttnrn3hguwvgcuk06
static immutable HR = KeyPair(PublicKey(Point([207, 29, 105, 248, 181, 173, 170, 128, 42, 247, 68, 245, 104, 119, 2, 171, 233, 37, 108, 177, 183, 202, 52, 19, 44, 86, 185, 142, 113, 186, 56, 230])), SecretKey(Scalar([33, 135, 219, 5, 178, 160, 96, 189, 227, 146, 159, 159, 52, 126, 192, 1, 186, 234, 244, 98, 127, 223, 55, 184, 80, 66, 189, 192, 93, 184, 40, 15])));
/// HS("gdhs"): gdhs1xr8j66ej30dn8vsht5xr37cn0k6f4q030use6209rug7rvklqphuumgw638
static immutable HS = KeyPair(PublicKey(Point([207, 45, 107, 50, 139, 219, 51, 178, 23, 93, 12, 56, 251, 19, 125, 180, 154, 129, 241, 127, 33, 157, 41, 229, 31, 17, 225, 178, 223, 0, 111, 206])), SecretKey(Scalar([226, 200, 36, 199, 101, 101, 77, 107, 229, 53, 22, 12, 131, 165, 38, 92, 162, 109, 225, 47, 115, 82, 196, 163, 5, 253, 126, 195, 172, 194, 111, 10])));
/// HT("gdht"): gdht1xr8n66h64pkl58a0rwuycy7uau0mq9z95zszj5pkqlv46epgwjq86y9a62f
static immutable HT = KeyPair(PublicKey(Point([207, 61, 106, 250, 168, 109, 250, 31, 175, 27, 184, 76, 19, 220, 239, 31, 176, 20, 69, 160, 160, 41, 80, 54, 7, 217, 93, 100, 40, 116, 128, 125])), SecretKey(Scalar([73, 182, 211, 236, 27, 169, 244, 232, 120, 127, 162, 53, 254, 130, 66, 104, 4, 158, 137, 4, 58, 180, 142, 220, 32, 54, 135, 4, 217, 20, 90, 9])));
/// HU("gdhu"): gdhu1xr8566tjappyr79q04d7vhzwkydl8h7ppqmpwgyy840nsrdr7rftx9uzt7y
static immutable HU = KeyPair(PublicKey(Point([207, 77, 105, 114, 232, 66, 65, 248, 160, 125, 91, 230, 92, 78, 177, 27, 243, 223, 193, 8, 54, 23, 32, 132, 61, 95, 56, 13, 163, 240, 210, 179])), SecretKey(Scalar([37, 197, 229, 60, 88, 8, 133, 204, 31, 64, 129, 95, 209, 158, 155, 23, 203, 120, 209, 200, 165, 240, 253, 223, 92, 119, 249, 53, 91, 6, 127, 7])));
/// HV("gdhv"): gdhv1xr84660rrwe2xdpd9g6eqwmmqdty79j3l67a9hjlf7q692nnqdd9qskjcjr
static immutable HV = KeyPair(PublicKey(Point([207, 93, 105, 227, 27, 178, 163, 52, 45, 42, 53, 144, 59, 123, 3, 86, 79, 22, 81, 254, 189, 210, 222, 95, 79, 129, 162, 170, 115, 3, 90, 80])), SecretKey(Scalar([239, 20, 159, 238, 101, 230, 104, 60, 152, 229, 13, 51, 103, 113, 209, 29, 210, 205, 195, 113, 121, 157, 34, 247, 29, 21, 148, 69, 119, 189, 161, 3])));
/// HW("gdhw"): gdhw1xr8k664pgvf0y44wscs3nhph2685nwk5aah0rmnqn3vlu4ymqtrz7rmy2ax
static immutable HW = KeyPair(PublicKey(Point([207, 109, 106, 161, 67, 18, 242, 86, 174, 134, 33, 25, 220, 55, 86, 143, 73, 186, 212, 239, 110, 241, 238, 96, 156, 89, 254, 84, 155, 2, 198, 47])), SecretKey(Scalar([45, 188, 37, 161, 59, 190, 92, 43, 226, 230, 35, 11, 99, 44, 106, 251, 175, 144, 225, 53, 57, 5, 32, 176, 181, 93, 25, 217, 72, 139, 176, 1])));
/// HX("gdhx"): gdhx1xr8h6654x4quyewfp0akd4mdjn2elkczfrxywpuagywkrxhaa9uwq6xevg9
static immutable HX = KeyPair(PublicKey(Point([207, 125, 106, 149, 53, 65, 194, 101, 201, 11, 251, 102, 215, 109, 148, 213, 159, 219, 2, 72, 204, 71, 7, 157, 65, 29, 97, 154, 253, 233, 120, 224])), SecretKey(Scalar([77, 200, 138, 39, 178, 230, 182, 158, 122, 232, 8, 250, 34, 136, 43, 126, 127, 135, 153, 80, 179, 234, 7, 125, 11, 183, 81, 68, 217, 151, 230, 15])));
/// HY("gdhy"): gdhy1xr8c66haqryfv7p4urcn2l26p5hrhg3fetyphc3s535p0jeqy45jygsfefh
static immutable HY = KeyPair(PublicKey(Point([207, 141, 106, 253, 0, 200, 150, 120, 53, 224, 241, 53, 125, 90, 13, 46, 59, 162, 41, 202, 200, 27, 226, 48, 164, 104, 23, 203, 32, 37, 105, 34])), SecretKey(Scalar([41, 76, 117, 176, 164, 149, 223, 81, 50, 239, 235, 229, 31, 59, 80, 134, 192, 224, 221, 152, 192, 157, 99, 123, 38, 120, 10, 156, 176, 54, 5, 12])));
/// HZ("gdhz"): gdhz1xr8e66awqgdzzwm0y3ra8pxvttfv78lk7a2g2ncyxxrkqry3fsnt2llzq7p
static immutable HZ = KeyPair(PublicKey(Point([207, 157, 107, 174, 2, 26, 33, 59, 111, 36, 71, 211, 132, 204, 90, 210, 207, 31, 246, 247, 84, 133, 79, 4, 49, 135, 96, 12, 145, 76, 38, 181])), SecretKey(Scalar([12, 213, 128, 143, 169, 83, 200, 241, 47, 168, 220, 211, 107, 239, 181, 225, 38, 81, 171, 211, 61, 133, 189, 180, 120, 112, 252, 226, 142, 218, 218, 1])));
/// IA("gdia"): gdia1xrgq6607dulyra5r9dw0ha6883va0jghdzk67er49h3ysm7k222ruhure6s
static immutable IA = KeyPair(PublicKey(Point([208, 13, 105, 254, 111, 62, 65, 246, 131, 43, 92, 251, 247, 71, 60, 89, 215, 201, 23, 104, 173, 175, 100, 117, 45, 226, 72, 111, 214, 82, 148, 62])), SecretKey(Scalar([156, 76, 102, 218, 138, 54, 32, 28, 182, 5, 154, 189, 191, 229, 123, 74, 168, 215, 64, 190, 193, 35, 222, 221, 254, 99, 15, 94, 70, 32, 9, 13])));
/// IB("gdib"): gdib1xrgp66c2wrqw0qg2w48xfwdpygt4c9hevfum7zx9twy8r7g20ew8s7elghq
static immutable IB = KeyPair(PublicKey(Point([208, 29, 107, 10, 112, 192, 231, 129, 10, 117, 78, 100, 185, 161, 34, 23, 92, 22, 249, 98, 121, 191, 8, 197, 91, 136, 113, 249, 10, 126, 92, 120])), SecretKey(Scalar([67, 231, 95, 53, 65, 73, 28, 193, 160, 40, 33, 151, 51, 0, 91, 249, 46, 203, 156, 207, 220, 77, 247, 162, 95, 170, 218, 94, 250, 105, 51, 3])));
/// IC("gdic"): gdic1xrgz66drg7vqx7ppyrv4kngng66zn9er8nm67pk39pstrme9sj6vwq9xkhw
static immutable IC = KeyPair(PublicKey(Point([208, 45, 105, 163, 71, 152, 3, 120, 33, 32, 217, 91, 77, 19, 70, 180, 41, 151, 35, 60, 247, 175, 6, 209, 40, 96, 177, 239, 37, 132, 180, 199])), SecretKey(Scalar([185, 166, 199, 20, 232, 232, 188, 176, 80, 200, 243, 159, 73, 6, 133, 142, 31, 120, 68, 117, 215, 98, 71, 20, 179, 75, 235, 225, 214, 117, 225, 7])));
/// ID("gdid"): gdid1xrgr66gdm5je646x70l5ar6qkhun0hg3yy2eh7tf8xxlmlt9fgjd29nucys
static immutable ID = KeyPair(PublicKey(Point([208, 61, 105, 13, 221, 37, 157, 87, 70, 243, 255, 78, 143, 64, 181, 249, 55, 221, 17, 33, 21, 155, 249, 105, 57, 141, 253, 253, 101, 74, 36, 213])), SecretKey(Scalar([129, 76, 90, 133, 32, 93, 32, 173, 255, 65, 216, 61, 29, 233, 46, 214, 253, 118, 69, 18, 109, 61, 191, 219, 240, 172, 112, 240, 138, 164, 136, 12])));
/// IE("gdie"): gdie1xrgy66chhx25l2c77fnwxr05yu83qqaxx2ea9ap9qpmeer2x872aqsx9vw6
static immutable IE = KeyPair(PublicKey(Point([208, 77, 107, 23, 185, 149, 79, 171, 30, 242, 102, 227, 13, 244, 39, 15, 16, 3, 166, 50, 179, 210, 244, 37, 0, 119, 156, 141, 70, 63, 149, 208])), SecretKey(Scalar([30, 192, 85, 101, 215, 91, 189, 73, 21, 255, 135, 217, 168, 136, 58, 185, 151, 64, 65, 110, 4, 240, 211, 44, 140, 219, 183, 221, 37, 71, 82, 8])));
/// IF("gdif"): gdif1xrg96658wp3nltds3fjww26h5fyjp522mcazdxj3yvhplhzegphvk42uvar
static immutable IF = KeyPair(PublicKey(Point([208, 93, 106, 135, 112, 99, 63, 173, 176, 138, 100, 231, 43, 87, 162, 73, 32, 209, 74, 222, 58, 38, 154, 81, 35, 46, 31, 220, 89, 64, 110, 203])), SecretKey(Scalar([104, 111, 122, 9, 106, 235, 212, 65, 66, 121, 100, 98, 217, 144, 217, 181, 19, 81, 122, 214, 159, 219, 17, 169, 93, 50, 11, 204, 181, 24, 1, 15])));
/// IG("gdig"): gdig1xrgx663xl6udlhq0pzzga5pndg858h0yurc8xwkfm7pk4h2m23r5j9au662
static immutable IG = KeyPair(PublicKey(Point([208, 109, 106, 38, 254, 184, 223, 220, 15, 8, 132, 142, 208, 51, 106, 15, 67, 221, 228, 224, 240, 115, 58, 201, 223, 131, 106, 221, 91, 84, 71, 73])), SecretKey(Scalar([228, 29, 60, 18, 172, 89, 184, 248, 72, 26, 86, 104, 124, 202, 145, 206, 5, 217, 247, 180, 108, 74, 140, 192, 192, 213, 42, 10, 111, 30, 234, 0])));
/// IH("gdih"): gdih1xrg866h0r6spn9njuwrvkedltua7mzharmrzufjwev0d42pu967w55w3pzp
static immutable IH = KeyPair(PublicKey(Point([208, 125, 106, 239, 30, 160, 25, 150, 114, 227, 134, 203, 101, 191, 95, 59, 237, 138, 253, 30, 198, 46, 38, 78, 203, 30, 218, 168, 60, 46, 188, 234])), SecretKey(Scalar([98, 140, 197, 57, 226, 227, 46, 125, 236, 112, 59, 149, 72, 202, 148, 202, 72, 107, 135, 121, 223, 59, 180, 145, 174, 78, 160, 70, 176, 6, 2, 6])));
/// II("gdii"): gdii1xrgg660j0ahtvtc0s4s274fqpjtylc6lhfr2h2gyk7zu3dvht79q5meyyvv
static immutable II = KeyPair(PublicKey(Point([208, 141, 105, 242, 127, 110, 182, 47, 15, 133, 96, 175, 85, 32, 12, 150, 79, 227, 95, 186, 70, 171, 169, 4, 183, 133, 200, 181, 151, 95, 138, 10])), SecretKey(Scalar([240, 98, 208, 179, 180, 236, 55, 41, 170, 96, 147, 222, 234, 80, 195, 174, 242, 42, 57, 85, 60, 174, 178, 207, 17, 172, 110, 0, 20, 118, 135, 15])));
/// IJ("gdij"): gdij1xrgf66mfuw3ppkw26yvafj7xhsy3nfuxten3dfze7vse85e8lzq0kg9laxu
static immutable IJ = KeyPair(PublicKey(Point([208, 157, 107, 105, 227, 162, 16, 217, 202, 209, 25, 212, 203, 198, 188, 9, 25, 167, 134, 94, 103, 22, 164, 89, 243, 33, 147, 211, 39, 248, 128, 251])), SecretKey(Scalar([77, 105, 161, 135, 200, 196, 135, 57, 82, 82, 100, 70, 135, 35, 54, 254, 224, 156, 28, 170, 180, 129, 28, 62, 115, 251, 238, 248, 17, 45, 185, 11])));
/// IK("gdik"): gdik1xrg26690zy8ptu6vpvtmv29l799qtupjtutq6v4fwcg6jq66hyjxx7qjsdh
static immutable IK = KeyPair(PublicKey(Point([208, 173, 104, 175, 17, 14, 21, 243, 76, 11, 23, 182, 40, 191, 241, 74, 5, 240, 50, 95, 22, 13, 50, 169, 118, 17, 169, 3, 90, 185, 36, 99])), SecretKey(Scalar([10, 10, 177, 51, 47, 203, 16, 147, 9, 72, 110, 112, 134, 180, 178, 159, 118, 158, 85, 68, 84, 159, 131, 85, 79, 255, 69, 102, 188, 139, 95, 11])));
/// IL("gdil"): gdil1xrgt66l0r4kz4m6jq84ywsh5eunly6nvpman0l6076hq483a5rchq0yjnva
static immutable IL = KeyPair(PublicKey(Point([208, 189, 107, 239, 29, 108, 42, 239, 82, 1, 234, 71, 66, 244, 207, 39, 242, 106, 108, 14, 251, 55, 255, 79, 246, 174, 10, 158, 61, 160, 241, 112])), SecretKey(Scalar([6, 44, 93, 19, 153, 42, 118, 41, 50, 81, 134, 105, 85, 42, 48, 50, 17, 45, 99, 50, 25, 163, 127, 68, 135, 31, 107, 16, 3, 181, 239, 13])));
/// IM("gdim"): gdim1xrgv66tw3thnjtzjdd8j8pyc8y43dpacfxyqqfyk29dr544syd63ugrkv04
static immutable IM = KeyPair(PublicKey(Point([208, 205, 105, 110, 138, 239, 57, 44, 82, 107, 79, 35, 132, 152, 57, 43, 22, 135, 184, 73, 136, 0, 36, 150, 81, 90, 58, 86, 176, 35, 117, 30])), SecretKey(Scalar([9, 100, 44, 187, 233, 31, 26, 205, 96, 102, 94, 199, 38, 165, 62, 16, 69, 88, 103, 71, 74, 23, 228, 26, 196, 250, 208, 22, 182, 119, 92, 12])));
/// IN("gdin"): gdin1xrgd66ac3tend8xnw08kkhgz4m25qjcel69u8y8wty9eltjl5fyyg929wrw
static immutable IN = KeyPair(PublicKey(Point([208, 221, 107, 184, 138, 243, 54, 156, 211, 115, 207, 107, 93, 2, 174, 213, 64, 75, 25, 254, 139, 195, 144, 238, 89, 11, 159, 174, 95, 162, 72, 68])), SecretKey(Scalar([25, 154, 241, 205, 8, 102, 90, 160, 135, 206, 41, 42, 194, 28, 103, 194, 12, 213, 79, 214, 71, 35, 250, 177, 250, 81, 66, 243, 3, 137, 239, 4])));
/// IO("gdio"): gdio1xrgw66hw9c26vp29p9f2mkwuxs44ylwkduc5zs3vygxxfcadatjmun3t5xq
static immutable IO = KeyPair(PublicKey(Point([208, 237, 106, 238, 46, 21, 166, 5, 69, 9, 82, 173, 217, 220, 52, 43, 82, 125, 214, 111, 49, 65, 66, 44, 34, 12, 100, 227, 173, 234, 229, 190])), SecretKey(Scalar([103, 106, 99, 252, 97, 40, 139, 49, 67, 150, 119, 187, 208, 101, 80, 227, 5, 99, 21, 221, 20, 66, 15, 41, 116, 246, 239, 146, 131, 238, 206, 9])));
/// IP("gdip"): gdip1xrg06697cnlej3yewfd5jqa2sluf0qc8zu3z8lk8wlxdcpe8g75nznyfz8c
static immutable IP = KeyPair(PublicKey(Point([208, 253, 104, 190, 196, 255, 153, 68, 153, 114, 91, 73, 3, 170, 135, 248, 151, 131, 7, 23, 34, 35, 254, 199, 119, 204, 220, 7, 39, 71, 169, 49])), SecretKey(Scalar([14, 244, 34, 151, 8, 37, 176, 61, 5, 164, 17, 54, 12, 3, 49, 106, 91, 85, 74, 230, 99, 109, 85, 87, 44, 70, 31, 78, 1, 56, 55, 12])));
/// IQ("gdiq"): gdiq1xrgs66ej8za6af5tdjhe8p3h2c5rat7e5mudgt5eccyjcshrglc9qlsxmtx
static immutable IQ = KeyPair(PublicKey(Point([209, 13, 107, 50, 56, 187, 174, 166, 139, 108, 175, 147, 134, 55, 86, 40, 62, 175, 217, 166, 248, 212, 46, 153, 198, 9, 44, 66, 227, 71, 240, 80])), SecretKey(Scalar([231, 57, 111, 227, 173, 181, 62, 28, 2, 249, 168, 94, 56, 111, 241, 49, 90, 78, 18, 130, 129, 60, 47, 112, 183, 87, 68, 54, 215, 76, 131, 6])));
/// IR("gdir"): gdir1xrg366u0ytyckglmml06d6w4kvsfctrezrguhnfzn22q4ynjwp92227nd07
static immutable IR = KeyPair(PublicKey(Point([209, 29, 107, 143, 34, 201, 139, 35, 251, 223, 223, 166, 233, 213, 179, 32, 156, 44, 121, 16, 209, 203, 205, 34, 154, 148, 10, 146, 114, 112, 74, 165])), SecretKey(Scalar([182, 91, 20, 72, 237, 17, 137, 220, 244, 224, 152, 10, 178, 44, 244, 220, 103, 74, 4, 201, 237, 64, 10, 169, 46, 76, 22, 113, 209, 189, 185, 5])));
/// IS("gdis"): gdis1xrgj668wzrd48zjphhyh0ws74ex23pr4sndctee5h3zvyzunrpzrswcl2rw
static immutable IS = KeyPair(PublicKey(Point([209, 45, 104, 238, 16, 219, 83, 138, 65, 189, 201, 119, 186, 30, 174, 76, 168, 132, 117, 132, 219, 133, 231, 52, 188, 68, 194, 11, 147, 24, 68, 56])), SecretKey(Scalar([253, 108, 11, 242, 239, 164, 54, 52, 224, 144, 12, 111, 132, 69, 69, 246, 200, 237, 152, 63, 34, 209, 67, 3, 241, 176, 160, 154, 246, 19, 33, 7])));
/// IT("gdit"): gdit1xrgn66xp9mwv6kl50ytnwrld2p95gnezfkmceuffj29mya5tye8jjdrhefv
static immutable IT = KeyPair(PublicKey(Point([209, 61, 104, 193, 46, 220, 205, 91, 244, 121, 23, 55, 15, 237, 80, 75, 68, 79, 34, 77, 183, 140, 241, 41, 146, 139, 178, 118, 139, 38, 79, 41])), SecretKey(Scalar([138, 178, 117, 6, 102, 255, 141, 253, 97, 128, 63, 54, 124, 110, 228, 151, 10, 77, 128, 126, 26, 3, 213, 147, 20, 32, 34, 202, 64, 16, 80, 14])));
/// IU("gdiu"): gdiu1xrg566yx3j4y3gw649jdh3ewzq6sgcyn9rn8rhpyns7clarxqcqhgsak9ae
static immutable IU = KeyPair(PublicKey(Point([209, 77, 104, 134, 140, 170, 72, 161, 218, 169, 100, 219, 199, 46, 16, 53, 4, 96, 147, 40, 230, 113, 220, 36, 156, 61, 143, 244, 102, 6, 1, 116])), SecretKey(Scalar([7, 141, 163, 206, 41, 81, 151, 33, 221, 226, 183, 25, 16, 226, 155, 199, 144, 157, 5, 32, 1, 190, 43, 30, 87, 40, 7, 189, 15, 66, 87, 8])));
/// IV("gdiv"): gdiv1xrg466whrya8hyqdnaqhzf62ply4cvh2cxe7gynjr8gnsc7urglwczkp69m
static immutable IV = KeyPair(PublicKey(Point([209, 93, 105, 215, 25, 58, 123, 144, 13, 159, 65, 113, 39, 74, 15, 201, 92, 50, 234, 193, 179, 228, 18, 114, 25, 209, 56, 99, 220, 26, 62, 236])), SecretKey(Scalar([69, 233, 205, 90, 126, 40, 64, 241, 176, 89, 189, 171, 234, 169, 154, 193, 231, 238, 82, 240, 15, 138, 197, 70, 210, 111, 233, 46, 137, 186, 31, 0])));
/// IW("gdiw"): gdiw1xrgk66dvpes354rxf76tshug6ws59m3uf479zhsj465rjyw5tgycu4cx7cr
static immutable IW = KeyPair(PublicKey(Point([209, 109, 105, 172, 14, 97, 26, 84, 102, 79, 180, 184, 95, 136, 211, 161, 66, 238, 60, 77, 124, 81, 94, 18, 174, 168, 57, 17, 212, 90, 9, 142])), SecretKey(Scalar([249, 176, 94, 74, 233, 29, 236, 191, 4, 113, 131, 146, 84, 91, 82, 197, 211, 77, 92, 117, 223, 164, 123, 57, 197, 77, 52, 220, 224, 199, 140, 1])));
/// IX("gdix"): gdix1xrgh66j56wpzpt35ygalwff2s255crrajw0dkvpzy6szun8hpy8g7wqn5vv
static immutable IX = KeyPair(PublicKey(Point([209, 125, 106, 84, 211, 130, 32, 174, 52, 34, 59, 247, 37, 42, 130, 169, 76, 12, 125, 147, 158, 219, 48, 34, 38, 160, 46, 76, 247, 9, 14, 143])), SecretKey(Scalar([160, 174, 79, 53, 40, 118, 95, 121, 138, 16, 206, 104, 123, 183, 86, 55, 6, 13, 48, 109, 157, 31, 24, 59, 0, 149, 251, 109, 59, 133, 200, 2])));
/// IY("gdiy"): gdiy1xrgc660r0xpxzlrw6ty3zxzkgmaw9zdavtslj5ltg3lu28aezqd8g4arpwd
static immutable IY = KeyPair(PublicKey(Point([209, 141, 105, 227, 121, 130, 97, 124, 110, 210, 201, 17, 24, 86, 70, 250, 226, 137, 189, 98, 225, 249, 83, 235, 68, 127, 197, 31, 185, 16, 26, 116])), SecretKey(Scalar([159, 105, 11, 172, 202, 87, 15, 206, 202, 200, 96, 65, 75, 231, 35, 215, 145, 199, 156, 64, 104, 169, 20, 42, 145, 227, 240, 129, 112, 221, 172, 11])));
/// IZ("gdiz"): gdiz1xrge665m8cfehyc4ehydmamhh04phncxzxnmnc34lcny723t4wux6llamm6
static immutable IZ = KeyPair(PublicKey(Point([209, 157, 106, 155, 62, 19, 155, 147, 21, 205, 200, 221, 247, 119, 187, 234, 27, 207, 6, 17, 167, 185, 226, 53, 254, 38, 79, 42, 43, 171, 184, 109])), SecretKey(Scalar([243, 60, 121, 235, 67, 125, 216, 76, 188, 19, 181, 246, 104, 159, 154, 107, 47, 193, 90, 109, 195, 156, 133, 156, 211, 53, 215, 50, 113, 197, 19, 11])));
/// JA("gdja"): gdja1xrfq6698f7qcpu8cj6vg7t4dcx555wzp54erptldpf3t77nww3j875n454k
static immutable JA = KeyPair(PublicKey(Point([210, 13, 104, 167, 79, 129, 128, 240, 248, 150, 152, 143, 46, 173, 193, 169, 74, 56, 65, 165, 114, 48, 175, 237, 10, 98, 191, 122, 110, 116, 100, 127])), SecretKey(Scalar([83, 168, 103, 189, 163, 225, 225, 151, 236, 244, 221, 235, 16, 26, 234, 150, 113, 203, 74, 101, 104, 19, 255, 163, 231, 74, 80, 41, 79, 104, 80, 10])));
/// JB("gdjb"): gdjb1xrfp66emyad982lyecya8me62mufzp964xytgnxqwhnq3u0554t85mgpjkh
static immutable JB = KeyPair(PublicKey(Point([210, 29, 107, 59, 39, 90, 83, 171, 228, 206, 9, 211, 239, 58, 86, 248, 145, 4, 186, 169, 136, 180, 76, 192, 117, 230, 8, 241, 244, 165, 86, 122])), SecretKey(Scalar([118, 208, 70, 66, 117, 114, 234, 243, 29, 119, 80, 225, 36, 36, 34, 181, 99, 122, 4, 109, 110, 148, 125, 188, 58, 123, 147, 7, 18, 181, 149, 9])));
/// JC("gdjc"): gdjc1xrfz66r3x35unjv6v3kx74nhz4cheg957kk8eap82s7vlme2wgu6ujs689w
static immutable JC = KeyPair(PublicKey(Point([210, 45, 104, 113, 52, 105, 201, 201, 154, 100, 108, 111, 86, 119, 21, 113, 124, 160, 180, 245, 172, 124, 244, 39, 84, 60, 207, 239, 42, 114, 57, 174])), SecretKey(Scalar([197, 153, 162, 78, 54, 231, 221, 165, 21, 190, 18, 82, 30, 15, 103, 14, 238, 104, 192, 90, 158, 235, 246, 90, 104, 197, 161, 162, 163, 152, 45, 8])));
/// JD("gdjd"): gdjd1xrfr66vqlw3a8et6ns8v99nzklksvy738c6xnp9zcltajszfmqhxc7fdwel
static immutable JD = KeyPair(PublicKey(Point([210, 61, 105, 128, 251, 163, 211, 229, 122, 156, 14, 194, 150, 98, 183, 237, 6, 19, 209, 62, 52, 105, 132, 162, 199, 215, 217, 64, 73, 216, 46, 108])), SecretKey(Scalar([246, 0, 223, 144, 0, 188, 144, 89, 174, 117, 102, 174, 123, 222, 120, 86, 234, 102, 207, 214, 71, 131, 45, 174, 154, 99, 122, 9, 40, 169, 114, 10])));
/// JE("gdje"): gdje1xrfy663gk6qj2e90yk2pc0cyu7evlalxef9d4wya4fah8vz9t4hd5x6n8zt
static immutable JE = KeyPair(PublicKey(Point([210, 77, 106, 40, 182, 129, 37, 100, 175, 37, 148, 28, 63, 4, 231, 178, 207, 247, 230, 202, 74, 218, 184, 157, 170, 123, 115, 176, 69, 93, 110, 218])), SecretKey(Scalar([37, 252, 106, 117, 113, 235, 97, 216, 227, 198, 109, 48, 136, 130, 125, 122, 100, 90, 236, 237, 219, 72, 33, 32, 140, 148, 133, 80, 241, 230, 9, 5])));
/// JF("gdjf"): gdjf1xrf966j5kmahaulvvk08fsrewpl5cd6auj3zslj86ddj3zvft0pt5ucxn7r
static immutable JF = KeyPair(PublicKey(Point([210, 93, 106, 84, 182, 251, 126, 243, 236, 101, 158, 116, 192, 121, 112, 127, 76, 55, 93, 228, 162, 40, 126, 71, 211, 91, 40, 137, 137, 91, 194, 186])), SecretKey(Scalar([223, 176, 115, 114, 180, 246, 237, 237, 23, 198, 26, 232, 33, 5, 178, 183, 54, 126, 197, 98, 224, 151, 82, 92, 189, 117, 252, 47, 237, 225, 243, 1])));
/// JG("gdjg"): gdjg1xrfx66hfutkxs64k383djkdec6r3k5csyf68llk4kejys24j0k8uywfkryu
static immutable JG = KeyPair(PublicKey(Point([210, 109, 106, 233, 226, 236, 104, 106, 182, 137, 226, 217, 89, 185, 198, 135, 27, 83, 16, 34, 116, 127, 254, 213, 182, 100, 72, 42, 178, 125, 143, 194])), SecretKey(Scalar([57, 113, 180, 3, 24, 28, 66, 65, 248, 236, 119, 166, 115, 108, 25, 225, 149, 143, 149, 218, 182, 10, 241, 122, 100, 8, 18, 36, 155, 47, 2, 9])));
/// JH("gdjh"): gdjh1xrf8663xg7m0jcvng5ffvavxz8fy7h0vmtsm8pqaffnh2959ddj5gasqyzk
static immutable JH = KeyPair(PublicKey(Point([210, 125, 106, 38, 71, 182, 249, 97, 147, 69, 18, 150, 117, 134, 17, 210, 79, 93, 236, 218, 225, 179, 132, 29, 74, 103, 117, 22, 133, 107, 101, 68])), SecretKey(Scalar([231, 135, 230, 221, 55, 17, 138, 123, 111, 247, 167, 74, 177, 40, 18, 105, 59, 28, 24, 34, 69, 93, 118, 43, 66, 202, 112, 48, 209, 165, 200, 14])));
/// JI("gdji"): gdji1xrfg66hmzvpvxtxy778d6dewmxdvvzfp2v9205hfvgyq7rjypqmkgyvxmrm
static immutable JI = KeyPair(PublicKey(Point([210, 141, 106, 251, 19, 2, 195, 44, 196, 247, 142, 221, 55, 46, 217, 154, 198, 9, 33, 83, 10, 167, 210, 233, 98, 8, 15, 14, 68, 8, 55, 100])), SecretKey(Scalar([251, 199, 72, 239, 194, 14, 211, 230, 33, 128, 184, 86, 91, 207, 49, 129, 43, 33, 196, 88, 234, 171, 17, 172, 73, 131, 33, 5, 52, 76, 201, 9])));
/// JJ("gdjj"): gdjj1xrff66agrl9qxz9e98wc0xq3g2gqwqwfl68vmwug05dktf4pzmxv78x3pel
static immutable JJ = KeyPair(PublicKey(Point([210, 157, 107, 168, 31, 202, 3, 8, 185, 41, 221, 135, 152, 17, 66, 144, 7, 1, 201, 254, 142, 205, 187, 136, 125, 27, 101, 166, 161, 22, 204, 207])), SecretKey(Scalar([244, 162, 89, 5, 150, 24, 93, 250, 170, 81, 46, 64, 191, 91, 20, 221, 131, 27, 149, 173, 239, 73, 245, 147, 80, 215, 20, 105, 187, 112, 7, 2])));
/// JK("gdjk"): gdjk1xrf266d7l993gwkx53n922kfeu7p83y3krvsw2x7qzyt695u0wv2cj0q2cp
static immutable JK = KeyPair(PublicKey(Point([210, 173, 105, 190, 249, 75, 20, 58, 198, 164, 102, 85, 42, 201, 207, 60, 19, 196, 145, 176, 217, 7, 40, 222, 0, 136, 189, 22, 156, 123, 152, 172])), SecretKey(Scalar([204, 121, 0, 10, 100, 92, 25, 124, 247, 109, 80, 173, 6, 189, 201, 129, 94, 78, 45, 145, 204, 87, 235, 168, 8, 54, 168, 190, 232, 110, 183, 15])));
/// JL("gdjl"): gdjl1xrft66v7wg4ta9054sfy2u5tvd69x7f50tuduhdccpjk3m8reltkznsqcvq
static immutable JL = KeyPair(PublicKey(Point([210, 189, 105, 158, 114, 42, 190, 149, 244, 172, 18, 69, 114, 139, 99, 116, 83, 121, 52, 122, 248, 222, 93, 184, 192, 101, 104, 236, 227, 207, 215, 97])), SecretKey(Scalar([218, 186, 20, 106, 7, 112, 31, 165, 75, 232, 185, 204, 15, 10, 124, 160, 99, 112, 241, 140, 212, 242, 72, 102, 25, 226, 253, 155, 46, 233, 84, 7])));
/// JM("gdjm"): gdjm1xrfv66d4kk4sxup0v89f8wckaasadqhhu26wwvlenscxtedev2qh6ajrph7
static immutable JM = KeyPair(PublicKey(Point([210, 205, 105, 181, 181, 171, 3, 112, 47, 97, 202, 147, 187, 22, 239, 97, 214, 130, 247, 226, 180, 231, 51, 249, 156, 48, 101, 229, 185, 98, 129, 125])), SecretKey(Scalar([16, 1, 68, 103, 188, 182, 144, 161, 47, 190, 207, 161, 240, 233, 52, 60, 26, 64, 235, 164, 159, 34, 43, 105, 174, 31, 118, 40, 32, 174, 157, 4])));
/// JN("gdjn"): gdjn1xrfd66kvgzk5kvjfq4g6mw5jku3txy56c2suk8da89j2t4avkdsgqhvhacg
static immutable JN = KeyPair(PublicKey(Point([210, 221, 106, 204, 64, 173, 75, 50, 73, 5, 81, 173, 186, 146, 183, 34, 179, 18, 154, 194, 161, 203, 29, 189, 57, 100, 165, 215, 172, 179, 96, 128])), SecretKey(Scalar([6, 240, 46, 103, 60, 123, 248, 188, 157, 238, 57, 77, 228, 231, 66, 154, 108, 99, 239, 133, 146, 4, 150, 98, 231, 39, 21, 38, 237, 183, 83, 15])));
/// JO("gdjo"): gdjo1xrfw66taxhhd6laps6g4rvkfd8scz78jkqtuc3x0yj8dn2wa878yc5uq7h4
static immutable JO = KeyPair(PublicKey(Point([210, 237, 105, 125, 53, 238, 221, 127, 161, 134, 145, 81, 178, 201, 105, 225, 129, 120, 242, 176, 23, 204, 68, 207, 36, 142, 217, 169, 221, 63, 142, 76])), SecretKey(Scalar([97, 152, 115, 117, 26, 71, 27, 110, 72, 107, 73, 123, 56, 217, 83, 72, 81, 173, 209, 242, 90, 106, 87, 115, 115, 44, 86, 102, 234, 36, 168, 9])));
/// JP("gdjp"): gdjp1xrf066hhnj47uwccys87r6auxx74fh52hmtx07eaj639h34r4uteg93sz3w
static immutable JP = KeyPair(PublicKey(Point([210, 253, 106, 247, 156, 171, 238, 59, 24, 36, 15, 225, 235, 188, 49, 189, 84, 222, 138, 190, 214, 103, 251, 61, 150, 162, 91, 198, 163, 175, 23, 148])), SecretKey(Scalar([31, 221, 22, 54, 112, 174, 18, 30, 196, 134, 189, 97, 23, 245, 119, 36, 59, 232, 69, 11, 220, 73, 43, 173, 240, 121, 40, 16, 158, 88, 123, 14])));
/// JQ("gdjq"): gdjq1xrfs66779q52v9s646ke2hmpep5dkd2exa5qp245kgljeuve98h9wmgk9m2
static immutable JQ = KeyPair(PublicKey(Point([211, 13, 107, 222, 40, 40, 166, 22, 26, 174, 173, 149, 95, 97, 200, 104, 219, 53, 89, 55, 104, 0, 170, 180, 178, 63, 44, 241, 153, 41, 238, 87])), SecretKey(Scalar([9, 20, 174, 103, 55, 24, 47, 143, 114, 178, 73, 1, 53, 175, 84, 99, 174, 36, 214, 89, 43, 94, 118, 44, 229, 191, 165, 159, 226, 86, 165, 10])));
/// JR("gdjr"): gdjr1xrf366jm2npy3ksw9p9r3enxxwzxduuz806k88t06e5wjgw6vv6lqwe93ft
static immutable JR = KeyPair(PublicKey(Point([211, 29, 106, 91, 84, 194, 72, 218, 14, 40, 74, 56, 230, 102, 51, 132, 102, 243, 130, 59, 245, 99, 157, 111, 214, 104, 233, 33, 218, 99, 53, 240])), SecretKey(Scalar([72, 199, 84, 45, 210, 239, 12, 108, 127, 195, 93, 179, 225, 14, 150, 202, 250, 80, 137, 14, 209, 253, 129, 57, 151, 109, 238, 216, 219, 106, 107, 14])));
/// JS("gdjs"): gdjs1xrfj66qwgwequ5pvjfjwmh6ar6g4nvvzyy5feru7jvv0lkz73xcx2s8f7q5
static immutable JS = KeyPair(PublicKey(Point([211, 45, 104, 14, 67, 178, 14, 80, 44, 146, 100, 237, 223, 93, 30, 145, 89, 177, 130, 33, 40, 156, 143, 158, 147, 24, 255, 216, 94, 137, 176, 101])), SecretKey(Scalar([41, 178, 249, 187, 120, 181, 194, 241, 173, 5, 50, 239, 231, 41, 180, 202, 35, 246, 70, 56, 45, 169, 242, 43, 145, 182, 213, 8, 198, 39, 160, 15])));
/// JT("gdjt"): gdjt1xrfn6687tzsp7nwvva95pddzjwh2gqnfvct5kqu9ycp4h4y2qfte5jw3tzv
static immutable JT = KeyPair(PublicKey(Point([211, 61, 104, 254, 88, 160, 31, 77, 204, 103, 75, 64, 181, 162, 147, 174, 164, 2, 105, 102, 23, 75, 3, 133, 38, 3, 91, 212, 138, 2, 87, 154])), SecretKey(Scalar([97, 127, 42, 87, 139, 113, 188, 39, 20, 190, 26, 36, 39, 225, 82, 233, 235, 197, 111, 133, 196, 178, 10, 164, 117, 253, 42, 79, 220, 12, 233, 7])));
/// JU("gdju"): gdju1xrf566puvtz4srsqnglezk43wepj0qgmnpe67087ksxw6q9le3fyvn7hedr
static immutable JU = KeyPair(PublicKey(Point([211, 77, 104, 60, 98, 197, 88, 14, 0, 154, 63, 145, 90, 177, 118, 67, 39, 129, 27, 152, 115, 175, 60, 254, 180, 12, 237, 0, 191, 204, 82, 70])), SecretKey(Scalar([133, 126, 81, 187, 210, 123, 107, 109, 238, 15, 92, 16, 86, 255, 38, 152, 163, 149, 70, 87, 43, 238, 96, 189, 35, 17, 133, 79, 176, 134, 97, 1])));
/// JV("gdjv"): gdjv1xrf466mj2v5du86fwe6q0xpyh6ck2u30w7zkdh2ag2weqg0qqartggkle4x
static immutable JV = KeyPair(PublicKey(Point([211, 93, 107, 114, 83, 40, 222, 31, 73, 118, 116, 7, 152, 36, 190, 177, 101, 114, 47, 119, 133, 102, 221, 93, 66, 157, 144, 33, 224, 7, 70, 180])), SecretKey(Scalar([158, 136, 10, 175, 161, 84, 105, 195, 132, 105, 208, 74, 25, 40, 125, 68, 182, 205, 125, 103, 130, 165, 251, 164, 4, 62, 69, 216, 95, 136, 52, 7])));
/// JW("gdjw"): gdjw1xrfk66ry740kjqludeuhhy4c5etkqfscfqu2dvg447y9luvv3uws6dq0psm
static immutable JW = KeyPair(PublicKey(Point([211, 109, 104, 100, 245, 95, 105, 3, 252, 110, 121, 123, 146, 184, 166, 87, 96, 38, 24, 72, 56, 166, 177, 21, 175, 136, 95, 241, 140, 143, 29, 13])), SecretKey(Scalar([212, 185, 36, 67, 109, 85, 112, 34, 87, 13, 4, 165, 198, 30, 119, 61, 151, 122, 192, 83, 40, 27, 68, 127, 1, 212, 188, 11, 75, 233, 23, 12])));
/// JX("gdjx"): gdjx1xrfh66saqldzwe0908ltcdepl22njvajdy8tjgnrazc89g92wh69ql9jv8g
static immutable JX = KeyPair(PublicKey(Point([211, 125, 106, 29, 7, 218, 39, 101, 229, 121, 254, 188, 55, 33, 250, 149, 57, 51, 178, 105, 14, 185, 34, 99, 232, 176, 114, 160, 170, 117, 244, 80])), SecretKey(Scalar([143, 195, 85, 69, 106, 110, 26, 91, 90, 100, 89, 213, 221, 46, 55, 157, 34, 28, 196, 20, 120, 54, 127, 193, 51, 223, 10, 112, 102, 188, 227, 10])));
/// JY("gdjy"): gdjy1xrfc66hwr8r5alr98r49pd4zr4pwlckcyfvnc54zw90nkjyxfudfuf5zpxk
static immutable JY = KeyPair(PublicKey(Point([211, 141, 106, 238, 25, 199, 78, 252, 101, 56, 234, 80, 182, 162, 29, 66, 239, 226, 216, 34, 89, 60, 82, 162, 113, 95, 59, 72, 134, 79, 26, 158])), SecretKey(Scalar([169, 199, 226, 178, 235, 163, 235, 7, 153, 79, 217, 197, 96, 227, 51, 45, 102, 98, 237, 158, 216, 93, 219, 215, 211, 14, 225, 80, 123, 103, 208, 15])));
/// JZ("gdjz"): gdjz1xrfe669j3txugkeh6pq4ad8pdps0smhar9xj2aaaaqhq9lz5p50u7t70de4
static immutable JZ = KeyPair(PublicKey(Point([211, 157, 104, 178, 138, 205, 196, 91, 55, 208, 65, 94, 180, 225, 104, 96, 248, 110, 253, 25, 77, 37, 119, 189, 232, 46, 2, 252, 84, 13, 31, 207])), SecretKey(Scalar([84, 114, 239, 218, 80, 104, 252, 22, 188, 63, 28, 223, 153, 80, 31, 58, 137, 252, 248, 10, 165, 247, 194, 213, 47, 166, 147, 190, 180, 90, 197, 7])));
/// KA("gdka"): gdka1xr2q66g0qtxwpnyl7hnn3jgq7v50rrs7c8jaf0e34z62qrzeyr6xsvkfs0q
static immutable KA = KeyPair(PublicKey(Point([212, 13, 105, 15, 2, 204, 224, 204, 159, 245, 231, 56, 201, 0, 243, 40, 241, 142, 30, 193, 229, 212, 191, 49, 168, 180, 160, 12, 89, 32, 244, 104])), SecretKey(Scalar([151, 33, 108, 110, 77, 72, 31, 243, 34, 194, 116, 249, 170, 11, 26, 196, 61, 10, 206, 142, 131, 93, 153, 40, 100, 252, 8, 181, 248, 78, 200, 1])));
/// KB("gdkb"): gdkb1xr2p665vqlxd704letlupxp2ytum887gzuqe7ev6xsnyw8tr025g723yjls
static immutable KB = KeyPair(PublicKey(Point([212, 29, 106, 140, 7, 204, 223, 62, 191, 202, 255, 192, 152, 42, 34, 249, 179, 159, 200, 23, 1, 159, 101, 154, 52, 38, 71, 29, 99, 122, 168, 143])), SecretKey(Scalar([40, 248, 54, 226, 52, 1, 63, 173, 43, 245, 214, 59, 209, 81, 126, 129, 156, 79, 92, 212, 227, 196, 176, 47, 59, 80, 62, 109, 153, 55, 177, 7])));
/// KC("gdkc"): gdkc1xr2z66wplrxqh3hdq8uyxdvcmd2827g2kf7k9d3ev5j55jny282mwcctpsy
static immutable KC = KeyPair(PublicKey(Point([212, 45, 105, 193, 248, 204, 11, 198, 237, 1, 248, 67, 53, 152, 219, 84, 117, 121, 10, 178, 125, 98, 182, 57, 101, 37, 74, 74, 100, 81, 213, 183])), SecretKey(Scalar([43, 198, 245, 196, 191, 28, 17, 200, 213, 53, 157, 118, 14, 1, 90, 72, 134, 91, 235, 195, 28, 230, 66, 203, 138, 210, 139, 46, 192, 76, 157, 1])));
/// KD("gdkd"): gdkd1xr2r660m7kfr8ras0r486x2asaj069cxne9rqlg9e305gv5ch80dkaup0vk
static immutable KD = KeyPair(PublicKey(Point([212, 61, 105, 251, 245, 146, 51, 143, 176, 120, 234, 125, 25, 93, 135, 100, 253, 23, 6, 158, 74, 48, 125, 5, 204, 95, 68, 50, 152, 185, 222, 219])), SecretKey(Scalar([66, 20, 178, 240, 165, 131, 175, 44, 104, 144, 232, 29, 4, 41, 253, 8, 30, 124, 144, 128, 42, 53, 63, 174, 18, 223, 215, 64, 123, 106, 52, 12])));
/// KE("gdke"): gdke1xr2y664dftn33a7qt4pkdztgx7tcru6rzqxe488ytz0dxdaf5sphzy8h4c6
static immutable KE = KeyPair(PublicKey(Point([212, 77, 106, 173, 74, 231, 24, 247, 192, 93, 67, 102, 137, 104, 55, 151, 129, 243, 67, 16, 13, 154, 156, 228, 88, 158, 211, 55, 169, 164, 3, 113])), SecretKey(Scalar([208, 55, 14, 142, 208, 190, 189, 226, 37, 60, 173, 79, 137, 169, 57, 214, 61, 255, 236, 106, 117, 88, 97, 237, 250, 112, 137, 127, 85, 99, 107, 1])));
/// KF("gdkf"): gdkf1xr2966f4lfp35fjyktdyexm82ty99g708j4jufgp734supehytajgjh22ps
static immutable KF = KeyPair(PublicKey(Point([212, 93, 105, 53, 250, 67, 26, 38, 68, 178, 218, 76, 155, 103, 82, 200, 82, 163, 207, 60, 171, 46, 37, 1, 244, 107, 14, 7, 55, 34, 251, 36])), SecretKey(Scalar([161, 84, 36, 65, 158, 28, 167, 52, 96, 143, 235, 77, 63, 161, 152, 148, 168, 157, 170, 164, 76, 202, 14, 138, 151, 123, 118, 77, 65, 64, 67, 15])));
/// KG("gdkg"): gdkg1xr2x66n9l0q3n7qe9m9n5uamxpasuc3ut09f9t3lemnykv09e00m6gpq0af
static immutable KG = KeyPair(PublicKey(Point([212, 109, 106, 101, 251, 193, 25, 248, 25, 46, 203, 58, 115, 187, 48, 123, 14, 98, 60, 91, 202, 146, 174, 63, 206, 230, 75, 49, 229, 203, 223, 189])), SecretKey(Scalar([93, 96, 53, 24, 177, 76, 203, 119, 72, 99, 203, 108, 81, 25, 159, 31, 139, 118, 18, 201, 136, 233, 23, 82, 117, 222, 33, 87, 21, 83, 91, 1])));
/// KH("gdkh"): gdkh1xr2866hsgj46kj7jflhltus8rx8nygntv37h64v4chl245a0s0lacfcr00v
static immutable KH = KeyPair(PublicKey(Point([212, 125, 106, 240, 68, 171, 171, 75, 210, 79, 239, 245, 242, 7, 25, 143, 50, 34, 107, 100, 125, 125, 85, 149, 197, 254, 170, 211, 175, 131, 255, 220])), SecretKey(Scalar([250, 67, 31, 229, 57, 86, 200, 196, 87, 24, 196, 68, 136, 221, 42, 7, 182, 69, 105, 69, 72, 181, 160, 80, 94, 202, 14, 85, 99, 227, 206, 9])));
/// KI("gdki"): gdki1xr2g66rqzm6ez09qpmuv7zxeq8mksyrm4lg25gwjdg3jq2ncqnmkk0nsfa8
static immutable KI = KeyPair(PublicKey(Point([212, 141, 104, 96, 22, 245, 145, 60, 160, 14, 248, 207, 8, 217, 1, 247, 104, 16, 123, 175, 208, 170, 33, 210, 106, 35, 32, 42, 120, 4, 247, 107])), SecretKey(Scalar([177, 125, 6, 55, 190, 177, 235, 103, 36, 237, 129, 193, 184, 67, 153, 229, 130, 160, 250, 136, 200, 55, 72, 249, 122, 51, 223, 190, 1, 172, 138, 7])));
/// KJ("gdkj"): gdkj1xr2f666f7v96v253fde33l8zfx38x3kgeag6x3j7uju03gtmjq44cgzsrj6
static immutable KJ = KeyPair(PublicKey(Point([212, 157, 107, 73, 243, 11, 166, 42, 145, 75, 115, 24, 252, 226, 73, 162, 115, 70, 200, 207, 81, 163, 70, 94, 228, 184, 248, 161, 123, 144, 43, 92])), SecretKey(Scalar([198, 88, 145, 46, 77, 217, 74, 209, 65, 61, 220, 184, 77, 86, 235, 24, 237, 163, 244, 87, 204, 213, 35, 40, 185, 12, 114, 80, 59, 181, 236, 1])));
/// KK("gdkk"): gdkk1xr22669yr7u8q3wjv5aaz894u390hatkdgn6yqf30g8d6ly9tv8vu6fffy3
static immutable KK = KeyPair(PublicKey(Point([212, 173, 104, 164, 31, 184, 112, 69, 210, 101, 59, 209, 28, 181, 228, 74, 251, 245, 118, 106, 39, 162, 1, 49, 122, 14, 221, 124, 133, 91, 14, 206])), SecretKey(Scalar([190, 124, 96, 249, 223, 27, 171, 51, 144, 202, 79, 35, 66, 75, 52, 8, 140, 70, 159, 89, 181, 99, 77, 22, 19, 200, 30, 223, 159, 65, 126, 12])));
/// KL("gdkl"): gdkl1xr2t66zahhaq660j39h7zg596kg4c7ew8ksat8a3a7dr8356mslxc9qvru5
static immutable KL = KeyPair(PublicKey(Point([212, 189, 104, 93, 189, 250, 13, 105, 242, 137, 111, 225, 34, 133, 213, 145, 92, 123, 46, 61, 161, 213, 159, 177, 239, 154, 51, 198, 154, 220, 62, 108])), SecretKey(Scalar([192, 43, 246, 158, 73, 61, 189, 183, 86, 191, 207, 190, 134, 10, 216, 188, 44, 172, 177, 205, 40, 111, 191, 181, 37, 165, 37, 57, 189, 13, 149, 6])));
/// KM("gdkm"): gdkm1xr2v66etmm0aetj9erdrpv7nyduql008aery9gwrhh9zcramvsaesl392r7
static immutable KM = KeyPair(PublicKey(Point([212, 205, 107, 43, 222, 223, 220, 174, 69, 200, 218, 48, 179, 211, 35, 120, 15, 189, 231, 238, 70, 66, 161, 195, 189, 202, 44, 15, 187, 100, 59, 152])), SecretKey(Scalar([40, 232, 72, 80, 163, 88, 207, 8, 127, 166, 27, 30, 235, 91, 242, 40, 34, 252, 85, 30, 97, 216, 232, 170, 93, 16, 205, 2, 245, 184, 146, 12])));
/// KN("gdkn"): gdkn1xr2d66kpxt4t63zp0n8y4y23y2mg55z6hngh0crjssys6l5z0l9hvcjrrl3
static immutable KN = KeyPair(PublicKey(Point([212, 221, 106, 193, 50, 234, 189, 68, 65, 124, 206, 74, 145, 81, 34, 182, 138, 80, 90, 188, 209, 119, 224, 114, 132, 9, 13, 126, 130, 127, 203, 118])), SecretKey(Scalar([181, 223, 134, 167, 182, 109, 90, 86, 40, 56, 224, 64, 41, 222, 122, 173, 100, 170, 78, 175, 180, 7, 152, 55, 2, 131, 168, 99, 238, 41, 99, 0])));
/// KO("gdko"): gdko1xr2w667l77hwvuwe0vnp6fk8s9qrv4nrqnam6zwmn397d9zyq8yh58dfhhf
static immutable KO = KeyPair(PublicKey(Point([212, 237, 107, 223, 247, 174, 230, 113, 217, 123, 38, 29, 38, 199, 129, 64, 54, 86, 99, 4, 251, 189, 9, 219, 156, 75, 230, 148, 68, 1, 201, 122])), SecretKey(Scalar([14, 103, 72, 244, 178, 235, 152, 211, 104, 22, 136, 25, 225, 21, 18, 6, 121, 194, 202, 203, 242, 244, 224, 19, 114, 100, 226, 186, 124, 242, 192, 8])));
/// KP("gdkp"): gdkp1xr2066hqff8kddy2jl8hakhcr2dqurfgld8jgjsmqmtt05sg60xj5nw0he6
static immutable KP = KeyPair(PublicKey(Point([212, 253, 106, 224, 74, 79, 102, 180, 138, 151, 207, 126, 218, 248, 26, 154, 14, 13, 40, 251, 79, 36, 74, 27, 6, 214, 183, 210, 8, 211, 205, 42])), SecretKey(Scalar([133, 3, 120, 28, 152, 194, 10, 46, 229, 232, 17, 112, 226, 163, 70, 146, 32, 6, 69, 168, 85, 220, 10, 55, 166, 132, 61, 171, 44, 195, 218, 14])));
/// KQ("gdkq"): gdkq1xr2s66u8hggqpg0ymv9erqwxres4ave7crc3pda7ag5v0dayan8jcw470fw
static immutable KQ = KeyPair(PublicKey(Point([213, 13, 107, 135, 186, 16, 0, 161, 228, 219, 11, 145, 129, 198, 30, 97, 94, 179, 62, 192, 241, 16, 183, 190, 234, 40, 199, 183, 164, 236, 207, 44])), SecretKey(Scalar([49, 247, 212, 186, 44, 34, 49, 33, 170, 121, 187, 209, 37, 131, 139, 164, 22, 6, 40, 231, 0, 243, 109, 171, 47, 139, 210, 8, 189, 138, 44, 2])));
/// KR("gdkr"): gdkr1xr2366at6vp4u55tfmpcnlpzv6k42804z0277vq99hyeshzgwug8z0wah9l
static immutable KR = KeyPair(PublicKey(Point([213, 29, 107, 171, 211, 3, 94, 82, 139, 78, 195, 137, 252, 34, 102, 173, 85, 29, 245, 19, 213, 239, 48, 5, 45, 201, 152, 92, 72, 119, 16, 113])), SecretKey(Scalar([60, 250, 171, 88, 47, 250, 241, 31, 219, 155, 230, 255, 251, 237, 45, 115, 97, 220, 126, 220, 217, 224, 202, 208, 113, 165, 253, 52, 148, 224, 199, 4])));
/// KS("gdks"): gdks1xr2j669y96nttvglp3tgy93kq7we6lkj2fw58fq2rxcfug60fkgujx2dpsv
static immutable KS = KeyPair(PublicKey(Point([213, 45, 104, 164, 46, 166, 181, 177, 31, 12, 86, 130, 22, 54, 7, 157, 157, 126, 210, 82, 93, 67, 164, 10, 25, 176, 158, 35, 79, 77, 145, 201])), SecretKey(Scalar([204, 72, 208, 91, 132, 106, 126, 217, 59, 130, 204, 146, 34, 63, 110, 139, 210, 194, 37, 73, 178, 204, 62, 251, 177, 229, 120, 235, 33, 232, 13, 2])));
/// KT("gdkt"): gdkt1xr2n66p53u4rrgu4ucrd4vtssnn9jr7rhdj6lry5dcuc7t2aucwvu6jhffk
static immutable KT = KeyPair(PublicKey(Point([213, 61, 104, 52, 143, 42, 49, 163, 149, 230, 6, 218, 177, 112, 132, 230, 89, 15, 195, 187, 101, 175, 140, 148, 110, 57, 143, 45, 93, 230, 28, 206])), SecretKey(Scalar([111, 59, 140, 237, 129, 9, 141, 241, 132, 48, 5, 69, 14, 97, 196, 245, 2, 99, 148, 238, 76, 59, 78, 25, 157, 4, 2, 39, 244, 202, 179, 8])));
/// KU("gdku"): gdku1xr25662g8jqpkprva26msjv9wmqrlqcpzql08fqjyqcaume5juqvg5xjsft
static immutable KU = KeyPair(PublicKey(Point([213, 77, 105, 72, 60, 128, 27, 4, 108, 234, 181, 184, 73, 133, 118, 192, 63, 131, 1, 16, 62, 243, 164, 18, 32, 49, 222, 111, 52, 151, 0, 196])), SecretKey(Scalar([116, 4, 126, 239, 165, 210, 231, 41, 94, 171, 231, 157, 2, 77, 114, 221, 185, 116, 251, 244, 214, 95, 162, 218, 70, 127, 55, 180, 34, 110, 148, 13])));
/// KV("gdkv"): gdkv1xr2466anh0pud85al8tk499h7fe3j3lydpv6d0q4dstknql5pdd6ukulwlk
static immutable KV = KeyPair(PublicKey(Point([213, 93, 107, 179, 187, 195, 198, 158, 157, 249, 215, 106, 148, 183, 242, 115, 25, 71, 228, 104, 89, 166, 188, 21, 108, 23, 105, 131, 244, 11, 91, 174])), SecretKey(Scalar([194, 196, 255, 187, 67, 204, 115, 20, 127, 90, 91, 135, 72, 177, 198, 105, 181, 184, 79, 146, 132, 223, 236, 6, 127, 44, 255, 9, 56, 213, 114, 5])));
/// KW("gdkw"): gdkw1xr2k66r3zt6z6cqzm5wtduel0hn8wlrl955u4wfraykqjte6de8z66wjtxm
static immutable KW = KeyPair(PublicKey(Point([213, 109, 104, 113, 18, 244, 45, 96, 2, 221, 28, 182, 243, 63, 125, 230, 119, 124, 127, 45, 41, 202, 185, 35, 233, 44, 9, 47, 58, 110, 78, 45])), SecretKey(Scalar([219, 183, 146, 105, 234, 70, 35, 139, 212, 83, 140, 111, 205, 138, 46, 118, 84, 129, 61, 202, 218, 91, 52, 107, 156, 68, 10, 85, 108, 160, 186, 14])));
/// KX("gdkx"): gdkx1xr2h66q6hxsqzdrh7rtuncuks074650dkx9luyzwn42ldwwa4uswsva0xm8
static immutable KX = KeyPair(PublicKey(Point([213, 125, 104, 26, 185, 160, 1, 52, 119, 240, 215, 201, 227, 150, 131, 253, 93, 81, 237, 177, 139, 254, 16, 78, 157, 85, 246, 185, 221, 175, 32, 232])), SecretKey(Scalar([215, 76, 252, 27, 201, 212, 178, 184, 30, 188, 12, 173, 55, 124, 4, 57, 77, 194, 119, 105, 222, 123, 32, 117, 30, 33, 97, 27, 206, 188, 230, 14])));
/// KY("gdky"): gdky1xr2c66f88tugvltswrgpfh7sfvrvh55mdcdjepwa4p6t73s5ywje5lfy0rm
static immutable KY = KeyPair(PublicKey(Point([213, 141, 105, 39, 58, 248, 134, 125, 112, 112, 208, 20, 223, 208, 75, 6, 203, 210, 155, 110, 27, 44, 133, 221, 168, 116, 191, 70, 20, 35, 165, 154])), SecretKey(Scalar([232, 219, 190, 235, 203, 174, 98, 141, 228, 20, 128, 23, 147, 197, 66, 60, 100, 179, 119, 131, 160, 91, 155, 208, 135, 235, 26, 48, 141, 74, 26, 15])));
/// KZ("gdkz"): gdkz1xr2e66vmwnc8h725qk3t8umvaxeazjagr5a6hgjw2dn5xf6e32r4uwejh94
static immutable KZ = KeyPair(PublicKey(Point([213, 157, 105, 155, 116, 240, 123, 249, 84, 5, 162, 179, 243, 108, 233, 179, 209, 75, 168, 29, 59, 171, 162, 78, 83, 103, 67, 39, 89, 138, 135, 94])), SecretKey(Scalar([121, 95, 217, 60, 65, 159, 214, 125, 94, 73, 107, 228, 164, 249, 122, 218, 180, 142, 122, 227, 81, 38, 229, 55, 238, 145, 20, 23, 207, 11, 192, 15])));
/// LA("gdla"): gdla1xrtq66ljnw8glpcawec035n0mmrx3s847s4xfv7lk7e5rknp2yrnz24sxhv
static immutable LA = KeyPair(PublicKey(Point([214, 13, 107, 242, 155, 142, 143, 135, 29, 118, 112, 248, 210, 111, 222, 198, 104, 192, 245, 244, 42, 100, 179, 223, 183, 179, 65, 218, 97, 81, 7, 49])), SecretKey(Scalar([143, 198, 132, 142, 118, 25, 187, 30, 216, 213, 213, 152, 217, 50, 127, 134, 236, 42, 41, 107, 88, 122, 215, 210, 190, 123, 156, 230, 102, 171, 117, 15])));
/// LB("gdlb"): gdlb1xrtp66rmuakfkpgn25w572m2y048ss7vq959pe0h6kvv67l55dtr2rhpruw
static immutable LB = KeyPair(PublicKey(Point([214, 29, 104, 123, 231, 108, 155, 5, 19, 85, 29, 79, 43, 106, 35, 234, 120, 67, 204, 1, 104, 80, 229, 247, 213, 152, 205, 123, 244, 163, 86, 53])), SecretKey(Scalar([235, 233, 171, 103, 35, 243, 234, 133, 49, 172, 27, 138, 230, 250, 56, 145, 31, 123, 140, 210, 80, 55, 70, 162, 242, 94, 73, 147, 62, 72, 108, 4])));
/// LC("gdlc"): gdlc1xrtz66xkxzrvznaqyxvu256jerlr2fyswnru0udx8szg468n662hjqfpt3z
static immutable LC = KeyPair(PublicKey(Point([214, 45, 104, 214, 48, 134, 193, 79, 160, 33, 153, 197, 83, 82, 200, 254, 53, 36, 144, 116, 199, 199, 241, 166, 60, 4, 138, 232, 243, 214, 149, 121])), SecretKey(Scalar([155, 48, 129, 168, 103, 247, 25, 252, 31, 90, 49, 145, 89, 24, 118, 15, 35, 136, 1, 188, 15, 90, 235, 136, 204, 121, 245, 200, 77, 26, 168, 9])));
/// LD("gdld"): gdld1xrtr66z4ev5ld94vnl4l8dw43wl8zauet4measjk8fy7663a92uexek4pvh
static immutable LD = KeyPair(PublicKey(Point([214, 61, 104, 85, 203, 41, 246, 150, 172, 159, 235, 243, 181, 213, 139, 190, 113, 119, 153, 93, 119, 158, 194, 86, 58, 73, 237, 106, 61, 42, 185, 147])), SecretKey(Scalar([155, 218, 166, 214, 111, 87, 74, 185, 31, 227, 111, 4, 211, 211, 18, 145, 228, 83, 20, 217, 21, 51, 209, 184, 67, 137, 170, 2, 193, 191, 218, 0])));
/// LE("gdle"): gdle1xrty6656sj02h2mc8mz7wr48ap4elakzg99xd9alray3re5dxgyc72jf0z4
static immutable LE = KeyPair(PublicKey(Point([214, 77, 106, 154, 132, 158, 171, 171, 120, 62, 197, 231, 14, 167, 232, 107, 159, 246, 194, 65, 74, 102, 151, 191, 31, 73, 17, 230, 141, 50, 9, 143])), SecretKey(Scalar([219, 254, 31, 159, 75, 76, 105, 107, 139, 203, 65, 54, 134, 18, 115, 160, 75, 41, 232, 93, 104, 114, 27, 158, 177, 112, 233, 248, 12, 81, 200, 14])));
/// LF("gdlf"): gdlf1xrt966p3jn4dcp5227ftvfhctd2gxaadzcj8fr48rx9gpvvvynpzw9l46zz
static immutable LF = KeyPair(PublicKey(Point([214, 93, 104, 49, 148, 234, 220, 6, 138, 87, 146, 182, 38, 248, 91, 84, 131, 119, 173, 22, 36, 116, 142, 167, 25, 138, 128, 177, 140, 36, 194, 39])), SecretKey(Scalar([21, 192, 106, 116, 134, 79, 68, 131, 112, 135, 244, 49, 168, 225, 133, 161, 118, 233, 91, 238, 218, 65, 69, 60, 249, 101, 36, 9, 230, 202, 64, 7])));
/// LG("gdlg"): gdlg1xrtx66pk5zmvesh3h4sn6m32206dyen8d2alfqccxhatst6qf4hfjmsz7ak
static immutable LG = KeyPair(PublicKey(Point([214, 109, 104, 54, 160, 182, 204, 194, 241, 189, 97, 61, 110, 42, 83, 244, 210, 102, 103, 106, 187, 244, 131, 24, 53, 250, 184, 47, 64, 77, 110, 153])), SecretKey(Scalar([207, 7, 21, 51, 236, 61, 53, 60, 145, 168, 83, 61, 183, 52, 207, 213, 118, 168, 29, 15, 219, 33, 3, 2, 215, 249, 29, 235, 157, 65, 77, 10])));
/// LH("gdlh"): gdlh1xrt866sgd6efl379q2j68apdfncmq2pkx9azlsw8w3vk3rth6najqhrwh7x
static immutable LH = KeyPair(PublicKey(Point([214, 125, 106, 8, 110, 178, 159, 199, 197, 2, 165, 163, 244, 45, 76, 241, 176, 40, 54, 49, 122, 47, 193, 199, 116, 89, 104, 141, 119, 212, 251, 32])), SecretKey(Scalar([173, 66, 139, 39, 59, 28, 210, 212, 241, 190, 13, 75, 34, 248, 129, 145, 45, 98, 215, 18, 177, 224, 250, 43, 44, 44, 4, 9, 108, 91, 111, 2])));
/// LI("gdli"): gdli1xrtg66zkyarpd974ehma00zz84ylnz0uqhhdgwvuxc6dk67jst572vg3qf5
static immutable LI = KeyPair(PublicKey(Point([214, 141, 104, 86, 39, 70, 22, 151, 213, 205, 247, 215, 188, 66, 61, 73, 249, 137, 252, 5, 238, 212, 57, 156, 54, 52, 219, 107, 210, 130, 233, 229])), SecretKey(Scalar([75, 6, 84, 223, 25, 57, 54, 86, 148, 33, 213, 37, 136, 254, 158, 77, 116, 212, 237, 200, 150, 174, 101, 99, 1, 66, 0, 114, 133, 31, 98, 4])));
/// LJ("gdlj"): gdlj1xrtf66u53l3lcg2myltfd882ng5wlcpwp6cmqg7machtg23lzmk9q9xk580
static immutable LJ = KeyPair(PublicKey(Point([214, 157, 107, 148, 143, 227, 252, 33, 91, 39, 214, 150, 156, 234, 154, 40, 239, 224, 46, 14, 177, 176, 35, 219, 238, 46, 180, 42, 63, 22, 236, 80])), SecretKey(Scalar([139, 111, 230, 63, 254, 116, 83, 196, 44, 25, 156, 83, 165, 39, 248, 222, 54, 171, 225, 24, 250, 9, 163, 74, 52, 29, 90, 36, 63, 254, 134, 11])));
/// LK("gdlk"): gdlk1xrt2665gkej5k5tp2vyulp087sekd3lg2nj9nhlglekkf4fghuey5mtxlfw
static immutable LK = KeyPair(PublicKey(Point([214, 173, 106, 136, 182, 101, 75, 81, 97, 83, 9, 207, 133, 231, 244, 51, 102, 199, 232, 84, 228, 89, 223, 232, 254, 109, 100, 213, 40, 191, 50, 74])), SecretKey(Scalar([238, 41, 171, 43, 5, 134, 187, 4, 129, 137, 191, 145, 136, 207, 23, 151, 150, 107, 133, 39, 66, 242, 88, 30, 182, 82, 252, 227, 192, 20, 7, 1])));
/// LL("gdll"): gdll1xrtt66weg777cmk3jshvcx6qk3ahf25fqzn5jds4pc0rs3fea9nn2tfvaxx
static immutable LL = KeyPair(PublicKey(Point([214, 189, 105, 217, 71, 189, 236, 110, 209, 148, 46, 204, 27, 64, 180, 123, 116, 170, 137, 0, 167, 73, 54, 21, 14, 30, 56, 69, 57, 233, 103, 53])), SecretKey(Scalar([228, 158, 201, 212, 165, 8, 44, 206, 166, 232, 229, 114, 156, 216, 51, 252, 132, 74, 171, 178, 23, 242, 23, 184, 8, 118, 112, 13, 217, 251, 248, 5])));
/// LM("gdlm"): gdlm1xrtv66au9js469lq7ylzsv32t4cjuhuut5tcg5w3u759h0gqrtcd2h47ty3
static immutable LM = KeyPair(PublicKey(Point([214, 205, 107, 188, 44, 161, 93, 23, 224, 241, 62, 40, 50, 42, 93, 113, 46, 95, 156, 93, 23, 132, 81, 209, 231, 168, 91, 189, 0, 26, 240, 213])), SecretKey(Scalar([45, 39, 164, 175, 105, 47, 116, 149, 241, 64, 142, 238, 118, 65, 157, 184, 53, 232, 7, 130, 213, 140, 13, 14, 81, 146, 95, 84, 73, 123, 105, 9])));
/// LN("gdln"): gdln1xrtd66r0r9gmaxf4xew90hf2vf3938h0h75rw0xd7pggxk2754gvjjvelg3
static immutable LN = KeyPair(PublicKey(Point([214, 221, 104, 111, 25, 81, 190, 153, 53, 54, 92, 87, 221, 42, 98, 98, 88, 158, 239, 191, 168, 55, 60, 205, 240, 80, 131, 89, 94, 165, 80, 201])), SecretKey(Scalar([207, 72, 190, 68, 161, 126, 202, 26, 160, 75, 103, 219, 84, 241, 110, 197, 131, 173, 249, 177, 112, 29, 50, 225, 189, 59, 195, 114, 40, 35, 151, 12])));
/// LO("gdlo"): gdlo1xrtw66f4yg95fxe2zdlz67pa3kq6rcgc3caums5a3j4jdarpfd5sz55sxln
static immutable LO = KeyPair(PublicKey(Point([214, 237, 105, 53, 34, 11, 68, 155, 42, 19, 126, 45, 120, 61, 141, 129, 161, 225, 24, 142, 59, 205, 194, 157, 140, 171, 38, 244, 97, 75, 105, 1])), SecretKey(Scalar([215, 221, 134, 177, 228, 62, 78, 171, 166, 236, 100, 110, 251, 171, 233, 242, 138, 97, 109, 109, 225, 192, 90, 79, 26, 77, 47, 22, 150, 162, 86, 7])));
/// LP("gdlp"): gdlp1xrt066qp8ehwrfp8rme9la4nktc6t364ze5rsjsrn9zh4vv8x48fqqa4ksm
static immutable LP = KeyPair(PublicKey(Point([214, 253, 104, 1, 62, 110, 225, 164, 39, 30, 242, 95, 246, 179, 178, 241, 165, 199, 85, 22, 104, 56, 74, 3, 153, 69, 122, 177, 135, 53, 78, 144])), SecretKey(Scalar([203, 155, 15, 181, 226, 127, 231, 159, 135, 136, 194, 23, 146, 126, 210, 34, 145, 11, 254, 36, 87, 85, 253, 114, 21, 207, 228, 101, 133, 242, 174, 11])));
/// LQ("gdlq"): gdlq1xrts660paggf9wz0qflr6aay8wcfsnav440rnjwlv56a3r37c0glw2czvzc
static immutable LQ = KeyPair(PublicKey(Point([215, 13, 105, 225, 234, 16, 146, 184, 79, 2, 126, 61, 119, 164, 59, 176, 152, 79, 172, 173, 94, 57, 201, 223, 101, 53, 216, 142, 62, 195, 209, 247])), SecretKey(Scalar([9, 10, 26, 47, 134, 32, 255, 32, 132, 236, 98, 205, 10, 160, 103, 124, 48, 22, 142, 145, 51, 52, 253, 184, 151, 247, 178, 38, 28, 187, 172, 0])));
/// LR("gdlr"): gdlr1xrt3664y7yqnhhvz2rtj39f6ya05dfejjesq4ul7cm9rqgag0gfmuumaj4h
static immutable LR = KeyPair(PublicKey(Point([215, 29, 106, 164, 241, 1, 59, 221, 130, 80, 215, 40, 149, 58, 39, 95, 70, 167, 50, 150, 96, 10, 243, 254, 198, 202, 48, 35, 168, 122, 19, 190])), SecretKey(Scalar([63, 8, 37, 0, 100, 215, 112, 29, 89, 26, 190, 38, 40, 243, 9, 213, 113, 22, 213, 206, 26, 160, 247, 125, 102, 168, 43, 8, 228, 80, 218, 14])));
/// LS("gdls"): gdls1xrtj66ynpufy7pgrsn5u7jq95pvnyxyq2jxw2mpf4mk8ntaz3yc4g9vcfjj
static immutable LS = KeyPair(PublicKey(Point([215, 45, 104, 147, 15, 18, 79, 5, 3, 132, 233, 207, 72, 5, 160, 89, 50, 24, 128, 84, 140, 229, 108, 41, 174, 236, 121, 175, 162, 137, 49, 84])), SecretKey(Scalar([81, 72, 185, 145, 254, 210, 60, 171, 94, 233, 199, 132, 111, 100, 212, 153, 186, 38, 210, 81, 213, 5, 239, 24, 166, 162, 191, 174, 133, 255, 199, 5])));
/// LT("gdlt"): gdlt1xrtn66a64l4aetxmz8688ez39cvy444u6w3zzqvvdj9jkl4lu5w3q5wr9jl
static immutable LT = KeyPair(PublicKey(Point([215, 61, 107, 186, 175, 235, 220, 172, 219, 17, 244, 115, 228, 81, 46, 24, 74, 214, 188, 211, 162, 33, 1, 140, 108, 139, 43, 126, 191, 229, 29, 16])), SecretKey(Scalar([126, 135, 7, 254, 231, 93, 241, 176, 222, 83, 59, 165, 208, 158, 77, 187, 213, 96, 47, 149, 118, 22, 79, 164, 211, 127, 21, 74, 18, 44, 6, 12])));
/// LU("gdlu"): gdlu1xrt56638vwfv85dqmynm5p3py6yyh0gjua7pvp8s8h4pk4j5vyh3595c0ur
static immutable LU = KeyPair(PublicKey(Point([215, 77, 106, 39, 99, 146, 195, 209, 160, 217, 39, 186, 6, 33, 38, 136, 75, 189, 18, 231, 124, 22, 4, 240, 61, 234, 27, 86, 84, 97, 47, 26])), SecretKey(Scalar([91, 125, 203, 112, 61, 101, 144, 97, 36, 40, 66, 245, 123, 166, 214, 74, 152, 160, 110, 109, 255, 87, 111, 138, 144, 207, 104, 217, 99, 72, 138, 7])));
/// LV("gdlv"): gdlv1xrt46607hguj37e385uauy70w884r2u2z9gcpl8ravy9trfsr9g7szhwyxn
static immutable LV = KeyPair(PublicKey(Point([215, 93, 105, 254, 186, 57, 40, 251, 49, 61, 57, 222, 19, 207, 113, 207, 81, 171, 138, 17, 81, 128, 252, 227, 235, 8, 85, 141, 48, 25, 81, 232])), SecretKey(Scalar([4, 172, 69, 149, 194, 71, 25, 73, 207, 175, 247, 77, 58, 0, 159, 176, 14, 105, 48, 202, 236, 63, 67, 35, 42, 85, 179, 110, 98, 113, 37, 11])));
/// LW("gdlw"): gdlw1xrtk66ty5rtjj2y9xmf79t608ppgzch76vtstjdddkmhm5kgkda9uufhgrm
static immutable LW = KeyPair(PublicKey(Point([215, 109, 105, 100, 160, 215, 41, 40, 133, 54, 211, 226, 175, 79, 56, 66, 129, 98, 254, 211, 23, 5, 201, 173, 109, 183, 125, 210, 200, 179, 122, 94])), SecretKey(Scalar([52, 86, 114, 23, 37, 215, 2, 37, 172, 131, 227, 209, 215, 51, 165, 23, 151, 98, 6, 190, 179, 74, 236, 158, 98, 217, 34, 111, 40, 198, 42, 11])));
/// LX("gdlx"): gdlx1xrth66yeyewu49dya7p3fnp0tuxr447y0l9whlrk0sz9nu59ejuk769r94d
static immutable LX = KeyPair(PublicKey(Point([215, 125, 104, 153, 38, 93, 202, 149, 164, 239, 131, 20, 204, 47, 95, 12, 58, 215, 196, 127, 202, 235, 252, 118, 124, 4, 89, 242, 133, 204, 185, 111])), SecretKey(Scalar([182, 101, 79, 7, 9, 37, 10, 88, 164, 61, 97, 155, 12, 88, 66, 146, 145, 19, 171, 179, 119, 22, 5, 205, 72, 196, 42, 131, 84, 145, 50, 5])));
/// LY("gdly"): gdly1xrtc662p6hnzu3zr4cjtahajg5qmeh3mtsdrx2xrv444l9w8w8phcwfuqdy
static immutable LY = KeyPair(PublicKey(Point([215, 141, 105, 65, 213, 230, 46, 68, 67, 174, 36, 190, 223, 178, 69, 1, 188, 222, 59, 92, 26, 51, 40, 195, 101, 107, 95, 149, 199, 113, 195, 124])), SecretKey(Scalar([171, 18, 221, 48, 93, 246, 45, 163, 23, 218, 241, 160, 138, 134, 121, 241, 142, 112, 132, 150, 240, 228, 120, 175, 87, 175, 209, 72, 160, 61, 121, 13])));
/// LZ("gdlz"): gdlz1xrte66xh3avnmde0x3mzpk8epw7jflw5akf0p52etn9narfqyadczu000nm
static immutable LZ = KeyPair(PublicKey(Point([215, 157, 104, 215, 143, 89, 61, 183, 47, 52, 118, 32, 216, 249, 11, 189, 36, 253, 212, 237, 146, 240, 209, 89, 92, 203, 62, 141, 32, 39, 91, 129])), SecretKey(Scalar([97, 60, 113, 129, 201, 121, 131, 86, 31, 183, 51, 2, 62, 212, 28, 85, 147, 12, 16, 101, 244, 55, 53, 213, 41, 169, 110, 106, 231, 24, 173, 0])));
/// MA("gdma"): gdma1xrvq663myugu7avje5ny37rkk9sfz4e083ryudz2v2dyxkpqk90qq6689qg
static immutable MA = KeyPair(PublicKey(Point([216, 13, 106, 59, 39, 17, 207, 117, 146, 205, 38, 72, 248, 118, 177, 96, 145, 87, 47, 60, 70, 78, 52, 74, 98, 154, 67, 88, 32, 177, 94, 0])), SecretKey(Scalar([249, 32, 99, 103, 91, 60, 83, 71, 214, 192, 4, 42, 3, 70, 255, 175, 26, 211, 68, 215, 19, 119, 91, 213, 34, 75, 36, 11, 51, 27, 52, 14])));
/// MB("gdmb"): gdmb1xrvp666yy6rtyf02ugsyn0zk0ptrs23el6f7hswcf3wqg4he6kcvwt0yjve
static immutable MB = KeyPair(PublicKey(Point([216, 29, 107, 68, 38, 134, 178, 37, 234, 226, 32, 73, 188, 86, 120, 86, 56, 42, 57, 254, 147, 235, 193, 216, 76, 92, 4, 86, 249, 213, 176, 199])), SecretKey(Scalar([178, 234, 100, 111, 136, 248, 223, 126, 42, 5, 180, 161, 195, 177, 231, 12, 218, 84, 149, 149, 47, 228, 202, 119, 39, 191, 11, 133, 23, 143, 237, 14])));
/// MC("gdmc"): gdmc1xrvz66zwgz2eku0l6qe8y5mekaae2xrs7xylx434waar088cyn7673tqwgk
static immutable MC = KeyPair(PublicKey(Point([216, 45, 104, 78, 64, 149, 155, 113, 255, 208, 50, 114, 83, 121, 183, 123, 149, 24, 112, 241, 137, 243, 86, 53, 119, 122, 55, 156, 248, 36, 253, 175])), SecretKey(Scalar([217, 179, 111, 53, 197, 246, 214, 48, 61, 77, 106, 154, 175, 200, 117, 138, 48, 98, 88, 236, 38, 42, 148, 139, 140, 245, 34, 92, 19, 113, 220, 6])));
/// MD("gdmd"): gdmd1xrvr66r73fd6s8tkyj4fzjqsx5tf5s56z524zu6g7vlwa5q4pe2pj7rqu0g
static immutable MD = KeyPair(PublicKey(Point([216, 61, 104, 126, 138, 91, 168, 29, 118, 36, 170, 145, 72, 16, 53, 22, 154, 66, 154, 21, 21, 81, 115, 72, 243, 62, 238, 208, 21, 14, 84, 25])), SecretKey(Scalar([205, 75, 59, 56, 161, 46, 190, 95, 149, 191, 15, 66, 206, 41, 246, 160, 172, 161, 224, 99, 98, 157, 164, 159, 82, 149, 199, 67, 16, 151, 7, 8])));
/// ME("gdme"): gdme1xrvy66c26a0xfflma4u563y988wfj5w709hj6upgdrxakkeqsg6autj2y9t
static immutable ME = KeyPair(PublicKey(Point([216, 77, 107, 10, 215, 94, 100, 167, 251, 237, 121, 77, 68, 133, 57, 220, 153, 81, 222, 121, 111, 45, 112, 40, 104, 205, 219, 91, 32, 130, 53, 222])), SecretKey(Scalar([60, 48, 101, 102, 154, 74, 59, 13, 156, 185, 196, 181, 83, 48, 230, 183, 244, 0, 109, 68, 158, 208, 33, 82, 210, 73, 39, 112, 111, 12, 192, 0])));
/// MF("gdmf"): gdmf1xrv966hfthefnwgfzqfhfxyc4k8dt2rwy42mgxl20qph7welc2vqjqarn9f
static immutable MF = KeyPair(PublicKey(Point([216, 93, 106, 233, 93, 242, 153, 185, 9, 16, 19, 116, 152, 152, 173, 142, 213, 168, 110, 37, 85, 180, 27, 234, 120, 3, 127, 59, 63, 194, 152, 9])), SecretKey(Scalar([62, 232, 27, 160, 7, 13, 30, 121, 125, 101, 182, 184, 155, 158, 64, 62, 25, 33, 254, 104, 177, 215, 177, 205, 145, 178, 102, 42, 115, 59, 48, 4])));
/// MG("gdmg"): gdmg1xrvx66z5ku70j5snc0feaytp6d82sdmfvcs2ypf0pzzj7stt49z7754msrx
static immutable MG = KeyPair(PublicKey(Point([216, 109, 104, 84, 183, 60, 249, 82, 19, 195, 211, 158, 145, 97, 211, 78, 168, 55, 105, 102, 32, 162, 5, 47, 8, 133, 47, 65, 107, 169, 69, 239])), SecretKey(Scalar([41, 205, 146, 3, 122, 246, 157, 141, 187, 154, 146, 33, 100, 98, 108, 253, 160, 174, 135, 145, 20, 205, 150, 129, 168, 103, 211, 233, 234, 223, 100, 1])));
/// MH("gdmh"): gdmh1xrv8668qcyls7u8s8w4m24skgwmsua8d7rkvja93528zf43d2hgdgj3vpak
static immutable MH = KeyPair(PublicKey(Point([216, 125, 104, 224, 193, 63, 15, 112, 240, 59, 171, 181, 86, 22, 67, 183, 14, 116, 237, 240, 236, 201, 116, 177, 162, 142, 36, 214, 45, 85, 208, 212])), SecretKey(Scalar([71, 109, 3, 150, 45, 112, 176, 131, 172, 189, 243, 94, 57, 5, 153, 240, 31, 229, 63, 187, 161, 114, 122, 35, 3, 79, 199, 215, 222, 107, 163, 12])));
/// MI("gdmi"): gdmi1xrvg66tcfkzfe0hwfe2cnzyvk09djj7hcyu0uc2p7alx2huyxj352cxssln
static immutable MI = KeyPair(PublicKey(Point([216, 141, 105, 120, 77, 132, 156, 190, 238, 78, 85, 137, 136, 140, 179, 202, 217, 75, 215, 193, 56, 254, 97, 65, 247, 126, 101, 95, 132, 52, 163, 69])), SecretKey(Scalar([108, 38, 245, 70, 81, 116, 210, 227, 60, 16, 220, 97, 196, 246, 138, 122, 244, 68, 95, 119, 216, 9, 159, 176, 137, 201, 171, 74, 129, 99, 85, 7])));
/// MJ("gdmj"): gdmj1xrvf663j8tzm740wrdrhjuhgf7ectjgyhtg6tkaurxu4hqkjpxpng04jtfg
static immutable MJ = KeyPair(PublicKey(Point([216, 157, 106, 50, 58, 197, 191, 85, 238, 27, 71, 121, 114, 232, 79, 179, 133, 201, 4, 186, 209, 165, 219, 188, 25, 185, 91, 130, 210, 9, 131, 52])), SecretKey(Scalar([202, 236, 120, 245, 24, 209, 118, 40, 126, 240, 130, 227, 62, 225, 205, 145, 136, 54, 103, 31, 29, 209, 132, 217, 140, 111, 10, 80, 240, 19, 114, 8])));
/// MK("gdmk"): gdmk1xrv26662jnmhj0qsrgadazqzll06kvntr5mkhyvwelwgxl2cgwt9ykmhd9t
static immutable MK = KeyPair(PublicKey(Point([216, 173, 107, 74, 148, 247, 121, 60, 16, 26, 58, 222, 136, 2, 255, 223, 171, 50, 107, 29, 55, 107, 145, 142, 207, 220, 131, 125, 88, 67, 150, 82])), SecretKey(Scalar([118, 161, 154, 25, 45, 139, 29, 135, 175, 66, 246, 37, 117, 48, 235, 136, 97, 199, 34, 142, 28, 84, 83, 133, 125, 249, 87, 240, 62, 108, 151, 8])));
/// ML("gdml"): gdml1xrvt66n33l4udhxqmem3t952h6z62ynmsnctmdllx628vxl48g6ljuukhp7
static immutable ML = KeyPair(PublicKey(Point([216, 189, 106, 113, 143, 235, 198, 220, 192, 222, 119, 21, 150, 138, 190, 133, 165, 18, 123, 132, 240, 189, 183, 255, 54, 148, 118, 27, 245, 58, 53, 249])), SecretKey(Scalar([165, 80, 233, 15, 173, 120, 185, 164, 93, 174, 246, 92, 164, 168, 12, 118, 243, 94, 250, 206, 135, 147, 4, 239, 94, 110, 20, 92, 36, 10, 96, 2])));
/// MM("gdmm"): gdmm1xrvv6685anhdjmwe0czexgmlpvrz6nqwq60syyzyk2dmez0wvn8dcaz6uaa
static immutable MM = KeyPair(PublicKey(Point([216, 205, 104, 244, 236, 238, 217, 109, 217, 126, 5, 147, 35, 127, 11, 6, 45, 76, 14, 6, 159, 2, 16, 68, 178, 155, 188, 137, 238, 100, 206, 220])), SecretKey(Scalar([3, 162, 254, 230, 81, 197, 230, 178, 193, 171, 250, 55, 108, 30, 60, 187, 115, 17, 3, 178, 45, 112, 8, 192, 65, 121, 248, 54, 28, 45, 126, 10])));
/// MN("gdmn"): gdmn1xrvd665t470ty6czcvzvs7l3xll7e4ntretwc5w9c6fpu0a6s0nq7c94fwp
static immutable MN = KeyPair(PublicKey(Point([216, 221, 106, 139, 175, 158, 178, 107, 2, 195, 4, 200, 123, 241, 55, 255, 236, 214, 107, 30, 86, 236, 81, 197, 198, 146, 30, 63, 186, 131, 230, 15])), SecretKey(Scalar([158, 208, 173, 181, 60, 228, 28, 186, 60, 95, 142, 135, 15, 63, 98, 60, 93, 88, 80, 52, 65, 44, 5, 172, 206, 250, 104, 64, 65, 52, 39, 8])));
/// MO("gdmo"): gdmo1xrvw669vxru33n3p3xu8e0syv00jhdnw2s6qcp4nra00kyju6twyc6vcctu
static immutable MO = KeyPair(PublicKey(Point([216, 237, 104, 172, 48, 249, 24, 206, 33, 137, 184, 124, 190, 4, 99, 223, 43, 182, 110, 84, 52, 12, 6, 179, 31, 94, 251, 18, 92, 210, 220, 76])), SecretKey(Scalar([204, 201, 9, 99, 174, 43, 28, 228, 47, 95, 115, 84, 144, 16, 231, 85, 235, 115, 195, 15, 168, 188, 251, 124, 106, 229, 110, 192, 7, 7, 235, 3])));
/// MP("gdmp"): gdmp1xrv066z5v8fc64snama84d2vps0h3jp9me4hrtdw8xn549g22ydtslmnnrh
static immutable MP = KeyPair(PublicKey(Point([216, 253, 104, 84, 97, 211, 141, 86, 19, 238, 250, 122, 181, 76, 12, 31, 120, 200, 37, 222, 107, 113, 173, 174, 57, 167, 74, 149, 10, 81, 26, 184])), SecretKey(Scalar([84, 60, 33, 22, 21, 183, 205, 61, 167, 182, 243, 123, 87, 191, 243, 43, 174, 218, 8, 182, 251, 226, 42, 231, 92, 192, 138, 240, 17, 146, 145, 8])));
/// MQ("gdmq"): gdmq1xrvs66nht4nfs9lql9nwss66w2xqp0f007rzd64lvrnk273gcfczwqvge5z
static immutable MQ = KeyPair(PublicKey(Point([217, 13, 106, 119, 93, 102, 152, 23, 224, 249, 102, 232, 67, 90, 114, 140, 0, 189, 47, 127, 134, 38, 234, 191, 96, 231, 101, 122, 40, 194, 112, 39])), SecretKey(Scalar([90, 177, 8, 115, 197, 193, 71, 113, 150, 95, 88, 117, 201, 126, 48, 240, 125, 159, 169, 48, 145, 181, 189, 37, 224, 17, 2, 122, 9, 36, 84, 13])));
/// MR("gdmr"): gdmr1xrv366fee3tsxh93u2t6r4m205wv9pryxz84pfn8kc7kxajsss89g0yf89c
static immutable MR = KeyPair(PublicKey(Point([217, 29, 105, 57, 204, 87, 3, 92, 177, 226, 151, 161, 215, 106, 125, 28, 194, 132, 100, 48, 143, 80, 166, 103, 182, 61, 99, 118, 80, 132, 14, 84])), SecretKey(Scalar([213, 60, 30, 93, 60, 20, 79, 164, 146, 85, 190, 48, 217, 50, 65, 248, 202, 9, 75, 56, 63, 113, 59, 119, 11, 200, 18, 37, 87, 102, 203, 7])));
/// MS("gdms"): gdms1xrvj66t0gy5sh2t2vaprmg7px8mpeyaz8e7fnsc90kvghrhw43d3g324m9u
static immutable MS = KeyPair(PublicKey(Point([217, 45, 105, 111, 65, 41, 11, 169, 106, 103, 66, 61, 163, 193, 49, 246, 28, 147, 162, 62, 124, 153, 195, 5, 125, 152, 139, 142, 238, 172, 91, 20])), SecretKey(Scalar([225, 137, 215, 108, 67, 12, 174, 229, 226, 38, 45, 132, 212, 66, 224, 116, 122, 107, 193, 157, 62, 179, 28, 216, 10, 113, 192, 100, 123, 169, 112, 15])));
/// MT("gdmt"): gdmt1xrvn665mzh7n0xay83lmnkdyksn2lzj90p8pnl4a9fnwjxhf0ltzccaqg03
static immutable MT = KeyPair(PublicKey(Point([217, 61, 106, 155, 21, 253, 55, 155, 164, 60, 127, 185, 217, 164, 180, 38, 175, 138, 69, 120, 78, 25, 254, 189, 42, 102, 233, 26, 233, 127, 214, 44])), SecretKey(Scalar([25, 25, 104, 17, 242, 245, 51, 227, 47, 123, 168, 186, 22, 181, 130, 255, 122, 137, 192, 72, 222, 57, 217, 197, 39, 237, 77, 252, 241, 217, 163, 10])));
/// MU("gdmu"): gdmu1xrv566le7yeqxm5m6km0msts4ugk5pglnh8r0mdxwfaen3w5gsv9kyup4cu
static immutable MU = KeyPair(PublicKey(Point([217, 77, 107, 249, 241, 50, 3, 110, 155, 213, 182, 253, 193, 112, 175, 17, 106, 5, 31, 157, 206, 55, 237, 166, 114, 123, 153, 197, 212, 68, 24, 91])), SecretKey(Scalar([241, 181, 88, 113, 20, 211, 50, 188, 197, 60, 221, 13, 238, 48, 100, 99, 199, 135, 250, 204, 49, 215, 234, 126, 253, 221, 210, 67, 92, 94, 124, 3])));
/// MV("gdmv"): gdmv1xrv4668lmzfrzel9y7h9cqvqqsnfq7ypenjwsv58hmkawa4wlwcc2rmnyzy
static immutable MV = KeyPair(PublicKey(Point([217, 93, 104, 255, 216, 146, 49, 103, 229, 39, 174, 92, 1, 128, 4, 38, 144, 120, 129, 204, 228, 232, 50, 135, 190, 237, 215, 118, 174, 251, 177, 133])), SecretKey(Scalar([112, 72, 109, 36, 35, 139, 252, 54, 213, 88, 34, 195, 243, 204, 235, 118, 236, 136, 229, 151, 6, 216, 131, 98, 44, 133, 86, 175, 34, 34, 215, 3])));
/// MW("gdmw"): gdmw1xrvk66sxduryrf9dqd25v9ux56egwdqn98j74hqvvz8vgpppu867z6txdwt
static immutable MW = KeyPair(PublicKey(Point([217, 109, 106, 6, 111, 6, 65, 164, 173, 3, 85, 70, 23, 134, 166, 178, 135, 52, 19, 41, 229, 234, 220, 12, 96, 142, 196, 4, 33, 225, 245, 225])), SecretKey(Scalar([30, 88, 50, 41, 79, 73, 172, 204, 19, 56, 22, 37, 47, 203, 27, 239, 249, 206, 26, 167, 12, 117, 60, 244, 158, 39, 193, 85, 244, 215, 252, 0])));
/// MX("gdmx"): gdmx1xrvh66qts8hx2ar5vhn2p4zn6te2t5w7v0ytarsag7fuv30d5zde56m6c4m
static immutable MX = KeyPair(PublicKey(Point([217, 125, 104, 11, 129, 238, 101, 116, 116, 101, 230, 160, 212, 83, 210, 242, 165, 209, 222, 99, 200, 190, 142, 29, 71, 147, 198, 69, 237, 160, 155, 154])), SecretKey(Scalar([102, 153, 84, 137, 126, 186, 254, 49, 184, 244, 54, 219, 95, 63, 173, 11, 174, 221, 128, 100, 48, 27, 211, 43, 175, 42, 127, 48, 233, 79, 145, 13])));
/// MY("gdmy"): gdmy1xrvc66ky2kq8xtzkfj02sua6hjjrjuy0ylthv4wg7tnl0mnu67vj6qfqfnd
static immutable MY = KeyPair(PublicKey(Point([217, 141, 106, 196, 85, 128, 115, 44, 86, 76, 158, 168, 115, 186, 188, 164, 57, 112, 143, 39, 215, 118, 85, 200, 242, 231, 247, 238, 124, 215, 153, 45])), SecretKey(Scalar([72, 83, 41, 112, 76, 252, 83, 201, 19, 125, 32, 205, 42, 213, 227, 7, 33, 10, 4, 24, 217, 40, 47, 73, 50, 99, 189, 136, 220, 17, 226, 15])));
/// MZ("gdmz"): gdmz1xrve66yvjz55pfh6jktajl599xegnends9dy2n7t8shuzrk9fpqqyjn7dny
static immutable MZ = KeyPair(PublicKey(Point([217, 157, 104, 140, 144, 169, 64, 166, 250, 149, 151, 217, 126, 133, 41, 178, 137, 230, 109, 129, 90, 69, 79, 203, 60, 47, 193, 14, 197, 72, 64, 2])), SecretKey(Scalar([134, 78, 156, 1, 90, 142, 153, 35, 201, 196, 94, 138, 145, 56, 85, 27, 197, 198, 44, 235, 110, 215, 177, 72, 61, 147, 207, 143, 215, 4, 120, 5])));
/// NA("gdna"): gdna1xrdq66ggu0r0c4cpv8hulcmc2ngzmqvn0tfz2pyk6myum9amz2w9ysda5l6
static immutable NA = KeyPair(PublicKey(Point([218, 13, 105, 8, 227, 198, 252, 87, 1, 97, 239, 207, 227, 120, 84, 208, 45, 129, 147, 122, 210, 37, 4, 150, 214, 201, 205, 151, 187, 18, 156, 82])), SecretKey(Scalar([90, 101, 204, 120, 160, 118, 177, 202, 20, 25, 161, 71, 182, 92, 28, 231, 2, 237, 111, 214, 104, 48, 36, 156, 64, 245, 53, 45, 53, 53, 113, 12])));
/// NB("gdnb"): gdnb1xrdp664h6yy903w95yj5eh9gkwexfnyn72jdyeas4kpffjv8kh4c278euhx
static immutable NB = KeyPair(PublicKey(Point([218, 29, 106, 183, 209, 8, 87, 197, 197, 161, 37, 76, 220, 168, 179, 178, 100, 204, 147, 242, 164, 210, 103, 176, 173, 130, 148, 201, 135, 181, 235, 133])), SecretKey(Scalar([36, 112, 104, 112, 205, 45, 63, 142, 76, 135, 240, 205, 223, 29, 133, 195, 87, 254, 122, 196, 246, 125, 111, 253, 85, 16, 113, 199, 175, 212, 95, 11])));
/// NC("gdnc"): gdnc1xrdz66adzkmds0czfz0582wy8425smqe6r9hxte7gevxp8055fqqwl05t2y
static immutable NC = KeyPair(PublicKey(Point([218, 45, 107, 173, 21, 182, 216, 63, 2, 72, 159, 67, 169, 196, 61, 85, 72, 108, 25, 208, 203, 115, 47, 62, 70, 88, 96, 157, 244, 162, 64, 7])), SecretKey(Scalar([203, 198, 5, 159, 86, 82, 83, 187, 32, 250, 20, 45, 244, 252, 193, 196, 9, 231, 21, 104, 65, 230, 170, 12, 198, 96, 26, 98, 203, 157, 255, 13])));
/// ND("gdnd"): gdnd1xrdr66a4m492kh83d4xu6a6vq8t4ngp3wdgfcdgmjwpcdgcs7p69yvz4hel
static immutable ND = KeyPair(PublicKey(Point([218, 61, 107, 181, 221, 74, 171, 92, 241, 109, 77, 205, 119, 76, 1, 215, 89, 160, 49, 115, 80, 156, 53, 27, 147, 131, 134, 163, 16, 240, 116, 82])), SecretKey(Scalar([248, 47, 245, 47, 91, 152, 213, 198, 178, 227, 239, 83, 188, 112, 14, 246, 58, 7, 152, 248, 163, 162, 224, 61, 18, 174, 27, 254, 179, 64, 240, 8])));
/// NE("gdne"): gdne1xrdy66r4vqx2gefmj5dvh55fpvu34xj9hh73853y7zsjxac8evhs2hpmevv
static immutable NE = KeyPair(PublicKey(Point([218, 77, 104, 117, 96, 12, 164, 101, 59, 149, 26, 203, 210, 137, 11, 57, 26, 154, 69, 189, 253, 19, 210, 36, 240, 161, 35, 119, 7, 203, 47, 5])), SecretKey(Scalar([169, 60, 9, 106, 14, 112, 16, 238, 131, 42, 224, 24, 107, 163, 238, 206, 109, 127, 65, 96, 220, 139, 145, 177, 126, 170, 116, 132, 129, 66, 88, 1])));
/// NF("gdnf"): gdnf1xrd966e2lh66p64fscranzt69djz8f96m0tgrzdmmdpkdnj9v2ue7u4nkwj
static immutable NF = KeyPair(PublicKey(Point([218, 93, 107, 42, 253, 245, 160, 234, 169, 134, 7, 217, 137, 122, 43, 100, 35, 164, 186, 219, 214, 129, 137, 187, 219, 67, 102, 206, 69, 98, 185, 159])), SecretKey(Scalar([28, 82, 94, 16, 62, 190, 227, 93, 229, 227, 69, 111, 196, 52, 78, 173, 104, 113, 27, 65, 174, 172, 79, 155, 105, 32, 128, 24, 200, 66, 76, 13])));
/// NG("gdng"): gdng1xrdx6623cvmjwqtgsexf43yaykc5526cr6jvw5xtl2n45508algwvs3rlj4
static immutable NG = KeyPair(PublicKey(Point([218, 109, 105, 81, 195, 55, 39, 1, 104, 134, 76, 154, 196, 157, 37, 177, 74, 43, 88, 30, 164, 199, 80, 203, 250, 167, 90, 81, 231, 239, 208, 230])), SecretKey(Scalar([196, 232, 114, 154, 142, 253, 103, 162, 243, 97, 156, 171, 50, 50, 73, 59, 34, 57, 136, 116, 199, 226, 130, 196, 103, 4, 216, 247, 43, 199, 246, 6])));
/// NH("gdnh"): gdnh1xrd866r2mxulm9e2ty66x0nv5yq5jv4rvt7ryvgl2caftg67ugqpq5gsumz
static immutable NH = KeyPair(PublicKey(Point([218, 125, 104, 106, 217, 185, 253, 151, 42, 89, 53, 163, 62, 108, 161, 1, 73, 50, 163, 98, 252, 50, 49, 31, 86, 58, 149, 163, 94, 226, 0, 16])), SecretKey(Scalar([160, 56, 11, 35, 230, 103, 160, 192, 30, 172, 210, 86, 142, 169, 10, 129, 248, 27, 154, 182, 218, 218, 33, 178, 80, 127, 118, 157, 48, 215, 70, 10])));
/// NI("gdni"): gdni1xrdg66ulv43evcfvwvhh9nxlqu87kczd3m60wsge4vjy98y7sy4tyvwtygy
static immutable NI = KeyPair(PublicKey(Point([218, 141, 107, 159, 101, 99, 150, 97, 44, 115, 47, 114, 204, 223, 7, 15, 235, 96, 77, 142, 244, 247, 65, 25, 171, 36, 66, 156, 158, 129, 42, 178])), SecretKey(Scalar([35, 59, 115, 91, 142, 218, 239, 67, 227, 254, 134, 83, 50, 187, 53, 90, 10, 36, 202, 228, 58, 54, 20, 227, 198, 86, 84, 240, 232, 106, 14, 9])));
/// NJ("gdnj"): gdnj1xrdf666r35aeus64f0y8pcqac5mq2zls07gx98kzkpzg845zf0awk0zqp80
static immutable NJ = KeyPair(PublicKey(Point([218, 157, 107, 67, 141, 59, 158, 67, 85, 75, 200, 112, 224, 29, 197, 54, 5, 11, 240, 127, 144, 98, 158, 194, 176, 68, 131, 214, 130, 75, 250, 235])), SecretKey(Scalar([84, 52, 140, 37, 59, 32, 217, 38, 204, 212, 174, 150, 212, 176, 204, 149, 143, 163, 134, 158, 94, 24, 88, 66, 179, 131, 34, 18, 134, 182, 130, 2])));
/// NK("gdnk"): gdnk1xrd266nxqjsyargvlnqrnsm5y4eas0y3752sslsq0cah9vdqfwtugk08us5
static immutable NK = KeyPair(PublicKey(Point([218, 173, 106, 102, 4, 160, 78, 141, 12, 252, 192, 57, 195, 116, 37, 115, 216, 60, 145, 245, 21, 8, 126, 0, 126, 59, 114, 177, 160, 75, 151, 196])), SecretKey(Scalar([225, 30, 1, 251, 57, 65, 141, 249, 246, 186, 252, 227, 98, 253, 46, 40, 128, 94, 178, 54, 86, 167, 228, 13, 69, 1, 98, 179, 76, 222, 225, 14])));
/// NL("gdnl"): gdnl1xrdt660zm5gz45gupuklhq7fwrl2ty3n5q5eykeh7r4kxmxx0hzk6wn3yga
static immutable NL = KeyPair(PublicKey(Point([218, 189, 105, 226, 221, 16, 42, 209, 28, 15, 45, 251, 131, 201, 112, 254, 165, 146, 51, 160, 41, 146, 91, 55, 240, 235, 99, 108, 198, 125, 197, 109])), SecretKey(Scalar([79, 208, 214, 136, 168, 79, 140, 206, 202, 208, 6, 110, 195, 235, 215, 35, 246, 206, 136, 174, 55, 175, 6, 202, 191, 171, 248, 6, 91, 132, 221, 13])));
/// NM("gdnm"): gdnm1xrdv662t57dvte6r08c06z2utth6cq6nwcplk5y4jqcgjemkhf0sqjgeqp4
static immutable NM = KeyPair(PublicKey(Point([218, 205, 105, 75, 167, 154, 197, 231, 67, 121, 240, 253, 9, 92, 90, 239, 172, 3, 83, 118, 3, 251, 80, 149, 144, 48, 137, 103, 118, 186, 95, 0])), SecretKey(Scalar([58, 124, 194, 133, 57, 115, 218, 109, 149, 231, 168, 105, 176, 81, 32, 228, 128, 187, 240, 196, 226, 118, 11, 136, 15, 157, 38, 6, 204, 43, 24, 10])));
/// NN("gdnn"): gdnn1xrdd66u96p4ghg74ccla89h0n8hcs92u98apg2vykrry4l8q6eykuex0uw9
static immutable NN = KeyPair(PublicKey(Point([218, 221, 107, 133, 208, 106, 139, 163, 213, 198, 63, 211, 150, 239, 153, 239, 136, 21, 92, 41, 250, 20, 41, 132, 176, 198, 74, 252, 224, 214, 73, 110])), SecretKey(Scalar([28, 178, 187, 163, 198, 224, 73, 156, 138, 81, 210, 176, 186, 226, 37, 43, 6, 228, 202, 102, 201, 221, 233, 52, 136, 82, 96, 200, 87, 15, 50, 12])));
/// NO("gdno"): gdno1xrdw666c2jngv0czrc5qwrlqdnvj68hkvrvlcp7cvpm7dqzcqt2769yzrh4
static immutable NO = KeyPair(PublicKey(Point([218, 237, 107, 88, 84, 166, 134, 63, 2, 30, 40, 7, 15, 224, 108, 217, 45, 30, 246, 96, 217, 252, 7, 216, 96, 119, 230, 128, 88, 2, 213, 237])), SecretKey(Scalar([221, 197, 51, 228, 36, 242, 10, 102, 80, 241, 169, 37, 130, 95, 148, 155, 26, 105, 164, 5, 69, 75, 80, 13, 87, 64, 194, 152, 172, 147, 115, 13])));
/// NP("gdnp"): gdnp1xrd066y2hk3stk55gs3talj7jfpxyt52fmxumeduynve0hmfgdhgz49v89q
static immutable NP = KeyPair(PublicKey(Point([218, 253, 104, 138, 189, 163, 5, 218, 148, 68, 34, 190, 254, 94, 146, 66, 98, 46, 138, 78, 205, 205, 229, 188, 36, 217, 151, 223, 105, 67, 110, 129])), SecretKey(Scalar([109, 137, 5, 105, 208, 91, 224, 5, 3, 224, 115, 163, 138, 198, 42, 106, 126, 128, 15, 129, 229, 250, 132, 149, 214, 34, 174, 166, 178, 106, 196, 9])));
/// NQ("gdnq"): gdnq1xrds6688lqj45kfrarkz7xafj9esjus95546py0l86t0frcx6twpgkkzc26
static immutable NQ = KeyPair(PublicKey(Point([219, 13, 104, 231, 248, 37, 90, 89, 35, 232, 236, 47, 27, 169, 145, 115, 9, 114, 5, 165, 43, 160, 145, 255, 62, 150, 244, 143, 6, 210, 220, 20])), SecretKey(Scalar([73, 19, 251, 38, 84, 117, 96, 9, 173, 132, 161, 99, 164, 119, 118, 162, 95, 254, 78, 150, 125, 60, 178, 122, 229, 87, 43, 201, 125, 250, 63, 13])));
/// NR("gdnr"): gdnr1xrd366venec6fqhz885ah7kg6cjl83tq4qh0rea7ca20ydn940r0qvl6kvd
static immutable NR = KeyPair(PublicKey(Point([219, 29, 105, 153, 158, 113, 164, 130, 226, 57, 233, 219, 250, 200, 214, 37, 243, 197, 96, 168, 46, 241, 231, 190, 199, 84, 242, 54, 101, 171, 198, 240])), SecretKey(Scalar([236, 231, 225, 247, 111, 169, 172, 101, 147, 52, 55, 100, 58, 99, 141, 77, 163, 43, 248, 43, 155, 2, 164, 36, 131, 120, 214, 79, 96, 128, 89, 0])));
/// NS("gdns"): gdns1xrdj66faet44yqckk55f84wutrq3kukq6mude5usc29vktsvkx9qvj7hng3
static immutable NS = KeyPair(PublicKey(Point([219, 45, 105, 61, 202, 235, 82, 3, 22, 181, 40, 147, 213, 220, 88, 193, 27, 114, 192, 214, 248, 220, 211, 144, 194, 138, 203, 46, 12, 177, 138, 6])), SecretKey(Scalar([133, 145, 79, 215, 29, 103, 244, 2, 206, 148, 134, 71, 196, 67, 20, 169, 227, 252, 216, 88, 229, 87, 224, 79, 241, 7, 14, 59, 144, 144, 113, 13])));
/// NT("gdnt"): gdnt1xrdn66yv5fleum5rpd2r6s02uxrzm4ykvj4e9nucjgnmntjdpq8ksxfzkcs
static immutable NT = KeyPair(PublicKey(Point([219, 61, 104, 140, 162, 127, 158, 110, 131, 11, 84, 61, 65, 234, 225, 134, 45, 212, 150, 100, 171, 146, 207, 152, 146, 39, 185, 174, 77, 8, 15, 104])), SecretKey(Scalar([218, 99, 235, 252, 236, 195, 85, 10, 198, 189, 232, 196, 95, 14, 18, 249, 16, 14, 190, 76, 165, 3, 31, 77, 85, 164, 220, 110, 158, 227, 168, 2])));
/// NU("gdnu"): gdnu1xrd566z3rgqx8tx8wdcxw22jgenzrmc7j8dgyr8802qkfneedycjvwd7hrz
static immutable NU = KeyPair(PublicKey(Point([219, 77, 104, 81, 26, 0, 99, 172, 199, 115, 112, 103, 41, 82, 70, 102, 33, 239, 30, 145, 218, 130, 12, 231, 122, 129, 100, 207, 57, 105, 49, 38])), SecretKey(Scalar([61, 12, 142, 249, 234, 164, 196, 188, 231, 31, 232, 14, 90, 26, 171, 135, 200, 209, 250, 97, 106, 80, 62, 232, 152, 85, 215, 80, 22, 94, 71, 0])));
/// NV("gdnv"): gdnv1xrd466e9l4khf9gjtst78lwgelqt4q6xz56vvrlty42ueydxhfcez3fuhvt
static immutable NV = KeyPair(PublicKey(Point([219, 93, 107, 37, 253, 109, 116, 149, 18, 92, 23, 227, 253, 200, 207, 192, 186, 131, 70, 21, 52, 198, 15, 235, 37, 85, 204, 145, 166, 186, 113, 145])), SecretKey(Scalar([49, 10, 124, 166, 208, 85, 5, 220, 162, 197, 91, 45, 232, 144, 240, 158, 245, 137, 32, 165, 56, 104, 214, 240, 157, 47, 95, 49, 132, 45, 107, 11])));
/// NW("gdnw"): gdnw1xrdk66m330yr3x9pkxey8muv8ud04pjskedvemrrt9yfcryyyw42zvkjg7a
static immutable NW = KeyPair(PublicKey(Point([219, 109, 107, 113, 139, 200, 56, 152, 161, 177, 178, 67, 239, 140, 63, 26, 250, 134, 80, 182, 90, 204, 236, 99, 89, 72, 156, 12, 132, 35, 170, 161])), SecretKey(Scalar([9, 151, 175, 126, 152, 61, 96, 103, 254, 50, 58, 111, 148, 155, 86, 153, 221, 98, 234, 55, 224, 55, 163, 70, 117, 175, 50, 227, 0, 111, 36, 7])));
/// NX("gdnx"): gdnx1xrdh66hac4wmtjhgjthja2ehwf4vn7vh9rw3jvsegn5tsnrpd2qrkulzzd0
static immutable NX = KeyPair(PublicKey(Point([219, 125, 106, 253, 197, 93, 181, 202, 232, 146, 239, 46, 171, 55, 114, 106, 201, 249, 151, 40, 221, 25, 50, 25, 68, 232, 184, 76, 97, 106, 128, 59])), SecretKey(Scalar([135, 145, 247, 227, 220, 145, 0, 1, 107, 122, 212, 224, 186, 150, 66, 250, 154, 230, 230, 14, 17, 202, 246, 217, 194, 140, 65, 222, 222, 51, 148, 4])));
/// NY("gdny"): gdny1xrdc66kvsj4nfcvjc25yvvmwl5npahfrqk0twznp6mu58q0f8ys4wzd77p5
static immutable NY = KeyPair(PublicKey(Point([219, 141, 106, 204, 132, 171, 52, 225, 146, 194, 168, 70, 51, 110, 253, 38, 30, 221, 35, 5, 158, 183, 10, 97, 214, 249, 67, 129, 233, 57, 33, 87])), SecretKey(Scalar([26, 161, 5, 28, 61, 152, 215, 140, 165, 116, 145, 172, 27, 35, 195, 138, 206, 121, 118, 250, 31, 246, 104, 46, 55, 2, 136, 224, 96, 205, 239, 0])));
/// NZ("gdnz"): gdnz1xrde66yf0v8r8z0xwre0re4vu899c6qqvn44amn4qemjc8ns8turzymkxk5
static immutable NZ = KeyPair(PublicKey(Point([219, 157, 104, 137, 123, 14, 51, 137, 230, 112, 242, 241, 230, 172, 225, 202, 92, 104, 0, 100, 235, 94, 238, 117, 6, 119, 44, 30, 112, 58, 248, 49])), SecretKey(Scalar([194, 30, 175, 34, 83, 46, 103, 210, 155, 8, 37, 27, 164, 233, 71, 75, 15, 75, 10, 68, 18, 31, 152, 38, 71, 56, 227, 204, 142, 49, 63, 14])));
/// OA("gdoa"): gdoa1xrwq66alasu563glt47sx2pdj9zg6xy0zdvkgluucldcmxemn79nz69f3mm
static immutable OA = KeyPair(PublicKey(Point([220, 13, 107, 191, 236, 57, 77, 69, 31, 93, 125, 3, 40, 45, 145, 68, 141, 24, 143, 19, 89, 100, 127, 156, 199, 219, 141, 155, 59, 159, 139, 49])), SecretKey(Scalar([12, 143, 133, 117, 115, 203, 89, 167, 56, 208, 108, 141, 185, 25, 245, 196, 46, 206, 80, 193, 93, 238, 148, 226, 133, 204, 44, 92, 67, 82, 135, 10])));
/// OB("gdob"): gdob1xrwp66f9xqq79x9h5n5wf7vqqqye2t55xjjhfjfww9t5vngtk78y7jqz5qp
static immutable OB = KeyPair(PublicKey(Point([220, 29, 105, 37, 48, 1, 226, 152, 183, 164, 232, 228, 249, 128, 0, 9, 149, 46, 148, 52, 165, 116, 201, 46, 113, 87, 70, 77, 11, 183, 142, 79])), SecretKey(Scalar([52, 196, 21, 163, 130, 81, 70, 249, 21, 203, 189, 20, 183, 191, 240, 64, 140, 110, 213, 127, 214, 5, 252, 212, 9, 130, 150, 171, 55, 10, 191, 15])));
/// OC("gdoc"): gdoc1xrwz66eq7q5j7kjy045wpmqxh7qen2uzjxygkfgtrg7dulutlcyvvtvjvjy
static immutable OC = KeyPair(PublicKey(Point([220, 45, 107, 32, 240, 41, 47, 90, 68, 125, 104, 224, 236, 6, 191, 129, 153, 171, 130, 145, 136, 139, 37, 11, 26, 60, 222, 127, 139, 254, 8, 198])), SecretKey(Scalar([49, 170, 194, 208, 237, 226, 71, 21, 26, 152, 176, 129, 161, 123, 202, 45, 46, 68, 61, 110, 141, 40, 79, 204, 144, 208, 144, 224, 5, 81, 44, 5])));
/// OD("gdod"): gdod1xrwr66nu6hl3nzwpk2pje7qp9ua4k2crzugeegn3j6y73m4sx9lz786kczc
static immutable OD = KeyPair(PublicKey(Point([220, 61, 106, 124, 213, 255, 25, 137, 193, 178, 131, 44, 248, 1, 47, 59, 91, 43, 3, 23, 17, 156, 162, 113, 150, 137, 232, 238, 176, 49, 126, 47])), SecretKey(Scalar([167, 55, 118, 227, 15, 72, 177, 237, 13, 141, 17, 195, 0, 22, 91, 143, 189, 235, 99, 202, 248, 36, 142, 103, 89, 199, 165, 99, 153, 224, 10, 9])));
/// OE("gdoe"): gdoe1xrwy66lqzm6z3l5jnrem8qgcf2fwawep8nays32wrwpmrcgwkn0hsd49lt2
static immutable OE = KeyPair(PublicKey(Point([220, 77, 107, 224, 22, 244, 40, 254, 146, 152, 243, 179, 129, 24, 74, 146, 238, 187, 33, 60, 250, 72, 69, 78, 27, 131, 177, 225, 14, 180, 223, 120])), SecretKey(Scalar([141, 113, 1, 225, 160, 204, 11, 70, 183, 136, 39, 150, 195, 48, 219, 25, 33, 225, 76, 145, 10, 96, 66, 141, 182, 150, 133, 247, 59, 72, 37, 6])));
/// OF("gdof"): gdof1xrw9664kpgrm6zkecdzdzqvlket9pyl3eph8anrp2zuvdrvxmdfdy4a9dtt
static immutable OF = KeyPair(PublicKey(Point([220, 93, 106, 182, 10, 7, 189, 10, 217, 195, 68, 209, 1, 159, 182, 86, 80, 147, 241, 200, 110, 126, 204, 97, 80, 184, 198, 141, 134, 219, 82, 210])), SecretKey(Scalar([181, 179, 71, 231, 209, 244, 204, 85, 105, 123, 100, 48, 176, 21, 187, 105, 120, 32, 147, 136, 99, 144, 237, 185, 154, 31, 109, 178, 9, 78, 192, 14])));
/// OG("gdog"): gdog1xrwx66m5ua96qrg78wlnayfpt58xx84zsxllgjd4t8caj96p6zf27xh83d3
static immutable OG = KeyPair(PublicKey(Point([220, 109, 107, 116, 231, 75, 160, 13, 30, 59, 191, 62, 145, 33, 93, 14, 99, 30, 162, 129, 191, 244, 73, 181, 89, 241, 217, 23, 65, 208, 146, 175])), SecretKey(Scalar([111, 215, 9, 46, 158, 67, 225, 146, 228, 164, 109, 9, 213, 241, 215, 252, 126, 173, 162, 232, 202, 213, 165, 52, 153, 14, 218, 165, 208, 170, 190, 14])));
/// OH("gdoh"): gdoh1xrw866w500ge956et83y57apvnapxts5rhecwh5g2qwrqm88z70dw6ygfc9
static immutable OH = KeyPair(PublicKey(Point([220, 125, 105, 212, 123, 209, 146, 211, 89, 89, 226, 74, 123, 161, 100, 250, 19, 46, 20, 29, 243, 135, 94, 136, 80, 28, 48, 108, 231, 23, 158, 215])), SecretKey(Scalar([30, 127, 111, 117, 252, 58, 200, 230, 104, 143, 63, 102, 248, 230, 39, 240, 3, 28, 75, 183, 69, 79, 235, 111, 92, 114, 176, 4, 218, 208, 153, 14])));
/// OI("gdoi"): gdoi1xrwg66tzwcqn80yq8mzrj958xftdnemxeyxjye5jmpryajvj4wsmjujnxvz
static immutable OI = KeyPair(PublicKey(Point([220, 141, 105, 98, 118, 1, 51, 188, 128, 62, 196, 57, 22, 135, 50, 86, 217, 231, 102, 201, 13, 34, 102, 146, 216, 70, 78, 201, 146, 171, 161, 185])), SecretKey(Scalar([255, 186, 136, 25, 75, 10, 225, 5, 84, 224, 28, 154, 73, 175, 224, 28, 59, 234, 49, 14, 32, 200, 125, 67, 121, 10, 226, 35, 77, 105, 184, 12])));
/// OJ("gdoj"): gdoj1xrwf66qzd2e0arwlmamycn32fasrjr9upxnfx47yza57tpvy7jhewfpet8t
static immutable OJ = KeyPair(PublicKey(Point([220, 157, 104, 2, 106, 178, 254, 141, 223, 223, 118, 76, 78, 42, 79, 96, 57, 12, 188, 9, 166, 147, 87, 196, 23, 105, 229, 133, 132, 244, 175, 151])), SecretKey(Scalar([30, 245, 122, 162, 209, 210, 103, 89, 124, 203, 61, 188, 195, 24, 164, 221, 119, 34, 29, 25, 203, 30, 222, 206, 91, 160, 59, 5, 105, 90, 67, 11])));
/// OK("gdok"): gdok1xrw266mga209ma3grkar5m024g9j33v8x5p8falkkpseqa8r58w7zdnmjwr
static immutable OK = KeyPair(PublicKey(Point([220, 173, 107, 104, 234, 158, 93, 246, 40, 29, 186, 58, 109, 234, 170, 11, 40, 197, 135, 53, 2, 116, 247, 246, 176, 97, 144, 116, 227, 161, 221, 225])), SecretKey(Scalar([99, 188, 101, 159, 107, 152, 162, 30, 249, 33, 35, 61, 119, 40, 101, 226, 170, 197, 67, 254, 144, 208, 170, 105, 201, 250, 100, 35, 66, 126, 164, 13])));
/// OL("gdol"): gdol1xrwt66y0y7a3mh2t09utjufz5wdf0a798j05qqas4m0d35s8amx0jdee9la
static immutable OL = KeyPair(PublicKey(Point([220, 189, 104, 143, 39, 187, 29, 221, 75, 121, 120, 185, 113, 34, 163, 154, 151, 247, 197, 60, 159, 64, 3, 176, 174, 222, 216, 210, 7, 238, 204, 249])), SecretKey(Scalar([165, 82, 16, 45, 131, 22, 191, 200, 132, 15, 84, 204, 48, 166, 150, 249, 85, 230, 131, 23, 114, 200, 165, 28, 187, 93, 252, 206, 59, 147, 121, 2])));
/// OM("gdom"): gdom1xrwv66c0fw47hapregjn4medz2g37rrgnkcvdwzsnp0fu9zu0ldqgdwydwm
static immutable OM = KeyPair(PublicKey(Point([220, 205, 107, 15, 75, 171, 235, 244, 35, 202, 37, 58, 239, 45, 18, 145, 31, 12, 104, 157, 176, 198, 184, 80, 152, 94, 158, 20, 92, 127, 218, 4])), SecretKey(Scalar([190, 236, 67, 152, 94, 167, 169, 32, 250, 179, 94, 158, 127, 76, 225, 246, 46, 40, 14, 36, 253, 81, 179, 15, 252, 69, 211, 205, 59, 27, 179, 6])));
/// ON("gdon"): gdon1xrwd66nwg5ql5mmzhg6s9lh7r8yhwk5w8kzqa755crfe2gezssxsyusuv2d
static immutable ON = KeyPair(PublicKey(Point([220, 221, 106, 110, 69, 1, 250, 111, 98, 186, 53, 2, 254, 254, 25, 201, 119, 90, 142, 61, 132, 14, 250, 148, 192, 211, 149, 35, 34, 132, 13, 2])), SecretKey(Scalar([93, 204, 70, 134, 112, 132, 237, 64, 155, 140, 168, 5, 149, 240, 59, 85, 198, 44, 179, 133, 76, 119, 165, 192, 119, 20, 254, 178, 155, 106, 35, 14])));
/// OO("gdoo"): gdoo1xrww66nlfxwuftlwu88sz623z9fqe3sl03at9nt82xkwvuzxmm8dyca0nmv
static immutable OO = KeyPair(PublicKey(Point([220, 237, 106, 127, 73, 157, 196, 175, 238, 225, 207, 1, 105, 81, 17, 82, 12, 198, 31, 124, 122, 178, 205, 103, 81, 172, 230, 112, 70, 222, 206, 210])), SecretKey(Scalar([250, 37, 178, 93, 224, 24, 205, 246, 225, 98, 165, 190, 167, 112, 202, 52, 238, 23, 253, 203, 10, 49, 174, 254, 14, 71, 204, 165, 174, 121, 213, 12])));
/// OP("gdop"): gdop1xrw066vjqzfhl0mefrdwnltt27vpjah9mnz5cqkagfgff4rapmdm5ksh8yj
static immutable OP = KeyPair(PublicKey(Point([220, 253, 105, 146, 0, 147, 127, 191, 121, 72, 218, 233, 253, 107, 87, 152, 25, 118, 229, 220, 197, 76, 2, 221, 66, 80, 148, 212, 125, 14, 219, 186])), SecretKey(Scalar([26, 49, 68, 48, 62, 152, 224, 167, 250, 4, 184, 140, 229, 29, 64, 122, 114, 10, 199, 69, 165, 216, 209, 16, 166, 11, 109, 14, 65, 74, 210, 8])));
/// OQ("gdoq"): gdoq1xrws66l8a4t7c7lmxry8trfhv7cl5cdzyvzztpp8j73apl06f8hhw7z4yjs
static immutable OQ = KeyPair(PublicKey(Point([221, 13, 107, 231, 237, 87, 236, 123, 251, 48, 200, 117, 141, 55, 103, 177, 250, 97, 162, 35, 4, 37, 132, 39, 151, 163, 208, 253, 250, 73, 239, 119])), SecretKey(Scalar([201, 92, 195, 32, 238, 39, 41, 178, 172, 141, 254, 253, 97, 209, 196, 36, 137, 113, 88, 136, 248, 187, 235, 31, 83, 183, 85, 172, 148, 204, 15, 8])));
/// OR("gdor"): gdor1xrw366ahxjct3h4ujqmyvf60p035lasaupl8p6vwa8tsc43janu6q7sa0ds
static immutable OR = KeyPair(PublicKey(Point([221, 29, 107, 183, 52, 176, 184, 222, 188, 144, 54, 70, 39, 79, 11, 227, 79, 246, 29, 224, 126, 112, 233, 142, 233, 215, 12, 86, 50, 236, 249, 160])), SecretKey(Scalar([228, 176, 170, 159, 14, 252, 52, 103, 244, 250, 43, 160, 100, 174, 84, 206, 247, 132, 9, 29, 62, 35, 175, 107, 253, 121, 211, 184, 234, 4, 198, 14])));
/// OS("gdos"): gdos1xrwj669m9xypk9hgs5w2mu9vmyjys764j56ej73q9545lfqlytzjjvvffs3
static immutable OS = KeyPair(PublicKey(Point([221, 45, 104, 187, 41, 136, 27, 22, 232, 133, 28, 173, 240, 172, 217, 36, 72, 123, 85, 149, 53, 153, 122, 32, 45, 43, 79, 164, 31, 34, 197, 41])), SecretKey(Scalar([147, 241, 66, 227, 16, 24, 101, 129, 248, 207, 189, 97, 158, 117, 70, 1, 178, 220, 33, 120, 199, 209, 110, 139, 43, 174, 246, 26, 153, 2, 202, 1])));
/// OT("gdot"): gdot1xrwn665xhhle280yv9vpa38fu63dh3dcfkn4v7cgznf5nvgjqf8gzz2rmde
static immutable OT = KeyPair(PublicKey(Point([221, 61, 106, 134, 189, 255, 149, 29, 228, 97, 88, 30, 196, 233, 230, 162, 219, 197, 184, 77, 167, 86, 123, 8, 20, 211, 73, 177, 18, 2, 78, 129])), SecretKey(Scalar([42, 61, 114, 98, 202, 120, 31, 103, 123, 179, 131, 206, 184, 69, 148, 218, 205, 67, 151, 167, 111, 249, 151, 235, 120, 72, 220, 200, 52, 25, 52, 6])));
/// OU("gdou"): gdou1xrw566vtzrqg4cs3z0x0c7dfvqyn8xj4t8mx29dzwggf6k9awdqukuw7dc9
static immutable OU = KeyPair(PublicKey(Point([221, 77, 105, 139, 16, 192, 138, 226, 17, 19, 204, 252, 121, 169, 96, 9, 51, 154, 85, 89, 246, 101, 21, 162, 114, 16, 157, 88, 189, 115, 65, 203])), SecretKey(Scalar([54, 101, 252, 81, 24, 32, 201, 148, 127, 191, 252, 175, 27, 22, 182, 172, 5, 37, 250, 202, 51, 197, 158, 82, 169, 209, 42, 68, 73, 229, 189, 12])));
/// OV("gdov"): gdov1xrw466ecfuws887crptx3qgzvqjhvp6f525tsagm5ylrppvkhnekkvaqfc2
static immutable OV = KeyPair(PublicKey(Point([221, 93, 107, 56, 79, 29, 3, 159, 216, 24, 86, 104, 129, 2, 96, 37, 118, 7, 73, 162, 168, 184, 117, 27, 161, 62, 48, 133, 150, 188, 243, 107])), SecretKey(Scalar([5, 54, 230, 113, 26, 81, 112, 94, 229, 63, 59, 138, 24, 175, 48, 137, 124, 217, 123, 238, 73, 190, 148, 145, 52, 118, 47, 128, 175, 94, 122, 3])));
/// OW("gdow"): gdow1xrwk66x93aq9e527djqhu0clgyud7lfd6y9npgmrh2uqlhc0td8mcqzlqaz
static immutable OW = KeyPair(PublicKey(Point([221, 109, 104, 197, 143, 64, 92, 209, 94, 108, 129, 126, 63, 31, 65, 56, 223, 125, 45, 209, 11, 48, 163, 99, 186, 184, 15, 223, 15, 91, 79, 188])), SecretKey(Scalar([47, 46, 93, 90, 74, 101, 142, 36, 10, 225, 227, 49, 84, 200, 110, 24, 45, 81, 232, 211, 185, 129, 176, 16, 110, 208, 161, 135, 201, 36, 86, 14])));
/// OX("gdox"): gdox1xrwh66jhfur0jgnn560mf0sz4597rek45xpnd94fdwl63xly4fecznj9nj9
static immutable OX = KeyPair(PublicKey(Point([221, 125, 106, 87, 79, 6, 249, 34, 115, 166, 159, 180, 190, 2, 173, 11, 225, 230, 213, 161, 131, 54, 150, 169, 107, 191, 168, 155, 228, 170, 115, 129])), SecretKey(Scalar([198, 42, 54, 242, 31, 239, 78, 149, 7, 3, 109, 200, 188, 66, 218, 141, 108, 128, 137, 162, 245, 207, 95, 32, 34, 113, 251, 133, 8, 178, 154, 4])));
/// OY("gdoy"): gdoy1xrwc662yhe496zqtcfpd48x8jg5nprw22gnhz39s2mdnaf65ayk0ywy9la3
static immutable OY = KeyPair(PublicKey(Point([221, 141, 105, 68, 190, 106, 93, 8, 11, 194, 66, 218, 156, 199, 146, 41, 48, 141, 202, 82, 39, 113, 68, 176, 86, 219, 62, 167, 84, 233, 44, 242])), SecretKey(Scalar([34, 243, 101, 248, 174, 198, 136, 39, 73, 119, 17, 216, 135, 224, 156, 23, 159, 5, 23, 0, 245, 176, 176, 159, 86, 178, 193, 145, 129, 74, 180, 9])));
/// OZ("gdoz"): gdoz1xrwe6603h2ut4ttq8cc6dttdnpzq0ldc8w0n3p3d6n9d07wx22q56ah2phl
static immutable OZ = KeyPair(PublicKey(Point([221, 157, 105, 241, 186, 184, 186, 173, 96, 62, 49, 166, 173, 109, 152, 68, 7, 253, 184, 59, 159, 56, 134, 45, 212, 202, 215, 249, 198, 82, 129, 77])), SecretKey(Scalar([239, 152, 147, 210, 99, 77, 149, 180, 3, 151, 24, 73, 63, 235, 166, 116, 26, 162, 98, 2, 65, 0, 75, 227, 58, 26, 213, 90, 124, 197, 242, 5])));
/// PA("gdpa"): gdpa1xr0q66hk3lhqwtnjzl24vdml3j668sgmnrut0j68sxfup04075xm7xsxpua
static immutable PA = KeyPair(PublicKey(Point([222, 13, 106, 246, 143, 238, 7, 46, 114, 23, 213, 86, 55, 127, 140, 181, 163, 193, 27, 152, 248, 183, 203, 71, 129, 147, 192, 190, 175, 245, 13, 191])), SecretKey(Scalar([22, 74, 94, 9, 119, 195, 112, 118, 57, 222, 86, 62, 149, 153, 120, 201, 255, 248, 17, 111, 153, 170, 97, 117, 158, 243, 138, 10, 206, 159, 189, 5])));
/// PB("gdpb"): gdpb1xr0p66ag5dsp9kgujtqlv7h0f6uupt560yd5z8w67gmmps2pchn2kcs4qnc
static immutable PB = KeyPair(PublicKey(Point([222, 29, 107, 168, 163, 96, 18, 217, 28, 146, 193, 246, 122, 239, 78, 185, 192, 174, 154, 121, 27, 65, 29, 218, 242, 55, 176, 193, 65, 197, 230, 171])), SecretKey(Scalar([116, 186, 164, 246, 0, 14, 150, 64, 185, 193, 32, 149, 245, 248, 170, 40, 16, 2, 91, 68, 101, 35, 212, 222, 85, 12, 173, 55, 244, 44, 245, 13])));
/// PC("gdpc"): gdpc1xr0z66et82n0qrh8d3d9zruasx0s74ulp7qh5eqwjcq3mcqjeecgydmff72
static immutable PC = KeyPair(PublicKey(Point([222, 45, 107, 43, 58, 166, 240, 14, 231, 108, 90, 81, 15, 157, 129, 159, 15, 87, 159, 15, 129, 122, 100, 14, 150, 1, 29, 224, 18, 206, 112, 130])), SecretKey(Scalar([119, 204, 250, 201, 197, 35, 226, 21, 45, 52, 203, 142, 186, 242, 28, 205, 122, 175, 215, 9, 175, 252, 171, 159, 240, 208, 49, 152, 18, 23, 48, 0])));
/// PD("gdpd"): gdpd1xr0r664g5mdmtg84rtkzgm8amgm7jur4mnvluega6ww6jqludkk7zdyy6ty
static immutable PD = KeyPair(PublicKey(Point([222, 61, 106, 168, 166, 219, 181, 160, 245, 26, 236, 36, 108, 253, 218, 55, 233, 112, 117, 220, 217, 254, 101, 29, 211, 157, 169, 3, 252, 109, 173, 225])), SecretKey(Scalar([224, 55, 239, 142, 7, 57, 53, 171, 154, 82, 102, 25, 24, 165, 78, 12, 25, 67, 232, 13, 1, 30, 210, 78, 197, 7, 111, 59, 135, 65, 61, 7])));
/// PE("gdpe"): gdpe1xr0y66khuyst7z8grxvuywjf7n4fc9k3hj0njcjh2cx8lt7za4v466shn4d
static immutable PE = KeyPair(PublicKey(Point([222, 77, 106, 215, 225, 32, 191, 8, 232, 25, 153, 194, 58, 73, 244, 234, 156, 22, 209, 188, 159, 57, 98, 87, 86, 12, 127, 175, 194, 237, 89, 93])), SecretKey(Scalar([43, 61, 131, 30, 57, 122, 92, 163, 82, 225, 112, 167, 215, 39, 113, 153, 137, 15, 101, 71, 251, 59, 102, 51, 7, 145, 88, 50, 216, 220, 38, 4])));
/// PF("gdpf"): gdpf1xr0966dg9vk5f3yew8mfvw62s9lkc86s6uhwjwws2utstffvqxvcjlpkz8h
static immutable PF = KeyPair(PublicKey(Point([222, 93, 105, 168, 43, 45, 68, 196, 153, 113, 246, 150, 59, 74, 129, 127, 108, 31, 80, 215, 46, 233, 57, 208, 87, 23, 5, 165, 44, 1, 153, 137])), SecretKey(Scalar([120, 70, 20, 207, 8, 80, 209, 226, 2, 209, 242, 209, 96, 85, 178, 188, 105, 32, 143, 4, 139, 212, 178, 230, 232, 161, 158, 223, 69, 219, 120, 2])));
/// PG("gdpg"): gdpg1xr0x66cf4ycszkh6rwefjtc22eknl29pt8a27ydl4gr36vv5qk9cyketydy
static immutable PG = KeyPair(PublicKey(Point([222, 109, 107, 9, 169, 49, 1, 90, 250, 27, 178, 153, 47, 10, 86, 109, 63, 168, 161, 89, 250, 175, 17, 191, 170, 7, 29, 49, 148, 5, 139, 130])), SecretKey(Scalar([153, 38, 98, 121, 163, 194, 249, 158, 133, 155, 252, 63, 62, 92, 46, 147, 208, 153, 231, 5, 209, 59, 183, 99, 254, 44, 34, 207, 252, 138, 148, 8])));
/// PH("gdph"): gdph1xr0866l28jpqh3ecy4khvyvdtjxwxqh0leds4a7yuzkmhfjwgqmh6u88e8y
static immutable PH = KeyPair(PublicKey(Point([222, 125, 107, 234, 60, 130, 11, 199, 56, 37, 109, 118, 17, 141, 92, 140, 227, 2, 239, 254, 91, 10, 247, 196, 224, 173, 187, 166, 78, 64, 55, 125])), SecretKey(Scalar([161, 21, 9, 76, 190, 75, 192, 251, 173, 70, 72, 254, 192, 234, 199, 25, 14, 148, 242, 236, 240, 169, 103, 49, 176, 81, 254, 223, 205, 68, 180, 8])));
/// PI("gdpi"): gdpi1xr0g66lcpv2vyp8ja2hh6ltfjvn8gjptk6t7xehchzxn0nzg9cx75w6lzy4
static immutable PI = KeyPair(PublicKey(Point([222, 141, 107, 248, 11, 20, 194, 4, 242, 234, 175, 125, 125, 105, 147, 38, 116, 72, 43, 182, 151, 227, 102, 248, 184, 141, 55, 204, 72, 46, 13, 234])), SecretKey(Scalar([109, 89, 18, 71, 163, 227, 166, 163, 124, 206, 39, 123, 191, 15, 252, 194, 233, 79, 128, 255, 144, 51, 33, 156, 68, 140, 5, 28, 141, 244, 24, 7])));
/// PJ("gdpj"): gdpj1xr0f66hpn5v5aw0rleskws3a6le737420w7yp4s02q6jwnnlqtw8k3n5dtl
static immutable PJ = KeyPair(PublicKey(Point([222, 157, 106, 225, 157, 25, 78, 185, 227, 254, 97, 103, 66, 61, 215, 243, 232, 250, 170, 123, 188, 64, 214, 15, 80, 53, 39, 78, 127, 2, 220, 123])), SecretKey(Scalar([128, 246, 245, 38, 109, 119, 120, 166, 48, 110, 7, 163, 131, 173, 35, 113, 197, 107, 231, 3, 9, 117, 31, 92, 20, 46, 114, 49, 28, 252, 221, 10])));
/// PK("gdpk"): gdpk1xr0266zy5wyq4ha3yzeg5hknux5m2mzwr9det0x2t05kzz5xj9yj257gzvv
static immutable PK = KeyPair(PublicKey(Point([222, 173, 104, 68, 163, 136, 10, 223, 177, 32, 178, 138, 94, 211, 225, 169, 181, 108, 78, 25, 91, 149, 188, 202, 91, 233, 97, 10, 134, 145, 73, 37])), SecretKey(Scalar([68, 22, 119, 116, 31, 135, 136, 170, 87, 173, 21, 22, 235, 181, 100, 148, 113, 78, 123, 241, 64, 224, 192, 209, 92, 124, 4, 7, 228, 24, 98, 15])));
/// PL("gdpl"): gdpl1xr0t66qy3gra2ehgcy5clw47jwvrmmj252dmpf3ydy9ksgenm4u7xy7j6rg
static immutable PL = KeyPair(PublicKey(Point([222, 189, 104, 4, 138, 7, 213, 102, 232, 193, 41, 143, 186, 190, 147, 152, 61, 238, 74, 162, 155, 176, 166, 36, 105, 11, 104, 35, 51, 221, 121, 227])), SecretKey(Scalar([175, 74, 24, 188, 244, 137, 159, 30, 188, 167, 53, 214, 158, 231, 255, 101, 179, 210, 140, 104, 169, 25, 234, 114, 99, 213, 101, 26, 193, 111, 89, 0])));
/// PM("gdpm"): gdpm1xr0v66nspf7g6u2rhzm0urftv8c779alfwterjffuukyp32qv7jwwvch7ld
static immutable PM = KeyPair(PublicKey(Point([222, 205, 106, 112, 10, 124, 141, 113, 67, 184, 182, 254, 13, 43, 97, 241, 239, 23, 191, 75, 151, 145, 201, 41, 231, 44, 64, 197, 64, 103, 164, 231])), SecretKey(Scalar([185, 255, 108, 87, 175, 206, 13, 3, 210, 89, 20, 151, 167, 35, 149, 24, 16, 168, 167, 93, 43, 203, 105, 140, 118, 244, 92, 12, 156, 84, 52, 8])));
/// PN("gdpn"): gdpn1xr0d66hpskh35j7r6m89jh9vs079k4m2pqsgt0ydkkar0tdftvn4yk038ug
static immutable PN = KeyPair(PublicKey(Point([222, 221, 106, 225, 133, 175, 26, 75, 195, 214, 206, 89, 92, 172, 131, 252, 91, 87, 106, 8, 32, 133, 188, 141, 181, 186, 55, 173, 169, 91, 39, 82])), SecretKey(Scalar([164, 114, 41, 27, 88, 35, 201, 31, 140, 79, 163, 156, 28, 229, 27, 167, 156, 113, 82, 68, 22, 71, 97, 217, 156, 11, 135, 195, 122, 197, 214, 4])));
/// PO("gdpo"): gdpo1xr0w66c3fuy6ypjfdxfqrz55yd38x6vrj5s73pt4py0rshj4lzdzzhjw69w
static immutable PO = KeyPair(PublicKey(Point([222, 237, 107, 17, 79, 9, 162, 6, 73, 105, 146, 1, 138, 148, 35, 98, 115, 105, 131, 149, 33, 232, 133, 117, 9, 30, 56, 94, 85, 248, 154, 33])), SecretKey(Scalar([55, 220, 17, 180, 28, 196, 128, 85, 150, 246, 235, 230, 41, 41, 176, 189, 255, 255, 39, 174, 153, 222, 19, 75, 178, 2, 90, 55, 86, 151, 30, 15])));
/// PP("gdpp"): gdpp1xr0066z8p7nmm9vfhclkrvwd6x27qvda56d7xgsnpruwsq6c3alau82d6tj
static immutable PP = KeyPair(PublicKey(Point([222, 253, 104, 71, 15, 167, 189, 149, 137, 190, 63, 97, 177, 205, 209, 149, 224, 49, 189, 166, 155, 227, 34, 19, 8, 248, 232, 3, 88, 143, 127, 222])), SecretKey(Scalar([216, 124, 71, 66, 220, 206, 63, 255, 69, 109, 167, 96, 141, 197, 29, 147, 202, 17, 142, 238, 79, 251, 133, 93, 239, 186, 60, 187, 254, 58, 191, 13])));
/// PQ("gdpq"): gdpq1xr0s668vn57um8wdsr3dek4y65ac020mjkyj4fxsshs499vuvsy7qyzsmpd
static immutable PQ = KeyPair(PublicKey(Point([223, 13, 104, 236, 157, 61, 205, 157, 205, 128, 226, 220, 218, 164, 213, 59, 135, 169, 251, 149, 137, 42, 164, 208, 133, 225, 82, 149, 156, 100, 9, 224])), SecretKey(Scalar([176, 145, 74, 134, 26, 42, 132, 110, 28, 122, 211, 252, 188, 134, 44, 229, 222, 155, 158, 202, 222, 119, 42, 105, 19, 120, 21, 185, 154, 50, 165, 10])));
/// PR("gdpr"): gdpr1xr0366v23ak5kg6928psmzarzfwtm257htcwvg5myv5ff3spfuugx4qft6k
static immutable PR = KeyPair(PublicKey(Point([223, 29, 105, 138, 143, 109, 75, 35, 69, 81, 195, 13, 139, 163, 18, 92, 189, 170, 158, 186, 240, 230, 34, 155, 35, 40, 148, 198, 1, 79, 56, 131])), SecretKey(Scalar([48, 45, 54, 161, 96, 126, 79, 50, 89, 108, 23, 208, 126, 196, 77, 106, 96, 93, 27, 28, 242, 205, 127, 98, 215, 221, 59, 125, 5, 37, 12, 4])));
/// PS("gdps"): gdps1xr0j66szvlc9neajt2cundg6fe20d34c35thrcxnvw4nwqv8gntw6la6sp7
static immutable PS = KeyPair(PublicKey(Point([223, 45, 106, 2, 103, 240, 89, 231, 178, 90, 177, 201, 181, 26, 78, 84, 246, 198, 184, 141, 23, 113, 224, 211, 99, 171, 55, 1, 135, 68, 214, 237])), SecretKey(Scalar([229, 226, 67, 70, 146, 150, 199, 171, 118, 91, 33, 95, 165, 65, 133, 245, 230, 26, 17, 158, 173, 181, 84, 26, 120, 122, 76, 182, 196, 47, 85, 8])));
/// PT("gdpt"): gdpt1xr0n66m9ugw4tlh83m5lml67nu4k3pnua9aml5mm7xjkzncsa2xkg05w0e7
static immutable PT = KeyPair(PublicKey(Point([223, 61, 107, 101, 226, 29, 85, 254, 231, 142, 233, 253, 255, 94, 159, 43, 104, 134, 124, 233, 123, 191, 211, 123, 241, 165, 97, 79, 16, 234, 141, 100])), SecretKey(Scalar([139, 105, 227, 33, 162, 237, 51, 190, 124, 158, 114, 82, 169, 36, 189, 200, 98, 218, 107, 128, 41, 54, 104, 132, 199, 180, 42, 61, 92, 86, 46, 6])));
/// PU("gdpu"): gdpu1xr0566cqhr6lyhywjh5j3rwv0ltesr94eayzxa3g6zmasmcqg6ae2j27e7e
static immutable PU = KeyPair(PublicKey(Point([223, 77, 107, 0, 184, 245, 242, 92, 142, 149, 233, 40, 141, 204, 127, 215, 152, 12, 181, 207, 72, 35, 118, 40, 208, 183, 216, 111, 0, 70, 187, 149])), SecretKey(Scalar([17, 227, 20, 71, 143, 6, 212, 44, 49, 196, 40, 75, 83, 4, 203, 153, 211, 167, 182, 114, 132, 9, 60, 29, 247, 97, 117, 87, 182, 176, 149, 11])));
/// PV("gdpv"): gdpv1xr04665lp96960d40lj0sm44d7hz2y540jga5qnde2h07veqd34nz4kzeht
static immutable PV = KeyPair(PublicKey(Point([223, 93, 106, 159, 9, 116, 93, 61, 181, 127, 228, 248, 110, 181, 111, 174, 37, 18, 149, 124, 145, 218, 2, 109, 202, 174, 255, 51, 32, 108, 107, 49])), SecretKey(Scalar([89, 135, 208, 98, 58, 74, 203, 157, 13, 250, 38, 157, 149, 17, 50, 40, 194, 94, 136, 239, 134, 220, 233, 59, 190, 160, 202, 139, 171, 84, 121, 12])));
/// PW("gdpw"): gdpw1xr0k6692qqtj3ud838s8lpdyg77xux0zkvkkxd4yj0c7zlgqz5wksaz379u
static immutable PW = KeyPair(PublicKey(Point([223, 109, 104, 170, 0, 23, 40, 241, 167, 137, 224, 127, 133, 164, 71, 188, 110, 25, 226, 179, 45, 99, 54, 164, 147, 241, 225, 125, 0, 21, 29, 104])), SecretKey(Scalar([194, 23, 100, 98, 218, 33, 86, 211, 152, 99, 40, 172, 207, 188, 226, 169, 14, 80, 42, 200, 215, 131, 11, 49, 222, 96, 46, 141, 32, 137, 11, 0])));
/// PX("gdpx"): gdpx1xr0h66eluzlpfce8gg95kxmcz9r7l9k3km7z4r4amxj6z927gd9tvh8ayk8
static immutable PX = KeyPair(PublicKey(Point([223, 125, 107, 63, 224, 190, 20, 227, 39, 66, 11, 75, 27, 120, 17, 71, 239, 150, 209, 182, 252, 42, 142, 189, 217, 165, 161, 21, 94, 67, 74, 182])), SecretKey(Scalar([195, 82, 76, 105, 240, 88, 131, 10, 26, 247, 18, 199, 213, 90, 202, 23, 229, 227, 199, 64, 175, 211, 5, 223, 115, 253, 236, 144, 61, 1, 103, 1])));
/// PY("gdpy"): gdpy1xr0c66umy96ueql60j8qytl3mkn5ue2cmhd030c5z0wrlgh9uwvz6f02d8u
static immutable PY = KeyPair(PublicKey(Point([223, 141, 107, 155, 33, 117, 204, 131, 250, 124, 142, 2, 47, 241, 221, 167, 78, 101, 88, 221, 218, 248, 191, 20, 19, 220, 63, 162, 229, 227, 152, 45])), SecretKey(Scalar([72, 123, 121, 126, 153, 158, 75, 107, 95, 121, 12, 124, 19, 119, 231, 244, 80, 154, 252, 20, 179, 251, 29, 203, 242, 82, 73, 158, 107, 31, 141, 8])));
/// PZ("gdpz"): gdpz1xr0e66w6rg7u6xu2h2nwwgjwg24pprxdp6gwmcttyyh3vd9wuvg8j3h9z70
static immutable PZ = KeyPair(PublicKey(Point([223, 157, 105, 218, 26, 61, 205, 27, 138, 186, 166, 231, 34, 78, 66, 170, 16, 140, 205, 14, 144, 237, 225, 107, 33, 47, 22, 52, 174, 227, 16, 121])), SecretKey(Scalar([175, 180, 67, 226, 9, 54, 129, 32, 227, 82, 122, 162, 156, 64, 44, 32, 206, 125, 64, 46, 254, 109, 135, 45, 82, 103, 170, 237, 198, 220, 38, 7])));
/// QA("gdqa"): gdqa1xrsq66ymrnryvxzzcxlgfzfj754hjvxjmpean58709w8tedzllpsk90sh7l
static immutable QA = KeyPair(PublicKey(Point([224, 13, 104, 155, 28, 198, 70, 24, 66, 193, 190, 132, 137, 50, 245, 43, 121, 48, 210, 216, 115, 217, 208, 254, 121, 92, 117, 229, 162, 255, 195, 11])), SecretKey(Scalar([110, 165, 237, 197, 87, 90, 201, 207, 193, 41, 173, 174, 202, 189, 15, 11, 130, 61, 112, 121, 152, 8, 42, 172, 245, 208, 213, 103, 170, 221, 187, 7])));
/// QB("gdqb"): gdqb1xrsp6648hfhnznp27wx5r8k98n4jjwtd0uqeg6tvr2r7v7c9szmyss7jltx
static immutable QB = KeyPair(PublicKey(Point([224, 29, 106, 167, 186, 111, 49, 76, 42, 243, 141, 65, 158, 197, 60, 235, 41, 57, 109, 127, 1, 148, 105, 108, 26, 135, 230, 123, 5, 128, 182, 72])), SecretKey(Scalar([103, 151, 60, 170, 74, 135, 162, 8, 243, 45, 167, 134, 49, 195, 96, 100, 176, 155, 195, 245, 99, 185, 88, 243, 218, 85, 186, 72, 57, 245, 248, 10])));
/// QC("gdqc"): gdqc1xrsz66dwk87aednugm7skxj3tl554pa9ucj3dwvw3al0a5ys3d3eq5cn8ny
static immutable QC = KeyPair(PublicKey(Point([224, 45, 105, 174, 177, 253, 220, 182, 124, 70, 253, 11, 26, 81, 95, 233, 74, 135, 165, 230, 37, 22, 185, 142, 143, 126, 254, 208, 144, 139, 99, 144])), SecretKey(Scalar([92, 223, 21, 162, 64, 81, 72, 152, 109, 137, 0, 203, 185, 109, 80, 203, 64, 7, 156, 169, 50, 253, 206, 19, 181, 132, 26, 214, 24, 166, 197, 14])));
/// QD("gdqd"): gdqd1xrsr66yvg30lda4ec2p0yasl2s53d75dte3c3kz08vj2s4gy6yx9536rjpd
static immutable QD = KeyPair(PublicKey(Point([224, 61, 104, 140, 68, 95, 246, 246, 185, 194, 130, 242, 118, 31, 84, 41, 22, 250, 141, 94, 99, 136, 216, 79, 59, 36, 168, 85, 4, 209, 12, 90])), SecretKey(Scalar([128, 239, 169, 117, 191, 187, 42, 174, 226, 112, 158, 176, 51, 250, 108, 71, 163, 150, 184, 175, 239, 192, 49, 184, 218, 34, 223, 36, 142, 137, 49, 1])));
/// QE("gdqe"): gdqe1xrsy66ndjxfvauj4z9hre0h32az4zesedyyrcww9yjqte4s9na9hwzau4wm
static immutable QE = KeyPair(PublicKey(Point([224, 77, 106, 109, 145, 146, 206, 242, 85, 17, 110, 60, 190, 241, 87, 69, 81, 102, 25, 105, 8, 60, 57, 197, 36, 128, 188, 214, 5, 159, 75, 119])), SecretKey(Scalar([179, 211, 173, 69, 158, 21, 31, 135, 105, 24, 134, 70, 141, 84, 172, 108, 224, 117, 52, 34, 11, 246, 31, 36, 147, 126, 0, 130, 229, 193, 68, 4])));
/// QF("gdqf"): gdqf1xrs96633d9d8mff87en2xx9mkr9k66qrs6jjfvpn67cfz72c29fgqah6xhl
static immutable QF = KeyPair(PublicKey(Point([224, 93, 106, 49, 105, 90, 125, 165, 39, 246, 102, 163, 24, 187, 176, 203, 109, 104, 3, 134, 165, 36, 176, 51, 215, 176, 145, 121, 88, 81, 82, 128])), SecretKey(Scalar([194, 115, 169, 162, 11, 123, 199, 115, 30, 80, 192, 143, 238, 145, 249, 160, 115, 198, 31, 150, 90, 245, 202, 142, 25, 151, 52, 43, 67, 233, 192, 9])));
/// QG("gdqg"): gdqg1xrsx66s8ylu9acnk2ep2793yz9jfxeg3e04ggagw6ksn7t7k4zeqqrlugqs
static immutable QG = KeyPair(PublicKey(Point([224, 109, 106, 7, 39, 248, 94, 226, 118, 86, 66, 175, 22, 36, 17, 100, 147, 101, 17, 203, 234, 132, 117, 14, 213, 161, 63, 47, 214, 168, 178, 0])), SecretKey(Scalar([18, 83, 128, 232, 33, 207, 207, 179, 10, 186, 176, 1, 11, 95, 163, 245, 165, 218, 250, 249, 8, 252, 138, 202, 76, 80, 201, 125, 89, 196, 141, 4])));
/// QH("gdqh"): gdqh1xrs866g3kqsnp2c6kyue54uqtyq96yfu9ean73n40u8aqpa3smanznvxva0
static immutable QH = KeyPair(PublicKey(Point([224, 125, 105, 17, 176, 33, 48, 171, 26, 177, 57, 154, 87, 128, 89, 0, 93, 17, 60, 46, 123, 63, 70, 117, 127, 15, 208, 7, 177, 134, 251, 49])), SecretKey(Scalar([143, 28, 150, 246, 74, 5, 21, 189, 141, 58, 3, 221, 117, 196, 6, 170, 98, 30, 4, 226, 163, 158, 28, 157, 187, 109, 74, 91, 184, 72, 243, 7])));
/// QI("gdqi"): gdqi1xrsg66rm5dxunax8zqca9zulhaxv465x3urnl6vpslpx6psqxsk4qz2xrwy
static immutable QI = KeyPair(PublicKey(Point([224, 141, 104, 123, 163, 77, 201, 244, 199, 16, 49, 210, 139, 159, 191, 76, 202, 234, 134, 143, 7, 63, 233, 129, 135, 194, 109, 6, 0, 52, 45, 80])), SecretKey(Scalar([26, 235, 49, 229, 165, 19, 202, 222, 98, 10, 206, 109, 253, 2, 91, 204, 114, 117, 201, 165, 12, 129, 241, 102, 0, 144, 89, 17, 177, 153, 79, 1])));
/// QJ("gdqj"): gdqj1xrsf66ujrkr6k279gupkzjtr9wr4qg40nqvuhpglmeh2f3f2lz8nwcsyn03
static immutable QJ = KeyPair(PublicKey(Point([224, 157, 107, 146, 29, 135, 171, 43, 197, 71, 3, 97, 73, 99, 43, 135, 80, 34, 175, 152, 25, 203, 133, 31, 222, 110, 164, 197, 42, 248, 143, 55])), SecretKey(Scalar([27, 6, 230, 95, 3, 178, 144, 46, 255, 176, 167, 150, 170, 98, 62, 5, 189, 232, 181, 179, 12, 143, 48, 233, 133, 245, 215, 81, 10, 38, 30, 1])));
/// QK("gdqk"): gdqk1xrs2669wag4j8wacaqshgq2w7fdlw7m6686525y952r4zuq4v4p4wls87v9
static immutable QK = KeyPair(PublicKey(Point([224, 173, 104, 174, 234, 43, 35, 187, 184, 232, 33, 116, 1, 78, 242, 91, 247, 123, 122, 209, 245, 69, 80, 133, 162, 135, 81, 112, 21, 101, 67, 87])), SecretKey(Scalar([233, 29, 3, 218, 59, 190, 185, 217, 188, 14, 229, 9, 249, 90, 242, 248, 214, 144, 226, 190, 154, 99, 122, 32, 232, 54, 52, 152, 67, 173, 141, 15])));
/// QL("gdql"): gdql1xrst66u7c9alp6mmw9txg6remwy8fkz2fup9p2udzr3hh822nj2cwjxnp4y
static immutable QL = KeyPair(PublicKey(Point([224, 189, 107, 158, 193, 123, 240, 235, 123, 113, 86, 100, 104, 121, 219, 136, 116, 216, 74, 79, 2, 80, 171, 141, 16, 227, 123, 157, 74, 156, 149, 135])), SecretKey(Scalar([222, 242, 55, 84, 214, 170, 82, 135, 39, 119, 188, 104, 113, 215, 95, 242, 29, 60, 179, 232, 136, 81, 27, 20, 252, 237, 207, 46, 108, 97, 196, 4])));
/// QM("gdqm"): gdqm1xrsv66ayf8k5hjldatt5qgdnzveyp6y36kjfjpeggzy68eu80a68v2vsady
static immutable QM = KeyPair(PublicKey(Point([224, 205, 107, 164, 73, 237, 75, 203, 237, 234, 215, 64, 33, 179, 19, 50, 64, 232, 145, 213, 164, 153, 7, 40, 64, 137, 163, 231, 135, 127, 116, 118])), SecretKey(Scalar([40, 175, 207, 69, 208, 100, 216, 163, 44, 109, 74, 235, 110, 4, 137, 36, 90, 158, 5, 164, 230, 201, 27, 167, 110, 104, 155, 143, 221, 111, 249, 6])));
/// QN("gdqn"): gdqn1xrsd660seg6ze2h8e387n9c0m0w0lmr68059lf8lnu3vkxqlx4h8kz3xuqy
static immutable QN = KeyPair(PublicKey(Point([224, 221, 105, 240, 202, 52, 44, 170, 231, 204, 79, 233, 151, 15, 219, 220, 255, 236, 122, 59, 232, 95, 164, 255, 159, 34, 203, 24, 31, 53, 110, 123])), SecretKey(Scalar([237, 145, 39, 183, 131, 218, 200, 4, 30, 127, 100, 86, 130, 229, 214, 255, 213, 160, 241, 53, 137, 25, 7, 47, 184, 18, 138, 120, 167, 15, 43, 15])));
/// QO("gdqo"): gdqo1xrsw66hyhz2u7t4sr4dfcy55dkgh9j7xp6hh226q2kyeqthcyg3c78mqcru
static immutable QO = KeyPair(PublicKey(Point([224, 237, 106, 228, 184, 149, 207, 46, 176, 29, 90, 156, 18, 148, 109, 145, 114, 203, 198, 14, 175, 117, 43, 64, 85, 137, 144, 46, 248, 34, 35, 143])), SecretKey(Scalar([190, 98, 225, 160, 71, 254, 146, 51, 205, 23, 204, 54, 205, 239, 106, 227, 52, 19, 117, 103, 234, 156, 25, 193, 163, 171, 89, 115, 147, 217, 76, 10])));
/// QP("gdqp"): gdqp1xrs066g5xvfwyyzjgr6639z3jhcc7uw853szvverg4js7gjjet0mslrxd3k
static immutable QP = KeyPair(PublicKey(Point([224, 253, 105, 20, 51, 18, 226, 16, 82, 64, 245, 168, 148, 81, 149, 241, 143, 113, 199, 164, 96, 38, 51, 35, 69, 101, 15, 34, 82, 202, 223, 184])), SecretKey(Scalar([15, 194, 118, 244, 34, 1, 137, 197, 28, 140, 215, 16, 107, 60, 254, 44, 50, 133, 101, 191, 141, 162, 249, 17, 23, 143, 233, 192, 224, 86, 125, 14])));
/// QQ("gdqq"): gdqq1xrss66w6dhu0dz2pn8u8apzlyf289a4e46rhvwew8aqymef6ekdlj48hncn
static immutable QQ = KeyPair(PublicKey(Point([225, 13, 105, 218, 109, 248, 246, 137, 65, 153, 248, 126, 132, 95, 34, 84, 114, 246, 185, 174, 135, 118, 59, 46, 63, 64, 77, 229, 58, 205, 155, 249])), SecretKey(Scalar([42, 38, 67, 123, 100, 48, 16, 106, 117, 251, 100, 246, 92, 218, 73, 36, 42, 111, 182, 95, 96, 86, 224, 4, 140, 1, 48, 124, 221, 102, 255, 15])));
/// QR("gdqr"): gdqr1xrs366lkzj63qthvv73s3lq77uyaz8fm705eafaulrhexrx8v7fjcx2amws
static immutable QR = KeyPair(PublicKey(Point([225, 29, 107, 246, 20, 181, 16, 46, 236, 103, 163, 8, 252, 30, 247, 9, 209, 29, 59, 243, 233, 158, 167, 188, 248, 239, 147, 12, 199, 103, 147, 44])), SecretKey(Scalar([254, 224, 86, 246, 99, 76, 7, 67, 66, 126, 225, 132, 45, 193, 108, 244, 74, 151, 39, 188, 162, 14, 106, 101, 87, 190, 110, 113, 245, 187, 75, 5])));
/// QS("gdqs"): gdqs1xrsj66xsllvu7zwuy7vnm4ecwd0ts4drzsgzusjx8g30ezzj33jxjgrv8q4
static immutable QS = KeyPair(PublicKey(Point([225, 45, 104, 208, 255, 217, 207, 9, 220, 39, 153, 61, 215, 56, 115, 94, 184, 85, 163, 20, 16, 46, 66, 70, 58, 34, 252, 136, 82, 140, 100, 105])), SecretKey(Scalar([120, 215, 84, 54, 145, 161, 255, 18, 154, 54, 241, 156, 164, 183, 217, 116, 217, 0, 43, 65, 31, 191, 116, 51, 5, 116, 8, 85, 251, 104, 17, 12])));
/// QT("gdqt"): gdqt1xrsn6697g2c0j83zpj75m8qn5e8u0e6n0fuch4jnu3z8ggtdfrt5vx9k6je
static immutable QT = KeyPair(PublicKey(Point([225, 61, 104, 190, 66, 176, 249, 30, 34, 12, 189, 77, 156, 19, 166, 79, 199, 231, 83, 122, 121, 139, 214, 83, 228, 68, 116, 33, 109, 72, 215, 70])), SecretKey(Scalar([110, 105, 157, 78, 223, 67, 181, 73, 99, 127, 18, 184, 99, 21, 136, 175, 20, 112, 29, 244, 92, 219, 24, 86, 79, 217, 90, 255, 200, 254, 218, 5])));
/// QU("gdqu"): gdqu1xrs566svjnx267g5n95vumcgwcgh72mn2wts2al7e8ul3v7pt2t6w5zperd
static immutable QU = KeyPair(PublicKey(Point([225, 77, 106, 12, 148, 204, 173, 121, 20, 153, 104, 206, 111, 8, 118, 17, 127, 43, 115, 83, 151, 5, 119, 254, 201, 249, 248, 179, 193, 90, 151, 167])), SecretKey(Scalar([155, 218, 233, 154, 186, 133, 244, 184, 227, 203, 37, 109, 82, 178, 23, 83, 184, 197, 25, 234, 69, 210, 99, 55, 128, 60, 32, 2, 163, 251, 189, 3])));
/// QV("gdqv"): gdqv1xrs466y9mgke6fwd6rukxlz9a6autwccf3xcr9qeg4mazh5ks2x95ru7xwn
static immutable QV = KeyPair(PublicKey(Point([225, 93, 104, 133, 218, 45, 157, 37, 205, 208, 249, 99, 124, 69, 238, 187, 197, 187, 24, 76, 77, 129, 148, 25, 69, 119, 209, 94, 150, 130, 140, 90])), SecretKey(Scalar([44, 109, 208, 137, 118, 23, 222, 108, 217, 14, 181, 123, 42, 1, 37, 70, 135, 83, 220, 124, 43, 188, 51, 91, 149, 136, 247, 83, 92, 22, 102, 3])));
/// QW("gdqw"): gdqw1xrsk66hgwx5mkp2cy7tnzave5xfa0vajyla2l39f53mdgc30uevlqy5s8dv
static immutable QW = KeyPair(PublicKey(Point([225, 109, 106, 232, 113, 169, 187, 5, 88, 39, 151, 49, 117, 153, 161, 147, 215, 179, 178, 39, 250, 175, 196, 169, 164, 118, 212, 98, 47, 230, 89, 240])), SecretKey(Scalar([61, 99, 246, 116, 6, 193, 133, 101, 117, 192, 89, 167, 158, 248, 12, 188, 173, 95, 184, 238, 146, 150, 246, 191, 158, 195, 39, 194, 88, 168, 226, 4])));
/// QX("gdqx"): gdqx1xrsh669e4cjdgq0fsc3y8mw53gry77yee2mcet4xhaqazdrta3k5kzv2le3
static immutable QX = KeyPair(PublicKey(Point([225, 125, 104, 185, 174, 36, 212, 1, 233, 134, 34, 67, 237, 212, 138, 6, 79, 120, 153, 202, 183, 140, 174, 166, 191, 65, 209, 52, 107, 236, 109, 75])), SecretKey(Scalar([70, 24, 198, 137, 242, 219, 10, 105, 72, 252, 93, 84, 102, 144, 176, 23, 20, 1, 142, 176, 89, 71, 83, 119, 137, 140, 0, 121, 164, 76, 61, 9])));
/// QY("gdqy"): gdqy1xrsc66wea5uxy0ypa03qa9e809h3a739a6w8pwzkzz9cnmpq4fa8kv9fkhd
static immutable QY = KeyPair(PublicKey(Point([225, 141, 105, 217, 237, 56, 98, 60, 129, 235, 226, 14, 151, 39, 121, 111, 30, 250, 37, 238, 156, 112, 184, 86, 16, 139, 137, 236, 32, 170, 122, 123])), SecretKey(Scalar([21, 52, 196, 180, 132, 37, 7, 7, 208, 146, 208, 162, 78, 206, 63, 184, 189, 152, 28, 187, 249, 221, 82, 195, 122, 132, 78, 109, 76, 200, 127, 10])));
/// QZ("gdqz"): gdqz1xrse66pvrwh0fattcdz8gg6t60yurrsuc84l4ewxhevcaznl8es96epa0gl
static immutable QZ = KeyPair(PublicKey(Point([225, 157, 104, 44, 27, 174, 244, 245, 107, 195, 68, 116, 35, 75, 211, 201, 193, 142, 28, 193, 235, 250, 229, 198, 190, 89, 142, 138, 127, 62, 96, 93])), SecretKey(Scalar([172, 167, 82, 137, 141, 175, 208, 77, 33, 92, 152, 30, 90, 13, 119, 153, 213, 206, 13, 141, 113, 178, 116, 16, 90, 31, 238, 240, 249, 104, 45, 5])));
/// RA("gdra"): gdra1xr3q662dzsxyvv8xkw40zs0skcc8hltqsnvj9wd6acytuj236qeax7kh35z
static immutable RA = KeyPair(PublicKey(Point([226, 13, 105, 77, 20, 12, 70, 48, 230, 179, 170, 241, 65, 240, 182, 48, 123, 253, 96, 132, 217, 34, 185, 186, 238, 8, 190, 73, 81, 208, 51, 211])), SecretKey(Scalar([167, 132, 37, 218, 187, 225, 124, 68, 80, 254, 202, 34, 211, 190, 136, 115, 132, 97, 21, 168, 236, 3, 173, 116, 250, 246, 178, 14, 40, 16, 240, 1])));
/// RB("gdrb"): gdrb1xr3p66pke2d9ts2f8g6chphn2jf0nt87zjuphs4kd27v22uxjqljcu8xl0g
static immutable RB = KeyPair(PublicKey(Point([226, 29, 104, 54, 202, 154, 85, 193, 73, 58, 53, 139, 134, 243, 84, 146, 249, 172, 254, 20, 184, 27, 194, 182, 106, 188, 197, 43, 134, 144, 63, 44])), SecretKey(Scalar([252, 5, 167, 173, 143, 141, 113, 19, 191, 109, 153, 111, 82, 105, 116, 221, 0, 134, 145, 114, 135, 98, 219, 29, 202, 19, 69, 72, 166, 203, 91, 14])));
/// RC("gdrc"): gdrc1xr3z66svq04e8xwn38s7uqktl2rnlxq76v8m876mpxq2am7fqcwvvpdg7vz
static immutable RC = KeyPair(PublicKey(Point([226, 45, 106, 12, 3, 235, 147, 153, 211, 137, 225, 238, 2, 203, 250, 135, 63, 152, 30, 211, 15, 179, 251, 91, 9, 128, 174, 239, 201, 6, 28, 198])), SecretKey(Scalar([102, 128, 181, 126, 234, 191, 45, 14, 137, 226, 176, 158, 99, 192, 94, 221, 128, 84, 84, 125, 206, 123, 123, 250, 247, 113, 222, 128, 158, 206, 222, 9])));
/// RD("gdrd"): gdrd1xr3r66mqwp6tggkyq0kv7lg9cdfe0eylehjaltmlhps40aj4tdh5kydntyl
static immutable RD = KeyPair(PublicKey(Point([226, 61, 107, 96, 112, 116, 180, 34, 196, 3, 236, 207, 125, 5, 195, 83, 151, 228, 159, 205, 229, 223, 175, 127, 184, 97, 87, 246, 85, 91, 111, 75])), SecretKey(Scalar([194, 181, 168, 68, 8, 219, 184, 254, 1, 34, 60, 190, 227, 10, 207, 15, 154, 232, 221, 49, 18, 141, 157, 167, 35, 39, 70, 86, 196, 243, 221, 9])));
/// RE("gdre"): gdre1xr3y66gc5yklf6mawx9tgata4gzrfgtcqwe0vprl5gp9l9ay7j3kyx8xvy2
static immutable RE = KeyPair(PublicKey(Point([226, 77, 105, 24, 161, 45, 244, 235, 125, 113, 138, 180, 117, 125, 170, 4, 52, 161, 120, 3, 178, 246, 4, 127, 162, 2, 95, 151, 164, 244, 163, 98])), SecretKey(Scalar([237, 216, 89, 163, 98, 130, 8, 6, 48, 181, 121, 175, 52, 205, 133, 113, 135, 212, 221, 253, 88, 198, 105, 30, 46, 221, 220, 197, 42, 190, 234, 1])));
/// RF("gdrf"): gdrf1xr3966l464fcmmmct3q98zl8jyrfvfftkmcdgwkqxx60jq8f2g6xv6q8ez8
static immutable RF = KeyPair(PublicKey(Point([226, 93, 107, 245, 213, 83, 141, 239, 120, 92, 64, 83, 139, 231, 145, 6, 150, 37, 43, 182, 240, 212, 58, 192, 49, 180, 249, 0, 233, 82, 52, 102])), SecretKey(Scalar([150, 187, 225, 122, 255, 84, 78, 128, 68, 42, 27, 152, 17, 2, 71, 238, 135, 212, 172, 254, 35, 41, 71, 165, 201, 155, 165, 208, 45, 39, 153, 8])));
/// RG("gdrg"): gdrg1xr3x666vafp0ls6k0j7cmmcn0m4aks4dwn0rkrvduau3hd0nfwy675dpfel
static immutable RG = KeyPair(PublicKey(Point([226, 109, 107, 76, 234, 66, 255, 195, 86, 124, 189, 141, 239, 19, 126, 235, 219, 66, 173, 116, 222, 59, 13, 141, 231, 121, 27, 181, 243, 75, 137, 175])), SecretKey(Scalar([117, 207, 109, 239, 139, 132, 230, 23, 157, 209, 58, 85, 233, 94, 92, 159, 199, 176, 38, 177, 169, 223, 124, 52, 108, 117, 171, 253, 148, 201, 79, 12])));
/// RH("gdrh"): gdrh1xr3866d3pzamq2nd7kj2gt53s8dg65n089gjk3gdyun2gz63yxr07ucy7wv
static immutable RH = KeyPair(PublicKey(Point([226, 125, 105, 177, 8, 187, 176, 42, 109, 245, 164, 164, 46, 145, 129, 218, 141, 82, 111, 57, 81, 43, 69, 13, 39, 38, 164, 11, 81, 33, 134, 255])), SecretKey(Scalar([183, 211, 239, 193, 16, 188, 124, 165, 199, 196, 0, 228, 205, 241, 55, 182, 91, 121, 8, 44, 66, 11, 13, 142, 227, 100, 162, 192, 125, 136, 126, 14])));
/// RI("gdri"): gdri1xr3g66stcy6v0nyw4d8t3ezzrvyvh4vgmkfaj2d3ewzy9x8jrgvf79pf93u
static immutable RI = KeyPair(PublicKey(Point([226, 141, 106, 11, 193, 52, 199, 204, 142, 171, 78, 184, 228, 66, 27, 8, 203, 213, 136, 221, 147, 217, 41, 177, 203, 132, 66, 152, 242, 26, 24, 159])), SecretKey(Scalar([33, 28, 110, 106, 199, 99, 231, 134, 239, 81, 35, 12, 178, 83, 50, 113, 50, 246, 51, 35, 240, 248, 95, 155, 4, 53, 184, 152, 133, 44, 84, 15])));
/// RJ("gdrj"): gdrj1xr3f662fwgyhjn6q0ev7y5he46t3lep623fuwcmj57m3etm4skffzhggtr9
static immutable RJ = KeyPair(PublicKey(Point([226, 157, 105, 73, 114, 9, 121, 79, 64, 126, 89, 226, 82, 249, 174, 151, 31, 228, 58, 84, 83, 199, 99, 114, 167, 183, 28, 175, 117, 133, 146, 145])), SecretKey(Scalar([217, 44, 149, 249, 255, 174, 2, 37, 80, 15, 45, 192, 140, 230, 64, 157, 233, 133, 74, 175, 73, 214, 76, 2, 181, 216, 161, 139, 30, 174, 10, 10])));
/// RK("gdrk"): gdrk1xr3266p425twlwyxefjpzahastutd98suwaz4sluunyt7nps4ccdws5lvtn
static immutable RK = KeyPair(PublicKey(Point([226, 173, 104, 53, 85, 22, 239, 184, 134, 202, 100, 17, 118, 253, 130, 248, 182, 148, 240, 227, 186, 42, 195, 252, 228, 200, 191, 76, 48, 174, 48, 215])), SecretKey(Scalar([213, 96, 74, 207, 123, 171, 95, 84, 65, 153, 101, 250, 165, 108, 49, 245, 130, 35, 91, 183, 53, 40, 18, 172, 216, 191, 194, 194, 108, 43, 250, 15])));
/// RL("gdrl"): gdrl1xr3t66wlf5q80as5ht6rn0ax5puz269lsstk5u0jhdq3k8wxl4zvg530pw2
static immutable RL = KeyPair(PublicKey(Point([226, 189, 105, 223, 77, 0, 119, 246, 20, 186, 244, 57, 191, 166, 160, 120, 37, 104, 191, 132, 23, 106, 113, 242, 187, 65, 27, 29, 198, 253, 68, 196])), SecretKey(Scalar([15, 89, 143, 221, 186, 24, 11, 120, 127, 87, 232, 232, 231, 37, 152, 215, 201, 200, 199, 234, 88, 110, 63, 155, 6, 34, 225, 196, 4, 193, 43, 12])));
/// RM("gdrm"): gdrm1xr3v66yl34v5mqe4k47y8u858vz5u4js70gdj5qkh0w3qj2yuae2cvz46j7
static immutable RM = KeyPair(PublicKey(Point([226, 205, 104, 159, 141, 89, 77, 131, 53, 181, 124, 67, 240, 244, 59, 5, 78, 86, 80, 243, 208, 217, 80, 22, 187, 221, 16, 73, 68, 231, 114, 172])), SecretKey(Scalar([129, 97, 155, 226, 195, 143, 38, 154, 143, 101, 118, 148, 170, 241, 98, 56, 21, 243, 85, 173, 90, 139, 230, 2, 96, 176, 232, 62, 110, 41, 167, 1])));
/// RN("gdrn"): gdrn1xr3d66s0ypvx6gpmvrrcldhke5tm3rdwpnq8uq32rkcngu2g26m7gv594hd
static immutable RN = KeyPair(PublicKey(Point([226, 221, 106, 15, 32, 88, 109, 32, 59, 96, 199, 143, 182, 246, 205, 23, 184, 141, 174, 12, 192, 126, 2, 42, 29, 177, 52, 113, 72, 86, 183, 228])), SecretKey(Scalar([8, 228, 204, 114, 63, 242, 238, 134, 236, 235, 233, 219, 191, 133, 10, 136, 115, 210, 240, 54, 140, 97, 225, 245, 142, 103, 171, 73, 205, 163, 166, 1])));
/// RO("gdro"): gdro1xr3w66r6fcv3qalnz5tjfv4efamxmqcz33kj899le6rat4fdjxdukglayn3
static immutable RO = KeyPair(PublicKey(Point([226, 237, 104, 122, 78, 25, 16, 119, 243, 21, 23, 36, 178, 185, 79, 118, 109, 131, 2, 140, 109, 35, 148, 191, 206, 135, 213, 213, 45, 145, 155, 203])), SecretKey(Scalar([212, 189, 191, 220, 135, 120, 10, 26, 235, 168, 205, 44, 228, 175, 141, 142, 53, 189, 224, 237, 57, 63, 213, 166, 27, 10, 138, 99, 255, 135, 246, 11])));
/// RP("gdrp"): gdrp1xr3066f78kvw2c4jxh2dy5u4numcxcpw80hfldlj7qpglrmts7w0z0cdf3y
static immutable RP = KeyPair(PublicKey(Point([226, 253, 105, 62, 61, 152, 229, 98, 178, 53, 212, 210, 83, 149, 159, 55, 131, 96, 46, 59, 238, 159, 183, 242, 240, 2, 143, 143, 107, 135, 156, 241])), SecretKey(Scalar([154, 169, 233, 247, 204, 242, 225, 96, 63, 40, 65, 102, 202, 34, 252, 143, 5, 128, 112, 218, 30, 246, 154, 115, 4, 179, 0, 174, 131, 92, 46, 14])));
/// RQ("gdrq"): gdrq1xr3s666wn3saavvyvrcz32z5gwytchthsfngn2a6xtvz48et055tcr5d9hv
static immutable RQ = KeyPair(PublicKey(Point([227, 13, 107, 78, 156, 97, 222, 177, 132, 96, 240, 40, 168, 84, 67, 136, 188, 93, 119, 130, 102, 137, 171, 186, 50, 216, 42, 159, 43, 125, 40, 188])), SecretKey(Scalar([131, 32, 81, 59, 217, 216, 25, 187, 181, 155, 254, 199, 0, 93, 101, 252, 18, 237, 105, 71, 88, 66, 219, 162, 85, 148, 151, 253, 175, 77, 19, 0])));
/// RR("gdrr"): gdrr1xr3366rrcqlrz52uewyn29rcq44gvu3phvckrgh0h9g8s0q0vxhj5gaalj3
static immutable RR = KeyPair(PublicKey(Point([227, 29, 104, 99, 192, 62, 49, 81, 92, 203, 137, 53, 20, 120, 5, 106, 134, 114, 33, 187, 49, 97, 162, 239, 185, 80, 120, 60, 15, 97, 175, 42])), SecretKey(Scalar([144, 134, 104, 240, 77, 205, 248, 80, 35, 102, 115, 204, 240, 172, 239, 146, 212, 149, 123, 100, 77, 239, 61, 189, 236, 38, 84, 184, 59, 220, 241, 10])));
/// RS("gdrs"): gdrs1xr3j66chzcmmelgnp86x40upuejpnqxgtdyrswdypfmkk9txu9k8k0mxzuv
static immutable RS = KeyPair(PublicKey(Point([227, 45, 107, 23, 22, 55, 188, 253, 19, 9, 244, 106, 191, 129, 230, 100, 25, 128, 200, 91, 72, 56, 57, 164, 10, 119, 107, 21, 102, 225, 108, 123])), SecretKey(Scalar([193, 20, 50, 166, 66, 242, 100, 146, 6, 189, 171, 4, 224, 134, 18, 237, 189, 122, 164, 238, 159, 136, 82, 142, 22, 152, 192, 39, 236, 209, 148, 7])));
/// RT("gdrt"): gdrt1xr3n66rfufrkw7crdznw8nravcf6330ww5rgvt6nd76adm7h96j0jg6x6c6
static immutable RT = KeyPair(PublicKey(Point([227, 61, 104, 105, 226, 71, 103, 123, 3, 104, 166, 227, 204, 125, 102, 19, 168, 197, 238, 117, 6, 134, 47, 83, 111, 181, 214, 239, 215, 46, 164, 249])), SecretKey(Scalar([240, 215, 161, 244, 241, 27, 246, 41, 226, 121, 29, 83, 24, 123, 252, 105, 9, 142, 130, 45, 157, 113, 88, 238, 184, 32, 89, 196, 151, 1, 19, 15])));
/// RU("gdru"): gdru1xr3566yxudwln3l0a3296ac4k0lnsxyxz0z7q56av5xm8unan2yruvpx98y
static immutable RU = KeyPair(PublicKey(Point([227, 77, 104, 134, 227, 93, 249, 199, 239, 236, 84, 93, 119, 21, 179, 255, 56, 24, 134, 19, 197, 224, 83, 93, 101, 13, 179, 242, 125, 154, 136, 62])), SecretKey(Scalar([110, 223, 209, 85, 215, 145, 204, 152, 36, 165, 173, 158, 181, 118, 235, 115, 66, 191, 36, 228, 253, 100, 126, 197, 208, 237, 77, 7, 124, 159, 177, 8])));
/// RV("gdrv"): gdrv1xr3466qxnzgzg2zk4rjxhlmv3k3wjxv8nrxmskl9jjp2llzhj65cg0j3n6s
static immutable RV = KeyPair(PublicKey(Point([227, 93, 104, 6, 152, 144, 36, 40, 86, 168, 228, 107, 255, 108, 141, 162, 233, 25, 135, 152, 205, 184, 91, 229, 148, 130, 175, 252, 87, 150, 169, 132])), SecretKey(Scalar([206, 125, 192, 223, 133, 194, 80, 225, 115, 190, 68, 7, 53, 26, 85, 31, 72, 146, 61, 3, 82, 44, 5, 29, 9, 195, 59, 242, 159, 6, 248, 2])));
/// RW("gdrw"): gdrw1xr3k66ynln5582kypv5q0ret3wpscwcm5qgrvxl6z34vjeq4glrd2tjpn42
static immutable RW = KeyPair(PublicKey(Point([227, 109, 104, 147, 252, 233, 67, 170, 196, 11, 40, 7, 143, 43, 139, 131, 12, 59, 27, 160, 16, 54, 27, 250, 20, 106, 201, 100, 21, 71, 198, 213])), SecretKey(Scalar([29, 174, 177, 35, 128, 223, 63, 6, 213, 5, 176, 177, 131, 222, 248, 105, 84, 83, 39, 10, 63, 133, 61, 226, 122, 18, 113, 45, 132, 209, 48, 15])));
/// RX("gdrx"): gdrx1xr3h66p4xzraq2edrznxvyzqp8ku8dm7el7mhg4cm5fn56g9ugzxkxje5md
static immutable RX = KeyPair(PublicKey(Point([227, 125, 104, 53, 48, 135, 208, 43, 45, 24, 166, 102, 16, 64, 9, 237, 195, 183, 126, 207, 253, 187, 162, 184, 221, 19, 58, 105, 5, 226, 4, 107])), SecretKey(Scalar([87, 28, 185, 176, 17, 206, 162, 45, 155, 113, 112, 144, 194, 124, 53, 145, 101, 206, 87, 225, 81, 142, 62, 161, 130, 56, 76, 167, 229, 210, 94, 12])));
/// RY("gdry"): gdry1xr3c66m7edqwesca03x8g9kellhvxnex6sjh5qdrjswxetz0vwve6rmk7st
static immutable RY = KeyPair(PublicKey(Point([227, 141, 107, 126, 203, 64, 236, 195, 29, 124, 76, 116, 22, 217, 255, 238, 195, 79, 38, 212, 37, 122, 1, 163, 148, 28, 108, 172, 79, 99, 153, 157])), SecretKey(Scalar([255, 68, 222, 143, 181, 133, 249, 98, 167, 122, 249, 152, 101, 38, 131, 221, 109, 144, 29, 20, 20, 123, 78, 77, 2, 107, 163, 142, 127, 23, 56, 6])));
/// RZ("gdrz"): gdrz1xr3e66tjeyme9sggp45qjr87xyr8qcchcpawlu572yycae68luqr7ryv6ne
static immutable RZ = KeyPair(PublicKey(Point([227, 157, 105, 114, 201, 55, 146, 193, 8, 13, 104, 9, 12, 254, 49, 6, 112, 99, 23, 192, 122, 239, 242, 158, 81, 9, 142, 231, 71, 255, 0, 63])), SecretKey(Scalar([42, 16, 230, 180, 134, 52, 6, 137, 171, 43, 3, 125, 180, 25, 61, 172, 52, 94, 215, 17, 111, 204, 190, 48, 72, 219, 90, 43, 197, 50, 37, 3])));
/// SA("gdsa"): gdsa1xrjq66xkhsln2lh6946s7qc9e36muf7f3eazkyfvvcp89geze9585l7pzdv
static immutable SA = KeyPair(PublicKey(Point([228, 13, 104, 214, 188, 63, 53, 126, 250, 45, 117, 15, 3, 5, 204, 117, 190, 39, 201, 142, 122, 43, 17, 44, 102, 2, 114, 163, 34, 201, 104, 122])), SecretKey(Scalar([101, 215, 109, 176, 222, 115, 20, 27, 124, 175, 173, 33, 33, 55, 108, 137, 226, 97, 108, 168, 2, 37, 188, 65, 81, 20, 169, 129, 45, 182, 77, 8])));
/// SB("gdsb"): gdsb1xrjp66vtnqsl2cryt9gr8f9njyqeeu6x3899f93qsfc4pctyvf0uk04yk2l
static immutable SB = KeyPair(PublicKey(Point([228, 29, 105, 139, 152, 33, 245, 96, 100, 89, 80, 51, 164, 179, 145, 1, 156, 243, 70, 137, 202, 84, 150, 32, 130, 113, 80, 225, 100, 98, 95, 203])), SecretKey(Scalar([16, 145, 18, 18, 3, 71, 113, 158, 165, 134, 55, 56, 176, 216, 91, 214, 245, 66, 173, 49, 207, 182, 185, 27, 8, 95, 178, 219, 72, 85, 226, 10])));
/// SC("gdsc"): gdsc1xrjz66hqqk9x2cqf3thze7x5y8qsuafyumy0lhka6hxyreyfy2ayu6n6es2
static immutable SC = KeyPair(PublicKey(Point([228, 45, 106, 224, 5, 138, 101, 96, 9, 138, 238, 44, 248, 212, 33, 193, 14, 117, 36, 230, 200, 255, 222, 221, 213, 204, 65, 228, 137, 34, 186, 78])), SecretKey(Scalar([16, 46, 14, 87, 2, 218, 61, 178, 168, 162, 203, 212, 75, 13, 98, 39, 127, 227, 81, 249, 253, 144, 37, 14, 132, 158, 231, 84, 191, 243, 24, 8])));
/// SD("gdsd"): gdsd1xrjr667hskjlg5jnrflyjvuerg3g2l89rm5x598lsk666y2k90r453zurju
static immutable SD = KeyPair(PublicKey(Point([228, 61, 107, 215, 133, 165, 244, 82, 83, 26, 126, 73, 51, 153, 26, 34, 133, 124, 229, 30, 232, 106, 20, 255, 133, 181, 173, 17, 86, 43, 199, 90])), SecretKey(Scalar([216, 159, 87, 137, 29, 69, 84, 154, 62, 17, 78, 71, 16, 219, 23, 76, 222, 232, 24, 25, 91, 147, 25, 7, 109, 41, 183, 253, 25, 178, 28, 2])));
/// SE("gdse"): gdse1xrjy66ajnvrc6pfuxnryvca4w46dfn5dxlqkk43cu69d9slgpty3jfnsveg
static immutable SE = KeyPair(PublicKey(Point([228, 77, 107, 178, 155, 7, 141, 5, 60, 52, 198, 70, 99, 181, 117, 116, 212, 206, 141, 55, 193, 107, 86, 56, 230, 138, 210, 195, 232, 10, 201, 25])), SecretKey(Scalar([228, 151, 245, 157, 162, 37, 50, 94, 137, 147, 184, 183, 80, 172, 50, 132, 190, 242, 222, 212, 234, 205, 118, 41, 35, 23, 242, 80, 122, 40, 23, 2])));
/// SF("gdsf"): gdsf1xrj966hue26dfhczd99e6jqg7czjqstlnmj6hg3w4j0tpzy4nr4xx3mf7kx
static immutable SF = KeyPair(PublicKey(Point([228, 93, 106, 252, 202, 180, 212, 223, 2, 105, 75, 157, 72, 8, 246, 5, 32, 65, 127, 158, 229, 171, 162, 46, 172, 158, 176, 136, 149, 152, 234, 99])), SecretKey(Scalar([101, 17, 94, 112, 214, 192, 38, 144, 172, 185, 28, 253, 192, 132, 33, 184, 51, 150, 157, 254, 44, 105, 18, 199, 220, 128, 45, 4, 33, 206, 88, 11])));
/// SG("gdsg"): gdsg1xrjx66s55qh8cg9wxxd8syqntnyfhpfm04dhh3sumy2k5rwkpmsw66mf0nk
static immutable SG = KeyPair(PublicKey(Point([228, 109, 106, 20, 160, 46, 124, 32, 174, 49, 154, 120, 16, 19, 92, 200, 155, 133, 59, 125, 91, 123, 198, 28, 217, 21, 106, 13, 214, 14, 224, 237])), SecretKey(Scalar([234, 128, 104, 200, 93, 204, 191, 137, 112, 148, 121, 142, 4, 124, 11, 154, 114, 191, 152, 105, 42, 176, 221, 180, 251, 212, 118, 235, 198, 251, 41, 4])));
/// SH("gdsh"): gdsh1xrj866swv5hn3088w26k9a3xhr2mgnzkqkyczze7n39eq6al6azgz7pv9q7
static immutable SH = KeyPair(PublicKey(Point([228, 125, 106, 14, 101, 47, 56, 188, 231, 114, 181, 98, 246, 38, 184, 213, 180, 76, 86, 5, 137, 129, 11, 62, 156, 75, 144, 107, 191, 215, 68, 129])), SecretKey(Scalar([12, 149, 241, 11, 197, 55, 113, 187, 156, 207, 37, 106, 37, 240, 3, 212, 161, 143, 39, 174, 106, 216, 215, 232, 177, 236, 114, 211, 128, 151, 75, 6])));
/// SI("gdsi"): gdsi1xrjg66kr4xrgnmln496wnq80g7ee5nc5wcaamjyf3ynedlqkv9ru533kh6e
static immutable SI = KeyPair(PublicKey(Point([228, 141, 106, 195, 169, 134, 137, 239, 243, 169, 116, 233, 128, 239, 71, 179, 154, 79, 20, 118, 59, 221, 200, 137, 137, 39, 150, 252, 22, 97, 71, 202])), SecretKey(Scalar([76, 222, 255, 234, 150, 230, 81, 179, 73, 17, 46, 169, 103, 135, 1, 55, 134, 79, 229, 211, 83, 219, 249, 61, 183, 204, 182, 197, 126, 39, 171, 1])));
/// SJ("gdsj"): gdsj1xrjf66sae0karpfxhsrpafpna8dh2e895z5psmz9cjyy46nx6qv6xsur5ym
static immutable SJ = KeyPair(PublicKey(Point([228, 157, 106, 29, 203, 237, 209, 133, 38, 188, 6, 30, 164, 51, 233, 219, 117, 100, 229, 160, 168, 24, 108, 69, 196, 136, 74, 234, 102, 208, 25, 163])), SecretKey(Scalar([252, 108, 160, 238, 151, 12, 135, 68, 44, 192, 62, 117, 54, 230, 230, 2, 131, 23, 145, 154, 171, 3, 173, 108, 37, 72, 41, 12, 164, 48, 90, 12])));
/// SK("gdsk"): gdsk1xrj266a0a70nnnht20avm0e75605x9m5wtq9am3z6wwd068hw24p27xyzuz
static immutable SK = KeyPair(PublicKey(Point([228, 173, 107, 175, 239, 159, 57, 206, 235, 83, 250, 205, 191, 62, 166, 159, 67, 23, 116, 114, 192, 94, 238, 34, 211, 156, 215, 232, 247, 114, 170, 21])), SecretKey(Scalar([70, 48, 233, 145, 73, 40, 220, 246, 75, 101, 42, 53, 53, 110, 73, 209, 233, 135, 66, 234, 143, 111, 184, 30, 46, 172, 243, 215, 102, 75, 126, 10])));
/// SL("gdsl"): gdsl1xrjt66cf3axkyw52hnnac8r3t50tlkhpqwgdz9z3nddulk3cad827dg2x6w
static immutable SL = KeyPair(PublicKey(Point([228, 189, 107, 9, 143, 77, 98, 58, 138, 188, 231, 220, 28, 113, 93, 30, 191, 218, 225, 3, 144, 209, 20, 81, 155, 91, 207, 218, 56, 235, 78, 175])), SecretKey(Scalar([77, 15, 149, 166, 113, 27, 135, 135, 29, 198, 255, 118, 15, 133, 26, 198, 211, 140, 52, 71, 57, 147, 150, 146, 10, 196, 173, 103, 4, 94, 51, 1])));
/// SM("gdsm"): gdsm1xrjv66lj4e7zks33d7dc5evup0fmaryn77v682lnxx4fqrwl3vm0z6uwda5
static immutable SM = KeyPair(PublicKey(Point([228, 205, 107, 242, 174, 124, 43, 66, 49, 111, 155, 138, 101, 156, 11, 211, 190, 140, 147, 247, 153, 163, 171, 243, 49, 170, 144, 13, 223, 139, 54, 241])), SecretKey(Scalar([14, 123, 248, 168, 76, 11, 244, 22, 85, 210, 121, 72, 89, 249, 236, 25, 167, 122, 218, 11, 47, 104, 21, 64, 135, 188, 98, 46, 49, 166, 133, 13])));
/// SN("gdsn"): gdsn1xrjd6650tavmz939nuqj8ehtvhfe9k2xtwvvu2t4axspywdu2ty6jsrkpr6
static immutable SN = KeyPair(PublicKey(Point([228, 221, 106, 143, 95, 89, 177, 22, 37, 159, 1, 35, 230, 235, 101, 211, 146, 217, 70, 91, 152, 206, 41, 117, 233, 160, 18, 57, 188, 82, 201, 169])), SecretKey(Scalar([137, 157, 108, 182, 85, 81, 65, 229, 57, 73, 167, 162, 2, 217, 62, 101, 250, 241, 104, 38, 211, 8, 186, 194, 48, 222, 127, 218, 27, 186, 131, 3])));
/// SO("gdso"): gdso1xrjw66y9qnsz3vyxk2k8pl6t9xg4jsqy6xu6p2k3jn2yky8t2d3gqytlukt
static immutable SO = KeyPair(PublicKey(Point([228, 237, 104, 133, 4, 224, 40, 176, 134, 178, 172, 112, 255, 75, 41, 145, 89, 64, 4, 209, 185, 160, 170, 209, 148, 212, 75, 16, 235, 83, 98, 128])), SecretKey(Scalar([141, 146, 51, 134, 35, 240, 58, 118, 110, 3, 25, 177, 188, 17, 226, 101, 49, 94, 181, 107, 80, 187, 252, 204, 77, 230, 23, 252, 179, 113, 164, 4])));
/// SP("gdsp"): gdsp1xrj0664rj72kmgu6tgj9eefwa508mfsj30y3etwkg7v99yfhuqkysmzypkc
static immutable SP = KeyPair(PublicKey(Point([228, 253, 106, 163, 151, 149, 109, 163, 154, 90, 36, 92, 229, 46, 237, 30, 125, 166, 18, 139, 201, 28, 173, 214, 71, 152, 82, 145, 55, 224, 44, 72])), SecretKey(Scalar([182, 36, 50, 148, 240, 184, 201, 191, 34, 229, 61, 204, 200, 159, 207, 15, 117, 156, 158, 8, 173, 148, 55, 219, 220, 223, 128, 175, 156, 36, 85, 12])));
/// SQ("gdsq"): gdsq1xrjs660mvassdcew4rr675stqjyqd034aqmmtrnep45uy4fqlwk92gy2l3t
static immutable SQ = KeyPair(PublicKey(Point([229, 13, 105, 251, 103, 97, 6, 227, 46, 168, 199, 175, 82, 11, 4, 136, 6, 190, 53, 232, 55, 181, 142, 121, 13, 105, 194, 85, 32, 251, 172, 85])), SecretKey(Scalar([108, 140, 191, 66, 189, 167, 106, 20, 225, 212, 24, 204, 173, 248, 119, 131, 108, 33, 130, 90, 7, 142, 106, 99, 2, 200, 122, 146, 200, 1, 27, 8])));
/// SR("gdsr"): gdsr1xrj3662aaf84l0kg0xuh0yqgnsfy608x4ty7w95a2ss7mv9y8qahx0zcp0z
static immutable SR = KeyPair(PublicKey(Point([229, 29, 105, 93, 234, 79, 95, 190, 200, 121, 185, 119, 144, 8, 156, 18, 77, 60, 230, 170, 201, 231, 22, 157, 84, 33, 237, 176, 164, 56, 59, 115])), SecretKey(Scalar([106, 202, 217, 207, 77, 78, 162, 245, 219, 200, 174, 214, 169, 153, 251, 56, 91, 86, 87, 146, 91, 71, 13, 124, 135, 157, 216, 244, 186, 103, 135, 0])));
/// SS("gdss"): gdss1xrjj66cuupvkt33tdst08l94ffzwg48ldxrzlz8hcwa6kpc08dfd6990876
static immutable SS = KeyPair(PublicKey(Point([229, 45, 107, 28, 224, 89, 101, 198, 43, 108, 22, 243, 252, 181, 74, 68, 228, 84, 255, 105, 134, 47, 136, 247, 195, 187, 171, 7, 15, 59, 82, 221])), SecretKey(Scalar([223, 215, 110, 159, 10, 146, 87, 74, 24, 124, 254, 186, 228, 55, 120, 49, 119, 152, 11, 8, 61, 32, 255, 170, 190, 29, 255, 2, 141, 151, 155, 2])));
/// ST("gdst"): gdst1xrjn66gjyl33tzqz8q68zlrpuupj3x6lgf76xx062facdc6l7zy8v89qfn9
static immutable ST = KeyPair(PublicKey(Point([229, 61, 105, 18, 39, 227, 21, 136, 2, 56, 52, 113, 124, 97, 231, 3, 40, 155, 95, 66, 125, 163, 25, 250, 82, 123, 134, 227, 95, 240, 136, 118])), SecretKey(Scalar([102, 142, 205, 6, 128, 20, 162, 184, 83, 76, 126, 218, 170, 56, 52, 107, 153, 242, 29, 231, 248, 1, 107, 103, 63, 33, 39, 251, 2, 51, 241, 8])));
/// SU("gdsu"): gdsu1xrj566r03vp3qfjra9apd93r2r6nj3uq2nc3k30ulj5dfzeuvs2dvp2c702
static immutable SU = KeyPair(PublicKey(Point([229, 77, 104, 111, 139, 3, 16, 38, 67, 233, 122, 22, 150, 35, 80, 245, 57, 71, 128, 84, 241, 27, 69, 252, 252, 168, 212, 139, 60, 100, 20, 214])), SecretKey(Scalar([215, 117, 5, 141, 250, 105, 104, 131, 41, 251, 36, 133, 39, 174, 156, 149, 220, 21, 218, 97, 206, 20, 241, 38, 119, 176, 95, 191, 162, 252, 99, 7])));
/// SV("gdsv"): gdsv1xrj466zdr3mlu9p43fvx2up7f6fnnew0jjkazjzgmqc47qa6uql4gqr0dpg
static immutable SV = KeyPair(PublicKey(Point([229, 93, 104, 77, 28, 119, 254, 20, 53, 138, 88, 101, 112, 62, 78, 147, 57, 229, 207, 148, 173, 209, 72, 72, 216, 49, 95, 3, 186, 224, 63, 84])), SecretKey(Scalar([89, 199, 183, 0, 167, 145, 145, 153, 126, 154, 217, 220, 155, 93, 19, 69, 228, 250, 50, 184, 207, 9, 253, 242, 136, 105, 21, 182, 38, 25, 21, 7])));
/// SW("gdsw"): gdsw1xrjk66tp0lpr5y7zgqrh4fnx790ewd274zhu77gxc494cdlv40n7sxj5pd8
static immutable SW = KeyPair(PublicKey(Point([229, 109, 105, 97, 127, 194, 58, 19, 194, 64, 7, 122, 166, 102, 241, 95, 151, 53, 94, 168, 175, 207, 121, 6, 197, 75, 92, 55, 236, 171, 231, 232])), SecretKey(Scalar([197, 253, 56, 38, 78, 187, 85, 205, 159, 101, 22, 82, 248, 188, 178, 23, 90, 187, 27, 125, 176, 216, 181, 65, 17, 99, 184, 150, 169, 139, 217, 8])));
/// SX("gdsx"): gdsx1xrjh66xx5gre88k5w7gw2nfu25h6maerct6cm070wtnr6vv8qmmsxu0zssn
static immutable SX = KeyPair(PublicKey(Point([229, 125, 104, 198, 162, 7, 147, 158, 212, 119, 144, 229, 77, 60, 85, 47, 173, 247, 35, 194, 245, 141, 191, 207, 114, 230, 61, 49, 135, 6, 247, 3])), SecretKey(Scalar([6, 230, 196, 156, 110, 237, 28, 117, 160, 139, 133, 64, 109, 58, 246, 29, 104, 158, 106, 203, 35, 173, 113, 198, 140, 109, 248, 42, 196, 45, 138, 1])));
/// SY("gdsy"): gdsy1xrjc66599zfc8lsx7ksavp2q7qnjtlzgcqesfeujzvcz9enpwtu2khrh5l3
static immutable SY = KeyPair(PublicKey(Point([229, 141, 106, 133, 40, 147, 131, 254, 6, 245, 161, 214, 5, 64, 240, 39, 37, 252, 72, 192, 51, 4, 231, 146, 19, 48, 34, 230, 97, 114, 248, 171])), SecretKey(Scalar([220, 153, 216, 170, 198, 148, 142, 21, 61, 80, 109, 241, 177, 117, 201, 112, 206, 235, 217, 168, 58, 92, 54, 92, 88, 194, 102, 238, 72, 160, 56, 1])));
/// SZ("gdsz"): gdsz1xrje6678tcwly8xu0rk2hrv0d4e3uwy0ne0rh35uqaeaq0hkd7yg7vchymd
static immutable SZ = KeyPair(PublicKey(Point([229, 157, 107, 199, 94, 29, 242, 28, 220, 120, 236, 171, 141, 143, 109, 115, 30, 56, 143, 158, 94, 59, 198, 156, 7, 115, 208, 62, 246, 111, 136, 143])), SecretKey(Scalar([199, 11, 135, 183, 191, 78, 229, 128, 183, 191, 130, 125, 147, 51, 86, 254, 40, 224, 243, 41, 181, 65, 73, 179, 172, 23, 175, 164, 57, 194, 105, 15])));
/// TA("gdta"): gdta1xrnq66j9hpzaquxn7u7jj70w3ye6xmf45syywtejphz050f6u4yeqdfsf9f
static immutable TA = KeyPair(PublicKey(Point([230, 13, 106, 69, 184, 69, 208, 112, 211, 247, 61, 41, 121, 238, 137, 51, 163, 109, 53, 164, 8, 71, 47, 50, 13, 196, 250, 61, 58, 229, 73, 144])), SecretKey(Scalar([25, 44, 209, 222, 85, 225, 39, 232, 209, 62, 104, 171, 142, 188, 71, 155, 244, 83, 82, 188, 185, 86, 228, 220, 103, 243, 85, 44, 117, 255, 144, 11])));
/// TB("gdtb"): gdtb1xrnp66uspfexq8lgjfn6sgjmx467rw8xaukaz5053axcae60w7jvuns8v29
static immutable TB = KeyPair(PublicKey(Point([230, 29, 107, 144, 10, 114, 96, 31, 232, 146, 103, 168, 34, 91, 53, 117, 225, 184, 230, 239, 45, 209, 81, 244, 143, 77, 142, 231, 79, 119, 164, 206])), SecretKey(Scalar([129, 202, 219, 163, 25, 104, 116, 203, 68, 10, 131, 254, 40, 39, 74, 31, 28, 193, 89, 102, 79, 132, 185, 100, 53, 7, 254, 169, 222, 78, 212, 14])));
/// TC("gdtc"): gdtc1xrnz66d4zkj7kv895ex82xcfsu0xlz693624nxzy5d28l4qtu2qzvy0xg9m
static immutable TC = KeyPair(PublicKey(Point([230, 45, 105, 181, 21, 165, 235, 48, 229, 166, 76, 117, 27, 9, 135, 30, 111, 139, 69, 142, 149, 89, 152, 68, 163, 84, 127, 212, 11, 226, 128, 38])), SecretKey(Scalar([12, 92, 166, 150, 66, 199, 211, 162, 141, 51, 55, 43, 244, 144, 45, 33, 172, 103, 28, 243, 218, 160, 181, 57, 153, 99, 47, 69, 140, 173, 0, 12])));
/// TD("gdtd"): gdtd1xrnr66yjmksvwlrsazaj3jwdgd6m6zm0dhmxql42m8g48mfpnj5xs5cl3vg
static immutable TD = KeyPair(PublicKey(Point([230, 61, 104, 146, 221, 160, 199, 124, 112, 232, 187, 40, 201, 205, 67, 117, 189, 11, 111, 109, 246, 96, 126, 170, 217, 209, 83, 237, 33, 156, 168, 104])), SecretKey(Scalar([205, 8, 255, 99, 212, 149, 10, 18, 14, 10, 175, 138, 254, 74, 189, 50, 22, 209, 149, 185, 142, 180, 106, 78, 206, 42, 190, 19, 81, 115, 15, 7])));
/// TE("gdte"): gdte1xrny66pn4f87ff9fke43qwd6hu8jz5kvj90trfyn42lwmhslwzj329uv4np
static immutable TE = KeyPair(PublicKey(Point([230, 77, 104, 51, 170, 79, 228, 164, 169, 182, 107, 16, 57, 186, 191, 15, 33, 82, 204, 145, 94, 177, 164, 147, 170, 190, 237, 222, 31, 112, 165, 21])), SecretKey(Scalar([163, 132, 54, 1, 249, 152, 107, 153, 246, 212, 76, 186, 147, 85, 206, 156, 118, 222, 212, 80, 160, 58, 105, 45, 249, 210, 1, 99, 216, 32, 10, 10])));
/// TF("gdtf"): gdtf1xrn9660ph8sz0ymdtwry367z0hmrsggjgugl2mcpkpe0sfwev6kpkd6dh5j
static immutable TF = KeyPair(PublicKey(Point([230, 93, 105, 225, 185, 224, 39, 147, 109, 91, 134, 72, 235, 194, 125, 246, 56, 33, 18, 71, 17, 245, 111, 1, 176, 114, 248, 37, 217, 102, 172, 27])), SecretKey(Scalar([179, 236, 249, 125, 178, 134, 143, 230, 74, 60, 127, 5, 49, 207, 213, 14, 37, 170, 29, 52, 26, 56, 53, 185, 42, 15, 185, 143, 23, 78, 64, 8])));
/// TG("gdtg"): gdtg1xrnx66lv3p05fzmrvm5ju5vkeyk5t8wnea9pt4h7asnmqd4p9cheyyqf8ah
static immutable TG = KeyPair(PublicKey(Point([230, 109, 107, 236, 136, 95, 68, 139, 99, 102, 233, 46, 81, 150, 201, 45, 69, 157, 211, 207, 74, 21, 214, 254, 236, 39, 176, 54, 161, 46, 47, 146])), SecretKey(Scalar([81, 108, 31, 110, 226, 115, 27, 63, 72, 139, 180, 11, 204, 185, 225, 9, 201, 111, 142, 235, 3, 218, 103, 240, 141, 119, 153, 228, 5, 66, 64, 3])));
/// TH("gdth"): gdth1xrn8666twxmhn6v0fc2wda89y3r5x3lfg6m5fv9j22set3p0r052wv9cs3y
static immutable TH = KeyPair(PublicKey(Point([230, 125, 107, 75, 113, 183, 121, 233, 143, 78, 20, 230, 244, 229, 36, 71, 67, 71, 233, 70, 183, 68, 176, 178, 82, 161, 149, 196, 47, 27, 232, 167])), SecretKey(Scalar([61, 144, 198, 235, 208, 80, 116, 186, 96, 181, 87, 24, 20, 253, 64, 241, 14, 35, 101, 105, 109, 198, 253, 2, 89, 141, 11, 43, 11, 72, 206, 8])));
/// TI("gdti"): gdti1xrng66zewzzvwmcx7k4sh9qlkdpg5l862jd53ytgy29cyjg54hmrxd8a5s4
static immutable TI = KeyPair(PublicKey(Point([230, 141, 104, 89, 112, 132, 199, 111, 6, 245, 171, 11, 148, 31, 179, 66, 138, 124, 250, 84, 155, 72, 145, 104, 34, 139, 130, 73, 20, 173, 246, 51])), SecretKey(Scalar([40, 102, 102, 219, 136, 67, 59, 250, 164, 167, 29, 138, 16, 36, 69, 96, 28, 39, 100, 187, 8, 125, 116, 199, 8, 175, 59, 160, 28, 46, 194, 12])));
/// TJ("gdtj"): gdtj1xrnf664r729vcu9s2jenv0fgjxf4uwh68sa8kt9kxvzlr0yuwnq5jj4l6uv
static immutable TJ = KeyPair(PublicKey(Point([230, 157, 106, 163, 242, 138, 204, 112, 176, 84, 179, 54, 61, 40, 145, 147, 94, 58, 250, 60, 58, 123, 44, 182, 51, 5, 241, 188, 156, 116, 193, 73])), SecretKey(Scalar([145, 227, 13, 156, 179, 120, 114, 115, 41, 216, 65, 144, 33, 73, 163, 96, 211, 23, 11, 124, 62, 6, 87, 208, 27, 32, 156, 43, 232, 168, 167, 5])));
/// TK("gdtk"): gdtk1xrn2662ed7y03lqvp4yc0khhezuqee2m3zyzxn7kfza5c4jlw2592lyssl5
static immutable TK = KeyPair(PublicKey(Point([230, 173, 105, 89, 111, 136, 248, 252, 12, 13, 73, 135, 218, 247, 200, 184, 12, 229, 91, 136, 136, 35, 79, 214, 72, 187, 76, 86, 95, 114, 168, 85])), SecretKey(Scalar([152, 60, 215, 34, 177, 81, 206, 21, 201, 18, 20, 145, 207, 246, 234, 203, 192, 89, 222, 12, 231, 172, 159, 210, 214, 225, 25, 248, 75, 97, 221, 3])));
/// TL("gdtl"): gdtl1xrnt66efrzuuqfnwjys965auym4t52sd8y2m8eyhgz7efma2mr6a7fwv4ez
static immutable TL = KeyPair(PublicKey(Point([230, 189, 107, 41, 24, 185, 192, 38, 110, 145, 32, 93, 83, 188, 38, 234, 186, 42, 13, 57, 21, 179, 228, 151, 64, 189, 148, 239, 170, 216, 245, 223])), SecretKey(Scalar([165, 2, 76, 73, 59, 40, 134, 132, 166, 188, 90, 213, 29, 118, 64, 27, 164, 204, 20, 0, 15, 39, 159, 29, 37, 168, 213, 125, 101, 213, 119, 11])));
/// TM("gdtm"): gdtm1xrnv66ej3jps94n4wy6yddn40vtzfjc67ykjmq0t4ezcajwpp2uuwkjn0nt
static immutable TM = KeyPair(PublicKey(Point([230, 205, 107, 50, 140, 131, 2, 214, 117, 113, 52, 70, 182, 117, 123, 22, 36, 203, 26, 241, 45, 45, 129, 235, 174, 69, 142, 201, 193, 10, 185, 199])), SecretKey(Scalar([72, 212, 145, 240, 209, 135, 131, 179, 104, 166, 75, 30, 172, 76, 0, 152, 89, 140, 30, 6, 154, 163, 106, 54, 93, 95, 76, 81, 249, 3, 165, 12])));
/// TN("gdtn"): gdtn1xrnd66mwfyaclrxnhzl52m7vzgvp0t7pcl7pezdxhh5rtt8p5ym9kfjwuxl
static immutable TN = KeyPair(PublicKey(Point([230, 221, 107, 110, 73, 59, 143, 140, 211, 184, 191, 69, 111, 204, 18, 24, 23, 175, 193, 199, 252, 28, 137, 166, 189, 232, 53, 172, 225, 161, 54, 91])), SecretKey(Scalar([42, 123, 66, 195, 178, 234, 50, 156, 184, 228, 26, 13, 244, 42, 62, 93, 197, 204, 15, 206, 106, 227, 240, 42, 95, 154, 252, 126, 155, 228, 215, 1])));
/// TO("gdto"): gdto1xrnw66v74k32rnfh532gtt4ukr9wdqytdlgx5tk3p8jwpak37zhtklqawhp
static immutable TO = KeyPair(PublicKey(Point([230, 237, 105, 158, 173, 162, 161, 205, 55, 164, 84, 133, 174, 188, 176, 202, 230, 128, 139, 111, 208, 106, 46, 209, 9, 228, 224, 246, 209, 240, 174, 187])), SecretKey(Scalar([51, 221, 173, 218, 31, 62, 175, 186, 102, 155, 83, 242, 146, 156, 61, 67, 2, 209, 230, 85, 128, 98, 159, 14, 161, 211, 246, 168, 27, 129, 228, 7])));
/// TP("gdtp"): gdtp1xrn066ldx3gqxjnc8vvuw0r5cm0h870eu2f0nq735typ9rp9jn9yw2tsf8d
static immutable TP = KeyPair(PublicKey(Point([230, 253, 107, 237, 52, 80, 3, 74, 120, 59, 25, 199, 60, 116, 198, 223, 115, 249, 249, 226, 146, 249, 131, 209, 162, 200, 18, 140, 37, 148, 202, 71])), SecretKey(Scalar([145, 132, 240, 234, 89, 122, 244, 108, 161, 1, 33, 98, 202, 38, 38, 237, 103, 19, 146, 112, 32, 55, 208, 76, 250, 115, 22, 84, 57, 48, 99, 4])));
/// TQ("gdtq"): gdtq1xrns66xscrgre3vqfdn6wc8uu6pn3ph6cs5ngrnl9343qndw32z0sgp6qv0
static immutable TQ = KeyPair(PublicKey(Point([231, 13, 104, 208, 192, 208, 60, 197, 128, 75, 103, 167, 96, 252, 230, 131, 56, 134, 250, 196, 41, 52, 14, 127, 44, 107, 16, 77, 174, 138, 132, 248])), SecretKey(Scalar([102, 251, 202, 230, 110, 87, 159, 128, 240, 44, 255, 150, 179, 249, 116, 86, 209, 126, 176, 231, 33, 0, 179, 145, 174, 79, 15, 20, 16, 160, 18, 10])));
/// TR("gdtr"): gdtr1xrn366zysn0ng38arz5ezj5ddnehz9qrhf2t4uem33n0ccqc2ajv52ag95h
static immutable TR = KeyPair(PublicKey(Point([231, 29, 104, 68, 132, 223, 52, 68, 253, 24, 169, 145, 74, 141, 108, 243, 113, 20, 3, 186, 84, 186, 243, 59, 140, 102, 252, 96, 24, 87, 100, 202])), SecretKey(Scalar([206, 109, 216, 101, 32, 199, 197, 230, 213, 209, 111, 178, 222, 192, 137, 81, 157, 112, 134, 4, 107, 229, 11, 243, 226, 199, 137, 210, 245, 222, 26, 1])));
/// TS("gdts"): gdts1xrnj6629kwc2wg685frhdpaq6u3dl4jvxzumaa3qymcd6vs68t0fg46pplg
static immutable TS = KeyPair(PublicKey(Point([231, 45, 105, 69, 179, 176, 167, 35, 71, 162, 71, 118, 135, 160, 215, 34, 223, 214, 76, 48, 185, 190, 246, 32, 38, 240, 221, 50, 26, 58, 222, 148])), SecretKey(Scalar([187, 251, 163, 39, 125, 70, 219, 2, 151, 217, 85, 81, 18, 236, 230, 117, 175, 70, 134, 81, 241, 86, 228, 245, 207, 118, 22, 113, 1, 136, 23, 4])));
/// TT("gdtt"): gdtt1xrnn66e20un7e8s4p2mc2tz536gkxm7qly8z6u4ddgcy4ghaemyq7u3x0fg
static immutable TT = KeyPair(PublicKey(Point([231, 61, 107, 42, 127, 39, 236, 158, 21, 10, 183, 133, 44, 84, 142, 145, 99, 111, 192, 249, 14, 45, 114, 173, 106, 48, 74, 162, 253, 206, 200, 15])), SecretKey(Scalar([131, 113, 214, 199, 95, 213, 27, 0, 241, 17, 127, 199, 103, 243, 249, 47, 17, 29, 158, 78, 87, 99, 41, 234, 14, 75, 100, 104, 180, 227, 212, 9])));
/// TU("gdtu"): gdtu1xrn566p0v75hsdywls3sz2ugemt8jwcyer9ags93zwahy87sle5p564854t
static immutable TU = KeyPair(PublicKey(Point([231, 77, 104, 47, 103, 169, 120, 52, 142, 252, 35, 1, 43, 136, 206, 214, 121, 59, 4, 200, 203, 212, 64, 177, 19, 187, 114, 31, 208, 254, 104, 26])), SecretKey(Scalar([122, 179, 30, 156, 39, 75, 45, 66, 226, 34, 244, 152, 235, 139, 218, 211, 10, 27, 76, 223, 70, 29, 92, 161, 149, 85, 114, 109, 105, 170, 33, 10])));
/// TV("gdtv"): gdtv1xrn4666zchhu0rjeat3v67pg4rc805yz40s56x747t4ld9ku3ygp78kwdhm
static immutable TV = KeyPair(PublicKey(Point([231, 93, 107, 66, 197, 239, 199, 142, 89, 234, 226, 205, 120, 40, 168, 240, 119, 208, 130, 171, 225, 77, 27, 213, 242, 235, 246, 150, 220, 137, 16, 31])), SecretKey(Scalar([21, 148, 19, 43, 67, 148, 134, 139, 50, 79, 58, 58, 193, 224, 250, 30, 178, 134, 144, 220, 161, 138, 184, 12, 81, 230, 183, 47, 217, 218, 194, 10])));
/// TW("gdtw"): gdtw1xrnk669zn90qwz5xa5p9y72n3klnp5af25t6eudm8230mwkhpdresmvg3lf
static immutable TW = KeyPair(PublicKey(Point([231, 109, 104, 162, 153, 94, 7, 10, 134, 237, 2, 82, 121, 83, 141, 191, 48, 211, 169, 85, 23, 172, 241, 187, 58, 162, 253, 186, 215, 11, 71, 152])), SecretKey(Scalar([211, 72, 11, 171, 166, 249, 226, 13, 22, 166, 112, 138, 214, 213, 117, 42, 112, 249, 72, 92, 135, 216, 20, 220, 107, 203, 123, 118, 226, 42, 170, 10])));
/// TX("gdtx"): gdtx1xrnh669xqwk37ztvhm3u8970v8lm24juwpnj28hd0h6hsykh64phwufgs35
static immutable TX = KeyPair(PublicKey(Point([231, 125, 104, 166, 3, 173, 31, 9, 108, 190, 227, 195, 151, 207, 97, 255, 181, 86, 92, 112, 103, 37, 30, 237, 125, 245, 120, 18, 215, 213, 67, 119])), SecretKey(Scalar([62, 48, 232, 87, 62, 190, 85, 167, 138, 105, 169, 190, 39, 50, 175, 76, 106, 29, 74, 207, 24, 51, 165, 76, 19, 83, 243, 204, 121, 65, 100, 13])));
/// TY("gdty"): gdty1xrnc66352r4weynj4qftr6gmwdgygvzd4c8t2n9wy54n2vwpk0xjztcrzt5
static immutable TY = KeyPair(PublicKey(Point([231, 141, 106, 52, 80, 234, 236, 146, 114, 168, 18, 177, 233, 27, 115, 80, 68, 48, 77, 174, 14, 181, 76, 174, 37, 43, 53, 49, 193, 179, 205, 33])), SecretKey(Scalar([47, 100, 238, 179, 239, 151, 29, 175, 54, 71, 166, 198, 68, 156, 152, 69, 69, 236, 105, 168, 32, 254, 142, 173, 226, 212, 175, 60, 241, 13, 34, 5])));
/// TZ("gdtz"): gdtz1xrne66eaz42crc447qsjtlrjd48v203krttahyzs7rc2x33ph7ypzjh42wv
static immutable TZ = KeyPair(PublicKey(Point([231, 157, 107, 61, 21, 85, 129, 226, 181, 240, 33, 37, 252, 114, 109, 78, 197, 62, 54, 26, 215, 219, 144, 80, 240, 240, 163, 70, 33, 191, 136, 17])), SecretKey(Scalar([15, 134, 24, 174, 231, 81, 160, 235, 239, 149, 185, 212, 91, 193, 202, 42, 223, 209, 92, 254, 62, 181, 144, 182, 235, 152, 8, 125, 206, 127, 208, 11])));
/// UA("gdua"): gdua1xr5q66p4zhzaykqmpk6yphcnvxutx8dtp92lk059rpgxfdec7a7mx527f3e
static immutable UA = KeyPair(PublicKey(Point([232, 13, 104, 53, 21, 197, 210, 88, 27, 13, 180, 64, 223, 19, 97, 184, 179, 29, 171, 9, 85, 251, 62, 133, 24, 80, 100, 183, 56, 247, 125, 179])), SecretKey(Scalar([236, 87, 56, 178, 53, 21, 221, 105, 95, 135, 109, 83, 11, 10, 246, 127, 79, 207, 249, 255, 206, 47, 123, 108, 205, 123, 122, 132, 151, 150, 21, 14])));
/// UB("gdub"): gdub1xr5p664939wyyxry29fzkp6l8rmvpgwf7hvd99cd6qkdxzwkq6j6kln7alc
static immutable UB = KeyPair(PublicKey(Point([232, 29, 106, 165, 137, 92, 66, 24, 100, 81, 82, 43, 7, 95, 56, 246, 192, 161, 201, 245, 216, 210, 151, 13, 208, 44, 211, 9, 214, 6, 165, 171])), SecretKey(Scalar([163, 93, 223, 162, 219, 140, 11, 96, 83, 92, 202, 13, 213, 8, 53, 79, 25, 26, 123, 238, 190, 255, 121, 68, 249, 237, 51, 247, 19, 201, 20, 11])));
/// UC("gduc"): gduc1xr5z6654nvedduhw637u2n6cyhzjkt3c6rw66nxnpr0rw5lefkdq7pggfmy
static immutable UC = KeyPair(PublicKey(Point([232, 45, 106, 149, 155, 50, 214, 242, 238, 212, 125, 197, 79, 88, 37, 197, 43, 46, 56, 208, 221, 173, 76, 211, 8, 222, 55, 83, 249, 77, 154, 15])), SecretKey(Scalar([95, 146, 132, 239, 12, 44, 186, 240, 10, 25, 97, 178, 139, 225, 224, 83, 40, 172, 251, 221, 190, 124, 93, 73, 104, 180, 126, 42, 159, 88, 135, 2])));
/// UD("gdud"): gdud1xr5r66cmphmc9zhqxsrsydsayfkfvk2hvjsefvre39hmpyl4866z7vdc5aw
static immutable UD = KeyPair(PublicKey(Point([232, 61, 107, 27, 13, 247, 130, 138, 224, 52, 7, 2, 54, 29, 34, 108, 150, 89, 87, 100, 161, 148, 176, 121, 137, 111, 176, 147, 245, 62, 180, 47])), SecretKey(Scalar([219, 251, 51, 90, 7, 192, 22, 139, 166, 165, 119, 13, 212, 37, 88, 167, 16, 115, 213, 101, 8, 164, 175, 130, 40, 114, 37, 112, 90, 208, 49, 7])));
/// UE("gdue"): gdue1xr5y6648ltuwyukrhaeqf3mhp6dkkmcdh9czx4kzlsyjq60gsw8kxav3ga7
static immutable UE = KeyPair(PublicKey(Point([232, 77, 106, 167, 250, 248, 226, 114, 195, 191, 114, 4, 199, 119, 14, 155, 107, 111, 13, 185, 112, 35, 86, 194, 252, 9, 32, 105, 232, 131, 143, 99])), SecretKey(Scalar([127, 39, 239, 172, 169, 184, 209, 119, 29, 94, 245, 15, 189, 154, 207, 50, 182, 60, 220, 48, 207, 167, 36, 130, 7, 116, 146, 59, 188, 236, 62, 13])));
/// UF("gduf"): gduf1xr59663l67ndzwha3kyclzlxs9a2e4z55js43qra676wmnxeqtv4wh05t64
static immutable UF = KeyPair(PublicKey(Point([232, 93, 106, 63, 215, 166, 209, 58, 253, 141, 137, 143, 139, 230, 129, 122, 172, 212, 84, 164, 161, 88, 128, 125, 215, 180, 237, 204, 217, 2, 217, 87])), SecretKey(Scalar([231, 234, 73, 98, 160, 244, 100, 115, 102, 148, 124, 143, 197, 57, 61, 120, 131, 130, 199, 179, 163, 213, 165, 5, 171, 111, 198, 111, 202, 248, 2, 6])));
/// UG("gdug"): gdug1xr5x66g39y33jte68s5acpkfjqzsf8590sqedxx809mwgschu6d06lh9qws
static immutable UG = KeyPair(PublicKey(Point([232, 109, 105, 17, 41, 35, 25, 47, 58, 60, 41, 220, 6, 201, 144, 5, 4, 158, 133, 124, 1, 150, 152, 199, 121, 118, 228, 67, 23, 230, 154, 253])), SecretKey(Scalar([101, 19, 168, 16, 194, 114, 19, 80, 226, 142, 39, 125, 56, 151, 27, 5, 127, 173, 215, 251, 241, 197, 56, 48, 88, 224, 153, 186, 26, 43, 118, 9])));
/// UH("gduh"): gduh1xr5866nrvvxwzmhs6gcu040m9xc23reeewufyjenplw8xlwsch4cgafhnh4
static immutable UH = KeyPair(PublicKey(Point([232, 125, 106, 99, 99, 12, 225, 110, 240, 210, 49, 199, 213, 251, 41, 176, 168, 143, 57, 203, 184, 146, 75, 51, 15, 220, 115, 125, 208, 197, 235, 132])), SecretKey(Scalar([94, 27, 189, 57, 56, 42, 132, 9, 117, 244, 125, 13, 170, 172, 30, 76, 241, 83, 217, 157, 11, 186, 226, 52, 91, 102, 152, 40, 203, 235, 246, 13])));
/// UI("gdui"): gdui1xr5g66f5zy08ksaptv4sxmhx8junx2lr8p734mguh7spgsh9d9e3kpwp7xz
static immutable UI = KeyPair(PublicKey(Point([232, 141, 105, 52, 17, 30, 123, 67, 161, 91, 43, 3, 110, 230, 60, 185, 51, 43, 227, 56, 125, 26, 237, 28, 191, 160, 20, 66, 229, 105, 115, 27])), SecretKey(Scalar([107, 123, 241, 243, 124, 53, 141, 49, 119, 5, 54, 61, 108, 108, 241, 171, 79, 236, 157, 40, 181, 202, 207, 9, 57, 109, 98, 228, 185, 180, 127, 2])));
/// UJ("gduj"): gduj1xr5f667s9xns2sfuef73n0uaqc6hpumqgw88llu5hqxwgzj6c0xtxwusskg
static immutable UJ = KeyPair(PublicKey(Point([232, 157, 107, 208, 41, 167, 5, 65, 60, 202, 125, 25, 191, 157, 6, 53, 112, 243, 96, 67, 142, 127, 255, 148, 184, 12, 228, 10, 90, 195, 204, 179])), SecretKey(Scalar([255, 183, 58, 49, 248, 217, 193, 1, 28, 140, 221, 253, 36, 190, 62, 60, 50, 242, 179, 65, 49, 230, 92, 74, 172, 143, 15, 31, 57, 243, 121, 0])));
/// UK("gduk"): gduk1xr5266vqj9zfdlwzqdsw2hsky8a830zvh3y966e8dul8j9g60fmu7aqduap
static immutable UK = KeyPair(PublicKey(Point([232, 173, 105, 128, 145, 68, 150, 253, 194, 3, 96, 229, 94, 22, 33, 250, 120, 188, 76, 188, 72, 93, 107, 39, 111, 62, 121, 21, 26, 122, 119, 207])), SecretKey(Scalar([219, 94, 201, 120, 199, 168, 42, 3, 245, 104, 182, 52, 78, 45, 161, 103, 8, 120, 62, 73, 55, 173, 145, 207, 52, 180, 139, 120, 5, 22, 224, 1])));
/// UL("gdul"): gdul1xr5t6657uflj5kgcd9v4wedmuyyak4qeqff9pxpm8kd8m65pndgzy9lvngd
static immutable UL = KeyPair(PublicKey(Point([232, 189, 106, 158, 226, 127, 42, 89, 24, 105, 89, 87, 101, 187, 225, 9, 219, 84, 25, 2, 82, 80, 152, 59, 61, 154, 125, 234, 129, 155, 80, 34])), SecretKey(Scalar([116, 82, 3, 157, 199, 36, 65, 116, 110, 63, 103, 78, 230, 192, 143, 148, 194, 56, 141, 46, 66, 82, 112, 75, 154, 51, 23, 200, 74, 72, 155, 15])));
/// UM("gdum"): gdum1xr5v66y50w8zgk0k7yaqw543zvna2gr8ye2j2k7rfwyptakszlt0qva2642
static immutable UM = KeyPair(PublicKey(Point([232, 205, 104, 148, 123, 142, 36, 89, 246, 241, 58, 7, 82, 177, 19, 39, 213, 32, 103, 38, 85, 37, 91, 195, 75, 136, 21, 246, 208, 23, 214, 240])), SecretKey(Scalar([1, 207, 157, 5, 219, 9, 217, 145, 46, 67, 187, 202, 53, 144, 240, 137, 76, 199, 161, 40, 222, 171, 183, 38, 155, 227, 145, 133, 85, 110, 47, 12])));
/// UN("gdun"): gdun1xr5d66hqkja06sgkefuzwp9hlxzgmscy6l9mf8cujc7f2zxe2443gxkfpsz
static immutable UN = KeyPair(PublicKey(Point([232, 221, 106, 224, 180, 186, 253, 65, 22, 202, 120, 39, 4, 183, 249, 132, 141, 195, 4, 215, 203, 180, 159, 28, 150, 60, 149, 8, 217, 85, 107, 20])), SecretKey(Scalar([88, 97, 19, 189, 118, 215, 242, 169, 42, 186, 110, 34, 134, 131, 150, 178, 237, 10, 26, 233, 21, 255, 219, 185, 42, 93, 230, 41, 44, 203, 223, 3])));
/// UO("gduo"): gduo1xr5w66y5jvrx6fzvca7nhyhud02262tmpsmp02n487ad6lhzr3g2ys3v7wm
static immutable UO = KeyPair(PublicKey(Point([232, 237, 104, 148, 147, 6, 109, 36, 76, 199, 125, 59, 146, 252, 107, 212, 173, 41, 123, 12, 54, 23, 170, 117, 63, 186, 221, 126, 226, 28, 80, 162])), SecretKey(Scalar([245, 171, 160, 186, 78, 10, 144, 175, 209, 201, 81, 40, 251, 25, 34, 123, 226, 19, 120, 169, 246, 202, 241, 232, 58, 182, 198, 13, 238, 188, 158, 7])));
/// UP("gdup"): gdup1xr50665d2jkclclteenqyx08plugs28qwe7fvytf3f238f7mx8sujlgumht
static immutable UP = KeyPair(PublicKey(Point([232, 253, 106, 141, 84, 173, 143, 227, 235, 206, 102, 2, 25, 231, 15, 248, 136, 40, 224, 118, 124, 150, 17, 105, 138, 85, 19, 167, 219, 49, 225, 201])), SecretKey(Scalar([92, 123, 230, 204, 167, 192, 11, 201, 154, 248, 156, 102, 173, 64, 29, 196, 25, 64, 55, 164, 6, 107, 183, 252, 126, 139, 110, 53, 175, 93, 11, 7])));
/// UQ("gduq"): gduq1xr5s66ljtzhmhrsrsysmwz4wmuddfhegdplz76ruahnakz4dk6tjufgxcz4
static immutable UQ = KeyPair(PublicKey(Point([233, 13, 107, 242, 88, 175, 187, 142, 3, 129, 33, 183, 10, 174, 223, 26, 212, 223, 40, 104, 126, 47, 104, 124, 237, 231, 219, 10, 173, 182, 151, 46])), SecretKey(Scalar([65, 157, 224, 29, 96, 27, 149, 63, 102, 0, 78, 67, 0, 122, 139, 163, 40, 60, 123, 16, 111, 79, 251, 82, 100, 10, 118, 181, 31, 118, 81, 0])));
/// UR("gdur"): gdur1xr5366drrlmv9507pzrtw6kdxvqwk082weg07j28q6r5fa96a8pjvhes0rx
static immutable UR = KeyPair(PublicKey(Point([233, 29, 105, 163, 31, 246, 194, 209, 254, 8, 134, 183, 106, 205, 51, 0, 235, 60, 234, 118, 80, 255, 73, 71, 6, 135, 68, 244, 186, 233, 195, 38])), SecretKey(Scalar([85, 118, 171, 39, 68, 58, 195, 175, 56, 74, 57, 27, 39, 81, 72, 76, 218, 30, 69, 170, 107, 8, 70, 107, 124, 212, 189, 69, 12, 144, 61, 2])));
/// US("gdus"): gdus1xr5j66jprd6fm3hgsxszmfr6mvkved4nrzxqc2mf9dncpu832czjcckgm0e
static immutable US = KeyPair(PublicKey(Point([233, 45, 106, 65, 27, 116, 157, 198, 232, 129, 160, 45, 164, 122, 219, 44, 204, 182, 179, 24, 140, 12, 43, 105, 43, 103, 128, 240, 241, 86, 5, 44])), SecretKey(Scalar([166, 190, 22, 156, 165, 137, 241, 36, 1, 123, 148, 236, 22, 97, 54, 172, 202, 170, 188, 55, 98, 101, 178, 89, 181, 32, 14, 70, 128, 145, 151, 4])));
/// UT("gdut"): gdut1xr5n66weuqus70ltn6czsld5mmy6p7gx5zkhrnpxhah59ja48gcnuejdrfx
static immutable UT = KeyPair(PublicKey(Point([233, 61, 105, 217, 224, 57, 15, 63, 235, 158, 176, 40, 125, 180, 222, 201, 160, 249, 6, 160, 173, 113, 204, 38, 191, 111, 66, 203, 181, 58, 49, 62])), SecretKey(Scalar([197, 236, 226, 211, 64, 131, 126, 179, 85, 9, 11, 2, 115, 171, 235, 234, 124, 151, 234, 93, 15, 24, 230, 250, 67, 25, 197, 178, 85, 163, 250, 6])));
/// UU("gduu"): gduu1xr5566jmuvyc6g4gc4hh4jv9ph27rrjjhsu3zarhvj3vz7fvkrp97sagnpv
static immutable UU = KeyPair(PublicKey(Point([233, 77, 106, 91, 227, 9, 141, 34, 168, 197, 111, 122, 201, 133, 13, 213, 225, 142, 82, 188, 57, 17, 116, 119, 100, 162, 193, 121, 44, 176, 194, 95])), SecretKey(Scalar([178, 8, 78, 48, 161, 120, 172, 84, 103, 224, 214, 110, 120, 104, 70, 98, 154, 233, 198, 41, 178, 228, 193, 12, 100, 140, 53, 50, 118, 253, 237, 9])));
/// UV("gduv"): gduv1xr5466ph388q8h7hhlahvghmrg7v6darur5k9835ukhxkfs6ffavxmpv0jd
static immutable UV = KeyPair(PublicKey(Point([233, 93, 104, 55, 137, 206, 3, 223, 215, 191, 251, 118, 34, 251, 26, 60, 205, 55, 163, 224, 233, 98, 158, 52, 229, 174, 107, 38, 26, 74, 122, 195])), SecretKey(Scalar([47, 108, 82, 188, 75, 177, 216, 127, 80, 94, 100, 249, 247, 123, 18, 28, 77, 118, 103, 1, 173, 141, 30, 62, 129, 242, 74, 115, 181, 137, 216, 12])));
/// UW("gduw"): gduw1xr5k66yr59ju8ufykjvlkvm4fcj3rdqhzsn0wsr0mg937ev50z3ajug7hcu
static immutable UW = KeyPair(PublicKey(Point([233, 109, 104, 131, 161, 101, 195, 241, 36, 180, 153, 251, 51, 117, 78, 37, 17, 180, 23, 20, 38, 247, 64, 111, 218, 11, 31, 101, 148, 120, 163, 217])), SecretKey(Scalar([154, 35, 87, 15, 21, 108, 225, 211, 172, 6, 53, 16, 109, 109, 183, 92, 24, 116, 146, 101, 38, 252, 146, 112, 197, 47, 129, 121, 251, 211, 97, 13])));
/// UX("gdux"): gdux1xr5h66tuvexvfmnax2nkg4jxtdy98vydgcfcay6gxh2fh7rq9qprwym7em7
static immutable UX = KeyPair(PublicKey(Point([233, 125, 105, 124, 102, 76, 196, 238, 125, 50, 167, 100, 86, 70, 91, 72, 83, 176, 141, 70, 19, 142, 147, 72, 53, 212, 155, 248, 96, 40, 2, 55])), SecretKey(Scalar([84, 46, 238, 79, 187, 47, 83, 9, 18, 28, 240, 71, 78, 38, 33, 99, 233, 216, 90, 77, 104, 201, 55, 9, 87, 7, 207, 70, 148, 26, 240, 15])));
/// UY("gduy"): gduy1xr5c668x475rmjmtmku7rmxyvh7n9v6n27k5z0zm9uzmx6h8cp3a60n8q6h
static immutable UY = KeyPair(PublicKey(Point([233, 141, 104, 230, 175, 168, 61, 203, 107, 221, 185, 225, 236, 196, 101, 253, 50, 179, 83, 87, 173, 65, 60, 91, 47, 5, 179, 106, 231, 192, 99, 221])), SecretKey(Scalar([19, 128, 4, 184, 186, 213, 237, 130, 80, 107, 215, 198, 75, 116, 238, 254, 78, 28, 168, 152, 126, 128, 165, 0, 24, 49, 90, 148, 39, 17, 226, 13])));
/// UZ("gduz"): gduz1xr5e66uyc0ra7u25p5gcvstu6tu6qsgaszp0w7p7fntzc5eg4hdwu5x9lfm
static immutable UZ = KeyPair(PublicKey(Point([233, 157, 107, 132, 195, 199, 223, 113, 84, 13, 17, 134, 65, 124, 210, 249, 160, 65, 29, 128, 130, 247, 120, 62, 76, 214, 44, 83, 40, 173, 218, 238])), SecretKey(Scalar([26, 181, 43, 221, 57, 133, 21, 31, 171, 36, 135, 1, 229, 182, 82, 1, 251, 149, 250, 28, 234, 98, 86, 19, 190, 220, 99, 200, 194, 94, 197, 9])));
/// VA("gdva"): gdva1xr4q66luuqkqe7wnxwu30thnygku4e7hqxdq2zgpkdh5chyy5gs2sg7f6ly
static immutable VA = KeyPair(PublicKey(Point([234, 13, 107, 252, 224, 44, 12, 249, 211, 51, 185, 23, 174, 243, 34, 45, 202, 231, 215, 1, 154, 5, 9, 1, 179, 111, 76, 92, 132, 162, 32, 168])), SecretKey(Scalar([35, 16, 98, 218, 118, 191, 252, 194, 16, 238, 175, 198, 244, 187, 142, 240, 193, 131, 28, 157, 97, 53, 145, 28, 146, 102, 25, 99, 195, 226, 218, 10])));
/// VB("gdvb"): gdvb1xr4p66qxhs25quewq4akkzuyd7e5nd5l77hau7gqmlrva8uk0xfv2hz5a6d
static immutable VB = KeyPair(PublicKey(Point([234, 29, 104, 6, 188, 21, 64, 115, 46, 5, 123, 107, 11, 132, 111, 179, 73, 182, 159, 247, 175, 222, 121, 0, 223, 198, 206, 159, 150, 121, 146, 197])), SecretKey(Scalar([213, 33, 206, 0, 154, 208, 5, 40, 72, 51, 55, 229, 56, 1, 249, 193, 130, 237, 56, 43, 239, 22, 187, 255, 213, 66, 217, 113, 179, 174, 71, 1])));
/// VC("gdvc"): gdvc1xr4z66dac7ymxfa7m0j0c52fwa8tjk67tmrynzxgn437gxg7myaqqkxdj22
static immutable VC = KeyPair(PublicKey(Point([234, 45, 105, 189, 199, 137, 179, 39, 190, 219, 228, 252, 81, 73, 119, 78, 185, 91, 94, 94, 198, 73, 136, 200, 157, 99, 228, 25, 30, 217, 58, 0])), SecretKey(Scalar([148, 190, 96, 133, 5, 149, 150, 93, 158, 219, 153, 249, 51, 218, 83, 40, 172, 86, 204, 241, 197, 190, 124, 233, 215, 215, 236, 148, 29, 91, 59, 10])));
/// VD("gdvd"): gdvd1xr4r663aza7zh0vwsmdq370havxne2fq5h8798hxsv090q46nrs3q6j4ags
static immutable VD = KeyPair(PublicKey(Point([234, 61, 106, 61, 23, 124, 43, 189, 142, 134, 218, 8, 249, 247, 235, 13, 60, 169, 32, 165, 207, 226, 158, 230, 131, 30, 87, 130, 186, 152, 225, 16])), SecretKey(Scalar([22, 154, 73, 152, 152, 79, 248, 237, 239, 181, 248, 226, 121, 145, 138, 230, 242, 206, 211, 245, 86, 35, 108, 234, 182, 37, 60, 101, 251, 112, 82, 2])));
/// VE("gdve"): gdve1xr4y66w99h6y6epry78pf8uu0dzzp9c0ca6vxftju93mj6e2kz7rk0cd945
static immutable VE = KeyPair(PublicKey(Point([234, 77, 105, 197, 45, 244, 77, 100, 35, 39, 142, 20, 159, 156, 123, 68, 32, 151, 15, 199, 116, 195, 37, 114, 225, 99, 185, 107, 42, 176, 188, 59])), SecretKey(Scalar([9, 129, 199, 195, 139, 55, 114, 16, 108, 163, 207, 36, 122, 79, 168, 40, 80, 111, 184, 10, 83, 148, 242, 229, 120, 61, 11, 120, 243, 57, 62, 12])));
/// VF("gdvf"): gdvf1xr4966shvqp9znxgmkrmlm4m3vw54d8tc27y5x5mhl7mg8pjls02zykjh2f
static immutable VF = KeyPair(PublicKey(Point([234, 93, 106, 23, 96, 2, 81, 76, 200, 221, 135, 191, 238, 187, 139, 29, 74, 180, 235, 194, 188, 74, 26, 155, 191, 253, 180, 28, 50, 252, 30, 161])), SecretKey(Scalar([226, 221, 185, 31, 182, 98, 171, 48, 253, 94, 153, 162, 63, 165, 184, 155, 223, 158, 223, 249, 50, 156, 46, 99, 130, 247, 106, 110, 186, 102, 171, 2])));
/// VG("gdvg"): gdvg1xr4x66czpzywuknneagpr0fuduqzznu7jyqstdff4946z2dmgfll79k2ng9
static immutable VG = KeyPair(PublicKey(Point([234, 109, 107, 2, 8, 136, 238, 90, 115, 207, 80, 17, 189, 60, 111, 0, 33, 79, 158, 145, 1, 5, 181, 41, 169, 107, 161, 41, 187, 66, 127, 255])), SecretKey(Scalar([57, 215, 201, 148, 229, 77, 31, 71, 208, 23, 73, 30, 64, 157, 78, 75, 163, 138, 48, 224, 221, 221, 107, 57, 13, 57, 238, 12, 34, 34, 41, 6])));
/// VH("gdvh"): gdvh1xr4866cywpzk7an4rmucwkqf3d8mmuwnjkgewf2580m44za8k8kvq6n2x48
static immutable VH = KeyPair(PublicKey(Point([234, 125, 107, 4, 112, 69, 111, 118, 117, 30, 249, 135, 88, 9, 139, 79, 189, 241, 211, 149, 145, 151, 37, 84, 59, 247, 90, 139, 167, 177, 236, 192])), SecretKey(Scalar([125, 132, 45, 180, 153, 236, 154, 143, 47, 175, 183, 50, 174, 174, 77, 153, 139, 105, 140, 240, 194, 51, 210, 126, 204, 226, 253, 55, 176, 210, 37, 6])));
/// VI("gdvi"): gdvi1xr4g66dkykwglg9ktr9llpjeza2c8vvpd0j48snt6gp33z3aelx65m8h0ld
static immutable VI = KeyPair(PublicKey(Point([234, 141, 105, 182, 37, 156, 143, 160, 182, 88, 203, 255, 134, 89, 23, 85, 131, 177, 129, 107, 229, 83, 194, 107, 210, 3, 24, 138, 61, 207, 205, 170])), SecretKey(Scalar([134, 109, 177, 121, 225, 224, 46, 85, 29, 74, 48, 202, 157, 77, 212, 254, 115, 41, 213, 101, 129, 71, 64, 119, 38, 210, 118, 216, 230, 199, 14, 15])));
/// VJ("gdvj"): gdvj1xr4f66kajganq8pgvmmw9kkpxesv0hhu2ekpu4qufrlua3gdwnpzkxp06qm
static immutable VJ = KeyPair(PublicKey(Point([234, 157, 106, 221, 146, 59, 48, 28, 40, 102, 246, 226, 218, 193, 54, 96, 199, 222, 252, 86, 108, 30, 84, 28, 72, 255, 206, 197, 13, 116, 194, 43])), SecretKey(Scalar([247, 73, 130, 191, 182, 251, 151, 70, 190, 234, 240, 225, 39, 150, 97, 14, 14, 176, 150, 232, 124, 229, 208, 134, 165, 252, 112, 59, 225, 167, 199, 9])));
/// VK("gdvk"): gdvk1xr4266clcftdsdxg38dunhamvkvfwduucq0equq34patacea865457xgxv8
static immutable VK = KeyPair(PublicKey(Point([234, 173, 107, 31, 194, 86, 216, 52, 200, 137, 219, 201, 223, 187, 101, 152, 151, 55, 156, 192, 31, 144, 112, 17, 168, 122, 190, 227, 61, 62, 169, 90])), SecretKey(Scalar([225, 189, 40, 78, 224, 243, 26, 197, 129, 116, 2, 167, 1, 201, 249, 233, 237, 115, 163, 39, 45, 172, 127, 156, 234, 51, 95, 198, 211, 233, 59, 3])));
/// VL("gdvl"): gdvl1xr4t66j73wc2km365n4t027pxsuw27xls3s50mr73eu36qrtuce9c3vd29q
static immutable VL = KeyPair(PublicKey(Point([234, 189, 106, 94, 139, 176, 171, 110, 58, 164, 234, 183, 171, 193, 52, 56, 229, 120, 223, 132, 97, 71, 236, 126, 142, 121, 29, 0, 107, 230, 50, 92])), SecretKey(Scalar([194, 87, 199, 175, 129, 6, 167, 68, 213, 155, 115, 113, 42, 69, 195, 160, 144, 66, 14, 24, 83, 71, 198, 20, 249, 18, 233, 249, 145, 75, 66, 8])));
/// VM("gdvm"): gdvm1xr4v66gqaap2ksnghqd2wf7luwlj67p6aes22g8226xlrxt8cmjwkqtfu4h
static immutable VM = KeyPair(PublicKey(Point([234, 205, 105, 0, 239, 66, 171, 66, 104, 184, 26, 167, 39, 223, 227, 191, 45, 120, 58, 238, 96, 165, 32, 234, 86, 141, 241, 153, 103, 198, 228, 235])), SecretKey(Scalar([63, 222, 36, 29, 160, 230, 140, 211, 166, 5, 8, 90, 69, 207, 12, 208, 143, 217, 194, 48, 217, 229, 198, 17, 209, 132, 155, 63, 133, 153, 207, 12])));
/// VN("gdvn"): gdvn1xr4d66ewweehw7mnxvzcmxmnf30u3ws7eunfkp8ca5ysc4hqd8gzkwtd2u3
static immutable VN = KeyPair(PublicKey(Point([234, 221, 107, 46, 118, 115, 119, 123, 115, 51, 5, 141, 155, 115, 76, 95, 200, 186, 30, 207, 38, 155, 4, 248, 237, 9, 12, 86, 224, 105, 208, 43])), SecretKey(Scalar([180, 92, 160, 51, 30, 196, 47, 64, 255, 183, 6, 120, 19, 213, 242, 234, 251, 186, 137, 0, 135, 239, 18, 87, 116, 44, 153, 211, 189, 166, 152, 5])));
/// VO("gdvo"): gdvo1xr4w664euccv2ydyntdnredud68hw8d5tdr05v0awckp0zzplw0fwm4f2jz
static immutable VO = KeyPair(PublicKey(Point([234, 237, 106, 185, 230, 48, 197, 17, 164, 154, 219, 49, 229, 188, 110, 143, 119, 29, 180, 91, 70, 250, 49, 253, 118, 44, 23, 136, 65, 251, 158, 151])), SecretKey(Scalar([117, 193, 179, 216, 196, 89, 47, 5, 191, 162, 224, 209, 5, 78, 2, 232, 32, 55, 64, 209, 48, 212, 219, 187, 77, 22, 169, 48, 64, 126, 213, 14])));
/// VP("gdvp"): gdvp1xr4066gk9rcpra96ut3e78p4m8qmyuc3xxncmhq0yd6wlhlgq8mdq8szezd
static immutable VP = KeyPair(PublicKey(Point([234, 253, 105, 22, 40, 240, 17, 244, 186, 226, 227, 159, 28, 53, 217, 193, 178, 115, 17, 49, 167, 141, 220, 15, 35, 116, 239, 223, 232, 1, 246, 208])), SecretKey(Scalar([142, 24, 186, 97, 187, 120, 242, 178, 164, 187, 199, 172, 8, 122, 117, 3, 121, 230, 160, 112, 5, 51, 20, 0, 120, 78, 21, 198, 198, 150, 143, 8])));
/// VQ("gdvq"): gdvq1xr4s66v4c7vx6lf4za225x2e50v2w6elpwnl9dfdny5zpuxnstc96gh5zje
static immutable VQ = KeyPair(PublicKey(Point([235, 13, 105, 149, 199, 152, 109, 125, 53, 23, 84, 170, 25, 89, 163, 216, 167, 107, 63, 11, 167, 242, 181, 45, 153, 40, 32, 240, 211, 130, 240, 93])), SecretKey(Scalar([177, 80, 120, 0, 43, 53, 251, 104, 99, 242, 240, 196, 128, 64, 6, 220, 196, 92, 217, 213, 78, 172, 71, 155, 51, 48, 230, 70, 182, 111, 229, 0])));
/// VR("gdvr"): gdvr1xr4366e7648s55lz4qqx6ce6ghutfuljz7fduaqaluzcq9dy46jg756s9g8
static immutable VR = KeyPair(PublicKey(Point([235, 29, 107, 62, 213, 79, 10, 83, 226, 168, 0, 109, 99, 58, 69, 248, 180, 243, 242, 23, 146, 222, 116, 29, 255, 5, 128, 21, 164, 174, 164, 143])), SecretKey(Scalar([24, 246, 155, 36, 224, 209, 154, 28, 12, 126, 108, 23, 148, 29, 12, 208, 93, 86, 14, 17, 2, 113, 218, 91, 136, 45, 26, 134, 24, 48, 107, 7])));
/// VS("gdvs"): gdvs1xr4j6602pah472rchfqz2x2wtd2lha2k5u2e4urz4fajfm4l7p7lymun653
static immutable VS = KeyPair(PublicKey(Point([235, 45, 105, 234, 15, 111, 95, 40, 120, 186, 64, 37, 25, 78, 91, 85, 251, 245, 86, 167, 21, 154, 240, 98, 170, 123, 36, 238, 191, 240, 125, 242])), SecretKey(Scalar([127, 48, 142, 102, 11, 25, 15, 145, 99, 243, 227, 15, 228, 62, 178, 171, 199, 157, 127, 127, 43, 60, 61, 245, 171, 208, 119, 123, 101, 254, 112, 12])));
/// VT("gdvt"): gdvt1xr4n66cechm6v9hke3s0zt449kgqcl6qd752y989a3gt5jlt2kl8qu6v2av
static immutable VT = KeyPair(PublicKey(Point([235, 61, 107, 25, 197, 247, 166, 22, 246, 204, 96, 241, 46, 181, 45, 144, 12, 127, 64, 111, 168, 162, 20, 229, 236, 80, 186, 75, 235, 85, 190, 112])), SecretKey(Scalar([153, 40, 17, 58, 178, 223, 173, 166, 203, 95, 76, 223, 239, 137, 214, 67, 115, 188, 197, 10, 13, 218, 227, 148, 33, 92, 246, 196, 14, 84, 57, 3])));
/// VU("gdvu"): gdvu1xr4566cvtlp7wxycsmach82lz67u8untwqu74z9ntq5pnfefnys670z8y7s
static immutable VU = KeyPair(PublicKey(Point([235, 77, 107, 12, 95, 195, 231, 24, 152, 134, 251, 139, 157, 95, 22, 189, 195, 242, 107, 112, 57, 234, 136, 179, 88, 40, 25, 167, 41, 153, 33, 175])), SecretKey(Scalar([234, 243, 233, 241, 192, 101, 20, 176, 120, 62, 149, 111, 11, 205, 169, 143, 44, 78, 77, 140, 77, 141, 185, 23, 224, 14, 75, 26, 61, 228, 199, 6])));
/// VV("gdvv"): gdvv1xr44667dnv6thlzljq3t7zdm37488jl5ckads9jf383zg09taaf7gxhcp2y
static immutable VV = KeyPair(PublicKey(Point([235, 93, 107, 205, 155, 52, 187, 252, 95, 144, 34, 191, 9, 187, 143, 170, 115, 203, 244, 197, 186, 216, 22, 73, 137, 226, 36, 60, 171, 239, 83, 228])), SecretKey(Scalar([183, 231, 178, 213, 34, 220, 55, 84, 165, 49, 221, 25, 107, 161, 254, 81, 133, 159, 9, 51, 239, 58, 64, 134, 193, 109, 83, 126, 96, 192, 8, 15])));
/// VW("gdvw"): gdvw1xr4k66knks8tu2pevsw2r675u5ft0nhx88fd368hc0nqnqqmx3fwgzp3kq0
static immutable VW = KeyPair(PublicKey(Point([235, 109, 106, 211, 180, 14, 190, 40, 57, 100, 28, 161, 235, 212, 229, 18, 183, 206, 230, 57, 210, 216, 232, 247, 195, 230, 9, 128, 27, 52, 82, 228])), SecretKey(Scalar([118, 174, 13, 37, 78, 84, 105, 51, 60, 197, 90, 87, 47, 68, 149, 133, 39, 8, 0, 0, 251, 213, 232, 197, 180, 64, 134, 235, 204, 160, 205, 12])));
/// VX("gdvx"): gdvx1xr4h6663k974ahrzrf7p8tw4kwpnxw4t3qmfnx66sa9qqre8tlq2qgnnm5z
static immutable VX = KeyPair(PublicKey(Point([235, 125, 107, 81, 177, 125, 94, 220, 98, 26, 124, 19, 173, 213, 179, 131, 51, 58, 171, 136, 54, 153, 155, 90, 135, 74, 0, 15, 39, 95, 192, 160])), SecretKey(Scalar([144, 47, 125, 217, 113, 220, 12, 194, 38, 237, 255, 46, 134, 218, 150, 52, 193, 141, 154, 102, 137, 97, 227, 129, 179, 4, 198, 137, 135, 173, 110, 0])));
/// VY("gdvy"): gdvy1xr4c66jp9lwvmvj6r7v9j5ejnfvpljevtc9fumpur62ljsh4203z77zmhxp
static immutable VY = KeyPair(PublicKey(Point([235, 141, 106, 65, 47, 220, 205, 178, 90, 31, 152, 89, 83, 50, 154, 88, 31, 203, 44, 94, 10, 158, 108, 60, 30, 149, 249, 66, 245, 83, 226, 47])), SecretKey(Scalar([1, 157, 42, 87, 227, 46, 0, 75, 154, 63, 194, 205, 46, 137, 50, 162, 169, 159, 187, 53, 211, 90, 132, 122, 13, 108, 118, 117, 193, 126, 226, 8])));
/// VZ("gdvz"): gdvz1xr4e662pt6h9hhtqhhqfkn39kt0tmjtufy27su9a8talxvxg7g5n56ve8tr
static immutable VZ = KeyPair(PublicKey(Point([235, 157, 105, 65, 94, 174, 91, 221, 96, 189, 192, 155, 78, 37, 178, 222, 189, 201, 124, 73, 21, 232, 112, 189, 58, 251, 243, 48, 200, 242, 41, 58])), SecretKey(Scalar([226, 136, 41, 55, 0, 134, 143, 197, 65, 166, 44, 193, 193, 124, 223, 143, 36, 2, 245, 85, 36, 168, 142, 106, 239, 99, 178, 187, 53, 253, 151, 7])));
/// WA("gdwa"): gdwa1xrkq66z8730enh97tkyqlqv0aa93ffzvf53ld6g97ff66kl2z7hjxs44cdp
static immutable WA = KeyPair(PublicKey(Point([236, 13, 104, 71, 244, 95, 153, 220, 190, 93, 136, 15, 129, 143, 239, 75, 20, 164, 76, 77, 35, 246, 233, 5, 242, 83, 173, 91, 234, 23, 175, 35])), SecretKey(Scalar([177, 99, 176, 54, 124, 242, 146, 162, 73, 102, 88, 31, 56, 175, 200, 0, 221, 202, 35, 235, 124, 120, 27, 71, 177, 8, 162, 0, 178, 141, 130, 3])));
/// WB("gdwb"): gdwb1xrkp66ungf4mwnytc2e0zs2n5hc7n450ne0xc3f6aqlr50ul9sxrx8274tf
static immutable WB = KeyPair(PublicKey(Point([236, 29, 107, 147, 66, 107, 183, 76, 139, 194, 178, 241, 65, 83, 165, 241, 233, 214, 143, 158, 94, 108, 69, 58, 232, 62, 58, 63, 159, 44, 12, 51])), SecretKey(Scalar([121, 120, 68, 254, 102, 2, 202, 234, 49, 97, 52, 151, 13, 40, 212, 43, 143, 214, 66, 254, 4, 222, 210, 97, 240, 240, 22, 230, 236, 147, 74, 2])));
/// WC("gdwc"): gdwc1xrkz66x8e52quaj44zw34vf9ags5r87zguf3vhuzj9tcv0tahl5h60qcxjc
static immutable WC = KeyPair(PublicKey(Point([236, 45, 104, 199, 205, 20, 14, 118, 85, 168, 157, 26, 177, 37, 234, 33, 65, 159, 194, 71, 19, 22, 95, 130, 145, 87, 134, 61, 125, 191, 233, 125])), SecretKey(Scalar([236, 147, 16, 39, 218, 42, 10, 210, 79, 112, 136, 153, 246, 165, 198, 103, 5, 127, 191, 227, 175, 128, 255, 140, 80, 59, 30, 178, 67, 24, 160, 13])));
/// WD("gdwd"): gdwd1xrkr66n9tqqv8v5cvp6gy7f00pktg83l7u7e6whq9uwpk483uc0wyxknqp9
static immutable WD = KeyPair(PublicKey(Point([236, 61, 106, 101, 88, 0, 195, 178, 152, 96, 116, 130, 121, 47, 120, 108, 180, 30, 63, 247, 61, 157, 58, 224, 47, 28, 27, 84, 241, 230, 30, 226])), SecretKey(Scalar([187, 83, 9, 100, 143, 227, 144, 141, 177, 212, 69, 248, 56, 57, 22, 144, 107, 208, 59, 121, 151, 30, 155, 131, 243, 227, 218, 141, 90, 239, 164, 3])));
/// WE("gdwe"): gdwe1xrky6627svrxkm7mvtcvxwavmfvdqyumlqxl5v3798d7hf4c28ye7nme92n
static immutable WE = KeyPair(PublicKey(Point([236, 77, 105, 94, 131, 6, 107, 111, 219, 98, 240, 195, 59, 172, 218, 88, 208, 19, 155, 248, 13, 250, 50, 62, 41, 219, 235, 166, 184, 81, 201, 159])), SecretKey(Scalar([161, 160, 220, 80, 21, 159, 50, 138, 15, 115, 13, 219, 195, 90, 253, 10, 219, 89, 251, 199, 255, 109, 8, 68, 159, 152, 35, 164, 198, 227, 212, 1])));
/// WF("gdwf"): gdwf1xrk966mvvfk5ece3aqat9p7tez39dhyx833jkm6muve7u3ns2dmu6kh3rxf
static immutable WF = KeyPair(PublicKey(Point([236, 93, 107, 108, 98, 109, 76, 227, 49, 232, 58, 178, 135, 203, 200, 162, 86, 220, 134, 60, 99, 43, 111, 91, 227, 51, 238, 70, 112, 83, 119, 205])), SecretKey(Scalar([196, 252, 37, 135, 3, 101, 216, 222, 37, 154, 126, 51, 245, 243, 47, 117, 169, 235, 192, 198, 230, 8, 140, 62, 250, 225, 145, 19, 80, 179, 142, 2])));
/// WG("gdwg"): gdwg1xrkx669l6jv38ggr69n9huuvvluspddl47n4w6ge5zdsdkzs2f5x7cw3rdg
static immutable WG = KeyPair(PublicKey(Point([236, 109, 104, 191, 212, 153, 19, 161, 3, 209, 102, 91, 243, 140, 103, 249, 0, 181, 191, 175, 167, 87, 105, 25, 160, 155, 6, 216, 80, 82, 104, 111])), SecretKey(Scalar([141, 111, 154, 81, 205, 82, 196, 101, 166, 90, 104, 64, 244, 239, 110, 246, 102, 9, 224, 184, 5, 150, 219, 80, 72, 251, 231, 62, 111, 226, 155, 5])));
/// WH("gdwh"): gdwh1xrk866k83x3hdxv64xllw67ppfk0u2hgdswcjx0a9jd97wtsgsenyvd3ymh
static immutable WH = KeyPair(PublicKey(Point([236, 125, 106, 199, 137, 163, 118, 153, 154, 169, 191, 247, 107, 193, 10, 108, 254, 42, 232, 108, 29, 137, 25, 253, 44, 154, 95, 57, 112, 68, 51, 50])), SecretKey(Scalar([224, 142, 254, 16, 56, 12, 150, 9, 168, 116, 140, 27, 109, 191, 104, 7, 118, 164, 99, 96, 1, 25, 129, 141, 204, 215, 64, 108, 218, 220, 134, 4])));
/// WI("gdwi"): gdwi1xrkg66rgk6lrze7h4r8el4pjcl6ctfagaysamds9dphc5se78q27s539luh
static immutable WI = KeyPair(PublicKey(Point([236, 141, 104, 104, 182, 190, 49, 103, 215, 168, 207, 159, 212, 50, 199, 245, 133, 167, 168, 233, 33, 221, 182, 5, 104, 111, 138, 67, 62, 56, 21, 232])), SecretKey(Scalar([217, 145, 242, 175, 14, 57, 236, 61, 178, 218, 255, 239, 40, 115, 52, 193, 232, 32, 30, 38, 204, 48, 206, 184, 37, 29, 188, 47, 86, 18, 192, 6])));
/// WJ("gdwj"): gdwj1xrkf66ycd70k203tfxn2ke62yweach9thnh09lfmgg00aetuvmepwk6ddue
static immutable WJ = KeyPair(PublicKey(Point([236, 157, 104, 152, 111, 159, 101, 62, 43, 73, 166, 171, 103, 74, 35, 179, 220, 92, 171, 188, 238, 242, 253, 59, 66, 30, 254, 229, 124, 102, 242, 23])), SecretKey(Scalar([236, 146, 203, 209, 189, 204, 93, 50, 68, 247, 76, 50, 5, 223, 80, 230, 9, 34, 22, 33, 137, 152, 191, 106, 229, 17, 252, 41, 96, 19, 224, 10])));
/// WK("gdwk"): gdwk1xrk266lrqtnsnda5xg5zd5eaqdf6ew9mk33n3p7ehsz07vesxvj056h28uw
static immutable WK = KeyPair(PublicKey(Point([236, 173, 107, 227, 2, 231, 9, 183, 180, 50, 40, 38, 211, 61, 3, 83, 172, 184, 187, 180, 99, 56, 135, 217, 188, 4, 255, 51, 48, 51, 36, 250])), SecretKey(Scalar([146, 183, 254, 242, 122, 65, 191, 174, 6, 221, 30, 183, 168, 100, 232, 246, 237, 139, 41, 49, 225, 38, 15, 177, 57, 64, 51, 118, 141, 191, 71, 15])));
/// WL("gdwl"): gdwl1xrkt66m6u4lnl44gun0lfc3g6uhq5p9zdd92fef283npal7kctr8jny9z9j
static immutable WL = KeyPair(PublicKey(Point([236, 189, 107, 122, 229, 127, 63, 214, 168, 228, 223, 244, 226, 40, 215, 46, 10, 4, 162, 107, 74, 164, 229, 42, 60, 102, 30, 255, 214, 194, 198, 121])), SecretKey(Scalar([56, 40, 204, 224, 66, 74, 212, 152, 9, 218, 131, 153, 66, 155, 56, 196, 134, 47, 206, 35, 160, 175, 103, 178, 177, 162, 132, 40, 180, 34, 77, 1])));
/// WM("gdwm"): gdwm1xrkv66l8ehmy0qw5q5kw8luk9pcwem2epgs8ru7wf5aw5f3r2hzcsag527h
static immutable WM = KeyPair(PublicKey(Point([236, 205, 107, 231, 205, 246, 71, 129, 212, 5, 44, 227, 255, 150, 40, 112, 236, 237, 89, 10, 32, 113, 243, 206, 77, 58, 234, 38, 35, 85, 197, 136])), SecretKey(Scalar([241, 98, 127, 223, 152, 154, 16, 1, 192, 202, 191, 136, 37, 75, 161, 106, 221, 255, 163, 65, 56, 190, 137, 175, 200, 115, 180, 204, 57, 150, 188, 3])));
/// WN("gdwn"): gdwn1xrkd667n7p24uy5a4jxelzq0dglpcftxntuzjqurn4nzxkh047decgeq4t3
static immutable WN = KeyPair(PublicKey(Point([236, 221, 107, 211, 240, 85, 94, 18, 157, 172, 141, 159, 136, 15, 106, 62, 28, 37, 102, 154, 248, 41, 3, 131, 157, 102, 35, 90, 239, 175, 155, 156])), SecretKey(Scalar([81, 247, 152, 49, 118, 179, 235, 138, 194, 25, 95, 50, 207, 235, 121, 180, 248, 206, 44, 92, 187, 248, 140, 146, 26, 182, 85, 53, 214, 198, 21, 6])));
/// WO("gdwo"): gdwo1xrkw66yn377pq38u5f7aud0h0g7xpvxuq9ven8m4rgd6h4fkghdy7yezg94
static immutable WO = KeyPair(PublicKey(Point([236, 237, 104, 147, 143, 188, 16, 68, 252, 162, 125, 222, 53, 247, 122, 60, 96, 176, 220, 1, 89, 153, 159, 117, 26, 27, 171, 213, 54, 69, 218, 79])), SecretKey(Scalar([191, 47, 239, 46, 219, 166, 62, 130, 24, 58, 89, 206, 51, 87, 214, 117, 223, 75, 251, 112, 240, 194, 174, 170, 21, 90, 121, 50, 149, 162, 31, 3])));
/// WP("gdwp"): gdwp1xrk066f699566wjgla0z9vmkumtgtu2vqhwlmpp0yqp9mnxexzrsvappma9
static immutable WP = KeyPair(PublicKey(Point([236, 253, 105, 58, 41, 105, 173, 58, 72, 255, 94, 34, 179, 118, 230, 214, 133, 241, 76, 5, 221, 253, 132, 47, 32, 2, 93, 204, 217, 48, 135, 6])), SecretKey(Scalar([111, 205, 43, 80, 199, 6, 195, 165, 119, 68, 224, 52, 184, 137, 29, 106, 174, 16, 39, 114, 32, 60, 117, 151, 134, 177, 113, 254, 216, 113, 120, 11])));
/// WQ("gdwq"): gdwq1xrks66q93qkz6m0xen9jlyn7gg7m9rq8fel9dzza2zn6zf5446xlu4t525x
static immutable WQ = KeyPair(PublicKey(Point([237, 13, 104, 5, 136, 44, 45, 109, 230, 204, 203, 47, 146, 126, 66, 61, 178, 140, 7, 78, 126, 86, 136, 93, 80, 167, 161, 38, 149, 174, 141, 254])), SecretKey(Scalar([153, 83, 139, 220, 38, 209, 162, 151, 199, 154, 165, 87, 49, 125, 28, 247, 75, 115, 218, 34, 220, 117, 36, 238, 233, 229, 121, 143, 193, 254, 231, 9])));
/// WR("gdwr"): gdwr1xrk366pp9cgd826g0y6fpzt5j7cjjevqumaysswqzsvjlsrw38h4jesgr59
static immutable WR = KeyPair(PublicKey(Point([237, 29, 104, 33, 46, 16, 211, 171, 72, 121, 52, 144, 137, 116, 151, 177, 41, 101, 128, 230, 250, 72, 65, 192, 20, 25, 47, 192, 110, 137, 239, 89])), SecretKey(Scalar([111, 68, 10, 160, 175, 96, 145, 94, 248, 70, 170, 144, 40, 192, 160, 4, 107, 15, 110, 103, 253, 148, 248, 101, 252, 58, 199, 55, 123, 38, 178, 8])));
/// WS("gdws"): gdws1xrkj668xqyazyddqrsczmsnr4me2kzpttuf9jer2wuwp0lvugg5azceud56
static immutable WS = KeyPair(PublicKey(Point([237, 45, 104, 230, 1, 58, 34, 53, 160, 28, 48, 45, 194, 99, 174, 242, 171, 8, 43, 95, 18, 89, 100, 106, 119, 28, 23, 253, 156, 66, 41, 209])), SecretKey(Scalar([68, 99, 135, 89, 33, 0, 73, 181, 100, 154, 192, 2, 11, 187, 107, 104, 233, 125, 74, 125, 87, 215, 207, 118, 113, 114, 212, 88, 79, 113, 228, 11])));
/// WT("gdwt"): gdwt1xrkn66nsz673rhvm76zsq0suxmfq4jxr8a22vhp43x4j4tw0g6tzkgjlz2z
static immutable WT = KeyPair(PublicKey(Point([237, 61, 106, 112, 22, 189, 17, 221, 155, 246, 133, 0, 62, 28, 54, 210, 10, 200, 195, 63, 84, 166, 92, 53, 137, 171, 42, 173, 207, 70, 150, 43])), SecretKey(Scalar([33, 199, 214, 61, 149, 169, 129, 201, 143, 65, 49, 151, 133, 187, 44, 204, 178, 69, 61, 253, 146, 139, 134, 197, 2, 122, 152, 37, 76, 125, 95, 12])));
/// WU("gdwu"): gdwu1xrk566xmn0rtqct6s4xcnmn9m23v08k3xxcmh5zpmxzf8vp680wwssr7na2
static immutable WU = KeyPair(PublicKey(Point([237, 77, 104, 219, 155, 198, 176, 97, 122, 133, 77, 137, 238, 101, 218, 162, 199, 158, 209, 49, 177, 187, 208, 65, 217, 132, 147, 176, 58, 59, 220, 232])), SecretKey(Scalar([199, 110, 20, 187, 158, 96, 242, 251, 148, 205, 15, 51, 62, 246, 207, 232, 121, 105, 144, 148, 107, 73, 24, 152, 4, 76, 83, 200, 46, 51, 216, 5])));
/// WV("gdwv"): gdwv1xrk466lge2ul4a9wxsme04jeyqzkhl6xhdrawplayyklx9vfm5cesx0ysw6
static immutable WV = KeyPair(PublicKey(Point([237, 93, 107, 232, 202, 185, 250, 244, 174, 52, 55, 151, 214, 89, 32, 5, 107, 255, 70, 187, 71, 215, 7, 253, 33, 45, 243, 21, 137, 221, 49, 152])), SecretKey(Scalar([18, 177, 1, 147, 236, 228, 190, 246, 128, 228, 201, 241, 194, 77, 171, 194, 202, 193, 86, 217, 24, 16, 239, 143, 99, 183, 250, 17, 37, 49, 138, 11])));
/// WW("gdww"): gdww1xrkk66yawylc93vpkls5rtwzrmradyhjfmzyvcc49wz2pc226sr8jtj0w8n
static immutable WW = KeyPair(PublicKey(Point([237, 109, 104, 157, 113, 63, 130, 197, 129, 183, 225, 65, 173, 194, 30, 199, 214, 146, 242, 78, 196, 70, 99, 21, 43, 132, 160, 225, 74, 212, 6, 121])), SecretKey(Scalar([51, 183, 86, 243, 121, 172, 57, 82, 17, 117, 138, 238, 195, 114, 119, 74, 152, 91, 176, 167, 220, 63, 25, 70, 8, 87, 96, 6, 197, 48, 233, 14])));
/// WX("gdwx"): gdwx1xrkh66sytzqdw4zmuva3eay2ucd43dsh7p7raa9uuscjejlwawr96jlw65u
static immutable WX = KeyPair(PublicKey(Point([237, 125, 106, 4, 88, 128, 215, 84, 91, 227, 59, 28, 244, 138, 230, 27, 88, 182, 23, 240, 124, 62, 244, 188, 228, 49, 44, 203, 238, 235, 134, 93])), SecretKey(Scalar([55, 214, 178, 223, 49, 179, 220, 194, 54, 231, 2, 32, 89, 2, 8, 213, 100, 4, 155, 102, 188, 217, 211, 141, 167, 205, 144, 71, 142, 0, 190, 7])));
/// WY("gdwy"): gdwy1xrkc66mj97z5ewt7md8tpus9pcmhyzjtmne8jtv668tj9pnygctdudgk5zz
static immutable WY = KeyPair(PublicKey(Point([237, 141, 107, 114, 47, 133, 76, 185, 126, 219, 78, 176, 242, 5, 14, 55, 114, 10, 75, 220, 242, 121, 45, 154, 209, 215, 34, 134, 100, 70, 22, 222])), SecretKey(Scalar([52, 67, 128, 91, 13, 192, 101, 8, 194, 194, 139, 159, 112, 114, 133, 199, 28, 241, 31, 124, 31, 233, 152, 157, 28, 126, 11, 25, 52, 86, 165, 1])));
/// WZ("gdwz"): gdwz1xrke668f7suphms5ugch359s7mtncgqwj05fsrw46jm9mm06ynd77vze806
static immutable WZ = KeyPair(PublicKey(Point([237, 157, 104, 233, 244, 56, 27, 238, 20, 226, 49, 120, 208, 176, 246, 215, 60, 32, 14, 147, 232, 152, 13, 213, 212, 182, 93, 237, 250, 36, 219, 239])), SecretKey(Scalar([253, 30, 197, 214, 171, 130, 199, 251, 86, 33, 141, 17, 184, 247, 18, 47, 86, 62, 156, 179, 251, 182, 206, 93, 64, 69, 51, 136, 118, 194, 236, 8])));
/// XA("gdxa"): gdxa1xrhq66lmjvpqeyeehzphk8jmss4m73j0k28de9kv40kt3s9l8twhvm3tmws
static immutable XA = KeyPair(PublicKey(Point([238, 13, 107, 251, 147, 2, 12, 147, 57, 184, 131, 123, 30, 91, 132, 43, 191, 70, 79, 178, 142, 220, 150, 204, 171, 236, 184, 192, 191, 58, 221, 118])), SecretKey(Scalar([196, 79, 86, 252, 1, 146, 130, 246, 176, 205, 145, 43, 144, 237, 159, 226, 232, 39, 24, 234, 116, 221, 130, 255, 126, 219, 192, 216, 147, 27, 33, 14])));
/// XB("gdxb"): gdxb1xrhp66vzancj5vchrdxzcl7hhk4f420lms425vqcw89c8yax2tak77fyas3
static immutable XB = KeyPair(PublicKey(Point([238, 29, 105, 130, 236, 241, 42, 51, 23, 27, 76, 44, 127, 215, 189, 170, 154, 169, 255, 220, 42, 170, 48, 24, 113, 203, 131, 147, 166, 82, 251, 111])), SecretKey(Scalar([198, 123, 13, 45, 58, 2, 142, 8, 32, 251, 177, 225, 250, 128, 78, 15, 195, 103, 180, 186, 71, 0, 88, 110, 68, 103, 124, 15, 48, 132, 118, 3])));
/// XC("gdxc"): gdxc1xrhz6658eu6vnx3vh54vwdx3cem6zl4ltzpu6xssx3dnq7y4eyen2wh3khj
static immutable XC = KeyPair(PublicKey(Point([238, 45, 106, 135, 207, 52, 201, 154, 44, 189, 42, 199, 52, 209, 198, 119, 161, 126, 191, 88, 131, 205, 26, 16, 52, 91, 48, 120, 149, 201, 51, 53])), SecretKey(Scalar([132, 153, 21, 45, 125, 79, 173, 126, 219, 48, 58, 229, 14, 211, 229, 181, 82, 131, 154, 1, 254, 64, 192, 194, 0, 17, 191, 183, 132, 154, 118, 5])));
/// XD("gdxd"): gdxd1xrhr664e8qmt95fsesc4nuekgm3sg8jwgwge299kl55zlkvha4yuxnsklum
static immutable XD = KeyPair(PublicKey(Point([238, 61, 106, 185, 56, 54, 178, 209, 48, 204, 49, 89, 243, 54, 70, 227, 4, 30, 78, 67, 145, 149, 20, 182, 253, 40, 47, 217, 151, 237, 73, 195])), SecretKey(Scalar([123, 127, 13, 105, 4, 122, 81, 175, 137, 59, 38, 203, 27, 192, 140, 197, 61, 137, 239, 149, 129, 8, 128, 218, 240, 37, 53, 80, 158, 254, 47, 11])));
/// XE("gdxe"): gdxe1xrhy66nq05k22sgjxljanc30u2rcvswsf329wq2pxzpushcpz43rklgx3kq
static immutable XE = KeyPair(PublicKey(Point([238, 77, 106, 96, 125, 44, 165, 65, 18, 55, 229, 217, 226, 47, 226, 135, 134, 65, 208, 76, 84, 87, 1, 65, 48, 131, 200, 95, 1, 21, 98, 59])), SecretKey(Scalar([245, 185, 40, 231, 243, 69, 122, 37, 214, 135, 14, 48, 226, 178, 104, 248, 112, 1, 163, 223, 2, 96, 49, 248, 60, 137, 69, 162, 123, 112, 236, 8])));
/// XF("gdxf"): gdxf1xrh966nr6cggq0kfy4c5gupp07s2ddz953rxpt0dyukdfsvwujvfx8kqnqm
static immutable XF = KeyPair(PublicKey(Point([238, 93, 106, 99, 214, 16, 128, 62, 201, 37, 113, 68, 112, 33, 127, 160, 166, 180, 69, 164, 70, 96, 173, 237, 39, 44, 212, 193, 142, 228, 152, 147])), SecretKey(Scalar([179, 85, 228, 134, 148, 8, 228, 61, 251, 200, 220, 37, 72, 102, 229, 241, 197, 185, 6, 220, 169, 183, 119, 73, 3, 49, 182, 85, 188, 23, 38, 10])));
/// XG("gdxg"): gdxg1xrhx66hfn0dz8l2gaftvth0k2nrw0277zd6xyfu0rklff5tp776774l6yra
static immutable XG = KeyPair(PublicKey(Point([238, 109, 106, 233, 155, 218, 35, 253, 72, 234, 86, 197, 221, 246, 84, 198, 231, 171, 222, 19, 116, 98, 39, 143, 29, 190, 148, 209, 97, 247, 181, 239])), SecretKey(Scalar([45, 21, 181, 30, 111, 12, 244, 129, 17, 13, 16, 121, 110, 50, 232, 133, 16, 89, 168, 31, 16, 78, 225, 106, 121, 144, 96, 248, 184, 60, 208, 2])));
/// XH("gdxh"): gdxh1xrh866ddtufg5qz8stzmppk52d7u4tupf5rzphht2xyy600vwp3ncyy6hus
static immutable XH = KeyPair(PublicKey(Point([238, 125, 105, 173, 95, 18, 138, 0, 71, 130, 197, 176, 134, 212, 83, 125, 202, 175, 129, 77, 6, 32, 222, 235, 81, 136, 77, 61, 236, 112, 99, 60])), SecretKey(Scalar([34, 228, 130, 180, 6, 246, 73, 157, 99, 215, 180, 98, 181, 65, 186, 68, 25, 38, 35, 20, 51, 40, 87, 151, 83, 44, 153, 219, 235, 113, 59, 9])));
/// XI("gdxi"): gdxi1xrhg6656czd7u8yzzzyfewcuk35cp02mwyfzxaskgwyd44t3837jzpzytk9
static immutable XI = KeyPair(PublicKey(Point([238, 141, 106, 154, 192, 155, 238, 28, 130, 16, 136, 156, 187, 28, 180, 105, 128, 189, 91, 113, 18, 35, 118, 22, 67, 136, 218, 213, 113, 60, 125, 33])), SecretKey(Scalar([15, 29, 0, 122, 69, 166, 106, 241, 51, 11, 68, 134, 131, 126, 202, 26, 196, 14, 190, 250, 236, 131, 35, 123, 87, 171, 117, 73, 33, 202, 12, 3])));
/// XJ("gdxj"): gdxj1xrhf66jhhqgva5kdhscvdcreyhv44uxv77y5jjy2gedq3cq4se4k25460rf
static immutable XJ = KeyPair(PublicKey(Point([238, 157, 106, 87, 184, 16, 206, 210, 205, 188, 48, 198, 224, 121, 37, 217, 90, 240, 204, 247, 137, 73, 72, 138, 70, 90, 8, 224, 21, 134, 107, 101])), SecretKey(Scalar([130, 122, 165, 25, 228, 198, 196, 110, 148, 150, 217, 107, 170, 29, 120, 205, 53, 228, 253, 133, 254, 6, 7, 50, 246, 120, 119, 108, 146, 79, 106, 12])));
/// XK("gdxk"): gdxk1xrh266pxd20c80ttyazsr95caytw9nawqh8l8pslekpdvdgjuvfqv3ymzuj
static immutable XK = KeyPair(PublicKey(Point([238, 173, 104, 38, 106, 159, 131, 189, 107, 39, 69, 1, 150, 152, 233, 22, 226, 207, 174, 5, 207, 243, 134, 31, 205, 130, 214, 53, 18, 227, 18, 6])), SecretKey(Scalar([49, 169, 24, 112, 66, 102, 249, 208, 255, 55, 115, 58, 209, 56, 94, 229, 146, 177, 114, 139, 122, 89, 192, 210, 10, 89, 193, 229, 207, 26, 12, 8])));
/// XL("gdxl"): gdxl1xrht66rnrj2lftnj78cfp0d2zvckwtxp8dljl7rf3y7ry9hp7t6ycae6n5a
static immutable XL = KeyPair(PublicKey(Point([238, 189, 104, 115, 28, 149, 244, 174, 114, 241, 240, 144, 189, 170, 19, 49, 103, 44, 193, 59, 127, 47, 248, 105, 137, 60, 50, 22, 225, 242, 244, 76])), SecretKey(Scalar([6, 64, 209, 148, 8, 107, 172, 31, 104, 97, 63, 140, 251, 71, 15, 51, 196, 131, 122, 106, 225, 108, 243, 198, 21, 156, 242, 202, 47, 148, 88, 6])));
/// XM("gdxm"): gdxm1xrhv660fe4qayr9mjg0dluyhjpww9psmy8y2tsefrp2e0xwf2wq8wejlmsw
static immutable XM = KeyPair(PublicKey(Point([238, 205, 105, 233, 205, 65, 210, 12, 187, 146, 30, 223, 240, 151, 144, 92, 226, 134, 27, 33, 200, 165, 195, 41, 24, 85, 151, 153, 201, 83, 128, 119])), SecretKey(Scalar([76, 64, 4, 234, 238, 67, 237, 129, 40, 17, 167, 21, 31, 213, 50, 192, 188, 11, 211, 87, 147, 155, 78, 181, 117, 44, 142, 105, 218, 190, 105, 0])));
/// XN("gdxn"): gdxn1xrhd66nsvce2ptepms3dug0l9dzqsam6vfewwsq3jum2pgnkcjlnce62z55
static immutable XN = KeyPair(PublicKey(Point([238, 221, 106, 112, 102, 50, 160, 175, 33, 220, 34, 222, 33, 255, 43, 68, 8, 119, 122, 98, 114, 231, 64, 17, 151, 54, 160, 162, 118, 196, 191, 60])), SecretKey(Scalar([111, 6, 98, 247, 222, 63, 175, 56, 253, 36, 203, 246, 97, 134, 145, 219, 247, 0, 252, 59, 15, 96, 6, 21, 227, 140, 223, 255, 187, 135, 221, 5])));
/// XO("gdxo"): gdxo1xrhw66829qplz0ea7e9gy6dw0fksm4j8eqecq9f3s3walvaatrgnctfzalp
static immutable XO = KeyPair(PublicKey(Point([238, 237, 104, 234, 40, 3, 241, 63, 61, 246, 74, 130, 105, 174, 122, 109, 13, 214, 71, 200, 51, 128, 21, 49, 132, 93, 223, 179, 189, 88, 209, 60])), SecretKey(Scalar([101, 252, 72, 249, 130, 107, 53, 57, 146, 254, 138, 30, 119, 65, 54, 10, 118, 235, 58, 202, 127, 194, 32, 77, 120, 81, 126, 248, 200, 220, 39, 1])));
/// XP("gdxp"): gdxp1xrh0664kqkgqvpf6ejhgran7qantrpqedk6ruqyx20q8z6fd7jm3gyxmx2q
static immutable XP = KeyPair(PublicKey(Point([238, 253, 106, 182, 5, 144, 6, 5, 58, 204, 174, 129, 246, 126, 7, 102, 177, 132, 25, 109, 180, 62, 0, 134, 83, 192, 113, 105, 45, 244, 183, 20])), SecretKey(Scalar([115, 117, 117, 188, 38, 220, 180, 2, 125, 1, 70, 112, 254, 132, 99, 160, 85, 91, 118, 122, 189, 2, 104, 154, 61, 8, 121, 99, 132, 151, 4, 13])));
/// XQ("gdxq"): gdxq1xrhs66j0dy6ujellqh9ezn6n26t3j5srmrtzqxncpusnjg9044czxxut4w3
static immutable XQ = KeyPair(PublicKey(Point([239, 13, 106, 79, 105, 53, 201, 103, 255, 5, 203, 145, 79, 83, 86, 151, 25, 82, 3, 216, 214, 32, 26, 120, 15, 33, 57, 32, 175, 173, 112, 35])), SecretKey(Scalar([248, 31, 247, 180, 230, 166, 118, 232, 149, 71, 117, 69, 79, 82, 240, 236, 134, 249, 107, 60, 221, 243, 182, 175, 46, 243, 39, 235, 66, 13, 230, 3])));
/// XR("gdxr"): gdxr1xrh366dcdxhylkpnnh3g5tj6pr8sd7khyst8d2u2ehrl2mmkua9wswqrte7
static immutable XR = KeyPair(PublicKey(Point([239, 29, 105, 184, 105, 174, 79, 216, 51, 157, 226, 138, 46, 90, 8, 207, 6, 250, 215, 36, 22, 118, 171, 138, 205, 199, 245, 111, 118, 231, 74, 232])), SecretKey(Scalar([78, 92, 19, 166, 234, 143, 188, 109, 171, 20, 164, 234, 162, 208, 78, 26, 7, 151, 95, 6, 169, 66, 73, 62, 229, 28, 132, 81, 132, 251, 183, 8])));
/// XS("gdxs"): gdxs1xrhj6687nyx0r2t6gfvp39csayjg7snlcpukfu8xy3adzmjxwh44gk22r96
static immutable XS = KeyPair(PublicKey(Point([239, 45, 104, 254, 153, 12, 241, 169, 122, 66, 88, 24, 151, 16, 233, 36, 143, 66, 127, 192, 121, 100, 240, 230, 36, 122, 209, 110, 70, 117, 235, 84])), SecretKey(Scalar([87, 56, 236, 42, 129, 7, 253, 233, 19, 175, 141, 198, 16, 4, 61, 170, 87, 141, 242, 149, 250, 250, 202, 246, 143, 37, 220, 151, 3, 95, 136, 7])));
/// XT("gdxt"): gdxt1xrhn66wsxwvypunmyrz4r8ss8w70jmk07ch5np5h5h6myhxh4jwpgpljh3j
static immutable XT = KeyPair(PublicKey(Point([239, 61, 105, 208, 51, 152, 64, 242, 123, 32, 197, 81, 158, 16, 59, 188, 249, 110, 207, 246, 47, 73, 134, 151, 165, 245, 178, 92, 215, 172, 156, 20])), SecretKey(Scalar([214, 108, 228, 202, 239, 215, 254, 235, 144, 56, 136, 2, 109, 75, 114, 210, 107, 234, 240, 187, 221, 233, 26, 3, 242, 119, 57, 69, 146, 56, 63, 3])));
/// XU("gdxu"): gdxu1xrh566a9gxgd8lenpdmrz0wggpr4a5p8z9qvhfe052r8psv2ywznghmgmds
static immutable XU = KeyPair(PublicKey(Point([239, 77, 107, 165, 65, 144, 211, 255, 51, 11, 118, 49, 61, 200, 64, 71, 94, 208, 39, 17, 64, 203, 167, 47, 162, 134, 112, 193, 138, 35, 133, 52])), SecretKey(Scalar([205, 200, 54, 140, 188, 3, 175, 100, 17, 127, 33, 101, 62, 227, 219, 10, 95, 246, 180, 8, 200, 205, 132, 2, 101, 182, 87, 95, 50, 156, 88, 6])));
/// XV("gdxv"): gdxv1xrh466ccjqpmv6xnu4jrkdgmxynvpdg2cc0tzt5xrutf99ldm2a62nxgl8v
static immutable XV = KeyPair(PublicKey(Point([239, 93, 107, 24, 144, 3, 182, 104, 211, 229, 100, 59, 53, 27, 49, 38, 192, 181, 10, 198, 30, 177, 46, 134, 31, 22, 146, 151, 237, 218, 187, 165])), SecretKey(Scalar([12, 122, 141, 73, 152, 219, 6, 135, 162, 248, 160, 221, 34, 22, 103, 125, 221, 175, 29, 120, 254, 121, 174, 169, 83, 217, 194, 6, 45, 45, 10, 5])));
/// XW("gdxw"): gdxw1xrhk665rk39uhpd0kcx66rvezq0w3zndj6q9j53eqgfn3njwv6gc5wc4zpd
static immutable XW = KeyPair(PublicKey(Point([239, 109, 106, 131, 180, 75, 203, 133, 175, 182, 13, 173, 13, 153, 16, 30, 232, 138, 109, 150, 128, 89, 82, 57, 2, 19, 56, 206, 78, 102, 145, 138])), SecretKey(Scalar([23, 214, 225, 77, 78, 42, 62, 108, 179, 239, 219, 59, 116, 105, 139, 20, 233, 43, 27, 192, 139, 233, 66, 207, 92, 234, 214, 218, 154, 186, 56, 13])));
/// XX("gdxx"): gdxx1xrhh66ek0kyp25gv7c3yys7xjdu8msx882y7peufnepyguxzuwngw8c02vz
static immutable XX = KeyPair(PublicKey(Point([239, 125, 107, 54, 125, 136, 21, 81, 12, 246, 34, 66, 67, 198, 147, 120, 125, 192, 199, 58, 137, 224, 231, 137, 158, 66, 68, 112, 194, 227, 166, 135])), SecretKey(Scalar([153, 159, 158, 140, 11, 55, 132, 98, 133, 66, 39, 60, 195, 193, 91, 205, 158, 147, 2, 36, 39, 237, 207, 219, 46, 148, 56, 124, 103, 93, 30, 14])));
/// XY("gdxy"): gdxy1xrhc66kg9al98w7yhd26e36wslq4lszdsml50x974qdmaydp9kflwkepcm8
static immutable XY = KeyPair(PublicKey(Point([239, 141, 106, 200, 47, 126, 83, 187, 196, 187, 85, 172, 199, 78, 135, 193, 95, 192, 77, 134, 255, 71, 152, 190, 168, 27, 190, 145, 161, 45, 147, 247])), SecretKey(Scalar([239, 10, 12, 51, 85, 54, 224, 1, 226, 145, 35, 120, 177, 155, 6, 124, 241, 32, 74, 83, 59, 155, 54, 184, 12, 223, 88, 134, 239, 109, 204, 8])));
/// XZ("gdxz"): gdxz1xrhe66l54c59ehqsw339xt2knlm3rj77ex9lyy2fhvfrgj8alty6gj5d2ny
static immutable XZ = KeyPair(PublicKey(Point([239, 157, 107, 244, 174, 40, 92, 220, 16, 116, 98, 83, 45, 86, 159, 247, 17, 203, 222, 201, 139, 242, 17, 73, 187, 18, 52, 72, 253, 250, 201, 164])), SecretKey(Scalar([136, 9, 60, 170, 210, 17, 24, 205, 24, 95, 204, 61, 187, 154, 64, 236, 165, 103, 237, 244, 22, 24, 118, 23, 224, 204, 37, 190, 232, 231, 181, 12])));
/// YA("gdya"): gdya1xrcq669fu0knmujltmp3wsug05h97zck3qjhssjrm4f682u3swx4k2fus8w
static immutable YA = KeyPair(PublicKey(Point([240, 13, 104, 169, 227, 237, 61, 242, 95, 94, 195, 23, 67, 136, 125, 46, 95, 11, 22, 136, 37, 120, 66, 67, 221, 83, 163, 171, 145, 131, 141, 91])), SecretKey(Scalar([206, 54, 208, 125, 216, 233, 42, 221, 224, 2, 67, 77, 233, 213, 220, 214, 66, 134, 104, 120, 21, 108, 194, 203, 60, 199, 228, 156, 206, 141, 46, 4])));
/// YB("gdyb"): gdyb1xrcp660wvz2ayz7tx2tnnmkr77z058nyg3hkqzucfglqct2qhvxwgst6zxn
static immutable YB = KeyPair(PublicKey(Point([240, 29, 105, 238, 96, 149, 210, 11, 203, 50, 151, 57, 238, 195, 247, 132, 250, 30, 100, 68, 111, 96, 11, 152, 74, 62, 12, 45, 64, 187, 12, 228])), SecretKey(Scalar([229, 17, 239, 198, 149, 147, 100, 72, 225, 102, 43, 212, 3, 149, 100, 197, 42, 246, 35, 47, 236, 247, 57, 76, 230, 213, 11, 150, 148, 236, 87, 0])));
/// YC("gdyc"): gdyc1xrcz665gngsakz0tl485awx2qjgccanayw7fa002fnpzutcvw7uqxr2xxpn
static immutable YC = KeyPair(PublicKey(Point([240, 45, 106, 136, 154, 33, 219, 9, 235, 253, 79, 78, 184, 202, 4, 145, 140, 118, 125, 35, 188, 158, 189, 234, 76, 194, 46, 47, 12, 119, 184, 3])), SecretKey(Scalar([199, 15, 178, 94, 9, 124, 255, 175, 15, 85, 118, 199, 111, 251, 118, 241, 196, 144, 164, 137, 108, 53, 104, 96, 61, 53, 208, 242, 170, 163, 18, 10])));
/// YD("gdyd"): gdyd1xrcr66wqj9w2xcmd9ycqkea9z9qqlm9944xks40w4tj8c2yyh0e9y2clw95
static immutable YD = KeyPair(PublicKey(Point([240, 61, 105, 192, 145, 92, 163, 99, 109, 41, 48, 11, 103, 165, 17, 64, 15, 236, 165, 173, 77, 104, 85, 238, 170, 228, 124, 40, 132, 187, 242, 82])), SecretKey(Scalar([17, 128, 9, 123, 180, 183, 93, 73, 154, 11, 162, 11, 102, 244, 138, 120, 24, 186, 178, 179, 65, 108, 10, 148, 88, 142, 208, 177, 189, 15, 70, 2])));
/// YE("gdye"): gdye1xrcy66y7n0jdcfttqpwjmnprjqth7eyavgweumd8xatuht89m8eeszch7l2
static immutable YE = KeyPair(PublicKey(Point([240, 77, 104, 158, 155, 228, 220, 37, 107, 0, 93, 45, 204, 35, 144, 23, 127, 100, 157, 98, 29, 158, 109, 167, 55, 87, 203, 172, 229, 217, 243, 152])), SecretKey(Scalar([254, 161, 135, 99, 165, 163, 20, 67, 240, 101, 133, 48, 86, 102, 112, 126, 81, 222, 73, 8, 67, 147, 164, 54, 57, 72, 221, 136, 40, 107, 86, 7])));
/// YF("gdyf"): gdyf1xrc966f5sfn5ehth9mtukgp5ekkyucfktaaafv5ec6hvnzqaraezcaxt239
static immutable YF = KeyPair(PublicKey(Point([240, 93, 105, 52, 130, 103, 76, 221, 119, 46, 215, 203, 32, 52, 205, 172, 78, 97, 54, 95, 123, 212, 178, 153, 198, 174, 201, 136, 29, 31, 114, 44])), SecretKey(Scalar([9, 159, 134, 215, 12, 71, 197, 172, 221, 112, 231, 66, 211, 63, 48, 16, 140, 192, 189, 159, 73, 142, 210, 86, 108, 162, 49, 217, 237, 58, 199, 14])));
/// YG("gdyg"): gdyg1xrcx66hm2c3jxm0k5lxaxyh6ddem0g6lnjjzgsywyyzq7kt29lzxg6z7jd4
static immutable YG = KeyPair(PublicKey(Point([240, 109, 106, 251, 86, 35, 35, 109, 246, 167, 205, 211, 18, 250, 107, 115, 183, 163, 95, 156, 164, 36, 64, 142, 33, 4, 15, 89, 106, 47, 196, 100])), SecretKey(Scalar([42, 201, 40, 110, 96, 118, 250, 20, 187, 213, 191, 44, 38, 41, 69, 95, 11, 124, 221, 91, 128, 156, 163, 70, 4, 12, 127, 20, 76, 118, 176, 9])));
/// YH("gdyh"): gdyh1xrc866v6e3yhu6wk2hl9d8uhvdljf04nsg08cjcckjxv3a7k55985tux9sw
static immutable YH = KeyPair(PublicKey(Point([240, 125, 105, 154, 204, 73, 126, 105, 214, 85, 254, 86, 159, 151, 99, 127, 36, 190, 179, 130, 30, 124, 75, 24, 180, 140, 200, 247, 214, 165, 10, 122])), SecretKey(Scalar([73, 161, 194, 31, 166, 53, 88, 42, 203, 246, 188, 215, 154, 54, 6, 129, 216, 153, 22, 206, 63, 50, 246, 124, 125, 220, 15, 67, 93, 67, 114, 7])));
/// YI("gdyi"): gdyi1xrcg66fwe099rx23jzy260mr5p6ey5z74taas8dpknyzg30ydh98jgpk2ej
static immutable YI = KeyPair(PublicKey(Point([240, 141, 105, 46, 203, 202, 81, 153, 81, 144, 136, 173, 63, 99, 160, 117, 146, 80, 94, 170, 251, 216, 29, 161, 180, 200, 36, 69, 228, 109, 202, 121])), SecretKey(Scalar([61, 4, 247, 25, 70, 146, 191, 149, 198, 77, 196, 190, 246, 218, 70, 73, 160, 19, 82, 229, 19, 110, 203, 246, 30, 81, 196, 129, 247, 75, 86, 9])));
/// YJ("gdyj"): gdyj1xrcf66rqmha4gh0geslfgk6zxjqrcl3mwu6f5s8dzapp62hswxjzjx8y9nr
static immutable YJ = KeyPair(PublicKey(Point([240, 157, 104, 96, 221, 251, 84, 93, 232, 204, 62, 148, 91, 66, 52, 128, 60, 126, 59, 119, 52, 154, 64, 237, 23, 66, 29, 42, 240, 113, 164, 41])), SecretKey(Scalar([39, 168, 177, 21, 52, 6, 196, 74, 202, 193, 96, 182, 99, 120, 180, 190, 158, 86, 217, 191, 70, 212, 102, 144, 60, 249, 29, 147, 152, 0, 179, 0])));
/// YK("gdyk"): gdyk1xrc2668qsxhwuqagahk4e4lvtu9dj4dmyp7px5f2tvvmqvtvamf3w2dpxtz
static immutable YK = KeyPair(PublicKey(Point([240, 173, 104, 224, 129, 174, 238, 3, 168, 237, 237, 92, 215, 236, 95, 10, 217, 85, 187, 32, 124, 19, 81, 42, 91, 25, 176, 49, 108, 238, 211, 23])), SecretKey(Scalar([88, 67, 188, 114, 79, 61, 32, 68, 32, 11, 196, 18, 203, 146, 104, 127, 157, 240, 3, 196, 241, 213, 238, 37, 103, 157, 217, 204, 223, 91, 176, 2])));
/// YL("gdyl"): gdyl1xrct66npvhck8aph344df7j967qats60n03yf0v4tn0x3pe2yfgh79jt9zy
static immutable YL = KeyPair(PublicKey(Point([240, 189, 106, 97, 101, 241, 99, 244, 55, 141, 106, 212, 250, 69, 215, 129, 213, 195, 79, 155, 226, 68, 189, 149, 92, 222, 104, 135, 42, 34, 81, 127])), SecretKey(Scalar([152, 212, 112, 137, 114, 217, 203, 115, 83, 97, 134, 88, 177, 233, 229, 187, 44, 122, 203, 168, 96, 82, 72, 160, 174, 71, 76, 220, 183, 125, 146, 14])));
/// YM("gdym"): gdym1xrcv663fn5dvrwgetdyrsszay00s3xhdz867fa98hf5kgptyvlnawpn33ue
static immutable YM = KeyPair(PublicKey(Point([240, 205, 106, 41, 157, 26, 193, 185, 25, 91, 72, 56, 64, 93, 35, 223, 8, 154, 237, 17, 245, 228, 244, 167, 186, 105, 100, 5, 100, 103, 231, 215])), SecretKey(Scalar([216, 94, 49, 64, 158, 47, 55, 16, 54, 45, 9, 163, 230, 211, 213, 98, 162, 193, 219, 77, 241, 18, 74, 240, 197, 125, 43, 245, 77, 170, 82, 8])));
/// YN("gdyn"): gdyn1xrcd6683s92906qx8t8qw4he6g2p5ms6ftx3efn4vve63akd0nravky0wda
static immutable YN = KeyPair(PublicKey(Point([240, 221, 104, 241, 129, 84, 87, 232, 6, 58, 206, 7, 86, 249, 210, 20, 26, 110, 26, 74, 205, 28, 166, 117, 99, 51, 168, 246, 205, 124, 199, 214])), SecretKey(Scalar([22, 157, 89, 107, 164, 72, 202, 238, 130, 95, 39, 199, 44, 40, 41, 158, 198, 196, 14, 20, 144, 28, 32, 31, 87, 84, 128, 30, 63, 242, 47, 9])));
/// YO("gdyo"): gdyo1xrcw6670se2jfk0vlwpjd8vpp9vlu7cq7qrhnwpsqdrdwzrfa33zspafl2h
static immutable YO = KeyPair(PublicKey(Point([240, 237, 107, 207, 134, 85, 36, 217, 236, 251, 131, 38, 157, 129, 9, 89, 254, 123, 0, 240, 7, 121, 184, 48, 3, 70, 215, 8, 105, 236, 98, 40])), SecretKey(Scalar([140, 40, 226, 8, 14, 190, 104, 102, 72, 228, 174, 70, 81, 238, 89, 102, 86, 230, 41, 48, 29, 89, 60, 60, 228, 82, 151, 137, 163, 71, 95, 13])));
/// YP("gdyp"): gdyp1xrc066mf5xcfg2ek0wnp0ee8an84z9fjrfyvp2hyzj3lwu3pdmarj8vqzlk
static immutable YP = KeyPair(PublicKey(Point([240, 253, 107, 105, 161, 176, 148, 43, 54, 123, 166, 23, 231, 39, 236, 207, 81, 21, 50, 26, 72, 192, 170, 228, 20, 163, 247, 114, 33, 110, 250, 57])), SecretKey(Scalar([177, 120, 191, 98, 247, 59, 78, 210, 69, 175, 28, 21, 102, 181, 191, 75, 25, 222, 5, 35, 48, 4, 222, 20, 199, 179, 136, 1, 26, 112, 176, 5])));
/// YQ("gdyq"): gdyq1xrcs662077xlx9fsrfuvsmucgc9y8tjrmwrqzwhymu74s5jurgd57we7tz7
static immutable YQ = KeyPair(PublicKey(Point([241, 13, 105, 79, 247, 141, 243, 21, 48, 26, 120, 200, 111, 152, 70, 10, 67, 174, 67, 219, 134, 1, 58, 228, 223, 61, 88, 82, 92, 26, 27, 79])), SecretKey(Scalar([246, 64, 88, 117, 253, 239, 61, 139, 238, 122, 129, 80, 238, 153, 135, 45, 55, 55, 239, 62, 19, 137, 37, 202, 147, 167, 196, 77, 235, 49, 40, 6])));
/// YR("gdyr"): gdyr1xrc366ay2jdkle9r0yyzxl4t4xk8s3x955d09z36qudsrgtnfu0a2xefmda
static immutable YR = KeyPair(PublicKey(Point([241, 29, 107, 164, 84, 155, 111, 228, 163, 121, 8, 35, 126, 171, 169, 172, 120, 68, 197, 165, 26, 242, 138, 58, 7, 27, 1, 161, 115, 79, 31, 213])), SecretKey(Scalar([246, 245, 247, 85, 134, 229, 60, 176, 37, 27, 178, 229, 173, 78, 52, 156, 135, 252, 223, 31, 61, 215, 32, 10, 159, 182, 45, 76, 78, 112, 100, 10])));
/// YS("gdys"): gdys1xrcj662wegyasxnv05wnr2muxyfwjgkrmh8m0lg9jnu4y9c7un6nsc9h9p0
static immutable YS = KeyPair(PublicKey(Point([241, 45, 105, 78, 202, 9, 216, 26, 108, 125, 29, 49, 171, 124, 49, 18, 233, 34, 195, 221, 207, 183, 253, 5, 148, 249, 82, 23, 30, 228, 245, 56])), SecretKey(Scalar([40, 210, 230, 56, 120, 79, 118, 73, 229, 8, 163, 100, 55, 120, 236, 162, 89, 82, 161, 56, 70, 140, 37, 241, 183, 39, 224, 47, 250, 93, 236, 0])));
/// YT("gdyt"): gdyt1xrcn66c8qj0m87w3h4v3vp73tv89kls9kjxjxlhspflrg3jad3nfssgs9qz
static immutable YT = KeyPair(PublicKey(Point([241, 61, 107, 7, 4, 159, 179, 249, 209, 189, 89, 22, 7, 209, 91, 14, 91, 126, 5, 180, 141, 35, 126, 240, 10, 126, 52, 70, 93, 108, 102, 152])), SecretKey(Scalar([162, 197, 44, 125, 204, 154, 212, 99, 235, 30, 37, 92, 16, 148, 77, 30, 191, 63, 42, 175, 243, 120, 167, 148, 109, 164, 85, 129, 176, 168, 100, 10])));
/// YU("gdyu"): gdyu1xrc566uh8hq5gesu7x6sgttrwfm9gna4s3hdfv53gcyuyslsgxzegz5pjtm
static immutable YU = KeyPair(PublicKey(Point([241, 77, 107, 151, 61, 193, 68, 102, 28, 241, 181, 4, 45, 99, 114, 118, 84, 79, 181, 132, 110, 212, 178, 145, 70, 9, 194, 67, 240, 65, 133, 148])), SecretKey(Scalar([209, 229, 224, 118, 106, 50, 130, 60, 59, 130, 234, 96, 64, 120, 11, 126, 151, 116, 29, 224, 86, 100, 234, 175, 202, 179, 70, 16, 6, 226, 242, 15])));
/// YV("gdyv"): gdyv1xrc466rtxdp373hp4qycjxpplvadamw0kfh2ducym22rcn3hvkujq9daq0u
static immutable YV = KeyPair(PublicKey(Point([241, 93, 104, 107, 51, 67, 31, 70, 225, 168, 9, 137, 24, 33, 251, 58, 222, 237, 207, 178, 110, 166, 243, 4, 218, 148, 60, 78, 55, 101, 185, 32])), SecretKey(Scalar([50, 201, 186, 116, 186, 81, 81, 37, 218, 249, 103, 136, 97, 136, 245, 34, 153, 43, 221, 128, 132, 188, 224, 195, 125, 98, 78, 89, 147, 105, 205, 3])));
/// YW("gdyw"): gdyw1xrck66p44fqqp8z8gy3jua5pnx7pwu9637y0pg9e2hufzl2yrvtmknxr3h3
static immutable YW = KeyPair(PublicKey(Point([241, 109, 104, 53, 170, 64, 0, 156, 71, 65, 35, 46, 118, 129, 153, 188, 23, 112, 186, 143, 136, 240, 160, 185, 85, 248, 145, 125, 68, 27, 23, 187])), SecretKey(Scalar([221, 61, 65, 81, 97, 139, 8, 250, 241, 216, 62, 11, 105, 1, 146, 247, 88, 15, 166, 237, 165, 139, 124, 107, 113, 31, 213, 103, 30, 100, 242, 6])));
/// YX("gdyx"): gdyx1xrch66zt9mrwsxe293a9p0fgrzgac6r88npnp3cy4plchjutjzgvqse4e5r
static immutable YX = KeyPair(PublicKey(Point([241, 125, 104, 75, 46, 198, 232, 27, 42, 44, 122, 80, 189, 40, 24, 145, 220, 104, 103, 60, 195, 48, 199, 4, 168, 127, 139, 203, 139, 144, 144, 192])), SecretKey(Scalar([223, 55, 175, 191, 218, 139, 62, 195, 107, 237, 94, 246, 106, 72, 50, 74, 183, 153, 218, 125, 235, 136, 211, 68, 53, 163, 53, 249, 236, 208, 204, 4])));
/// YY("gdyy"): gdyy1xrcc66de9d83az9ssjdef63zjxvuya86dkhsnwjk2fcxqvnzc02rcf5w0p8
static immutable YY = KeyPair(PublicKey(Point([241, 141, 105, 185, 43, 79, 30, 136, 176, 132, 155, 148, 234, 34, 145, 153, 194, 116, 250, 109, 175, 9, 186, 86, 82, 112, 96, 50, 98, 195, 212, 60])), SecretKey(Scalar([37, 112, 40, 38, 107, 72, 133, 73, 14, 136, 126, 245, 81, 177, 237, 41, 131, 173, 212, 119, 29, 21, 114, 62, 141, 63, 146, 25, 213, 143, 238, 3])));
/// YZ("gdyz"): gdyz1xrce66yya5va59esyxt6p38dfmx22sm3057lrx8mhhn8snzdlv2fs5a2hrm
static immutable YZ = KeyPair(PublicKey(Point([241, 157, 104, 132, 237, 25, 218, 23, 48, 33, 151, 160, 196, 237, 78, 204, 165, 67, 113, 125, 61, 241, 152, 251, 189, 230, 120, 76, 77, 251, 20, 152])), SecretKey(Scalar([2, 109, 246, 122, 3, 59, 1, 56, 74, 200, 84, 235, 89, 136, 219, 145, 70, 67, 54, 204, 70, 82, 113, 9, 238, 207, 176, 43, 25, 128, 160, 6])));
/// ZA("gdza"): gdza1xreq6667gg733ycejx6hqxh6w5fyayap5jervy5fve7aap9v3sch70tj4zl
static immutable ZA = KeyPair(PublicKey(Point([242, 13, 107, 94, 66, 61, 24, 147, 25, 145, 181, 112, 26, 250, 117, 18, 78, 147, 161, 164, 178, 54, 18, 137, 102, 125, 222, 132, 172, 140, 49, 127])), SecretKey(Scalar([80, 252, 122, 162, 228, 117, 168, 162, 212, 190, 134, 3, 116, 41, 23, 184, 72, 166, 85, 82, 211, 192, 171, 196, 223, 94, 152, 178, 96, 98, 68, 1])));
/// ZB("gdzb"): gdzb1xrep66jwyru4uw2eqa7d65dkrf6us56v4r6xqfpqvz33sw3eyqev2u2aueq
static immutable ZB = KeyPair(PublicKey(Point([242, 29, 106, 78, 32, 249, 94, 57, 89, 7, 124, 221, 81, 182, 26, 117, 200, 83, 76, 168, 244, 96, 36, 32, 96, 163, 24, 58, 57, 32, 50, 197])), SecretKey(Scalar([19, 125, 147, 197, 94, 180, 164, 40, 214, 43, 227, 66, 63, 245, 225, 240, 215, 183, 238, 237, 141, 115, 75, 236, 99, 197, 163, 90, 36, 207, 154, 10])));
/// ZC("gdzc"): gdzc1xrez66pjsnm2nk9zw75gnntj7x5p07ddnukp4swnyglyartjammf7wlhrxh
static immutable ZC = KeyPair(PublicKey(Point([242, 45, 104, 50, 132, 246, 169, 216, 162, 119, 168, 137, 205, 114, 241, 168, 23, 249, 173, 159, 44, 26, 193, 211, 34, 62, 78, 141, 114, 238, 246, 159])), SecretKey(Scalar([145, 40, 64, 20, 71, 194, 163, 74, 67, 216, 150, 128, 112, 66, 58, 88, 196, 119, 251, 100, 70, 97, 113, 179, 168, 154, 140, 31, 124, 169, 42, 10])));
/// ZD("gdzd"): gdzd1xrer66t2cstqt94l4r463twrf8vvjt6dsy935kh655d0l3gkxxg0vc6sd8l
static immutable ZD = KeyPair(PublicKey(Point([242, 61, 105, 106, 196, 22, 5, 150, 191, 168, 235, 168, 173, 195, 73, 216, 201, 47, 77, 129, 11, 26, 90, 250, 165, 26, 255, 197, 22, 49, 144, 246])), SecretKey(Scalar([98, 131, 201, 107, 50, 98, 187, 120, 99, 227, 216, 155, 40, 209, 43, 203, 205, 28, 54, 14, 137, 57, 16, 152, 80, 151, 177, 115, 148, 97, 113, 11])));
/// ZE("gdze"): gdze1xrey668pq5csl27muzczqqs3nzxycqddsxnjych3l8h0vfv0fvuajj4tchm
static immutable ZE = KeyPair(PublicKey(Point([242, 77, 104, 225, 5, 49, 15, 171, 219, 224, 176, 32, 2, 17, 152, 140, 76, 1, 173, 129, 167, 34, 98, 241, 249, 238, 246, 37, 143, 75, 57, 217])), SecretKey(Scalar([60, 214, 250, 101, 155, 84, 154, 146, 14, 36, 199, 194, 56, 33, 219, 140, 223, 101, 10, 159, 87, 81, 53, 22, 177, 188, 186, 92, 1, 227, 83, 5])));
/// ZF("gdzf"): gdzf1xre966230995n5xuekfj2qqhz96jqwzkmpsgkgfrj84fhfcgxxt7gynqwjf
static immutable ZF = KeyPair(PublicKey(Point([242, 93, 105, 81, 121, 75, 73, 208, 220, 205, 147, 37, 0, 23, 17, 117, 32, 56, 86, 216, 96, 139, 33, 35, 145, 234, 155, 167, 8, 49, 151, 228])), SecretKey(Scalar([78, 233, 14, 0, 243, 138, 122, 230, 197, 82, 17, 44, 122, 77, 248, 140, 14, 135, 218, 134, 191, 240, 118, 231, 152, 61, 200, 238, 35, 102, 105, 9])));
/// ZG("gdzg"): gdzg1xrex66f549gafgmc5zcfkcd4unmscmvglzmy0lk49zhnhkam8uxcylcqrc7
static immutable ZG = KeyPair(PublicKey(Point([242, 109, 105, 52, 169, 81, 212, 163, 120, 160, 176, 155, 97, 181, 228, 247, 12, 109, 136, 248, 182, 71, 254, 213, 40, 175, 59, 219, 187, 63, 13, 130])), SecretKey(Scalar([6, 112, 4, 171, 132, 209, 14, 89, 105, 204, 114, 236, 162, 147, 240, 99, 23, 61, 5, 10, 113, 132, 222, 159, 10, 84, 107, 169, 3, 63, 164, 11])));
/// ZH("gdzh"): gdzh1xre8663kd73mp7h2jcyatgaxraujrqfky59c0nl5m3rrye8ygeqpwscvzl6
static immutable ZH = KeyPair(PublicKey(Point([242, 125, 106, 54, 111, 163, 176, 250, 234, 150, 9, 213, 163, 166, 31, 121, 33, 129, 54, 37, 11, 135, 207, 244, 220, 70, 50, 100, 228, 70, 64, 23])), SecretKey(Scalar([114, 167, 202, 215, 175, 130, 148, 95, 85, 24, 175, 139, 77, 55, 210, 138, 30, 231, 105, 48, 129, 136, 60, 19, 233, 72, 30, 85, 36, 161, 136, 0])));
/// ZI("gdzi"): gdzi1xreg66846uc74qdzuyn2y2e7fgvr0a9avkkpwz8j24z08hwahevcqspgrdc
static immutable ZI = KeyPair(PublicKey(Point([242, 141, 104, 245, 215, 49, 234, 129, 162, 225, 38, 162, 43, 62, 74, 24, 55, 244, 189, 101, 172, 23, 8, 242, 85, 68, 243, 221, 221, 190, 89, 128])), SecretKey(Scalar([9, 213, 211, 4, 6, 136, 57, 35, 50, 200, 153, 16, 68, 153, 217, 76, 1, 222, 128, 51, 182, 100, 140, 59, 65, 159, 234, 101, 27, 209, 83, 1])));
/// ZJ("gdzj"): gdzj1xref66wvnp44vwpuz2hlujrcrjy8jtagvdllwgwuyc9lf4u2mr7067qgsj5
static immutable ZJ = KeyPair(PublicKey(Point([242, 157, 105, 204, 152, 107, 86, 56, 60, 18, 175, 254, 72, 120, 28, 136, 121, 47, 168, 99, 127, 247, 33, 220, 38, 11, 244, 215, 138, 216, 252, 253])), SecretKey(Scalar([163, 169, 222, 95, 51, 120, 202, 116, 225, 253, 180, 69, 253, 66, 75, 214, 222, 88, 98, 106, 162, 45, 194, 106, 220, 83, 133, 109, 106, 207, 133, 6])));
/// ZK("gdzk"): gdzk1xre266dt6lnetla95l82k6eg0ff3jxqel3mldq36dtx22lsxv54czh4dtxd
static immutable ZK = KeyPair(PublicKey(Point([242, 173, 105, 171, 215, 231, 149, 255, 165, 167, 206, 171, 107, 40, 122, 83, 25, 24, 25, 252, 119, 246, 130, 58, 106, 204, 165, 126, 6, 101, 43, 129])), SecretKey(Scalar([69, 228, 120, 114, 10, 33, 131, 253, 83, 40, 93, 225, 85, 75, 212, 118, 145, 176, 93, 46, 171, 59, 97, 202, 113, 158, 133, 67, 208, 91, 114, 11])));
/// ZL("gdzl"): gdzl1xret66j7gz2qm2faawxjuj59j4zmnauwjenuedzw7srfznj69sg86r53z4f
static immutable ZL = KeyPair(PublicKey(Point([242, 189, 106, 94, 64, 148, 13, 169, 61, 235, 141, 46, 74, 133, 149, 69, 185, 247, 142, 150, 103, 204, 180, 78, 244, 6, 145, 78, 90, 44, 16, 125])), SecretKey(Scalar([80, 113, 205, 156, 175, 52, 30, 94, 221, 58, 242, 19, 229, 170, 159, 45, 168, 29, 69, 128, 240, 144, 19, 191, 22, 5, 84, 71, 46, 51, 215, 1])));
/// ZM("gdzm"): gdzm1xrev66pq6wm4v4u5cfw7uwd57hsyysj2l5acpjj293gqt8yeju8cyxuvynu
static immutable ZM = KeyPair(PublicKey(Point([242, 205, 104, 32, 211, 183, 86, 87, 148, 194, 93, 238, 57, 180, 245, 224, 66, 66, 74, 253, 59, 128, 202, 74, 44, 80, 5, 156, 153, 151, 15, 130])), SecretKey(Scalar([111, 147, 229, 234, 75, 206, 33, 174, 32, 63, 209, 206, 109, 145, 81, 92, 19, 1, 79, 2, 32, 114, 134, 110, 133, 99, 71, 80, 156, 241, 114, 10])));
/// ZN("gdzn"): gdzn1xred6635c6felz03nfm7sm9qaef7wtszev7q0rak345l45j243pdkd5p3eu
static immutable ZN = KeyPair(PublicKey(Point([242, 221, 106, 52, 198, 147, 159, 137, 241, 154, 119, 232, 108, 160, 238, 83, 231, 46, 2, 203, 60, 7, 143, 182, 141, 105, 250, 210, 74, 172, 66, 219])), SecretKey(Scalar([139, 149, 30, 199, 14, 176, 222, 225, 236, 99, 124, 50, 242, 115, 41, 117, 19, 193, 99, 102, 153, 188, 42, 151, 199, 73, 35, 205, 233, 76, 87, 12])));
/// ZO("gdzo"): gdzo1xrew66gfvc7fk7kr7ar856r7et7y7aa9xu7c6vhe04trspw95r0ru9p40py
static immutable ZO = KeyPair(PublicKey(Point([242, 237, 105, 9, 102, 60, 155, 122, 195, 247, 70, 122, 104, 126, 202, 252, 79, 119, 165, 55, 61, 141, 50, 249, 125, 86, 56, 5, 197, 160, 222, 62])), SecretKey(Scalar([235, 21, 61, 250, 245, 253, 219, 56, 82, 184, 114, 197, 224, 231, 73, 110, 92, 31, 209, 138, 142, 36, 74, 131, 227, 117, 30, 58, 148, 241, 194, 9])));
/// ZP("gdzp"): gdzp1xre066aymkv2epqgff567ppqp7wdkg6fz46rhtktuvgc56nvq72hqkqwc55
static immutable ZP = KeyPair(PublicKey(Point([242, 253, 107, 164, 221, 152, 172, 132, 8, 74, 105, 175, 4, 32, 15, 156, 219, 35, 73, 21, 116, 59, 174, 203, 227, 17, 138, 106, 108, 7, 149, 112])), SecretKey(Scalar([140, 32, 239, 227, 61, 179, 231, 219, 182, 223, 164, 200, 160, 58, 16, 3, 133, 226, 107, 114, 235, 149, 211, 82, 216, 101, 109, 155, 217, 128, 168, 6])));
/// ZQ("gdzq"): gdzq1xres66tu0xmxm409s20g4u420l6075anl8kahgt7m5cg6q6s06zsw30gmmy
static immutable ZQ = KeyPair(PublicKey(Point([243, 13, 105, 124, 121, 182, 109, 213, 229, 130, 158, 138, 242, 170, 127, 244, 255, 83, 179, 249, 237, 219, 161, 126, 221, 48, 141, 3, 80, 126, 133, 7])), SecretKey(Scalar([102, 134, 71, 188, 8, 95, 240, 167, 134, 140, 13, 109, 152, 68, 95, 47, 125, 38, 185, 75, 148, 115, 84, 162, 31, 237, 22, 229, 93, 251, 128, 10])));
/// ZR("gdzr"): gdzr1xre366r0tecj83l4463ue7wxekpyuujszfz7rwv9pw0xs5u8n3x6wxv9f2u
static immutable ZR = KeyPair(PublicKey(Point([243, 29, 104, 111, 94, 113, 35, 199, 245, 174, 163, 204, 249, 198, 205, 130, 78, 114, 80, 18, 69, 225, 185, 133, 11, 158, 104, 83, 135, 156, 77, 167])), SecretKey(Scalar([63, 115, 240, 121, 65, 166, 139, 156, 38, 140, 248, 48, 127, 152, 44, 34, 45, 50, 173, 12, 233, 103, 91, 104, 230, 225, 117, 74, 168, 170, 246, 10])));
/// ZS("gdzs"): gdzs1xrej66883ktaeyhwxzknqekmsd34ndcyk7fdyrjw3e9z8p5z6a70s900y8t
static immutable ZS = KeyPair(PublicKey(Point([243, 45, 104, 231, 141, 151, 220, 146, 238, 48, 173, 48, 102, 219, 131, 99, 89, 183, 4, 183, 146, 210, 14, 78, 142, 74, 35, 134, 130, 215, 124, 248])), SecretKey(Scalar([218, 3, 255, 81, 49, 193, 224, 101, 219, 73, 12, 157, 49, 155, 171, 254, 171, 113, 176, 112, 236, 30, 70, 93, 86, 128, 154, 45, 220, 67, 129, 8])));
/// ZT("gdzt"): gdzt1xren66l42s6qpa03k9kcsxy3zm9ny6stfswhmc7tutc3zrk5eu6xgadyxet
static immutable ZT = KeyPair(PublicKey(Point([243, 61, 107, 245, 84, 52, 0, 245, 241, 177, 109, 136, 24, 145, 22, 203, 50, 106, 11, 76, 29, 125, 227, 203, 226, 241, 17, 14, 212, 207, 52, 100])), SecretKey(Scalar([120, 77, 120, 229, 245, 164, 142, 17, 91, 96, 14, 191, 101, 231, 17, 1, 199, 218, 163, 120, 246, 115, 217, 94, 130, 72, 120, 205, 148, 116, 65, 0])));
/// ZU("gdzu"): gdzu1xre566xqvwktycfezjmr6fup0vnw8zhj0havtp05uwy26mznhmpexs7p39j
static immutable ZU = KeyPair(PublicKey(Point([243, 77, 104, 192, 99, 172, 178, 97, 57, 20, 182, 61, 39, 129, 123, 38, 227, 138, 242, 125, 250, 197, 133, 244, 227, 136, 173, 108, 83, 190, 195, 147])), SecretKey(Scalar([58, 213, 74, 102, 90, 246, 216, 80, 103, 121, 98, 18, 68, 218, 23, 21, 173, 122, 229, 210, 98, 69, 101, 59, 42, 249, 153, 103, 51, 196, 131, 9])));
/// ZV("gdzv"): gdzv1xre466zv608qca7ql3z284zjf4y9d49jlqadyjw9shwglpfdzqxpv7znrw4
static immutable ZV = KeyPair(PublicKey(Point([243, 93, 104, 76, 211, 206, 12, 119, 192, 252, 68, 163, 212, 82, 77, 72, 86, 212, 178, 248, 58, 210, 73, 197, 133, 220, 143, 133, 45, 16, 12, 22])), SecretKey(Scalar([79, 223, 138, 193, 238, 171, 38, 155, 148, 87, 211, 42, 93, 90, 240, 235, 65, 89, 173, 19, 31, 156, 144, 150, 87, 217, 134, 182, 39, 11, 134, 1])));
/// ZW("gdzw"): gdzw1xrek664757hxa35d2zltcja7q003x6z4s0t7pj6nmpkrsu87ty2wsx6x8lg
static immutable ZW = KeyPair(PublicKey(Point([243, 109, 106, 190, 167, 174, 110, 198, 141, 80, 190, 188, 75, 190, 3, 223, 19, 104, 85, 131, 215, 224, 203, 83, 216, 108, 56, 112, 254, 89, 20, 232])), SecretKey(Scalar([59, 131, 121, 231, 19, 212, 69, 77, 208, 106, 180, 31, 66, 255, 242, 236, 170, 144, 97, 100, 170, 67, 183, 82, 69, 199, 33, 197, 64, 88, 231, 0])));
/// ZX("gdzx"): gdzx1xreh668d7lv9l8fj37w7vu6ejs8aj640cwpzedczn525wl7t0ytv6v4dhjk
static immutable ZX = KeyPair(PublicKey(Point([243, 125, 104, 237, 247, 216, 95, 157, 50, 143, 157, 230, 115, 89, 148, 15, 217, 106, 175, 195, 130, 44, 183, 2, 157, 21, 71, 127, 203, 121, 22, 205])), SecretKey(Scalar([135, 251, 157, 128, 37, 99, 190, 237, 166, 167, 222, 64, 249, 205, 177, 193, 252, 150, 113, 176, 139, 229, 94, 239, 21, 125, 33, 165, 88, 88, 5, 13])));
/// ZY("gdzy"): gdzy1xrec66jdv7du75s56fyu33q0cq9y965ef5g6y060krdmmuwm7wxdzpvrjya
static immutable ZY = KeyPair(PublicKey(Point([243, 141, 106, 77, 103, 155, 207, 82, 20, 210, 73, 200, 196, 15, 192, 10, 66, 234, 153, 77, 17, 162, 63, 79, 176, 219, 189, 241, 219, 243, 140, 209])), SecretKey(Scalar([160, 205, 88, 105, 254, 5, 188, 0, 59, 191, 95, 9, 64, 56, 167, 17, 189, 103, 233, 85, 237, 55, 48, 215, 244, 228, 27, 161, 208, 78, 212, 13])));
/// ZZ("gdzz"): gdzz1xree66lvd8gcn8hv3csxs9x8xxd20s2dt9f5qtkceey7nxhjl4h6v084n7s
static immutable ZZ = KeyPair(PublicKey(Point([243, 157, 107, 236, 105, 209, 137, 158, 236, 142, 32, 104, 20, 199, 49, 154, 167, 193, 77, 89, 83, 64, 46, 216, 206, 73, 233, 154, 242, 253, 111, 166])), SecretKey(Scalar([202, 156, 189, 234, 27, 106, 118, 83, 38, 229, 109, 49, 218, 98, 122, 42, 23, 225, 113, 254, 60, 143, 199, 235, 235, 180, 88, 29, 51, 117, 224, 4])));
/// AAA("gdaaa"): gdaaa1xrqqq66w0fsn2nwuy09vhjs4h7tnfgch4r669csf4qxc9fct050vjxs6a6c
static immutable AAA = KeyPair(PublicKey(Point([192, 0, 107, 78, 122, 97, 53, 77, 220, 35, 202, 203, 202, 21, 191, 151, 52, 163, 23, 168, 245, 162, 226, 9, 168, 13, 130, 167, 11, 125, 30, 201])), SecretKey(Scalar([77, 26, 181, 210, 175, 94, 169, 104, 172, 205, 198, 210, 170, 180, 225, 76, 110, 32, 29, 78, 143, 203, 83, 223, 40, 243, 95, 125, 44, 240, 36, 4])));
/// AAB("gdaab"): gdaab1xrqqp66h8xgm2gc7k907m65jx80hukzddnu730mk8gh4f5vfds2huhaqt90
static immutable AAB = KeyPair(PublicKey(Point([192, 0, 235, 87, 57, 145, 181, 35, 30, 177, 95, 237, 234, 146, 49, 223, 126, 88, 77, 108, 249, 232, 191, 118, 58, 47, 84, 209, 137, 108, 21, 126])), SecretKey(Scalar([156, 12, 134, 174, 37, 241, 146, 45, 241, 159, 229, 252, 90, 194, 26, 248, 202, 204, 119, 41, 221, 123, 83, 196, 230, 190, 111, 219, 2, 150, 69, 7])));
/// AAC("gdaac"): gdaac1xrqqz668g0sudapw3uspkqlvehs3q7mqxwxmapjkzhdlwe7gpqg87hlmwxy
static immutable AAC = KeyPair(PublicKey(Point([192, 1, 107, 71, 67, 225, 198, 244, 46, 143, 32, 27, 3, 236, 205, 225, 16, 123, 96, 51, 141, 190, 134, 86, 21, 219, 247, 103, 200, 8, 16, 127])), SecretKey(Scalar([141, 196, 27, 227, 168, 160, 201, 203, 203, 132, 102, 38, 126, 150, 205, 224, 159, 68, 49, 200, 64, 39, 246, 38, 66, 62, 123, 19, 147, 11, 102, 12])));
/// AAD("gdaad"): gdaad1xrqqr66ut7s47xu38m6ydv3r5rh0777l9yk7vjdn7lcpgsuyxf60qvzdsfs
static immutable AAD = KeyPair(PublicKey(Point([192, 1, 235, 92, 95, 161, 95, 27, 145, 62, 244, 70, 178, 35, 160, 238, 255, 123, 223, 41, 45, 230, 73, 179, 247, 240, 20, 67, 132, 50, 116, 240])), SecretKey(Scalar([180, 202, 85, 217, 206, 4, 202, 255, 172, 203, 161, 214, 38, 85, 134, 39, 104, 232, 197, 14, 236, 214, 41, 189, 140, 10, 177, 251, 66, 30, 169, 8])));
/// AAE("gdaae"): gdaae1xrqqy66hnr7yppkrjmjn09u3w7s9zyclltjj5jtup4dkmczc8s55kcnshvh
static immutable AAE = KeyPair(PublicKey(Point([192, 2, 107, 87, 152, 252, 64, 134, 195, 150, 229, 55, 151, 145, 119, 160, 81, 19, 31, 250, 229, 42, 73, 124, 13, 91, 109, 224, 88, 60, 41, 75])), SecretKey(Scalar([232, 164, 190, 228, 209, 232, 176, 203, 87, 25, 123, 64, 117, 144, 51, 5, 246, 249, 61, 119, 80, 74, 43, 245, 166, 200, 130, 87, 163, 128, 56, 8])));
/// AAF("gdaaf"): gdaaf1xrqq966g6765umy0wpkattlqqug50d2qekq2ntntykxwa2scdwtlur60epd
static immutable AAF = KeyPair(PublicKey(Point([192, 2, 235, 72, 215, 181, 78, 108, 143, 112, 109, 213, 175, 224, 7, 17, 71, 181, 64, 205, 128, 169, 174, 107, 37, 140, 238, 170, 24, 107, 151, 254])), SecretKey(Scalar([241, 207, 67, 80, 121, 42, 206, 164, 245, 1, 88, 157, 2, 21, 156, 159, 55, 45, 174, 198, 95, 147, 228, 89, 208, 238, 179, 206, 179, 103, 76, 4])));
/// AAG("gdaag"): gdaag1xrqqx663yv4sy62gh7ycdh6hvddqlpuv8f9v8hxhk5tv7pfgd8k7ugd4j2m
static immutable AAG = KeyPair(PublicKey(Point([192, 3, 107, 81, 35, 43, 2, 105, 72, 191, 137, 134, 223, 87, 99, 90, 15, 135, 140, 58, 74, 195, 220, 215, 181, 22, 207, 5, 40, 105, 237, 238])), SecretKey(Scalar([117, 212, 29, 160, 110, 110, 1, 233, 35, 23, 62, 2, 241, 250, 179, 233, 55, 72, 179, 39, 170, 239, 27, 197, 9, 81, 161, 160, 218, 79, 107, 9])));
/// AAH("gdaah"): gdaah1xrqq866vhxkem2e4q422gf6mwm92tgv66fs9cm0r6cja839c3dw8gxh98hk
static immutable AAH = KeyPair(PublicKey(Point([192, 3, 235, 76, 185, 173, 157, 171, 53, 5, 84, 164, 39, 91, 118, 202, 165, 161, 154, 210, 96, 92, 109, 227, 214, 37, 211, 196, 184, 139, 92, 116])), SecretKey(Scalar([37, 14, 43, 77, 74, 229, 61, 219, 86, 70, 211, 122, 242, 126, 126, 15, 168, 129, 238, 214, 199, 19, 43, 142, 143, 150, 222, 191, 162, 165, 48, 3])));
/// AAI("gdaai"): gdaai1xrqqg664c48tpc7yrytyva4zlp492dpdlr90gu6e6m8y6m32g5k3j9h8qn0
static immutable AAI = KeyPair(PublicKey(Point([192, 4, 107, 85, 197, 78, 176, 227, 196, 25, 22, 70, 118, 162, 248, 106, 85, 52, 45, 248, 202, 244, 115, 89, 214, 206, 77, 110, 42, 69, 45, 25])), SecretKey(Scalar([177, 60, 177, 136, 195, 252, 66, 39, 143, 86, 10, 134, 96, 253, 172, 158, 250, 82, 164, 226, 63, 40, 148, 80, 46, 250, 144, 33, 18, 156, 81, 5])));
/// AAJ("gdaaj"): gdaaj1xrqqf66nk2n6dwuwf9xua35zz6kjj5p6lvudf2ca65xj7clufl3csd7ly43
static immutable AAJ = KeyPair(PublicKey(Point([192, 4, 235, 83, 178, 167, 166, 187, 142, 73, 77, 206, 198, 130, 22, 173, 41, 80, 58, 251, 56, 212, 171, 29, 213, 13, 47, 99, 252, 79, 227, 136])), SecretKey(Scalar([113, 86, 13, 13, 187, 199, 39, 11, 253, 28, 93, 216, 64, 244, 210, 94, 45, 218, 175, 157, 181, 31, 66, 130, 75, 213, 23, 102, 29, 218, 73, 14])));
/// AAK("gdaak"): gdaak1xrqq266mtdnf68armecwwt42pr7hryfkq7kq4pw3haly8zerzxfv59uy9gp
static immutable AAK = KeyPair(PublicKey(Point([192, 5, 107, 91, 91, 102, 157, 31, 163, 222, 112, 231, 46, 170, 8, 253, 113, 145, 54, 7, 172, 10, 133, 209, 191, 126, 67, 139, 35, 17, 146, 202])), SecretKey(Scalar([106, 174, 188, 92, 90, 157, 215, 22, 142, 246, 1, 140, 227, 19, 25, 135, 11, 31, 136, 79, 238, 77, 5, 83, 33, 124, 2, 94, 210, 183, 15, 4])));
/// AAL("gdaal"): gdaal1xrqqt66cxh5sw5nj3qpa2k0qxvq3rytusrauykvkc6zs60pa5puwjl0x6rt
static immutable AAL = KeyPair(PublicKey(Point([192, 5, 235, 88, 53, 233, 7, 82, 114, 136, 3, 213, 89, 224, 51, 1, 17, 145, 124, 128, 251, 194, 89, 150, 198, 133, 13, 60, 61, 160, 120, 233])), SecretKey(Scalar([164, 78, 73, 47, 90, 17, 226, 214, 103, 210, 173, 22, 194, 140, 5, 162, 233, 103, 109, 236, 27, 187, 88, 79, 53, 36, 102, 200, 157, 233, 21, 15])));
/// AAM("gdaam"): gdaam1xrqqv669s06m75v6c5568z2jmm4qzheky8x6xs28j8rcdxfy07xzklsycas
static immutable AAM = KeyPair(PublicKey(Point([192, 6, 107, 69, 131, 245, 191, 81, 154, 197, 41, 163, 137, 82, 222, 234, 1, 95, 54, 33, 205, 163, 65, 71, 145, 199, 134, 153, 36, 127, 140, 43])), SecretKey(Scalar([162, 34, 134, 65, 154, 44, 187, 21, 253, 222, 197, 153, 246, 65, 87, 200, 133, 220, 44, 214, 163, 133, 102, 175, 40, 29, 140, 64, 70, 187, 127, 9])));
/// AAN("gdaan"): gdaan1xrqqd66vtkmew2v2xvenjeuyu8jjxd9n8ajvtglla4jnd4cg56wjkgnr96q
static immutable AAN = KeyPair(PublicKey(Point([192, 6, 235, 76, 93, 183, 151, 41, 138, 51, 51, 57, 103, 132, 225, 229, 35, 52, 179, 63, 100, 197, 163, 255, 237, 101, 54, 215, 8, 166, 157, 43])), SecretKey(Scalar([56, 194, 31, 107, 33, 39, 12, 186, 149, 227, 100, 71, 233, 255, 87, 6, 33, 182, 102, 106, 181, 90, 68, 70, 110, 147, 102, 56, 175, 58, 41, 3])));
/// AAO("gdaao"): gdaao1xrqqw66vts4q3ca2p0t3vdyvyr5k4zwnpa65vhurjwzkswd4d5dwydzccjq
static immutable AAO = KeyPair(PublicKey(Point([192, 7, 107, 76, 92, 42, 8, 227, 170, 11, 215, 22, 52, 140, 32, 233, 106, 137, 211, 15, 117, 70, 95, 131, 147, 133, 104, 57, 181, 109, 26, 226])), SecretKey(Scalar([3, 66, 88, 249, 238, 127, 15, 46, 115, 110, 145, 141, 1, 64, 76, 189, 16, 29, 170, 21, 145, 46, 225, 54, 124, 11, 163, 59, 3, 76, 225, 2])));
/// AAP("gdaap"): gdaap1xrqq066hnv25wnd0d0fnkwkwwstmfxenxvlhy6we94e8pwjwcrlx7t3rq0n
static immutable AAP = KeyPair(PublicKey(Point([192, 7, 235, 87, 155, 21, 71, 77, 175, 107, 211, 59, 58, 206, 116, 23, 180, 155, 51, 51, 63, 114, 105, 217, 45, 114, 112, 186, 78, 192, 254, 111])), SecretKey(Scalar([60, 44, 144, 143, 176, 176, 183, 151, 70, 130, 35, 236, 26, 36, 186, 114, 44, 129, 40, 129, 198, 229, 246, 107, 128, 231, 57, 29, 120, 103, 14, 11])));
/// AAQ("gdaaq"): gdaaq1xrqqs66atd7f0y72x2mzqgdewzzkw43kh9lpesdq9qkgrdmxe2rx67yd24f
static immutable AAQ = KeyPair(PublicKey(Point([192, 8, 107, 93, 91, 124, 151, 147, 202, 50, 182, 32, 33, 185, 112, 133, 103, 86, 54, 185, 126, 28, 193, 160, 40, 44, 129, 183, 102, 202, 134, 109])), SecretKey(Scalar([117, 6, 234, 9, 108, 167, 192, 119, 64, 245, 216, 202, 76, 214, 160, 236, 201, 210, 215, 33, 104, 228, 50, 142, 190, 44, 98, 23, 7, 133, 174, 15])));
/// AAR("gdaar"): gdaar1xrqq366aywpdyasvgp2e3ljqg9e8vgfkwmxvvv37caz3lre9htsdxg5a3wd
static immutable AAR = KeyPair(PublicKey(Point([192, 8, 235, 93, 35, 130, 210, 118, 12, 64, 85, 152, 254, 64, 65, 114, 118, 33, 54, 118, 204, 198, 50, 62, 199, 69, 31, 143, 37, 186, 224, 211])), SecretKey(Scalar([248, 208, 106, 81, 73, 3, 17, 73, 30, 112, 122, 91, 64, 29, 140, 0, 82, 137, 61, 6, 219, 233, 73, 195, 209, 147, 163, 5, 40, 113, 47, 14])));
/// AAS("gdaas"): gdaas1xrqqj66qdp6g485azqnvencls34ddlfp2wdxfnuf56g6gzh9e5sg5v0h4e9
static immutable AAS = KeyPair(PublicKey(Point([192, 9, 107, 64, 104, 116, 138, 158, 157, 16, 38, 204, 207, 31, 132, 106, 214, 253, 33, 83, 154, 100, 207, 137, 166, 145, 164, 10, 229, 205, 32, 138])), SecretKey(Scalar([154, 30, 64, 155, 18, 219, 84, 11, 121, 25, 93, 15, 5, 171, 255, 98, 236, 215, 194, 49, 235, 152, 253, 207, 122, 225, 253, 252, 166, 181, 162, 1])));
/// AAT("gdaat"): gdaat1xrqqn666sjq6k83yfqtuhhnl24lxp7yg9stch2qxfylhwxthj0wf6hm84gq
static immutable AAT = KeyPair(PublicKey(Point([192, 9, 235, 90, 132, 129, 171, 30, 36, 72, 23, 203, 222, 127, 85, 126, 96, 248, 136, 44, 23, 139, 168, 6, 73, 63, 119, 25, 119, 147, 220, 157])), SecretKey(Scalar([191, 249, 196, 170, 235, 103, 118, 214, 168, 15, 45, 127, 144, 243, 164, 216, 253, 54, 181, 205, 38, 27, 245, 119, 193, 237, 215, 47, 16, 41, 124, 8])));
/// AAU("gdaau"): gdaau1xrqq566prawfc9jwwzjwp22zqpfhu95vj6rw4utls4876u0j22vp2usdcrj
static immutable AAU = KeyPair(PublicKey(Point([192, 10, 107, 65, 31, 92, 156, 22, 78, 112, 164, 224, 169, 66, 0, 83, 126, 22, 140, 150, 134, 234, 241, 127, 133, 79, 237, 113, 242, 82, 152, 21])), SecretKey(Scalar([33, 17, 227, 239, 255, 134, 0, 148, 67, 47, 46, 183, 94, 136, 52, 44, 123, 13, 224, 175, 244, 54, 83, 177, 169, 76, 244, 191, 56, 219, 36, 1])));
/// AAV("gdaav"): gdaav1xrqq4663gg9smtul9wc6yssmhnjre9zfxj2zh8mkjatnesy65p3zgyatdn5
static immutable AAV = KeyPair(PublicKey(Point([192, 10, 235, 81, 66, 11, 13, 175, 159, 43, 177, 162, 66, 27, 188, 228, 60, 148, 73, 52, 148, 43, 159, 118, 151, 87, 60, 192, 154, 160, 98, 36])), SecretKey(Scalar([190, 62, 62, 123, 159, 193, 65, 160, 200, 158, 44, 215, 158, 105, 180, 109, 50, 132, 53, 53, 11, 152, 178, 131, 133, 72, 132, 174, 168, 113, 39, 2])));
/// AAW("gdaaw"): gdaaw1xrqqk66swrlz6nt8al92esfnv7qj59937qlp0e8p6r0cljnn2urk5gs6nkk
static immutable AAW = KeyPair(PublicKey(Point([192, 11, 107, 80, 112, 254, 45, 77, 103, 239, 202, 172, 193, 51, 103, 129, 42, 20, 177, 240, 62, 23, 228, 225, 208, 223, 143, 202, 115, 87, 7, 106])), SecretKey(Scalar([127, 161, 235, 16, 123, 222, 130, 177, 139, 189, 103, 179, 147, 145, 205, 69, 250, 173, 66, 43, 106, 193, 3, 50, 84, 234, 194, 251, 144, 126, 75, 4])));
/// AAX("gdaax"): gdaax1xrqqh66j2a5usquvez8ezsw0nkhklvw7rmnk2y8jry7gzf04tsxk7j8mhyc
static immutable AAX = KeyPair(PublicKey(Point([192, 11, 235, 82, 87, 105, 200, 3, 140, 200, 143, 145, 65, 207, 157, 175, 111, 177, 222, 30, 231, 101, 16, 242, 25, 60, 129, 37, 245, 92, 13, 111])), SecretKey(Scalar([200, 100, 195, 27, 252, 84, 113, 212, 98, 166, 15, 141, 154, 68, 138, 229, 57, 75, 139, 93, 93, 150, 154, 204, 62, 218, 144, 25, 95, 39, 6, 14])));
/// AAY("gdaay"): gdaay1xrqqc66h72zqsg88jalhacfs28g3tg0fhuhua6kmlzmylfv64jn8yv6hvsk
static immutable AAY = KeyPair(PublicKey(Point([192, 12, 107, 87, 242, 132, 8, 32, 231, 151, 127, 126, 225, 48, 81, 209, 21, 161, 233, 191, 47, 206, 234, 219, 248, 182, 79, 165, 154, 172, 166, 114])), SecretKey(Scalar([50, 186, 121, 25, 59, 106, 137, 227, 9, 44, 109, 122, 222, 218, 173, 253, 195, 93, 43, 86, 214, 235, 141, 36, 24, 241, 34, 84, 90, 203, 111, 12])));
/// AAZ("gdaaz"): gdaaz1xrqqe6630hjpdvwya23xxqlanem378k9vy05nscmwrzupw3ztgysz8ffcm8
static immutable AAZ = KeyPair(PublicKey(Point([192, 12, 235, 81, 125, 228, 22, 177, 196, 234, 162, 99, 3, 253, 158, 119, 31, 30, 197, 97, 31, 73, 195, 27, 112, 197, 192, 186, 34, 90, 9, 1])), SecretKey(Scalar([164, 132, 106, 225, 8, 53, 114, 35, 17, 172, 148, 215, 162, 149, 119, 236, 187, 1, 21, 157, 32, 3, 180, 203, 208, 205, 243, 216, 18, 20, 129, 5])));
/// ABA("gdaba"): gdaba1xrqpq66h0nthtrg4x98f7aw522k799qup9nev89jey3ahvrgz52ejdgu8cz
static immutable ABA = KeyPair(PublicKey(Point([192, 16, 107, 87, 124, 215, 117, 141, 21, 49, 78, 159, 117, 212, 82, 173, 226, 148, 28, 9, 103, 150, 28, 178, 201, 35, 219, 176, 104, 21, 21, 153])), SecretKey(Scalar([56, 29, 61, 233, 139, 14, 19, 27, 78, 157, 56, 72, 224, 161, 149, 38, 86, 177, 5, 216, 155, 13, 53, 35, 111, 49, 75, 165, 213, 168, 2, 7])));
/// ABB("gdabb"): gdabb1xrqpp66h5m5a7xaun9sfkttjnr9jvtnkyrtlqwsccn6j0gsqz86xgpuyutf
static immutable ABB = KeyPair(PublicKey(Point([192, 16, 235, 87, 166, 233, 223, 27, 188, 153, 96, 155, 45, 114, 152, 203, 38, 46, 118, 32, 215, 240, 58, 24, 196, 245, 39, 162, 0, 17, 244, 100])), SecretKey(Scalar([62, 132, 85, 50, 120, 51, 125, 188, 128, 123, 177, 84, 1, 168, 49, 9, 226, 26, 168, 146, 72, 129, 97, 114, 9, 77, 82, 173, 17, 94, 83, 10])));
/// ABC("gdabc"): gdabc1xrqpz66nltawnyeazewt2zap6ykpq5jvxnu6z53xfsv2u9tdultvkdsxvdu
static immutable ABC = KeyPair(PublicKey(Point([192, 17, 107, 83, 250, 250, 233, 147, 61, 22, 92, 181, 11, 161, 209, 44, 16, 82, 76, 52, 249, 161, 82, 38, 76, 24, 174, 21, 109, 231, 214, 203])), SecretKey(Scalar([131, 240, 5, 109, 205, 23, 21, 53, 151, 216, 215, 174, 145, 93, 13, 132, 126, 175, 137, 89, 166, 73, 10, 57, 169, 3, 225, 87, 201, 134, 94, 9])));
/// ABD("gdabd"): gdabd1xrqpr66yskdn6g3l8f99l784ayw2zfqwqz7eyl6fyxrwsgdpk3k6sasat58
static immutable ABD = KeyPair(PublicKey(Point([192, 17, 235, 68, 133, 155, 61, 34, 63, 58, 74, 95, 248, 245, 233, 28, 161, 36, 14, 0, 189, 146, 127, 73, 33, 134, 232, 33, 161, 180, 109, 168])), SecretKey(Scalar([28, 97, 230, 210, 128, 210, 233, 189, 206, 113, 128, 71, 173, 24, 85, 127, 140, 185, 187, 29, 255, 233, 166, 123, 249, 127, 250, 39, 90, 247, 103, 11])));
/// ABE("gdabe"): gdabe1xrqpy667xu2du4zwvcmuvk2tl2anawnhap93hrqmvnfcwgwhkanp545qrv0
static immutable ABE = KeyPair(PublicKey(Point([192, 18, 107, 94, 55, 20, 222, 84, 78, 102, 55, 198, 89, 75, 250, 187, 62, 186, 119, 232, 75, 27, 140, 27, 100, 211, 135, 33, 215, 183, 102, 26])), SecretKey(Scalar([181, 249, 58, 252, 245, 133, 215, 253, 42, 88, 25, 107, 144, 61, 22, 150, 60, 100, 218, 101, 170, 28, 77, 91, 155, 48, 44, 209, 15, 51, 238, 15])));
/// ABF("gdabf"): gdabf1xrqp966m6xn6hy8mwe7k7cx7s850yg94s23pn8cqwtwzcrw0c9paqm3d045
static immutable ABF = KeyPair(PublicKey(Point([192, 18, 235, 91, 209, 167, 171, 144, 251, 118, 125, 111, 96, 222, 129, 232, 242, 32, 181, 130, 162, 25, 159, 0, 114, 220, 44, 13, 207, 193, 67, 208])), SecretKey(Scalar([229, 98, 87, 68, 188, 16, 89, 186, 237, 100, 253, 139, 78, 112, 142, 3, 13, 186, 107, 154, 17, 135, 245, 138, 53, 249, 87, 77, 126, 217, 123, 9])));
/// ABG("gdabg"): gdabg1xrqpx66xgf55xxd8zxp3mvm6url6v65sc5faccej0fmelg86ury4c90n4wg
static immutable ABG = KeyPair(PublicKey(Point([192, 19, 107, 70, 66, 105, 67, 25, 167, 17, 131, 29, 179, 122, 224, 255, 166, 106, 144, 197, 19, 220, 99, 50, 122, 119, 159, 160, 250, 224, 201, 92])), SecretKey(Scalar([186, 53, 1, 216, 96, 62, 222, 20, 236, 81, 146, 218, 152, 109, 12, 40, 148, 189, 58, 166, 67, 105, 204, 168, 152, 238, 234, 91, 120, 60, 68, 3])));
/// ABH("gdabh"): gdabh1xrqp866dq5er6tpasccf8jwgtz9uq6607ktfv9qt5a785s9gs8glw4yyq5f
static immutable ABH = KeyPair(PublicKey(Point([192, 19, 235, 77, 5, 50, 61, 44, 61, 134, 48, 147, 201, 200, 88, 139, 192, 107, 79, 245, 150, 150, 20, 11, 167, 124, 122, 64, 168, 129, 209, 247])), SecretKey(Scalar([118, 136, 203, 154, 227, 119, 159, 216, 6, 33, 203, 2, 46, 145, 45, 184, 122, 180, 168, 65, 59, 255, 119, 0, 35, 254, 3, 75, 108, 239, 131, 13])));
/// ABI("gdabi"): gdabi1xrqpg66ldhr3p87x4tcektlnv7stpmvcznkgkrkqknjxh47eglwgxsdys0j
static immutable ABI = KeyPair(PublicKey(Point([192, 20, 107, 95, 109, 199, 16, 159, 198, 170, 241, 155, 47, 243, 103, 160, 176, 237, 152, 20, 236, 139, 14, 192, 180, 228, 107, 215, 217, 71, 220, 131])), SecretKey(Scalar([25, 138, 5, 214, 176, 219, 99, 36, 12, 75, 116, 17, 27, 149, 252, 32, 199, 148, 38, 144, 216, 215, 114, 42, 251, 136, 128, 136, 225, 47, 70, 7])));
/// ABJ("gdabj"): gdabj1xrqpf667j78vensuuhzduevppsuwrraszwql2z7pcxxzh62x2mwyqfw7jwu
static immutable ABJ = KeyPair(PublicKey(Point([192, 20, 235, 94, 151, 142, 204, 206, 28, 229, 196, 222, 101, 129, 12, 56, 225, 143, 176, 19, 129, 245, 11, 193, 193, 140, 43, 233, 70, 86, 220, 64])), SecretKey(Scalar([179, 99, 184, 115, 21, 190, 183, 178, 137, 42, 23, 172, 79, 230, 117, 43, 58, 20, 201, 23, 100, 56, 235, 168, 220, 248, 140, 40, 246, 135, 210, 5])));
/// ABK("gdabk"): gdabk1xrqp2668649vpxm6huv7jt4f0v2802dht0m6l5vr92acktfk956lq5xxq9j
static immutable ABK = KeyPair(PublicKey(Point([192, 21, 107, 71, 213, 74, 192, 155, 122, 191, 25, 233, 46, 169, 123, 20, 119, 169, 183, 91, 247, 175, 209, 131, 42, 187, 139, 45, 54, 45, 53, 240])), SecretKey(Scalar([211, 202, 124, 39, 164, 202, 221, 120, 13, 129, 233, 1, 83, 106, 209, 116, 165, 64, 211, 226, 11, 119, 43, 5, 42, 47, 220, 18, 190, 93, 101, 0])));
/// ABL("gdabl"): gdabl1xrqpt665f7anzd4us7ghw8ex305a7jrwgvltfuudkfu4rt85l575v6xs8h3
static immutable ABL = KeyPair(PublicKey(Point([192, 21, 235, 84, 79, 187, 49, 54, 188, 135, 145, 119, 31, 38, 139, 233, 223, 72, 110, 67, 62, 180, 243, 141, 178, 121, 81, 172, 244, 253, 61, 70])), SecretKey(Scalar([187, 92, 213, 246, 90, 92, 252, 189, 50, 85, 172, 153, 216, 225, 132, 13, 173, 36, 12, 32, 33, 169, 61, 224, 91, 189, 49, 41, 71, 142, 220, 8])));
/// ABM("gdabm"): gdabm1xrqpv668nmq2m9shll8p7wy7z9ahm6uh363tad0d7t54qkckk43m2uftfjp
static immutable ABM = KeyPair(PublicKey(Point([192, 22, 107, 71, 158, 192, 173, 150, 23, 255, 206, 31, 56, 158, 17, 123, 125, 235, 151, 142, 162, 190, 181, 237, 242, 233, 80, 91, 22, 181, 99, 181])), SecretKey(Scalar([54, 9, 52, 106, 58, 222, 232, 203, 196, 101, 17, 12, 213, 70, 11, 212, 209, 118, 229, 17, 195, 140, 100, 54, 197, 123, 35, 86, 7, 155, 174, 6])));
/// ABN("gdabn"): gdabn1xrqpd66806w733tgq3xuyzvshc9nzd7vu9a3lm94vgn640anhyc077c9qag
static immutable ABN = KeyPair(PublicKey(Point([192, 22, 235, 71, 126, 157, 232, 197, 104, 4, 77, 194, 9, 144, 190, 11, 49, 55, 204, 225, 123, 31, 236, 181, 98, 39, 170, 191, 179, 185, 48, 255])), SecretKey(Scalar([186, 169, 65, 243, 164, 33, 193, 121, 86, 89, 247, 15, 27, 159, 247, 196, 166, 253, 67, 253, 248, 141, 190, 74, 64, 57, 113, 60, 250, 111, 14, 1])));
/// ABO("gdabo"): gdabo1xrqpw669ksh7fh3xlvzuzjpwj4q69x90vrp5evu5ulzuser0gqrdvqyfs3z
static immutable ABO = KeyPair(PublicKey(Point([192, 23, 107, 69, 180, 47, 228, 222, 38, 251, 5, 193, 72, 46, 149, 65, 162, 152, 175, 96, 195, 76, 179, 148, 231, 197, 200, 100, 111, 64, 6, 214])), SecretKey(Scalar([39, 202, 26, 32, 206, 227, 179, 85, 170, 231, 91, 126, 167, 117, 92, 189, 249, 30, 98, 77, 40, 236, 22, 9, 175, 145, 25, 123, 168, 247, 180, 4])));
/// ABP("gdabp"): gdabp1xrqp066pcfzh4e2wu64jc595hkdql3jq6n05p45zufsmm98d784vj3phlf3
static immutable ABP = KeyPair(PublicKey(Point([192, 23, 235, 65, 194, 69, 122, 229, 78, 230, 171, 44, 80, 180, 189, 154, 15, 198, 64, 212, 223, 64, 214, 130, 226, 97, 189, 148, 237, 241, 234, 201])), SecretKey(Scalar([100, 43, 77, 236, 199, 217, 139, 62, 9, 250, 83, 120, 226, 228, 22, 60, 63, 166, 178, 38, 48, 224, 140, 168, 176, 120, 168, 253, 113, 255, 215, 12])));
/// ABQ("gdabq"): gdabq1xrqps66t6q0hdsts5sz6mhmmwe02650alv6m2f8anlujtmlzkk3vv5lduss
static immutable ABQ = KeyPair(PublicKey(Point([192, 24, 107, 75, 208, 31, 118, 193, 112, 164, 5, 173, 223, 123, 118, 94, 173, 81, 253, 251, 53, 181, 36, 253, 159, 249, 37, 239, 226, 181, 162, 198])), SecretKey(Scalar([198, 75, 255, 155, 19, 3, 60, 72, 146, 154, 184, 235, 236, 123, 67, 99, 24, 37, 244, 55, 87, 124, 37, 184, 240, 24, 114, 62, 0, 226, 2, 2])));
/// ABR("gdabr"): gdabr1xrqp366qttm5yzt5xsgjj23r6jl32w4qf9hyv2lglvupw28vhxx67syh5y0
static immutable ABR = KeyPair(PublicKey(Point([192, 24, 235, 64, 90, 247, 66, 9, 116, 52, 17, 41, 42, 35, 212, 191, 21, 58, 160, 73, 110, 70, 43, 232, 251, 56, 23, 40, 236, 185, 141, 175])), SecretKey(Scalar([148, 166, 220, 142, 98, 43, 109, 238, 160, 221, 133, 106, 160, 132, 16, 107, 191, 24, 157, 240, 16, 107, 243, 242, 108, 23, 211, 208, 156, 115, 218, 7])));
/// ABS("gdabs"): gdabs1xrqpj665c8my8j6srzm695pc92dq6j8n4pq2cdel5qynqppjpzxngda0g25
static immutable ABS = KeyPair(PublicKey(Point([192, 25, 107, 84, 193, 246, 67, 203, 80, 24, 183, 162, 208, 56, 42, 154, 13, 72, 243, 168, 64, 172, 55, 63, 160, 9, 48, 4, 50, 8, 141, 52])), SecretKey(Scalar([31, 105, 125, 119, 177, 172, 63, 207, 237, 240, 32, 221, 1, 135, 114, 21, 249, 21, 223, 33, 99, 244, 116, 117, 136, 114, 22, 127, 253, 15, 218, 9])));
/// ABT("gdabt"): gdabt1xrqpn66n6cktqvm0znfv8tm3y487gr8gjq8ftgl3ey65anvvpy2hgz600ys
static immutable ABT = KeyPair(PublicKey(Point([192, 25, 235, 83, 214, 44, 176, 51, 111, 20, 210, 195, 175, 113, 37, 79, 228, 12, 232, 144, 14, 149, 163, 241, 201, 53, 78, 205, 140, 9, 21, 116])), SecretKey(Scalar([242, 251, 4, 6, 12, 10, 88, 189, 52, 117, 242, 246, 180, 192, 40, 118, 196, 85, 104, 238, 80, 237, 197, 227, 189, 166, 212, 161, 8, 129, 79, 3])));
/// ABU("gdabu"): gdabu1xrqp5663hkrhdag8dnr6e5tmpyw6qzafa4wlr6t9tgvu4qf8j3gtg5htczt
static immutable ABU = KeyPair(PublicKey(Point([192, 26, 107, 81, 189, 135, 118, 245, 7, 108, 199, 172, 209, 123, 9, 29, 160, 11, 169, 237, 93, 241, 233, 101, 90, 25, 202, 129, 39, 148, 80, 180])), SecretKey(Scalar([99, 106, 216, 37, 109, 23, 108, 247, 171, 208, 224, 245, 41, 65, 65, 136, 90, 212, 104, 133, 212, 229, 0, 229, 120, 230, 96, 222, 202, 182, 243, 12])));
/// ABV("gdabv"): gdabv1xrqp46689cegj4elaad3h0rhg865aqhdhk2fuhfdu8mwx0zreapqudhc6vc
static immutable ABV = KeyPair(PublicKey(Point([192, 26, 235, 71, 46, 50, 137, 87, 63, 239, 91, 27, 188, 119, 65, 245, 78, 130, 237, 189, 148, 158, 93, 45, 225, 246, 227, 60, 67, 207, 66, 14])), SecretKey(Scalar([172, 172, 138, 251, 2, 242, 152, 42, 41, 137, 233, 193, 229, 203, 83, 181, 172, 252, 122, 106, 147, 235, 95, 144, 68, 255, 122, 35, 199, 119, 76, 12])));
/// ABW("gdabw"): gdabw1xrqpk668p7l5gmr6wsjwvhz720l05e40wn7kj6r7edtwlal82qccvydd960
static immutable ABW = KeyPair(PublicKey(Point([192, 27, 107, 71, 15, 191, 68, 108, 122, 116, 36, 230, 92, 94, 83, 254, 250, 102, 175, 116, 253, 105, 104, 126, 203, 86, 239, 247, 231, 80, 49, 134])), SecretKey(Scalar([74, 134, 187, 130, 210, 119, 93, 4, 46, 91, 212, 198, 72, 92, 203, 89, 134, 22, 204, 103, 13, 135, 57, 238, 185, 179, 128, 243, 171, 209, 202, 9])));
/// ABX("gdabx"): gdabx1xrqph66hgmhk6kdauqlpnsp4y5mf0t8zfq7mxyala83z9ven3ty5zljz2u6
static immutable ABX = KeyPair(PublicKey(Point([192, 27, 235, 87, 70, 239, 109, 89, 189, 224, 62, 25, 192, 53, 37, 54, 151, 172, 226, 72, 61, 179, 19, 191, 233, 226, 34, 179, 51, 138, 201, 65])), SecretKey(Scalar([163, 173, 103, 34, 55, 98, 24, 20, 33, 239, 31, 246, 96, 220, 25, 186, 169, 231, 95, 93, 107, 210, 137, 172, 253, 225, 38, 216, 41, 94, 182, 3])));
/// ABY("gdaby"): gdaby1xrqpc66s43f89fj3re2uucs4g0xe8xmkufauf7ugntu5axc7jm9ckutlsth
static immutable ABY = KeyPair(PublicKey(Point([192, 28, 107, 80, 172, 82, 114, 166, 81, 30, 85, 206, 98, 21, 67, 205, 147, 155, 118, 226, 123, 196, 251, 136, 154, 249, 78, 155, 30, 150, 203, 139])), SecretKey(Scalar([186, 64, 144, 50, 214, 62, 242, 230, 222, 181, 207, 152, 71, 252, 81, 55, 125, 12, 242, 200, 90, 137, 5, 121, 251, 141, 95, 35, 137, 229, 31, 9])));
/// ABZ("gdabz"): gdabz1xrqpe663ek0anvsvy5k03ytpzkq2d4ppecp7edh4ph8weynz89f0g2n6cft
static immutable ABZ = KeyPair(PublicKey(Point([192, 28, 235, 81, 205, 159, 217, 178, 12, 37, 44, 248, 145, 97, 21, 128, 166, 212, 33, 206, 3, 236, 182, 245, 13, 206, 236, 146, 98, 57, 82, 244])), SecretKey(Scalar([56, 255, 20, 43, 85, 21, 92, 220, 131, 93, 237, 103, 219, 93, 233, 196, 21, 228, 127, 153, 217, 207, 217, 31, 254, 140, 3, 171, 149, 185, 55, 13])));
/// ACA("gdaca"): gdaca1xrqzq667y3y03ejytzps6v275gnz2nd6zgfmhjv34entp2vy9qp55exuc2d
static immutable ACA = KeyPair(PublicKey(Point([192, 32, 107, 94, 36, 72, 248, 230, 68, 88, 131, 13, 49, 94, 162, 38, 37, 77, 186, 18, 19, 187, 201, 145, 174, 102, 176, 169, 132, 40, 3, 74])), SecretKey(Scalar([195, 174, 101, 24, 52, 201, 122, 22, 232, 237, 226, 148, 112, 30, 231, 38, 121, 27, 212, 38, 120, 212, 62, 121, 135, 130, 91, 54, 237, 33, 37, 13])));
/// ACB("gdacb"): gdacb1xrqzp66cz5u2m69c0pxdkmmvqh6kzytvyn2m6tqgstkwfavpf0rcyvhvc3a
static immutable ACB = KeyPair(PublicKey(Point([192, 32, 235, 88, 21, 56, 173, 232, 184, 120, 76, 219, 111, 108, 5, 245, 97, 17, 108, 36, 213, 189, 44, 8, 130, 236, 228, 245, 129, 75, 199, 130])), SecretKey(Scalar([206, 57, 77, 59, 33, 132, 233, 208, 120, 28, 206, 220, 90, 35, 144, 173, 139, 28, 130, 173, 68, 195, 197, 154, 41, 110, 141, 190, 195, 238, 51, 14])));
/// ACC("gdacc"): gdacc1xrqzz6663fakcmv80gn0qwcjkmgnl6ptaycdgnp2eydyjv7x9a6cckvgqsr
static immutable ACC = KeyPair(PublicKey(Point([192, 33, 107, 90, 138, 123, 108, 109, 135, 122, 38, 240, 59, 18, 182, 209, 63, 232, 43, 233, 48, 212, 76, 42, 201, 26, 73, 51, 198, 47, 117, 140])), SecretKey(Scalar([53, 124, 47, 69, 181, 46, 189, 219, 189, 17, 96, 170, 51, 194, 131, 25, 92, 192, 189, 121, 231, 233, 57, 192, 181, 52, 21, 232, 89, 51, 165, 4])));
/// ACD("gdacd"): gdacd1xrqzr66gl2sl5h8y5mq8w9ru0hs5tv0t2cgl0x0yyjyn6f9xaqrsj8lp4rv
static immutable ACD = KeyPair(PublicKey(Point([192, 33, 235, 72, 250, 161, 250, 92, 228, 166, 192, 119, 20, 124, 125, 225, 69, 177, 235, 86, 17, 247, 153, 228, 36, 137, 61, 36, 166, 232, 7, 9])), SecretKey(Scalar([131, 250, 102, 237, 130, 162, 36, 179, 195, 51, 28, 98, 39, 179, 51, 40, 182, 245, 7, 17, 106, 39, 254, 6, 192, 143, 111, 15, 7, 161, 140, 10])));
/// ACE("gdace"): gdace1xrqzy66cr7n4zrymtxtn2qvpv6nnrmrwtncp5d3h8t0yhhm7hmt7umqw3sf
static immutable ACE = KeyPair(PublicKey(Point([192, 34, 107, 88, 31, 167, 81, 12, 155, 89, 151, 53, 1, 129, 102, 167, 49, 236, 110, 92, 240, 26, 54, 55, 58, 222, 75, 223, 126, 190, 215, 238])), SecretKey(Scalar([37, 19, 188, 29, 43, 206, 121, 15, 169, 5, 6, 212, 186, 84, 40, 119, 17, 212, 59, 27, 100, 112, 85, 202, 205, 123, 204, 225, 84, 147, 46, 6])));
/// ACF("gdacf"): gdacf1xrqz966xey5074tu0k758ckqpmvggdaqadupyqchrj3k0hc8p2exk7ajlal
static immutable ACF = KeyPair(PublicKey(Point([192, 34, 235, 70, 201, 40, 255, 85, 124, 125, 189, 67, 226, 192, 14, 216, 132, 55, 160, 235, 120, 18, 3, 23, 28, 163, 103, 223, 7, 10, 178, 107])), SecretKey(Scalar([57, 154, 221, 76, 37, 245, 107, 224, 155, 178, 253, 227, 89, 38, 108, 177, 243, 156, 252, 191, 103, 145, 38, 192, 159, 233, 97, 233, 137, 63, 207, 12])));
/// ACG("gdacg"): gdacg1xrqzx66sttycmvqf673tf894wv6xdq30546klp90pcxf2mlef69mzahq55p
static immutable ACG = KeyPair(PublicKey(Point([192, 35, 107, 80, 90, 201, 141, 176, 9, 215, 162, 180, 156, 181, 115, 52, 102, 130, 47, 165, 117, 111, 132, 175, 14, 12, 149, 111, 249, 78, 139, 177])), SecretKey(Scalar([107, 251, 6, 223, 9, 147, 255, 120, 93, 21, 156, 203, 245, 225, 188, 196, 125, 27, 30, 235, 86, 54, 15, 229, 9, 134, 246, 51, 158, 216, 155, 1])));
/// ACH("gdach"): gdach1xrqz866pqzqjppt7gtd8d6tgppkxn0l6t3nwatgazdsprhdljxwvzdpx705
static immutable ACH = KeyPair(PublicKey(Point([192, 35, 235, 65, 0, 129, 32, 133, 126, 66, 218, 118, 233, 104, 8, 108, 105, 191, 250, 92, 102, 238, 173, 29, 19, 96, 17, 221, 191, 145, 156, 193])), SecretKey(Scalar([227, 202, 193, 38, 118, 238, 105, 115, 225, 18, 93, 76, 164, 24, 100, 243, 13, 54, 120, 150, 97, 120, 15, 160, 235, 156, 80, 137, 33, 221, 90, 12])));
/// ACI("gdaci"): gdaci1xrqzg66cj4dxkax4jc4xv9lqt8d34ujd0xpcyxq96jk3k5f894wkuwd5gam
static immutable ACI = KeyPair(PublicKey(Point([192, 36, 107, 88, 149, 90, 107, 116, 213, 150, 42, 102, 23, 224, 89, 219, 26, 242, 77, 121, 131, 130, 24, 5, 212, 173, 27, 81, 39, 45, 93, 110])), SecretKey(Scalar([170, 250, 26, 47, 45, 35, 175, 53, 157, 225, 107, 244, 77, 153, 34, 58, 232, 18, 242, 133, 213, 190, 237, 167, 235, 203, 17, 156, 79, 106, 105, 11])));
/// ACJ("gdacj"): gdacj1xrqzf66whvw4frpjlh8uqfs9gresx839p9fr94sp9xypxy84sun2xj22r2g
static immutable ACJ = KeyPair(PublicKey(Point([192, 36, 235, 78, 187, 29, 84, 140, 50, 253, 207, 192, 38, 5, 64, 243, 3, 30, 37, 9, 82, 50, 214, 1, 41, 136, 19, 16, 245, 135, 38, 163])), SecretKey(Scalar([7, 51, 132, 102, 242, 238, 133, 147, 210, 178, 219, 129, 123, 191, 161, 80, 15, 252, 147, 0, 155, 31, 133, 77, 150, 66, 23, 90, 43, 7, 148, 14])));
/// ACK("gdack"): gdack1xrqz266jklv3mhkju02c0cgr6a3c4yfwhtygrvdjnu979hq2m6dcwhh46h6
static immutable ACK = KeyPair(PublicKey(Point([192, 37, 107, 82, 183, 217, 29, 222, 210, 227, 213, 135, 225, 3, 215, 99, 138, 145, 46, 186, 200, 129, 177, 178, 159, 11, 226, 220, 10, 222, 155, 135])), SecretKey(Scalar([42, 60, 231, 235, 224, 98, 25, 219, 188, 244, 153, 20, 225, 139, 219, 116, 10, 19, 232, 13, 159, 89, 126, 243, 180, 207, 12, 85, 160, 220, 20, 0])));
/// ACL("gdacl"): gdacl1xrqzt665cv3pqzr0wnzpw4r0v7gv7lcnuhce3twjx7h5t5v5r7lhgwu0znx
static immutable ACL = KeyPair(PublicKey(Point([192, 37, 235, 84, 195, 34, 16, 8, 111, 116, 196, 23, 84, 111, 103, 144, 207, 127, 19, 229, 241, 152, 173, 210, 55, 175, 69, 209, 148, 31, 191, 116])), SecretKey(Scalar([118, 149, 127, 247, 165, 72, 132, 207, 135, 89, 47, 109, 102, 13, 227, 249, 242, 109, 116, 202, 193, 231, 124, 223, 205, 133, 35, 148, 105, 51, 174, 2])));
/// ACM("gdacm"): gdacm1xrqzv66jr6qqw307cenld2xzwlt43xkhfj4qncsmgtwc0le75f4fq0xa8u3
static immutable ACM = KeyPair(PublicKey(Point([192, 38, 107, 82, 30, 128, 7, 69, 254, 198, 103, 246, 168, 194, 119, 215, 88, 154, 215, 76, 170, 9, 226, 27, 66, 221, 135, 255, 62, 162, 106, 144])), SecretKey(Scalar([140, 38, 118, 172, 253, 30, 121, 134, 28, 75, 98, 3, 86, 136, 234, 46, 89, 119, 91, 212, 42, 72, 127, 191, 159, 114, 255, 222, 88, 30, 247, 4])));
/// ACN("gdacn"): gdacn1xrqzd66qr2mpmmeztqpzgkssnglv6jpjhtu06v5930wjzxwnryfa2hd46q0
static immutable ACN = KeyPair(PublicKey(Point([192, 38, 235, 64, 26, 182, 29, 239, 34, 88, 2, 36, 90, 16, 154, 62, 205, 72, 50, 186, 248, 253, 50, 133, 139, 221, 33, 25, 211, 25, 19, 213])), SecretKey(Scalar([171, 84, 59, 23, 213, 161, 107, 100, 125, 135, 4, 112, 108, 183, 97, 139, 142, 90, 194, 196, 121, 216, 22, 27, 38, 238, 70, 140, 81, 54, 99, 14])));
/// ACO("gdaco"): gdaco1xrqzw662dhcuazt2uhxm3javcfzngfa69qtsdrxm5yhhfpr5993gs9aayg0
static immutable ACO = KeyPair(PublicKey(Point([192, 39, 107, 74, 109, 241, 206, 137, 106, 229, 205, 184, 203, 172, 194, 69, 52, 39, 186, 40, 23, 6, 140, 219, 161, 47, 116, 132, 116, 41, 98, 136])), SecretKey(Scalar([120, 6, 35, 88, 221, 239, 42, 234, 36, 234, 61, 154, 49, 195, 29, 196, 211, 134, 87, 129, 42, 202, 36, 67, 202, 69, 143, 137, 124, 30, 96, 9])));
/// ACP("gdacp"): gdacp1xrqz066k9e3d9kk2g4thxa92n2ynchj7wqtjjcjex42lzd94lhtdxgt0q93
static immutable ACP = KeyPair(PublicKey(Point([192, 39, 235, 86, 46, 98, 210, 218, 202, 69, 87, 115, 116, 170, 154, 137, 60, 94, 94, 112, 23, 41, 98, 89, 53, 85, 241, 52, 181, 253, 214, 211])), SecretKey(Scalar([106, 25, 76, 252, 139, 20, 31, 113, 184, 59, 81, 193, 25, 52, 13, 117, 228, 23, 238, 0, 119, 245, 129, 88, 46, 29, 1, 235, 90, 46, 212, 3])));
/// ACQ("gdacq"): gdacq1xrqzs66404zyyhawvka69fxvtvk3fjcmen3fp2h6g38zwue07v5qx3l3qk6
static immutable ACQ = KeyPair(PublicKey(Point([192, 40, 107, 85, 125, 68, 66, 95, 174, 101, 187, 162, 164, 204, 91, 45, 20, 203, 27, 204, 226, 144, 170, 250, 68, 78, 39, 115, 47, 243, 40, 3])), SecretKey(Scalar([232, 124, 13, 182, 102, 9, 28, 102, 37, 49, 207, 223, 183, 193, 64, 207, 166, 170, 222, 107, 15, 120, 220, 87, 77, 245, 72, 97, 204, 114, 167, 8])));
/// ACR("gdacr"): gdacr1xrqz3662eqt7hy0jdrm5eg693umep5erwcyhhztktmyj7d06va56czeshem
static immutable ACR = KeyPair(PublicKey(Point([192, 40, 235, 74, 200, 23, 235, 145, 242, 104, 247, 76, 163, 69, 143, 55, 144, 211, 35, 118, 9, 123, 137, 118, 94, 201, 47, 53, 250, 103, 105, 172])), SecretKey(Scalar([115, 51, 103, 165, 103, 67, 244, 168, 51, 152, 53, 19, 145, 186, 251, 84, 126, 202, 250, 40, 204, 29, 254, 200, 149, 172, 122, 139, 173, 34, 52, 7])));
/// ACS("gdacs"): gdacs1xrqzj668x4pjj9yt2ng2pfv5twmhugxf9t9jgv05y9wu3cp666th7etnjxr
static immutable ACS = KeyPair(PublicKey(Point([192, 41, 107, 71, 53, 67, 41, 20, 139, 84, 208, 160, 165, 148, 91, 183, 126, 32, 201, 42, 203, 36, 49, 244, 33, 93, 200, 224, 58, 214, 151, 127])), SecretKey(Scalar([20, 3, 148, 213, 37, 48, 142, 19, 69, 130, 4, 141, 68, 60, 127, 7, 223, 78, 215, 108, 106, 155, 185, 156, 221, 112, 61, 236, 143, 104, 87, 12])));
/// ACT("gdact"): gdact1xrqzn66rzqng3gmy5dex5p9qyamzcwk6khnxyyc5dhlxassdq0qm2wfrthm
static immutable ACT = KeyPair(PublicKey(Point([192, 41, 235, 67, 16, 38, 136, 163, 100, 163, 114, 106, 4, 160, 39, 118, 44, 58, 218, 181, 230, 98, 19, 20, 109, 254, 110, 194, 13, 3, 193, 181])), SecretKey(Scalar([20, 25, 206, 39, 51, 188, 170, 69, 101, 65, 114, 136, 212, 67, 129, 45, 134, 212, 237, 179, 172, 211, 161, 59, 102, 78, 21, 114, 14, 59, 38, 7])));
/// ACU("gdacu"): gdacu1xrqz566gy0rlqscvdhe65zgunv2f8kkrv8wqmcjex3jy3qyj8c8sj20dy9f
static immutable ACU = KeyPair(PublicKey(Point([192, 42, 107, 72, 35, 199, 240, 67, 12, 109, 243, 170, 9, 28, 155, 20, 147, 218, 195, 97, 220, 13, 226, 89, 52, 100, 72, 128, 146, 62, 15, 9])), SecretKey(Scalar([66, 106, 180, 34, 148, 66, 217, 145, 143, 192, 133, 247, 19, 251, 73, 206, 205, 29, 203, 55, 147, 252, 228, 240, 27, 0, 172, 165, 58, 213, 215, 1])));
/// ACV("gdacv"): gdacv1xrqz4662uzjsy044usu4c7gpe0270yj9ssx8uk68gd3zvddh05xyvw4s067
static immutable ACV = KeyPair(PublicKey(Point([192, 42, 235, 74, 224, 165, 2, 62, 181, 228, 57, 92, 121, 1, 203, 213, 231, 146, 69, 132, 12, 126, 91, 71, 67, 98, 38, 53, 183, 125, 12, 70])), SecretKey(Scalar([104, 133, 52, 9, 239, 186, 164, 50, 67, 30, 140, 190, 198, 49, 207, 218, 160, 133, 156, 121, 80, 40, 250, 128, 163, 144, 253, 188, 220, 67, 195, 14])));
/// ACW("gdacw"): gdacw1xrqzk6656vycts34tgg9amr9hp5trjsje7hfv23d4ku2ug88jpsvqna8w56
static immutable ACW = KeyPair(PublicKey(Point([192, 43, 107, 84, 211, 9, 133, 194, 53, 90, 16, 94, 236, 101, 184, 104, 177, 202, 18, 207, 174, 150, 42, 45, 173, 184, 174, 32, 231, 144, 96, 192])), SecretKey(Scalar([235, 137, 228, 116, 163, 109, 77, 21, 79, 68, 40, 211, 132, 29, 210, 195, 131, 218, 91, 151, 125, 118, 66, 26, 86, 135, 159, 212, 52, 66, 126, 5])));
/// ACX("gdacx"): gdacx1xrqzh660pw50ww8kq05u9ykzp7geqmy6kq2p5g4h63dwd05h0cml6hge0h8
static immutable ACX = KeyPair(PublicKey(Point([192, 43, 235, 79, 11, 168, 247, 56, 246, 3, 233, 194, 146, 194, 15, 145, 144, 108, 154, 176, 20, 26, 34, 183, 212, 90, 230, 190, 151, 126, 55, 253])), SecretKey(Scalar([128, 11, 7, 141, 205, 235, 231, 21, 21, 184, 137, 86, 19, 139, 80, 62, 74, 59, 123, 0, 125, 47, 176, 204, 54, 26, 154, 190, 32, 234, 58, 4])));
/// ACY("gdacy"): gdacy1xrqzc663ttkueq9396ycl6ytza3neuac7ky96q6wryzd9vlxhn63zg0nvt9
static immutable ACY = KeyPair(PublicKey(Point([192, 44, 107, 81, 90, 237, 204, 128, 177, 46, 137, 143, 232, 139, 23, 99, 60, 243, 184, 245, 136, 93, 3, 78, 25, 4, 210, 179, 230, 188, 245, 17])), SecretKey(Scalar([161, 65, 250, 126, 100, 33, 35, 41, 85, 207, 9, 96, 174, 176, 95, 59, 240, 155, 75, 238, 34, 99, 82, 176, 177, 142, 115, 135, 117, 249, 49, 1])));
/// ACZ("gdacz"): gdacz1xrqze663vdk94sty5s4u87rep5kzq870uwtw7veed9cx85e3n9y7kg0spwx
static immutable ACZ = KeyPair(PublicKey(Point([192, 44, 235, 81, 99, 108, 90, 193, 100, 164, 43, 195, 248, 121, 13, 44, 32, 31, 207, 227, 150, 239, 51, 57, 105, 112, 99, 211, 49, 153, 73, 235])), SecretKey(Scalar([104, 129, 160, 228, 196, 137, 42, 88, 162, 230, 164, 206, 16, 67, 144, 64, 217, 230, 166, 246, 73, 122, 136, 87, 94, 57, 160, 255, 202, 54, 100, 11])));
/// ADA("gdada"): gdada1xrqrq668p6cpgjm32k7vlyfcrazcyxzgaj23z9w9uudmlc5hl8vwx0nnwh6
static immutable ADA = KeyPair(PublicKey(Point([192, 48, 107, 71, 14, 176, 20, 75, 113, 85, 188, 207, 145, 56, 31, 69, 130, 24, 72, 236, 149, 17, 21, 197, 231, 27, 191, 226, 151, 249, 216, 227])), SecretKey(Scalar([168, 60, 163, 111, 30, 178, 235, 108, 106, 40, 196, 54, 178, 222, 69, 139, 220, 96, 98, 166, 2, 230, 16, 160, 14, 255, 17, 170, 135, 22, 47, 10])));
/// ADB("gdadb"): gdadb1xrqrp66exjxhksz3k5j9s2wxltq0vcqsxcp7ky48zfa5rfz4954a5mn285y
static immutable ADB = KeyPair(PublicKey(Point([192, 48, 235, 89, 52, 141, 123, 64, 81, 181, 36, 88, 41, 198, 250, 192, 246, 96, 16, 54, 3, 235, 18, 167, 18, 123, 65, 164, 85, 45, 43, 218])), SecretKey(Scalar([244, 117, 131, 69, 26, 14, 113, 181, 152, 1, 254, 235, 156, 226, 76, 46, 48, 208, 71, 11, 159, 200, 165, 58, 217, 54, 91, 27, 68, 66, 255, 14])));
/// ADC("gdadc"): gdadc1xrqrz66z3cu6jn3ayu5rxsr5zlt7slz55h6266pu9jp2gnc9gkkhv2lq33d
static immutable ADC = KeyPair(PublicKey(Point([192, 49, 107, 66, 142, 57, 169, 78, 61, 39, 40, 51, 64, 116, 23, 215, 232, 124, 84, 165, 244, 173, 104, 60, 44, 130, 164, 79, 5, 69, 173, 118])), SecretKey(Scalar([215, 123, 56, 24, 137, 0, 135, 254, 13, 181, 77, 126, 84, 140, 52, 236, 225, 20, 180, 224, 108, 175, 229, 42, 204, 17, 160, 121, 21, 177, 73, 15])));
/// ADD("gdadd"): gdadd1xrqrr66lgxq80klvwzl2rknfwvmsljylh3a87fvly9pajwq2flf72x4ksn9
static immutable ADD = KeyPair(PublicKey(Point([192, 49, 235, 95, 65, 128, 119, 219, 236, 112, 190, 161, 218, 105, 115, 55, 15, 200, 159, 188, 122, 127, 37, 159, 33, 67, 217, 56, 10, 79, 211, 229])), SecretKey(Scalar([159, 167, 234, 171, 140, 190, 101, 178, 30, 86, 2, 158, 254, 79, 171, 76, 57, 71, 165, 18, 95, 125, 27, 131, 4, 110, 196, 33, 150, 123, 32, 11])));
/// ADE("gdade"): gdade1xrqry66cgsxrm9ncn98ga4q8hewqffs2chwpuapkwedfun32uk79vmc3fck
static immutable ADE = KeyPair(PublicKey(Point([192, 50, 107, 88, 68, 12, 61, 150, 120, 153, 78, 142, 212, 7, 190, 92, 4, 166, 10, 197, 220, 30, 116, 54, 118, 90, 158, 78, 42, 229, 188, 86])), SecretKey(Scalar([45, 108, 178, 115, 145, 179, 191, 192, 138, 140, 14, 118, 44, 36, 22, 179, 230, 126, 136, 193, 141, 222, 45, 9, 145, 198, 60, 120, 200, 82, 198, 6])));
/// ADF("gdadf"): gdadf1xrqr96633kd08zmzzewy8t7raj2ecxpmf7r5e792x8v6lw4ypp5pjyx9f5n
static immutable ADF = KeyPair(PublicKey(Point([192, 50, 235, 81, 141, 154, 243, 139, 98, 22, 92, 67, 175, 195, 236, 149, 156, 24, 59, 79, 135, 76, 248, 170, 49, 217, 175, 186, 164, 8, 104, 25])), SecretKey(Scalar([107, 203, 225, 70, 29, 142, 59, 211, 19, 162, 114, 242, 95, 18, 92, 214, 60, 193, 238, 120, 75, 51, 15, 164, 174, 240, 182, 173, 206, 107, 32, 3])));
/// ADG("gdadg"): gdadg1xrqrx66w8duzesr2t7le6axxg8x4ex4d4jk8ntpsjydeaj676edj6zqsvcz
static immutable ADG = KeyPair(PublicKey(Point([192, 51, 107, 78, 59, 120, 44, 192, 106, 95, 191, 157, 116, 198, 65, 205, 92, 154, 173, 172, 172, 121, 172, 48, 145, 27, 158, 203, 94, 214, 91, 45])), SecretKey(Scalar([83, 178, 16, 127, 132, 59, 255, 39, 204, 194, 184, 67, 154, 143, 4, 11, 206, 12, 18, 212, 117, 238, 158, 187, 74, 99, 136, 183, 29, 177, 170, 9])));
/// ADH("gdadh"): gdadh1xrqr8667fkx4u3x8fzxy8gr2gku3qa6v4g3hjpw8mwvnya3axc30ghqfmte
static immutable ADH = KeyPair(PublicKey(Point([192, 51, 235, 94, 77, 141, 94, 68, 199, 72, 140, 67, 160, 106, 69, 185, 16, 119, 76, 170, 35, 121, 5, 199, 219, 153, 50, 118, 61, 54, 34, 244])), SecretKey(Scalar([165, 229, 51, 234, 111, 252, 11, 99, 147, 176, 228, 47, 224, 217, 46, 14, 65, 230, 19, 184, 211, 55, 212, 183, 39, 48, 205, 5, 20, 17, 216, 3])));
/// ADI("gdadi"): gdadi1xrqrg66pkly7c9mg3zrhk2j9q0anaexzmlnl46vj8yws2hg7sfpcytzk6u4
static immutable ADI = KeyPair(PublicKey(Point([192, 52, 107, 65, 183, 201, 236, 23, 104, 136, 135, 123, 42, 69, 3, 251, 62, 228, 194, 223, 231, 250, 233, 146, 57, 29, 5, 93, 30, 130, 67, 130])), SecretKey(Scalar([47, 253, 182, 3, 65, 96, 56, 131, 192, 118, 202, 224, 118, 190, 163, 191, 65, 30, 170, 49, 82, 105, 50, 48, 148, 45, 215, 106, 126, 113, 61, 5])));
/// ADJ("gdadj"): gdadj1xrqrf66x4aq487kxcp30qvp2ar4cnkgq3zvqtyeehkskr2w0n7n6jvulkgw
static immutable ADJ = KeyPair(PublicKey(Point([192, 52, 235, 70, 175, 65, 83, 250, 198, 192, 98, 240, 48, 42, 232, 235, 137, 217, 0, 136, 152, 5, 147, 57, 189, 161, 97, 169, 207, 159, 167, 169])), SecretKey(Scalar([12, 74, 62, 226, 114, 123, 204, 117, 180, 201, 47, 106, 28, 205, 230, 242, 106, 114, 164, 227, 2, 208, 37, 93, 15, 50, 223, 127, 136, 0, 139, 4])));
/// ADK("gdadk"): gdadk1xrqr266wn8ew3s2ea90xwyyq07m2rpm3mx9u6sh7nr9vvyx3ee44yywe5t4
static immutable ADK = KeyPair(PublicKey(Point([192, 53, 107, 78, 153, 242, 232, 193, 89, 233, 94, 103, 16, 128, 127, 182, 161, 135, 113, 217, 139, 205, 66, 254, 152, 202, 198, 16, 209, 206, 107, 82])), SecretKey(Scalar([189, 132, 240, 72, 76, 141, 179, 51, 154, 136, 86, 184, 166, 26, 36, 187, 14, 111, 86, 156, 54, 240, 33, 246, 221, 7, 242, 191, 23, 39, 14, 10])));
/// ADL("gdadl"): gdadl1xrqrt66cvkgrm208g2mgqlw3r5z65ekclhas2d64seqqj533jc7mk93tayu
static immutable ADL = KeyPair(PublicKey(Point([192, 53, 235, 88, 101, 144, 61, 169, 231, 66, 182, 128, 125, 209, 29, 5, 170, 102, 216, 253, 251, 5, 55, 85, 134, 64, 9, 82, 49, 150, 61, 187])), SecretKey(Scalar([134, 238, 106, 165, 252, 205, 34, 33, 67, 139, 166, 31, 153, 6, 170, 198, 255, 136, 152, 185, 53, 188, 255, 146, 233, 231, 12, 12, 214, 48, 196, 7])));
/// ADM("gdadm"): gdadm1xrqrv66s608yva62nr2z4g32asseufhax93gx6kfv9ppvq8rsdxtgvu25cd
static immutable ADM = KeyPair(PublicKey(Point([192, 54, 107, 80, 211, 206, 70, 119, 74, 152, 212, 42, 162, 42, 236, 33, 158, 38, 253, 49, 98, 131, 106, 201, 97, 66, 22, 0, 227, 131, 76, 180])), SecretKey(Scalar([13, 131, 84, 94, 141, 89, 250, 9, 39, 243, 168, 117, 130, 132, 143, 102, 170, 56, 243, 66, 238, 106, 10, 145, 80, 109, 189, 9, 25, 73, 50, 7])));
/// ADN("gdadn"): gdadn1xrqrd66fec5knqc72wj7w25vwa83ks8x6ce7xce0l9z6q4vzrjp270rzqq5
static immutable ADN = KeyPair(PublicKey(Point([192, 54, 235, 73, 206, 41, 105, 131, 30, 83, 165, 231, 42, 140, 119, 79, 27, 64, 230, 214, 51, 227, 99, 47, 249, 69, 160, 85, 130, 28, 130, 175])), SecretKey(Scalar([75, 34, 113, 255, 7, 143, 88, 83, 166, 140, 32, 21, 151, 200, 64, 122, 231, 86, 251, 58, 177, 36, 215, 236, 7, 242, 209, 100, 147, 39, 138, 0])));
/// ADO("gdado"): gdado1xrqrw66usaj9h55da9ae2pgxkvqwq9q75a7xrsr2k5xm9mkn225rj2rkypf
static immutable ADO = KeyPair(PublicKey(Point([192, 55, 107, 92, 135, 100, 91, 210, 141, 233, 123, 149, 5, 6, 179, 0, 224, 20, 30, 167, 124, 97, 192, 106, 181, 13, 178, 238, 211, 82, 168, 57])), SecretKey(Scalar([97, 151, 59, 72, 118, 185, 119, 9, 212, 79, 41, 65, 212, 167, 189, 54, 224, 65, 216, 104, 45, 187, 76, 153, 158, 17, 40, 104, 148, 164, 19, 10])));
/// ADP("gdadp"): gdadp1xrqr066ttcmhf9387xdvamseqgvhvsq7e6dyuetn7gcfdysv57gzjdn2uvr
static immutable ADP = KeyPair(PublicKey(Point([192, 55, 235, 75, 94, 55, 116, 150, 39, 241, 154, 206, 238, 25, 2, 25, 118, 64, 30, 206, 154, 78, 101, 115, 242, 48, 150, 146, 12, 167, 144, 41])), SecretKey(Scalar([222, 22, 233, 151, 86, 137, 79, 144, 5, 227, 2, 183, 63, 115, 185, 232, 95, 229, 203, 65, 139, 3, 85, 228, 74, 3, 193, 221, 36, 34, 212, 14])));
/// ADQ("gdadq"): gdadq1xrqrs665llf8nwkg4d0d2c77h8njr59ld78739jfw88ys5ae2u9p2eekf6u
static immutable ADQ = KeyPair(PublicKey(Point([192, 56, 107, 84, 255, 210, 121, 186, 200, 171, 94, 213, 99, 222, 185, 231, 33, 208, 191, 111, 143, 232, 150, 73, 113, 206, 72, 83, 185, 87, 10, 21])), SecretKey(Scalar([48, 126, 160, 117, 162, 145, 53, 147, 217, 194, 152, 178, 165, 6, 183, 132, 14, 137, 227, 157, 71, 60, 75, 153, 55, 8, 34, 65, 6, 110, 139, 8])));
/// ADR("gdadr"): gdadr1xrqr366ffpexsq075hp2grwu98z76qs0mpdlzmwpjhnzzn25kf4cgyhwg4m
static immutable ADR = KeyPair(PublicKey(Point([192, 56, 235, 73, 72, 114, 104, 1, 254, 165, 194, 164, 13, 220, 41, 197, 237, 2, 15, 216, 91, 241, 109, 193, 149, 230, 33, 77, 84, 178, 107, 132])), SecretKey(Scalar([203, 30, 76, 208, 53, 157, 70, 10, 72, 231, 107, 25, 38, 133, 112, 48, 89, 74, 253, 126, 112, 148, 137, 74, 177, 22, 71, 181, 87, 34, 196, 3])));
/// ADS("gdads"): gdads1xrqrj669hpewa2jj8u24c6gmvqttjx3cfxr5jk7wa3tnd4lfs39ey7d4pta
static immutable ADS = KeyPair(PublicKey(Point([192, 57, 107, 69, 184, 114, 238, 170, 82, 63, 21, 92, 105, 27, 96, 22, 185, 26, 56, 73, 135, 73, 91, 206, 236, 87, 54, 215, 233, 132, 75, 146])), SecretKey(Scalar([31, 94, 234, 75, 204, 133, 102, 12, 97, 19, 207, 148, 254, 93, 169, 198, 154, 173, 240, 20, 63, 253, 243, 184, 229, 176, 197, 171, 128, 48, 140, 0])));
/// ADT("gdadt"): gdadt1xrqrn66z49xc5ym0qh6m5l57slgj3e85echs0we7j3rggjlqxvpck0kll97
static immutable ADT = KeyPair(PublicKey(Point([192, 57, 235, 66, 169, 77, 138, 19, 111, 5, 245, 186, 126, 158, 135, 209, 40, 228, 244, 206, 47, 7, 187, 62, 148, 70, 132, 75, 224, 51, 3, 139])), SecretKey(Scalar([37, 118, 143, 185, 178, 16, 249, 212, 81, 161, 194, 174, 204, 236, 88, 56, 25, 218, 121, 55, 74, 154, 179, 166, 114, 224, 145, 168, 87, 183, 204, 13])));
/// ADU("gdadu"): gdadu1xrqr566cafer32l8kcsx5ngrt96cs96cvpre0whgylpgf22m7l9g53tadl0
static immutable ADU = KeyPair(PublicKey(Point([192, 58, 107, 88, 234, 114, 56, 171, 231, 182, 32, 106, 77, 3, 89, 117, 136, 23, 88, 96, 71, 151, 186, 232, 39, 194, 132, 169, 91, 247, 202, 138])), SecretKey(Scalar([226, 141, 244, 217, 252, 77, 63, 101, 88, 242, 248, 189, 223, 56, 156, 32, 30, 86, 104, 134, 59, 182, 47, 93, 239, 190, 57, 9, 139, 177, 174, 9])));
/// ADV("gdadv"): gdadv1xrqr466en2c246y698zh8ffkmrpqdlxu6900r2qxzfr33pcsc0d8ytqss28
static immutable ADV = KeyPair(PublicKey(Point([192, 58, 235, 89, 154, 176, 170, 232, 154, 41, 197, 115, 165, 54, 216, 194, 6, 252, 220, 209, 94, 241, 168, 6, 18, 71, 24, 135, 16, 195, 218, 114])), SecretKey(Scalar([84, 67, 233, 77, 37, 169, 109, 194, 125, 106, 77, 157, 47, 178, 14, 214, 175, 189, 202, 85, 55, 231, 70, 142, 20, 109, 181, 230, 195, 221, 70, 9])));
/// ADW("gdadw"): gdadw1xrqrk66rueh3wey2znahcncaped5yw34zumzhe2wh2vt4n97qj4375fw2an
static immutable ADW = KeyPair(PublicKey(Point([192, 59, 107, 67, 230, 111, 23, 100, 138, 20, 251, 124, 79, 29, 14, 91, 66, 58, 53, 23, 54, 43, 229, 78, 186, 152, 186, 204, 190, 4, 171, 31])), SecretKey(Scalar([106, 42, 229, 28, 202, 124, 181, 68, 47, 248, 104, 232, 86, 112, 117, 3, 49, 255, 171, 27, 239, 244, 3, 33, 101, 170, 4, 152, 202, 205, 199, 12])));
/// ADX("gdadx"): gdadx1xrqrh66c6z5h75qzw9jpftgxtv26ynldt2dql9ee4aw0nzg696j5c4snexk
static immutable ADX = KeyPair(PublicKey(Point([192, 59, 235, 88, 208, 169, 127, 80, 2, 113, 100, 20, 173, 6, 91, 21, 162, 79, 237, 90, 154, 15, 151, 57, 175, 92, 249, 137, 26, 46, 165, 76])), SecretKey(Scalar([162, 168, 58, 73, 122, 134, 176, 24, 195, 28, 13, 86, 158, 198, 150, 135, 245, 197, 223, 50, 140, 105, 134, 81, 172, 216, 149, 72, 52, 222, 143, 6])));
/// ADY("gdady"): gdady1xrqrc66d43ds59qpnrad73jh4c55pa0hnt476wadv496jkd4thv228d898c
static immutable ADY = KeyPair(PublicKey(Point([192, 60, 107, 77, 172, 91, 10, 20, 1, 152, 250, 223, 70, 87, 174, 41, 64, 245, 247, 154, 235, 237, 59, 173, 101, 75, 169, 89, 181, 93, 216, 165])), SecretKey(Scalar([166, 64, 162, 215, 215, 168, 214, 27, 159, 85, 32, 226, 231, 140, 224, 174, 139, 97, 157, 57, 61, 143, 75, 254, 151, 48, 134, 83, 209, 227, 46, 14])));
/// ADZ("gdadz"): gdadz1xrqre66whvxwgtr8t2pfrqzwjwdhyzralv343cvruhn9l0xdzjekurafa50
static immutable ADZ = KeyPair(PublicKey(Point([192, 60, 235, 78, 187, 12, 228, 44, 103, 90, 130, 145, 128, 78, 147, 155, 114, 8, 125, 251, 35, 88, 225, 131, 229, 230, 95, 188, 205, 20, 179, 110])), SecretKey(Scalar([31, 163, 48, 5, 202, 165, 44, 249, 244, 72, 2, 221, 171, 245, 117, 75, 103, 218, 25, 181, 23, 82, 32, 192, 186, 68, 44, 96, 208, 247, 82, 9])));
/// AEA("gdaea"): gdaea1xrqyq66mryyvmtlhd0jvru7pyulecatxfhfslg48s72s9txeqcgu5lhtyj8
static immutable AEA = KeyPair(PublicKey(Point([192, 64, 107, 91, 25, 8, 205, 175, 247, 107, 228, 193, 243, 193, 39, 63, 156, 117, 102, 77, 211, 15, 162, 167, 135, 149, 2, 172, 217, 6, 17, 202])), SecretKey(Scalar([142, 202, 153, 41, 214, 252, 23, 70, 182, 49, 10, 30, 116, 73, 43, 60, 175, 19, 167, 124, 107, 187, 240, 30, 29, 255, 188, 54, 132, 214, 144, 2])));
/// AEB("gdaeb"): gdaeb1xrqyp66h4rnuy0rxne44a7ccxq6nmwur8rjaawhhg26z2gr7kq3h6uhjqy6
static immutable AEB = KeyPair(PublicKey(Point([192, 64, 235, 87, 168, 231, 194, 60, 102, 158, 107, 94, 251, 24, 48, 53, 61, 187, 131, 56, 229, 222, 186, 247, 66, 180, 37, 32, 126, 176, 35, 125])), SecretKey(Scalar([144, 123, 150, 214, 230, 124, 9, 15, 242, 116, 29, 1, 159, 218, 103, 176, 190, 128, 83, 66, 79, 132, 93, 245, 226, 147, 234, 206, 113, 164, 209, 7])));
/// AEC("gdaec"): gdaec1xrqyz666hv5fumdlxtqpglqfj6el7n43f4u0jnrh9ehhafwwevuw7q3xf6m
static immutable AEC = KeyPair(PublicKey(Point([192, 65, 107, 90, 187, 40, 158, 109, 191, 50, 192, 20, 124, 9, 150, 179, 255, 78, 177, 77, 120, 249, 76, 119, 46, 111, 126, 165, 206, 203, 56, 239])), SecretKey(Scalar([30, 115, 177, 189, 125, 138, 9, 8, 185, 130, 207, 143, 65, 242, 82, 0, 57, 71, 35, 252, 163, 254, 183, 157, 240, 209, 231, 6, 58, 73, 116, 8])));
/// AED("gdaed"): gdaed1xrqyr66qlv7h8ws2nw2luxzqaw9r3vvd88s8kv4key44szxnd6cs7ypush2
static immutable AED = KeyPair(PublicKey(Point([192, 65, 235, 64, 251, 61, 115, 186, 10, 155, 149, 254, 24, 64, 235, 138, 56, 177, 141, 57, 224, 123, 50, 182, 201, 43, 88, 8, 211, 110, 177, 15])), SecretKey(Scalar([140, 64, 76, 51, 36, 238, 149, 100, 103, 227, 105, 3, 121, 126, 237, 197, 5, 66, 21, 175, 179, 189, 246, 151, 94, 172, 88, 152, 170, 206, 125, 2])));
/// AEE("gdaee"): gdaee1xrqyy66ufacn6r7v7p0y4zr9z5rtjug0ujwuuxpgwlnpf80fskywus825k5
static immutable AEE = KeyPair(PublicKey(Point([192, 66, 107, 92, 79, 113, 61, 15, 204, 240, 94, 74, 136, 101, 21, 6, 185, 113, 15, 228, 157, 206, 24, 40, 119, 230, 20, 157, 233, 133, 136, 238])), SecretKey(Scalar([22, 43, 18, 248, 81, 83, 224, 145, 199, 115, 233, 47, 250, 13, 190, 135, 6, 114, 131, 8, 158, 40, 180, 186, 35, 20, 172, 244, 49, 8, 21, 2])));
/// AEF("gdaef"): gdaef1xrqy9666w4zwkhzd7jannjslhjtx6ytnmylyz86zxmq6h9enh5cvvrh833t
static immutable AEF = KeyPair(PublicKey(Point([192, 66, 235, 90, 117, 68, 235, 92, 77, 244, 187, 57, 202, 31, 188, 150, 109, 17, 115, 217, 62, 65, 31, 66, 54, 193, 171, 151, 51, 189, 48, 198])), SecretKey(Scalar([6, 164, 167, 179, 232, 197, 30, 90, 251, 228, 135, 213, 103, 91, 150, 190, 201, 22, 68, 145, 242, 155, 98, 200, 158, 228, 147, 179, 69, 117, 149, 3])));
/// AEG("gdaeg"): gdaeg1xrqyx660peqtrcxdfdw9k64ykqlxm4ezj6czr0luqq6yhqwa5aakg5nxq7s
static immutable AEG = KeyPair(PublicKey(Point([192, 67, 107, 79, 14, 64, 177, 224, 205, 75, 92, 91, 106, 164, 176, 62, 109, 215, 34, 150, 176, 33, 191, 252, 0, 52, 75, 129, 221, 167, 123, 100])), SecretKey(Scalar([16, 170, 228, 163, 243, 141, 247, 116, 14, 225, 115, 144, 112, 91, 255, 5, 105, 170, 207, 166, 45, 172, 67, 72, 77, 1, 238, 178, 71, 223, 247, 15])));
/// AEH("gdaeh"): gdaeh1xrqy866tvvff0trr7um68agffxc37z3ylmtfw56u0cmqgzj9a5kv7qulhtr
static immutable AEH = KeyPair(PublicKey(Point([192, 67, 235, 75, 99, 18, 151, 172, 99, 247, 55, 163, 245, 9, 73, 177, 31, 10, 36, 254, 214, 151, 83, 92, 126, 54, 4, 10, 69, 237, 44, 207])), SecretKey(Scalar([112, 53, 99, 248, 91, 51, 71, 72, 31, 222, 28, 251, 238, 105, 59, 238, 209, 48, 95, 206, 78, 81, 143, 128, 32, 30, 91, 54, 233, 168, 212, 15])));
/// AEI("gdaei"): gdaei1xrqyg66lngjsh5ufkjfkwmv9man4ukppk995mcdlxecfggkrr36fqrja27q
static immutable AEI = KeyPair(PublicKey(Point([192, 68, 107, 95, 154, 37, 11, 211, 137, 180, 147, 103, 109, 133, 223, 103, 94, 88, 33, 177, 75, 77, 225, 191, 54, 112, 148, 34, 195, 28, 116, 144])), SecretKey(Scalar([154, 20, 234, 25, 90, 133, 91, 191, 253, 251, 2, 218, 201, 230, 32, 5, 39, 131, 202, 164, 210, 164, 100, 87, 83, 145, 234, 138, 10, 94, 70, 2])));
/// AEJ("gdaej"): gdaej1xrqyf66cj2nlsd7mw6492gmeclau3n2655ckswphcqv6q3lxsaf9kd56j9k
static immutable AEJ = KeyPair(PublicKey(Point([192, 68, 235, 88, 146, 167, 248, 55, 219, 118, 170, 85, 35, 121, 199, 251, 200, 205, 90, 165, 49, 104, 56, 55, 192, 25, 160, 71, 230, 135, 82, 91])), SecretKey(Scalar([218, 141, 158, 62, 1, 73, 60, 53, 56, 76, 41, 14, 91, 217, 32, 172, 96, 226, 53, 99, 162, 28, 26, 35, 251, 210, 74, 3, 58, 18, 58, 12])));
/// AEK("gdaek"): gdaek1xrqy266tqsqqkx72es9see9lsht2rh0a2djcpwdnswe550qhpu2qctawq6f
static immutable AEK = KeyPair(PublicKey(Point([192, 69, 107, 75, 4, 0, 11, 27, 202, 204, 11, 12, 228, 191, 133, 214, 161, 221, 253, 83, 101, 128, 185, 179, 131, 179, 74, 60, 23, 15, 20, 12])), SecretKey(Scalar([20, 221, 120, 12, 59, 9, 245, 25, 190, 156, 208, 75, 94, 205, 61, 154, 108, 38, 201, 254, 82, 173, 189, 12, 140, 98, 63, 13, 184, 232, 88, 7])));
/// AEL("gdael"): gdael1xrqyt66n8krxtquk6uncuppg53rs0yqq5zy7p0ccjzx6e0rk65r95632m9v
static immutable AEL = KeyPair(PublicKey(Point([192, 69, 235, 83, 61, 134, 101, 131, 150, 215, 39, 142, 4, 40, 164, 71, 7, 144, 0, 160, 137, 224, 191, 24, 144, 141, 172, 188, 118, 213, 6, 90])), SecretKey(Scalar([157, 22, 19, 129, 189, 106, 232, 218, 198, 92, 195, 91, 71, 15, 189, 43, 72, 216, 94, 151, 251, 124, 252, 230, 97, 121, 5, 44, 116, 186, 36, 1])));
/// AEM("gdaem"): gdaem1xrqyv666lrtgdvg4hl67lr9hjxjac4s0950q0lclu6nse5x7uyl0sql88rn
static immutable AEM = KeyPair(PublicKey(Point([192, 70, 107, 90, 248, 214, 134, 177, 21, 191, 245, 239, 140, 183, 145, 165, 220, 86, 15, 45, 30, 7, 255, 31, 230, 167, 12, 208, 222, 225, 62, 248])), SecretKey(Scalar([148, 9, 242, 177, 239, 244, 96, 195, 93, 72, 120, 35, 12, 91, 71, 113, 106, 183, 223, 159, 2, 119, 175, 190, 119, 195, 182, 201, 146, 242, 231, 8])));
/// AEN("gdaen"): gdaen1xrqyd66r9qnnqxjh0udrqmmqcj88l7w5sgw0tsnnfjzs5mae8hzwcws8mdg
static immutable AEN = KeyPair(PublicKey(Point([192, 70, 235, 67, 40, 39, 48, 26, 87, 127, 26, 48, 111, 96, 196, 142, 127, 249, 212, 130, 28, 245, 194, 115, 76, 133, 10, 111, 185, 61, 196, 236])), SecretKey(Scalar([102, 134, 12, 225, 91, 255, 11, 20, 115, 99, 255, 41, 35, 40, 92, 247, 195, 205, 217, 221, 160, 20, 221, 249, 135, 185, 1, 170, 109, 163, 224, 5])));
/// AEO("gdaeo"): gdaeo1xrqyw66fzumh9d53u6xlkg3p988r7fe8kmz4rzqj8sqgt6f0r76mv6n75c6
static immutable AEO = KeyPair(PublicKey(Point([192, 71, 107, 73, 23, 55, 114, 182, 145, 230, 141, 251, 34, 33, 41, 206, 63, 39, 39, 182, 197, 81, 136, 18, 60, 0, 133, 233, 47, 31, 181, 182])), SecretKey(Scalar([207, 129, 164, 2, 45, 93, 216, 129, 110, 217, 64, 101, 223, 106, 202, 180, 152, 146, 71, 87, 252, 12, 200, 187, 65, 224, 227, 163, 214, 110, 203, 11])));
/// AEP("gdaep"): gdaep1xrqy0663wvvg7f33pacywjykkymasupas7z053ak7x84c87r6402ggvj3g9
static immutable AEP = KeyPair(PublicKey(Point([192, 71, 235, 81, 115, 24, 143, 38, 49, 15, 112, 71, 72, 150, 177, 55, 216, 112, 61, 135, 132, 250, 71, 182, 241, 143, 92, 31, 195, 213, 94, 164])), SecretKey(Scalar([178, 223, 191, 238, 28, 253, 197, 219, 245, 82, 159, 214, 146, 94, 136, 215, 152, 116, 27, 236, 177, 177, 200, 20, 250, 51, 71, 250, 0, 171, 43, 14])));
/// AEQ("gdaeq"): gdaeq1xrqys6658px8fmsgjsjk2r3dp4ararts78ykuytmzkdteskfk42kjhts4fx
static immutable AEQ = KeyPair(PublicKey(Point([192, 72, 107, 84, 56, 76, 116, 238, 8, 148, 37, 101, 14, 45, 13, 122, 62, 141, 112, 241, 201, 110, 17, 123, 21, 154, 188, 194, 201, 181, 85, 105])), SecretKey(Scalar([24, 129, 90, 70, 74, 149, 155, 6, 36, 221, 1, 0, 6, 9, 250, 44, 149, 196, 227, 50, 93, 74, 157, 122, 17, 7, 129, 243, 122, 103, 225, 5])));
/// AER("gdaer"): gdaer1xrqy3668yayl47vw8m8avzrlhus903shhwg4w4wwjf27ukjsylzsgskwvyh
static immutable AER = KeyPair(PublicKey(Point([192, 72, 235, 71, 39, 73, 250, 249, 142, 62, 207, 214, 8, 127, 191, 32, 87, 198, 23, 187, 145, 87, 85, 206, 146, 85, 238, 90, 80, 39, 197, 4])), SecretKey(Scalar([148, 96, 194, 243, 64, 111, 182, 57, 70, 9, 226, 233, 162, 38, 165, 213, 122, 51, 232, 94, 30, 73, 219, 39, 43, 217, 194, 121, 39, 189, 22, 11])));
/// AES("gdaes"): gdaes1xrqyj66v93z9pn2z2u3sajnrjavvaqz92pu6y8t4yteyt6zzz8tux8nlgse
static immutable AES = KeyPair(PublicKey(Point([192, 73, 107, 76, 44, 68, 80, 205, 66, 87, 35, 14, 202, 99, 151, 88, 206, 128, 69, 80, 121, 162, 29, 117, 34, 242, 69, 232, 66, 17, 215, 195])), SecretKey(Scalar([243, 222, 236, 107, 10, 138, 74, 145, 131, 243, 107, 121, 210, 71, 67, 242, 202, 46, 155, 127, 235, 166, 77, 16, 75, 231, 200, 88, 152, 221, 67, 2])));
/// AET("gdaet"): gdaet1xrqyn66yakzku9utuygf7rljge2674gpvaedcv4sdqdza8sjnkc9k6fxz3p
static immutable AET = KeyPair(PublicKey(Point([192, 73, 235, 68, 237, 133, 110, 23, 139, 225, 16, 159, 15, 242, 70, 85, 175, 85, 1, 103, 114, 220, 50, 176, 104, 26, 46, 158, 18, 157, 176, 91])), SecretKey(Scalar([138, 218, 122, 101, 191, 169, 127, 88, 113, 15, 174, 187, 143, 150, 171, 83, 141, 194, 7, 61, 213, 212, 72, 70, 4, 227, 84, 26, 138, 53, 219, 0])));
/// AEU("gdaeu"): gdaeu1xrqy566qkf86tn6hjt28gulnaskwcf77pjtfd6p4kezz76v4t3mek63tfl7
static immutable AEU = KeyPair(PublicKey(Point([192, 74, 107, 64, 178, 79, 165, 207, 87, 146, 212, 116, 115, 243, 236, 44, 236, 39, 222, 12, 150, 150, 232, 53, 182, 68, 47, 105, 149, 92, 119, 155])), SecretKey(Scalar([100, 139, 99, 134, 215, 25, 9, 166, 72, 13, 31, 211, 47, 116, 97, 48, 122, 33, 248, 156, 219, 89, 43, 18, 254, 99, 110, 151, 214, 159, 245, 15])));
/// AEV("gdaev"): gdaev1xrqy46676lx3an0ezx3hp48ja84tt8quk9nmyll9l0s3ewkxnp0kuvylyjl
static immutable AEV = KeyPair(PublicKey(Point([192, 74, 235, 94, 215, 205, 30, 205, 249, 17, 163, 112, 212, 242, 233, 234, 181, 156, 28, 177, 103, 178, 127, 229, 251, 225, 28, 186, 198, 152, 95, 110])), SecretKey(Scalar([6, 109, 215, 197, 220, 118, 235, 239, 103, 142, 11, 84, 3, 239, 63, 163, 158, 177, 235, 247, 212, 6, 206, 45, 167, 184, 54, 119, 243, 55, 98, 12])));
/// AEW("gdaew"): gdaew1xrqyk663hgmrdlfwnvehanrjpjnq90t4sm9epu0drdt8pmayrj47z66xgrs
static immutable AEW = KeyPair(PublicKey(Point([192, 75, 107, 81, 186, 54, 54, 253, 46, 155, 51, 126, 204, 114, 12, 166, 2, 189, 117, 134, 203, 144, 241, 237, 27, 86, 112, 239, 164, 28, 171, 225])), SecretKey(Scalar([29, 46, 159, 13, 215, 98, 251, 83, 56, 98, 0, 58, 13, 163, 111, 232, 207, 26, 10, 215, 234, 25, 175, 55, 172, 125, 36, 18, 156, 182, 76, 1])));
/// AEX("gdaex"): gdaex1xrqyh66rp48w8ducc4hd4znvsz5l6nprgv7ljw77se7qmrrrl5v47v0a043
static immutable AEX = KeyPair(PublicKey(Point([192, 75, 235, 67, 13, 78, 227, 183, 152, 197, 110, 218, 138, 108, 128, 169, 253, 76, 35, 67, 61, 249, 59, 222, 134, 124, 13, 140, 99, 253, 25, 95])), SecretKey(Scalar([238, 6, 112, 198, 244, 171, 206, 192, 23, 64, 181, 155, 206, 216, 232, 224, 28, 146, 79, 209, 145, 180, 45, 114, 124, 215, 160, 138, 80, 183, 61, 9])));
/// AEY("gdaey"): gdaey1xrqyc66q8pfu8zqnxpu9kz7gw7hkr5veq5u58zumeydt65hm92ux50kdm44
static immutable AEY = KeyPair(PublicKey(Point([192, 76, 107, 64, 56, 83, 195, 136, 19, 48, 120, 91, 11, 200, 119, 175, 97, 209, 153, 5, 57, 67, 139, 155, 201, 26, 189, 82, 251, 42, 184, 106])), SecretKey(Scalar([138, 219, 193, 94, 22, 94, 210, 63, 21, 245, 129, 254, 143, 52, 43, 126, 38, 232, 141, 81, 198, 248, 152, 128, 136, 175, 70, 121, 86, 51, 154, 10])));
/// AEZ("gdaez"): gdaez1xrqye66ctlc0jp2jp9g2am7yxdyrpylyz4yvuua9prkl4f65jxf3ulyrkyx
static immutable AEZ = KeyPair(PublicKey(Point([192, 76, 235, 88, 95, 240, 249, 5, 82, 9, 80, 174, 239, 196, 51, 72, 48, 147, 228, 21, 72, 206, 115, 165, 8, 237, 250, 167, 84, 145, 147, 30])), SecretKey(Scalar([15, 186, 78, 198, 135, 94, 16, 220, 71, 67, 103, 94, 178, 57, 71, 41, 36, 115, 43, 224, 76, 144, 180, 169, 14, 44, 247, 152, 125, 90, 223, 7])));
/// AFA("gdafa"): gdafa1xrq9q66fkwhrvjau0a7qe3jt8zpvd03pmmuts78fdya3gdauzw4wcqdszyd
static immutable AFA = KeyPair(PublicKey(Point([192, 80, 107, 73, 179, 174, 54, 75, 188, 127, 124, 12, 198, 75, 56, 130, 198, 190, 33, 222, 248, 184, 120, 233, 105, 59, 20, 55, 188, 19, 170, 236])), SecretKey(Scalar([13, 249, 125, 76, 45, 249, 245, 181, 77, 253, 60, 237, 227, 74, 173, 223, 41, 107, 82, 215, 131, 139, 188, 241, 90, 241, 217, 167, 172, 213, 175, 2])));
/// AFB("gdafb"): gdafb1xrq9p66vxz73yjmjvk2y3qhn89ptvfhns4xr7r3ksjz327hnuq3ezv4rfaz
static immutable AFB = KeyPair(PublicKey(Point([192, 80, 235, 76, 48, 189, 18, 75, 114, 101, 148, 72, 130, 243, 57, 66, 182, 38, 243, 133, 76, 63, 14, 54, 132, 133, 21, 122, 243, 224, 35, 145])), SecretKey(Scalar([172, 156, 157, 31, 131, 14, 103, 156, 5, 161, 15, 77, 232, 213, 162, 238, 58, 125, 108, 137, 131, 154, 110, 45, 222, 140, 139, 233, 88, 84, 245, 7])));
/// AFC("gdafc"): gdafc1xrq9z66k2wc6yzg598j9p8rcax073h77ttzmemlknxvfmyatg023jyw65rh
static immutable AFC = KeyPair(PublicKey(Point([192, 81, 107, 86, 83, 177, 162, 9, 20, 41, 228, 80, 156, 120, 233, 159, 232, 223, 222, 90, 197, 188, 239, 246, 153, 152, 157, 147, 171, 67, 213, 25])), SecretKey(Scalar([179, 249, 228, 140, 190, 136, 176, 127, 37, 221, 160, 144, 239, 112, 152, 2, 129, 119, 137, 115, 119, 10, 96, 129, 242, 51, 42, 197, 0, 134, 212, 12])));
/// AFD("gdafd"): gdafd1xrq9r66yv0sheaepy0u9y6zjas64um6mgtng5w2cazcp7myxgxnqum8xhgq
static immutable AFD = KeyPair(PublicKey(Point([192, 81, 235, 68, 99, 225, 124, 247, 33, 35, 248, 82, 104, 82, 236, 53, 94, 111, 91, 66, 230, 138, 57, 88, 232, 176, 31, 108, 134, 65, 166, 14])), SecretKey(Scalar([198, 180, 246, 154, 151, 124, 143, 245, 222, 12, 30, 31, 141, 110, 154, 123, 247, 46, 83, 22, 157, 60, 151, 181, 113, 183, 198, 30, 26, 168, 247, 7])));
/// AFE("gdafe"): gdafe1xrq9y667xr89yk9tg9x098drddh4t59h602khv24tw04ga6qrg6v7n5cxje
static immutable AFE = KeyPair(PublicKey(Point([192, 82, 107, 94, 48, 206, 82, 88, 171, 65, 76, 242, 157, 163, 107, 111, 85, 208, 183, 211, 213, 107, 177, 85, 91, 159, 84, 119, 64, 26, 52, 207])), SecretKey(Scalar([224, 110, 136, 65, 185, 205, 242, 192, 84, 189, 123, 186, 38, 188, 135, 126, 139, 207, 127, 197, 45, 233, 4, 99, 183, 4, 131, 218, 1, 241, 54, 2])));
/// AFF("gdaff"): gdaff1xrq9966l7c3dxx46v0gdzrvu8m5dlfruf9jdmg4qnpwcsdl25n0ty3w0k56
static immutable AFF = KeyPair(PublicKey(Point([192, 82, 235, 95, 246, 34, 211, 26, 186, 99, 208, 209, 13, 156, 62, 232, 223, 164, 124, 73, 100, 221, 162, 160, 152, 93, 136, 55, 234, 164, 222, 178])), SecretKey(Scalar([28, 37, 53, 163, 90, 82, 79, 33, 26, 116, 138, 234, 17, 62, 97, 121, 61, 183, 135, 193, 134, 30, 134, 202, 6, 25, 62, 53, 83, 219, 184, 7])));
/// AFG("gdafg"): gdafg1xrq9x6682rw0th6al04k6rx3hfcyujtygr8rllxcjf7kt3crasxtgqzl4z8
static immutable AFG = KeyPair(PublicKey(Point([192, 83, 107, 71, 80, 220, 245, 223, 93, 251, 235, 109, 12, 209, 186, 112, 78, 73, 100, 64, 206, 63, 252, 216, 146, 125, 101, 199, 3, 236, 12, 180])), SecretKey(Scalar([234, 163, 222, 33, 144, 215, 236, 86, 13, 164, 82, 249, 112, 239, 135, 149, 221, 21, 88, 214, 106, 243, 193, 201, 78, 72, 154, 164, 188, 147, 238, 0])));
/// AFH("gdafh"): gdafh1xrq9866pf3n37krnjvzvttfsveltcfx5tcn9thg437uk2tpjkxw27pcc3sp
static immutable AFH = KeyPair(PublicKey(Point([192, 83, 235, 65, 76, 103, 31, 88, 115, 147, 4, 197, 173, 48, 102, 126, 188, 36, 212, 94, 38, 85, 221, 21, 143, 185, 101, 44, 50, 177, 156, 175])), SecretKey(Scalar([131, 186, 6, 132, 30, 230, 235, 147, 49, 183, 12, 151, 34, 89, 106, 235, 204, 251, 164, 254, 243, 32, 28, 113, 82, 96, 153, 115, 86, 15, 46, 10])));
/// AFI("gdafi"): gdafi1xrq9g66mauy5fww4xan9pryfp4w7f7avwxstn47760gpt0rtnuj77d2vt4m
static immutable AFI = KeyPair(PublicKey(Point([192, 84, 107, 91, 239, 9, 68, 185, 213, 55, 102, 80, 140, 137, 13, 93, 228, 251, 172, 113, 160, 185, 215, 222, 211, 208, 21, 188, 107, 159, 37, 239])), SecretKey(Scalar([225, 157, 100, 75, 101, 193, 30, 10, 87, 87, 57, 98, 93, 126, 254, 230, 125, 162, 87, 147, 23, 147, 213, 57, 231, 81, 17, 162, 13, 144, 61, 8])));
/// AFJ("gdafj"): gdafj1xrq9f669zkqedgd86chyfddqgr9xa5dpqfj5v7nqx88wpetnc6etqh2hqlm
static immutable AFJ = KeyPair(PublicKey(Point([192, 84, 235, 69, 21, 129, 150, 161, 167, 214, 46, 68, 181, 160, 64, 202, 110, 209, 161, 2, 101, 70, 122, 96, 49, 206, 224, 229, 115, 198, 178, 176])), SecretKey(Scalar([126, 220, 88, 167, 113, 161, 76, 42, 21, 187, 15, 95, 186, 198, 18, 138, 42, 63, 81, 42, 112, 202, 36, 185, 135, 105, 185, 29, 185, 70, 222, 11])));
/// AFK("gdafk"): gdafk1xrq9266y6ljxxutzqut7862u5sf6uws8mh2sgn7vrwm2ya053pkpgv7yadm
static immutable AFK = KeyPair(PublicKey(Point([192, 85, 107, 68, 215, 228, 99, 113, 98, 7, 23, 227, 233, 92, 164, 19, 174, 58, 7, 221, 213, 4, 79, 204, 27, 182, 162, 117, 244, 136, 108, 20])), SecretKey(Scalar([232, 243, 76, 203, 14, 117, 2, 191, 68, 154, 104, 7, 95, 78, 148, 11, 73, 252, 194, 104, 126, 197, 53, 240, 153, 157, 234, 169, 127, 147, 12, 1])));
/// AFL("gdafl"): gdafl1xrq9t66xc7c5lfz64vmuuhj0l9sh486943x8m40fpautu6a4474rx2nu9xf
static immutable AFL = KeyPair(PublicKey(Point([192, 85, 235, 70, 199, 177, 79, 164, 90, 171, 55, 206, 94, 79, 249, 97, 122, 159, 69, 172, 76, 125, 213, 233, 15, 120, 190, 107, 181, 175, 170, 51])), SecretKey(Scalar([46, 168, 1, 196, 242, 193, 63, 123, 163, 213, 98, 209, 223, 156, 15, 178, 193, 132, 40, 220, 145, 177, 241, 250, 28, 47, 201, 223, 144, 212, 20, 2])));
/// AFM("gdafm"): gdafm1xrq9v669fv5qm0ryfz65jp0pw857xx95xtefh0j6t2yh5n2vpq2jcttdwu7
static immutable AFM = KeyPair(PublicKey(Point([192, 86, 107, 69, 75, 40, 13, 188, 100, 72, 181, 73, 5, 225, 113, 233, 227, 24, 180, 50, 242, 155, 190, 90, 90, 137, 122, 77, 76, 8, 21, 44])), SecretKey(Scalar([126, 192, 255, 21, 118, 179, 136, 187, 86, 194, 184, 158, 163, 194, 175, 143, 163, 236, 54, 155, 68, 94, 70, 219, 75, 58, 213, 9, 36, 187, 26, 0])));
/// AFN("gdafn"): gdafn1xrq9d66fnnuzfa8q8klyglcpzyqktvn4ryyf6d5fl2tjg0qt9z587q7cr85
static immutable AFN = KeyPair(PublicKey(Point([192, 86, 235, 73, 156, 248, 36, 244, 224, 61, 190, 68, 127, 1, 17, 1, 101, 178, 117, 25, 8, 157, 54, 137, 250, 151, 36, 60, 11, 40, 168, 127])), SecretKey(Scalar([119, 5, 51, 47, 1, 50, 239, 36, 122, 92, 177, 32, 87, 124, 15, 107, 83, 72, 135, 166, 199, 140, 217, 176, 143, 73, 185, 122, 171, 114, 86, 14])));
/// AFO("gdafo"): gdafo1xrq9w66qvs7q5wzsk7dhteruxg3l6ek9vuf2404p4tyspd8ntqstcg6ve4h
static immutable AFO = KeyPair(PublicKey(Point([192, 87, 107, 64, 100, 60, 10, 56, 80, 183, 155, 117, 228, 124, 50, 35, 253, 102, 197, 103, 18, 170, 190, 161, 170, 201, 0, 180, 243, 88, 32, 188])), SecretKey(Scalar([110, 173, 220, 171, 240, 22, 161, 11, 89, 40, 50, 235, 165, 73, 203, 199, 210, 192, 223, 145, 149, 45, 4, 165, 72, 170, 99, 237, 238, 202, 28, 14])));
/// AFP("gdafp"): gdafp1xrq9066cr38fylpxtd53wq2squlycqm3p0cs6kdmv7ayea2x4mx5yaqk8t4
static immutable AFP = KeyPair(PublicKey(Point([192, 87, 235, 88, 28, 78, 146, 124, 38, 91, 105, 23, 1, 80, 7, 62, 76, 3, 113, 11, 241, 13, 89, 187, 103, 186, 76, 245, 70, 174, 205, 66])), SecretKey(Scalar([159, 161, 60, 240, 85, 116, 165, 95, 125, 244, 149, 140, 143, 6, 6, 213, 201, 165, 25, 119, 123, 250, 66, 230, 122, 3, 96, 153, 28, 26, 222, 13])));
/// AFQ("gdafq"): gdafq1xrq9s665820smj89chqk70g3zkhvrv0slwn9affwnsq4az9r2vyec2sd29r
static immutable AFQ = KeyPair(PublicKey(Point([192, 88, 107, 84, 58, 159, 13, 200, 229, 197, 193, 111, 61, 17, 21, 174, 193, 177, 240, 251, 166, 94, 165, 46, 156, 1, 94, 136, 163, 83, 9, 156])), SecretKey(Scalar([169, 202, 191, 191, 39, 58, 139, 213, 202, 253, 189, 247, 227, 77, 61, 222, 101, 7, 137, 139, 53, 171, 169, 47, 184, 90, 95, 234, 32, 203, 217, 0])));
/// AFR("gdafr"): gdafr1xrq9366y588tfe0tdhsykwwsnnxay3mn2cz9qpte8rfs6y9l27gg27z6xdu
static immutable AFR = KeyPair(PublicKey(Point([192, 88, 235, 68, 161, 206, 180, 229, 235, 109, 224, 75, 57, 208, 156, 205, 210, 71, 115, 86, 4, 80, 5, 121, 56, 211, 13, 16, 191, 87, 144, 133])), SecretKey(Scalar([206, 150, 14, 254, 74, 176, 109, 58, 25, 10, 80, 198, 51, 182, 253, 38, 211, 52, 230, 134, 224, 56, 236, 166, 32, 234, 86, 169, 136, 178, 120, 15])));
/// AFS("gdafs"): gdafs1xrq9j66f95jugsqzh4g9y3vu2gspqx0h4m8mrvnn3j57mepnhlq92tmay9v
static immutable AFS = KeyPair(PublicKey(Point([192, 89, 107, 73, 45, 37, 196, 64, 2, 189, 80, 82, 69, 156, 82, 32, 16, 25, 247, 174, 207, 177, 178, 115, 140, 169, 237, 228, 51, 191, 192, 85])), SecretKey(Scalar([94, 193, 229, 241, 159, 34, 171, 76, 87, 201, 8, 99, 25, 147, 148, 70, 29, 181, 93, 82, 253, 121, 84, 32, 66, 35, 223, 196, 84, 237, 178, 14])));
/// AFT("gdaft"): gdaft1xrq9n667wtst6w7u3e0awrt37f9thd8w4tyvnu6cusqkdt7v6zvakg4rmmm
static immutable AFT = KeyPair(PublicKey(Point([192, 89, 235, 94, 114, 224, 189, 59, 220, 142, 95, 215, 13, 113, 242, 74, 187, 180, 238, 170, 200, 201, 243, 88, 228, 1, 102, 175, 204, 208, 153, 219])), SecretKey(Scalar([192, 38, 82, 50, 2, 48, 151, 139, 0, 96, 42, 101, 177, 249, 65, 223, 187, 39, 2, 103, 80, 169, 126, 148, 22, 41, 87, 80, 215, 183, 201, 3])));
/// AFU("gdafu"): gdafu1xrq9566r9xrzj0hrzvxgg7dwgee4pgzkke0qjahl42g2k5k0tyyy74yjn3k
static immutable AFU = KeyPair(PublicKey(Point([192, 90, 107, 67, 41, 134, 41, 62, 227, 19, 12, 132, 121, 174, 70, 115, 80, 160, 86, 182, 94, 9, 118, 255, 170, 144, 171, 82, 207, 89, 8, 79])), SecretKey(Scalar([243, 124, 129, 10, 253, 158, 94, 73, 61, 157, 192, 61, 98, 179, 90, 19, 16, 78, 59, 5, 178, 160, 80, 179, 228, 49, 178, 176, 236, 152, 254, 3])));
/// AFV("gdafv"): gdafv1xrq9466s7c7h3ctya2v63lrsgn9g8f309sc58kcru576r8vy9jwl5yk9d32
static immutable AFV = KeyPair(PublicKey(Point([192, 90, 235, 80, 246, 61, 120, 225, 100, 234, 153, 168, 252, 112, 68, 202, 131, 166, 47, 44, 49, 67, 219, 3, 229, 61, 161, 157, 132, 44, 157, 250])), SecretKey(Scalar([255, 36, 132, 230, 82, 202, 165, 8, 98, 155, 144, 29, 164, 148, 20, 44, 89, 130, 49, 77, 211, 70, 153, 47, 251, 22, 85, 64, 21, 81, 16, 0])));
/// AFW("gdafw"): gdafw1xrq9k66z3cky70zm3yltqkj5c0ttfwtde80n0hs9cuvz3jy9l0uys47lw4n
static immutable AFW = KeyPair(PublicKey(Point([192, 91, 107, 66, 142, 44, 79, 60, 91, 137, 62, 176, 90, 84, 195, 214, 180, 185, 109, 201, 223, 55, 222, 5, 199, 24, 40, 200, 133, 251, 248, 72])), SecretKey(Scalar([219, 80, 255, 33, 192, 172, 82, 214, 188, 101, 45, 253, 40, 49, 37, 182, 152, 18, 201, 31, 76, 57, 213, 214, 104, 173, 29, 125, 75, 240, 59, 2])));
/// AFX("gdafx"): gdafx1xrq9h66rxygkwelky5ds6774rxe360cr32j9nr7tg5s8zgfakxx3xymrghp
static immutable AFX = KeyPair(PublicKey(Point([192, 91, 235, 67, 49, 17, 103, 103, 246, 37, 27, 13, 123, 213, 25, 179, 29, 63, 3, 138, 164, 89, 143, 203, 69, 32, 113, 33, 61, 177, 141, 19])), SecretKey(Scalar([76, 132, 125, 117, 59, 143, 72, 38, 32, 159, 159, 128, 254, 87, 55, 248, 177, 231, 17, 206, 182, 107, 233, 0, 139, 208, 67, 98, 65, 175, 92, 6])));
/// AFY("gdafy"): gdafy1xrq9c66cdc3sumqkwurz9qrzc2fc0qcx9wwjrh0yqcrr3fgjx9adxs40yyj
static immutable AFY = KeyPair(PublicKey(Point([192, 92, 107, 88, 110, 35, 14, 108, 22, 119, 6, 34, 128, 98, 194, 147, 135, 131, 6, 43, 157, 33, 221, 228, 6, 6, 56, 165, 18, 49, 122, 211])), SecretKey(Scalar([9, 255, 144, 150, 13, 221, 181, 63, 147, 186, 232, 70, 193, 226, 229, 68, 45, 77, 175, 143, 44, 74, 221, 177, 46, 224, 83, 51, 16, 19, 26, 9])));
/// AFZ("gdafz"): gdafz1xrq9e66wf8gyt0mlsl5xyf4qz9slq7ka84mllhtu9quza2vn0p24jggy7hc
static immutable AFZ = KeyPair(PublicKey(Point([192, 92, 235, 78, 73, 208, 69, 191, 127, 135, 232, 98, 38, 160, 17, 97, 240, 122, 221, 61, 119, 255, 221, 124, 40, 56, 46, 169, 147, 120, 85, 89])), SecretKey(Scalar([1, 212, 129, 49, 95, 162, 77, 246, 80, 191, 25, 164, 234, 77, 253, 89, 103, 123, 224, 9, 38, 242, 250, 113, 248, 251, 68, 167, 199, 79, 63, 8])));
/// AGA("gdaga"): gdaga1xrqxq66tfyft7j9fl88ej4xrkwhm8qms4ve5va8se64qx3v37q97j6wjqvu
static immutable AGA = KeyPair(PublicKey(Point([192, 96, 107, 75, 73, 18, 191, 72, 169, 249, 207, 153, 84, 195, 179, 175, 179, 131, 112, 171, 51, 70, 116, 240, 206, 170, 3, 69, 145, 240, 11, 233])), SecretKey(Scalar([155, 87, 36, 244, 220, 239, 165, 47, 75, 228, 165, 46, 254, 78, 249, 155, 101, 156, 140, 136, 231, 98, 211, 5, 72, 36, 179, 80, 145, 164, 252, 8])));
/// AGB("gdagb"): gdagb1xrqxp660ymcm7hsh6j8yz23htpws27eat3g84v7lskn7dwvdvgfw5yzzu3v
static immutable AGB = KeyPair(PublicKey(Point([192, 96, 235, 79, 38, 241, 191, 94, 23, 212, 142, 65, 42, 55, 88, 93, 5, 123, 61, 92, 80, 122, 179, 223, 133, 167, 230, 185, 141, 98, 18, 234])), SecretKey(Scalar([131, 44, 68, 137, 234, 187, 44, 159, 171, 11, 5, 207, 133, 198, 61, 204, 187, 132, 110, 148, 39, 105, 129, 193, 241, 127, 110, 65, 58, 250, 117, 12])));
/// AGC("gdagc"): gdagc1xrqxz66yfvygmm7pxn3rq38mf02ur98k7npgc9nazh6mlugx93wesknkhtj
static immutable AGC = KeyPair(PublicKey(Point([192, 97, 107, 68, 75, 8, 141, 239, 193, 52, 226, 48, 68, 251, 75, 213, 193, 148, 246, 244, 194, 140, 22, 125, 21, 245, 191, 241, 6, 44, 93, 152])), SecretKey(Scalar([107, 145, 158, 195, 142, 20, 68, 233, 15, 215, 157, 237, 25, 124, 18, 75, 71, 104, 108, 180, 17, 62, 29, 37, 150, 158, 125, 226, 25, 183, 125, 13])));
/// AGD("gdagd"): gdagd1xrqxr66h0nwha5t55tg9vsqx2fgg906kkxkqcm93asrpe75jlzfr7krfspg
static immutable AGD = KeyPair(PublicKey(Point([192, 97, 235, 87, 124, 221, 126, 209, 116, 162, 208, 86, 64, 6, 82, 80, 130, 191, 86, 177, 172, 12, 108, 177, 236, 6, 28, 250, 146, 248, 146, 63])), SecretKey(Scalar([5, 206, 65, 238, 209, 50, 41, 55, 118, 121, 202, 60, 242, 63, 195, 34, 93, 132, 214, 101, 248, 13, 94, 202, 109, 82, 0, 146, 170, 211, 205, 0])));
/// AGE("gdage"): gdage1xrqxy66td96a2usg78wrtpsx8k4j3lnxtacl9s6xzgll42mnnj74wxqq3zf
static immutable AGE = KeyPair(PublicKey(Point([192, 98, 107, 75, 105, 117, 213, 114, 8, 241, 220, 53, 134, 6, 61, 171, 40, 254, 102, 95, 113, 242, 195, 70, 18, 63, 250, 171, 115, 156, 189, 87])), SecretKey(Scalar([61, 253, 49, 174, 48, 243, 187, 97, 123, 224, 230, 104, 230, 97, 215, 177, 223, 196, 221, 240, 172, 180, 42, 175, 154, 9, 23, 247, 149, 221, 89, 7])));
/// AGF("gdagf"): gdagf1xrqx96640j022nsvn39qqme740sesn6trm4064xxrgktvy7l9ws5xzxdr2a
static immutable AGF = KeyPair(PublicKey(Point([192, 98, 235, 85, 124, 158, 165, 78, 12, 156, 74, 0, 111, 62, 171, 225, 152, 79, 75, 30, 234, 253, 84, 198, 26, 44, 182, 19, 223, 43, 161, 67])), SecretKey(Scalar([122, 139, 186, 48, 67, 232, 190, 196, 243, 221, 165, 5, 125, 230, 217, 74, 13, 88, 81, 182, 18, 220, 180, 8, 60, 210, 64, 109, 64, 121, 80, 2])));
/// AGG("gdagg"): gdagg1xrqxx66pszpkt520w5jvlv526urdpe92ex8u8txym6py27ta3050q5cv73r
static immutable AGG = KeyPair(PublicKey(Point([192, 99, 107, 65, 128, 131, 101, 209, 79, 117, 36, 207, 178, 138, 215, 6, 208, 228, 170, 201, 143, 195, 172, 196, 222, 130, 69, 121, 125, 139, 232, 240])), SecretKey(Scalar([219, 206, 185, 103, 199, 255, 200, 251, 105, 63, 11, 193, 81, 99, 198, 25, 185, 46, 154, 235, 115, 0, 102, 139, 204, 1, 241, 48, 158, 0, 28, 1])));
/// AGH("gdagh"): gdagh1xrqx866svwm8mk0ztxl2tru9eaaghgm26hjv5x2uxmhy6nhu49gvvnk0l7l
static immutable AGH = KeyPair(PublicKey(Point([192, 99, 235, 80, 99, 182, 125, 217, 226, 89, 190, 165, 143, 133, 207, 122, 139, 163, 106, 213, 228, 202, 25, 92, 54, 238, 77, 78, 252, 169, 80, 198])), SecretKey(Scalar([250, 252, 220, 156, 37, 153, 199, 244, 227, 89, 74, 134, 112, 225, 76, 37, 160, 25, 68, 72, 150, 186, 244, 4, 235, 35, 226, 60, 202, 171, 64, 6])));
/// AGI("gdagi"): gdagi1xrqxg66l3rntpty3ham8m6p30gghqu7sjurq7p5azlurg9xce2kscycga4x
static immutable AGI = KeyPair(PublicKey(Point([192, 100, 107, 95, 136, 230, 176, 172, 145, 191, 118, 125, 232, 49, 122, 17, 112, 115, 208, 151, 6, 15, 6, 157, 23, 248, 52, 20, 216, 202, 173, 12])), SecretKey(Scalar([15, 104, 115, 176, 163, 47, 108, 57, 157, 216, 201, 0, 98, 82, 118, 38, 7, 94, 117, 213, 224, 142, 198, 70, 198, 207, 24, 94, 174, 49, 39, 1])));
/// AGJ("gdagj"): gdagj1xrqxf662lzyaq03jwh93wn2zhh29x60c46y9m63jr6332fnqk0djuc0t5zs
static immutable AGJ = KeyPair(PublicKey(Point([192, 100, 235, 74, 248, 137, 208, 62, 50, 117, 203, 23, 77, 66, 189, 212, 83, 105, 248, 174, 136, 93, 234, 50, 30, 163, 21, 38, 96, 179, 219, 46])), SecretKey(Scalar([50, 20, 155, 124, 144, 137, 242, 35, 214, 94, 100, 244, 236, 191, 101, 131, 163, 220, 195, 195, 95, 220, 66, 31, 141, 245, 108, 183, 63, 13, 248, 0])));
/// AGK("gdagk"): gdagk1xrqx266zagfgg3ma75ryr5vrrye8jn0r87g9wuqx8rnvxxwut5z6chnyg0f
static immutable AGK = KeyPair(PublicKey(Point([192, 101, 107, 66, 234, 18, 132, 71, 125, 245, 6, 65, 209, 131, 25, 50, 121, 77, 227, 63, 144, 87, 112, 6, 56, 230, 195, 25, 220, 93, 5, 172])), SecretKey(Scalar([8, 5, 255, 214, 75, 97, 21, 92, 163, 37, 203, 155, 229, 212, 14, 102, 181, 147, 164, 162, 248, 49, 198, 105, 226, 166, 135, 213, 119, 118, 255, 15])));
/// AGL("gdagl"): gdagl1xrqxt662p8qqtqju798zrfc9jml89zmw460c5hksy2pzp3k5wylhw8wldm3
static immutable AGL = KeyPair(PublicKey(Point([192, 101, 235, 74, 9, 192, 5, 130, 92, 241, 78, 33, 167, 5, 150, 254, 114, 139, 110, 174, 159, 138, 94, 208, 34, 130, 32, 198, 212, 113, 63, 119])), SecretKey(Scalar([144, 167, 186, 154, 147, 60, 148, 5, 12, 244, 1, 47, 164, 77, 120, 33, 159, 57, 93, 181, 186, 179, 175, 217, 126, 112, 207, 60, 221, 25, 189, 5])));
/// AGM("gdagm"): gdagm1xrqxv66f6dr8ltc0u7evd6hggp8n93g2dxjqtmn8a346jj97rq88yr5kutu
static immutable AGM = KeyPair(PublicKey(Point([192, 102, 107, 73, 211, 70, 127, 175, 15, 231, 178, 198, 234, 232, 64, 79, 50, 197, 10, 105, 164, 5, 238, 103, 236, 107, 169, 72, 190, 24, 14, 114])), SecretKey(Scalar([202, 115, 105, 182, 102, 0, 175, 144, 142, 33, 66, 66, 215, 3, 149, 235, 252, 19, 67, 52, 68, 9, 242, 136, 239, 116, 95, 106, 217, 176, 62, 1])));
/// AGN("gdagn"): gdagn1xrqxd665wlh63697f45hq86mjkvtvkr2d7599f5hk38lldqnklpaqpsue7h
static immutable AGN = KeyPair(PublicKey(Point([192, 102, 235, 84, 119, 239, 168, 232, 190, 77, 105, 112, 31, 91, 149, 152, 182, 88, 106, 111, 168, 82, 166, 151, 180, 79, 255, 180, 19, 183, 195, 208])), SecretKey(Scalar([211, 191, 220, 141, 209, 222, 14, 118, 199, 211, 65, 199, 193, 210, 225, 41, 10, 89, 104, 125, 147, 38, 4, 75, 86, 131, 18, 254, 245, 172, 9, 0])));
/// AGO("gdago"): gdago1xrqxw66l7n2qt8jxkzeeprchszuf7ck05g4drlws77dxtfale8czjc5x9aj
static immutable AGO = KeyPair(PublicKey(Point([192, 103, 107, 95, 244, 212, 5, 158, 70, 176, 179, 144, 143, 23, 128, 184, 159, 98, 207, 162, 42, 209, 253, 208, 247, 154, 101, 167, 191, 201, 240, 41])), SecretKey(Scalar([14, 17, 170, 45, 134, 228, 113, 2, 72, 72, 215, 201, 70, 112, 255, 168, 11, 173, 23, 161, 188, 130, 214, 248, 208, 118, 70, 242, 117, 91, 234, 10])));
/// AGP("gdagp"): gdagp1xrqx0667ce2tsp5heh3kcrrzwgdf0fg3euqrg06glatv3nj3zkylss4tz0f
static immutable AGP = KeyPair(PublicKey(Point([192, 103, 235, 94, 198, 84, 184, 6, 151, 205, 227, 108, 12, 98, 114, 26, 151, 165, 17, 207, 0, 52, 63, 72, 255, 86, 200, 206, 81, 21, 137, 248])), SecretKey(Scalar([141, 71, 233, 214, 83, 90, 191, 130, 138, 157, 251, 52, 30, 72, 110, 122, 168, 121, 131, 17, 48, 93, 83, 44, 239, 117, 80, 212, 196, 96, 48, 9])));
/// AGQ("gdagq"): gdagq1xrqxs66et6gjufxkq8n8m7ydshhynm4hgzdpvsrjzr0np23ckyv2276csz4
static immutable AGQ = KeyPair(PublicKey(Point([192, 104, 107, 89, 94, 145, 46, 36, 214, 1, 230, 125, 248, 141, 133, 238, 73, 238, 183, 64, 154, 22, 64, 114, 16, 223, 48, 170, 56, 177, 24, 165])), SecretKey(Scalar([218, 86, 177, 3, 131, 182, 35, 115, 223, 115, 60, 10, 231, 130, 157, 228, 77, 128, 34, 70, 217, 134, 122, 137, 255, 81, 200, 211, 20, 98, 120, 12])));
/// AGR("gdagr"): gdagr1xrqx366yn8xktzhtsj83gj0nnj35cv8lrk7xhszj0dfemlacumguj8xc3h9
static immutable AGR = KeyPair(PublicKey(Point([192, 104, 235, 68, 153, 205, 101, 138, 235, 132, 143, 20, 73, 243, 156, 163, 76, 48, 255, 29, 188, 107, 192, 82, 123, 83, 157, 255, 184, 230, 209, 201])), SecretKey(Scalar([86, 208, 161, 19, 221, 91, 118, 233, 208, 219, 42, 134, 62, 145, 12, 169, 133, 77, 106, 66, 85, 33, 162, 37, 25, 17, 178, 153, 46, 7, 93, 11])));
/// AGS("gdags"): gdags1xrqxj66649r2zn6vg9q80f4je8n258v5jyaat39dcrejqw0sjqtu7s8n6tg
static immutable AGS = KeyPair(PublicKey(Point([192, 105, 107, 90, 169, 70, 161, 79, 76, 65, 64, 119, 166, 178, 201, 230, 170, 29, 148, 145, 59, 213, 196, 173, 192, 243, 32, 57, 240, 144, 23, 207])), SecretKey(Scalar([84, 96, 227, 226, 149, 143, 16, 85, 194, 124, 87, 211, 4, 219, 97, 160, 55, 225, 159, 45, 213, 240, 103, 230, 202, 189, 150, 213, 42, 232, 157, 12])));
/// AGT("gdagt"): gdagt1xrqxn66jc0cgfcmjfmvydhqlgkv6ac2fqu9hvdmj59gn7nvh6800x8zd22w
static immutable AGT = KeyPair(PublicKey(Point([192, 105, 235, 82, 195, 240, 132, 227, 114, 78, 216, 70, 220, 31, 69, 153, 174, 225, 73, 7, 11, 118, 55, 114, 161, 81, 63, 77, 151, 209, 222, 243])), SecretKey(Scalar([222, 66, 56, 157, 221, 210, 34, 220, 191, 85, 21, 127, 111, 59, 159, 185, 250, 143, 7, 253, 40, 222, 66, 106, 101, 21, 83, 235, 11, 128, 77, 10])));
/// AGU("gdagu"): gdagu1xrqx5668rhx7wd4xcc9rqyw8rmkd34zklqapwwl676dgc6k87kea6jx4eul
static immutable AGU = KeyPair(PublicKey(Point([192, 106, 107, 71, 29, 205, 231, 54, 166, 198, 10, 48, 17, 199, 30, 236, 216, 212, 86, 248, 58, 23, 59, 250, 246, 154, 140, 106, 199, 245, 179, 221])), SecretKey(Scalar([27, 192, 2, 42, 162, 40, 65, 0, 36, 11, 7, 228, 111, 222, 211, 123, 177, 204, 129, 83, 120, 26, 53, 121, 213, 33, 11, 190, 18, 54, 159, 7])));
/// AGV("gdagv"): gdagv1xrqx466tmpa7udyde29lq5g592ca76tq8erlynd298kr6asyuqwpz0j39sl
static immutable AGV = KeyPair(PublicKey(Point([192, 106, 235, 75, 216, 123, 238, 52, 141, 202, 139, 240, 81, 20, 42, 177, 223, 105, 96, 62, 71, 242, 77, 170, 41, 236, 61, 118, 4, 224, 28, 17])), SecretKey(Scalar([69, 133, 92, 99, 238, 255, 253, 158, 73, 121, 216, 124, 7, 247, 249, 240, 147, 27, 224, 104, 92, 169, 173, 68, 76, 254, 168, 6, 244, 119, 106, 1])));
/// AGW("gdagw"): gdagw1xrqxk66805hv8wnr9kgyt34896pmyutgtqwdcnuf6jft4au4as5m5x52ss9
static immutable AGW = KeyPair(PublicKey(Point([192, 107, 107, 71, 125, 46, 195, 186, 99, 45, 144, 69, 198, 167, 46, 131, 178, 113, 104, 88, 28, 220, 79, 137, 212, 146, 186, 247, 149, 236, 41, 186])), SecretKey(Scalar([198, 172, 239, 169, 101, 150, 99, 177, 41, 150, 158, 42, 55, 45, 145, 17, 244, 160, 210, 85, 152, 208, 180, 219, 78, 69, 172, 106, 25, 107, 103, 0])));
/// AGX("gdagx"): gdagx1xrqxh66t7ldhqu7r8hftcmg2nlqsykanrps35qwdwhtlgedpmcrn7u8qqzc
static immutable AGX = KeyPair(PublicKey(Point([192, 107, 235, 75, 247, 219, 112, 115, 195, 61, 210, 188, 109, 10, 159, 193, 2, 91, 179, 24, 97, 26, 1, 205, 117, 215, 244, 101, 161, 222, 7, 63])), SecretKey(Scalar([51, 234, 79, 72, 103, 63, 97, 213, 68, 94, 126, 91, 206, 112, 144, 59, 128, 193, 199, 37, 178, 27, 216, 22, 197, 87, 113, 183, 234, 117, 52, 1])));
/// AGY("gdagy"): gdagy1xrqxc66lst4h7a23p2l7u4nrte839a67eg8kt08zj8eqr94nk9v0xnctske
static immutable AGY = KeyPair(PublicKey(Point([192, 108, 107, 95, 130, 235, 127, 117, 81, 10, 191, 238, 86, 99, 94, 79, 18, 247, 94, 202, 15, 101, 188, 226, 145, 242, 1, 150, 179, 177, 88, 243])), SecretKey(Scalar([158, 51, 63, 195, 167, 233, 196, 215, 221, 24, 191, 107, 14, 213, 161, 135, 50, 220, 189, 60, 225, 246, 97, 13, 25, 135, 60, 194, 117, 165, 113, 0])));
/// AGZ("gdagz"): gdagz1xrqxe66khmqg27nylj4hmzam5pkdjxnaam4nhepkph4fe74hq3e3z59tukz
static immutable AGZ = KeyPair(PublicKey(Point([192, 108, 235, 86, 190, 192, 133, 122, 100, 252, 171, 125, 139, 187, 160, 108, 217, 26, 125, 238, 235, 59, 228, 54, 13, 234, 156, 250, 183, 4, 115, 17])), SecretKey(Scalar([249, 62, 165, 41, 249, 23, 1, 112, 227, 73, 109, 152, 194, 149, 21, 194, 102, 155, 154, 146, 170, 198, 139, 74, 51, 90, 40, 59, 114, 23, 95, 3])));
/// AHA("gdaha"): gdaha1xrq8q66hdrl74pmats4mx3lg3dcjsc7tdp09hgtv9ek2aw24tc92vj5zuqp
static immutable AHA = KeyPair(PublicKey(Point([192, 112, 107, 87, 104, 255, 234, 135, 125, 92, 43, 179, 71, 232, 139, 113, 40, 99, 203, 104, 94, 91, 161, 108, 46, 108, 174, 185, 85, 94, 10, 166])), SecretKey(Scalar([36, 195, 226, 55, 22, 62, 27, 211, 37, 109, 178, 176, 29, 185, 49, 119, 166, 75, 181, 182, 32, 6, 37, 59, 19, 177, 214, 18, 168, 108, 211, 5])));
/// AHB("gdahb"): gdahb1xrq8p66hq8y3wvymr9x3mrurgfh72n088jps3cenl7ks33aym56dxv79g3p
static immutable AHB = KeyPair(PublicKey(Point([192, 112, 235, 87, 1, 201, 23, 48, 155, 25, 77, 29, 143, 131, 66, 111, 229, 77, 231, 60, 131, 8, 227, 51, 255, 173, 8, 199, 164, 221, 52, 211])), SecretKey(Scalar([128, 61, 40, 223, 254, 144, 139, 235, 79, 96, 39, 48, 189, 251, 230, 54, 161, 121, 92, 226, 58, 155, 153, 33, 115, 238, 8, 37, 230, 20, 141, 3])));
/// AHC("gdahc"): gdahc1xrq8z664xjndmrn23jf9tjkj7lw7vncj8hlszll24yqkf4764x2cjn0w9ew
static immutable AHC = KeyPair(PublicKey(Point([192, 113, 107, 85, 52, 166, 221, 142, 106, 140, 146, 85, 202, 210, 247, 221, 230, 79, 18, 61, 255, 1, 127, 234, 169, 1, 100, 215, 218, 169, 149, 137])), SecretKey(Scalar([57, 49, 153, 27, 248, 219, 241, 52, 13, 177, 42, 172, 63, 159, 7, 150, 123, 169, 66, 222, 23, 240, 164, 48, 29, 114, 102, 65, 125, 74, 19, 12])));
/// AHD("gdahd"): gdahd1xrq8r66kf56k0nwwnyu2jaghsfq8ee7qr8c7q645rhnluwpt4dyn6hnsmxn
static immutable AHD = KeyPair(PublicKey(Point([192, 113, 235, 86, 77, 53, 103, 205, 206, 153, 56, 169, 117, 23, 130, 64, 124, 231, 192, 25, 241, 224, 106, 180, 29, 231, 254, 56, 43, 171, 73, 61])), SecretKey(Scalar([242, 32, 82, 153, 92, 100, 120, 110, 2, 215, 222, 46, 192, 206, 15, 150, 55, 164, 161, 46, 247, 231, 84, 241, 12, 26, 246, 248, 87, 29, 168, 11])));
/// AHE("gdahe"): gdahe1xrq8y66slpmdswwz370vjjzwf8h6v0dxqgpjwkwacy6q3p9fff9d54urlus
static immutable AHE = KeyPair(PublicKey(Point([192, 114, 107, 80, 248, 118, 216, 57, 194, 143, 158, 201, 72, 78, 73, 239, 166, 61, 166, 2, 3, 39, 89, 221, 193, 52, 8, 132, 169, 74, 74, 218])), SecretKey(Scalar([33, 17, 71, 254, 63, 12, 96, 79, 82, 31, 136, 244, 110, 119, 96, 42, 159, 96, 133, 245, 194, 253, 73, 146, 66, 190, 73, 29, 105, 148, 103, 1])));
/// AHF("gdahf"): gdahf1xrq8966mpr9x02td2ceprvjea2lhvlcl3sld508rcg54jrcclpc0kj727cd
static immutable AHF = KeyPair(PublicKey(Point([192, 114, 235, 91, 8, 202, 103, 169, 109, 86, 50, 17, 178, 89, 234, 191, 118, 127, 31, 140, 62, 218, 60, 227, 194, 41, 89, 15, 24, 248, 112, 251])), SecretKey(Scalar([250, 63, 178, 57, 195, 197, 234, 83, 85, 70, 17, 42, 208, 160, 160, 154, 165, 161, 18, 217, 161, 68, 155, 168, 254, 80, 24, 208, 175, 85, 141, 5])));
/// AHG("gdahg"): gdahg1xrq8x66w0mc3cdxul7m80uzvgq6mjdqmzqtvx9zlp7hw9wga896nk3cg7nz
static immutable AHG = KeyPair(PublicKey(Point([192, 115, 107, 78, 126, 241, 28, 52, 220, 255, 182, 119, 240, 76, 64, 53, 185, 52, 27, 16, 22, 195, 20, 95, 15, 174, 226, 185, 29, 57, 117, 59])), SecretKey(Scalar([161, 187, 65, 197, 172, 186, 46, 231, 134, 191, 159, 27, 240, 64, 68, 167, 125, 52, 25, 108, 127, 91, 194, 85, 132, 132, 235, 214, 102, 201, 61, 9])));
/// AHH("gdahh"): gdahh1xrq8866shat3genzz3y8aufk2gmk4lzzzas28za0v5s6jlfpvqevu9az0gw
static immutable AHH = KeyPair(PublicKey(Point([192, 115, 235, 80, 191, 87, 20, 102, 98, 20, 72, 126, 241, 54, 82, 55, 106, 252, 66, 23, 96, 163, 139, 175, 101, 33, 169, 125, 33, 96, 50, 206])), SecretKey(Scalar([76, 162, 12, 245, 115, 199, 126, 54, 78, 231, 22, 89, 82, 182, 174, 111, 208, 152, 50, 198, 82, 37, 14, 162, 23, 161, 145, 153, 170, 51, 250, 0])));
/// AHI("gdahi"): gdahi1xrq8g66xgd62c2amk2q23wlhdd565kxpzadm7mndh6wuayru4hhv5fkvmqh
static immutable AHI = KeyPair(PublicKey(Point([192, 116, 107, 70, 67, 116, 172, 43, 187, 178, 128, 168, 187, 247, 107, 105, 170, 88, 193, 23, 91, 191, 110, 109, 190, 157, 206, 144, 124, 173, 238, 202])), SecretKey(Scalar([208, 189, 205, 210, 157, 149, 64, 74, 35, 0, 49, 184, 235, 68, 178, 210, 173, 254, 104, 187, 105, 55, 110, 209, 200, 126, 92, 252, 100, 243, 142, 5])));
/// AHJ("gdahj"): gdahj1xrq8f668ex82mmlx9amhg7dtdj3c3d9c30mmzy9adxtnqekgxcxfkfqg9z8
static immutable AHJ = KeyPair(PublicKey(Point([192, 116, 235, 71, 201, 142, 173, 239, 230, 47, 119, 116, 121, 171, 108, 163, 136, 180, 184, 139, 247, 177, 16, 189, 105, 151, 48, 102, 200, 54, 12, 155])), SecretKey(Scalar([32, 36, 176, 177, 77, 52, 235, 81, 201, 144, 88, 229, 221, 239, 252, 157, 124, 168, 33, 118, 29, 3, 179, 36, 152, 211, 53, 90, 63, 3, 5, 0])));
/// AHK("gdahk"): gdahk1xrq826639xjshazupw50wfazasn8y95njy9w2c5cjsgjyrtpjuqz67mf58z
static immutable AHK = KeyPair(PublicKey(Point([192, 117, 107, 81, 41, 165, 11, 244, 92, 11, 168, 247, 39, 162, 236, 38, 114, 22, 147, 145, 10, 229, 98, 152, 148, 17, 34, 13, 97, 151, 0, 45])), SecretKey(Scalar([3, 7, 178, 183, 74, 99, 143, 2, 3, 68, 154, 232, 245, 103, 122, 173, 103, 178, 97, 78, 35, 44, 153, 54, 194, 87, 79, 86, 72, 94, 87, 14])));
/// AHL("gdahl"): gdahl1xrq8t66e6fxeuxu54lumdz8l4j8gllpcmf2vam8ydsymjvasthn7wqvdcs6
static immutable AHL = KeyPair(PublicKey(Point([192, 117, 235, 89, 210, 77, 158, 27, 148, 175, 249, 182, 136, 255, 172, 142, 143, 252, 56, 218, 84, 206, 236, 228, 108, 9, 185, 51, 176, 93, 231, 231])), SecretKey(Scalar([80, 156, 62, 47, 14, 90, 9, 162, 234, 216, 186, 217, 62, 207, 83, 123, 212, 171, 245, 237, 166, 90, 135, 157, 203, 148, 204, 130, 4, 90, 46, 8])));
/// AHM("gdahm"): gdahm1xrq8v66zyaz95wyy6sh3mr7rzt80yqy9rk7zfrn6g4xnygm9smhe2rd4uv3
static immutable AHM = KeyPair(PublicKey(Point([192, 118, 107, 66, 39, 68, 90, 56, 132, 212, 47, 29, 143, 195, 18, 206, 242, 0, 133, 29, 188, 36, 142, 122, 69, 77, 50, 35, 101, 134, 239, 149])), SecretKey(Scalar([159, 54, 49, 73, 143, 182, 179, 21, 155, 31, 178, 141, 115, 145, 249, 191, 65, 230, 166, 141, 9, 161, 114, 248, 94, 16, 16, 233, 249, 51, 81, 0])));
/// AHN("gdahn"): gdahn1xrq8d66clyq04m3x8z4sdsnnkrya36v0wpzwgfr3gqn3ddla85y7w4f64c6
static immutable AHN = KeyPair(PublicKey(Point([192, 118, 235, 88, 249, 0, 250, 238, 38, 56, 171, 6, 194, 115, 176, 201, 216, 233, 143, 112, 68, 228, 36, 113, 64, 39, 22, 183, 253, 61, 9, 231])), SecretKey(Scalar([168, 172, 30, 249, 75, 255, 112, 75, 229, 199, 135, 40, 85, 102, 242, 27, 10, 16, 7, 51, 60, 156, 147, 29, 186, 48, 97, 98, 59, 108, 90, 0])));
/// AHO("gdaho"): gdaho1xrq8w66q65kpe06dxdru6l4y9mmewnzwa6umqdgczezt2xue485xk79kynu
static immutable AHO = KeyPair(PublicKey(Point([192, 119, 107, 64, 213, 44, 28, 191, 77, 51, 71, 205, 126, 164, 46, 247, 151, 76, 78, 238, 185, 176, 53, 24, 22, 68, 181, 27, 153, 169, 232, 107])), SecretKey(Scalar([89, 245, 106, 170, 2, 211, 7, 125, 155, 51, 230, 165, 90, 18, 192, 201, 91, 228, 136, 201, 0, 158, 92, 171, 159, 116, 128, 39, 13, 209, 23, 1])));
/// AHP("gdahp"): gdahp1xrq80668khcqgg44r9jchwu8u3gtrkhk5wzx4ptdn0ulngrexlru73z859l
static immutable AHP = KeyPair(PublicKey(Point([192, 119, 235, 71, 181, 240, 4, 34, 181, 25, 101, 139, 187, 135, 228, 80, 177, 218, 246, 163, 132, 106, 133, 109, 155, 249, 249, 160, 121, 55, 199, 207])), SecretKey(Scalar([45, 153, 139, 19, 110, 249, 211, 211, 45, 122, 161, 219, 244, 182, 146, 223, 243, 195, 143, 114, 43, 5, 81, 93, 94, 46, 247, 91, 112, 70, 134, 11])));
/// AHQ("gdahq"): gdahq1xrq8s66h96r3xrdmh68yz0q8wke3ayhkdnm30n5gs2wqff4rh4m057gv8wr
static immutable AHQ = KeyPair(PublicKey(Point([192, 120, 107, 87, 46, 135, 19, 13, 187, 190, 142, 65, 60, 7, 117, 179, 30, 146, 246, 108, 247, 23, 206, 136, 130, 156, 4, 166, 163, 189, 118, 250])), SecretKey(Scalar([237, 200, 156, 47, 116, 141, 41, 255, 82, 221, 182, 180, 15, 204, 216, 51, 39, 50, 201, 159, 36, 146, 6, 108, 102, 175, 205, 85, 0, 156, 65, 2])));
/// AHR("gdahr"): gdahr1xrq8366fj0fx0kwknwqu2mull6nf007p280ev50hn0t4cs80xu7ev2yh2pw
static immutable AHR = KeyPair(PublicKey(Point([192, 120, 235, 73, 147, 210, 103, 217, 214, 155, 129, 197, 111, 159, 254, 166, 151, 191, 193, 81, 223, 150, 81, 247, 155, 215, 92, 64, 239, 55, 61, 150])), SecretKey(Scalar([76, 244, 38, 35, 96, 191, 88, 237, 103, 218, 210, 7, 12, 9, 218, 244, 128, 7, 199, 153, 175, 206, 150, 166, 82, 157, 13, 214, 27, 248, 205, 2])));
/// AHS("gdahs"): gdahs1xrq8j660sd25sdpt5qwuhcq9pu7jsqv3mwq0zjn2vawaaw80xxwf25e9nup
static immutable AHS = KeyPair(PublicKey(Point([192, 121, 107, 79, 131, 85, 72, 52, 43, 160, 29, 203, 224, 5, 15, 61, 40, 1, 145, 219, 128, 241, 74, 106, 103, 93, 222, 184, 239, 49, 156, 149])), SecretKey(Scalar([82, 209, 181, 143, 7, 145, 27, 186, 117, 72, 46, 214, 41, 57, 218, 132, 254, 36, 205, 235, 18, 150, 153, 95, 113, 96, 165, 224, 66, 107, 193, 6])));
/// AHT("gdaht"): gdaht1xrq8n666ch0j94w3jckjx42xmatrlveqlmwshtjfxrllle4dm669wqfrxpt
static immutable AHT = KeyPair(PublicKey(Point([192, 121, 235, 90, 197, 223, 34, 213, 209, 150, 45, 35, 85, 70, 223, 86, 63, 179, 32, 254, 221, 11, 174, 73, 48, 255, 255, 230, 173, 222, 180, 87])), SecretKey(Scalar([118, 207, 59, 57, 33, 170, 211, 245, 223, 158, 157, 148, 32, 197, 154, 250, 118, 85, 237, 146, 31, 39, 147, 123, 203, 100, 93, 147, 223, 126, 226, 10])));
/// AHU("gdahu"): gdahu1xrq8566ctj6wk50xv2znzruhhwexdqh93jfxrsajpzyt6nlce6hwvsca9am
static immutable AHU = KeyPair(PublicKey(Point([192, 122, 107, 88, 92, 180, 235, 81, 230, 98, 133, 49, 15, 151, 187, 178, 102, 130, 229, 140, 146, 97, 195, 178, 8, 136, 189, 79, 248, 206, 174, 230])), SecretKey(Scalar([235, 44, 43, 56, 104, 160, 81, 58, 165, 5, 103, 163, 251, 62, 45, 12, 64, 145, 224, 207, 41, 80, 234, 230, 242, 129, 231, 247, 19, 57, 99, 0])));
/// AHV("gdahv"): gdahv1xrq8466x767lzfx6m9zf9ds4fyyk7f7mdurkytswn2fyte57yapduuvkwwm
static immutable AHV = KeyPair(PublicKey(Point([192, 122, 235, 70, 246, 189, 241, 36, 218, 217, 68, 146, 182, 21, 73, 9, 111, 39, 219, 111, 7, 98, 46, 14, 154, 146, 69, 230, 158, 39, 66, 222])), SecretKey(Scalar([45, 44, 208, 204, 114, 113, 118, 62, 240, 42, 45, 194, 126, 125, 67, 101, 224, 103, 93, 177, 253, 239, 190, 160, 162, 237, 158, 9, 218, 10, 159, 11])));
/// AHW("gdahw"): gdahw1xrq8k66h377jaf3y2kwhgtwp9x8cceslv2lmsqwam9ptj08q9jqmk53s72s
static immutable AHW = KeyPair(PublicKey(Point([192, 123, 107, 87, 143, 189, 46, 166, 36, 85, 157, 116, 45, 193, 41, 143, 140, 102, 31, 98, 191, 184, 1, 221, 217, 66, 185, 60, 224, 44, 129, 187])), SecretKey(Scalar([100, 184, 71, 102, 162, 255, 45, 71, 238, 216, 27, 176, 165, 9, 179, 180, 253, 167, 219, 252, 232, 102, 143, 65, 47, 112, 45, 85, 205, 110, 236, 1])));
/// AHX("gdahx"): gdahx1xrq8h6684d35wssczk6pvul5t9awjk6cpet2ujf4vtjdzk3pdqnv62nz4le
static immutable AHX = KeyPair(PublicKey(Point([192, 123, 235, 71, 171, 99, 71, 66, 24, 21, 180, 22, 115, 244, 89, 122, 233, 91, 88, 14, 86, 174, 73, 53, 98, 228, 209, 90, 33, 104, 38, 205])), SecretKey(Scalar([129, 34, 10, 223, 255, 4, 125, 179, 139, 110, 245, 223, 170, 69, 79, 225, 218, 211, 192, 207, 14, 237, 190, 131, 185, 73, 95, 183, 149, 176, 43, 12])));
/// AHY("gdahy"): gdahy1xrq8c66qg9lfprc0zqh26gj2yhh4037knwj35w27m77gyake9p7tk4lsyxm
static immutable AHY = KeyPair(PublicKey(Point([192, 124, 107, 64, 65, 126, 144, 143, 15, 16, 46, 173, 34, 74, 37, 239, 87, 199, 214, 155, 165, 26, 57, 94, 223, 188, 130, 118, 217, 40, 124, 187])), SecretKey(Scalar([238, 232, 56, 255, 10, 90, 238, 159, 104, 87, 110, 177, 99, 242, 81, 176, 35, 93, 72, 110, 139, 143, 129, 49, 237, 139, 29, 75, 114, 149, 228, 10])));
/// AHZ("gdahz"): gdahz1xrq8e66nz7pkyp07ewlgq3a39adpjw3l0dkyqjh736qha8hpq662c9kj543
static immutable AHZ = KeyPair(PublicKey(Point([192, 124, 235, 83, 23, 131, 98, 5, 254, 203, 190, 128, 71, 177, 47, 90, 25, 58, 63, 123, 108, 64, 74, 254, 142, 129, 126, 158, 225, 6, 180, 172])), SecretKey(Scalar([114, 168, 44, 42, 44, 216, 104, 196, 167, 125, 176, 141, 186, 210, 67, 253, 146, 162, 0, 240, 212, 100, 104, 63, 213, 64, 9, 222, 252, 150, 30, 13])));
/// AIA("gdaia"): gdaia1xrqgq66wa3yz38x3f34w2tgg4uy2f9ggynukuxuh5w5rzf8wkmdekwnde0p
static immutable AIA = KeyPair(PublicKey(Point([192, 128, 107, 78, 236, 72, 40, 156, 209, 76, 106, 229, 45, 8, 175, 8, 164, 149, 8, 36, 249, 110, 27, 151, 163, 168, 49, 36, 238, 182, 219, 155])), SecretKey(Scalar([209, 89, 78, 63, 22, 207, 206, 199, 199, 68, 119, 41, 247, 106, 250, 197, 36, 140, 232, 41, 75, 228, 127, 56, 73, 65, 93, 156, 61, 210, 58, 2])));
/// AIB("gdaib"): gdaib1xrqgp66x9pfnt9paxe0qml9p5ynqc5tx08rwatfrkvrlt3qx8437uawnm0m
static immutable AIB = KeyPair(PublicKey(Point([192, 128, 235, 70, 40, 83, 53, 148, 61, 54, 94, 13, 252, 161, 161, 38, 12, 81, 102, 121, 198, 238, 173, 35, 179, 7, 245, 196, 6, 61, 99, 238])), SecretKey(Scalar([200, 5, 149, 169, 55, 175, 16, 65, 9, 90, 255, 126, 174, 71, 233, 165, 163, 100, 188, 43, 244, 255, 27, 88, 144, 137, 39, 151, 196, 215, 157, 0])));
/// AIC("gdaic"): gdaic1xrqgz66d94047j8dws77wugathzp06yyhmy9r08e44e8af8c7eq3c3xmfwg
static immutable AIC = KeyPair(PublicKey(Point([192, 129, 107, 77, 45, 95, 95, 72, 237, 116, 61, 231, 113, 29, 93, 196, 23, 232, 132, 190, 200, 81, 188, 249, 173, 114, 126, 164, 248, 246, 65, 28])), SecretKey(Scalar([112, 108, 120, 203, 64, 194, 156, 212, 203, 227, 93, 128, 236, 18, 71, 182, 202, 5, 94, 48, 199, 234, 225, 69, 199, 238, 106, 214, 241, 37, 207, 15])));
/// AID("gdaid"): gdaid1xrqgr666pp3gpe37mptgnftnndeue9w704z5m58cqmssus45d265kfl9yna
static immutable AID = KeyPair(PublicKey(Point([192, 129, 235, 90, 8, 98, 128, 230, 62, 216, 86, 137, 165, 115, 155, 115, 204, 149, 222, 125, 69, 77, 208, 248, 6, 225, 14, 66, 180, 106, 181, 75])), SecretKey(Scalar([72, 248, 66, 47, 20, 102, 55, 113, 11, 154, 115, 43, 106, 204, 199, 57, 195, 46, 26, 36, 38, 6, 59, 107, 63, 200, 80, 57, 230, 156, 226, 10])));
/// AIE("gdaie"): gdaie1xrqgy6673nehs87hsef2hzk3l3naag8wr7s3cda7s0re6rgjs0lezjel5kp
static immutable AIE = KeyPair(PublicKey(Point([192, 130, 107, 94, 140, 243, 120, 31, 215, 134, 82, 171, 138, 209, 252, 103, 222, 160, 238, 31, 161, 28, 55, 190, 131, 199, 157, 13, 18, 131, 255, 145])), SecretKey(Scalar([79, 236, 153, 21, 16, 217, 21, 135, 74, 251, 125, 97, 152, 61, 190, 6, 31, 162, 173, 105, 179, 168, 95, 69, 130, 104, 134, 246, 223, 5, 83, 2])));
/// AIF("gdaif"): gdaif1xrqg9662xlfcec7hcrvpu02nqtzx70sxcy92tm8k3pfcl3kvmvl9kg9a2d9
static immutable AIF = KeyPair(PublicKey(Point([192, 130, 235, 74, 55, 211, 140, 227, 215, 192, 216, 30, 61, 83, 2, 196, 111, 62, 6, 193, 10, 165, 236, 246, 136, 83, 143, 198, 204, 219, 62, 91])), SecretKey(Scalar([133, 9, 218, 186, 116, 111, 117, 186, 161, 160, 241, 234, 82, 226, 140, 244, 55, 141, 107, 4, 46, 183, 164, 12, 41, 145, 243, 44, 185, 160, 216, 10])));
/// AIG("gdaig"): gdaig1xrqgx66v5zkf9wk6p3lw2hverxk6rae9m9p2acd7f5srlalx59ek6dr8wee
static immutable AIG = KeyPair(PublicKey(Point([192, 131, 107, 76, 160, 172, 146, 186, 218, 12, 126, 229, 93, 153, 25, 173, 161, 247, 37, 217, 66, 174, 225, 190, 77, 32, 63, 247, 230, 161, 115, 109])), SecretKey(Scalar([163, 114, 16, 128, 243, 9, 91, 113, 236, 145, 87, 84, 169, 30, 33, 134, 245, 114, 210, 246, 140, 39, 168, 48, 72, 244, 175, 127, 79, 230, 190, 13])));
/// AIH("gdaih"): gdaih1xrqg866fl85l09engkprafsf0f92u5nqccj9frjpsesulfhd03gjy7g4hlv
static immutable AIH = KeyPair(PublicKey(Point([192, 131, 235, 73, 249, 233, 247, 151, 51, 69, 130, 62, 166, 9, 122, 74, 174, 82, 96, 198, 36, 84, 142, 65, 134, 97, 207, 166, 237, 124, 81, 34])), SecretKey(Scalar([117, 186, 5, 215, 24, 237, 158, 8, 174, 126, 90, 70, 147, 250, 190, 224, 53, 40, 120, 227, 215, 31, 104, 14, 128, 231, 116, 117, 55, 159, 53, 11])));
/// AII("gdaii"): gdaii1xrqgg66par5zuf502rdl98hrjpnh6g4r2hslfxrfhlp60t69f0p2x30zt02
static immutable AII = KeyPair(PublicKey(Point([192, 132, 107, 65, 232, 232, 46, 38, 143, 80, 219, 242, 158, 227, 144, 103, 125, 34, 163, 85, 225, 244, 152, 105, 191, 195, 167, 175, 69, 75, 194, 163])), SecretKey(Scalar([70, 225, 177, 202, 186, 48, 197, 29, 57, 122, 128, 109, 178, 206, 16, 35, 19, 193, 135, 54, 4, 121, 39, 108, 184, 24, 52, 114, 170, 7, 165, 10])));
/// AIJ("gdaij"): gdaij1xrqgf66e025eg3c0qrqds3mgx6xue6nfucgdgjkdqn20e4l7c46rv5l6tk5
static immutable AIJ = KeyPair(PublicKey(Point([192, 132, 235, 89, 122, 169, 148, 71, 15, 0, 192, 216, 71, 104, 54, 141, 204, 234, 105, 230, 16, 212, 74, 205, 4, 212, 252, 215, 254, 197, 116, 54])), SecretKey(Scalar([57, 56, 53, 247, 207, 3, 231, 141, 197, 43, 17, 58, 250, 179, 71, 203, 2, 209, 216, 219, 93, 55, 70, 32, 177, 227, 135, 119, 248, 189, 100, 2])));
/// AIK("gdaik"): gdaik1xrqg266m29nrk8ss77fu6a9cwz2a6m54dlaqcl7xhl7lpk85p6yzwtswz2e
static immutable AIK = KeyPair(PublicKey(Point([192, 133, 107, 91, 81, 102, 59, 30, 16, 247, 147, 205, 116, 184, 112, 149, 221, 110, 149, 111, 250, 12, 127, 198, 191, 253, 240, 216, 244, 14, 136, 39])), SecretKey(Scalar([113, 81, 77, 173, 48, 25, 132, 38, 235, 187, 100, 166, 208, 82, 177, 75, 120, 43, 143, 195, 193, 250, 143, 109, 172, 86, 10, 159, 239, 43, 75, 1])));
/// AIL("gdail"): gdail1xrqgt66cralh3axppjt624z50s0z0r8wfxy9du7q0rxvpk2xgad3xzjdgnk
static immutable AIL = KeyPair(PublicKey(Point([192, 133, 235, 88, 31, 127, 120, 244, 193, 12, 151, 165, 84, 84, 124, 30, 39, 140, 238, 73, 136, 86, 243, 192, 120, 204, 192, 217, 70, 71, 91, 19])), SecretKey(Scalar([177, 143, 54, 51, 197, 244, 206, 107, 85, 113, 105, 193, 194, 111, 157, 72, 43, 40, 45, 232, 51, 53, 33, 55, 188, 149, 0, 148, 19, 215, 164, 6])));
/// AIM("gdaim"): gdaim1xrqgv66r5vaqwjt3vtd86yd0mgd3rmcucgpjz8e9gd3efh299nc7u67c2tl
static immutable AIM = KeyPair(PublicKey(Point([192, 134, 107, 67, 163, 58, 7, 73, 113, 98, 218, 125, 17, 175, 218, 27, 17, 239, 28, 194, 3, 33, 31, 37, 67, 99, 148, 221, 69, 44, 241, 238])), SecretKey(Scalar([74, 220, 91, 113, 113, 1, 50, 168, 34, 76, 123, 221, 111, 10, 114, 78, 251, 98, 103, 242, 58, 169, 113, 211, 75, 15, 116, 44, 96, 197, 10, 10])));
/// AIN("gdain"): gdain1xrqgd66j70rcfc0rqzgtavrww5t0wz0h3aelywp4yprhvvmryvmlgwwy66h
static immutable AIN = KeyPair(PublicKey(Point([192, 134, 235, 82, 243, 199, 132, 225, 227, 0, 144, 190, 176, 110, 117, 22, 247, 9, 247, 143, 115, 242, 56, 53, 32, 71, 118, 51, 99, 35, 55, 244])), SecretKey(Scalar([80, 6, 214, 19, 192, 247, 255, 53, 216, 145, 126, 42, 121, 198, 253, 81, 65, 63, 157, 145, 222, 218, 114, 177, 152, 153, 210, 136, 67, 83, 172, 8])));
/// AIO("gdaio"): gdaio1xrqgw66e6wthgaa8w2pwkwj90kkjeqn6fp7ak0w79aah674jxme4w0xus96
static immutable AIO = KeyPair(PublicKey(Point([192, 135, 107, 89, 211, 151, 116, 119, 167, 114, 130, 235, 58, 69, 125, 173, 44, 130, 122, 72, 125, 219, 61, 222, 47, 123, 125, 122, 178, 54, 243, 87])), SecretKey(Scalar([239, 246, 15, 149, 64, 43, 71, 161, 181, 246, 100, 243, 225, 78, 61, 130, 201, 55, 230, 164, 43, 161, 60, 44, 168, 55, 57, 8, 204, 126, 65, 4])));
/// AIP("gdaip"): gdaip1xrqg066hk0kmwjp5l0mrgtearfllsh27f5cvhw3at4r7ve6tnh5a5f49d9z
static immutable AIP = KeyPair(PublicKey(Point([192, 135, 235, 87, 179, 237, 183, 72, 52, 251, 246, 52, 47, 61, 26, 127, 248, 93, 94, 77, 48, 203, 186, 61, 93, 71, 230, 103, 75, 157, 233, 218])), SecretKey(Scalar([48, 209, 13, 55, 107, 234, 93, 101, 197, 92, 235, 108, 53, 176, 174, 182, 137, 249, 22, 162, 237, 117, 64, 210, 20, 101, 0, 19, 78, 46, 17, 5])));
/// AIQ("gdaiq"): gdaiq1xrqgs66qvgn0v73yvkecnpakcwxjjhrpvhzdp9u2kjceenl7k9x25grhfyh
static immutable AIQ = KeyPair(PublicKey(Point([192, 136, 107, 64, 98, 38, 246, 122, 36, 101, 179, 137, 135, 182, 195, 141, 41, 92, 97, 101, 196, 208, 151, 138, 180, 177, 156, 207, 254, 177, 76, 170])), SecretKey(Scalar([96, 58, 17, 116, 161, 25, 237, 177, 244, 83, 96, 173, 65, 155, 169, 245, 98, 24, 90, 99, 100, 210, 54, 252, 187, 110, 79, 241, 141, 99, 83, 11])));
/// AIR("gdair"): gdair1xrqg366wcn5tx853mzv28llyppawlr8r46ualgjj0rfxf0f3u7cj5td2e5k
static immutable AIR = KeyPair(PublicKey(Point([192, 136, 235, 78, 196, 232, 179, 30, 145, 216, 152, 163, 255, 228, 8, 122, 239, 140, 227, 174, 185, 223, 162, 82, 120, 210, 100, 189, 49, 231, 177, 42])), SecretKey(Scalar([29, 86, 38, 0, 40, 31, 37, 86, 11, 60, 72, 1, 74, 88, 0, 42, 205, 32, 210, 127, 67, 19, 70, 218, 156, 175, 147, 170, 203, 57, 51, 0])));
/// AIS("gdais"): gdais1xrqgj669rqaj32e8yfmsut8r5a5zzcxr6al05a9pvjjscdpu6539s5c0fwk
static immutable AIS = KeyPair(PublicKey(Point([192, 137, 107, 69, 24, 59, 40, 171, 39, 34, 119, 14, 44, 227, 167, 104, 33, 96, 195, 215, 126, 250, 116, 161, 100, 165, 12, 52, 60, 213, 34, 88])), SecretKey(Scalar([75, 230, 226, 124, 161, 192, 120, 232, 114, 228, 161, 198, 222, 70, 208, 34, 134, 145, 253, 252, 153, 138, 226, 121, 53, 230, 71, 170, 185, 72, 59, 4])));
/// AIT("gdait"): gdait1xrqgn66p7j6f6agmknun6fz4yxay676k4x687txdgxwhgjp7rt39zv44zy2
static immutable AIT = KeyPair(PublicKey(Point([192, 137, 235, 65, 244, 180, 157, 117, 27, 180, 249, 61, 36, 85, 33, 186, 77, 123, 86, 169, 180, 127, 44, 205, 65, 157, 116, 72, 62, 26, 226, 81])), SecretKey(Scalar([246, 101, 158, 243, 225, 224, 11, 250, 53, 233, 251, 213, 107, 23, 187, 213, 18, 194, 89, 181, 163, 235, 17, 161, 40, 126, 31, 115, 47, 189, 142, 5])));
/// AIU("gdaiu"): gdaiu1xrqg5669pqhw8rmhtwxxamcsx6nsqdrukkffr8uvaufrxyr9x7dlu5r5gaj
static immutable AIU = KeyPair(PublicKey(Point([192, 138, 107, 69, 8, 46, 227, 143, 119, 91, 140, 110, 239, 16, 54, 167, 0, 52, 124, 181, 146, 145, 159, 140, 239, 18, 51, 16, 101, 55, 155, 254])), SecretKey(Scalar([177, 103, 59, 215, 252, 133, 69, 28, 209, 197, 53, 168, 247, 201, 28, 64, 95, 61, 196, 68, 123, 115, 66, 3, 26, 163, 60, 107, 21, 212, 0, 7])));
/// AIV("gdaiv"): gdaiv1xrqg466229qpqw6w5pgmcnx4jwqwelz0flc30prjdm5x0dd8g78gq32cysm
static immutable AIV = KeyPair(PublicKey(Point([192, 138, 235, 74, 81, 64, 16, 59, 78, 160, 81, 188, 76, 213, 147, 128, 236, 252, 79, 79, 241, 23, 132, 114, 110, 232, 103, 181, 167, 71, 142, 128])), SecretKey(Scalar([202, 75, 98, 29, 188, 71, 112, 92, 193, 176, 195, 1, 169, 166, 158, 135, 224, 131, 102, 153, 161, 138, 41, 218, 249, 146, 254, 2, 187, 36, 127, 10])));
/// AIW("gdaiw"): gdaiw1xrqgk6696svprr50g3f82u93flst6vlw8wjq2rlrfaecmvxwu4whq9wug6v
static immutable AIW = KeyPair(PublicKey(Point([192, 139, 107, 69, 212, 24, 17, 142, 143, 68, 82, 117, 112, 177, 79, 224, 189, 51, 238, 59, 164, 5, 15, 227, 79, 115, 141, 176, 206, 229, 93, 112])), SecretKey(Scalar([97, 215, 98, 208, 226, 34, 225, 121, 34, 106, 13, 192, 143, 200, 86, 22, 28, 132, 95, 68, 218, 171, 49, 166, 171, 140, 126, 44, 30, 18, 53, 14])));
/// AIX("gdaix"): gdaix1xrqgh66ta75ydq0d8w74x5lk5dnh8e5jr8a4ux6889xd33367649qm0qalz
static immutable AIX = KeyPair(PublicKey(Point([192, 139, 235, 75, 239, 168, 70, 129, 237, 59, 189, 83, 83, 246, 163, 103, 115, 230, 146, 25, 251, 94, 27, 71, 57, 76, 216, 198, 58, 246, 170, 80])), SecretKey(Scalar([129, 1, 95, 16, 166, 160, 70, 65, 158, 42, 127, 222, 130, 190, 58, 130, 35, 159, 45, 220, 3, 52, 70, 140, 11, 90, 174, 154, 82, 201, 144, 2])));
/// AIY("gdaiy"): gdaiy1xrqgc66y9npqr2t93xqymzyxn6nlpm0ur4y3n3nn5ex98pfcvk5a78fsk6x
static immutable AIY = KeyPair(PublicKey(Point([192, 140, 107, 68, 44, 194, 1, 169, 101, 137, 128, 77, 136, 134, 158, 167, 240, 237, 252, 29, 73, 25, 198, 115, 166, 76, 83, 133, 56, 101, 169, 223])), SecretKey(Scalar([80, 230, 91, 169, 65, 138, 40, 234, 140, 52, 205, 33, 229, 60, 129, 145, 148, 0, 133, 250, 27, 245, 248, 147, 116, 220, 208, 230, 218, 199, 232, 6])));
/// AIZ("gdaiz"): gdaiz1xrqge66k3am9cczusyh96zt5jax6jjfrg7v3cwkrs69yywux0jfngsp044u
static immutable AIZ = KeyPair(PublicKey(Point([192, 140, 235, 86, 143, 118, 92, 96, 92, 129, 46, 93, 9, 116, 151, 77, 169, 73, 35, 71, 153, 28, 58, 195, 134, 138, 66, 59, 134, 124, 147, 52])), SecretKey(Scalar([204, 82, 158, 199, 242, 32, 110, 172, 251, 234, 218, 112, 78, 95, 28, 100, 21, 96, 214, 38, 188, 221, 178, 131, 230, 226, 184, 83, 210, 255, 69, 0])));
/// AJA("gdaja"): gdaja1xrqfq66t3wtxcmm7qywd7r39yljdnzcyswaw6gr9tzkqa44tjt6jqj86h8r
static immutable AJA = KeyPair(PublicKey(Point([192, 144, 107, 75, 139, 150, 108, 111, 126, 1, 28, 223, 14, 37, 39, 228, 217, 139, 4, 131, 186, 237, 32, 101, 88, 172, 14, 214, 171, 146, 245, 32])), SecretKey(Scalar([66, 114, 194, 147, 170, 93, 169, 102, 5, 95, 89, 220, 147, 141, 132, 174, 22, 200, 182, 226, 112, 46, 77, 174, 189, 137, 220, 27, 188, 194, 94, 2])));
/// AJB("gdajb"): gdajb1xrqfp66dmshrgwpnwmhx3nt9hts5vztnlku4h9sl3ljtwrx07t7h2k7qj9r
static immutable AJB = KeyPair(PublicKey(Point([192, 144, 235, 77, 220, 46, 52, 56, 51, 118, 238, 104, 205, 101, 186, 225, 70, 9, 115, 253, 185, 91, 150, 31, 143, 228, 183, 12, 207, 242, 253, 117])), SecretKey(Scalar([158, 93, 231, 190, 247, 191, 176, 166, 36, 54, 77, 33, 83, 6, 155, 59, 24, 105, 116, 134, 98, 125, 90, 192, 172, 123, 74, 234, 93, 204, 89, 10])));
/// AJC("gdajc"): gdajc1xrqfz66apyzclkny7rheequafavu4d2tuatkjjy27g2xux623hv2jam5xc2
static immutable AJC = KeyPair(PublicKey(Point([192, 145, 107, 93, 9, 5, 143, 218, 100, 240, 239, 156, 131, 157, 79, 89, 202, 181, 75, 231, 87, 105, 72, 138, 242, 20, 110, 27, 74, 141, 216, 169])), SecretKey(Scalar([122, 41, 75, 116, 64, 211, 149, 216, 148, 95, 92, 99, 7, 212, 5, 139, 219, 56, 94, 249, 222, 63, 46, 136, 220, 173, 200, 141, 161, 248, 253, 0])));
/// AJD("gdajd"): gdajd1xrqfr66n8fvglj2nmnsauhqmadt5qcn6rfk040nkauxwhhxmk7lwk8hxxj5
static immutable AJD = KeyPair(PublicKey(Point([192, 145, 235, 83, 58, 88, 143, 201, 83, 220, 225, 222, 92, 27, 235, 87, 64, 98, 122, 26, 108, 250, 190, 118, 239, 12, 235, 220, 219, 183, 190, 235])), SecretKey(Scalar([253, 58, 144, 10, 100, 97, 38, 138, 216, 93, 26, 112, 144, 151, 196, 30, 12, 44, 180, 148, 67, 179, 141, 55, 136, 3, 129, 127, 248, 85, 88, 8])));
/// AJE("gdaje"): gdaje1xrqfy663u54gamr43tql6jufnznkfscpdtuqzjgc3czr7ug4446xzmg6hqj
static immutable AJE = KeyPair(PublicKey(Point([192, 146, 107, 81, 229, 42, 142, 236, 117, 138, 193, 253, 75, 137, 152, 167, 100, 195, 1, 106, 248, 1, 73, 24, 142, 4, 63, 113, 21, 173, 116, 97])), SecretKey(Scalar([250, 249, 55, 116, 117, 21, 172, 64, 128, 226, 35, 243, 114, 109, 88, 208, 247, 39, 122, 70, 56, 57, 7, 53, 107, 55, 237, 151, 125, 189, 32, 4])));
/// AJF("gdajf"): gdajf1xrqf9666ufeekh8c3x799nen5kps39du9msj66nxtek90p7flk26qchzyvl
static immutable AJF = KeyPair(PublicKey(Point([192, 146, 235, 90, 226, 115, 155, 92, 248, 137, 188, 82, 207, 51, 165, 131, 8, 149, 188, 46, 225, 45, 106, 102, 94, 108, 87, 135, 201, 253, 149, 160])), SecretKey(Scalar([213, 7, 100, 116, 38, 50, 46, 177, 126, 81, 220, 149, 147, 13, 179, 141, 224, 81, 13, 100, 204, 123, 219, 228, 33, 11, 153, 3, 78, 84, 39, 4])));
/// AJG("gdajg"): gdajg1xrqfx66w98tvlwa7y572asv6e5vjuetp9u23jd47xjm5yvgdslw5uv2hllh
static immutable AJG = KeyPair(PublicKey(Point([192, 147, 107, 78, 41, 214, 207, 187, 190, 37, 60, 174, 193, 154, 205, 25, 46, 101, 97, 47, 21, 25, 54, 190, 52, 183, 66, 49, 13, 135, 221, 78])), SecretKey(Scalar([247, 114, 153, 60, 188, 25, 147, 29, 241, 34, 61, 164, 246, 185, 238, 130, 93, 83, 62, 160, 107, 68, 219, 34, 198, 18, 139, 204, 117, 96, 196, 4])));
/// AJH("gdajh"): gdajh1xrqf8663k026agwnyla3ewlf5k8mg2y459adxa8nzqwlgnl08grvcfzqy0w
static immutable AJH = KeyPair(PublicKey(Point([192, 147, 235, 81, 179, 213, 174, 161, 211, 39, 251, 28, 187, 233, 165, 143, 180, 40, 149, 161, 122, 211, 116, 243, 16, 29, 244, 79, 239, 58, 6, 204])), SecretKey(Scalar([197, 28, 187, 176, 247, 85, 5, 8, 211, 178, 62, 96, 123, 178, 235, 215, 205, 79, 30, 79, 212, 126, 65, 47, 138, 237, 27, 104, 17, 135, 75, 3])));
/// AJI("gdaji"): gdaji1xrqfg66m8trgx6hmm0pdd33hx7654wgdceawjepzf3fest7prv34j2xhtm6
static immutable AJI = KeyPair(PublicKey(Point([192, 148, 107, 91, 58, 198, 131, 106, 251, 219, 194, 214, 198, 55, 55, 181, 74, 185, 13, 198, 122, 233, 100, 34, 76, 83, 152, 47, 193, 27, 35, 89])), SecretKey(Scalar([240, 96, 54, 227, 32, 208, 119, 81, 101, 72, 64, 30, 171, 39, 27, 146, 253, 161, 151, 44, 57, 147, 66, 131, 28, 147, 73, 2, 198, 70, 195, 8])));
/// AJJ("gdajj"): gdajj1xrqff66kkvgy9qh2rrr3jdfv4cml8clgpz5r25z28fy4ka3qsqw5y8q5pf5
static immutable AJJ = KeyPair(PublicKey(Point([192, 148, 235, 86, 179, 16, 66, 130, 234, 24, 199, 25, 53, 44, 174, 55, 243, 227, 232, 8, 168, 53, 80, 74, 58, 73, 91, 118, 32, 128, 29, 66])), SecretKey(Scalar([70, 199, 247, 29, 83, 210, 35, 78, 120, 185, 155, 54, 171, 175, 88, 236, 22, 24, 195, 110, 185, 132, 101, 40, 228, 4, 22, 215, 154, 120, 48, 5])));
/// AJK("gdajk"): gdajk1xrqf2666p2qqd8c4q78e7q6xfvjsmfpp2620f0j0sjjnfewyxskh2azp0k3
static immutable AJK = KeyPair(PublicKey(Point([192, 149, 107, 90, 10, 128, 6, 159, 21, 7, 143, 159, 3, 70, 75, 37, 13, 164, 33, 86, 148, 244, 190, 79, 132, 165, 52, 229, 196, 52, 45, 117])), SecretKey(Scalar([44, 56, 67, 110, 91, 183, 24, 241, 235, 86, 66, 22, 61, 88, 27, 27, 100, 66, 244, 37, 137, 2, 86, 38, 151, 23, 218, 222, 19, 201, 16, 6])));
/// AJL("gdajl"): gdajl1xrqft6600x6mt3rnsf9g43yhgq6w03fc28czwnf9l0kefajys289sg8zpmx
static immutable AJL = KeyPair(PublicKey(Point([192, 149, 235, 79, 121, 181, 181, 196, 115, 130, 74, 138, 196, 151, 64, 52, 231, 197, 56, 81, 240, 39, 77, 37, 251, 237, 148, 246, 68, 130, 142, 88])), SecretKey(Scalar([165, 174, 101, 214, 219, 175, 41, 242, 158, 193, 47, 209, 252, 199, 16, 221, 165, 118, 113, 245, 216, 207, 112, 43, 58, 33, 238, 30, 162, 239, 162, 12])));
/// AJM("gdajm"): gdajm1xrqfv66pt6s4zv0rm3w8sl8w963qy6r5fcckxryjvtpyeh8jnv406j6wl37
static immutable AJM = KeyPair(PublicKey(Point([192, 150, 107, 65, 94, 161, 81, 49, 227, 220, 92, 120, 124, 238, 46, 162, 2, 104, 116, 78, 49, 99, 12, 146, 98, 194, 76, 220, 242, 155, 42, 253])), SecretKey(Scalar([185, 154, 229, 224, 79, 93, 144, 25, 246, 246, 246, 120, 188, 32, 217, 133, 86, 46, 73, 123, 153, 31, 255, 26, 178, 51, 125, 151, 146, 190, 18, 0])));
/// AJN("gdajn"): gdajn1xrqfd6605zx4ffp02py507yk6ltpkf0vw8zyn765wzvqjhm3exvwc6cwhyv
static immutable AJN = KeyPair(PublicKey(Point([192, 150, 235, 79, 160, 141, 84, 164, 47, 80, 73, 71, 248, 150, 215, 214, 27, 37, 236, 113, 196, 73, 251, 84, 112, 152, 9, 95, 113, 201, 152, 236])), SecretKey(Scalar([94, 208, 158, 165, 116, 86, 75, 204, 12, 72, 186, 62, 137, 209, 3, 51, 231, 236, 196, 151, 181, 175, 17, 148, 145, 201, 204, 18, 253, 155, 159, 9])));
/// AJO("gdajo"): gdajo1xrqfw669uh70m7j98q3tu6whvt6fe3u97dvtscucsw76lrgxv2f7z3qzvlc
static immutable AJO = KeyPair(PublicKey(Point([192, 151, 107, 69, 229, 252, 253, 250, 69, 56, 34, 190, 105, 215, 98, 244, 156, 199, 133, 243, 88, 184, 99, 152, 131, 189, 175, 141, 6, 98, 147, 225])), SecretKey(Scalar([12, 205, 53, 143, 7, 195, 232, 99, 218, 108, 48, 30, 152, 0, 31, 16, 115, 248, 220, 179, 26, 57, 229, 88, 53, 134, 245, 179, 102, 63, 81, 0])));
/// AJP("gdajp"): gdajp1xrqf066sdm6n6wx67efmpwqyup8ssuye7mg5kyh7fqy3fly7m0lzxw24eum
static immutable AJP = KeyPair(PublicKey(Point([192, 151, 235, 80, 110, 245, 61, 56, 218, 246, 83, 176, 184, 4, 224, 79, 8, 112, 153, 246, 209, 75, 18, 254, 72, 9, 20, 252, 158, 219, 254, 35])), SecretKey(Scalar([134, 187, 131, 99, 143, 159, 176, 8, 175, 124, 10, 208, 83, 163, 12, 83, 46, 226, 27, 192, 198, 113, 138, 244, 168, 20, 98, 83, 152, 204, 216, 12])));
/// AJQ("gdajq"): gdajq1xrqfs66a56fnmjwxqmalmffhdq03jk94qtgy3ftuyzl3dgczk5u2782zxw3
static immutable AJQ = KeyPair(PublicKey(Point([192, 152, 107, 93, 166, 147, 61, 201, 198, 6, 251, 253, 165, 55, 104, 31, 25, 88, 181, 2, 208, 72, 165, 124, 32, 191, 22, 163, 2, 181, 56, 175])), SecretKey(Scalar([140, 107, 99, 18, 216, 207, 237, 88, 78, 98, 171, 85, 6, 174, 106, 188, 5, 136, 163, 207, 221, 104, 139, 171, 210, 221, 133, 250, 201, 142, 239, 9])));
/// AJR("gdajr"): gdajr1xrqf366q43jk7a4tx0zyl8mk8fcm8tmhz4jxztdf2tumltn7795vvlkcv03
static immutable AJR = KeyPair(PublicKey(Point([192, 152, 235, 64, 172, 101, 111, 118, 171, 51, 196, 79, 159, 118, 58, 113, 179, 175, 119, 21, 100, 97, 45, 169, 82, 249, 191, 174, 126, 241, 104, 198])), SecretKey(Scalar([33, 89, 66, 47, 181, 102, 47, 40, 250, 182, 156, 214, 87, 102, 26, 67, 177, 21, 80, 185, 232, 52, 60, 224, 203, 144, 27, 53, 233, 11, 223, 7])));
/// AJS("gdajs"): gdajs1xrqfj66537sjyaqse6k3zre483sshrlpl5nsj6m087s2xdfx82k4cud8e93
static immutable AJS = KeyPair(PublicKey(Point([192, 153, 107, 84, 143, 161, 34, 116, 16, 206, 173, 17, 15, 53, 60, 97, 11, 143, 225, 253, 39, 9, 107, 111, 63, 160, 163, 53, 38, 58, 173, 92])), SecretKey(Scalar([1, 178, 216, 82, 196, 134, 105, 83, 133, 213, 123, 186, 255, 108, 62, 153, 40, 140, 143, 122, 168, 79, 75, 124, 147, 195, 99, 218, 81, 198, 189, 12])));
/// AJT("gdajt"): gdajt1xrqfn66y0df2ersalwmfq506un4l46sjjpf97nv4mwugxzhree8qwaa8ycn
static immutable AJT = KeyPair(PublicKey(Point([192, 153, 235, 68, 123, 82, 172, 142, 29, 251, 182, 144, 81, 250, 228, 235, 250, 234, 18, 144, 82, 95, 77, 149, 219, 184, 131, 10, 227, 206, 78, 7])), SecretKey(Scalar([175, 2, 163, 24, 150, 217, 224, 221, 199, 198, 237, 215, 126, 8, 32, 86, 57, 230, 90, 89, 176, 68, 163, 198, 36, 112, 228, 71, 242, 9, 129, 7])));
/// AJU("gdaju"): gdaju1xrqf566mlmpuxpcz5t6t4nfapaq38detmt0aruhg2c42z79fa3t2snq9jp5
static immutable AJU = KeyPair(PublicKey(Point([192, 154, 107, 91, 254, 195, 195, 7, 2, 162, 244, 186, 205, 61, 15, 65, 19, 183, 43, 218, 223, 209, 242, 232, 86, 42, 161, 120, 169, 236, 86, 168])), SecretKey(Scalar([44, 177, 96, 57, 78, 128, 1, 250, 87, 142, 104, 96, 95, 68, 168, 70, 212, 13, 81, 118, 248, 167, 128, 90, 31, 67, 162, 177, 150, 195, 170, 11])));
/// AJV("gdajv"): gdajv1xrqf46644vxsd4500v42q6cue8c7nyu3qk7r4k4c5trmax6hunh0vflf8zx
static immutable AJV = KeyPair(PublicKey(Point([192, 154, 235, 85, 171, 13, 6, 214, 143, 123, 42, 160, 107, 28, 201, 241, 233, 147, 145, 5, 188, 58, 218, 184, 162, 199, 190, 155, 87, 228, 238, 246])), SecretKey(Scalar([239, 59, 122, 58, 207, 139, 37, 249, 26, 0, 102, 194, 88, 90, 32, 15, 48, 69, 156, 239, 194, 145, 71, 57, 250, 54, 132, 14, 38, 196, 244, 13])));
/// AJW("gdajw"): gdajw1xrqfk6696z76mcwje8qku42rsalpuledkea50v2ck2py9dcxfkvwymq0x5q
static immutable AJW = KeyPair(PublicKey(Point([192, 155, 107, 69, 208, 189, 173, 225, 210, 201, 193, 110, 85, 67, 135, 126, 30, 127, 45, 182, 123, 71, 177, 88, 178, 130, 66, 183, 6, 77, 152, 226])), SecretKey(Scalar([83, 166, 192, 53, 135, 129, 232, 168, 201, 156, 234, 183, 71, 206, 173, 64, 29, 196, 130, 146, 182, 130, 209, 27, 76, 137, 104, 32, 174, 240, 135, 3])));
/// AJX("gdajx"): gdajx1xrqfh663zed9nkclr0349lljkcaj9kqfzldphgt5ldt9j2um70h6up0mxcs
static immutable AJX = KeyPair(PublicKey(Point([192, 155, 235, 81, 22, 90, 89, 219, 31, 27, 227, 82, 255, 242, 182, 59, 34, 216, 9, 23, 218, 27, 161, 116, 251, 86, 89, 43, 155, 243, 239, 174])), SecretKey(Scalar([38, 58, 7, 34, 140, 158, 30, 28, 178, 211, 53, 152, 144, 227, 238, 41, 170, 220, 120, 10, 104, 225, 250, 118, 133, 112, 253, 122, 160, 254, 221, 10])));
/// AJY("gdajy"): gdajy1xrqfc66uqk8arnqaw8ynrrpftrfc0k3d5e83j9htfkj2622t8v4acdqe5qs
static immutable AJY = KeyPair(PublicKey(Point([192, 156, 107, 92, 5, 143, 209, 204, 29, 113, 201, 49, 140, 41, 88, 211, 135, 218, 45, 166, 79, 25, 22, 235, 77, 164, 173, 41, 75, 59, 43, 220])), SecretKey(Scalar([178, 173, 61, 252, 172, 166, 225, 232, 59, 182, 196, 47, 31, 58, 63, 114, 5, 249, 151, 78, 244, 249, 151, 62, 216, 33, 218, 252, 104, 29, 225, 9])));
/// AJZ("gdajz"): gdajz1xrqfe667rxh2524mlz427sa8wl60yhh3vwg63xl8xr5au7jw4qnu7wl0uyy
static immutable AJZ = KeyPair(PublicKey(Point([192, 156, 235, 94, 25, 174, 170, 42, 187, 248, 170, 175, 67, 167, 119, 244, 242, 94, 241, 99, 145, 168, 155, 231, 48, 233, 222, 122, 78, 168, 39, 207])), SecretKey(Scalar([192, 18, 129, 231, 213, 57, 83, 1, 21, 251, 71, 14, 185, 165, 158, 193, 108, 146, 208, 172, 101, 118, 223, 213, 77, 174, 23, 17, 125, 19, 226, 2])));
/// AKA("gdaka"): gdaka1xrq2q66vgf0vtemz0j7n5a5kgwaakgcjytj7vm8q0u6f0mwjrld5q6qfsx3
static immutable AKA = KeyPair(PublicKey(Point([192, 160, 107, 76, 66, 94, 197, 231, 98, 124, 189, 58, 118, 150, 67, 187, 219, 35, 18, 34, 229, 230, 108, 224, 127, 52, 151, 237, 210, 31, 219, 64])), SecretKey(Scalar([157, 134, 246, 166, 58, 211, 106, 203, 252, 29, 126, 55, 101, 191, 32, 132, 83, 210, 42, 195, 67, 169, 217, 245, 114, 151, 37, 242, 217, 51, 250, 3])));
/// AKB("gdakb"): gdakb1xrq2p66pl2r7hc7jps7uc4wvlfm8307ekft8kuaeaqa7xq05nqluzga5u89
static immutable AKB = KeyPair(PublicKey(Point([192, 160, 235, 65, 250, 135, 235, 227, 210, 12, 61, 204, 85, 204, 250, 118, 120, 191, 217, 178, 86, 123, 115, 185, 232, 59, 227, 1, 244, 152, 63, 193])), SecretKey(Scalar([2, 254, 88, 132, 33, 6, 154, 177, 59, 71, 51, 10, 160, 14, 110, 133, 56, 8, 86, 125, 220, 21, 231, 126, 37, 120, 32, 154, 80, 52, 163, 5])));
/// AKC("gdakc"): gdakc1xrq2z66dz60xf6e6cghd0y7m4vlk9p8qjl4kn68afvvgtd833hqgk5w9g52
static immutable AKC = KeyPair(PublicKey(Point([192, 161, 107, 77, 22, 158, 100, 235, 58, 194, 46, 215, 147, 219, 171, 63, 98, 132, 224, 151, 235, 105, 232, 253, 75, 24, 133, 180, 241, 141, 192, 139])), SecretKey(Scalar([217, 211, 130, 246, 157, 201, 255, 101, 160, 159, 42, 243, 207, 245, 208, 181, 35, 89, 174, 166, 202, 127, 224, 174, 84, 160, 110, 13, 68, 81, 51, 6])));
/// AKD("gdakd"): gdakd1xrq2r6625q560hqcyh9rgf7g09lcd0s4kaqe5elctjzksap86et75thqz47
static immutable AKD = KeyPair(PublicKey(Point([192, 161, 235, 74, 160, 41, 167, 220, 24, 37, 202, 52, 39, 200, 121, 127, 134, 190, 21, 183, 65, 154, 103, 248, 92, 133, 104, 116, 39, 214, 87, 234])), SecretKey(Scalar([115, 180, 209, 63, 40, 134, 111, 246, 99, 244, 66, 20, 123, 119, 168, 136, 153, 186, 190, 183, 239, 161, 78, 190, 66, 110, 171, 198, 9, 167, 188, 7])));
/// AKE("gdake"): gdake1xrq2y66ypd9shp997glt9mz53sjj28mxsn6su70c99pz3xg8094rqae2g9x
static immutable AKE = KeyPair(PublicKey(Point([192, 162, 107, 68, 11, 75, 11, 132, 165, 242, 62, 178, 236, 84, 140, 37, 37, 31, 102, 132, 245, 14, 121, 248, 41, 66, 40, 153, 7, 121, 106, 48])), SecretKey(Scalar([38, 47, 45, 232, 252, 145, 44, 159, 197, 129, 179, 70, 127, 133, 217, 220, 23, 230, 137, 75, 86, 140, 138, 247, 234, 234, 72, 90, 242, 230, 45, 14])));
/// AKF("gdakf"): gdakf1xrq2966079nfcpxuzmyzhss5e0uljfcjy5g0vj3s37zm3zf6fyfnzx2yktf
static immutable AKF = KeyPair(PublicKey(Point([192, 162, 235, 79, 241, 102, 156, 4, 220, 22, 200, 43, 194, 20, 203, 249, 249, 39, 18, 37, 16, 246, 74, 48, 143, 133, 184, 137, 58, 73, 19, 49])), SecretKey(Scalar([191, 80, 229, 91, 221, 135, 230, 176, 124, 231, 17, 63, 224, 77, 254, 123, 189, 49, 104, 100, 33, 102, 79, 236, 97, 108, 148, 112, 135, 164, 237, 8])));
/// AKG("gdakg"): gdakg1xrq2x665ttc6k6dw3y4x6ev980y4e8c9yh3zxzc0dypmnr5m3xg050w7m44
static immutable AKG = KeyPair(PublicKey(Point([192, 163, 107, 84, 90, 241, 171, 105, 174, 137, 42, 109, 101, 133, 59, 201, 92, 159, 5, 37, 226, 35, 11, 15, 105, 3, 185, 142, 155, 137, 144, 250])), SecretKey(Scalar([70, 194, 55, 114, 241, 156, 70, 112, 162, 10, 222, 214, 219, 236, 61, 29, 117, 177, 147, 126, 233, 41, 182, 214, 123, 243, 24, 125, 34, 194, 218, 8])));
/// AKH("gdakh"): gdakh1xrq2866uu0l8tvu38rlq72nf0knul2nefnr30tfk079zj9vg9wlhkhyqmvf
static immutable AKH = KeyPair(PublicKey(Point([192, 163, 235, 92, 227, 254, 117, 179, 145, 56, 254, 15, 42, 105, 125, 167, 207, 170, 121, 76, 199, 23, 173, 54, 127, 138, 41, 21, 136, 43, 191, 123])), SecretKey(Scalar([249, 164, 160, 133, 116, 168, 102, 125, 124, 240, 175, 153, 47, 157, 207, 80, 34, 236, 36, 0, 91, 219, 34, 151, 156, 232, 244, 72, 211, 24, 12, 10])));
/// AKI("gdaki"): gdaki1xrq2g664vmtyk0nx5syu7hqcghz96kc2jsaqytsw0tw5c8aeafkvc2t9gp3
static immutable AKI = KeyPair(PublicKey(Point([192, 164, 107, 85, 102, 214, 75, 62, 102, 164, 9, 207, 92, 24, 69, 196, 93, 91, 10, 148, 58, 2, 46, 14, 122, 221, 76, 31, 185, 234, 108, 204])), SecretKey(Scalar([119, 196, 5, 122, 79, 9, 24, 192, 113, 164, 44, 48, 235, 126, 108, 169, 229, 2, 164, 46, 247, 120, 158, 128, 224, 160, 162, 199, 122, 71, 49, 12])));
/// AKJ("gdakj"): gdakj1xrq2f66eh4hv646nkk5x6xty9tn3rcv8eemqur8n0zc734l0whuzyr34x4t
static immutable AKJ = KeyPair(PublicKey(Point([192, 164, 235, 89, 189, 110, 205, 87, 83, 181, 168, 109, 25, 100, 42, 231, 17, 225, 135, 206, 118, 14, 12, 243, 120, 177, 232, 215, 239, 117, 248, 34])), SecretKey(Scalar([139, 147, 188, 103, 167, 18, 64, 51, 41, 212, 141, 69, 152, 50, 93, 107, 42, 139, 80, 127, 112, 147, 68, 183, 241, 71, 150, 87, 170, 116, 198, 6])));
/// AKK("gdakk"): gdakk1xrq2266dgxdrm54ay8vwneyjtepg78ck6mjjrnj7fqmrxlpjys4u6k9w2me
static immutable AKK = KeyPair(PublicKey(Point([192, 165, 107, 77, 65, 154, 61, 210, 189, 33, 216, 233, 228, 146, 94, 66, 143, 31, 22, 214, 229, 33, 206, 94, 72, 54, 51, 124, 50, 36, 43, 205])), SecretKey(Scalar([32, 134, 125, 54, 234, 122, 251, 219, 23, 86, 183, 51, 68, 133, 215, 57, 156, 99, 126, 70, 180, 113, 30, 182, 33, 249, 211, 188, 80, 65, 85, 2])));
/// AKL("gdakl"): gdakl1xrq2t66aqkgxxs8zy7n09aashz9svsdwn5y0mextsa6h0q5z72vj7ntja89
static immutable AKL = KeyPair(PublicKey(Point([192, 165, 235, 93, 5, 144, 99, 64, 226, 39, 166, 242, 247, 176, 184, 139, 6, 65, 174, 157, 8, 253, 228, 203, 135, 117, 119, 130, 130, 242, 153, 47])), SecretKey(Scalar([105, 30, 245, 159, 218, 26, 241, 90, 212, 7, 234, 232, 160, 116, 38, 81, 170, 113, 207, 137, 151, 13, 169, 166, 122, 14, 236, 95, 149, 163, 184, 9])));
/// AKM("gdakm"): gdakm1xrq2v66ksukxtyjvpek4rzzlg06yyk457eh9qdsjvp70hafruwc3g0l62hq
static immutable AKM = KeyPair(PublicKey(Point([192, 166, 107, 86, 135, 44, 101, 146, 76, 14, 109, 81, 136, 95, 67, 244, 66, 90, 180, 246, 110, 80, 54, 18, 96, 124, 251, 245, 35, 227, 177, 20])), SecretKey(Scalar([194, 31, 116, 0, 139, 186, 148, 29, 87, 240, 106, 212, 73, 192, 3, 164, 45, 26, 12, 219, 175, 139, 17, 193, 77, 177, 251, 192, 90, 58, 187, 5])));
/// AKN("gdakn"): gdakn1xrq2d6683vsvelve2hxftd7dk5v65f2mlwjuly3j6m7kjlldrj0nqm4avka
static immutable AKN = KeyPair(PublicKey(Point([192, 166, 235, 71, 139, 32, 204, 253, 153, 85, 204, 149, 183, 205, 181, 25, 170, 37, 91, 251, 165, 207, 146, 50, 214, 253, 105, 127, 237, 28, 159, 48])), SecretKey(Scalar([56, 224, 168, 55, 61, 186, 87, 238, 185, 36, 52, 150, 169, 48, 176, 205, 74, 7, 100, 135, 24, 100, 221, 10, 2, 235, 83, 88, 0, 226, 189, 0])));
/// AKO("gdako"): gdako1xrq2w669lxkdh5j6frs488kgd06rtj7zk9054sncyrwgesvql66awshw4am
static immutable AKO = KeyPair(PublicKey(Point([192, 167, 107, 69, 249, 172, 219, 210, 90, 72, 225, 83, 158, 200, 107, 244, 53, 203, 194, 177, 95, 74, 194, 120, 32, 220, 140, 193, 128, 254, 181, 215])), SecretKey(Scalar([211, 217, 65, 40, 26, 52, 222, 200, 194, 17, 87, 179, 8, 149, 216, 165, 195, 19, 204, 242, 151, 184, 96, 235, 173, 186, 8, 149, 153, 232, 246, 13])));
/// AKP("gdakp"): gdakp1xrq2066rsqm6ggkafwl3yutf9unk5fme3u6g3egusfsrc4nld8geseenhgq
static immutable AKP = KeyPair(PublicKey(Point([192, 167, 235, 67, 128, 55, 164, 34, 221, 75, 191, 18, 113, 105, 47, 39, 106, 39, 121, 143, 52, 136, 229, 28, 130, 96, 60, 86, 127, 105, 209, 152])), SecretKey(Scalar([89, 101, 88, 52, 151, 42, 248, 168, 179, 186, 50, 166, 112, 195, 144, 0, 63, 99, 127, 134, 17, 153, 160, 54, 17, 220, 246, 157, 171, 157, 3, 0])));
/// AKQ("gdakq"): gdakq1xrq2s668kkadcyzgfs53hrqdf0kjntp74getkga4egxck646uqcrx0h9wy7
static immutable AKQ = KeyPair(PublicKey(Point([192, 168, 107, 71, 181, 186, 220, 16, 72, 76, 41, 27, 140, 13, 75, 237, 41, 172, 62, 170, 50, 187, 35, 181, 202, 13, 139, 106, 186, 224, 48, 51])), SecretKey(Scalar([21, 29, 51, 156, 158, 72, 213, 84, 108, 167, 74, 80, 219, 101, 118, 146, 203, 194, 231, 66, 95, 238, 231, 180, 29, 247, 208, 202, 12, 102, 200, 0])));
/// AKR("gdakr"): gdakr1xrq23663077vp4qs6mhtxmhuf4cz5mqwg8a3ufefachf3fjmdcm6g0sq7qn
static immutable AKR = KeyPair(PublicKey(Point([192, 168, 235, 81, 127, 188, 192, 212, 16, 214, 238, 179, 110, 252, 77, 112, 42, 108, 14, 65, 251, 30, 39, 41, 238, 46, 152, 166, 91, 110, 55, 164])), SecretKey(Scalar([192, 80, 123, 129, 67, 111, 126, 93, 245, 154, 10, 188, 51, 68, 162, 195, 131, 193, 44, 67, 124, 104, 223, 88, 178, 241, 148, 30, 158, 77, 121, 7])));
/// AKS("gdaks"): gdaks1xrq2j66mdurjc03g76cqdus9w2uvhnjxz3vnzujazx6dvrdayant6ww0r9z
static immutable AKS = KeyPair(PublicKey(Point([192, 169, 107, 91, 111, 7, 44, 62, 40, 246, 176, 6, 242, 5, 114, 184, 203, 206, 70, 20, 89, 49, 114, 93, 17, 180, 214, 13, 189, 39, 102, 189])), SecretKey(Scalar([85, 96, 254, 120, 8, 186, 176, 167, 214, 30, 125, 215, 79, 159, 53, 149, 209, 192, 31, 210, 18, 162, 98, 77, 80, 200, 98, 6, 255, 226, 195, 14])));
/// AKT("gdakt"): gdakt1xrq2n668jqas8pjzerfjplpafvju2rn0azxqv7f9ht9j64rfg5g35ln3aev
static immutable AKT = KeyPair(PublicKey(Point([192, 169, 235, 71, 144, 59, 3, 134, 66, 200, 211, 32, 252, 61, 75, 37, 197, 14, 111, 232, 140, 6, 121, 37, 186, 203, 45, 84, 105, 69, 17, 26])), SecretKey(Scalar([237, 83, 58, 56, 30, 226, 153, 144, 201, 113, 202, 149, 50, 187, 217, 116, 15, 98, 61, 90, 66, 114, 160, 136, 177, 190, 11, 226, 163, 31, 216, 15])));
/// AKU("gdaku"): gdaku1xrq2566z387lg0ltry553ujleppv9rf4jkuehwpt9sgd6te6d892x2r4sax
static immutable AKU = KeyPair(PublicKey(Point([192, 170, 107, 66, 137, 253, 244, 63, 235, 25, 41, 72, 242, 95, 200, 66, 194, 141, 53, 149, 185, 155, 184, 43, 44, 16, 221, 47, 58, 105, 202, 163])), SecretKey(Scalar([203, 195, 174, 200, 37, 134, 113, 107, 148, 129, 228, 255, 13, 107, 67, 226, 214, 200, 224, 200, 201, 82, 172, 150, 225, 178, 22, 18, 80, 56, 230, 4])));
/// AKV("gdakv"): gdakv1xrq24663vqg4s9uxymcayn45htuat43zr3r9kj5gxwj25vuerek0ursr94c
static immutable AKV = KeyPair(PublicKey(Point([192, 170, 235, 81, 96, 17, 88, 23, 134, 38, 241, 210, 78, 180, 186, 249, 213, 214, 34, 28, 70, 91, 74, 136, 51, 164, 170, 51, 153, 30, 108, 254])), SecretKey(Scalar([94, 162, 31, 122, 19, 115, 183, 69, 22, 24, 128, 9, 108, 224, 42, 119, 129, 223, 130, 94, 96, 136, 55, 176, 151, 138, 215, 240, 225, 181, 145, 12])));
/// AKW("gdakw"): gdakw1xrq2k66lmfq2zkmh6npg3v5rc9s7lhqqu9vfear92p03r7qpc9565hmrd2l
static immutable AKW = KeyPair(PublicKey(Point([192, 171, 107, 95, 218, 64, 161, 91, 119, 212, 194, 136, 178, 131, 193, 97, 239, 220, 0, 225, 88, 156, 244, 101, 80, 95, 17, 248, 1, 193, 105, 170])), SecretKey(Scalar([243, 156, 140, 126, 208, 89, 3, 132, 193, 5, 245, 234, 213, 111, 52, 137, 108, 34, 240, 178, 138, 176, 170, 11, 157, 253, 166, 230, 9, 33, 63, 11])));
/// AKX("gdakx"): gdakx1xrq2h66xhkwlecm8uj4al7vfl5t5kglulyvefzhkwft72ctvpxpw7hd9a8m
static immutable AKX = KeyPair(PublicKey(Point([192, 171, 235, 70, 189, 157, 252, 227, 103, 228, 171, 223, 249, 137, 253, 23, 75, 35, 252, 249, 25, 148, 138, 246, 114, 87, 229, 97, 108, 9, 130, 239])), SecretKey(Scalar([253, 209, 37, 164, 214, 57, 46, 124, 129, 57, 22, 32, 120, 155, 208, 69, 69, 81, 181, 123, 22, 78, 32, 99, 255, 225, 97, 89, 15, 191, 117, 5])));
/// AKY("gdaky"): gdaky1xrq2c66fz3zj7m3mjx0gvxp0wgxl0nr8fwzwhjulfeecwe47jdfcsupshel
static immutable AKY = KeyPair(PublicKey(Point([192, 172, 107, 73, 20, 69, 47, 110, 59, 145, 158, 134, 24, 47, 114, 13, 247, 204, 103, 75, 132, 235, 203, 159, 78, 115, 135, 102, 190, 147, 83, 136])), SecretKey(Scalar([65, 142, 24, 229, 157, 199, 111, 123, 19, 242, 127, 183, 211, 183, 29, 169, 221, 145, 137, 175, 227, 238, 123, 189, 175, 156, 88, 73, 52, 151, 68, 15])));
/// AKZ("gdakz"): gdakz1xrq2e667a7a0zrs73r0d5k3ejcp6exer06fptuqw2mvdxwq069n2xe6n9l9
static immutable AKZ = KeyPair(PublicKey(Point([192, 172, 235, 94, 239, 186, 241, 14, 30, 136, 222, 218, 90, 57, 150, 3, 172, 155, 35, 126, 146, 21, 240, 14, 86, 216, 211, 56, 15, 209, 102, 163])), SecretKey(Scalar([215, 83, 71, 185, 237, 52, 72, 220, 41, 21, 169, 49, 11, 96, 162, 111, 94, 121, 77, 145, 195, 58, 132, 80, 191, 106, 147, 131, 171, 253, 69, 7])));
/// ALA("gdala"): gdala1xrqtq66l8lwxsg0vx9dajkg0m97cst99e8twd4vmkg394lv2j582kt759r6
static immutable ALA = KeyPair(PublicKey(Point([192, 176, 107, 95, 63, 220, 104, 33, 236, 49, 91, 217, 89, 15, 217, 125, 136, 44, 165, 201, 214, 230, 213, 155, 178, 34, 90, 253, 138, 149, 14, 171])), SecretKey(Scalar([119, 50, 23, 250, 27, 163, 103, 19, 46, 47, 115, 250, 194, 207, 53, 119, 226, 90, 45, 0, 73, 46, 35, 96, 83, 87, 13, 24, 97, 69, 72, 10])));
/// ALB("gdalb"): gdalb1xrqtp66yuc4rsatk6fvq04qcepp27ummk54sg8rfp55fdzpn4trzs4eu6qj
static immutable ALB = KeyPair(PublicKey(Point([192, 176, 235, 68, 230, 42, 56, 117, 118, 210, 88, 7, 212, 24, 200, 66, 175, 115, 123, 181, 43, 4, 28, 105, 13, 40, 150, 136, 51, 170, 198, 40])), SecretKey(Scalar([85, 230, 220, 143, 160, 170, 118, 109, 125, 253, 76, 27, 23, 171, 27, 69, 210, 16, 204, 192, 246, 9, 239, 78, 105, 251, 234, 114, 125, 173, 254, 6])));
/// ALC("gdalc"): gdalc1xrqtz66fykl6s37p2y4505vmy97a868vn6x73gpnulksy4a82swuvt0yq7a
static immutable ALC = KeyPair(PublicKey(Point([192, 177, 107, 73, 37, 191, 168, 71, 193, 81, 43, 71, 209, 155, 33, 125, 211, 232, 236, 158, 141, 232, 160, 51, 231, 237, 2, 87, 167, 84, 29, 198])), SecretKey(Scalar([237, 104, 176, 187, 23, 216, 250, 140, 157, 59, 186, 190, 106, 212, 23, 161, 13, 171, 9, 117, 6, 4, 153, 23, 40, 177, 196, 130, 146, 138, 169, 2])));
/// ALD("gdald"): gdald1xrqtr66cmcxvq866pwthj9j0pyqv7z6p5fwcmveqnkalpkgeszw0gym37vp
static immutable ALD = KeyPair(PublicKey(Point([192, 177, 235, 88, 222, 12, 192, 31, 90, 11, 151, 121, 22, 79, 9, 0, 207, 11, 65, 162, 93, 141, 179, 32, 157, 187, 240, 217, 25, 128, 156, 244])), SecretKey(Scalar([200, 188, 181, 208, 16, 67, 149, 202, 59, 110, 17, 48, 0, 160, 122, 81, 241, 137, 138, 200, 197, 246, 40, 210, 149, 79, 99, 238, 29, 204, 251, 0])));
/// ALE("gdale"): gdale1xrqty66jr42v8eprx8grl9rd0l28aejfdpxy4frfj2sx5d9yf33k2arh75f
static immutable ALE = KeyPair(PublicKey(Point([192, 178, 107, 82, 29, 84, 195, 228, 35, 49, 208, 63, 148, 109, 127, 212, 126, 230, 73, 104, 76, 74, 164, 105, 146, 160, 106, 52, 164, 76, 99, 101])), SecretKey(Scalar([196, 226, 215, 235, 65, 24, 89, 183, 114, 85, 89, 240, 174, 178, 25, 138, 92, 25, 146, 39, 134, 120, 29, 91, 103, 106, 154, 212, 34, 61, 223, 3])));
/// ALF("gdalf"): gdalf1xrqt966z5urxkfmawc9pswkngfjy7erlc8m8r6t6mkfwre5qxj656f93eff
static immutable ALF = KeyPair(PublicKey(Point([192, 178, 235, 66, 167, 6, 107, 39, 125, 118, 10, 24, 58, 211, 66, 100, 79, 100, 127, 193, 246, 113, 233, 122, 221, 146, 225, 230, 128, 52, 181, 77])), SecretKey(Scalar([7, 166, 231, 45, 37, 3, 204, 214, 198, 200, 162, 245, 252, 146, 176, 146, 154, 4, 229, 6, 128, 49, 174, 255, 6, 158, 79, 161, 101, 149, 26, 1])));
/// ALG("gdalg"): gdalg1xrqtx66ql235dj98ay8k6lvdmgwhem6fnkhpalw4x87ze449fmlcgslxtsj
static immutable ALG = KeyPair(PublicKey(Point([192, 179, 107, 64, 250, 163, 70, 200, 167, 233, 15, 109, 125, 141, 218, 29, 124, 239, 73, 157, 174, 30, 253, 213, 49, 252, 44, 214, 165, 78, 255, 132])), SecretKey(Scalar([23, 242, 40, 68, 129, 219, 247, 102, 244, 60, 121, 27, 34, 217, 240, 137, 170, 161, 88, 169, 235, 68, 228, 162, 66, 178, 64, 137, 1, 164, 240, 1])));
/// ALH("gdalh"): gdalh1xrqt866x3cm58p24jlkgvd7fqt073mxj4et2v3wz465mzf292g2u2f7rlzt
static immutable ALH = KeyPair(PublicKey(Point([192, 179, 235, 70, 142, 55, 67, 133, 85, 151, 236, 134, 55, 201, 2, 223, 232, 236, 210, 174, 86, 166, 69, 194, 174, 169, 177, 37, 69, 82, 21, 197])), SecretKey(Scalar([102, 125, 78, 114, 165, 231, 226, 70, 49, 168, 38, 56, 108, 244, 31, 206, 122, 78, 212, 157, 20, 99, 239, 3, 92, 144, 71, 105, 236, 157, 119, 7])));
/// ALI("gdali"): gdali1xrqtg664destv529cpprjr9p7k2m7nly9ms92j7p0trjxfdxtgkk5ke2m6d
static immutable ALI = KeyPair(PublicKey(Point([192, 180, 107, 85, 110, 96, 182, 81, 69, 192, 66, 57, 12, 161, 245, 149, 191, 79, 228, 46, 224, 85, 75, 193, 122, 199, 35, 37, 166, 90, 45, 106])), SecretKey(Scalar([148, 130, 134, 17, 139, 84, 113, 39, 222, 230, 227, 14, 28, 4, 44, 164, 193, 38, 206, 101, 139, 248, 62, 44, 212, 189, 63, 135, 2, 24, 241, 4])));
/// ALJ("gdalj"): gdalj1xrqtf66z3ykzely9q2jc5tk0yfclh4scm4ljt4gfxj8j47s5y7a9kflzant
static immutable ALJ = KeyPair(PublicKey(Point([192, 180, 235, 66, 137, 44, 44, 252, 133, 2, 165, 138, 46, 207, 34, 113, 251, 214, 24, 221, 127, 37, 213, 9, 52, 143, 42, 250, 20, 39, 186, 91])), SecretKey(Scalar([208, 172, 204, 210, 212, 104, 210, 102, 181, 154, 3, 254, 213, 244, 121, 249, 37, 2, 181, 4, 25, 248, 38, 101, 91, 128, 64, 240, 110, 240, 125, 5])));
/// ALK("gdalk"): gdalk1xrqt266qnvgsszenm3nc896st75eudta292jyng67lckzgduvtrvwp47yup
static immutable ALK = KeyPair(PublicKey(Point([192, 181, 107, 64, 155, 17, 8, 11, 51, 220, 103, 131, 151, 80, 95, 169, 158, 53, 125, 81, 85, 34, 77, 26, 247, 241, 97, 33, 188, 98, 198, 199])), SecretKey(Scalar([25, 62, 226, 200, 235, 49, 158, 64, 146, 61, 91, 84, 39, 243, 3, 5, 110, 117, 139, 33, 232, 121, 12, 22, 57, 102, 65, 49, 221, 226, 201, 4])));
/// ALL("gdall"): gdall1xrqtt66mu8xdwez0d77pdq0ykax5v0kzh5k23a6zn2qukrm2df2jyd3rte3
static immutable ALL = KeyPair(PublicKey(Point([192, 181, 235, 91, 225, 204, 215, 100, 79, 111, 188, 22, 129, 228, 183, 77, 70, 62, 194, 189, 44, 168, 247, 66, 154, 129, 203, 15, 106, 106, 85, 34])), SecretKey(Scalar([96, 189, 196, 7, 117, 111, 104, 27, 206, 3, 225, 149, 83, 122, 15, 116, 242, 1, 238, 34, 113, 32, 50, 135, 96, 137, 93, 69, 251, 188, 143, 4])));
/// ALM("gdalm"): gdalm1xrqtv66kxr3atx26yzd9a5gxlqluawpxfq642qvgs8svu860upspc650tl6
static immutable ALM = KeyPair(PublicKey(Point([192, 182, 107, 86, 48, 227, 213, 153, 90, 32, 154, 94, 209, 6, 248, 63, 206, 184, 38, 72, 53, 85, 1, 136, 129, 224, 206, 31, 79, 224, 96, 28])), SecretKey(Scalar([117, 226, 248, 66, 8, 137, 247, 203, 171, 37, 106, 129, 115, 232, 11, 189, 139, 194, 37, 238, 108, 27, 15, 199, 27, 193, 44, 205, 58, 157, 137, 1])));
/// ALN("gdaln"): gdaln1xrqtd66j7m4sg8ddecs40g5hf0vc24tvgx3z753gwccgrlxuszzlvvak8tt
static immutable ALN = KeyPair(PublicKey(Point([192, 182, 235, 82, 246, 235, 4, 29, 173, 206, 33, 87, 162, 151, 75, 217, 133, 85, 108, 65, 162, 47, 82, 40, 118, 48, 129, 252, 220, 128, 133, 246])), SecretKey(Scalar([117, 167, 81, 129, 247, 6, 208, 225, 65, 4, 91, 97, 73, 123, 29, 4, 246, 29, 58, 34, 241, 143, 51, 48, 204, 137, 76, 147, 235, 177, 220, 12])));
/// ALO("gdalo"): gdalo1xrqtw665lpa65045k5rxu2ntce9luv6nrcvwcsuppmwwnufnydspx0p23nr
static immutable ALO = KeyPair(PublicKey(Point([192, 183, 107, 84, 248, 123, 170, 62, 180, 181, 6, 110, 42, 107, 198, 75, 254, 51, 83, 30, 24, 236, 67, 129, 14, 220, 233, 241, 51, 35, 96, 19])), SecretKey(Scalar([165, 68, 242, 194, 13, 100, 96, 165, 189, 0, 202, 74, 161, 38, 127, 48, 214, 109, 19, 169, 14, 212, 119, 222, 181, 150, 82, 219, 0, 128, 204, 8])));
/// ALP("gdalp"): gdalp1xrqt066h67q46wsjf49mc0rvwzx248zc6ju6zu4cmeegz66zryeq6f44hv4
static immutable ALP = KeyPair(PublicKey(Point([192, 183, 235, 87, 215, 129, 93, 58, 18, 77, 75, 188, 60, 108, 112, 140, 170, 156, 88, 212, 185, 161, 114, 184, 222, 114, 129, 107, 66, 25, 50, 13])), SecretKey(Scalar([198, 49, 189, 231, 172, 104, 88, 218, 50, 56, 69, 71, 72, 197, 156, 225, 50, 10, 16, 23, 36, 192, 120, 0, 158, 139, 141, 246, 39, 133, 116, 11])));
/// ALQ("gdalq"): gdalq1xrqts66kcpj7936d485u9q404a2v08cfver4cee3qwz05axgkd4m77c35er
static immutable ALQ = KeyPair(PublicKey(Point([192, 184, 107, 86, 192, 101, 226, 199, 77, 169, 233, 194, 130, 175, 175, 84, 199, 159, 9, 102, 71, 92, 103, 49, 3, 132, 250, 116, 200, 179, 107, 191])), SecretKey(Scalar([118, 178, 116, 199, 72, 98, 232, 109, 124, 220, 244, 150, 198, 203, 31, 194, 33, 134, 164, 87, 142, 92, 5, 20, 250, 115, 46, 202, 73, 38, 88, 4])));
/// ALR("gdalr"): gdalr1xrqt366nzda3yaufsxhnggfrywhd3rsdkusw8wm326wfm9scvurujdpy4gm
static immutable ALR = KeyPair(PublicKey(Point([192, 184, 235, 83, 19, 123, 18, 119, 137, 129, 175, 52, 33, 35, 35, 174, 216, 142, 13, 183, 32, 227, 187, 113, 86, 156, 157, 150, 24, 103, 7, 201])), SecretKey(Scalar([153, 164, 118, 210, 49, 55, 72, 116, 7, 72, 241, 198, 149, 135, 223, 128, 239, 42, 212, 235, 225, 244, 234, 134, 0, 10, 219, 142, 184, 114, 115, 4])));
/// ALS("gdals"): gdals1xrqtj66jl7xc6uv3z3jzn3t3w8rg2853902v85a3zcculhykq34nz7argg9
static immutable ALS = KeyPair(PublicKey(Point([192, 185, 107, 82, 255, 141, 141, 113, 145, 20, 100, 41, 197, 113, 113, 198, 133, 30, 145, 43, 212, 195, 211, 177, 22, 49, 207, 220, 150, 4, 107, 49])), SecretKey(Scalar([169, 72, 213, 227, 152, 175, 244, 133, 219, 178, 88, 6, 181, 37, 186, 104, 215, 156, 33, 180, 42, 86, 79, 228, 58, 243, 123, 139, 88, 253, 234, 6])));
/// ALT("gdalt"): gdalt1xrqtn66m57h4a6p0ry7uza9mlm07jfk8y0f7lq0w4npwr7k32knl74w097w
static immutable ALT = KeyPair(PublicKey(Point([192, 185, 235, 91, 167, 175, 94, 232, 47, 25, 61, 193, 116, 187, 254, 223, 233, 38, 199, 35, 211, 239, 129, 238, 172, 194, 225, 250, 209, 85, 167, 255])), SecretKey(Scalar([109, 233, 26, 170, 30, 114, 168, 121, 107, 47, 99, 203, 228, 187, 218, 44, 32, 17, 207, 252, 42, 150, 92, 153, 155, 83, 168, 103, 147, 175, 133, 5])));
/// ALU("gdalu"): gdalu1xrqt566fh0j697mhnhra06c3gwurtg0p7a0z22hqc309ume7vreuz468p77
static immutable ALU = KeyPair(PublicKey(Point([192, 186, 107, 73, 187, 229, 162, 251, 119, 157, 199, 215, 235, 17, 67, 184, 53, 161, 225, 247, 94, 37, 42, 224, 196, 94, 94, 111, 62, 96, 243, 193])), SecretKey(Scalar([145, 17, 247, 152, 217, 198, 146, 195, 219, 245, 137, 161, 138, 52, 4, 30, 125, 172, 214, 221, 187, 218, 22, 179, 71, 164, 11, 117, 72, 180, 253, 8])));
/// ALV("gdalv"): gdalv1xrqt466xxn4uqfnm8yfmr2j8k66j940f3gcmy545rr5fhpjwu3nkg43rjny
static immutable ALV = KeyPair(PublicKey(Point([192, 186, 235, 70, 52, 235, 192, 38, 123, 57, 19, 177, 170, 71, 182, 181, 34, 213, 233, 138, 49, 178, 82, 180, 24, 232, 155, 134, 78, 228, 103, 100])), SecretKey(Scalar([251, 241, 190, 187, 76, 14, 127, 13, 78, 72, 92, 195, 63, 106, 44, 54, 27, 228, 46, 133, 107, 141, 174, 118, 151, 108, 195, 228, 25, 250, 51, 14])));
/// ALW("gdalw"): gdalw1xrqtk666dm2l7gukkwa8rn6x328ktzev5qpekvekcphzy3fhjzexg0rgn4s
static immutable ALW = KeyPair(PublicKey(Point([192, 187, 107, 90, 110, 213, 255, 35, 150, 179, 186, 113, 207, 70, 138, 143, 101, 139, 44, 160, 3, 155, 51, 54, 192, 110, 34, 69, 55, 144, 178, 100])), SecretKey(Scalar([189, 214, 70, 121, 52, 81, 245, 171, 191, 135, 153, 155, 254, 171, 65, 208, 67, 115, 123, 230, 45, 177, 99, 105, 237, 213, 31, 177, 15, 54, 232, 0])));
/// ALX("gdalx"): gdalx1xrqth66egvcyvf4ne6ytap6r8uvsmwq82pe06655fh4v89atvq5avzjtreq
static immutable ALX = KeyPair(PublicKey(Point([192, 187, 235, 89, 67, 48, 70, 38, 179, 206, 136, 190, 135, 67, 63, 25, 13, 184, 7, 80, 114, 253, 106, 148, 77, 234, 195, 151, 171, 96, 41, 214])), SecretKey(Scalar([21, 241, 146, 199, 13, 133, 197, 166, 211, 7, 20, 78, 31, 12, 76, 193, 178, 207, 242, 247, 95, 172, 213, 161, 144, 157, 235, 59, 203, 111, 108, 9])));
/// ALY("gdaly"): gdaly1xrqtc66tmqsjsrp0z3vul6xnfjldspm0hqa6gwlp4kk83sqgs5lq53jqw5d
static immutable ALY = KeyPair(PublicKey(Point([192, 188, 107, 75, 216, 33, 40, 12, 47, 20, 89, 207, 232, 211, 76, 190, 216, 7, 111, 184, 59, 164, 59, 225, 173, 172, 120, 192, 8, 133, 62, 10])), SecretKey(Scalar([182, 7, 88, 146, 7, 61, 141, 21, 114, 35, 187, 202, 138, 85, 125, 4, 32, 55, 106, 139, 17, 80, 58, 183, 242, 58, 133, 28, 180, 155, 208, 15])));
/// ALZ("gdalz"): gdalz1xrqte66c45gf0245yfc9pqty3ss4zh855vn83a7yzwt8sznaeer3ypcr4ak
static immutable ALZ = KeyPair(PublicKey(Point([192, 188, 235, 88, 173, 16, 151, 170, 180, 34, 112, 80, 129, 100, 140, 33, 81, 92, 244, 163, 38, 120, 247, 196, 19, 150, 120, 10, 125, 206, 71, 18])), SecretKey(Scalar([128, 125, 251, 216, 78, 102, 33, 113, 168, 177, 49, 124, 79, 163, 38, 215, 166, 140, 187, 34, 152, 85, 60, 158, 194, 72, 21, 140, 204, 88, 33, 6])));
/// AMA("gdama"): gdama1xrqvq66wvngzpl53sktvrcey8mj58ewlpa8pehn9tw9k4axw4nvt2nw8zss
static immutable AMA = KeyPair(PublicKey(Point([192, 192, 107, 78, 100, 208, 32, 254, 145, 133, 150, 193, 227, 36, 62, 229, 67, 229, 223, 15, 78, 28, 222, 101, 91, 139, 106, 244, 206, 172, 216, 181])), SecretKey(Scalar([32, 173, 9, 177, 46, 84, 229, 175, 63, 230, 229, 157, 217, 205, 23, 44, 85, 56, 84, 26, 41, 53, 126, 247, 89, 130, 187, 253, 116, 178, 118, 6])));
/// AMB("gdamb"): gdamb1xrqvp66027pvegag54csvtdu03repz8mhhhxsvdk3yza4vamyxm358xhzu2
static immutable AMB = KeyPair(PublicKey(Point([192, 192, 235, 79, 87, 130, 204, 163, 168, 165, 113, 6, 45, 188, 124, 71, 144, 136, 251, 189, 238, 104, 49, 182, 137, 5, 218, 179, 187, 33, 183, 26])), SecretKey(Scalar([43, 37, 141, 55, 173, 4, 84, 182, 99, 213, 43, 228, 61, 93, 166, 154, 101, 217, 38, 46, 155, 21, 159, 63, 152, 244, 171, 57, 211, 207, 176, 3])));
/// AMC("gdamc"): gdamc1xrqvz66cym6hyskrds0gmkuny4efrrx6x8w27xemggcn8xtelqlqyctgk6d
static immutable AMC = KeyPair(PublicKey(Point([192, 193, 107, 88, 38, 245, 114, 66, 195, 108, 30, 141, 219, 147, 37, 114, 145, 140, 218, 49, 220, 175, 27, 59, 66, 49, 51, 153, 121, 248, 62, 2])), SecretKey(Scalar([41, 42, 85, 172, 120, 70, 202, 177, 195, 50, 152, 219, 213, 76, 236, 168, 53, 243, 218, 56, 9, 117, 168, 114, 47, 99, 84, 95, 181, 72, 14, 0])));
/// AMD("gdamd"): gdamd1xrqvr669v9xq0xz73a5px9l0gkh6a0c0mfzeehmx0zvzqsq8898uvfeqfs7
static immutable AMD = KeyPair(PublicKey(Point([192, 193, 235, 69, 97, 76, 7, 152, 94, 143, 104, 19, 23, 239, 69, 175, 174, 191, 15, 218, 69, 156, 223, 102, 120, 152, 32, 64, 7, 57, 79, 198])), SecretKey(Scalar([192, 23, 71, 29, 17, 9, 221, 221, 36, 241, 140, 251, 248, 107, 104, 58, 84, 166, 37, 241, 129, 87, 124, 207, 45, 45, 87, 245, 224, 228, 100, 1])));
/// AME("gdame"): gdame1xrqvy66xfzs5ss9q24lks4mekx64znur27gn4pauzk0qyxanspw8jka6gye
static immutable AME = KeyPair(PublicKey(Point([192, 194, 107, 70, 72, 161, 72, 64, 160, 85, 127, 104, 87, 121, 177, 181, 81, 79, 131, 87, 145, 58, 135, 188, 21, 158, 2, 27, 179, 128, 92, 121])), SecretKey(Scalar([115, 18, 204, 47, 126, 99, 66, 125, 31, 203, 115, 42, 96, 247, 76, 155, 166, 63, 240, 95, 152, 139, 211, 87, 110, 215, 255, 87, 2, 220, 113, 11])));
/// AMF("gdamf"): gdamf1xrqv966ry7sffzpalj5edq2xhrgkcnuv38e67daclgdtgcxlg0a87vs6ux8
static immutable AMF = KeyPair(PublicKey(Point([192, 194, 235, 67, 39, 160, 148, 136, 61, 252, 169, 150, 129, 70, 184, 209, 108, 79, 140, 137, 243, 175, 55, 184, 250, 26, 180, 96, 223, 67, 250, 127])), SecretKey(Scalar([38, 169, 192, 22, 118, 126, 136, 101, 84, 81, 209, 121, 66, 179, 119, 234, 189, 47, 133, 86, 202, 213, 52, 219, 26, 64, 164, 130, 116, 37, 238, 14])));
/// AMG("gdamg"): gdamg1xrqvx66aece7gzkwp0ktqxva2v4tmahr3jky66z3p6jr4t5gtus2xk7e8kr
static immutable AMG = KeyPair(PublicKey(Point([192, 195, 107, 93, 206, 51, 228, 10, 206, 11, 236, 176, 25, 157, 83, 42, 189, 246, 227, 140, 172, 77, 104, 81, 14, 164, 58, 174, 136, 95, 32, 163])), SecretKey(Scalar([60, 78, 90, 105, 145, 33, 15, 167, 229, 49, 125, 172, 255, 110, 185, 111, 153, 225, 203, 100, 241, 123, 171, 190, 150, 11, 92, 47, 66, 213, 221, 15])));
/// AMH("gdamh"): gdamh1xrqv866detzrrq8l0t34wzj3rllkj8af88qh22ft3v63w2dgzjllv4eqrtg
static immutable AMH = KeyPair(PublicKey(Point([192, 195, 235, 77, 202, 196, 49, 128, 255, 122, 227, 87, 10, 81, 31, 255, 105, 31, 169, 57, 193, 117, 41, 43, 139, 53, 23, 41, 168, 20, 191, 246])), SecretKey(Scalar([255, 143, 8, 212, 73, 75, 82, 194, 67, 41, 101, 109, 86, 242, 0, 170, 81, 255, 150, 61, 121, 50, 138, 87, 131, 162, 155, 246, 151, 115, 218, 0])));
/// AMI("gdami"): gdami1xrqvg66y595hjg7467vvx6m4c7y9vyyje0ewcm204qt7vwgxggc2sln63jq
static immutable AMI = KeyPair(PublicKey(Point([192, 196, 107, 68, 161, 105, 121, 35, 213, 215, 152, 195, 107, 117, 199, 136, 86, 16, 146, 203, 242, 236, 109, 79, 168, 23, 230, 57, 6, 66, 48, 168])), SecretKey(Scalar([209, 54, 149, 42, 163, 165, 6, 168, 74, 128, 20, 245, 218, 212, 246, 148, 204, 90, 212, 29, 224, 125, 205, 89, 45, 6, 163, 4, 197, 183, 75, 3])));
/// AMJ("gdamj"): gdamj1xrqvf66d25edlzmkw4gc06k2qcgtwfwkqke000r6x4u40z87v5dmqzsya43
static immutable AMJ = KeyPair(PublicKey(Point([192, 196, 235, 77, 85, 50, 223, 139, 118, 117, 81, 135, 234, 202, 6, 16, 183, 37, 214, 5, 178, 247, 188, 122, 53, 121, 87, 136, 254, 101, 27, 176])), SecretKey(Scalar([216, 239, 144, 219, 192, 236, 191, 141, 244, 103, 85, 188, 104, 144, 4, 79, 51, 113, 108, 161, 82, 248, 129, 239, 237, 125, 105, 11, 254, 26, 20, 2])));
/// AMK("gdamk"): gdamk1xrqv266da83k66u0lz3zle7jy2dt7932qvzfg3lpyan23a64y4urs37psxz
static immutable AMK = KeyPair(PublicKey(Point([192, 197, 107, 77, 233, 227, 109, 107, 143, 248, 162, 47, 231, 210, 34, 154, 191, 22, 42, 3, 4, 148, 71, 225, 39, 102, 168, 247, 85, 37, 120, 56])), SecretKey(Scalar([102, 58, 96, 110, 35, 44, 174, 97, 125, 84, 217, 57, 180, 158, 151, 156, 238, 170, 224, 152, 176, 38, 126, 136, 123, 205, 29, 131, 182, 6, 70, 3])));
/// AML("gdaml"): gdaml1xrqvt66anlfeyj4nlrua5g656ye6cp6ls4xaty6qmqykp99h35cncqmk7gk
static immutable AML = KeyPair(PublicKey(Point([192, 197, 235, 93, 159, 211, 146, 74, 179, 248, 249, 218, 35, 84, 209, 51, 172, 7, 95, 133, 77, 213, 147, 64, 216, 9, 96, 148, 183, 141, 49, 60])), SecretKey(Scalar([158, 166, 229, 210, 204, 241, 135, 226, 72, 207, 205, 66, 249, 159, 234, 82, 151, 71, 178, 9, 211, 180, 151, 246, 246, 229, 125, 115, 251, 177, 226, 12])));
/// AMM("gdamm"): gdamm1xrqvv66xqwxhxltsnjsl9sjf5e6nuawudczhrf6tmspm83v8kh73ykysjzf
static immutable AMM = KeyPair(PublicKey(Point([192, 198, 107, 70, 3, 141, 115, 125, 112, 156, 161, 242, 194, 73, 166, 117, 62, 117, 220, 110, 5, 113, 167, 75, 220, 3, 179, 197, 135, 181, 253, 18])), SecretKey(Scalar([10, 169, 106, 57, 16, 98, 102, 181, 179, 253, 89, 219, 85, 173, 212, 90, 155, 138, 104, 55, 72, 53, 151, 74, 33, 101, 152, 28, 86, 97, 116, 1])));
/// AMN("gdamn"): gdamn1xrqvd66e3f8k9v57l35euk0qjdygqv8heaemkcavcrgypaq2druy575w08y
static immutable AMN = KeyPair(PublicKey(Point([192, 198, 235, 89, 138, 79, 98, 178, 158, 252, 105, 158, 89, 224, 147, 72, 128, 48, 247, 207, 115, 187, 99, 172, 192, 208, 64, 244, 10, 104, 248, 74])), SecretKey(Scalar([150, 133, 115, 59, 71, 39, 168, 247, 177, 185, 49, 189, 99, 153, 235, 207, 138, 154, 163, 175, 12, 12, 125, 74, 55, 141, 46, 130, 94, 146, 51, 7])));
/// AMO("gdamo"): gdamo1xrqvw66vs9dnwluksal3zczaz47ccz6gwrwezdp8v4fqtl6w4klh2kvmflf
static immutable AMO = KeyPair(PublicKey(Point([192, 199, 107, 76, 129, 91, 55, 127, 150, 135, 127, 17, 96, 93, 21, 125, 140, 11, 72, 112, 221, 145, 52, 39, 101, 82, 5, 255, 78, 173, 191, 117])), SecretKey(Scalar([184, 111, 131, 13, 54, 174, 44, 236, 126, 187, 169, 142, 172, 204, 189, 141, 185, 254, 127, 236, 232, 20, 60, 201, 60, 0, 238, 144, 244, 225, 139, 3])));
/// AMP("gdamp"): gdamp1xrqv066metzmsalz38yadhvxx88wj5dj2py467m3dqjhckhtq8gh7zanfkf
static immutable AMP = KeyPair(PublicKey(Point([192, 199, 235, 91, 202, 197, 184, 119, 226, 137, 201, 214, 221, 134, 49, 206, 233, 81, 178, 80, 73, 93, 123, 113, 104, 37, 124, 90, 235, 1, 209, 127])), SecretKey(Scalar([80, 151, 26, 5, 178, 245, 205, 174, 176, 137, 98, 91, 3, 176, 184, 214, 104, 109, 114, 250, 58, 124, 215, 202, 95, 45, 250, 235, 98, 198, 111, 15])));
/// AMQ("gdamq"): gdamq1xrqvs6646yhth684hsygf5jny3lprhmkf0emjlwv0j05xgtrteewu8kgd43
static immutable AMQ = KeyPair(PublicKey(Point([192, 200, 107, 85, 209, 46, 187, 232, 245, 188, 8, 132, 210, 83, 36, 126, 17, 223, 118, 75, 243, 185, 125, 204, 124, 159, 67, 33, 99, 94, 114, 238])), SecretKey(Scalar([233, 103, 82, 232, 23, 1, 75, 200, 214, 139, 199, 231, 204, 153, 106, 240, 214, 74, 1, 134, 129, 0, 27, 143, 254, 185, 17, 47, 70, 253, 75, 11])));
/// AMR("gdamr"): gdamr1xrqv366ny4gush8q7hr2u8xd6g7cyflvymq97gjgpdq3glsmmjvev9twrug
static immutable AMR = KeyPair(PublicKey(Point([192, 200, 235, 83, 37, 81, 200, 92, 224, 245, 198, 174, 28, 205, 210, 61, 130, 39, 236, 38, 192, 95, 34, 72, 11, 65, 20, 126, 27, 220, 153, 150])), SecretKey(Scalar([69, 60, 135, 145, 148, 250, 107, 166, 79, 216, 2, 169, 46, 113, 255, 181, 147, 59, 52, 42, 15, 230, 25, 232, 69, 89, 51, 181, 70, 54, 109, 5])));
/// AMS("gdams"): gdams1xrqvj66y6pa0le9evaefkw6rnr36yu5qju3l7whxukpqeax25lnvum777ue
static immutable AMS = KeyPair(PublicKey(Point([192, 201, 107, 68, 208, 122, 255, 228, 185, 103, 114, 155, 59, 67, 152, 227, 162, 114, 128, 151, 35, 255, 58, 230, 229, 130, 12, 244, 202, 167, 230, 206])), SecretKey(Scalar([109, 156, 126, 59, 133, 125, 15, 145, 174, 70, 27, 170, 97, 216, 108, 243, 221, 161, 68, 49, 131, 106, 215, 239, 174, 76, 94, 135, 19, 95, 9, 8])));
/// AMT("gdamt"): gdamt1xrqvn66rgqrhm2qdxhdcgz83xfspuqhfnmf0wrrpsf89z2h28vdxygv7j3l
static immutable AMT = KeyPair(PublicKey(Point([192, 201, 235, 67, 64, 7, 125, 168, 13, 53, 219, 132, 8, 241, 50, 96, 30, 2, 233, 158, 210, 247, 12, 97, 130, 78, 81, 42, 234, 59, 26, 98])), SecretKey(Scalar([141, 147, 2, 68, 72, 25, 165, 156, 238, 97, 92, 232, 80, 168, 48, 73, 241, 128, 196, 187, 150, 242, 136, 248, 230, 187, 183, 225, 175, 132, 59, 10])));
/// AMU("gdamu"): gdamu1xrqv566rzjt6z45tjznpk5g7eupujdg4ndg5mjquu3fl3ytv6xkq7cj9yve
static immutable AMU = KeyPair(PublicKey(Point([192, 202, 107, 67, 20, 151, 161, 86, 139, 144, 166, 27, 81, 30, 207, 3, 201, 53, 21, 155, 81, 77, 200, 28, 228, 83, 248, 145, 108, 209, 172, 15])), SecretKey(Scalar([225, 14, 202, 35, 149, 102, 39, 165, 17, 226, 42, 129, 235, 251, 48, 217, 69, 207, 21, 74, 125, 255, 113, 29, 76, 202, 71, 105, 214, 189, 55, 6])));
/// AMV("gdamv"): gdamv1xrqv466tvcpffkuc4yl7074zfxxmh0sff7lgfcvacc4p4e2j4wm9gj2juds
static immutable AMV = KeyPair(PublicKey(Point([192, 202, 235, 75, 102, 2, 148, 219, 152, 169, 63, 231, 250, 162, 73, 141, 187, 190, 9, 79, 190, 132, 225, 157, 198, 42, 26, 229, 82, 171, 182, 84])), SecretKey(Scalar([169, 71, 34, 106, 161, 217, 165, 155, 69, 155, 107, 127, 55, 186, 50, 119, 66, 7, 87, 212, 44, 76, 51, 220, 238, 13, 98, 24, 105, 197, 106, 8])));
/// AMW("gdamw"): gdamw1xrqvk66twdz0sc4wad49wf6uqmeet3mcpmx7r6r6r00utw5yn7l8yjs5c9r
static immutable AMW = KeyPair(PublicKey(Point([192, 203, 107, 75, 115, 68, 248, 98, 174, 235, 106, 87, 39, 92, 6, 243, 149, 199, 120, 14, 205, 225, 232, 122, 27, 223, 197, 186, 132, 159, 190, 114])), SecretKey(Scalar([40, 221, 44, 36, 54, 118, 231, 231, 253, 35, 138, 145, 82, 138, 252, 27, 165, 69, 193, 149, 197, 50, 73, 53, 15, 144, 42, 112, 158, 218, 19, 12])));
/// AMX("gdamx"): gdamx1xrqvh66uxqjtr9eczwpj5nfrqrnladgscwagewllwke32jhy2qn7c35z60v
static immutable AMX = KeyPair(PublicKey(Point([192, 203, 235, 92, 48, 36, 177, 151, 56, 19, 131, 42, 77, 35, 0, 231, 254, 181, 16, 195, 186, 140, 187, 255, 117, 179, 21, 74, 228, 80, 39, 236])), SecretKey(Scalar([62, 2, 168, 205, 239, 211, 215, 108, 98, 37, 132, 207, 40, 98, 11, 220, 7, 214, 208, 217, 77, 41, 111, 28, 76, 183, 144, 75, 164, 141, 60, 4])));
/// AMY("gdamy"): gdamy1xrqvc66tp2gjah9nsesmyejlxq6kkx9a7w4pju233v73ljulypqpkyh9ymw
static immutable AMY = KeyPair(PublicKey(Point([192, 204, 107, 75, 10, 145, 46, 220, 179, 134, 97, 178, 102, 95, 48, 53, 107, 24, 189, 243, 170, 25, 113, 81, 139, 61, 31, 203, 159, 32, 64, 27])), SecretKey(Scalar([235, 157, 160, 207, 149, 179, 43, 25, 123, 60, 100, 32, 118, 202, 77, 118, 236, 221, 95, 40, 157, 178, 140, 247, 44, 204, 85, 129, 30, 206, 176, 7])));
/// AMZ("gdamz"): gdamz1xrqve66jwqehmzvegh20uysytfnw0yad7enazqnuvz9slrh5qvrxy9gmr7d
static immutable AMZ = KeyPair(PublicKey(Point([192, 204, 235, 82, 112, 51, 125, 137, 153, 69, 212, 254, 18, 4, 90, 102, 231, 147, 173, 246, 103, 209, 2, 124, 96, 139, 15, 142, 244, 3, 6, 98])), SecretKey(Scalar([17, 109, 112, 14, 52, 44, 101, 197, 165, 163, 61, 218, 248, 66, 51, 235, 82, 58, 160, 192, 204, 92, 80, 238, 137, 103, 34, 216, 168, 27, 128, 0])));
/// ANA("gdana"): gdana1xrqdq662m9qud09zj53h5s8xsgtgmy8qywxscpfj33730drvtk9a7u4t5lc
static immutable ANA = KeyPair(PublicKey(Point([192, 208, 107, 74, 217, 65, 198, 188, 162, 149, 35, 122, 64, 230, 130, 22, 141, 144, 224, 35, 141, 12, 5, 50, 140, 125, 23, 180, 108, 93, 139, 223])), SecretKey(Scalar([198, 119, 132, 44, 88, 246, 74, 42, 61, 174, 171, 124, 105, 37, 141, 54, 54, 135, 163, 54, 71, 21, 102, 159, 31, 109, 46, 52, 118, 51, 74, 6])));
/// ANB("gdanb"): gdanb1xrqdp66ryhp3hpdhvcwp83htds45qgqj4kvv8udentd4jgtmzsffj5amyc8
static immutable ANB = KeyPair(PublicKey(Point([192, 208, 235, 67, 37, 195, 27, 133, 183, 102, 28, 19, 198, 235, 108, 43, 64, 32, 18, 173, 152, 195, 241, 185, 154, 219, 89, 33, 123, 20, 18, 153])), SecretKey(Scalar([19, 126, 75, 250, 145, 110, 245, 123, 55, 216, 139, 58, 61, 143, 27, 202, 81, 145, 248, 248, 55, 28, 233, 159, 242, 154, 85, 71, 79, 97, 47, 12])));
/// ANC("gdanc"): gdanc1xrqdz66ps7t0kmescaeyccj3vlkrl5hqy23e8hypa46js49ejcqwq299njs
static immutable ANC = KeyPair(PublicKey(Point([192, 209, 107, 65, 135, 150, 251, 111, 48, 199, 114, 76, 98, 81, 103, 236, 63, 210, 224, 34, 163, 147, 220, 129, 237, 117, 40, 84, 185, 150, 0, 224])), SecretKey(Scalar([99, 26, 41, 112, 50, 86, 44, 79, 95, 69, 46, 44, 5, 113, 128, 178, 233, 98, 32, 68, 113, 249, 1, 169, 235, 229, 90, 241, 13, 10, 89, 4])));
/// AND("gdand"): gdand1xrqdr66vkxpynuxer7w3l43muysh28nq6643wvmzm4f7x45f986cwauw0qq
static immutable AND = KeyPair(PublicKey(Point([192, 209, 235, 76, 177, 130, 73, 240, 217, 31, 157, 31, 214, 59, 225, 33, 117, 30, 96, 214, 171, 23, 51, 98, 221, 83, 227, 86, 137, 41, 245, 135])), SecretKey(Scalar([197, 18, 37, 141, 213, 154, 38, 55, 77, 30, 41, 187, 140, 97, 11, 217, 129, 128, 9, 153, 6, 65, 154, 232, 58, 30, 101, 202, 152, 22, 6, 0])));
/// ANE("gdane"): gdane1xrqdy66q56s3ndc0wu73hkr6yvu7ykxfzzvvnv3xevrfl4756arwclphx8f
static immutable ANE = KeyPair(PublicKey(Point([192, 210, 107, 64, 166, 161, 25, 183, 15, 119, 61, 27, 216, 122, 35, 57, 226, 88, 201, 16, 152, 201, 178, 38, 203, 6, 159, 215, 212, 215, 70, 236])), SecretKey(Scalar([135, 114, 46, 90, 10, 68, 93, 124, 138, 8, 126, 7, 0, 73, 158, 1, 128, 239, 61, 143, 87, 113, 9, 56, 52, 38, 222, 118, 111, 250, 137, 6])));
/// ANF("gdanf"): gdanf1xrqd966vah8q26h35zvpfjwgr4u0et8v4csraa6x8gccfe9pynmucmd64ja
static immutable ANF = KeyPair(PublicKey(Point([192, 210, 235, 76, 237, 206, 5, 106, 241, 160, 152, 20, 201, 200, 29, 120, 252, 172, 236, 174, 32, 62, 247, 70, 58, 49, 132, 228, 161, 36, 247, 204])), SecretKey(Scalar([77, 89, 250, 38, 56, 46, 157, 112, 80, 160, 101, 84, 7, 100, 116, 247, 17, 26, 86, 158, 211, 173, 95, 239, 50, 171, 22, 47, 43, 175, 39, 6])));
/// ANG("gdang"): gdang1xrqdx662dzahz9q0ysfvzynu2ujd5fq06gn24ldqps9e6rzh75n8wgc9dfy
static immutable ANG = KeyPair(PublicKey(Point([192, 211, 107, 74, 104, 187, 113, 20, 15, 36, 18, 193, 18, 124, 87, 36, 218, 36, 15, 210, 38, 170, 253, 160, 12, 11, 157, 12, 87, 245, 38, 119])), SecretKey(Scalar([123, 203, 100, 220, 147, 104, 40, 213, 154, 203, 6, 46, 22, 208, 220, 120, 164, 156, 251, 168, 23, 48, 219, 3, 176, 211, 214, 121, 152, 36, 95, 2])));
/// ANH("gdanh"): gdanh1xrqd8665l2n4jy9xq5y5jy38lqfu66y5q0vxcgqa2vxe8hdljr5aq4msk7x
static immutable ANH = KeyPair(PublicKey(Point([192, 211, 235, 84, 250, 167, 89, 16, 166, 5, 9, 73, 18, 39, 248, 19, 205, 104, 148, 3, 216, 108, 32, 29, 83, 13, 147, 221, 191, 144, 233, 208])), SecretKey(Scalar([189, 203, 130, 88, 4, 126, 2, 82, 93, 30, 183, 196, 9, 145, 67, 231, 243, 115, 154, 4, 220, 35, 150, 4, 230, 88, 247, 185, 127, 30, 139, 13])));
/// ANI("gdani"): gdani1xrqdg66flq8gccgu873alk4v6h3wk3mftv4llhhayrrr48yzgkk9jurudfe
static immutable ANI = KeyPair(PublicKey(Point([192, 212, 107, 73, 248, 14, 140, 97, 28, 63, 163, 223, 218, 172, 213, 226, 235, 71, 105, 91, 43, 255, 222, 253, 32, 198, 58, 156, 130, 69, 172, 89])), SecretKey(Scalar([114, 88, 18, 170, 109, 162, 27, 60, 166, 212, 138, 24, 10, 236, 33, 232, 34, 188, 185, 163, 72, 80, 185, 74, 226, 13, 225, 28, 192, 35, 2, 0])));
/// ANJ("gdanj"): gdanj1xrqdf66xx9lpyrukzv09qw552c4tvnat75avecwaj5xvu6tvjsq8qqp6qd7
static immutable ANJ = KeyPair(PublicKey(Point([192, 212, 235, 70, 49, 126, 18, 15, 150, 19, 30, 80, 58, 148, 86, 42, 182, 79, 171, 245, 58, 204, 225, 221, 149, 12, 206, 105, 108, 148, 0, 112])), SecretKey(Scalar([95, 154, 8, 42, 201, 248, 177, 13, 184, 155, 28, 242, 136, 174, 118, 3, 138, 42, 23, 29, 96, 251, 63, 134, 161, 36, 221, 109, 139, 79, 230, 0])));
/// ANK("gdank"): gdank1xrqd266ldx7yk894d48yct8frsaxwwl6rplt594hmllyrl5nplqjw5sz3a2
static immutable ANK = KeyPair(PublicKey(Point([192, 213, 107, 95, 105, 188, 75, 28, 181, 109, 78, 76, 44, 233, 28, 58, 103, 59, 250, 24, 126, 186, 22, 183, 223, 254, 65, 254, 147, 15, 193, 39])), SecretKey(Scalar([80, 80, 45, 26, 204, 5, 66, 187, 226, 68, 123, 188, 228, 86, 118, 40, 172, 29, 10, 152, 178, 177, 19, 228, 71, 9, 150, 209, 246, 107, 104, 5])));
/// ANL("gdanl"): gdanl1xrqdt66mjar66latg5r3zq93j7m57hqntxxekvxk3dn5t695qkwl6wx9vdh
static immutable ANL = KeyPair(PublicKey(Point([192, 213, 235, 91, 151, 71, 173, 127, 171, 69, 7, 17, 0, 177, 151, 183, 79, 92, 19, 89, 141, 155, 48, 214, 139, 103, 69, 232, 180, 5, 157, 253])), SecretKey(Scalar([214, 41, 115, 243, 168, 51, 129, 70, 242, 99, 167, 207, 166, 68, 33, 110, 92, 154, 249, 94, 100, 128, 242, 248, 8, 73, 227, 172, 230, 248, 153, 14])));
/// ANM("gdanm"): gdanm1xrqdv66zu2e2g04vugut65l6rdnluen8ty2ufgfpr9stg43eu9llvfwhudz
static immutable ANM = KeyPair(PublicKey(Point([192, 214, 107, 66, 226, 178, 164, 62, 172, 226, 56, 189, 83, 250, 27, 103, 254, 102, 103, 89, 21, 196, 161, 33, 25, 96, 180, 86, 57, 225, 127, 246])), SecretKey(Scalar([250, 178, 104, 42, 233, 145, 164, 145, 158, 194, 246, 24, 224, 29, 137, 220, 129, 136, 180, 230, 239, 72, 223, 170, 195, 194, 24, 224, 193, 72, 73, 7])));
/// ANN("gdann"): gdann1xrqdd660mtwy40ff6a36qmhnvychs46usr2yqpd3ejgs5cr2vukygju8g65
static immutable ANN = KeyPair(PublicKey(Point([192, 214, 235, 79, 218, 220, 74, 189, 41, 215, 99, 160, 110, 243, 97, 49, 120, 87, 92, 128, 212, 64, 5, 177, 204, 145, 10, 96, 106, 103, 44, 68])), SecretKey(Scalar([119, 20, 139, 157, 155, 137, 209, 124, 25, 160, 174, 181, 18, 224, 106, 207, 8, 253, 224, 204, 140, 41, 221, 121, 212, 196, 177, 55, 57, 195, 101, 9])));
/// ANO("gdano"): gdano1xrqdw66eg84vs68wmkvv9vdp955d8nxr2u20qks2z57gemjwm3sw770k8ve
static immutable ANO = KeyPair(PublicKey(Point([192, 215, 107, 89, 65, 234, 200, 104, 238, 221, 152, 194, 177, 161, 45, 40, 211, 204, 195, 87, 20, 240, 90, 10, 21, 60, 140, 238, 78, 220, 96, 239])), SecretKey(Scalar([214, 255, 162, 131, 72, 12, 36, 20, 138, 49, 12, 204, 36, 98, 180, 230, 220, 137, 71, 24, 168, 139, 67, 16, 21, 144, 117, 103, 87, 17, 190, 10])));
/// ANP("gdanp"): gdanp1xrqd066s2g5gtatkql5q28hlwrmelqckuy2h30zjx0rkeqwnuq9vwcfsjnq
static immutable ANP = KeyPair(PublicKey(Point([192, 215, 235, 80, 82, 40, 133, 245, 118, 7, 232, 5, 30, 255, 112, 247, 159, 131, 22, 225, 21, 120, 188, 82, 51, 199, 108, 129, 211, 224, 10, 199])), SecretKey(Scalar([133, 20, 27, 23, 15, 75, 157, 227, 173, 125, 241, 177, 27, 101, 141, 20, 165, 134, 220, 70, 46, 64, 63, 239, 251, 255, 17, 251, 222, 168, 45, 0])));
/// ANQ("gdanq"): gdanq1xrqds668grw2kjxaex04zaedg3p4u4nzj9n9weda94xf2a6mastw66stt3x
static immutable ANQ = KeyPair(PublicKey(Point([192, 216, 107, 71, 64, 220, 171, 72, 221, 201, 159, 81, 119, 45, 68, 67, 94, 86, 98, 145, 102, 87, 101, 189, 45, 76, 149, 119, 91, 236, 22, 237])), SecretKey(Scalar([50, 193, 99, 203, 106, 45, 101, 161, 101, 35, 81, 171, 65, 7, 232, 73, 226, 113, 26, 123, 10, 243, 124, 44, 211, 10, 64, 136, 190, 76, 128, 2])));
/// ANR("gdanr"): gdanr1xrqd366v3sdryn0xul8ws5mtd2j2yxwz6xvsz38r5sqd0map6mr3waa70fl
static immutable ANR = KeyPair(PublicKey(Point([192, 216, 235, 76, 140, 26, 50, 77, 230, 231, 206, 232, 83, 107, 106, 164, 162, 25, 194, 209, 153, 1, 68, 227, 164, 0, 215, 239, 161, 214, 199, 23])), SecretKey(Scalar([8, 109, 144, 99, 91, 199, 41, 124, 143, 254, 20, 221, 21, 80, 14, 101, 225, 125, 0, 159, 171, 200, 16, 121, 179, 60, 101, 248, 22, 255, 53, 5])));
/// ANS("gdans"): gdans1xrqdj66x467g20gla4vk2ftuh2sd9hfvfhjq38tqfjeel34p9acnu370p07
static immutable ANS = KeyPair(PublicKey(Point([192, 217, 107, 70, 174, 188, 133, 61, 31, 237, 89, 101, 37, 124, 186, 160, 210, 221, 44, 77, 228, 8, 157, 96, 76, 179, 159, 198, 161, 47, 113, 62])), SecretKey(Scalar([198, 130, 132, 165, 196, 116, 119, 224, 209, 99, 17, 119, 32, 175, 218, 51, 82, 42, 15, 110, 104, 203, 92, 236, 250, 176, 22, 199, 209, 119, 81, 13])));
/// ANT("gdant"): gdant1xrqdn665ej2qm03xze8ehw304yq5unsd6cz7ga308xfpmywc7vph70kunjd
static immutable ANT = KeyPair(PublicKey(Point([192, 217, 235, 84, 204, 148, 13, 190, 38, 22, 79, 155, 186, 47, 169, 1, 78, 78, 13, 214, 5, 228, 118, 47, 57, 146, 29, 145, 216, 243, 3, 127])), SecretKey(Scalar([218, 29, 206, 3, 14, 100, 201, 98, 120, 0, 22, 74, 220, 31, 252, 185, 29, 81, 63, 28, 170, 115, 193, 199, 217, 10, 67, 137, 74, 85, 24, 0])));
/// ANU("gdanu"): gdanu1xrqd5668s3ycusa50v5x8zdat0046dcwm547hcjxmzugcfad0lycg2evh70
static immutable ANU = KeyPair(PublicKey(Point([192, 218, 107, 71, 132, 73, 142, 67, 180, 123, 40, 99, 137, 189, 91, 223, 93, 55, 14, 221, 43, 235, 226, 70, 216, 184, 140, 39, 173, 127, 201, 132])), SecretKey(Scalar([134, 103, 236, 193, 134, 230, 135, 29, 126, 229, 169, 53, 161, 136, 25, 30, 252, 145, 40, 108, 59, 90, 196, 200, 71, 184, 199, 148, 227, 103, 187, 8])));
/// ANV("gdanv"): gdanv1xrqd466kv0s0t7es4vys8hzacwmgx0mpmwzt6fna3l3wpu0kjgglyl7lrt3
static immutable ANV = KeyPair(PublicKey(Point([192, 218, 235, 86, 99, 224, 245, 251, 48, 171, 9, 3, 220, 93, 195, 182, 131, 63, 97, 219, 132, 189, 38, 125, 143, 226, 224, 241, 246, 146, 17, 242])), SecretKey(Scalar([22, 93, 120, 177, 187, 183, 184, 241, 111, 238, 75, 103, 39, 60, 150, 63, 162, 25, 175, 40, 200, 227, 79, 192, 152, 225, 65, 92, 170, 57, 238, 8])));
/// ANW("gdanw"): gdanw1xrqdk66ga7wwykn8s989ckll0jqwlf8vhtp2e49f9y03j4m77gj3k5jh9np
static immutable ANW = KeyPair(PublicKey(Point([192, 219, 107, 72, 239, 156, 226, 90, 103, 129, 78, 92, 91, 255, 124, 128, 239, 164, 236, 186, 194, 172, 212, 169, 41, 31, 25, 87, 126, 242, 37, 27])), SecretKey(Scalar([236, 22, 39, 131, 60, 15, 26, 29, 232, 1, 35, 78, 19, 113, 221, 237, 130, 28, 69, 127, 218, 235, 15, 153, 211, 35, 106, 41, 40, 222, 80, 4])));
/// ANX("gdanx"): gdanx1xrqdh6625wkpcy2u6gja93ddu0zv4qg00yhkexq7wun4wvc344jtvmtczyq
static immutable ANX = KeyPair(PublicKey(Point([192, 219, 235, 74, 163, 172, 28, 17, 92, 210, 37, 210, 197, 173, 227, 196, 202, 129, 15, 121, 47, 108, 152, 30, 119, 39, 87, 51, 17, 173, 100, 182])), SecretKey(Scalar([19, 239, 198, 126, 58, 251, 36, 91, 6, 254, 240, 146, 162, 192, 172, 50, 198, 107, 103, 12, 7, 206, 32, 2, 83, 114, 11, 145, 35, 31, 154, 11])));
/// ANY("gdany"): gdany1xrqdc66d8rvs6pph00q0ejkt6t8t7rlma9203e8llm3e5tg6tz45sdt9vrn
static immutable ANY = KeyPair(PublicKey(Point([192, 220, 107, 77, 56, 217, 13, 4, 55, 123, 192, 252, 202, 203, 210, 206, 191, 15, 251, 233, 84, 248, 228, 255, 254, 227, 154, 45, 26, 88, 171, 72])), SecretKey(Scalar([26, 215, 75, 88, 101, 240, 152, 230, 93, 251, 124, 33, 197, 4, 126, 100, 220, 131, 100, 72, 248, 252, 156, 147, 133, 119, 101, 81, 9, 171, 156, 8])));
/// ANZ("gdanz"): gdanz1xrqde664lmstlmj69zdqapn6mgzfl9d4ys0sjrcj6g759f29ys9p5jluapj
static immutable ANZ = KeyPair(PublicKey(Point([192, 220, 235, 85, 254, 224, 191, 238, 90, 40, 154, 14, 134, 122, 218, 4, 159, 149, 181, 36, 31, 9, 15, 18, 210, 61, 66, 165, 69, 36, 10, 26])), SecretKey(Scalar([196, 28, 13, 175, 202, 208, 137, 11, 112, 248, 75, 204, 173, 122, 113, 245, 213, 133, 71, 42, 33, 22, 49, 241, 111, 171, 115, 183, 43, 2, 127, 15])));
/// AOA("gdaoa"): gdaoa1xrqwq66u6fchutda6x8c0q73hyp87997s4vdy4wzh950626s5euwvxy7lz8
static immutable AOA = KeyPair(PublicKey(Point([192, 224, 107, 92, 210, 113, 126, 45, 189, 209, 143, 135, 131, 209, 185, 2, 127, 20, 190, 133, 88, 210, 85, 194, 185, 104, 253, 43, 80, 166, 120, 230])), SecretKey(Scalar([29, 247, 139, 87, 211, 199, 6, 198, 131, 115, 130, 15, 126, 202, 37, 210, 143, 166, 18, 57, 212, 208, 254, 147, 54, 179, 117, 147, 5, 204, 51, 4])));
/// AOB("gdaob"): gdaob1xrqwp663us8f4vw9f2u32hkmye2ffakpw5fwqu0z8l67k8x47xckx39zcwp
static immutable AOB = KeyPair(PublicKey(Point([192, 224, 235, 81, 228, 14, 154, 177, 197, 74, 185, 21, 94, 219, 38, 84, 148, 246, 193, 117, 18, 224, 113, 226, 63, 245, 235, 28, 213, 241, 177, 99])), SecretKey(Scalar([69, 146, 36, 90, 151, 114, 226, 138, 231, 152, 226, 240, 162, 38, 221, 101, 237, 223, 248, 213, 123, 17, 37, 218, 63, 74, 176, 77, 217, 37, 189, 15])));
/// AOC("gdaoc"): gdaoc1xrqwz669rde02jn03hxdndxx6ek4w7zhje6vu3dcj52mtl4j9dx3y8qd8lj
static immutable AOC = KeyPair(PublicKey(Point([192, 225, 107, 69, 27, 114, 245, 74, 111, 141, 204, 217, 180, 198, 214, 109, 87, 120, 87, 150, 116, 206, 69, 184, 149, 21, 181, 254, 178, 43, 77, 18])), SecretKey(Scalar([243, 66, 61, 71, 204, 210, 115, 53, 206, 159, 90, 38, 86, 197, 229, 181, 252, 157, 31, 92, 167, 42, 218, 232, 20, 89, 140, 82, 245, 139, 134, 6])));
/// AOD("gdaod"): gdaod1xrqwr66ygdj53zh0yhzce7cjcg2cme8akjfszwx9y5wlprw6htncv6ye4vs
static immutable AOD = KeyPair(PublicKey(Point([192, 225, 235, 68, 67, 101, 72, 138, 239, 37, 197, 140, 251, 18, 194, 21, 141, 228, 253, 180, 147, 1, 56, 197, 37, 29, 240, 141, 218, 186, 231, 134])), SecretKey(Scalar([156, 185, 135, 38, 14, 174, 111, 74, 30, 150, 227, 46, 21, 242, 182, 20, 140, 77, 123, 133, 195, 37, 188, 136, 136, 176, 51, 153, 194, 73, 66, 14])));
/// AOE("gdaoe"): gdaoe1xrqwy66j6lyy4sm9ln4yxyswq4du0f627tgpahh8y8zq3e5qdrrd6xt9jvf
static immutable AOE = KeyPair(PublicKey(Point([192, 226, 107, 82, 215, 200, 74, 195, 101, 252, 234, 67, 18, 14, 5, 91, 199, 167, 74, 242, 208, 30, 222, 231, 33, 196, 8, 230, 128, 104, 198, 221])), SecretKey(Scalar([184, 90, 152, 102, 166, 121, 152, 144, 23, 194, 237, 56, 183, 238, 250, 159, 87, 123, 126, 102, 174, 72, 121, 62, 130, 236, 52, 178, 64, 85, 242, 0])));
/// AOF("gdaof"): gdaof1xrqw96607h2c5zuewhr9470vdcf8gukyvlcspy36t08rtpxqfhwcc3xp4pf
static immutable AOF = KeyPair(PublicKey(Point([192, 226, 235, 79, 245, 213, 138, 11, 153, 117, 198, 90, 249, 236, 110, 18, 116, 114, 196, 103, 241, 0, 146, 58, 91, 206, 53, 132, 192, 77, 221, 140])), SecretKey(Scalar([178, 33, 43, 19, 46, 25, 9, 115, 69, 255, 154, 94, 99, 134, 89, 11, 213, 52, 186, 18, 27, 244, 236, 207, 179, 131, 166, 24, 213, 33, 19, 10])));
/// AOG("gdaog"): gdaog1xrqwx66w0lcfnadeqz2ulypslzcvkfk3202y3y952e2cjl8v4dzzzk0wrlz
static immutable AOG = KeyPair(PublicKey(Point([192, 227, 107, 78, 127, 240, 153, 245, 185, 0, 149, 207, 144, 48, 248, 176, 203, 38, 209, 83, 212, 72, 144, 180, 86, 85, 137, 124, 236, 171, 68, 33])), SecretKey(Scalar([42, 21, 56, 57, 191, 216, 124, 46, 180, 142, 51, 209, 140, 65, 125, 58, 97, 45, 157, 18, 111, 152, 144, 4, 3, 65, 163, 225, 19, 228, 222, 11])));
/// AOH("gdaoh"): gdaoh1xrqw866h3nvl5jvfwy429yvq4r9f69vz7n60z9z90xc98vf0zzxewzs8c56
static immutable AOH = KeyPair(PublicKey(Point([192, 227, 235, 87, 140, 217, 250, 73, 137, 113, 42, 162, 145, 128, 168, 202, 157, 21, 130, 244, 244, 241, 20, 69, 121, 176, 83, 177, 47, 16, 141, 151])), SecretKey(Scalar([207, 193, 206, 143, 32, 66, 5, 123, 95, 220, 219, 12, 192, 187, 106, 53, 133, 176, 254, 178, 150, 102, 222, 65, 149, 55, 201, 253, 20, 19, 93, 12])));
/// AOI("gdaoi"): gdaoi1xrqwg660l2xap3zsthznxch0pjgqkswzl5gu88ksdsfrghhtsu5fg8g52u2
static immutable AOI = KeyPair(PublicKey(Point([192, 228, 107, 79, 250, 141, 208, 196, 80, 93, 197, 51, 98, 239, 12, 144, 11, 65, 194, 253, 17, 195, 158, 208, 108, 18, 52, 94, 235, 135, 40, 148])), SecretKey(Scalar([136, 207, 59, 134, 108, 48, 116, 112, 49, 135, 111, 70, 119, 202, 9, 92, 218, 237, 23, 19, 123, 196, 157, 194, 46, 82, 169, 131, 182, 63, 20, 14])));
/// AOJ("gdaoj"): gdaoj1xrqwf6639tuka7hr3mmssz79mgc0jjchhe96kql73nn4eec3xdx46xvf9j0
static immutable AOJ = KeyPair(PublicKey(Point([192, 228, 235, 81, 42, 249, 110, 250, 227, 142, 247, 8, 11, 197, 218, 48, 249, 75, 23, 190, 75, 171, 3, 254, 140, 231, 92, 231, 17, 51, 77, 93])), SecretKey(Scalar([83, 162, 73, 12, 121, 9, 92, 158, 7, 170, 237, 245, 7, 237, 25, 201, 62, 72, 141, 89, 197, 13, 94, 54, 247, 244, 185, 242, 141, 174, 10, 3])));
/// AOK("gdaok"): gdaok1xrqw266ykkf6x3tmhvf6za0e0hc0kmstp2h2j2tgwhazc8medy3auek76fq
static immutable AOK = KeyPair(PublicKey(Point([192, 229, 107, 68, 181, 147, 163, 69, 123, 187, 19, 161, 117, 249, 125, 240, 251, 110, 11, 10, 174, 169, 41, 104, 117, 250, 44, 31, 121, 105, 35, 222])), SecretKey(Scalar([82, 20, 87, 23, 239, 12, 253, 73, 41, 207, 136, 100, 44, 94, 193, 231, 245, 105, 23, 38, 160, 203, 35, 158, 236, 149, 145, 25, 18, 80, 212, 7])));
/// AOL("gdaol"): gdaol1xrqwt66ztuv6jx7r6mfwjamzjss5kkuv84cq322lvg9rm5csjuswy8cf9xk
static immutable AOL = KeyPair(PublicKey(Point([192, 229, 235, 66, 95, 25, 169, 27, 195, 214, 210, 233, 119, 98, 148, 33, 75, 91, 140, 61, 112, 8, 169, 95, 98, 10, 61, 211, 16, 151, 32, 226])), SecretKey(Scalar([0, 203, 187, 109, 137, 102, 131, 13, 119, 48, 104, 197, 116, 134, 68, 114, 96, 101, 31, 48, 27, 196, 222, 168, 22, 128, 133, 176, 160, 0, 177, 13])));
/// AOM("gdaom"): gdaom1xrqwv6622y7s2d5ecnty03eaym8hcqzynpt6lnat7hgsln923u9esaaa5kf
static immutable AOM = KeyPair(PublicKey(Point([192, 230, 107, 74, 81, 61, 5, 54, 153, 196, 214, 71, 199, 61, 38, 207, 124, 0, 68, 152, 87, 175, 207, 171, 245, 209, 15, 204, 170, 143, 11, 152])), SecretKey(Scalar([182, 171, 237, 58, 226, 177, 98, 96, 243, 138, 130, 62, 173, 45, 182, 76, 34, 208, 191, 182, 28, 209, 1, 81, 104, 110, 22, 68, 224, 173, 233, 7])));
/// AON("gdaon"): gdaon1xrqwd660uraemumh0wywm2er47l8eha9yjwtg8ymw76x34qcsrqzxjejhrm
static immutable AON = KeyPair(PublicKey(Point([192, 230, 235, 79, 224, 251, 157, 243, 119, 123, 136, 237, 171, 35, 175, 190, 124, 223, 165, 36, 156, 180, 28, 155, 119, 180, 104, 212, 24, 128, 192, 35])), SecretKey(Scalar([125, 39, 192, 128, 117, 138, 227, 206, 87, 168, 77, 143, 156, 253, 127, 172, 130, 145, 90, 147, 120, 144, 239, 199, 0, 68, 120, 63, 23, 169, 213, 7])));
/// AOO("gdaoo"): gdaoo1xrqww665sgm0zykuxn26l8tznxn9n6rzjaq85sulpgshyw2gc9x47nrwmg4
static immutable AOO = KeyPair(PublicKey(Point([192, 231, 107, 84, 130, 54, 241, 18, 220, 52, 213, 175, 157, 98, 153, 166, 89, 232, 98, 151, 64, 122, 67, 159, 10, 33, 114, 57, 72, 193, 77, 95])), SecretKey(Scalar([51, 111, 123, 64, 79, 72, 41, 252, 12, 63, 107, 184, 207, 95, 41, 186, 180, 88, 213, 166, 127, 121, 186, 8, 62, 83, 75, 155, 194, 30, 214, 10])));
/// AOP("gdaop"): gdaop1xrqw066n4a6cer3thujnm8zc5zshruht6rj0dk0c8cnr77rht7lryq30qwl
static immutable AOP = KeyPair(PublicKey(Point([192, 231, 235, 83, 175, 117, 140, 142, 43, 191, 37, 61, 156, 88, 160, 161, 113, 242, 235, 208, 228, 246, 217, 248, 62, 38, 63, 120, 119, 95, 190, 50])), SecretKey(Scalar([208, 245, 252, 159, 139, 240, 65, 105, 94, 24, 151, 75, 132, 79, 249, 196, 126, 251, 135, 15, 51, 175, 2, 107, 57, 166, 34, 66, 142, 58, 95, 1])));
/// AOQ("gdaoq"): gdaoq1xrqws66ks68wfev63zunsckf8psgmqnvsplqxtdrnwp37ukfk8rj52wg7ft
static immutable AOQ = KeyPair(PublicKey(Point([192, 232, 107, 86, 134, 142, 228, 229, 154, 136, 185, 56, 98, 201, 56, 96, 141, 130, 108, 128, 126, 3, 45, 163, 155, 131, 31, 114, 201, 177, 199, 42])), SecretKey(Scalar([102, 254, 255, 232, 29, 137, 102, 12, 125, 211, 127, 169, 85, 153, 10, 4, 71, 240, 176, 233, 19, 4, 55, 106, 164, 129, 79, 98, 197, 142, 69, 14])));
/// AOR("gdaor"): gdaor1xrqw366q4cqqd95zskfesrpfj2qj3y3gdaath7qyak74lhwpjsmfvcyzdej
static immutable AOR = KeyPair(PublicKey(Point([192, 232, 235, 64, 174, 0, 6, 150, 130, 133, 147, 152, 12, 41, 146, 129, 40, 146, 40, 111, 122, 187, 248, 4, 237, 189, 95, 221, 193, 148, 54, 150])), SecretKey(Scalar([22, 32, 33, 222, 248, 133, 169, 224, 140, 231, 76, 80, 74, 54, 49, 27, 144, 252, 162, 187, 144, 115, 213, 219, 197, 36, 157, 35, 226, 23, 46, 13])));
/// AOS("gdaos"): gdaos1xrqwj66wn4ff8ag68g96f9zpc4kxefsj49lr65zfrswy5j2jfqcu6lgdy39
static immutable AOS = KeyPair(PublicKey(Point([192, 233, 107, 78, 157, 82, 147, 245, 26, 58, 11, 164, 148, 65, 197, 108, 108, 166, 18, 169, 126, 61, 80, 73, 28, 28, 74, 73, 82, 72, 49, 205])), SecretKey(Scalar([21, 198, 247, 41, 76, 200, 40, 219, 105, 191, 236, 246, 246, 52, 0, 166, 143, 20, 163, 137, 95, 101, 30, 198, 132, 107, 205, 227, 225, 96, 241, 5])));
/// AOT("gdaot"): gdaot1xrqwn66mm6ljlvzle9llkkgqzlw2xur2382quw9j08n4e5s4gwyrvle96cg
static immutable AOT = KeyPair(PublicKey(Point([192, 233, 235, 91, 222, 191, 47, 176, 95, 201, 127, 251, 89, 0, 23, 220, 163, 112, 106, 137, 212, 14, 56, 178, 121, 231, 92, 210, 21, 67, 136, 54])), SecretKey(Scalar([132, 176, 80, 157, 23, 74, 245, 13, 238, 91, 225, 71, 89, 252, 15, 210, 203, 226, 29, 113, 152, 102, 99, 46, 208, 165, 12, 59, 140, 176, 11, 10])));
/// AOU("gdaou"): gdaou1xrqw5667dmtqe06q2yhk6j8mcsfpjqt4ndysj92wl0cjzs6kh8e0wspdr2z
static immutable AOU = KeyPair(PublicKey(Point([192, 234, 107, 94, 110, 214, 12, 191, 64, 81, 47, 109, 72, 251, 196, 18, 25, 1, 117, 155, 73, 9, 21, 78, 251, 241, 33, 67, 86, 185, 242, 247])), SecretKey(Scalar([47, 208, 56, 116, 6, 81, 25, 176, 210, 120, 35, 68, 60, 126, 247, 21, 61, 96, 204, 141, 167, 71, 253, 39, 145, 247, 48, 181, 184, 58, 18, 5])));
/// AOV("gdaov"): gdaov1xrqw466qsevkynj84p6tfkfcpvdtnlmrpsa54dhq6xkm67wf8avfuqh7pd9
static immutable AOV = KeyPair(PublicKey(Point([192, 234, 235, 64, 134, 89, 98, 78, 71, 168, 116, 180, 217, 56, 11, 26, 185, 255, 99, 12, 59, 74, 182, 224, 209, 173, 189, 121, 201, 63, 88, 158])), SecretKey(Scalar([200, 246, 38, 95, 181, 151, 37, 139, 152, 234, 161, 29, 139, 189, 191, 122, 155, 16, 209, 179, 106, 118, 232, 217, 172, 220, 20, 129, 240, 71, 11, 3])));
/// AOW("gdaow"): gdaow1xrqwk669cnqnpzmqm7w59weysl04jhplgvpx6ek0zq4np9dstnkezaz0yyr
static immutable AOW = KeyPair(PublicKey(Point([192, 235, 107, 69, 196, 193, 48, 139, 96, 223, 157, 66, 187, 36, 135, 223, 89, 92, 63, 67, 2, 109, 102, 207, 16, 43, 48, 149, 176, 92, 237, 145])), SecretKey(Scalar([222, 54, 168, 22, 135, 195, 56, 119, 171, 104, 54, 192, 180, 82, 239, 69, 108, 49, 228, 152, 170, 27, 38, 92, 152, 39, 206, 205, 123, 13, 185, 1])));
/// AOX("gdaox"): gdaox1xrqwh66gv35a7q950j44hlq2l4tm6vtzut234m2u9j2z5zkfwjcau0y9tyc
static immutable AOX = KeyPair(PublicKey(Point([192, 235, 235, 72, 100, 105, 223, 0, 180, 124, 171, 91, 252, 10, 253, 87, 189, 49, 98, 226, 213, 26, 237, 92, 44, 148, 42, 10, 201, 116, 177, 222])), SecretKey(Scalar([180, 226, 105, 243, 149, 117, 101, 72, 143, 98, 162, 241, 225, 240, 244, 140, 155, 219, 242, 216, 54, 142, 131, 68, 10, 148, 110, 208, 233, 153, 151, 9])));
/// AOY("gdaoy"): gdaoy1xrqwc66spnruhshmclc5q3mpgme0tpacnlk02pvzddupcepr2dacgt8wsn7
static immutable AOY = KeyPair(PublicKey(Point([192, 236, 107, 80, 12, 199, 203, 194, 251, 199, 241, 64, 71, 97, 70, 242, 245, 135, 184, 159, 236, 245, 5, 130, 107, 120, 28, 100, 35, 83, 123, 132])), SecretKey(Scalar([197, 81, 68, 33, 19, 206, 210, 242, 44, 97, 39, 120, 227, 215, 228, 220, 193, 134, 147, 46, 123, 136, 62, 90, 161, 162, 65, 148, 107, 109, 64, 5])));
/// AOZ("gdaoz"): gdaoz1xrqwe66g54p5u5etg7v9d8gqecvddlz68ur40nkmfzumkxtks7xkcdm8pcz
static immutable AOZ = KeyPair(PublicKey(Point([192, 236, 235, 72, 165, 67, 78, 83, 43, 71, 152, 86, 157, 0, 206, 24, 214, 252, 90, 63, 7, 87, 206, 219, 72, 185, 187, 25, 118, 135, 141, 108])), SecretKey(Scalar([224, 244, 242, 163, 82, 195, 0, 87, 37, 235, 168, 201, 248, 6, 110, 236, 58, 220, 72, 203, 142, 68, 251, 186, 170, 96, 85, 174, 151, 243, 92, 4])));
/// APA("gdapa"): gdapa1xrq0q66df05su2rl7y209vnqw4dwuxa9kmssc2jzq86j47edfl7fwjchqz5
static immutable APA = KeyPair(PublicKey(Point([192, 240, 107, 77, 75, 233, 14, 40, 127, 241, 20, 242, 178, 96, 117, 90, 238, 27, 165, 182, 225, 12, 42, 66, 1, 245, 42, 251, 45, 79, 252, 151])), SecretKey(Scalar([138, 8, 81, 44, 240, 242, 74, 142, 188, 191, 62, 82, 6, 76, 8, 117, 179, 199, 112, 255, 93, 245, 130, 116, 199, 197, 139, 92, 89, 120, 103, 15])));
/// APB("gdapb"): gdapb1xrq0p66sjtcr825ktqnh4w6hv8dzp2cmruglh2l05ppr0e88eyjuwrsugh7
static immutable APB = KeyPair(PublicKey(Point([192, 240, 235, 80, 146, 240, 51, 170, 150, 88, 39, 122, 187, 87, 97, 218, 32, 171, 27, 31, 17, 251, 171, 239, 160, 66, 55, 228, 231, 201, 37, 199])), SecretKey(Scalar([159, 5, 2, 160, 83, 34, 164, 252, 120, 223, 223, 167, 189, 231, 225, 249, 204, 25, 144, 109, 99, 227, 29, 80, 253, 76, 127, 48, 17, 199, 6, 11])));
/// APC("gdapc"): gdapc1xrq0z66gsv75uv8al44d8c2fz0wpz7efmm6ezxgvqty2zt0sz39xqewd4zl
static immutable APC = KeyPair(PublicKey(Point([192, 241, 107, 72, 131, 61, 78, 48, 253, 253, 106, 211, 225, 73, 19, 220, 17, 123, 41, 222, 245, 145, 25, 12, 2, 200, 161, 45, 240, 20, 74, 96])), SecretKey(Scalar([154, 221, 21, 113, 147, 192, 101, 161, 149, 194, 229, 60, 78, 63, 172, 149, 76, 112, 225, 207, 226, 80, 156, 154, 110, 86, 120, 123, 53, 135, 6, 11])));
/// APD("gdapd"): gdapd1xrq0r66rhpa2r0k2fplw3z62rrp89hzuk3n53vn3ctjtsd7vajusj4gc9fr
static immutable APD = KeyPair(PublicKey(Point([192, 241, 235, 67, 184, 122, 161, 190, 202, 72, 126, 232, 139, 74, 24, 194, 114, 220, 92, 180, 103, 72, 178, 113, 194, 228, 184, 55, 204, 236, 185, 9])), SecretKey(Scalar([26, 151, 197, 114, 255, 98, 11, 240, 141, 15, 165, 63, 177, 179, 119, 236, 19, 176, 216, 84, 86, 45, 68, 10, 49, 94, 34, 217, 184, 165, 129, 5])));
/// APE("gdape"): gdape1xrq0y66pcmxly6xvxr54x4qj5jcnlne7pm86yfdxnhwpzlgtuus6cqapjh3
static immutable APE = KeyPair(PublicKey(Point([192, 242, 107, 65, 198, 205, 242, 104, 204, 48, 233, 83, 84, 18, 164, 177, 63, 207, 62, 14, 207, 162, 37, 166, 157, 220, 17, 125, 11, 231, 33, 172])), SecretKey(Scalar([192, 251, 182, 84, 18, 35, 88, 111, 69, 134, 199, 69, 135, 217, 39, 15, 98, 162, 216, 154, 210, 196, 29, 191, 11, 93, 50, 76, 67, 119, 147, 3])));
/// APF("gdapf"): gdapf1xrq09669kw420dt2zaex6ycs8t07nurhka53g07mwapqmuy4uawfxnguspw
static immutable APF = KeyPair(PublicKey(Point([192, 242, 235, 69, 179, 170, 167, 181, 106, 23, 114, 109, 19, 16, 58, 223, 233, 240, 119, 183, 105, 20, 63, 219, 119, 66, 13, 240, 149, 231, 92, 147])), SecretKey(Scalar([213, 64, 193, 17, 57, 183, 18, 152, 81, 207, 155, 177, 107, 97, 111, 216, 169, 39, 255, 205, 70, 205, 12, 74, 109, 143, 147, 74, 102, 121, 123, 3])));
/// APG("gdapg"): gdapg1xrq0x66luh4h8yuazw80p0wrlawgh5rt9j0v3x2rnjxjgr08c50us56dzz3
static immutable APG = KeyPair(PublicKey(Point([192, 243, 107, 95, 229, 235, 115, 147, 157, 19, 142, 240, 189, 195, 255, 92, 139, 208, 107, 44, 158, 200, 153, 67, 156, 141, 36, 13, 231, 197, 31, 200])), SecretKey(Scalar([45, 144, 34, 143, 248, 235, 136, 214, 129, 47, 120, 27, 143, 109, 59, 231, 254, 118, 193, 249, 219, 105, 237, 78, 232, 227, 145, 188, 173, 22, 125, 1])));
/// APH("gdaph"): gdaph1xrq0866mxc8qvall34s6ymfnx537qn5x9sws20x5nl3sa2cck9vgcju6c5g
static immutable APH = KeyPair(PublicKey(Point([192, 243, 235, 91, 54, 14, 6, 119, 255, 141, 97, 162, 109, 51, 53, 35, 224, 78, 134, 44, 29, 5, 60, 212, 159, 227, 14, 171, 24, 177, 88, 140])), SecretKey(Scalar([220, 48, 226, 142, 170, 161, 130, 158, 109, 139, 149, 103, 73, 107, 171, 13, 146, 72, 80, 52, 117, 100, 162, 191, 170, 157, 57, 149, 175, 31, 12, 12])));
/// API("gdapi"): gdapi1xrq0g66mxxeqc3xq3aeyw4u2hf2sc0qragcwx6v3j4q4na2sqd5qcnuzarq
static immutable API = KeyPair(PublicKey(Point([192, 244, 107, 91, 49, 178, 12, 68, 192, 143, 114, 71, 87, 138, 186, 85, 12, 60, 3, 234, 48, 227, 105, 145, 149, 65, 89, 245, 80, 3, 104, 12])), SecretKey(Scalar([21, 74, 241, 3, 191, 171, 213, 215, 202, 175, 245, 179, 148, 65, 38, 125, 194, 166, 103, 25, 85, 101, 254, 208, 63, 95, 68, 156, 79, 173, 146, 5])));
/// APJ("gdapj"): gdapj1xrq0f66kpjxkt9g9ytnvwnlg4ny2jrpqqentpn2g392xdkczz980yracymf
static immutable APJ = KeyPair(PublicKey(Point([192, 244, 235, 86, 12, 141, 101, 149, 5, 34, 230, 199, 79, 232, 172, 200, 169, 12, 32, 6, 102, 176, 205, 72, 137, 84, 102, 219, 2, 17, 78, 242])), SecretKey(Scalar([109, 137, 165, 38, 219, 41, 87, 181, 242, 246, 245, 157, 251, 96, 225, 190, 106, 38, 122, 250, 111, 8, 217, 185, 118, 152, 148, 196, 159, 173, 252, 15])));
/// APK("gdapk"): gdapk1xrq0266gzsxdm2zgzrzkvs4ymf6cnq6w7n0q85csgu8y730va9xnxx4hcrr
static immutable APK = KeyPair(PublicKey(Point([192, 245, 107, 72, 20, 12, 221, 168, 72, 16, 197, 102, 66, 164, 218, 117, 137, 131, 78, 244, 222, 3, 211, 16, 71, 14, 79, 69, 236, 233, 77, 51])), SecretKey(Scalar([126, 189, 53, 200, 45, 38, 130, 233, 74, 53, 131, 211, 138, 207, 102, 49, 113, 72, 77, 72, 60, 144, 44, 165, 248, 202, 195, 100, 88, 88, 214, 10])));
/// APL("gdapl"): gdapl1xrq0t66qgcx9czqwc44q0qk2yzy8m8d4ha6ljw75s0as26nnhwa6w6t4k6a
static immutable APL = KeyPair(PublicKey(Point([192, 245, 235, 64, 70, 12, 92, 8, 14, 197, 106, 7, 130, 202, 32, 136, 125, 157, 181, 191, 117, 249, 59, 212, 131, 251, 5, 106, 115, 187, 187, 167])), SecretKey(Scalar([154, 213, 212, 32, 182, 46, 3, 152, 83, 70, 11, 165, 193, 35, 81, 243, 204, 44, 117, 96, 235, 233, 108, 92, 24, 107, 138, 79, 108, 87, 176, 7])));
/// APM("gdapm"): gdapm1xrq0v66xu6kjl06wdqhgs0x3kzg73mlc344glp0nhelxgnnva368unxtyqk
static immutable APM = KeyPair(PublicKey(Point([192, 246, 107, 70, 230, 173, 47, 191, 78, 104, 46, 136, 60, 209, 176, 145, 232, 239, 248, 141, 106, 143, 133, 243, 190, 126, 100, 78, 108, 236, 116, 126])), SecretKey(Scalar([72, 78, 206, 32, 33, 203, 232, 45, 97, 213, 247, 26, 181, 154, 208, 195, 83, 140, 196, 110, 24, 67, 9, 252, 64, 104, 155, 51, 98, 43, 153, 5])));
/// APN("gdapn"): gdapn1xrq0d66hmmkfauaq9p8l2lqwrqxj3ktfhv9zqg787p8g5t56lvjs575gx63
static immutable APN = KeyPair(PublicKey(Point([192, 246, 235, 87, 222, 236, 158, 243, 160, 40, 79, 245, 124, 14, 24, 13, 40, 217, 105, 187, 10, 32, 35, 199, 240, 78, 138, 46, 154, 251, 37, 10])), SecretKey(Scalar([192, 187, 14, 197, 248, 17, 161, 15, 9, 59, 125, 36, 61, 66, 26, 203, 238, 78, 223, 223, 171, 217, 67, 62, 27, 129, 229, 150, 25, 218, 174, 11])));
/// APO("gdapo"): gdapo1xrq0w665q6hk7mffxhd5a0ect88ncsr5zs2lye9rmkujpyypf5l7sxjswvm
static immutable APO = KeyPair(PublicKey(Point([192, 247, 107, 84, 6, 175, 111, 109, 41, 53, 219, 78, 191, 56, 89, 207, 60, 64, 116, 20, 21, 242, 100, 163, 221, 185, 32, 144, 129, 77, 63, 232])), SecretKey(Scalar([188, 161, 21, 249, 102, 230, 142, 167, 138, 78, 33, 148, 55, 227, 201, 24, 79, 84, 16, 110, 154, 24, 57, 146, 41, 166, 173, 170, 29, 202, 117, 10])));
/// APP("gdapp"): gdapp1xrq0066ykdh7qywcuxmxrjca8k5drej8f4zenufnmeqqq8tgnen8ypaxv65
static immutable APP = KeyPair(PublicKey(Point([192, 247, 235, 68, 179, 111, 224, 17, 216, 225, 182, 97, 203, 29, 61, 168, 209, 230, 71, 77, 69, 153, 241, 51, 222, 64, 0, 29, 104, 158, 102, 114])), SecretKey(Scalar([149, 147, 164, 227, 27, 66, 136, 184, 60, 184, 250, 150, 223, 61, 209, 23, 155, 67, 54, 78, 118, 102, 190, 201, 201, 12, 64, 207, 239, 48, 55, 8])));
/// APQ("gdapq"): gdapq1xrq0s66z0g7ug5ydjc9pwamlkqzm2k9n52r0nwcfqtrhms00mw6lq04dzut
static immutable APQ = KeyPair(PublicKey(Point([192, 248, 107, 66, 122, 61, 196, 80, 141, 150, 10, 23, 119, 127, 176, 5, 181, 88, 179, 162, 134, 249, 187, 9, 2, 199, 125, 193, 239, 219, 181, 240])), SecretKey(Scalar([111, 154, 132, 84, 132, 235, 31, 215, 133, 13, 153, 159, 214, 46, 67, 103, 131, 114, 78, 174, 8, 237, 52, 43, 70, 115, 118, 3, 167, 228, 155, 2])));
/// APR("gdapr"): gdapr1xrq03666z9t09uyflrpsulsgpcr6g9d0mh4m7mc2mfqz85mhmvr3k7kyufp
static immutable APR = KeyPair(PublicKey(Point([192, 248, 235, 90, 17, 86, 242, 240, 137, 248, 195, 14, 126, 8, 14, 7, 164, 21, 175, 221, 235, 191, 111, 10, 218, 64, 35, 211, 119, 219, 7, 27])), SecretKey(Scalar([12, 76, 100, 173, 161, 99, 253, 246, 17, 197, 51, 231, 92, 192, 101, 33, 134, 67, 76, 51, 30, 194, 198, 63, 129, 10, 60, 52, 21, 92, 39, 0])));
/// APS("gdaps"): gdaps1xrq0j66rvgphzu0azep2dr5depwjjfu89q09d0y8ls4dujgf5xql2nqmzmv
static immutable APS = KeyPair(PublicKey(Point([192, 249, 107, 67, 98, 3, 113, 113, 253, 22, 66, 166, 142, 141, 200, 93, 41, 39, 135, 40, 30, 86, 188, 135, 252, 42, 222, 73, 9, 161, 129, 245])), SecretKey(Scalar([180, 22, 201, 255, 49, 42, 206, 154, 88, 205, 71, 248, 180, 250, 138, 248, 54, 138, 227, 78, 138, 227, 43, 255, 135, 243, 119, 138, 234, 213, 104, 15])));
/// APT("gdapt"): gdapt1xrq0n667j53rz453u7v9zjmt0sa6uglkeurpyhnx9kyrsxpw3wa6gpudnmg
static immutable APT = KeyPair(PublicKey(Point([192, 249, 235, 94, 149, 34, 49, 86, 145, 231, 152, 81, 75, 107, 124, 59, 174, 35, 246, 207, 6, 18, 94, 102, 45, 136, 56, 24, 46, 139, 187, 164])), SecretKey(Scalar([180, 195, 31, 147, 174, 6, 104, 250, 57, 64, 219, 126, 38, 21, 72, 41, 47, 183, 113, 157, 172, 248, 146, 105, 125, 26, 8, 161, 62, 163, 212, 7])));
/// APU("gdapu"): gdapu1xrq0566l7d02aga2quewmtrwgggdt8jpmvrfn0nm0yrmhu0axda2jpfxhwx
static immutable APU = KeyPair(PublicKey(Point([192, 250, 107, 95, 243, 94, 174, 163, 170, 7, 50, 237, 172, 110, 66, 16, 213, 158, 65, 219, 6, 153, 190, 123, 121, 7, 187, 241, 253, 51, 122, 169])), SecretKey(Scalar([161, 84, 19, 57, 220, 217, 253, 100, 105, 180, 176, 23, 170, 83, 213, 177, 249, 212, 198, 196, 196, 132, 9, 155, 202, 205, 140, 242, 237, 245, 42, 10])));
/// APV("gdapv"): gdapv1xrq0466g3h9yxuad22lxf53g9eacd7gtumlz8te0ucdxzrfyxk5m524tcr5
static immutable APV = KeyPair(PublicKey(Point([192, 250, 235, 72, 141, 202, 67, 115, 173, 82, 190, 100, 210, 40, 46, 123, 134, 249, 11, 230, 254, 35, 175, 47, 230, 26, 97, 13, 36, 53, 169, 186])), SecretKey(Scalar([74, 119, 215, 201, 203, 186, 166, 233, 76, 44, 167, 145, 58, 116, 57, 123, 61, 154, 154, 35, 253, 145, 65, 244, 40, 231, 19, 226, 52, 240, 146, 10])));
/// APW("gdapw"): gdapw1xrq0k66gxq80ss7ssql32vz28hyfxy5sv425je5n5czpurad9hlp7v86pmv
static immutable APW = KeyPair(PublicKey(Point([192, 251, 107, 72, 48, 14, 248, 67, 208, 128, 63, 21, 48, 74, 61, 200, 147, 18, 144, 101, 85, 73, 102, 147, 166, 4, 30, 15, 173, 45, 254, 31])), SecretKey(Scalar([105, 0, 214, 226, 201, 233, 239, 111, 226, 120, 26, 108, 61, 218, 53, 27, 4, 66, 234, 203, 186, 137, 43, 175, 6, 95, 59, 195, 245, 213, 217, 13])));
/// APX("gdapx"): gdapx1xrq0h66m0952zejrjfm3ev7l0rslgt6uep3wxa4hwk2aht0a9c37gpxzdwn
static immutable APX = KeyPair(PublicKey(Point([192, 251, 235, 91, 121, 104, 161, 102, 67, 146, 119, 28, 179, 223, 120, 225, 244, 47, 92, 200, 98, 227, 118, 183, 117, 149, 219, 173, 253, 46, 35, 228])), SecretKey(Scalar([14, 230, 104, 44, 54, 70, 177, 99, 203, 140, 120, 243, 196, 221, 253, 228, 236, 63, 31, 208, 168, 103, 61, 13, 43, 66, 69, 6, 175, 126, 200, 6])));
/// APY("gdapy"): gdapy1xrq0c66nc8jz28lxd3yayxcgz7g25z8x89u4grdweu8vjpd9h94t7qey98t
static immutable APY = KeyPair(PublicKey(Point([192, 252, 107, 83, 193, 228, 37, 31, 230, 108, 73, 210, 27, 8, 23, 144, 170, 8, 230, 57, 121, 84, 13, 174, 207, 14, 201, 5, 165, 185, 106, 191])), SecretKey(Scalar([225, 108, 102, 251, 3, 81, 227, 115, 43, 32, 153, 236, 182, 223, 135, 101, 86, 206, 133, 83, 3, 255, 138, 60, 149, 105, 130, 241, 54, 62, 214, 10])));
/// APZ("gdapz"): gdapz1xrq0e66v9hnl09aqlz7twq8gp5v60w00ed382jzx55wvw0ma7z4x2pyjepe
static immutable APZ = KeyPair(PublicKey(Point([192, 252, 235, 76, 45, 231, 247, 151, 160, 248, 188, 183, 0, 232, 13, 25, 167, 185, 239, 203, 98, 117, 72, 70, 165, 28, 199, 63, 125, 240, 170, 101])), SecretKey(Scalar([115, 38, 64, 206, 138, 144, 14, 131, 250, 197, 101, 199, 222, 234, 126, 26, 210, 231, 73, 242, 37, 46, 140, 5, 174, 120, 203, 244, 238, 246, 111, 14])));
/// AQA("gdaqa"): gdaqa1xrqsq6603svwh2g87yup39jqaej0qxc2ej8x7u9lercarlsvwndk7yqjmaz
static immutable AQA = KeyPair(PublicKey(Point([193, 0, 107, 79, 140, 24, 235, 169, 7, 241, 56, 24, 150, 64, 238, 100, 240, 27, 10, 204, 142, 111, 112, 191, 200, 241, 209, 254, 12, 116, 219, 111])), SecretKey(Scalar([156, 208, 82, 39, 131, 72, 64, 141, 23, 147, 156, 166, 76, 156, 174, 186, 82, 191, 23, 163, 143, 201, 35, 167, 225, 234, 63, 94, 79, 11, 190, 13])));
/// AQB("gdaqb"): gdaqb1xrqsp66qy4u52rvn9pu4rwkh5tfmhs87l0zemaa3kydqg6yfvmsqxje05w6
static immutable AQB = KeyPair(PublicKey(Point([193, 0, 235, 64, 37, 121, 69, 13, 147, 40, 121, 81, 186, 215, 162, 211, 187, 192, 254, 251, 197, 157, 247, 177, 177, 26, 4, 104, 137, 102, 224, 3])), SecretKey(Scalar([214, 130, 16, 8, 76, 93, 146, 96, 177, 3, 209, 136, 60, 54, 163, 75, 21, 65, 172, 188, 220, 177, 235, 75, 173, 25, 0, 166, 224, 252, 15, 1])));
/// AQC("gdaqc"): gdaqc1xrqsz66ywlmcqhvckvmgxlm34hnvwsztmlwpst4xhylkwxdvcxsjjpxhh8h
static immutable AQC = KeyPair(PublicKey(Point([193, 1, 107, 68, 119, 247, 128, 93, 152, 179, 54, 131, 127, 113, 173, 230, 199, 64, 75, 223, 220, 24, 46, 166, 185, 63, 103, 25, 172, 193, 161, 41])), SecretKey(Scalar([182, 111, 4, 143, 91, 248, 15, 37, 212, 206, 110, 234, 201, 210, 136, 247, 112, 103, 79, 148, 67, 6, 198, 71, 127, 145, 199, 124, 25, 237, 149, 4])));
/// AQD("gdaqd"): gdaqd1xrqsr66lm46f7wvy36qfg2ey3xfj7g6t459amne8v4xyrs6mamhqsj9k5md
static immutable AQD = KeyPair(PublicKey(Point([193, 1, 235, 95, 221, 116, 159, 57, 132, 142, 128, 148, 43, 36, 137, 147, 47, 35, 75, 173, 11, 221, 207, 39, 101, 76, 65, 195, 91, 238, 238, 8])), SecretKey(Scalar([229, 99, 75, 191, 124, 238, 115, 34, 220, 171, 73, 223, 44, 84, 127, 93, 201, 112, 29, 95, 159, 32, 68, 241, 243, 249, 90, 197, 83, 240, 185, 5])));
/// AQE("gdaqe"): gdaqe1xrqsy663rn8hud5pqqa093xal8j4fdt3mc06rylrqwdz0hp5xpzu7lharkg
static immutable AQE = KeyPair(PublicKey(Point([193, 2, 107, 81, 28, 207, 126, 54, 129, 0, 58, 242, 196, 221, 249, 229, 84, 181, 113, 222, 31, 161, 147, 227, 3, 154, 39, 220, 52, 48, 69, 207])), SecretKey(Scalar([12, 61, 83, 135, 138, 36, 163, 90, 23, 103, 48, 192, 105, 160, 141, 23, 38, 54, 63, 18, 108, 74, 187, 169, 247, 232, 225, 100, 95, 55, 159, 10])));
/// AQF("gdaqf"): gdaqf1xrqs966k2quj6aqec8ql390umdz0knqqd69ghskdm85uqz9f6c3cctcy5s7
static immutable AQF = KeyPair(PublicKey(Point([193, 2, 235, 86, 80, 57, 45, 116, 25, 193, 193, 248, 149, 252, 219, 68, 251, 76, 0, 110, 138, 139, 194, 205, 217, 233, 192, 8, 169, 214, 35, 140])), SecretKey(Scalar([157, 61, 206, 42, 157, 58, 139, 20, 187, 180, 55, 202, 101, 148, 33, 55, 86, 30, 6, 91, 29, 33, 91, 187, 159, 56, 3, 67, 22, 192, 54, 10])));
/// AQG("gdaqg"): gdaqg1xrqsx66p7vtc73me620m6hc9nwmqcrdla4pu74z9f6266knnrnnpq5mysvg
static immutable AQG = KeyPair(PublicKey(Point([193, 3, 107, 65, 243, 23, 143, 71, 121, 210, 159, 189, 95, 5, 155, 182, 12, 13, 191, 237, 67, 207, 84, 69, 78, 149, 173, 90, 115, 28, 230, 16])), SecretKey(Scalar([169, 43, 140, 243, 130, 116, 211, 132, 45, 176, 218, 159, 119, 21, 92, 139, 1, 44, 24, 253, 156, 32, 3, 28, 32, 90, 90, 149, 100, 129, 182, 14])));
/// AQH("gdaqh"): gdaqh1xrqs866ffaxt5nkmny3qpeu8xek94yhgfy0ndva59p2qwmnwa6257fflvx5
static immutable AQH = KeyPair(PublicKey(Point([193, 3, 235, 73, 79, 76, 186, 78, 219, 153, 34, 0, 231, 135, 54, 108, 90, 146, 232, 73, 31, 54, 179, 180, 40, 84, 7, 110, 110, 238, 149, 79])), SecretKey(Scalar([93, 250, 122, 200, 127, 255, 251, 74, 235, 249, 74, 254, 148, 130, 138, 169, 162, 92, 240, 21, 159, 115, 31, 99, 165, 79, 107, 87, 101, 183, 203, 8])));
/// AQI("gdaqi"): gdaqi1xrqsg66r7q9qn72g80l3g96avrtc9krafdn722s40fnz5k0gj4jtswax6cx
static immutable AQI = KeyPair(PublicKey(Point([193, 4, 107, 67, 240, 10, 9, 249, 72, 59, 255, 20, 23, 93, 96, 215, 130, 216, 125, 75, 103, 229, 42, 21, 122, 102, 42, 89, 232, 149, 100, 184])), SecretKey(Scalar([103, 237, 108, 106, 32, 122, 251, 96, 142, 219, 190, 124, 90, 195, 38, 201, 195, 120, 122, 153, 213, 10, 73, 197, 106, 109, 223, 154, 91, 43, 116, 15])));
/// AQJ("gdaqj"): gdaqj1xrqsf66d45e0dpnr6qguq65wmqfvput5rk75vl0pgrjl0grdu04d6pwnm3q
static immutable AQJ = KeyPair(PublicKey(Point([193, 4, 235, 77, 173, 50, 246, 134, 99, 208, 17, 192, 106, 142, 216, 18, 192, 241, 116, 29, 189, 70, 125, 225, 64, 229, 247, 160, 109, 227, 234, 221])), SecretKey(Scalar([141, 86, 3, 66, 66, 141, 75, 234, 134, 127, 79, 83, 34, 68, 110, 180, 155, 187, 186, 135, 48, 255, 171, 16, 85, 215, 98, 22, 17, 18, 21, 13])));
/// AQK("gdaqk"): gdaqk1xrqs266xm6ly7v72ljc0qaxgtnnsv7ldtulj6q8kldl09f48lxresfqyzu4
static immutable AQK = KeyPair(PublicKey(Point([193, 5, 107, 70, 222, 190, 79, 51, 202, 252, 176, 240, 116, 200, 92, 231, 6, 123, 237, 95, 63, 45, 0, 246, 251, 126, 242, 166, 167, 249, 135, 152])), SecretKey(Scalar([82, 58, 57, 139, 227, 231, 62, 103, 140, 144, 20, 83, 159, 148, 106, 56, 231, 69, 73, 196, 64, 1, 197, 177, 252, 202, 160, 70, 127, 217, 117, 12])));
/// AQL("gdaql"): gdaql1xrqst66n05lscfy98qjpsmpl30wwu3aga5mnu4gg5a5jder9nsv9jx620y9
static immutable AQL = KeyPair(PublicKey(Point([193, 5, 235, 83, 125, 63, 12, 36, 133, 56, 36, 24, 108, 63, 139, 220, 238, 71, 168, 237, 55, 62, 85, 8, 167, 105, 38, 228, 101, 156, 24, 89])), SecretKey(Scalar([14, 208, 12, 197, 133, 77, 156, 236, 232, 188, 223, 135, 53, 191, 142, 235, 47, 30, 54, 243, 197, 5, 36, 62, 129, 24, 169, 10, 76, 31, 44, 0])));
/// AQM("gdaqm"): gdaqm1xrqsv6609e8m9n7pum57m0hsq6dw4ygqdny4earcttr2a3dvpzz9ctlhxzj
static immutable AQM = KeyPair(PublicKey(Point([193, 6, 107, 79, 46, 79, 178, 207, 193, 230, 233, 237, 190, 240, 6, 154, 234, 145, 0, 108, 201, 92, 244, 120, 90, 198, 174, 197, 172, 8, 132, 92])), SecretKey(Scalar([215, 78, 120, 225, 207, 86, 133, 32, 255, 128, 247, 203, 44, 227, 0, 218, 200, 68, 237, 174, 195, 3, 41, 223, 196, 98, 75, 119, 186, 62, 251, 15])));
/// AQN("gdaqn"): gdaqn1xrqsd6669kdklgtuhlw7ype82dt3zawu6kuzumz5ylfn8nvrygjlcd0lg6x
static immutable AQN = KeyPair(PublicKey(Point([193, 6, 235, 90, 45, 155, 111, 161, 124, 191, 221, 226, 7, 39, 83, 87, 17, 117, 220, 213, 184, 46, 108, 84, 39, 211, 51, 205, 131, 34, 37, 252])), SecretKey(Scalar([141, 243, 201, 8, 70, 68, 245, 77, 177, 206, 222, 158, 91, 207, 221, 105, 89, 125, 22, 102, 16, 43, 18, 199, 119, 150, 197, 99, 206, 45, 18, 14])));
/// AQO("gdaqo"): gdaqo1xrqsw662pyecgg42fqv3tgapx5tfxmfyetn8tspnh7at90xz3v24uxu3399
static immutable AQO = KeyPair(PublicKey(Point([193, 7, 107, 74, 9, 51, 132, 34, 170, 72, 25, 21, 163, 161, 53, 22, 147, 109, 36, 202, 230, 117, 192, 51, 191, 186, 178, 188, 194, 139, 21, 94])), SecretKey(Scalar([155, 24, 210, 232, 131, 235, 193, 99, 81, 109, 194, 80, 201, 238, 149, 95, 206, 2, 195, 122, 49, 91, 131, 40, 128, 14, 227, 98, 57, 114, 91, 7])));
/// AQP("gdaqp"): gdaqp1xrqs0669svg5cyktc90q3dvruhg7delazdllrrqq6pa4nv5khpdk6xpff7e
static immutable AQP = KeyPair(PublicKey(Point([193, 7, 235, 69, 131, 17, 76, 18, 203, 193, 94, 8, 181, 131, 229, 209, 230, 231, 253, 19, 127, 241, 140, 0, 208, 123, 89, 178, 150, 184, 91, 109])), SecretKey(Scalar([35, 45, 182, 194, 17, 184, 69, 6, 63, 226, 176, 83, 145, 54, 224, 61, 105, 53, 56, 113, 171, 156, 238, 132, 87, 217, 15, 9, 195, 163, 221, 1])));
/// AQQ("gdaqq"): gdaqq1xrqss66gwngaz7az669ssn9wuvxnw8zze2ag68se6gvxz64058fe5tg093u
static immutable AQQ = KeyPair(PublicKey(Point([193, 8, 107, 72, 116, 209, 209, 123, 162, 214, 139, 8, 76, 174, 227, 13, 55, 28, 66, 202, 186, 141, 30, 25, 210, 24, 97, 106, 175, 161, 211, 154])), SecretKey(Scalar([212, 9, 140, 105, 233, 241, 140, 31, 7, 87, 203, 249, 54, 188, 242, 16, 14, 229, 166, 159, 25, 157, 225, 186, 55, 178, 33, 21, 192, 118, 72, 12])));
/// AQR("gdaqr"): gdaqr1xrqs3669txkt796p8uqgwkjfxc4sv98sm2dr4cl2mlq6ku3pk5y2u4tc8k6
static immutable AQR = KeyPair(PublicKey(Point([193, 8, 235, 69, 89, 172, 191, 23, 65, 63, 0, 135, 90, 73, 54, 43, 6, 20, 240, 218, 154, 58, 227, 234, 223, 193, 171, 114, 33, 181, 8, 174])), SecretKey(Scalar([78, 98, 42, 231, 165, 170, 127, 194, 14, 112, 92, 40, 223, 136, 13, 22, 83, 201, 158, 245, 96, 220, 213, 118, 252, 232, 218, 179, 220, 252, 173, 3])));
/// AQS("gdaqs"): gdaqs1xrqsj6603jl5j0j3p5zvfgmtxhd6c6ue328y4nc4ljz7zf9qz7cyx9l3fxw
static immutable AQS = KeyPair(PublicKey(Point([193, 9, 107, 79, 140, 191, 73, 62, 81, 13, 4, 196, 163, 107, 53, 219, 172, 107, 153, 138, 142, 74, 207, 21, 252, 133, 225, 36, 160, 23, 176, 67])), SecretKey(Scalar([74, 71, 81, 122, 84, 236, 13, 1, 196, 201, 153, 177, 200, 13, 244, 181, 215, 23, 162, 162, 206, 48, 126, 32, 112, 224, 59, 148, 29, 116, 76, 15])));
/// AQT("gdaqt"): gdaqt1xrqsn66hvrspscxemhu65mtw3lkfwyj4a5uxp2x8cv3r5vfkgcnx2cgdwr6
static immutable AQT = KeyPair(PublicKey(Point([193, 9, 235, 87, 96, 224, 24, 96, 217, 221, 249, 170, 109, 110, 143, 236, 151, 18, 85, 237, 56, 96, 168, 199, 195, 34, 58, 49, 54, 70, 38, 101])), SecretKey(Scalar([179, 215, 248, 99, 95, 229, 129, 194, 30, 208, 22, 90, 45, 199, 160, 161, 232, 123, 160, 250, 169, 241, 65, 74, 170, 171, 234, 93, 48, 120, 116, 8])));
/// AQU("gdaqu"): gdaqu1xrqs566han3yafxaa7remg37j9fsch4jraksct5yrxjras3p576054mgnxx
static immutable AQU = KeyPair(PublicKey(Point([193, 10, 107, 87, 236, 226, 78, 164, 221, 239, 135, 157, 162, 62, 145, 83, 12, 94, 178, 31, 109, 12, 46, 132, 25, 164, 62, 194, 33, 167, 180, 250])), SecretKey(Scalar([209, 120, 248, 114, 231, 210, 124, 203, 40, 126, 81, 124, 15, 127, 65, 195, 248, 79, 195, 33, 216, 23, 159, 251, 30, 45, 121, 64, 80, 122, 115, 12])));
/// AQV("gdaqv"): gdaqv1xrqs466vgxwa2kpg7qfzpvlqkn0ht8rc0khv62ga329vj95qj08mw4qchz0
static immutable AQV = KeyPair(PublicKey(Point([193, 10, 235, 76, 65, 157, 213, 88, 40, 240, 18, 32, 179, 224, 180, 223, 117, 156, 120, 125, 174, 205, 41, 29, 138, 138, 201, 22, 128, 147, 207, 183])), SecretKey(Scalar([219, 140, 116, 179, 122, 106, 203, 176, 129, 135, 239, 31, 151, 241, 206, 17, 156, 228, 208, 179, 171, 124, 79, 234, 4, 114, 184, 91, 211, 185, 241, 7])));
/// AQW("gdaqw"): gdaqw1xrqsk66vjweuqr675yd0wy983vdj0wnsc5lvlq7d07yslf7h7f5rkpllgqa
static immutable AQW = KeyPair(PublicKey(Point([193, 11, 107, 76, 147, 179, 192, 15, 94, 161, 26, 247, 16, 167, 139, 27, 39, 186, 112, 197, 62, 207, 131, 205, 127, 137, 15, 167, 215, 242, 104, 59])), SecretKey(Scalar([57, 152, 28, 48, 67, 91, 239, 97, 172, 24, 131, 191, 225, 146, 188, 26, 185, 138, 165, 224, 25, 215, 190, 22, 141, 171, 42, 67, 158, 28, 212, 12])));
/// AQX("gdaqx"): gdaqx1xrqsh664a2nxmc2khn5v40v9nv6hkkxgzflwr5we306adke0za94y93dfpx
static immutable AQX = KeyPair(PublicKey(Point([193, 11, 235, 85, 234, 166, 109, 225, 86, 188, 232, 202, 189, 133, 155, 53, 123, 88, 200, 18, 126, 225, 209, 217, 139, 245, 214, 219, 47, 23, 75, 82])), SecretKey(Scalar([29, 213, 124, 41, 37, 50, 58, 182, 79, 129, 240, 178, 240, 36, 243, 176, 69, 9, 251, 168, 64, 2, 7, 192, 26, 125, 113, 47, 75, 164, 221, 13])));
/// AQY("gdaqy"): gdaqy1xrqsc666hwh6eh53scsv7xukwwlz3uv5aa63aa4tv47su8tz4qkux28kqhp
static immutable AQY = KeyPair(PublicKey(Point([193, 12, 107, 90, 187, 175, 172, 222, 145, 134, 32, 207, 27, 150, 115, 190, 40, 241, 148, 239, 117, 30, 246, 171, 101, 125, 14, 29, 98, 168, 45, 195])), SecretKey(Scalar([240, 151, 125, 15, 50, 177, 176, 156, 171, 55, 186, 144, 115, 205, 133, 49, 51, 98, 46, 32, 182, 95, 128, 167, 175, 61, 155, 61, 208, 248, 69, 4])));
/// AQZ("gdaqz"): gdaqz1xrqse66ltdrk3p9x9rjwyextpfrmtryqzh7c385255pu0z64lvv4ghxv3gk
static immutable AQZ = KeyPair(PublicKey(Point([193, 12, 235, 95, 91, 71, 104, 132, 166, 40, 228, 226, 100, 203, 10, 71, 181, 140, 128, 21, 253, 136, 158, 138, 165, 3, 199, 139, 85, 251, 25, 84])), SecretKey(Scalar([131, 174, 67, 210, 199, 108, 29, 75, 158, 10, 11, 57, 44, 96, 60, 106, 147, 180, 166, 227, 11, 186, 226, 244, 15, 16, 229, 108, 144, 46, 59, 7])));
/// ARA("gdara"): gdara1xrq3q666enmtevc064ge3xdnp5snzwp3z9z5vnsqz5d8yln50xvcwqk7qml
static immutable ARA = KeyPair(PublicKey(Point([193, 16, 107, 90, 204, 246, 188, 179, 15, 213, 81, 152, 153, 179, 13, 33, 49, 56, 49, 17, 69, 70, 78, 0, 21, 26, 114, 126, 116, 121, 153, 135])), SecretKey(Scalar([174, 213, 211, 21, 213, 10, 139, 231, 95, 146, 99, 64, 64, 252, 14, 187, 60, 247, 100, 36, 101, 131, 118, 187, 148, 169, 172, 153, 120, 155, 18, 6])));
/// ARB("gdarb"): gdarb1xrq3p66pslpamsxj8afu3gg2rfpekqg2c2sacam6wc5eqm5m0tu4czch4fz
static immutable ARB = KeyPair(PublicKey(Point([193, 16, 235, 65, 135, 195, 221, 192, 210, 63, 83, 200, 161, 10, 26, 67, 155, 1, 10, 194, 161, 220, 119, 122, 118, 41, 144, 110, 155, 122, 249, 92])), SecretKey(Scalar([129, 1, 230, 1, 83, 176, 195, 168, 154, 142, 114, 215, 82, 36, 195, 102, 207, 13, 5, 202, 139, 234, 122, 178, 39, 251, 88, 105, 26, 51, 143, 4])));
/// ARC("gdarc"): gdarc1xrq3z66awa9pqafd3swyzc8fntd6nflumllzh5yl23czy7kdlhhacn4zedg
static immutable ARC = KeyPair(PublicKey(Point([193, 17, 107, 93, 119, 74, 16, 117, 45, 140, 28, 65, 96, 233, 154, 219, 169, 167, 252, 223, 254, 43, 208, 159, 84, 112, 34, 122, 205, 253, 239, 220])), SecretKey(Scalar([190, 131, 103, 46, 211, 11, 217, 209, 175, 203, 154, 112, 36, 88, 41, 153, 195, 123, 60, 238, 11, 153, 206, 189, 107, 222, 123, 19, 170, 20, 154, 6])));
/// ARD("gdard"): gdard1xrq3r667zlvt2vsve3yrgxvsuyykytjzqz25wuxt9q8nzhvpfmz27v0xrly
static immutable ARD = KeyPair(PublicKey(Point([193, 17, 235, 94, 23, 216, 181, 50, 12, 204, 72, 52, 25, 144, 225, 9, 98, 46, 66, 0, 149, 71, 112, 203, 40, 15, 49, 93, 129, 78, 196, 175])), SecretKey(Scalar([153, 56, 206, 190, 177, 174, 15, 228, 242, 62, 139, 51, 34, 44, 227, 123, 83, 117, 53, 88, 212, 10, 70, 115, 133, 111, 35, 68, 29, 147, 157, 3])));
/// ARE("gdare"): gdare1xrq3y662g4p9amcjg3fu5h0l5mjh2ewl6he8z3zr94wc85n3y2x36srphln
static immutable ARE = KeyPair(PublicKey(Point([193, 18, 107, 74, 69, 66, 94, 239, 18, 68, 83, 202, 93, 255, 166, 229, 117, 101, 223, 213, 242, 113, 68, 67, 45, 93, 131, 210, 113, 34, 141, 29])), SecretKey(Scalar([55, 119, 60, 178, 129, 35, 121, 142, 180, 210, 147, 227, 75, 179, 195, 125, 192, 251, 79, 149, 5, 237, 221, 201, 107, 139, 210, 45, 45, 207, 185, 15])));
/// ARF("gdarf"): gdarf1xrq3966cyfpz55kx2l9hl5gjdv2fmzdd3kwjsr87mf6nsxu8q6a2xapdxa0
static immutable ARF = KeyPair(PublicKey(Point([193, 18, 235, 88, 34, 66, 42, 82, 198, 87, 203, 127, 209, 18, 107, 20, 157, 137, 173, 141, 157, 40, 12, 254, 218, 117, 56, 27, 135, 6, 186, 163])), SecretKey(Scalar([186, 179, 254, 36, 223, 101, 213, 248, 30, 20, 148, 103, 94, 224, 115, 173, 2, 230, 221, 168, 68, 251, 11, 49, 133, 178, 114, 106, 249, 60, 65, 6])));
/// ARG("gdarg"): gdarg1xrq3x66rlw3vwg7qe7c2crm9uma88ckgx55fmjnfqzfqtsdfs5vykhnhf55
static immutable ARG = KeyPair(PublicKey(Point([193, 19, 107, 67, 251, 162, 199, 35, 192, 207, 176, 172, 15, 101, 230, 250, 115, 226, 200, 53, 40, 157, 202, 105, 0, 146, 5, 193, 169, 133, 24, 75])), SecretKey(Scalar([142, 245, 58, 184, 127, 183, 114, 88, 250, 81, 23, 226, 56, 200, 196, 18, 5, 133, 170, 98, 183, 241, 96, 117, 74, 34, 49, 212, 56, 84, 12, 7])));
/// ARH("gdarh"): gdarh1xrq3866vf0vpexdqhhv30lu3unl8egjklpnz0nqy98wqsn6c4zvt7c4zwa4
static immutable ARH = KeyPair(PublicKey(Point([193, 19, 235, 76, 75, 216, 28, 153, 160, 189, 217, 23, 255, 145, 228, 254, 124, 162, 86, 248, 102, 39, 204, 4, 41, 220, 8, 79, 88, 168, 152, 191])), SecretKey(Scalar([160, 72, 190, 76, 91, 171, 80, 76, 23, 194, 137, 246, 215, 237, 66, 238, 187, 159, 67, 128, 170, 129, 23, 123, 107, 180, 71, 250, 51, 202, 250, 0])));
/// ARI("gdari"): gdari1xrq3g66flpw8l3g86407gk4ncu9k08dg2lk90w4acv7ypgf3vaar5xw2jed
static immutable ARI = KeyPair(PublicKey(Point([193, 20, 107, 73, 248, 92, 127, 197, 7, 213, 95, 228, 90, 179, 199, 11, 103, 157, 168, 87, 236, 87, 186, 189, 195, 60, 64, 161, 49, 103, 122, 58])), SecretKey(Scalar([43, 25, 19, 120, 8, 191, 184, 73, 91, 148, 190, 253, 167, 136, 174, 112, 44, 8, 146, 145, 111, 144, 18, 161, 255, 150, 235, 139, 102, 237, 199, 2])));
/// ARJ("gdarj"): gdarj1xrq3f66r39575cfapkzrdtuwul9plsy9d0j9ezfc3m8wqw0d0tlfza88hvh
static immutable ARJ = KeyPair(PublicKey(Point([193, 20, 235, 67, 137, 105, 234, 97, 61, 13, 132, 54, 175, 142, 231, 202, 31, 192, 133, 107, 228, 92, 137, 56, 142, 206, 224, 57, 237, 122, 254, 145])), SecretKey(Scalar([128, 99, 61, 9, 149, 235, 80, 81, 86, 135, 230, 160, 207, 78, 11, 58, 249, 1, 106, 133, 94, 88, 227, 49, 38, 126, 36, 46, 201, 147, 53, 15])));
/// ARK("gdark"): gdark1xrq3266c0nqaeazs9argtcdv68fsxf7gkc5gnh9g95r4l9dgl30zzjh2crt
static immutable ARK = KeyPair(PublicKey(Point([193, 21, 107, 88, 124, 193, 220, 244, 80, 47, 70, 133, 225, 172, 209, 211, 3, 39, 200, 182, 40, 137, 220, 168, 45, 7, 95, 149, 168, 252, 94, 33])), SecretKey(Scalar([250, 69, 22, 215, 124, 65, 146, 135, 187, 38, 181, 83, 103, 157, 9, 154, 187, 65, 156, 77, 148, 141, 116, 151, 179, 9, 220, 140, 125, 159, 28, 4])));
/// ARL("gdarl"): gdarl1xrq3t66au4rw9ex77w7djl9z0tpxn3a0cewk73xd6zzkts2wtay5wdwrrrn
static immutable ARL = KeyPair(PublicKey(Point([193, 21, 235, 93, 229, 70, 226, 228, 222, 243, 188, 217, 124, 162, 122, 194, 105, 199, 175, 198, 93, 111, 68, 205, 208, 133, 101, 193, 78, 95, 73, 71])), SecretKey(Scalar([69, 80, 61, 88, 70, 133, 59, 170, 247, 30, 152, 44, 210, 135, 100, 179, 135, 139, 154, 134, 230, 248, 33, 185, 4, 48, 250, 174, 29, 104, 136, 8])));
/// ARM("gdarm"): gdarm1xrq3v66w96plexmyd7a27a5zzpe7n2r92j0u0k47nluxk9k45qmecdak9xl
static immutable ARM = KeyPair(PublicKey(Point([193, 22, 107, 78, 46, 131, 252, 155, 100, 111, 186, 175, 118, 130, 16, 115, 233, 168, 101, 84, 159, 199, 218, 190, 159, 248, 107, 22, 213, 160, 55, 156])), SecretKey(Scalar([168, 138, 142, 120, 30, 45, 99, 115, 250, 30, 0, 119, 225, 12, 230, 28, 231, 81, 94, 241, 232, 152, 161, 250, 205, 33, 63, 162, 94, 150, 112, 3])));
/// ARN("gdarn"): gdarn1xrq3d66xj9y40elkxk34w3r2pehwez54mgcwwnydctr62lr37r5xxxrajcn
static immutable ARN = KeyPair(PublicKey(Point([193, 22, 235, 70, 145, 73, 87, 231, 246, 53, 163, 87, 68, 106, 14, 110, 236, 138, 149, 218, 48, 231, 76, 141, 194, 199, 165, 124, 113, 240, 232, 99])), SecretKey(Scalar([117, 218, 161, 56, 23, 215, 158, 199, 241, 1, 37, 18, 241, 69, 245, 27, 33, 165, 255, 140, 147, 142, 243, 116, 26, 180, 2, 63, 115, 170, 236, 10])));
/// ARO("gdaro"): gdaro1xrq3w66gujs8e5c6h09j4rky93hmgqks2487v92lz8mhk7p0jjlycphmfus
static immutable ARO = KeyPair(PublicKey(Point([193, 23, 107, 72, 228, 160, 124, 211, 26, 187, 203, 42, 142, 196, 44, 111, 180, 2, 208, 85, 79, 230, 21, 95, 17, 247, 123, 120, 47, 148, 190, 76])), SecretKey(Scalar([198, 208, 221, 192, 79, 76, 170, 73, 52, 36, 0, 56, 68, 174, 251, 106, 104, 9, 106, 110, 71, 174, 180, 227, 120, 199, 154, 63, 216, 107, 161, 1])));
/// ARP("gdarp"): gdarp1xrq3066cmc9ttnwegwxjtzh76ek42luedf24upcv90ckm6wxx3u7kwmx3p2
static immutable ARP = KeyPair(PublicKey(Point([193, 23, 235, 88, 222, 10, 181, 205, 217, 67, 141, 37, 138, 254, 214, 109, 85, 127, 153, 106, 85, 94, 7, 12, 43, 241, 109, 233, 198, 52, 121, 235])), SecretKey(Scalar([117, 25, 222, 205, 73, 210, 28, 130, 223, 115, 80, 166, 117, 12, 138, 98, 91, 5, 51, 253, 113, 251, 110, 186, 35, 204, 195, 147, 63, 78, 149, 15])));
/// ARQ("gdarq"): gdarq1xrq3s660hl706h085vtu997hz68yatwkewqfhey8u0vhh7mexk3x590nckd
static immutable ARQ = KeyPair(PublicKey(Point([193, 24, 107, 79, 191, 252, 253, 93, 231, 163, 23, 194, 151, 215, 22, 142, 78, 173, 214, 203, 128, 155, 228, 135, 227, 217, 123, 251, 121, 53, 162, 106])), SecretKey(Scalar([232, 225, 133, 225, 144, 245, 231, 172, 233, 99, 228, 81, 103, 147, 81, 24, 148, 195, 60, 167, 202, 33, 54, 236, 171, 56, 86, 62, 100, 253, 212, 6])));
/// ARR("gdarr"): gdarr1xrq3366as3484kgqx2cdjk7lk07486epx7fphrr45ng7qmtgunery4kp0qn
static immutable ARR = KeyPair(PublicKey(Point([193, 24, 235, 93, 132, 106, 122, 217, 0, 50, 176, 217, 91, 223, 179, 253, 83, 235, 33, 55, 146, 27, 140, 117, 164, 209, 224, 109, 104, 228, 242, 50])), SecretKey(Scalar([196, 71, 99, 87, 87, 76, 75, 145, 221, 88, 181, 109, 105, 58, 126, 65, 122, 167, 239, 14, 29, 52, 180, 72, 129, 119, 54, 151, 222, 211, 188, 3])));
/// ARS("gdars"): gdars1xrq3j66p0vn9tghu4zsw5yjxge4fxxvcs80knuslgqe86g690aark5uwyqp
static immutable ARS = KeyPair(PublicKey(Point([193, 25, 107, 65, 123, 38, 85, 162, 252, 168, 160, 234, 18, 70, 70, 106, 147, 25, 152, 129, 223, 105, 242, 31, 64, 50, 125, 35, 69, 127, 122, 59])), SecretKey(Scalar([92, 94, 135, 149, 66, 109, 196, 21, 150, 153, 40, 117, 16, 139, 0, 246, 129, 148, 150, 2, 199, 149, 156, 130, 78, 83, 60, 100, 209, 50, 46, 11])));
/// ART("gdart"): gdart1xrq3n66uzqhlfs740wslavjzy6dwu65xgcfgmr2sn43v62qtszcewd4v8hf
static immutable ART = KeyPair(PublicKey(Point([193, 25, 235, 92, 16, 47, 244, 195, 213, 123, 161, 254, 178, 66, 38, 154, 238, 106, 134, 70, 18, 141, 141, 80, 157, 98, 205, 40, 11, 128, 177, 151])), SecretKey(Scalar([18, 53, 126, 47, 158, 195, 185, 111, 117, 3, 250, 58, 122, 14, 161, 21, 39, 13, 32, 84, 48, 188, 49, 200, 109, 239, 239, 131, 45, 169, 217, 0])));
/// ARU("gdaru"): gdaru1xrq3566m63u86cc5sa6wddxdxflwdjjvajtdju2nevnv44ttywwsct4cg8y
static immutable ARU = KeyPair(PublicKey(Point([193, 26, 107, 91, 212, 120, 125, 99, 20, 135, 116, 230, 180, 205, 50, 126, 230, 202, 76, 236, 150, 217, 113, 83, 203, 38, 202, 213, 107, 35, 157, 12])), SecretKey(Scalar([98, 16, 225, 214, 228, 192, 207, 56, 94, 187, 99, 113, 152, 79, 60, 241, 73, 189, 115, 207, 156, 70, 210, 30, 117, 69, 198, 14, 178, 249, 39, 6])));
/// ARV("gdarv"): gdarv1xrq3466a97zrr7ljtj2zmcq7ktvcx3l9dzmznxd86mssp7wau4t455r6yju
static immutable ARV = KeyPair(PublicKey(Point([193, 26, 235, 93, 47, 132, 49, 251, 242, 92, 148, 45, 224, 30, 178, 217, 131, 71, 229, 104, 182, 41, 153, 167, 214, 225, 0, 249, 221, 229, 87, 90])), SecretKey(Scalar([126, 109, 52, 9, 49, 223, 106, 89, 171, 215, 223, 25, 62, 164, 142, 185, 47, 14, 51, 236, 113, 88, 65, 250, 15, 101, 182, 84, 40, 122, 245, 1])));
/// ARW("gdarw"): gdarw1xrq3k668jcmnypk2te5j929s6pk6zmtld9d02d99ysn83vzdmpyf7genn0j
static immutable ARW = KeyPair(PublicKey(Point([193, 27, 107, 71, 150, 55, 50, 6, 202, 94, 105, 34, 168, 176, 208, 109, 161, 109, 127, 105, 90, 245, 52, 165, 36, 38, 120, 176, 77, 216, 72, 159])), SecretKey(Scalar([50, 119, 219, 253, 174, 205, 63, 59, 30, 108, 190, 103, 98, 180, 9, 175, 249, 123, 52, 61, 109, 6, 110, 122, 91, 247, 249, 111, 247, 179, 244, 13])));
/// ARX("gdarx"): gdarx1xrq3h6667weclmt7vcstaec4xghu3a006mut54t8f5td0v79u6luvhdewur
static immutable ARX = KeyPair(PublicKey(Point([193, 27, 235, 90, 243, 179, 143, 237, 126, 102, 32, 190, 231, 21, 50, 47, 200, 245, 239, 214, 248, 186, 85, 103, 77, 22, 215, 179, 197, 230, 191, 198])), SecretKey(Scalar([255, 212, 83, 159, 252, 181, 98, 197, 177, 229, 112, 69, 171, 81, 177, 70, 20, 83, 146, 191, 99, 251, 23, 228, 138, 112, 221, 176, 90, 0, 201, 3])));
/// ARY("gdary"): gdary1xrq3c66r5y3tn09hzwkwhht5n0vd8je3p2jqldq2ew9syp5kzzq0vhqevrf
static immutable ARY = KeyPair(PublicKey(Point([193, 28, 107, 67, 161, 34, 185, 188, 183, 19, 172, 235, 221, 116, 155, 216, 211, 203, 49, 10, 164, 15, 180, 10, 203, 139, 2, 6, 150, 16, 128, 246])), SecretKey(Scalar([110, 158, 180, 77, 136, 191, 50, 112, 113, 122, 137, 143, 2, 240, 135, 63, 238, 145, 166, 63, 184, 182, 94, 47, 156, 27, 253, 71, 188, 198, 168, 1])));
/// ARZ("gdarz"): gdarz1xrq3e66h9ckz7qafwntakaurdmcddg7yp6vdqcrakk7jqzqzypkcsd6j98h
static immutable ARZ = KeyPair(PublicKey(Point([193, 28, 235, 87, 46, 44, 47, 3, 169, 116, 215, 219, 119, 131, 110, 240, 214, 163, 196, 14, 152, 208, 96, 125, 181, 189, 32, 8, 2, 32, 109, 136])), SecretKey(Scalar([82, 86, 56, 4, 183, 69, 73, 157, 83, 68, 86, 32, 95, 255, 3, 154, 239, 63, 87, 227, 66, 29, 147, 20, 207, 151, 67, 42, 246, 70, 190, 14])));
/// ASA("gdasa"): gdasa1xrqjq66v52w4ymvlcvfnelm4zpxkg4gp0dlxsq8dqrywhhmk3j2mkadwd4l
static immutable ASA = KeyPair(PublicKey(Point([193, 32, 107, 76, 162, 157, 82, 109, 159, 195, 19, 60, 255, 117, 16, 77, 100, 85, 1, 123, 126, 104, 0, 237, 0, 200, 235, 223, 118, 140, 149, 187])), SecretKey(Scalar([243, 244, 120, 118, 52, 205, 42, 68, 194, 55, 146, 220, 0, 140, 98, 223, 29, 28, 225, 28, 208, 1, 146, 97, 158, 12, 71, 162, 167, 48, 208, 8])));
/// ASB("gdasb"): gdasb1xrqjp66g98gakkrqxg9fu92fdur3lq8kax7wcxuajgu9pc43tahe54lpwk9
static immutable ASB = KeyPair(PublicKey(Point([193, 32, 235, 72, 41, 209, 219, 88, 96, 50, 10, 158, 21, 73, 111, 7, 31, 128, 246, 233, 188, 236, 27, 157, 146, 56, 80, 226, 177, 95, 111, 154])), SecretKey(Scalar([28, 74, 56, 96, 188, 197, 40, 78, 232, 207, 141, 98, 183, 206, 111, 108, 199, 80, 12, 8, 222, 43, 34, 18, 160, 215, 246, 121, 250, 4, 88, 12])));
/// ASC("gdasc"): gdasc1xrqjz66dd04c4uuhj9hk4jugnuzc8pr34wcey7dtq4pk5fkw52ftqxz9zet
static immutable ASC = KeyPair(PublicKey(Point([193, 33, 107, 77, 107, 235, 138, 243, 151, 145, 111, 106, 203, 136, 159, 5, 131, 132, 113, 171, 177, 146, 121, 171, 5, 67, 106, 38, 206, 162, 146, 176])), SecretKey(Scalar([125, 23, 179, 210, 236, 215, 146, 243, 173, 51, 99, 87, 122, 83, 79, 213, 238, 246, 226, 198, 123, 162, 227, 11, 1, 174, 178, 156, 163, 232, 235, 10])));
/// ASD("gdasd"): gdasd1xrqjr667vundhxkq950pzfpu7z79hczjv9x7kn9u02ykjkugx4dd2yljg4k
static immutable ASD = KeyPair(PublicKey(Point([193, 33, 235, 94, 103, 38, 219, 154, 192, 45, 30, 17, 36, 60, 240, 188, 91, 224, 82, 97, 77, 235, 76, 188, 122, 137, 105, 91, 136, 53, 90, 213])), SecretKey(Scalar([229, 107, 151, 43, 118, 161, 72, 248, 48, 23, 14, 199, 97, 104, 124, 57, 208, 72, 59, 76, 106, 199, 48, 133, 3, 71, 93, 202, 249, 163, 16, 2])));
/// ASE("gdase"): gdase1xrqjy66249ujd0ms2r39jg94lw7vhdfdvprsfzkm5znxu2j6akuhw53k867
static immutable ASE = KeyPair(PublicKey(Point([193, 34, 107, 74, 169, 121, 38, 191, 112, 80, 226, 89, 32, 181, 251, 188, 203, 181, 45, 96, 71, 4, 138, 219, 160, 166, 110, 42, 90, 237, 185, 119])), SecretKey(Scalar([171, 149, 144, 166, 176, 81, 36, 23, 193, 43, 247, 186, 78, 207, 244, 163, 119, 223, 202, 218, 58, 143, 240, 176, 59, 222, 57, 250, 244, 54, 202, 9])));
/// ASF("gdasf"): gdasf1xrqj966hn0kp0zwzfvegd9zmqhrllklr2vyuwxkmyxxf67m8xps575r764w
static immutable ASF = KeyPair(PublicKey(Point([193, 34, 235, 87, 155, 236, 23, 137, 194, 75, 50, 134, 148, 91, 5, 199, 255, 219, 227, 83, 9, 199, 26, 219, 33, 140, 157, 123, 103, 48, 97, 79])), SecretKey(Scalar([242, 250, 185, 202, 124, 59, 117, 154, 90, 218, 32, 56, 55, 188, 187, 222, 188, 76, 158, 111, 120, 183, 204, 158, 29, 86, 159, 203, 40, 163, 59, 4])));
/// ASG("gdasg"): gdasg1xrqjx66uway9au2ut82jm4kx8jwwz6dncss3jmedaaatpkpz35tekgpqpfs
static immutable ASG = KeyPair(PublicKey(Point([193, 35, 107, 92, 119, 72, 94, 241, 92, 89, 213, 45, 214, 198, 60, 156, 225, 105, 179, 196, 33, 25, 111, 45, 239, 122, 176, 216, 34, 141, 23, 155])), SecretKey(Scalar([11, 16, 135, 110, 166, 246, 212, 180, 77, 136, 182, 124, 7, 140, 199, 14, 21, 104, 132, 245, 75, 221, 176, 251, 83, 43, 112, 59, 169, 203, 173, 14])));
/// ASH("gdash"): gdash1xrqj8666eqw5ulq6tgwhysj0ffuglds4lstla2nqwrcc2up8z7ghjxhz453
static immutable ASH = KeyPair(PublicKey(Point([193, 35, 235, 90, 200, 29, 78, 124, 26, 90, 29, 114, 66, 79, 74, 120, 143, 182, 21, 252, 23, 254, 170, 96, 112, 241, 133, 112, 39, 23, 145, 121])), SecretKey(Scalar([27, 53, 62, 5, 11, 151, 242, 172, 238, 231, 67, 115, 199, 76, 64, 108, 187, 0, 65, 173, 74, 216, 197, 196, 190, 8, 69, 196, 248, 197, 171, 10])));
/// ASI("gdasi"): gdasi1xrqjg66xzjmwxefmqsuw48m686ng4r0m9peqry94rmf3uy8am7zx6afdas8
static immutable ASI = KeyPair(PublicKey(Point([193, 36, 107, 70, 20, 182, 227, 101, 59, 4, 56, 234, 159, 122, 62, 166, 138, 141, 251, 40, 114, 1, 144, 181, 30, 211, 30, 16, 253, 223, 132, 109])), SecretKey(Scalar([119, 93, 64, 207, 85, 136, 4, 196, 3, 19, 75, 16, 187, 185, 41, 51, 243, 75, 135, 24, 174, 184, 32, 165, 48, 116, 133, 113, 21, 155, 35, 10])));
/// ASJ("gdasj"): gdasj1xrqjf66cs5a6v87v6p90ute86txlecs7d3e62xzn8w9nulcr7tdt24n6zxz
static immutable ASJ = KeyPair(PublicKey(Point([193, 36, 235, 88, 133, 59, 166, 31, 204, 208, 74, 254, 47, 39, 210, 205, 252, 226, 30, 108, 115, 165, 24, 83, 59, 139, 62, 127, 3, 242, 218, 181])), SecretKey(Scalar([57, 102, 114, 173, 45, 87, 120, 241, 255, 189, 155, 238, 23, 209, 147, 154, 42, 139, 88, 59, 83, 55, 84, 177, 63, 248, 47, 227, 61, 179, 244, 9])));
/// ASK("gdask"): gdask1xrqj266u3re8sj240k62nmm0mgtes8lqh9pg337fj70yvrl98pz9v8ttxqh
static immutable ASK = KeyPair(PublicKey(Point([193, 37, 107, 92, 136, 242, 120, 73, 85, 125, 180, 169, 239, 111, 218, 23, 152, 31, 224, 185, 66, 136, 199, 201, 151, 158, 70, 15, 229, 56, 68, 86])), SecretKey(Scalar([99, 13, 83, 143, 91, 214, 231, 105, 202, 203, 163, 230, 81, 160, 248, 194, 224, 169, 145, 226, 246, 155, 68, 111, 139, 148, 188, 41, 81, 76, 1, 12])));
/// ASL("gdasl"): gdasl1xrqjt66z93gneqm78z7699nyjr638j5pyfxf0e2nwg3rlcwsrfvu5j3mn6d
static immutable ASL = KeyPair(PublicKey(Point([193, 37, 235, 66, 44, 81, 60, 131, 126, 56, 189, 162, 150, 100, 144, 245, 19, 202, 129, 34, 76, 151, 229, 83, 114, 34, 63, 225, 208, 26, 89, 202])), SecretKey(Scalar([21, 176, 65, 112, 113, 86, 117, 101, 146, 167, 13, 143, 43, 39, 127, 60, 23, 253, 100, 203, 29, 225, 101, 109, 42, 209, 241, 189, 185, 46, 245, 15])));
/// ASM("gdasm"): gdasm1xrqjv66eurs07xdpqxc74gg5ax8lvc0xn98k7p8ujjt834ukq2fck4z6dpx
static immutable ASM = KeyPair(PublicKey(Point([193, 38, 107, 89, 224, 224, 255, 25, 161, 1, 177, 234, 161, 20, 233, 143, 246, 97, 230, 153, 79, 111, 4, 252, 148, 150, 120, 215, 150, 2, 147, 139])), SecretKey(Scalar([220, 181, 20, 112, 132, 173, 242, 233, 46, 223, 80, 116, 80, 32, 23, 127, 17, 28, 99, 29, 56, 27, 241, 175, 34, 179, 128, 243, 173, 33, 59, 7])));
/// ASN("gdasn"): gdasn1xrqjd66mcvfhgp26ws64czmlaxl7t8u9876ez0c6pxuh2m57wl7lwsvmcsl
static immutable ASN = KeyPair(PublicKey(Point([193, 38, 235, 91, 195, 19, 116, 5, 90, 116, 53, 92, 11, 127, 233, 191, 229, 159, 133, 63, 181, 145, 63, 26, 9, 185, 117, 110, 158, 119, 253, 247])), SecretKey(Scalar([28, 157, 239, 48, 26, 178, 158, 103, 102, 129, 178, 115, 18, 187, 75, 142, 225, 194, 133, 95, 102, 118, 199, 148, 9, 63, 69, 66, 164, 27, 166, 6])));
/// ASO("gdaso"): gdaso1xrqjw66shhvhwjjgn6qs7z3mmr540slaur8qfgkmfl6c76mfpdcjcmrrxz8
static immutable ASO = KeyPair(PublicKey(Point([193, 39, 107, 80, 189, 217, 119, 74, 72, 158, 129, 15, 10, 59, 216, 233, 87, 195, 253, 224, 206, 4, 162, 219, 79, 245, 143, 107, 105, 11, 113, 44])), SecretKey(Scalar([187, 61, 55, 254, 100, 15, 76, 7, 116, 57, 208, 22, 218, 37, 32, 182, 244, 173, 109, 98, 111, 252, 84, 66, 102, 102, 174, 163, 8, 233, 178, 7])));
/// ASP("gdasp"): gdasp1xrqj066l5n08mjt9shkmncec0h4lqm4twmpj67vquy3qelxevrp6yhsjz0w
static immutable ASP = KeyPair(PublicKey(Point([193, 39, 235, 95, 164, 222, 125, 201, 101, 133, 237, 185, 227, 56, 125, 235, 240, 110, 171, 118, 195, 45, 121, 128, 225, 34, 12, 252, 217, 96, 195, 162])), SecretKey(Scalar([198, 53, 12, 180, 88, 52, 211, 23, 152, 87, 64, 22, 142, 247, 24, 216, 9, 39, 145, 163, 167, 245, 12, 238, 86, 52, 83, 210, 215, 105, 77, 3])));
/// ASQ("gdasq"): gdasq1xrqjs66lh45nxuklgf8rujvglkvzrjple50dttxsld59jua8mmnfwxmvr82
static immutable ASQ = KeyPair(PublicKey(Point([193, 40, 107, 95, 189, 105, 51, 114, 223, 66, 78, 62, 73, 136, 253, 152, 33, 200, 63, 205, 30, 213, 172, 208, 251, 104, 89, 115, 167, 222, 230, 151])), SecretKey(Scalar([175, 232, 170, 240, 192, 230, 157, 157, 58, 126, 95, 152, 163, 55, 47, 137, 161, 139, 40, 81, 122, 239, 241, 95, 173, 91, 140, 55, 201, 33, 165, 5])));
/// ASR("gdasr"): gdasr1xrqj366wsnw0lp3kd93gwcx2asug8j2484e9uz5d903ke3q9cj6xs8l2es7
static immutable ASR = KeyPair(PublicKey(Point([193, 40, 235, 78, 132, 220, 255, 134, 54, 105, 98, 135, 96, 202, 236, 56, 131, 201, 85, 61, 114, 94, 10, 141, 43, 227, 108, 196, 5, 196, 180, 104])), SecretKey(Scalar([9, 179, 7, 170, 19, 156, 153, 29, 103, 79, 253, 238, 211, 92, 114, 214, 67, 220, 72, 101, 76, 40, 223, 5, 207, 61, 228, 78, 196, 107, 64, 3])));
/// ASS("gdass"): gdass1xrqjj66jfs8n7rut6xpw6r2nr25jykn4lj6asyxec68385h98v096g9lwyh
static immutable ASS = KeyPair(PublicKey(Point([193, 41, 107, 82, 76, 15, 63, 15, 139, 209, 130, 237, 13, 83, 26, 169, 34, 90, 117, 252, 181, 216, 16, 217, 198, 143, 19, 210, 229, 59, 30, 93])), SecretKey(Scalar([10, 34, 115, 87, 34, 192, 57, 38, 200, 75, 90, 7, 30, 178, 109, 69, 70, 195, 218, 83, 249, 111, 120, 119, 86, 119, 18, 14, 25, 3, 208, 7])));
/// AST("gdast"): gdast1xrqjn66dkgwf97vgqwak95dxwzaefh4wyhjhju9pampafptue0vgyh2qqn8
static immutable AST = KeyPair(PublicKey(Point([193, 41, 235, 77, 178, 28, 146, 249, 136, 3, 187, 98, 209, 166, 112, 187, 148, 222, 174, 37, 229, 121, 112, 161, 238, 195, 212, 133, 124, 203, 216, 130])), SecretKey(Scalar([39, 35, 145, 31, 252, 174, 196, 208, 72, 132, 239, 110, 132, 113, 99, 71, 146, 133, 235, 173, 88, 34, 146, 140, 186, 23, 225, 76, 230, 240, 11, 0])));
/// ASU("gdasu"): gdasu1xrqj566tgs2tthz02fyrvnfggdvzu828x4m5u5dgzw7gryaufny4qlkt0w6
static immutable ASU = KeyPair(PublicKey(Point([193, 42, 107, 75, 68, 20, 181, 220, 79, 82, 72, 54, 77, 40, 67, 88, 46, 29, 71, 53, 119, 78, 81, 168, 19, 188, 129, 147, 188, 76, 201, 80])), SecretKey(Scalar([192, 233, 16, 172, 44, 87, 84, 94, 244, 251, 124, 206, 110, 201, 37, 255, 157, 102, 38, 106, 124, 176, 243, 238, 74, 10, 11, 26, 176, 112, 13, 15])));
/// ASV("gdasv"): gdasv1xrqj4669p493mckh9c7zlc4r4jgvwzxg3tp8ev5g9h4vvelklc4q7ff60zk
static immutable ASV = KeyPair(PublicKey(Point([193, 42, 235, 69, 13, 75, 29, 226, 215, 46, 60, 47, 226, 163, 172, 144, 199, 8, 200, 138, 194, 124, 178, 136, 45, 234, 198, 103, 246, 254, 42, 15])), SecretKey(Scalar([106, 142, 191, 146, 12, 234, 233, 42, 245, 82, 101, 39, 125, 17, 243, 184, 70, 109, 159, 203, 192, 242, 122, 66, 86, 18, 67, 94, 169, 52, 227, 10])));
/// ASW("gdasw"): gdasw1xrqjk66zukjuurmzuwe9cvcnfeychend73f7hmk27yjj0x8zqjyf6j7gh56
static immutable ASW = KeyPair(PublicKey(Point([193, 43, 107, 66, 229, 165, 206, 15, 98, 227, 178, 92, 51, 19, 78, 73, 139, 230, 109, 244, 83, 235, 238, 202, 241, 37, 39, 152, 226, 4, 136, 157])), SecretKey(Scalar([143, 128, 92, 85, 213, 61, 167, 198, 1, 251, 207, 32, 102, 231, 231, 88, 173, 13, 101, 224, 235, 243, 213, 147, 173, 173, 67, 185, 173, 17, 247, 0])));
/// ASX("gdasx"): gdasx1xrqjh66fmq92sn6tx8500dhdjw4ye5ahlvme4um5ajxxz06hy4vj542uqmm
static immutable ASX = KeyPair(PublicKey(Point([193, 43, 235, 73, 216, 10, 168, 79, 75, 49, 232, 247, 182, 237, 147, 170, 76, 211, 183, 251, 55, 154, 243, 116, 236, 140, 97, 63, 87, 37, 89, 42])), SecretKey(Scalar([28, 243, 105, 0, 85, 164, 158, 74, 73, 26, 175, 126, 100, 1, 156, 224, 246, 199, 109, 10, 20, 88, 109, 54, 82, 58, 208, 214, 220, 39, 43, 4])));
/// ASY("gdasy"): gdasy1xrqjc66lsqfz93suefenpzhcmap5md8vs3n64ern53c5pp0yjldazexh7rd
static immutable ASY = KeyPair(PublicKey(Point([193, 44, 107, 95, 128, 18, 34, 198, 28, 202, 115, 48, 138, 248, 223, 67, 77, 180, 236, 132, 103, 170, 228, 115, 164, 113, 64, 133, 228, 151, 219, 209])), SecretKey(Scalar([36, 206, 198, 183, 11, 188, 7, 21, 252, 68, 179, 99, 188, 212, 86, 140, 241, 107, 240, 249, 216, 188, 3, 185, 50, 82, 212, 223, 142, 171, 190, 4])));
/// ASZ("gdasz"): gdasz1xrqje669kksrsqpg7h7mdh3hd8n7ujngms962ae8wxwcxkzlh324w2at9qg
static immutable ASZ = KeyPair(PublicKey(Point([193, 44, 235, 69, 181, 160, 56, 0, 40, 245, 253, 182, 222, 55, 105, 231, 238, 74, 104, 220, 11, 165, 119, 39, 113, 157, 131, 88, 95, 188, 85, 87])), SecretKey(Scalar([129, 39, 204, 90, 18, 159, 101, 234, 174, 250, 159, 249, 250, 218, 215, 103, 230, 184, 35, 19, 226, 58, 179, 243, 116, 113, 75, 237, 194, 137, 57, 15])));
/// ATA("gdata"): gdata1xrqnq66fxz88hqjlw9vn0dxkk0s3wp88sr4pnyyhclun2hqmxgk874p3zzs
static immutable ATA = KeyPair(PublicKey(Point([193, 48, 107, 73, 48, 142, 123, 130, 95, 113, 89, 55, 180, 214, 179, 225, 23, 4, 231, 128, 234, 25, 144, 151, 199, 249, 53, 92, 27, 50, 44, 127])), SecretKey(Scalar([118, 23, 62, 110, 174, 168, 154, 96, 181, 193, 191, 229, 254, 204, 153, 117, 163, 54, 230, 146, 53, 237, 233, 122, 17, 143, 39, 94, 185, 114, 215, 15])));
/// ATB("gdatb"): gdatb1xrqnp668nm9lg7x48yph99j3mndr9uttevznsn329ahy9qppzj38wq760ht
static immutable ATB = KeyPair(PublicKey(Point([193, 48, 235, 71, 158, 203, 244, 120, 213, 57, 3, 114, 150, 81, 220, 218, 50, 241, 107, 203, 5, 56, 78, 42, 47, 110, 66, 128, 33, 20, 162, 119])), SecretKey(Scalar([40, 155, 50, 195, 115, 252, 14, 11, 61, 170, 113, 21, 194, 15, 136, 109, 103, 151, 233, 162, 249, 239, 38, 238, 112, 87, 246, 55, 39, 117, 43, 10])));
/// ATC("gdatc"): gdatc1xrqnz66vmkhdc9h6dl7ad9eglsfy68jpwul53zspl8e6ardxsa6swvkdyrj
static immutable ATC = KeyPair(PublicKey(Point([193, 49, 107, 76, 221, 174, 220, 22, 250, 111, 253, 214, 151, 40, 252, 18, 77, 30, 65, 119, 63, 72, 138, 1, 249, 243, 174, 141, 166, 135, 117, 7])), SecretKey(Scalar([200, 71, 32, 97, 154, 131, 85, 100, 220, 152, 18, 60, 99, 20, 155, 167, 40, 252, 57, 71, 21, 91, 32, 227, 144, 194, 225, 27, 140, 67, 186, 14])));
/// ATD("gdatd"): gdatd1xrqnr66qh2knqw4smd2nz4jxfhsx9hq06q6dytxj75g2fe95u72vwgdku0c
static immutable ATD = KeyPair(PublicKey(Point([193, 49, 235, 64, 186, 173, 48, 58, 176, 219, 85, 49, 86, 70, 77, 224, 98, 220, 15, 208, 52, 210, 44, 210, 245, 16, 164, 228, 180, 231, 148, 199])), SecretKey(Scalar([136, 113, 150, 141, 230, 186, 112, 100, 213, 128, 55, 96, 250, 171, 38, 100, 95, 93, 186, 125, 78, 155, 92, 73, 237, 140, 163, 158, 213, 152, 176, 3])));
/// ATE("gdate"): gdate1xrqny66gvlexkqc2aur4v27jepq05f0cnytk5du769q694g20va225ja62w
static immutable ATE = KeyPair(PublicKey(Point([193, 50, 107, 72, 103, 242, 107, 3, 10, 239, 7, 86, 43, 210, 200, 64, 250, 37, 248, 153, 23, 106, 55, 158, 209, 65, 162, 213, 10, 123, 58, 165])), SecretKey(Scalar([59, 249, 24, 20, 70, 55, 214, 155, 174, 192, 137, 133, 70, 217, 105, 235, 248, 5, 37, 46, 113, 99, 75, 246, 91, 80, 64, 27, 8, 0, 156, 0])));
/// ATF("gdatf"): gdatf1xrqn9665tj2nzqe5lj64fjwtdwrkderk6slqt26hj7t5pr0vr5x070j4m8u
static immutable ATF = KeyPair(PublicKey(Point([193, 50, 235, 84, 92, 149, 49, 3, 52, 252, 181, 84, 201, 203, 107, 135, 102, 228, 118, 212, 62, 5, 171, 87, 151, 151, 64, 141, 236, 29, 12, 255])), SecretKey(Scalar([11, 17, 49, 245, 252, 137, 175, 29, 61, 11, 46, 35, 198, 218, 148, 175, 145, 153, 20, 193, 92, 122, 141, 202, 244, 118, 219, 47, 65, 36, 114, 9])));
/// ATG("gdatg"): gdatg1xrqnx665gnvxwcluvg70czshufqdjjrz3d7wzgs9ffnjmye6qk6uy5p5n55
static immutable ATG = KeyPair(PublicKey(Point([193, 51, 107, 84, 68, 216, 103, 99, 252, 98, 60, 252, 10, 23, 226, 64, 217, 72, 98, 139, 124, 225, 34, 5, 74, 103, 45, 147, 58, 5, 181, 194])), SecretKey(Scalar([31, 107, 131, 179, 202, 160, 115, 25, 255, 76, 79, 53, 172, 183, 41, 248, 187, 229, 103, 26, 228, 3, 58, 70, 6, 175, 117, 108, 18, 174, 146, 0])));
/// ATH("gdath"): gdath1xrqn86680z7zaen30hv3f67urjv8y87ez79lth4xj3wpzt6q50u4ggcdv9t
static immutable ATH = KeyPair(PublicKey(Point([193, 51, 235, 71, 120, 188, 46, 230, 113, 125, 217, 20, 235, 220, 28, 152, 114, 31, 217, 23, 139, 245, 222, 166, 148, 92, 17, 47, 64, 163, 249, 84])), SecretKey(Scalar([11, 15, 227, 227, 115, 75, 190, 169, 48, 155, 71, 124, 16, 127, 127, 158, 231, 98, 122, 29, 168, 16, 135, 3, 200, 236, 103, 22, 234, 79, 5, 12])));
/// ATI("gdati"): gdati1xrqng66ynxdv97remmg3rh0t8v8as2un0rv5nrht38z886gymafd6n4zudx
static immutable ATI = KeyPair(PublicKey(Point([193, 52, 107, 68, 153, 154, 194, 248, 121, 222, 209, 17, 221, 235, 59, 15, 216, 43, 147, 120, 217, 73, 142, 235, 137, 196, 115, 233, 4, 223, 82, 221])), SecretKey(Scalar([54, 142, 235, 253, 201, 208, 123, 166, 211, 122, 137, 241, 154, 74, 45, 206, 209, 169, 77, 222, 203, 190, 194, 12, 119, 247, 215, 125, 69, 210, 182, 1])));
/// ATJ("gdatj"): gdatj1xrqnf66xwudd3380ejrn9thcwtp5j3m9ygy9pn80qrz65eu3camwsh0w8lx
static immutable ATJ = KeyPair(PublicKey(Point([193, 52, 235, 70, 119, 26, 216, 196, 239, 204, 135, 50, 174, 248, 114, 195, 73, 71, 101, 34, 8, 80, 204, 239, 0, 197, 170, 103, 145, 199, 118, 232])), SecretKey(Scalar([48, 26, 167, 211, 95, 198, 232, 141, 151, 100, 193, 227, 129, 143, 250, 88, 202, 130, 253, 159, 225, 207, 35, 58, 8, 248, 108, 50, 229, 113, 80, 14])));
/// ATK("gdatk"): gdatk1xrqn266g8plkzw6gjk4khxthcz0pujjv8jz9ereq84ckd0dly8d0x405cay
static immutable ATK = KeyPair(PublicKey(Point([193, 53, 107, 72, 56, 127, 97, 59, 72, 149, 171, 107, 153, 119, 192, 158, 30, 74, 76, 60, 132, 92, 143, 32, 61, 113, 102, 189, 191, 33, 218, 243])), SecretKey(Scalar([251, 124, 194, 236, 110, 180, 243, 191, 151, 57, 21, 26, 43, 77, 180, 169, 253, 119, 82, 36, 132, 126, 250, 13, 22, 98, 174, 222, 229, 83, 119, 5])));
/// ATL("gdatl"): gdatl1xrqnt66pxzhnufxvczqxq5epzeafpq33k87d6kndsun8wyuvp2p4kukgpf2
static immutable ATL = KeyPair(PublicKey(Point([193, 53, 235, 65, 48, 175, 62, 36, 204, 192, 128, 96, 83, 33, 22, 122, 144, 130, 49, 177, 252, 221, 90, 109, 135, 38, 119, 19, 140, 10, 131, 91])), SecretKey(Scalar([164, 13, 14, 49, 39, 92, 152, 100, 248, 79, 7, 53, 171, 158, 49, 187, 74, 223, 183, 222, 156, 213, 47, 25, 112, 47, 120, 151, 98, 136, 60, 14])));
/// ATM("gdatm"): gdatm1xrqnv667w8y0rkq3mx25n4cuvrzdgust2pjat3wpag36y0vwhxajsq8hmhz
static immutable ATM = KeyPair(PublicKey(Point([193, 54, 107, 94, 113, 200, 241, 216, 17, 217, 149, 73, 215, 28, 96, 196, 212, 114, 11, 80, 101, 213, 197, 193, 234, 35, 162, 61, 142, 185, 187, 40])), SecretKey(Scalar([246, 132, 29, 115, 91, 251, 196, 113, 101, 222, 201, 140, 47, 61, 253, 160, 174, 14, 68, 14, 103, 79, 158, 243, 119, 134, 149, 74, 179, 159, 49, 10])));
/// ATN("gdatn"): gdatn1xrqnd66nupdgv7scm0rsfwum5h7jr260rjkwsc6trf8rccq4qw95u3r7l2s
static immutable ATN = KeyPair(PublicKey(Point([193, 54, 235, 83, 224, 90, 134, 122, 24, 219, 199, 4, 187, 155, 165, 253, 33, 171, 79, 28, 172, 232, 99, 75, 26, 78, 60, 96, 21, 3, 139, 78])), SecretKey(Scalar([174, 189, 72, 186, 33, 245, 41, 84, 45, 123, 94, 14, 149, 165, 123, 12, 252, 156, 163, 170, 205, 139, 21, 245, 96, 142, 210, 3, 147, 78, 214, 13])));
/// ATO("gdato"): gdato1xrqnw660yz3jw0mmpxvd6dk20ekpj00a9wv3urn6f7l93dzgca56w38hsqc
static immutable ATO = KeyPair(PublicKey(Point([193, 55, 107, 79, 32, 163, 39, 63, 123, 9, 152, 221, 54, 202, 126, 108, 25, 61, 253, 43, 153, 30, 14, 122, 79, 190, 88, 180, 72, 199, 105, 167])), SecretKey(Scalar([59, 44, 64, 188, 51, 3, 144, 124, 189, 183, 41, 246, 75, 252, 202, 42, 136, 55, 121, 125, 252, 74, 103, 62, 52, 195, 141, 144, 248, 141, 91, 9])));
/// ATP("gdatp"): gdatp1xrqn0664svasslnkl0mpxjx3taw4sq8wk39s94yvxwyy5ghvpntuvnl9076
static immutable ATP = KeyPair(PublicKey(Point([193, 55, 235, 85, 131, 59, 8, 126, 118, 251, 246, 19, 72, 209, 95, 93, 88, 0, 238, 180, 75, 2, 212, 140, 51, 136, 74, 34, 236, 12, 215, 198])), SecretKey(Scalar([47, 175, 24, 19, 183, 177, 99, 137, 16, 41, 104, 46, 241, 1, 87, 25, 31, 252, 106, 70, 237, 109, 34, 51, 123, 239, 139, 99, 118, 1, 66, 7])));
/// ATQ("gdatq"): gdatq1xrqns66gwswtdcflr0rh6hh57g49wqy4m6kauhrg5t96yt0yvxc9c92lw2h
static immutable ATQ = KeyPair(PublicKey(Point([193, 56, 107, 72, 116, 28, 182, 225, 63, 27, 199, 125, 94, 244, 242, 42, 87, 0, 149, 222, 173, 222, 92, 104, 162, 203, 162, 45, 228, 97, 176, 92])), SecretKey(Scalar([157, 114, 58, 98, 250, 140, 113, 206, 19, 168, 250, 8, 182, 31, 142, 237, 183, 181, 4, 59, 66, 113, 233, 97, 118, 231, 87, 199, 70, 84, 88, 10])));
/// ATR("gdatr"): gdatr1xrqn366f4vjth4yt54c2a0886knkl5fheacpntj8qz2ewxfk853c79uny48
static immutable ATR = KeyPair(PublicKey(Point([193, 56, 235, 73, 171, 36, 187, 212, 139, 165, 112, 174, 188, 231, 213, 167, 111, 209, 55, 207, 112, 25, 174, 71, 0, 149, 151, 25, 54, 61, 35, 143])), SecretKey(Scalar([121, 98, 110, 28, 50, 132, 161, 54, 76, 255, 117, 163, 199, 98, 99, 69, 113, 68, 88, 235, 29, 141, 203, 86, 183, 63, 56, 75, 88, 226, 12, 3])));
/// ATS("gdats"): gdats1xrqnj66xwv363s0jc0w7g8shk6qucv9wkdwk7w92tqctzahle7s3xt7xdl8
static immutable ATS = KeyPair(PublicKey(Point([193, 57, 107, 70, 115, 35, 168, 193, 242, 195, 221, 228, 30, 23, 182, 129, 204, 48, 174, 179, 93, 111, 56, 170, 88, 48, 177, 118, 255, 207, 161, 19])), SecretKey(Scalar([7, 92, 46, 25, 60, 212, 191, 185, 241, 252, 37, 27, 130, 247, 151, 44, 91, 67, 250, 17, 4, 189, 156, 170, 71, 113, 185, 174, 200, 139, 15, 7])));
/// ATT("gdatt"): gdatt1xrqnn66at4d4txvu8fwfqsgplu8hdwfgy7lqker523smzjggqzzzxe9llae
static immutable ATT = KeyPair(PublicKey(Point([193, 57, 235, 93, 93, 91, 85, 153, 156, 58, 92, 144, 65, 1, 255, 15, 118, 185, 40, 39, 190, 11, 100, 116, 84, 97, 177, 73, 8, 0, 132, 35])), SecretKey(Scalar([255, 33, 253, 97, 95, 119, 125, 138, 239, 128, 95, 78, 134, 143, 150, 119, 160, 18, 22, 16, 83, 14, 176, 13, 182, 225, 109, 105, 112, 16, 120, 10])));
/// ATU("gdatu"): gdatu1xrqn566knuy84yhlxd7yd9zn78729kusv7jt2y3xs4cs59l2lwxt580dg3h
static immutable ATU = KeyPair(PublicKey(Point([193, 58, 107, 86, 159, 8, 122, 146, 255, 51, 124, 70, 148, 83, 241, 252, 162, 219, 144, 103, 164, 181, 18, 38, 133, 113, 10, 23, 234, 251, 140, 186])), SecretKey(Scalar([253, 107, 1, 55, 103, 186, 235, 222, 219, 44, 149, 209, 80, 99, 128, 100, 9, 108, 149, 236, 231, 212, 209, 56, 198, 21, 87, 38, 235, 196, 128, 4])));
/// ATV("gdatv"): gdatv1xrqn466mnpt7mpjmaxv6k5h4j7rt9pnkg3t74nqlu4sph90mn38ry7atl9f
static immutable ATV = KeyPair(PublicKey(Point([193, 58, 235, 91, 152, 87, 237, 134, 91, 233, 153, 171, 82, 245, 151, 134, 178, 134, 118, 68, 87, 234, 204, 31, 229, 96, 27, 149, 251, 156, 78, 50])), SecretKey(Scalar([192, 164, 222, 1, 235, 215, 180, 167, 193, 35, 113, 158, 41, 186, 201, 84, 222, 239, 220, 204, 115, 246, 78, 6, 167, 8, 142, 104, 217, 170, 54, 2])));
/// ATW("gdatw"): gdatw1xrqnk66p3ntjvqxjthtv37sdgax0c9wmmnq78c4mjz8ynfuxw8psx2cxm9s
static immutable ATW = KeyPair(PublicKey(Point([193, 59, 107, 65, 140, 215, 38, 0, 210, 93, 214, 200, 250, 13, 71, 76, 252, 21, 219, 220, 193, 227, 226, 187, 144, 142, 73, 167, 134, 113, 195, 3])), SecretKey(Scalar([249, 124, 232, 152, 102, 27, 8, 0, 90, 112, 7, 243, 110, 154, 214, 223, 26, 17, 39, 128, 141, 187, 175, 143, 231, 157, 169, 58, 220, 6, 209, 7])));
/// ATX("gdatx"): gdatx1xrqnh66m9ehv6r3gtewv6rhy9r67wpm6yxfp52gv70gqgtr0hhkwctfh677
static immutable ATX = KeyPair(PublicKey(Point([193, 59, 235, 91, 46, 110, 205, 14, 40, 94, 92, 205, 14, 228, 40, 245, 231, 7, 122, 33, 146, 26, 41, 12, 243, 208, 4, 44, 111, 189, 236, 236])), SecretKey(Scalar([118, 217, 69, 142, 28, 164, 169, 5, 133, 86, 181, 220, 136, 142, 224, 252, 141, 87, 157, 26, 237, 56, 10, 131, 122, 23, 86, 65, 85, 246, 115, 6])));
/// ATY("gdaty"): gdaty1xrqnc66d5ht7pr50kwy0tcvpk2r42kwaf8ce82x0cmgul7pjm9cd2ecpy6g
static immutable ATY = KeyPair(PublicKey(Point([193, 60, 107, 77, 165, 215, 224, 142, 143, 179, 136, 245, 225, 129, 178, 135, 85, 89, 221, 73, 241, 147, 168, 207, 198, 209, 207, 248, 50, 217, 112, 213])), SecretKey(Scalar([100, 205, 112, 222, 10, 191, 140, 182, 89, 189, 180, 185, 123, 182, 246, 87, 126, 87, 111, 69, 180, 225, 38, 47, 255, 161, 172, 182, 204, 149, 66, 5])));
/// ATZ("gdatz"): gdatz1xrqne666rvezrsplqkf305h7dexfs7hvvwrphmpsdvpnt3qkevkxjy3a9aw
static immutable ATZ = KeyPair(PublicKey(Point([193, 60, 235, 90, 27, 50, 33, 192, 63, 5, 147, 23, 210, 254, 110, 76, 152, 122, 236, 99, 134, 27, 236, 48, 107, 3, 53, 196, 22, 203, 44, 105])), SecretKey(Scalar([6, 216, 144, 93, 187, 235, 157, 65, 184, 32, 71, 195, 252, 135, 215, 108, 129, 39, 49, 62, 206, 195, 89, 238, 126, 192, 231, 114, 223, 46, 23, 2])));
/// AUA("gdaua"): gdaua1xrq5q66mw6vjvt6xs855t8uah2jfjss2268smt4lr3w49pfnc60njcdj3ad
static immutable AUA = KeyPair(PublicKey(Point([193, 64, 107, 91, 118, 153, 38, 47, 70, 129, 233, 69, 159, 157, 186, 164, 153, 66, 10, 86, 143, 13, 174, 191, 28, 93, 82, 133, 51, 198, 159, 57])), SecretKey(Scalar([136, 237, 212, 135, 42, 185, 132, 147, 196, 149, 228, 105, 80, 50, 224, 138, 176, 0, 88, 124, 123, 29, 199, 74, 241, 28, 232, 175, 202, 91, 82, 0])));
/// AUB("gdaub"): gdaub1xrq5p66hd3a2ghjuyfpjyqttxg8tj9qfa8hc7tnlugszgrzmuzgfqcckz6n
static immutable AUB = KeyPair(PublicKey(Point([193, 64, 235, 87, 108, 122, 164, 94, 92, 34, 67, 34, 1, 107, 50, 14, 185, 20, 9, 233, 239, 143, 46, 127, 226, 32, 36, 12, 91, 224, 144, 144])), SecretKey(Scalar([13, 122, 110, 133, 42, 198, 136, 149, 103, 170, 187, 114, 183, 148, 130, 240, 206, 150, 232, 214, 205, 122, 239, 165, 14, 65, 164, 213, 10, 253, 68, 12])));
/// AUC("gdauc"): gdauc1xrq5z66z5x55x25jg33333azvhmr5u3nquhscwdtrwff5jw9y3u97pf23l3
static immutable AUC = KeyPair(PublicKey(Point([193, 65, 107, 66, 161, 169, 67, 42, 146, 68, 99, 24, 199, 162, 101, 246, 58, 114, 51, 7, 47, 12, 57, 171, 27, 146, 154, 73, 197, 36, 120, 95])), SecretKey(Scalar([24, 246, 245, 102, 143, 242, 143, 14, 164, 95, 174, 172, 226, 208, 85, 14, 161, 135, 88, 64, 36, 228, 138, 122, 46, 158, 26, 193, 60, 217, 195, 3])));
/// AUD("gdaud"): gdaud1xrq5r66d94wsj092d8a5tc74ck9nuky7kn8k4yxs04vys2cs8j59ucel9ra
static immutable AUD = KeyPair(PublicKey(Point([193, 65, 235, 77, 45, 93, 9, 60, 170, 105, 251, 69, 227, 213, 197, 139, 62, 88, 158, 180, 207, 106, 144, 208, 125, 88, 72, 43, 16, 60, 168, 94])), SecretKey(Scalar([210, 64, 107, 183, 47, 21, 214, 17, 90, 122, 93, 67, 78, 168, 153, 49, 142, 74, 155, 120, 24, 230, 117, 226, 176, 209, 235, 13, 237, 22, 168, 9])));
/// AUE("gdaue"): gdaue1xrq5y66vd4465qx5tq2xjrf0k94u7p84aa3ealtq0ddma9hdgzv2uz706cf
static immutable AUE = KeyPair(PublicKey(Point([193, 66, 107, 76, 109, 107, 170, 0, 212, 88, 20, 105, 13, 47, 177, 107, 207, 4, 245, 239, 99, 158, 253, 96, 123, 91, 190, 150, 237, 64, 152, 174])), SecretKey(Scalar([249, 36, 151, 170, 251, 90, 2, 224, 96, 145, 209, 7, 238, 176, 34, 30, 248, 8, 174, 180, 21, 205, 37, 100, 78, 141, 128, 186, 158, 18, 134, 14])));
/// AUF("gdauf"): gdauf1xrq59669d2lqscjh3nkjtf97gnvctjku4m4ly4xqj74z3ehy3l9kucyl2cq
static immutable AUF = KeyPair(PublicKey(Point([193, 66, 235, 69, 106, 190, 8, 98, 87, 140, 237, 37, 164, 190, 68, 217, 133, 202, 220, 174, 235, 242, 84, 192, 151, 170, 40, 230, 228, 143, 203, 110])), SecretKey(Scalar([185, 64, 17, 177, 213, 59, 29, 217, 6, 16, 190, 95, 73, 88, 50, 98, 159, 117, 181, 55, 220, 137, 27, 25, 195, 212, 83, 227, 15, 11, 58, 6])));
/// AUG("gdaug"): gdaug1xrq5x66ztxwztsnjk556xzfkjj3w95fljn7g67k5htqxqph02aljuacd2gx
static immutable AUG = KeyPair(PublicKey(Point([193, 67, 107, 66, 89, 156, 37, 194, 114, 181, 41, 163, 9, 54, 148, 162, 226, 209, 63, 148, 252, 141, 122, 212, 186, 192, 96, 6, 239, 87, 127, 46])), SecretKey(Scalar([154, 15, 52, 243, 177, 188, 214, 177, 235, 120, 220, 190, 236, 64, 6, 125, 124, 97, 120, 158, 50, 122, 38, 164, 157, 39, 38, 56, 251, 211, 200, 10])));
/// AUH("gdauh"): gdauh1xrq5866af6nh4kes5vl67sthrhz9a85y3nacspz2cez7r6v2a4myjg8spfv
static immutable AUH = KeyPair(PublicKey(Point([193, 67, 235, 93, 78, 167, 122, 219, 48, 163, 63, 175, 65, 119, 29, 196, 94, 158, 132, 140, 251, 136, 4, 74, 198, 69, 225, 233, 138, 237, 118, 73])), SecretKey(Scalar([109, 12, 15, 176, 112, 0, 219, 191, 54, 124, 236, 68, 45, 88, 41, 48, 119, 47, 206, 192, 89, 126, 65, 87, 239, 42, 75, 8, 36, 50, 117, 7])));
/// AUI("gdaui"): gdaui1xrq5g66t9p8ha58slxzh2nxvr5m8w6a4ljmtcajg7ctql5nkcet6c55wsr2
static immutable AUI = KeyPair(PublicKey(Point([193, 68, 107, 75, 40, 79, 126, 208, 240, 249, 133, 117, 76, 204, 29, 54, 119, 107, 181, 252, 182, 188, 118, 72, 246, 22, 15, 210, 118, 198, 87, 172])), SecretKey(Scalar([92, 212, 46, 89, 22, 52, 102, 55, 169, 65, 62, 2, 244, 246, 251, 30, 56, 172, 27, 212, 165, 204, 94, 217, 131, 240, 22, 226, 25, 176, 4, 14])));
/// AUJ("gdauj"): gdauj1xrq5f66xd3d3srn0kwkgr70vgt5fjzjqjdh4cj6c5c96lmfxhfv6q6nfspl
static immutable AUJ = KeyPair(PublicKey(Point([193, 68, 235, 70, 108, 91, 24, 14, 111, 179, 172, 129, 249, 236, 66, 232, 153, 10, 64, 147, 111, 92, 75, 88, 166, 11, 175, 237, 38, 186, 89, 160])), SecretKey(Scalar([162, 14, 76, 131, 81, 188, 193, 208, 228, 186, 148, 105, 211, 168, 63, 147, 107, 65, 116, 103, 38, 225, 46, 65, 102, 205, 159, 79, 173, 184, 217, 8])));
/// AUK("gdauk"): gdauk1xrq52666ayn5xrvsn9jlyeq77yqxjhucfvql5af3qu8rqq5vnt7wzs405v2
static immutable AUK = KeyPair(PublicKey(Point([193, 69, 107, 90, 233, 39, 67, 13, 144, 153, 101, 242, 100, 30, 241, 0, 105, 95, 152, 75, 1, 250, 117, 49, 7, 14, 48, 2, 140, 154, 252, 225])), SecretKey(Scalar([194, 204, 216, 5, 94, 72, 146, 225, 98, 118, 204, 135, 71, 110, 193, 75, 188, 186, 35, 8, 40, 105, 241, 52, 47, 60, 161, 244, 65, 156, 171, 1])));
/// AUL("gdaul"): gdaul1xrq5t66yfhh8qpfjw56rkt4rnl8xdpthsdwagw3unkm4gh87kk3lq0pluk7
static immutable AUL = KeyPair(PublicKey(Point([193, 69, 235, 68, 77, 238, 112, 5, 50, 117, 52, 59, 46, 163, 159, 206, 102, 133, 119, 131, 93, 212, 58, 60, 157, 183, 84, 92, 254, 181, 163, 240])), SecretKey(Scalar([231, 110, 118, 182, 228, 59, 143, 18, 42, 123, 233, 241, 240, 81, 1, 107, 210, 224, 67, 38, 241, 197, 129, 214, 136, 228, 148, 8, 27, 153, 25, 13])));
/// AUM("gdaum"): gdaum1xrq5v66cl0khxh86scnhenja8qe56e7fx7jug0ym9uq93ndel6qryljdmlq
static immutable AUM = KeyPair(PublicKey(Point([193, 70, 107, 88, 251, 237, 115, 92, 250, 134, 39, 124, 206, 93, 56, 51, 77, 103, 201, 55, 165, 196, 60, 155, 47, 0, 88, 205, 185, 254, 128, 50])), SecretKey(Scalar([36, 47, 66, 92, 41, 48, 173, 182, 45, 167, 57, 143, 116, 44, 45, 57, 16, 237, 182, 239, 73, 126, 5, 133, 89, 59, 98, 103, 50, 139, 10, 0])));
/// AUN("gdaun"): gdaun1xrq5d66n55urysn0e5mashn9fq3l58a0vad9093v3pu05ldwgqc8yldpuk5
static immutable AUN = KeyPair(PublicKey(Point([193, 70, 235, 83, 165, 56, 50, 66, 111, 205, 55, 216, 94, 101, 72, 35, 250, 31, 175, 103, 90, 87, 150, 44, 136, 120, 250, 125, 174, 64, 48, 114])), SecretKey(Scalar([78, 195, 214, 209, 245, 84, 30, 149, 236, 154, 92, 173, 135, 206, 137, 164, 119, 46, 216, 239, 115, 186, 59, 178, 238, 73, 169, 179, 200, 80, 168, 1])));
/// AUO("gdauo"): gdauo1xrq5w66jjmyp3em85dhl3vs7k0u5ln4k9l6s434gdfpa9r78j2n8zz2z46c
static immutable AUO = KeyPair(PublicKey(Point([193, 71, 107, 82, 150, 200, 24, 231, 103, 163, 111, 248, 178, 30, 179, 249, 79, 206, 182, 47, 245, 10, 198, 168, 106, 67, 210, 143, 199, 146, 166, 113])), SecretKey(Scalar([111, 53, 149, 49, 85, 74, 150, 146, 191, 233, 193, 148, 25, 171, 92, 118, 47, 71, 137, 193, 100, 189, 14, 0, 116, 101, 102, 111, 39, 248, 188, 10])));
/// AUP("gdaup"): gdaup1xrq50668ce98cn073esly43uquh9ypn8kqm6nf62upt3lmx49u652vd7le7
static immutable AUP = KeyPair(PublicKey(Point([193, 71, 235, 71, 198, 74, 124, 77, 254, 142, 97, 242, 86, 60, 7, 46, 82, 6, 103, 176, 55, 169, 167, 74, 224, 87, 31, 236, 213, 47, 53, 69])), SecretKey(Scalar([89, 87, 42, 148, 228, 130, 61, 95, 205, 48, 109, 170, 143, 39, 134, 216, 85, 245, 118, 69, 124, 100, 49, 221, 70, 78, 69, 252, 123, 124, 63, 9])));
/// AUQ("gdauq"): gdauq1xrq5s666c0knhek3wxqd9rzs6mauad97v7gkydytkw93fnwamm3sv90ttgy
static immutable AUQ = KeyPair(PublicKey(Point([193, 72, 107, 90, 195, 237, 59, 230, 209, 113, 128, 210, 140, 80, 214, 251, 206, 180, 190, 103, 145, 98, 52, 139, 179, 139, 20, 205, 221, 222, 227, 6])), SecretKey(Scalar([188, 92, 255, 170, 255, 91, 4, 205, 40, 92, 125, 177, 229, 109, 194, 120, 153, 190, 74, 146, 10, 132, 185, 144, 124, 120, 86, 170, 208, 217, 86, 4])));
/// AUR("gdaur"): gdaur1xrq5366f5yvgw5kqr47ugwwe6fkva42p9m923tujj9sxnl25tn69st6gcg3
static immutable AUR = KeyPair(PublicKey(Point([193, 72, 235, 73, 161, 24, 135, 82, 192, 29, 125, 196, 57, 217, 210, 108, 206, 213, 65, 46, 202, 168, 175, 146, 145, 96, 105, 253, 84, 92, 244, 88])), SecretKey(Scalar([136, 245, 236, 145, 161, 146, 167, 154, 171, 191, 136, 176, 253, 135, 194, 171, 153, 184, 205, 199, 129, 92, 143, 125, 3, 19, 200, 214, 223, 225, 85, 3])));
/// AUS("gdaus"): gdaus1xrq5j66t8z8xxhj6sz8drzny06f927q24v0anyfrncg02w27qahr5t9r070
static immutable AUS = KeyPair(PublicKey(Point([193, 73, 107, 75, 56, 142, 99, 94, 90, 128, 142, 209, 138, 100, 126, 146, 85, 120, 10, 171, 31, 217, 145, 35, 158, 16, 245, 57, 94, 7, 110, 58])), SecretKey(Scalar([13, 114, 37, 35, 80, 247, 224, 162, 227, 70, 128, 217, 232, 251, 213, 1, 86, 30, 85, 61, 196, 229, 254, 230, 189, 185, 163, 233, 22, 104, 6, 5])));
/// AUT("gdaut"): gdaut1xrq5n66q2hhtf2uw3krfwxzpfx45lyzlha7jyu7mjwwelk5p9rkyg6sv5we
static immutable AUT = KeyPair(PublicKey(Point([193, 73, 235, 64, 85, 238, 180, 171, 142, 141, 134, 151, 24, 65, 73, 171, 79, 144, 95, 191, 125, 34, 115, 219, 147, 157, 159, 218, 129, 40, 236, 68])), SecretKey(Scalar([106, 184, 7, 14, 224, 51, 4, 21, 59, 144, 234, 68, 154, 102, 238, 1, 238, 15, 241, 121, 41, 29, 16, 62, 91, 195, 160, 44, 68, 107, 213, 9])));
/// AUU("gdauu"): gdauu1xrq5566sfv94kecrsy8q3xgxthp24c7lhgjw5klp26a49qgs7r686tw7lp4
static immutable AUU = KeyPair(PublicKey(Point([193, 74, 107, 80, 75, 11, 91, 103, 3, 129, 14, 8, 153, 6, 93, 194, 170, 227, 223, 186, 36, 234, 91, 225, 86, 187, 82, 129, 16, 240, 244, 125])), SecretKey(Scalar([33, 240, 220, 2, 233, 76, 84, 42, 10, 150, 134, 193, 192, 253, 30, 87, 247, 107, 224, 158, 23, 128, 69, 112, 183, 11, 187, 127, 10, 221, 59, 3])));
/// AUV("gdauv"): gdauv1xrq5466lg5a0754d76jgepxwazvdur8w5xaq532cdgffny8d9vpj6qgd4p0
static immutable AUV = KeyPair(PublicKey(Point([193, 74, 235, 95, 69, 58, 255, 82, 173, 246, 164, 140, 132, 206, 232, 152, 222, 12, 238, 161, 186, 10, 69, 88, 106, 18, 153, 144, 237, 43, 3, 45])), SecretKey(Scalar([187, 10, 89, 220, 217, 84, 200, 134, 9, 134, 232, 87, 79, 195, 169, 75, 46, 138, 217, 53, 156, 206, 165, 8, 203, 81, 2, 185, 73, 108, 26, 2])));
/// AUW("gdauw"): gdauw1xrq5k66hkz3gc3gmhguez972glv5mj84q7tcu70s0unffc7ghqqgvkn7zva
static immutable AUW = KeyPair(PublicKey(Point([193, 75, 107, 87, 176, 162, 140, 69, 27, 186, 57, 145, 23, 202, 71, 217, 77, 200, 245, 7, 151, 142, 121, 240, 127, 38, 148, 227, 200, 184, 0, 134])), SecretKey(Scalar([198, 116, 194, 243, 175, 250, 234, 64, 17, 169, 156, 253, 14, 117, 63, 224, 3, 50, 55, 200, 197, 3, 111, 163, 118, 180, 67, 130, 14, 227, 74, 6])));
/// AUX("gdaux"): gdaux1xrq5h66vdd7c5km0v6gtr5yfcltlu4xrh3all8hashcejykdr2y7sc9sxy9
static immutable AUX = KeyPair(PublicKey(Point([193, 75, 235, 76, 107, 125, 138, 91, 111, 102, 144, 177, 208, 137, 199, 215, 254, 84, 195, 188, 123, 255, 158, 253, 133, 241, 153, 18, 205, 26, 137, 232])), SecretKey(Scalar([42, 11, 13, 117, 182, 63, 165, 64, 142, 91, 21, 66, 155, 167, 110, 161, 185, 23, 42, 224, 213, 102, 175, 86, 111, 153, 191, 16, 136, 135, 210, 5])));
/// AUY("gdauy"): gdauy1xrq5c66fmkytgrgsl2zwc3rp4k2ngd8uuq2krphya6hx7ncy0redq2pxpha
static immutable AUY = KeyPair(PublicKey(Point([193, 76, 107, 73, 221, 136, 180, 13, 16, 250, 132, 236, 68, 97, 173, 149, 52, 52, 252, 224, 21, 97, 134, 228, 238, 174, 111, 79, 4, 120, 242, 208])), SecretKey(Scalar([166, 89, 247, 123, 107, 232, 92, 200, 173, 19, 6, 253, 157, 164, 254, 237, 86, 206, 221, 140, 224, 8, 183, 110, 173, 38, 67, 21, 244, 35, 243, 7])));
/// AUZ("gdauz"): gdauz1xrq5e66d5rqwm9zy22k4wmrsn0scg42xjqmvv0c3n86cum0llgzj5zfaukk
static immutable AUZ = KeyPair(PublicKey(Point([193, 76, 235, 77, 160, 192, 237, 148, 68, 82, 173, 87, 108, 112, 155, 225, 132, 85, 70, 144, 54, 198, 63, 17, 153, 245, 142, 109, 255, 250, 5, 42])), SecretKey(Scalar([64, 52, 28, 64, 54, 187, 178, 30, 2, 111, 83, 52, 186, 103, 17, 40, 78, 213, 175, 93, 39, 16, 105, 182, 62, 227, 247, 188, 92, 7, 99, 12])));
/// AVA("gdava"): gdava1xrq4q66xq37gk09cfy6jpplapr9mqf8zdrpygxuzae6cxsvf2lcwcd5384l
static immutable AVA = KeyPair(PublicKey(Point([193, 80, 107, 70, 4, 124, 139, 60, 184, 73, 53, 32, 135, 253, 8, 203, 176, 36, 226, 104, 194, 68, 27, 130, 238, 117, 131, 65, 137, 87, 240, 236])), SecretKey(Scalar([179, 46, 99, 75, 54, 151, 213, 79, 79, 211, 120, 174, 0, 64, 122, 36, 4, 196, 199, 116, 206, 8, 79, 148, 147, 228, 99, 158, 57, 222, 68, 15])));
/// AVB("gdavb"): gdavb1xrq4p66m63msrzzs7vzxccmczyw0yqmyhrv4zcstefflxyme0wuavvnex4w
static immutable AVB = KeyPair(PublicKey(Point([193, 80, 235, 91, 212, 119, 1, 136, 80, 243, 4, 108, 99, 120, 17, 28, 242, 3, 100, 184, 217, 81, 98, 11, 202, 83, 243, 19, 121, 123, 185, 214])), SecretKey(Scalar([186, 41, 218, 236, 138, 128, 157, 55, 250, 127, 96, 157, 3, 244, 248, 63, 208, 240, 242, 94, 226, 18, 39, 72, 95, 105, 41, 183, 182, 230, 193, 5])));
/// AVC("gdavc"): gdavc1xrq4z665f39c9dkcw5p8245crueu29l9kswtfzptgyfqxxcmc6yy22tdhlj
static immutable AVC = KeyPair(PublicKey(Point([193, 81, 107, 84, 76, 75, 130, 182, 216, 117, 2, 117, 86, 152, 31, 51, 197, 23, 229, 180, 28, 180, 136, 43, 65, 18, 3, 27, 27, 198, 136, 69])), SecretKey(Scalar([183, 240, 54, 109, 81, 65, 226, 112, 4, 104, 146, 137, 81, 140, 200, 95, 77, 101, 128, 142, 109, 80, 41, 30, 242, 240, 37, 234, 1, 170, 230, 7])));
/// AVD("gdavd"): gdavd1xrq4r6672zvz0ymr03s200fx4u74eqvrw7xhlp77hq6vms5gklpw6evc4gg
static immutable AVD = KeyPair(PublicKey(Point([193, 81, 235, 94, 80, 152, 39, 147, 99, 124, 96, 167, 189, 38, 175, 61, 92, 129, 131, 119, 141, 127, 135, 222, 184, 52, 205, 194, 136, 183, 194, 237])), SecretKey(Scalar([193, 113, 245, 231, 205, 15, 237, 96, 111, 141, 107, 107, 236, 240, 103, 17, 163, 47, 101, 76, 6, 210, 46, 147, 74, 89, 16, 156, 30, 4, 212, 15])));
/// AVE("gdave"): gdave1xrq4y664maka3hewu8uzajmfvv4pnp2a6srguz9z8sqjlrtla7mhcchfvgq
static immutable AVE = KeyPair(PublicKey(Point([193, 82, 107, 85, 223, 109, 216, 223, 46, 225, 248, 46, 203, 105, 99, 42, 25, 133, 93, 212, 6, 142, 8, 162, 60, 1, 47, 141, 127, 239, 183, 124])), SecretKey(Scalar([145, 83, 62, 210, 26, 63, 177, 129, 225, 161, 252, 227, 95, 78, 2, 223, 176, 185, 137, 203, 195, 215, 195, 156, 183, 57, 182, 202, 26, 161, 148, 1])));
/// AVF("gdavf"): gdavf1xrq4966uhp4e3ewht7lrjgve2qlm8jzjf7y8e29ml7zuks5pzacak7xd9d4
static immutable AVF = KeyPair(PublicKey(Point([193, 82, 235, 92, 184, 107, 152, 229, 215, 95, 190, 57, 33, 153, 80, 63, 179, 200, 82, 79, 136, 124, 168, 187, 255, 133, 203, 66, 129, 23, 113, 219])), SecretKey(Scalar([167, 205, 182, 61, 108, 221, 66, 200, 225, 141, 213, 234, 99, 99, 86, 209, 53, 205, 230, 21, 121, 226, 197, 224, 111, 77, 196, 199, 105, 183, 159, 5])));
/// AVG("gdavg"): gdavg1xrq4x66sh2vquae2rrmmh582hjaz5w3kesx6c0svqv98pffa2yh0wrs55sw
static immutable AVG = KeyPair(PublicKey(Point([193, 83, 107, 80, 186, 152, 14, 119, 42, 24, 247, 187, 208, 234, 188, 186, 42, 58, 54, 204, 13, 172, 62, 12, 3, 10, 112, 165, 61, 81, 46, 247])), SecretKey(Scalar([144, 33, 48, 67, 204, 126, 66, 140, 49, 168, 98, 16, 179, 152, 243, 145, 81, 64, 247, 146, 78, 135, 86, 92, 104, 251, 100, 170, 107, 123, 102, 10])));
/// AVH("gdavh"): gdavh1xrq4866s7hjqmqk48k3ej2v48d43xjq0yjsxvc0uqd9cj4glef6yqqehr2j
static immutable AVH = KeyPair(PublicKey(Point([193, 83, 235, 80, 245, 228, 13, 130, 213, 61, 163, 153, 41, 149, 59, 107, 19, 72, 15, 36, 160, 102, 97, 252, 3, 75, 137, 85, 31, 202, 116, 64])), SecretKey(Scalar([229, 106, 248, 183, 118, 69, 253, 11, 173, 109, 213, 108, 110, 30, 45, 168, 85, 222, 81, 97, 241, 254, 75, 136, 53, 52, 163, 189, 204, 82, 235, 7])));
/// AVI("gdavi"): gdavi1xrq4g66xz8dkryxearpg8p54jmzl0qfsgk06pm39mt520e3rk0vx74mx0fn
static immutable AVI = KeyPair(PublicKey(Point([193, 84, 107, 70, 17, 219, 97, 144, 217, 232, 194, 131, 134, 149, 150, 197, 247, 129, 48, 69, 159, 160, 238, 37, 218, 232, 167, 230, 35, 179, 216, 111])), SecretKey(Scalar([209, 227, 242, 50, 172, 60, 103, 63, 9, 137, 78, 29, 252, 167, 150, 197, 105, 12, 100, 116, 145, 4, 110, 106, 27, 119, 122, 156, 130, 15, 184, 8])));
/// AVJ("gdavj"): gdavj1xrq4f666p5aa74dhpfaag73kfugkd67v8jusf8qcw62jz7eg88ekj6tn2mz
static immutable AVJ = KeyPair(PublicKey(Point([193, 84, 235, 90, 13, 59, 223, 85, 183, 10, 123, 212, 122, 54, 79, 17, 102, 235, 204, 60, 185, 4, 156, 24, 118, 149, 33, 123, 40, 57, 243, 105])), SecretKey(Scalar([103, 184, 110, 175, 116, 180, 90, 45, 118, 147, 62, 233, 19, 220, 95, 85, 146, 62, 107, 108, 32, 170, 16, 44, 48, 133, 29, 213, 225, 48, 134, 5])));
/// AVK("gdavk"): gdavk1xrq4266kkkzur2qmma0ahu9cvzrlwvd7lc9fgcgja2tsu6art3eqgmh3da4
static immutable AVK = KeyPair(PublicKey(Point([193, 85, 107, 86, 181, 133, 193, 168, 27, 223, 95, 219, 240, 184, 96, 135, 247, 49, 190, 254, 10, 148, 97, 18, 234, 151, 14, 107, 163, 92, 114, 4])), SecretKey(Scalar([43, 41, 252, 75, 43, 220, 5, 225, 47, 223, 11, 32, 69, 124, 156, 105, 115, 42, 135, 172, 209, 23, 130, 255, 155, 48, 49, 5, 234, 205, 253, 12])));
/// AVL("gdavl"): gdavl1xrq4t6647clp4dkyuaffgd4fm6z4vfq8w6ch00pknnuy8zp2vjse2nqlt42
static immutable AVL = KeyPair(PublicKey(Point([193, 85, 235, 85, 246, 62, 26, 182, 196, 231, 82, 148, 54, 169, 222, 133, 86, 36, 7, 118, 177, 119, 188, 54, 156, 248, 67, 136, 42, 100, 161, 149])), SecretKey(Scalar([167, 161, 54, 92, 33, 174, 23, 237, 166, 245, 168, 138, 112, 128, 167, 103, 122, 84, 237, 159, 127, 248, 70, 74, 184, 41, 233, 147, 211, 20, 30, 14])));
/// AVM("gdavm"): gdavm1xrq4v66cv6yzkg8f38lys6vung8n0tynrs7v4x487rl4kmhxc87gxafunxz
static immutable AVM = KeyPair(PublicKey(Point([193, 86, 107, 88, 102, 136, 43, 32, 233, 137, 254, 72, 105, 156, 154, 15, 55, 172, 147, 28, 60, 202, 154, 167, 240, 255, 91, 110, 230, 193, 252, 131])), SecretKey(Scalar([119, 140, 41, 88, 162, 93, 221, 209, 186, 150, 227, 90, 25, 251, 88, 63, 218, 77, 113, 182, 181, 231, 157, 16, 9, 218, 43, 30, 65, 190, 44, 15])));
/// AVN("gdavn"): gdavn1xrq4d662ql5gxrzu8varuq5f8rhkgxnxea0f48lfpxtayhhnjjz0c9tur6z
static immutable AVN = KeyPair(PublicKey(Point([193, 86, 235, 74, 7, 232, 131, 12, 92, 59, 58, 62, 2, 137, 56, 239, 100, 26, 102, 207, 94, 154, 159, 233, 9, 151, 210, 94, 243, 148, 132, 252])), SecretKey(Scalar([98, 185, 123, 160, 182, 217, 121, 75, 89, 90, 78, 108, 100, 57, 152, 84, 116, 246, 237, 43, 54, 104, 126, 64, 3, 164, 141, 50, 197, 48, 244, 13])));
/// AVO("gdavo"): gdavo1xrq4w66eycsyu4npavu769kz5nnrnxedq4qequ33kex8fcw3c8tzxyv0k0u
static immutable AVO = KeyPair(PublicKey(Point([193, 87, 107, 89, 38, 32, 78, 86, 97, 235, 57, 237, 22, 194, 164, 230, 57, 155, 45, 5, 65, 144, 114, 49, 182, 76, 116, 225, 209, 193, 214, 35])), SecretKey(Scalar([247, 233, 110, 239, 46, 180, 23, 116, 235, 213, 210, 79, 49, 83, 135, 27, 168, 174, 132, 197, 83, 168, 39, 191, 53, 157, 33, 213, 175, 225, 74, 7])));
/// AVP("gdavp"): gdavp1xrq4066czehv0wwp3kpwmru2fx7sury4wlq2ccysqrx8anetyhzru5m5kzt
static immutable AVP = KeyPair(PublicKey(Point([193, 87, 235, 88, 22, 110, 199, 185, 193, 141, 130, 237, 143, 138, 73, 189, 14, 12, 149, 119, 192, 172, 96, 144, 0, 204, 126, 207, 43, 37, 196, 62])), SecretKey(Scalar([122, 4, 184, 254, 111, 22, 145, 252, 186, 30, 126, 215, 90, 49, 2, 25, 94, 242, 211, 2, 174, 229, 84, 171, 250, 182, 171, 219, 154, 137, 15, 3])));
/// AVQ("gdavq"): gdavq1xrq4s66nnmp6gujckfl8scy8zr5vv9srehfnc4mdvgy8ges2tlp6uvy859a
static immutable AVQ = KeyPair(PublicKey(Point([193, 88, 107, 83, 158, 195, 164, 114, 88, 178, 126, 120, 96, 135, 16, 232, 198, 22, 3, 205, 211, 60, 87, 109, 98, 8, 116, 102, 10, 95, 195, 174])), SecretKey(Scalar([222, 171, 109, 139, 181, 79, 143, 26, 146, 219, 2, 203, 183, 83, 254, 178, 35, 123, 148, 23, 3, 69, 57, 40, 47, 205, 63, 246, 69, 160, 211, 12])));
/// AVR("gdavr"): gdavr1xrq43669kmcechke9th9jcy7y6lryhl4vyz56aaumqey9wyrjjgc73q4rqw
static immutable AVR = KeyPair(PublicKey(Point([193, 88, 235, 69, 182, 241, 156, 94, 217, 42, 238, 89, 96, 158, 38, 190, 50, 95, 245, 97, 5, 77, 119, 188, 216, 50, 66, 184, 131, 148, 145, 143])), SecretKey(Scalar([33, 252, 155, 194, 5, 195, 202, 142, 132, 205, 15, 168, 193, 125, 46, 155, 255, 206, 108, 21, 9, 134, 35, 242, 89, 74, 148, 14, 168, 59, 86, 4])));
/// AVS("gdavs"): gdavs1xrq4j66pus9wzwexks9j9ty8pen7g95pdr02tgew33x28wk6jq8t5mm0k9n
static immutable AVS = KeyPair(PublicKey(Point([193, 89, 107, 65, 228, 10, 225, 59, 38, 180, 11, 34, 172, 135, 14, 103, 228, 22, 129, 104, 222, 165, 163, 46, 140, 76, 163, 186, 218, 144, 14, 186])), SecretKey(Scalar([71, 3, 84, 81, 198, 24, 17, 156, 140, 27, 211, 123, 84, 66, 68, 36, 32, 15, 225, 25, 82, 179, 68, 137, 120, 89, 183, 58, 242, 230, 62, 15])));
/// AVT("gdavt"): gdavt1xrq4n66z2w505scv8d9t2fvt7968kpu87up7l2q95x2wayhphyqps527kww
static immutable AVT = KeyPair(PublicKey(Point([193, 89, 235, 66, 83, 168, 250, 67, 12, 59, 74, 181, 37, 139, 241, 116, 123, 7, 135, 247, 3, 239, 168, 5, 161, 148, 238, 146, 225, 185, 0, 24])), SecretKey(Scalar([165, 52, 98, 175, 29, 111, 202, 144, 72, 139, 224, 143, 241, 190, 146, 33, 161, 104, 3, 198, 110, 191, 79, 156, 182, 45, 242, 158, 244, 110, 211, 3])));
/// AVU("gdavu"): gdavu1xrq4566p8ekgp29nltk2g09smpk8rwyxegp97tzmh9zp8492em6tgyhpxst
static immutable AVU = KeyPair(PublicKey(Point([193, 90, 107, 65, 62, 108, 128, 168, 179, 250, 236, 164, 60, 176, 216, 108, 113, 184, 134, 202, 2, 95, 44, 91, 185, 68, 19, 212, 170, 206, 244, 180])), SecretKey(Scalar([28, 25, 109, 134, 221, 234, 85, 85, 178, 98, 247, 208, 45, 203, 142, 176, 141, 106, 89, 97, 140, 208, 225, 29, 55, 252, 215, 32, 55, 102, 32, 8])));
/// AVV("gdavv"): gdavv1xrq4466cshka03fu269nkv0wvs9qrkxqhtccdj49ye5y8uahrcny5hfjks6
static immutable AVV = KeyPair(PublicKey(Point([193, 90, 235, 88, 133, 237, 215, 197, 60, 86, 139, 59, 49, 238, 100, 10, 1, 216, 192, 186, 241, 134, 202, 165, 38, 104, 67, 243, 183, 30, 38, 74])), SecretKey(Scalar([71, 248, 93, 22, 182, 146, 203, 141, 141, 213, 106, 43, 37, 174, 124, 180, 115, 124, 253, 12, 58, 184, 40, 235, 74, 240, 211, 107, 106, 202, 115, 13])));
/// AVW("gdavw"): gdavw1xrq4k66gl20kx6ztppleh4uz3rlrce55sfqpwgqd2flqe7fvstamuqn2y95
static immutable AVW = KeyPair(PublicKey(Point([193, 91, 107, 72, 250, 159, 99, 104, 75, 8, 127, 155, 215, 130, 136, 254, 60, 102, 148, 130, 64, 23, 32, 13, 82, 126, 12, 249, 44, 130, 251, 190])), SecretKey(Scalar([127, 196, 7, 204, 117, 252, 241, 191, 58, 236, 151, 185, 247, 139, 196, 44, 237, 234, 83, 149, 111, 219, 251, 72, 126, 86, 227, 219, 40, 178, 83, 14])));
/// AVX("gdavx"): gdavx1xrq4h662f63s5kga0hxz80jm5frt04xyvkwpatrg0wkpswrrjck8v7pk7p4
static immutable AVX = KeyPair(PublicKey(Point([193, 91, 235, 74, 78, 163, 10, 89, 29, 125, 204, 35, 190, 91, 162, 70, 183, 212, 196, 101, 156, 30, 172, 104, 123, 172, 24, 56, 99, 150, 44, 118])), SecretKey(Scalar([132, 251, 176, 57, 181, 133, 18, 71, 94, 183, 29, 248, 115, 223, 38, 38, 108, 61, 189, 80, 76, 237, 232, 238, 41, 59, 135, 49, 65, 52, 160, 10])));
/// AVY("gdavy"): gdavy1xrq4c667fjvssczw42n3mx4sakmx5wnlv9sxpvjq6pxw233ek9qnqsul3v2
static immutable AVY = KeyPair(PublicKey(Point([193, 92, 107, 94, 76, 153, 8, 96, 78, 170, 167, 29, 154, 176, 237, 182, 106, 58, 127, 97, 96, 96, 178, 64, 208, 76, 229, 70, 57, 177, 65, 48])), SecretKey(Scalar([215, 8, 76, 253, 236, 94, 157, 148, 61, 248, 130, 160, 223, 54, 30, 49, 171, 83, 231, 139, 179, 61, 217, 233, 214, 4, 193, 190, 241, 222, 107, 5])));
/// AVZ("gdavz"): gdavz1xrq4e66dlw80msxcgh80xpsfys7t2d2hftdmpv339t7tnr3kxsh32cdwusl
static immutable AVZ = KeyPair(PublicKey(Point([193, 92, 235, 77, 251, 142, 253, 192, 216, 69, 206, 243, 6, 9, 36, 60, 181, 53, 87, 74, 219, 176, 178, 49, 42, 252, 185, 142, 54, 52, 47, 21])), SecretKey(Scalar([9, 212, 250, 77, 164, 65, 195, 28, 202, 91, 56, 136, 197, 197, 2, 117, 55, 3, 133, 160, 113, 69, 64, 91, 229, 85, 187, 112, 146, 131, 91, 8])));
/// AWA("gdawa"): gdawa1xrqkq66kj6lzw7cgvdytvrprvu53s49vhpp283ffvjk9qfdsdqqsclerx0f
static immutable AWA = KeyPair(PublicKey(Point([193, 96, 107, 86, 150, 190, 39, 123, 8, 99, 72, 182, 12, 35, 103, 41, 24, 84, 172, 184, 66, 163, 197, 41, 100, 172, 80, 37, 176, 104, 1, 12])), SecretKey(Scalar([135, 67, 114, 179, 203, 15, 167, 123, 10, 19, 83, 164, 126, 54, 237, 45, 159, 83, 174, 3, 21, 49, 80, 200, 201, 86, 194, 196, 143, 51, 234, 9])));
/// AWB("gdawb"): gdawb1xrqkp660a0jx5wf3vsaz5mqx5fddhfxxt3xt37u7cdadyksyxw4msqalqdq
static immutable AWB = KeyPair(PublicKey(Point([193, 96, 235, 79, 235, 228, 106, 57, 49, 100, 58, 42, 108, 6, 162, 90, 219, 164, 198, 92, 76, 184, 251, 158, 195, 122, 210, 90, 4, 51, 171, 184])), SecretKey(Scalar([243, 80, 132, 59, 55, 111, 150, 80, 190, 73, 12, 120, 110, 86, 143, 202, 13, 54, 0, 64, 216, 228, 69, 132, 157, 47, 52, 212, 168, 144, 168, 10])));
/// AWC("gdawc"): gdawc1xrqkz66svshq9q5darut3zkysrkjvhhjcgntkk39t82mv9sapnf2y42jy50
static immutable AWC = KeyPair(PublicKey(Point([193, 97, 107, 80, 100, 46, 2, 130, 141, 232, 248, 184, 138, 196, 128, 237, 38, 94, 242, 194, 38, 187, 90, 37, 89, 213, 182, 22, 29, 12, 210, 162])), SecretKey(Scalar([249, 168, 98, 119, 255, 157, 30, 175, 237, 30, 224, 173, 143, 244, 230, 205, 39, 59, 63, 236, 247, 119, 247, 102, 229, 255, 24, 110, 237, 124, 238, 9])));
/// AWD("gdawd"): gdawd1xrqkr66yt4arzjf8tjfj97mf90ae9hekd3l79vz8zqny7z54u5equt3htvu
static immutable AWD = KeyPair(PublicKey(Point([193, 97, 235, 68, 93, 122, 49, 73, 39, 92, 147, 34, 251, 105, 43, 251, 146, 223, 54, 108, 127, 226, 176, 71, 16, 38, 79, 10, 149, 229, 50, 14])), SecretKey(Scalar([211, 41, 0, 43, 36, 143, 199, 57, 189, 189, 15, 172, 30, 196, 79, 71, 66, 126, 228, 2, 146, 229, 60, 145, 244, 18, 240, 186, 194, 39, 153, 6])));
/// AWE("gdawe"): gdawe1xrqky665ggudtelagh867frlhq8adj9eqw9urqs70tpcm0j359ydzkayepu
static immutable AWE = KeyPair(PublicKey(Point([193, 98, 107, 84, 66, 56, 213, 231, 253, 69, 207, 175, 36, 127, 184, 15, 214, 200, 185, 3, 139, 193, 130, 30, 122, 195, 141, 190, 81, 161, 72, 209])), SecretKey(Scalar([213, 189, 217, 175, 25, 89, 233, 242, 60, 131, 138, 240, 17, 149, 220, 35, 181, 198, 74, 186, 184, 224, 67, 249, 150, 247, 130, 196, 26, 208, 199, 0])));
/// AWF("gdawf"): gdawf1xrqk96660cwqkqpyhnmrdvzzrpchurjq5pfag90yth8dd3fp92rtzy8hmpm
static immutable AWF = KeyPair(PublicKey(Point([193, 98, 235, 90, 126, 28, 11, 0, 36, 188, 246, 54, 176, 66, 24, 113, 126, 14, 64, 160, 83, 212, 21, 228, 93, 206, 214, 197, 33, 42, 134, 177])), SecretKey(Scalar([220, 147, 59, 194, 160, 174, 138, 181, 237, 160, 200, 73, 43, 105, 217, 111, 41, 146, 37, 251, 53, 201, 197, 128, 227, 82, 42, 146, 110, 149, 164, 3])));
/// AWG("gdawg"): gdawg1xrqkx6670g0dksyumn4emamzrsjq9fp36r6caqrt2n8e4lwanp4rvf0qea4
static immutable AWG = KeyPair(PublicKey(Point([193, 99, 107, 94, 122, 30, 219, 64, 156, 220, 235, 157, 247, 98, 28, 36, 2, 164, 49, 208, 245, 142, 128, 107, 84, 207, 154, 253, 221, 152, 106, 54])), SecretKey(Scalar([12, 32, 148, 14, 232, 54, 199, 169, 74, 70, 144, 110, 132, 87, 238, 181, 84, 60, 140, 123, 174, 35, 22, 35, 64, 223, 102, 141, 59, 101, 192, 13])));
/// AWH("gdawh"): gdawh1xrqk8665vm0vsjl0wfxyhf3sqygfx5t2q24r5df57jpx6v9glkmrkc06fuc
static immutable AWH = KeyPair(PublicKey(Point([193, 99, 235, 84, 102, 222, 200, 75, 239, 114, 76, 75, 166, 48, 1, 16, 147, 81, 106, 2, 170, 58, 53, 52, 244, 130, 109, 48, 168, 253, 182, 59])), SecretKey(Scalar([42, 247, 230, 101, 221, 238, 87, 14, 76, 62, 125, 164, 204, 17, 120, 204, 241, 68, 160, 255, 230, 193, 4, 11, 176, 183, 33, 245, 203, 201, 241, 11])));
/// AWI("gdawi"): gdawi1xrqkg66kq3u6k7sduuyf43lfuvvz99cuyf3h057pxx24lrpzsygpx06x7xw
static immutable AWI = KeyPair(PublicKey(Point([193, 100, 107, 86, 4, 121, 171, 122, 13, 231, 8, 154, 199, 233, 227, 24, 34, 151, 28, 34, 99, 119, 211, 193, 49, 149, 95, 140, 34, 129, 16, 19])), SecretKey(Scalar([34, 26, 232, 80, 219, 47, 6, 229, 180, 79, 187, 26, 151, 48, 132, 226, 18, 110, 89, 92, 178, 44, 82, 53, 89, 2, 114, 210, 171, 45, 132, 8])));
/// AWJ("gdawj"): gdawj1xrqkf66ul9ws2xsja65hgu3dak6tfx34202v98xq60n0frnkjyn7wnj3e9g
static immutable AWJ = KeyPair(PublicKey(Point([193, 100, 235, 92, 249, 93, 5, 26, 18, 238, 169, 116, 114, 45, 237, 180, 180, 154, 53, 83, 212, 194, 156, 192, 211, 230, 244, 142, 118, 145, 39, 231])), SecretKey(Scalar([15, 77, 32, 226, 163, 219, 0, 157, 4, 191, 18, 216, 45, 144, 31, 136, 241, 92, 180, 74, 184, 36, 204, 254, 137, 121, 194, 221, 187, 70, 54, 14])));
/// AWK("gdawk"): gdawk1xrqk266nghydc6kj2229zme3xmj2s5llsrpwxdxfl0sl5x23xap3q4p22nd
static immutable AWK = KeyPair(PublicKey(Point([193, 101, 107, 83, 69, 200, 220, 106, 210, 82, 148, 81, 111, 49, 54, 228, 168, 83, 255, 128, 194, 227, 52, 201, 251, 225, 250, 25, 81, 55, 67, 16])), SecretKey(Scalar([89, 61, 115, 115, 51, 243, 145, 19, 188, 50, 52, 117, 109, 8, 107, 113, 41, 115, 43, 161, 32, 1, 69, 211, 135, 0, 48, 29, 60, 5, 94, 5])));
/// AWL("gdawl"): gdawl1xrqkt66y0epalsgvukepvy9lq28nzpck46wgzjat6g9wak3rywcrxsc5uxk
static immutable AWL = KeyPair(PublicKey(Point([193, 101, 235, 68, 126, 67, 223, 193, 12, 229, 178, 22, 16, 191, 2, 143, 49, 7, 22, 174, 156, 129, 75, 171, 210, 10, 238, 218, 35, 35, 176, 51])), SecretKey(Scalar([37, 33, 204, 23, 55, 101, 38, 34, 193, 13, 210, 196, 57, 151, 168, 17, 29, 31, 95, 200, 245, 73, 191, 228, 101, 237, 177, 218, 19, 246, 219, 14])));
/// AWM("gdawm"): gdawm1xrqkv66r4d4px0fzjtx0g6jeafd24w86wrqhg0ldxv0hze06h6j274kxcm7
static immutable AWM = KeyPair(PublicKey(Point([193, 102, 107, 67, 171, 106, 19, 61, 34, 146, 204, 244, 106, 89, 234, 90, 170, 184, 250, 112, 193, 116, 63, 237, 51, 31, 113, 101, 250, 190, 164, 175])), SecretKey(Scalar([25, 109, 138, 51, 35, 254, 61, 17, 182, 120, 240, 198, 3, 126, 156, 136, 213, 81, 219, 156, 85, 197, 121, 252, 146, 112, 153, 28, 208, 21, 42, 3])));
/// AWN("gdawn"): gdawn1xrqkd6603rpc8tzwsfzfrp0jtp4x4knnyf70e3agz3zaxyueq78rwxpmgsf
static immutable AWN = KeyPair(PublicKey(Point([193, 102, 235, 79, 136, 195, 131, 172, 78, 130, 68, 145, 133, 242, 88, 106, 106, 218, 115, 34, 124, 252, 199, 168, 20, 69, 211, 19, 153, 7, 142, 55])), SecretKey(Scalar([234, 199, 249, 123, 133, 54, 99, 56, 221, 99, 234, 148, 137, 76, 160, 120, 65, 190, 70, 61, 40, 159, 252, 39, 25, 182, 50, 3, 185, 200, 150, 10])));
/// AWO("gdawo"): gdawo1xrqkw66fdgyl7j8ktlgaavhxpww75pnq7kenp33y7y23vm9hyu985aj2mas
static immutable AWO = KeyPair(PublicKey(Point([193, 103, 107, 73, 106, 9, 255, 72, 246, 95, 209, 222, 178, 230, 11, 157, 234, 6, 96, 245, 179, 48, 198, 36, 241, 21, 22, 108, 183, 39, 10, 122])), SecretKey(Scalar([149, 193, 36, 205, 214, 43, 249, 193, 245, 135, 193, 39, 172, 161, 244, 125, 120, 151, 128, 158, 19, 94, 10, 179, 66, 16, 236, 56, 200, 54, 195, 0])));
/// AWP("gdawp"): gdawp1xrqk066j8eqyffkgz06f85qxnklf6jq6sk4kqcktves832yaklupkljhnqn
static immutable AWP = KeyPair(PublicKey(Point([193, 103, 235, 82, 62, 64, 68, 166, 200, 19, 244, 147, 208, 6, 157, 190, 157, 72, 26, 133, 171, 96, 98, 203, 102, 96, 120, 168, 157, 183, 248, 27])), SecretKey(Scalar([217, 54, 134, 74, 255, 111, 172, 191, 182, 135, 94, 181, 134, 221, 149, 90, 210, 156, 120, 17, 239, 160, 63, 182, 201, 112, 206, 182, 69, 101, 98, 6])));
/// AWQ("gdawq"): gdawq1xrqks66e3upqmg2mjyy4vfxk22fpt2cgjftuupxe7l4zcfjvm8gn5dl4c9n
static immutable AWQ = KeyPair(PublicKey(Point([193, 104, 107, 89, 143, 2, 13, 161, 91, 145, 9, 86, 36, 214, 82, 146, 21, 171, 8, 146, 87, 206, 4, 217, 247, 234, 44, 38, 76, 217, 209, 58])), SecretKey(Scalar([237, 113, 177, 33, 150, 230, 142, 151, 201, 135, 201, 20, 132, 127, 242, 242, 110, 8, 113, 87, 31, 156, 89, 98, 132, 225, 22, 187, 178, 243, 58, 9])));
/// AWR("gdawr"): gdawr1xrqk366e8mvhs4fm3f8hkx4xq9j4cjwfj68y7p89qgec408su9j3xx5jpnk
static immutable AWR = KeyPair(PublicKey(Point([193, 104, 235, 89, 62, 217, 120, 85, 59, 138, 79, 123, 26, 166, 1, 101, 92, 73, 201, 150, 142, 79, 4, 229, 2, 51, 138, 188, 240, 225, 101, 19])), SecretKey(Scalar([232, 208, 173, 105, 35, 15, 117, 72, 112, 142, 204, 50, 185, 129, 64, 222, 11, 96, 133, 207, 226, 162, 39, 156, 103, 24, 223, 253, 50, 84, 162, 5])));
/// AWS("gdaws"): gdaws1xrqkj66h4jd4qt3pk3nv6un0lqaly0dw4lvd4m22rrxjyvdftvd9ctnrn6s
static immutable AWS = KeyPair(PublicKey(Point([193, 105, 107, 87, 172, 155, 80, 46, 33, 180, 102, 205, 114, 111, 248, 59, 242, 61, 174, 175, 216, 218, 237, 74, 24, 205, 34, 49, 169, 91, 26, 92])), SecretKey(Scalar([52, 143, 195, 235, 216, 60, 238, 95, 196, 180, 110, 50, 3, 96, 197, 133, 35, 209, 144, 157, 118, 164, 230, 136, 225, 108, 254, 167, 191, 153, 64, 2])));
/// AWT("gdawt"): gdawt1xrqkn66dpy0tn5fvpt6gq4dzq3x07vghny47m0kpjsyrwnta6xrukjd6h35
static immutable AWT = KeyPair(PublicKey(Point([193, 105, 235, 77, 9, 30, 185, 209, 44, 10, 244, 128, 85, 162, 4, 76, 255, 49, 23, 153, 43, 237, 190, 193, 148, 8, 55, 77, 125, 209, 135, 203])), SecretKey(Scalar([72, 149, 75, 99, 49, 66, 141, 185, 105, 89, 251, 80, 111, 15, 184, 24, 92, 92, 76, 147, 223, 209, 62, 32, 75, 158, 234, 90, 63, 233, 32, 14])));
/// AWU("gdawu"): gdawu1xrqk5662akqqsz9yd4zj5cv5xdax3lv937x46k6ehs7ejc57w9ykkul7cz7
static immutable AWU = KeyPair(PublicKey(Point([193, 106, 107, 74, 237, 128, 8, 8, 164, 109, 69, 42, 97, 148, 51, 122, 104, 253, 133, 143, 141, 93, 91, 89, 188, 61, 153, 98, 158, 113, 73, 107])), SecretKey(Scalar([8, 208, 234, 210, 111, 13, 235, 128, 120, 56, 71, 45, 224, 220, 219, 76, 88, 248, 125, 92, 234, 237, 174, 56, 204, 172, 65, 33, 176, 208, 122, 2])));
/// AWV("gdawv"): gdawv1xrqk466sksxvcxcs0vpjytr9c92r260x6z8ftyvvma09mwf77pg4wfzxlrs
static immutable AWV = KeyPair(PublicKey(Point([193, 106, 235, 80, 180, 12, 204, 27, 16, 123, 3, 34, 44, 101, 193, 84, 53, 105, 230, 208, 142, 149, 145, 140, 223, 94, 93, 185, 62, 240, 81, 87])), SecretKey(Scalar([124, 163, 68, 213, 250, 172, 9, 61, 175, 131, 12, 9, 99, 242, 181, 102, 121, 13, 93, 205, 245, 218, 130, 217, 52, 158, 183, 65, 235, 131, 114, 10])));
/// AWW("gdaww"): gdaww1xrqkk66sxgsg2ke7rtymj547xclz60jg6aykds5t0cxmetx5jlmtzh83muz
static immutable AWW = KeyPair(PublicKey(Point([193, 107, 107, 80, 50, 32, 133, 91, 62, 26, 201, 185, 82, 190, 54, 62, 45, 62, 72, 215, 73, 102, 194, 139, 126, 13, 188, 172, 212, 151, 246, 177])), SecretKey(Scalar([204, 64, 169, 165, 1, 44, 65, 5, 74, 125, 110, 80, 211, 254, 108, 205, 33, 0, 63, 152, 84, 5, 150, 23, 66, 232, 169, 246, 52, 87, 53, 5])));
/// AWX("gdawx"): gdawx1xrqkh66ny7g9mla4ujmww04j7hmg4s40mmuzxn9c6um9r7sq3d8n2f290sz
static immutable AWX = KeyPair(PublicKey(Point([193, 107, 235, 83, 39, 144, 93, 255, 181, 228, 182, 231, 62, 178, 245, 246, 138, 194, 175, 222, 248, 35, 76, 184, 215, 54, 81, 250, 0, 139, 79, 53])), SecretKey(Scalar([90, 195, 251, 215, 153, 102, 11, 58, 65, 84, 195, 16, 201, 213, 67, 56, 182, 72, 193, 232, 59, 78, 138, 52, 215, 86, 138, 252, 0, 91, 124, 14])));
/// AWY("gdawy"): gdawy1xrqkc66z7al3nt4j4nus6gnp7m8t8zpf352gwqd22hau35y9dfhd6h7frae
static immutable AWY = KeyPair(PublicKey(Point([193, 108, 107, 66, 247, 127, 25, 174, 178, 172, 249, 13, 34, 97, 246, 206, 179, 136, 41, 141, 20, 135, 1, 170, 85, 251, 200, 208, 133, 106, 110, 221])), SecretKey(Scalar([200, 171, 252, 136, 132, 175, 250, 112, 187, 98, 143, 139, 67, 238, 131, 112, 118, 20, 11, 206, 209, 83, 41, 98, 252, 244, 38, 250, 188, 111, 100, 15])));
/// AWZ("gdawz"): gdawz1xrqke66733acvj5gjgnm6np7848fmmkhjn0eeje5eh93xjvaus45gar64t4
static immutable AWZ = KeyPair(PublicKey(Point([193, 108, 235, 94, 140, 123, 134, 74, 136, 146, 39, 189, 76, 62, 61, 78, 157, 238, 215, 148, 223, 156, 203, 52, 205, 203, 19, 73, 157, 228, 43, 68])), SecretKey(Scalar([69, 117, 16, 15, 86, 136, 51, 77, 83, 10, 76, 149, 184, 27, 115, 216, 167, 168, 165, 150, 85, 48, 13, 240, 179, 231, 134, 115, 231, 97, 92, 11])));
/// AXA("gdaxa"): gdaxa1xrqhq66hk7uz592y4t764tt7l48jdjxvhz5y8x48u82jnfn5csk3jgf74et
static immutable AXA = KeyPair(PublicKey(Point([193, 112, 107, 87, 183, 184, 42, 21, 68, 170, 253, 170, 173, 126, 253, 79, 38, 200, 204, 184, 168, 67, 154, 167, 225, 213, 41, 166, 116, 196, 45, 25])), SecretKey(Scalar([227, 190, 67, 131, 6, 247, 94, 25, 104, 70, 181, 80, 202, 173, 139, 50, 171, 54, 164, 196, 210, 200, 42, 71, 62, 8, 116, 82, 122, 66, 16, 5])));
/// AXB("gdaxb"): gdaxb1xrqhp66vur4q8u0mjdxf0rrw68qqlyx74pfqqfn60eqtgzeczkq0xprs3jx
static immutable AXB = KeyPair(PublicKey(Point([193, 112, 235, 76, 224, 234, 3, 241, 251, 147, 76, 151, 140, 110, 209, 192, 15, 144, 222, 168, 82, 0, 38, 122, 126, 64, 180, 11, 56, 21, 128, 243])), SecretKey(Scalar([185, 172, 198, 66, 170, 0, 10, 98, 163, 223, 155, 226, 151, 136, 40, 182, 42, 107, 14, 8, 31, 162, 119, 125, 115, 60, 218, 131, 0, 207, 135, 7])));
/// AXC("gdaxc"): gdaxc1xrqhz6604al70pqefq09yxf39plls0twmqzk65kx96sjylgzn72uzzurqxz
static immutable AXC = KeyPair(PublicKey(Point([193, 113, 107, 79, 175, 127, 231, 132, 25, 72, 30, 82, 25, 49, 40, 127, 248, 61, 110, 216, 5, 109, 82, 198, 46, 161, 34, 125, 2, 159, 149, 193])), SecretKey(Scalar([232, 170, 115, 105, 244, 111, 208, 115, 249, 233, 70, 15, 11, 137, 46, 91, 123, 7, 133, 111, 9, 37, 129, 237, 29, 186, 16, 228, 37, 76, 239, 14])));
/// AXD("gdaxd"): gdaxd1xrqhr66xmkyjgqncegnawmgleuef28e65gz82cfjsfs89kfgvpqux9umr9x
static immutable AXD = KeyPair(PublicKey(Point([193, 113, 235, 70, 221, 137, 36, 2, 120, 202, 39, 215, 109, 31, 207, 50, 149, 31, 58, 162, 4, 117, 97, 50, 130, 96, 114, 217, 40, 96, 65, 195])), SecretKey(Scalar([169, 113, 144, 171, 7, 106, 113, 16, 138, 220, 33, 58, 174, 226, 198, 189, 163, 197, 229, 131, 233, 13, 151, 73, 148, 251, 56, 50, 229, 127, 243, 9])));
/// AXE("gdaxe"): gdaxe1xrqhy66359lumwam8727aq4lv57ttqawce4gw03xd5y4qvhef5cw2xtl7yu
static immutable AXE = KeyPair(PublicKey(Point([193, 114, 107, 81, 161, 127, 205, 187, 187, 63, 149, 238, 130, 191, 101, 60, 181, 131, 174, 198, 106, 135, 62, 38, 109, 9, 80, 50, 249, 77, 48, 229])), SecretKey(Scalar([0, 6, 82, 171, 125, 45, 145, 160, 45, 37, 31, 30, 47, 62, 149, 115, 162, 202, 107, 136, 156, 131, 232, 210, 0, 172, 143, 75, 138, 29, 151, 7])));
/// AXF("gdaxf"): gdaxf1xrqh9667wgtluug67t9jnahmvczezqfnd4wa8mg55jmave09fee3kszc7lt
static immutable AXF = KeyPair(PublicKey(Point([193, 114, 235, 94, 114, 23, 254, 113, 26, 242, 203, 41, 246, 251, 102, 5, 145, 1, 51, 109, 93, 211, 237, 20, 164, 183, 214, 101, 229, 78, 115, 27])), SecretKey(Scalar([39, 243, 22, 24, 240, 246, 198, 28, 85, 43, 250, 106, 247, 90, 68, 96, 145, 200, 240, 47, 172, 249, 238, 93, 242, 100, 29, 207, 114, 215, 207, 10])));
/// AXG("gdaxg"): gdaxg1xrqhx66vx0u4na7hxv5sdfv3ak8kfa6ps46cfppjmp0f8ytf6dzq6q64px3
static immutable AXG = KeyPair(PublicKey(Point([193, 115, 107, 76, 51, 249, 89, 247, 215, 51, 41, 6, 165, 145, 237, 143, 100, 247, 65, 133, 117, 132, 132, 50, 216, 94, 147, 145, 105, 211, 68, 13])), SecretKey(Scalar([202, 67, 229, 189, 192, 236, 125, 244, 102, 229, 188, 155, 76, 49, 20, 8, 28, 26, 133, 233, 101, 170, 31, 240, 8, 177, 140, 196, 206, 114, 152, 14])));
/// AXH("gdaxh"): gdaxh1xrqh866wh37uem5dqm43n63nnddq34htxk4m9gwnv458hy689m5xjaareur
static immutable AXH = KeyPair(PublicKey(Point([193, 115, 235, 78, 188, 125, 204, 238, 141, 6, 235, 25, 234, 51, 155, 90, 8, 214, 235, 53, 171, 178, 161, 211, 101, 104, 123, 147, 71, 46, 232, 105])), SecretKey(Scalar([196, 139, 165, 64, 255, 202, 20, 116, 79, 85, 63, 224, 210, 230, 24, 137, 216, 67, 122, 253, 46, 123, 74, 134, 100, 62, 119, 7, 182, 146, 138, 15])));
/// AXI("gdaxi"): gdaxi1xrqhg66y2t8ahsnanle59vh52ncmjx235vercckwlq3snwmpsgtjsqjwqpu
static immutable AXI = KeyPair(PublicKey(Point([193, 116, 107, 68, 82, 207, 219, 194, 125, 159, 243, 66, 178, 244, 84, 241, 185, 25, 81, 163, 50, 60, 98, 206, 248, 35, 9, 187, 97, 130, 23, 40])), SecretKey(Scalar([116, 146, 0, 81, 107, 152, 21, 24, 189, 16, 125, 10, 160, 15, 238, 187, 149, 229, 172, 89, 158, 131, 183, 198, 135, 94, 107, 131, 88, 159, 71, 5])));
/// AXJ("gdaxj"): gdaxj1xrqhf66gjdrgmc57lr8nedes2q73epmlzp4scfktxm46tf67vqrwx4mdgrs
static immutable AXJ = KeyPair(PublicKey(Point([193, 116, 235, 72, 147, 70, 141, 226, 158, 248, 207, 60, 183, 48, 80, 61, 28, 135, 127, 16, 107, 12, 38, 203, 54, 235, 165, 167, 94, 96, 6, 227])), SecretKey(Scalar([32, 241, 242, 27, 238, 155, 162, 248, 97, 89, 80, 159, 156, 92, 75, 55, 243, 216, 97, 236, 155, 35, 134, 127, 20, 14, 115, 68, 49, 153, 118, 6])));
/// AXK("gdaxk"): gdaxk1xrqh266sxxpywyy0rfwrnmsswcn3pluknry93ejnw96a37k0h08nu2tpztg
static immutable AXK = KeyPair(PublicKey(Point([193, 117, 107, 80, 49, 130, 71, 16, 143, 26, 92, 57, 238, 16, 118, 39, 16, 255, 150, 152, 200, 88, 230, 83, 113, 117, 216, 250, 207, 187, 207, 62])), SecretKey(Scalar([158, 86, 172, 118, 121, 117, 137, 51, 145, 80, 184, 116, 61, 124, 163, 104, 101, 14, 65, 121, 105, 71, 183, 212, 173, 6, 181, 2, 162, 153, 162, 1])));
/// AXL("gdaxl"): gdaxl1xrqht662u9v24q4rfkyxr9gvq3c253r3w2emjc0nxu0e8ter9a3t6duhmev
static immutable AXL = KeyPair(PublicKey(Point([193, 117, 235, 74, 225, 88, 170, 130, 163, 77, 136, 97, 149, 12, 4, 112, 170, 68, 113, 114, 179, 185, 97, 243, 55, 31, 147, 175, 35, 47, 98, 189])), SecretKey(Scalar([36, 243, 217, 203, 233, 151, 231, 126, 125, 41, 18, 35, 68, 6, 129, 118, 225, 159, 164, 151, 7, 234, 9, 33, 24, 153, 140, 172, 14, 253, 9, 10])));
/// AXM("gdaxm"): gdaxm1xrqhv66yf02wdwlg9muxy7fk24glws67su37gd93nn6jajzasxyzwep84u4
static immutable AXM = KeyPair(PublicKey(Point([193, 118, 107, 68, 75, 212, 230, 187, 232, 46, 248, 98, 121, 54, 85, 81, 247, 67, 94, 135, 35, 228, 52, 177, 156, 245, 46, 200, 93, 129, 136, 39])), SecretKey(Scalar([26, 80, 57, 11, 89, 173, 191, 216, 89, 13, 54, 211, 239, 6, 58, 4, 122, 31, 132, 250, 74, 219, 136, 226, 131, 213, 68, 90, 103, 72, 249, 1])));
/// AXN("gdaxn"): gdaxn1xrqhd66wqzlf9jfys748zq5uhwsv6e42vkmm5ry5td73k4p4acducu75phs
static immutable AXN = KeyPair(PublicKey(Point([193, 118, 235, 78, 0, 190, 146, 201, 36, 135, 170, 113, 2, 156, 187, 160, 205, 102, 170, 101, 183, 186, 12, 148, 91, 125, 27, 84, 53, 238, 27, 204])), SecretKey(Scalar([90, 89, 138, 213, 58, 28, 43, 97, 229, 18, 62, 146, 42, 135, 97, 3, 220, 59, 91, 106, 88, 31, 83, 223, 58, 193, 234, 6, 97, 191, 54, 2])));
/// AXO("gdaxo"): gdaxo1xrqhw66pqxmxcqru57nhf9smpsv904sqn7vqp6eau8s4k8lvkpqvsy05l4r
static immutable AXO = KeyPair(PublicKey(Point([193, 119, 107, 65, 1, 182, 108, 0, 124, 167, 167, 116, 150, 27, 12, 24, 87, 214, 0, 159, 152, 0, 235, 61, 225, 225, 91, 31, 236, 176, 64, 200])), SecretKey(Scalar([181, 201, 181, 196, 109, 113, 139, 224, 249, 3, 44, 101, 202, 215, 220, 13, 181, 207, 118, 143, 43, 17, 152, 16, 183, 49, 86, 121, 123, 193, 184, 1])));
/// AXP("gdaxp"): gdaxp1xrqh066jtqvf72l6ewaw8swxxhu9h77r8v45fefrqrvhjcaqglvxvr9ccjq
static immutable AXP = KeyPair(PublicKey(Point([193, 119, 235, 82, 88, 24, 159, 43, 250, 203, 186, 227, 193, 198, 53, 248, 91, 251, 195, 59, 43, 68, 229, 35, 0, 217, 121, 99, 160, 71, 216, 102])), SecretKey(Scalar([65, 22, 130, 137, 172, 85, 225, 65, 145, 190, 202, 176, 229, 9, 191, 150, 155, 6, 26, 18, 84, 50, 150, 94, 26, 178, 223, 212, 165, 192, 73, 10])));
/// AXQ("gdaxq"): gdaxq1xrqhs66qetu3salpkpucz8fejnlmmyn68rz8ka6r998r9ru3l660se6xw7n
static immutable AXQ = KeyPair(PublicKey(Point([193, 120, 107, 64, 202, 249, 24, 119, 225, 176, 121, 129, 29, 57, 148, 255, 189, 146, 122, 56, 196, 123, 119, 67, 41, 78, 50, 143, 145, 254, 180, 248])), SecretKey(Scalar([132, 74, 146, 239, 123, 83, 122, 84, 181, 236, 197, 37, 101, 21, 84, 123, 76, 211, 22, 85, 141, 115, 86, 92, 56, 217, 22, 79, 28, 156, 101, 13])));
/// AXR("gdaxr"): gdaxr1xrqh366p7jepgkymk75dxw5k76782wwdvqszzddjae6dcuq8scw62geglv3
static immutable AXR = KeyPair(PublicKey(Point([193, 120, 235, 65, 244, 178, 20, 88, 155, 183, 168, 211, 58, 150, 246, 188, 117, 57, 205, 96, 32, 33, 53, 178, 238, 116, 220, 112, 7, 134, 29, 165])), SecretKey(Scalar([112, 2, 147, 16, 235, 194, 93, 241, 40, 52, 28, 21, 228, 197, 63, 139, 240, 28, 97, 55, 132, 4, 64, 158, 65, 21, 102, 113, 25, 139, 192, 15])));
/// AXS("gdaxs"): gdaxs1xrqhj66pjcxsr6sj5ln7fszjt6l4tch320x3t806rphalfnwhaz9kmvnm8x
static immutable AXS = KeyPair(PublicKey(Point([193, 121, 107, 65, 150, 13, 1, 234, 18, 167, 231, 228, 192, 82, 94, 191, 85, 226, 241, 83, 205, 21, 157, 250, 24, 111, 223, 166, 110, 191, 68, 91])), SecretKey(Scalar([205, 185, 235, 157, 39, 17, 196, 231, 218, 47, 188, 75, 91, 146, 231, 117, 164, 129, 242, 166, 81, 109, 76, 29, 225, 250, 66, 87, 43, 105, 165, 5])));
/// AXT("gdaxt"): gdaxt1xrqhn66mgrh7qkfzssnuc6fq7wrmwjghfshhg9fgfhkejzczpeamu4ksknk
static immutable AXT = KeyPair(PublicKey(Point([193, 121, 235, 91, 64, 239, 224, 89, 34, 132, 39, 204, 105, 32, 243, 135, 183, 73, 23, 76, 47, 116, 21, 40, 77, 237, 153, 11, 2, 14, 123, 190])), SecretKey(Scalar([230, 231, 158, 208, 110, 191, 215, 36, 61, 124, 175, 91, 236, 118, 82, 139, 38, 18, 64, 247, 110, 228, 144, 131, 221, 176, 249, 102, 69, 162, 235, 15])));
/// AXU("gdaxu"): gdaxu1xrqh566hux0f022auvwgsfjpuvw8h4nyrsmc0u4s84p565s369t72thtlw0
static immutable AXU = KeyPair(PublicKey(Point([193, 122, 107, 87, 225, 158, 151, 169, 93, 227, 28, 136, 38, 65, 227, 28, 123, 214, 100, 28, 55, 135, 242, 176, 61, 67, 77, 82, 17, 209, 87, 229])), SecretKey(Scalar([251, 177, 248, 114, 122, 198, 127, 204, 255, 163, 65, 82, 205, 140, 205, 140, 151, 71, 4, 19, 24, 96, 83, 197, 237, 108, 243, 39, 33, 139, 48, 3])));
/// AXV("gdaxv"): gdaxv1xrqh466g2gr88ve8te56zw2jlyypmfl5f0mf7870dj8nxgx790qs7duntdg
static immutable AXV = KeyPair(PublicKey(Point([193, 122, 235, 72, 82, 6, 115, 179, 39, 94, 105, 161, 57, 82, 249, 8, 29, 167, 244, 75, 246, 159, 31, 207, 108, 143, 51, 32, 222, 43, 193, 15])), SecretKey(Scalar([216, 242, 84, 112, 242, 153, 63, 188, 159, 235, 198, 48, 212, 99, 17, 29, 9, 63, 141, 231, 2, 101, 53, 171, 1, 22, 110, 73, 133, 216, 77, 15])));
/// AXW("gdaxw"): gdaxw1xrqhk665mg8dfmnw6nsprhc9zxkaz2l77w2hnd00p8mywyas52dms67sv0w
static immutable AXW = KeyPair(PublicKey(Point([193, 123, 107, 84, 218, 14, 212, 238, 110, 212, 224, 17, 223, 5, 17, 173, 209, 43, 254, 243, 149, 121, 181, 239, 9, 246, 71, 19, 176, 162, 155, 184])), SecretKey(Scalar([237, 255, 48, 112, 84, 157, 108, 189, 79, 212, 181, 240, 183, 38, 238, 51, 7, 94, 139, 104, 8, 133, 98, 13, 0, 194, 253, 207, 39, 93, 244, 0])));
/// AXX("gdaxx"): gdaxx1xrqhh66rej5fm5wwj6r97mlkzdavjln8hhxtwvghfagtp0c6rl6dwdhez3t
static immutable AXX = KeyPair(PublicKey(Point([193, 123, 235, 67, 204, 168, 157, 209, 206, 150, 134, 95, 111, 246, 19, 122, 201, 126, 103, 189, 204, 183, 49, 23, 79, 80, 176, 191, 26, 31, 244, 215])), SecretKey(Scalar([1, 54, 76, 221, 123, 92, 154, 135, 200, 62, 255, 243, 161, 243, 225, 146, 213, 80, 148, 159, 220, 200, 50, 242, 127, 150, 34, 25, 109, 229, 37, 11])));
/// AXY("gdaxy"): gdaxy1xrqhc66fpfgzrw9dxqry7kl9x727tkgkzs63zzel479amst3awmhw4mx0y0
static immutable AXY = KeyPair(PublicKey(Point([193, 124, 107, 73, 10, 80, 33, 184, 173, 48, 6, 79, 91, 229, 55, 149, 229, 217, 22, 20, 53, 17, 11, 63, 175, 139, 221, 193, 113, 235, 183, 119])), SecretKey(Scalar([96, 18, 174, 191, 39, 136, 206, 57, 171, 46, 224, 203, 133, 240, 76, 50, 2, 248, 63, 81, 144, 70, 218, 31, 82, 250, 130, 35, 104, 102, 70, 15])));
/// AXZ("gdaxz"): gdaxz1xrqhe66ft9nygqhqz5e6nwe0h3wsf6c0zzrp37x8w3fnzravp25aj97jasp
static immutable AXZ = KeyPair(PublicKey(Point([193, 124, 235, 73, 89, 102, 68, 2, 224, 21, 51, 169, 187, 47, 188, 93, 4, 235, 15, 16, 134, 24, 248, 199, 116, 83, 49, 15, 172, 10, 169, 217])), SecretKey(Scalar([252, 17, 131, 255, 158, 94, 142, 122, 18, 225, 123, 152, 5, 82, 187, 225, 84, 84, 18, 109, 135, 207, 247, 68, 240, 211, 136, 164, 249, 47, 144, 13])));
/// AYA("gdaya"): gdaya1xrqcq669f0hgljskevusu0v9rseu98w6akywkhehe5xc0k44q93fy7qw8mv
static immutable AYA = KeyPair(PublicKey(Point([193, 128, 107, 69, 75, 238, 143, 202, 22, 203, 57, 14, 61, 133, 28, 51, 194, 157, 218, 237, 136, 235, 95, 55, 205, 13, 135, 218, 181, 1, 98, 146])), SecretKey(Scalar([170, 71, 146, 76, 34, 138, 166, 150, 77, 59, 134, 252, 96, 71, 183, 138, 245, 108, 26, 186, 91, 210, 161, 193, 132, 83, 187, 171, 234, 184, 212, 6])));
/// AYB("gdayb"): gdayb1xrqcp663zqtqlc24fjwd4acsq7zfs6w4ss5davgrj539kt2hetuaj46wryc
static immutable AYB = KeyPair(PublicKey(Point([193, 128, 235, 81, 16, 22, 15, 225, 85, 76, 156, 218, 247, 16, 7, 132, 152, 105, 213, 132, 40, 222, 177, 3, 149, 34, 91, 45, 87, 202, 249, 217])), SecretKey(Scalar([153, 123, 255, 57, 70, 53, 87, 153, 201, 229, 201, 217, 107, 179, 22, 204, 87, 154, 163, 68, 126, 63, 252, 16, 166, 16, 87, 44, 97, 116, 114, 0])));
/// AYC("gdayc"): gdayc1xrqcz6664e46r44kk3rkr33kwj8ata52e8swjjpr5jk7c09v2ur5y3x9u6s
static immutable AYC = KeyPair(PublicKey(Point([193, 129, 107, 90, 174, 107, 161, 214, 182, 180, 71, 97, 198, 54, 116, 143, 213, 246, 138, 201, 224, 233, 72, 35, 164, 173, 236, 60, 172, 87, 7, 66])), SecretKey(Scalar([217, 239, 250, 221, 118, 51, 235, 212, 132, 8, 127, 106, 109, 153, 204, 116, 171, 46, 49, 4, 239, 52, 106, 74, 15, 214, 116, 205, 66, 234, 107, 5])));
/// AYD("gdayd"): gdayd1xrqcr66kc33dr8w5xt37wgcn8vdrmhqqx8tnh0nt5xw9cvhqqkg329art6a
static immutable AYD = KeyPair(PublicKey(Point([193, 129, 235, 86, 196, 98, 209, 157, 212, 50, 227, 231, 35, 19, 59, 26, 61, 220, 0, 49, 215, 59, 190, 107, 161, 156, 92, 50, 224, 5, 145, 21])), SecretKey(Scalar([212, 71, 48, 175, 118, 228, 173, 19, 70, 237, 74, 230, 172, 203, 245, 48, 52, 74, 248, 231, 232, 151, 163, 22, 158, 190, 68, 128, 254, 35, 177, 11])));
/// AYE("gdaye"): gdaye1xrqcy66sh3mg3w7p3hag3euxh2uky4r45dkd92fc3gq9yp0nfg586axhf0f
static immutable AYE = KeyPair(PublicKey(Point([193, 130, 107, 80, 188, 118, 136, 187, 193, 141, 250, 136, 231, 134, 186, 185, 98, 84, 117, 163, 108, 210, 169, 56, 138, 0, 82, 5, 243, 74, 40, 125])), SecretKey(Scalar([112, 115, 146, 55, 153, 131, 1, 208, 241, 52, 190, 130, 186, 226, 53, 14, 10, 234, 200, 241, 94, 227, 224, 139, 76, 161, 217, 62, 107, 75, 63, 2])));
/// AYF("gdayf"): gdayf1xrqc966s66fgey9qp03mr4q7yp847equgmr0pec33pu82rphxu4cx2g72rn
static immutable AYF = KeyPair(PublicKey(Point([193, 130, 235, 80, 214, 146, 140, 144, 160, 11, 227, 177, 212, 30, 32, 79, 95, 100, 28, 70, 198, 240, 231, 17, 136, 120, 117, 12, 55, 55, 43, 131])), SecretKey(Scalar([92, 210, 5, 202, 2, 145, 32, 230, 65, 180, 69, 90, 101, 20, 46, 165, 5, 76, 35, 212, 87, 41, 59, 255, 80, 138, 245, 66, 188, 157, 241, 7])));
/// AYG("gdayg"): gdayg1xrqcx669dp66de86eekykpy2kmmnlspeak2jprs54l3muvwveygkk2wqd6p
static immutable AYG = KeyPair(PublicKey(Point([193, 131, 107, 69, 104, 117, 166, 228, 250, 206, 108, 75, 4, 138, 182, 247, 63, 192, 57, 237, 149, 32, 142, 20, 175, 227, 190, 49, 204, 201, 17, 107])), SecretKey(Scalar([205, 145, 192, 119, 2, 150, 83, 7, 130, 17, 79, 82, 235, 4, 229, 145, 18, 171, 253, 16, 190, 75, 75, 203, 47, 133, 252, 143, 129, 44, 24, 4])));
/// AYH("gdayh"): gdayh1xrqc8669g9yswpt2umug0h3f9r43kd3emvr34qwcy47vhwqnu73egznpfaj
static immutable AYH = KeyPair(PublicKey(Point([193, 131, 235, 69, 65, 73, 7, 5, 106, 230, 248, 135, 222, 41, 40, 235, 27, 54, 57, 219, 7, 26, 129, 216, 37, 124, 203, 184, 19, 231, 163, 148])), SecretKey(Scalar([118, 167, 81, 90, 40, 102, 250, 43, 177, 18, 91, 13, 234, 29, 72, 71, 17, 255, 233, 206, 193, 113, 144, 161, 186, 196, 241, 174, 120, 212, 248, 10])));
/// AYI("gdayi"): gdayi1xrqcg668ajljmcfm8d7acutxkpna6efa0fgus9z82yymnpsk7z3kjjm738q
static immutable AYI = KeyPair(PublicKey(Point([193, 132, 107, 71, 236, 191, 45, 225, 59, 59, 125, 220, 113, 102, 176, 103, 221, 101, 61, 122, 81, 200, 20, 71, 81, 9, 185, 134, 22, 240, 163, 105])), SecretKey(Scalar([101, 249, 239, 203, 145, 4, 136, 9, 230, 161, 72, 206, 237, 184, 0, 178, 136, 36, 254, 221, 216, 82, 237, 7, 120, 86, 82, 7, 69, 249, 103, 5])));
/// AYJ("gdayj"): gdayj1xrqcf66snlykvkslce82yru9jqfc0qrxtdmuvgdplkhmrws9h5gk20yp7g3
static immutable AYJ = KeyPair(PublicKey(Point([193, 132, 235, 80, 159, 201, 102, 90, 31, 198, 78, 162, 15, 133, 144, 19, 135, 128, 102, 91, 119, 198, 33, 161, 253, 175, 177, 186, 5, 189, 17, 101])), SecretKey(Scalar([0, 124, 13, 21, 234, 96, 239, 16, 42, 231, 18, 100, 5, 12, 39, 99, 168, 209, 31, 168, 135, 196, 0, 221, 97, 182, 241, 208, 76, 129, 88, 6])));
/// AYK("gdayk"): gdayk1xrqc266f8wfm83m33p55p5a0la302jlph2aguxx0lsyz4vjxhuahy7clnla
static immutable AYK = KeyPair(PublicKey(Point([193, 133, 107, 73, 59, 147, 179, 199, 113, 136, 105, 64, 211, 175, 255, 98, 245, 75, 225, 186, 186, 142, 24, 207, 252, 8, 42, 178, 70, 191, 59, 114])), SecretKey(Scalar([180, 168, 213, 121, 74, 36, 187, 20, 36, 21, 142, 84, 226, 215, 111, 150, 192, 184, 204, 216, 249, 119, 198, 129, 248, 219, 210, 233, 165, 243, 119, 10])));
/// AYL("gdayl"): gdayl1xrqct66v7ypwna9ck9nccz64hg46l50xwu46dkh6ne42nwskl8afy3dwfhq
static immutable AYL = KeyPair(PublicKey(Point([193, 133, 235, 76, 241, 2, 233, 244, 184, 177, 103, 140, 11, 85, 186, 43, 175, 209, 230, 119, 43, 166, 218, 250, 158, 106, 169, 186, 22, 249, 250, 146])), SecretKey(Scalar([189, 237, 48, 215, 100, 180, 242, 198, 224, 136, 67, 106, 251, 220, 168, 25, 106, 97, 198, 85, 228, 152, 64, 169, 231, 211, 51, 184, 245, 201, 204, 6])));
/// AYM("gdaym"): gdaym1xrqcv66gqu7mecddntfahfcf26n7jwtmey5mkse0p9g0rnsymdsq5vjmh80
static immutable AYM = KeyPair(PublicKey(Point([193, 134, 107, 72, 7, 61, 188, 225, 173, 154, 211, 219, 167, 9, 86, 167, 233, 57, 123, 201, 41, 187, 67, 47, 9, 80, 241, 206, 4, 219, 96, 10])), SecretKey(Scalar([13, 25, 65, 195, 122, 59, 49, 240, 63, 133, 199, 3, 220, 97, 89, 176, 70, 76, 6, 25, 100, 212, 171, 249, 120, 211, 32, 121, 193, 41, 167, 7])));
/// AYN("gdayn"): gdayn1xrqcd662xrtcs4mgqezvlps9d7wxcpu48t3pmjfh5s0ahyjajn80g6xr4ru
static immutable AYN = KeyPair(PublicKey(Point([193, 134, 235, 74, 48, 215, 136, 87, 104, 6, 68, 207, 134, 5, 111, 156, 108, 7, 149, 58, 226, 29, 201, 55, 164, 31, 219, 146, 93, 148, 206, 244])), SecretKey(Scalar([71, 88, 192, 217, 125, 125, 176, 161, 22, 24, 217, 14, 183, 216, 75, 209, 19, 189, 248, 158, 45, 16, 34, 179, 227, 34, 3, 253, 201, 59, 191, 15])));
/// AYO("gdayo"): gdayo1xrqcw664y3s7jqr89tgj7lpv6cwpryk575vld398h6rn78cn65hnced99ad
static immutable AYO = KeyPair(PublicKey(Point([193, 135, 107, 85, 36, 97, 233, 0, 103, 42, 209, 47, 124, 44, 214, 28, 17, 146, 212, 245, 25, 246, 196, 167, 190, 135, 63, 31, 19, 213, 47, 60])), SecretKey(Scalar([194, 206, 210, 207, 29, 151, 157, 98, 7, 37, 246, 127, 219, 139, 33, 245, 19, 134, 10, 246, 207, 2, 32, 166, 8, 219, 176, 185, 50, 221, 105, 11])));
/// AYP("gdayp"): gdayp1xrqc066nj4kdaca28vrpgezjx2zjdcvfmewpkm46xz5ef29c0y5zslryp20
static immutable AYP = KeyPair(PublicKey(Point([193, 135, 235, 83, 149, 108, 222, 227, 170, 59, 6, 20, 100, 82, 50, 133, 38, 225, 137, 222, 92, 27, 110, 186, 48, 169, 148, 168, 184, 121, 40, 40])), SecretKey(Scalar([160, 12, 210, 9, 211, 172, 50, 243, 254, 218, 141, 54, 154, 114, 93, 125, 168, 130, 176, 155, 118, 189, 109, 141, 150, 69, 222, 27, 126, 167, 200, 3])));
/// AYQ("gdayq"): gdayq1xrqcs66rpatx4dcc0nan5ykdylsrktv7lw4g2tle5ew520x87z0xjuejhzh
static immutable AYQ = KeyPair(PublicKey(Point([193, 136, 107, 67, 15, 86, 106, 183, 24, 124, 251, 58, 18, 205, 39, 224, 59, 45, 158, 251, 170, 133, 47, 249, 166, 93, 69, 60, 199, 240, 158, 105])), SecretKey(Scalar([198, 177, 225, 112, 57, 148, 21, 95, 171, 57, 208, 216, 247, 66, 246, 141, 42, 220, 37, 15, 139, 79, 154, 26, 174, 23, 157, 64, 93, 63, 188, 9])));
/// AYR("gdayr"): gdayr1xrqc3664wcrxu35uh97da2qgpq8mg4ag4n8rsgk8nh7hx6p8nvrx7qgx8ef
static immutable AYR = KeyPair(PublicKey(Point([193, 136, 235, 85, 118, 6, 110, 70, 156, 185, 124, 222, 168, 8, 8, 15, 180, 87, 168, 172, 206, 56, 34, 199, 157, 253, 115, 104, 39, 155, 6, 111])), SecretKey(Scalar([165, 56, 97, 208, 240, 179, 134, 48, 158, 190, 98, 250, 135, 89, 241, 1, 76, 175, 10, 53, 133, 229, 216, 65, 198, 116, 28, 235, 83, 124, 109, 5])));
/// AYS("gdays"): gdays1xrqcj662aaqnn9t9h3dxla7u6g7jc989eqwnw3dytk66hqtdsutpjztrga3
static immutable AYS = KeyPair(PublicKey(Point([193, 137, 107, 74, 239, 65, 57, 149, 101, 188, 90, 111, 247, 220, 210, 61, 44, 20, 229, 200, 29, 55, 69, 164, 93, 181, 171, 129, 109, 135, 22, 25])), SecretKey(Scalar([251, 114, 7, 208, 253, 251, 57, 47, 143, 127, 120, 152, 112, 22, 126, 166, 254, 136, 246, 156, 52, 18, 240, 149, 190, 110, 216, 142, 152, 77, 223, 15])));
/// AYT("gdayt"): gdayt1xrqcn66t7lwdzzdez2zp5gg4e2eh3a55n8vycjfeln7x7s9u02l7juqfts8
static immutable AYT = KeyPair(PublicKey(Point([193, 137, 235, 75, 247, 220, 209, 9, 185, 18, 132, 26, 33, 21, 202, 179, 120, 246, 148, 153, 216, 76, 73, 57, 252, 252, 111, 64, 188, 122, 191, 233])), SecretKey(Scalar([78, 226, 14, 136, 132, 183, 195, 191, 75, 65, 196, 18, 49, 168, 47, 255, 237, 21, 167, 191, 64, 155, 76, 12, 221, 31, 166, 97, 226, 27, 128, 7])));
/// AYU("gdayu"): gdayu1xrqc5660v0cjlf8xsjruwx6ggvpy8vllcxpvp0p0f4j2mwvrvr8yynclmly
static immutable AYU = KeyPair(PublicKey(Point([193, 138, 107, 79, 99, 241, 47, 164, 230, 132, 135, 199, 27, 72, 67, 2, 67, 179, 255, 193, 130, 192, 188, 47, 77, 100, 173, 185, 131, 96, 206, 66])), SecretKey(Scalar([1, 184, 125, 227, 20, 227, 28, 18, 230, 218, 5, 82, 90, 210, 122, 157, 80, 4, 134, 7, 66, 0, 22, 229, 181, 236, 13, 192, 147, 150, 223, 6])));
/// AYV("gdayv"): gdayv1xrqc466hv55qzyjawstt486ezagepf8pmxg3n6cryjzczytv98nfxdt9zrt
static immutable AYV = KeyPair(PublicKey(Point([193, 138, 235, 87, 101, 40, 1, 18, 93, 116, 22, 186, 159, 89, 23, 81, 144, 164, 225, 217, 145, 25, 235, 3, 36, 133, 129, 17, 108, 41, 230, 147])), SecretKey(Scalar([75, 246, 8, 111, 150, 19, 40, 254, 94, 176, 82, 197, 51, 156, 1, 13, 108, 104, 125, 226, 210, 100, 142, 181, 227, 52, 172, 207, 147, 123, 131, 11])));
/// AYW("gdayw"): gdayw1xrqck6602q22ppsg3p3jyz64zl2sfg7hn4f5m48d2vgk6ydy35pv77fd8aj
static immutable AYW = KeyPair(PublicKey(Point([193, 139, 107, 79, 80, 20, 160, 134, 8, 136, 99, 34, 11, 85, 23, 213, 4, 163, 215, 157, 83, 77, 212, 237, 83, 17, 109, 17, 164, 141, 2, 207])), SecretKey(Scalar([111, 182, 7, 135, 5, 139, 33, 228, 95, 195, 142, 147, 89, 214, 205, 128, 5, 30, 76, 221, 53, 164, 115, 217, 121, 69, 30, 71, 50, 74, 79, 3])));
/// AYX("gdayx"): gdayx1xrqch669tfp3e77gvmhkj8al483kxf8uuz5vkqwwz3d72y5n5tfsvve9jnf
static immutable AYX = KeyPair(PublicKey(Point([193, 139, 235, 69, 90, 67, 28, 251, 200, 102, 239, 105, 31, 191, 169, 227, 99, 36, 252, 224, 168, 203, 1, 206, 20, 91, 229, 18, 147, 162, 211, 6])), SecretKey(Scalar([63, 146, 252, 196, 123, 219, 217, 58, 129, 112, 163, 193, 205, 190, 217, 138, 234, 55, 9, 128, 48, 224, 159, 178, 35, 72, 162, 166, 91, 123, 207, 1])));
/// AYY("gdayy"): gdayy1xrqcc66a0pgkzrhf30p2mj70kwe3kc6ss4yw0w9hdud4rxvenehuwuf9p6w
static immutable AYY = KeyPair(PublicKey(Point([193, 140, 107, 93, 120, 81, 97, 14, 233, 139, 194, 173, 203, 207, 179, 179, 27, 99, 80, 133, 72, 231, 184, 183, 111, 27, 81, 153, 153, 158, 111, 199])), SecretKey(Scalar([20, 120, 201, 142, 86, 95, 40, 107, 238, 60, 57, 238, 182, 65, 135, 41, 139, 1, 62, 84, 157, 148, 42, 62, 108, 88, 64, 136, 219, 64, 47, 0])));
/// AYZ("gdayz"): gdayz1xrqce66dwxa0l9jl9mcztmdssmh6m9wjvyqr6w8f653wv8r5kfd8k5pn09c
static immutable AYZ = KeyPair(PublicKey(Point([193, 140, 235, 77, 113, 186, 255, 150, 95, 46, 240, 37, 237, 176, 134, 239, 173, 149, 210, 97, 0, 61, 56, 233, 213, 34, 230, 28, 116, 178, 90, 123])), SecretKey(Scalar([212, 63, 91, 135, 34, 236, 172, 205, 9, 147, 28, 105, 161, 12, 92, 140, 40, 214, 187, 125, 120, 223, 130, 184, 3, 200, 43, 118, 95, 171, 200, 0])));
/// AZA("gdaza"): gdaza1xrqeq66lgzzf9t33ew3he6suq6emsxnm8t45fw5m6d6ys9we5aa56dyw0nm
static immutable AZA = KeyPair(PublicKey(Point([193, 144, 107, 95, 64, 132, 146, 174, 49, 203, 163, 124, 234, 28, 6, 179, 184, 26, 123, 58, 235, 68, 186, 155, 211, 116, 72, 21, 217, 167, 123, 77])), SecretKey(Scalar([221, 133, 199, 191, 125, 168, 179, 139, 20, 84, 223, 144, 138, 238, 182, 40, 229, 200, 49, 57, 116, 214, 70, 145, 122, 135, 159, 119, 181, 162, 58, 8])));
/// AZB("gdazb"): gdazb1xrqep66s7rrt00d4a6jpapqdz0y9xnwdlmjhvra3f38yx4cczcaexafe26n
static immutable AZB = KeyPair(PublicKey(Point([193, 144, 235, 80, 240, 198, 183, 189, 181, 238, 164, 30, 132, 13, 19, 200, 83, 77, 205, 254, 229, 118, 15, 177, 76, 78, 67, 87, 24, 22, 59, 147])), SecretKey(Scalar([94, 124, 161, 113, 112, 237, 30, 209, 192, 228, 233, 13, 34, 85, 208, 104, 214, 226, 154, 220, 230, 254, 251, 216, 233, 84, 76, 124, 66, 217, 111, 7])));
/// AZC("gdazc"): gdazc1xrqez66aatrtgzsj2qg8zptcgnh6k6ara2akcyntw3ks50kjfx0njd05vrr
static immutable AZC = KeyPair(PublicKey(Point([193, 145, 107, 93, 234, 198, 180, 10, 18, 80, 16, 113, 5, 120, 68, 239, 171, 107, 163, 234, 187, 108, 18, 107, 116, 109, 10, 62, 210, 73, 159, 57])), SecretKey(Scalar([134, 166, 230, 40, 176, 141, 133, 82, 201, 125, 200, 241, 247, 182, 111, 94, 46, 86, 140, 178, 10, 24, 66, 126, 184, 159, 111, 230, 27, 89, 86, 12])));
/// AZD("gdazd"): gdazd1xrqer66vu36q62y5f80fpyf97p0jr2z98yuxs9dz7840x8ddm32du99dgmg
static immutable AZD = KeyPair(PublicKey(Point([193, 145, 235, 76, 228, 116, 13, 40, 148, 73, 222, 144, 145, 37, 240, 95, 33, 168, 69, 57, 56, 104, 21, 162, 241, 234, 243, 29, 173, 220, 84, 222])), SecretKey(Scalar([206, 118, 44, 169, 210, 72, 12, 97, 240, 238, 42, 28, 184, 86, 72, 198, 196, 48, 46, 41, 42, 249, 205, 72, 156, 175, 92, 117, 38, 156, 40, 11])));
/// AZE("gdaze"): gdaze1xrqey66v77a47zacvtp5v95wx09wm7rcm8lkw6487ff4c4dxxfu9w4ns0ej
static immutable AZE = KeyPair(PublicKey(Point([193, 146, 107, 76, 247, 187, 95, 11, 184, 98, 195, 70, 22, 142, 51, 202, 237, 248, 120, 217, 255, 103, 106, 167, 242, 83, 92, 85, 166, 50, 120, 87])), SecretKey(Scalar([94, 119, 141, 224, 8, 49, 197, 110, 211, 227, 113, 29, 12, 202, 2, 140, 196, 22, 194, 105, 28, 157, 91, 108, 244, 38, 50, 191, 189, 19, 2, 5])));
/// AZF("gdazf"): gdazf1xrqe96654ydxpuwepnwmstz8fuwdyultedv5xktd4q4yvgnumn9pksafhxh
static immutable AZF = KeyPair(PublicKey(Point([193, 146, 235, 84, 169, 26, 96, 241, 217, 12, 221, 184, 44, 71, 79, 28, 210, 115, 235, 203, 89, 67, 89, 109, 168, 42, 70, 34, 124, 220, 202, 27])), SecretKey(Scalar([154, 117, 82, 1, 147, 166, 205, 1, 106, 195, 207, 22, 100, 224, 25, 53, 247, 161, 88, 53, 180, 128, 86, 1, 192, 110, 54, 227, 108, 168, 218, 7])));
/// AZG("gdazg"): gdazg1xrqex66rm9zfcnc3y8zhrz0ykwfmgtxmva04x4l3vxzt2zqqqaxz6gywl0a
static immutable AZG = KeyPair(PublicKey(Point([193, 147, 107, 67, 217, 68, 156, 79, 17, 33, 197, 113, 137, 228, 179, 147, 180, 44, 219, 103, 95, 83, 87, 241, 97, 132, 181, 8, 0, 7, 76, 45])), SecretKey(Scalar([252, 54, 123, 100, 250, 39, 24, 84, 60, 158, 231, 49, 12, 128, 3, 137, 135, 242, 30, 3, 255, 247, 178, 172, 87, 154, 220, 84, 84, 238, 114, 5])));
/// AZH("gdazh"): gdazh1xrqe866cvusxen8nnqp84xqen8r08h677f947cwt8m0ucwenfye7uulmsp3
static immutable AZH = KeyPair(PublicKey(Point([193, 147, 235, 88, 103, 32, 108, 204, 243, 152, 2, 122, 152, 25, 153, 198, 243, 223, 94, 242, 75, 95, 97, 203, 62, 223, 204, 59, 51, 73, 51, 238])), SecretKey(Scalar([72, 132, 187, 127, 159, 186, 10, 89, 215, 187, 107, 61, 77, 180, 48, 160, 136, 7, 246, 142, 112, 160, 211, 100, 155, 223, 138, 13, 0, 97, 69, 5])));
/// AZI("gdazi"): gdazi1xrqeg66kcmnl4wsyvty73p2xhf4adk6agrxdjpwk0fazxs5tf4qsu2scwae
static immutable AZI = KeyPair(PublicKey(Point([193, 148, 107, 86, 198, 231, 250, 186, 4, 98, 201, 232, 133, 70, 186, 107, 214, 219, 93, 64, 204, 217, 5, 214, 122, 122, 35, 66, 139, 77, 65, 14])), SecretKey(Scalar([130, 199, 208, 27, 230, 255, 41, 16, 7, 162, 20, 217, 10, 230, 77, 1, 225, 225, 197, 40, 23, 58, 73, 28, 121, 147, 228, 184, 2, 129, 180, 15])));
/// AZJ("gdazj"): gdazj1xrqef66wl54q8gcqft2jyyhk42k389n8tp4tlaug5c7yse744n5rxwdnluc
static immutable AZJ = KeyPair(PublicKey(Point([193, 148, 235, 78, 253, 42, 3, 163, 0, 74, 213, 34, 18, 246, 170, 173, 19, 150, 103, 88, 106, 191, 247, 136, 166, 60, 72, 103, 213, 172, 232, 51])), SecretKey(Scalar([211, 71, 49, 194, 148, 232, 101, 86, 92, 219, 214, 122, 86, 185, 127, 158, 253, 69, 162, 254, 4, 182, 0, 215, 232, 156, 71, 232, 92, 5, 148, 10])));
/// AZK("gdazk"): gdazk1xrqe26620zkfpm2q68a7krdyl9te54v27q979jvvn43na2s2a549x5aqkw4
static immutable AZK = KeyPair(PublicKey(Point([193, 149, 107, 74, 120, 172, 144, 237, 64, 209, 251, 235, 13, 164, 249, 87, 154, 85, 138, 240, 11, 226, 201, 140, 157, 99, 62, 170, 10, 237, 42, 83])), SecretKey(Scalar([108, 99, 138, 248, 91, 186, 141, 113, 199, 25, 34, 122, 107, 41, 75, 89, 60, 172, 199, 117, 164, 13, 3, 102, 24, 225, 153, 219, 233, 93, 206, 14])));
/// AZL("gdazl"): gdazl1xrqet66u7447h23637spmua3my7a7asne5ye9zleglqs0fzec3krs4w6v9v
static immutable AZL = KeyPair(PublicKey(Point([193, 149, 235, 92, 245, 107, 235, 170, 58, 143, 160, 29, 243, 177, 217, 61, 223, 118, 19, 205, 9, 146, 139, 249, 71, 193, 7, 164, 89, 196, 108, 56])), SecretKey(Scalar([218, 163, 142, 50, 135, 49, 34, 142, 11, 221, 81, 124, 20, 147, 54, 235, 3, 203, 177, 205, 25, 161, 93, 101, 21, 1, 30, 151, 117, 151, 141, 12])));
/// AZM("gdazm"): gdazm1xrqev665eatw67um58xe3yts5vv54exjuyutvrkfnqxejnrnqp9zcz7jjt4
static immutable AZM = KeyPair(PublicKey(Point([193, 150, 107, 84, 207, 86, 237, 123, 155, 161, 205, 152, 145, 112, 163, 25, 74, 228, 210, 225, 56, 182, 14, 201, 152, 13, 153, 76, 115, 0, 74, 44])), SecretKey(Scalar([248, 38, 132, 44, 133, 56, 97, 201, 109, 211, 219, 149, 68, 155, 45, 75, 15, 114, 130, 6, 126, 230, 209, 48, 193, 65, 100, 161, 46, 182, 57, 2])));
/// AZN("gdazn"): gdazn1xrqed664w5890pr5rk3adc2l2re969u52tw037pq5e6dkfzd5jxpxvgnfdv
static immutable AZN = KeyPair(PublicKey(Point([193, 150, 235, 85, 117, 14, 87, 132, 116, 29, 163, 214, 225, 95, 80, 242, 93, 23, 148, 82, 220, 248, 248, 32, 166, 116, 219, 36, 77, 164, 140, 19])), SecretKey(Scalar([86, 172, 159, 13, 67, 12, 146, 60, 253, 199, 167, 150, 166, 218, 91, 148, 207, 10, 185, 13, 8, 237, 104, 44, 59, 171, 15, 114, 198, 201, 8, 14])));
/// AZO("gdazo"): gdazo1xrqew66nzhmrs3mh2fxgda0w4lphydpjlz5as5p58kava3jqq9f72ud3wf7
static immutable AZO = KeyPair(PublicKey(Point([193, 151, 107, 83, 21, 246, 56, 71, 119, 82, 76, 134, 245, 238, 175, 195, 114, 52, 50, 248, 169, 216, 80, 52, 61, 186, 206, 198, 64, 1, 83, 229])), SecretKey(Scalar([32, 1, 41, 59, 136, 152, 206, 99, 115, 122, 233, 29, 108, 238, 170, 183, 154, 172, 35, 148, 86, 163, 219, 0, 188, 181, 86, 239, 133, 205, 37, 1])));
/// AZP("gdazp"): gdazp1xrqe066hrw3wqpqxd870k7yef0vdqm023utulr007jyzws4rzfgrgjaxlkn
static immutable AZP = KeyPair(PublicKey(Point([193, 151, 235, 87, 27, 162, 224, 4, 6, 105, 252, 251, 120, 153, 75, 216, 208, 109, 234, 143, 23, 207, 141, 239, 244, 136, 39, 66, 163, 18, 80, 52])), SecretKey(Scalar([59, 66, 136, 93, 172, 46, 240, 244, 239, 23, 60, 211, 21, 0, 241, 125, 80, 109, 170, 140, 124, 199, 168, 39, 8, 172, 105, 196, 247, 191, 41, 13])));
/// AZQ("gdazq"): gdazq1xrqes66jgh6vmsecd5khhhw3gwpn6j3rra6mv3wyphtaxepwlg94qwepzx2
static immutable AZQ = KeyPair(PublicKey(Point([193, 152, 107, 82, 69, 244, 205, 195, 56, 109, 45, 123, 221, 209, 67, 131, 61, 74, 35, 31, 117, 182, 69, 196, 13, 215, 211, 100, 46, 250, 11, 80])), SecretKey(Scalar([28, 156, 31, 201, 78, 117, 233, 70, 182, 138, 211, 222, 56, 105, 181, 174, 129, 67, 16, 40, 246, 195, 183, 110, 221, 49, 37, 149, 243, 0, 89, 9])));
/// AZR("gdazr"): gdazr1xrqe36677597xn43dcyelqkrzf9lq77wak372qcec998mm97azjfy9wf6nj
static immutable AZR = KeyPair(PublicKey(Point([193, 152, 235, 94, 245, 11, 227, 78, 177, 110, 9, 159, 130, 195, 18, 75, 240, 123, 206, 237, 163, 229, 3, 25, 193, 74, 125, 236, 190, 232, 164, 146])), SecretKey(Scalar([150, 175, 33, 95, 16, 176, 239, 36, 162, 208, 31, 109, 11, 102, 72, 65, 135, 74, 8, 168, 51, 143, 80, 4, 169, 210, 192, 38, 40, 147, 169, 5])));
/// AZS("gdazs"): gdazs1xrqej66m9vwads46k46shtxfz804c25vl7q7r6js7luwtuawf4yu527ll5g
static immutable AZS = KeyPair(PublicKey(Point([193, 153, 107, 91, 43, 29, 214, 194, 186, 181, 117, 11, 172, 201, 17, 223, 92, 42, 140, 255, 129, 225, 234, 80, 247, 248, 229, 243, 174, 77, 73, 202])), SecretKey(Scalar([182, 226, 119, 21, 188, 123, 7, 56, 12, 234, 121, 143, 108, 63, 25, 85, 226, 159, 21, 128, 114, 85, 69, 215, 249, 29, 234, 179, 103, 29, 75, 1])));
/// AZT("gdazt"): gdazt1xrqen66ev5fnqsmqtjcum3c6qq7suqclqegrfj5k87mv5p2xq7ax65uczdu
static immutable AZT = KeyPair(PublicKey(Point([193, 153, 235, 89, 101, 19, 48, 67, 96, 92, 177, 205, 199, 26, 0, 61, 14, 3, 31, 6, 80, 52, 202, 150, 63, 182, 202, 5, 70, 7, 186, 109])), SecretKey(Scalar([203, 252, 69, 74, 121, 31, 190, 130, 29, 35, 194, 78, 228, 47, 30, 206, 91, 156, 31, 211, 196, 180, 245, 211, 128, 250, 78, 148, 7, 156, 156, 4])));
/// AZU("gdazu"): gdazu1xrqe566xwlfy3xfjujlcq728p0yawz9hqd0fdky2h9pfztcaz7qsvv6nh5l
static immutable AZU = KeyPair(PublicKey(Point([193, 154, 107, 70, 119, 210, 72, 153, 50, 228, 191, 128, 121, 71, 11, 201, 215, 8, 183, 3, 94, 150, 216, 138, 185, 66, 145, 47, 29, 23, 129, 6])), SecretKey(Scalar([65, 113, 14, 17, 141, 244, 30, 169, 53, 186, 16, 111, 196, 181, 206, 81, 85, 158, 51, 42, 238, 73, 158, 59, 49, 20, 160, 137, 59, 24, 99, 0])));
/// AZV("gdazv"): gdazv1xrqe466qajftzr6dekycuh0glfyk2kdhwzqqlcnc3rs8sd655l3ky0kj496
static immutable AZV = KeyPair(PublicKey(Point([193, 154, 235, 64, 236, 146, 177, 15, 77, 205, 137, 142, 93, 232, 250, 73, 101, 89, 183, 112, 128, 15, 226, 120, 136, 224, 120, 55, 84, 167, 227, 98])), SecretKey(Scalar([7, 53, 229, 3, 213, 114, 1, 29, 107, 91, 137, 82, 151, 18, 52, 159, 164, 45, 23, 94, 239, 80, 18, 66, 60, 26, 71, 73, 2, 178, 188, 7])));
/// AZW("gdazw"): gdazw1xrqek664uk4s7c7gtg2cmpdwrykphh2a4c6pm8qz9v74k4ufyyq0z4sasfz
static immutable AZW = KeyPair(PublicKey(Point([193, 155, 107, 85, 229, 171, 15, 99, 200, 90, 21, 141, 133, 174, 25, 44, 27, 221, 93, 174, 52, 29, 156, 2, 43, 61, 91, 87, 137, 33, 0, 241])), SecretKey(Scalar([175, 187, 192, 190, 116, 184, 99, 231, 84, 222, 114, 44, 250, 148, 174, 158, 81, 43, 132, 99, 70, 30, 22, 17, 95, 238, 42, 132, 95, 159, 206, 0])));
/// AZX("gdazx"): gdazx1xrqeh66wqk9xqgvszg2j6uslg4mu8c6zprkyh0udu82595utsc02sw0elda
static immutable AZX = KeyPair(PublicKey(Point([193, 155, 235, 78, 5, 138, 96, 33, 144, 18, 21, 45, 114, 31, 69, 119, 195, 227, 66, 8, 236, 75, 191, 141, 225, 213, 66, 211, 139, 134, 30, 168])), SecretKey(Scalar([155, 151, 33, 177, 118, 136, 166, 111, 10, 68, 20, 71, 161, 179, 175, 192, 198, 75, 55, 132, 26, 83, 225, 31, 240, 181, 146, 223, 60, 163, 211, 9])));
/// AZY("gdazy"): gdazy1xrqec664xx77z4qa2wewkcs4ykmv8a6ky2xmvtjmezp7pyvvl9k4wxjck2k
static immutable AZY = KeyPair(PublicKey(Point([193, 156, 107, 85, 49, 189, 225, 84, 29, 83, 178, 235, 98, 21, 37, 182, 195, 247, 86, 34, 141, 182, 46, 91, 200, 131, 224, 145, 140, 249, 109, 87])), SecretKey(Scalar([194, 245, 117, 76, 81, 225, 22, 57, 6, 206, 125, 3, 243, 190, 251, 43, 111, 163, 79, 163, 50, 170, 80, 64, 36, 4, 204, 182, 135, 246, 184, 1])));
/// AZZ("gdazz"): gdazz1xrqee666u3kva7kcpck987luczx7k0na8hh6z3lzfu6n5rx73t8sx2dz0mm
static immutable AZZ = KeyPair(PublicKey(Point([193, 156, 235, 90, 228, 108, 206, 250, 216, 14, 44, 83, 251, 252, 192, 141, 235, 62, 125, 61, 239, 161, 71, 226, 79, 53, 58, 12, 222, 138, 207, 3])), SecretKey(Scalar([25, 115, 222, 75, 37, 76, 156, 1, 245, 176, 62, 200, 183, 61, 34, 138, 95, 5, 236, 102, 148, 175, 36, 179, 12, 202, 68, 156, 205, 51, 218, 3])));

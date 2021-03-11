/*******************************************************************************

    The list of well-known keypairs

    This module should not be imported directly.
    Instead use `agora.utils.Test : WK.Keys`.
    It is solely here to host all well-known keys in a separate, single file,
    as they are stored as array of `ubyte` to speed-up compilation.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.WellKnownKeys;

import agora.crypto.Key;

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

    Seed:    SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4
    Address: GCOQEOHAUFYUAC6G22FJ3GZRNLGVCCLESEJ2AXBIJ5BJNUVTAERPLRIJ

*******************************************************************************/

static immutable Genesis = KeyPair(
    PublicKey([157, 2, 56, 224, 161, 113, 64, 11, 198, 214, 138, 157, 155, 49, 106, 205, 81, 9, 100, 145, 19, 160, 92, 40, 79, 66, 150, 210, 179, 1, 34, 245]),
    SecretKey([184, 45, 128, 164, 113, 43, 34, 123, 140, 162, 187, 53, 141, 225, 232, 223, 227, 155, 162, 39, 236, 7, 254, 245, 59, 69, 215, 59, 210, 93, 36, 68]),
    Seed([167, 197, 41, 45, 194, 231, 7, 114, 117, 27, 234, 152, 100, 142, 108, 235, 91, 123, 216, 92, 108, 4, 54, 200, 217, 114, 60, 126, 156, 76, 184, 148]));


/*******************************************************************************

    Commons Budget KeyPair used in unittests

    In unittests, we need the commons budget key pair to be known for us to be
    able to write tests.
    In the real network, there are different values.

    Note that while this is a well-known keys, it is not part of the
    range returned by `byRange`, nor can it be indexed by `size_t`,
    to avoid it being mistakenly used.

    Seed:    SCNRULE3Q7NBNX7UIJVVI6HI5DQKP3MNDEHJA66FJZXDEGGH4SRRDSDR
    Address: GCOMMONBGUXXP4RFCYGEF74JDJVPUW2GUENGTKKJECDNO6AGO32CUWGU

*******************************************************************************/

static immutable CommonsBudget = KeyPair(
    PublicKey([156, 198, 57, 161, 53, 47, 119, 242, 37, 22, 12, 66, 255, 137, 26, 106, 250, 91, 70, 161, 26, 105, 169, 73, 32, 134, 215, 120, 6, 118, 244, 42]),
    SecretKey([232, 225, 158, 186, 229, 227, 21, 206, 210, 224, 81, 169, 198, 215, 159, 248, 28, 3, 215, 233, 52, 122, 159, 2, 0, 103, 143, 188, 212, 93, 234, 90]),
    Seed([155, 26, 44, 155, 135, 218, 22, 223, 244, 66, 107, 84, 120, 232, 232, 224, 167, 237, 141, 25, 14, 144, 123, 197, 78, 110, 50, 24, 199, 228, 163, 17]));


/*******************************************************************************

    Key pairs used for Enrollments in the genesis block

    Note that despite mining for a few days, NODE0, NODE1, NODE8, NODE9 were
    not found.

*******************************************************************************/

/// NODE2: GDNODE2IMTDH7SZHXWDS24EZCMYCEJMRZWB3S4HLRIUP6UNGKVVFLVHQ
static immutable NODE2 = KeyPair(PublicKey([218, 225, 147, 72, 100, 198, 127, 203, 39, 189, 135, 45, 112, 153, 19, 48, 34, 37, 145, 205, 131, 185, 112, 235, 138, 40, 255, 81, 166, 85, 106, 85]), SecretKey([96, 129, 32, 153, 248, 229, 88, 80, 36, 176, 239, 77, 130, 248, 187, 250, 111, 179, 165, 35, 103, 135, 159, 228, 191, 127, 43, 28, 6, 147, 185, 122]), Seed([213, 219, 59, 66, 143, 187, 219, 138, 53, 118, 247, 121, 81, 26, 130, 151, 52, 93, 233, 123, 112, 192, 176, 154, 7, 127, 204, 246, 72, 11, 101, 110]));
/// NODE3: GDNODE3EWQKF33TPK35DAQ3KXAYSOT4E4ACDOVJMDZQDVKP66IMJEACM
static immutable NODE3 = KeyPair(PublicKey([218, 225, 147, 100, 180, 20, 93, 238, 111, 86, 250, 48, 67, 106, 184, 49, 39, 79, 132, 224, 4, 55, 85, 44, 30, 96, 58, 169, 254, 242, 24, 146]), SecretKey([80, 37, 191, 11, 233, 67, 133, 155, 105, 191, 89, 139, 254, 110, 203, 110, 51, 3, 44, 220, 193, 36, 251, 97, 42, 21, 83, 220, 21, 135, 241, 67]), Seed([158, 128, 149, 27, 28, 8, 183, 199, 249, 172, 74, 90, 34, 118, 203, 66, 73, 132, 55, 94, 83, 133, 76, 159, 138, 130, 42, 33, 11, 216, 207, 112]));
/// NODE4: GDNODE4KTE7VQUHVBLXIGD7VEFY57X4XV547P72D37SDG7UEO7MWOSNY
static immutable NODE4 = KeyPair(PublicKey([218, 225, 147, 138, 153, 63, 88, 80, 245, 10, 238, 131, 15, 245, 33, 113, 223, 223, 151, 175, 121, 247, 255, 67, 223, 228, 51, 126, 132, 119, 217, 103]), SecretKey([104, 149, 165, 113, 80, 222, 31, 59, 252, 175, 82, 50, 86, 185, 171, 10, 179, 233, 36, 190, 162, 45, 53, 88, 162, 28, 97, 40, 171, 238, 93, 86]), Seed([204, 156, 42, 118, 105, 190, 35, 66, 45, 136, 166, 96, 0, 15, 4, 216, 129, 253, 115, 77, 207, 232, 178, 79, 243, 244, 110, 104, 24, 231, 27, 111]));
/// NODE5: GDNODE5T7TWJ2S4UQSTM7KDHU2HQHCJUXFYLPZDDYGXIBUAH3U3PJQC2
static immutable NODE5 = KeyPair(PublicKey([218, 225, 147, 179, 252, 236, 157, 75, 148, 132, 166, 207, 168, 103, 166, 143, 3, 137, 52, 185, 112, 183, 228, 99, 193, 174, 128, 208, 7, 221, 54, 244]), SecretKey([176, 13, 80, 153, 30, 8, 199, 228, 90, 197, 27, 240, 157, 235, 85, 132, 10, 120, 12, 119, 244, 28, 188, 54, 163, 79, 88, 20, 116, 140, 77, 98]), Seed([225, 12, 19, 219, 173, 131, 133, 192, 80, 192, 84, 47, 164, 47, 111, 109, 173, 88, 176, 222, 112, 253, 25, 155, 74, 24, 251, 15, 26, 208, 224, 47]));
/// NODE6: GDNODE6ZXW2NNOOQIGN24MBEZRO5226LSMHGQA3MUAMYQSTJVR7XT6GH
static immutable NODE6 = KeyPair(PublicKey([218, 225, 147, 217, 189, 180, 214, 185, 208, 65, 155, 174, 48, 36, 204, 93, 221, 107, 203, 147, 14, 104, 3, 108, 160, 25, 136, 74, 105, 172, 127, 121]), SecretKey([64, 211, 173, 237, 65, 88, 6, 23, 9, 87, 113, 142, 80, 17, 87, 86, 163, 233, 104, 188, 34, 126, 64, 108, 16, 68, 35, 14, 186, 173, 104, 75]), Seed([106, 1, 166, 251, 71, 195, 194, 214, 108, 158, 49, 36, 128, 57, 143, 3, 211, 177, 53, 234, 228, 189, 15, 26, 23, 70, 234, 160, 247, 42, 214, 116]));
/// NODE7: GDNODE7J5EUK7T6HLEO2FDUBWZEXVXHJO7C4AF5VZAKZENGQ4WR3IX2U
static immutable NODE7 = KeyPair(PublicKey([218, 225, 147, 233, 233, 40, 175, 207, 199, 89, 29, 162, 142, 129, 182, 73, 122, 220, 233, 119, 197, 192, 23, 181, 200, 21, 146, 52, 208, 229, 163, 180]), SecretKey([224, 3, 67, 62, 66, 75, 4, 199, 214, 46, 107, 12, 136, 49, 83, 189, 28, 229, 67, 22, 103, 156, 41, 25, 17, 154, 245, 150, 214, 106, 198, 75]), Seed([37, 25, 185, 138, 197, 67, 118, 91, 162, 51, 121, 65, 54, 3, 168, 9, 97, 212, 85, 22, 6, 45, 119, 2, 16, 5, 38, 234, 127, 33, 43, 216]));


/*******************************************************************************

    All well-known keypairs

    The pattern is as follow:
    Keys are in the range `[A,Z]`, `[AA,ZZ]` and `[AAA,AZZ]`, for a total of
    1,377 keys (26 + 26 * 26 * 2 - 1), as we needed more than 1,000 keys.
    Keys have been mined to be easily recognizable in logs, as such, their
    public keys starts with `GD`, followed by their name, followed by `22`.
    For example, `A` is `GDA22...` and `ABC` is `GDABC22...`.

*******************************************************************************/

/// A: GDA225RGC4GOCVASSAMROSWJSGNOZX2IGPXZG52ESDSKQW2VN6UJFKWI
static immutable A = KeyPair(PublicKey([193, 173, 118, 38, 23, 12, 225, 84, 18, 144, 25, 23, 74, 201, 145, 154, 236, 223, 72, 51, 239, 147, 119, 68, 144, 228, 168, 91, 85, 111, 168, 146]), SecretKey([248, 160, 158, 236, 138, 239, 59, 175, 116, 68, 134, 191, 142, 172, 4, 192, 38, 31, 221, 164, 75, 87, 145, 185, 76, 235, 179, 192, 158, 200, 118, 111]), Seed([165, 27, 119, 139, 225, 46, 156, 78, 8, 134, 4, 145, 243, 11, 11, 6, 5, 196, 44, 60, 165, 44, 199, 149, 183, 95, 32, 231, 58, 194, 17, 168]));
/// B: GDB22QJ4NHOHPOGWZG2Y5IFXKW6DCBEFX6QNBR6NSCT6E7CYU66IDGJJ
static immutable B = KeyPair(PublicKey([195, 173, 65, 60, 105, 220, 119, 184, 214, 201, 181, 142, 160, 183, 85, 188, 49, 4, 133, 191, 160, 208, 199, 205, 144, 167, 226, 124, 88, 167, 188, 129]), SecretKey([248, 172, 16, 89, 2, 79, 211, 163, 186, 211, 235, 132, 46, 4, 77, 74, 213, 238, 87, 38, 15, 144, 190, 12, 112, 211, 207, 91, 85, 143, 206, 114]), Seed([169, 218, 45, 47, 95, 245, 33, 18, 210, 47, 237, 202, 4, 218, 202, 159, 182, 131, 37, 229, 194, 185, 160, 64, 19, 210, 194, 177, 17, 203, 148, 4]));
/// C: GDC22CFFKB4ZNRZUP6EMRIGVZSQEPSNH2CBMWLU5GLGKE36M3KX5YD36
static immutable C = KeyPair(PublicKey([197, 173, 8, 165, 80, 121, 150, 199, 52, 127, 136, 200, 160, 213, 204, 160, 71, 201, 167, 208, 130, 203, 46, 157, 50, 204, 162, 111, 204, 218, 175, 220]), SecretKey([224, 212, 98, 181, 144, 66, 230, 245, 71, 55, 136, 123, 3, 238, 88, 164, 84, 246, 188, 202, 23, 120, 135, 210, 226, 120, 134, 41, 59, 108, 19, 112]), Seed([97, 39, 35, 62, 21, 29, 148, 118, 52, 80, 12, 24, 39, 122, 90, 55, 107, 95, 14, 209, 151, 132, 93, 118, 182, 77, 126, 227, 115, 183, 58, 208]));
/// D: GDD22H4TGRGS5ENN3DHBGMMCSZELKORKEZT4SZKTKHZESTVQMONREB2D
static immutable D = KeyPair(PublicKey([199, 173, 31, 147, 52, 77, 46, 145, 173, 216, 206, 19, 49, 130, 150, 72, 181, 58, 42, 38, 103, 201, 101, 83, 81, 242, 73, 78, 176, 99, 155, 18]), SecretKey([136, 252, 58, 107, 217, 138, 208, 113, 49, 96, 186, 85, 20, 139, 244, 113, 78, 249, 6, 246, 214, 45, 149, 134, 210, 0, 211, 103, 15, 252, 180, 87]), Seed([21, 209, 13, 90, 230, 208, 233, 200, 146, 19, 177, 88, 34, 108, 17, 96, 118, 42, 180, 255, 92, 90, 167, 172, 68, 99, 252, 232, 173, 60, 219, 214]));
/// E: GDE22BZJPPMELAQUZBQR7GTILNHMSUHS5J2BVMKU36LPW3SSKQU737SP
static immutable E = KeyPair(PublicKey([201, 173, 7, 41, 123, 216, 69, 130, 20, 200, 97, 31, 154, 104, 91, 78, 201, 80, 242, 234, 116, 26, 177, 84, 223, 150, 251, 110, 82, 84, 41, 253]), SecretKey([64, 10, 180, 177, 232, 198, 203, 135, 165, 120, 11, 110, 26, 113, 138, 106, 114, 167, 103, 164, 61, 158, 54, 77, 135, 55, 139, 228, 83, 236, 53, 65]), Seed([119, 113, 158, 127, 123, 37, 76, 17, 123, 225, 110, 94, 95, 97, 154, 153, 38, 190, 138, 85, 112, 1, 147, 5, 223, 150, 166, 25, 9, 10, 195, 8]));
/// F: GDF22EW2CZW2KVRSLFNGJQOTTDH5XWOK7MLINZPWO526WWXJMDXU3DPI
static immutable F = KeyPair(PublicKey([203, 173, 18, 218, 22, 109, 165, 86, 50, 89, 90, 100, 193, 211, 152, 207, 219, 217, 202, 251, 22, 134, 229, 246, 119, 117, 235, 90, 233, 96, 239, 77]), SecretKey([48, 98, 49, 194, 129, 59, 99, 63, 108, 216, 205, 140, 242, 239, 170, 129, 150, 12, 195, 106, 127, 102, 133, 24, 66, 110, 128, 246, 113, 155, 158, 79]), Seed([191, 233, 46, 2, 193, 153, 234, 46, 7, 220, 75, 52, 17, 204, 243, 0, 195, 146, 203, 97, 83, 194, 98, 44, 119, 191, 172, 196, 165, 178, 34, 119]));
/// G: GDG22B5FTPXE5THQMCTGDUC4LF2N4DFF44PGX2LIFG4WNUZZAT4L6ZGD
static immutable G = KeyPair(PublicKey([205, 173, 7, 165, 155, 238, 78, 204, 240, 96, 166, 97, 208, 92, 89, 116, 222, 12, 165, 231, 30, 107, 233, 104, 41, 185, 102, 211, 57, 4, 248, 191]), SecretKey([64, 185, 16, 9, 66, 227, 80, 19, 157, 120, 204, 79, 252, 137, 119, 40, 239, 28, 127, 89, 154, 199, 66, 12, 153, 183, 155, 1, 176, 240, 195, 121]), Seed([62, 48, 161, 123, 3, 213, 157, 202, 143, 66, 226, 234, 32, 82, 235, 135, 222, 32, 184, 133, 225, 15, 80, 224, 218, 254, 78, 149, 232, 189, 228, 165]));
/// H: GDH22SK6XFL6ZETRGFHYHIYXHPRSFR2RWT4RZYU5YNYIF6BIHCRKPSEI
static immutable H = KeyPair(PublicKey([207, 173, 73, 94, 185, 87, 236, 146, 113, 49, 79, 131, 163, 23, 59, 227, 34, 199, 81, 180, 249, 28, 226, 157, 195, 112, 130, 248, 40, 56, 162, 167]), SecretKey([32, 215, 230, 131, 62, 142, 249, 181, 121, 105, 156, 24, 1, 146, 225, 224, 95, 57, 139, 18, 198, 165, 134, 92, 83, 241, 108, 21, 242, 220, 211, 82]), Seed([102, 8, 109, 118, 100, 151, 231, 193, 37, 201, 147, 7, 10, 82, 233, 215, 252, 141, 54, 240, 211, 21, 253, 184, 75, 155, 80, 180, 177, 13, 241, 120]));
/// I: GDI22L72RGWY3BEFK2VUBWMJMSZU5SQNCQLN5FCF467RFIYN5KMY3YJT
static immutable I = KeyPair(PublicKey([209, 173, 47, 250, 137, 173, 141, 132, 133, 86, 171, 64, 217, 137, 100, 179, 78, 202, 13, 20, 22, 222, 148, 69, 231, 191, 18, 163, 13, 234, 153, 141]), SecretKey([24, 72, 10, 73, 100, 203, 105, 51, 27, 80, 206, 35, 16, 198, 99, 61, 166, 120, 95, 207, 12, 222, 47, 145, 126, 103, 77, 201, 158, 152, 166, 120]), Seed([184, 105, 1, 141, 39, 121, 166, 43, 146, 226, 69, 139, 71, 200, 166, 119, 111, 194, 78, 202, 236, 140, 231, 186, 140, 167, 193, 217, 186, 114, 51, 108]));
/// J: GDJ227UY64U4VLOW773KIT64RHHRZKRZFA7YS7MFMJK5WUDEQCEEEJUW
static immutable J = KeyPair(PublicKey([211, 173, 126, 152, 247, 41, 202, 173, 214, 255, 246, 164, 79, 220, 137, 207, 28, 170, 57, 40, 63, 137, 125, 133, 98, 85, 219, 80, 100, 128, 136, 66]), SecretKey([224, 108, 159, 202, 112, 236, 207, 141, 183, 131, 210, 149, 49, 72, 32, 74, 112, 106, 19, 124, 130, 207, 243, 194, 69, 4, 117, 81, 42, 29, 246, 111]), Seed([47, 42, 185, 111, 110, 141, 54, 190, 95, 88, 10, 148, 92, 143, 183, 249, 91, 243, 38, 134, 55, 41, 186, 202, 191, 2, 233, 103, 104, 206, 61, 85]));
/// K: GDK223SKRC2QD3FFIXSZJRL6SKQI4MLJNVJB4FE356OEIVVGWGBAWLRM
static immutable K = KeyPair(PublicKey([213, 173, 110, 74, 136, 181, 1, 236, 165, 69, 229, 148, 197, 126, 146, 160, 142, 49, 105, 109, 82, 30, 20, 155, 239, 156, 68, 86, 166, 177, 130, 11]), SecretKey([136, 187, 186, 22, 192, 126, 27, 143, 172, 2, 222, 128, 172, 203, 101, 34, 198, 191, 52, 37, 234, 203, 56, 234, 130, 243, 132, 193, 239, 20, 125, 99]), Seed([164, 80, 174, 237, 127, 100, 165, 237, 51, 212, 202, 243, 94, 31, 156, 33, 104, 42, 120, 233, 30, 240, 175, 127, 20, 185, 139, 158, 178, 209, 110, 86]));
/// L: GDL22GNXKCG5QLZ2WG7GUX5B7LXYVFUA4QU5IDKD5ESHBMGZXFUJHDUT
static immutable L = KeyPair(PublicKey([215, 173, 25, 183, 80, 141, 216, 47, 58, 177, 190, 106, 95, 161, 250, 239, 138, 150, 128, 228, 41, 212, 13, 67, 233, 36, 112, 176, 217, 185, 104, 147]), SecretKey([240, 253, 242, 117, 104, 160, 117, 233, 96, 204, 244, 245, 215, 22, 54, 218, 180, 206, 150, 173, 250, 4, 235, 28, 184, 211, 54, 130, 62, 188, 219, 108]), Seed([241, 34, 85, 160, 125, 167, 198, 135, 30, 77, 216, 131, 192, 104, 3, 227, 79, 99, 16, 225, 10, 246, 74, 6, 97, 242, 72, 151, 184, 66, 146, 252]));
/// M: GDM226GCA5DXXTS2YN3SNBUOFUACT7G57MWUG4F57HF65DDQ4DTRNP3Q
static immutable M = KeyPair(PublicKey([217, 173, 120, 194, 7, 71, 123, 206, 90, 195, 119, 38, 134, 142, 45, 0, 41, 252, 221, 251, 45, 67, 112, 189, 249, 203, 238, 140, 112, 224, 231, 22]), SecretKey([208, 45, 175, 126, 176, 42, 208, 95, 194, 193, 90, 124, 40, 49, 102, 48, 227, 211, 4, 99, 16, 212, 91, 220, 171, 68, 93, 79, 57, 53, 123, 123]), Seed([157, 20, 54, 35, 185, 67, 213, 44, 125, 16, 118, 46, 166, 48, 205, 24, 212, 150, 40, 175, 51, 83, 26, 119, 231, 118, 52, 18, 22, 215, 209, 160]));
/// N: GDN22BSZ6JCLELE4AJJJR4DYSIGK72Q37RLAEX2AH7CFULG4OUQB6A7I
static immutable N = KeyPair(PublicKey([219, 173, 6, 89, 242, 68, 178, 44, 156, 2, 82, 152, 240, 120, 146, 12, 175, 234, 27, 252, 86, 2, 95, 64, 63, 196, 90, 44, 220, 117, 32, 31]), SecretKey([80, 181, 207, 142, 12, 222, 78, 147, 170, 64, 39, 188, 63, 132, 205, 68, 135, 171, 219, 240, 210, 57, 29, 191, 41, 43, 155, 180, 106, 36, 121, 120]), Seed([36, 70, 240, 233, 139, 254, 148, 253, 0, 94, 244, 128, 118, 103, 131, 120, 26, 30, 52, 68, 127, 59, 219, 65, 186, 142, 132, 44, 188, 204, 2, 100]));
/// O: GDO22PFYWMU3YFLKDYP2PVM4PLX2D4BLJ2IRQMIHWJHFS3TZ6ITJMGPU
static immutable O = KeyPair(PublicKey([221, 173, 60, 184, 179, 41, 188, 21, 106, 30, 31, 167, 213, 156, 122, 239, 161, 240, 43, 78, 145, 24, 49, 7, 178, 78, 89, 110, 121, 242, 38, 150]), SecretKey([16, 32, 28, 132, 159, 6, 194, 211, 42, 182, 107, 169, 154, 194, 137, 177, 234, 93, 140, 227, 147, 38, 0, 116, 2, 92, 152, 133, 119, 22, 239, 73]), Seed([199, 144, 228, 92, 211, 113, 215, 10, 195, 76, 91, 53, 172, 100, 83, 55, 245, 58, 92, 155, 103, 77, 173, 169, 164, 239, 222, 159, 132, 250, 250, 123]));
/// P: GDP22NLZYRX2TBOBWTG46YCHB7WV76J56TMDZO5TDUQPIL7NCM4Q7TGU
static immutable P = KeyPair(PublicKey([223, 173, 53, 121, 196, 111, 169, 133, 193, 180, 205, 207, 96, 71, 15, 237, 95, 249, 61, 244, 216, 60, 187, 179, 29, 32, 244, 47, 237, 19, 57, 15]), SecretKey([224, 206, 166, 165, 245, 232, 250, 49, 202, 22, 120, 226, 95, 42, 84, 143, 181, 216, 147, 66, 235, 158, 61, 147, 190, 83, 198, 17, 29, 111, 85, 117]), Seed([234, 173, 205, 85, 74, 201, 189, 113, 29, 78, 21, 149, 123, 88, 167, 128, 59, 168, 75, 80, 213, 51, 197, 40, 32, 250, 85, 239, 86, 96, 10, 55]));
/// Q: GDQ22X67LUSWO4TN6D5KHXBQDBW43PDHI527ITKYK3Q6T3H5ZGXCAVEO
static immutable Q = KeyPair(PublicKey([225, 173, 95, 223, 93, 37, 103, 114, 109, 240, 250, 163, 220, 48, 24, 109, 205, 188, 103, 71, 117, 244, 77, 88, 86, 225, 233, 236, 253, 201, 174, 32]), SecretKey([120, 180, 19, 187, 117, 181, 174, 127, 215, 60, 130, 228, 4, 228, 11, 80, 186, 47, 242, 132, 62, 189, 214, 2, 125, 79, 238, 249, 215, 198, 190, 66]), Seed([88, 17, 84, 148, 141, 194, 206, 55, 233, 75, 248, 25, 47, 203, 23, 159, 27, 236, 19, 247, 63, 134, 48, 89, 138, 232, 202, 91, 186, 102, 217, 163]));
/// R: GDR22WW5K2CUC6LZFEDC7NQDN7QYKJ2K5SOVV3HK5JKJCRTWFUTQBQMV
static immutable R = KeyPair(PublicKey([227, 173, 90, 221, 86, 133, 65, 121, 121, 41, 6, 47, 182, 3, 111, 225, 133, 39, 74, 236, 157, 90, 236, 234, 234, 84, 145, 70, 118, 45, 39, 0]), SecretKey([232, 202, 193, 232, 225, 112, 90, 53, 29, 145, 17, 230, 255, 146, 247, 55, 149, 99, 152, 219, 140, 120, 106, 24, 20, 112, 148, 175, 212, 43, 222, 66]), Seed([49, 100, 108, 196, 182, 68, 185, 59, 198, 228, 98, 173, 180, 123, 107, 107, 197, 210, 94, 168, 127, 6, 199, 132, 18, 250, 187, 106, 239, 124, 181, 251]));
/// S: GDS22L4BX3KRBP6ZZEF3IT55GLM2GGM2WHJBCWOMLVRGJFUSLU6D7ICU
static immutable S = KeyPair(PublicKey([229, 173, 47, 129, 190, 213, 16, 191, 217, 201, 11, 180, 79, 189, 50, 217, 163, 25, 154, 177, 210, 17, 89, 204, 93, 98, 100, 150, 146, 93, 60, 63]), SecretKey([160, 108, 219, 188, 117, 100, 59, 20, 87, 150, 107, 195, 66, 58, 109, 78, 229, 236, 15, 252, 196, 53, 157, 15, 115, 216, 233, 215, 158, 15, 19, 104]), Seed([245, 72, 144, 66, 100, 213, 54, 115, 205, 175, 103, 54, 107, 241, 163, 236, 127, 221, 76, 96, 201, 1, 41, 193, 113, 208, 186, 216, 138, 6, 241, 178]));
/// T: GDT22QLGVCZWNQZGLC4SLHQPCLPD7MNLAFUDLMRX4MYLUDYTKIJFB6S4
static immutable T = KeyPair(PublicKey([231, 173, 65, 102, 168, 179, 102, 195, 38, 88, 185, 37, 158, 15, 18, 222, 63, 177, 171, 1, 104, 53, 178, 55, 227, 48, 186, 15, 19, 82, 18, 80]), SecretKey([56, 140, 210, 16, 29, 170, 180, 196, 52, 236, 238, 119, 70, 68, 32, 208, 214, 36, 95, 199, 218, 182, 190, 226, 234, 139, 207, 237, 247, 80, 172, 104]), Seed([209, 25, 13, 50, 2, 182, 153, 141, 56, 253, 12, 66, 217, 99, 49, 47, 49, 150, 52, 168, 171, 108, 84, 235, 210, 208, 86, 81, 101, 224, 28, 63]));
/// U: GDU22IOIYY2RDYILBCWAFNSGV2GFTS5NZXWY2LV77UCOJUSQCAGYCMZI
static immutable U = KeyPair(PublicKey([233, 173, 33, 200, 198, 53, 17, 225, 11, 8, 172, 2, 182, 70, 174, 140, 89, 203, 173, 205, 237, 141, 46, 191, 253, 4, 228, 210, 80, 16, 13, 129]), SecretKey([248, 156, 54, 24, 82, 63, 72, 215, 144, 104, 220, 215, 243, 216, 110, 80, 41, 126, 12, 234, 180, 235, 53, 211, 177, 61, 5, 80, 227, 215, 153, 110]), Seed([17, 146, 152, 178, 122, 74, 40, 22, 71, 123, 59, 144, 197, 33, 26, 153, 159, 235, 12, 166, 136, 225, 224, 126, 107, 225, 222, 63, 191, 183, 130, 191]));
/// V: GDV22PGJUL4VXAO65Q4SZZN2ODLCFYXF5WUC4GN26S3POWV4CYWQ2BHH
static immutable V = KeyPair(PublicKey([235, 173, 60, 201, 162, 249, 91, 129, 222, 236, 57, 44, 229, 186, 112, 214, 34, 226, 229, 237, 168, 46, 25, 186, 244, 182, 247, 90, 188, 22, 45, 13]), SecretKey([48, 192, 248, 84, 191, 166, 28, 249, 205, 93, 171, 18, 21, 157, 193, 36, 151, 103, 120, 71, 98, 96, 240, 111, 96, 59, 95, 65, 75, 131, 78, 82]), Seed([23, 43, 31, 87, 52, 103, 68, 208, 81, 220, 213, 43, 77, 45, 169, 69, 44, 178, 49, 216, 173, 37, 175, 103, 219, 218, 55, 180, 176, 42, 246, 10]));
/// W: GDW227EHGZKE67TON3H6AHDYDGS3Y5JLEGYWLJSUQR5BASE2HHQCTNPR
static immutable W = KeyPair(PublicKey([237, 173, 124, 135, 54, 84, 79, 126, 110, 110, 207, 224, 28, 120, 25, 165, 188, 117, 43, 33, 177, 101, 166, 84, 132, 122, 16, 72, 154, 57, 224, 41]), SecretKey([160, 189, 97, 111, 84, 58, 26, 21, 164, 91, 148, 90, 238, 104, 59, 254, 177, 125, 163, 54, 120, 54, 170, 165, 27, 84, 40, 111, 51, 222, 53, 112]), Seed([122, 63, 184, 84, 138, 151, 250, 229, 79, 185, 62, 71, 103, 89, 176, 2, 246, 250, 226, 239, 154, 233, 56, 44, 223, 54, 70, 121, 243, 0, 23, 94]));
/// X: GDX22ZICMUG43SWBIBXW67QMFDAGEYTODI3U7KUZU5OFVDJTCBVFPA7D
static immutable X = KeyPair(PublicKey([239, 173, 101, 2, 101, 13, 205, 202, 193, 64, 111, 111, 126, 12, 40, 192, 98, 98, 110, 26, 55, 79, 170, 153, 167, 92, 90, 141, 51, 16, 106, 87]), SecretKey([0, 15, 82, 214, 234, 15, 111, 187, 102, 102, 21, 216, 196, 54, 117, 42, 130, 40, 214, 211, 186, 207, 195, 184, 220, 57, 216, 225, 187, 252, 171, 73]), Seed([123, 12, 172, 31, 181, 195, 118, 100, 185, 101, 111, 97, 251, 212, 87, 85, 25, 30, 160, 253, 212, 151, 18, 181, 236, 154, 97, 106, 170, 223, 212, 226]));
/// Y: GDY22H6GFYR2DZOQKD3QOJBOL6RJW7PJYTQ44K3MU7A3YGV6L54WYUZU
static immutable Y = KeyPair(PublicKey([241, 173, 31, 198, 46, 35, 161, 229, 208, 80, 247, 7, 36, 46, 95, 162, 155, 125, 233, 196, 225, 206, 43, 108, 167, 193, 188, 26, 190, 95, 121, 108]), SecretKey([248, 52, 78, 83, 130, 228, 181, 12, 253, 155, 18, 188, 145, 194, 154, 17, 191, 93, 65, 84, 138, 89, 81, 30, 247, 12, 88, 169, 179, 52, 227, 87]), Seed([120, 134, 245, 100, 87, 40, 147, 3, 253, 153, 179, 249, 204, 43, 62, 131, 115, 90, 189, 42, 76, 164, 82, 40, 75, 182, 216, 105, 143, 104, 166, 23]));
/// Z: GDZ22FRGBYCFU4HHWZCHIWZXI5OTJT5LLRPOX3JF2QH4OMEUSDRQEA6K
static immutable Z = KeyPair(PublicKey([243, 173, 22, 38, 14, 4, 90, 112, 231, 182, 68, 116, 91, 55, 71, 93, 52, 207, 171, 92, 94, 235, 237, 37, 212, 15, 199, 48, 148, 144, 227, 2]), SecretKey([224, 164, 202, 122, 110, 126, 215, 187, 31, 176, 86, 220, 105, 182, 62, 133, 31, 205, 1, 190, 236, 42, 1, 2, 77, 69, 32, 222, 205, 234, 37, 91]), Seed([193, 213, 88, 244, 2, 90, 11, 51, 196, 18, 96, 93, 186, 209, 128, 163, 132, 72, 218, 47, 192, 122, 64, 60, 193, 88, 216, 164, 223, 175, 88, 57]));
/// AA: GDAA227YVGTKYZ2ITYECGQRMP4RZ4XNARGVUKD3CROYCKD2RMXQ5AYSU
static immutable AA = KeyPair(PublicKey([192, 13, 107, 248, 169, 166, 172, 103, 72, 158, 8, 35, 66, 44, 127, 35, 158, 93, 160, 137, 171, 69, 15, 98, 139, 176, 37, 15, 81, 101, 225, 208]), SecretKey([8, 249, 144, 71, 140, 30, 9, 101, 33, 221, 90, 116, 24, 248, 87, 181, 81, 93, 84, 34, 92, 107, 63, 196, 60, 128, 88, 241, 247, 233, 113, 83]), Seed([203, 85, 166, 152, 212, 59, 117, 254, 62, 255, 205, 223, 97, 29, 151, 99, 128, 158, 44, 37, 252, 123, 13, 135, 125, 179, 194, 141, 87, 138, 249, 203]));
/// AB: GDAB22GGZQS3K7DTVIEHB55JSZVBATS22WJGQHC2CPOKMWSDLDL2VYA3
static immutable AB = KeyPair(PublicKey([192, 29, 104, 198, 204, 37, 181, 124, 115, 170, 8, 112, 247, 169, 150, 106, 16, 78, 90, 213, 146, 104, 28, 90, 19, 220, 166, 90, 67, 88, 215, 170]), SecretKey([168, 104, 139, 183, 135, 84, 69, 118, 231, 128, 57, 103, 253, 165, 127, 156, 59, 215, 113, 23, 113, 192, 65, 212, 0, 164, 45, 167, 223, 49, 119, 117]), Seed([207, 181, 174, 58, 27, 239, 64, 211, 183, 50, 128, 240, 122, 25, 205, 99, 3, 59, 251, 25, 31, 62, 63, 142, 161, 96, 178, 193, 78, 105, 124, 80]));
/// AC: GDAC22HMM2SPGR7WZ2E77RGLIPBTZM6NR3IAOLFKMTQGXVYLC4JWO7RM
static immutable AC = KeyPair(PublicKey([192, 45, 104, 236, 102, 164, 243, 71, 246, 206, 137, 255, 196, 203, 67, 195, 60, 179, 205, 142, 208, 7, 44, 170, 100, 224, 107, 215, 11, 23, 19, 103]), SecretKey([136, 209, 242, 235, 178, 66, 62, 148, 124, 175, 61, 228, 1, 136, 34, 114, 162, 176, 222, 130, 111, 201, 212, 155, 24, 136, 155, 233, 144, 231, 62, 71]), Seed([48, 241, 176, 34, 247, 152, 171, 179, 203, 118, 107, 133, 199, 92, 147, 157, 158, 144, 22, 231, 149, 195, 123, 4, 77, 168, 61, 215, 0, 189, 241, 120]));
/// AD: GDAD22DCK5YYZ5LJXLMBYGNJXBA7IATZQYT522E5WTQONRWPEPVKRSXJ
static immutable AD = KeyPair(PublicKey([192, 61, 104, 98, 87, 113, 140, 245, 105, 186, 216, 28, 25, 169, 184, 65, 244, 2, 121, 134, 39, 221, 104, 157, 180, 224, 230, 198, 207, 35, 234, 168]), SecretKey([24, 95, 156, 226, 197, 129, 184, 96, 37, 219, 226, 254, 167, 156, 138, 82, 13, 156, 9, 121, 191, 162, 64, 42, 47, 108, 56, 12, 236, 26, 229, 124]), Seed([138, 91, 16, 247, 233, 146, 245, 118, 105, 226, 221, 57, 91, 57, 24, 222, 167, 111, 89, 93, 72, 6, 187, 9, 236, 108, 101, 163, 108, 171, 156, 39]));
/// AE: GDAE22L7FJ4IPLKJHDY3TEKGH3YZX7XZ43JWKRXPEKV7CDJJNDSACCFU
static immutable AE = KeyPair(PublicKey([192, 77, 105, 127, 42, 120, 135, 173, 73, 56, 241, 185, 145, 70, 62, 241, 155, 254, 249, 230, 211, 101, 70, 239, 34, 171, 241, 13, 41, 104, 228, 1]), SecretKey([224, 125, 106, 244, 155, 138, 142, 98, 114, 139, 145, 65, 212, 165, 128, 77, 162, 173, 41, 223, 141, 115, 179, 6, 42, 133, 95, 201, 65, 234, 186, 102]), Seed([22, 106, 23, 217, 58, 205, 3, 128, 70, 181, 5, 126, 202, 118, 187, 106, 232, 198, 121, 60, 166, 104, 208, 220, 53, 246, 167, 134, 173, 179, 39, 85]));
/// AF: GDAF22QVXVTEBYGIM7JKROLWHBAZLAM2PRUHXWFTGFUGRXHUUSAOOOKQ
static immutable AF = KeyPair(PublicKey([192, 93, 106, 21, 189, 102, 64, 224, 200, 103, 210, 168, 185, 118, 56, 65, 149, 129, 154, 124, 104, 123, 216, 179, 49, 104, 104, 220, 244, 164, 128, 231]), SecretKey([88, 100, 116, 117, 248, 43, 21, 71, 166, 152, 48, 122, 67, 190, 169, 107, 208, 113, 69, 61, 129, 213, 148, 43, 66, 109, 217, 160, 68, 249, 200, 109]), Seed([29, 200, 104, 64, 188, 198, 249, 89, 119, 222, 226, 41, 22, 77, 55, 77, 3, 230, 202, 142, 183, 61, 77, 224, 18, 215, 25, 73, 232, 153, 168, 86]));
/// AG: GDAG22ZLWU7BGIAVP6YDOBYYO5DNEWUNS6T5WBLTW5JDDK2XODFNEKVL
static immutable AG = KeyPair(PublicKey([192, 109, 107, 43, 181, 62, 19, 32, 21, 127, 176, 55, 7, 24, 119, 70, 210, 90, 141, 151, 167, 219, 5, 115, 183, 82, 49, 171, 87, 112, 202, 210]), SecretKey([152, 31, 191, 238, 172, 34, 15, 5, 14, 221, 187, 191, 113, 11, 51, 12, 245, 125, 111, 221, 153, 71, 19, 185, 172, 197, 89, 198, 250, 68, 13, 83]), Seed([162, 240, 73, 72, 34, 161, 137, 106, 107, 201, 220, 219, 168, 233, 91, 199, 41, 139, 222, 213, 240, 50, 101, 24, 132, 57, 168, 37, 89, 122, 164, 198]));
/// AH: GDAH22VGWOP4GMYLSMKEBEABMIVDAYTAUFYULWO2RDIZZHJ5YJSEA4CA
static immutable AH = KeyPair(PublicKey([192, 125, 106, 166, 179, 159, 195, 51, 11, 147, 20, 64, 144, 1, 98, 42, 48, 98, 96, 161, 113, 69, 217, 218, 136, 209, 156, 157, 61, 194, 100, 64]), SecretKey([128, 204, 197, 128, 23, 1, 214, 43, 219, 75, 157, 49, 234, 229, 145, 25, 135, 57, 194, 18, 3, 19, 101, 209, 118, 255, 14, 208, 79, 149, 218, 120]), Seed([40, 66, 71, 167, 230, 6, 209, 219, 255, 14, 104, 155, 144, 69, 133, 87, 242, 141, 199, 115, 175, 236, 119, 130, 208, 203, 246, 172, 119, 248, 93, 163]));
/// AI: GDAI22KKP5Z2SXFFQPSJCVRV56HLF52TH3DUNZZ5XXOM2QAI5THMTEHG
static immutable AI = KeyPair(PublicKey([192, 141, 105, 74, 127, 115, 169, 92, 165, 131, 228, 145, 86, 53, 239, 142, 178, 247, 83, 62, 199, 70, 231, 61, 189, 220, 205, 64, 8, 236, 206, 201]), SecretKey([88, 155, 230, 55, 147, 214, 215, 164, 212, 180, 43, 52, 62, 113, 163, 191, 214, 104, 36, 150, 10, 97, 192, 248, 21, 11, 255, 27, 253, 21, 110, 114]), Seed([55, 46, 211, 149, 26, 36, 88, 77, 63, 44, 146, 66, 186, 126, 80, 93, 145, 164, 53, 2, 51, 133, 93, 79, 127, 255, 111, 87, 56, 0, 192, 152]));
/// AJ: GDAJ22VT4BJ6OJKDNCQQMXDTP4B4XKKIKGFFCEDSAIKH2F72WPH54SWB
static immutable AJ = KeyPair(PublicKey([192, 157, 106, 179, 224, 83, 231, 37, 67, 104, 161, 6, 92, 115, 127, 3, 203, 169, 72, 81, 138, 81, 16, 114, 2, 20, 125, 23, 250, 179, 207, 222]), SecretKey([64, 108, 54, 143, 69, 95, 30, 96, 158, 172, 207, 194, 19, 242, 182, 237, 95, 92, 178, 129, 221, 47, 224, 208, 132, 193, 143, 104, 12, 20, 9, 103]), Seed([135, 225, 13, 161, 57, 150, 161, 127, 222, 105, 74, 225, 148, 9, 99, 227, 17, 227, 42, 94, 4, 107, 86, 181, 124, 253, 24, 217, 39, 235, 185, 37]));
/// AK: GDAK22A2VXNFAY2XO4KVDBOH675KMDOS3AR3WHBI7QJPVCTYBCO4B22G
static immutable AK = KeyPair(PublicKey([192, 173, 104, 26, 173, 218, 80, 99, 87, 119, 21, 81, 133, 199, 247, 250, 166, 13, 210, 216, 35, 187, 28, 40, 252, 18, 250, 138, 120, 8, 157, 192]), SecretKey([184, 154, 102, 191, 79, 131, 115, 238, 223, 207, 113, 167, 1, 39, 227, 160, 152, 106, 105, 148, 243, 203, 252, 100, 196, 35, 244, 54, 105, 242, 174, 78]), Seed([145, 111, 159, 0, 151, 234, 174, 121, 113, 236, 231, 183, 131, 240, 74, 254, 60, 56, 168, 237, 99, 21, 57, 120, 211, 77, 184, 41, 123, 123, 129, 201]));
/// AL: GDAL223FE6A4DWR67EKPILDL7JIVMEMGDFFMEOKPKEQ7FSLX33ISZMS7
static immutable AL = KeyPair(PublicKey([192, 189, 107, 101, 39, 129, 193, 218, 62, 249, 20, 244, 44, 107, 250, 81, 86, 17, 134, 25, 74, 194, 57, 79, 81, 33, 242, 201, 119, 222, 209, 44]), SecretKey([80, 29, 125, 176, 32, 83, 87, 183, 78, 101, 31, 180, 64, 19, 42, 130, 77, 201, 105, 134, 115, 50, 123, 14, 252, 91, 173, 157, 235, 13, 224, 117]), Seed([240, 111, 80, 127, 37, 64, 219, 174, 190, 24, 8, 23, 175, 168, 84, 209, 93, 80, 13, 168, 229, 79, 34, 113, 96, 243, 239, 145, 247, 209, 114, 99]));
/// AM: GDAM22GVYPG4QPNAUCX4KKBJD5KMW3ERK3R7VADYF5XOKTFUK4TFDZIQ
static immutable AM = KeyPair(PublicKey([192, 205, 104, 213, 195, 205, 200, 61, 160, 160, 175, 197, 40, 41, 31, 84, 203, 108, 145, 86, 227, 250, 128, 120, 47, 110, 229, 76, 180, 87, 38, 81]), SecretKey([248, 36, 63, 27, 180, 146, 156, 96, 68, 34, 63, 129, 211, 99, 17, 77, 6, 243, 185, 18, 216, 218, 6, 109, 107, 159, 36, 141, 124, 125, 112, 85]), Seed([7, 104, 103, 224, 42, 2, 105, 9, 231, 69, 58, 232, 43, 88, 177, 82, 122, 114, 87, 223, 45, 56, 70, 50, 41, 138, 34, 225, 101, 38, 81, 207]));
/// AN: GDAN222MOIYKUBCP7M6DCESCILP5P6AKWOATHEXN6OM3OTPPUQZTU2V5
static immutable AN = KeyPair(PublicKey([192, 221, 107, 76, 114, 48, 170, 4, 79, 251, 60, 49, 18, 66, 66, 223, 215, 248, 10, 179, 129, 51, 146, 237, 243, 153, 183, 77, 239, 164, 51, 58]), SecretKey([80, 67, 206, 49, 36, 81, 9, 55, 115, 32, 140, 213, 33, 129, 202, 102, 131, 178, 47, 87, 66, 165, 251, 8, 15, 150, 63, 14, 201, 28, 127, 68]), Seed([214, 13, 73, 132, 36, 20, 152, 142, 31, 75, 105, 165, 251, 126, 184, 225, 188, 56, 129, 199, 167, 237, 52, 225, 72, 19, 66, 98, 99, 155, 220, 141]));
/// AO: GDAO22VTOAUU6CIXB5CBKDB4NT7DM2UH2DCM5P6RLI7EXHHLFOWL55FG
static immutable AO = KeyPair(PublicKey([192, 237, 106, 179, 112, 41, 79, 9, 23, 15, 68, 21, 12, 60, 108, 254, 54, 106, 135, 208, 196, 206, 191, 209, 90, 62, 75, 156, 235, 43, 172, 190]), SecretKey([128, 214, 168, 29, 225, 255, 156, 158, 29, 9, 203, 51, 20, 242, 39, 159, 60, 100, 16, 198, 16, 71, 17, 192, 130, 124, 43, 233, 242, 13, 117, 72]), Seed([84, 205, 0, 249, 215, 121, 170, 80, 143, 204, 174, 249, 218, 32, 160, 132, 78, 235, 122, 207, 207, 36, 91, 182, 91, 90, 50, 223, 73, 9, 134, 179]));
/// AP: GDAP222RSUTWT6RW5XJNKG26VQQGJDUECYM6NZQ7ZSLOPVEYWKOES2AN
static immutable AP = KeyPair(PublicKey([192, 253, 107, 81, 149, 39, 105, 250, 54, 237, 210, 213, 27, 94, 172, 32, 100, 142, 132, 22, 25, 230, 230, 31, 204, 150, 231, 212, 152, 178, 156, 73]), SecretKey([56, 219, 110, 166, 138, 164, 207, 122, 255, 241, 77, 46, 83, 170, 168, 108, 235, 231, 197, 230, 42, 239, 121, 132, 209, 145, 224, 254, 52, 168, 33, 113]), Seed([179, 94, 16, 148, 139, 84, 5, 189, 117, 134, 80, 213, 253, 244, 156, 253, 199, 23, 210, 150, 107, 187, 131, 169, 99, 79, 124, 59, 50, 18, 7, 66]));
/// AQ: GDAQ22HYDB3SC5V7DB3WQ5DQBYXO5A5JVRLC5TVVKKZE3D2BSGKHAQTW
static immutable AQ = KeyPair(PublicKey([193, 13, 104, 248, 24, 119, 33, 118, 191, 24, 119, 104, 116, 112, 14, 46, 238, 131, 169, 172, 86, 46, 206, 181, 82, 178, 77, 143, 65, 145, 148, 112]), SecretKey([216, 235, 30, 190, 65, 211, 86, 88, 100, 50, 108, 243, 167, 108, 62, 134, 108, 63, 38, 94, 16, 168, 193, 224, 250, 238, 16, 176, 21, 84, 134, 102]), Seed([4, 212, 186, 130, 251, 157, 223, 208, 222, 42, 174, 193, 101, 61, 196, 181, 69, 139, 239, 184, 7, 27, 41, 116, 120, 76, 88, 64, 19, 43, 24, 193]));
/// AR: GDAR224UX7CRAPXCTS4MXKS4NXRKZXI3E6PFE5ZVG44GPEUGD6HTNNWG
static immutable AR = KeyPair(PublicKey([193, 29, 107, 148, 191, 197, 16, 62, 226, 156, 184, 203, 170, 92, 109, 226, 172, 221, 27, 39, 158, 82, 119, 53, 55, 56, 103, 146, 134, 31, 143, 54]), SecretKey([128, 31, 143, 140, 250, 181, 186, 10, 38, 79, 6, 208, 177, 125, 209, 242, 174, 183, 246, 28, 189, 80, 8, 182, 244, 214, 228, 186, 177, 128, 19, 105]), Seed([168, 110, 192, 105, 62, 170, 7, 212, 184, 31, 203, 111, 250, 189, 236, 21, 28, 126, 194, 138, 13, 192, 12, 175, 226, 183, 2, 118, 238, 173, 114, 143]));
/// AS: GDAS22RVCODZCM3YEHDBCS3OQPKOLRKRSJBBZVWJYWXXQCPBAFHGPJC5
static immutable AS = KeyPair(PublicKey([193, 45, 106, 53, 19, 135, 145, 51, 120, 33, 198, 17, 75, 110, 131, 212, 229, 197, 81, 146, 66, 28, 214, 201, 197, 175, 120, 9, 225, 1, 78, 103]), SecretKey([16, 219, 126, 243, 75, 151, 80, 222, 242, 37, 209, 168, 242, 50, 253, 6, 254, 35, 220, 149, 158, 230, 78, 203, 155, 77, 252, 153, 111, 148, 235, 106]), Seed([143, 248, 38, 24, 171, 114, 244, 215, 18, 131, 237, 27, 228, 168, 46, 82, 56, 159, 237, 87, 210, 153, 47, 48, 124, 103, 233, 219, 110, 151, 157, 74]));
/// AT: GDAT22QB7RZAC3Q2FX56JCTKEYZHMXUZ2BTZPKKBJVHENMUAADA5NRDA
static immutable AT = KeyPair(PublicKey([193, 61, 106, 1, 252, 114, 1, 110, 26, 45, 251, 228, 138, 106, 38, 50, 118, 94, 153, 208, 103, 151, 169, 65, 77, 78, 70, 178, 128, 0, 193, 214]), SecretKey([104, 8, 37, 159, 177, 63, 34, 50, 148, 68, 162, 192, 247, 226, 183, 32, 21, 25, 250, 150, 132, 181, 59, 129, 223, 134, 179, 158, 82, 80, 189, 68]), Seed([1, 10, 73, 23, 95, 159, 70, 247, 56, 153, 29, 85, 106, 33, 17, 18, 2, 177, 228, 180, 23, 110, 44, 234, 133, 128, 25, 102, 141, 247, 83, 17]));
/// AU: GDAU22NOHGHKXZNZ4F626DRNE4QDEQ6LEZ5VLAZLCHZ33PTFWDEZUOJK
static immutable AU = KeyPair(PublicKey([193, 77, 105, 174, 57, 142, 171, 229, 185, 225, 125, 175, 14, 45, 39, 32, 50, 67, 203, 38, 123, 85, 131, 43, 17, 243, 189, 190, 101, 176, 201, 154]), SecretKey([96, 70, 118, 247, 106, 148, 2, 35, 211, 70, 242, 201, 127, 29, 83, 139, 157, 74, 81, 17, 47, 236, 96, 154, 177, 197, 140, 75, 252, 207, 223, 68]), Seed([165, 60, 48, 243, 183, 211, 190, 86, 185, 125, 140, 30, 46, 226, 241, 44, 123, 128, 223, 99, 252, 232, 238, 113, 213, 221, 127, 110, 81, 51, 159, 27]));
/// AV: GDAV22MKX3ETP5R5VDR33R6676LV3MF6XQ6QQB6GGZDAS7TFBYANMKOE
static immutable AV = KeyPair(PublicKey([193, 93, 105, 138, 190, 201, 55, 246, 61, 168, 227, 189, 199, 222, 255, 151, 93, 176, 190, 188, 61, 8, 7, 198, 54, 70, 9, 126, 101, 14, 0, 214]), SecretKey([112, 62, 32, 88, 33, 196, 131, 211, 131, 107, 175, 1, 178, 6, 122, 14, 125, 206, 30, 189, 41, 209, 189, 67, 111, 98, 73, 209, 30, 49, 18, 121]), Seed([78, 219, 144, 5, 45, 244, 42, 195, 217, 214, 3, 202, 155, 191, 23, 214, 41, 178, 3, 46, 192, 161, 204, 201, 191, 161, 83, 247, 16, 64, 0, 142]));
/// AW: GDAW22FCXUGCEGBAKMYSXFSZFVHCUCYODMUO5VFMZSCDMTWZZFGKLPJU
static immutable AW = KeyPair(PublicKey([193, 109, 104, 162, 189, 12, 34, 24, 32, 83, 49, 43, 150, 89, 45, 78, 42, 11, 14, 27, 40, 238, 212, 172, 204, 132, 54, 78, 217, 201, 76, 165]), SecretKey([80, 52, 141, 212, 197, 88, 113, 144, 148, 187, 254, 209, 153, 53, 150, 90, 234, 189, 117, 109, 212, 93, 131, 129, 118, 163, 172, 1, 66, 187, 10, 108]), Seed([54, 246, 220, 213, 226, 176, 52, 2, 199, 59, 202, 87, 132, 222, 42, 122, 184, 31, 102, 119, 216, 252, 125, 90, 15, 124, 55, 150, 139, 231, 130, 94]));
/// AX: GDAX22AQLMZGOJZXS23GW3VBB74E3BYHOAU2GAIN4DQ2EN2V3YCTW6HF
static immutable AX = KeyPair(PublicKey([193, 125, 104, 16, 91, 50, 103, 39, 55, 150, 182, 107, 110, 161, 15, 248, 77, 135, 7, 112, 41, 163, 1, 13, 224, 225, 162, 55, 85, 222, 5, 59]), SecretKey([224, 113, 198, 151, 94, 1, 193, 235, 57, 205, 171, 21, 25, 69, 226, 140, 98, 251, 227, 18, 37, 119, 34, 115, 122, 176, 254, 45, 168, 215, 206, 66]), Seed([252, 234, 254, 207, 61, 250, 229, 195, 183, 6, 155, 243, 172, 6, 111, 235, 74, 182, 191, 210, 16, 138, 28, 141, 144, 159, 228, 97, 234, 30, 24, 213]));
/// AY: GDAY22JPTSNVOBCPHWVHAFRJAQZ66OX72E5B5PAO2FTHSJ5SVXJL4O2K
static immutable AY = KeyPair(PublicKey([193, 141, 105, 47, 156, 155, 87, 4, 79, 61, 170, 112, 22, 41, 4, 51, 239, 58, 255, 209, 58, 30, 188, 14, 209, 102, 121, 39, 178, 173, 210, 190]), SecretKey([200, 61, 191, 87, 218, 127, 177, 115, 201, 154, 163, 74, 250, 146, 83, 48, 121, 237, 50, 173, 252, 55, 201, 8, 219, 141, 156, 82, 146, 253, 186, 92]), Seed([225, 210, 86, 65, 94, 115, 117, 178, 82, 171, 228, 90, 189, 57, 217, 138, 5, 249, 18, 230, 14, 193, 68, 44, 86, 99, 35, 100, 68, 106, 111, 224]));
/// AZ: GDAZ225AF3UWYPAYKZELPET6WGHOVRF45R5JEN5WLLNHXRGJB2MB2W2V
static immutable AZ = KeyPair(PublicKey([193, 157, 107, 160, 46, 233, 108, 60, 24, 86, 72, 183, 146, 126, 177, 142, 234, 196, 188, 236, 122, 146, 55, 182, 90, 218, 123, 196, 201, 14, 152, 29]), SecretKey([32, 94, 157, 168, 6, 87, 76, 205, 240, 207, 51, 213, 228, 154, 3, 63, 116, 82, 59, 130, 224, 216, 151, 122, 109, 50, 136, 120, 220, 42, 52, 119]), Seed([5, 7, 98, 106, 65, 238, 156, 71, 165, 187, 197, 8, 52, 43, 203, 158, 246, 176, 225, 171, 145, 162, 49, 226, 251, 171, 227, 175, 64, 16, 155, 158]));
/// BA: GDBA22CVTCQPAYF5O326MRCJU3CN5XGMLTJUAMH6TM4PTM54N2ZNNTUK
static immutable BA = KeyPair(PublicKey([194, 13, 104, 85, 152, 160, 240, 96, 189, 118, 245, 230, 68, 73, 166, 196, 222, 220, 204, 92, 211, 64, 48, 254, 155, 56, 249, 179, 188, 110, 178, 214]), SecretKey([184, 85, 62, 204, 165, 59, 16, 213, 233, 254, 94, 77, 203, 32, 158, 157, 130, 240, 198, 138, 196, 173, 145, 157, 148, 208, 151, 29, 251, 232, 141, 107]), Seed([100, 74, 226, 224, 34, 190, 108, 58, 62, 137, 25, 158, 103, 150, 20, 95, 10, 37, 24, 80, 234, 27, 249, 149, 252, 1, 51, 193, 74, 168, 116, 155]));
/// BB: GDBB22R2SKSOFVR7EEREM22JGUAUZIUHA5NNGK2NP4KWG6MHPCWYHNKB
static immutable BB = KeyPair(PublicKey([194, 29, 106, 58, 146, 164, 226, 214, 63, 33, 34, 70, 107, 73, 53, 1, 76, 162, 135, 7, 90, 211, 43, 77, 127, 21, 99, 121, 135, 120, 173, 131]), SecretKey([32, 86, 197, 210, 250, 218, 54, 134, 122, 148, 99, 232, 206, 242, 102, 2, 76, 175, 212, 52, 59, 140, 5, 28, 8, 97, 59, 171, 152, 106, 204, 127]), Seed([94, 2, 65, 250, 194, 177, 20, 151, 238, 126, 218, 118, 167, 164, 148, 203, 115, 71, 92, 31, 94, 84, 229, 82, 157, 66, 195, 121, 53, 137, 189, 182]));
/// BC: GDBC22EG3MW4SCNUM2RAVRQZXQXPUQZJ62D4Y6KSAB76KEOOLDPVCI6L
static immutable BC = KeyPair(PublicKey([194, 45, 104, 134, 219, 45, 201, 9, 180, 102, 162, 10, 198, 25, 188, 46, 250, 67, 41, 246, 135, 204, 121, 82, 0, 127, 229, 17, 206, 88, 223, 81]), SecretKey([96, 181, 170, 124, 72, 164, 247, 151, 134, 84, 14, 62, 113, 49, 162, 193, 59, 123, 215, 109, 69, 50, 149, 233, 239, 44, 49, 216, 180, 106, 191, 69]), Seed([72, 129, 164, 239, 43, 58, 192, 175, 18, 22, 6, 189, 178, 128, 79, 124, 1, 237, 147, 227, 153, 233, 8, 95, 76, 156, 17, 39, 87, 243, 198, 219]));
/// BD: GDBD22HJC2V6VHVLFESQUTZPU2BW4GLAHR7MX4Q4FZMENGHFJ2YCBBGH
static immutable BD = KeyPair(PublicKey([194, 61, 104, 233, 22, 171, 234, 158, 171, 41, 37, 10, 79, 47, 166, 131, 110, 25, 96, 60, 126, 203, 242, 28, 46, 88, 70, 152, 229, 78, 176, 32]), SecretKey([88, 193, 71, 154, 56, 150, 23, 217, 20, 100, 149, 99, 104, 160, 127, 233, 17, 31, 46, 245, 216, 4, 31, 32, 238, 168, 110, 218, 227, 3, 16, 94]), Seed([223, 226, 103, 192, 143, 242, 111, 70, 85, 223, 90, 94, 156, 89, 7, 176, 133, 67, 75, 180, 180, 92, 145, 83, 6, 19, 70, 44, 84, 203, 211, 9]));
/// BE: GDBE22YQOCIJOUVRUFKK7Y22RVIY7PECRSSHGEKMWGFTKHTNVEA7SQBS
static immutable BE = KeyPair(PublicKey([194, 77, 107, 16, 112, 144, 151, 82, 177, 161, 84, 175, 227, 90, 141, 81, 143, 188, 130, 140, 164, 115, 17, 76, 177, 139, 53, 30, 109, 169, 1, 249]), SecretKey([192, 103, 56, 227, 79, 11, 100, 154, 4, 91, 70, 232, 113, 141, 153, 99, 227, 231, 115, 196, 238, 95, 62, 178, 23, 235, 127, 238, 224, 210, 2, 101]), Seed([238, 82, 241, 213, 89, 108, 218, 66, 37, 117, 106, 130, 29, 33, 114, 63, 38, 187, 13, 229, 26, 21, 155, 225, 213, 3, 174, 117, 86, 158, 5, 140]));
/// BF: GDBF22DRSUEOBBSLWFSMPVGYTCTHYBQMQ27DMMALAC5CLHRQONCD3OJW
static immutable BF = KeyPair(PublicKey([194, 93, 104, 113, 149, 8, 224, 134, 75, 177, 100, 199, 212, 216, 152, 166, 124, 6, 12, 134, 190, 54, 48, 11, 0, 186, 37, 158, 48, 115, 68, 61]), SecretKey([112, 21, 24, 58, 88, 35, 228, 228, 72, 161, 120, 224, 32, 177, 73, 21, 213, 182, 109, 186, 184, 35, 203, 102, 27, 30, 41, 116, 50, 174, 216, 66]), Seed([127, 4, 148, 143, 181, 118, 239, 208, 245, 179, 216, 125, 31, 45, 223, 21, 236, 247, 142, 205, 36, 43, 13, 194, 244, 237, 219, 31, 167, 143, 136, 109]));
/// BG: GDBG22N42WFOSG2YWVSJ2SXMAMC2C46SSQPASMZMNUKZZQVYJPY2YQ5V
static immutable BG = KeyPair(PublicKey([194, 109, 105, 188, 213, 138, 233, 27, 88, 181, 100, 157, 74, 236, 3, 5, 161, 115, 210, 148, 30, 9, 51, 44, 109, 21, 156, 194, 184, 75, 241, 172]), SecretKey([216, 211, 154, 239, 13, 148, 26, 81, 32, 155, 225, 196, 77, 71, 212, 217, 90, 185, 158, 61, 78, 15, 146, 26, 69, 59, 62, 55, 212, 101, 219, 81]), Seed([100, 72, 16, 176, 183, 16, 172, 252, 250, 161, 53, 230, 119, 105, 116, 56, 32, 18, 26, 179, 230, 10, 118, 59, 209, 245, 161, 12, 39, 145, 115, 68]));
/// BH: GDBH22QKLSS3XTR3DU35NLDJRCSOKUITMCQUHPIWCFH5VCOW36TAYO55
static immutable BH = KeyPair(PublicKey([194, 125, 106, 10, 92, 165, 187, 206, 59, 29, 55, 214, 172, 105, 136, 164, 229, 81, 19, 96, 161, 67, 189, 22, 17, 79, 218, 137, 214, 223, 166, 12]), SecretKey([88, 247, 253, 127, 94, 20, 221, 109, 144, 171, 161, 172, 235, 88, 179, 17, 253, 203, 237, 10, 220, 82, 112, 55, 154, 1, 121, 63, 237, 129, 146, 84]), Seed([145, 79, 127, 89, 210, 157, 115, 144, 89, 111, 234, 126, 211, 12, 52, 146, 201, 238, 82, 149, 83, 166, 185, 73, 65, 203, 89, 183, 145, 162, 243, 120]));
/// BI: GDBI22GIDMVZXOSRP4QL67RLNY32PIDPESH7WTEVX26LBJ3SPNU6LZQ3
static immutable BI = KeyPair(PublicKey([194, 141, 104, 200, 27, 43, 155, 186, 81, 127, 32, 191, 126, 43, 110, 55, 167, 160, 111, 36, 143, 251, 76, 149, 190, 188, 176, 167, 114, 123, 105, 229]), SecretKey([0, 30, 203, 108, 197, 87, 29, 61, 101, 52, 244, 93, 60, 70, 145, 223, 77, 64, 120, 8, 156, 68, 82, 44, 34, 172, 227, 182, 131, 23, 121, 106]), Seed([184, 132, 227, 102, 215, 199, 237, 101, 20, 92, 84, 125, 115, 193, 72, 29, 246, 132, 41, 11, 221, 202, 184, 153, 151, 205, 102, 9, 152, 171, 211, 211]));
/// BJ: GDBJ22CZF3EZHAEHSDPZUTOZCW545JZ3WGDPSGHZKDO5LW3HCYQFMY2Y
static immutable BJ = KeyPair(PublicKey([194, 157, 104, 89, 46, 201, 147, 128, 135, 144, 223, 154, 77, 217, 21, 187, 206, 167, 59, 177, 134, 249, 24, 249, 80, 221, 213, 219, 103, 22, 32, 86]), SecretKey([48, 157, 100, 250, 159, 84, 21, 53, 7, 160, 48, 36, 129, 181, 111, 117, 223, 7, 174, 251, 202, 28, 185, 66, 185, 238, 92, 172, 223, 77, 2, 83]), Seed([198, 19, 42, 85, 183, 156, 224, 43, 198, 75, 217, 234, 82, 28, 200, 173, 184, 154, 60, 178, 233, 10, 217, 27, 51, 206, 139, 37, 181, 242, 33, 236]));
/// BK: GDBK22G6MOSZFU747DATO7EJNPYUDPWGUI5WTUKDB4KR4U2OL2LFZC7U
static immutable BK = KeyPair(PublicKey([194, 173, 104, 222, 99, 165, 146, 211, 252, 248, 193, 55, 124, 137, 107, 241, 65, 190, 198, 162, 59, 105, 209, 67, 15, 21, 30, 83, 78, 94, 150, 92]), SecretKey([144, 16, 17, 51, 67, 255, 159, 245, 25, 201, 206, 21, 6, 5, 162, 63, 74, 80, 60, 4, 93, 165, 11, 172, 32, 174, 151, 105, 147, 30, 161, 117]), Seed([238, 137, 23, 46, 75, 201, 172, 82, 254, 95, 166, 216, 197, 75, 108, 2, 213, 215, 191, 173, 228, 65, 10, 79, 136, 6, 12, 153, 71, 220, 79, 54]));
/// BL: GDBL22Q57MPO3QQVDEYO44VDWXLSXY4IYXRPG6I3NNCRSW27GGGJFTM2
static immutable BL = KeyPair(PublicKey([194, 189, 106, 29, 251, 30, 237, 194, 21, 25, 48, 238, 114, 163, 181, 215, 43, 227, 136, 197, 226, 243, 121, 27, 107, 69, 25, 91, 95, 49, 140, 146]), SecretKey([112, 16, 100, 65, 63, 180, 72, 20, 246, 23, 106, 150, 237, 153, 27, 184, 142, 221, 248, 123, 188, 114, 197, 186, 135, 161, 219, 68, 234, 81, 169, 77]), Seed([54, 27, 186, 194, 196, 129, 182, 160, 77, 12, 23, 185, 183, 236, 186, 181, 14, 131, 54, 245, 173, 228, 86, 227, 166, 148, 170, 227, 148, 27, 255, 19]));
/// BM: GDBM224ERGVSXPJ3EA76ASO6RD3MODOJ5LJPONV4IK5GDXXSCBMKQDNZ
static immutable BM = KeyPair(PublicKey([194, 205, 107, 132, 137, 171, 43, 189, 59, 32, 63, 224, 73, 222, 136, 246, 199, 13, 201, 234, 210, 247, 54, 188, 66, 186, 97, 222, 242, 16, 88, 168]), SecretKey([8, 189, 241, 108, 186, 113, 165, 87, 165, 224, 188, 95, 57, 244, 143, 19, 37, 22, 155, 82, 153, 181, 189, 28, 110, 238, 118, 61, 13, 154, 227, 98]), Seed([187, 114, 197, 146, 0, 228, 103, 83, 243, 218, 10, 139, 239, 96, 150, 45, 249, 210, 140, 76, 105, 114, 48, 186, 215, 166, 219, 161, 152, 180, 137, 253]));
/// BN: GDBN224ZR7CIK6VNUNE3O2WVGRPZR3G7USGAGLEA6O6YQ3P6G47S3J3O
static immutable BN = KeyPair(PublicKey([194, 221, 107, 153, 143, 196, 133, 122, 173, 163, 73, 183, 106, 213, 52, 95, 152, 236, 223, 164, 140, 3, 44, 128, 243, 189, 136, 109, 254, 55, 63, 45]), SecretKey([64, 221, 244, 53, 22, 59, 204, 171, 4, 250, 150, 137, 99, 163, 234, 74, 151, 106, 230, 246, 87, 213, 61, 240, 94, 222, 129, 211, 97, 251, 110, 101]), Seed([227, 195, 220, 243, 97, 220, 86, 105, 55, 234, 94, 22, 82, 199, 97, 246, 159, 160, 136, 157, 22, 115, 126, 107, 152, 88, 102, 247, 67, 31, 166, 251]));
/// BO: GDBO224V44H6ERU3FJOCAYISGRULKXIBTO4H6DKHBSVQT66VIX2ZOITX
static immutable BO = KeyPair(PublicKey([194, 237, 107, 149, 231, 15, 226, 70, 155, 42, 92, 32, 97, 18, 52, 104, 181, 93, 1, 155, 184, 127, 13, 71, 12, 171, 9, 251, 213, 69, 245, 151]), SecretKey([24, 138, 135, 82, 53, 33, 223, 86, 115, 223, 62, 183, 61, 9, 173, 90, 52, 177, 248, 67, 147, 251, 20, 221, 7, 190, 89, 211, 195, 116, 109, 73]), Seed([74, 211, 80, 200, 230, 222, 173, 138, 230, 108, 196, 210, 21, 130, 178, 192, 31, 233, 216, 81, 1, 178, 214, 114, 73, 207, 116, 140, 38, 166, 172, 144]));
/// BP: GDBP224GJUA7IV4RF53HKJPJRUBV42M3WT7CBZB3E6HDRTD435OPJRCS
static immutable BP = KeyPair(PublicKey([194, 253, 107, 134, 77, 1, 244, 87, 145, 47, 118, 117, 37, 233, 141, 3, 94, 105, 155, 180, 254, 32, 228, 59, 39, 142, 56, 204, 124, 223, 92, 244]), SecretKey([224, 25, 195, 226, 35, 107, 84, 243, 188, 97, 122, 119, 218, 113, 126, 104, 155, 98, 184, 144, 153, 141, 52, 89, 137, 3, 32, 124, 101, 134, 198, 89]), Seed([91, 143, 208, 142, 220, 43, 80, 17, 3, 118, 203, 110, 176, 237, 49, 90, 249, 198, 248, 96, 132, 114, 47, 216, 78, 230, 117, 121, 76, 218, 18, 204]));
/// BQ: GDBQ22FROVYWYAH74UHFRFXQM5GWUK53YD3CT6PEFGGE25KWRNKJ2ZQV
static immutable BQ = KeyPair(PublicKey([195, 13, 104, 177, 117, 113, 108, 0, 255, 229, 14, 88, 150, 240, 103, 77, 106, 43, 187, 192, 246, 41, 249, 228, 41, 140, 77, 117, 86, 139, 84, 157]), SecretKey([176, 179, 9, 61, 146, 200, 153, 224, 12, 200, 109, 50, 137, 184, 151, 41, 123, 23, 140, 114, 218, 81, 43, 65, 57, 67, 159, 221, 172, 65, 5, 107]), Seed([210, 162, 41, 69, 72, 243, 29, 164, 115, 83, 214, 170, 95, 20, 118, 58, 236, 39, 3, 179, 97, 175, 112, 247, 15, 99, 69, 133, 238, 146, 133, 230]));
/// BR: GDBR22CYVB25L4AOFNWPDC6XIENU6VEUSL3V526E2FG3XKVR5LBJKA7Z
static immutable BR = KeyPair(PublicKey([195, 29, 104, 88, 168, 117, 213, 240, 14, 43, 108, 241, 139, 215, 65, 27, 79, 84, 148, 146, 247, 94, 235, 196, 209, 77, 187, 170, 177, 234, 194, 149]), SecretKey([184, 81, 30, 43, 162, 244, 179, 38, 6, 8, 142, 67, 212, 189, 45, 82, 7, 81, 93, 72, 144, 5, 46, 217, 202, 73, 226, 153, 181, 8, 91, 120]), Seed([47, 104, 57, 56, 92, 14, 27, 220, 166, 187, 83, 113, 207, 235, 138, 171, 250, 5, 191, 35, 170, 110, 192, 67, 135, 3, 116, 77, 22, 213, 68, 189]));
/// BS: GDBS22K5R4A6BZZIHD7BYY7G66F67ANRMU4K7VBTPTA6IT2PWAIRVVBF
static immutable BS = KeyPair(PublicKey([195, 45, 105, 93, 143, 1, 224, 231, 40, 56, 254, 28, 99, 230, 247, 139, 239, 129, 177, 101, 56, 175, 212, 51, 124, 193, 228, 79, 79, 176, 17, 26]), SecretKey([96, 217, 14, 73, 78, 184, 168, 161, 231, 47, 80, 210, 15, 45, 78, 119, 223, 102, 72, 246, 81, 92, 217, 208, 8, 0, 87, 19, 23, 92, 43, 88]), Seed([174, 90, 248, 40, 32, 213, 211, 254, 226, 83, 90, 198, 248, 183, 69, 33, 112, 142, 210, 40, 156, 138, 192, 250, 178, 105, 88, 199, 250, 62, 70, 203]));
/// BT: GDBT22D2OIQH5SZSKBB56MBNKIBULJINT4T33WJD7PDYAENQKBLKDMTR
static immutable BT = KeyPair(PublicKey([195, 61, 104, 122, 114, 32, 126, 203, 50, 80, 67, 223, 48, 45, 82, 3, 69, 165, 13, 159, 39, 189, 217, 35, 251, 199, 128, 17, 176, 80, 86, 161]), SecretKey([224, 138, 130, 93, 228, 47, 183, 11, 70, 121, 142, 149, 241, 177, 63, 225, 214, 2, 158, 28, 136, 117, 238, 196, 221, 39, 176, 106, 36, 62, 226, 85]), Seed([142, 141, 111, 154, 191, 160, 214, 47, 51, 143, 212, 85, 185, 17, 113, 210, 175, 191, 180, 208, 178, 210, 18, 95, 183, 215, 246, 231, 188, 160, 58, 15]));
/// BU: GDBU22TRV7M7BP6N4LMOOI5YLAEC7LH7AOOO7UV674TRJLZIFOV5L5XV
static immutable BU = KeyPair(PublicKey([195, 77, 106, 113, 175, 217, 240, 191, 205, 226, 216, 231, 35, 184, 88, 8, 47, 172, 255, 3, 156, 239, 210, 190, 255, 39, 20, 175, 40, 43, 171, 213]), SecretKey([16, 247, 90, 164, 138, 147, 200, 60, 193, 124, 6, 228, 154, 52, 59, 231, 86, 230, 157, 217, 78, 195, 118, 234, 158, 114, 239, 222, 149, 153, 45, 106]), Seed([229, 89, 93, 27, 173, 144, 91, 162, 160, 242, 196, 151, 94, 195, 1, 38, 204, 84, 35, 21, 94, 203, 226, 191, 225, 23, 50, 146, 52, 242, 217, 97]));
/// BV: GDBV22OMAZAXETJIAVAAFFPFBF7DPU2BIOO3CNUZDKORJYG5DWEHDJPK
static immutable BV = KeyPair(PublicKey([195, 93, 105, 204, 6, 65, 114, 77, 40, 5, 64, 2, 149, 229, 9, 126, 55, 211, 65, 67, 157, 177, 54, 153, 26, 157, 20, 224, 221, 29, 136, 113]), SecretKey([208, 51, 160, 120, 186, 180, 105, 37, 14, 109, 224, 216, 64, 73, 99, 49, 63, 111, 102, 135, 98, 108, 242, 0, 146, 196, 25, 68, 155, 166, 8, 119]), Seed([122, 114, 94, 145, 116, 203, 184, 13, 172, 147, 196, 110, 172, 123, 81, 136, 72, 44, 1, 39, 142, 233, 62, 138, 21, 26, 18, 45, 2, 140, 205, 4]));
/// BW: GDBW22FLX36FG74DAWUVF4PCZDXGIYQUUDHEVXOI66ISIBD3FRPFT3MQ
static immutable BW = KeyPair(PublicKey([195, 109, 104, 171, 190, 252, 83, 127, 131, 5, 169, 82, 241, 226, 200, 238, 100, 98, 20, 160, 206, 74, 221, 200, 247, 145, 36, 4, 123, 44, 94, 89]), SecretKey([128, 179, 5, 213, 145, 195, 132, 169, 148, 83, 97, 213, 55, 150, 118, 42, 120, 180, 82, 111, 51, 145, 164, 186, 171, 222, 59, 173, 108, 1, 52, 99]), Seed([64, 113, 117, 113, 63, 85, 242, 32, 242, 30, 66, 114, 45, 45, 104, 203, 144, 158, 175, 188, 65, 206, 22, 80, 34, 136, 202, 61, 91, 75, 59, 199]));
/// BX: GDBX22S6R6CWUHIWJQEAQXLWXTUSRBRKE5CFKG5EXEL4362KGJKZMVHQ
static immutable BX = KeyPair(PublicKey([195, 125, 106, 94, 143, 133, 106, 29, 22, 76, 8, 8, 93, 118, 188, 233, 40, 134, 42, 39, 68, 85, 27, 164, 185, 23, 205, 251, 74, 50, 85, 150]), SecretKey([80, 189, 212, 7, 206, 28, 108, 125, 87, 3, 215, 204, 31, 192, 204, 72, 126, 135, 96, 200, 146, 133, 205, 145, 244, 242, 208, 125, 28, 151, 217, 127]), Seed([159, 138, 46, 58, 173, 252, 224, 237, 26, 99, 26, 189, 150, 165, 54, 202, 213, 252, 129, 231, 229, 29, 156, 197, 101, 150, 140, 114, 78, 225, 172, 133]));
/// BY: GDBY22B24CYSPDG5EITECF5LHCFCZM2AEESGA3UU6NLR52IJ2NWBDVOF
static immutable BY = KeyPair(PublicKey([195, 141, 104, 58, 224, 177, 39, 140, 221, 34, 38, 65, 23, 171, 56, 138, 44, 179, 64, 33, 36, 96, 110, 148, 243, 87, 30, 233, 9, 211, 108, 17]), SecretKey([152, 18, 14, 146, 147, 84, 77, 239, 254, 232, 170, 126, 41, 242, 222, 201, 28, 27, 187, 67, 189, 114, 187, 113, 181, 155, 221, 156, 157, 38, 57, 77]), Seed([39, 112, 89, 152, 58, 12, 238, 143, 85, 122, 199, 126, 188, 57, 5, 19, 238, 142, 217, 248, 224, 24, 44, 159, 249, 135, 98, 214, 140, 161, 20, 16]));
/// BZ: GDBZ22YBAB2TVIKBPIPZ2QAUBAG6WNL55BJMXXISMD3WCUMAN2XTCDN6
static immutable BZ = KeyPair(PublicKey([195, 157, 107, 1, 0, 117, 58, 161, 65, 122, 31, 157, 64, 20, 8, 13, 235, 53, 125, 232, 82, 203, 221, 18, 96, 247, 97, 81, 128, 110, 175, 49]), SecretKey([152, 220, 188, 129, 63, 156, 203, 21, 97, 97, 145, 68, 11, 53, 79, 38, 193, 73, 220, 165, 51, 189, 152, 118, 89, 234, 139, 31, 233, 253, 138, 98]), Seed([227, 243, 124, 71, 191, 105, 1, 101, 131, 165, 187, 12, 138, 107, 183, 187, 73, 25, 98, 28, 85, 92, 112, 196, 247, 103, 75, 252, 226, 156, 228, 128]));
/// CA: GDCA22QHZGOLSHM3XQQLJP6ZCZZIHVXQFEB63IIWZNGZYZTBLG4FWWC3
static immutable CA = KeyPair(PublicKey([196, 13, 106, 7, 201, 156, 185, 29, 155, 188, 32, 180, 191, 217, 22, 114, 131, 214, 240, 41, 3, 237, 161, 22, 203, 77, 156, 102, 97, 89, 184, 91]), SecretKey([56, 254, 114, 223, 80, 117, 26, 197, 102, 42, 44, 165, 48, 34, 245, 235, 130, 235, 173, 206, 208, 3, 225, 172, 198, 74, 52, 141, 167, 226, 112, 97]), Seed([220, 3, 244, 192, 230, 106, 131, 61, 240, 204, 38, 113, 181, 112, 126, 29, 127, 119, 71, 158, 66, 121, 65, 88, 14, 31, 181, 111, 159, 24, 227, 209]));
/// CB: GDCB22SZRET5COIW5IGIDTDTS7Y5SKEHRLZWXOYQ7RODSDAO2HY574YM
static immutable CB = KeyPair(PublicKey([196, 29, 106, 89, 137, 39, 209, 57, 22, 234, 12, 129, 204, 115, 151, 241, 217, 40, 135, 138, 243, 107, 187, 16, 252, 92, 57, 12, 14, 209, 241, 223]), SecretKey([40, 121, 94, 190, 25, 80, 220, 120, 198, 255, 81, 144, 73, 130, 32, 31, 116, 244, 201, 65, 106, 62, 19, 204, 132, 111, 167, 40, 112, 169, 183, 70]), Seed([33, 92, 228, 223, 155, 186, 70, 212, 38, 180, 119, 99, 48, 229, 107, 222, 86, 112, 50, 247, 27, 174, 86, 83, 223, 100, 147, 249, 94, 15, 19, 67]));
/// CC: GDCC22H2Y3ABAOZC6GLESODU3VYKK5JFYYCZM75DX25Y52LM23LGGZAB
static immutable CC = KeyPair(PublicKey([196, 45, 104, 250, 198, 192, 16, 59, 34, 241, 150, 73, 56, 116, 221, 112, 165, 117, 37, 198, 5, 150, 127, 163, 190, 187, 142, 233, 108, 214, 214, 99]), SecretKey([208, 114, 88, 49, 107, 80, 239, 212, 184, 37, 28, 231, 44, 193, 18, 253, 157, 36, 7, 252, 126, 98, 180, 2, 146, 197, 195, 194, 17, 52, 238, 127]), Seed([6, 56, 146, 74, 246, 129, 189, 30, 133, 255, 189, 154, 150, 12, 252, 97, 50, 184, 139, 201, 55, 215, 22, 173, 201, 17, 11, 162, 113, 183, 117, 65]));
/// CD: GDCD22GZUAY27U7VHAIZXVK7JFD4GGBGP4O4Z2QDI7VAW4FI3QSYF6NE
static immutable CD = KeyPair(PublicKey([196, 61, 104, 217, 160, 49, 175, 211, 245, 56, 17, 155, 213, 95, 73, 71, 195, 24, 38, 127, 29, 204, 234, 3, 71, 234, 11, 112, 168, 220, 37, 130]), SecretKey([72, 250, 241, 157, 252, 210, 53, 152, 99, 250, 18, 188, 133, 75, 193, 215, 115, 159, 118, 244, 201, 65, 77, 6, 251, 163, 196, 28, 98, 3, 44, 79]), Seed([147, 19, 42, 25, 139, 226, 240, 171, 222, 121, 230, 125, 37, 249, 162, 183, 30, 164, 89, 50, 62, 160, 176, 238, 163, 24, 81, 5, 30, 3, 71, 253]));
/// CE: GDCE22XHIBUPSEDM6TYWA56YOYRUNDSVUUJAGF4LZ4SMGJWRMEYSD2Q7
static immutable CE = KeyPair(PublicKey([196, 77, 106, 231, 64, 104, 249, 16, 108, 244, 241, 96, 119, 216, 118, 35, 70, 142, 85, 165, 18, 3, 23, 139, 207, 36, 195, 38, 209, 97, 49, 33]), SecretKey([216, 104, 122, 81, 212, 184, 175, 215, 85, 9, 105, 101, 250, 133, 180, 126, 207, 100, 147, 152, 208, 184, 198, 194, 113, 94, 122, 244, 82, 215, 98, 107]), Seed([192, 63, 52, 199, 28, 81, 82, 115, 154, 98, 44, 187, 67, 254, 76, 226, 120, 41, 22, 74, 175, 158, 117, 153, 176, 130, 71, 192, 74, 124, 162, 185]));
/// CF: GDCF22MHACYIIDQ7GGNLU54DOWKRGH2725JMFAURNIABISDSEU4YWD2Y
static immutable CF = KeyPair(PublicKey([196, 93, 105, 135, 0, 176, 132, 14, 31, 49, 154, 186, 119, 131, 117, 149, 19, 31, 95, 215, 82, 194, 130, 145, 106, 0, 20, 72, 114, 37, 57, 139]), SecretKey([80, 111, 58, 20, 30, 65, 13, 225, 171, 41, 12, 113, 94, 198, 138, 167, 75, 156, 113, 106, 241, 196, 56, 60, 75, 95, 164, 245, 142, 65, 192, 64]), Seed([80, 187, 94, 21, 230, 186, 208, 143, 49, 11, 40, 82, 37, 166, 47, 61, 86, 198, 129, 9, 46, 165, 255, 136, 68, 121, 215, 213, 4, 231, 17, 50]));
/// CG: GDCG22M6GFQKAWOD3PODLOURD2TAV2NYOVHUZHT3B3MR7QP2U6POJGMW
static immutable CG = KeyPair(PublicKey([196, 109, 105, 158, 49, 96, 160, 89, 195, 219, 220, 53, 186, 145, 30, 166, 10, 233, 184, 117, 79, 76, 158, 123, 14, 217, 31, 193, 250, 167, 158, 228]), SecretKey([184, 137, 47, 55, 208, 174, 241, 247, 35, 54, 151, 69, 43, 169, 47, 24, 62, 65, 168, 179, 142, 191, 128, 46, 123, 248, 228, 178, 172, 84, 76, 103]), Seed([103, 174, 155, 130, 0, 204, 111, 65, 79, 123, 155, 108, 234, 136, 55, 208, 174, 190, 129, 29, 165, 143, 185, 222, 88, 103, 113, 91, 70, 112, 202, 42]));
/// CH: GDCH22NVIM7UZHBZAM2XFGAVMKITUDTVAS6JWFAKE7YQA2WOO3QIH75Y
static immutable CH = KeyPair(PublicKey([196, 125, 105, 181, 67, 63, 76, 156, 57, 3, 53, 114, 152, 21, 98, 145, 58, 14, 117, 4, 188, 155, 20, 10, 39, 241, 0, 106, 206, 118, 224, 131]), SecretKey([144, 184, 217, 36, 211, 210, 12, 245, 252, 88, 225, 191, 16, 7, 124, 149, 142, 254, 226, 47, 190, 65, 89, 113, 140, 9, 117, 158, 56, 199, 99, 91]), Seed([252, 102, 232, 19, 205, 119, 99, 40, 243, 24, 71, 33, 67, 145, 230, 55, 34, 148, 22, 255, 190, 4, 209, 55, 80, 11, 226, 43, 192, 113, 236, 131]));
/// CI: GDCI22BEC7GYOW3G2DG7PUPFUGWWODN5LBYCIUDKOCR5IVJVS452QWF2
static immutable CI = KeyPair(PublicKey([196, 141, 104, 36, 23, 205, 135, 91, 102, 208, 205, 247, 209, 229, 161, 173, 103, 13, 189, 88, 112, 36, 80, 106, 112, 163, 212, 85, 53, 151, 59, 168]), SecretKey([248, 144, 126, 192, 71, 96, 32, 102, 234, 154, 41, 114, 61, 21, 202, 30, 61, 197, 74, 138, 136, 170, 106, 136, 174, 49, 172, 82, 154, 80, 27, 91]), Seed([85, 249, 196, 149, 64, 148, 105, 132, 131, 77, 128, 66, 113, 45, 223, 144, 208, 3, 140, 252, 97, 133, 146, 74, 255, 207, 100, 65, 209, 153, 130, 112]));
/// CJ: GDCJ22VU66H3VG6VFUTQAHOWYU5OGRYTHIYFGGIBGQM5HSFKHWBAJ2L4
static immutable CJ = KeyPair(PublicKey([196, 157, 106, 180, 247, 143, 186, 155, 213, 45, 39, 0, 29, 214, 197, 58, 227, 71, 19, 58, 48, 83, 25, 1, 52, 25, 211, 200, 170, 61, 130, 4]), SecretKey([136, 56, 138, 12, 194, 207, 246, 150, 114, 180, 143, 142, 250, 210, 39, 172, 216, 164, 161, 59, 56, 126, 11, 100, 186, 38, 235, 132, 10, 75, 179, 77]), Seed([109, 158, 198, 20, 188, 180, 127, 4, 138, 166, 246, 141, 95, 195, 27, 187, 138, 107, 21, 224, 141, 165, 5, 195, 154, 17, 107, 55, 204, 154, 240, 104]));
/// CK: GDCK226IN4NS7ABWI34I7S7VST3QPTKEUZDN4MPEWCQUL27WIRVO2OA5
static immutable CK = KeyPair(PublicKey([196, 173, 107, 200, 111, 27, 47, 128, 54, 70, 248, 143, 203, 245, 148, 247, 7, 205, 68, 166, 70, 222, 49, 228, 176, 161, 69, 235, 246, 68, 106, 237]), SecretKey([0, 15, 20, 93, 105, 110, 194, 133, 125, 189, 51, 87, 155, 55, 240, 170, 160, 71, 130, 236, 206, 218, 170, 173, 68, 210, 70, 249, 121, 156, 40, 104]), Seed([225, 114, 140, 143, 133, 196, 3, 50, 39, 73, 67, 62, 58, 196, 202, 130, 141, 62, 63, 109, 210, 49, 252, 134, 201, 244, 119, 1, 219, 115, 225, 49]));
/// CL: GDCL22VTWCM2K3TJO3IX3FSQVSAIHLHN46GOIRNNLA3CMARCOR4SP4PA
static immutable CL = KeyPair(PublicKey([196, 189, 106, 179, 176, 153, 165, 110, 105, 118, 209, 125, 150, 80, 172, 128, 131, 172, 237, 231, 140, 228, 69, 173, 88, 54, 38, 2, 34, 116, 121, 39]), SecretKey([88, 189, 243, 168, 53, 169, 44, 179, 104, 113, 194, 49, 131, 239, 129, 219, 56, 15, 252, 174, 95, 60, 54, 16, 56, 98, 226, 240, 87, 126, 96, 101]), Seed([118, 111, 82, 134, 184, 169, 10, 34, 140, 176, 41, 184, 182, 88, 238, 2, 42, 235, 78, 252, 33, 127, 96, 170, 226, 123, 23, 113, 198, 66, 107, 29]));
/// CM: GDCM22EZZTXWFUKGFTJA43LKD62MTM4CT74KCLG3DN34RHQKE7YICNBX
static immutable CM = KeyPair(PublicKey([196, 205, 104, 153, 204, 239, 98, 209, 70, 44, 210, 14, 109, 106, 31, 180, 201, 179, 130, 159, 248, 161, 44, 219, 27, 119, 200, 158, 10, 39, 240, 129]), SecretKey([232, 2, 104, 230, 24, 208, 10, 115, 124, 139, 95, 235, 114, 131, 157, 121, 46, 83, 250, 231, 18, 8, 138, 63, 156, 188, 17, 211, 63, 230, 132, 83]), Seed([91, 140, 181, 144, 125, 149, 168, 139, 34, 214, 88, 196, 104, 58, 108, 173, 94, 77, 150, 157, 82, 7, 203, 137, 126, 222, 255, 140, 148, 105, 151, 168]));
/// CN: GDCN22DCX2575YXM32OAXF73YFQRI3CVN2LFZJYAZXC4NE5ZBWR2DJQ3
static immutable CN = KeyPair(PublicKey([196, 221, 104, 98, 190, 187, 254, 226, 236, 222, 156, 11, 151, 251, 193, 97, 20, 108, 85, 110, 150, 92, 167, 0, 205, 197, 198, 147, 185, 13, 163, 161]), SecretKey([16, 175, 113, 64, 228, 164, 237, 230, 127, 220, 45, 20, 33, 232, 235, 151, 178, 210, 155, 51, 131, 127, 26, 203, 0, 75, 240, 193, 212, 154, 126, 101]), Seed([10, 84, 205, 57, 227, 111, 47, 87, 2, 234, 86, 202, 170, 110, 191, 65, 173, 145, 96, 6, 189, 5, 2, 132, 9, 99, 28, 1, 134, 125, 22, 78]));
/// CO: GDCO22CEH656ZBWVHAPJGPQNFEHMQ2MBSGSM7H47FTUATC4JRFNQH3YD
static immutable CO = KeyPair(PublicKey([196, 237, 104, 68, 63, 187, 236, 134, 213, 56, 30, 147, 62, 13, 41, 14, 200, 105, 129, 145, 164, 207, 159, 159, 44, 232, 9, 139, 137, 137, 91, 3]), SecretKey([8, 96, 159, 165, 84, 131, 150, 194, 251, 64, 22, 96, 107, 74, 25, 141, 127, 60, 56, 61, 77, 99, 51, 34, 193, 142, 215, 51, 17, 174, 6, 100]), Seed([41, 175, 184, 201, 247, 58, 71, 227, 211, 29, 131, 32, 99, 145, 86, 121, 132, 248, 83, 224, 134, 213, 124, 160, 84, 254, 101, 228, 95, 139, 176, 248]));
/// CP: GDCP22JZVQDL6JRGLVLDZLAXMPBVZXA26MPNS72F6AANOOIVABWESWFG
static immutable CP = KeyPair(PublicKey([196, 253, 105, 57, 172, 6, 191, 38, 38, 93, 86, 60, 172, 23, 99, 195, 92, 220, 26, 243, 30, 217, 127, 69, 240, 0, 215, 57, 21, 0, 108, 73]), SecretKey([8, 216, 130, 35, 83, 96, 192, 141, 239, 46, 221, 41, 237, 169, 79, 94, 106, 114, 123, 242, 11, 144, 197, 13, 129, 167, 200, 17, 213, 19, 210, 74]), Seed([108, 110, 250, 222, 84, 83, 134, 45, 249, 123, 190, 130, 156, 87, 31, 31, 71, 178, 0, 170, 152, 67, 127, 63, 83, 60, 167, 41, 254, 119, 178, 74]));
/// CQ: GDCQ22IXSIYU5OM6Q556TU5DSEDO3NHYVDM5SVJ6INPRNCGZGJMVCHX2
static immutable CQ = KeyPair(PublicKey([197, 13, 105, 23, 146, 49, 78, 185, 158, 135, 123, 233, 211, 163, 145, 6, 237, 180, 248, 168, 217, 217, 85, 62, 67, 95, 22, 136, 217, 50, 89, 81]), SecretKey([184, 135, 62, 135, 59, 191, 32, 134, 111, 213, 152, 174, 197, 120, 184, 34, 20, 151, 83, 179, 244, 231, 64, 181, 78, 66, 111, 59, 12, 17, 150, 108]), Seed([243, 70, 79, 126, 112, 51, 139, 112, 175, 189, 181, 11, 243, 61, 203, 220, 16, 101, 228, 65, 223, 205, 202, 77, 239, 146, 144, 57, 154, 171, 206, 255]));
/// CR: GDCR22FTZG2T4LOJM2RKHDRPN5AUDDUKV6QPSOSAIYQ7UHYII6I2IOJA
static immutable CR = KeyPair(PublicKey([197, 29, 104, 179, 201, 181, 62, 45, 201, 102, 162, 163, 142, 47, 111, 65, 65, 142, 138, 175, 160, 249, 58, 64, 70, 33, 250, 31, 8, 71, 145, 164]), SecretKey([72, 122, 72, 21, 194, 81, 252, 47, 231, 32, 82, 49, 39, 190, 137, 123, 21, 230, 230, 53, 67, 83, 243, 239, 142, 27, 224, 151, 237, 219, 39, 108]), Seed([100, 213, 144, 99, 102, 205, 239, 202, 236, 218, 91, 48, 146, 15, 234, 11, 64, 227, 41, 173, 206, 80, 99, 233, 100, 61, 182, 79, 70, 37, 206, 155]));
/// CS: GDCS22RNRN65EA6MFFHCVOD3QG5BQGG4F72Y2KM6NIP24YULU273XA2L
static immutable CS = KeyPair(PublicKey([197, 45, 106, 45, 139, 125, 210, 3, 204, 41, 78, 42, 184, 123, 129, 186, 24, 24, 220, 47, 245, 141, 41, 158, 106, 31, 174, 98, 139, 166, 191, 187]), SecretKey([192, 41, 84, 141, 91, 228, 214, 198, 79, 32, 162, 213, 167, 16, 75, 134, 85, 132, 235, 113, 85, 201, 139, 75, 241, 150, 236, 46, 255, 6, 199, 84]), Seed([163, 37, 24, 15, 41, 161, 39, 58, 4, 214, 74, 107, 188, 233, 185, 217, 92, 124, 217, 104, 27, 3, 151, 31, 5, 171, 124, 117, 146, 190, 38, 18]));
/// CT: GDCT22AWWZM4MA6UPRKG6OVO3LHU74YZN42JR3DAZOALQTZJEORA7E2R
static immutable CT = KeyPair(PublicKey([197, 61, 104, 22, 182, 89, 198, 3, 212, 124, 84, 111, 58, 174, 218, 207, 79, 243, 25, 111, 52, 152, 236, 96, 203, 128, 184, 79, 41, 35, 162, 15]), SecretKey([176, 203, 174, 179, 182, 220, 242, 112, 187, 45, 1, 150, 163, 247, 210, 34, 61, 192, 91, 232, 174, 178, 232, 96, 239, 107, 188, 82, 245, 85, 128, 112]), Seed([229, 127, 235, 114, 119, 15, 21, 70, 71, 39, 92, 2, 117, 146, 56, 93, 251, 207, 161, 252, 188, 169, 145, 51, 59, 171, 1, 140, 109, 223, 31, 154]));
/// CU: GDCU22CQAR2SQVTEPK3H7S3A2CY4VVWLUJELTA2ARPQ6MLFKIBHZBANB
static immutable CU = KeyPair(PublicKey([197, 77, 104, 80, 4, 117, 40, 86, 100, 122, 182, 127, 203, 96, 208, 177, 202, 214, 203, 162, 72, 185, 131, 64, 139, 225, 230, 44, 170, 64, 79, 144]), SecretKey([48, 208, 122, 9, 119, 94, 212, 202, 166, 241, 137, 250, 63, 52, 214, 13, 73, 215, 114, 222, 10, 53, 89, 226, 147, 23, 145, 73, 18, 221, 13, 69]), Seed([156, 186, 237, 89, 222, 48, 24, 191, 36, 111, 243, 225, 82, 69, 31, 104, 116, 187, 240, 233, 91, 246, 219, 209, 183, 243, 163, 31, 81, 251, 117, 185]));
/// CV: GDCV22ZDUIMOBRLIX3PEBOBMZQVQZMFKAMTHKMJHQUEB2W7HD4VFRSZG
static immutable CV = KeyPair(PublicKey([197, 93, 107, 35, 162, 24, 224, 197, 104, 190, 222, 64, 184, 44, 204, 43, 12, 176, 170, 3, 38, 117, 49, 39, 133, 8, 29, 91, 231, 31, 42, 88]), SecretKey([96, 228, 254, 81, 30, 166, 130, 249, 134, 114, 172, 228, 130, 194, 207, 95, 5, 176, 115, 109, 106, 139, 232, 187, 105, 146, 127, 129, 52, 216, 92, 99]), Seed([57, 206, 43, 173, 232, 162, 6, 174, 35, 201, 152, 70, 105, 41, 217, 239, 33, 77, 120, 243, 26, 190, 32, 31, 85, 29, 203, 105, 55, 23, 230, 1]));
/// CW: GDCW223BPKURYBEDT7FO55TIVAG3OMLZDY5PPSIU3RKK543LYJLBDSOK
static immutable CW = KeyPair(PublicKey([197, 109, 107, 97, 122, 169, 28, 4, 131, 159, 202, 238, 246, 104, 168, 13, 183, 49, 121, 30, 58, 247, 201, 20, 220, 84, 174, 243, 107, 194, 86, 17]), SecretKey([248, 141, 126, 184, 197, 166, 83, 194, 114, 0, 119, 44, 35, 15, 202, 211, 235, 199, 211, 236, 89, 175, 231, 103, 80, 116, 96, 149, 91, 163, 138, 83]), Seed([13, 70, 134, 4, 159, 148, 160, 64, 55, 12, 109, 37, 46, 163, 100, 249, 16, 28, 62, 239, 208, 49, 209, 214, 203, 124, 92, 232, 0, 218, 139, 245]));
/// CX: GDCX2274MLGYEK2LVSVHYFOH33BIT5PMTB246KAS4SNPQYMM4E7WCRN3
static immutable CX = KeyPair(PublicKey([197, 125, 107, 252, 98, 205, 130, 43, 75, 172, 170, 124, 21, 199, 222, 194, 137, 245, 236, 152, 117, 207, 40, 18, 228, 154, 248, 97, 140, 225, 63, 97]), SecretKey([72, 158, 181, 182, 118, 159, 250, 186, 225, 111, 113, 100, 242, 150, 191, 112, 41, 109, 68, 77, 94, 93, 181, 162, 66, 110, 237, 189, 49, 94, 232, 85]), Seed([175, 231, 94, 4, 228, 93, 12, 172, 203, 52, 161, 158, 16, 211, 232, 196, 11, 198, 179, 102, 67, 17, 113, 248, 80, 40, 72, 188, 200, 124, 149, 7]));
/// CY: GDCY224G6XURB7AXULIJOHJGGAUCP4LHZILXAPPU7DR22R6WRV3QNIGE
static immutable CY = KeyPair(PublicKey([197, 141, 107, 134, 245, 233, 16, 252, 23, 162, 208, 151, 29, 38, 48, 40, 39, 241, 103, 202, 23, 112, 61, 244, 248, 227, 173, 71, 214, 141, 119, 6]), SecretKey([120, 206, 227, 178, 170, 251, 141, 119, 60, 38, 234, 56, 200, 32, 15, 153, 158, 109, 197, 87, 51, 14, 140, 154, 246, 216, 184, 40, 81, 175, 183, 64]), Seed([8, 130, 187, 162, 98, 172, 160, 5, 198, 31, 254, 20, 184, 179, 148, 198, 127, 210, 253, 112, 105, 185, 160, 64, 185, 245, 170, 105, 75, 4, 162, 0]));
/// CZ: GDCZ22EZHHFTUVZTYZJGHAWZKKBKM6ZCIE7YH62SH67R77XAXGIGJ6SC
static immutable CZ = KeyPair(PublicKey([197, 157, 104, 153, 57, 203, 58, 87, 51, 198, 82, 99, 130, 217, 82, 130, 166, 123, 34, 65, 63, 131, 251, 82, 63, 191, 31, 254, 224, 185, 144, 100]), SecretKey([224, 244, 68, 244, 145, 204, 158, 208, 15, 180, 133, 240, 205, 242, 128, 94, 97, 120, 124, 198, 114, 21, 150, 70, 212, 235, 175, 92, 139, 34, 110, 100]), Seed([195, 161, 143, 225, 74, 223, 127, 164, 66, 65, 190, 104, 227, 113, 106, 57, 152, 164, 60, 220, 59, 82, 152, 169, 121, 189, 178, 143, 160, 103, 122, 199]));
/// DA: GDDA22VM7PFOLGMGOQR6MVSNUFUUKOXGNAAON36VI62AWURPYMZKNWLG
static immutable DA = KeyPair(PublicKey([198, 13, 106, 172, 251, 202, 229, 153, 134, 116, 35, 230, 86, 77, 161, 105, 69, 58, 230, 104, 0, 230, 239, 213, 71, 180, 11, 82, 47, 195, 50, 166]), SecretKey([216, 131, 178, 196, 89, 53, 183, 50, 151, 236, 47, 253, 172, 165, 70, 158, 154, 110, 70, 248, 77, 106, 214, 249, 100, 48, 176, 4, 159, 5, 202, 109]), Seed([187, 253, 69, 81, 202, 144, 119, 150, 183, 206, 251, 101, 210, 77, 89, 247, 54, 221, 188, 217, 113, 193, 161, 208, 22, 181, 249, 117, 212, 174, 123, 186]));
/// DB: GDDB22OXNCEFLCU4KGVKTOFH5TOV5MBYMQSNXAXT64KMTDANMEN4XF23
static immutable DB = KeyPair(PublicKey([198, 29, 105, 215, 104, 136, 85, 138, 156, 81, 170, 169, 184, 167, 236, 221, 94, 176, 56, 100, 36, 219, 130, 243, 247, 20, 201, 140, 13, 97, 27, 203]), SecretKey([160, 113, 179, 141, 253, 78, 115, 5, 254, 52, 166, 152, 43, 215, 231, 91, 157, 162, 210, 121, 228, 133, 154, 90, 205, 152, 118, 14, 69, 70, 96, 68]), Seed([254, 226, 166, 87, 72, 6, 43, 54, 185, 250, 102, 132, 177, 134, 4, 208, 189, 140, 245, 147, 241, 159, 226, 238, 95, 232, 169, 154, 200, 180, 216, 82]));
/// DC: GDDC22X44G44NYD5KLGHPCVKDNX4LTDQZRT24DDEFSNY4GH4GWDW4RR4
static immutable DC = KeyPair(PublicKey([198, 45, 106, 252, 225, 185, 198, 224, 125, 82, 204, 119, 138, 170, 27, 111, 197, 204, 112, 204, 103, 174, 12, 100, 44, 155, 142, 24, 252, 53, 135, 110]), SecretKey([24, 170, 118, 179, 2, 248, 108, 161, 180, 199, 209, 133, 193, 3, 200, 85, 180, 203, 71, 152, 168, 164, 15, 21, 88, 57, 184, 188, 125, 238, 135, 64]), Seed([225, 69, 125, 166, 112, 44, 230, 75, 65, 81, 154, 61, 216, 64, 231, 62, 36, 186, 92, 106, 122, 178, 92, 129, 226, 105, 172, 179, 199, 24, 145, 50]));
/// DD: GDDD22ML3GAD24TTSGMRCUJXUCLNNNWXMPD54VF5MQSNFV7VAB4BTMAI
static immutable DD = KeyPair(PublicKey([198, 61, 105, 139, 217, 128, 61, 114, 115, 145, 153, 17, 81, 55, 160, 150, 214, 182, 215, 99, 199, 222, 84, 189, 100, 36, 210, 215, 245, 0, 120, 25]), SecretKey([104, 248, 171, 173, 43, 228, 214, 139, 113, 215, 62, 133, 27, 157, 191, 192, 38, 236, 170, 115, 98, 68, 68, 213, 32, 68, 78, 212, 71, 92, 31, 116]), Seed([127, 124, 29, 177, 103, 152, 166, 89, 160, 214, 107, 235, 239, 195, 94, 136, 169, 224, 128, 252, 158, 162, 132, 34, 14, 173, 191, 174, 12, 185, 32, 5]));
/// DE: GDDE22VJS5AYUYZAGG4CG6HLP5SA4LVECMFGW6EW6FMDQNR3V46IBQGJ
static immutable DE = KeyPair(PublicKey([198, 77, 106, 169, 151, 65, 138, 99, 32, 49, 184, 35, 120, 235, 127, 100, 14, 46, 164, 19, 10, 107, 120, 150, 241, 88, 56, 54, 59, 175, 60, 128]), SecretKey([120, 64, 236, 65, 184, 65, 13, 10, 59, 44, 15, 23, 1, 224, 28, 98, 147, 188, 78, 113, 173, 109, 150, 66, 74, 127, 46, 41, 34, 23, 177, 85]), Seed([52, 5, 91, 6, 28, 104, 165, 91, 161, 151, 218, 109, 246, 66, 105, 128, 233, 103, 37, 190, 202, 135, 30, 44, 79, 217, 127, 42, 124, 45, 240, 201]));
/// DF: GDDF22D4LYDCLIJHJEAN6WLYKXK7EPIGCR6IDSFGXIGWOUTS3DZB4T2A
static immutable DF = KeyPair(PublicKey([198, 93, 104, 124, 94, 6, 37, 161, 39, 73, 0, 223, 89, 120, 85, 213, 242, 61, 6, 20, 124, 129, 200, 166, 186, 13, 103, 82, 114, 216, 242, 30]), SecretKey([64, 149, 242, 108, 186, 163, 5, 200, 57, 35, 46, 176, 17, 247, 90, 68, 253, 191, 155, 27, 153, 157, 132, 152, 126, 196, 214, 140, 253, 52, 90, 74]), Seed([148, 233, 242, 249, 235, 41, 82, 29, 188, 165, 56, 164, 76, 208, 245, 52, 11, 93, 220, 87, 145, 201, 132, 122, 104, 212, 19, 167, 140, 32, 243, 66]));
/// DG: GDDG22V5H34MEINQIVHKNAEOYE7CG4RLQ2KLZ4DFVT7U73XJYKN5EIB2
static immutable DG = KeyPair(PublicKey([198, 109, 106, 189, 62, 248, 194, 33, 176, 69, 78, 166, 128, 142, 193, 62, 35, 114, 43, 134, 148, 188, 240, 101, 172, 255, 79, 238, 233, 194, 155, 210]), SecretKey([208, 100, 125, 82, 8, 142, 94, 216, 215, 167, 116, 177, 102, 200, 67, 25, 220, 111, 226, 164, 83, 136, 39, 78, 114, 76, 151, 69, 62, 217, 115, 65]), Seed([60, 148, 22, 126, 148, 140, 127, 228, 240, 176, 188, 167, 14, 211, 252, 59, 86, 109, 181, 105, 227, 75, 187, 182, 121, 225, 60, 175, 169, 134, 112, 112]));
/// DH: GDDH22TIBPVENK47G7SD4RSNWVE57RL5L2HS6BTYZBAX2JN2IKTKX265
static immutable DH = KeyPair(PublicKey([198, 125, 106, 104, 11, 234, 70, 171, 159, 55, 228, 62, 70, 77, 181, 73, 223, 197, 125, 94, 143, 47, 6, 120, 200, 65, 125, 37, 186, 66, 166, 171]), SecretKey([232, 141, 140, 211, 24, 46, 177, 86, 112, 115, 172, 20, 209, 2, 226, 128, 238, 64, 171, 42, 200, 57, 227, 202, 62, 158, 151, 245, 233, 186, 124, 77]), Seed([137, 210, 1, 125, 0, 202, 63, 212, 181, 87, 199, 242, 63, 138, 146, 89, 221, 228, 177, 148, 151, 147, 33, 128, 178, 127, 132, 237, 216, 10, 36, 222]));
/// DI: GDDI22U6FZQMJDTV5XTKSBF6QXY6WAPEOZM3CXHKSPKL6UQLKLR3ZHSY
static immutable DI = KeyPair(PublicKey([198, 141, 106, 158, 46, 96, 196, 142, 117, 237, 230, 169, 4, 190, 133, 241, 235, 1, 228, 118, 89, 177, 92, 234, 147, 212, 191, 82, 11, 82, 227, 188]), SecretKey([72, 218, 226, 125, 249, 85, 204, 253, 175, 53, 175, 255, 97, 73, 10, 22, 80, 41, 3, 14, 38, 237, 72, 45, 36, 21, 137, 89, 230, 4, 38, 76]), Seed([235, 28, 77, 219, 98, 44, 122, 36, 36, 42, 147, 11, 10, 145, 161, 93, 26, 173, 43, 220, 149, 27, 177, 14, 125, 68, 234, 206, 251, 73, 124, 181]));
/// DJ: GDDJ22WIK3ITUCQ6JSGGG3JOUXHGEKOUX65HMC6NHKMC4ONQCT3GMQAJ
static immutable DJ = KeyPair(PublicKey([198, 157, 106, 200, 86, 209, 58, 10, 30, 76, 140, 99, 109, 46, 165, 206, 98, 41, 212, 191, 186, 118, 11, 205, 58, 152, 46, 57, 176, 20, 246, 102]), SecretKey([8, 251, 184, 94, 29, 138, 198, 194, 61, 97, 120, 224, 176, 223, 219, 198, 204, 235, 28, 208, 196, 74, 2, 171, 80, 29, 209, 117, 145, 77, 129, 101]), Seed([204, 85, 248, 226, 55, 205, 238, 46, 74, 52, 94, 33, 217, 31, 19, 118, 128, 30, 144, 78, 149, 64, 159, 176, 76, 106, 95, 68, 223, 101, 218, 212]));
/// DK: GDDK22AY6BMKFEXKGAN5XCGB2TSOU43ES5O4IM6ZLFAH5VAMUFIDPU4T
static immutable DK = KeyPair(PublicKey([198, 173, 104, 24, 240, 88, 162, 146, 234, 48, 27, 219, 136, 193, 212, 228, 234, 115, 100, 151, 93, 196, 51, 217, 89, 64, 126, 212, 12, 161, 80, 55]), SecretKey([200, 106, 202, 242, 89, 115, 183, 41, 3, 0, 77, 206, 13, 208, 50, 158, 127, 192, 131, 45, 236, 170, 129, 172, 135, 40, 242, 177, 214, 224, 106, 99]), Seed([196, 7, 90, 170, 144, 144, 99, 153, 151, 165, 33, 172, 226, 35, 0, 126, 167, 212, 166, 242, 243, 46, 51, 206, 234, 178, 222, 140, 246, 93, 183, 54]));
/// DL: GDDL2274WD5KUO7SJJLSRYDV6TKYAKEG773YEL3DJYULTT723ZBFBSTB
static immutable DL = KeyPair(PublicKey([198, 189, 107, 252, 176, 250, 170, 59, 242, 74, 87, 40, 224, 117, 244, 213, 128, 40, 134, 255, 247, 130, 47, 99, 78, 40, 185, 207, 250, 222, 66, 80]), SecretKey([48, 52, 80, 203, 160, 108, 173, 29, 165, 191, 77, 225, 161, 98, 242, 92, 55, 212, 232, 121, 198, 35, 134, 8, 32, 185, 61, 206, 208, 87, 238, 93]), Seed([129, 115, 186, 9, 47, 217, 27, 200, 18, 106, 108, 250, 80, 248, 31, 156, 47, 94, 69, 199, 179, 153, 146, 200, 9, 196, 71, 0, 130, 162, 51, 47]));
/// DM: GDDM22PNPMRYQANYB3ZKRCBLQAGP7BLJW4QBEDP4HW5GM7UISDW7WOC2
static immutable DM = KeyPair(PublicKey([198, 205, 105, 237, 123, 35, 136, 1, 184, 14, 242, 168, 136, 43, 128, 12, 255, 133, 105, 183, 32, 18, 13, 252, 61, 186, 102, 126, 136, 144, 237, 251]), SecretKey([96, 180, 148, 106, 224, 17, 126, 112, 138, 3, 187, 208, 39, 178, 27, 192, 222, 80, 76, 70, 184, 190, 151, 34, 206, 204, 77, 143, 7, 157, 63, 90]), Seed([33, 204, 197, 237, 126, 219, 159, 155, 157, 186, 68, 205, 60, 187, 178, 19, 239, 50, 113, 81, 94, 223, 178, 156, 222, 173, 41, 229, 240, 239, 247, 118]));
/// DN: GDDN22GXA5FMEXZTUWV44BIDIE2QKQYCLY5BD5BZJTWI2GK6TOY2Q3DG
static immutable DN = KeyPair(PublicKey([198, 221, 104, 215, 7, 74, 194, 95, 51, 165, 171, 206, 5, 3, 65, 53, 5, 67, 2, 94, 58, 17, 244, 57, 76, 236, 141, 25, 94, 155, 177, 168]), SecretKey([232, 51, 231, 196, 34, 9, 228, 175, 48, 236, 173, 94, 227, 23, 247, 3, 254, 206, 46, 34, 112, 81, 162, 157, 176, 47, 191, 24, 17, 200, 147, 90]), Seed([224, 82, 87, 77, 123, 110, 134, 252, 42, 12, 97, 228, 146, 0, 154, 73, 1, 4, 141, 55, 121, 28, 76, 216, 139, 115, 69, 97, 91, 215, 156, 130]));
/// DO: GDDO22QZHCJPZKZUXFKRUF5FME3HQA7UG7LC7TPBRTGE6NU77TUSS2ZC
static immutable DO = KeyPair(PublicKey([198, 237, 106, 25, 56, 146, 252, 171, 52, 185, 85, 26, 23, 165, 97, 54, 120, 3, 244, 55, 214, 47, 205, 225, 140, 204, 79, 54, 159, 252, 233, 41]), SecretKey([208, 141, 40, 46, 214, 205, 219, 206, 152, 203, 185, 226, 5, 23, 253, 86, 116, 236, 90, 82, 247, 21, 17, 142, 254, 193, 172, 74, 179, 48, 134, 79]), Seed([240, 128, 1, 4, 133, 46, 162, 78, 9, 206, 169, 12, 235, 213, 169, 237, 108, 94, 73, 115, 55, 251, 150, 167, 38, 207, 46, 100, 163, 199, 44, 84]));
/// DP: GDDP22MJRLUBLTT6QOKQCQVSLNBGQITOCBMIN454RRPJOAHZGIYWE2PV
static immutable DP = KeyPair(PublicKey([198, 253, 105, 137, 138, 232, 21, 206, 126, 131, 149, 1, 66, 178, 91, 66, 104, 34, 110, 16, 88, 134, 243, 188, 140, 94, 151, 0, 249, 50, 49, 98]), SecretKey([120, 33, 136, 217, 109, 215, 224, 103, 84, 44, 202, 208, 138, 129, 151, 147, 220, 66, 36, 41, 184, 126, 114, 66, 165, 218, 231, 228, 209, 21, 161, 123]), Seed([252, 57, 163, 124, 205, 191, 212, 11, 94, 30, 61, 68, 187, 186, 185, 216, 118, 32, 26, 125, 68, 193, 180, 41, 118, 204, 156, 102, 174, 102, 2, 209]));
/// DQ: GDDQ22N4XOJU2RH6T36FIX6P3GOPR4LAOQUX7RJJOZZKPO34EKNHLSIK
static immutable DQ = KeyPair(PublicKey([199, 13, 105, 188, 187, 147, 77, 68, 254, 158, 252, 84, 95, 207, 217, 156, 248, 241, 96, 116, 41, 127, 197, 41, 118, 114, 167, 187, 124, 34, 154, 117]), SecretKey([96, 105, 201, 154, 201, 214, 199, 109, 22, 53, 237, 86, 163, 159, 100, 201, 235, 127, 113, 186, 217, 51, 203, 228, 152, 50, 149, 15, 230, 220, 207, 99]), Seed([55, 225, 194, 147, 175, 187, 77, 187, 103, 204, 146, 138, 74, 34, 139, 92, 37, 25, 250, 132, 171, 38, 26, 212, 106, 176, 219, 196, 70, 79, 41, 9]));
/// DR: GDDR22EPSGVCQTT2WI52LZAZDU5PBB5VHMWK6MX3TSQC3VA3I4UFEGCD
static immutable DR = KeyPair(PublicKey([199, 29, 104, 143, 145, 170, 40, 78, 122, 178, 59, 165, 228, 25, 29, 58, 240, 135, 181, 59, 44, 175, 50, 251, 156, 160, 45, 212, 27, 71, 40, 82]), SecretKey([200, 4, 182, 241, 196, 57, 191, 36, 32, 176, 154, 205, 184, 85, 138, 63, 61, 95, 48, 97, 45, 143, 191, 244, 255, 226, 33, 81, 187, 45, 117, 87]), Seed([147, 177, 64, 8, 70, 140, 146, 181, 123, 36, 89, 98, 236, 25, 248, 246, 121, 17, 5, 186, 125, 124, 141, 5, 157, 17, 233, 153, 203, 243, 68, 247]));
/// DS: GDDS22QEWHGTXHD2N7UHVK7Y6R3OBNXIZMAUDWWBKMAEQQEWSICTFWWS
static immutable DS = KeyPair(PublicKey([199, 45, 106, 4, 177, 205, 59, 156, 122, 111, 232, 122, 171, 248, 244, 118, 224, 182, 232, 203, 1, 65, 218, 193, 83, 0, 72, 64, 150, 146, 5, 50]), SecretKey([80, 12, 103, 82, 225, 157, 62, 138, 7, 200, 206, 62, 21, 14, 125, 113, 99, 61, 147, 64, 77, 36, 254, 68, 34, 90, 66, 213, 81, 89, 26, 96]), Seed([23, 128, 56, 243, 74, 229, 251, 118, 164, 41, 167, 32, 21, 166, 62, 65, 219, 186, 152, 235, 233, 126, 212, 188, 162, 174, 77, 136, 28, 8, 201, 142]));
/// DT: GDDT22QTPK56WV5E6537HQDGLXPPYX7VFOA3Z7LTLQ7L26DE4PGN5KL6
static immutable DT = KeyPair(PublicKey([199, 61, 106, 19, 122, 187, 235, 87, 164, 247, 119, 243, 192, 102, 93, 222, 252, 95, 245, 43, 129, 188, 253, 115, 92, 62, 189, 120, 100, 227, 204, 222]), SecretKey([0, 193, 156, 68, 40, 157, 189, 123, 8, 137, 194, 72, 29, 217, 222, 43, 98, 134, 231, 68, 90, 111, 172, 217, 249, 136, 4, 207, 218, 221, 21, 92]), Seed([126, 19, 153, 52, 212, 183, 232, 200, 173, 102, 224, 225, 62, 127, 164, 134, 241, 211, 171, 99, 74, 3, 119, 135, 193, 1, 94, 236, 64, 165, 66, 155]));
/// DU: GDDU22FE6NR5UQZIB4ATFC4WRQGY7SJV63KRCAUZX2HDQWUIGHBKPEDD
static immutable DU = KeyPair(PublicKey([199, 77, 104, 164, 243, 99, 218, 67, 40, 15, 1, 50, 139, 150, 140, 13, 143, 201, 53, 246, 213, 17, 2, 153, 190, 142, 56, 90, 136, 49, 194, 167]), SecretKey([16, 110, 61, 22, 247, 161, 49, 253, 73, 250, 195, 123, 146, 201, 94, 22, 94, 147, 24, 225, 220, 29, 145, 131, 8, 146, 169, 152, 173, 54, 190, 70]), Seed([106, 47, 164, 97, 80, 184, 91, 144, 26, 148, 151, 171, 105, 29, 55, 200, 35, 187, 212, 7, 251, 224, 58, 238, 57, 62, 88, 135, 122, 3, 72, 170]));
/// DV: GDDV22PTIY4CH5ROZTC6VLGA3XVZNU7KPDOGPBP6MUS5SUHH7OG3LJQD
static immutable DV = KeyPair(PublicKey([199, 93, 105, 243, 70, 56, 35, 246, 46, 204, 197, 234, 172, 192, 221, 235, 150, 211, 234, 120, 220, 103, 133, 254, 101, 37, 217, 80, 231, 251, 141, 181]), SecretKey([128, 106, 79, 247, 221, 122, 171, 1, 34, 170, 13, 217, 208, 63, 46, 61, 204, 180, 139, 190, 96, 165, 195, 211, 119, 84, 39, 248, 193, 189, 253, 72]), Seed([165, 84, 12, 144, 92, 57, 84, 245, 93, 239, 4, 82, 245, 136, 98, 136, 156, 11, 234, 17, 117, 37, 104, 89, 40, 95, 217, 127, 172, 255, 189, 130]));
/// DW: GDDW22ZCJHHIRE3HB4QMJFGBR7CPVXSRQCG2AVEVSINZ45FUDI72DZJI
static immutable DW = KeyPair(PublicKey([199, 109, 107, 34, 73, 206, 136, 147, 103, 15, 32, 196, 148, 193, 143, 196, 250, 222, 81, 128, 141, 160, 84, 149, 146, 27, 158, 116, 180, 26, 63, 161]), SecretKey([176, 82, 68, 211, 44, 6, 238, 165, 145, 154, 224, 96, 60, 163, 226, 122, 16, 79, 5, 42, 237, 100, 225, 48, 15, 111, 248, 175, 172, 194, 232, 66]), Seed([153, 199, 184, 128, 148, 113, 58, 183, 231, 217, 123, 137, 53, 68, 125, 201, 101, 23, 206, 95, 135, 236, 98, 102, 40, 134, 111, 45, 211, 180, 51, 117]));
/// DX: GDDX22K66JM3EIEXRQNIWWO6YXE37WSROYLFNYRBCVL6UH6GGZT55CBK
static immutable DX = KeyPair(PublicKey([199, 125, 105, 94, 242, 89, 178, 32, 151, 140, 26, 139, 89, 222, 197, 201, 191, 218, 81, 118, 22, 86, 226, 33, 21, 87, 234, 31, 198, 54, 103, 222]), SecretKey([104, 139, 58, 108, 43, 27, 232, 120, 140, 150, 110, 57, 82, 228, 147, 140, 113, 73, 133, 145, 129, 221, 178, 223, 122, 222, 244, 37, 45, 107, 33, 101]), Seed([183, 50, 230, 254, 207, 129, 11, 197, 89, 4, 7, 179, 23, 210, 46, 57, 39, 35, 115, 69, 132, 32, 249, 215, 8, 144, 81, 94, 234, 178, 7, 105]));
/// DY: GDDY22GHHZTYZTQP2BDP6I3RFR327OPM2CBTO37FO2SA2LYFI6CCJKTN
static immutable DY = KeyPair(PublicKey([199, 141, 104, 199, 62, 103, 140, 206, 15, 208, 70, 255, 35, 113, 44, 119, 175, 185, 236, 208, 131, 55, 111, 229, 118, 164, 13, 47, 5, 71, 132, 36]), SecretKey([16, 166, 130, 151, 235, 157, 92, 240, 127, 202, 68, 111, 180, 30, 62, 133, 113, 86, 49, 135, 144, 168, 192, 95, 97, 73, 93, 201, 79, 240, 7, 99]), Seed([104, 164, 32, 242, 41, 5, 78, 182, 157, 158, 78, 121, 34, 64, 223, 34, 39, 52, 163, 195, 25, 138, 50, 176, 237, 7, 79, 49, 75, 253, 196, 66]));
/// DZ: GDDZ22E4HB2BA7LF5AVCFDSWAV2GYJML5N2ELTAHNJR4TBBNLGKBUICC
static immutable DZ = KeyPair(PublicKey([199, 157, 104, 156, 56, 116, 16, 125, 101, 232, 42, 34, 142, 86, 5, 116, 108, 37, 139, 235, 116, 69, 204, 7, 106, 99, 201, 132, 45, 89, 148, 26]), SecretKey([176, 127, 139, 195, 61, 11, 245, 112, 125, 200, 218, 70, 83, 124, 113, 45, 37, 15, 97, 43, 107, 238, 28, 64, 188, 6, 164, 192, 161, 109, 167, 106]), Seed([129, 47, 192, 14, 233, 124, 157, 126, 116, 108, 193, 131, 228, 244, 12, 111, 207, 216, 153, 226, 235, 178, 129, 15, 181, 147, 156, 25, 153, 116, 219, 58]));
/// EA: GDEA22CLN3HBFMOECEA52VOMM4RSQFEX6ACICSTGLN3S5DLMMUPKTSEI
static immutable EA = KeyPair(PublicKey([200, 13, 104, 75, 110, 206, 18, 177, 196, 17, 1, 221, 85, 204, 103, 35, 40, 20, 151, 240, 4, 129, 74, 102, 91, 119, 46, 141, 108, 101, 30, 169]), SecretKey([200, 115, 230, 65, 32, 242, 233, 210, 10, 4, 199, 217, 172, 162, 194, 246, 117, 93, 91, 1, 236, 80, 11, 16, 88, 168, 247, 91, 27, 107, 104, 105]), Seed([124, 74, 70, 20, 237, 25, 75, 125, 189, 221, 20, 39, 48, 67, 10, 59, 12, 100, 221, 190, 158, 246, 202, 179, 88, 120, 48, 28, 0, 166, 34, 81]));
/// EB: GDEB22BTNEHGYOXSQFBLQU5ELBULP2JPNUUC6KJ4CDCY3WBQF7NGGZ55
static immutable EB = KeyPair(PublicKey([200, 29, 104, 51, 105, 14, 108, 58, 242, 129, 66, 184, 83, 164, 88, 104, 183, 233, 47, 109, 40, 47, 41, 60, 16, 197, 141, 216, 48, 47, 218, 99]), SecretKey([176, 210, 171, 13, 239, 12, 60, 76, 168, 50, 179, 208, 146, 161, 121, 146, 217, 194, 174, 188, 139, 121, 85, 180, 235, 116, 80, 195, 187, 11, 6, 101]), Seed([151, 228, 90, 18, 22, 190, 192, 164, 14, 25, 221, 8, 216, 9, 49, 87, 173, 146, 148, 36, 233, 179, 175, 232, 198, 67, 51, 91, 225, 66, 5, 100]));
/// EC: GDEC22SEWGZ7PNMBQRPECFL3ASTK43IUIZPX5UR74FYGQGAC7DIC5HAV
static immutable EC = KeyPair(PublicKey([200, 45, 106, 68, 177, 179, 247, 181, 129, 132, 94, 65, 21, 123, 4, 166, 174, 109, 20, 70, 95, 126, 210, 63, 225, 112, 104, 24, 2, 248, 208, 46]), SecretKey([64, 115, 153, 169, 178, 119, 30, 20, 57, 172, 225, 254, 153, 84, 146, 129, 174, 7, 216, 246, 105, 232, 246, 124, 202, 120, 101, 186, 163, 21, 92, 107]), Seed([45, 78, 219, 118, 79, 17, 57, 48, 230, 16, 24, 18, 44, 127, 35, 18, 119, 224, 146, 210, 84, 102, 71, 244, 172, 143, 145, 161, 41, 39, 123, 165]));
/// ED: GDED22RMEUO6E7I3X2IYAETVY32LHK2WSOHBRVYPCQT2WMR5ZFT5PG5B
static immutable ED = KeyPair(PublicKey([200, 61, 106, 44, 37, 29, 226, 125, 27, 190, 145, 128, 18, 117, 198, 244, 179, 171, 86, 147, 142, 24, 215, 15, 20, 39, 171, 50, 61, 201, 103, 215]), SecretKey([72, 60, 85, 236, 178, 68, 177, 113, 146, 91, 172, 103, 127, 58, 48, 181, 8, 37, 26, 34, 12, 201, 3, 109, 131, 51, 111, 135, 51, 169, 139, 118]), Seed([7, 250, 187, 52, 18, 121, 68, 232, 131, 123, 32, 0, 38, 177, 67, 203, 145, 65, 133, 42, 103, 137, 243, 23, 202, 182, 92, 251, 120, 251, 16, 148]));
/// EE: GDEE22ZPHIV2QDMFKV67REGISQW5BPBX5PBCNPH3PGNMDMSGTXVGH462
static immutable EE = KeyPair(PublicKey([200, 77, 107, 47, 58, 43, 168, 13, 133, 85, 125, 248, 144, 200, 148, 45, 208, 188, 55, 235, 194, 38, 188, 251, 121, 154, 193, 178, 70, 157, 234, 99]), SecretKey([80, 157, 43, 179, 137, 35, 120, 43, 233, 121, 34, 63, 49, 20, 59, 38, 176, 31, 87, 125, 93, 208, 120, 207, 13, 237, 17, 4, 244, 74, 52, 106]), Seed([234, 187, 180, 235, 207, 123, 126, 118, 189, 158, 244, 80, 83, 210, 209, 108, 13, 255, 152, 2, 147, 161, 41, 154, 102, 177, 92, 84, 20, 163, 5, 107]));
/// EF: GDEF22NJNE4V6LM2TDLHJRBB6PLSJXMBLZYZGXHHU7DA43I5JHML6EAJ
static immutable EF = KeyPair(PublicKey([200, 93, 105, 169, 105, 57, 95, 45, 154, 152, 214, 116, 196, 33, 243, 215, 36, 221, 129, 94, 113, 147, 92, 231, 167, 198, 14, 109, 29, 73, 216, 191]), SecretKey([152, 56, 178, 194, 129, 115, 88, 198, 189, 161, 99, 32, 236, 118, 145, 134, 127, 121, 17, 54, 186, 246, 28, 185, 219, 151, 235, 122, 129, 38, 203, 79]), Seed([89, 232, 210, 149, 21, 218, 50, 44, 37, 251, 47, 101, 76, 90, 153, 98, 165, 243, 244, 219, 55, 106, 160, 239, 213, 225, 66, 65, 24, 185, 87, 236]));
/// EG: GDEG22CG6IQLPVENM2XQNKMU66XEAURE5IRIB45KUKT6MMAII4ZVAD4P
static immutable EG = KeyPair(PublicKey([200, 109, 104, 70, 242, 32, 183, 212, 141, 102, 175, 6, 169, 148, 247, 174, 64, 82, 36, 234, 34, 128, 243, 170, 162, 167, 230, 48, 8, 71, 51, 80]), SecretKey([192, 35, 63, 238, 12, 216, 88, 25, 220, 186, 153, 154, 141, 209, 246, 97, 154, 151, 179, 6, 230, 255, 70, 162, 13, 167, 250, 31, 226, 97, 218, 125]), Seed([145, 233, 150, 78, 156, 38, 197, 205, 167, 101, 44, 129, 161, 213, 162, 202, 83, 2, 79, 171, 21, 167, 171, 155, 190, 166, 154, 167, 235, 211, 23, 220]));
/// EH: GDEH22VQGIO2TOCKCKNDSOPMLEGPC5CJNEYU3MMA4OBA4MXL2RFELSO5
static immutable EH = KeyPair(PublicKey([200, 125, 106, 176, 50, 29, 169, 184, 74, 18, 154, 57, 57, 236, 89, 12, 241, 116, 73, 105, 49, 77, 177, 128, 227, 130, 14, 50, 235, 212, 74, 69]), SecretKey([24, 52, 39, 219, 89, 61, 158, 45, 145, 66, 122, 167, 147, 154, 12, 27, 250, 150, 15, 215, 239, 252, 47, 56, 245, 190, 220, 102, 133, 225, 166, 103]), Seed([12, 4, 200, 157, 152, 137, 99, 157, 132, 172, 95, 152, 206, 45, 55, 231, 244, 100, 193, 139, 127, 54, 245, 159, 216, 224, 227, 75, 67, 165, 227, 165]));
/// EI: GDEI22J3IR744JMWBMFCO5KXAIHIHVJ4YE7IFHZIR3MEW7O2JT5I7RZO
static immutable EI = KeyPair(PublicKey([200, 141, 105, 59, 68, 127, 206, 37, 150, 11, 10, 39, 117, 87, 2, 14, 131, 213, 60, 193, 62, 130, 159, 40, 142, 216, 75, 125, 218, 76, 250, 143]), SecretKey([96, 3, 94, 8, 68, 136, 228, 163, 205, 92, 143, 200, 12, 122, 61, 20, 197, 210, 56, 215, 129, 234, 210, 77, 255, 140, 126, 248, 14, 116, 16, 120]), Seed([191, 50, 244, 87, 181, 100, 199, 90, 247, 82, 179, 222, 94, 95, 103, 39, 175, 47, 29, 89, 200, 197, 157, 197, 245, 243, 35, 26, 180, 200, 83, 234]));
/// EJ: GDEJ22BQCRECQDAPY4HGXGEHQKAAA34JIDYIT3WJANOVZ2JMQXCMGFFU
static immutable EJ = KeyPair(PublicKey([200, 157, 104, 48, 20, 72, 40, 12, 15, 199, 14, 107, 152, 135, 130, 128, 0, 111, 137, 64, 240, 137, 238, 201, 3, 93, 92, 233, 44, 133, 196, 195]), SecretKey([0, 102, 98, 254, 168, 49, 203, 109, 133, 63, 239, 29, 60, 75, 196, 229, 67, 221, 94, 172, 170, 43, 116, 130, 23, 39, 112, 98, 73, 111, 200, 75]), Seed([108, 41, 29, 19, 129, 53, 54, 52, 70, 5, 135, 198, 147, 139, 207, 45, 136, 240, 31, 182, 205, 76, 72, 203, 223, 16, 27, 218, 219, 56, 127, 68]));
/// EK: GDEK22URO47P7H4BPCFFP3L6D4SFCJIYWWECATGA5QJ6DG6R4NL65YJA
static immutable EK = KeyPair(PublicKey([200, 173, 106, 145, 119, 62, 255, 159, 129, 120, 138, 87, 237, 126, 31, 36, 81, 37, 24, 181, 136, 32, 76, 192, 236, 19, 225, 155, 209, 227, 87, 238]), SecretKey([168, 83, 235, 11, 62, 42, 212, 181, 157, 121, 127, 202, 65, 231, 111, 96, 202, 197, 215, 228, 95, 62, 85, 155, 176, 65, 91, 223, 11, 210, 67, 118]), Seed([238, 82, 57, 144, 173, 201, 78, 152, 17, 112, 164, 212, 203, 106, 128, 154, 164, 166, 174, 201, 205, 239, 128, 246, 92, 95, 197, 231, 37, 111, 119, 14]));
/// EL: GDEL22YYLOYB5DFFZRVBRMWKS5F4OYAHTVGOGH7XTQJK4J7KALXZCGFD
static immutable EL = KeyPair(PublicKey([200, 189, 107, 24, 91, 176, 30, 140, 165, 204, 106, 24, 178, 202, 151, 75, 199, 96, 7, 157, 76, 227, 31, 247, 156, 18, 174, 39, 234, 2, 239, 145]), SecretKey([48, 103, 130, 205, 146, 194, 54, 187, 146, 155, 58, 146, 29, 128, 13, 145, 33, 97, 188, 177, 218, 148, 87, 28, 232, 98, 243, 91, 36, 178, 100, 66]), Seed([34, 187, 44, 21, 106, 61, 111, 87, 12, 148, 212, 225, 27, 202, 149, 93, 130, 28, 139, 223, 239, 82, 71, 10, 39, 82, 101, 99, 47, 225, 176, 243]));
/// EM: GDEM22YKORETWRBTANTKMPJHWZVBK5D2QSIYQDYPRWMM7KKUEZ24KPEN
static immutable EM = KeyPair(PublicKey([200, 205, 107, 10, 116, 73, 59, 68, 51, 3, 102, 166, 61, 39, 182, 106, 21, 116, 122, 132, 145, 136, 15, 15, 141, 152, 207, 169, 84, 38, 117, 197]), SecretKey([232, 202, 62, 184, 112, 192, 33, 173, 90, 39, 196, 225, 186, 231, 21, 51, 23, 176, 204, 71, 56, 48, 28, 124, 155, 166, 199, 204, 126, 79, 195, 96]), Seed([176, 50, 121, 17, 162, 4, 75, 37, 151, 118, 143, 90, 53, 244, 13, 79, 183, 89, 89, 138, 36, 180, 131, 106, 133, 154, 90, 132, 160, 66, 53, 22]));
/// EN: GDEN22ZR754DZAC3JAQ7FTTNBR32TDDKHZNTNAZ3CCB3A3F7ZW7HBPVZ
static immutable EN = KeyPair(PublicKey([200, 221, 107, 49, 255, 120, 60, 128, 91, 72, 33, 242, 206, 109, 12, 119, 169, 140, 106, 62, 91, 54, 131, 59, 16, 131, 176, 108, 191, 205, 190, 112]), SecretKey([160, 190, 144, 244, 47, 174, 220, 250, 115, 111, 88, 80, 136, 203, 55, 5, 161, 198, 209, 37, 48, 4, 176, 210, 216, 168, 93, 148, 3, 85, 243, 104]), Seed([88, 239, 72, 151, 180, 152, 143, 152, 197, 253, 121, 68, 179, 134, 180, 157, 109, 20, 119, 109, 154, 87, 127, 35, 81, 231, 77, 115, 15, 220, 148, 105]));
/// EO: GDEO22DOEMOSLOJUIF7E6EGUSY2IVZCHZJNBO2PUFWWLAID7K5XWJNYQ
static immutable EO = KeyPair(PublicKey([200, 237, 104, 110, 35, 29, 37, 185, 52, 65, 126, 79, 16, 212, 150, 52, 138, 228, 71, 202, 90, 23, 105, 244, 45, 172, 176, 32, 127, 87, 111, 100]), SecretKey([8, 178, 45, 80, 8, 45, 223, 230, 91, 203, 30, 127, 81, 104, 147, 216, 162, 100, 116, 16, 233, 188, 83, 75, 111, 61, 243, 5, 149, 214, 9, 92]), Seed([215, 7, 92, 211, 53, 170, 90, 164, 118, 112, 39, 243, 241, 202, 144, 123, 149, 121, 18, 227, 122, 205, 24, 221, 240, 130, 141, 200, 91, 139, 15, 46]));
/// EP: GDEP22J2IVC4OH7A4O7X6R42ZCKN2BCIN5SWPGRC7BWB43INC6SHXQD3
static immutable EP = KeyPair(PublicKey([200, 253, 105, 58, 69, 69, 199, 31, 224, 227, 191, 127, 71, 154, 200, 148, 221, 4, 72, 111, 101, 103, 154, 34, 248, 108, 30, 109, 13, 23, 164, 123]), SecretKey([16, 38, 219, 230, 109, 95, 117, 225, 159, 198, 108, 195, 111, 111, 13, 230, 51, 241, 177, 157, 239, 128, 176, 244, 183, 41, 175, 192, 140, 141, 162, 83]), Seed([218, 230, 187, 22, 190, 116, 120, 155, 241, 133, 77, 248, 71, 178, 50, 120, 176, 66, 214, 89, 247, 237, 175, 91, 107, 33, 169, 199, 84, 221, 62, 26]));
/// EQ: GDEQ22Z6GNDWAGOOLLVSJF2ZJ4WIWZ7SC5ONXLR6HFCWGSRVTRESWKCG
static immutable EQ = KeyPair(PublicKey([201, 13, 107, 62, 51, 71, 96, 25, 206, 90, 235, 36, 151, 89, 79, 44, 139, 103, 242, 23, 92, 219, 174, 62, 57, 69, 99, 74, 53, 156, 73, 43]), SecretKey([80, 236, 210, 179, 155, 72, 112, 232, 28, 143, 117, 105, 190, 173, 126, 197, 235, 111, 102, 37, 155, 88, 76, 33, 106, 252, 136, 179, 63, 9, 18, 114]), Seed([215, 13, 254, 29, 253, 177, 21, 211, 211, 150, 109, 3, 247, 101, 148, 3, 148, 229, 111, 34, 98, 20, 243, 147, 174, 4, 36, 2, 90, 206, 248, 35]));
/// ER: GDER22N6N2KPG3RXEQ6GCIOF46Y56JQGWWDY3USINAWYU3IBBU3GRJ2R
static immutable ER = KeyPair(PublicKey([201, 29, 105, 190, 110, 148, 243, 110, 55, 36, 60, 97, 33, 197, 231, 177, 223, 38, 6, 181, 135, 141, 210, 72, 104, 45, 138, 109, 1, 13, 54, 104]), SecretKey([32, 233, 218, 23, 10, 229, 158, 52, 199, 26, 23, 205, 198, 123, 89, 31, 60, 29, 253, 75, 206, 132, 248, 205, 239, 11, 233, 244, 47, 91, 28, 110]), Seed([187, 179, 84, 181, 101, 40, 87, 72, 168, 96, 21, 205, 171, 204, 156, 126, 221, 81, 108, 207, 89, 127, 142, 102, 226, 147, 227, 39, 156, 243, 174, 133]));
/// ES: GDES22LPDL6FBAUXQZAHXU4ZDLZJ7YZZHNDS22BREPV3RIA6GKQD6BU6
static immutable ES = KeyPair(PublicKey([201, 45, 105, 111, 26, 252, 80, 130, 151, 134, 64, 123, 211, 153, 26, 242, 159, 227, 57, 59, 71, 45, 104, 49, 35, 235, 184, 160, 30, 50, 160, 63]), SecretKey([8, 206, 166, 52, 173, 177, 150, 170, 6, 122, 153, 7, 208, 160, 35, 99, 98, 155, 37, 64, 27, 210, 85, 188, 232, 63, 29, 155, 141, 254, 32, 69]), Seed([231, 86, 83, 72, 198, 40, 119, 56, 157, 74, 68, 33, 165, 123, 214, 101, 195, 198, 41, 28, 141, 13, 156, 100, 200, 169, 18, 202, 94, 33, 199, 160]));
/// ET: GDET22XPKJ7XJXIWFTNAXQJG4RRPSDZJUHQAPTLZZGV2TLGG7RHEPAHD
static immutable ET = KeyPair(PublicKey([201, 61, 106, 239, 82, 127, 116, 221, 22, 44, 218, 11, 193, 38, 228, 98, 249, 15, 41, 161, 224, 7, 205, 121, 201, 171, 169, 172, 198, 252, 78, 71]), SecretKey([160, 211, 113, 203, 158, 174, 175, 113, 191, 202, 6, 221, 32, 80, 75, 86, 9, 232, 239, 151, 32, 178, 89, 148, 176, 0, 119, 175, 180, 57, 95, 127]), Seed([2, 121, 29, 182, 220, 143, 87, 27, 205, 103, 113, 46, 90, 135, 6, 62, 76, 8, 185, 39, 18, 121, 206, 214, 251, 137, 237, 147, 200, 202, 239, 100]));
/// EU: GDEU22CIQGY4QXP7RLWAIGQBTPTYZTPCBCDSUQWKRU2V3HCACGZZLSNP
static immutable EU = KeyPair(PublicKey([201, 77, 104, 72, 129, 177, 200, 93, 255, 138, 236, 4, 26, 1, 155, 231, 140, 205, 226, 8, 135, 42, 66, 202, 141, 53, 93, 156, 64, 17, 179, 149]), SecretKey([72, 90, 55, 204, 25, 244, 116, 194, 161, 90, 142, 177, 251, 141, 50, 80, 13, 62, 186, 132, 43, 187, 197, 69, 55, 118, 172, 243, 97, 187, 155, 91]), Seed([133, 163, 29, 111, 137, 118, 207, 190, 243, 199, 237, 80, 46, 137, 91, 251, 18, 20, 181, 78, 22, 21, 229, 40, 110, 75, 220, 77, 181, 131, 50, 108]));
/// EV: GDEV22IIUZ2H7XTNCUFCOF4BDSAPOWW4E3VNA2SPDUHILX4PBLDSG66O
static immutable EV = KeyPair(PublicKey([201, 93, 105, 8, 166, 116, 127, 222, 109, 21, 10, 39, 23, 129, 28, 128, 247, 90, 220, 38, 234, 208, 106, 79, 29, 14, 133, 223, 143, 10, 199, 35]), SecretKey([216, 184, 50, 39, 250, 54, 6, 238, 119, 86, 142, 118, 170, 106, 200, 242, 209, 74, 115, 117, 229, 177, 132, 97, 100, 53, 11, 38, 134, 107, 59, 99]), Seed([1, 177, 62, 236, 59, 156, 225, 209, 88, 213, 101, 99, 24, 249, 205, 148, 140, 92, 56, 78, 224, 189, 190, 140, 114, 180, 203, 132, 109, 226, 18, 136]));
/// EW: GDEW22BABRVEHCEYLOULI4RBOTCJ2LWCLCCRVRGL4RCTGSJVFEBGGOSK
static immutable EW = KeyPair(PublicKey([201, 109, 104, 32, 12, 106, 67, 136, 152, 91, 168, 180, 114, 33, 116, 196, 157, 46, 194, 88, 133, 26, 196, 203, 228, 69, 51, 73, 53, 41, 2, 99]), SecretKey([48, 17, 136, 5, 208, 240, 145, 215, 246, 209, 10, 37, 34, 21, 228, 162, 132, 108, 245, 58, 119, 68, 103, 184, 134, 123, 40, 87, 65, 64, 96, 69]), Seed([184, 144, 232, 106, 184, 11, 184, 154, 184, 166, 124, 141, 254, 24, 42, 222, 124, 134, 82, 24, 75, 157, 30, 213, 193, 241, 17, 211, 64, 185, 144, 32]));
/// EX: GDEX22BLONII5RZBVGKKGJ4O7CPD4JM3YW2KO2Z2HE22325V4SFGXKWO
static immutable EX = KeyPair(PublicKey([201, 125, 104, 43, 115, 80, 142, 199, 33, 169, 148, 163, 39, 142, 248, 158, 62, 37, 155, 197, 180, 167, 107, 58, 57, 53, 173, 235, 181, 228, 138, 107]), SecretKey([0, 20, 17, 108, 116, 157, 108, 219, 110, 130, 217, 235, 97, 107, 232, 225, 187, 207, 86, 150, 19, 39, 188, 159, 106, 29, 233, 149, 68, 80, 139, 119]), Seed([101, 156, 75, 18, 215, 145, 98, 186, 167, 217, 226, 255, 73, 107, 198, 83, 30, 48, 117, 255, 127, 169, 22, 224, 196, 248, 143, 239, 141, 1, 116, 117]));
/// EY: GDEY22DN7MS4FVVTHWQCKU3TYFYJSMVQG3M7T6GRVJIQX77TY2BEYDPO
static immutable EY = KeyPair(PublicKey([201, 141, 104, 109, 251, 37, 194, 214, 179, 61, 160, 37, 83, 115, 193, 112, 153, 50, 176, 54, 217, 249, 248, 209, 170, 81, 11, 255, 243, 198, 130, 76]), SecretKey([56, 80, 164, 45, 9, 25, 193, 147, 146, 0, 246, 139, 182, 180, 252, 128, 215, 85, 219, 191, 252, 191, 12, 86, 179, 111, 32, 195, 104, 83, 112, 79]), Seed([12, 104, 43, 55, 214, 61, 230, 234, 134, 214, 14, 174, 52, 168, 221, 2, 66, 35, 226, 66, 180, 253, 251, 63, 200, 22, 7, 129, 146, 198, 142, 54]));
/// EZ: GDEZ227UPTPLWVSQGLN2NE4SKVTOVMJCONB3UN3GXRMV6ME2MPMNZQSQ
static immutable EZ = KeyPair(PublicKey([201, 157, 107, 244, 124, 222, 187, 86, 80, 50, 219, 166, 147, 146, 85, 102, 234, 177, 34, 115, 67, 186, 55, 102, 188, 89, 95, 48, 154, 99, 216, 220]), SecretKey([232, 173, 78, 53, 69, 86, 158, 129, 90, 163, 159, 117, 51, 155, 35, 224, 42, 61, 225, 202, 129, 196, 61, 168, 212, 29, 143, 131, 76, 130, 59, 78]), Seed([7, 156, 137, 46, 87, 47, 220, 62, 242, 92, 246, 145, 246, 201, 30, 28, 11, 224, 204, 99, 98, 16, 180, 250, 161, 192, 239, 217, 40, 72, 103, 169]));
/// FA: GDFA22MORQXHECNYBKZDNY4UMQZUSLZB536MLUIOXOIRHXPMSLPJ3R47
static immutable FA = KeyPair(PublicKey([202, 13, 105, 142, 140, 46, 114, 9, 184, 10, 178, 54, 227, 148, 100, 51, 73, 47, 33, 238, 252, 197, 209, 14, 187, 145, 19, 221, 236, 146, 222, 157]), SecretKey([144, 35, 203, 136, 124, 94, 92, 52, 49, 243, 71, 109, 193, 118, 201, 8, 194, 140, 37, 117, 151, 45, 97, 20, 210, 73, 61, 0, 119, 171, 216, 71]), Seed([14, 166, 12, 228, 40, 250, 130, 120, 96, 28, 137, 85, 39, 18, 182, 6, 39, 107, 243, 236, 59, 66, 253, 222, 70, 170, 67, 249, 175, 79, 97, 70]));
/// FB: GDFB22LPSAJCXH7R32G2ZLX3DSUP6FUJF6LYRWZX5G2M55CEYIPQJ3HF
static immutable FB = KeyPair(PublicKey([202, 29, 105, 111, 144, 18, 43, 159, 241, 222, 141, 172, 174, 251, 28, 168, 255, 22, 137, 47, 151, 136, 219, 55, 233, 180, 206, 244, 68, 194, 31, 4]), SecretKey([176, 30, 231, 188, 103, 92, 176, 96, 162, 208, 179, 198, 213, 24, 194, 31, 49, 231, 74, 185, 176, 140, 104, 78, 168, 174, 82, 20, 33, 182, 102, 118]), Seed([210, 110, 106, 238, 102, 0, 223, 85, 246, 48, 169, 36, 254, 243, 14, 187, 6, 108, 13, 119, 239, 97, 109, 26, 202, 118, 149, 210, 242, 250, 229, 233]));
/// FC: GDFC22OIXIKLE3QJMRPUY3X2LDN7ANALL5WX7EU23QN7HYOQA3HAX22W
static immutable FC = KeyPair(PublicKey([202, 45, 105, 200, 186, 20, 178, 110, 9, 100, 95, 76, 110, 250, 88, 219, 240, 52, 11, 95, 109, 127, 146, 154, 220, 27, 243, 225, 208, 6, 206, 11]), SecretKey([80, 81, 147, 73, 34, 198, 233, 170, 128, 121, 154, 177, 214, 127, 226, 38, 234, 138, 184, 91, 95, 122, 222, 179, 179, 100, 128, 146, 29, 59, 4, 83]), Seed([223, 130, 43, 164, 73, 197, 213, 224, 4, 99, 2, 40, 167, 243, 226, 44, 100, 222, 239, 173, 94, 173, 240, 209, 94, 242, 4, 161, 174, 207, 163, 175]));
/// FD: GDFD22GBWW6Q63QAG2IPIY4PAJG447WOJ3ZQFRL724IVVBTLFWWR7J5T
static immutable FD = KeyPair(PublicKey([202, 61, 104, 193, 181, 189, 15, 110, 0, 54, 144, 244, 99, 143, 2, 77, 206, 126, 206, 78, 243, 2, 197, 127, 215, 17, 90, 134, 107, 45, 173, 31]), SecretKey([64, 60, 95, 46, 149, 210, 51, 6, 73, 107, 135, 27, 8, 25, 173, 210, 46, 245, 190, 9, 158, 34, 139, 64, 147, 191, 11, 160, 162, 130, 218, 119]), Seed([7, 63, 41, 218, 164, 13, 1, 181, 87, 5, 60, 110, 70, 66, 227, 41, 153, 101, 243, 164, 17, 247, 84, 193, 79, 83, 238, 120, 50, 35, 186, 142]));
/// FE: GDFE22N5GW3IJLYXCQV5ZXIKIOMQLI4HANXIYI3RFPQER7LDPBURVS5D
static immutable FE = KeyPair(PublicKey([202, 77, 105, 189, 53, 182, 132, 175, 23, 20, 43, 220, 221, 10, 67, 153, 5, 163, 135, 3, 110, 140, 35, 113, 43, 224, 72, 253, 99, 120, 105, 26]), SecretKey([208, 37, 31, 83, 180, 56, 168, 171, 218, 211, 154, 231, 244, 99, 149, 18, 144, 185, 22, 197, 157, 243, 254, 153, 110, 187, 183, 74, 103, 118, 165, 64]), Seed([178, 190, 145, 218, 158, 156, 191, 255, 190, 142, 250, 182, 32, 212, 198, 177, 201, 242, 224, 219, 100, 131, 130, 35, 124, 14, 252, 124, 78, 127, 227, 111]));
/// FF: GDFF227PKQIWI5KHK5PFR5RCPTQU42GDET4IHVKKMFTPQ7K7CB5ATJNT
static immutable FF = KeyPair(PublicKey([202, 93, 107, 239, 84, 17, 100, 117, 71, 87, 94, 88, 246, 34, 124, 225, 78, 104, 195, 36, 248, 131, 213, 74, 97, 102, 248, 125, 95, 16, 122, 9]), SecretKey([184, 18, 186, 35, 113, 236, 213, 209, 113, 122, 48, 120, 65, 69, 127, 157, 78, 87, 3, 39, 121, 164, 50, 210, 189, 107, 137, 206, 110, 199, 76, 65]), Seed([14, 16, 206, 53, 211, 66, 35, 74, 125, 247, 22, 171, 10, 163, 172, 136, 205, 86, 153, 0, 192, 100, 121, 197, 255, 215, 219, 182, 50, 4, 191, 118]));
/// FG: GDFG22MOWUULUNRNKL3O5BGOEGDRJJX7NLNQUVVBFDN53ZYU3TH2UB5U
static immutable FG = KeyPair(PublicKey([202, 109, 105, 142, 181, 40, 186, 54, 45, 82, 246, 238, 132, 206, 33, 135, 20, 166, 255, 106, 219, 10, 86, 161, 40, 219, 221, 231, 20, 220, 207, 170]), SecretKey([232, 75, 12, 168, 162, 243, 135, 205, 215, 243, 11, 45, 119, 193, 105, 14, 7, 6, 143, 146, 253, 148, 197, 143, 185, 52, 54, 123, 214, 97, 77, 110]), Seed([129, 21, 122, 185, 173, 243, 116, 1, 172, 160, 239, 0, 56, 183, 184, 252, 102, 107, 152, 46, 65, 7, 92, 225, 227, 92, 185, 145, 238, 216, 167, 97]));
/// FH: GDFH227PDPF44TMWEP5FOLPTZ5EIWPW4IIHAYI4IAVN6TG3TZ2OWWSKZ
static immutable FH = KeyPair(PublicKey([202, 125, 107, 239, 27, 203, 206, 77, 150, 35, 250, 87, 45, 243, 207, 72, 139, 62, 220, 66, 14, 12, 35, 136, 5, 91, 233, 155, 115, 206, 157, 107]), SecretKey([144, 198, 110, 158, 194, 13, 208, 234, 24, 156, 87, 209, 189, 112, 227, 217, 98, 48, 242, 34, 221, 71, 103, 37, 252, 245, 122, 111, 122, 25, 229, 72]), Seed([106, 221, 77, 221, 21, 199, 32, 76, 6, 79, 207, 161, 207, 7, 238, 194, 39, 52, 166, 227, 217, 59, 90, 248, 9, 77, 247, 9, 104, 253, 125, 1]));
/// FI: GDFI22II25RTDJEVPRLK3CL6E25SOPZRYQY5SVHVJEPXSC7QNS65S7NT
static immutable FI = KeyPair(PublicKey([202, 141, 105, 8, 215, 99, 49, 164, 149, 124, 86, 173, 137, 126, 38, 187, 39, 63, 49, 196, 49, 217, 84, 245, 73, 31, 121, 11, 240, 108, 189, 217]), SecretKey([128, 57, 126, 92, 171, 94, 59, 119, 250, 246, 249, 126, 29, 6, 206, 105, 73, 244, 255, 136, 204, 31, 99, 42, 92, 111, 218, 246, 199, 128, 151, 83]), Seed([54, 26, 131, 8, 58, 151, 175, 141, 132, 208, 105, 47, 33, 199, 2, 186, 177, 111, 124, 217, 128, 141, 141, 148, 68, 109, 252, 138, 25, 96, 23, 163]));
/// FJ: GDFJ22YRUI2PTD6DHRZKAWQWJB6HQKFCH6U6DQI5LCV4ICEXM5NOZSCM
static immutable FJ = KeyPair(PublicKey([202, 157, 107, 17, 162, 52, 249, 143, 195, 60, 114, 160, 90, 22, 72, 124, 120, 40, 162, 63, 169, 225, 193, 29, 88, 171, 196, 8, 151, 103, 90, 236]), SecretKey([104, 244, 142, 210, 5, 137, 177, 210, 254, 0, 3, 224, 128, 220, 236, 234, 222, 119, 127, 46, 33, 170, 210, 87, 0, 70, 38, 122, 17, 3, 151, 118]), Seed([64, 191, 27, 10, 11, 129, 206, 162, 118, 154, 53, 71, 37, 161, 113, 49, 2, 157, 59, 207, 192, 176, 185, 222, 25, 221, 118, 53, 225, 94, 65, 157]));
/// FK: GDFK22OLQZ7OPFS2QGJ6UATBY573S7EMJ4J46H4RNWBVKAUQYBZZWXUM
static immutable FK = KeyPair(PublicKey([202, 173, 105, 203, 134, 126, 231, 150, 90, 129, 147, 234, 2, 97, 199, 127, 185, 124, 140, 79, 19, 207, 31, 145, 109, 131, 85, 2, 144, 192, 115, 155]), SecretKey([0, 50, 231, 84, 47, 103, 39, 226, 158, 66, 115, 184, 219, 213, 176, 94, 156, 62, 225, 176, 41, 241, 26, 234, 114, 224, 160, 147, 136, 11, 167, 85]), Seed([23, 205, 169, 243, 3, 164, 236, 74, 63, 107, 151, 177, 124, 217, 10, 223, 227, 241, 129, 115, 5, 123, 151, 176, 225, 244, 135, 47, 6, 136, 251, 186]));
/// FL: GDFL22YITBSIMD6SDZYPGDLJPB3ITHYBUARMAOUFRHTDEHWNTA2B3KNZ
static immutable FL = KeyPair(PublicKey([202, 189, 107, 8, 152, 100, 134, 15, 210, 30, 112, 243, 13, 105, 120, 118, 137, 159, 1, 160, 34, 192, 58, 133, 137, 230, 50, 30, 205, 152, 52, 29]), SecretKey([192, 84, 100, 85, 138, 219, 197, 59, 144, 153, 123, 117, 243, 34, 101, 77, 131, 171, 248, 173, 24, 9, 9, 213, 179, 0, 249, 5, 234, 117, 63, 82]), Seed([40, 102, 234, 40, 6, 212, 14, 122, 226, 181, 99, 237, 5, 107, 25, 130, 16, 111, 170, 118, 188, 169, 176, 68, 99, 46, 186, 121, 56, 63, 94, 37]));
/// FM: GDFM22ANK2CCKIOB5LNV5DNKRUVDOONYSYA24N6UWHBI4UGYOQF3L3QT
static immutable FM = KeyPair(PublicKey([202, 205, 104, 13, 86, 132, 37, 33, 193, 234, 219, 94, 141, 170, 141, 42, 55, 57, 184, 150, 1, 174, 55, 212, 177, 194, 142, 80, 216, 116, 11, 181]), SecretKey([152, 140, 97, 215, 196, 214, 120, 184, 10, 117, 184, 245, 227, 226, 130, 126, 184, 124, 32, 72, 206, 59, 194, 135, 139, 172, 31, 202, 249, 37, 55, 87]), Seed([166, 174, 36, 130, 226, 45, 10, 7, 204, 230, 189, 176, 35, 161, 26, 21, 121, 115, 108, 29, 249, 101, 197, 22, 47, 182, 130, 86, 32, 240, 203, 97]));
/// FN: GDFN22C6DRVRA2TKC3FWWK4NC4MRLZJYAFONLMNL4VOYO5QY5AWSPMU2
static immutable FN = KeyPair(PublicKey([202, 221, 104, 94, 28, 107, 16, 106, 106, 22, 203, 107, 43, 141, 23, 25, 21, 229, 56, 1, 92, 213, 177, 171, 229, 93, 135, 118, 24, 232, 45, 39]), SecretKey([216, 225, 178, 30, 236, 213, 85, 115, 168, 92, 78, 134, 252, 158, 130, 37, 12, 61, 149, 157, 48, 111, 76, 218, 186, 112, 146, 41, 108, 236, 118, 79]), Seed([191, 211, 53, 235, 191, 159, 221, 225, 176, 178, 132, 200, 103, 243, 30, 10, 145, 77, 247, 36, 119, 192, 114, 192, 13, 154, 223, 239, 15, 203, 142, 255]));
/// FO: GDFO22EYAETWQ5C4JQR7GCK72NEK6PCEIDUJCAJMO22G7FHQSHOAJDM2
static immutable FO = KeyPair(PublicKey([202, 237, 104, 152, 1, 39, 104, 116, 92, 76, 35, 243, 9, 95, 211, 72, 175, 60, 68, 64, 232, 145, 1, 44, 118, 180, 111, 148, 240, 145, 220, 4]), SecretKey([184, 241, 183, 114, 46, 21, 233, 205, 211, 235, 221, 43, 53, 93, 154, 117, 137, 11, 14, 126, 78, 105, 48, 149, 253, 200, 89, 27, 214, 31, 52, 92]), Seed([65, 148, 234, 166, 188, 48, 102, 180, 75, 192, 4, 252, 118, 38, 66, 92, 50, 71, 22, 227, 158, 159, 191, 35, 43, 86, 84, 43, 62, 155, 59, 26]));
/// FP: GDFP22PCYOH4VOSLJ4JC6QTW6CYWCYGDYPDV4PUM73FTQMNJH6UBAF5E
static immutable FP = KeyPair(PublicKey([202, 253, 105, 226, 195, 143, 202, 186, 75, 79, 18, 47, 66, 118, 240, 177, 97, 96, 195, 195, 199, 94, 62, 140, 254, 203, 56, 49, 169, 63, 168, 16]), SecretKey([56, 95, 149, 136, 93, 126, 29, 253, 136, 95, 208, 112, 12, 82, 84, 74, 7, 8, 78, 56, 193, 224, 187, 159, 60, 70, 183, 239, 72, 168, 22, 92]), Seed([106, 90, 253, 154, 217, 51, 13, 25, 30, 235, 122, 162, 184, 204, 121, 146, 104, 96, 107, 208, 63, 38, 69, 254, 106, 146, 213, 2, 230, 40, 247, 246]));
/// FQ: GDFQ22URYVSTGRDIY5T2D6RI35LH5SQATQV5GPFSLW4WZXZZ3XH4SXVV
static immutable FQ = KeyPair(PublicKey([203, 13, 106, 145, 197, 101, 51, 68, 104, 199, 103, 161, 250, 40, 223, 86, 126, 202, 0, 156, 43, 211, 60, 178, 93, 185, 108, 223, 57, 221, 207, 201]), SecretKey([72, 251, 239, 207, 238, 66, 127, 34, 20, 154, 126, 68, 105, 67, 195, 210, 30, 85, 169, 248, 213, 184, 208, 120, 218, 163, 88, 38, 238, 85, 152, 102]), Seed([14, 154, 72, 232, 129, 159, 32, 139, 241, 71, 137, 229, 209, 158, 207, 2, 17, 180, 215, 182, 247, 199, 231, 222, 43, 185, 78, 189, 149, 162, 139, 178]));
/// FR: GDFR22WB2MFJSPEE5MOJLBUFQ26AUPDWBXQYWBTF3GCLA4YGQJ3L2ATC
static immutable FR = KeyPair(PublicKey([203, 29, 106, 193, 211, 10, 153, 60, 132, 235, 28, 149, 134, 133, 134, 188, 10, 60, 118, 13, 225, 139, 6, 101, 217, 132, 176, 115, 6, 130, 118, 189]), SecretKey([8, 25, 102, 93, 202, 90, 108, 18, 34, 23, 130, 78, 212, 78, 55, 109, 204, 224, 118, 145, 193, 110, 18, 153, 246, 9, 159, 11, 101, 33, 207, 126]), Seed([245, 154, 123, 22, 48, 25, 205, 121, 190, 35, 195, 187, 51, 12, 144, 62, 255, 212, 144, 107, 21, 179, 253, 252, 193, 108, 172, 224, 153, 3, 216, 102]));
/// FS: GDFS22LAMY6OJG323XBYAY57QAW26C2A2FCJIIQQ22SHPCYNBT4PIQNW
static immutable FS = KeyPair(PublicKey([203, 45, 105, 96, 102, 60, 228, 155, 122, 221, 195, 128, 99, 191, 128, 45, 175, 11, 64, 209, 68, 148, 34, 16, 214, 164, 119, 139, 13, 12, 248, 244]), SecretKey([24, 236, 99, 239, 147, 167, 155, 34, 101, 213, 130, 131, 249, 236, 179, 61, 177, 11, 96, 73, 39, 208, 128, 147, 200, 87, 251, 51, 25, 142, 151, 126]), Seed([227, 53, 5, 21, 10, 213, 161, 70, 165, 126, 219, 170, 17, 59, 49, 244, 169, 98, 231, 225, 176, 145, 199, 216, 97, 137, 12, 160, 99, 222, 10, 120]));
/// FT: GDFT22YPNH6XKAF2VDVMVJQK646KSAKAA7VDQ6FON7EITDCBMNOJ3E5L
static immutable FT = KeyPair(PublicKey([203, 61, 107, 15, 105, 253, 117, 0, 186, 168, 234, 202, 166, 10, 247, 60, 169, 1, 64, 7, 234, 56, 120, 174, 111, 200, 137, 140, 65, 99, 92, 157]), SecretKey([48, 94, 135, 192, 39, 11, 73, 228, 151, 96, 114, 197, 43, 204, 129, 221, 210, 108, 26, 209, 33, 185, 188, 152, 38, 3, 184, 18, 54, 65, 134, 90]), Seed([247, 226, 95, 173, 106, 125, 127, 186, 38, 193, 200, 98, 88, 184, 181, 90, 39, 13, 162, 3, 55, 247, 210, 65, 134, 95, 125, 182, 65, 105, 159, 109]));
/// FU: GDFU22SOYHFJZEQUAZ3FPECPVP7HT3LRETC6STVMQNF4EY2MULY55ZIR
static immutable FU = KeyPair(PublicKey([203, 77, 106, 78, 193, 202, 156, 146, 20, 6, 118, 87, 144, 79, 171, 254, 121, 237, 113, 36, 197, 233, 78, 172, 131, 75, 194, 99, 76, 162, 241, 222]), SecretKey([200, 57, 24, 146, 234, 230, 33, 182, 173, 21, 93, 132, 91, 81, 190, 71, 59, 186, 6, 107, 151, 211, 144, 94, 183, 56, 105, 4, 228, 149, 21, 117]), Seed([131, 188, 144, 248, 50, 42, 194, 236, 254, 44, 223, 64, 182, 3, 112, 68, 103, 233, 41, 88, 108, 202, 49, 227, 132, 181, 222, 80, 66, 94, 142, 110]));
/// FV: GDFV22BTDNG6YVOCPKGK7F62WQ4J5VTMLY2FMZ7YXBRVV6S7WL6ESXKO
static immutable FV = KeyPair(PublicKey([203, 93, 104, 51, 27, 77, 236, 85, 194, 122, 140, 175, 151, 218, 180, 56, 158, 214, 108, 94, 52, 86, 103, 248, 184, 99, 90, 250, 95, 178, 252, 73]), SecretKey([192, 78, 231, 230, 98, 49, 16, 160, 30, 96, 196, 151, 196, 194, 254, 82, 243, 110, 0, 120, 115, 246, 168, 82, 16, 103, 84, 19, 128, 135, 98, 91]), Seed([69, 183, 208, 215, 78, 74, 113, 250, 176, 24, 41, 252, 206, 67, 142, 55, 152, 188, 199, 151, 138, 136, 88, 69, 120, 189, 133, 39, 228, 248, 67, 101]));
/// FW: GDFW22QHBNC2V3MKJMRMIOQBGJIR7WKOOAJLBUDGFWPCR2CDKY5LC6WR
static immutable FW = KeyPair(PublicKey([203, 109, 106, 7, 11, 69, 170, 237, 138, 75, 34, 196, 58, 1, 50, 81, 31, 217, 78, 112, 18, 176, 208, 102, 45, 158, 40, 232, 67, 86, 58, 177]), SecretKey([232, 82, 144, 101, 1, 208, 254, 132, 126, 52, 8, 210, 195, 250, 162, 54, 49, 231, 195, 176, 18, 30, 87, 178, 118, 0, 68, 140, 200, 56, 140, 112]), Seed([118, 182, 208, 10, 111, 49, 29, 247, 51, 250, 113, 114, 8, 218, 158, 197, 185, 255, 101, 76, 7, 82, 84, 173, 56, 224, 104, 162, 7, 15, 144, 145]));
/// FX: GDFX22ID7QSOARIEAXJ3ZAWGO7YMQUNDIGSE6OA22VPYXGBW5DLI3CV3
static immutable FX = KeyPair(PublicKey([203, 125, 105, 3, 252, 36, 224, 69, 4, 5, 211, 188, 130, 198, 119, 240, 200, 81, 163, 65, 164, 79, 56, 26, 213, 95, 139, 152, 54, 232, 214, 141]), SecretKey([224, 174, 126, 211, 128, 126, 35, 130, 1, 199, 226, 3, 153, 67, 188, 80, 127, 57, 79, 14, 88, 110, 28, 14, 250, 146, 197, 108, 1, 224, 244, 126]), Seed([194, 254, 196, 205, 176, 151, 95, 191, 148, 194, 254, 221, 135, 254, 60, 33, 184, 228, 8, 26, 27, 103, 125, 153, 190, 12, 84, 161, 214, 142, 8, 96]));
/// FY: GDFY22NORIUB747RSJQ55RG2KXNQBVXHJNG5BWW55XKXWCLLGKIOHCFK
static immutable FY = KeyPair(PublicKey([203, 141, 105, 174, 138, 40, 31, 243, 241, 146, 97, 222, 196, 218, 85, 219, 0, 214, 231, 75, 77, 208, 218, 221, 237, 213, 123, 9, 107, 50, 144, 227]), SecretKey([248, 30, 167, 228, 47, 21, 63, 45, 91, 131, 37, 22, 41, 206, 230, 179, 220, 246, 239, 35, 42, 9, 93, 50, 188, 195, 102, 55, 207, 24, 232, 112]), Seed([186, 216, 237, 135, 82, 149, 170, 109, 122, 222, 119, 70, 57, 15, 177, 157, 172, 26, 235, 215, 234, 145, 180, 120, 200, 132, 105, 174, 249, 93, 143, 109]));
/// FZ: GDFZ227S5OGB7F4J45N4K4KXAOJEUWPJLMLMSRC7LVCYWI2GWDBVJAXP
static immutable FZ = KeyPair(PublicKey([203, 157, 107, 242, 235, 140, 31, 151, 137, 231, 91, 197, 113, 87, 3, 146, 74, 89, 233, 91, 22, 201, 68, 95, 93, 69, 139, 35, 70, 176, 195, 84]), SecretKey([16, 253, 2, 52, 39, 145, 81, 248, 200, 104, 39, 211, 197, 23, 106, 245, 103, 195, 177, 37, 172, 34, 217, 49, 29, 196, 28, 25, 136, 81, 186, 68]), Seed([146, 88, 139, 157, 116, 102, 172, 190, 65, 88, 52, 149, 186, 255, 181, 208, 172, 13, 74, 182, 63, 136, 191, 14, 145, 134, 20, 235, 245, 174, 87, 46]));
/// GA: GDGA22CSPBQOWS6A2IWSVOCNOYEAUIU56FIIUT2NIV5CZUN5LPJRISEU
static immutable GA = KeyPair(PublicKey([204, 13, 104, 82, 120, 96, 235, 75, 192, 210, 45, 42, 184, 77, 118, 8, 10, 34, 157, 241, 80, 138, 79, 77, 69, 122, 44, 209, 189, 91, 211, 20]), SecretKey([72, 110, 42, 72, 0, 242, 154, 49, 209, 206, 81, 204, 49, 183, 173, 203, 73, 183, 210, 110, 113, 12, 172, 173, 36, 111, 64, 2, 50, 87, 172, 68]), Seed([107, 219, 248, 95, 214, 248, 149, 116, 209, 240, 170, 190, 21, 182, 35, 181, 98, 47, 191, 21, 180, 255, 224, 121, 217, 38, 12, 132, 165, 186, 201, 120]));
/// GB: GDGB22IOJHYRPBDFW3ROQIJWN2KXXB7RSM5GDWNRKLPQ2QTH2KJ53233
static immutable GB = KeyPair(PublicKey([204, 29, 105, 14, 73, 241, 23, 132, 101, 182, 226, 232, 33, 54, 110, 149, 123, 135, 241, 147, 58, 97, 217, 177, 82, 223, 13, 66, 103, 210, 147, 221]), SecretKey([72, 218, 158, 152, 152, 41, 116, 161, 143, 244, 150, 149, 74, 138, 87, 77, 200, 152, 113, 164, 147, 218, 201, 142, 188, 17, 111, 147, 182, 38, 250, 97]), Seed([160, 160, 97, 230, 243, 155, 216, 88, 56, 7, 22, 53, 127, 11, 119, 5, 30, 157, 92, 254, 137, 55, 176, 174, 51, 9, 36, 142, 101, 200, 72, 122]));
/// GC: GDGC22FMCCMFW7JJHADTL4V3JJHLXQFFOPXMSBQ7MHU6E7FYD6ZDZWTG
static immutable GC = KeyPair(PublicKey([204, 45, 104, 172, 16, 152, 91, 125, 41, 56, 7, 53, 242, 187, 74, 78, 187, 192, 165, 115, 238, 201, 6, 31, 97, 233, 226, 124, 184, 31, 178, 60]), SecretKey([144, 174, 186, 74, 23, 123, 91, 22, 79, 190, 255, 121, 19, 193, 223, 49, 202, 219, 155, 226, 175, 220, 78, 173, 25, 75, 124, 0, 130, 77, 28, 96]), Seed([148, 41, 22, 10, 9, 9, 152, 148, 210, 33, 179, 254, 40, 144, 5, 157, 236, 177, 231, 40, 44, 240, 128, 230, 21, 61, 106, 79, 223, 177, 112, 253]));
/// GD: GDGD22RK4KNWCZJOXJJ6ZTZROLR5YV6VSB7LJ5JTNVXDOVHZMUBUPKOW
static immutable GD = KeyPair(PublicKey([204, 61, 106, 42, 226, 155, 97, 101, 46, 186, 83, 236, 207, 49, 114, 227, 220, 87, 213, 144, 126, 180, 245, 51, 109, 110, 55, 84, 249, 101, 3, 71]), SecretKey([88, 127, 176, 224, 227, 70, 117, 162, 129, 62, 51, 226, 43, 82, 134, 112, 188, 79, 0, 115, 94, 240, 103, 242, 162, 148, 142, 25, 217, 137, 132, 110]), Seed([184, 255, 52, 112, 115, 39, 62, 97, 154, 250, 54, 162, 105, 102, 25, 183, 58, 172, 26, 41, 87, 185, 195, 40, 80, 188, 0, 220, 78, 74, 124, 162]));
/// GE: GDGE22YW5OXRHAUSB62LCRJS53HVQK5JNRJFLSWDRDBOJBN3JWZ54HUX
static immutable GE = KeyPair(PublicKey([204, 77, 107, 22, 235, 175, 19, 130, 146, 15, 180, 177, 69, 50, 238, 207, 88, 43, 169, 108, 82, 85, 202, 195, 136, 194, 228, 133, 187, 77, 179, 222]), SecretKey([56, 236, 178, 10, 7, 238, 239, 189, 213, 158, 184, 189, 70, 232, 238, 150, 101, 208, 150, 156, 59, 206, 144, 83, 168, 178, 229, 67, 146, 133, 137, 86]), Seed([117, 219, 130, 179, 121, 202, 151, 126, 211, 67, 104, 237, 163, 100, 254, 169, 220, 250, 55, 52, 235, 234, 131, 159, 61, 214, 210, 179, 164, 78, 112, 132]));
/// GF: GDGF22X5S4FRW7JYFXBB25GFVFQAFSCTPVUBYD2KLUMVKTV4D2MGVRVV
static immutable GF = KeyPair(PublicKey([204, 93, 106, 253, 151, 11, 27, 125, 56, 45, 194, 29, 116, 197, 169, 96, 2, 200, 83, 125, 104, 28, 15, 74, 93, 25, 85, 78, 188, 30, 152, 106]), SecretKey([80, 173, 120, 23, 64, 8, 7, 49, 179, 212, 110, 93, 103, 192, 125, 163, 208, 181, 138, 207, 65, 205, 99, 162, 18, 94, 236, 129, 19, 125, 49, 103]), Seed([2, 59, 5, 212, 148, 13, 219, 238, 172, 240, 242, 125, 207, 119, 38, 87, 83, 104, 8, 170, 1, 245, 61, 148, 180, 206, 251, 100, 33, 214, 44, 196]));
/// GG: GDGG22R2AMDU6ENLP6GREW7XBPMHOZ3LB2DJJOQOUY66LGT46FYE6K4A
static immutable GG = KeyPair(PublicKey([204, 109, 106, 58, 3, 7, 79, 17, 171, 127, 141, 18, 91, 247, 11, 216, 119, 103, 107, 14, 134, 148, 186, 14, 166, 61, 229, 154, 124, 241, 112, 79]), SecretKey([32, 3, 136, 207, 36, 119, 171, 197, 238, 211, 242, 230, 111, 94, 205, 92, 88, 252, 111, 252, 242, 183, 168, 80, 105, 197, 111, 105, 242, 109, 84, 92]), Seed([69, 78, 71, 144, 83, 1, 112, 240, 120, 150, 57, 242, 134, 228, 202, 152, 119, 39, 63, 250, 94, 119, 101, 181, 252, 17, 70, 150, 35, 242, 109, 3]));
/// GH: GDGH22PDOHERCYSMZEECJZY7B4FVCNRPVLZFZGW5Q4JL3M6LWQXO7FQX
static immutable GH = KeyPair(PublicKey([204, 125, 105, 227, 113, 201, 17, 98, 76, 201, 8, 36, 231, 31, 15, 11, 81, 54, 47, 170, 242, 92, 154, 221, 135, 18, 189, 179, 203, 180, 46, 239]), SecretKey([48, 161, 84, 248, 4, 170, 214, 87, 123, 56, 247, 29, 66, 135, 160, 120, 221, 241, 64, 160, 172, 135, 208, 231, 121, 167, 206, 173, 170, 47, 203, 108]), Seed([185, 235, 238, 160, 53, 144, 236, 48, 44, 41, 151, 98, 219, 103, 157, 85, 221, 211, 111, 236, 145, 213, 5, 228, 106, 52, 86, 163, 239, 134, 181, 76]));
/// GI: GDGI22SR36KLXSKW77R2M6FJEYZEDUEWAIKAV237LN6KZI6P5DVC5VBC
static immutable GI = KeyPair(PublicKey([204, 141, 106, 81, 223, 148, 187, 201, 86, 255, 227, 166, 120, 169, 38, 50, 65, 208, 150, 2, 20, 10, 235, 127, 91, 124, 172, 163, 207, 232, 234, 46]), SecretKey([200, 105, 246, 132, 130, 174, 218, 48, 248, 123, 24, 254, 136, 60, 255, 101, 189, 128, 144, 110, 60, 113, 56, 96, 232, 120, 18, 36, 174, 173, 87, 117]), Seed([78, 216, 211, 7, 35, 182, 213, 137, 77, 75, 80, 229, 250, 171, 118, 106, 163, 96, 221, 74, 236, 10, 171, 233, 51, 40, 210, 246, 33, 147, 174, 150]));
/// GJ: GDGJ225DQHWTWEMKER5UXMR5L3PPBE6IQZQPB3J7W7WQYSZJXXWEHAXR
static immutable GJ = KeyPair(PublicKey([204, 157, 107, 163, 129, 237, 59, 17, 138, 36, 123, 75, 178, 61, 94, 222, 240, 147, 200, 134, 96, 240, 237, 63, 183, 237, 12, 75, 41, 189, 236, 67]), SecretKey([224, 31, 98, 85, 177, 229, 46, 125, 18, 90, 211, 253, 172, 247, 185, 88, 109, 140, 172, 40, 81, 223, 177, 154, 175, 151, 199, 128, 4, 32, 212, 79]), Seed([251, 29, 2, 164, 221, 147, 131, 148, 205, 22, 241, 9, 47, 206, 58, 203, 132, 235, 8, 201, 102, 190, 126, 210, 74, 1, 117, 106, 144, 35, 198, 163]));
/// GK: GDGK22RJZ4JLGAQS3XDLH46OXYMX6RWXNKTTPNUCPGVB7F43LTNOWEXJ
static immutable GK = KeyPair(PublicKey([204, 173, 106, 41, 207, 18, 179, 2, 18, 221, 198, 179, 243, 206, 190, 25, 127, 70, 215, 106, 167, 55, 182, 130, 121, 170, 31, 151, 155, 92, 218, 235]), SecretKey([144, 139, 182, 205, 211, 193, 224, 214, 44, 248, 145, 9, 115, 230, 61, 187, 223, 4, 249, 136, 247, 245, 146, 209, 117, 254, 215, 217, 31, 54, 66, 102]), Seed([60, 252, 49, 164, 43, 163, 27, 223, 247, 214, 159, 171, 23, 0, 43, 205, 82, 177, 38, 146, 102, 109, 28, 251, 148, 99, 184, 196, 249, 27, 41, 255]));
/// GL: GDGL22UDZA4PLZZHIL2EQZKWM6ILOJWOIB7W6DRW4EWV7TZWPPS3J2VJ
static immutable GL = KeyPair(PublicKey([204, 189, 106, 131, 200, 56, 245, 231, 39, 66, 244, 72, 101, 86, 103, 144, 183, 38, 206, 64, 127, 111, 14, 54, 225, 45, 95, 207, 54, 123, 229, 180]), SecretKey([240, 108, 109, 153, 49, 64, 123, 166, 28, 111, 131, 49, 226, 50, 154, 106, 73, 101, 57, 153, 225, 128, 194, 140, 203, 36, 127, 168, 195, 92, 231, 65]), Seed([94, 37, 74, 104, 216, 164, 27, 25, 204, 252, 36, 54, 144, 34, 252, 237, 120, 194, 94, 251, 172, 225, 75, 166, 194, 24, 63, 228, 163, 36, 25, 252]));
/// GM: GDGM22FDC2JPYARPRMQYNUKSTKCO3Q6PXJLG6FM2KU5RX5GWDDIJ5WI3
static immutable GM = KeyPair(PublicKey([204, 205, 104, 163, 22, 146, 252, 2, 47, 139, 33, 134, 209, 82, 154, 132, 237, 195, 207, 186, 86, 111, 21, 154, 85, 59, 27, 244, 214, 24, 208, 158]), SecretKey([144, 92, 212, 73, 21, 197, 181, 156, 180, 107, 71, 107, 123, 240, 87, 225, 87, 57, 17, 29, 171, 200, 45, 35, 23, 155, 212, 69, 125, 205, 45, 106]), Seed([109, 179, 173, 159, 147, 144, 235, 188, 159, 28, 231, 67, 225, 118, 231, 18, 128, 13, 235, 229, 146, 224, 133, 255, 105, 47, 230, 196, 208, 225, 231, 207]));
/// GN: GDGN22MUD265DBYWG44WDMZUCF2QBKEUXVAYVOJF7PY336EVLWMTILV7
static immutable GN = KeyPair(PublicKey([204, 221, 105, 148, 30, 189, 209, 135, 22, 55, 57, 97, 179, 52, 17, 117, 0, 168, 148, 189, 65, 138, 185, 37, 251, 241, 189, 248, 149, 93, 153, 52]), SecretKey([192, 234, 173, 25, 128, 73, 28, 128, 95, 240, 79, 112, 110, 152, 194, 183, 206, 198, 13, 250, 36, 117, 224, 195, 47, 35, 175, 246, 88, 137, 50, 105]), Seed([115, 72, 229, 116, 66, 112, 245, 108, 147, 136, 40, 9, 113, 19, 98, 175, 46, 91, 90, 236, 57, 150, 203, 173, 183, 132, 134, 96, 139, 217, 213, 225]));
/// GO: GDGO22RU5Z7ETJSTXPLPCPPS7NS5ETE5LKEX37EVY2CZYNCHIHUG5XEV
static immutable GO = KeyPair(PublicKey([204, 237, 106, 52, 238, 126, 73, 166, 83, 187, 214, 241, 61, 242, 251, 101, 210, 76, 157, 90, 137, 125, 252, 149, 198, 133, 156, 52, 71, 65, 232, 110]), SecretKey([32, 208, 59, 169, 86, 179, 196, 90, 69, 98, 13, 19, 153, 58, 65, 229, 149, 140, 139, 216, 255, 222, 76, 202, 202, 206, 94, 164, 190, 106, 212, 64]), Seed([122, 181, 42, 110, 102, 85, 146, 230, 233, 183, 122, 118, 15, 220, 62, 77, 141, 135, 82, 242, 188, 98, 249, 219, 170, 74, 216, 239, 9, 239, 203, 125]));
/// GP: GDGP22POUYZ572WKOTHOCF627XYPB6FNBB7OADCS53AYDZZXNP5W5Q6F
static immutable GP = KeyPair(PublicKey([204, 253, 105, 238, 166, 51, 223, 234, 202, 116, 206, 225, 23, 218, 253, 240, 240, 248, 173, 8, 126, 224, 12, 82, 238, 193, 129, 231, 55, 107, 251, 110]), SecretKey([96, 225, 146, 238, 48, 76, 253, 146, 52, 73, 19, 128, 174, 75, 123, 20, 61, 227, 94, 37, 60, 137, 120, 48, 65, 213, 191, 82, 0, 92, 157, 90]), Seed([218, 253, 164, 107, 101, 121, 184, 173, 158, 230, 6, 52, 227, 36, 98, 8, 0, 201, 23, 97, 13, 56, 23, 72, 167, 152, 99, 92, 146, 148, 130, 212]));
/// GQ: GDGQ22CTYNPD5US2JY6VI6MI5EOUXWMHYPKMTNOMW5MSJDWMVJRV3PKT
static immutable GQ = KeyPair(PublicKey([205, 13, 104, 83, 195, 94, 62, 210, 90, 78, 61, 84, 121, 136, 233, 29, 75, 217, 135, 195, 212, 201, 181, 204, 183, 89, 36, 142, 204, 170, 99, 93]), SecretKey([224, 37, 132, 217, 67, 223, 138, 11, 92, 101, 206, 251, 202, 172, 24, 170, 166, 202, 5, 213, 166, 160, 6, 175, 16, 110, 115, 61, 68, 95, 49, 66]), Seed([175, 212, 128, 57, 61, 81, 171, 219, 135, 97, 192, 187, 113, 238, 113, 81, 138, 67, 186, 135, 3, 124, 90, 162, 96, 54, 57, 108, 134, 17, 242, 229]));
/// GR: GDGR225FDNPZCKIA7VRELLEF3UKXKASASG5NEHBDQLCM26O53WDSONO4
static immutable GR = KeyPair(PublicKey([205, 29, 107, 165, 27, 95, 145, 41, 0, 253, 98, 69, 172, 133, 221, 21, 117, 2, 64, 145, 186, 210, 28, 35, 130, 196, 205, 121, 221, 221, 135, 39]), SecretKey([80, 168, 125, 111, 53, 151, 185, 145, 72, 177, 64, 193, 217, 160, 101, 175, 91, 79, 36, 139, 191, 198, 156, 106, 9, 127, 28, 216, 182, 174, 145, 100]), Seed([174, 41, 104, 8, 201, 154, 251, 161, 95, 210, 11, 250, 127, 151, 99, 213, 237, 247, 49, 178, 201, 141, 165, 56, 179, 92, 133, 5, 65, 144, 212, 109]));
/// GS: GDGS225YURYUQUXGDOOKPC3UEZTXIYVJFRYJWD6MR3EJIMBFPNFMYLCM
static immutable GS = KeyPair(PublicKey([205, 45, 107, 184, 164, 113, 72, 82, 230, 27, 156, 167, 139, 116, 38, 103, 116, 98, 169, 44, 112, 155, 15, 204, 142, 200, 148, 48, 37, 123, 74, 204]), SecretKey([224, 255, 240, 230, 28, 48, 212, 253, 171, 103, 181, 5, 177, 182, 159, 203, 110, 181, 221, 129, 176, 77, 119, 19, 244, 172, 201, 247, 84, 178, 246, 103]), Seed([207, 40, 20, 94, 142, 147, 31, 82, 87, 141, 131, 30, 39, 189, 41, 21, 79, 92, 75, 140, 53, 169, 229, 251, 243, 182, 41, 76, 124, 75, 253, 156]));
/// GT: GDGT22RZ76FJN3YKIP4CJ5TYHHM7U77TAUHHORGGMXZ6IQ5LCJ65MIZG
static immutable GT = KeyPair(PublicKey([205, 61, 106, 57, 255, 138, 150, 239, 10, 67, 248, 36, 246, 120, 57, 217, 250, 127, 243, 5, 14, 119, 68, 198, 101, 243, 228, 67, 171, 18, 125, 214]), SecretKey([24, 84, 185, 203, 97, 73, 71, 174, 100, 62, 10, 198, 121, 244, 225, 201, 5, 144, 21, 191, 42, 130, 3, 70, 177, 162, 223, 232, 72, 48, 55, 100]), Seed([17, 245, 103, 202, 250, 87, 201, 216, 148, 225, 176, 66, 160, 88, 100, 94, 67, 186, 189, 129, 117, 24, 137, 15, 148, 233, 108, 136, 236, 206, 47, 107]));
/// GU: GDGU22Q5PQEPRLO4V6STISECUIBGKN4NMY43XOYANKQ647PJ4653P7GD
static immutable GU = KeyPair(PublicKey([205, 77, 106, 29, 124, 8, 248, 173, 220, 175, 165, 52, 72, 130, 162, 2, 101, 55, 141, 102, 57, 187, 187, 0, 106, 161, 238, 125, 233, 231, 187, 183]), SecretKey([88, 168, 13, 254, 132, 132, 116, 21, 167, 45, 148, 216, 108, 228, 220, 237, 128, 182, 49, 157, 60, 79, 53, 70, 236, 125, 159, 238, 132, 50, 207, 89]), Seed([60, 18, 77, 208, 205, 51, 191, 68, 188, 60, 48, 225, 22, 84, 44, 123, 84, 190, 21, 187, 245, 203, 68, 149, 181, 35, 171, 163, 86, 66, 215, 129]));
/// GV: GDGV22LN6KCVKKPAGCNMHPGOJVX7KLB3I2P52FITIEI4L5ZKV5RLTMYB
static immutable GV = KeyPair(PublicKey([205, 93, 105, 109, 242, 133, 85, 41, 224, 48, 154, 195, 188, 206, 77, 111, 245, 44, 59, 70, 159, 221, 21, 19, 65, 17, 197, 247, 42, 175, 98, 185]), SecretKey([120, 207, 120, 158, 50, 8, 72, 138, 138, 188, 217, 242, 74, 55, 101, 241, 225, 163, 168, 121, 144, 46, 247, 63, 48, 130, 113, 18, 68, 169, 81, 127]), Seed([234, 169, 229, 116, 69, 58, 210, 55, 124, 28, 141, 228, 255, 204, 37, 252, 244, 7, 219, 126, 98, 161, 116, 149, 158, 66, 106, 8, 89, 96, 250, 249]));
/// GW: GDGW223H666HCHK5ODIDMDW6U6RP6BS4JZ7YBM7YZVEZ4IKHTI456KX3
static immutable GW = KeyPair(PublicKey([205, 109, 107, 103, 247, 188, 113, 29, 93, 112, 208, 54, 14, 222, 167, 162, 255, 6, 92, 78, 127, 128, 179, 248, 205, 73, 158, 33, 71, 154, 57, 223]), SecretKey([208, 192, 171, 218, 202, 55, 139, 194, 81, 3, 22, 15, 38, 230, 10, 6, 125, 186, 49, 36, 188, 1, 139, 3, 235, 234, 186, 120, 77, 147, 17, 73]), Seed([227, 26, 199, 100, 119, 20, 162, 181, 134, 231, 104, 12, 42, 91, 241, 195, 57, 192, 182, 143, 61, 117, 215, 112, 5, 215, 141, 128, 181, 38, 162, 163]));
/// GX: GDGX22ISXJXACDCVV5DOBQSZF7EY3HHTSEBZULRN74V6FXMB6STFPYWE
static immutable GX = KeyPair(PublicKey([205, 125, 105, 18, 186, 110, 1, 12, 85, 175, 70, 224, 194, 89, 47, 201, 141, 156, 243, 145, 3, 154, 46, 45, 255, 43, 226, 221, 129, 244, 166, 87]), SecretKey([128, 229, 120, 199, 211, 180, 127, 113, 12, 100, 10, 75, 121, 12, 190, 130, 173, 44, 226, 10, 165, 97, 179, 206, 161, 14, 16, 123, 12, 209, 93, 122]), Seed([252, 117, 72, 81, 127, 183, 120, 11, 73, 253, 194, 241, 85, 101, 163, 133, 248, 252, 115, 93, 215, 225, 77, 94, 118, 83, 135, 214, 78, 246, 65, 71]));
/// GY: GDGY22O4BT7QPD46LP2GKFTE3VKQS5IS5GN5BSMD7JJ5RW5KFMZWIVWO
static immutable GY = KeyPair(PublicKey([205, 141, 105, 220, 12, 255, 7, 143, 158, 91, 244, 101, 22, 100, 221, 85, 9, 117, 18, 233, 155, 208, 201, 131, 250, 83, 216, 219, 170, 43, 51, 100]), SecretKey([16, 162, 92, 180, 138, 96, 52, 234, 222, 242, 228, 64, 63, 222, 219, 55, 148, 225, 0, 143, 207, 77, 228, 184, 150, 99, 172, 111, 64, 235, 218, 104]), Seed([104, 108, 222, 253, 65, 96, 66, 217, 110, 213, 1, 199, 37, 173, 64, 195, 116, 179, 105, 113, 210, 207, 133, 138, 131, 216, 113, 168, 189, 153, 168, 107]));
/// GZ: GDGZ22UK6SGECQEROZYPU5NOOMB7SP5V4RV3KZAJPHTEBACXWFAITFUA
static immutable GZ = KeyPair(PublicKey([205, 157, 106, 138, 244, 140, 65, 64, 145, 118, 112, 250, 117, 174, 115, 3, 249, 63, 181, 228, 107, 181, 100, 9, 121, 230, 64, 128, 87, 177, 64, 137]), SecretKey([64, 120, 109, 104, 40, 232, 219, 122, 145, 6, 198, 114, 233, 251, 217, 190, 200, 158, 171, 142, 156, 22, 81, 81, 119, 164, 23, 206, 135, 119, 29, 118]), Seed([227, 186, 222, 249, 67, 166, 225, 198, 93, 130, 229, 87, 93, 176, 169, 196, 249, 4, 103, 19, 212, 87, 72, 71, 232, 231, 73, 108, 221, 183, 171, 239]));
/// HA: GDHA22Q63OQROJZQEA5MZ2WTM4HOF6Y3KMIRRBCDF2CJIHDKTJX6UOAP
static immutable HA = KeyPair(PublicKey([206, 13, 106, 30, 219, 161, 23, 39, 48, 32, 58, 204, 234, 211, 103, 14, 226, 251, 27, 83, 17, 24, 132, 67, 46, 132, 148, 28, 106, 154, 111, 234]), SecretKey([224, 96, 164, 55, 204, 55, 124, 166, 116, 181, 110, 184, 100, 64, 220, 242, 65, 128, 246, 87, 39, 75, 99, 220, 108, 34, 194, 237, 134, 242, 117, 96]), Seed([177, 16, 92, 196, 221, 131, 228, 220, 248, 237, 20, 94, 3, 190, 203, 168, 144, 45, 145, 34, 202, 113, 145, 248, 98, 28, 119, 36, 233, 115, 31, 18]));
/// HB: GDHB22CIN6WNLTRR6LDWLV3LV6YEWOFEWF3Z2CTFSPTRDY5QVYLC4FU3
static immutable HB = KeyPair(PublicKey([206, 29, 104, 72, 111, 172, 213, 206, 49, 242, 199, 101, 215, 107, 175, 176, 75, 56, 164, 177, 119, 157, 10, 101, 147, 231, 17, 227, 176, 174, 22, 46]), SecretKey([240, 164, 146, 147, 175, 80, 99, 221, 132, 51, 29, 37, 193, 64, 54, 208, 231, 39, 169, 116, 194, 9, 73, 132, 228, 7, 196, 2, 172, 137, 189, 81]), Seed([57, 94, 10, 146, 215, 59, 28, 142, 7, 187, 195, 67, 35, 225, 99, 160, 214, 26, 243, 65, 222, 58, 184, 182, 252, 173, 231, 72, 46, 95, 242, 113]));
/// HC: GDHC22Z7VX2MW4KDMSX3XL5GKTIH5NVX4TNDM6KOXBCWJUFTX2NJI4NQ
static immutable HC = KeyPair(PublicKey([206, 45, 107, 63, 173, 244, 203, 113, 67, 100, 175, 187, 175, 166, 84, 208, 126, 182, 183, 228, 218, 54, 121, 78, 184, 69, 100, 208, 179, 190, 154, 148]), SecretKey([160, 104, 2, 226, 115, 176, 60, 8, 99, 99, 177, 30, 143, 114, 46, 75, 73, 90, 2, 8, 8, 96, 136, 50, 239, 154, 129, 147, 181, 237, 10, 90]), Seed([83, 107, 158, 255, 89, 0, 62, 170, 197, 139, 62, 1, 32, 164, 174, 161, 30, 152, 227, 131, 233, 26, 182, 152, 72, 76, 177, 230, 163, 249, 44, 93]));
/// HD: GDHD22OF7E6L637BKQYJKTSAUPLWSOYMPBLZR3KLISJNZZ4HJIWDG2TK
static immutable HD = KeyPair(PublicKey([206, 61, 105, 197, 249, 60, 191, 111, 225, 84, 48, 149, 78, 64, 163, 215, 105, 59, 12, 120, 87, 152, 237, 75, 68, 146, 220, 231, 135, 74, 44, 51]), SecretKey([0, 215, 143, 157, 29, 110, 16, 95, 82, 140, 168, 110, 212, 194, 71, 28, 176, 195, 58, 182, 87, 252, 241, 104, 58, 215, 113, 77, 20, 209, 44, 106]), Seed([41, 48, 107, 118, 76, 120, 145, 175, 138, 208, 149, 181, 247, 228, 249, 114, 19, 164, 43, 4, 107, 154, 145, 158, 177, 44, 141, 116, 19, 66, 18, 102]));
/// HE: GDHE22NPJZOA7JRBSJEZYFLGLEUNQZF7I5NOLORBGTXUSCYRFXPG7RL3
static immutable HE = KeyPair(PublicKey([206, 77, 105, 175, 78, 92, 15, 166, 33, 146, 73, 156, 21, 102, 89, 40, 216, 100, 191, 71, 90, 229, 186, 33, 52, 239, 73, 11, 17, 45, 222, 111]), SecretKey([56, 80, 67, 217, 150, 71, 107, 172, 194, 89, 247, 56, 66, 21, 211, 166, 49, 248, 201, 148, 66, 33, 163, 100, 33, 1, 240, 113, 148, 139, 183, 123]), Seed([53, 104, 71, 81, 157, 185, 100, 216, 157, 69, 15, 176, 103, 21, 126, 249, 0, 72, 146, 13, 196, 150, 254, 13, 17, 149, 30, 198, 191, 7, 17, 42]));
/// HF: GDHF22G6Q3LJJSBRSGATMCBQE7ZFHM3H56FSCV3UCMVONRYHTAJBI3OY
static immutable HF = KeyPair(PublicKey([206, 93, 104, 222, 134, 214, 148, 200, 49, 145, 129, 54, 8, 48, 39, 242, 83, 179, 103, 239, 139, 33, 87, 116, 19, 42, 230, 199, 7, 152, 18, 20]), SecretKey([96, 200, 242, 223, 178, 192, 59, 253, 119, 170, 155, 38, 66, 171, 14, 168, 15, 199, 81, 189, 147, 35, 27, 191, 31, 54, 197, 242, 231, 42, 126, 88]), Seed([235, 74, 204, 124, 195, 164, 134, 163, 221, 176, 117, 55, 24, 83, 39, 67, 45, 93, 142, 212, 146, 39, 144, 111, 207, 175, 32, 77, 8, 201, 174, 22]));
/// HG: GDHG22FLLCNAXFHJJVB7ZHWYWB3LEFRWG47EF3IQDARK4L22N4Z26JX3
static immutable HG = KeyPair(PublicKey([206, 109, 104, 171, 88, 154, 11, 148, 233, 77, 67, 252, 158, 216, 176, 118, 178, 22, 54, 55, 62, 66, 237, 16, 24, 34, 174, 47, 90, 111, 51, 175]), SecretKey([120, 157, 246, 165, 162, 13, 233, 144, 126, 211, 109, 127, 109, 87, 246, 87, 129, 183, 146, 204, 214, 135, 169, 83, 239, 172, 176, 156, 126, 253, 122, 103]), Seed([72, 15, 200, 14, 125, 231, 202, 97, 163, 91, 58, 180, 62, 37, 186, 225, 33, 3, 247, 235, 105, 52, 52, 153, 73, 191, 136, 25, 245, 141, 146, 121]));
/// HH: GDHH22KBAQ7IQPOIJ7UIVJSOPXAPUXOCRY5YLFIFQRTVLGDQGRPBQOWY
static immutable HH = KeyPair(PublicKey([206, 125, 105, 65, 4, 62, 136, 61, 200, 79, 232, 138, 166, 78, 125, 192, 250, 93, 194, 142, 59, 133, 149, 5, 132, 103, 85, 152, 112, 52, 94, 24]), SecretKey([8, 236, 183, 248, 195, 212, 250, 39, 61, 148, 118, 237, 236, 12, 33, 200, 142, 51, 121, 97, 251, 45, 188, 236, 164, 178, 115, 120, 194, 10, 35, 75]), Seed([100, 231, 217, 168, 198, 124, 192, 51, 199, 170, 4, 30, 170, 164, 211, 161, 214, 245, 10, 155, 184, 8, 161, 132, 223, 238, 3, 79, 197, 116, 248, 151]));
/// HI: GDHI22UFRUGLSJ3FV5BQEACYXZILWKWEGDNL5CCCGL4EZ46J74UGFUIL
static immutable HI = KeyPair(PublicKey([206, 141, 106, 133, 141, 12, 185, 39, 101, 175, 67, 2, 0, 88, 190, 80, 187, 42, 196, 48, 218, 190, 136, 66, 50, 248, 76, 243, 201, 255, 40, 98]), SecretKey([176, 104, 245, 91, 172, 143, 209, 22, 45, 83, 52, 107, 116, 33, 201, 230, 19, 188, 32, 8, 103, 117, 185, 83, 25, 250, 164, 76, 139, 195, 232, 120]), Seed([162, 133, 220, 52, 134, 140, 200, 157, 127, 161, 20, 244, 66, 81, 213, 178, 203, 79, 94, 8, 102, 135, 172, 211, 73, 192, 252, 1, 90, 26, 109, 239]));
/// HJ: GDHJ22A7D6KKHM56UQRRQVQSBBC52W44K72DLITVEGDN4GGFYNK3ZPLF
static immutable HJ = KeyPair(PublicKey([206, 157, 104, 31, 31, 148, 163, 179, 190, 164, 35, 24, 86, 18, 8, 69, 221, 91, 156, 87, 244, 53, 162, 117, 33, 134, 222, 24, 197, 195, 85, 188]), SecretKey([208, 196, 152, 129, 63, 164, 184, 127, 158, 187, 201, 111, 142, 130, 21, 33, 226, 148, 82, 227, 148, 198, 184, 213, 68, 45, 0, 159, 0, 28, 163, 98]), Seed([93, 255, 135, 45, 105, 254, 142, 120, 31, 177, 83, 149, 149, 184, 184, 40, 41, 221, 107, 128, 0, 238, 26, 71, 11, 173, 101, 26, 212, 6, 252, 84]));
/// HK: GDHK22HPPOD54UMTBVXNHUZWDB7BGABCA7OOFQWHC25UC4UMJ2APSV2Z
static immutable HK = KeyPair(PublicKey([206, 173, 104, 239, 123, 135, 222, 81, 147, 13, 110, 211, 211, 54, 24, 126, 19, 0, 34, 7, 220, 226, 194, 199, 22, 187, 65, 114, 140, 78, 128, 249]), SecretKey([0, 178, 96, 91, 126, 67, 131, 166, 143, 45, 4, 72, 149, 228, 7, 232, 50, 154, 22, 171, 190, 169, 246, 250, 101, 23, 112, 2, 121, 216, 79, 90]), Seed([131, 14, 141, 53, 184, 215, 214, 18, 217, 124, 72, 158, 67, 87, 148, 162, 20, 113, 189, 8, 116, 177, 217, 229, 82, 72, 45, 30, 195, 68, 125, 7]));
/// HL: GDHL22MMGXMJ74V3SBKBJEL6LUDOIF2HZ7DXK2MMJ7X2NW2W5VYVPDMH
static immutable HL = KeyPair(PublicKey([206, 189, 105, 140, 53, 216, 159, 242, 187, 144, 84, 20, 145, 126, 93, 6, 228, 23, 71, 207, 199, 117, 105, 140, 79, 239, 166, 219, 86, 237, 113, 87]), SecretKey([40, 117, 60, 51, 152, 86, 234, 16, 240, 37, 70, 217, 59, 240, 39, 16, 173, 249, 155, 229, 83, 244, 158, 172, 197, 218, 92, 84, 194, 141, 88, 122]), Seed([80, 19, 199, 69, 208, 209, 16, 111, 61, 224, 72, 175, 231, 93, 220, 150, 128, 63, 28, 35, 144, 121, 234, 92, 49, 31, 222, 239, 230, 4, 189, 250]));
/// HM: GDHM227VO4FPNK3EEMT5OHIJTYSKLHSYGE4M5GQP7GKU4F7ELLYAU2FZ
static immutable HM = KeyPair(PublicKey([206, 205, 107, 245, 119, 10, 246, 171, 100, 35, 39, 215, 29, 9, 158, 36, 165, 158, 88, 49, 56, 206, 154, 15, 249, 149, 78, 23, 228, 90, 240, 10]), SecretKey([80, 154, 144, 227, 189, 197, 83, 138, 66, 150, 20, 233, 82, 39, 43, 102, 209, 212, 156, 221, 203, 138, 64, 116, 152, 203, 78, 155, 246, 105, 197, 65]), Seed([221, 86, 174, 64, 126, 164, 231, 23, 234, 183, 230, 187, 208, 95, 203, 117, 56, 176, 130, 205, 190, 148, 152, 109, 235, 27, 148, 59, 71, 182, 214, 85]));
/// HN: GDHN22XVKRY37PBFXKWWVHPWU4KHFSVPMX6IZ3QIW5H2T4AMUPO3EYEO
static immutable HN = KeyPair(PublicKey([206, 221, 106, 245, 84, 113, 191, 188, 37, 186, 173, 106, 157, 246, 167, 20, 114, 202, 175, 101, 252, 140, 238, 8, 183, 79, 169, 240, 12, 163, 221, 178]), SecretKey([144, 177, 52, 161, 123, 219, 209, 175, 247, 162, 143, 106, 21, 236, 100, 207, 182, 254, 229, 180, 8, 162, 114, 79, 225, 96, 28, 196, 132, 196, 212, 85]), Seed([132, 139, 46, 208, 180, 62, 215, 201, 247, 26, 158, 24, 34, 64, 164, 234, 51, 28, 155, 62, 6, 93, 85, 130, 129, 139, 82, 82, 218, 30, 126, 110]));
/// HO: GDHO22GZDASFAUXJUOGBJLOPKDJH3ESSM4FVXKQ7V6CQHKELXJC37T3U
static immutable HO = KeyPair(PublicKey([206, 237, 104, 217, 24, 36, 80, 82, 233, 163, 140, 20, 173, 207, 80, 210, 125, 146, 82, 103, 11, 91, 170, 31, 175, 133, 3, 168, 139, 186, 69, 191]), SecretKey([104, 242, 56, 195, 57, 65, 73, 255, 230, 238, 237, 85, 236, 65, 93, 227, 204, 190, 12, 233, 234, 218, 52, 216, 21, 99, 205, 107, 199, 14, 91, 78]), Seed([110, 11, 36, 145, 68, 10, 109, 81, 194, 33, 122, 179, 236, 195, 206, 51, 202, 156, 145, 123, 76, 37, 146, 212, 123, 188, 199, 171, 153, 42, 158, 167]));
/// HP: GDHP222PLF7ONFQUJZZZ5G7AAUFVHCW2X2NP2IG2TQYRBPAINP2QVW5F
static immutable HP = KeyPair(PublicKey([206, 253, 107, 79, 89, 126, 230, 150, 20, 78, 115, 158, 155, 224, 5, 11, 83, 138, 218, 190, 154, 253, 32, 218, 156, 49, 16, 188, 8, 107, 245, 10]), SecretKey([144, 217, 142, 213, 70, 195, 119, 108, 161, 71, 158, 27, 21, 212, 158, 36, 59, 94, 158, 231, 127, 227, 136, 142, 210, 101, 119, 249, 254, 108, 203, 104]), Seed([194, 186, 163, 49, 204, 24, 58, 170, 9, 23, 146, 104, 101, 26, 26, 107, 244, 107, 244, 216, 91, 12, 19, 88, 135, 117, 40, 221, 132, 112, 17, 168]));
/// HQ: GDHQ22AVCAMCZTACMYXZYHDUBNDGRDX4WHVVCIPCGBGBXIA7U6KXFLMO
static immutable HQ = KeyPair(PublicKey([207, 13, 104, 21, 16, 24, 44, 204, 2, 102, 47, 156, 28, 116, 11, 70, 104, 142, 252, 177, 235, 81, 33, 226, 48, 76, 27, 160, 31, 167, 149, 114]), SecretKey([232, 187, 56, 15, 237, 3, 220, 255, 94, 129, 40, 11, 249, 238, 248, 61, 70, 170, 220, 160, 68, 27, 100, 81, 251, 158, 148, 210, 140, 131, 142, 102]), Seed([139, 0, 94, 45, 124, 144, 175, 48, 31, 245, 7, 5, 132, 202, 185, 88, 219, 21, 6, 112, 139, 218, 232, 48, 180, 250, 71, 22, 166, 80, 114, 39]));
/// HR: GDHR222VMPPUQGDVAA7QQDIKHRAXGCHP5LZIKNPTRLB6NLVO2LLOT64L
static immutable HR = KeyPair(PublicKey([207, 29, 107, 85, 99, 223, 72, 24, 117, 0, 63, 8, 13, 10, 60, 65, 115, 8, 239, 234, 242, 133, 53, 243, 138, 195, 230, 174, 174, 210, 214, 233]), SecretKey([96, 114, 10, 58, 165, 17, 146, 249, 52, 30, 19, 102, 253, 4, 146, 91, 252, 17, 68, 131, 237, 228, 4, 88, 84, 223, 193, 11, 211, 114, 59, 106]), Seed([182, 164, 233, 252, 213, 137, 6, 30, 171, 108, 78, 214, 26, 136, 56, 122, 248, 85, 198, 72, 127, 74, 10, 183, 89, 133, 77, 210, 18, 63, 2, 190]));
/// HS: GDHS223YAIFLTPENAFVDRN6ITZPWDUNZ2VZTNTKICH5VOATKRUBYG7CO
static immutable HS = KeyPair(PublicKey([207, 45, 107, 120, 2, 10, 185, 188, 141, 1, 106, 56, 183, 200, 158, 95, 97, 209, 185, 213, 115, 54, 205, 72, 17, 251, 87, 2, 106, 141, 3, 131]), SecretKey([168, 49, 5, 12, 62, 170, 214, 238, 209, 246, 128, 142, 55, 194, 248, 95, 79, 139, 81, 28, 123, 99, 80, 91, 23, 54, 144, 181, 114, 54, 78, 81]), Seed([38, 51, 236, 89, 155, 42, 16, 58, 152, 28, 241, 68, 96, 179, 90, 29, 10, 76, 153, 29, 55, 145, 66, 54, 39, 100, 40, 2, 162, 65, 161, 117]));
/// HT: GDHT22OV6LAN7DP4IVPRIKAL5KRSPEQ7TICWMSP6DUOWOFUKQ4X7ELFH
static immutable HT = KeyPair(PublicKey([207, 61, 105, 213, 242, 192, 223, 141, 252, 69, 95, 20, 40, 11, 234, 163, 39, 146, 31, 154, 5, 102, 73, 254, 29, 29, 103, 22, 138, 135, 47, 242]), SecretKey([192, 186, 22, 115, 10, 35, 156, 27, 8, 166, 139, 240, 78, 132, 121, 158, 162, 108, 190, 201, 22, 114, 62, 57, 153, 166, 205, 16, 201, 196, 14, 69]), Seed([136, 43, 196, 229, 59, 163, 79, 21, 66, 59, 176, 151, 250, 176, 153, 242, 144, 49, 148, 78, 44, 68, 31, 46, 160, 14, 226, 42, 244, 232, 180, 141]));
/// HU: GDHU22L5O5BSVZXTEWTZOGD666HEMEOGMQAGSNUFIHZFGOJH6LSSTSDC
static immutable HU = KeyPair(PublicKey([207, 77, 105, 125, 119, 67, 42, 230, 243, 37, 167, 151, 24, 126, 247, 142, 70, 17, 198, 100, 0, 105, 54, 133, 65, 242, 83, 57, 39, 242, 229, 41]), SecretKey([168, 18, 130, 56, 88, 111, 206, 109, 61, 45, 229, 214, 138, 117, 45, 187, 134, 181, 170, 148, 55, 230, 71, 118, 254, 149, 12, 187, 121, 13, 15, 110]), Seed([214, 157, 226, 168, 174, 151, 53, 174, 51, 93, 67, 67, 130, 120, 95, 106, 154, 66, 57, 145, 132, 87, 58, 143, 13, 86, 217, 126, 211, 70, 79, 23]));
/// HV: GDHV224A44TEMZOTHUW7ZLXEDT7EKBEB7W4EMCNN2FW7TAP3RHAA34KQ
static immutable HV = KeyPair(PublicKey([207, 93, 107, 128, 231, 38, 70, 101, 211, 61, 45, 252, 174, 228, 28, 254, 69, 4, 129, 253, 184, 70, 9, 173, 209, 109, 249, 129, 251, 137, 192, 13]), SecretKey([32, 45, 74, 199, 82, 13, 246, 31, 90, 95, 169, 87, 35, 78, 84, 185, 31, 122, 144, 8, 142, 163, 16, 200, 132, 112, 230, 32, 5, 109, 115, 119]), Seed([207, 149, 134, 120, 249, 144, 162, 238, 196, 191, 84, 51, 235, 76, 67, 45, 195, 75, 48, 78, 207, 105, 207, 227, 117, 74, 188, 157, 109, 20, 27, 243]));
/// HW: GDHW22YTTOQZLZC25J5MDPKS2JHBZ2C2W43HTMAXMAFFC5JHTSHEO223
static immutable HW = KeyPair(PublicKey([207, 109, 107, 19, 155, 161, 149, 228, 90, 234, 122, 193, 189, 82, 210, 78, 28, 232, 90, 183, 54, 121, 176, 23, 96, 10, 81, 117, 39, 156, 142, 71]), SecretKey([232, 235, 229, 161, 251, 48, 128, 19, 176, 3, 58, 110, 202, 82, 106, 10, 53, 52, 146, 104, 226, 176, 118, 255, 130, 61, 179, 209, 214, 214, 114, 120]), Seed([32, 115, 80, 24, 47, 106, 217, 29, 107, 206, 203, 78, 27, 73, 107, 79, 85, 106, 140, 72, 1, 106, 41, 15, 128, 76, 230, 97, 134, 5, 209, 154]));
/// HX: GDHX22LURP3D5TAQDEJNRHITU4X7RBTYBBFJAYA7B24M7SSTP4VOIIGX
static immutable HX = KeyPair(PublicKey([207, 125, 105, 116, 139, 246, 62, 204, 16, 25, 18, 216, 157, 19, 167, 47, 248, 134, 120, 8, 74, 144, 96, 31, 14, 184, 207, 202, 83, 127, 42, 228]), SecretKey([104, 250, 86, 140, 108, 159, 96, 207, 223, 37, 184, 80, 124, 247, 199, 152, 239, 144, 219, 165, 14, 64, 233, 141, 47, 123, 238, 156, 216, 123, 198, 109]), Seed([249, 29, 167, 15, 12, 209, 247, 138, 0, 89, 158, 68, 182, 178, 118, 244, 89, 44, 80, 189, 223, 95, 52, 194, 2, 84, 17, 71, 158, 219, 123, 237]));
/// HY: GDHY224WLBHKNLVQUNVKFDSYSORS7MJZJQJMIX2PMTZQ7PSNGQSD75HP
static immutable HY = KeyPair(PublicKey([207, 141, 107, 150, 88, 78, 166, 174, 176, 163, 106, 162, 142, 88, 147, 163, 47, 177, 57, 76, 18, 196, 95, 79, 100, 243, 15, 190, 77, 52, 36, 63]), SecretKey([112, 6, 65, 93, 186, 144, 148, 165, 190, 30, 8, 47, 255, 145, 24, 106, 216, 138, 111, 161, 205, 248, 137, 234, 142, 56, 77, 108, 82, 177, 168, 71]), Seed([52, 119, 25, 248, 129, 105, 69, 143, 89, 184, 249, 86, 208, 210, 55, 67, 33, 118, 112, 46, 96, 64, 207, 208, 41, 253, 96, 93, 45, 173, 171, 143]));
/// HZ: GDHZ22JGSGZ4AHDUE7FPERAMP3XWA2Q2UVDV73X6AI6LEZAZ6LO4ON4G
static immutable HZ = KeyPair(PublicKey([207, 157, 105, 38, 145, 179, 192, 28, 116, 39, 202, 242, 68, 12, 126, 239, 96, 106, 26, 165, 71, 95, 238, 254, 2, 60, 178, 100, 25, 242, 221, 199]), SecretKey([80, 106, 80, 49, 40, 212, 159, 42, 95, 207, 232, 104, 103, 202, 185, 3, 48, 242, 9, 208, 91, 25, 197, 231, 97, 66, 94, 6, 121, 250, 187, 125]), Seed([14, 18, 204, 225, 53, 85, 247, 124, 204, 166, 114, 195, 218, 47, 216, 37, 162, 171, 140, 113, 116, 63, 202, 244, 26, 166, 245, 58, 81, 108, 137, 196]));
/// IA: GDIA223DROQA22K3P4UFM6EZBLO4IAT7R4O5XUD7TYPHNNZBCHXDYSVE
static immutable IA = KeyPair(PublicKey([208, 13, 107, 99, 139, 160, 13, 105, 91, 127, 40, 86, 120, 153, 10, 221, 196, 2, 127, 143, 29, 219, 208, 127, 158, 30, 118, 183, 33, 17, 238, 60]), SecretKey([168, 82, 108, 139, 5, 70, 180, 240, 95, 151, 17, 187, 88, 128, 111, 118, 63, 54, 29, 168, 80, 142, 27, 38, 32, 252, 90, 191, 37, 141, 100, 65]), Seed([239, 245, 216, 119, 169, 198, 2, 197, 183, 143, 74, 17, 201, 255, 109, 174, 210, 132, 106, 124, 138, 79, 48, 204, 87, 121, 20, 240, 146, 3, 70, 234]));
/// IB: GDIB22RXDIS7IOQCCR4GIPMXQFVGXTD52H4AKA4GQ43BRDJZZAVTBSYK
static immutable IB = KeyPair(PublicKey([208, 29, 106, 55, 26, 37, 244, 58, 2, 20, 120, 100, 61, 151, 129, 106, 107, 204, 125, 209, 248, 5, 3, 134, 135, 54, 24, 141, 57, 200, 43, 48]), SecretKey([0, 205, 237, 4, 86, 53, 21, 111, 21, 118, 240, 242, 14, 188, 62, 194, 96, 32, 188, 215, 124, 189, 69, 114, 151, 6, 190, 19, 82, 158, 224, 75]), Seed([59, 8, 96, 95, 131, 41, 187, 163, 199, 176, 136, 251, 2, 122, 229, 17, 123, 162, 22, 235, 135, 131, 0, 111, 19, 13, 175, 234, 85, 224, 151, 226]));
/// IC: GDIC22CD5YMNCUXGEFEFR43KGHK4UUVEOASAAIDVVM57OTBZBRCX72LM
static immutable IC = KeyPair(PublicKey([208, 45, 104, 67, 238, 24, 209, 82, 230, 33, 72, 88, 243, 106, 49, 213, 202, 82, 164, 112, 36, 0, 32, 117, 171, 59, 247, 76, 57, 12, 69, 127]), SecretKey([24, 49, 38, 236, 115, 125, 101, 216, 37, 78, 244, 135, 82, 98, 17, 97, 178, 220, 147, 204, 22, 178, 184, 40, 13, 234, 128, 218, 193, 158, 12, 83]), Seed([210, 250, 250, 81, 218, 216, 197, 99, 244, 89, 114, 63, 32, 166, 28, 5, 189, 147, 144, 229, 182, 246, 28, 13, 18, 255, 73, 143, 138, 159, 74, 88]));
/// ID: GDID227ETHPOMLRLIHVDJSNSJVLDS4D4ANYOUHXPMG2WWEZN5JO473ZO
static immutable ID = KeyPair(PublicKey([208, 61, 107, 228, 153, 222, 230, 46, 43, 65, 234, 52, 201, 178, 77, 86, 57, 112, 124, 3, 112, 234, 30, 239, 97, 181, 107, 19, 45, 234, 93, 207]), SecretKey([104, 196, 88, 255, 41, 201, 194, 56, 207, 103, 229, 38, 92, 7, 206, 108, 40, 158, 156, 205, 206, 149, 226, 52, 204, 255, 73, 65, 33, 213, 160, 123]), Seed([185, 12, 168, 56, 175, 234, 237, 211, 216, 136, 86, 36, 158, 37, 10, 24, 238, 182, 250, 95, 241, 104, 73, 224, 134, 253, 38, 34, 96, 20, 44, 238]));
/// IE: GDIE22HA6Q5CQAB3VOEQN2QXO5XI3W2ZJR46J5CAUD4WRBDXT3V3RFNB
static immutable IE = KeyPair(PublicKey([208, 77, 104, 224, 244, 58, 40, 0, 59, 171, 137, 6, 234, 23, 119, 110, 141, 219, 89, 76, 121, 228, 244, 64, 160, 249, 104, 132, 119, 158, 235, 184]), SecretKey([8, 11, 238, 204, 112, 235, 209, 78, 26, 197, 5, 19, 216, 43, 17, 219, 222, 172, 119, 237, 106, 156, 231, 220, 68, 57, 93, 152, 105, 1, 141, 80]), Seed([253, 80, 223, 44, 30, 247, 123, 154, 134, 165, 204, 9, 10, 65, 122, 180, 52, 12, 210, 98, 99, 62, 47, 174, 39, 94, 16, 50, 89, 202, 16, 205]));
/// IF: GDIF225RYUSDB4FB2XNYMQXSRIIOMSB6WAQHUDARLMMBXYDFCOMZ5MDT
static immutable IF = KeyPair(PublicKey([208, 93, 107, 177, 197, 36, 48, 240, 161, 213, 219, 134, 66, 242, 138, 16, 230, 72, 62, 176, 32, 122, 12, 17, 91, 24, 27, 224, 101, 19, 153, 158]), SecretKey([16, 253, 225, 45, 172, 186, 141, 76, 216, 12, 44, 106, 166, 7, 3, 46, 225, 117, 26, 221, 222, 207, 72, 24, 194, 4, 97, 55, 117, 221, 17, 81]), Seed([150, 182, 77, 185, 37, 27, 42, 224, 154, 90, 124, 142, 174, 77, 89, 81, 169, 29, 22, 177, 108, 12, 185, 254, 100, 119, 88, 245, 84, 216, 197, 167]));
/// IG: GDIG224BUOX5LRFQUMC5M5GWQACQ2H75ZIO7KH4HU6N2QENV3YOTTTNR
static immutable IG = KeyPair(PublicKey([208, 109, 107, 129, 163, 175, 213, 196, 176, 163, 5, 214, 116, 214, 128, 5, 13, 31, 253, 202, 29, 245, 31, 135, 167, 155, 168, 17, 181, 222, 29, 57]), SecretKey([232, 71, 226, 33, 25, 67, 153, 192, 246, 50, 190, 204, 98, 36, 205, 184, 31, 6, 254, 171, 109, 180, 164, 136, 118, 135, 62, 205, 168, 11, 179, 91]), Seed([48, 40, 61, 127, 145, 192, 91, 90, 132, 70, 61, 189, 98, 157, 125, 176, 54, 191, 49, 101, 98, 59, 231, 88, 35, 230, 179, 138, 157, 72, 31, 234]));
/// IH: GDIH222EE54XPJQ2T4TJ5SEM4DM35TJJJSIFBWZD63XKWSU6Y3FNXJDS
static immutable IH = KeyPair(PublicKey([208, 125, 107, 68, 39, 121, 119, 166, 26, 159, 38, 158, 200, 140, 224, 217, 190, 205, 41, 76, 144, 80, 219, 35, 246, 238, 171, 74, 158, 198, 202, 219]), SecretKey([176, 146, 203, 16, 132, 2, 77, 104, 58, 147, 215, 114, 88, 229, 178, 98, 92, 76, 189, 215, 168, 96, 81, 197, 111, 212, 246, 52, 191, 178, 165, 95]), Seed([193, 236, 104, 7, 133, 89, 206, 235, 225, 115, 120, 252, 64, 152, 229, 217, 147, 69, 88, 139, 5, 195, 163, 45, 205, 3, 35, 177, 25, 11, 92, 152]));
/// II: GDII223RNPZPXSEWFJVAVVXSOO2Y5WURCWJYDKLGAY546WNYXQPVBUWW
static immutable II = KeyPair(PublicKey([208, 141, 107, 113, 107, 242, 251, 200, 150, 42, 106, 10, 214, 242, 115, 181, 142, 218, 145, 21, 147, 129, 169, 102, 6, 59, 207, 89, 184, 188, 31, 80]), SecretKey([168, 69, 172, 132, 73, 243, 242, 188, 233, 160, 200, 158, 18, 46, 21, 38, 54, 107, 114, 246, 141, 156, 163, 177, 174, 236, 201, 205, 96, 17, 80, 110]), Seed([148, 208, 73, 70, 198, 88, 103, 195, 135, 38, 152, 19, 130, 115, 33, 25, 243, 75, 50, 201, 22, 108, 46, 160, 154, 89, 250, 173, 146, 74, 241, 189]));
/// IJ: GDIJ22JFHFELJ77IAUVCPBTPAZCFI3TFXIF73F2GOHAKOM4PBNJNHA6Y
static immutable IJ = KeyPair(PublicKey([208, 157, 105, 37, 57, 72, 180, 255, 232, 5, 42, 39, 134, 111, 6, 68, 84, 110, 101, 186, 11, 253, 151, 70, 113, 192, 167, 51, 143, 11, 82, 211]), SecretKey([200, 107, 184, 6, 230, 155, 96, 214, 71, 68, 154, 199, 57, 25, 171, 78, 219, 104, 10, 40, 229, 126, 33, 15, 54, 188, 136, 247, 167, 146, 18, 122]), Seed([23, 131, 107, 237, 242, 7, 114, 14, 124, 170, 80, 203, 6, 4, 86, 110, 64, 254, 112, 148, 76, 197, 86, 72, 206, 36, 150, 83, 93, 71, 13, 54]));
/// IK: GDIK224GEZY7YWDLZ442EF4XVMYDB5JTHQ74HPOFPBIKEPKZOPYTGG7B
static immutable IK = KeyPair(PublicKey([208, 173, 107, 134, 38, 113, 252, 88, 107, 207, 57, 162, 23, 151, 171, 48, 48, 245, 51, 60, 63, 195, 189, 197, 120, 80, 162, 61, 89, 115, 241, 51]), SecretKey([128, 179, 243, 72, 15, 50, 138, 126, 199, 119, 168, 227, 162, 49, 58, 65, 219, 241, 98, 167, 29, 6, 226, 255, 226, 28, 154, 10, 130, 115, 15, 82]), Seed([107, 90, 141, 42, 223, 186, 51, 113, 105, 171, 177, 245, 188, 199, 95, 71, 68, 134, 127, 159, 142, 3, 49, 16, 145, 246, 248, 206, 255, 99, 212, 85]));
/// IL: GDIL22MC3DZBQUZJIQLYRWDQ7NT2L6FNM4TQWZ44RZEGYOMXNWRVMJ3B
static immutable IL = KeyPair(PublicKey([208, 189, 105, 130, 216, 242, 24, 83, 41, 68, 23, 136, 216, 112, 251, 103, 165, 248, 173, 103, 39, 11, 103, 156, 142, 72, 108, 57, 151, 109, 163, 86]), SecretKey([152, 123, 23, 81, 198, 111, 185, 15, 77, 22, 253, 183, 243, 30, 74, 58, 182, 80, 16, 53, 188, 160, 36, 193, 253, 53, 75, 102, 166, 135, 131, 88]), Seed([96, 172, 184, 25, 96, 225, 98, 139, 48, 68, 247, 99, 29, 238, 153, 214, 31, 232, 98, 192, 45, 148, 203, 25, 105, 126, 49, 75, 41, 114, 193, 20]));
/// IM: GDIM224YK2ZAVIVTPDA3HGR64FPT4S2VBKBP4IT6NTT2LIKJQW3ZLNSJ
static immutable IM = KeyPair(PublicKey([208, 205, 107, 152, 86, 178, 10, 162, 179, 120, 193, 179, 154, 62, 225, 95, 62, 75, 85, 10, 130, 254, 34, 126, 108, 231, 165, 161, 73, 133, 183, 149]), SecretKey([248, 252, 152, 137, 98, 235, 55, 5, 143, 97, 105, 231, 252, 8, 226, 236, 127, 190, 227, 5, 195, 25, 114, 202, 237, 108, 98, 96, 29, 237, 168, 75]), Seed([251, 23, 106, 84, 131, 31, 165, 133, 210, 149, 55, 115, 195, 112, 17, 22, 223, 125, 140, 193, 175, 248, 127, 172, 3, 26, 74, 167, 145, 66, 131, 173]));
/// IN: GDIN22E5BKWYBVM6YSQWL6SJ47DRWSHEDBSTHP6YMWRTNBBBODZECKJJ
static immutable IN = KeyPair(PublicKey([208, 221, 104, 157, 10, 173, 128, 213, 158, 196, 161, 101, 250, 73, 231, 199, 27, 72, 228, 24, 101, 51, 191, 216, 101, 163, 54, 132, 33, 112, 242, 65]), SecretKey([56, 175, 33, 20, 150, 14, 143, 203, 203, 24, 129, 170, 117, 98, 134, 33, 82, 20, 41, 155, 238, 1, 41, 72, 30, 64, 156, 67, 68, 58, 159, 104]), Seed([41, 208, 62, 5, 209, 189, 140, 230, 143, 79, 200, 71, 19, 233, 190, 90, 201, 66, 53, 199, 60, 37, 152, 102, 93, 124, 192, 156, 224, 8, 58, 41]));
/// IO: GDIO22HOEQSI4O2LBV3JC3CO4AF4JY2S6I5RVFMJ2ZJSOHI35TBKA3LT
static immutable IO = KeyPair(PublicKey([208, 237, 104, 238, 36, 36, 142, 59, 75, 13, 118, 145, 108, 78, 224, 11, 196, 227, 82, 242, 59, 26, 149, 137, 214, 83, 39, 29, 27, 236, 194, 160]), SecretKey([72, 255, 74, 45, 213, 173, 98, 60, 206, 35, 182, 17, 88, 250, 232, 241, 108, 19, 58, 233, 218, 179, 17, 17, 109, 21, 202, 178, 227, 93, 236, 84]), Seed([237, 252, 37, 4, 6, 242, 58, 42, 148, 252, 209, 81, 124, 40, 166, 63, 208, 220, 166, 201, 213, 7, 125, 222, 125, 174, 12, 16, 109, 229, 192, 134]));
/// IP: GDIP22LZWYP4KJGPWXJ36FRZ7JLPXRWRJAFARP5PMRPMEECV4C5TJRLG
static immutable IP = KeyPair(PublicKey([208, 253, 105, 121, 182, 31, 197, 36, 207, 181, 211, 191, 22, 57, 250, 86, 251, 198, 209, 72, 10, 8, 191, 175, 100, 94, 194, 16, 85, 224, 187, 52]), SecretKey([24, 99, 81, 128, 171, 222, 139, 205, 7, 68, 213, 31, 4, 41, 30, 115, 215, 211, 115, 233, 107, 65, 218, 9, 37, 109, 91, 236, 88, 27, 120, 119]), Seed([73, 88, 80, 148, 166, 233, 190, 156, 194, 248, 103, 198, 97, 46, 142, 199, 169, 17, 173, 119, 184, 248, 255, 236, 8, 83, 37, 149, 89, 160, 42, 142]));
/// IQ: GDIQ22ITQDARRQPX5SUJW7GQPWJG42TVJGLKADHZUDALNGT7QBSYGXF4
static immutable IQ = KeyPair(PublicKey([209, 13, 105, 19, 128, 193, 24, 193, 247, 236, 168, 155, 124, 208, 125, 146, 110, 106, 117, 73, 150, 160, 12, 249, 160, 192, 182, 154, 127, 128, 101, 131]), SecretKey([240, 152, 143, 27, 2, 167, 157, 80, 44, 184, 103, 1, 182, 209, 168, 11, 47, 127, 41, 132, 38, 164, 19, 16, 131, 242, 28, 3, 205, 171, 11, 117]), Seed([168, 172, 217, 75, 204, 248, 116, 50, 16, 175, 20, 87, 119, 128, 192, 49, 126, 29, 124, 176, 206, 242, 167, 59, 125, 73, 23, 245, 105, 53, 222, 157]));
/// IR: GDIR223SZLIWN4ZKE556SXEGERIL7OQOSIU36RJD63DXKNK2NFA44L5A
static immutable IR = KeyPair(PublicKey([209, 29, 107, 114, 202, 209, 102, 243, 42, 39, 123, 233, 92, 134, 36, 80, 191, 186, 14, 146, 41, 191, 69, 35, 246, 199, 117, 53, 90, 105, 65, 206]), SecretKey([152, 53, 220, 11, 160, 240, 99, 44, 100, 79, 102, 245, 28, 47, 250, 147, 148, 92, 121, 223, 81, 123, 154, 226, 34, 140, 59, 32, 182, 2, 101, 124]), Seed([139, 106, 40, 15, 197, 105, 28, 181, 131, 146, 186, 10, 165, 247, 150, 130, 56, 117, 18, 122, 126, 98, 195, 7, 5, 90, 220, 178, 43, 57, 66, 182]));
/// IS: GDIS22DBCJJY53ZXI3O6EN7RFEDOGH76B6LOPZO23ZDATZOVE7KTSCRA
static immutable IS = KeyPair(PublicKey([209, 45, 104, 97, 18, 83, 142, 239, 55, 70, 221, 226, 55, 241, 41, 6, 227, 31, 254, 15, 150, 231, 229, 218, 222, 70, 9, 229, 213, 39, 213, 57]), SecretKey([48, 238, 155, 71, 50, 171, 23, 29, 93, 125, 174, 46, 197, 205, 205, 135, 22, 212, 44, 254, 131, 202, 84, 64, 243, 99, 224, 242, 100, 59, 39, 65]), Seed([236, 143, 211, 141, 77, 207, 223, 108, 206, 183, 151, 205, 20, 12, 158, 221, 48, 191, 218, 170, 193, 164, 247, 11, 137, 36, 15, 126, 249, 35, 102, 38]));
/// IT: GDIT22EMYV7ROULYIT5OFPHCKVAYJ6AW2G3LEBTUZKRH54MFYP43WHO6
static immutable IT = KeyPair(PublicKey([209, 61, 104, 140, 197, 127, 23, 81, 120, 68, 250, 226, 188, 226, 85, 65, 132, 248, 22, 209, 182, 178, 6, 116, 202, 162, 126, 241, 133, 195, 249, 187]), SecretKey([152, 130, 177, 94, 1, 54, 11, 225, 236, 110, 11, 102, 55, 146, 241, 55, 10, 26, 64, 96, 219, 155, 251, 14, 226, 167, 130, 246, 83, 148, 10, 121]), Seed([82, 105, 13, 67, 56, 255, 121, 5, 0, 221, 13, 150, 247, 177, 38, 239, 181, 74, 144, 152, 88, 35, 232, 133, 81, 228, 80, 213, 16, 61, 32, 50]));
/// IU: GDIU22QULKNSSXBRGVAI2UKLE46XYTP6VQAAS3L4BMVFGCWRILSC3CIC
static immutable IU = KeyPair(PublicKey([209, 77, 106, 20, 90, 155, 41, 92, 49, 53, 64, 141, 81, 75, 39, 61, 124, 77, 254, 172, 0, 9, 109, 124, 11, 42, 83, 10, 209, 66, 228, 45]), SecretKey([168, 215, 83, 82, 46, 248, 19, 139, 32, 165, 91, 245, 145, 65, 38, 109, 173, 145, 171, 209, 222, 205, 200, 115, 233, 42, 134, 39, 163, 8, 14, 108]), Seed([112, 184, 67, 246, 174, 40, 66, 93, 49, 148, 194, 79, 50, 243, 54, 250, 167, 22, 12, 33, 25, 165, 82, 197, 217, 218, 43, 209, 90, 170, 223, 170]));
/// IV: GDIV22POM55X32TKVHIGV5H2F34EFB2BE6JMAWSWL4Z2BQY25KU2QFRA
static immutable IV = KeyPair(PublicKey([209, 93, 105, 238, 103, 123, 125, 234, 106, 169, 208, 106, 244, 250, 46, 248, 66, 135, 65, 39, 146, 192, 90, 86, 95, 51, 160, 195, 26, 234, 169, 168]), SecretKey([152, 201, 47, 215, 102, 100, 104, 191, 123, 11, 203, 137, 100, 158, 160, 97, 116, 67, 170, 109, 91, 8, 216, 104, 143, 24, 2, 90, 216, 5, 75, 109]), Seed([235, 174, 250, 33, 153, 1, 95, 230, 247, 72, 10, 132, 245, 131, 40, 150, 144, 61, 180, 229, 65, 220, 146, 244, 149, 229, 214, 141, 26, 12, 21, 143]));
/// IW: GDIW22WFCOMKX7QH2PS6QFYPZPSU6A4TSZSJRGLCKVP7EY4NYKBNHTO3
static immutable IW = KeyPair(PublicKey([209, 109, 106, 197, 19, 152, 171, 254, 7, 211, 229, 232, 23, 15, 203, 229, 79, 3, 147, 150, 100, 152, 153, 98, 85, 95, 242, 99, 141, 194, 130, 211]), SecretKey([120, 137, 124, 233, 202, 202, 238, 217, 192, 222, 19, 81, 50, 119, 11, 133, 162, 62, 158, 95, 2, 32, 9, 57, 31, 117, 116, 93, 23, 160, 96, 79]), Seed([2, 39, 248, 1, 182, 204, 249, 19, 28, 2, 166, 30, 240, 228, 33, 234, 48, 15, 244, 237, 250, 40, 10, 27, 51, 96, 156, 229, 190, 151, 23, 240]));
/// IX: GDIX22FZWDN6SH7WW4PIMFKRK4XF2XI3BKXPD7P65EOPL4MIKBVGDLHA
static immutable IX = KeyPair(PublicKey([209, 125, 104, 185, 176, 219, 233, 31, 246, 183, 30, 134, 21, 81, 87, 46, 93, 93, 27, 10, 174, 241, 253, 254, 233, 28, 245, 241, 136, 80, 106, 97]), SecretKey([232, 252, 33, 233, 166, 61, 99, 81, 111, 185, 85, 71, 22, 150, 17, 70, 4, 27, 191, 82, 212, 244, 121, 146, 9, 174, 190, 77, 54, 5, 197, 83]), Seed([18, 46, 47, 11, 89, 138, 44, 85, 211, 179, 210, 108, 166, 33, 191, 113, 51, 69, 13, 143, 158, 104, 209, 71, 202, 189, 123, 90, 52, 150, 84, 167]));
/// IY: GDIY22KXHKXFC7CLFAMUIV6XRKVHKNVDSRLUREAE726G5ALPWKEJJXUG
static immutable IY = KeyPair(PublicKey([209, 141, 105, 87, 58, 174, 81, 124, 75, 40, 25, 68, 87, 215, 138, 170, 117, 54, 163, 148, 87, 72, 144, 4, 254, 188, 110, 129, 111, 178, 136, 148]), SecretKey([40, 69, 4, 6, 14, 18, 106, 167, 59, 80, 148, 60, 146, 222, 67, 175, 178, 60, 202, 137, 24, 209, 78, 43, 115, 140, 197, 103, 118, 183, 18, 125]), Seed([151, 217, 27, 111, 190, 126, 201, 63, 181, 88, 4, 18, 47, 191, 57, 156, 216, 153, 12, 18, 32, 228, 114, 42, 231, 234, 133, 37, 89, 55, 221, 151]));
/// IZ: GDIZ22SEFUVEKBLCG5LCKY5V3S6SOX2NUIRLYMOACKE4EV2P3KSQLQU6
static immutable IZ = KeyPair(PublicKey([209, 157, 106, 68, 45, 42, 69, 5, 98, 55, 86, 37, 99, 181, 220, 189, 39, 95, 77, 162, 34, 188, 49, 192, 18, 137, 194, 87, 79, 218, 165, 5]), SecretKey([64, 196, 89, 93, 146, 150, 96, 117, 84, 225, 55, 189, 50, 111, 216, 142, 114, 72, 155, 63, 151, 54, 45, 103, 137, 103, 59, 33, 156, 142, 66, 107]), Seed([253, 36, 153, 221, 229, 226, 194, 8, 182, 166, 65, 161, 24, 240, 121, 43, 60, 226, 66, 224, 162, 48, 35, 117, 14, 172, 131, 139, 28, 92, 109, 94]));
/// JA: GDJA22KZIBKUTZRMPHJY54OSQXUBPNH3L46AE7ENLJWFVLUZ3AP2QIIW
static immutable JA = KeyPair(PublicKey([210, 13, 105, 89, 64, 85, 73, 230, 44, 121, 211, 142, 241, 210, 133, 232, 23, 180, 251, 95, 60, 2, 124, 141, 90, 108, 90, 174, 153, 216, 31, 168]), SecretKey([120, 133, 77, 143, 95, 173, 41, 170, 98, 23, 135, 88, 43, 56, 141, 220, 8, 114, 94, 168, 30, 181, 142, 22, 212, 134, 111, 172, 39, 28, 139, 81]), Seed([254, 120, 227, 74, 227, 222, 69, 57, 38, 66, 181, 87, 140, 215, 20, 121, 243, 103, 160, 116, 255, 190, 177, 162, 250, 167, 149, 137, 191, 9, 24, 232]));
/// JB: GDJB22NJOV6NY3PQFGSVAMQSH3RBRQWXMZ6IOUHYTE4IVA3GXMZ56AOW
static immutable JB = KeyPair(PublicKey([210, 29, 105, 169, 117, 124, 220, 109, 240, 41, 165, 80, 50, 18, 62, 226, 24, 194, 215, 102, 124, 135, 80, 248, 153, 56, 138, 131, 102, 187, 51, 223]), SecretKey([248, 105, 245, 119, 63, 160, 146, 172, 220, 78, 167, 210, 223, 191, 44, 148, 123, 192, 241, 98, 173, 218, 238, 158, 58, 52, 118, 94, 139, 38, 110, 85]), Seed([230, 47, 192, 35, 255, 243, 99, 201, 140, 21, 173, 66, 216, 149, 116, 27, 176, 108, 1, 24, 73, 127, 124, 175, 229, 67, 188, 211, 232, 197, 137, 56]));
/// JC: GDJC22SCS2RFXIHO7JLVPKUC6M5GVN4FV4GXHVLZEQIELPQNUWNGLY7G
static immutable JC = KeyPair(PublicKey([210, 45, 106, 66, 150, 162, 91, 160, 238, 250, 87, 87, 170, 130, 243, 58, 106, 183, 133, 175, 13, 115, 213, 121, 36, 16, 69, 190, 13, 165, 154, 101]), SecretKey([16, 244, 67, 250, 162, 61, 156, 34, 224, 24, 214, 249, 236, 150, 235, 42, 155, 188, 253, 238, 134, 249, 29, 210, 213, 144, 209, 36, 144, 48, 166, 99]), Seed([20, 2, 86, 91, 51, 77, 249, 182, 43, 71, 30, 70, 240, 104, 107, 215, 206, 82, 114, 2, 39, 88, 65, 61, 173, 174, 82, 90, 146, 143, 58, 30]));
/// JD: GDJD22X3NK4KPLCZ7HPARGQYKWTKQ64MALIG5R3QYQD66CGTXSQ4W3HA
static immutable JD = KeyPair(PublicKey([210, 61, 106, 251, 106, 184, 167, 172, 89, 249, 222, 8, 154, 24, 85, 166, 168, 123, 140, 2, 208, 110, 199, 112, 196, 7, 239, 8, 211, 188, 161, 203]), SecretKey([40, 104, 140, 79, 8, 101, 106, 32, 235, 48, 146, 185, 245, 75, 96, 114, 125, 23, 115, 200, 112, 153, 56, 220, 81, 110, 233, 91, 113, 165, 2, 127]), Seed([236, 105, 22, 14, 93, 248, 19, 206, 74, 7, 71, 200, 141, 8, 45, 77, 223, 134, 49, 55, 146, 136, 2, 76, 195, 82, 126, 92, 20, 34, 153, 131]));
/// JE: GDJE2265VWANHTHDAPHNIXVQWXOYDSODH23SOM6JAMJ3DAOB54DYGISA
static immutable JE = KeyPair(PublicKey([210, 77, 107, 221, 173, 128, 211, 204, 227, 3, 206, 212, 94, 176, 181, 221, 129, 201, 195, 62, 183, 39, 51, 201, 3, 19, 177, 129, 193, 239, 7, 131]), SecretKey([104, 226, 180, 11, 6, 127, 34, 209, 69, 250, 15, 43, 102, 33, 3, 77, 97, 119, 71, 233, 93, 66, 95, 136, 134, 222, 251, 219, 149, 130, 201, 65]), Seed([102, 204, 184, 240, 134, 192, 241, 196, 179, 18, 220, 190, 176, 198, 111, 201, 205, 226, 166, 132, 239, 190, 144, 145, 6, 41, 215, 8, 26, 56, 26, 37]));
/// JF: GDJF22UTRJCGMNMEYXRFS3MPVWY7PFVH5Y7B6UJGLVA7UTT66SGKG3JD
static immutable JF = KeyPair(PublicKey([210, 93, 106, 147, 138, 68, 102, 53, 132, 197, 226, 89, 109, 143, 173, 177, 247, 150, 167, 238, 62, 31, 81, 38, 93, 65, 250, 78, 126, 244, 140, 163]), SecretKey([168, 54, 226, 136, 206, 155, 246, 72, 171, 51, 169, 251, 75, 102, 85, 85, 205, 160, 61, 130, 172, 74, 142, 24, 62, 71, 203, 227, 102, 212, 96, 93]), Seed([85, 203, 191, 26, 208, 255, 23, 151, 63, 82, 207, 134, 93, 69, 54, 23, 41, 151, 80, 174, 60, 139, 125, 13, 111, 229, 212, 247, 51, 135, 177, 81]));
/// JG: GDJG22FKSE3GFMNFUPZZWSAWXN5KGSIYYUADR26ZIAAPEYJ43IDVOE5E
static immutable JG = KeyPair(PublicKey([210, 109, 104, 170, 145, 54, 98, 177, 165, 163, 243, 155, 72, 22, 187, 122, 163, 73, 24, 197, 0, 56, 235, 217, 64, 0, 242, 97, 60, 218, 7, 87]), SecretKey([80, 83, 156, 127, 62, 43, 33, 36, 203, 239, 93, 119, 221, 207, 218, 101, 222, 72, 142, 58, 106, 154, 220, 212, 159, 24, 101, 97, 80, 77, 58, 112]), Seed([174, 177, 83, 213, 189, 209, 137, 103, 58, 142, 155, 150, 210, 67, 60, 96, 110, 18, 113, 73, 91, 238, 185, 78, 45, 143, 45, 156, 13, 251, 106, 23]));
/// JH: GDJH22MC4I6FLOI65NXI2OMUEAM2J5NZZOZOMPQ3Y2CRD7WC3HHHLD5O
static immutable JH = KeyPair(PublicKey([210, 125, 105, 130, 226, 60, 85, 185, 30, 235, 110, 141, 57, 148, 32, 25, 164, 245, 185, 203, 178, 230, 62, 27, 198, 133, 17, 254, 194, 217, 206, 117]), SecretKey([120, 61, 165, 95, 166, 137, 31, 136, 251, 73, 67, 14, 132, 109, 60, 216, 171, 227, 81, 57, 77, 150, 162, 38, 20, 53, 233, 198, 94, 45, 120, 114]), Seed([204, 119, 172, 198, 214, 120, 48, 59, 10, 245, 188, 129, 112, 154, 41, 185, 70, 34, 160, 39, 71, 198, 35, 139, 239, 75, 86, 237, 146, 221, 189, 71]));
/// JI: GDJI22D4VMVILPDPMN4IIFO22PK522CEEPE5RFLIUUWMCTITIMR2BWO7
static immutable JI = KeyPair(PublicKey([210, 141, 104, 124, 171, 42, 133, 188, 111, 99, 120, 132, 21, 218, 211, 213, 221, 104, 68, 35, 201, 216, 149, 104, 165, 44, 193, 77, 19, 67, 35, 160]), SecretKey([112, 160, 189, 52, 252, 139, 177, 169, 24, 243, 34, 176, 121, 74, 11, 195, 134, 146, 131, 140, 140, 155, 34, 251, 74, 212, 177, 119, 203, 98, 197, 108]), Seed([111, 172, 187, 67, 121, 189, 35, 213, 43, 147, 161, 32, 205, 238, 152, 114, 3, 153, 248, 60, 94, 138, 88, 228, 227, 225, 142, 62, 92, 167, 80, 182]));
/// JJ: GDJJ22ZAUW4KXGEMQQF7Q34CZJTVNGOXQCUQNCVJHDAI4ZWFQ75SCVZB
static immutable JJ = KeyPair(PublicKey([210, 157, 107, 32, 165, 184, 171, 152, 140, 132, 11, 248, 111, 130, 202, 103, 86, 153, 215, 128, 169, 6, 138, 169, 56, 192, 142, 102, 197, 135, 251, 33]), SecretKey([232, 254, 236, 205, 252, 167, 229, 221, 192, 62, 198, 86, 230, 4, 166, 135, 59, 8, 13, 136, 2, 2, 70, 71, 72, 53, 47, 193, 211, 42, 39, 118]), Seed([232, 228, 187, 132, 192, 187, 240, 240, 76, 162, 89, 10, 179, 153, 194, 94, 121, 81, 151, 176, 107, 135, 18, 3, 218, 18, 188, 184, 208, 124, 80, 183]));
/// JK: GDJK22X5EDEEIFECQ4G5J4GLMRFPJVI5CMGLBWK5MBGNPFQKVTJXHOIG
static immutable JK = KeyPair(PublicKey([210, 173, 106, 253, 32, 200, 68, 20, 130, 135, 13, 212, 240, 203, 100, 74, 244, 213, 29, 19, 12, 176, 217, 93, 96, 76, 215, 150, 10, 172, 211, 115]), SecretKey([160, 135, 192, 210, 162, 218, 40, 247, 69, 184, 194, 240, 238, 185, 25, 20, 5, 61, 230, 42, 209, 128, 248, 70, 211, 216, 161, 147, 142, 105, 106, 66]), Seed([44, 195, 92, 55, 184, 185, 44, 232, 117, 57, 92, 58, 109, 248, 60, 249, 144, 174, 147, 217, 49, 125, 57, 252, 56, 149, 66, 105, 247, 207, 74, 101]));
/// JL: GDJL22NZYDOYQ3HODEIMAMS7LJAYOO5VEFYEIUMPPXJNWHUGGRWF3URZ
static immutable JL = KeyPair(PublicKey([210, 189, 105, 185, 192, 221, 136, 108, 238, 25, 16, 192, 50, 95, 90, 65, 135, 59, 181, 33, 112, 68, 81, 143, 125, 210, 219, 30, 134, 52, 108, 93]), SecretKey([168, 54, 50, 176, 26, 181, 239, 134, 105, 213, 38, 249, 151, 47, 144, 64, 220, 234, 187, 153, 228, 146, 6, 253, 156, 36, 158, 146, 199, 248, 234, 68]), Seed([201, 170, 41, 137, 125, 81, 148, 38, 37, 219, 28, 226, 40, 222, 242, 112, 58, 180, 137, 127, 12, 42, 52, 200, 139, 185, 174, 21, 239, 213, 120, 1]));
/// JM: GDJM22ZZNK2HP4FPBQA2MBJRDTNI7FAVXQQCAJLHSRD2XBDZZFUS35YX
static immutable JM = KeyPair(PublicKey([210, 205, 107, 57, 106, 180, 119, 240, 175, 12, 1, 166, 5, 49, 28, 218, 143, 148, 21, 188, 32, 32, 37, 103, 148, 71, 171, 132, 121, 201, 105, 45]), SecretKey([240, 112, 38, 137, 70, 170, 67, 237, 116, 95, 242, 9, 244, 3, 138, 66, 10, 2, 214, 106, 26, 249, 140, 133, 102, 83, 13, 116, 124, 119, 116, 68]), Seed([130, 206, 233, 130, 31, 61, 28, 147, 226, 72, 245, 160, 220, 100, 159, 80, 89, 12, 152, 138, 244, 11, 135, 136, 183, 244, 246, 119, 139, 222, 74, 196]));
/// JN: GDJN22RGKE6X2QIIDDO23UOBJ4RDIKET2KYGEVTY7QOTXGSTFGSHQQMX
static immutable JN = KeyPair(PublicKey([210, 221, 106, 38, 81, 61, 125, 65, 8, 24, 221, 173, 209, 193, 79, 34, 52, 40, 147, 210, 176, 98, 86, 120, 252, 29, 59, 154, 83, 41, 164, 120]), SecretKey([200, 175, 245, 127, 43, 253, 147, 88, 190, 238, 2, 211, 160, 92, 131, 69, 158, 247, 90, 141, 166, 78, 8, 87, 97, 214, 187, 219, 184, 118, 37, 114]), Seed([225, 70, 34, 126, 235, 192, 70, 130, 121, 45, 51, 205, 131, 88, 31, 147, 86, 164, 136, 241, 169, 151, 123, 81, 225, 231, 61, 198, 89, 126, 181, 231]));
/// JO: GDJO22HOLIKR6PW6WTF7E6UU7WOQGXAKWJ6PLTZM37ZFWTV4DVXF5MJI
static immutable JO = KeyPair(PublicKey([210, 237, 104, 238, 90, 21, 31, 62, 222, 180, 203, 242, 122, 148, 253, 157, 3, 92, 10, 178, 124, 245, 207, 44, 223, 242, 91, 78, 188, 29, 110, 94]), SecretKey([200, 102, 203, 177, 83, 39, 250, 80, 181, 178, 240, 92, 109, 21, 211, 64, 141, 176, 104, 191, 59, 203, 122, 131, 146, 254, 167, 143, 199, 68, 137, 97]), Seed([33, 127, 46, 126, 232, 202, 31, 203, 122, 146, 124, 253, 207, 152, 57, 180, 0, 77, 72, 3, 38, 91, 54, 88, 112, 47, 69, 181, 57, 194, 169, 7]));
/// JP: GDJP22OKETICLHX7PNGQQXDU4X3QL7HMV3VR2FEJHMKZB2U34IYUWDWF
static immutable JP = KeyPair(PublicKey([210, 253, 105, 202, 36, 208, 37, 158, 255, 123, 77, 8, 92, 116, 229, 247, 5, 252, 236, 174, 235, 29, 20, 137, 59, 21, 144, 234, 155, 226, 49, 75]), SecretKey([208, 212, 182, 196, 112, 208, 74, 164, 217, 160, 164, 133, 213, 13, 79, 63, 109, 197, 32, 189, 70, 18, 12, 246, 174, 184, 227, 229, 111, 98, 33, 76]), Seed([95, 255, 106, 35, 176, 186, 73, 242, 87, 196, 197, 254, 160, 18, 245, 63, 169, 26, 115, 151, 143, 69, 169, 203, 252, 12, 190, 105, 167, 77, 235, 116]));
/// JQ: GDJQ22SD7GJKWHFAEC6HK7WNBOWXQ4ZLLSDGDUV2VOO2RO7ADPLF265M
static immutable JQ = KeyPair(PublicKey([211, 13, 106, 67, 249, 146, 171, 28, 160, 32, 188, 117, 126, 205, 11, 173, 120, 115, 43, 92, 134, 97, 210, 186, 171, 157, 168, 187, 224, 27, 214, 93]), SecretKey([8, 79, 248, 221, 226, 57, 74, 119, 172, 104, 27, 180, 27, 148, 119, 200, 4, 186, 49, 202, 39, 102, 150, 53, 134, 136, 190, 217, 139, 125, 250, 102]), Seed([171, 153, 112, 120, 174, 158, 254, 90, 2, 253, 247, 226, 229, 145, 87, 124, 97, 43, 208, 18, 159, 96, 9, 1, 241, 109, 159, 246, 79, 87, 164, 230]));
/// JR: GDJR22FFPEMYV4VUTJBO2OTENMZM2G56LSE5TKB32NJU4IAD6IQBGHCH
static immutable JR = KeyPair(PublicKey([211, 29, 104, 165, 121, 25, 138, 242, 180, 154, 66, 237, 58, 100, 107, 50, 205, 27, 190, 92, 137, 217, 168, 59, 211, 83, 78, 32, 3, 242, 32, 19]), SecretKey([32, 253, 114, 170, 130, 154, 137, 119, 172, 226, 153, 94, 69, 114, 252, 15, 21, 96, 239, 250, 186, 55, 120, 57, 204, 12, 33, 186, 118, 102, 104, 108]), Seed([42, 41, 184, 34, 190, 250, 234, 242, 238, 177, 63, 68, 75, 170, 132, 105, 35, 65, 56, 72, 76, 65, 67, 11, 47, 125, 25, 32, 104, 119, 2, 87]));
/// JS: GDJS22MZQNXXVI23O4662ORA7UURVLPIS2ENOVZMU232FGJJ7UWPFUCO
static immutable JS = KeyPair(PublicKey([211, 45, 105, 153, 131, 111, 122, 163, 91, 119, 61, 237, 58, 32, 253, 41, 26, 173, 232, 150, 136, 215, 87, 44, 166, 183, 162, 153, 41, 253, 44, 242]), SecretKey([56, 22, 46, 4, 140, 162, 93, 46, 26, 165, 186, 135, 189, 48, 79, 180, 21, 63, 169, 164, 171, 176, 207, 4, 21, 117, 122, 163, 126, 235, 208, 116]), Seed([20, 101, 49, 206, 27, 191, 216, 176, 96, 197, 112, 128, 173, 44, 113, 171, 208, 223, 247, 195, 150, 23, 49, 80, 206, 63, 231, 173, 245, 90, 18, 203]));
/// JT: GDJT22J2KGUVGDLB4WCYXVKMFZ3FZVUBT7PBSWGAUF3ZTFWRXCYV6VCF
static immutable JT = KeyPair(PublicKey([211, 61, 105, 58, 81, 169, 83, 13, 97, 229, 133, 139, 213, 76, 46, 118, 92, 214, 129, 159, 222, 25, 88, 192, 161, 119, 153, 150, 209, 184, 177, 95]), SecretKey([184, 244, 190, 195, 218, 152, 237, 176, 8, 252, 131, 98, 103, 221, 62, 192, 125, 62, 244, 120, 251, 23, 42, 16, 251, 81, 16, 51, 173, 140, 241, 126]), Seed([195, 121, 242, 108, 46, 131, 117, 19, 106, 150, 94, 145, 34, 15, 198, 51, 231, 69, 149, 252, 74, 149, 118, 118, 68, 161, 56, 66, 234, 40, 53, 143]));
/// JU: GDJU22DMLACWNG3WT252T4ADUI7Q3RQ4VXPL2GYGABWTURZRZV72TDFL
static immutable JU = KeyPair(PublicKey([211, 77, 104, 108, 88, 5, 102, 155, 118, 158, 187, 169, 240, 3, 162, 63, 13, 198, 28, 173, 222, 189, 27, 6, 0, 109, 58, 71, 49, 205, 127, 169]), SecretKey([64, 203, 12, 18, 169, 160, 149, 218, 27, 137, 145, 37, 206, 115, 55, 223, 199, 189, 76, 157, 23, 178, 7, 220, 19, 199, 225, 77, 37, 185, 70, 99]), Seed([77, 92, 226, 34, 197, 15, 77, 43, 57, 20, 79, 42, 190, 127, 153, 199, 16, 53, 69, 66, 244, 63, 182, 92, 209, 9, 6, 51, 142, 2, 175, 50]));
/// JV: GDJV22W2CZKZNKYCQEVPUPJ2TNWA7TLKJK67OVQKV5OAWIHVOBNGAR45
static immutable JV = KeyPair(PublicKey([211, 93, 106, 218, 22, 85, 150, 171, 2, 129, 42, 250, 61, 58, 155, 108, 15, 205, 106, 74, 189, 247, 86, 10, 175, 92, 11, 32, 245, 112, 90, 96]), SecretKey([96, 190, 239, 49, 208, 26, 108, 58, 113, 178, 18, 196, 189, 57, 114, 76, 152, 195, 230, 111, 152, 173, 102, 139, 234, 141, 75, 33, 156, 106, 72, 117]), Seed([162, 8, 184, 20, 14, 122, 165, 228, 139, 167, 129, 34, 196, 83, 183, 72, 75, 53, 161, 13, 84, 20, 160, 155, 64, 230, 178, 241, 158, 227, 143, 254]));
/// JW: GDJW223XRMGSCCWF5WEAYIDVIZRH4A7DUX5EYL7QTANLVZMMBE4KMCP6
static immutable JW = KeyPair(PublicKey([211, 109, 107, 119, 139, 13, 33, 10, 197, 237, 136, 12, 32, 117, 70, 98, 126, 3, 227, 165, 250, 76, 47, 240, 152, 26, 186, 229, 140, 9, 56, 166]), SecretKey([88, 159, 123, 185, 213, 43, 56, 187, 60, 214, 191, 252, 109, 45, 77, 77, 106, 12, 119, 167, 36, 206, 76, 224, 207, 117, 198, 70, 56, 131, 15, 94]), Seed([213, 124, 214, 170, 149, 103, 136, 209, 4, 52, 30, 219, 194, 29, 15, 187, 90, 34, 190, 238, 219, 165, 255, 157, 36, 71, 151, 188, 143, 137, 159, 220]));
/// JX: GDJX22OOWSEKGD25VJ5F7N6E6ZYMMBU6FKUPUMN7J4FWF47EKCVKRWDZ
static immutable JX = KeyPair(PublicKey([211, 125, 105, 206, 180, 136, 163, 15, 93, 170, 122, 95, 183, 196, 246, 112, 198, 6, 158, 42, 168, 250, 49, 191, 79, 11, 98, 243, 228, 80, 170, 168]), SecretKey([72, 128, 7, 217, 200, 139, 161, 162, 25, 84, 134, 226, 86, 122, 145, 161, 125, 89, 189, 43, 44, 251, 206, 48, 207, 238, 13, 181, 88, 179, 241, 107]), Seed([232, 69, 103, 15, 13, 103, 167, 167, 13, 46, 7, 24, 69, 187, 28, 186, 55, 231, 102, 72, 218, 142, 113, 65, 34, 247, 45, 102, 232, 34, 229, 127]));
/// JY: GDJY22ZK7QAZUB6UEQEFFVLODQ7KONH2N6SIYBOATAS32HKH7E5AFMHX
static immutable JY = KeyPair(PublicKey([211, 141, 107, 42, 252, 1, 154, 7, 212, 36, 8, 82, 213, 110, 28, 62, 167, 52, 250, 111, 164, 140, 5, 192, 152, 37, 189, 29, 71, 249, 58, 2]), SecretKey([128, 138, 36, 222, 74, 173, 74, 42, 156, 194, 84, 197, 127, 126, 139, 135, 168, 185, 7, 149, 92, 101, 175, 166, 95, 42, 41, 145, 139, 40, 67, 114]), Seed([37, 225, 45, 120, 131, 142, 32, 107, 73, 74, 217, 14, 93, 46, 16, 79, 234, 33, 14, 16, 50, 236, 98, 151, 254, 162, 193, 134, 110, 218, 167, 123]));
/// JZ: GDJZ22BO7N4SSSJQ6OL7GGOEUXBCBGREERYI5DW52SIUGTE63AAB6YHE
static immutable JZ = KeyPair(PublicKey([211, 157, 104, 46, 251, 121, 41, 73, 48, 243, 151, 243, 25, 196, 165, 194, 32, 154, 36, 36, 112, 142, 142, 221, 212, 145, 67, 76, 158, 216, 0, 31]), SecretKey([72, 84, 123, 33, 167, 83, 218, 254, 129, 187, 9, 6, 236, 222, 187, 186, 173, 151, 218, 58, 138, 60, 17, 60, 172, 167, 204, 244, 241, 214, 188, 113]), Seed([60, 130, 130, 160, 125, 100, 191, 6, 19, 112, 13, 215, 103, 109, 101, 48, 18, 123, 170, 58, 59, 213, 205, 146, 122, 110, 147, 195, 95, 64, 243, 90]));
/// KA: GDKA22NYLRAZSAGWSBGVOMFU3SJTI52LSSV3SLILRRBSRQCPL5KYMQAD
static immutable KA = KeyPair(PublicKey([212, 13, 105, 184, 92, 65, 153, 0, 214, 144, 77, 87, 48, 180, 220, 147, 52, 119, 75, 148, 171, 185, 45, 11, 140, 67, 40, 192, 79, 95, 85, 134]), SecretKey([168, 1, 224, 33, 142, 204, 223, 61, 215, 9, 1, 231, 139, 132, 16, 89, 7, 70, 246, 23, 142, 44, 101, 157, 243, 75, 34, 104, 204, 37, 155, 68]), Seed([222, 13, 239, 80, 141, 194, 208, 8, 145, 175, 38, 198, 210, 192, 213, 173, 0, 110, 137, 38, 206, 181, 97, 3, 55, 221, 60, 207, 1, 50, 162, 43]));
/// KB: GDKB22ZO54OMH7XXD4X7RKCASF4XRFTT7BXCM27JDKAU37W34BJO6BXA
static immutable KB = KeyPair(PublicKey([212, 29, 107, 46, 239, 28, 195, 254, 247, 31, 47, 248, 168, 64, 145, 121, 120, 150, 115, 248, 110, 38, 107, 233, 26, 129, 77, 254, 219, 224, 82, 239]), SecretKey([104, 23, 52, 246, 47, 79, 77, 64, 24, 107, 0, 126, 239, 72, 191, 140, 39, 222, 30, 154, 107, 88, 25, 145, 33, 168, 73, 68, 72, 29, 182, 75]), Seed([149, 211, 47, 234, 174, 160, 189, 227, 242, 79, 236, 196, 31, 172, 243, 207, 36, 88, 174, 58, 226, 9, 113, 26, 252, 236, 238, 227, 18, 177, 99, 37]));
/// KC: GDKC22OVBADP6HFPH64FBK7RVGIGXLAZ6QH7HQCLBDFIQUSWFP3IKZXG
static immutable KC = KeyPair(PublicKey([212, 45, 105, 213, 8, 6, 255, 28, 175, 63, 184, 80, 171, 241, 169, 144, 107, 172, 25, 244, 15, 243, 192, 75, 8, 202, 136, 82, 86, 43, 246, 133]), SecretKey([176, 145, 35, 179, 94, 138, 85, 186, 14, 13, 57, 190, 97, 205, 109, 112, 213, 108, 253, 90, 51, 33, 200, 32, 249, 142, 87, 125, 108, 242, 106, 118]), Seed([114, 142, 236, 202, 117, 107, 113, 8, 117, 3, 185, 208, 188, 206, 99, 239, 116, 137, 55, 11, 60, 30, 89, 185, 117, 91, 31, 52, 27, 154, 14, 41]));
/// KD: GDKD22ZRRSJOYXJFZ64PZZG4OXQWE4RKMPF47ND6SS72U3YNKYZOMVZ5
static immutable KD = KeyPair(PublicKey([212, 61, 107, 49, 140, 146, 236, 93, 37, 207, 184, 252, 228, 220, 117, 225, 98, 114, 42, 99, 203, 207, 180, 126, 148, 191, 170, 111, 13, 86, 50, 230]), SecretKey([160, 42, 71, 187, 178, 245, 99, 131, 234, 124, 163, 197, 151, 146, 209, 85, 145, 76, 100, 248, 52, 1, 254, 120, 171, 47, 251, 22, 88, 127, 179, 123]), Seed([175, 132, 1, 29, 111, 112, 37, 222, 110, 187, 233, 118, 177, 147, 138, 133, 2, 117, 21, 82, 174, 176, 123, 204, 250, 33, 177, 162, 63, 87, 239, 246]));
/// KE: GDKE226TWSRJRM2KI5O5JJ4XILM3TJHRGG7IQEUHGQZ7WNYKCFIODINR
static immutable KE = KeyPair(PublicKey([212, 77, 107, 211, 180, 162, 152, 179, 74, 71, 93, 212, 167, 151, 66, 217, 185, 164, 241, 49, 190, 136, 18, 135, 52, 51, 251, 55, 10, 17, 80, 225]), SecretKey([168, 128, 200, 40, 108, 235, 164, 70, 245, 196, 32, 175, 19, 213, 103, 148, 115, 161, 242, 54, 246, 193, 150, 69, 240, 116, 68, 128, 209, 249, 180, 83]), Seed([210, 141, 169, 26, 206, 171, 13, 99, 30, 41, 68, 64, 15, 39, 100, 190, 13, 203, 168, 125, 50, 75, 4, 108, 52, 166, 0, 150, 241, 41, 140, 172]));
/// KF: GDKF22XD6656GXOF5274SMTUN3WTI3TP6KA7JGMENEHTAZEXQGDENQJM
static immutable KF = KeyPair(PublicKey([212, 93, 106, 227, 247, 187, 227, 93, 197, 238, 191, 201, 50, 116, 110, 237, 52, 110, 111, 242, 129, 244, 153, 132, 105, 15, 48, 100, 151, 129, 134, 70]), SecretKey([232, 142, 43, 246, 67, 37, 126, 80, 177, 48, 125, 85, 214, 158, 151, 174, 61, 107, 142, 98, 48, 158, 17, 58, 191, 174, 202, 169, 253, 91, 129, 103]), Seed([158, 165, 76, 212, 230, 53, 136, 192, 59, 210, 113, 237, 146, 135, 249, 128, 13, 122, 62, 150, 149, 190, 151, 34, 146, 8, 163, 191, 100, 101, 221, 128]));
/// KG: GDKG22CQZV2S6FCSOSPYLTOQ6RB4IINMCR5K7IMA2TL4FIFC4VZMYGMU
static immutable KG = KeyPair(PublicKey([212, 109, 104, 80, 205, 117, 47, 20, 82, 116, 159, 133, 205, 208, 244, 67, 196, 33, 172, 20, 122, 175, 161, 128, 212, 215, 194, 160, 162, 229, 114, 204]), SecretKey([56, 236, 60, 180, 54, 156, 189, 251, 150, 74, 77, 26, 59, 105, 250, 13, 16, 50, 108, 191, 250, 184, 244, 251, 243, 157, 254, 237, 238, 135, 209, 71]), Seed([223, 100, 221, 86, 58, 12, 55, 188, 35, 129, 86, 137, 212, 146, 211, 171, 80, 172, 31, 77, 201, 168, 18, 169, 36, 8, 253, 227, 168, 219, 91, 89]));
/// KH: GDKH22NGJ7TQ7S6EB4SNGQVF5ADOB3VBK4U3EO2GZM7XJRCILMDQI6QF
static immutable KH = KeyPair(PublicKey([212, 125, 105, 166, 79, 231, 15, 203, 196, 15, 36, 211, 66, 165, 232, 6, 224, 238, 161, 87, 41, 178, 59, 70, 203, 63, 116, 196, 72, 91, 7, 4]), SecretKey([184, 65, 213, 48, 162, 101, 241, 99, 252, 19, 160, 171, 20, 116, 113, 42, 217, 130, 151, 162, 232, 143, 192, 148, 95, 3, 195, 201, 252, 140, 203, 85]), Seed([79, 7, 225, 18, 92, 203, 88, 221, 204, 119, 3, 92, 107, 192, 101, 69, 52, 230, 38, 11, 48, 192, 31, 227, 138, 18, 70, 44, 9, 36, 208, 176]));
/// KI: GDKI22YQ44W7IGIRSQCNVEIAQS3WQ5WIBP4OT3ZF5MQW57TFVE4XTA7E
static immutable KI = KeyPair(PublicKey([212, 141, 107, 16, 231, 45, 244, 25, 17, 148, 4, 218, 145, 0, 132, 183, 104, 118, 200, 11, 248, 233, 239, 37, 235, 33, 110, 254, 101, 169, 57, 121]), SecretKey([168, 29, 81, 181, 64, 23, 239, 13, 4, 137, 85, 232, 150, 228, 197, 160, 101, 177, 239, 160, 118, 203, 113, 167, 249, 211, 148, 61, 83, 181, 188, 75]), Seed([120, 132, 47, 227, 15, 204, 77, 37, 136, 207, 110, 159, 226, 134, 228, 180, 188, 66, 105, 168, 49, 41, 193, 130, 169, 80, 246, 33, 1, 197, 160, 23]));
/// KJ: GDKJ22TPWN7RV54OFVIHTJZA4GPZO7CYISUUZQ2C3FD3FPWX4SEQDKMP
static immutable KJ = KeyPair(PublicKey([212, 157, 106, 111, 179, 127, 26, 247, 142, 45, 80, 121, 167, 32, 225, 159, 151, 124, 88, 68, 169, 76, 195, 66, 217, 71, 178, 190, 215, 228, 137, 1]), SecretKey([200, 52, 224, 195, 44, 142, 9, 69, 20, 169, 120, 161, 156, 145, 207, 150, 3, 47, 153, 187, 154, 172, 46, 42, 223, 64, 15, 122, 202, 210, 17, 77]), Seed([142, 15, 9, 198, 85, 140, 174, 197, 210, 47, 107, 110, 86, 222, 125, 255, 229, 45, 42, 142, 162, 74, 73, 180, 105, 118, 143, 3, 204, 28, 85, 69]));
/// KK: GDKK225NND5CVSY7NHWSAZ4ENJDZ7SQAM5A5B6KWSERG5MWUI6HHAHCM
static immutable KK = KeyPair(PublicKey([212, 173, 107, 173, 104, 250, 42, 203, 31, 105, 237, 32, 103, 132, 106, 71, 159, 202, 0, 103, 65, 208, 249, 86, 145, 34, 110, 178, 212, 71, 142, 112]), SecretKey([0, 12, 162, 182, 109, 39, 220, 179, 237, 74, 23, 233, 122, 146, 59, 5, 114, 57, 207, 154, 27, 85, 198, 71, 48, 12, 20, 88, 119, 151, 48, 73]), Seed([101, 170, 237, 88, 122, 108, 58, 212, 71, 44, 64, 247, 37, 26, 53, 79, 110, 101, 68, 254, 103, 128, 96, 58, 32, 55, 193, 250, 185, 43, 7, 225]));
/// KL: GDKL22EUNI44V2PBGLD6TLEWSUPRTLESVOYT4RWW6KXY2KARPR7GRMER
static immutable KL = KeyPair(PublicKey([212, 189, 104, 148, 106, 57, 202, 233, 225, 50, 199, 233, 172, 150, 149, 31, 25, 172, 146, 171, 177, 62, 70, 214, 242, 175, 141, 40, 17, 124, 126, 104]), SecretKey([48, 46, 61, 72, 221, 62, 132, 3, 177, 221, 5, 189, 149, 78, 121, 149, 163, 117, 242, 83, 247, 109, 43, 121, 105, 38, 69, 251, 232, 162, 16, 120]), Seed([42, 37, 78, 158, 221, 201, 135, 120, 139, 12, 50, 78, 57, 24, 172, 86, 161, 113, 33, 177, 18, 145, 209, 79, 194, 22, 136, 183, 193, 11, 210, 0]));
/// KM: GDKM22WCXLCCMYFV3JX2HDXJOJFT6PEDJMKCJI5A2274AEIVPDZWEXTP
static immutable KM = KeyPair(PublicKey([212, 205, 106, 194, 186, 196, 38, 96, 181, 218, 111, 163, 142, 233, 114, 75, 63, 60, 131, 75, 20, 36, 163, 160, 214, 191, 192, 17, 21, 120, 243, 98]), SecretKey([208, 121, 84, 197, 130, 160, 175, 144, 58, 91, 228, 57, 110, 148, 238, 199, 245, 58, 109, 111, 97, 200, 161, 227, 131, 202, 124, 90, 100, 145, 11, 69]), Seed([195, 254, 80, 164, 178, 184, 48, 99, 209, 141, 50, 146, 190, 171, 172, 219, 184, 123, 165, 97, 44, 176, 89, 28, 101, 175, 169, 168, 139, 213, 250, 44]));
/// KN: GDKN22NVCBKRYHMU27KIQLBDCY2COA54VZIJ3UGXUYBI4AWR6OITBOVF
static immutable KN = KeyPair(PublicKey([212, 221, 105, 181, 16, 85, 28, 29, 148, 215, 212, 136, 44, 35, 22, 52, 39, 3, 188, 174, 80, 157, 208, 215, 166, 2, 142, 2, 209, 243, 145, 48]), SecretKey([240, 31, 133, 117, 111, 129, 224, 169, 151, 45, 194, 105, 236, 31, 230, 32, 149, 229, 111, 140, 244, 7, 23, 40, 68, 191, 141, 194, 151, 54, 37, 67]), Seed([140, 128, 152, 25, 74, 161, 83, 98, 163, 135, 58, 181, 162, 16, 79, 26, 243, 34, 251, 99, 112, 51, 179, 234, 32, 182, 224, 236, 150, 99, 104, 196]));
/// KO: GDKO22Q6WTVAYXGNCYPCOZX76I77GLL4FC4GD7I4EQYYPIS2XHNJRZME
static immutable KO = KeyPair(PublicKey([212, 237, 106, 30, 180, 234, 12, 92, 205, 22, 30, 39, 102, 255, 242, 63, 243, 45, 124, 40, 184, 97, 253, 28, 36, 49, 135, 162, 90, 185, 218, 152]), SecretKey([88, 213, 5, 178, 77, 173, 89, 77, 11, 140, 75, 237, 8, 60, 175, 209, 115, 55, 26, 179, 118, 104, 91, 84, 97, 206, 13, 253, 190, 17, 163, 109]), Seed([11, 141, 128, 195, 118, 32, 166, 204, 107, 33, 61, 113, 97, 104, 84, 73, 47, 209, 151, 162, 31, 190, 172, 208, 242, 59, 12, 224, 5, 168, 229, 255]));
/// KP: GDKP22MAMRH6BU5E4ZI3UGGT6YVV7AQPWIF4SQR42PYDSYWBR7LEG33S
static immutable KP = KeyPair(PublicKey([212, 253, 105, 128, 100, 79, 224, 211, 164, 230, 81, 186, 24, 211, 246, 43, 95, 130, 15, 178, 11, 201, 66, 60, 211, 240, 57, 98, 193, 143, 214, 67]), SecretKey([184, 246, 248, 187, 243, 111, 205, 253, 199, 43, 130, 37, 85, 220, 84, 233, 17, 27, 192, 133, 136, 146, 142, 3, 175, 159, 177, 112, 167, 137, 78, 94]), Seed([24, 194, 199, 66, 171, 246, 49, 105, 19, 8, 49, 191, 162, 247, 60, 188, 247, 193, 164, 134, 100, 145, 149, 170, 118, 159, 55, 62, 1, 144, 230, 120]));
/// KQ: GDKQ22UKJZC3FQ7FAGQXXNN67TOXYBSWCVBIR5QY7BBPM3RVZYMUAGIK
static immutable KQ = KeyPair(PublicKey([213, 13, 106, 138, 78, 69, 178, 195, 229, 1, 161, 123, 181, 190, 252, 221, 124, 6, 86, 21, 66, 136, 246, 24, 248, 66, 246, 110, 53, 206, 25, 64]), SecretKey([192, 241, 191, 218, 66, 204, 32, 118, 61, 234, 128, 55, 139, 58, 80, 58, 192, 240, 67, 5, 158, 208, 185, 146, 123, 56, 17, 9, 82, 90, 231, 97]), Seed([104, 35, 40, 240, 149, 239, 169, 216, 155, 98, 15, 254, 58, 179, 74, 140, 102, 106, 133, 254, 220, 154, 225, 124, 28, 38, 35, 29, 219, 60, 50, 196]));
/// KR: GDKR22PQX5DNQHZIWU3QQWXMDN3EDHNC4AJ2EQPZIADDJD75WCZONY3H
static immutable KR = KeyPair(PublicKey([213, 29, 105, 240, 191, 70, 216, 31, 40, 181, 55, 8, 90, 236, 27, 118, 65, 157, 162, 224, 19, 162, 65, 249, 64, 6, 52, 143, 253, 176, 178, 230]), SecretKey([88, 185, 235, 43, 223, 143, 251, 87, 70, 42, 113, 209, 6, 178, 177, 76, 177, 27, 154, 249, 67, 182, 230, 223, 127, 252, 102, 239, 159, 114, 135, 70]), Seed([195, 122, 228, 246, 103, 166, 45, 214, 117, 176, 78, 248, 193, 87, 115, 186, 35, 57, 94, 9, 255, 171, 178, 164, 208, 39, 174, 84, 248, 39, 136, 5]));
/// KS: GDKS22ZSWN5INCNQVGKABVY7PBOLMOTRPQRESLZGDTKFE6U5SOO3M52F
static immutable KS = KeyPair(PublicKey([213, 45, 107, 50, 179, 122, 134, 137, 176, 169, 148, 0, 215, 31, 120, 92, 182, 58, 113, 124, 34, 73, 47, 38, 28, 212, 82, 122, 157, 147, 157, 182]), SecretKey([40, 167, 109, 78, 219, 25, 68, 46, 91, 158, 15, 71, 115, 117, 145, 226, 213, 97, 45, 204, 121, 170, 211, 179, 159, 243, 11, 81, 175, 5, 73, 66]), Seed([61, 62, 225, 214, 61, 157, 222, 144, 202, 126, 68, 255, 43, 134, 188, 107, 232, 251, 193, 173, 121, 196, 96, 68, 62, 67, 58, 177, 85, 201, 157, 197]));
/// KT: GDKT222BGB2GJC5HIG4L4WVURLKEWIL5MQ2PNY2QFNDPJWUGGTYALQBE
static immutable KT = KeyPair(PublicKey([213, 61, 107, 65, 48, 116, 100, 139, 167, 65, 184, 190, 90, 180, 138, 212, 75, 33, 125, 100, 52, 246, 227, 80, 43, 70, 244, 218, 134, 52, 240, 5]), SecretKey([24, 188, 32, 94, 203, 186, 53, 7, 20, 249, 176, 164, 185, 3, 37, 9, 103, 90, 66, 142, 129, 142, 119, 165, 187, 40, 33, 110, 23, 64, 223, 72]), Seed([122, 31, 120, 214, 203, 0, 174, 227, 86, 8, 131, 124, 39, 11, 65, 3, 31, 133, 102, 77, 176, 216, 23, 103, 194, 1, 83, 18, 47, 175, 253, 99]));
/// KU: GDKU2253VCFPHGUO2P4QRDZO4DWQ6XDOVTOOCXNDXWHQLDIIJHMKHFML
static immutable KU = KeyPair(PublicKey([213, 77, 107, 187, 168, 138, 243, 154, 142, 211, 249, 8, 143, 46, 224, 237, 15, 92, 110, 172, 220, 225, 93, 163, 189, 143, 5, 141, 8, 73, 216, 163]), SecretKey([232, 253, 121, 133, 142, 131, 87, 198, 32, 103, 54, 51, 35, 123, 65, 64, 28, 85, 164, 110, 137, 46, 201, 160, 160, 172, 33, 25, 173, 125, 131, 125]), Seed([140, 88, 191, 37, 25, 13, 117, 175, 209, 129, 51, 74, 181, 44, 124, 182, 195, 182, 249, 236, 207, 87, 169, 121, 115, 52, 38, 30, 93, 33, 197, 126]));
/// KV: GDKV22KJNAH5KJETVJEKELE7XOCZHZ3JAWSBX5KFL7PIWFKBO4HAW35I
static immutable KV = KeyPair(PublicKey([213, 93, 105, 73, 104, 15, 213, 36, 147, 170, 72, 162, 44, 159, 187, 133, 147, 231, 105, 5, 164, 27, 245, 69, 95, 222, 139, 21, 65, 119, 14, 11]), SecretKey([232, 134, 226, 135, 177, 166, 85, 17, 21, 50, 60, 111, 124, 175, 116, 93, 240, 0, 39, 20, 174, 46, 242, 10, 51, 142, 64, 76, 223, 9, 121, 123]), Seed([22, 228, 48, 16, 31, 93, 222, 98, 236, 243, 79, 75, 187, 207, 123, 76, 125, 222, 141, 36, 127, 143, 151, 34, 164, 22, 109, 209, 198, 4, 180, 71]));
/// KW: GDKW22G4VI4EQCDQ7IGI4U7CC3VT3BEW27NFGKAETD7GHTENE3VHZS4X
static immutable KW = KeyPair(PublicKey([213, 109, 104, 220, 170, 56, 72, 8, 112, 250, 12, 142, 83, 226, 22, 235, 61, 132, 150, 215, 218, 83, 40, 4, 152, 254, 99, 204, 141, 38, 234, 124]), SecretKey([48, 132, 122, 202, 202, 30, 209, 35, 216, 152, 141, 110, 211, 183, 6, 160, 226, 99, 193, 37, 97, 218, 76, 251, 178, 227, 177, 4, 27, 108, 212, 78]), Seed([168, 90, 233, 155, 53, 181, 217, 238, 140, 128, 192, 35, 210, 200, 68, 197, 167, 213, 180, 157, 139, 112, 120, 248, 246, 91, 241, 159, 120, 11, 152, 105]));
/// KX: GDKX22TCNBVRU6QF2JSQKJUEWW7OYJBSH23X4WMQHF3BNY5E2CC3R66X
static immutable KX = KeyPair(PublicKey([213, 125, 106, 98, 104, 107, 26, 122, 5, 210, 101, 5, 38, 132, 181, 190, 236, 36, 50, 62, 183, 126, 89, 144, 57, 118, 22, 227, 164, 208, 133, 184]), SecretKey([192, 176, 105, 43, 170, 116, 228, 76, 119, 133, 210, 13, 142, 206, 53, 49, 229, 44, 238, 25, 215, 20, 31, 232, 91, 237, 141, 116, 73, 154, 169, 126]), Seed([190, 254, 23, 62, 133, 252, 205, 143, 180, 226, 207, 109, 95, 205, 112, 108, 30, 198, 38, 47, 216, 145, 148, 144, 2, 17, 236, 223, 66, 34, 185, 34]));
/// KY: GDKY22LCPYK2RE3JJYTLWIVJE6TPZ2UPBITMC3FGE3XN6JNNXLKOOJQC
static immutable KY = KeyPair(PublicKey([213, 141, 105, 98, 126, 21, 168, 147, 105, 78, 38, 187, 34, 169, 39, 166, 252, 234, 143, 10, 38, 193, 108, 166, 38, 238, 223, 37, 173, 186, 212, 231]), SecretKey([184, 120, 21, 56, 141, 93, 113, 106, 245, 48, 91, 202, 181, 238, 60, 39, 18, 78, 233, 131, 83, 228, 252, 113, 54, 237, 180, 155, 90, 13, 165, 120]), Seed([112, 241, 84, 174, 200, 246, 154, 19, 106, 168, 213, 147, 226, 222, 189, 7, 72, 217, 105, 226, 113, 73, 154, 74, 39, 5, 214, 22, 221, 218, 215, 17]));
/// KZ: GDKZ22D55PK3ZP4NILJ2VHB2JCPMF6ADTZM4ZX46SJJ4OTOF3AXE5BYL
static immutable KZ = KeyPair(PublicKey([213, 157, 104, 125, 235, 213, 188, 191, 141, 66, 211, 170, 156, 58, 72, 158, 194, 248, 3, 158, 89, 204, 223, 158, 146, 83, 199, 77, 197, 216, 46, 78]), SecretKey([232, 8, 20, 229, 66, 127, 232, 64, 42, 40, 111, 131, 184, 222, 84, 95, 80, 104, 14, 176, 237, 19, 171, 144, 146, 150, 249, 187, 217, 231, 182, 64]), Seed([47, 219, 130, 54, 60, 3, 122, 163, 184, 174, 110, 194, 105, 38, 39, 8, 65, 82, 100, 37, 172, 77, 42, 238, 1, 123, 186, 135, 152, 193, 136, 210]));
/// LA: GDLA22LZH2SNR7VYXPWAJBZ6ZJY5UKSM5W3IIKBBB5YMSPNCPLIQXAJO
static immutable LA = KeyPair(PublicKey([214, 13, 105, 121, 62, 164, 216, 254, 184, 187, 236, 4, 135, 62, 202, 113, 218, 42, 76, 237, 182, 132, 40, 33, 15, 112, 201, 61, 162, 122, 209, 11]), SecretKey([208, 29, 208, 35, 9, 130, 163, 232, 219, 15, 55, 131, 179, 109, 142, 120, 239, 250, 27, 201, 102, 87, 40, 196, 174, 135, 124, 15, 211, 151, 238, 77]), Seed([168, 16, 47, 73, 48, 47, 45, 126, 221, 126, 204, 29, 255, 111, 166, 243, 221, 146, 157, 66, 128, 100, 225, 203, 110, 211, 22, 83, 108, 152, 141, 41]));
/// LB: GDLB22CH4DZPWXHYEXB22BMISTAGLQJT474GS5HPIQDEI6NWZBEVJDKY
static immutable LB = KeyPair(PublicKey([214, 29, 104, 71, 224, 242, 251, 92, 248, 37, 195, 173, 5, 136, 148, 192, 101, 193, 51, 231, 248, 105, 116, 239, 68, 6, 68, 121, 182, 200, 73, 84]), SecretKey([8, 223, 54, 53, 162, 8, 132, 210, 122, 25, 176, 116, 248, 19, 124, 178, 236, 232, 61, 76, 153, 125, 174, 49, 12, 193, 204, 254, 246, 78, 47, 88]), Seed([133, 222, 151, 113, 208, 108, 194, 255, 242, 122, 196, 254, 36, 34, 220, 141, 194, 186, 22, 192, 191, 163, 203, 165, 148, 52, 153, 119, 142, 229, 159, 184]));
/// LC: GDLC22DKGYUJWJIJEZL5RJZ26ID463IN62XNS5GWVQGY43FWXRPCJFCY
static immutable LC = KeyPair(PublicKey([214, 45, 104, 106, 54, 40, 155, 37, 9, 38, 87, 216, 167, 58, 242, 7, 207, 109, 13, 246, 174, 217, 116, 214, 172, 13, 142, 108, 182, 188, 94, 36]), SecretKey([24, 124, 227, 123, 169, 186, 47, 151, 42, 246, 87, 230, 206, 105, 130, 134, 236, 99, 12, 225, 46, 188, 160, 27, 231, 51, 236, 110, 26, 121, 150, 101]), Seed([17, 28, 144, 29, 17, 83, 34, 134, 30, 153, 106, 23, 146, 153, 43, 112, 86, 194, 171, 66, 172, 33, 57, 168, 212, 61, 18, 191, 252, 194, 62, 45]));
/// LD: GDLD22WYG5IBHJV46MHVHDJF5C4OF2Y3WNGWEAUDUQAHADIHRQXTJ3JU
static immutable LD = KeyPair(PublicKey([214, 61, 106, 216, 55, 80, 19, 166, 188, 243, 15, 83, 141, 37, 232, 184, 226, 235, 27, 179, 77, 98, 2, 131, 164, 0, 112, 13, 7, 140, 47, 52]), SecretKey([216, 183, 87, 180, 131, 210, 192, 54, 52, 211, 175, 103, 148, 244, 20, 36, 180, 246, 112, 2, 52, 31, 212, 125, 148, 233, 14, 104, 109, 3, 188, 122]), Seed([63, 153, 144, 225, 172, 182, 177, 122, 60, 192, 223, 170, 75, 92, 6, 169, 111, 56, 216, 123, 193, 56, 116, 11, 183, 177, 4, 153, 156, 252, 73, 13]));
/// LE: GDLE22LCD55WCFO72UXCIKRB2QX2UXHPCPBTASQVTEQAU7U7CLMYMRCC
static immutable LE = KeyPair(PublicKey([214, 77, 105, 98, 31, 123, 97, 21, 223, 213, 46, 36, 42, 33, 212, 47, 170, 92, 239, 19, 195, 48, 74, 21, 153, 32, 10, 126, 159, 18, 217, 134]), SecretKey([128, 11, 195, 60, 54, 135, 190, 52, 107, 32, 114, 4, 208, 67, 188, 171, 106, 141, 94, 58, 60, 188, 176, 12, 233, 240, 199, 126, 230, 236, 238, 80]), Seed([190, 43, 148, 149, 186, 141, 120, 221, 129, 230, 45, 131, 70, 203, 128, 115, 184, 5, 153, 254, 65, 76, 24, 34, 178, 151, 78, 175, 187, 194, 109, 151]));
/// LF: GDLF22YFGGHYPSM3LA5PRU3Q4R22WQB3XNYVHZWL5727HN7Q2PHM7PCW
static immutable LF = KeyPair(PublicKey([214, 93, 107, 5, 49, 143, 135, 201, 155, 88, 58, 248, 211, 112, 228, 117, 171, 64, 59, 187, 113, 83, 230, 203, 239, 245, 243, 183, 240, 211, 206, 207]), SecretKey([168, 137, 207, 146, 14, 149, 161, 51, 52, 255, 163, 241, 124, 168, 13, 140, 65, 163, 90, 27, 16, 70, 160, 192, 44, 63, 27, 138, 143, 8, 244, 93]), Seed([66, 123, 224, 44, 143, 173, 247, 54, 200, 150, 110, 44, 72, 246, 21, 187, 160, 185, 80, 107, 75, 51, 154, 145, 114, 141, 140, 185, 89, 57, 111, 195]));
/// LG: GDLG22FIES6AXM6HYAAWPFLK7P7M5URW3F5FEOATQ3I5LGCRPUYT7BTF
static immutable LG = KeyPair(PublicKey([214, 109, 104, 168, 36, 188, 11, 179, 199, 192, 1, 103, 149, 106, 251, 254, 206, 210, 54, 217, 122, 82, 56, 19, 134, 209, 213, 152, 81, 125, 49, 63]), SecretKey([64, 87, 151, 133, 28, 29, 78, 176, 204, 206, 234, 171, 132, 149, 158, 140, 228, 252, 120, 195, 252, 184, 140, 226, 96, 126, 7, 175, 88, 42, 136, 83]), Seed([200, 17, 84, 232, 211, 163, 91, 145, 194, 116, 243, 64, 209, 10, 3, 133, 135, 129, 238, 187, 222, 246, 144, 120, 169, 13, 210, 19, 227, 121, 175, 162]));
/// LH: GDLH226XKLZWQNZFBO5KAKTUHKBQJC5PROUXD62Z7YCZIOOFOAT3LDCR
static immutable LH = KeyPair(PublicKey([214, 125, 107, 215, 82, 243, 104, 55, 37, 11, 186, 160, 42, 116, 58, 131, 4, 139, 175, 139, 169, 113, 251, 89, 254, 5, 148, 57, 197, 112, 39, 181]), SecretKey([224, 127, 22, 86, 113, 195, 9, 179, 157, 231, 100, 73, 68, 25, 194, 101, 64, 228, 13, 94, 12, 159, 106, 69, 23, 136, 119, 60, 33, 117, 114, 104]), Seed([202, 173, 202, 105, 132, 200, 69, 251, 221, 244, 198, 1, 211, 74, 244, 108, 240, 102, 60, 132, 17, 171, 27, 52, 40, 187, 196, 43, 172, 133, 121, 113]));
/// LI: GDLI22XBSROFGUHAOZXTFYFMH5ZRY2IFYNFCXRVUBAEHZC2FVBUDC2RW
static immutable LI = KeyPair(PublicKey([214, 141, 106, 225, 148, 92, 83, 80, 224, 118, 111, 50, 224, 172, 63, 115, 28, 105, 5, 195, 74, 43, 198, 180, 8, 8, 124, 139, 69, 168, 104, 49]), SecretKey([232, 219, 20, 109, 194, 51, 241, 98, 79, 201, 44, 153, 125, 235, 249, 97, 91, 150, 90, 11, 67, 161, 9, 188, 190, 12, 38, 213, 194, 110, 255, 92]), Seed([239, 29, 218, 37, 127, 230, 12, 115, 129, 158, 73, 98, 136, 198, 136, 99, 195, 137, 144, 243, 197, 218, 175, 99, 151, 70, 16, 124, 198, 87, 8, 50]));
/// LJ: GDLJ227JR6MRCILHGZ5YWXMWI2QM2525SLNJYS2LXDXNWAH4Q3LRTBJD
static immutable LJ = KeyPair(PublicKey([214, 157, 107, 233, 143, 153, 17, 33, 103, 54, 123, 139, 93, 150, 70, 160, 205, 119, 93, 146, 218, 156, 75, 75, 184, 238, 219, 0, 252, 134, 215, 25]), SecretKey([64, 2, 211, 18, 228, 73, 88, 45, 75, 6, 137, 108, 85, 241, 111, 2, 248, 80, 233, 230, 238, 125, 179, 245, 103, 245, 73, 185, 225, 73, 79, 69]), Seed([85, 137, 237, 14, 135, 65, 20, 202, 109, 11, 201, 8, 199, 177, 107, 166, 247, 69, 112, 36, 185, 166, 5, 168, 105, 66, 223, 35, 17, 29, 241, 144]));
/// LK: GDLK225DC5UECAHOPW4BOCM5ARKQBSXWVJPWT7ZKWRITC3NNDTGIEH3V
static immutable LK = KeyPair(PublicKey([214, 173, 107, 163, 23, 104, 65, 0, 238, 125, 184, 23, 9, 157, 4, 85, 0, 202, 246, 170, 95, 105, 255, 42, 180, 81, 49, 109, 173, 28, 204, 130]), SecretKey([176, 0, 48, 169, 233, 42, 222, 7, 153, 180, 225, 73, 147, 44, 131, 54, 105, 105, 147, 211, 179, 202, 52, 76, 46, 80, 202, 11, 212, 184, 66, 72]), Seed([220, 34, 85, 182, 210, 148, 129, 171, 235, 246, 52, 209, 177, 173, 102, 190, 221, 164, 176, 126, 28, 182, 174, 228, 27, 57, 235, 140, 197, 250, 160, 9]));
/// LL: GDLL22DK5NTHSFOIHICTVQXYX3LO6I2PFKYTP7BSZL6WTGN6ZUDB5WM6
static immutable LL = KeyPair(PublicKey([214, 189, 104, 106, 235, 102, 121, 21, 200, 58, 5, 58, 194, 248, 190, 214, 239, 35, 79, 42, 177, 55, 252, 50, 202, 253, 105, 153, 190, 205, 6, 30]), SecretKey([168, 4, 69, 129, 148, 188, 235, 84, 88, 131, 249, 206, 141, 195, 237, 134, 177, 227, 16, 239, 79, 232, 107, 110, 89, 218, 211, 197, 88, 6, 80, 122]), Seed([213, 224, 70, 205, 195, 127, 151, 244, 138, 116, 228, 56, 10, 161, 154, 64, 163, 172, 177, 82, 137, 130, 184, 34, 240, 196, 63, 120, 30, 28, 17, 165]));
/// LM: GDLM22E5WQLQYH7CPTC5O75WNCZAKHFDY7LLD3EMWNXOOS6WC5CIDOUW
static immutable LM = KeyPair(PublicKey([214, 205, 104, 157, 180, 23, 12, 31, 226, 124, 197, 215, 127, 182, 104, 178, 5, 28, 163, 199, 214, 177, 236, 140, 179, 110, 231, 75, 214, 23, 68, 129]), SecretKey([48, 67, 8, 76, 121, 159, 214, 108, 190, 235, 150, 12, 96, 87, 106, 134, 85, 157, 33, 125, 14, 49, 66, 53, 245, 46, 37, 148, 167, 94, 46, 65]), Seed([167, 199, 145, 176, 126, 181, 167, 61, 184, 20, 76, 93, 166, 140, 82, 184, 19, 201, 226, 190, 23, 117, 233, 133, 121, 4, 128, 161, 88, 28, 76, 145]));
/// LN: GDLN22YY3O2HKOCTXG472TQOGG6VMW4HB6JBQDYO4UMCNCNBSFWTXDKX
static immutable LN = KeyPair(PublicKey([214, 221, 107, 24, 219, 180, 117, 56, 83, 185, 185, 253, 78, 14, 49, 189, 86, 91, 135, 15, 146, 24, 15, 14, 229, 24, 38, 137, 161, 145, 109, 59]), SecretKey([240, 183, 106, 229, 5, 158, 78, 104, 35, 132, 12, 44, 92, 193, 42, 1, 111, 155, 235, 97, 64, 44, 234, 53, 167, 245, 71, 140, 140, 20, 146, 75]), Seed([47, 92, 44, 28, 144, 55, 189, 125, 102, 66, 58, 112, 102, 12, 43, 138, 14, 63, 35, 243, 99, 181, 18, 143, 86, 119, 77, 235, 41, 132, 168, 200]));
/// LO: GDLO22WRCB5JVMPFDEJZGYIXNLT3BEIEQUAQYYD7BXEO5IBVTET6GTRC
static immutable LO = KeyPair(PublicKey([214, 237, 106, 209, 16, 122, 154, 177, 229, 25, 19, 147, 97, 23, 106, 231, 176, 145, 4, 133, 1, 12, 96, 127, 13, 200, 238, 160, 53, 153, 39, 227]), SecretKey([56, 103, 84, 173, 106, 70, 60, 168, 134, 133, 11, 115, 105, 91, 143, 192, 45, 238, 196, 215, 46, 110, 127, 74, 118, 110, 36, 15, 133, 174, 102, 110]), Seed([102, 126, 49, 148, 17, 235, 245, 158, 141, 132, 64, 242, 157, 113, 21, 142, 36, 189, 229, 217, 19, 6, 104, 252, 113, 80, 107, 214, 255, 220, 103, 75]));
/// LP: GDLP22GE7MG7YPU5OKNUPRM4FILPJM36X4JVIHFJ33PUK6N5CUV4I47G
static immutable LP = KeyPair(PublicKey([214, 253, 104, 196, 251, 13, 252, 62, 157, 114, 155, 71, 197, 156, 42, 22, 244, 179, 126, 191, 19, 84, 28, 169, 222, 223, 69, 121, 189, 21, 43, 196]), SecretKey([56, 9, 144, 93, 115, 12, 199, 201, 168, 199, 207, 102, 28, 159, 135, 70, 201, 182, 68, 126, 203, 156, 153, 44, 77, 236, 2, 236, 71, 104, 139, 100]), Seed([18, 166, 14, 96, 20, 137, 15, 18, 192, 177, 219, 220, 111, 184, 64, 247, 105, 63, 5, 101, 46, 233, 243, 169, 19, 72, 206, 120, 86, 118, 23, 183]));
/// LQ: GDLQ223S3MUHFVLCJ74O4VTPNAXMWZFAOMCKWV266ND544RIFQQXKINX
static immutable LQ = KeyPair(PublicKey([215, 13, 107, 114, 219, 40, 114, 213, 98, 79, 248, 238, 86, 111, 104, 46, 203, 100, 160, 115, 4, 171, 87, 94, 243, 71, 222, 114, 40, 44, 33, 117]), SecretKey([32, 227, 117, 91, 224, 86, 2, 145, 215, 217, 239, 79, 233, 245, 60, 253, 29, 6, 145, 112, 236, 253, 162, 166, 45, 142, 245, 3, 178, 253, 221, 67]), Seed([172, 19, 137, 160, 191, 153, 49, 194, 206, 49, 177, 48, 174, 196, 49, 244, 90, 89, 71, 158, 68, 6, 176, 117, 84, 203, 238, 20, 83, 72, 190, 99]));
/// LR: GDLR22SOF7VTZ5T7O6RF2XL5PRY54J63YJNSZCVWKFWFPEJMDFHNCGWI
static immutable LR = KeyPair(PublicKey([215, 29, 106, 78, 47, 235, 60, 246, 127, 119, 162, 93, 93, 125, 124, 113, 222, 39, 219, 194, 91, 44, 138, 182, 81, 108, 87, 145, 44, 25, 78, 209]), SecretKey([208, 128, 80, 232, 213, 188, 82, 241, 170, 245, 201, 191, 7, 26, 129, 9, 103, 195, 106, 110, 167, 110, 83, 1, 140, 86, 55, 181, 230, 132, 240, 64]), Seed([67, 26, 215, 130, 160, 174, 137, 30, 96, 168, 34, 137, 236, 79, 154, 161, 61, 214, 148, 68, 203, 196, 225, 187, 196, 189, 37, 192, 121, 46, 66, 114]));
/// LS: GDLS22N7D5ESZ4VZG5B56KS76JXJRGWENBPYWPMRFEP3OTR2DRD2OLJG
static immutable LS = KeyPair(PublicKey([215, 45, 105, 191, 31, 73, 44, 242, 185, 55, 67, 223, 42, 95, 242, 110, 152, 154, 196, 104, 95, 139, 61, 145, 41, 31, 183, 78, 58, 28, 71, 167]), SecretKey([192, 219, 237, 88, 63, 202, 21, 115, 226, 47, 213, 182, 246, 227, 171, 220, 100, 28, 246, 247, 130, 171, 109, 97, 26, 13, 52, 255, 198, 128, 81, 100]), Seed([79, 55, 26, 135, 211, 5, 102, 186, 92, 50, 71, 75, 61, 189, 138, 55, 28, 252, 172, 210, 119, 220, 71, 214, 250, 136, 9, 126, 198, 14, 236, 112]));
/// LT: GDLT22CBDXWN3KQV7K6V2JJSLPOEJ2W34RAEYECVLJLAOFQ53DKP42WD
static immutable LT = KeyPair(PublicKey([215, 61, 104, 65, 29, 236, 221, 170, 21, 250, 189, 93, 37, 50, 91, 220, 68, 234, 219, 228, 64, 76, 16, 85, 90, 86, 7, 22, 29, 216, 212, 254]), SecretKey([144, 68, 255, 74, 139, 169, 233, 100, 44, 67, 212, 108, 198, 183, 16, 201, 234, 28, 120, 196, 13, 90, 46, 107, 225, 124, 250, 217, 42, 30, 10, 85]), Seed([219, 93, 230, 252, 253, 209, 151, 7, 52, 25, 13, 125, 246, 235, 163, 179, 71, 101, 43, 198, 22, 228, 59, 111, 111, 127, 130, 134, 143, 22, 51, 74]));
/// LU: GDLU224HNKOFKPALHCFIG26ELKIDOLGIKZHIGKZ4H344NENWJZ3P3YEY
static immutable LU = KeyPair(PublicKey([215, 77, 107, 135, 106, 156, 85, 60, 11, 56, 138, 131, 107, 196, 90, 144, 55, 44, 200, 86, 78, 131, 43, 60, 62, 249, 198, 145, 182, 78, 118, 253]), SecretKey([232, 213, 20, 70, 204, 58, 144, 232, 244, 124, 230, 31, 69, 235, 201, 112, 152, 158, 217, 255, 198, 96, 91, 152, 0, 215, 173, 162, 231, 224, 114, 123]), Seed([152, 186, 228, 250, 237, 173, 187, 39, 93, 18, 141, 9, 70, 159, 114, 105, 116, 17, 198, 53, 182, 33, 19, 146, 238, 33, 118, 126, 98, 248, 189, 121]));
/// LV: GDLV22TEU2XA24MPDMH25SBFVKF4B5TBABE4JJAI3BHJCKQCHTQDF2BC
static immutable LV = KeyPair(PublicKey([215, 93, 106, 100, 166, 174, 13, 113, 143, 27, 15, 174, 200, 37, 170, 139, 192, 246, 97, 0, 73, 196, 164, 8, 216, 78, 145, 42, 2, 60, 224, 50]), SecretKey([160, 192, 17, 87, 67, 140, 168, 253, 138, 69, 40, 194, 97, 20, 1, 219, 127, 70, 97, 165, 165, 191, 60, 128, 151, 133, 240, 190, 54, 103, 164, 102]), Seed([62, 99, 133, 243, 221, 99, 126, 221, 168, 223, 162, 238, 124, 75, 192, 125, 126, 52, 144, 118, 155, 82, 43, 175, 113, 148, 160, 93, 212, 177, 17, 106]));
/// LW: GDLW224XXRL5ULEMFAU3G67GT3TGC5R2DORTTB2KOC275XENLIW6UJH5
static immutable LW = KeyPair(PublicKey([215, 109, 107, 151, 188, 87, 218, 44, 140, 40, 41, 179, 123, 230, 158, 230, 97, 118, 58, 27, 163, 57, 135, 74, 112, 181, 254, 220, 141, 90, 45, 234]), SecretKey([200, 208, 121, 199, 61, 232, 41, 124, 140, 236, 240, 212, 229, 84, 119, 241, 132, 71, 105, 212, 190, 26, 101, 87, 35, 103, 73, 0, 204, 185, 111, 64]), Seed([97, 60, 145, 206, 131, 228, 50, 77, 14, 151, 200, 87, 108, 14, 44, 95, 238, 117, 223, 66, 210, 34, 59, 141, 167, 78, 162, 174, 199, 165, 156, 27]));
/// LX: GDLX22WB2WSZU4DVY2OPUSJG6WOMGILSZJQZ4OEFAZE4W7AHUZZJOFIY
static immutable LX = KeyPair(PublicKey([215, 125, 106, 193, 213, 165, 154, 112, 117, 198, 156, 250, 73, 38, 245, 156, 195, 33, 114, 202, 97, 158, 56, 133, 6, 73, 203, 124, 7, 166, 114, 151]), SecretKey([40, 195, 130, 130, 37, 239, 241, 231, 179, 29, 134, 211, 182, 54, 215, 126, 237, 116, 27, 103, 214, 126, 5, 254, 145, 154, 15, 238, 252, 146, 35, 93]), Seed([52, 198, 11, 182, 140, 7, 65, 178, 200, 139, 227, 219, 250, 8, 202, 90, 102, 247, 41, 148, 67, 174, 16, 135, 130, 224, 20, 236, 223, 68, 214, 212]));
/// LY: GDLY22LCETHDB26S77R2KH7DY62D5X3ESORG3EETJKL7KS5UQ2MSMRKQ
static immutable LY = KeyPair(PublicKey([215, 141, 105, 98, 36, 206, 48, 235, 210, 255, 227, 165, 31, 227, 199, 180, 62, 223, 100, 147, 162, 109, 144, 147, 74, 151, 245, 75, 180, 134, 153, 38]), SecretKey([112, 129, 121, 255, 67, 45, 8, 73, 121, 95, 92, 167, 198, 131, 138, 244, 107, 6, 165, 242, 49, 127, 63, 150, 177, 192, 31, 58, 161, 77, 245, 84]), Seed([207, 115, 151, 4, 244, 220, 52, 36, 128, 244, 234, 241, 210, 2, 245, 68, 120, 172, 10, 114, 219, 74, 62, 96, 203, 88, 64, 173, 166, 215, 100, 72]));
/// LZ: GDLZ22GUV3RR2VEXNCNQTIUNWOXSOBCSZZREMOUVXZTVGZT2SIMYIATR
static immutable LZ = KeyPair(PublicKey([215, 157, 104, 212, 174, 227, 29, 84, 151, 104, 155, 9, 162, 141, 179, 175, 39, 4, 82, 206, 98, 70, 58, 149, 190, 103, 83, 102, 122, 146, 25, 132]), SecretKey([96, 24, 151, 186, 94, 5, 231, 196, 59, 125, 228, 137, 204, 34, 36, 120, 22, 208, 4, 245, 67, 83, 199, 157, 226, 66, 109, 35, 117, 26, 245, 73]), Seed([170, 65, 174, 91, 247, 222, 65, 85, 94, 92, 183, 202, 169, 150, 61, 147, 120, 245, 132, 141, 75, 95, 102, 232, 195, 183, 53, 14, 51, 95, 125, 7]));
/// MA: GDMA22PBDOSPVDTGZ4J7F6GKPJRPIP2W5KTHPKVHIE6VN5P2A6WN2J7L
static immutable MA = KeyPair(PublicKey([216, 13, 105, 225, 27, 164, 250, 142, 102, 207, 19, 242, 248, 202, 122, 98, 244, 63, 86, 234, 166, 119, 170, 167, 65, 61, 86, 245, 250, 7, 172, 221]), SecretKey([120, 172, 241, 87, 160, 245, 121, 68, 12, 28, 222, 240, 71, 95, 129, 150, 194, 72, 153, 80, 49, 170, 181, 231, 142, 50, 172, 216, 84, 81, 187, 89]), Seed([133, 70, 149, 240, 50, 252, 38, 183, 6, 200, 141, 32, 25, 83, 232, 235, 93, 179, 123, 223, 164, 227, 215, 150, 71, 218, 83, 212, 78, 168, 112, 44]));
/// MB: GDMB22EWWKA5KECSXFPCGJDZOZZAHB6GOB44PTTMCB52ULXIHUM2NG2M
static immutable MB = KeyPair(PublicKey([216, 29, 104, 150, 178, 129, 213, 16, 82, 185, 94, 35, 36, 121, 118, 114, 3, 135, 198, 112, 121, 199, 206, 108, 16, 123, 170, 46, 232, 61, 25, 166]), SecretKey([120, 166, 84, 76, 91, 67, 114, 236, 247, 15, 164, 183, 61, 254, 187, 131, 164, 61, 82, 192, 145, 222, 15, 125, 146, 172, 78, 104, 116, 78, 192, 75]), Seed([203, 248, 39, 58, 43, 18, 35, 88, 17, 66, 245, 155, 196, 80, 243, 73, 206, 249, 17, 72, 126, 15, 151, 93, 0, 162, 149, 53, 187, 59, 104, 168]));
/// MC: GDMC222JAQ5LGMFGE677TL4XLWINR6R7VB5YCAK53WJYBTHNUZJYTKYN
static immutable MC = KeyPair(PublicKey([216, 45, 107, 73, 4, 58, 179, 48, 166, 39, 191, 249, 175, 151, 93, 144, 216, 250, 63, 168, 123, 129, 1, 93, 221, 147, 128, 204, 237, 166, 83, 137]), SecretKey([64, 74, 237, 77, 83, 223, 183, 28, 221, 210, 93, 188, 245, 120, 46, 139, 6, 34, 12, 75, 68, 75, 215, 198, 20, 133, 87, 8, 120, 48, 63, 87]), Seed([77, 200, 127, 151, 181, 248, 39, 57, 147, 61, 140, 102, 58, 227, 255, 170, 139, 76, 102, 98, 255, 223, 50, 36, 189, 47, 37, 114, 239, 146, 215, 169]));
/// MD: GDMD22RR53AFMIYO7DHV3H6J5GDDQQKM6SNCUHMK3UY32HFOSF5LKPBM
static immutable MD = KeyPair(PublicKey([216, 61, 106, 49, 238, 192, 86, 35, 14, 248, 207, 93, 159, 201, 233, 134, 56, 65, 76, 244, 154, 42, 29, 138, 221, 49, 189, 28, 174, 145, 122, 181]), SecretKey([200, 211, 138, 178, 125, 14, 113, 111, 100, 215, 203, 192, 149, 237, 208, 198, 188, 202, 117, 8, 145, 75, 39, 99, 157, 70, 107, 123, 242, 242, 78, 123]), Seed([88, 212, 5, 63, 179, 226, 19, 170, 21, 176, 168, 211, 66, 58, 6, 33, 60, 201, 175, 125, 201, 218, 4, 153, 234, 195, 45, 65, 161, 184, 75, 135]));
/// ME: GDME22AQV3RDGS64F2XUSEWHAKSE7YAY5WQQGLDSOKNAY5G2DPROZQ44
static immutable ME = KeyPair(PublicKey([216, 77, 104, 16, 174, 226, 51, 75, 220, 46, 175, 73, 18, 199, 2, 164, 79, 224, 24, 237, 161, 3, 44, 114, 114, 154, 12, 116, 218, 27, 226, 236]), SecretKey([232, 23, 144, 17, 2, 51, 12, 7, 56, 234, 226, 168, 215, 129, 100, 10, 154, 128, 154, 157, 158, 190, 239, 166, 233, 70, 129, 89, 208, 105, 243, 113]), Seed([240, 218, 253, 124, 17, 207, 25, 71, 81, 49, 239, 125, 226, 37, 38, 147, 21, 195, 129, 31, 106, 180, 104, 2, 58, 138, 142, 62, 27, 140, 129, 4]));
/// MF: GDMF22GNY7GXSBIGNUYZ2MUOE46E57S3JLLCERLHDETGMSD5JNSLSSOH
static immutable MF = KeyPair(PublicKey([216, 93, 104, 205, 199, 205, 121, 5, 6, 109, 49, 157, 50, 142, 39, 60, 78, 254, 91, 74, 214, 34, 69, 103, 25, 38, 102, 72, 125, 75, 100, 185]), SecretKey([0, 249, 38, 52, 228, 36, 184, 183, 162, 75, 34, 122, 34, 59, 143, 199, 23, 134, 103, 168, 132, 199, 144, 79, 221, 1, 76, 197, 148, 195, 249, 118]), Seed([131, 100, 255, 110, 3, 36, 20, 213, 192, 200, 104, 136, 147, 184, 183, 165, 170, 119, 204, 14, 208, 173, 243, 100, 4, 187, 201, 36, 47, 8, 46, 67]));
/// MG: GDMG22QS6BU5DIWDN6KT4DTGEKPYQYHRN7SCDUP6OPZ7WH34QUJ7Y5X5
static immutable MG = KeyPair(PublicKey([216, 109, 106, 18, 240, 105, 209, 162, 195, 111, 149, 62, 14, 102, 34, 159, 136, 96, 241, 111, 228, 33, 209, 254, 115, 243, 251, 31, 124, 133, 19, 252]), SecretKey([64, 170, 40, 74, 29, 110, 195, 214, 145, 206, 173, 158, 6, 111, 76, 161, 37, 111, 80, 4, 234, 151, 78, 226, 0, 193, 80, 232, 222, 227, 83, 102]), Seed([49, 239, 203, 135, 119, 50, 208, 154, 167, 189, 49, 219, 174, 197, 137, 203, 97, 192, 97, 80, 29, 17, 130, 162, 245, 197, 107, 159, 10, 151, 38, 112]));
/// MH: GDMH22F3BKBSHYEL7WJCTAGKVNAXU2I4UUUXQ36JEZ44CQOQQG7BXOBE
static immutable MH = KeyPair(PublicKey([216, 125, 104, 187, 10, 131, 35, 224, 139, 253, 146, 41, 128, 202, 171, 65, 122, 105, 28, 165, 41, 120, 111, 201, 38, 121, 193, 65, 208, 129, 190, 27]), SecretKey([96, 34, 252, 235, 154, 146, 200, 173, 154, 116, 223, 55, 48, 1, 190, 19, 172, 21, 249, 203, 156, 160, 251, 78, 88, 84, 217, 83, 59, 224, 166, 125]), Seed([20, 174, 27, 191, 215, 133, 25, 131, 144, 66, 215, 105, 162, 218, 66, 205, 71, 42, 65, 195, 190, 187, 181, 129, 32, 92, 177, 180, 243, 239, 129, 92]));
/// MI: GDMI22XJQP3UQWZUMXJWMJLSU2626QY57ZDFGVHXENVBW74YNKQEMSHE
static immutable MI = KeyPair(PublicKey([216, 141, 106, 233, 131, 247, 72, 91, 52, 101, 211, 102, 37, 114, 166, 189, 175, 67, 29, 254, 70, 83, 84, 247, 35, 106, 27, 127, 152, 106, 160, 70]), SecretKey([144, 248, 140, 100, 149, 42, 199, 35, 197, 22, 141, 76, 40, 216, 184, 212, 107, 134, 205, 149, 207, 212, 141, 210, 252, 67, 191, 140, 69, 150, 48, 118]), Seed([226, 229, 15, 136, 155, 122, 161, 248, 154, 104, 124, 229, 219, 202, 227, 72, 204, 16, 242, 33, 252, 177, 147, 58, 253, 29, 129, 211, 237, 38, 120, 126]));
/// MJ: GDMJ22ANVXGDZXXV4F4QA3XC243YKOTZ35K6IJTYZAR5KTVP3EJ3JPJT
static immutable MJ = KeyPair(PublicKey([216, 157, 104, 13, 173, 204, 60, 222, 245, 225, 121, 0, 110, 226, 215, 55, 133, 58, 121, 223, 85, 228, 38, 120, 200, 35, 213, 78, 175, 217, 19, 180]), SecretKey([144, 136, 129, 76, 78, 224, 35, 230, 187, 189, 255, 116, 167, 0, 55, 200, 206, 23, 246, 190, 74, 92, 110, 65, 91, 109, 74, 34, 41, 12, 56, 91]), Seed([236, 192, 201, 238, 116, 228, 200, 224, 194, 39, 108, 214, 159, 149, 100, 33, 212, 253, 41, 144, 36, 40, 0, 79, 147, 29, 229, 11, 120, 25, 188, 70]));
/// MK: GDMK22YZINLXNYH64YXZFCMSHHVKQXCRQNEMOPAZYBIZEWEMVETQRFXH
static immutable MK = KeyPair(PublicKey([216, 173, 107, 25, 67, 87, 118, 224, 254, 230, 47, 146, 137, 146, 57, 234, 168, 92, 81, 131, 72, 199, 60, 25, 192, 81, 146, 88, 140, 169, 39, 8]), SecretKey([24, 228, 249, 148, 208, 77, 197, 33, 221, 238, 11, 188, 131, 99, 86, 3, 41, 234, 44, 48, 156, 101, 81, 30, 211, 233, 44, 242, 187, 145, 138, 113]), Seed([100, 115, 196, 67, 116, 142, 223, 95, 161, 203, 62, 26, 91, 171, 225, 175, 155, 55, 83, 165, 27, 13, 111, 86, 204, 46, 218, 51, 38, 249, 23, 130]));
/// ML: GDML22LKP3N6S37CYIBFRANXVY7KMJMINH5VFADGDFLGIWNOR3YU7T6I
static immutable ML = KeyPair(PublicKey([216, 189, 105, 106, 126, 219, 233, 111, 226, 194, 2, 88, 129, 183, 174, 62, 166, 37, 136, 105, 251, 82, 128, 102, 25, 86, 100, 89, 174, 142, 241, 79]), SecretKey([96, 213, 133, 41, 61, 208, 76, 213, 4, 105, 203, 234, 239, 234, 73, 3, 191, 45, 175, 235, 224, 187, 70, 58, 156, 186, 12, 241, 83, 47, 211, 125]), Seed([104, 47, 137, 242, 205, 90, 118, 183, 14, 220, 177, 252, 180, 51, 218, 183, 127, 70, 206, 22, 218, 46, 22, 180, 225, 156, 155, 139, 103, 232, 104, 17]));
/// MM: GDMM22LU54X5YHGWQYS3TWNNNL2BZJ4AMIEKNQREEB4TKMB56IYIOXNH
static immutable MM = KeyPair(PublicKey([216, 205, 105, 116, 239, 47, 220, 28, 214, 134, 37, 185, 217, 173, 106, 244, 28, 167, 128, 98, 8, 166, 194, 36, 32, 121, 53, 48, 61, 242, 48, 135]), SecretKey([64, 249, 65, 164, 51, 113, 45, 191, 139, 0, 143, 146, 59, 201, 150, 24, 60, 39, 127, 120, 98, 196, 39, 77, 126, 155, 9, 208, 63, 53, 114, 99]), Seed([22, 184, 116, 239, 172, 97, 251, 78, 184, 74, 78, 192, 217, 130, 32, 136, 201, 85, 126, 210, 136, 195, 207, 25, 137, 172, 136, 253, 28, 137, 215, 100]));
/// MN: GDMN22O4APCNQ4ICXRCY2BWTPBHQDVFSS27CRERRYL6ZCRQBUV2BEFME
static immutable MN = KeyPair(PublicKey([216, 221, 105, 220, 3, 196, 216, 113, 2, 188, 69, 141, 6, 211, 120, 79, 1, 212, 178, 150, 190, 40, 146, 49, 194, 253, 145, 70, 1, 165, 116, 18]), SecretKey([152, 225, 129, 102, 41, 230, 244, 145, 95, 39, 41, 8, 94, 167, 83, 109, 226, 1, 11, 86, 6, 159, 147, 164, 143, 50, 247, 224, 223, 244, 98, 68]), Seed([88, 204, 99, 31, 120, 228, 181, 48, 146, 45, 186, 49, 29, 39, 176, 229, 60, 245, 78, 221, 144, 70, 94, 20, 6, 71, 159, 141, 145, 86, 86, 36]));
/// MO: GDMO22SYVHF5CXPIABI3F2MOL3L6XQF37GLU2W3SHEOIQZHXJSLFFS7W
static immutable MO = KeyPair(PublicKey([216, 237, 106, 88, 169, 203, 209, 93, 232, 0, 81, 178, 233, 142, 94, 215, 235, 192, 187, 249, 151, 77, 91, 114, 57, 28, 136, 100, 247, 76, 150, 82]), SecretKey([160, 154, 43, 12, 28, 180, 102, 85, 231, 104, 157, 43, 107, 55, 184, 80, 68, 27, 61, 221, 12, 48, 11, 129, 236, 44, 171, 106, 159, 0, 56, 73]), Seed([229, 156, 151, 200, 63, 26, 183, 155, 214, 110, 27, 219, 175, 107, 188, 204, 65, 239, 101, 82, 103, 171, 15, 238, 127, 152, 215, 181, 46, 246, 65, 241]));
/// MP: GDMP225FPLLGIRNIUJFP2QHAI3V6YCA3DT2HMBNQTMIO5EZPDH3EDIIA
static immutable MP = KeyPair(PublicKey([216, 253, 107, 165, 122, 214, 100, 69, 168, 162, 74, 253, 64, 224, 70, 235, 236, 8, 27, 28, 244, 118, 5, 176, 155, 16, 238, 147, 47, 25, 246, 65]), SecretKey([232, 129, 118, 161, 236, 177, 108, 233, 89, 235, 204, 121, 107, 166, 138, 91, 222, 200, 230, 21, 23, 211, 73, 4, 199, 216, 44, 121, 26, 130, 33, 92]), Seed([130, 25, 20, 87, 238, 84, 102, 205, 211, 115, 204, 93, 229, 240, 127, 233, 60, 70, 178, 150, 145, 87, 11, 157, 72, 19, 169, 244, 213, 170, 67, 168]));
/// MQ: GDMQ22YRJOQQS3UGGE43SDTS6I7F35DF442IVDS4RSUF4MJOPF3DNQDO
static immutable MQ = KeyPair(PublicKey([217, 13, 107, 17, 75, 161, 9, 110, 134, 49, 57, 185, 14, 114, 242, 62, 93, 244, 101, 231, 52, 138, 142, 92, 140, 168, 94, 49, 46, 121, 118, 54]), SecretKey([216, 31, 208, 0, 65, 225, 78, 212, 153, 192, 167, 141, 120, 206, 246, 188, 128, 166, 162, 163, 197, 194, 201, 111, 118, 60, 98, 216, 66, 250, 223, 119]), Seed([40, 209, 32, 91, 206, 132, 6, 180, 62, 4, 254, 228, 165, 250, 8, 190, 125, 234, 74, 34, 110, 71, 202, 24, 234, 241, 249, 237, 116, 241, 105, 176]));
/// MR: GDMR22F4O4GNVYTBNGBKLAK3ET25SHURBIVLHVTRDGMY5VVI3LPV4CUF
static immutable MR = KeyPair(PublicKey([217, 29, 104, 188, 119, 12, 218, 226, 97, 105, 130, 165, 129, 91, 36, 245, 217, 30, 145, 10, 42, 179, 214, 113, 25, 153, 142, 214, 168, 218, 223, 94]), SecretKey([64, 43, 231, 196, 78, 64, 113, 179, 248, 50, 31, 224, 77, 177, 164, 131, 173, 113, 227, 54, 124, 78, 237, 194, 249, 107, 252, 14, 55, 76, 7, 120]), Seed([94, 20, 224, 208, 175, 44, 196, 63, 113, 134, 82, 103, 153, 1, 86, 78, 98, 252, 22, 158, 100, 23, 87, 176, 215, 63, 227, 80, 129, 212, 170, 245]));
/// MS: GDMS22YAXJOT545SOSIN5ASLSAXKIDUHN7YMSRUAB7NB6QNCYLTQKQSK
static immutable MS = KeyPair(PublicKey([217, 45, 107, 0, 186, 93, 62, 243, 178, 116, 144, 222, 130, 75, 144, 46, 164, 14, 135, 111, 240, 201, 70, 128, 15, 218, 31, 65, 162, 194, 231, 5]), SecretKey([184, 227, 209, 61, 245, 60, 64, 49, 75, 77, 176, 4, 165, 97, 196, 245, 71, 132, 17, 138, 76, 47, 194, 181, 184, 60, 95, 38, 213, 33, 242, 108]), Seed([25, 12, 34, 146, 213, 39, 27, 248, 107, 18, 179, 154, 72, 212, 33, 131, 129, 138, 18, 226, 147, 50, 161, 73, 222, 227, 232, 49, 28, 143, 218, 122]));
/// MT: GDMT22RY3GWK5VP2N7QF7ULTQ2AS5OHIZQV5HKL5PFBIRGUC5MT27CUE
static immutable MT = KeyPair(PublicKey([217, 61, 106, 56, 217, 172, 174, 213, 250, 111, 224, 95, 209, 115, 134, 129, 46, 184, 232, 204, 43, 211, 169, 125, 121, 66, 136, 154, 130, 235, 39, 175]), SecretKey([144, 178, 88, 192, 139, 190, 175, 232, 109, 111, 84, 66, 131, 98, 61, 12, 218, 2, 49, 91, 15, 101, 10, 181, 216, 29, 138, 118, 10, 26, 30, 95]), Seed([55, 135, 154, 239, 170, 152, 0, 135, 22, 26, 45, 31, 184, 235, 238, 192, 183, 131, 163, 37, 195, 23, 131, 179, 153, 138, 3, 249, 82, 162, 6, 105]));
/// MU: GDMU22SCMIXRGW4Y7NK7BOJHB4ES3VFWLK7KFXC5Z3HSHNFFXGLEWD6I
static immutable MU = KeyPair(PublicKey([217, 77, 106, 66, 98, 47, 19, 91, 152, 251, 85, 240, 185, 39, 15, 9, 45, 212, 182, 90, 190, 162, 220, 93, 206, 207, 35, 180, 165, 185, 150, 75]), SecretKey([32, 60, 7, 152, 136, 153, 161, 168, 231, 158, 151, 33, 176, 15, 64, 115, 226, 50, 36, 67, 145, 26, 55, 44, 48, 70, 117, 49, 38, 222, 216, 115]), Seed([111, 126, 132, 218, 234, 36, 85, 252, 200, 82, 108, 156, 244, 205, 129, 118, 159, 210, 167, 95, 64, 192, 83, 93, 132, 136, 46, 31, 82, 35, 184, 151]));
/// MV: GDMV22ZPCUQWB7SLQNXRMW4XZ3RUUD6P5WMLACTZ6G7KOMSB3ZMCUMGN
static immutable MV = KeyPair(PublicKey([217, 93, 107, 47, 21, 33, 96, 254, 75, 131, 111, 22, 91, 151, 206, 227, 74, 15, 207, 237, 152, 176, 10, 121, 241, 190, 167, 50, 65, 222, 88, 42]), SecretKey([208, 135, 138, 19, 71, 137, 151, 52, 89, 120, 14, 92, 4, 152, 81, 78, 248, 109, 23, 19, 110, 117, 85, 251, 41, 23, 49, 197, 182, 113, 159, 121]), Seed([224, 60, 81, 150, 236, 165, 127, 186, 70, 60, 140, 216, 242, 146, 39, 89, 119, 206, 89, 210, 23, 160, 119, 113, 99, 6, 223, 124, 143, 137, 95, 24]));
/// MW: GDMW22LVW4KDMDFMCN4GN4FEFFSPMJTJ7H7PRUFQBNRKA4W4EHXCCEFU
static immutable MW = KeyPair(PublicKey([217, 109, 105, 117, 183, 20, 54, 12, 172, 19, 120, 102, 240, 164, 41, 100, 246, 38, 105, 249, 254, 248, 208, 176, 11, 98, 160, 114, 220, 33, 238, 33]), SecretKey([112, 81, 212, 66, 109, 243, 197, 128, 29, 254, 43, 82, 56, 186, 198, 71, 156, 19, 91, 157, 132, 172, 41, 218, 184, 178, 48, 130, 20, 202, 237, 85]), Seed([193, 121, 127, 204, 69, 53, 53, 112, 30, 92, 16, 69, 162, 24, 77, 91, 81, 75, 239, 161, 230, 74, 44, 245, 234, 149, 48, 65, 13, 74, 78, 41]));
/// MX: GDMX22AL3QGJT55FNSNAQDWBK3JGO5G3QYBHFCWZGI6CTHFWJCOYIPZF
static immutable MX = KeyPair(PublicKey([217, 125, 104, 11, 220, 12, 153, 247, 165, 108, 154, 8, 14, 193, 86, 210, 103, 116, 219, 134, 2, 114, 138, 217, 50, 60, 41, 156, 182, 72, 157, 132]), SecretKey([136, 109, 229, 134, 1, 87, 239, 216, 173, 134, 50, 18, 152, 183, 108, 249, 115, 209, 15, 98, 228, 83, 38, 108, 221, 134, 242, 223, 151, 83, 62, 85]), Seed([93, 24, 225, 130, 124, 13, 109, 143, 54, 203, 101, 207, 143, 217, 178, 229, 135, 83, 194, 176, 212, 201, 200, 220, 190, 217, 114, 151, 91, 97, 181, 74]));
/// MY: GDMY22XQ7UECVQBWTY7SIDTEFK4CGPCKLRQPCWS47XS3NPXKVPYVR7GX
static immutable MY = KeyPair(PublicKey([217, 141, 106, 240, 253, 8, 42, 192, 54, 158, 63, 36, 14, 100, 42, 184, 35, 60, 74, 92, 96, 241, 90, 92, 253, 229, 182, 190, 234, 171, 241, 88]), SecretKey([176, 147, 211, 93, 79, 185, 104, 20, 217, 211, 38, 81, 138, 21, 186, 245, 175, 154, 105, 246, 183, 197, 122, 112, 72, 87, 207, 132, 101, 180, 242, 82]), Seed([203, 208, 197, 106, 84, 202, 199, 114, 91, 212, 215, 53, 170, 110, 135, 200, 250, 20, 222, 138, 115, 132, 168, 219, 229, 91, 54, 183, 126, 39, 38, 167]));
/// MZ: GDMZ2253Q62MV5CWQ6EIVDZYFNI3BGWFIOHCUDNW5SK643JFNIA7T7O3
static immutable MZ = KeyPair(PublicKey([217, 157, 107, 187, 135, 180, 202, 244, 86, 135, 136, 138, 143, 56, 43, 81, 176, 154, 197, 67, 142, 42, 13, 182, 236, 149, 238, 109, 37, 106, 1, 249]), SecretKey([24, 57, 156, 54, 192, 22, 164, 26, 28, 191, 73, 135, 173, 220, 113, 227, 122, 241, 174, 203, 166, 139, 43, 14, 2, 199, 209, 128, 26, 13, 183, 93]), Seed([94, 169, 134, 180, 172, 129, 195, 154, 155, 91, 70, 76, 38, 199, 157, 196, 180, 109, 132, 158, 153, 18, 133, 111, 202, 99, 107, 97, 100, 174, 120, 74]));
/// NA: GDNA22QDAJRNNPD7BEJG4INCI2HOBUOVNQJLRBMNXHEDBXH6JQCQPWSW
static immutable NA = KeyPair(PublicKey([218, 13, 106, 3, 2, 98, 214, 188, 127, 9, 18, 110, 33, 162, 70, 142, 224, 209, 213, 108, 18, 184, 133, 141, 185, 200, 48, 220, 254, 76, 5, 7]), SecretKey([56, 177, 190, 199, 195, 201, 186, 158, 226, 72, 153, 102, 64, 71, 230, 12, 91, 53, 145, 176, 63, 59, 128, 207, 67, 73, 242, 24, 164, 186, 95, 77]), Seed([59, 74, 39, 188, 112, 234, 199, 72, 88, 181, 16, 158, 217, 150, 28, 195, 92, 11, 180, 236, 119, 196, 32, 58, 225, 214, 115, 43, 130, 71, 192, 203]));
/// NB: GDNB22W7MUI36RFJFGBK6VDYQ23XOMPJYWE53LB6UZH4AYV6RUN76RC4
static immutable NB = KeyPair(PublicKey([218, 29, 106, 223, 101, 17, 191, 68, 169, 41, 130, 175, 84, 120, 134, 183, 119, 49, 233, 197, 137, 221, 172, 62, 166, 79, 192, 98, 190, 141, 27, 255]), SecretKey([40, 30, 212, 162, 131, 122, 203, 172, 228, 229, 46, 36, 121, 95, 106, 180, 224, 253, 124, 216, 48, 38, 56, 39, 178, 239, 145, 71, 6, 125, 94, 96]), Seed([162, 37, 26, 115, 215, 139, 239, 141, 209, 85, 170, 124, 165, 30, 130, 185, 99, 51, 94, 167, 47, 113, 180, 6, 139, 46, 42, 216, 166, 245, 180, 36]));
/// NC: GDNC22KXQGDKH6EO2UIOWNCYOPMO6XZX7T6P4TH6XZ4UYSR6JOBGY5U6
static immutable NC = KeyPair(PublicKey([218, 45, 105, 87, 129, 134, 163, 248, 142, 213, 16, 235, 52, 88, 115, 216, 239, 95, 55, 252, 252, 254, 76, 254, 190, 121, 76, 74, 62, 75, 130, 108]), SecretKey([80, 6, 237, 45, 236, 72, 20, 30, 180, 141, 67, 152, 96, 185, 143, 34, 42, 110, 229, 226, 89, 197, 187, 166, 253, 29, 113, 42, 222, 185, 137, 101]), Seed([129, 192, 112, 219, 112, 253, 94, 57, 153, 248, 15, 254, 154, 124, 135, 99, 207, 1, 248, 37, 244, 114, 118, 92, 70, 114, 161, 214, 205, 61, 75, 85]));
/// ND: GDND22TGPJA7IKVXIFNEL2RQQ63OSBMCSVDAXNO3FNJELUTXF2XVQLPM
static immutable ND = KeyPair(PublicKey([218, 61, 106, 102, 122, 65, 244, 42, 183, 65, 90, 69, 234, 48, 135, 182, 233, 5, 130, 149, 70, 11, 181, 219, 43, 82, 69, 210, 119, 46, 175, 88]), SecretKey([72, 105, 217, 70, 220, 98, 131, 143, 117, 38, 11, 25, 191, 88, 180, 213, 31, 198, 193, 249, 117, 202, 190, 41, 186, 193, 202, 154, 212, 211, 106, 119]), Seed([51, 73, 166, 112, 45, 228, 96, 95, 132, 48, 199, 26, 44, 38, 10, 49, 55, 161, 182, 142, 180, 143, 72, 122, 55, 73, 226, 122, 100, 73, 204, 235]));
/// NE: GDNE22WJMKOYYNCW3HEOJ3M4XSEJG36F2FEVIMZ2C342OFUZ6GZSOYYN
static immutable NE = KeyPair(PublicKey([218, 77, 106, 201, 98, 157, 140, 52, 86, 217, 200, 228, 237, 156, 188, 136, 147, 111, 197, 209, 73, 84, 51, 58, 22, 249, 167, 22, 153, 241, 179, 39]), SecretKey([136, 104, 68, 71, 145, 249, 98, 182, 30, 78, 196, 122, 89, 227, 15, 119, 48, 88, 171, 141, 146, 68, 79, 4, 235, 69, 228, 159, 84, 56, 97, 115]), Seed([81, 27, 29, 164, 234, 101, 131, 236, 241, 86, 42, 253, 232, 173, 129, 74, 23, 96, 197, 239, 126, 150, 95, 66, 25, 57, 34, 248, 82, 227, 76, 41]));
/// NF: GDNF22WLWQCGVBGBRIUP22XBO4373HSE7TDOZB5AQBRWIANQWJDBFCQQ
static immutable NF = KeyPair(PublicKey([218, 93, 106, 203, 180, 4, 106, 132, 193, 138, 40, 253, 106, 225, 119, 55, 253, 158, 68, 252, 198, 236, 135, 160, 128, 99, 100, 1, 176, 178, 70, 18]), SecretKey([56, 33, 233, 218, 169, 120, 151, 154, 82, 126, 226, 232, 9, 34, 105, 13, 148, 139, 125, 106, 219, 98, 146, 65, 63, 218, 227, 212, 78, 84, 22, 81]), Seed([24, 10, 80, 184, 185, 149, 131, 1, 121, 31, 98, 244, 179, 211, 117, 161, 201, 149, 90, 233, 175, 195, 176, 18, 107, 4, 159, 50, 186, 196, 70, 44]));
/// NG: GDNG2244V7D3LKPSGCDPP3QGL57RYRA4EVFBR66HWDXTFBUTKRAQTFKZ
static immutable NG = KeyPair(PublicKey([218, 109, 107, 156, 175, 199, 181, 169, 242, 48, 134, 247, 238, 6, 95, 127, 28, 68, 28, 37, 74, 24, 251, 199, 176, 239, 50, 134, 147, 84, 65, 9]), SecretKey([232, 16, 135, 169, 227, 48, 201, 34, 205, 92, 7, 106, 168, 203, 6, 254, 197, 62, 139, 99, 89, 104, 75, 220, 79, 91, 96, 35, 195, 7, 38, 98]), Seed([149, 137, 124, 60, 117, 135, 141, 82, 172, 213, 250, 81, 134, 24, 221, 65, 174, 213, 72, 165, 136, 112, 127, 189, 166, 183, 145, 2, 246, 40, 25, 33]));
/// NH: GDNH22OUMP6OEDXYZR6RLHSQISS7YG4ILP7GX6JBYEXH7AQEJA33IWSB
static immutable NH = KeyPair(PublicKey([218, 125, 105, 212, 99, 252, 226, 14, 248, 204, 125, 21, 158, 80, 68, 165, 252, 27, 136, 91, 254, 107, 249, 33, 193, 46, 127, 130, 4, 72, 55, 180]), SecretKey([144, 123, 37, 121, 128, 50, 105, 21, 133, 219, 48, 179, 65, 193, 184, 56, 164, 62, 139, 224, 125, 12, 135, 243, 99, 188, 193, 118, 115, 244, 100, 75]), Seed([119, 136, 85, 247, 191, 136, 74, 90, 253, 180, 117, 81, 110, 216, 18, 75, 14, 134, 206, 136, 253, 115, 128, 238, 246, 230, 198, 254, 89, 172, 224, 110]));
/// NI: GDNI22VDN7AUMU3P5TVJOMXSO52EM6FQ5Q2VA52YBELRHIF3NZD622SV
static immutable NI = KeyPair(PublicKey([218, 141, 106, 163, 111, 193, 70, 83, 111, 236, 234, 151, 50, 242, 119, 116, 70, 120, 176, 236, 53, 80, 119, 88, 9, 23, 19, 160, 187, 110, 71, 237]), SecretKey([16, 117, 44, 77, 57, 159, 94, 101, 130, 227, 195, 65, 12, 51, 6, 222, 191, 12, 231, 235, 7, 54, 58, 223, 208, 227, 94, 84, 87, 149, 55, 118]), Seed([235, 96, 141, 148, 56, 235, 30, 235, 229, 115, 90, 4, 250, 70, 207, 111, 251, 219, 233, 133, 240, 230, 43, 119, 237, 179, 29, 131, 91, 158, 115, 113]));
/// NJ: GDNJ22VT4G62L5GL7EVGZFOME4QHMYKUX57JCXGHNGSHZJDUC2RJV7QC
static immutable NJ = KeyPair(PublicKey([218, 157, 106, 179, 225, 189, 165, 244, 203, 249, 42, 108, 149, 204, 39, 32, 118, 97, 84, 191, 126, 145, 92, 199, 105, 164, 124, 164, 116, 22, 162, 154]), SecretKey([128, 207, 1, 100, 113, 199, 123, 196, 32, 49, 202, 137, 142, 109, 93, 189, 252, 233, 41, 52, 193, 74, 61, 143, 118, 191, 235, 8, 13, 3, 19, 124]), Seed([253, 151, 116, 252, 22, 49, 141, 201, 190, 255, 54, 1, 40, 251, 142, 126, 174, 207, 178, 160, 44, 241, 75, 30, 236, 52, 11, 199, 231, 252, 150, 198]));
/// NK: GDNK22ESIAXXKTJQGJICF3HQMVA67H4ZBB3VKJASVZA3FXV4UYS5LMKD
static immutable NK = KeyPair(PublicKey([218, 173, 104, 146, 64, 47, 117, 77, 48, 50, 80, 34, 236, 240, 101, 65, 239, 159, 153, 8, 119, 85, 36, 18, 174, 65, 178, 222, 188, 166, 37, 213]), SecretKey([64, 20, 152, 19, 170, 31, 186, 191, 49, 8, 208, 116, 116, 21, 165, 143, 73, 61, 206, 150, 145, 169, 199, 15, 209, 142, 27, 227, 236, 186, 124, 125]), Seed([199, 30, 90, 147, 168, 55, 103, 140, 102, 70, 66, 165, 114, 28, 171, 98, 100, 231, 167, 140, 61, 142, 120, 247, 217, 74, 78, 167, 198, 255, 90, 105]));
/// NL: GDNL22GA6TO3ZQVYIIPTNQAMSBNJV4ZBIMRRHMQZP2DLDGEDLYDK62DH
static immutable NL = KeyPair(PublicKey([218, 189, 104, 192, 244, 221, 188, 194, 184, 66, 31, 54, 192, 12, 144, 90, 154, 243, 33, 67, 35, 19, 178, 25, 126, 134, 177, 152, 131, 94, 6, 175]), SecretKey([24, 6, 48, 243, 203, 15, 32, 239, 134, 187, 245, 23, 164, 145, 214, 106, 203, 211, 238, 240, 79, 162, 156, 9, 91, 39, 188, 162, 254, 227, 247, 67]), Seed([229, 181, 160, 85, 4, 4, 88, 255, 152, 20, 223, 160, 153, 180, 255, 45, 121, 5, 227, 174, 156, 89, 241, 71, 94, 224, 184, 111, 93, 180, 76, 117]));
/// NM: GDNM2257Q6MTH6MS6DVEKODRKYCY5QTZC3CHPKBY2NAP53HETYSMLU4N
static immutable NM = KeyPair(PublicKey([218, 205, 107, 191, 135, 153, 51, 249, 146, 240, 234, 69, 56, 113, 86, 5, 142, 194, 121, 22, 196, 119, 168, 56, 211, 64, 254, 236, 228, 158, 36, 197]), SecretKey([240, 74, 216, 128, 41, 63, 211, 130, 4, 197, 155, 250, 107, 181, 150, 158, 240, 193, 153, 50, 32, 150, 240, 86, 7, 87, 70, 224, 24, 132, 98, 118]), Seed([68, 139, 121, 132, 242, 128, 115, 205, 104, 171, 86, 119, 138, 181, 243, 98, 217, 217, 231, 150, 3, 63, 235, 217, 253, 178, 38, 110, 141, 198, 197, 118]));
/// NN: GDNN22SUKRN4FYLJCRQNICYNSHWRHO3QWPSHCHRDKD3RBIVG5JE7SHE4
static immutable NN = KeyPair(PublicKey([218, 221, 106, 84, 84, 91, 194, 225, 105, 20, 96, 212, 11, 13, 145, 237, 19, 187, 112, 179, 228, 113, 30, 35, 80, 247, 16, 162, 166, 234, 73, 249]), SecretKey([104, 45, 171, 56, 204, 217, 130, 152, 61, 253, 53, 232, 17, 86, 114, 145, 165, 86, 111, 186, 29, 140, 105, 235, 50, 228, 100, 15, 126, 198, 36, 107]), Seed([66, 236, 105, 142, 87, 174, 246, 129, 246, 195, 74, 36, 201, 2, 217, 194, 41, 118, 208, 122, 140, 42, 24, 144, 240, 197, 224, 93, 94, 78, 155, 61]));
/// NO: GDNO22KBS7V2TMZVN4J6WNGEMIRJX3LFS36YDSMUJNIJJYIRCUKVQEJI
static immutable NO = KeyPair(PublicKey([218, 237, 105, 65, 151, 235, 169, 179, 53, 111, 19, 235, 52, 196, 98, 34, 155, 237, 101, 150, 253, 129, 201, 148, 75, 80, 148, 225, 17, 21, 21, 88]), SecretKey([120, 110, 62, 227, 144, 9, 202, 130, 214, 217, 13, 106, 116, 140, 116, 115, 227, 24, 190, 163, 193, 156, 50, 109, 222, 190, 245, 190, 204, 234, 210, 77]), Seed([232, 232, 218, 116, 88, 131, 226, 191, 79, 61, 59, 40, 127, 173, 86, 107, 141, 206, 141, 27, 34, 157, 118, 128, 32, 239, 192, 254, 190, 183, 230, 228]));
/// NP: GDNP22YNQP2APJXWKY2KGZ2REL2JHNRFI47K2TJGU7OEHE222LM3MUR2
static immutable NP = KeyPair(PublicKey([218, 253, 107, 13, 131, 244, 7, 166, 246, 86, 52, 163, 103, 81, 34, 244, 147, 182, 37, 71, 62, 173, 77, 38, 167, 220, 67, 147, 90, 210, 217, 182]), SecretKey([8, 255, 118, 92, 61, 79, 164, 7, 174, 212, 128, 135, 91, 110, 17, 211, 129, 217, 25, 213, 19, 38, 35, 166, 114, 60, 242, 169, 118, 187, 101, 113]), Seed([42, 181, 119, 137, 186, 234, 185, 42, 242, 187, 53, 112, 96, 93, 203, 88, 97, 123, 136, 39, 202, 17, 42, 14, 87, 102, 79, 181, 162, 60, 192, 43]));
/// NQ: GDNQ22WRBRT4XCEI5LHHDXYX3PBACRR5ZEG7C5AIB5O2K57EBHHU6CJ5
static immutable NQ = KeyPair(PublicKey([219, 13, 106, 209, 12, 103, 203, 136, 136, 234, 206, 113, 223, 23, 219, 194, 1, 70, 61, 201, 13, 241, 116, 8, 15, 93, 165, 119, 228, 9, 207, 79]), SecretKey([56, 166, 25, 37, 51, 93, 8, 95, 16, 36, 115, 148, 2, 102, 98, 175, 64, 177, 29, 124, 19, 208, 40, 244, 202, 145, 137, 116, 198, 176, 5, 107]), Seed([80, 134, 14, 216, 40, 41, 106, 130, 30, 11, 122, 122, 97, 163, 27, 3, 32, 33, 183, 241, 43, 154, 137, 4, 197, 160, 160, 22, 100, 131, 240, 63]));
/// NR: GDNR22JQKCBWKS7TWRHGDJ7FBXRYKV2EH3SL22FTMR2GCUAJ33OALLNE
static immutable NR = KeyPair(PublicKey([219, 29, 105, 48, 80, 131, 101, 75, 243, 180, 78, 97, 167, 229, 13, 227, 133, 87, 68, 62, 228, 189, 104, 179, 100, 116, 97, 80, 9, 222, 220, 5]), SecretKey([128, 52, 89, 110, 132, 78, 204, 44, 77, 49, 15, 28, 80, 37, 251, 172, 119, 34, 176, 209, 98, 22, 137, 226, 248, 239, 8, 160, 98, 192, 246, 77]), Seed([45, 113, 22, 24, 137, 207, 81, 14, 144, 50, 82, 113, 76, 32, 112, 49, 33, 70, 208, 88, 68, 202, 234, 133, 155, 206, 54, 16, 169, 167, 44, 176]));
/// NS: GDNS222MPIW4DKFLRSCVM4RAIMRM4FVOEHBT3NS7B3IKAEBSNIIE7IBA
static immutable NS = KeyPair(PublicKey([219, 45, 107, 76, 122, 45, 193, 168, 171, 140, 133, 86, 114, 32, 67, 34, 206, 22, 174, 33, 195, 61, 182, 95, 14, 208, 160, 16, 50, 106, 16, 79]), SecretKey([152, 24, 128, 170, 171, 240, 10, 91, 112, 61, 106, 34, 156, 222, 169, 36, 58, 230, 77, 67, 35, 234, 157, 97, 44, 239, 62, 183, 205, 240, 192, 65]), Seed([251, 7, 172, 163, 187, 201, 81, 146, 186, 110, 150, 90, 117, 70, 201, 75, 246, 138, 117, 108, 83, 120, 107, 174, 15, 5, 196, 44, 59, 16, 56, 136]));
/// NT: GDNT2226B3XEVFXN52KIVUZQXPEG6O3OKQCMWAY7ZSQ7ZA62JDOARXAC
static immutable NT = KeyPair(PublicKey([219, 61, 107, 94, 14, 238, 74, 150, 237, 238, 148, 138, 211, 48, 187, 200, 111, 59, 110, 84, 4, 203, 3, 31, 204, 161, 252, 131, 218, 72, 220, 8]), SecretKey([0, 239, 232, 163, 223, 172, 118, 19, 46, 21, 48, 62, 1, 59, 103, 239, 255, 98, 144, 142, 107, 137, 84, 21, 77, 44, 29, 196, 6, 47, 233, 127]), Seed([168, 77, 111, 78, 49, 192, 113, 240, 108, 114, 147, 220, 122, 140, 4, 86, 4, 144, 228, 142, 185, 174, 35, 248, 198, 17, 123, 231, 233, 56, 64, 123]));
/// NU: GDNU22MTHLPRDOJHKSO5QNN3B6ZFI27TUAFHURM4WS5YUPIEVTXX2S6P
static immutable NU = KeyPair(PublicKey([219, 77, 105, 147, 58, 223, 17, 185, 39, 84, 157, 216, 53, 187, 15, 178, 84, 107, 243, 160, 10, 122, 69, 156, 180, 187, 138, 61, 4, 172, 239, 125]), SecretKey([192, 249, 16, 200, 86, 232, 146, 19, 169, 199, 169, 3, 254, 66, 250, 90, 106, 64, 70, 187, 83, 126, 165, 49, 164, 142, 119, 177, 15, 166, 149, 102]), Seed([12, 94, 67, 189, 15, 247, 3, 118, 147, 253, 157, 74, 145, 157, 157, 172, 18, 252, 137, 88, 173, 47, 251, 22, 157, 213, 234, 132, 170, 11, 8, 125]));
/// NV: GDNV227UXVYIF5WOPPP6KI4JNWFIHCO2TF3GBOZFCCTG36D3IAZJGLQE
static immutable NV = KeyPair(PublicKey([219, 93, 107, 244, 189, 112, 130, 246, 206, 123, 223, 229, 35, 137, 109, 138, 131, 137, 218, 153, 118, 96, 187, 37, 16, 166, 109, 248, 123, 64, 50, 147]), SecretKey([152, 252, 200, 142, 96, 246, 5, 88, 92, 86, 198, 33, 28, 78, 110, 117, 29, 50, 128, 220, 90, 230, 14, 255, 241, 167, 93, 184, 119, 77, 163, 125]), Seed([18, 19, 190, 48, 233, 54, 35, 74, 219, 100, 153, 125, 87, 85, 239, 20, 250, 82, 139, 77, 175, 189, 121, 122, 227, 71, 179, 165, 86, 232, 52, 5]));
/// NW: GDNW22IUBVNGJZNKRVCHZBW7GS2YA6VKSSIDL2GKRZHWKFYJJMVCT7J7
static immutable NW = KeyPair(PublicKey([219, 109, 105, 20, 13, 90, 100, 229, 170, 141, 68, 124, 134, 223, 52, 181, 128, 122, 170, 148, 144, 53, 232, 202, 142, 79, 101, 23, 9, 75, 42, 41]), SecretKey([56, 217, 39, 156, 138, 130, 237, 111, 104, 208, 58, 42, 178, 60, 197, 118, 4, 116, 129, 152, 163, 14, 163, 15, 181, 80, 203, 236, 238, 91, 129, 68]), Seed([236, 36, 152, 158, 106, 70, 118, 80, 102, 150, 137, 227, 3, 114, 0, 202, 12, 230, 28, 183, 87, 47, 9, 214, 10, 14, 219, 216, 4, 190, 31, 152]));
/// NX: GDNX22YZNTXFUVWRIZ6O2N5FXNCFQNBRNTBRXG7MHIA7XEDADAHMPIOT
static immutable NX = KeyPair(PublicKey([219, 125, 107, 25, 108, 238, 90, 86, 209, 70, 124, 237, 55, 165, 187, 68, 88, 52, 49, 108, 195, 27, 155, 236, 58, 1, 251, 144, 96, 24, 14, 199]), SecretKey([192, 205, 74, 222, 137, 41, 73, 192, 126, 139, 46, 212, 193, 234, 184, 227, 88, 157, 229, 170, 179, 125, 4, 110, 211, 21, 81, 29, 77, 123, 214, 66]), Seed([123, 161, 76, 9, 113, 253, 133, 7, 168, 84, 187, 111, 17, 171, 88, 27, 179, 11, 192, 90, 192, 255, 106, 34, 108, 31, 228, 115, 220, 64, 104, 238]));
/// NY: GDNY22ZIS2DV25UDHLRQYJ2GV3SBAAA4SI6QSZSVETRFQSB22UBOACSY
static immutable NY = KeyPair(PublicKey([219, 141, 107, 40, 150, 135, 93, 118, 131, 58, 227, 12, 39, 70, 174, 228, 16, 0, 28, 146, 61, 9, 102, 85, 36, 226, 88, 72, 58, 213, 2, 224]), SecretKey([136, 69, 193, 22, 36, 236, 46, 60, 212, 114, 84, 214, 52, 198, 95, 4, 56, 174, 80, 123, 238, 218, 234, 114, 97, 4, 225, 67, 249, 178, 159, 83]), Seed([60, 156, 8, 68, 58, 196, 88, 9, 237, 145, 24, 148, 75, 172, 23, 96, 62, 188, 107, 22, 24, 132, 30, 29, 39, 230, 20, 41, 114, 168, 45, 248]));
/// NZ: GDNZ22DKPWQ4FHYY64JZEOLYXFBSYWNB6UWT74AF4YY5WSZ4P4TWLCPJ
static immutable NZ = KeyPair(PublicKey([219, 157, 104, 106, 125, 161, 194, 159, 24, 247, 19, 146, 57, 120, 185, 67, 44, 89, 161, 245, 45, 63, 240, 5, 230, 49, 219, 75, 60, 127, 39, 101]), SecretKey([32, 37, 192, 125, 26, 93, 34, 68, 222, 221, 139, 229, 43, 25, 191, 188, 136, 236, 88, 219, 119, 111, 229, 88, 57, 22, 133, 59, 208, 42, 225, 103]), Seed([160, 38, 17, 100, 97, 165, 161, 102, 212, 59, 180, 81, 205, 235, 223, 21, 240, 190, 147, 136, 43, 13, 173, 59, 114, 229, 181, 200, 50, 145, 103, 153]));
/// OA: GDOA22VR6OXFN6YNPHP7GLGEUKRKT7Y2ECGSKDRJDFHVZUXZCEUE5O2O
static immutable OA = KeyPair(PublicKey([220, 13, 106, 177, 243, 174, 86, 251, 13, 121, 223, 243, 44, 196, 162, 162, 169, 255, 26, 32, 141, 37, 14, 41, 25, 79, 92, 210, 249, 17, 40, 78]), SecretKey([176, 249, 29, 54, 7, 79, 205, 26, 147, 214, 103, 57, 186, 40, 39, 46, 207, 116, 175, 35, 130, 53, 56, 169, 204, 178, 196, 10, 145, 142, 81, 115]), Seed([152, 208, 80, 119, 169, 142, 47, 109, 138, 41, 142, 182, 56, 131, 211, 254, 41, 235, 201, 106, 243, 24, 110, 97, 35, 235, 168, 13, 230, 13, 100, 70]));
/// OB: GDOB22GVJPETVJO6TNAYLZLAACRFFYDETL52ZPA27XAOOSBVHEER7KC2
static immutable OB = KeyPair(PublicKey([220, 29, 104, 213, 75, 201, 58, 165, 222, 155, 65, 133, 229, 96, 0, 162, 82, 224, 100, 154, 251, 172, 188, 26, 253, 192, 231, 72, 53, 57, 9, 31]), SecretKey([24, 96, 240, 25, 174, 198, 41, 26, 18, 0, 239, 40, 79, 176, 91, 23, 131, 88, 11, 50, 225, 57, 71, 249, 103, 205, 15, 43, 198, 206, 38, 108]), Seed([10, 2, 234, 241, 166, 32, 81, 205, 150, 49, 32, 103, 2, 80, 164, 204, 49, 65, 112, 224, 193, 214, 49, 209, 24, 57, 135, 183, 210, 121, 205, 2]));
/// OC: GDOC22VNQG2EN7PLJDENN6JFHOJISBLHU4HZCRBLZSPKJWDJKL4F3HQ2
static immutable OC = KeyPair(PublicKey([220, 45, 106, 173, 129, 180, 70, 253, 235, 72, 200, 214, 249, 37, 59, 146, 137, 5, 103, 167, 15, 145, 68, 43, 204, 158, 164, 216, 105, 82, 248, 93]), SecretKey([104, 58, 231, 24, 161, 37, 143, 172, 62, 106, 41, 103, 230, 73, 167, 122, 43, 147, 132, 64, 206, 47, 53, 86, 154, 42, 214, 86, 186, 194, 152, 88]), Seed([218, 77, 191, 135, 197, 14, 213, 97, 94, 215, 42, 102, 170, 224, 163, 243, 0, 36, 248, 60, 219, 208, 78, 60, 233, 0, 96, 108, 172, 144, 22, 189]));
/// OD: GDOD22LRDBIHXEIEQADPBIG5LEZ53MCCJRMTOZJLM5EQLLG7JIFB55FH
static immutable OD = KeyPair(PublicKey([220, 61, 105, 113, 24, 80, 123, 145, 4, 128, 6, 240, 160, 221, 89, 51, 221, 176, 66, 76, 89, 55, 101, 43, 103, 73, 5, 172, 223, 74, 10, 30]), SecretKey([96, 177, 119, 10, 218, 184, 100, 36, 228, 121, 253, 210, 207, 123, 231, 85, 187, 206, 56, 78, 163, 145, 58, 248, 112, 122, 237, 52, 88, 146, 197, 104]), Seed([216, 83, 149, 26, 40, 56, 33, 112, 70, 73, 116, 120, 127, 48, 56, 200, 237, 51, 144, 135, 183, 157, 12, 39, 1, 253, 83, 147, 163, 233, 174, 166]));
/// OE: GDOE226V33EKB4XP57PKOSPPRQNVADJCMVGBA4LS6NU4LMCGTGG6PAHP
static immutable OE = KeyPair(PublicKey([220, 77, 107, 213, 222, 200, 160, 242, 239, 239, 222, 167, 73, 239, 140, 27, 80, 13, 34, 101, 76, 16, 113, 114, 243, 105, 197, 176, 70, 153, 141, 231]), SecretKey([24, 34, 71, 81, 54, 249, 163, 24, 162, 112, 162, 166, 196, 161, 39, 92, 52, 142, 240, 228, 229, 176, 106, 149, 126, 100, 20, 156, 169, 50, 160, 122]), Seed([115, 217, 49, 121, 112, 250, 60, 214, 232, 25, 242, 207, 43, 210, 99, 16, 4, 237, 74, 90, 119, 35, 164, 191, 12, 125, 137, 141, 35, 216, 161, 248]));
/// OF: GDOF22UGZZEDV4FOMFVUPEIWZV4WKZUWRVYBE45VV5MBYPHEKXLAHHJW
static immutable OF = KeyPair(PublicKey([220, 93, 106, 134, 206, 72, 58, 240, 174, 97, 107, 71, 145, 22, 205, 121, 101, 102, 150, 141, 112, 18, 115, 181, 175, 88, 28, 60, 228, 85, 214, 3]), SecretKey([72, 134, 24, 135, 37, 205, 152, 98, 209, 1, 75, 211, 187, 95, 26, 202, 0, 16, 92, 4, 78, 234, 59, 101, 241, 160, 157, 39, 232, 73, 10, 82]), Seed([25, 130, 47, 236, 123, 149, 217, 12, 104, 252, 59, 90, 87, 96, 123, 39, 188, 33, 156, 173, 108, 138, 98, 202, 251, 197, 193, 65, 98, 2, 90, 141]));
/// OG: GDOG22L23G7XJO27N47DGSA7POSSUI7OCSB4JMZGDNVYAOHXIF6V56E3
static immutable OG = KeyPair(PublicKey([220, 109, 105, 122, 217, 191, 116, 187, 95, 111, 62, 51, 72, 31, 123, 165, 42, 35, 238, 20, 131, 196, 179, 38, 27, 107, 128, 56, 247, 65, 125, 94]), SecretKey([80, 207, 135, 103, 108, 247, 71, 50, 163, 197, 128, 193, 151, 169, 161, 154, 62, 240, 229, 138, 224, 191, 34, 253, 43, 63, 11, 101, 188, 108, 13, 119]), Seed([48, 89, 207, 241, 71, 123, 42, 79, 113, 225, 14, 43, 126, 216, 20, 5, 175, 212, 147, 139, 47, 236, 206, 77, 19, 196, 218, 189, 5, 172, 87, 20]));
/// OH: GDOH22YHYU3GGBCAAFGORJQPEUYG52OD3HQKTTYS34JZBBLKBKLRQJQ7
static immutable OH = KeyPair(PublicKey([220, 125, 107, 7, 197, 54, 99, 4, 64, 1, 76, 232, 166, 15, 37, 48, 110, 233, 195, 217, 224, 169, 207, 18, 223, 19, 144, 133, 106, 10, 151, 24]), SecretKey([96, 133, 63, 195, 57, 154, 65, 236, 8, 59, 222, 99, 34, 177, 67, 14, 178, 123, 85, 232, 150, 144, 221, 180, 57, 148, 252, 133, 223, 201, 6, 93]), Seed([15, 52, 3, 65, 153, 78, 126, 249, 104, 246, 22, 31, 167, 151, 82, 196, 187, 217, 209, 220, 228, 224, 82, 123, 2, 253, 11, 63, 193, 67, 5, 26]));
/// OI: GDOI22B57HS3P4K5WP7VK7VULPJPWKFOABAHYDB6BCMB4ZVT5LJSI6TW
static immutable OI = KeyPair(PublicKey([220, 141, 104, 61, 249, 229, 183, 241, 93, 179, 255, 85, 126, 180, 91, 210, 251, 40, 174, 0, 64, 124, 12, 62, 8, 152, 30, 102, 179, 234, 211, 36]), SecretKey([232, 100, 205, 93, 163, 168, 173, 108, 173, 229, 71, 202, 184, 54, 99, 134, 5, 85, 0, 114, 108, 120, 180, 2, 97, 194, 126, 139, 252, 139, 150, 94]), Seed([239, 43, 175, 67, 118, 28, 244, 147, 137, 148, 68, 162, 185, 106, 224, 108, 87, 103, 157, 139, 27, 152, 88, 114, 44, 210, 105, 13, 157, 150, 180, 14]));
/// OJ: GDOJ22AJQ5TGWFAZ5S5AEX3SCDFEUJSMF5C7Z2WM7OLZ2BUARFH3E7TW
static immutable OJ = KeyPair(PublicKey([220, 157, 104, 9, 135, 102, 107, 20, 25, 236, 186, 2, 95, 114, 16, 202, 74, 38, 76, 47, 69, 252, 234, 204, 251, 151, 157, 6, 128, 137, 79, 178]), SecretKey([120, 38, 14, 62, 40, 16, 34, 189, 134, 223, 230, 5, 99, 88, 161, 96, 78, 150, 189, 178, 55, 251, 98, 110, 145, 126, 173, 135, 227, 46, 21, 75]), Seed([52, 25, 167, 104, 161, 246, 251, 56, 16, 106, 5, 18, 39, 41, 1, 21, 113, 31, 204, 18, 39, 44, 133, 180, 119, 161, 174, 160, 3, 23, 77, 106]));
/// OK: GDOK22LAZJBZ3UA5ZE6TSHPHHHHL4DUYZHZQYIJHBS4ZYYT5YPQ3Q5YT
static immutable OK = KeyPair(PublicKey([220, 173, 105, 96, 202, 67, 157, 208, 29, 201, 61, 57, 29, 231, 57, 206, 190, 14, 152, 201, 243, 12, 33, 39, 12, 185, 156, 98, 125, 195, 225, 184]), SecretKey([216, 223, 188, 227, 249, 239, 185, 139, 182, 123, 114, 57, 136, 209, 58, 180, 153, 82, 188, 104, 203, 65, 245, 170, 202, 232, 119, 241, 26, 173, 161, 99]), Seed([206, 48, 22, 231, 6, 102, 217, 236, 108, 19, 251, 218, 25, 228, 233, 247, 104, 199, 43, 78, 234, 227, 83, 252, 149, 245, 65, 248, 48, 145, 250, 197]));
/// OL: GDOL225BYWTWOU4J772Y7EVVRT4BRR5WADUQB5DJRFXFXHVKB2V57WQ2
static immutable OL = KeyPair(PublicKey([220, 189, 107, 161, 197, 167, 103, 83, 137, 255, 245, 143, 146, 181, 140, 248, 24, 199, 182, 0, 233, 0, 244, 105, 137, 110, 91, 158, 170, 14, 171, 223]), SecretKey([16, 216, 242, 133, 236, 43, 108, 79, 164, 48, 136, 73, 147, 8, 19, 47, 132, 208, 239, 119, 176, 207, 199, 189, 69, 16, 184, 171, 133, 239, 152, 110]), Seed([206, 246, 23, 165, 71, 138, 4, 56, 188, 141, 211, 63, 209, 76, 41, 178, 63, 46, 24, 94, 93, 132, 33, 41, 97, 144, 215, 40, 37, 69, 2, 21]));
/// OM: GDOM22KNG357QGUEJO5BD7KLLC5UCC45R2IL73ZPTJJ6QV3KZZLDPLYG
static immutable OM = KeyPair(PublicKey([220, 205, 105, 77, 54, 251, 248, 26, 132, 75, 186, 17, 253, 75, 88, 187, 65, 11, 157, 142, 144, 191, 239, 47, 154, 83, 232, 87, 106, 206, 86, 55]), SecretKey([8, 156, 116, 1, 163, 35, 47, 188, 77, 106, 247, 7, 200, 47, 55, 197, 5, 238, 33, 3, 219, 66, 135, 23, 204, 59, 121, 190, 21, 62, 72, 77]), Seed([183, 225, 7, 111, 70, 180, 227, 6, 113, 249, 201, 172, 25, 13, 140, 142, 206, 124, 170, 214, 99, 172, 218, 42, 78, 140, 39, 33, 48, 14, 12, 17]));
/// ON: GDON22QX2XNG3MZ57ZRJWGVNE6KOVBYAJQMNJKHPGGQJMZRDQCZFYGJ2
static immutable ON = KeyPair(PublicKey([220, 221, 106, 23, 213, 218, 109, 179, 61, 254, 98, 155, 26, 173, 39, 148, 234, 135, 0, 76, 24, 212, 168, 239, 49, 160, 150, 102, 35, 128, 178, 92]), SecretKey([8, 183, 55, 237, 235, 100, 20, 170, 205, 10, 98, 216, 211, 254, 11, 130, 205, 123, 62, 158, 79, 167, 81, 105, 70, 144, 88, 133, 31, 31, 166, 96]), Seed([171, 173, 218, 14, 66, 173, 243, 148, 204, 162, 210, 220, 4, 12, 254, 178, 114, 119, 233, 168, 107, 176, 225, 83, 179, 104, 153, 104, 89, 239, 212, 103]));
/// OO: GDOO224N2AIAINCTRWPVHDTNNUSBZLBDUINBOVOV22MO34E7OESLZP6T
static immutable OO = KeyPair(PublicKey([220, 237, 107, 141, 208, 16, 4, 52, 83, 141, 159, 83, 142, 109, 109, 36, 28, 172, 35, 162, 26, 23, 85, 213, 214, 152, 237, 240, 159, 113, 36, 188]), SecretKey([224, 188, 204, 197, 232, 220, 196, 46, 0, 246, 69, 153, 167, 175, 49, 24, 50, 4, 228, 75, 30, 232, 214, 219, 97, 97, 109, 212, 6, 134, 85, 101]), Seed([2, 189, 27, 69, 2, 18, 139, 178, 231, 220, 169, 70, 49, 205, 82, 248, 9, 184, 44, 119, 88, 130, 115, 0, 127, 41, 236, 214, 250, 82, 220, 163]));
/// OP: GDOP22BG43YXPRQJGXJIDMCV3DTQWTNEJZ4S2UEHZFKECBCTKRXTQBEY
static immutable OP = KeyPair(PublicKey([220, 253, 104, 38, 230, 241, 119, 198, 9, 53, 210, 129, 176, 85, 216, 231, 11, 77, 164, 78, 121, 45, 80, 135, 201, 84, 65, 4, 83, 84, 111, 56]), SecretKey([56, 146, 158, 47, 222, 234, 72, 17, 226, 116, 209, 205, 229, 240, 160, 161, 192, 182, 1, 85, 111, 12, 244, 61, 235, 197, 165, 14, 139, 75, 216, 80]), Seed([239, 28, 31, 117, 165, 137, 129, 225, 217, 4, 121, 51, 206, 250, 147, 150, 7, 243, 13, 215, 16, 221, 4, 34, 251, 241, 135, 170, 240, 196, 141, 250]));
/// OQ: GDOQ22NJ45KYOUPUCNW4NTAX6VQLJBNG2H62OYTYCX6ASYAITAOGNK7H
static immutable OQ = KeyPair(PublicKey([221, 13, 105, 169, 231, 85, 135, 81, 244, 19, 109, 198, 204, 23, 245, 96, 180, 133, 166, 209, 253, 167, 98, 120, 21, 252, 9, 96, 8, 152, 28, 102]), SecretKey([160, 210, 158, 204, 234, 206, 69, 158, 61, 241, 61, 117, 33, 131, 177, 43, 82, 5, 52, 87, 41, 214, 179, 212, 84, 176, 145, 83, 220, 83, 176, 94]), Seed([250, 107, 55, 219, 12, 150, 129, 100, 94, 18, 70, 244, 204, 244, 50, 0, 189, 62, 67, 56, 202, 66, 171, 53, 20, 129, 97, 47, 171, 72, 129, 160]));
/// OR: GDOR22N4SNROOWSCLONF7TJQW22BEG4UV2RWUPEPUCF7GQVZVAU6L4ZE
static immutable OR = KeyPair(PublicKey([221, 29, 105, 188, 147, 98, 231, 90, 66, 91, 154, 95, 205, 48, 182, 180, 18, 27, 148, 174, 163, 106, 60, 143, 160, 139, 243, 66, 185, 168, 41, 229]), SecretKey([208, 222, 31, 183, 130, 116, 204, 70, 74, 66, 13, 209, 3, 219, 214, 175, 50, 253, 38, 67, 254, 242, 55, 47, 156, 96, 148, 93, 148, 148, 109, 73]), Seed([147, 9, 77, 47, 234, 36, 72, 175, 16, 132, 11, 90, 42, 211, 46, 90, 3, 130, 24, 32, 240, 82, 8, 21, 183, 179, 77, 62, 225, 233, 128, 73]));
/// OS: GDOS224XWTE6NZJWLVHSBKIYR7LLLGGNY7QV2XT4DY3XKM5CRKWYWKNU
static immutable OS = KeyPair(PublicKey([221, 45, 107, 151, 180, 201, 230, 229, 54, 93, 79, 32, 169, 24, 143, 214, 181, 152, 205, 199, 225, 93, 94, 124, 30, 55, 117, 51, 162, 138, 173, 139]), SecretKey([56, 226, 88, 133, 217, 10, 172, 219, 93, 175, 246, 135, 179, 62, 129, 61, 53, 183, 82, 238, 127, 151, 240, 69, 190, 247, 190, 58, 176, 55, 64, 85]), Seed([97, 0, 98, 243, 36, 128, 61, 29, 121, 201, 192, 135, 91, 126, 208, 126, 32, 196, 16, 217, 47, 79, 165, 41, 250, 208, 129, 215, 187, 89, 49, 235]));
/// OT: GDOT22M6E4MALB4MQIQT5DXM5DLBLJ5I72AXFNHXU53OSWYH6ED27SBS
static immutable OT = KeyPair(PublicKey([221, 61, 105, 158, 39, 24, 5, 135, 140, 130, 33, 62, 142, 236, 232, 214, 21, 167, 168, 254, 129, 114, 180, 247, 167, 118, 233, 91, 7, 241, 7, 175]), SecretKey([32, 129, 80, 55, 231, 252, 26, 67, 185, 101, 231, 94, 171, 73, 118, 23, 172, 196, 169, 182, 205, 77, 134, 113, 215, 234, 155, 204, 132, 203, 181, 109]), Seed([33, 118, 50, 215, 39, 76, 47, 71, 204, 81, 162, 37, 100, 237, 158, 26, 175, 205, 7, 2, 2, 58, 168, 54, 152, 34, 17, 134, 182, 48, 43, 231]));
/// OU: GDOU22SPHEDQYQXH5WDMQ6H5GQDV44XOA4HHQ7EW4WJ2Z4V6TR6APEAV
static immutable OU = KeyPair(PublicKey([221, 77, 106, 79, 57, 7, 12, 66, 231, 237, 134, 200, 120, 253, 52, 7, 94, 114, 238, 7, 14, 120, 124, 150, 229, 147, 172, 242, 190, 156, 124, 7]), SecretKey([224, 168, 139, 74, 228, 56, 214, 200, 140, 6, 110, 223, 155, 128, 146, 32, 152, 210, 226, 216, 51, 138, 133, 11, 74, 93, 241, 186, 88, 214, 156, 74]), Seed([9, 44, 19, 190, 71, 112, 5, 90, 69, 170, 219, 251, 230, 31, 65, 231, 125, 171, 84, 251, 1, 217, 94, 47, 179, 145, 38, 71, 70, 101, 54, 204]));
/// OV: GDOV223KFRTASZKNAHMEPHCKB5VXBSZHRLZQAKE5HBE42DFLJE6PWAXD
static immutable OV = KeyPair(PublicKey([221, 93, 107, 106, 44, 102, 9, 101, 77, 1, 216, 71, 156, 74, 15, 107, 112, 203, 39, 138, 243, 0, 40, 157, 56, 73, 205, 12, 171, 73, 60, 251]), SecretKey([136, 187, 43, 205, 112, 92, 119, 216, 179, 154, 243, 42, 85, 131, 34, 27, 133, 94, 166, 213, 40, 197, 128, 28, 5, 188, 67, 25, 229, 147, 10, 99]), Seed([87, 244, 71, 161, 68, 244, 103, 184, 82, 199, 51, 150, 32, 14, 57, 193, 69, 81, 56, 132, 202, 175, 240, 98, 215, 120, 31, 199, 31, 116, 76, 116]));
/// OW: GDOW22D6UFO4LQIA6I427XLH4M6LBHFQTOQXIGJIV5WW3ESEENWIGR63
static immutable OW = KeyPair(PublicKey([221, 109, 104, 126, 161, 93, 197, 193, 0, 242, 57, 175, 221, 103, 227, 60, 176, 156, 176, 155, 161, 116, 25, 40, 175, 109, 109, 146, 68, 35, 108, 131]), SecretKey([32, 3, 44, 53, 108, 185, 34, 85, 189, 20, 140, 45, 136, 119, 198, 39, 179, 14, 53, 28, 213, 37, 17, 200, 241, 201, 212, 215, 94, 104, 188, 85]), Seed([97, 154, 151, 247, 23, 89, 49, 89, 248, 117, 251, 123, 124, 195, 126, 202, 130, 195, 193, 200, 144, 109, 104, 23, 33, 48, 74, 238, 202, 56, 97, 221]));
/// OX: GDOX222WHTDRXL6LXR4XIW6KGS5PUJ5QHXWYW5HNHWZZGSOLDN6PITRT
static immutable OX = KeyPair(PublicKey([221, 125, 107, 86, 60, 199, 27, 175, 203, 188, 121, 116, 91, 202, 52, 186, 250, 39, 176, 61, 237, 139, 116, 237, 61, 179, 147, 73, 203, 27, 124, 244]), SecretKey([216, 113, 167, 5, 201, 80, 160, 172, 181, 220, 218, 159, 181, 51, 31, 115, 241, 65, 202, 40, 51, 210, 1, 116, 138, 176, 5, 157, 147, 229, 184, 116]), Seed([29, 213, 112, 81, 182, 133, 131, 46, 239, 139, 86, 88, 81, 209, 179, 167, 19, 213, 12, 94, 33, 105, 221, 236, 240, 6, 62, 174, 173, 225, 39, 136]));
/// OY: GDOY223G2FL467MXW7FMM7Q5IQKTXXAL24DCUWWZ5IEOYYHB326JJFZ3
static immutable OY = KeyPair(PublicKey([221, 141, 107, 102, 209, 87, 207, 125, 151, 183, 202, 198, 126, 29, 68, 21, 59, 220, 11, 215, 6, 42, 90, 217, 234, 8, 236, 96, 225, 222, 188, 148]), SecretKey([184, 67, 253, 227, 240, 156, 69, 114, 183, 140, 26, 137, 77, 145, 241, 15, 75, 136, 15, 103, 192, 238, 238, 245, 53, 57, 222, 144, 169, 217, 63, 84]), Seed([8, 117, 75, 131, 236, 207, 57, 66, 242, 133, 194, 211, 22, 132, 254, 50, 129, 118, 246, 6, 48, 89, 220, 69, 33, 186, 85, 212, 46, 232, 197, 24]));
/// OZ: GDOZ226HCEXJSJFHVKZ7XLNEVHZA5XPDLHECUPCRQZXV2TZIV7TESGVD
static immutable OZ = KeyPair(PublicKey([221, 157, 107, 199, 17, 46, 153, 36, 167, 170, 179, 251, 173, 164, 169, 242, 14, 221, 227, 89, 200, 42, 60, 81, 134, 111, 93, 79, 40, 175, 230, 73]), SecretKey([16, 28, 86, 91, 9, 247, 185, 53, 34, 161, 99, 109, 136, 223, 108, 82, 126, 188, 195, 157, 154, 207, 94, 93, 119, 8, 87, 174, 3, 149, 27, 123]), Seed([92, 92, 118, 189, 38, 7, 118, 86, 77, 104, 140, 183, 66, 220, 31, 32, 151, 183, 121, 183, 31, 91, 207, 193, 61, 179, 182, 18, 116, 138, 143, 82]));
/// PA: GDPA22RBRR35DWC4PMRUDOZPOIKW56E3IHDT2Y5A5KWZB2WN3YI5Q5BO
static immutable PA = KeyPair(PublicKey([222, 13, 106, 33, 140, 119, 209, 216, 92, 123, 35, 65, 187, 47, 114, 21, 110, 248, 155, 65, 199, 61, 99, 160, 234, 173, 144, 234, 205, 222, 17, 216]), SecretKey([232, 208, 131, 124, 40, 28, 180, 177, 53, 208, 194, 95, 115, 212, 255, 121, 224, 176, 245, 200, 159, 230, 102, 222, 81, 41, 192, 169, 146, 205, 132, 80]), Seed([103, 172, 109, 78, 28, 28, 236, 9, 217, 109, 246, 7, 254, 57, 147, 190, 66, 142, 41, 0, 128, 163, 74, 25, 130, 214, 145, 144, 139, 146, 224, 76]));
/// PB: GDPB22BO5OF2I4ULFTUVDVTMZ55J2KA3CUY2FOYVYRF26ENGYFVDKWLA
static immutable PB = KeyPair(PublicKey([222, 29, 104, 46, 235, 139, 164, 114, 139, 44, 233, 81, 214, 108, 207, 122, 157, 40, 27, 21, 49, 162, 187, 21, 196, 75, 175, 17, 166, 193, 106, 53]), SecretKey([240, 184, 166, 223, 86, 206, 203, 201, 12, 118, 249, 160, 203, 141, 139, 130, 212, 64, 27, 212, 142, 63, 189, 13, 25, 210, 120, 108, 134, 134, 17, 109]), Seed([36, 64, 62, 187, 41, 164, 155, 52, 216, 137, 206, 202, 18, 35, 182, 235, 206, 190, 107, 168, 98, 27, 206, 26, 207, 67, 222, 98, 121, 26, 61, 210]));
/// PC: GDPC224CBW5MSK3ESU2FL4IGI7VWZK5LYQ6UKU33XPG5QTNLFWDLBSUJ
static immutable PC = KeyPair(PublicKey([222, 45, 107, 130, 13, 186, 201, 43, 100, 149, 52, 85, 241, 6, 71, 235, 108, 171, 171, 196, 61, 69, 83, 123, 187, 205, 216, 77, 171, 45, 134, 176]), SecretKey([176, 90, 193, 108, 83, 145, 58, 232, 225, 20, 73, 39, 234, 25, 167, 99, 32, 167, 110, 10, 252, 47, 167, 181, 169, 127, 14, 183, 203, 115, 3, 72]), Seed([23, 138, 145, 178, 186, 215, 135, 0, 115, 80, 65, 214, 240, 44, 233, 20, 34, 134, 33, 137, 183, 77, 136, 87, 143, 240, 107, 186, 13, 230, 254, 203]));
/// PD: GDPD22MFXATBWCATNSLQG6GUS5PUDFMPBII2CXVEBBSVF2U2ZSY4OKQM
static immutable PD = KeyPair(PublicKey([222, 61, 105, 133, 184, 38, 27, 8, 19, 108, 151, 3, 120, 212, 151, 95, 65, 149, 143, 10, 17, 161, 94, 164, 8, 101, 82, 234, 154, 204, 177, 199]), SecretKey([224, 156, 139, 82, 246, 205, 217, 120, 222, 37, 45, 126, 122, 143, 73, 139, 43, 85, 28, 225, 82, 252, 206, 216, 81, 44, 187, 58, 169, 120, 71, 73]), Seed([86, 108, 6, 110, 151, 186, 157, 233, 204, 82, 202, 178, 226, 32, 104, 253, 213, 57, 126, 67, 83, 58, 226, 32, 24, 81, 59, 27, 147, 90, 65, 178]));
/// PE: GDPE22KFOEHMOTPBPFIZSNG33EWMA5KZXYIKXRHG24JO2Y5DE5OCYRYJ
static immutable PE = KeyPair(PublicKey([222, 77, 105, 69, 113, 14, 199, 77, 225, 121, 81, 153, 52, 219, 217, 44, 192, 117, 89, 190, 16, 171, 196, 230, 215, 18, 237, 99, 163, 39, 92, 44]), SecretKey([24, 32, 247, 28, 237, 199, 213, 175, 136, 25, 57, 209, 141, 97, 82, 59, 175, 91, 190, 168, 25, 245, 171, 138, 219, 163, 110, 120, 52, 30, 241, 126]), Seed([146, 167, 132, 130, 151, 220, 235, 177, 75, 106, 84, 30, 218, 196, 148, 165, 144, 61, 166, 118, 137, 233, 108, 243, 190, 229, 77, 143, 121, 172, 173, 8]));
/// PF: GDPF22L2ZO6SNZRT7NR6U5OVLT5YJZUQTS4Y3D75PIGBGFZAZU6QNLED
static immutable PF = KeyPair(PublicKey([222, 93, 105, 122, 203, 189, 38, 230, 51, 251, 99, 234, 117, 213, 92, 251, 132, 230, 144, 156, 185, 141, 143, 253, 122, 12, 19, 23, 32, 205, 61, 6]), SecretKey([152, 25, 225, 116, 52, 13, 228, 194, 90, 35, 232, 193, 199, 98, 39, 222, 226, 38, 79, 194, 147, 77, 36, 63, 225, 136, 24, 112, 148, 242, 216, 78]), Seed([181, 232, 96, 158, 168, 33, 127, 4, 44, 5, 179, 125, 82, 116, 64, 111, 235, 240, 31, 108, 51, 207, 81, 116, 221, 154, 196, 239, 218, 44, 137, 205]));
/// PG: GDPG22IINMKXTPYB3QQUGKUHQXBZKSN2XM4LACUANNJGRYYE6JTQFV6K
static immutable PG = KeyPair(PublicKey([222, 109, 105, 8, 107, 21, 121, 191, 1, 220, 33, 67, 42, 135, 133, 195, 149, 73, 186, 187, 56, 176, 10, 128, 107, 82, 104, 227, 4, 242, 103, 2]), SecretKey([72, 213, 35, 62, 154, 173, 82, 119, 210, 247, 197, 167, 74, 13, 81, 29, 16, 98, 32, 213, 206, 215, 180, 207, 247, 129, 13, 39, 68, 44, 54, 113]), Seed([152, 236, 88, 173, 30, 91, 142, 36, 194, 207, 17, 201, 122, 109, 190, 191, 114, 216, 195, 35, 91, 121, 241, 142, 149, 181, 32, 227, 179, 129, 14, 162]));
/// PH: GDPH22AF3C7ADJTFDFCTOALO7GFOYPQN6SRSLJH7D7LWK7QNLBBYJ42W
static immutable PH = KeyPair(PublicKey([222, 125, 104, 5, 216, 190, 1, 166, 101, 25, 69, 55, 1, 110, 249, 138, 236, 62, 13, 244, 163, 37, 164, 255, 31, 215, 101, 126, 13, 88, 67, 132]), SecretKey([0, 159, 120, 122, 117, 20, 146, 84, 161, 56, 103, 48, 227, 106, 92, 125, 127, 186, 157, 242, 29, 34, 239, 230, 72, 209, 156, 28, 141, 150, 201, 74]), Seed([26, 238, 66, 90, 27, 90, 217, 46, 67, 253, 127, 110, 2, 37, 58, 127, 150, 189, 167, 68, 126, 233, 65, 212, 0, 200, 9, 216, 136, 251, 158, 156]));
/// PI: GDPI22DFZP25F3PW2KW6HK6QDS42SRG2IQC4LEQMMJ36Q5TKVOTLDK4L
static immutable PI = KeyPair(PublicKey([222, 141, 104, 101, 203, 245, 210, 237, 246, 210, 173, 227, 171, 208, 28, 185, 169, 68, 218, 68, 5, 197, 146, 12, 98, 119, 232, 118, 106, 171, 166, 177]), SecretKey([112, 180, 78, 183, 230, 225, 30, 131, 207, 254, 32, 213, 36, 115, 25, 64, 24, 96, 126, 36, 149, 162, 58, 182, 226, 236, 143, 223, 252, 151, 80, 72]), Seed([6, 76, 198, 104, 83, 248, 212, 84, 152, 130, 226, 156, 220, 131, 203, 30, 186, 138, 205, 136, 206, 82, 16, 182, 4, 177, 237, 86, 124, 153, 75, 33]));
/// PJ: GDPJ224AITWHMDI5HWDISLLSOCMRBR4LACDRVL2CCWXZK7HOEM7KRU57
static immutable PJ = KeyPair(PublicKey([222, 157, 107, 128, 68, 236, 118, 13, 29, 61, 134, 137, 45, 114, 112, 153, 16, 199, 139, 0, 135, 26, 175, 66, 21, 175, 149, 124, 238, 35, 62, 168]), SecretKey([88, 45, 143, 168, 204, 9, 107, 186, 171, 39, 233, 10, 42, 206, 114, 155, 14, 70, 175, 251, 109, 2, 159, 242, 20, 117, 164, 159, 189, 107, 224, 105]), Seed([151, 70, 168, 201, 28, 175, 177, 226, 137, 196, 86, 28, 231, 72, 22, 234, 76, 115, 191, 131, 218, 108, 224, 64, 3, 227, 207, 27, 185, 185, 83, 77]));
/// PK: GDPK22PHSTO3X5OKT5FUUWEVE6APU7KFCYKBS3BUFY5C74TCE65DAD3H
static immutable PK = KeyPair(PublicKey([222, 173, 105, 231, 148, 221, 187, 245, 202, 159, 75, 74, 88, 149, 39, 128, 250, 125, 69, 22, 20, 25, 108, 52, 46, 58, 47, 242, 98, 39, 186, 48]), SecretKey([136, 247, 149, 113, 222, 220, 25, 227, 193, 157, 101, 105, 155, 165, 90, 206, 37, 62, 71, 24, 166, 20, 219, 91, 255, 214, 30, 87, 201, 11, 99, 110]), Seed([103, 213, 120, 127, 78, 131, 196, 138, 133, 52, 13, 34, 197, 172, 39, 141, 180, 193, 115, 115, 90, 109, 195, 218, 236, 250, 1, 75, 8, 68, 197, 196]));
/// PL: GDPL22SWCWA3BTSMUG63CTT3H3JO75ZE25MMIBGJWSPHPGOGSBPQYORB
static immutable PL = KeyPair(PublicKey([222, 189, 106, 86, 21, 129, 176, 206, 76, 161, 189, 177, 78, 123, 62, 210, 239, 247, 36, 215, 88, 196, 4, 201, 180, 158, 119, 153, 198, 144, 95, 12]), SecretKey([72, 146, 116, 168, 126, 83, 32, 102, 146, 5, 110, 174, 7, 44, 154, 33, 42, 29, 21, 225, 176, 209, 18, 108, 80, 45, 236, 79, 146, 125, 21, 113]), Seed([58, 178, 162, 40, 54, 212, 88, 150, 178, 26, 199, 53, 130, 214, 207, 8, 72, 193, 14, 38, 206, 41, 159, 39, 0, 96, 14, 163, 54, 58, 35, 114]));
/// PM: GDPM225HEGZAZ4TJ3MJ37KSIATHNLHDWE2UEJJJW34L34XYVOLIBUDFJ
static immutable PM = KeyPair(PublicKey([222, 205, 107, 167, 33, 178, 12, 242, 105, 219, 19, 191, 170, 72, 4, 206, 213, 156, 118, 38, 168, 68, 165, 54, 223, 23, 190, 95, 21, 114, 208, 26]), SecretKey([112, 79, 214, 118, 60, 158, 29, 45, 158, 143, 176, 118, 231, 155, 193, 37, 2, 249, 10, 43, 182, 223, 106, 83, 109, 29, 157, 50, 63, 150, 1, 69]), Seed([166, 247, 89, 169, 80, 135, 67, 22, 84, 1, 205, 4, 57, 142, 8, 80, 251, 177, 169, 15, 138, 48, 50, 32, 107, 36, 41, 197, 2, 168, 110, 182]));
/// PN: GDPN22JQIUIUGEDRRZJ2DJAENJHAAEQZRDEE4BL6JKOTCMPM2R34FO6X
static immutable PN = KeyPair(PublicKey([222, 221, 105, 48, 69, 17, 67, 16, 113, 142, 83, 161, 164, 4, 106, 78, 0, 18, 25, 136, 200, 78, 5, 126, 74, 157, 49, 49, 236, 212, 119, 194]), SecretKey([192, 0, 81, 98, 72, 250, 19, 147, 28, 253, 180, 48, 46, 127, 157, 211, 161, 98, 41, 81, 53, 59, 128, 120, 202, 227, 207, 91, 39, 71, 105, 70]), Seed([81, 68, 250, 163, 75, 163, 121, 20, 43, 83, 229, 88, 162, 39, 217, 17, 54, 240, 206, 91, 240, 35, 232, 195, 95, 148, 212, 19, 124, 129, 51, 78]));
/// PO: GDPO22WUJC45ATZA6HEPZNMMSAH74RHACHDLTJR5OWWADL2574ZQQ7LJ
static immutable PO = KeyPair(PublicKey([222, 237, 106, 212, 72, 185, 208, 79, 32, 241, 200, 252, 181, 140, 144, 15, 254, 68, 224, 17, 198, 185, 166, 61, 117, 172, 1, 175, 93, 255, 51, 8]), SecretKey([96, 246, 81, 55, 200, 238, 107, 193, 81, 237, 236, 207, 184, 50, 248, 144, 112, 119, 182, 214, 79, 23, 197, 234, 154, 217, 16, 74, 218, 116, 23, 112]), Seed([161, 104, 22, 106, 186, 140, 86, 218, 38, 191, 43, 70, 124, 245, 89, 68, 233, 199, 244, 75, 227, 12, 143, 67, 196, 213, 3, 93, 202, 69, 242, 112]));
/// PP: GDPP22WOC72DKJOYBCSUHKTQYOZDF5H7NVQSB4MXFJL3C5HYZABF5PGQ
static immutable PP = KeyPair(PublicKey([222, 253, 106, 206, 23, 244, 53, 37, 216, 8, 165, 67, 170, 112, 195, 178, 50, 244, 255, 109, 97, 32, 241, 151, 42, 87, 177, 116, 248, 200, 2, 94]), SecretKey([152, 202, 102, 102, 110, 162, 71, 34, 255, 210, 250, 227, 25, 74, 94, 196, 198, 91, 45, 178, 113, 185, 46, 22, 74, 120, 131, 117, 236, 49, 196, 78]), Seed([170, 144, 58, 84, 104, 180, 14, 146, 69, 203, 7, 96, 61, 158, 190, 0, 86, 176, 64, 51, 112, 254, 119, 46, 187, 184, 191, 35, 235, 72, 39, 14]));
/// PQ: GDPQ22XJYFXIEUG3UWZREKQ4AKL6TFVSDPKLCUBBP75JAXN6WRNDN4YZ
static immutable PQ = KeyPair(PublicKey([223, 13, 106, 233, 193, 110, 130, 80, 219, 165, 179, 18, 42, 28, 2, 151, 233, 150, 178, 27, 212, 177, 80, 33, 127, 250, 144, 93, 190, 180, 90, 54]), SecretKey([216, 26, 25, 141, 247, 64, 241, 95, 68, 78, 36, 50, 107, 73, 201, 114, 231, 249, 208, 49, 42, 91, 41, 159, 227, 6, 123, 97, 53, 245, 252, 64]), Seed([83, 162, 108, 113, 187, 171, 173, 102, 16, 204, 199, 80, 68, 234, 98, 19, 223, 255, 85, 60, 48, 97, 67, 124, 90, 188, 25, 92, 105, 86, 9, 49]));
/// PR: GDPR22DW7W4EPJK7Z3YVJIH3A3NXC6AW2G2I2BJXPTD7HKCHCARA3ZED
static immutable PR = KeyPair(PublicKey([223, 29, 104, 118, 253, 184, 71, 165, 95, 206, 241, 84, 160, 251, 6, 219, 113, 120, 22, 209, 180, 141, 5, 55, 124, 199, 243, 168, 71, 16, 34, 13]), SecretKey([184, 5, 41, 74, 161, 210, 166, 210, 55, 219, 141, 182, 127, 154, 95, 144, 46, 119, 120, 57, 70, 20, 66, 175, 100, 0, 222, 34, 192, 150, 181, 64]), Seed([122, 166, 246, 208, 191, 114, 162, 78, 58, 13, 56, 56, 170, 102, 140, 127, 39, 149, 192, 51, 154, 62, 118, 181, 102, 37, 120, 254, 201, 114, 150, 62]));
/// PS: GDPS2264WBMPXIGRZQ4UCP5LSKDFJD73LYJMHPFCHKUWPX266H25LV2H
static immutable PS = KeyPair(PublicKey([223, 45, 107, 220, 176, 88, 251, 160, 209, 204, 57, 65, 63, 171, 146, 134, 84, 143, 251, 94, 18, 195, 188, 162, 58, 169, 103, 223, 94, 241, 245, 213]), SecretKey([216, 36, 72, 243, 205, 166, 172, 97, 255, 41, 158, 29, 251, 251, 130, 221, 148, 157, 205, 51, 128, 125, 7, 237, 172, 158, 19, 52, 52, 112, 151, 79]), Seed([92, 159, 154, 214, 82, 94, 219, 105, 81, 71, 214, 147, 121, 22, 137, 118, 147, 139, 118, 102, 31, 152, 175, 3, 158, 157, 77, 107, 84, 85, 148, 97]));
/// PT: GDPT22OOPAH3IC7AWRALYVY4BEWKXASPULNROE7CH3M4MDKNXF5WOQB4
static immutable PT = KeyPair(PublicKey([223, 61, 105, 206, 120, 15, 180, 11, 224, 180, 64, 188, 87, 28, 9, 44, 171, 130, 79, 162, 219, 23, 19, 226, 62, 217, 198, 13, 77, 185, 123, 103]), SecretKey([232, 27, 92, 26, 144, 7, 199, 53, 147, 213, 113, 196, 70, 130, 208, 116, 118, 136, 48, 166, 24, 52, 64, 111, 169, 43, 191, 189, 160, 105, 129, 93]), Seed([255, 188, 7, 128, 137, 138, 32, 162, 71, 97, 15, 133, 104, 166, 124, 185, 61, 206, 80, 95, 121, 25, 35, 104, 113, 48, 253, 98, 250, 35, 226, 11]));
/// PU: GDPU22KOCCNMCACFVN3BGDNC4NWXKQ4YGMZ75X4JXMNS7LO5IBQWB7CJ
static immutable PU = KeyPair(PublicKey([223, 77, 105, 78, 16, 154, 193, 0, 69, 171, 118, 19, 13, 162, 227, 109, 117, 67, 152, 51, 51, 254, 223, 137, 187, 27, 47, 173, 221, 64, 97, 96]), SecretKey([216, 20, 18, 62, 125, 215, 228, 103, 117, 115, 189, 255, 46, 177, 113, 197, 217, 23, 30, 108, 17, 204, 154, 37, 109, 196, 22, 99, 166, 64, 122, 86]), Seed([143, 254, 76, 127, 52, 23, 237, 156, 161, 221, 34, 57, 73, 135, 246, 144, 122, 12, 192, 43, 3, 237, 247, 88, 46, 23, 49, 203, 96, 7, 36, 152]));
/// PV: GDPV22UHJUZKPO4SDIZBNZXNKDFFSPLRHC3VPBO2TUBP2Y4LHGZYCP4L
static immutable PV = KeyPair(PublicKey([223, 93, 106, 135, 77, 50, 167, 187, 146, 26, 50, 22, 230, 237, 80, 202, 89, 61, 113, 56, 183, 87, 133, 218, 157, 2, 253, 99, 139, 57, 179, 129]), SecretKey([216, 150, 222, 251, 181, 178, 126, 88, 150, 235, 222, 78, 68, 131, 46, 49, 179, 66, 201, 86, 145, 93, 141, 143, 106, 213, 135, 106, 135, 254, 112, 125]), Seed([79, 103, 233, 186, 252, 173, 199, 12, 131, 171, 36, 163, 204, 25, 230, 12, 95, 92, 169, 159, 16, 163, 101, 1, 233, 186, 104, 16, 69, 181, 215, 182]));
/// PW: GDPW227UM2JOHIV7ASZPZ7KQ6DP2V2QX4VHLSKZX27545YBYFS7FZWFK
static immutable PW = KeyPair(PublicKey([223, 109, 107, 244, 102, 146, 227, 162, 191, 4, 178, 252, 253, 80, 240, 223, 170, 234, 23, 229, 78, 185, 43, 55, 215, 251, 206, 224, 56, 44, 190, 92]), SecretKey([96, 239, 101, 200, 0, 252, 57, 229, 38, 234, 147, 23, 131, 22, 122, 109, 198, 19, 58, 154, 155, 193, 99, 248, 38, 202, 156, 168, 227, 136, 84, 88]), Seed([1, 41, 213, 230, 188, 149, 187, 71, 54, 59, 54, 197, 102, 234, 26, 181, 154, 157, 164, 9, 91, 11, 171, 203, 228, 168, 243, 115, 51, 169, 0, 38]));
/// PX: GDPX22XXTETXC4YJCMGMI55OBGUVIXVL5AOKP2RGT24B4HCGBRIPFHHD
static immutable PX = KeyPair(PublicKey([223, 125, 106, 247, 153, 39, 113, 115, 9, 19, 12, 196, 119, 174, 9, 169, 84, 94, 171, 232, 28, 167, 234, 38, 158, 184, 30, 28, 70, 12, 80, 242]), SecretKey([224, 253, 115, 179, 33, 17, 137, 185, 56, 155, 77, 24, 149, 144, 98, 230, 20, 235, 80, 109, 144, 145, 156, 215, 188, 14, 139, 92, 247, 141, 29, 120]), Seed([173, 217, 229, 34, 59, 129, 16, 206, 2, 100, 4, 24, 2, 158, 153, 231, 24, 30, 160, 143, 141, 117, 95, 62, 145, 17, 126, 66, 42, 137, 108, 11]));
/// PY: GDPY22WMCY3TH5OUZRRN2CZF4I6UFBV3VDT627HCQMQCQAR7M2WQ5UT4
static immutable PY = KeyPair(PublicKey([223, 141, 106, 204, 22, 55, 51, 245, 212, 204, 98, 221, 11, 37, 226, 61, 66, 134, 187, 168, 231, 237, 124, 226, 131, 32, 40, 2, 63, 102, 173, 14]), SecretKey([152, 172, 54, 150, 90, 98, 125, 233, 59, 188, 22, 14, 212, 240, 229, 143, 244, 60, 84, 160, 131, 7, 36, 235, 88, 232, 228, 238, 208, 247, 102, 127]), Seed([10, 118, 148, 253, 234, 158, 234, 51, 204, 54, 107, 219, 236, 145, 71, 151, 228, 105, 74, 8, 194, 132, 239, 226, 111, 38, 62, 196, 106, 93, 148, 226]));
/// PZ: GDPZ225K4MUNOHGEYKP4RWBFXCHL6TXDLHZYRNGRXQ2MGGLTUSUCUNA7
static immutable PZ = KeyPair(PublicKey([223, 157, 107, 170, 227, 40, 215, 28, 196, 194, 159, 200, 216, 37, 184, 142, 191, 78, 227, 89, 243, 136, 180, 209, 188, 52, 195, 25, 115, 164, 168, 42]), SecretKey([192, 39, 95, 144, 155, 224, 75, 218, 216, 156, 73, 62, 152, 179, 200, 94, 60, 113, 124, 70, 67, 168, 236, 129, 251, 242, 74, 60, 155, 183, 38, 105]), Seed([212, 33, 102, 246, 108, 103, 51, 65, 100, 23, 125, 154, 223, 39, 118, 40, 4, 93, 59, 250, 126, 197, 29, 217, 46, 175, 223, 53, 251, 170, 243, 109]));
/// QA: GDQA224KNN7LBDRWG3VFL72DRZGKKLNYE4RB6NWP4HX26WKPPEWLNYWW
static immutable QA = KeyPair(PublicKey([224, 13, 107, 138, 107, 126, 176, 142, 54, 54, 234, 85, 255, 67, 142, 76, 165, 45, 184, 39, 34, 31, 54, 207, 225, 239, 175, 89, 79, 121, 44, 182]), SecretKey([248, 226, 167, 209, 227, 85, 252, 136, 178, 209, 180, 216, 62, 146, 232, 220, 138, 236, 159, 63, 51, 179, 86, 36, 200, 71, 202, 98, 177, 18, 156, 97]), Seed([66, 160, 25, 127, 9, 223, 137, 165, 85, 32, 53, 178, 95, 32, 186, 210, 254, 203, 229, 136, 95, 201, 32, 57, 14, 72, 79, 74, 135, 65, 223, 138]));
/// QB: GDQB22BXV375QVNWTB6AN4X7ML6Y6747JRU424TUM4X4ERH2B2XNU4R7
static immutable QB = KeyPair(PublicKey([224, 29, 104, 55, 174, 255, 216, 85, 182, 152, 124, 6, 242, 255, 98, 253, 143, 127, 159, 76, 105, 205, 114, 116, 103, 47, 194, 68, 250, 14, 174, 218]), SecretKey([16, 64, 56, 30, 17, 48, 66, 8, 178, 23, 122, 206, 17, 116, 170, 28, 108, 211, 109, 235, 246, 121, 239, 32, 207, 204, 170, 229, 33, 116, 171, 78]), Seed([56, 111, 124, 198, 254, 124, 94, 10, 124, 56, 21, 235, 9, 121, 195, 182, 102, 160, 232, 236, 131, 21, 187, 230, 84, 116, 222, 178, 20, 224, 143, 54]));
/// QC: GDQC22UCX6LMREY6KAL5RVJHWLJYQZFY5RV223GLIDWW6Q57SC5YZBAS
static immutable QC = KeyPair(PublicKey([224, 45, 106, 130, 191, 150, 200, 147, 30, 80, 23, 216, 213, 39, 178, 211, 136, 100, 184, 236, 107, 173, 108, 203, 64, 237, 111, 67, 191, 144, 187, 140]), SecretKey([32, 103, 26, 19, 150, 67, 9, 46, 64, 173, 222, 191, 139, 117, 123, 62, 42, 69, 132, 172, 165, 45, 99, 118, 140, 205, 33, 123, 186, 89, 69, 82]), Seed([214, 54, 206, 1, 102, 97, 253, 10, 213, 54, 223, 16, 111, 57, 209, 19, 141, 187, 29, 25, 215, 91, 189, 191, 93, 163, 112, 17, 20, 88, 224, 215]));
/// QD: GDQD22J34GZCX425ZFP6RUBMEQXDNOVALDROLVO2W5ZPVLWHFOGJ5IZM
static immutable QD = KeyPair(PublicKey([224, 61, 105, 59, 225, 178, 43, 243, 93, 201, 95, 232, 208, 44, 36, 46, 54, 186, 160, 88, 226, 229, 213, 218, 183, 114, 250, 174, 199, 43, 140, 158]), SecretKey([176, 14, 140, 187, 59, 35, 22, 135, 154, 83, 108, 39, 226, 7, 88, 134, 160, 194, 199, 178, 170, 98, 110, 235, 33, 79, 66, 102, 121, 234, 251, 111]), Seed([66, 44, 154, 124, 96, 85, 63, 75, 53, 170, 195, 189, 206, 61, 103, 161, 165, 249, 121, 216, 132, 234, 183, 122, 50, 85, 193, 3, 199, 88, 49, 107]));
/// QE: GDQE22F34VOBXPFNC7ZG324XKOSRIEVKC3CTBSJ6D4BIB2WWTM3PIJDO
static immutable QE = KeyPair(PublicKey([224, 77, 104, 187, 229, 92, 27, 188, 173, 23, 242, 109, 235, 151, 83, 165, 20, 18, 170, 22, 197, 48, 201, 62, 31, 2, 128, 234, 214, 155, 54, 244]), SecretKey([72, 25, 233, 199, 63, 5, 19, 152, 193, 134, 73, 119, 242, 189, 186, 146, 205, 37, 253, 148, 251, 239, 204, 163, 239, 57, 142, 234, 231, 111, 226, 94]), Seed([103, 252, 212, 106, 17, 240, 51, 203, 29, 70, 56, 0, 184, 247, 55, 138, 155, 144, 137, 5, 224, 221, 209, 186, 253, 182, 62, 93, 226, 8, 190, 145]));
/// QF: GDQF22B2M6UPRVNJR6QPRRREPYSYPEAKNLFIKFJRFHM67F5E2JXESDJS
static immutable QF = KeyPair(PublicKey([224, 93, 104, 58, 103, 168, 248, 213, 169, 143, 160, 248, 198, 36, 126, 37, 135, 144, 10, 106, 202, 133, 21, 49, 41, 217, 239, 151, 164, 210, 110, 73]), SecretKey([160, 62, 91, 61, 223, 59, 13, 20, 182, 19, 203, 18, 119, 90, 74, 80, 146, 245, 66, 254, 88, 242, 182, 69, 191, 243, 229, 171, 232, 18, 221, 110]), Seed([104, 196, 97, 64, 121, 224, 62, 53, 2, 113, 146, 213, 123, 227, 177, 65, 168, 88, 56, 134, 211, 94, 200, 149, 203, 9, 119, 173, 214, 107, 69, 72]));
/// QG: GDQG22ZH4UON4HOCG3IYFQLRZGDAU4VWH6S4DCP3Z3EGVGL4RA4OXJEP
static immutable QG = KeyPair(PublicKey([224, 109, 107, 39, 229, 28, 222, 29, 194, 54, 209, 130, 193, 113, 201, 134, 10, 114, 182, 63, 165, 193, 137, 251, 206, 200, 106, 153, 124, 136, 56, 235]), SecretKey([112, 54, 173, 29, 94, 238, 247, 183, 125, 24, 153, 27, 211, 123, 228, 38, 126, 50, 229, 59, 173, 151, 119, 210, 211, 13, 150, 242, 6, 117, 138, 91]), Seed([67, 105, 134, 135, 177, 68, 163, 56, 72, 100, 21, 11, 189, 236, 255, 114, 207, 133, 161, 236, 144, 118, 199, 99, 206, 226, 239, 41, 19, 101, 57, 87]));
/// QH: GDQH22V5IIEAWGK2UXBBW4O4V3WFKNGUV6QYWLSIC7BBCBIQYXZOL646
static immutable QH = KeyPair(PublicKey([224, 125, 106, 189, 66, 8, 11, 25, 90, 165, 194, 27, 113, 220, 174, 236, 85, 52, 212, 175, 161, 139, 46, 72, 23, 194, 17, 5, 16, 197, 242, 229]), SecretKey([152, 32, 250, 208, 215, 66, 118, 94, 209, 248, 179, 99, 244, 123, 211, 184, 240, 217, 94, 47, 126, 181, 193, 113, 161, 243, 136, 35, 101, 203, 252, 81]), Seed([203, 176, 66, 31, 113, 240, 55, 239, 233, 47, 131, 162, 98, 86, 145, 253, 6, 43, 221, 221, 192, 92, 230, 30, 1, 39, 154, 175, 16, 120, 49, 146]));
/// QI: GDQI22ZAWV7C4INFBSKBL6AXZE7CQV5LAB5KZVGXKIRNN76WXQN3RROH
static immutable QI = KeyPair(PublicKey([224, 141, 107, 32, 181, 126, 46, 33, 165, 12, 148, 21, 248, 23, 201, 62, 40, 87, 171, 0, 122, 172, 212, 215, 82, 34, 214, 255, 214, 188, 27, 184]), SecretKey([136, 24, 147, 15, 9, 3, 26, 79, 170, 15, 55, 181, 92, 169, 91, 241, 164, 70, 62, 12, 60, 41, 90, 15, 249, 252, 112, 228, 202, 143, 113, 71]), Seed([66, 204, 212, 120, 140, 16, 44, 35, 200, 253, 179, 196, 218, 138, 76, 215, 222, 109, 221, 231, 225, 195, 192, 53, 236, 34, 198, 209, 37, 214, 210, 90]));
/// QJ: GDQJ22U3YULFJNC2FPHXWDA7TW5NWZWFA724NOMHYDRKDYJTIL6AULMK
static immutable QJ = KeyPair(PublicKey([224, 157, 106, 155, 197, 22, 84, 180, 90, 43, 207, 123, 12, 31, 157, 186, 219, 102, 197, 7, 245, 198, 185, 135, 192, 226, 161, 225, 51, 66, 252, 10]), SecretKey([176, 121, 142, 183, 190, 103, 189, 130, 115, 32, 216, 87, 29, 35, 250, 162, 24, 145, 66, 102, 125, 213, 175, 90, 135, 239, 32, 254, 5, 214, 39, 97]), Seed([110, 177, 169, 29, 9, 249, 66, 248, 248, 112, 252, 175, 157, 254, 178, 186, 141, 62, 100, 79, 150, 39, 74, 99, 231, 202, 101, 237, 208, 253, 174, 238]));
/// QK: GDQK22DS4FGW7TLOZWQ5ZZEDBVZCPBTNJC3WXIYVKRBNWROPYIXXQDZE
static immutable QK = KeyPair(PublicKey([224, 173, 104, 114, 225, 77, 111, 205, 110, 205, 161, 220, 228, 131, 13, 114, 39, 134, 109, 72, 183, 107, 163, 21, 84, 66, 219, 69, 207, 194, 47, 120]), SecretKey([88, 121, 198, 207, 91, 162, 128, 140, 107, 200, 176, 72, 239, 136, 210, 28, 121, 191, 104, 141, 209, 183, 100, 145, 148, 17, 196, 121, 88, 99, 206, 84]), Seed([92, 255, 229, 212, 190, 189, 211, 196, 207, 165, 156, 42, 69, 193, 251, 94, 35, 131, 16, 159, 94, 147, 136, 80, 166, 40, 225, 21, 105, 0, 159, 255]));
/// QL: GDQL22N35N6C6CEZWOTEYH4TZH723EXDFLEKEYTLU5Y4VXEBVDJCRSYC
static immutable QL = KeyPair(PublicKey([224, 189, 105, 187, 235, 124, 47, 8, 153, 179, 166, 76, 31, 147, 201, 255, 173, 146, 227, 42, 200, 162, 98, 107, 167, 113, 202, 220, 129, 168, 210, 40]), SecretKey([56, 240, 39, 176, 195, 131, 222, 182, 247, 48, 155, 1, 212, 78, 147, 247, 27, 124, 79, 155, 180, 70, 53, 228, 231, 153, 180, 82, 158, 166, 235, 82]), Seed([91, 224, 45, 172, 34, 26, 8, 212, 237, 159, 236, 83, 22, 149, 12, 138, 227, 64, 87, 52, 151, 243, 125, 222, 166, 205, 252, 145, 126, 64, 82, 40]));
/// QM: GDQM225AFMY43DLHBOL4HBJ7DHT24VVTEGQR26KL4JLQZ6EYPXZVCSFG
static immutable QM = KeyPair(PublicKey([224, 205, 107, 160, 43, 49, 205, 141, 103, 11, 151, 195, 133, 63, 25, 231, 174, 86, 179, 33, 161, 29, 121, 75, 226, 87, 12, 248, 152, 125, 243, 81]), SecretKey([16, 195, 83, 26, 5, 246, 34, 244, 175, 87, 166, 184, 137, 9, 146, 202, 57, 229, 81, 52, 116, 189, 88, 207, 190, 84, 111, 122, 255, 209, 155, 76]), Seed([169, 181, 213, 173, 231, 90, 240, 30, 104, 109, 125, 110, 241, 221, 22, 62, 4, 108, 198, 45, 70, 44, 238, 146, 78, 167, 133, 211, 190, 37, 198, 216]));
/// QN: GDQN22GHLV54FDQEQ5CRUFD4QIXRQPCHCFLAEKUDB2O3JD6OPQJOCJV4
static immutable QN = KeyPair(PublicKey([224, 221, 104, 199, 93, 123, 194, 142, 4, 135, 69, 26, 20, 124, 130, 47, 24, 60, 71, 17, 86, 2, 42, 131, 14, 157, 180, 143, 206, 124, 18, 225]), SecretKey([40, 0, 144, 7, 104, 52, 66, 191, 36, 76, 6, 87, 187, 21, 11, 195, 14, 193, 30, 49, 8, 45, 139, 218, 124, 144, 141, 62, 118, 216, 112, 127]), Seed([70, 24, 109, 126, 23, 207, 125, 10, 112, 218, 207, 228, 136, 190, 181, 66, 249, 212, 40, 218, 150, 155, 7, 163, 67, 3, 29, 72, 50, 41, 80, 215]));
/// QO: GDQO22FOFLK4LNQQYRNDCVMXHJCOOZ7JVC6ATO6NUVTLNBADEQQGC6JF
static immutable QO = KeyPair(PublicKey([224, 237, 104, 174, 42, 213, 197, 182, 16, 196, 90, 49, 85, 151, 58, 68, 231, 103, 233, 168, 188, 9, 187, 205, 165, 102, 182, 132, 3, 36, 32, 97]), SecretKey([144, 22, 162, 59, 250, 62, 198, 160, 228, 156, 137, 29, 44, 192, 116, 236, 89, 134, 3, 193, 21, 1, 27, 254, 75, 254, 18, 236, 35, 64, 97, 90]), Seed([26, 189, 65, 231, 19, 49, 206, 15, 117, 32, 216, 180, 92, 215, 56, 184, 80, 13, 18, 68, 136, 156, 207, 60, 177, 90, 224, 132, 87, 140, 218, 49]));
/// QP: GDQP22LAXQMTSWIVN2JG27M5TNLLCFPEMRHAWDFEJVKGUUACH3YEU26Q
static immutable QP = KeyPair(PublicKey([224, 253, 105, 96, 188, 25, 57, 89, 21, 110, 146, 109, 125, 157, 155, 86, 177, 21, 228, 100, 78, 11, 12, 164, 77, 84, 106, 80, 2, 62, 240, 74]), SecretKey([16, 18, 56, 156, 186, 138, 99, 224, 247, 89, 1, 241, 108, 168, 202, 188, 86, 202, 111, 151, 81, 213, 145, 134, 133, 231, 73, 111, 27, 16, 137, 112]), Seed([4, 62, 73, 213, 246, 70, 93, 137, 84, 91, 144, 165, 50, 248, 0, 236, 173, 107, 15, 207, 168, 170, 32, 132, 253, 202, 65, 56, 231, 64, 218, 97]));
/// QQ: GDQQ22V32WEEWOCKOF3KOKEHLQBZQC254ZXQBORG35Q6BF3H5UTCQIFZ
static immutable QQ = KeyPair(PublicKey([225, 13, 106, 187, 213, 136, 75, 56, 74, 113, 118, 167, 40, 135, 92, 3, 152, 11, 93, 230, 111, 0, 186, 38, 223, 97, 224, 151, 103, 237, 38, 40]), SecretKey([128, 99, 0, 204, 233, 234, 217, 191, 57, 93, 181, 42, 13, 248, 47, 187, 110, 40, 151, 91, 48, 53, 135, 105, 119, 55, 6, 15, 217, 180, 85, 85]), Seed([59, 138, 113, 28, 53, 145, 21, 158, 240, 231, 26, 219, 80, 142, 69, 182, 103, 251, 145, 157, 11, 76, 147, 135, 171, 59, 225, 168, 77, 107, 101, 28]));
/// QR: GDQR227SL6FHKQX2FMEG6WSHYMFCBFBA6ZCXEZWRITDMUIB6OZ5YZZFC
static immutable QR = KeyPair(PublicKey([225, 29, 107, 242, 95, 138, 117, 66, 250, 43, 8, 111, 90, 71, 195, 10, 32, 148, 32, 246, 69, 114, 102, 209, 68, 198, 202, 32, 62, 118, 123, 140]), SecretKey([240, 18, 203, 79, 235, 21, 180, 248, 7, 113, 121, 33, 167, 145, 147, 142, 216, 216, 59, 79, 217, 163, 62, 249, 51, 233, 118, 77, 97, 159, 188, 75]), Seed([43, 140, 251, 219, 73, 12, 156, 20, 254, 70, 226, 247, 255, 101, 10, 167, 183, 39, 120, 252, 204, 50, 191, 149, 195, 225, 97, 251, 85, 168, 117, 86]));
/// QS: GDQS227JRX65IWBJBYE2HDDKQK5QMF6OYD47UMLC6EXOUWSWG5SY6A3U
static immutable QS = KeyPair(PublicKey([225, 45, 107, 233, 141, 253, 212, 88, 41, 14, 9, 163, 140, 106, 130, 187, 6, 23, 206, 192, 249, 250, 49, 98, 241, 46, 234, 90, 86, 55, 101, 143]), SecretKey([160, 129, 190, 1, 198, 150, 35, 207, 98, 137, 13, 145, 165, 157, 193, 122, 94, 175, 241, 237, 245, 115, 157, 251, 38, 95, 80, 71, 90, 140, 86, 102]), Seed([39, 234, 55, 162, 41, 192, 216, 123, 36, 182, 250, 183, 153, 11, 211, 231, 220, 62, 228, 79, 172, 99, 70, 183, 212, 243, 12, 86, 9, 146, 94, 149]));
/// QT: GDQT22U3FL2BYLDFV4KXMDBGOEK3VXRR67U6HZPCVMOK5OQHKEPLHN57
static immutable QT = KeyPair(PublicKey([225, 61, 106, 155, 42, 244, 28, 44, 101, 175, 21, 118, 12, 38, 113, 21, 186, 222, 49, 247, 233, 227, 229, 226, 171, 28, 174, 186, 7, 81, 30, 179]), SecretKey([120, 216, 221, 59, 105, 82, 193, 215, 152, 207, 134, 83, 207, 123, 253, 178, 142, 129, 205, 105, 167, 93, 220, 255, 118, 140, 109, 190, 88, 206, 225, 113]), Seed([222, 250, 70, 194, 122, 188, 74, 32, 3, 59, 1, 238, 73, 156, 39, 56, 62, 160, 247, 24, 68, 244, 134, 157, 2, 9, 93, 30, 68, 227, 249, 79]));
/// QU: GDQU22TXUEQZB6XXO4US6YO4GGRLQU6XU4BVH7J22IFBRIEVJL3I6NBS
static immutable QU = KeyPair(PublicKey([225, 77, 106, 119, 161, 33, 144, 250, 247, 119, 41, 47, 97, 220, 49, 162, 184, 83, 215, 167, 3, 83, 253, 58, 210, 10, 24, 160, 149, 74, 246, 143]), SecretKey([136, 243, 101, 76, 54, 180, 76, 147, 31, 147, 2, 57, 86, 193, 34, 172, 17, 16, 242, 40, 73, 251, 218, 23, 143, 28, 175, 77, 166, 53, 42, 90]), Seed([34, 3, 147, 102, 120, 209, 35, 214, 21, 47, 110, 191, 247, 14, 212, 190, 92, 6, 184, 70, 108, 58, 248, 42, 92, 134, 187, 72, 126, 21, 194, 132]));
/// QV: GDQV22QXEXDS5PRGWKU6AGUUWQYOYG5JWNXQC2GCZ6EXSW2PPAC3MWYP
static immutable QV = KeyPair(PublicKey([225, 93, 106, 23, 37, 199, 46, 190, 38, 178, 169, 224, 26, 148, 180, 48, 236, 27, 169, 179, 111, 1, 104, 194, 207, 137, 121, 91, 79, 120, 5, 182]), SecretKey([128, 219, 249, 168, 229, 159, 237, 33, 41, 246, 211, 8, 231, 202, 224, 30, 213, 92, 115, 27, 84, 33, 230, 34, 1, 85, 155, 229, 39, 135, 10, 117]), Seed([212, 190, 226, 56, 73, 76, 64, 170, 178, 62, 191, 105, 180, 116, 147, 118, 36, 246, 111, 206, 166, 52, 44, 240, 107, 10, 7, 183, 2, 242, 251, 12]));
/// QW: GDQW222HO3LUJM64XWJPHPV4XVLHMXGQCQ6FTAXQJN2LV6JHNBF6X5NL
static immutable QW = KeyPair(PublicKey([225, 109, 107, 71, 118, 215, 68, 179, 220, 189, 146, 243, 190, 188, 189, 86, 118, 92, 208, 20, 60, 89, 130, 240, 75, 116, 186, 249, 39, 104, 75, 235]), SecretKey([104, 130, 17, 126, 59, 24, 38, 148, 90, 227, 194, 200, 161, 111, 255, 154, 203, 221, 85, 214, 134, 231, 141, 170, 90, 247, 92, 137, 40, 169, 68, 76]), Seed([88, 57, 49, 251, 209, 104, 200, 13, 118, 102, 107, 90, 83, 71, 127, 132, 6, 128, 42, 65, 183, 250, 223, 76, 241, 194, 187, 14, 249, 200, 53, 23]));
/// QX: GDQX22IN5EZNFUPGFO2NOOID64BUKTCEP2VRXGGT6UQ7QDPR332RWGHY
static immutable QX = KeyPair(PublicKey([225, 125, 105, 13, 233, 50, 210, 209, 230, 43, 180, 215, 57, 3, 247, 3, 69, 76, 68, 126, 171, 27, 152, 211, 245, 33, 248, 13, 241, 222, 245, 27]), SecretKey([24, 189, 189, 214, 74, 167, 145, 253, 60, 1, 219, 161, 206, 164, 117, 170, 219, 239, 156, 179, 251, 77, 45, 169, 244, 204, 200, 175, 106, 172, 23, 69]), Seed([166, 107, 224, 51, 244, 115, 245, 2, 153, 232, 195, 174, 98, 210, 53, 190, 180, 242, 218, 173, 42, 109, 145, 152, 191, 120, 41, 84, 220, 107, 157, 129]));
/// QY: GDQY225NXK4HME67RDCP2TCH5MOJTGG5SSQUKRDDZ3W3HRBV5WFWDODA
static immutable QY = KeyPair(PublicKey([225, 141, 107, 173, 186, 184, 118, 19, 223, 136, 196, 253, 76, 71, 235, 28, 153, 152, 221, 148, 161, 69, 68, 99, 206, 237, 179, 196, 53, 237, 139, 97]), SecretKey([248, 125, 143, 76, 54, 192, 19, 251, 4, 233, 97, 49, 94, 0, 196, 42, 53, 106, 154, 8, 23, 102, 138, 242, 254, 51, 156, 125, 135, 234, 102, 125]), Seed([181, 153, 217, 208, 100, 163, 98, 207, 119, 130, 65, 165, 228, 52, 226, 31, 33, 103, 179, 101, 1, 76, 186, 145, 74, 117, 96, 238, 188, 102, 106, 124]));
/// QZ: GDQZ227M5DCL7JCOVLJCX643HBVAVRUQZDBZOGSZGYJDUJBYWHKKTUG3
static immutable QZ = KeyPair(PublicKey([225, 157, 107, 236, 232, 196, 191, 164, 78, 170, 210, 43, 251, 155, 56, 106, 10, 198, 144, 200, 195, 151, 26, 89, 54, 18, 58, 36, 56, 177, 212, 169]), SecretKey([8, 100, 155, 133, 232, 241, 98, 19, 225, 173, 242, 152, 195, 201, 244, 68, 43, 122, 77, 255, 93, 241, 71, 243, 208, 241, 98, 99, 71, 234, 217, 82]), Seed([191, 74, 253, 196, 235, 165, 155, 24, 159, 23, 137, 53, 115, 119, 120, 234, 128, 109, 242, 197, 85, 79, 13, 33, 248, 148, 125, 4, 250, 172, 187, 118]));
/// RA: GDRA22WR2WWHNZD5MC3CALIO3D335SRZARV2XXC7M7S4BPR4UEB6J7DD
static immutable RA = KeyPair(PublicKey([226, 13, 106, 209, 213, 172, 118, 228, 125, 96, 182, 32, 45, 14, 216, 247, 190, 202, 57, 4, 107, 171, 220, 95, 103, 229, 192, 190, 60, 161, 3, 228]), SecretKey([208, 51, 14, 213, 27, 141, 180, 118, 38, 19, 163, 235, 16, 74, 11, 44, 132, 168, 10, 14, 31, 119, 30, 147, 125, 162, 123, 13, 241, 144, 56, 77]), Seed([121, 236, 20, 82, 130, 98, 215, 218, 118, 114, 161, 160, 142, 73, 180, 82, 132, 103, 156, 229, 63, 155, 173, 113, 105, 197, 41, 201, 220, 238, 121, 229]));
/// RB: GDRB22V6FC5PI7HFAKFP5BGF6MWGOXTKR2JSPVM6WRXUXMNU66DIMS46
static immutable RB = KeyPair(PublicKey([226, 29, 106, 190, 40, 186, 244, 124, 229, 2, 138, 254, 132, 197, 243, 44, 103, 94, 106, 142, 147, 39, 213, 158, 180, 111, 75, 177, 180, 247, 134, 134]), SecretKey([120, 106, 37, 119, 115, 195, 228, 217, 134, 93, 39, 107, 116, 184, 54, 6, 33, 141, 117, 27, 139, 137, 75, 31, 148, 169, 21, 13, 254, 8, 14, 76]), Seed([209, 116, 92, 42, 182, 235, 40, 195, 109, 219, 152, 254, 224, 91, 34, 161, 29, 194, 113, 174, 180, 101, 168, 238, 232, 171, 120, 50, 122, 121, 228, 82]));
/// RC: GDRC22MDKPHFVZYSKXGGXFQGTVST2ATRSMOOVCNG3OZPO2C5TDTWVIA7
static immutable RC = KeyPair(PublicKey([226, 45, 105, 131, 83, 206, 90, 231, 18, 85, 204, 107, 150, 6, 157, 101, 61, 2, 113, 147, 28, 234, 137, 166, 219, 178, 247, 104, 93, 152, 231, 106]), SecretKey([32, 231, 115, 239, 207, 45, 53, 122, 66, 63, 215, 55, 45, 52, 146, 13, 143, 58, 43, 2, 16, 47, 5, 133, 162, 50, 190, 99, 113, 150, 240, 100]), Seed([1, 0, 37, 89, 206, 193, 56, 93, 18, 114, 6, 172, 200, 136, 159, 254, 171, 137, 133, 39, 34, 138, 186, 44, 27, 208, 25, 229, 45, 123, 249, 210]));
/// RD: GDRD22QJ3X2YOL32HLBR2ZCGCFZD45YTXR72QW32LIG3YBMXFR2XKANL
static immutable RD = KeyPair(PublicKey([226, 61, 106, 9, 221, 245, 135, 47, 122, 58, 195, 29, 100, 70, 17, 114, 62, 119, 19, 188, 127, 168, 91, 122, 90, 13, 188, 5, 151, 44, 117, 117]), SecretKey([176, 29, 25, 173, 241, 70, 202, 143, 215, 93, 39, 86, 116, 136, 157, 19, 139, 158, 55, 97, 52, 209, 108, 95, 51, 218, 191, 25, 165, 24, 60, 114]), Seed([87, 134, 22, 221, 243, 13, 218, 106, 107, 30, 61, 99, 16, 9, 236, 223, 130, 131, 77, 251, 3, 216, 153, 236, 85, 41, 164, 167, 23, 130, 190, 8]));
/// RE: GDRE22EBTSW7LAZOVUG3OHDLB4VRGFC5ELPYANBARYXPIZBJSLDG6TGM
static immutable RE = KeyPair(PublicKey([226, 77, 104, 129, 156, 173, 245, 131, 46, 173, 13, 183, 28, 107, 15, 43, 19, 20, 93, 34, 223, 128, 52, 32, 142, 46, 244, 100, 41, 146, 198, 111]), SecretKey([56, 162, 34, 106, 45, 77, 8, 52, 9, 189, 51, 212, 115, 23, 251, 243, 30, 148, 189, 150, 170, 16, 112, 241, 97, 76, 29, 82, 131, 216, 233, 110]), Seed([63, 126, 66, 168, 98, 10, 141, 123, 7, 204, 180, 147, 23, 122, 61, 53, 27, 212, 4, 219, 115, 156, 172, 47, 220, 52, 78, 27, 200, 134, 147, 177]));
/// RF: GDRF22LS7MV7YADFT43BMZVMV2AM5F5Z3AGI7223DZFU35FG2PIJHETM
static immutable RF = KeyPair(PublicKey([226, 93, 105, 114, 251, 43, 252, 0, 101, 159, 54, 22, 102, 172, 174, 128, 206, 151, 185, 216, 12, 143, 235, 91, 30, 75, 77, 244, 166, 211, 208, 147]), SecretKey([208, 1, 157, 73, 2, 20, 10, 195, 218, 186, 90, 185, 173, 46, 29, 18, 51, 50, 176, 140, 64, 171, 11, 15, 137, 56, 255, 222, 232, 91, 101, 112]), Seed([100, 94, 231, 226, 188, 92, 55, 112, 238, 209, 51, 65, 41, 119, 170, 14, 5, 45, 24, 8, 35, 93, 141, 10, 43, 137, 110, 190, 84, 154, 193, 69]));
/// RG: GDRG22TKLN5QTC4SAYP6MBJEY3THOVAJUWYSGNIKGGFDA6KFUTNSIMZJ
static immutable RG = KeyPair(PublicKey([226, 109, 106, 106, 91, 123, 9, 139, 146, 6, 31, 230, 5, 36, 198, 230, 119, 84, 9, 165, 177, 35, 53, 10, 49, 138, 48, 121, 69, 164, 219, 36]), SecretKey([168, 212, 91, 109, 232, 34, 4, 255, 144, 191, 96, 26, 224, 140, 35, 54, 14, 97, 67, 73, 92, 90, 154, 215, 180, 0, 92, 201, 36, 125, 82, 109]), Seed([69, 212, 191, 142, 209, 74, 202, 253, 101, 145, 173, 187, 208, 169, 183, 99, 83, 56, 85, 19, 223, 219, 185, 124, 183, 154, 253, 50, 5, 109, 208, 110]));
/// RH: GDRH22G5ELZCRYJRTGI7QFC5PJFURJWAAC5EKBPNGEZAZEK22GHDJQW6
static immutable RH = KeyPair(PublicKey([226, 125, 104, 221, 34, 242, 40, 225, 49, 153, 145, 248, 20, 93, 122, 75, 72, 166, 192, 0, 186, 69, 5, 237, 49, 50, 12, 145, 90, 209, 142, 52]), SecretKey([120, 51, 77, 6, 110, 163, 38, 206, 198, 82, 221, 138, 155, 182, 39, 237, 215, 201, 1, 62, 32, 129, 205, 137, 110, 78, 197, 215, 111, 153, 240, 103]), Seed([224, 45, 181, 110, 36, 181, 108, 250, 29, 237, 24, 250, 252, 49, 168, 141, 4, 59, 181, 92, 245, 11, 89, 79, 9, 179, 10, 135, 1, 253, 254, 127]));
/// RI: GDRI22RIX2KLHTBZZDZPQPKLCT6YKRJ6ZDH5P2X7SLLO7JKEQZXFLYNI
static immutable RI = KeyPair(PublicKey([226, 141, 106, 40, 190, 148, 179, 204, 57, 200, 242, 248, 61, 75, 20, 253, 133, 69, 62, 200, 207, 215, 234, 255, 146, 214, 239, 165, 68, 134, 110, 85]), SecretKey([176, 220, 37, 139, 106, 183, 146, 157, 246, 87, 68, 115, 251, 243, 68, 118, 192, 142, 74, 101, 134, 175, 95, 243, 13, 227, 236, 230, 115, 188, 133, 75]), Seed([57, 90, 178, 83, 189, 115, 155, 182, 56, 132, 235, 17, 193, 248, 6, 135, 114, 236, 116, 195, 4, 22, 208, 47, 182, 62, 176, 13, 235, 49, 131, 154]));
/// RJ: GDRJ22LSEOXJN77SF2PCKSVGXQPYYOZ6N4NJQUG5GLT6WZIEUCNQB4XT
static immutable RJ = KeyPair(PublicKey([226, 157, 105, 114, 35, 174, 150, 255, 242, 46, 158, 37, 74, 166, 188, 31, 140, 59, 62, 111, 26, 152, 80, 221, 50, 231, 235, 101, 4, 160, 155, 0]), SecretKey([224, 55, 223, 22, 50, 145, 183, 105, 13, 31, 248, 227, 130, 254, 232, 182, 44, 210, 115, 146, 22, 75, 243, 155, 30, 112, 118, 81, 227, 156, 101, 100]), Seed([21, 69, 208, 228, 210, 64, 115, 222, 163, 125, 54, 119, 246, 40, 198, 140, 163, 14, 238, 207, 211, 80, 139, 5, 207, 28, 176, 191, 218, 122, 121, 166]));
/// RK: GDRK22CO276UAEC5WLHL3I6657SGDMQA4UZHDBC6OATPR5QF7VYKLPMD
static immutable RK = KeyPair(PublicKey([226, 173, 104, 78, 215, 253, 64, 16, 93, 178, 206, 189, 163, 222, 239, 228, 97, 178, 0, 229, 50, 113, 132, 94, 112, 38, 248, 246, 5, 253, 112, 165]), SecretKey([104, 14, 171, 166, 242, 46, 42, 82, 48, 1, 93, 7, 248, 182, 120, 129, 3, 17, 237, 4, 40, 129, 127, 31, 238, 163, 221, 141, 91, 238, 23, 66]), Seed([203, 195, 21, 75, 109, 186, 98, 183, 60, 8, 181, 57, 184, 119, 118, 217, 166, 221, 45, 224, 183, 120, 188, 176, 28, 188, 240, 194, 87, 214, 25, 78]));
/// RL: GDRL22OQIZGKWNT2XGUHRKBDSCVYPNOD44DXBS52FWZQPRNAICN4CIL6
static immutable RL = KeyPair(PublicKey([226, 189, 105, 208, 70, 76, 171, 54, 122, 185, 168, 120, 168, 35, 144, 171, 135, 181, 195, 231, 7, 112, 203, 186, 45, 179, 7, 197, 160, 64, 155, 193]), SecretKey([128, 139, 55, 4, 40, 89, 121, 44, 74, 176, 99, 161, 236, 184, 128, 242, 242, 148, 225, 189, 132, 134, 240, 22, 51, 215, 229, 253, 5, 239, 56, 66]), Seed([39, 39, 146, 131, 117, 146, 151, 27, 95, 37, 244, 208, 118, 224, 214, 20, 4, 46, 222, 8, 93, 30, 28, 235, 237, 51, 172, 115, 97, 1, 110, 158]));
/// RM: GDRM224GYAFW3RUUTAXRKRKYP3WFFIWGIL7HIIU3ZA27QS2P6MJWHCAJ
static immutable RM = KeyPair(PublicKey([226, 205, 107, 134, 192, 11, 109, 198, 148, 152, 47, 21, 69, 88, 126, 236, 82, 162, 198, 66, 254, 116, 34, 155, 200, 53, 248, 75, 79, 243, 19, 99]), SecretKey([160, 67, 241, 233, 175, 235, 149, 175, 33, 100, 23, 255, 85, 166, 135, 85, 248, 84, 141, 178, 22, 97, 141, 204, 201, 93, 137, 167, 29, 43, 66, 127]), Seed([255, 175, 249, 166, 108, 0, 179, 32, 224, 185, 70, 38, 158, 148, 182, 155, 115, 228, 98, 208, 211, 126, 117, 48, 125, 90, 120, 36, 152, 8, 71, 105]));
/// RN: GDRN22ZZ4KEOY3UXCBDX2EZBVVNYC6VCEVVIYDNY74RNCRX2GPUDP6AR
static immutable RN = KeyPair(PublicKey([226, 221, 107, 57, 226, 136, 236, 110, 151, 16, 71, 125, 19, 33, 173, 91, 129, 122, 162, 37, 106, 140, 13, 184, 255, 34, 209, 70, 250, 51, 232, 55]), SecretKey([208, 232, 135, 111, 12, 6, 110, 247, 229, 57, 142, 229, 15, 234, 221, 194, 156, 222, 138, 36, 84, 210, 164, 59, 85, 225, 81, 52, 181, 118, 131, 97]), Seed([94, 155, 251, 107, 119, 97, 114, 55, 105, 84, 246, 185, 38, 106, 179, 85, 175, 69, 248, 47, 51, 140, 240, 64, 147, 14, 74, 62, 121, 126, 187, 35]));
/// RO: GDRO22MNEJQ2VY4HLTJWCM6YHAUN6FBIL426FR6GDLEBJRMAVFC5RREL
static immutable RO = KeyPair(PublicKey([226, 237, 105, 141, 34, 97, 170, 227, 135, 92, 211, 97, 51, 216, 56, 40, 223, 20, 40, 95, 53, 226, 199, 198, 26, 200, 20, 197, 128, 169, 69, 216]), SecretKey([176, 141, 132, 17, 202, 72, 3, 124, 246, 202, 163, 215, 210, 116, 2, 29, 100, 65, 171, 21, 254, 93, 51, 224, 182, 152, 129, 27, 221, 186, 48, 120]), Seed([166, 21, 55, 115, 211, 41, 219, 201, 50, 60, 93, 239, 217, 89, 215, 5, 99, 33, 74, 242, 173, 164, 25, 58, 177, 180, 78, 124, 228, 137, 139, 86]));
/// RP: GDRP227TOAVS72RUWLSNNPANEYQL52MJFJXY3757VKV5IQ3TZLHCYESH
static immutable RP = KeyPair(PublicKey([226, 253, 107, 243, 112, 43, 47, 234, 52, 178, 228, 214, 188, 13, 38, 32, 190, 233, 137, 42, 111, 141, 255, 191, 170, 171, 212, 67, 115, 202, 206, 44]), SecretKey([40, 31, 231, 139, 36, 73, 42, 219, 102, 199, 35, 102, 132, 164, 141, 11, 237, 166, 244, 80, 157, 223, 105, 78, 45, 9, 47, 47, 156, 241, 159, 103]), Seed([130, 32, 92, 13, 199, 217, 29, 73, 182, 126, 156, 75, 251, 122, 245, 60, 90, 205, 19, 199, 225, 151, 7, 73, 202, 198, 4, 93, 213, 219, 214, 50]));
/// RQ: GDRQ22DRNYMC7GMVVMZS2EORPIWQ4GV4B32X6I2C2BIMZE3SNLKBW6TO
static immutable RQ = KeyPair(PublicKey([227, 13, 104, 113, 110, 24, 47, 153, 149, 171, 51, 45, 17, 209, 122, 45, 14, 26, 188, 14, 245, 127, 35, 66, 208, 80, 204, 147, 114, 106, 212, 27]), SecretKey([112, 30, 28, 12, 217, 56, 198, 87, 130, 23, 22, 40, 59, 169, 26, 250, 40, 126, 82, 42, 62, 38, 178, 245, 170, 21, 248, 12, 8, 229, 253, 97]), Seed([72, 63, 187, 5, 69, 114, 237, 91, 157, 140, 67, 250, 84, 73, 132, 139, 8, 76, 46, 96, 221, 250, 56, 174, 123, 29, 219, 255, 248, 55, 217, 190]));
/// RR: GDRR2276ZPGDBQYMTG2DETUB6D2WMPQRYSMYR7HCXVQKUSYVFOHT5BR6
static immutable RR = KeyPair(PublicKey([227, 29, 107, 254, 203, 204, 48, 195, 12, 153, 180, 50, 78, 129, 240, 245, 102, 62, 17, 196, 153, 136, 252, 226, 189, 96, 170, 75, 21, 43, 143, 62]), SecretKey([200, 127, 204, 185, 106, 56, 146, 72, 155, 35, 106, 84, 5, 168, 36, 69, 167, 202, 4, 243, 247, 240, 6, 254, 164, 42, 198, 30, 47, 51, 63, 71]), Seed([113, 32, 63, 195, 88, 132, 235, 244, 83, 54, 31, 205, 203, 174, 5, 140, 146, 37, 7, 64, 153, 247, 248, 164, 246, 44, 133, 244, 191, 100, 150, 72]));
/// RS: GDRS22DTKJUVVSUPJWUDJMP3BFDJPWKVP42BBYG4YYL3GNS255MSDGGE
static immutable RS = KeyPair(PublicKey([227, 45, 104, 115, 82, 105, 90, 202, 143, 77, 168, 52, 177, 251, 9, 70, 151, 217, 85, 127, 52, 16, 224, 220, 198, 23, 179, 54, 90, 239, 89, 33]), SecretKey([160, 37, 21, 169, 146, 227, 103, 19, 166, 87, 85, 35, 49, 46, 238, 245, 50, 34, 231, 202, 158, 56, 99, 78, 104, 117, 184, 222, 184, 16, 47, 82]), Seed([114, 138, 204, 179, 244, 192, 24, 73, 233, 63, 233, 4, 83, 44, 64, 167, 253, 72, 220, 58, 4, 203, 102, 136, 102, 112, 78, 35, 197, 210, 161, 195]));
/// RT: GDRT22HJD7HAS66WJBNAUXTERBH7GVNX3SGAP3LE3TOGWEU2ME22VJQR
static immutable RT = KeyPair(PublicKey([227, 61, 104, 233, 31, 206, 9, 123, 214, 72, 90, 10, 94, 100, 136, 79, 243, 85, 183, 220, 140, 7, 237, 100, 220, 220, 107, 18, 154, 97, 53, 170]), SecretKey([120, 66, 123, 169, 106, 216, 0, 207, 123, 156, 215, 84, 184, 137, 63, 49, 98, 38, 130, 93, 118, 38, 54, 172, 27, 25, 150, 101, 236, 246, 120, 97]), Seed([117, 210, 189, 109, 74, 217, 233, 104, 44, 7, 128, 102, 114, 182, 247, 122, 3, 244, 29, 93, 124, 181, 65, 252, 107, 211, 129, 165, 49, 58, 69, 127]));
/// RU: GDRU22ANLUMFCCJ2SXJHDB2RG5LIMT3BLDNZPFFHITCSSQTCVYEVMRQF
static immutable RU = KeyPair(PublicKey([227, 77, 104, 13, 93, 24, 81, 9, 58, 149, 210, 113, 135, 81, 55, 86, 134, 79, 97, 88, 219, 151, 148, 167, 68, 197, 41, 66, 98, 174, 9, 86]), SecretKey([184, 76, 255, 3, 160, 14, 146, 82, 248, 3, 8, 145, 75, 236, 78, 26, 0, 114, 199, 207, 148, 31, 77, 140, 172, 109, 163, 204, 120, 140, 208, 75]), Seed([63, 228, 212, 168, 24, 240, 79, 86, 189, 224, 144, 94, 56, 139, 88, 229, 1, 128, 194, 58, 34, 226, 34, 183, 13, 163, 50, 52, 91, 82, 156, 66]));
/// RV: GDRV225HOIIQI5D765NPO476LGSQZ4I4UNA7TYHQXBGZXZI4IP5T332Z
static immutable RV = KeyPair(PublicKey([227, 93, 107, 167, 114, 17, 4, 116, 127, 247, 90, 247, 115, 254, 89, 165, 12, 241, 28, 163, 65, 249, 224, 240, 184, 77, 155, 229, 28, 67, 251, 61]), SecretKey([200, 55, 215, 210, 231, 218, 110, 188, 161, 48, 29, 73, 159, 91, 248, 16, 208, 104, 147, 130, 146, 64, 213, 245, 230, 175, 200, 244, 215, 52, 30, 112]), Seed([120, 204, 208, 89, 106, 106, 194, 121, 81, 144, 209, 90, 142, 122, 101, 82, 197, 10, 200, 2, 158, 232, 46, 0, 252, 78, 209, 165, 29, 43, 126, 86]));
/// RW: GDRW227SBX7YD2THAQMEH3J7WHBPI3VRPAZJP6FSHCUDV5UITKBGGRDZ
static immutable RW = KeyPair(PublicKey([227, 109, 107, 242, 13, 255, 129, 234, 103, 4, 24, 67, 237, 63, 177, 194, 244, 110, 177, 120, 50, 151, 248, 178, 56, 168, 58, 246, 136, 154, 130, 99]), SecretKey([96, 99, 218, 29, 39, 134, 162, 92, 114, 154, 210, 132, 162, 42, 1, 1, 103, 198, 142, 216, 92, 33, 146, 186, 204, 214, 16, 230, 173, 68, 111, 68]), Seed([80, 205, 83, 80, 179, 133, 166, 86, 111, 161, 227, 38, 73, 137, 89, 49, 76, 49, 113, 133, 161, 26, 87, 170, 85, 82, 38, 72, 241, 55, 139, 67]));
/// RX: GDRX22WMOA6QA36NOLIVZCKXWFYITDW3PXETQSNDULAL4CI3L7YG3L4Z
static immutable RX = KeyPair(PublicKey([227, 125, 106, 204, 112, 61, 0, 111, 205, 114, 209, 92, 137, 87, 177, 112, 137, 142, 219, 125, 201, 56, 73, 163, 162, 192, 190, 9, 27, 95, 240, 109]), SecretKey([160, 2, 77, 49, 122, 96, 183, 137, 246, 169, 49, 102, 97, 56, 243, 184, 41, 53, 145, 44, 249, 38, 84, 231, 49, 163, 207, 69, 248, 216, 160, 78]), Seed([246, 181, 229, 5, 100, 67, 48, 178, 17, 11, 94, 58, 252, 3, 46, 165, 138, 62, 128, 50, 252, 230, 40, 96, 186, 234, 33, 132, 59, 149, 251, 202]));
/// RY: GDRY223B7H4D7QVLPCVOYAMXPHG2FKH53BL72NNC32Q2GJINLUAKJJ37
static immutable RY = KeyPair(PublicKey([227, 141, 107, 97, 249, 248, 63, 194, 171, 120, 170, 236, 1, 151, 121, 205, 162, 168, 253, 216, 87, 253, 53, 162, 222, 161, 163, 37, 13, 93, 0, 164]), SecretKey([104, 39, 17, 210, 189, 127, 100, 168, 21, 67, 173, 91, 189, 253, 232, 34, 230, 144, 185, 246, 142, 38, 148, 55, 212, 89, 151, 56, 157, 37, 236, 92]), Seed([249, 17, 74, 85, 250, 156, 1, 69, 194, 121, 195, 181, 45, 204, 68, 112, 212, 32, 127, 168, 246, 255, 48, 56, 70, 161, 251, 111, 169, 16, 251, 225]));
/// RZ: GDRZ226VTNAEQWZ4OZGEVP6WV5I2ARXCDMDTO7LWAPO6PCL3WTWOV6QR
static immutable RZ = KeyPair(PublicKey([227, 157, 107, 213, 155, 64, 72, 91, 60, 118, 76, 74, 191, 214, 175, 81, 160, 70, 226, 27, 7, 55, 125, 118, 3, 221, 231, 137, 123, 180, 236, 234]), SecretKey([48, 238, 165, 59, 185, 142, 213, 188, 1, 207, 21, 252, 137, 90, 172, 194, 156, 198, 176, 98, 177, 189, 252, 58, 78, 127, 249, 97, 2, 204, 193, 102]), Seed([61, 181, 64, 71, 6, 179, 94, 67, 146, 132, 248, 73, 62, 155, 13, 9, 22, 235, 101, 79, 45, 208, 62, 217, 251, 177, 150, 209, 124, 51, 184, 122]));
/// SA: GDSA22CWNSRAMO5K5QGKNE7MGHANX4R24QQZ4WBMKKBUIRUBKROLL3GI
static immutable SA = KeyPair(PublicKey([228, 13, 104, 86, 108, 162, 6, 59, 170, 236, 12, 166, 147, 236, 49, 192, 219, 242, 58, 228, 33, 158, 88, 44, 82, 131, 68, 70, 129, 84, 92, 181]), SecretKey([40, 153, 104, 174, 226, 128, 142, 66, 158, 57, 53, 135, 110, 93, 221, 14, 194, 66, 8, 201, 225, 116, 55, 194, 107, 236, 116, 222, 207, 70, 248, 100]), Seed([127, 246, 34, 222, 117, 31, 178, 191, 183, 208, 127, 60, 17, 73, 203, 200, 99, 52, 158, 74, 169, 149, 158, 206, 253, 43, 78, 218, 40, 198, 195, 44]));
/// SB: GDSB22YYB5EM4P2O4MJVAF7JN6ICI6YVULPAQZ7KHOZJDZOOBI4LC2XF
static immutable SB = KeyPair(PublicKey([228, 29, 107, 24, 15, 72, 206, 63, 78, 227, 19, 80, 23, 233, 111, 144, 36, 123, 21, 162, 222, 8, 103, 234, 59, 178, 145, 229, 206, 10, 56, 177]), SecretKey([248, 199, 123, 175, 84, 40, 8, 135, 247, 79, 86, 120, 190, 20, 152, 66, 74, 131, 92, 93, 37, 59, 193, 76, 101, 139, 104, 129, 130, 32, 162, 88]), Seed([41, 109, 11, 133, 183, 192, 197, 50, 183, 14, 183, 171, 151, 115, 57, 105, 65, 199, 38, 0, 44, 254, 52, 100, 252, 1, 235, 99, 223, 110, 240, 40]));
/// SC: GDSC222EL6U7ERYOFL5PFAE665KQFO7GRYDMUZZYKSOSKTNUQAUJOAZ5
static immutable SC = KeyPair(PublicKey([228, 45, 107, 68, 95, 169, 242, 71, 14, 42, 250, 242, 128, 158, 247, 85, 2, 187, 230, 142, 6, 202, 103, 56, 84, 157, 37, 77, 180, 128, 40, 151]), SecretKey([216, 23, 196, 65, 205, 79, 4, 205, 4, 156, 71, 134, 204, 229, 238, 249, 41, 170, 236, 66, 230, 210, 100, 143, 83, 77, 132, 243, 61, 50, 167, 74]), Seed([33, 220, 24, 86, 19, 173, 191, 255, 23, 45, 209, 188, 243, 77, 94, 63, 205, 127, 255, 109, 204, 32, 20, 143, 136, 130, 120, 132, 223, 137, 34, 253]));
/// SD: GDSD22UJWUR5SZJXXYESP7HGL6TNPEXDNKLPDWBJXXUUWSBY7OCTHPNQ
static immutable SD = KeyPair(PublicKey([228, 61, 106, 137, 181, 35, 217, 101, 55, 190, 9, 39, 252, 230, 95, 166, 215, 146, 227, 106, 150, 241, 216, 41, 189, 233, 75, 72, 56, 251, 133, 51]), SecretKey([64, 167, 222, 228, 54, 26, 128, 77, 114, 31, 173, 161, 223, 200, 122, 63, 196, 90, 1, 79, 254, 108, 20, 144, 49, 109, 22, 214, 44, 140, 187, 124]), Seed([154, 247, 246, 167, 156, 125, 61, 55, 144, 220, 91, 155, 172, 105, 221, 127, 82, 1, 183, 175, 80, 29, 175, 115, 182, 214, 173, 93, 104, 253, 210, 109]));
/// SE: GDSE22RG66BUFJAMDDCZE5KLDRG572HAVNJWIBUIATOTTGHQ2PZTZE53
static immutable SE = KeyPair(PublicKey([228, 77, 106, 38, 247, 131, 66, 164, 12, 24, 197, 146, 117, 75, 28, 77, 223, 232, 224, 171, 83, 100, 6, 136, 4, 221, 57, 152, 240, 211, 243, 60]), SecretKey([128, 65, 205, 6, 100, 246, 86, 193, 32, 79, 16, 8, 196, 60, 66, 203, 136, 98, 187, 21, 196, 83, 181, 36, 201, 242, 27, 162, 138, 191, 62, 123]), Seed([199, 31, 123, 157, 72, 232, 176, 199, 183, 207, 33, 255, 149, 172, 67, 86, 29, 188, 68, 203, 38, 29, 223, 32, 82, 158, 84, 68, 75, 133, 39, 232]));
/// SF: GDSF22DWKK2BOSOGTAQQXGLOKA2DGZ4B3X5KFAFZT4F2FAPWN2IEAP5L
static immutable SF = KeyPair(PublicKey([228, 93, 104, 118, 82, 180, 23, 73, 198, 152, 33, 11, 153, 110, 80, 52, 51, 103, 129, 221, 250, 162, 128, 185, 159, 11, 162, 129, 246, 110, 144, 64]), SecretKey([168, 124, 231, 87, 237, 77, 141, 198, 152, 7, 114, 16, 156, 84, 224, 39, 109, 80, 39, 17, 94, 92, 127, 9, 215, 204, 173, 116, 18, 167, 110, 98]), Seed([255, 156, 99, 137, 152, 108, 10, 17, 252, 254, 189, 65, 152, 29, 211, 150, 13, 49, 113, 179, 168, 182, 243, 50, 223, 114, 85, 26, 171, 122, 152, 225]));
/// SG: GDSG22ZDV5WWI732WXNM2JPEI2M5I4K2YTDVOYNMBXBQSGWQ34UOIB23
static immutable SG = KeyPair(PublicKey([228, 109, 107, 35, 175, 109, 100, 127, 122, 181, 218, 205, 37, 228, 70, 153, 212, 113, 90, 196, 199, 87, 97, 172, 13, 195, 9, 26, 208, 223, 40, 228]), SecretKey([248, 144, 246, 146, 151, 189, 117, 187, 229, 23, 211, 10, 176, 59, 186, 120, 209, 151, 253, 52, 34, 216, 177, 87, 158, 162, 193, 3, 119, 247, 165, 113]), Seed([204, 227, 141, 46, 232, 71, 154, 180, 198, 70, 96, 46, 7, 200, 183, 11, 157, 17, 58, 143, 96, 37, 57, 251, 117, 152, 144, 213, 166, 51, 224, 242]));
/// SH: GDSH22V5AITZO4EV4GM6ACMMC27DO3PQD6OWED5G67XAJPBJ2NKMCBOU
static immutable SH = KeyPair(PublicKey([228, 125, 106, 189, 2, 39, 151, 112, 149, 225, 153, 224, 9, 140, 22, 190, 55, 109, 240, 31, 157, 98, 15, 166, 247, 238, 4, 188, 41, 211, 84, 193]), SecretKey([224, 70, 47, 236, 205, 64, 139, 71, 172, 250, 126, 11, 0, 224, 85, 248, 172, 35, 220, 125, 148, 68, 180, 193, 246, 98, 93, 104, 156, 190, 49, 118]), Seed([41, 57, 59, 50, 76, 142, 102, 156, 238, 38, 102, 97, 130, 189, 60, 91, 118, 126, 253, 247, 121, 230, 247, 71, 235, 37, 197, 139, 104, 4, 170, 166]));
/// SI: GDSI225Q4YBO7O66C2SCY2TVGQVGETCPJOD67TTJSV2QUGQG2ZNWEJEJ
static immutable SI = KeyPair(PublicKey([228, 141, 107, 176, 230, 2, 239, 187, 222, 22, 164, 44, 106, 117, 52, 42, 98, 76, 79, 75, 135, 239, 206, 105, 149, 117, 10, 26, 6, 214, 91, 98]), SecretKey([80, 83, 229, 38, 91, 116, 148, 14, 29, 121, 193, 133, 16, 105, 28, 156, 143, 248, 109, 155, 97, 146, 219, 188, 173, 173, 29, 28, 211, 246, 206, 116]), Seed([160, 94, 80, 115, 174, 71, 181, 254, 230, 96, 243, 48, 37, 181, 183, 104, 198, 32, 84, 116, 60, 100, 82, 116, 102, 207, 11, 151, 226, 139, 31, 64]));
/// SJ: GDSJ22A3GGQM7D37PLMZHO3VLWHXSCBGC5FJGHIGDYRQDAGNBE4BJQ5L
static immutable SJ = KeyPair(PublicKey([228, 157, 104, 27, 49, 160, 207, 143, 127, 122, 217, 147, 187, 117, 93, 143, 121, 8, 38, 23, 74, 147, 29, 6, 30, 35, 1, 128, 205, 9, 56, 20]), SecretKey([96, 85, 36, 254, 6, 78, 23, 139, 91, 216, 91, 199, 201, 13, 248, 8, 213, 126, 115, 31, 153, 101, 240, 102, 28, 28, 103, 156, 33, 238, 48, 101]), Seed([91, 208, 110, 229, 27, 184, 83, 77, 200, 238, 147, 151, 126, 15, 194, 19, 218, 172, 178, 102, 91, 114, 123, 102, 167, 235, 152, 227, 107, 158, 87, 193]));
/// SK: GDSK224DLB7CMT233SLVOJWZUA3XX54QI6T65PF2Y6P75OTWQP3K3W3W
static immutable SK = KeyPair(PublicKey([228, 173, 107, 131, 88, 126, 38, 79, 91, 220, 151, 87, 38, 217, 160, 55, 123, 247, 144, 71, 167, 238, 188, 186, 199, 159, 254, 186, 118, 131, 246, 173]), SecretKey([240, 86, 97, 30, 2, 49, 67, 79, 55, 67, 175, 82, 100, 46, 133, 122, 45, 45, 167, 52, 30, 33, 14, 104, 234, 72, 55, 58, 242, 248, 21, 120]), Seed([252, 52, 3, 230, 190, 131, 21, 142, 102, 224, 55, 204, 37, 50, 91, 26, 26, 240, 71, 220, 106, 70, 200, 83, 94, 115, 134, 26, 152, 166, 107, 230]));
/// SL: GDSL22RFISUF25P5ZQFGR6UZMQZZK4DXOTB6BQI5GNPU2HGDN5F4EHKE
static immutable SL = KeyPair(PublicKey([228, 189, 106, 37, 68, 168, 93, 117, 253, 204, 10, 104, 250, 153, 100, 51, 149, 112, 119, 116, 195, 224, 193, 29, 51, 95, 77, 28, 195, 111, 75, 194]), SecretKey([16, 0, 50, 218, 249, 171, 99, 88, 221, 251, 91, 60, 168, 201, 216, 17, 146, 162, 119, 128, 30, 100, 97, 155, 231, 213, 87, 128, 162, 209, 190, 87]), Seed([44, 145, 80, 218, 3, 207, 219, 49, 86, 169, 152, 169, 142, 160, 22, 238, 179, 206, 101, 129, 41, 165, 223, 170, 255, 30, 124, 33, 84, 134, 177, 117]));
/// SM: GDSM22YFJS4K4BSTUG73VCL2AULBIDGBYND2HMTPOL5AG5INP2EDVJ24
static immutable SM = KeyPair(PublicKey([228, 205, 107, 5, 76, 184, 174, 6, 83, 161, 191, 186, 137, 122, 5, 22, 20, 12, 193, 195, 71, 163, 178, 111, 114, 250, 3, 117, 13, 126, 136, 58]), SecretKey([112, 9, 164, 197, 104, 216, 136, 205, 106, 189, 98, 166, 165, 55, 18, 37, 126, 252, 247, 79, 196, 178, 144, 5, 87, 221, 97, 187, 211, 178, 94, 114]), Seed([124, 141, 8, 150, 2, 195, 219, 218, 61, 64, 81, 109, 21, 218, 174, 174, 104, 77, 201, 205, 37, 197, 25, 59, 51, 82, 14, 129, 2, 238, 134, 148]));
/// SN: GDSN22HEQTZNWN7IZLYAKQZ235UDOUF2WUTZWXZGHDCMBWFFZIENS7BT
static immutable SN = KeyPair(PublicKey([228, 221, 104, 228, 132, 242, 219, 55, 232, 202, 240, 5, 67, 58, 223, 104, 55, 80, 186, 181, 39, 155, 95, 38, 56, 196, 192, 216, 165, 202, 8, 217]), SecretKey([120, 189, 102, 1, 76, 23, 155, 190, 176, 250, 21, 237, 239, 204, 164, 117, 67, 145, 67, 77, 42, 84, 166, 119, 171, 97, 183, 201, 21, 133, 47, 83]), Seed([251, 5, 76, 162, 197, 141, 133, 248, 112, 127, 235, 129, 52, 89, 47, 39, 22, 75, 102, 88, 213, 54, 244, 157, 0, 163, 25, 204, 96, 59, 0, 28]));
/// SO: GDSO22GOPW5HSZGLYRG7ZIDPBZRLJJXOH4VNRECLKTRRTZYHZNECSMMD
static immutable SO = KeyPair(PublicKey([228, 237, 104, 206, 125, 186, 121, 100, 203, 196, 77, 252, 160, 111, 14, 98, 180, 166, 238, 63, 42, 216, 144, 75, 84, 227, 25, 231, 7, 203, 72, 41]), SecretKey([184, 28, 95, 131, 223, 186, 183, 19, 17, 211, 5, 18, 164, 93, 52, 232, 12, 192, 146, 133, 103, 184, 3, 124, 151, 20, 223, 123, 212, 219, 134, 101]), Seed([87, 44, 80, 67, 163, 204, 47, 176, 15, 75, 101, 253, 112, 31, 49, 171, 4, 236, 45, 115, 153, 208, 151, 136, 98, 52, 189, 229, 2, 69, 5, 57]));
/// SP: GDSP226LYS2FTWHLKWEU5VQFIFJHSMGMWYPQFCJK2EY3G3MRV3UKZZ7E
static immutable SP = KeyPair(PublicKey([228, 253, 107, 203, 196, 180, 89, 216, 235, 85, 137, 78, 214, 5, 65, 82, 121, 48, 204, 182, 31, 2, 137, 42, 209, 49, 179, 109, 145, 174, 232, 172]), SecretKey([80, 72, 163, 241, 190, 141, 55, 203, 42, 234, 184, 65, 218, 119, 45, 44, 103, 217, 35, 65, 184, 248, 215, 164, 58, 12, 81, 28, 19, 10, 43, 113]), Seed([13, 127, 247, 109, 80, 69, 61, 116, 86, 157, 116, 245, 242, 154, 117, 32, 31, 125, 28, 158, 69, 107, 31, 124, 153, 111, 132, 40, 101, 48, 60, 130]));
/// SQ: GDSQ22JUZQZYLEJKQBJYJL3MHMXBBPCSMTIXZGH7ACCLFFS5FMI27MN2
static immutable SQ = KeyPair(PublicKey([229, 13, 105, 52, 204, 51, 133, 145, 42, 128, 83, 132, 175, 108, 59, 46, 16, 188, 82, 100, 209, 124, 152, 255, 0, 132, 178, 150, 93, 43, 17, 175]), SecretKey([64, 41, 239, 81, 225, 183, 150, 85, 215, 122, 63, 71, 71, 190, 30, 8, 159, 239, 129, 160, 64, 141, 63, 100, 6, 237, 16, 109, 117, 68, 250, 82]), Seed([246, 219, 188, 96, 0, 112, 109, 137, 145, 20, 30, 27, 93, 37, 102, 68, 39, 86, 29, 71, 107, 190, 222, 200, 174, 238, 36, 132, 91, 166, 175, 184]));
/// SR: GDSR22PT3EHCCKXQ4RGPXLKORCWDA4PP42DZC6FD4EBYEBVYR3R3JBFC
static immutable SR = KeyPair(PublicKey([229, 29, 105, 243, 217, 14, 33, 42, 240, 228, 76, 251, 173, 78, 136, 172, 48, 113, 239, 230, 135, 145, 120, 163, 225, 3, 130, 6, 184, 142, 227, 180]), SecretKey([56, 53, 209, 183, 72, 146, 170, 209, 194, 200, 31, 230, 28, 37, 172, 253, 246, 58, 245, 154, 66, 198, 209, 106, 57, 51, 38, 32, 17, 91, 26, 96]), Seed([84, 193, 40, 242, 48, 180, 240, 175, 64, 189, 93, 116, 194, 132, 90, 235, 255, 147, 130, 95, 174, 139, 134, 131, 147, 247, 62, 132, 243, 128, 196, 140]));
/// SS: GDSS22UUSNIBKI2UKWKCN3ADZEVML5ZEZLN3Z6DRZCFZ473TPIFKN7M2
static immutable SS = KeyPair(PublicKey([229, 45, 106, 148, 147, 80, 21, 35, 84, 85, 148, 38, 236, 3, 201, 42, 197, 247, 36, 202, 219, 188, 248, 113, 200, 139, 158, 127, 115, 122, 10, 166]), SecretKey([176, 155, 207, 162, 86, 91, 48, 219, 79, 124, 52, 233, 170, 156, 2, 197, 142, 76, 33, 181, 0, 167, 146, 129, 109, 189, 60, 121, 52, 248, 83, 125]), Seed([65, 189, 37, 57, 49, 66, 195, 71, 149, 187, 128, 131, 101, 4, 178, 69, 217, 188, 48, 69, 133, 172, 214, 216, 55, 130, 58, 182, 153, 223, 82, 145]));
/// ST: GDST22SOLVXGSSM235CBRCPPAV5OKGH34GAO6GP4S3B7FCYFWNNAFQKE
static immutable ST = KeyPair(PublicKey([229, 61, 106, 78, 93, 110, 105, 73, 154, 223, 68, 24, 137, 239, 5, 122, 229, 24, 251, 225, 128, 239, 25, 252, 150, 195, 242, 139, 5, 179, 90, 2]), SecretKey([64, 157, 5, 255, 133, 162, 156, 209, 181, 52, 162, 181, 92, 176, 46, 120, 130, 22, 202, 112, 181, 43, 164, 92, 89, 138, 41, 175, 127, 218, 139, 125]), Seed([232, 119, 97, 99, 213, 19, 189, 188, 122, 208, 108, 181, 223, 170, 75, 255, 98, 56, 175, 128, 253, 145, 243, 150, 11, 119, 77, 228, 215, 212, 94, 201]));
/// SU: GDSU22XF7ZKDCZFOXMWV7S4HA3UVGYUWNAFP4QHHYSPO46KZWOAS2UHA
static immutable SU = KeyPair(PublicKey([229, 77, 106, 229, 254, 84, 49, 100, 174, 187, 45, 95, 203, 135, 6, 233, 83, 98, 150, 104, 10, 254, 64, 231, 196, 158, 238, 121, 89, 179, 129, 45]), SecretKey([80, 110, 119, 171, 62, 51, 240, 79, 255, 201, 42, 192, 52, 38, 80, 23, 40, 75, 105, 153, 98, 140, 137, 4, 185, 59, 224, 153, 42, 109, 58, 64]), Seed([126, 137, 191, 195, 120, 20, 160, 204, 125, 62, 31, 238, 245, 209, 61, 10, 226, 121, 156, 216, 141, 28, 72, 246, 128, 38, 69, 237, 150, 233, 22, 55]));
/// SV: GDSV22RUUOR7CZ7YUYMJV2NUCN7QW5VTOHWEO5V2IA252OPPVNBUQ3LM
static immutable SV = KeyPair(PublicKey([229, 93, 106, 52, 163, 163, 241, 103, 248, 166, 24, 154, 233, 180, 19, 127, 11, 118, 179, 113, 236, 71, 118, 186, 64, 53, 221, 57, 239, 171, 67, 72]), SecretKey([16, 110, 157, 63, 218, 54, 55, 3, 63, 33, 180, 110, 156, 149, 40, 201, 218, 169, 193, 245, 126, 251, 93, 216, 63, 198, 105, 114, 85, 5, 162, 97]), Seed([15, 38, 78, 211, 120, 99, 99, 192, 188, 113, 105, 158, 76, 84, 33, 184, 222, 194, 230, 14, 31, 183, 82, 197, 217, 18, 154, 209, 106, 26, 203, 182]));
/// SW: GDSW224HS5JXAXYSI7QAZUUY5SI2NYCQKNCTCQ7B76ASX3PSF32OWRNM
static immutable SW = KeyPair(PublicKey([229, 109, 107, 135, 151, 83, 112, 95, 18, 71, 224, 12, 210, 152, 236, 145, 166, 224, 80, 83, 69, 49, 67, 225, 255, 129, 43, 237, 242, 46, 244, 235]), SecretKey([200, 107, 135, 49, 225, 245, 14, 166, 246, 76, 24, 92, 173, 213, 70, 248, 175, 139, 44, 182, 83, 107, 124, 54, 37, 124, 255, 241, 1, 202, 124, 127]), Seed([132, 231, 88, 155, 206, 186, 67, 53, 37, 173, 59, 139, 181, 198, 248, 24, 65, 239, 102, 108, 223, 200, 127, 228, 210, 224, 79, 27, 143, 68, 130, 30]));
/// SX: GDSX22FWLQZY23M7RC3J4LXVUKD4VF2LBI5WS3BJUMNOP5HSMW4L2RAW
static immutable SX = KeyPair(PublicKey([229, 125, 104, 182, 92, 51, 141, 109, 159, 136, 182, 158, 46, 245, 162, 135, 202, 151, 75, 10, 59, 105, 108, 41, 163, 26, 231, 244, 242, 101, 184, 189]), SecretKey([40, 1, 53, 216, 53, 38, 40, 0, 101, 160, 74, 129, 239, 110, 168, 150, 206, 83, 31, 156, 57, 28, 100, 156, 235, 96, 220, 237, 150, 116, 77, 94]), Seed([148, 6, 24, 68, 233, 76, 210, 143, 228, 37, 9, 164, 41, 156, 117, 211, 220, 29, 11, 184, 122, 106, 65, 143, 51, 85, 60, 9, 53, 32, 130, 180]));
/// SY: GDSY223FGVBKQ2TXVHESCUODPDYLSHNMSPTMZ3ESGLSW6XT7CTQSWOEG
static immutable SY = KeyPair(PublicKey([229, 141, 107, 101, 53, 66, 168, 106, 119, 169, 201, 33, 81, 195, 120, 240, 185, 29, 172, 147, 230, 204, 236, 146, 50, 229, 111, 94, 127, 20, 225, 43]), SecretKey([128, 239, 0, 94, 115, 74, 244, 32, 58, 243, 128, 174, 160, 140, 153, 216, 155, 0, 1, 156, 154, 5, 172, 194, 219, 53, 109, 19, 107, 226, 93, 65]), Seed([162, 194, 141, 4, 98, 91, 27, 59, 188, 80, 67, 218, 192, 203, 237, 67, 175, 141, 5, 219, 245, 221, 191, 138, 228, 72, 64, 48, 122, 192, 224, 240]));
/// SZ: GDSZ22TSIYNKUMIJNOCL2LT3V24OZ22Q2MLDNMM2HAPMT2G76ZIRTUTU
static immutable SZ = KeyPair(PublicKey([229, 157, 106, 114, 70, 26, 170, 49, 9, 107, 132, 189, 46, 123, 174, 184, 236, 235, 80, 211, 22, 54, 177, 154, 56, 30, 201, 232, 223, 246, 81, 25]), SecretKey([200, 158, 124, 225, 89, 234, 74, 167, 167, 126, 34, 199, 149, 81, 232, 130, 65, 74, 104, 85, 138, 9, 110, 190, 246, 163, 143, 10, 239, 235, 154, 127]), Seed([242, 98, 139, 228, 26, 237, 250, 152, 73, 148, 179, 61, 155, 19, 118, 87, 74, 107, 74, 224, 161, 168, 97, 245, 105, 60, 111, 216, 197, 55, 221, 84]));
/// TA: GDTA22KVNORA5XGVFUD4IYIYBVKYCJN4N5NJAHGBWYMEGD3URBCFYPQX
static immutable TA = KeyPair(PublicKey([230, 13, 105, 85, 107, 162, 14, 220, 213, 45, 7, 196, 97, 24, 13, 85, 129, 37, 188, 111, 90, 144, 28, 193, 182, 24, 67, 15, 116, 136, 68, 92]), SecretKey([144, 37, 251, 176, 164, 150, 75, 117, 214, 100, 155, 82, 100, 141, 165, 34, 127, 245, 40, 14, 155, 18, 161, 102, 90, 110, 111, 15, 245, 99, 201, 84]), Seed([193, 201, 64, 91, 86, 244, 195, 130, 176, 203, 161, 23, 201, 117, 179, 239, 146, 204, 86, 39, 144, 114, 10, 117, 38, 204, 108, 197, 32, 168, 71, 176]));
/// TB: GDTB22S7V2NU64G7QXUJH5VZEV6M2OWIQBMZROLHUQKNI6XE7EY33CWG
static immutable TB = KeyPair(PublicKey([230, 29, 106, 95, 174, 155, 79, 112, 223, 133, 232, 147, 246, 185, 37, 124, 205, 58, 200, 128, 89, 152, 185, 103, 164, 20, 212, 122, 228, 249, 49, 189]), SecretKey([216, 189, 236, 53, 16, 49, 252, 241, 65, 138, 107, 60, 166, 148, 26, 88, 74, 204, 210, 239, 95, 191, 121, 93, 131, 140, 61, 120, 115, 1, 122, 115]), Seed([131, 221, 226, 7, 185, 82, 123, 204, 147, 207, 210, 198, 155, 245, 27, 230, 209, 178, 243, 136, 113, 215, 76, 5, 251, 116, 49, 97, 218, 248, 218, 78]));
/// TC: GDTC22EVNXVGQMMUXU6S3QJJGKSIAFL5IZ7CZ6QQ4HBLMKD7FOE53O5W
static immutable TC = KeyPair(PublicKey([230, 45, 104, 149, 109, 234, 104, 49, 148, 189, 61, 45, 193, 41, 50, 164, 128, 21, 125, 70, 126, 44, 250, 16, 225, 194, 182, 40, 127, 43, 137, 221]), SecretKey([24, 173, 151, 144, 174, 80, 177, 225, 100, 211, 81, 104, 76, 196, 253, 117, 143, 203, 89, 125, 172, 20, 224, 213, 156, 176, 192, 226, 147, 185, 244, 68]), Seed([147, 5, 156, 51, 162, 235, 191, 161, 190, 16, 165, 48, 30, 66, 242, 39, 52, 81, 180, 211, 2, 5, 123, 72, 223, 100, 193, 145, 107, 249, 61, 42]));
/// TD: GDTD22KO7MEYH665JVM3ARAFI3QXPEZFXCQT62FNBGHJ5TZHCBCZUGVI
static immutable TD = KeyPair(PublicKey([230, 61, 105, 78, 251, 9, 131, 251, 221, 77, 89, 176, 68, 5, 70, 225, 119, 147, 37, 184, 161, 63, 104, 173, 9, 142, 158, 207, 39, 16, 69, 154]), SecretKey([248, 19, 129, 240, 76, 200, 77, 115, 220, 167, 14, 120, 52, 117, 1, 157, 79, 43, 209, 8, 114, 249, 45, 179, 78, 74, 159, 105, 34, 97, 229, 97]), Seed([71, 52, 3, 239, 106, 23, 71, 91, 94, 9, 18, 96, 97, 39, 72, 53, 138, 176, 215, 119, 172, 165, 93, 64, 139, 9, 32, 173, 72, 177, 90, 128]));
/// TE: GDTE22QBHYAEQJDJYXCXXY6UUBUC7RF5M3KIXPUJGIQ4XW7MCRZMXY75
static immutable TE = KeyPair(PublicKey([230, 77, 106, 1, 62, 0, 72, 36, 105, 197, 197, 123, 227, 212, 160, 104, 47, 196, 189, 102, 212, 139, 190, 137, 50, 33, 203, 219, 236, 20, 114, 203]), SecretKey([232, 69, 224, 176, 155, 89, 123, 13, 255, 51, 4, 118, 71, 71, 183, 221, 11, 107, 245, 43, 171, 87, 192, 201, 93, 5, 115, 217, 209, 147, 3, 83]), Seed([7, 76, 87, 162, 177, 227, 200, 196, 231, 121, 79, 203, 183, 112, 84, 181, 5, 116, 18, 154, 108, 111, 152, 93, 191, 236, 103, 33, 50, 5, 252, 222]));
/// TF: GDTF22ODP434EZPOKJWCLOGLV6TEADVB7VIHNOI664L33ESSO4HFFYZ7
static immutable TF = KeyPair(PublicKey([230, 93, 105, 195, 127, 55, 194, 101, 238, 82, 108, 37, 184, 203, 175, 166, 64, 14, 161, 253, 80, 118, 185, 30, 247, 23, 189, 146, 82, 119, 14, 82]), SecretKey([128, 148, 30, 165, 250, 15, 41, 186, 131, 129, 253, 148, 46, 201, 144, 65, 38, 73, 171, 118, 195, 35, 89, 3, 149, 241, 97, 159, 235, 215, 115, 101]), Seed([73, 75, 241, 50, 173, 34, 72, 223, 68, 37, 255, 152, 227, 148, 32, 9, 161, 150, 160, 18, 143, 4, 194, 202, 28, 228, 65, 250, 196, 233, 18, 225]));
/// TG: GDTG222WFYK5JWGZACEP4253WBSJDH4FWUAXK5BJ5GBJNWRK56FGDM3X
static immutable TG = KeyPair(PublicKey([230, 109, 107, 86, 46, 21, 212, 216, 217, 0, 136, 254, 107, 187, 176, 100, 145, 159, 133, 181, 1, 117, 116, 41, 233, 130, 150, 218, 42, 239, 138, 97]), SecretKey([0, 62, 214, 190, 188, 50, 172, 100, 229, 215, 166, 11, 4, 15, 215, 50, 0, 206, 215, 58, 112, 171, 127, 205, 141, 249, 253, 40, 248, 241, 147, 72]), Seed([154, 154, 145, 7, 147, 101, 57, 210, 81, 188, 27, 151, 24, 70, 129, 231, 222, 230, 228, 30, 20, 33, 69, 142, 117, 51, 61, 82, 186, 123, 215, 138]));
/// TH: GDTH22IWD3WWOBS4ZHUBS63TLIFAJOSHWV67CA6JU4WKIMXAG2WGUEBF
static immutable TH = KeyPair(PublicKey([230, 125, 105, 22, 30, 237, 103, 6, 92, 201, 232, 25, 123, 115, 90, 10, 4, 186, 71, 181, 125, 241, 3, 201, 167, 44, 164, 50, 224, 54, 172, 106]), SecretKey([48, 226, 14, 146, 51, 50, 225, 58, 201, 230, 212, 37, 253, 254, 251, 54, 141, 221, 84, 157, 121, 15, 18, 34, 214, 51, 249, 213, 9, 161, 136, 68]), Seed([210, 46, 229, 112, 31, 191, 227, 221, 161, 21, 55, 252, 94, 119, 114, 153, 5, 219, 160, 235, 228, 7, 203, 124, 23, 240, 238, 68, 66, 109, 16, 153]));
/// TI: GDTI22LSGGRD2HXEJAIY6NO3MYB3HTLVIUO3N4RG4LDTCPZ6KF7HFZ5X
static immutable TI = KeyPair(PublicKey([230, 141, 105, 114, 49, 162, 61, 30, 228, 72, 17, 143, 53, 219, 102, 3, 179, 205, 117, 69, 29, 182, 242, 38, 226, 199, 49, 63, 62, 81, 126, 114]), SecretKey([128, 122, 244, 251, 218, 205, 25, 67, 223, 60, 121, 18, 77, 238, 221, 184, 187, 17, 9, 49, 214, 64, 210, 24, 115, 167, 170, 155, 21, 204, 135, 85]), Seed([180, 92, 169, 140, 104, 213, 194, 250, 188, 63, 148, 233, 211, 126, 142, 225, 17, 227, 204, 216, 116, 48, 221, 27, 197, 140, 186, 42, 100, 236, 12, 121]));
/// TJ: GDTJ22XQQUIHHHRHQ6F7WMRSFLHGOESRPSB7PBUEV7UW7WGQ5DIEBKCT
static immutable TJ = KeyPair(PublicKey([230, 157, 106, 240, 133, 16, 115, 158, 39, 135, 139, 251, 50, 50, 42, 206, 103, 18, 81, 124, 131, 247, 134, 132, 175, 233, 111, 216, 208, 232, 208, 64]), SecretKey([208, 66, 39, 16, 156, 12, 72, 180, 111, 29, 232, 54, 63, 100, 103, 154, 236, 232, 143, 145, 236, 159, 27, 226, 13, 183, 114, 127, 15, 153, 243, 77]), Seed([106, 135, 5, 248, 150, 60, 107, 157, 218, 204, 254, 25, 198, 12, 101, 106, 117, 171, 162, 201, 108, 153, 129, 237, 246, 240, 124, 245, 113, 215, 131, 202]));
/// TK: GDTK22AH5QYXQ7QRDDMDKSMLBMFT7EPPHLXROQAZYJCF3WMJOIRZWOIS
static immutable TK = KeyPair(PublicKey([230, 173, 104, 7, 236, 49, 120, 126, 17, 24, 216, 53, 73, 139, 11, 11, 63, 145, 239, 58, 239, 23, 64, 25, 194, 68, 93, 217, 137, 114, 35, 155]), SecretKey([232, 68, 147, 71, 74, 187, 224, 183, 167, 139, 237, 130, 194, 82, 189, 114, 240, 227, 121, 56, 205, 156, 174, 250, 7, 87, 106, 202, 57, 164, 189, 109]), Seed([55, 240, 80, 235, 144, 200, 116, 174, 133, 189, 190, 0, 175, 230, 10, 193, 76, 205, 218, 238, 237, 86, 219, 7, 130, 79, 95, 137, 207, 231, 183, 127]));
/// TL: GDTL22W4FQNUZ3OMA4RLRV5D6BRNIDGN2GUC6J4ZCCH4WU27R7YYKILE
static immutable TL = KeyPair(PublicKey([230, 189, 106, 220, 44, 27, 76, 237, 204, 7, 34, 184, 215, 163, 240, 98, 212, 12, 205, 209, 168, 47, 39, 153, 16, 143, 203, 83, 95, 143, 241, 133]), SecretKey([96, 249, 227, 82, 152, 252, 26, 150, 146, 14, 161, 53, 184, 137, 141, 58, 238, 69, 211, 59, 98, 98, 63, 39, 48, 74, 84, 190, 168, 12, 31, 89]), Seed([127, 172, 114, 1, 187, 136, 115, 154, 196, 117, 114, 68, 86, 188, 169, 113, 94, 224, 210, 194, 156, 8, 130, 177, 254, 64, 77, 143, 145, 76, 191, 49]));
/// TM: GDTM22WAF5OHFVL2KYGFS4QWOAWVMDONCZRV7MLJ7EA25ANWNZCWNBHX
static immutable TM = KeyPair(PublicKey([230, 205, 106, 192, 47, 92, 114, 213, 122, 86, 12, 89, 114, 22, 112, 45, 86, 13, 205, 22, 99, 95, 177, 105, 249, 1, 174, 129, 182, 110, 69, 102]), SecretKey([240, 1, 236, 241, 240, 167, 47, 90, 117, 149, 25, 23, 37, 19, 55, 168, 76, 143, 138, 62, 132, 26, 80, 215, 26, 189, 115, 212, 148, 19, 33, 65]), Seed([243, 190, 124, 12, 9, 107, 62, 178, 112, 247, 240, 149, 49, 97, 19, 207, 174, 65, 22, 119, 184, 167, 102, 17, 156, 229, 184, 43, 154, 128, 152, 71]));
/// TN: GDTN2225UR6G53NK525FVQ363NLYEB5ZRVUHBW5FEDMIRZAL4LGDBXOA
static immutable TN = KeyPair(PublicKey([230, 221, 107, 93, 164, 124, 110, 237, 170, 238, 186, 90, 195, 126, 219, 87, 130, 7, 185, 141, 104, 112, 219, 165, 32, 216, 136, 228, 11, 226, 204, 48]), SecretKey([0, 108, 68, 190, 251, 148, 232, 245, 113, 207, 168, 250, 94, 208, 246, 193, 161, 37, 187, 194, 93, 165, 17, 229, 143, 244, 178, 74, 177, 85, 203, 79]), Seed([69, 216, 25, 152, 247, 90, 201, 166, 24, 36, 82, 11, 122, 171, 172, 174, 171, 209, 243, 218, 14, 198, 250, 148, 76, 111, 59, 241, 234, 233, 132, 65]));
/// TO: GDTO22JWL3JON6BFN2WSPYQCXFURV4QENVJW77ZFD5UJF7HAUOG2VHZO
static immutable TO = KeyPair(PublicKey([230, 237, 105, 54, 94, 210, 230, 248, 37, 110, 173, 39, 226, 2, 185, 105, 26, 242, 4, 109, 83, 111, 255, 37, 31, 104, 146, 252, 224, 163, 141, 170]), SecretKey([232, 216, 121, 206, 205, 244, 155, 25, 44, 237, 87, 68, 188, 77, 29, 4, 150, 188, 26, 73, 144, 180, 159, 110, 9, 48, 58, 68, 192, 148, 85, 65]), Seed([2, 225, 174, 105, 88, 187, 50, 241, 145, 2, 244, 19, 168, 8, 234, 145, 29, 146, 149, 10, 135, 203, 70, 86, 242, 255, 72, 108, 185, 238, 87, 41]));
/// TP: GDTP22SDUFX5CZZSZMJBPJSAC7NICP77YMA6QE7ULCGZOIH4X5DT2U6Q
static immutable TP = KeyPair(PublicKey([230, 253, 106, 67, 161, 111, 209, 103, 50, 203, 18, 23, 166, 64, 23, 218, 129, 63, 255, 195, 1, 232, 19, 244, 88, 141, 151, 32, 252, 191, 71, 61]), SecretKey([48, 5, 54, 86, 243, 52, 123, 224, 3, 7, 248, 50, 110, 80, 47, 106, 116, 213, 116, 84, 220, 228, 163, 87, 118, 184, 240, 241, 94, 47, 61, 125]), Seed([121, 207, 225, 68, 87, 238, 136, 111, 133, 58, 144, 166, 45, 148, 64, 96, 122, 211, 22, 20, 124, 143, 87, 177, 24, 144, 198, 157, 27, 195, 231, 111]));
/// TQ: GDTQ224UL2CDYRJ7YO3II4ZVRPPPZCQ7M63W6HZZND72CR4IQK3HMXG7
static immutable TQ = KeyPair(PublicKey([231, 13, 107, 148, 94, 132, 60, 69, 63, 195, 182, 132, 115, 53, 139, 222, 252, 138, 31, 103, 183, 111, 31, 57, 104, 255, 161, 71, 136, 130, 182, 118]), SecretKey([96, 90, 118, 88, 169, 221, 35, 55, 94, 242, 216, 87, 45, 4, 121, 157, 91, 138, 204, 110, 83, 200, 149, 169, 149, 27, 181, 236, 98, 160, 183, 81]), Seed([239, 199, 65, 222, 225, 145, 226, 245, 46, 51, 105, 83, 169, 206, 130, 121, 121, 212, 207, 13, 2, 119, 212, 38, 124, 54, 107, 62, 201, 114, 212, 126]));
/// TR: GDTR22TXDZM2VI7QCKYTJAMZKNY2AEZ7XW47OPL25FSIVKHYQ7GEH32K
static immutable TR = KeyPair(PublicKey([231, 29, 106, 119, 30, 89, 170, 163, 240, 18, 177, 52, 129, 153, 83, 113, 160, 19, 63, 189, 185, 247, 61, 122, 233, 100, 138, 168, 248, 135, 204, 67]), SecretKey([232, 24, 50, 136, 197, 90, 108, 103, 232, 167, 66, 122, 90, 63, 53, 220, 124, 25, 203, 187, 38, 134, 187, 30, 76, 204, 168, 107, 203, 159, 46, 108]), Seed([206, 153, 76, 188, 183, 2, 151, 138, 41, 156, 174, 101, 43, 6, 221, 217, 101, 233, 193, 233, 234, 85, 184, 144, 81, 97, 108, 221, 230, 169, 249, 126]));
/// TS: GDTS227NRBKWTYMYXUYGN7YQLJCP6IJV5H7CK4NWG6FEY5PQXSMV6VEJ
static immutable TS = KeyPair(PublicKey([231, 45, 107, 237, 136, 85, 105, 225, 152, 189, 48, 102, 255, 16, 90, 68, 255, 33, 53, 233, 254, 37, 113, 182, 55, 138, 76, 117, 240, 188, 153, 95]), SecretKey([112, 67, 106, 128, 78, 225, 209, 5, 109, 24, 19, 142, 189, 211, 88, 29, 76, 88, 134, 86, 83, 168, 222, 123, 221, 50, 245, 155, 55, 54, 198, 121]), Seed([29, 200, 46, 105, 26, 7, 229, 211, 250, 80, 230, 49, 72, 101, 78, 230, 131, 188, 67, 117, 155, 187, 2, 199, 20, 8, 24, 37, 85, 158, 56, 96]));
/// TT: GDTT22W2G4WWJFGV2O24WP64TOTNTSVUIOZ2W27I3YIEVEJWWECB2T4J
static immutable TT = KeyPair(PublicKey([231, 61, 106, 218, 55, 45, 100, 148, 213, 211, 181, 203, 63, 220, 155, 166, 217, 202, 180, 67, 179, 171, 107, 232, 222, 16, 74, 145, 54, 177, 4, 29]), SecretKey([224, 212, 74, 34, 24, 100, 227, 41, 109, 200, 146, 152, 21, 181, 174, 246, 185, 34, 55, 73, 51, 253, 113, 172, 32, 152, 207, 112, 88, 172, 205, 119]), Seed([126, 130, 92, 88, 122, 250, 152, 196, 43, 30, 163, 135, 173, 117, 114, 47, 43, 167, 158, 96, 171, 38, 239, 244, 64, 222, 208, 180, 81, 15, 207, 40]));
/// TU: GDTU22VD36P2QJDJGQUGMYE7TS4RENIUDT36UHLVAYMUAQYR6D4JAWSC
static immutable TU = KeyPair(PublicKey([231, 77, 106, 163, 223, 159, 168, 36, 105, 52, 40, 102, 96, 159, 156, 185, 18, 53, 20, 28, 247, 234, 29, 117, 6, 25, 64, 67, 17, 240, 248, 144]), SecretKey([112, 56, 126, 153, 141, 131, 12, 51, 193, 26, 252, 110, 111, 118, 185, 184, 24, 20, 126, 166, 75, 125, 170, 79, 223, 139, 95, 190, 173, 56, 36, 77]), Seed([220, 205, 10, 62, 192, 63, 72, 232, 92, 251, 158, 182, 133, 78, 153, 56, 25, 154, 105, 64, 232, 185, 27, 178, 37, 8, 16, 16, 70, 69, 206, 57]));
/// TV: GDTV22ZAD2RQFUG6NQB547MY45B4SK5PRBG2ESVXHBFEGJJBY7WBEGB6
static immutable TV = KeyPair(PublicKey([231, 93, 107, 32, 30, 163, 2, 208, 222, 108, 3, 222, 125, 152, 231, 67, 201, 43, 175, 136, 77, 162, 74, 183, 56, 74, 67, 37, 33, 199, 236, 18]), SecretKey([88, 246, 105, 153, 214, 46, 36, 87, 103, 114, 184, 89, 216, 30, 102, 115, 128, 163, 57, 68, 245, 147, 11, 24, 37, 53, 125, 240, 247, 199, 102, 123]), Seed([126, 191, 42, 123, 94, 134, 41, 217, 103, 207, 137, 35, 121, 136, 45, 238, 209, 233, 75, 113, 237, 228, 159, 183, 36, 164, 122, 218, 206, 216, 233, 94]));
/// TW: GDTW225ZXUIS63MUQTORUAO54ZSW2UJEV3BXAY5JG6S7IEN4C2TCBGNG
static immutable TW = KeyPair(PublicKey([231, 109, 107, 185, 189, 17, 47, 109, 148, 132, 221, 26, 1, 221, 230, 101, 109, 81, 36, 174, 195, 112, 99, 169, 55, 165, 244, 17, 188, 22, 166, 32]), SecretKey([160, 212, 40, 58, 14, 137, 20, 251, 90, 229, 148, 127, 81, 100, 146, 205, 36, 71, 113, 111, 138, 208, 8, 209, 71, 106, 53, 213, 24, 207, 241, 64]), Seed([207, 241, 106, 189, 72, 247, 201, 64, 118, 182, 112, 232, 91, 153, 39, 247, 144, 181, 128, 53, 111, 235, 227, 107, 190, 160, 207, 201, 175, 14, 19, 46]));
/// TX: GDTX22MMFGEBKVWRIL7D2VVDD2G35HFYBLE7OQEQJ2LJ6XTZCKA3CJNJ
static immutable TX = KeyPair(PublicKey([231, 125, 105, 140, 41, 136, 21, 86, 209, 66, 254, 61, 86, 163, 30, 141, 190, 156, 184, 10, 201, 247, 64, 144, 78, 150, 159, 94, 121, 18, 129, 177]), SecretKey([144, 80, 73, 196, 213, 142, 143, 110, 236, 220, 32, 193, 13, 182, 233, 203, 23, 182, 82, 160, 240, 102, 195, 44, 142, 202, 107, 33, 102, 196, 127, 126]), Seed([132, 104, 76, 68, 171, 69, 108, 63, 154, 143, 40, 170, 123, 71, 152, 153, 6, 22, 47, 48, 216, 138, 217, 13, 207, 159, 119, 210, 55, 247, 156, 137]));
/// TY: GDTY22CKTQKN3MAM7LHHDUURSBUSJRXSKNQHUNSSIOKEZVUGAPNWEHSV
static immutable TY = KeyPair(PublicKey([231, 141, 104, 74, 156, 20, 221, 176, 12, 250, 206, 113, 210, 145, 144, 105, 36, 198, 242, 83, 96, 122, 54, 82, 67, 148, 76, 214, 134, 3, 219, 98]), SecretKey([48, 167, 154, 202, 199, 94, 170, 59, 103, 202, 155, 154, 241, 10, 161, 204, 96, 219, 73, 146, 150, 129, 124, 24, 130, 43, 138, 217, 191, 169, 90, 77]), Seed([36, 174, 147, 227, 229, 177, 78, 57, 129, 184, 56, 194, 68, 73, 92, 247, 214, 101, 79, 90, 108, 144, 76, 69, 111, 67, 56, 158, 51, 213, 179, 82]));
/// TZ: GDTZ22NS5NEWJSVMDY2EJ4UTHHVQT6U5S7PHF2VPIMOQYVKKQBEH7J4Y
static immutable TZ = KeyPair(PublicKey([231, 157, 105, 178, 235, 73, 100, 202, 172, 30, 52, 68, 242, 147, 57, 235, 9, 250, 157, 151, 222, 114, 234, 175, 67, 29, 12, 85, 74, 128, 72, 127]), SecretKey([72, 181, 35, 228, 123, 211, 125, 70, 63, 36, 182, 73, 36, 99, 232, 40, 144, 240, 93, 131, 177, 153, 183, 112, 197, 157, 219, 142, 251, 216, 208, 120]), Seed([173, 216, 89, 59, 156, 148, 166, 63, 215, 146, 134, 141, 241, 51, 97, 65, 79, 26, 194, 92, 183, 58, 217, 57, 51, 23, 158, 218, 199, 210, 213, 127]));
/// UA: GDUA224CYHWGFRHLD6V3TM6DL4IJIMK6OCH4RDP4T66O6FTYCOUGJOMB
static immutable UA = KeyPair(PublicKey([232, 13, 107, 130, 193, 236, 98, 196, 235, 31, 171, 185, 179, 195, 95, 16, 148, 49, 94, 112, 143, 200, 141, 252, 159, 188, 239, 22, 120, 19, 168, 100]), SecretKey([232, 176, 151, 69, 205, 192, 235, 150, 153, 84, 32, 127, 120, 247, 79, 143, 215, 159, 27, 104, 42, 93, 251, 121, 251, 253, 186, 40, 255, 134, 231, 67]), Seed([44, 251, 161, 161, 236, 184, 90, 49, 158, 160, 136, 44, 235, 250, 209, 35, 224, 95, 128, 112, 219, 169, 49, 80, 154, 17, 118, 253, 141, 164, 148, 12]));
/// UB: GDUB22JJMJAJPTSE3HKGJHNVETFFAKAOEK7ABVDR2UI5X4JTG5UGOLQH
static immutable UB = KeyPair(PublicKey([232, 29, 105, 41, 98, 64, 151, 206, 68, 217, 212, 100, 157, 181, 36, 202, 80, 40, 14, 34, 190, 0, 212, 113, 213, 17, 219, 241, 51, 55, 104, 103]), SecretKey([192, 102, 66, 23, 149, 64, 148, 58, 21, 8, 114, 139, 142, 6, 47, 237, 249, 159, 58, 109, 104, 0, 173, 36, 164, 143, 87, 124, 54, 108, 44, 99]), Seed([107, 156, 10, 246, 57, 254, 110, 108, 34, 243, 113, 200, 6, 184, 138, 154, 113, 155, 242, 18, 222, 101, 7, 89, 236, 224, 214, 122, 126, 12, 92, 105]));
/// UC: GDUC22B55HNXVBQSRDJO2VNTUKZCAMB7SOXA6CHBSAFT7ZW2WFIR7JAF
static immutable UC = KeyPair(PublicKey([232, 45, 104, 61, 233, 219, 122, 134, 18, 136, 210, 237, 85, 179, 162, 178, 32, 48, 63, 147, 174, 15, 8, 225, 144, 11, 63, 230, 218, 177, 81, 31]), SecretKey([224, 222, 244, 30, 144, 92, 53, 156, 9, 24, 207, 174, 243, 219, 157, 70, 237, 250, 11, 28, 60, 162, 105, 200, 108, 74, 221, 236, 36, 162, 144, 125]), Seed([167, 104, 107, 95, 121, 19, 98, 249, 125, 80, 242, 167, 45, 164, 40, 174, 93, 181, 221, 103, 150, 26, 70, 79, 86, 78, 184, 98, 135, 30, 201, 145]));
/// UD: GDUD227QWVPSMO6Y3NHRM3Q3H6NHW6EQ5FKZ5LV32XOO3Z6SESMXEFUT
static immutable UD = KeyPair(PublicKey([232, 61, 107, 240, 181, 95, 38, 59, 216, 219, 79, 22, 110, 27, 63, 154, 123, 120, 144, 233, 85, 158, 174, 187, 213, 220, 237, 231, 210, 36, 153, 114]), SecretKey([184, 187, 159, 232, 182, 24, 100, 93, 125, 78, 153, 230, 54, 38, 66, 188, 83, 36, 252, 183, 7, 168, 72, 224, 31, 99, 8, 155, 26, 115, 61, 120]), Seed([224, 70, 242, 134, 187, 250, 22, 31, 21, 184, 17, 129, 149, 190, 236, 181, 95, 117, 184, 91, 26, 211, 34, 123, 38, 76, 137, 156, 32, 190, 33, 20]));
/// UE: GDUE22WOLIO2UUYDLTTT23RDZW44L23K7OKPNWITVI5AOX72J6CBH3DY
static immutable UE = KeyPair(PublicKey([232, 77, 106, 206, 90, 29, 170, 83, 3, 92, 231, 61, 110, 35, 205, 185, 197, 235, 106, 251, 148, 246, 217, 19, 170, 58, 7, 95, 250, 79, 132, 19]), SecretKey([128, 9, 229, 98, 87, 40, 39, 186, 102, 163, 26, 141, 189, 100, 184, 64, 125, 191, 201, 3, 143, 160, 179, 135, 152, 171, 38, 51, 227, 130, 206, 76]), Seed([159, 238, 41, 181, 155, 108, 62, 41, 94, 101, 76, 230, 100, 132, 108, 120, 81, 10, 253, 239, 99, 46, 27, 66, 222, 69, 218, 233, 192, 181, 249, 220]));
/// UF: GDUF22RQWHTUHDY36SA3ME5GI7R2XBHSDNCFJHAUGL4QXYTKTHC6YMB3
static immutable UF = KeyPair(PublicKey([232, 93, 106, 48, 177, 231, 67, 143, 27, 244, 129, 182, 19, 166, 71, 227, 171, 132, 242, 27, 68, 84, 156, 20, 50, 249, 11, 226, 106, 153, 197, 236]), SecretKey([208, 247, 43, 53, 207, 71, 252, 127, 66, 137, 56, 18, 102, 234, 250, 42, 161, 159, 251, 216, 222, 22, 216, 151, 43, 55, 148, 241, 16, 103, 231, 66]), Seed([47, 203, 253, 144, 98, 123, 78, 250, 219, 16, 187, 207, 113, 39, 212, 231, 220, 31, 133, 171, 252, 162, 129, 110, 253, 212, 1, 224, 125, 183, 16, 209]));
/// UG: GDUG22NA645DGXGCWMFHSLRA5NA53LVZC75QCSPG6BV2LZN3J3EM7P3P
static immutable UG = KeyPair(PublicKey([232, 109, 105, 160, 247, 58, 51, 92, 194, 179, 10, 121, 46, 32, 235, 65, 221, 174, 185, 23, 251, 1, 73, 230, 240, 107, 165, 229, 187, 78, 200, 207]), SecretKey([152, 79, 184, 172, 245, 165, 190, 162, 208, 58, 168, 106, 72, 240, 236, 219, 4, 159, 4, 22, 44, 203, 25, 142, 30, 92, 183, 196, 200, 76, 204, 112]), Seed([110, 190, 28, 118, 115, 16, 224, 189, 170, 160, 59, 127, 26, 30, 200, 199, 28, 197, 42, 28, 113, 181, 59, 108, 239, 3, 85, 81, 104, 26, 94, 172]));
/// UH: GDUH22ZV544R32FOA2J5XXMCDSTS2BRULPLR7NOMTAUYT7DKHHSJNLWE
static immutable UH = KeyPair(PublicKey([232, 125, 107, 53, 239, 57, 29, 232, 174, 6, 147, 219, 221, 130, 28, 167, 45, 6, 52, 91, 215, 31, 181, 204, 152, 41, 137, 252, 106, 57, 228, 150]), SecretKey([216, 206, 98, 242, 121, 53, 215, 201, 18, 100, 60, 58, 176, 240, 38, 142, 129, 16, 96, 255, 220, 36, 63, 37, 46, 133, 111, 235, 1, 69, 255, 82]), Seed([13, 171, 14, 146, 61, 14, 209, 152, 123, 224, 207, 101, 150, 245, 134, 146, 51, 162, 207, 117, 13, 155, 47, 41, 253, 221, 247, 127, 28, 116, 23, 110]));
/// UI: GDUI22B3F6252DLV42OXKDE32WB52LKLSXLEF4WQA7OPSL5AYX4DA7HV
static immutable UI = KeyPair(PublicKey([232, 141, 104, 59, 47, 181, 221, 13, 117, 230, 157, 117, 12, 155, 213, 131, 221, 45, 75, 149, 214, 66, 242, 208, 7, 220, 249, 47, 160, 197, 248, 48]), SecretKey([40, 198, 213, 211, 107, 30, 114, 206, 99, 95, 211, 134, 106, 57, 115, 151, 52, 153, 46, 22, 238, 132, 13, 95, 81, 116, 53, 195, 166, 49, 16, 98]), Seed([12, 241, 21, 228, 36, 161, 184, 78, 140, 106, 189, 195, 202, 248, 142, 69, 159, 150, 240, 156, 233, 250, 103, 242, 133, 70, 6, 133, 210, 178, 244, 128]));
/// UJ: GDUJ22BKTKCSQ4DOFIG2WONQ4G5VJFP4PTL5SK6JQOX6RFGDLAAR3WN3
static immutable UJ = KeyPair(PublicKey([232, 157, 104, 42, 154, 133, 40, 112, 110, 42, 13, 171, 57, 176, 225, 187, 84, 149, 252, 124, 215, 217, 43, 201, 131, 175, 232, 148, 195, 88, 1, 29]), SecretKey([24, 239, 103, 56, 6, 37, 58, 9, 63, 71, 86, 236, 105, 222, 63, 85, 232, 10, 152, 76, 59, 75, 91, 116, 253, 125, 243, 238, 138, 217, 128, 72]), Seed([10, 123, 112, 161, 128, 58, 107, 228, 230, 21, 21, 243, 232, 68, 221, 193, 103, 8, 172, 186, 34, 38, 82, 43, 43, 185, 237, 42, 124, 241, 205, 228]));
/// UK: GDUK22PBYDASCN3TUZGSA4ELGSC6BTU4UDIKZJOAN3FF6B2JXKPBDFIK
static immutable UK = KeyPair(PublicKey([232, 173, 105, 225, 192, 193, 33, 55, 115, 166, 77, 32, 112, 139, 52, 133, 224, 206, 156, 160, 208, 172, 165, 192, 110, 202, 95, 7, 73, 186, 158, 17]), SecretKey([32, 35, 16, 238, 16, 86, 247, 192, 183, 50, 214, 239, 154, 211, 160, 220, 16, 231, 245, 31, 229, 121, 42, 250, 82, 179, 122, 64, 246, 234, 33, 77]), Seed([184, 194, 217, 212, 203, 216, 159, 71, 178, 46, 185, 128, 214, 15, 184, 146, 91, 32, 117, 78, 226, 174, 101, 4, 28, 177, 122, 10, 103, 44, 118, 164]));
/// UL: GDUL22XCWRHXGJFHJ7VN2VHVFSDSM5YLEQXGOEPFQSMN77KXR7C2PXBI
static immutable UL = KeyPair(PublicKey([232, 189, 106, 226, 180, 79, 115, 36, 167, 79, 234, 221, 84, 245, 44, 135, 38, 119, 11, 36, 46, 103, 17, 229, 132, 152, 223, 253, 87, 143, 197, 167]), SecretKey([112, 191, 121, 62, 198, 142, 191, 218, 6, 88, 26, 142, 162, 174, 70, 144, 252, 242, 248, 125, 32, 168, 192, 234, 71, 2, 198, 149, 188, 217, 83, 122]), Seed([208, 68, 181, 255, 12, 45, 156, 68, 218, 17, 32, 188, 69, 49, 72, 56, 247, 57, 237, 137, 106, 20, 191, 227, 128, 126, 76, 32, 212, 45, 54, 53]));
/// UM: GDUM22CSY54LX6JRNFYXO2C7JYQSZWH2JO6I6FSJTCQAVQX45GOQLNT5
static immutable UM = KeyPair(PublicKey([232, 205, 104, 82, 199, 120, 187, 249, 49, 105, 113, 119, 104, 95, 78, 33, 44, 216, 250, 75, 188, 143, 22, 73, 152, 160, 10, 194, 252, 233, 157, 5]), SecretKey([224, 172, 106, 191, 149, 205, 113, 177, 187, 145, 222, 111, 111, 109, 68, 1, 179, 172, 65, 145, 168, 3, 15, 205, 147, 89, 189, 60, 183, 118, 252, 124]), Seed([44, 47, 97, 195, 232, 49, 238, 67, 3, 253, 135, 54, 23, 74, 186, 41, 215, 136, 96, 237, 198, 53, 224, 164, 198, 214, 248, 159, 199, 190, 14, 202]));
/// UN: GDUN22NKAIX5M6OG66TGYV3W2ULZLHBJSC4PGGGHY3PXAGXBZYRT3PWK
static immutable UN = KeyPair(PublicKey([232, 221, 105, 170, 2, 47, 214, 121, 198, 247, 166, 108, 87, 118, 213, 23, 149, 156, 41, 144, 184, 243, 24, 199, 198, 223, 112, 26, 225, 206, 35, 61]), SecretKey([128, 227, 20, 192, 152, 223, 135, 137, 104, 193, 142, 234, 185, 189, 8, 89, 20, 36, 102, 170, 89, 202, 73, 28, 207, 101, 96, 196, 171, 91, 226, 94]), Seed([179, 79, 160, 15, 57, 194, 174, 1, 42, 118, 48, 28, 190, 254, 118, 241, 118, 157, 137, 126, 191, 127, 46, 4, 58, 116, 178, 192, 224, 23, 191, 89]));
/// UO: GDUO22OGUK3KPPV6SDCXYZ5XRDG3NYNINW45M4IFVAZGI6YHKD26ZYYC
static immutable UO = KeyPair(PublicKey([232, 237, 105, 198, 162, 182, 167, 190, 190, 144, 197, 124, 103, 183, 136, 205, 182, 225, 168, 109, 185, 214, 113, 5, 168, 50, 100, 123, 7, 80, 245, 236]), SecretKey([72, 233, 75, 142, 2, 230, 136, 62, 98, 191, 127, 99, 150, 248, 93, 151, 86, 168, 176, 178, 91, 72, 226, 192, 216, 37, 136, 174, 238, 178, 153, 121]), Seed([178, 14, 1, 233, 228, 108, 60, 62, 111, 238, 252, 220, 66, 38, 231, 151, 209, 141, 162, 1, 116, 252, 199, 56, 3, 30, 80, 67, 55, 176, 79, 34]));
/// UP: GDUP225DZMMMRONIXL5QFKWR3EYP6ASOH2O7VR35LOXEJEQTIWTFR2JD
static immutable UP = KeyPair(PublicKey([232, 253, 107, 163, 203, 24, 200, 185, 168, 186, 251, 2, 170, 209, 217, 48, 255, 2, 78, 62, 157, 250, 199, 125, 91, 174, 68, 146, 19, 69, 166, 88]), SecretKey([176, 234, 97, 132, 185, 227, 45, 55, 139, 65, 120, 41, 254, 91, 143, 180, 1, 113, 139, 33, 199, 169, 62, 5, 203, 213, 124, 7, 96, 244, 63, 69]), Seed([51, 96, 235, 56, 238, 236, 155, 94, 127, 119, 96, 212, 211, 59, 201, 123, 190, 73, 148, 20, 143, 70, 38, 81, 15, 123, 89, 144, 6, 148, 25, 95]));
/// UQ: GDUQ22IJAQSMGFBKCWGFJKCJROMIFXPNZJLTSNPPGPVFQLUGISLOXTNY
static immutable UQ = KeyPair(PublicKey([233, 13, 105, 9, 4, 36, 195, 20, 42, 21, 140, 84, 168, 73, 139, 152, 130, 221, 237, 202, 87, 57, 53, 239, 51, 234, 88, 46, 134, 68, 150, 235]), SecretKey([24, 107, 109, 237, 142, 124, 225, 207, 237, 224, 23, 197, 206, 20, 79, 82, 82, 188, 68, 100, 176, 220, 72, 13, 177, 55, 242, 190, 2, 135, 42, 122]), Seed([209, 14, 236, 120, 211, 161, 41, 85, 146, 197, 135, 245, 218, 84, 49, 161, 195, 70, 86, 37, 255, 191, 203, 33, 5, 61, 64, 27, 81, 163, 39, 245]));
/// UR: GDUR22SNGP555AYB7WMU6BI4M4DLGBAYQBJXPWHJXRREW7WOLLVK4BLW
static immutable UR = KeyPair(PublicKey([233, 29, 106, 77, 51, 251, 222, 131, 1, 253, 153, 79, 5, 28, 103, 6, 179, 4, 24, 128, 83, 119, 216, 233, 188, 98, 75, 126, 206, 90, 234, 174]), SecretKey([144, 215, 117, 111, 220, 61, 98, 20, 208, 245, 224, 36, 221, 100, 29, 57, 194, 233, 60, 63, 180, 31, 141, 59, 67, 108, 172, 179, 191, 16, 129, 66]), Seed([20, 116, 101, 55, 35, 164, 208, 143, 228, 210, 238, 145, 87, 225, 178, 161, 46, 105, 81, 35, 129, 164, 133, 13, 33, 206, 48, 73, 164, 179, 133, 134]));
/// US: GDUS225YW6FWVUY44NYLGF23CEJMY34WDUG7MV7ALRSHCEBSF6HGS2NO
static immutable US = KeyPair(PublicKey([233, 45, 107, 184, 183, 139, 106, 211, 28, 227, 112, 179, 23, 91, 17, 18, 204, 111, 150, 29, 13, 246, 87, 224, 92, 100, 113, 16, 50, 47, 142, 105]), SecretKey([248, 95, 128, 191, 235, 35, 147, 193, 165, 204, 80, 97, 115, 58, 191, 229, 33, 110, 232, 243, 66, 69, 233, 5, 39, 17, 79, 155, 99, 197, 14, 92]), Seed([7, 89, 195, 254, 28, 137, 150, 146, 190, 157, 161, 31, 95, 161, 74, 120, 126, 105, 156, 201, 77, 53, 150, 220, 165, 77, 37, 98, 157, 31, 29, 3]));
/// UT: GDUT22Y4BQHQBFWMUNCTQW2GPQ6XBLHEUQLCXQOTKCX5QN76TNIEZXTL
static immutable UT = KeyPair(PublicKey([233, 61, 107, 28, 12, 15, 0, 150, 204, 163, 69, 56, 91, 70, 124, 61, 112, 172, 228, 164, 22, 43, 193, 211, 80, 175, 216, 55, 254, 155, 80, 76]), SecretKey([8, 224, 111, 218, 235, 201, 86, 67, 102, 83, 129, 166, 167, 155, 192, 41, 72, 120, 70, 246, 111, 157, 35, 112, 46, 206, 65, 210, 182, 176, 52, 86]), Seed([6, 59, 255, 54, 187, 207, 195, 174, 122, 3, 82, 247, 224, 158, 93, 71, 187, 121, 10, 152, 28, 42, 140, 73, 249, 237, 209, 214, 200, 11, 104, 249]));
/// UU: GDUU227NIDITVR6R55HDUM5U3SLE7GJKW5SX5HNLMOH7JNB7V3ZNGO2C
static immutable UU = KeyPair(PublicKey([233, 77, 107, 237, 64, 209, 58, 199, 209, 239, 78, 58, 51, 180, 220, 150, 79, 153, 42, 183, 101, 126, 157, 171, 99, 143, 244, 180, 63, 174, 242, 211]), SecretKey([112, 91, 229, 245, 53, 177, 35, 18, 125, 110, 96, 227, 170, 126, 215, 16, 167, 101, 216, 197, 135, 146, 24, 215, 61, 115, 212, 204, 174, 123, 118, 64]), Seed([90, 81, 230, 0, 91, 112, 231, 158, 50, 0, 210, 44, 240, 65, 18, 124, 209, 107, 172, 2, 61, 204, 86, 77, 171, 170, 216, 37, 142, 73, 78, 24]));
/// UV: GDUV22EEHAQC5FQFO6WLS3M76QJBXYTMR5J7MTMTT7YDGZEC3FZY22PE
static immutable UV = KeyPair(PublicKey([233, 93, 104, 132, 56, 32, 46, 150, 5, 119, 172, 185, 109, 159, 244, 18, 27, 226, 108, 143, 83, 246, 77, 147, 159, 240, 51, 100, 130, 217, 115, 141]), SecretKey([56, 46, 168, 71, 243, 50, 238, 239, 183, 159, 83, 112, 66, 123, 31, 150, 211, 182, 158, 193, 102, 143, 151, 252, 107, 59, 206, 78, 60, 207, 142, 91]), Seed([131, 8, 40, 53, 117, 22, 26, 181, 162, 180, 94, 64, 201, 27, 234, 29, 10, 4, 183, 99, 45, 167, 70, 239, 17, 11, 10, 69, 24, 146, 250, 54]));
/// UW: GDUW22CAM3GKIQFQQVCK2FYO7S737UZMRMHYY7JDGQ2WZUWF3DZ3WB56
static immutable UW = KeyPair(PublicKey([233, 109, 104, 64, 102, 204, 164, 64, 176, 133, 68, 173, 23, 14, 252, 191, 191, 211, 44, 139, 15, 140, 125, 35, 52, 53, 108, 210, 197, 216, 243, 187]), SecretKey([104, 109, 119, 1, 67, 161, 82, 63, 238, 7, 94, 68, 26, 6, 87, 236, 76, 141, 161, 200, 35, 189, 9, 157, 189, 184, 61, 70, 235, 1, 89, 72]), Seed([208, 78, 143, 41, 207, 146, 114, 179, 138, 230, 58, 102, 184, 219, 114, 20, 188, 41, 192, 166, 126, 94, 101, 119, 131, 123, 122, 84, 73, 207, 98, 17]));
/// UX: GDUX22PS2HEVSUR3CSRLSCX7UAIZ6LKDTM6ABVYVSCMSEWQXELHBU2V2
static immutable UX = KeyPair(PublicKey([233, 125, 105, 242, 209, 201, 89, 82, 59, 20, 162, 185, 10, 255, 160, 17, 159, 45, 67, 155, 60, 0, 215, 21, 144, 153, 34, 90, 23, 34, 206, 26]), SecretKey([8, 232, 0, 38, 237, 246, 35, 58, 171, 245, 22, 186, 63, 255, 252, 171, 145, 245, 180, 198, 151, 41, 200, 58, 74, 174, 213, 20, 177, 11, 4, 89]), Seed([30, 40, 107, 17, 166, 125, 208, 86, 78, 140, 178, 219, 44, 189, 11, 229, 123, 170, 160, 178, 84, 190, 130, 155, 47, 64, 46, 93, 149, 198, 82, 110]));
/// UY: GDUY22OEJYCZO4OP4BNJBUPDLX2DENXHGMRKIIGOB3BLPLHM2PZSKWQK
static immutable UY = KeyPair(PublicKey([233, 141, 105, 196, 78, 5, 151, 113, 207, 224, 90, 144, 209, 227, 93, 244, 50, 54, 231, 51, 34, 164, 32, 206, 14, 194, 183, 172, 236, 211, 243, 37]), SecretKey([32, 120, 195, 78, 225, 134, 1, 57, 163, 77, 115, 161, 253, 200, 118, 175, 24, 66, 134, 195, 68, 64, 160, 157, 166, 163, 41, 129, 117, 203, 105, 120]), Seed([133, 230, 172, 176, 66, 28, 96, 241, 42, 195, 251, 207, 42, 127, 139, 55, 238, 41, 176, 94, 75, 151, 71, 21, 5, 98, 187, 254, 126, 173, 114, 81]));
/// UZ: GDUZ224DEITZ2LPZSFW5G6WD5FEDSNVGP2J33GECHZL4TOKA7KFUZVZH
static immutable UZ = KeyPair(PublicKey([233, 157, 107, 131, 34, 39, 157, 45, 249, 145, 109, 211, 122, 195, 233, 72, 57, 54, 166, 126, 147, 189, 152, 130, 62, 87, 201, 185, 64, 250, 139, 76]), SecretKey([16, 0, 187, 177, 225, 160, 251, 74, 88, 230, 53, 43, 161, 217, 120, 206, 253, 18, 18, 238, 19, 34, 253, 131, 84, 195, 171, 171, 175, 28, 67, 120]), Seed([90, 105, 212, 160, 88, 80, 10, 54, 39, 117, 105, 47, 99, 129, 230, 176, 64, 3, 46, 39, 232, 228, 210, 219, 119, 179, 160, 173, 117, 59, 159, 69]));
/// VA: GDVA22ORVHAU75GYSWOWQTZPS3E5YL3K7GBK57DXX34MHNOPXHQTMOEI
static immutable VA = KeyPair(PublicKey([234, 13, 105, 209, 169, 193, 79, 244, 216, 149, 157, 104, 79, 47, 150, 201, 220, 47, 106, 249, 130, 174, 252, 119, 190, 248, 195, 181, 207, 185, 225, 54]), SecretKey([128, 223, 135, 13, 219, 208, 220, 165, 177, 249, 99, 0, 5, 160, 247, 78, 65, 176, 157, 37, 195, 195, 224, 159, 191, 106, 141, 235, 105, 35, 92, 82]), Seed([194, 243, 114, 74, 103, 161, 157, 218, 30, 56, 77, 214, 158, 217, 64, 10, 211, 77, 139, 230, 177, 7, 146, 15, 104, 54, 114, 47, 161, 92, 108, 104]));
/// VB: GDVB22CQC3ZWN6H6GJOWBY54SA4CVMIOCP7DHPNRQZVNLL7B7UDV4PVJ
static immutable VB = KeyPair(PublicKey([234, 29, 104, 80, 22, 243, 102, 248, 254, 50, 93, 96, 227, 188, 144, 56, 42, 177, 14, 19, 254, 51, 189, 177, 134, 106, 213, 175, 225, 253, 7, 94]), SecretKey([176, 13, 18, 107, 6, 94, 160, 110, 239, 79, 34, 116, 201, 134, 12, 190, 251, 240, 100, 198, 24, 170, 187, 232, 73, 91, 239, 189, 53, 5, 156, 112]), Seed([6, 79, 50, 156, 99, 91, 222, 31, 0, 95, 156, 111, 79, 39, 113, 248, 158, 76, 54, 123, 167, 26, 176, 11, 106, 125, 203, 203, 10, 49, 21, 13]));
/// VC: GDVC225Z4PLAXO4LAVHXKKYPEVE5JVKBX76NJLZD3AEJIXP5SDS6ZUMK
static immutable VC = KeyPair(PublicKey([234, 45, 107, 185, 227, 214, 11, 187, 139, 5, 79, 117, 43, 15, 37, 73, 212, 213, 65, 191, 252, 212, 175, 35, 216, 8, 148, 93, 253, 144, 229, 236]), SecretKey([48, 145, 136, 255, 125, 182, 114, 132, 101, 204, 65, 54, 60, 27, 243, 15, 27, 20, 168, 64, 47, 7, 140, 195, 152, 51, 154, 234, 146, 221, 233, 64]), Seed([122, 191, 124, 107, 135, 14, 48, 49, 93, 224, 248, 102, 234, 17, 236, 3, 197, 68, 195, 223, 1, 112, 6, 12, 119, 96, 61, 109, 175, 103, 139, 179]));
/// VD: GDVD22IHA7RJY6TEH7YGRAJ5OYO5TMI45J5DQFULXRKJC3CGUDSVTRHJ
static immutable VD = KeyPair(PublicKey([234, 61, 105, 7, 7, 226, 156, 122, 100, 63, 240, 104, 129, 61, 118, 29, 217, 177, 28, 234, 122, 56, 22, 139, 188, 84, 145, 108, 70, 160, 229, 89]), SecretKey([40, 158, 206, 249, 71, 21, 47, 139, 211, 231, 251, 205, 44, 6, 155, 68, 120, 37, 185, 96, 55, 53, 173, 97, 192, 123, 217, 211, 244, 212, 221, 127]), Seed([141, 218, 125, 99, 31, 77, 167, 238, 250, 141, 51, 191, 169, 107, 34, 156, 156, 169, 236, 18, 250, 163, 161, 71, 129, 143, 61, 13, 39, 106, 109, 229]));
/// VE: GDVE22Z5OVODNMR2N7VPW3NRKAC4PDGRJ4NZVW5J3VINVU2QTAN7RVI4
static immutable VE = KeyPair(PublicKey([234, 77, 107, 61, 117, 92, 54, 178, 58, 111, 234, 251, 109, 177, 80, 5, 199, 140, 209, 79, 27, 154, 219, 169, 221, 80, 218, 211, 80, 152, 27, 248]), SecretKey([136, 35, 70, 137, 52, 239, 241, 185, 98, 237, 172, 103, 121, 170, 195, 53, 252, 121, 6, 3, 154, 147, 196, 187, 160, 87, 200, 173, 103, 15, 119, 89]), Seed([215, 189, 133, 66, 40, 95, 212, 0, 98, 61, 99, 206, 187, 109, 106, 253, 162, 238, 223, 237, 255, 245, 192, 108, 180, 234, 28, 109, 142, 249, 236, 6]));
/// VF: GDVF22J3C6SSOHEPEODWDFXEAULZNPRDSJW72D4ZEJKFLPFCX5DS4UVG
static immutable VF = KeyPair(PublicKey([234, 93, 105, 59, 23, 165, 39, 28, 143, 35, 135, 97, 150, 228, 5, 23, 150, 190, 35, 146, 109, 253, 15, 153, 34, 84, 85, 188, 162, 191, 71, 46]), SecretKey([120, 39, 213, 176, 109, 231, 178, 130, 132, 61, 107, 222, 126, 220, 83, 0, 118, 10, 107, 15, 60, 116, 75, 162, 206, 165, 181, 63, 22, 2, 146, 65]), Seed([77, 52, 113, 43, 19, 27, 197, 48, 102, 209, 61, 151, 207, 123, 168, 214, 242, 14, 231, 152, 19, 85, 42, 167, 226, 94, 231, 162, 75, 183, 28, 229]));
/// VG: GDVG22OCC7GGNOABJI3OVRZ7OBZSRTUSHV74W5BGSODWNFBHBMC7UNGG
static immutable VG = KeyPair(PublicKey([234, 109, 105, 194, 23, 204, 102, 184, 1, 74, 54, 234, 199, 63, 112, 115, 40, 206, 146, 61, 127, 203, 116, 38, 147, 135, 102, 148, 39, 11, 5, 250]), SecretKey([128, 228, 35, 176, 189, 120, 223, 169, 51, 159, 169, 113, 186, 71, 227, 141, 65, 185, 163, 168, 49, 222, 221, 218, 40, 65, 180, 164, 246, 126, 61, 113]), Seed([206, 179, 192, 165, 141, 29, 61, 41, 89, 128, 107, 105, 88, 186, 105, 120, 100, 157, 71, 195, 104, 161, 7, 118, 146, 107, 121, 247, 32, 2, 204, 16]));
/// VH: GDVH22YSOWE6XOO3FBEEE3AAUHSVUBL5EVCWMQYOLHK5JY33R34OLZ3B
static immutable VH = KeyPair(PublicKey([234, 125, 107, 18, 117, 137, 235, 185, 219, 40, 72, 66, 108, 0, 161, 229, 90, 5, 125, 37, 69, 102, 67, 14, 89, 213, 212, 227, 123, 142, 248, 229]), SecretKey([96, 34, 211, 48, 203, 12, 187, 91, 24, 94, 11, 103, 135, 80, 103, 80, 153, 240, 240, 11, 123, 107, 223, 76, 160, 123, 208, 168, 12, 182, 67, 90]), Seed([209, 0, 36, 89, 78, 205, 252, 172, 193, 86, 208, 5, 65, 250, 21, 228, 12, 185, 202, 177, 235, 41, 216, 65, 25, 4, 58, 224, 18, 198, 137, 245]));
/// VI: GDVI224VXAUYCEZRJH5N63P3WJSYL326VHLIAWB2FEF7C542BD6PP3XQ
static immutable VI = KeyPair(PublicKey([234, 141, 107, 149, 184, 41, 129, 19, 49, 73, 250, 223, 109, 251, 178, 101, 133, 239, 94, 169, 214, 128, 88, 58, 41, 11, 241, 119, 154, 8, 252, 247]), SecretKey([200, 98, 6, 170, 11, 88, 177, 199, 7, 194, 61, 90, 48, 212, 230, 175, 60, 44, 25, 53, 187, 132, 241, 40, 26, 238, 89, 141, 250, 164, 101, 64]), Seed([98, 235, 79, 121, 76, 75, 59, 61, 138, 121, 103, 40, 117, 231, 43, 224, 109, 225, 23, 150, 172, 119, 67, 227, 219, 205, 38, 144, 245, 20, 238, 41]));
/// VJ: GDVJ22ECJA77C6MLM5YYB45OLTMNY3454ULP5VPOAJIHWNTADOK2FV6S
static immutable VJ = KeyPair(PublicKey([234, 157, 104, 130, 72, 63, 241, 121, 139, 103, 113, 128, 243, 174, 92, 216, 220, 111, 157, 229, 22, 254, 213, 238, 2, 80, 123, 54, 96, 27, 149, 162]), SecretKey([152, 194, 77, 43, 10, 239, 50, 48, 243, 44, 253, 144, 29, 123, 104, 66, 24, 89, 245, 241, 254, 228, 55, 103, 129, 108, 218, 22, 75, 45, 210, 81]), Seed([7, 30, 243, 77, 47, 24, 93, 64, 138, 249, 76, 3, 22, 135, 238, 175, 121, 130, 134, 19, 33, 136, 241, 174, 174, 4, 13, 38, 130, 126, 89, 201]));
/// VK: GDVK225GGKMRU55LDXIYH6WIN5EK4QRXDYLGD5LGNRZO3R3LIZNNDQB5
static immutable VK = KeyPair(PublicKey([234, 173, 107, 166, 50, 153, 26, 119, 171, 29, 209, 131, 250, 200, 111, 72, 174, 66, 55, 30, 22, 97, 245, 102, 108, 114, 237, 199, 107, 70, 90, 209]), SecretKey([184, 133, 242, 30, 44, 26, 89, 202, 151, 71, 21, 188, 83, 160, 12, 52, 188, 197, 200, 251, 91, 150, 229, 241, 25, 69, 71, 239, 173, 159, 67, 112]), Seed([183, 42, 236, 52, 134, 61, 16, 103, 91, 47, 187, 187, 143, 66, 208, 144, 173, 94, 51, 124, 252, 128, 172, 228, 133, 13, 154, 224, 238, 55, 205, 60]));
/// VL: GDVL22UAC63ON2ZXLWKV4KEHGA4DBZ5EQNNSDFDLBXVL6HWMJJOTGC3L
static immutable VL = KeyPair(PublicKey([234, 189, 106, 128, 23, 182, 230, 235, 55, 93, 149, 94, 40, 135, 48, 56, 48, 231, 164, 131, 91, 33, 148, 107, 13, 234, 191, 30, 204, 74, 93, 51]), SecretKey([8, 243, 171, 91, 104, 115, 195, 203, 62, 38, 20, 88, 148, 192, 249, 98, 126, 188, 160, 125, 42, 146, 222, 191, 247, 174, 171, 131, 88, 91, 17, 119]), Seed([110, 113, 110, 27, 40, 155, 57, 49, 228, 185, 113, 13, 123, 6, 191, 112, 185, 169, 36, 110, 46, 5, 210, 183, 225, 99, 236, 197, 165, 79, 240, 186]));
/// VM: GDVM22SG5FFTRMJQ7S3O2UDNZDHSVJOME7F7R4JURMLGZLCWUSWQGGKY
static immutable VM = KeyPair(PublicKey([234, 205, 106, 70, 233, 75, 56, 177, 48, 252, 182, 237, 80, 109, 200, 207, 42, 165, 204, 39, 203, 248, 241, 52, 139, 22, 108, 172, 86, 164, 173, 3]), SecretKey([200, 96, 113, 100, 100, 254, 63, 225, 22, 8, 198, 208, 94, 141, 240, 82, 93, 74, 15, 31, 6, 96, 78, 151, 29, 159, 20, 20, 226, 206, 199, 120]), Seed([16, 175, 205, 209, 121, 164, 30, 86, 90, 173, 6, 142, 165, 38, 219, 0, 200, 73, 147, 122, 195, 37, 222, 104, 250, 62, 35, 40, 141, 32, 251, 134]));
/// VN: GDVN22TE7YNHV5IKMRMWKCY5SLCYS3YHW5BBWLEAKYMVDSBBQJZGTESO
static immutable VN = KeyPair(PublicKey([234, 221, 106, 100, 254, 26, 122, 245, 10, 100, 89, 101, 11, 29, 146, 197, 137, 111, 7, 183, 66, 27, 44, 128, 86, 25, 81, 200, 33, 130, 114, 105]), SecretKey([208, 108, 47, 176, 201, 148, 40, 99, 29, 110, 228, 250, 10, 244, 178, 182, 160, 200, 48, 150, 89, 183, 225, 34, 9, 195, 245, 137, 251, 95, 18, 96]), Seed([250, 171, 7, 45, 169, 73, 216, 212, 62, 237, 135, 42, 158, 135, 173, 61, 187, 5, 249, 240, 140, 140, 15, 45, 148, 208, 90, 93, 1, 243, 100, 168]));
/// VO: GDVO22AHVUYIGHCA6Y6PPDCX3DVTHWJTAY3RFHZTMCKGKRUYZ6ULJOD6
static immutable VO = KeyPair(PublicKey([234, 237, 104, 7, 173, 48, 131, 28, 64, 246, 60, 247, 140, 87, 216, 235, 51, 217, 51, 6, 55, 18, 159, 51, 96, 148, 101, 70, 152, 207, 168, 180]), SecretKey([192, 232, 200, 200, 117, 241, 20, 22, 240, 72, 211, 135, 23, 2, 60, 195, 72, 79, 38, 70, 46, 122, 133, 45, 53, 190, 205, 104, 62, 176, 205, 107]), Seed([96, 88, 191, 147, 55, 9, 27, 228, 223, 107, 124, 129, 197, 76, 94, 135, 147, 156, 100, 16, 21, 119, 19, 160, 255, 174, 59, 236, 250, 24, 243, 85]));
/// VP: GDVP22AHQPNLNFSKFCSZEHHX4JEYXNMR4JWQRKWRDAIXBFYN5ILYZC2U
static immutable VP = KeyPair(PublicKey([234, 253, 104, 7, 131, 218, 182, 150, 74, 40, 165, 146, 28, 247, 226, 73, 139, 181, 145, 226, 109, 8, 170, 209, 24, 17, 112, 151, 13, 234, 23, 140]), SecretKey([96, 243, 5, 124, 214, 189, 21, 10, 238, 8, 24, 160, 181, 55, 113, 104, 185, 238, 195, 247, 126, 32, 116, 72, 200, 42, 232, 80, 33, 4, 94, 72]), Seed([161, 141, 223, 192, 227, 224, 184, 97, 154, 141, 55, 40, 20, 81, 177, 167, 190, 21, 71, 148, 165, 33, 184, 212, 203, 158, 58, 57, 44, 11, 171, 42]));
/// VQ: GDVQ225BRC354HWZPXWKHGKDP6ZS6SAXLTKH7EJLLS5IFXQOIBK75C3W
static immutable VQ = KeyPair(PublicKey([235, 13, 107, 161, 136, 183, 222, 30, 217, 125, 236, 163, 153, 67, 127, 179, 47, 72, 23, 92, 212, 127, 145, 43, 92, 186, 130, 222, 14, 64, 85, 254]), SecretKey([152, 32, 158, 85, 100, 178, 75, 208, 209, 246, 120, 51, 12, 99, 67, 188, 132, 86, 153, 223, 255, 124, 61, 160, 255, 37, 212, 206, 227, 139, 57, 84]), Seed([2, 239, 128, 78, 3, 192, 49, 238, 35, 206, 205, 73, 112, 157, 190, 45, 188, 61, 153, 15, 160, 123, 227, 93, 153, 89, 161, 21, 20, 29, 9, 253]));
/// VR: GDVR22QV4AQGN2SI225S3DYA2F5VJKMA6P5MAM66A5HCJPSNFRN3VALA
static immutable VR = KeyPair(PublicKey([235, 29, 106, 21, 224, 32, 102, 234, 72, 214, 187, 45, 143, 0, 209, 123, 84, 169, 128, 243, 250, 192, 51, 222, 7, 78, 36, 190, 77, 44, 91, 186]), SecretKey([232, 142, 148, 70, 96, 17, 89, 96, 206, 51, 238, 220, 180, 91, 25, 212, 167, 248, 0, 138, 182, 126, 115, 136, 154, 173, 132, 143, 54, 213, 101, 101]), Seed([1, 242, 122, 31, 19, 150, 66, 83, 32, 99, 229, 156, 55, 204, 162, 207, 5, 129, 142, 0, 29, 146, 170, 145, 67, 231, 49, 113, 223, 2, 111, 236]));
/// VS: GDVS22YA3T35RGROC6IEQ2VEHEFX2J63KP576IEWV4Q5ZWTGYCTLEWHB
static immutable VS = KeyPair(PublicKey([235, 45, 107, 0, 220, 247, 216, 154, 46, 23, 144, 72, 106, 164, 57, 11, 125, 39, 219, 83, 251, 255, 32, 150, 175, 33, 220, 218, 102, 192, 166, 178]), SecretKey([120, 63, 227, 210, 205, 160, 218, 229, 191, 90, 115, 50, 175, 98, 218, 121, 180, 98, 127, 1, 20, 154, 238, 107, 181, 172, 27, 85, 204, 142, 119, 118]), Seed([31, 88, 31, 92, 103, 79, 132, 165, 74, 186, 144, 198, 121, 239, 122, 124, 101, 156, 192, 172, 51, 166, 49, 90, 134, 64, 162, 37, 3, 156, 110, 247]));
/// VT: GDVT22FM2QTJGQV7F743TYJKY3ZE3X2WQC7Q2GI3PEABMCDYPFPXTDBG
static immutable VT = KeyPair(PublicKey([235, 61, 104, 172, 212, 38, 147, 66, 191, 47, 249, 185, 225, 42, 198, 242, 77, 223, 86, 128, 191, 13, 25, 27, 121, 0, 22, 8, 120, 121, 95, 121]), SecretKey([248, 220, 228, 176, 156, 113, 71, 147, 209, 149, 213, 181, 29, 208, 187, 194, 225, 110, 207, 151, 127, 155, 204, 173, 116, 250, 31, 156, 72, 225, 246, 69]), Seed([253, 69, 224, 100, 38, 217, 208, 85, 105, 144, 150, 120, 194, 95, 93, 149, 195, 13, 182, 34, 143, 92, 159, 158, 215, 111, 177, 51, 25, 148, 86, 212]));
/// VU: GDVU2235SKF34RYX5AHC4YM2T5UZ36EDE3ERLSM5D7UCQKPT5Y4QS6O4
static immutable VU = KeyPair(PublicKey([235, 77, 107, 125, 146, 139, 190, 71, 23, 232, 14, 46, 97, 154, 159, 105, 157, 248, 131, 38, 201, 21, 201, 157, 31, 232, 40, 41, 243, 238, 57, 9]), SecretKey([176, 90, 4, 153, 69, 233, 115, 78, 94, 247, 51, 221, 18, 138, 135, 77, 109, 238, 219, 185, 186, 242, 61, 1, 235, 230, 91, 251, 20, 211, 132, 79]), Seed([1, 226, 69, 84, 167, 23, 63, 144, 234, 225, 218, 85, 126, 130, 140, 109, 39, 122, 1, 122, 194, 48, 56, 7, 220, 145, 0, 62, 74, 112, 188, 208]));
/// VV: GDVV22WKTJ3E3UCJ64YH4VQHZXIJP5KK5YL5E5LZBQAXSUDHXIT3RX6B
static immutable VV = KeyPair(PublicKey([235, 93, 106, 202, 154, 118, 77, 208, 73, 247, 48, 126, 86, 7, 205, 208, 151, 245, 74, 238, 23, 210, 117, 121, 12, 1, 121, 80, 103, 186, 39, 184]), SecretKey([64, 70, 145, 85, 77, 67, 115, 188, 191, 7, 59, 29, 114, 134, 244, 106, 100, 166, 146, 41, 127, 140, 90, 217, 186, 202, 50, 0, 102, 231, 236, 77]), Seed([54, 130, 187, 98, 147, 55, 205, 126, 192, 233, 101, 72, 78, 240, 147, 102, 9, 138, 127, 175, 217, 135, 207, 183, 241, 48, 32, 207, 202, 57, 195, 69]));
/// VW: GDVW22KIOI2CAZYTBZSEDAQ5NY6ALCKYKOL4SYGWLEURP7G6S6LH5A3B
static immutable VW = KeyPair(PublicKey([235, 109, 105, 72, 114, 52, 32, 103, 19, 14, 100, 65, 130, 29, 110, 60, 5, 137, 88, 83, 151, 201, 96, 214, 89, 41, 23, 252, 222, 151, 150, 126]), SecretKey([64, 127, 95, 100, 106, 155, 160, 69, 224, 17, 186, 50, 0, 239, 49, 240, 181, 246, 43, 43, 31, 71, 123, 30, 218, 234, 68, 162, 23, 53, 25, 88]), Seed([100, 241, 163, 220, 7, 210, 27, 58, 126, 209, 162, 213, 85, 127, 181, 71, 209, 254, 91, 164, 16, 60, 161, 12, 115, 15, 108, 149, 32, 14, 234, 95]));
/// VX: GDVX22YQJJ76AY2CE7FQR4WVZWMGUAZEK7JHTX27CH6I6BHURMOTNOE6
static immutable VX = KeyPair(PublicKey([235, 125, 107, 16, 74, 127, 224, 99, 66, 39, 203, 8, 242, 213, 205, 152, 106, 3, 36, 87, 210, 121, 223, 95, 17, 252, 143, 4, 244, 139, 29, 54]), SecretKey([208, 243, 190, 172, 28, 152, 185, 72, 213, 79, 133, 95, 171, 119, 89, 242, 179, 63, 141, 43, 69, 250, 60, 8, 246, 13, 250, 34, 91, 129, 6, 121]), Seed([101, 49, 97, 208, 108, 58, 154, 111, 140, 62, 31, 95, 55, 196, 81, 123, 247, 177, 178, 119, 82, 44, 80, 213, 178, 135, 105, 204, 3, 154, 133, 149]));
/// VY: GDVY22QTIZPWNBFQNQLXEKSOUUNSQWHHOYR46M2TBWGWVABCRNXMNE4I
static immutable VY = KeyPair(PublicKey([235, 141, 106, 19, 70, 95, 102, 132, 176, 108, 23, 114, 42, 78, 165, 27, 40, 88, 231, 118, 35, 207, 51, 83, 13, 141, 106, 128, 34, 139, 110, 198]), SecretKey([144, 151, 35, 191, 237, 235, 51, 90, 44, 252, 178, 98, 111, 86, 188, 253, 235, 146, 91, 92, 179, 161, 79, 171, 81, 245, 35, 155, 61, 242, 249, 96]), Seed([240, 192, 227, 38, 64, 28, 148, 239, 193, 123, 47, 232, 23, 89, 167, 99, 94, 140, 50, 132, 254, 84, 161, 162, 154, 22, 60, 13, 132, 22, 52, 135]));
/// VZ: GDVZ22RWPN4VIEMOAAR2MRFYFGLOJB2C2PUM7X2ZCX5LRQGJY7M6ECQG
static immutable VZ = KeyPair(PublicKey([235, 157, 106, 54, 123, 121, 84, 17, 142, 0, 35, 166, 68, 184, 41, 150, 228, 135, 66, 211, 232, 207, 223, 89, 21, 250, 184, 192, 201, 199, 217, 226]), SecretKey([40, 95, 10, 103, 77, 95, 192, 161, 20, 143, 154, 132, 231, 213, 99, 190, 247, 98, 105, 147, 190, 117, 237, 190, 189, 89, 66, 28, 27, 2, 176, 93]), Seed([86, 242, 103, 91, 102, 187, 230, 83, 102, 203, 196, 4, 68, 182, 209, 156, 147, 167, 188, 31, 170, 81, 41, 90, 108, 94, 151, 0, 224, 123, 116, 29]));
/// WA: GDWA22FIIK4ODGECBR4NUHTYJX4DVUYB4HYA4EZJSVDI62IWAF23LLDF
static immutable WA = KeyPair(PublicKey([236, 13, 104, 168, 66, 184, 225, 152, 130, 12, 120, 218, 30, 120, 77, 248, 58, 211, 1, 225, 240, 14, 19, 41, 149, 70, 143, 105, 22, 1, 117, 181]), SecretKey([184, 105, 167, 91, 134, 39, 95, 3, 193, 127, 95, 185, 15, 5, 242, 138, 140, 75, 182, 146, 176, 9, 109, 127, 21, 111, 216, 187, 184, 141, 170, 65]), Seed([92, 174, 193, 139, 45, 133, 208, 59, 99, 186, 216, 161, 214, 63, 54, 102, 81, 107, 69, 232, 150, 108, 42, 233, 239, 13, 219, 121, 96, 95, 28, 17]));
/// WB: GDWB222TSOWHJAGQUJRBTTPXH6SDTO2ZAORUTR54O364X7BWYZVXNT2N
static immutable WB = KeyPair(PublicKey([236, 29, 107, 83, 147, 172, 116, 128, 208, 162, 98, 25, 205, 247, 63, 164, 57, 187, 89, 3, 163, 73, 199, 188, 118, 253, 203, 252, 54, 198, 107, 118]), SecretKey([0, 149, 25, 179, 109, 204, 204, 194, 179, 156, 121, 62, 6, 10, 183, 78, 134, 159, 252, 107, 129, 150, 242, 216, 254, 21, 150, 58, 193, 47, 104, 72]), Seed([152, 239, 106, 82, 21, 235, 138, 240, 98, 56, 199, 137, 98, 189, 211, 34, 218, 128, 14, 69, 245, 226, 71, 39, 126, 177, 210, 33, 10, 195, 25, 165]));
/// WC: GDWC22NRBRIL2H7CXWRSVJZXE36P32OQY4FVUJM7LN26KTS43U6BPKS6
static immutable WC = KeyPair(PublicKey([236, 45, 105, 177, 12, 80, 189, 31, 226, 189, 163, 42, 167, 55, 38, 252, 253, 233, 208, 199, 11, 90, 37, 159, 91, 117, 229, 78, 92, 221, 60, 23]), SecretKey([0, 214, 255, 233, 236, 156, 146, 79, 249, 171, 154, 89, 140, 179, 220, 61, 30, 81, 243, 100, 74, 170, 230, 138, 137, 221, 175, 225, 217, 8, 180, 65]), Seed([131, 174, 41, 196, 224, 108, 216, 79, 128, 212, 115, 129, 31, 66, 42, 52, 39, 161, 113, 93, 89, 170, 220, 37, 178, 53, 13, 103, 212, 81, 65, 164]));
/// WD: GDWD22ZGTWJ6WII7JFGL63TCEOBYYHWT7JNLOSPSCBUK3B5JN74PUEKD
static immutable WD = KeyPair(PublicKey([236, 61, 107, 38, 157, 147, 235, 33, 31, 73, 76, 191, 110, 98, 35, 131, 140, 30, 211, 250, 90, 183, 73, 242, 16, 104, 173, 135, 169, 111, 248, 250]), SecretKey([160, 115, 52, 4, 147, 248, 10, 187, 17, 120, 172, 16, 24, 78, 217, 165, 35, 88, 9, 40, 67, 152, 53, 123, 29, 199, 189, 100, 165, 151, 155, 109]), Seed([32, 135, 129, 229, 175, 146, 220, 247, 172, 246, 31, 13, 92, 200, 251, 23, 245, 0, 23, 105, 88, 172, 35, 22, 187, 245, 123, 214, 109, 100, 209, 110]));
/// WE: GDWE227GAFB6LILRVOZI4BSMZCHFR4UVE6VVH6RZ3XMY33U7NOCQPBN5
static immutable WE = KeyPair(PublicKey([236, 77, 107, 230, 1, 67, 229, 161, 113, 171, 178, 142, 6, 76, 200, 142, 88, 242, 149, 39, 171, 83, 250, 57, 221, 217, 141, 238, 159, 107, 133, 7]), SecretKey([48, 172, 192, 119, 203, 57, 46, 228, 254, 7, 197, 214, 188, 206, 117, 33, 30, 71, 121, 213, 226, 124, 57, 127, 168, 239, 143, 128, 234, 156, 83, 94]), Seed([15, 216, 248, 5, 172, 79, 31, 183, 234, 73, 14, 207, 189, 221, 157, 187, 135, 148, 43, 204, 133, 4, 88, 134, 73, 219, 109, 202, 116, 192, 53, 245]));
/// WF: GDWF22Z7LZ3TA45WOCINJ42J5RRN7WUSINPN3XPKG77EAQHXO73IZ5OF
static immutable WF = KeyPair(PublicKey([236, 93, 107, 63, 94, 119, 48, 115, 182, 112, 144, 212, 243, 73, 236, 98, 223, 218, 146, 67, 94, 221, 221, 234, 55, 254, 64, 64, 247, 119, 246, 140]), SecretKey([136, 194, 147, 111, 106, 228, 175, 233, 103, 79, 75, 70, 238, 215, 154, 164, 21, 198, 157, 47, 63, 255, 221, 54, 248, 97, 98, 99, 212, 9, 67, 69]), Seed([66, 25, 15, 14, 157, 202, 212, 213, 46, 162, 29, 184, 143, 243, 188, 125, 11, 57, 114, 212, 191, 141, 144, 180, 146, 75, 223, 70, 91, 185, 36, 45]));
/// WG: GDWG22N32RFROPDQKLV3YH24DINHC2PRT2IW3SPUOWDE24PUEUJA6SIX
static immutable WG = KeyPair(PublicKey([236, 109, 105, 187, 212, 75, 23, 60, 112, 82, 235, 188, 31, 92, 26, 26, 113, 105, 241, 158, 145, 109, 201, 244, 117, 134, 77, 113, 244, 37, 18, 15]), SecretKey([200, 252, 112, 34, 92, 84, 110, 93, 76, 244, 199, 211, 166, 24, 255, 194, 249, 235, 101, 171, 153, 149, 99, 143, 83, 244, 212, 170, 11, 190, 27, 95]), Seed([184, 38, 180, 218, 59, 234, 218, 85, 234, 13, 149, 155, 207, 168, 200, 96, 66, 143, 116, 170, 182, 188, 231, 100, 102, 66, 7, 225, 176, 244, 251, 180]));
/// WH: GDWH223ZLRVMJBDGYJY4CJVDZPEOY2PCRV6ZZVOZ7QUHEFUTLMST4FVB
static immutable WH = KeyPair(PublicKey([236, 125, 107, 121, 92, 106, 196, 132, 102, 194, 113, 193, 38, 163, 203, 200, 236, 105, 226, 141, 125, 156, 213, 217, 252, 40, 114, 22, 147, 91, 37, 62]), SecretKey([192, 58, 35, 241, 3, 59, 225, 222, 101, 170, 42, 13, 71, 44, 93, 198, 214, 28, 192, 193, 109, 200, 249, 52, 113, 119, 145, 44, 27, 1, 46, 93]), Seed([148, 127, 162, 166, 190, 182, 204, 105, 134, 67, 189, 210, 113, 119, 26, 233, 3, 216, 77, 81, 24, 107, 237, 45, 61, 88, 151, 215, 161, 255, 162, 207]));
/// WI: GDWI22CNT4CUDANPYBKN5RHGNZEV3CUWBHZ3E7CTDOR4DMJCUNQTLNA6
static immutable WI = KeyPair(PublicKey([236, 141, 104, 77, 159, 5, 65, 129, 175, 192, 84, 222, 196, 230, 110, 73, 93, 138, 150, 9, 243, 178, 124, 83, 27, 163, 193, 177, 34, 163, 97, 53]), SecretKey([104, 218, 192, 145, 49, 83, 173, 220, 123, 57, 200, 166, 58, 29, 154, 61, 44, 6, 234, 177, 186, 71, 149, 13, 71, 191, 68, 99, 20, 173, 72, 72]), Seed([221, 115, 96, 82, 199, 167, 109, 67, 123, 196, 94, 40, 92, 60, 201, 18, 118, 164, 174, 201, 245, 120, 153, 230, 141, 29, 218, 91, 216, 54, 226, 45]));
/// WJ: GDWJ22IUGS5C465VEEM4HY6K6MXIMSMUTGY63W67J7PULVUY6HTPMLMB
static immutable WJ = KeyPair(PublicKey([236, 157, 105, 20, 52, 186, 46, 123, 181, 33, 25, 195, 227, 202, 243, 46, 134, 73, 148, 153, 177, 237, 219, 223, 79, 223, 69, 214, 152, 241, 230, 246]), SecretKey([64, 150, 32, 86, 130, 240, 135, 2, 20, 69, 149, 233, 6, 90, 184, 46, 74, 229, 173, 187, 175, 96, 222, 5, 206, 135, 189, 41, 141, 243, 143, 71]), Seed([41, 93, 1, 218, 153, 178, 119, 46, 35, 57, 66, 63, 206, 40, 43, 220, 121, 219, 113, 91, 53, 221, 41, 111, 15, 230, 204, 155, 157, 213, 205, 88]));
/// WK: GDWK22XKCQ3A4CI3OYZZ65QBHP6KE5QWPOGXRZ3I3GNCK32HDE4ID4LB
static immutable WK = KeyPair(PublicKey([236, 173, 106, 234, 20, 54, 14, 9, 27, 118, 51, 159, 118, 1, 59, 252, 162, 118, 22, 123, 141, 120, 231, 104, 217, 154, 37, 111, 71, 25, 56, 129]), SecretKey([48, 168, 45, 128, 211, 212, 37, 15, 202, 170, 27, 143, 44, 6, 24, 158, 48, 167, 193, 206, 100, 57, 64, 220, 22, 6, 167, 150, 154, 109, 19, 92]), Seed([196, 139, 177, 118, 114, 202, 62, 162, 12, 178, 25, 98, 119, 243, 87, 166, 23, 33, 1, 82, 149, 57, 59, 55, 101, 199, 207, 128, 90, 160, 113, 229]));
/// WL: GDWL22ZMWWFGVGX7V4JOMFJXYRU6W3NDWUUAJ56C2LI2QWC3AKSY6VUP
static immutable WL = KeyPair(PublicKey([236, 189, 107, 44, 181, 138, 106, 154, 255, 175, 18, 230, 21, 55, 196, 105, 235, 109, 163, 181, 40, 4, 247, 194, 210, 209, 168, 88, 91, 2, 165, 143]), SecretKey([208, 242, 123, 63, 251, 254, 71, 243, 110, 140, 157, 99, 30, 250, 189, 229, 7, 61, 124, 104, 164, 156, 118, 230, 243, 215, 133, 161, 54, 253, 45, 99]), Seed([168, 106, 196, 166, 159, 127, 214, 179, 223, 141, 189, 95, 225, 234, 202, 61, 236, 219, 252, 86, 24, 250, 35, 219, 61, 106, 53, 96, 118, 114, 163, 207]));
/// WM: GDWM22YAYQZ7I7KF6OQBFA4H23X7CJI7CJ7ECF6GPCPXXP2XNIRXA2JW
static immutable WM = KeyPair(PublicKey([236, 205, 107, 0, 196, 51, 244, 125, 69, 243, 160, 18, 131, 135, 214, 239, 241, 37, 31, 18, 126, 65, 23, 198, 120, 159, 123, 191, 87, 106, 35, 112]), SecretKey([128, 106, 227, 19, 45, 254, 87, 176, 223, 190, 100, 225, 9, 215, 1, 199, 81, 143, 135, 169, 2, 98, 95, 77, 57, 102, 174, 57, 233, 17, 255, 80]), Seed([127, 253, 61, 79, 138, 194, 76, 156, 140, 188, 180, 143, 107, 193, 18, 237, 105, 43, 2, 216, 23, 53, 96, 28, 38, 241, 136, 10, 184, 92, 198, 0]));
/// WN: GDWN22RDHO3WTZYLISCZUPS5G26LU5IJQWJSZWKYTHMKT6VYEUFFC37Q
static immutable WN = KeyPair(PublicKey([236, 221, 106, 35, 59, 183, 105, 231, 11, 68, 133, 154, 62, 93, 54, 188, 186, 117, 9, 133, 147, 44, 217, 88, 153, 216, 169, 250, 184, 37, 10, 81]), SecretKey([120, 164, 207, 241, 255, 212, 65, 181, 48, 196, 99, 212, 89, 37, 71, 21, 125, 76, 11, 136, 211, 74, 63, 32, 65, 25, 235, 96, 50, 195, 113, 95]), Seed([209, 161, 12, 212, 241, 111, 155, 213, 170, 139, 45, 210, 152, 238, 234, 16, 172, 239, 225, 101, 217, 100, 241, 242, 168, 5, 12, 127, 28, 242, 230, 137]));
/// WO: GDWO22BZ2JXL5VF5H6DWCQIS23JXL2FHQPO572PXWXMMO5CXOAEEAFVC
static immutable WO = KeyPair(PublicKey([236, 237, 104, 57, 210, 110, 190, 212, 189, 63, 135, 97, 65, 18, 214, 211, 117, 232, 167, 131, 221, 223, 233, 247, 181, 216, 199, 116, 87, 112, 8, 64]), SecretKey([248, 185, 19, 37, 173, 35, 162, 147, 238, 41, 3, 255, 134, 128, 128, 177, 199, 61, 67, 143, 5, 242, 205, 98, 223, 175, 202, 117, 177, 249, 8, 68]), Seed([41, 62, 148, 85, 245, 243, 153, 61, 101, 59, 250, 24, 54, 236, 46, 110, 107, 148, 103, 70, 147, 15, 61, 32, 235, 55, 211, 53, 127, 173, 206, 60]));
/// WP: GDWP22GCNSD2DZ4O4Y4MCN72K4WKQ43LOB3PJ4C65JK7CIJMPABKPBWK
static immutable WP = KeyPair(PublicKey([236, 253, 104, 194, 108, 135, 161, 231, 142, 230, 56, 193, 55, 250, 87, 44, 168, 115, 107, 112, 118, 244, 240, 94, 234, 85, 241, 33, 44, 120, 2, 167]), SecretKey([40, 248, 130, 173, 51, 157, 239, 12, 26, 174, 224, 130, 146, 55, 63, 108, 104, 79, 8, 51, 91, 196, 141, 60, 12, 28, 37, 38, 97, 118, 11, 84]), Seed([143, 101, 32, 57, 245, 111, 34, 211, 245, 4, 20, 131, 172, 196, 254, 139, 198, 19, 147, 73, 86, 178, 215, 24, 72, 206, 151, 110, 22, 76, 112, 194]));
/// WQ: GDWQ22JMSBRPJPWALS2UYTFQLQ2KCFSRLNHUVT4HYGHVXNVTRT6KK72O
static immutable WQ = KeyPair(PublicKey([237, 13, 105, 44, 144, 98, 244, 190, 192, 92, 181, 76, 76, 176, 92, 52, 161, 22, 81, 91, 79, 74, 207, 135, 193, 143, 91, 182, 179, 140, 252, 165]), SecretKey([8, 41, 181, 169, 31, 205, 173, 68, 162, 184, 76, 242, 60, 5, 26, 123, 44, 243, 117, 137, 69, 102, 197, 159, 127, 197, 130, 199, 221, 123, 123, 82]), Seed([126, 8, 97, 83, 109, 182, 126, 201, 21, 105, 17, 98, 34, 146, 155, 64, 130, 116, 251, 28, 185, 155, 187, 80, 141, 62, 44, 208, 17, 76, 148, 44]));
/// WR: GDWR22XYUCZKWFJPMZ6GKED3MVGLP54LTCF46ZURCOOLVMSIBM4YMSXJ
static immutable WR = KeyPair(PublicKey([237, 29, 106, 248, 160, 178, 171, 21, 47, 102, 124, 101, 16, 123, 101, 76, 183, 247, 139, 152, 139, 207, 102, 145, 19, 156, 186, 178, 72, 11, 57, 134]), SecretKey([176, 19, 2, 25, 21, 230, 87, 203, 146, 51, 246, 206, 132, 86, 23, 125, 208, 36, 251, 106, 218, 2, 180, 59, 71, 3, 26, 228, 100, 86, 63, 110]), Seed([212, 231, 188, 7, 165, 17, 6, 85, 250, 71, 24, 52, 162, 252, 97, 78, 235, 142, 65, 223, 94, 141, 36, 198, 11, 209, 7, 61, 211, 5, 107, 158]));
/// WS: GDWS22T374E377XJ2JKJVRZVMEQTJPQVFOPE73CG5ZFFMBMQYTZLN4YK
static immutable WS = KeyPair(PublicKey([237, 45, 106, 123, 255, 9, 191, 254, 233, 210, 84, 154, 199, 53, 97, 33, 52, 190, 21, 43, 158, 79, 236, 70, 238, 74, 86, 5, 144, 196, 242, 182]), SecretKey([232, 124, 60, 154, 169, 218, 61, 197, 102, 80, 127, 248, 176, 0, 162, 223, 112, 29, 6, 3, 169, 68, 1, 67, 35, 28, 74, 132, 211, 157, 108, 96]), Seed([137, 213, 212, 201, 159, 210, 29, 81, 248, 107, 126, 43, 151, 195, 200, 64, 216, 12, 157, 176, 179, 76, 63, 226, 55, 94, 179, 20, 64, 168, 195, 113]));
/// WT: GDWT22HYLMM6IFVGK377E6XTTCJ3JMNKW5HK6JJGUWIIVDPE7XQYU3CN
static immutable WT = KeyPair(PublicKey([237, 61, 104, 248, 91, 25, 228, 22, 166, 86, 255, 242, 122, 243, 152, 147, 180, 177, 170, 183, 78, 175, 37, 38, 165, 144, 138, 141, 228, 253, 225, 138]), SecretKey([16, 182, 139, 109, 239, 218, 227, 79, 55, 148, 250, 12, 83, 162, 4, 177, 38, 190, 213, 64, 221, 84, 231, 237, 229, 75, 174, 95, 28, 135, 88, 126]), Seed([43, 48, 196, 11, 10, 180, 42, 227, 11, 239, 25, 99, 162, 94, 0, 189, 119, 222, 93, 12, 137, 44, 229, 62, 164, 66, 53, 166, 206, 174, 16, 71]));
/// WU: GDWU22OQZYCO2VSQQYNLEVWEL5RC74JNE7MW5D6Y7AIJKKI6F6QZ6F6B
static immutable WU = KeyPair(PublicKey([237, 77, 105, 208, 206, 4, 237, 86, 80, 134, 26, 178, 86, 196, 95, 98, 47, 241, 45, 39, 217, 110, 143, 216, 248, 16, 149, 41, 30, 47, 161, 159]), SecretKey([64, 150, 27, 31, 230, 2, 140, 155, 95, 112, 144, 235, 43, 140, 228, 110, 142, 160, 153, 214, 148, 217, 205, 130, 16, 34, 65, 184, 77, 203, 148, 125]), Seed([192, 58, 230, 246, 5, 155, 68, 32, 3, 128, 67, 231, 225, 105, 163, 87, 41, 128, 242, 143, 247, 212, 86, 168, 121, 124, 99, 194, 116, 157, 102, 177]));
/// WV: GDWV22R74WPZIJ4ZL72OVXY4U5GINAWUXKN7AMRPE7TCUGJ7COPUCRBH
static immutable WV = KeyPair(PublicKey([237, 93, 106, 63, 229, 159, 148, 39, 153, 95, 244, 234, 223, 28, 167, 76, 134, 130, 212, 186, 155, 240, 50, 47, 39, 230, 42, 25, 63, 19, 159, 65]), SecretKey([80, 58, 95, 116, 245, 147, 27, 16, 119, 162, 60, 126, 152, 163, 115, 71, 22, 154, 101, 153, 40, 236, 8, 39, 13, 66, 35, 14, 216, 225, 245, 72]), Seed([145, 211, 184, 72, 3, 173, 26, 93, 29, 110, 226, 158, 252, 223, 148, 83, 70, 12, 108, 157, 112, 26, 93, 56, 204, 41, 19, 215, 120, 118, 237, 154]));
/// WW: GDWW22MTMGJTYBCO46IV7COYDMCL3YVOBTGDKKSVVYQX53YKU36NV5AJ
static immutable WW = KeyPair(PublicKey([237, 109, 105, 147, 97, 147, 60, 4, 78, 231, 145, 95, 137, 216, 27, 4, 189, 226, 174, 12, 204, 53, 42, 85, 174, 33, 126, 239, 10, 166, 252, 218]), SecretKey([88, 150, 43, 89, 107, 78, 164, 213, 165, 45, 18, 95, 31, 65, 120, 56, 241, 44, 209, 4, 110, 148, 108, 235, 166, 3, 117, 85, 121, 235, 101, 126]), Seed([128, 81, 55, 120, 83, 144, 114, 251, 71, 252, 80, 76, 253, 31, 240, 244, 134, 55, 207, 17, 18, 186, 116, 0, 168, 159, 46, 157, 16, 178, 171, 210]));
/// WX: GDWX22VL6IFHJCYQF3RD62DYIWSXPBOROL7SP7PDRRQWM6SIDXXZN6S2
static immutable WX = KeyPair(PublicKey([237, 125, 106, 171, 242, 10, 116, 139, 16, 46, 226, 63, 104, 120, 69, 165, 119, 133, 209, 114, 255, 39, 253, 227, 140, 97, 102, 122, 72, 29, 239, 150]), SecretKey([48, 39, 155, 174, 184, 3, 208, 71, 4, 134, 8, 175, 59, 161, 238, 77, 62, 72, 207, 150, 249, 249, 28, 134, 32, 1, 126, 239, 58, 144, 103, 92]), Seed([204, 113, 252, 202, 83, 47, 186, 58, 83, 208, 247, 145, 239, 113, 88, 108, 82, 2, 122, 231, 38, 223, 206, 190, 153, 58, 2, 99, 29, 125, 112, 220]));
/// WY: GDWY22TJZVS2ONZSBEFMUV6KVQVFBITKGNEXVKT3EN7EMO2R2OVT2MPA
static immutable WY = KeyPair(PublicKey([237, 141, 106, 105, 205, 101, 167, 55, 50, 9, 10, 202, 87, 202, 172, 42, 80, 162, 106, 51, 73, 122, 170, 123, 35, 126, 70, 59, 81, 211, 171, 61]), SecretKey([32, 40, 141, 69, 251, 197, 115, 176, 34, 46, 231, 29, 27, 102, 85, 164, 194, 104, 109, 153, 146, 215, 176, 165, 133, 176, 117, 245, 239, 157, 244, 86]), Seed([218, 137, 191, 180, 16, 151, 136, 147, 53, 130, 124, 135, 211, 43, 21, 32, 77, 52, 221, 82, 31, 18, 234, 167, 185, 89, 182, 171, 162, 86, 31, 0]));
/// WZ: GDWZ22D7RD6PMPAQUDD2SOHCSIGPC33RMSYH32R5VACFLVKETFCJILQF
static immutable WZ = KeyPair(PublicKey([237, 157, 104, 127, 136, 252, 246, 60, 16, 160, 199, 169, 56, 226, 146, 12, 241, 111, 113, 100, 176, 125, 234, 61, 168, 4, 85, 213, 68, 153, 68, 148]), SecretKey([88, 153, 90, 19, 212, 139, 224, 29, 32, 219, 233, 4, 14, 122, 246, 30, 215, 51, 191, 132, 243, 66, 230, 133, 57, 100, 42, 177, 24, 252, 65, 111]), Seed([149, 23, 30, 21, 217, 191, 123, 90, 173, 211, 12, 154, 108, 118, 29, 188, 5, 138, 87, 229, 34, 221, 13, 41, 114, 9, 118, 88, 243, 153, 38, 17]));
/// XA: GDXA22F4TG7SZUFXWWR5XO5PPNS42E2XAE3QSHKDGYX6Y3EAOBASAIR4
static immutable XA = KeyPair(PublicKey([238, 13, 104, 188, 153, 191, 44, 208, 183, 181, 163, 219, 187, 175, 123, 101, 205, 19, 87, 1, 55, 9, 29, 67, 54, 47, 236, 108, 128, 112, 65, 32]), SecretKey([104, 133, 140, 148, 160, 231, 67, 84, 46, 38, 69, 119, 209, 176, 55, 197, 30, 211, 251, 187, 230, 56, 78, 99, 124, 216, 32, 124, 90, 22, 193, 120]), Seed([11, 184, 115, 146, 127, 147, 78, 196, 204, 232, 143, 239, 154, 83, 207, 33, 3, 117, 142, 249, 247, 245, 112, 15, 29, 67, 186, 96, 180, 240, 3, 146]));
/// XB: GDXB22RUHSDU4G4RIITD7RNTBTJEOQWCVRGQHQ3EFXYEEKLGHPAYZA7J
static immutable XB = KeyPair(PublicKey([238, 29, 106, 52, 60, 135, 78, 27, 145, 66, 38, 63, 197, 179, 12, 210, 71, 66, 194, 172, 77, 3, 195, 100, 45, 240, 66, 41, 102, 59, 193, 140]), SecretKey([144, 173, 69, 141, 79, 206, 162, 45, 151, 169, 141, 99, 235, 92, 96, 3, 228, 131, 44, 76, 209, 179, 252, 207, 158, 211, 37, 171, 63, 156, 207, 109]), Seed([32, 134, 77, 222, 139, 195, 51, 225, 16, 80, 138, 122, 24, 46, 243, 5, 71, 86, 92, 86, 48, 74, 35, 185, 203, 127, 36, 214, 31, 242, 223, 83]));
/// XC: GDXC22XYJ7PRAFV65Z3KJ75AZIJ32BITGVEELIIQEZ65KFBGZT7BVLKI
static immutable XC = KeyPair(PublicKey([238, 45, 106, 248, 79, 223, 16, 22, 190, 238, 118, 164, 255, 160, 202, 19, 189, 5, 19, 53, 72, 69, 161, 16, 38, 125, 213, 20, 38, 204, 254, 26]), SecretKey([16, 212, 174, 3, 97, 253, 131, 248, 206, 249, 89, 63, 58, 9, 70, 86, 189, 56, 198, 214, 126, 119, 112, 47, 147, 110, 166, 201, 223, 20, 200, 66]), Seed([204, 222, 65, 142, 140, 184, 99, 190, 91, 254, 231, 204, 253, 137, 63, 78, 158, 224, 214, 243, 171, 205, 19, 199, 203, 186, 176, 123, 237, 35, 77, 54]));
/// XD: GDXD226ZBUNP2YLAO5EFSB6RVVBNM3ZLWRVY2TDFBWX3DMB7GRBZQEMK
static immutable XD = KeyPair(PublicKey([238, 61, 107, 217, 13, 26, 253, 97, 96, 119, 72, 89, 7, 209, 173, 66, 214, 111, 43, 180, 107, 141, 76, 101, 13, 175, 177, 176, 63, 52, 67, 152]), SecretKey([176, 224, 40, 133, 187, 198, 219, 17, 81, 23, 206, 238, 7, 221, 133, 204, 227, 29, 168, 104, 248, 135, 219, 166, 239, 18, 86, 118, 96, 228, 87, 64]), Seed([217, 3, 147, 179, 41, 81, 242, 177, 148, 185, 181, 22, 27, 34, 97, 118, 163, 224, 236, 76, 97, 216, 87, 174, 77, 65, 40, 13, 214, 183, 218, 141]));
/// XE: GDXE222ZRDVI7ZRYYUGK5KPZ7UHP2XT5QQ2IX7YFCOJD5NY7D4UBIGJS
static immutable XE = KeyPair(PublicKey([238, 77, 107, 89, 136, 234, 143, 230, 56, 197, 12, 174, 169, 249, 253, 14, 253, 94, 125, 132, 52, 139, 255, 5, 19, 146, 62, 183, 31, 31, 40, 20]), SecretKey([176, 200, 181, 63, 203, 8, 97, 249, 156, 75, 225, 152, 81, 215, 35, 82, 49, 235, 36, 89, 20, 253, 141, 181, 235, 192, 194, 110, 87, 200, 215, 82]), Seed([145, 70, 30, 228, 214, 135, 103, 140, 74, 240, 137, 51, 10, 40, 242, 249, 23, 50, 2, 43, 203, 119, 41, 169, 176, 220, 133, 62, 141, 54, 123, 252]));
/// XF: GDXF22UDOB5XRIYHJJW772ZJUKF45QLQHTL43YOODNQNXJCSDP3QF2IY
static immutable XF = KeyPair(PublicKey([238, 93, 106, 131, 112, 123, 120, 163, 7, 74, 109, 255, 235, 41, 162, 139, 206, 193, 112, 60, 215, 205, 225, 206, 27, 96, 219, 164, 82, 27, 247, 2]), SecretKey([104, 47, 24, 239, 6, 92, 155, 108, 57, 114, 178, 174, 119, 53, 213, 131, 8, 137, 141, 113, 43, 220, 67, 32, 76, 23, 104, 41, 38, 14, 202, 101]), Seed([70, 198, 249, 79, 52, 172, 127, 240, 194, 172, 21, 245, 178, 188, 99, 3, 165, 10, 86, 21, 55, 255, 58, 157, 251, 88, 22, 3, 83, 245, 102, 185]));
/// XG: GDXG22M5QCAROHK6HZ3MSM7NPLAWCEIOMQUPQTRKBAHDPZBSLL3NJTBS
static immutable XG = KeyPair(PublicKey([238, 109, 105, 157, 128, 129, 23, 29, 94, 62, 118, 201, 51, 237, 122, 193, 97, 17, 14, 100, 40, 248, 78, 42, 8, 14, 55, 228, 50, 90, 246, 212]), SecretKey([120, 191, 131, 38, 53, 82, 213, 238, 43, 142, 218, 26, 10, 109, 133, 246, 57, 213, 153, 186, 151, 231, 98, 208, 97, 119, 116, 136, 53, 41, 188, 82]), Seed([189, 45, 211, 6, 185, 4, 54, 86, 98, 239, 242, 123, 23, 91, 242, 102, 185, 168, 67, 75, 230, 25, 115, 147, 29, 232, 189, 246, 63, 72, 204, 86]));
/// XH: GDXH22E2BCDVTWAGCALRBLXC5VNQW7YBVLTPNQH2FNY4UZFO4AD7YGPS
static immutable XH = KeyPair(PublicKey([238, 125, 104, 154, 8, 135, 89, 216, 6, 16, 23, 16, 174, 226, 237, 91, 11, 127, 1, 170, 230, 246, 192, 250, 43, 113, 202, 100, 174, 224, 7, 252]), SecretKey([200, 1, 245, 24, 70, 237, 141, 34, 252, 113, 22, 213, 191, 123, 21, 143, 37, 150, 36, 114, 31, 206, 45, 232, 70, 108, 79, 154, 250, 167, 234, 118]), Seed([230, 107, 15, 149, 28, 221, 48, 60, 187, 5, 136, 181, 158, 206, 219, 156, 199, 168, 255, 64, 0, 123, 22, 221, 55, 179, 119, 121, 130, 190, 198, 178]));
/// XI: GDXI22PGQONMCU5NFIJMXPBZL5T36C746QJPR7WLCC7KQMISVFDSS72F
static immutable XI = KeyPair(PublicKey([238, 141, 105, 230, 131, 154, 193, 83, 173, 42, 18, 203, 188, 57, 95, 103, 191, 11, 252, 244, 18, 248, 254, 203, 16, 190, 168, 49, 18, 169, 71, 41]), SecretKey([8, 44, 67, 222, 188, 214, 92, 127, 1, 114, 130, 151, 111, 116, 108, 180, 14, 237, 23, 14, 175, 33, 224, 111, 67, 250, 7, 9, 64, 136, 22, 86]), Seed([217, 243, 82, 69, 240, 24, 226, 8, 18, 109, 157, 0, 5, 225, 159, 235, 74, 9, 5, 26, 14, 251, 53, 209, 83, 157, 215, 81, 240, 155, 234, 38]));
/// XJ: GDXJ22I7RZDXFT42ZMINOQZXTOSAFSRZK74IIPFIOMET4JWOATZH6NXK
static immutable XJ = KeyPair(PublicKey([238, 157, 105, 31, 142, 71, 114, 207, 154, 203, 16, 215, 67, 55, 155, 164, 2, 202, 57, 87, 248, 132, 60, 168, 115, 9, 62, 38, 206, 4, 242, 127]), SecretKey([120, 16, 41, 204, 4, 12, 68, 62, 162, 17, 101, 187, 62, 143, 206, 181, 115, 216, 219, 81, 141, 205, 49, 210, 157, 98, 44, 251, 147, 252, 182, 87]), Seed([232, 218, 50, 65, 116, 182, 104, 215, 156, 92, 110, 166, 156, 229, 76, 42, 215, 200, 30, 214, 164, 248, 108, 250, 156, 132, 151, 195, 131, 133, 18, 220]));
/// XK: GDXK22T6WQAOCLHA7JSMLEFFCWEN6WHIN56LNLPJOW6M6IV5XLVYKGVG
static immutable XK = KeyPair(PublicKey([238, 173, 106, 126, 180, 0, 225, 44, 224, 250, 100, 197, 144, 165, 21, 136, 223, 88, 232, 111, 124, 182, 173, 233, 117, 188, 207, 34, 189, 186, 235, 133]), SecretKey([232, 173, 128, 15, 214, 28, 52, 142, 87, 214, 33, 239, 187, 54, 209, 205, 13, 144, 0, 223, 192, 139, 151, 189, 43, 110, 165, 201, 15, 57, 68, 112]), Seed([158, 194, 197, 172, 72, 28, 248, 176, 201, 117, 115, 87, 225, 92, 70, 243, 67, 50, 239, 15, 225, 37, 233, 227, 250, 183, 75, 11, 132, 97, 92, 141]));
/// XL: GDXL2226D44JXCTI36SANFZSSYP3SLQ3PP7V5LT3POOLFGE3KRE3AMEO
static immutable XL = KeyPair(PublicKey([238, 189, 107, 94, 31, 56, 155, 138, 104, 223, 164, 6, 151, 50, 150, 31, 185, 46, 27, 123, 255, 94, 174, 123, 123, 156, 178, 152, 155, 84, 73, 176]), SecretKey([0, 211, 26, 106, 195, 208, 41, 251, 202, 205, 55, 24, 132, 0, 70, 95, 96, 38, 1, 62, 164, 201, 184, 193, 149, 43, 18, 214, 91, 4, 49, 126]), Seed([50, 195, 29, 161, 73, 192, 209, 184, 30, 82, 9, 20, 221, 6, 224, 248, 58, 229, 192, 48, 100, 123, 137, 94, 79, 113, 166, 134, 121, 202, 17, 55]));
/// XM: GDXM22L3O7XRA24FP7BPRM5ADFGIAYZAC2K5QVFOT4OJXAKCNVCZ4YRO
static immutable XM = KeyPair(PublicKey([238, 205, 105, 123, 119, 239, 16, 107, 133, 127, 194, 248, 179, 160, 25, 76, 128, 99, 32, 22, 149, 216, 84, 174, 159, 28, 155, 129, 66, 109, 69, 158]), SecretKey([192, 39, 187, 121, 236, 114, 164, 124, 227, 39, 137, 41, 143, 155, 234, 160, 54, 30, 255, 76, 153, 249, 197, 62, 190, 174, 229, 44, 191, 231, 24, 102]), Seed([215, 238, 214, 177, 233, 11, 131, 162, 187, 168, 1, 49, 185, 160, 3, 55, 176, 199, 233, 253, 192, 26, 131, 186, 145, 255, 34, 95, 106, 229, 200, 235]));
/// XN: GDXN22X7MYNVZKEICOBUISVNR3F4XXRLWPII32N6ESO5OBA3R65KZXZM
static immutable XN = KeyPair(PublicKey([238, 221, 106, 255, 102, 27, 92, 168, 136, 19, 131, 68, 74, 173, 142, 203, 203, 222, 43, 179, 208, 141, 233, 190, 36, 157, 215, 4, 27, 143, 186, 172]), SecretKey([128, 118, 85, 111, 21, 84, 235, 221, 121, 43, 0, 22, 96, 176, 129, 28, 178, 8, 241, 118, 87, 218, 70, 166, 123, 75, 91, 116, 138, 40, 64, 126]), Seed([187, 42, 251, 212, 106, 17, 34, 128, 142, 103, 85, 210, 96, 150, 85, 202, 81, 133, 63, 67, 205, 107, 198, 75, 149, 195, 178, 227, 104, 135, 79, 130]));
/// XO: GDXO22LTXH7BZYDEYU2STUMZ4DWVA7URM72VYLHKPRZJP5ZULSWRDQK2
static immutable XO = KeyPair(PublicKey([238, 237, 105, 115, 185, 254, 28, 224, 100, 197, 53, 41, 209, 153, 224, 237, 80, 126, 145, 103, 245, 92, 44, 234, 124, 114, 151, 247, 52, 92, 173, 17]), SecretKey([208, 8, 138, 21, 103, 120, 96, 250, 38, 138, 66, 185, 0, 135, 66, 219, 70, 238, 9, 225, 152, 247, 158, 106, 254, 135, 189, 253, 180, 224, 21, 109]), Seed([119, 112, 4, 51, 81, 14, 21, 2, 28, 140, 231, 28, 92, 217, 175, 120, 188, 143, 49, 0, 204, 245, 243, 29, 140, 53, 206, 158, 204, 126, 110, 17]));
/// XP: GDXP22J6MZA6DMTLNHBHIAUG3D5IPN2S5JFAOULAKFZVLTIBUMZOGNRD
static immutable XP = KeyPair(PublicKey([238, 253, 105, 62, 102, 65, 225, 178, 107, 105, 194, 116, 2, 134, 216, 250, 135, 183, 82, 234, 74, 7, 81, 96, 81, 115, 85, 205, 1, 163, 50, 227]), SecretKey([136, 0, 164, 47, 114, 172, 5, 110, 126, 124, 116, 163, 79, 70, 54, 154, 50, 251, 124, 6, 163, 26, 9, 21, 215, 10, 218, 40, 107, 248, 111, 82]), Seed([250, 170, 12, 101, 16, 29, 65, 197, 127, 50, 62, 160, 123, 98, 108, 25, 227, 136, 165, 249, 138, 5, 49, 131, 24, 157, 105, 7, 88, 13, 213, 90]));
/// XQ: GDXQ22GBQNYAG5YFVLOPYZBWV4KV2DY24OLBYM364OREXR3FUWR4SJOV
static immutable XQ = KeyPair(PublicKey([239, 13, 104, 193, 131, 112, 3, 119, 5, 170, 220, 252, 100, 54, 175, 21, 93, 15, 26, 227, 150, 28, 51, 126, 227, 162, 75, 199, 101, 165, 163, 201]), SecretKey([168, 223, 45, 99, 94, 22, 175, 164, 33, 183, 17, 15, 226, 115, 76, 150, 101, 83, 32, 105, 159, 153, 99, 46, 223, 63, 20, 130, 43, 23, 249, 102]), Seed([120, 153, 201, 59, 197, 214, 164, 80, 209, 13, 183, 137, 222, 150, 202, 246, 27, 152, 3, 224, 224, 143, 114, 238, 119, 77, 223, 13, 4, 200, 63, 244]));
/// XR: GDXR22YBUHZ7W4B3RRDLSJ3WY2PI6G6HRL7GOPP3NUAAL2YORQGMBP5Q
static immutable XR = KeyPair(PublicKey([239, 29, 107, 1, 161, 243, 251, 112, 59, 140, 70, 185, 39, 118, 198, 158, 143, 27, 199, 138, 254, 103, 61, 251, 109, 0, 5, 235, 14, 140, 12, 192]), SecretKey([24, 138, 38, 222, 147, 245, 28, 172, 161, 237, 22, 65, 172, 234, 25, 50, 206, 30, 154, 2, 53, 70, 185, 244, 218, 81, 253, 225, 252, 249, 51, 119]), Seed([147, 18, 104, 197, 44, 93, 225, 221, 155, 199, 191, 213, 39, 118, 124, 41, 195, 248, 147, 109, 186, 71, 92, 203, 116, 162, 152, 29, 147, 151, 9, 113]));
/// XS: GDXS22FIDAFO3V7ZZYPYHGF4HZWHDFIRT3IRQHO7EGR4ZB2OA4K3WOTL
static immutable XS = KeyPair(PublicKey([239, 45, 104, 168, 24, 10, 237, 215, 249, 206, 31, 131, 152, 188, 62, 108, 113, 149, 17, 158, 209, 24, 29, 223, 33, 163, 204, 135, 78, 7, 21, 187]), SecretKey([128, 49, 110, 211, 212, 235, 31, 44, 244, 20, 90, 37, 7, 30, 131, 13, 84, 208, 88, 53, 83, 73, 87, 56, 115, 218, 247, 143, 227, 240, 21, 115]), Seed([209, 251, 191, 146, 87, 17, 171, 157, 53, 14, 168, 215, 219, 87, 36, 15, 20, 176, 153, 208, 243, 106, 250, 119, 120, 221, 192, 143, 208, 168, 188, 153]));
/// XT: GDXT22BONUXDW77E4VZOWIRCOOIZLCVDF4T4RCKYU5N4LF5MZDRTLOMV
static immutable XT = KeyPair(PublicKey([239, 61, 104, 46, 109, 46, 59, 127, 228, 229, 114, 235, 34, 34, 115, 145, 149, 138, 163, 47, 39, 200, 137, 88, 167, 91, 197, 151, 172, 200, 227, 53]), SecretKey([48, 173, 57, 24, 255, 27, 161, 132, 24, 174, 107, 247, 222, 185, 120, 82, 252, 134, 8, 13, 152, 94, 225, 182, 137, 33, 136, 96, 220, 36, 141, 100]), Seed([25, 181, 157, 12, 193, 68, 45, 103, 219, 222, 1, 148, 197, 31, 17, 124, 89, 195, 220, 10, 136, 171, 241, 151, 205, 221, 63, 45, 229, 89, 47, 122]));
/// XU: GDXU22WPVHKKVME5APW4DTDESIAQADP6Z2F5XUQIEZLHLWAYHKIK3YT3
static immutable XU = KeyPair(PublicKey([239, 77, 106, 207, 169, 212, 170, 176, 157, 3, 237, 193, 204, 100, 146, 1, 0, 13, 254, 206, 139, 219, 210, 8, 38, 86, 117, 216, 24, 58, 144, 173]), SecretKey([72, 64, 90, 75, 178, 137, 131, 10, 150, 124, 68, 147, 129, 245, 141, 39, 247, 130, 90, 222, 181, 191, 174, 144, 78, 246, 184, 213, 93, 172, 114, 80]), Seed([241, 249, 204, 186, 68, 18, 33, 151, 185, 79, 103, 127, 56, 183, 175, 128, 73, 52, 44, 27, 157, 23, 168, 125, 86, 32, 118, 228, 58, 92, 73, 144]));
/// XV: GDXV22JOVPRTIIRLZGJRQPKJNRPFUCFOEEBFQYNK7AV2QEWQ2SJC5ABE
static immutable XV = KeyPair(PublicKey([239, 93, 105, 46, 171, 227, 52, 34, 43, 201, 147, 24, 61, 73, 108, 94, 90, 8, 174, 33, 2, 88, 97, 170, 248, 43, 168, 18, 208, 212, 146, 46]), SecretKey([24, 168, 108, 145, 208, 17, 2, 19, 39, 95, 226, 26, 186, 243, 103, 95, 35, 202, 9, 12, 31, 86, 0, 178, 103, 42, 250, 95, 148, 149, 156, 83]), Seed([72, 8, 54, 162, 176, 78, 55, 215, 211, 91, 220, 85, 106, 39, 238, 245, 170, 59, 234, 160, 52, 168, 101, 60, 126, 50, 9, 55, 45, 7, 215, 214]));
/// XW: GDXW22FECL5HERPBQP232SQOKEKI3XZH67PJD524EE5PMWSYIT3IF2AR
static immutable XW = KeyPair(PublicKey([239, 109, 104, 164, 18, 250, 114, 69, 225, 131, 245, 189, 74, 14, 81, 20, 141, 223, 39, 247, 222, 145, 247, 92, 33, 58, 246, 90, 88, 68, 246, 130]), SecretKey([16, 172, 60, 56, 37, 216, 184, 191, 48, 116, 14, 149, 201, 128, 203, 79, 137, 21, 39, 189, 2, 152, 172, 114, 229, 11, 90, 49, 194, 80, 194, 117]), Seed([185, 83, 209, 18, 123, 8, 51, 71, 119, 120, 206, 42, 40, 7, 29, 94, 112, 121, 111, 104, 4, 211, 162, 56, 255, 208, 132, 111, 70, 55, 56, 208]));
/// XX: GDXX22NXDZUMGFCYPTV7DIK5L42M6D54Q4AF7LF67RTYFDBKJBB7JS3L
static immutable XX = KeyPair(PublicKey([239, 125, 105, 183, 30, 104, 195, 20, 88, 124, 235, 241, 161, 93, 95, 52, 207, 15, 188, 135, 0, 95, 172, 190, 252, 103, 130, 140, 42, 72, 67, 244]), SecretKey([248, 101, 217, 79, 38, 214, 22, 173, 176, 52, 114, 26, 53, 233, 154, 196, 207, 62, 171, 153, 193, 99, 222, 166, 187, 208, 130, 7, 50, 122, 119, 127]), Seed([242, 39, 77, 60, 119, 233, 130, 191, 234, 250, 92, 103, 110, 64, 68, 30, 102, 11, 152, 1, 120, 251, 185, 173, 197, 129, 25, 144, 10, 108, 253, 120]));
/// XY: GDXY22T4L4W75NVXZFH3LWRZFMNLPKGDZHG6H4YI6CUATGWTBVKESBWZ
static immutable XY = KeyPair(PublicKey([239, 141, 106, 124, 95, 45, 254, 182, 183, 201, 79, 181, 218, 57, 43, 26, 183, 168, 195, 201, 205, 227, 243, 8, 240, 168, 9, 154, 211, 13, 84, 73]), SecretKey([232, 130, 165, 232, 192, 12, 66, 231, 182, 188, 74, 86, 88, 88, 132, 213, 19, 199, 86, 112, 137, 203, 115, 161, 201, 185, 130, 103, 105, 137, 189, 76]), Seed([25, 123, 202, 151, 118, 158, 36, 246, 165, 33, 182, 183, 3, 80, 216, 113, 205, 236, 177, 193, 98, 197, 227, 116, 171, 154, 114, 139, 226, 93, 255, 164]));
/// XZ: GDXZ22JXMYNKYDJ6UDF3IZSA6ZPERMFRCCQMD6PPBB2A4NPNTBXQY5H2
static immutable XZ = KeyPair(PublicKey([239, 157, 105, 55, 102, 26, 172, 13, 62, 160, 203, 180, 102, 64, 246, 94, 72, 176, 177, 16, 160, 193, 249, 239, 8, 116, 14, 53, 237, 152, 111, 12]), SecretKey([80, 8, 70, 248, 143, 79, 200, 87, 94, 126, 175, 51, 140, 80, 106, 167, 246, 152, 62, 153, 234, 245, 201, 6, 17, 86, 152, 172, 135, 207, 42, 113]), Seed([39, 124, 113, 74, 28, 102, 70, 173, 221, 10, 68, 205, 214, 206, 41, 196, 134, 94, 10, 163, 185, 41, 103, 99, 99, 254, 219, 111, 26, 2, 226, 17]));
/// YA: GDYA22INTZGFZIWRR3FCZV7TGDS6K33MQZ5ST7ZWUWHTP3G3F5ZKLRXN
static immutable YA = KeyPair(PublicKey([240, 13, 105, 13, 158, 76, 92, 162, 209, 142, 202, 44, 215, 243, 48, 229, 229, 111, 108, 134, 123, 41, 255, 54, 165, 143, 55, 236, 219, 47, 114, 165]), SecretKey([184, 249, 206, 14, 34, 83, 159, 229, 44, 223, 148, 159, 249, 143, 207, 127, 73, 115, 204, 219, 100, 226, 67, 185, 160, 234, 111, 89, 13, 93, 247, 122]), Seed([195, 0, 250, 50, 113, 244, 142, 211, 186, 183, 21, 255, 208, 128, 150, 70, 105, 61, 110, 20, 139, 164, 51, 168, 25, 30, 127, 123, 81, 185, 97, 162]));
/// YB: GDYB22NDD2FZZUHQWKLXZDDPSOBDP3S2N62MZRHGRZVELG6XDTNWEGBM
static immutable YB = KeyPair(PublicKey([240, 29, 105, 163, 30, 139, 156, 208, 240, 178, 151, 124, 140, 111, 147, 130, 55, 238, 90, 111, 180, 204, 196, 230, 142, 106, 69, 155, 215, 28, 219, 98]), SecretKey([112, 73, 7, 111, 235, 142, 41, 75, 223, 100, 215, 253, 11, 13, 24, 63, 249, 77, 153, 77, 122, 171, 102, 71, 117, 64, 255, 190, 210, 126, 207, 111]), Seed([68, 177, 174, 99, 31, 177, 41, 196, 252, 204, 138, 6, 123, 140, 121, 190, 117, 66, 87, 99, 65, 244, 77, 223, 211, 55, 45, 126, 248, 38, 190, 154]));
/// YC: GDYC22DI7KMFHCPZS4627XQO3OLGEOABS7OBNAIGCZCWOT2SXWQ546UO
static immutable YC = KeyPair(PublicKey([240, 45, 104, 104, 250, 152, 83, 137, 249, 151, 61, 175, 222, 14, 219, 150, 98, 56, 1, 151, 220, 22, 129, 6, 22, 69, 103, 79, 82, 189, 161, 222]), SecretKey([96, 41, 52, 43, 248, 101, 1, 28, 223, 35, 1, 0, 242, 19, 118, 55, 154, 239, 244, 156, 56, 62, 255, 10, 246, 239, 116, 58, 67, 105, 155, 96]), Seed([161, 176, 129, 180, 71, 73, 39, 248, 161, 203, 161, 175, 48, 58, 6, 240, 72, 208, 124, 158, 6, 221, 234, 55, 187, 244, 91, 227, 18, 198, 208, 119]));
/// YD: GDYD22AFGA46XEKHYAZNMYL4362MGCH3VEPNRHU4V6NUVDUG6K3AFXDX
static immutable YD = KeyPair(PublicKey([240, 61, 104, 5, 48, 57, 235, 145, 71, 192, 50, 214, 97, 124, 223, 180, 195, 8, 251, 169, 30, 216, 158, 156, 175, 155, 74, 142, 134, 242, 182, 2]), SecretKey([96, 218, 91, 189, 39, 35, 56, 60, 239, 235, 101, 50, 206, 183, 212, 186, 250, 32, 133, 112, 85, 227, 170, 59, 55, 65, 22, 202, 46, 244, 45, 88]), Seed([226, 88, 128, 81, 151, 241, 111, 157, 90, 117, 241, 81, 178, 170, 185, 199, 132, 210, 168, 21, 142, 223, 208, 182, 39, 75, 224, 172, 116, 4, 245, 59]));
/// YE: GDYE22HZ5DZ7I43DQELDZLBZ4OJRCSIDTQV3KGBVRQASZDCUJJ3LPM3Z
static immutable YE = KeyPair(PublicKey([240, 77, 104, 249, 232, 243, 244, 115, 99, 129, 22, 60, 172, 57, 227, 147, 17, 73, 3, 156, 43, 181, 24, 53, 140, 1, 44, 140, 84, 74, 118, 183]), SecretKey([88, 121, 138, 100, 6, 83, 201, 108, 196, 25, 121, 169, 125, 231, 227, 39, 243, 6, 59, 244, 193, 202, 69, 174, 147, 206, 238, 114, 111, 151, 205, 97]), Seed([121, 73, 107, 207, 168, 192, 144, 139, 223, 195, 14, 73, 223, 77, 23, 117, 152, 174, 221, 16, 158, 56, 153, 1, 221, 92, 43, 132, 41, 216, 88, 241]));
/// YF: GDYF22ICJ42MCLII3UDIMWLM2TA3LZK2DWD5W57BU27UCMH7RFSLVVQW
static immutable YF = KeyPair(PublicKey([240, 93, 105, 2, 79, 52, 193, 45, 8, 221, 6, 134, 89, 108, 212, 193, 181, 229, 90, 29, 135, 219, 119, 225, 166, 191, 65, 48, 255, 137, 100, 186]), SecretKey([80, 78, 108, 210, 0, 57, 120, 59, 242, 210, 114, 244, 208, 13, 232, 229, 48, 160, 126, 12, 103, 43, 206, 155, 83, 168, 62, 78, 98, 30, 115, 124]), Seed([31, 57, 208, 234, 76, 174, 248, 190, 207, 48, 244, 137, 147, 123, 130, 233, 223, 85, 136, 32, 108, 232, 196, 243, 231, 147, 239, 127, 255, 211, 100, 42]));
/// YG: GDYG22HFGU5AMFCTB6KKINUDXI2NAYTTMLNNPIFGWWHDYJBTV44LW3HJ
static immutable YG = KeyPair(PublicKey([240, 109, 104, 229, 53, 58, 6, 20, 83, 15, 148, 164, 54, 131, 186, 52, 208, 98, 115, 98, 218, 215, 160, 166, 181, 142, 60, 36, 51, 175, 56, 187]), SecretKey([96, 48, 34, 180, 102, 34, 88, 211, 214, 228, 130, 127, 183, 114, 93, 35, 151, 14, 203, 41, 168, 181, 135, 46, 226, 137, 107, 124, 41, 248, 173, 89]), Seed([6, 150, 47, 42, 200, 200, 35, 104, 107, 252, 64, 68, 2, 49, 216, 177, 49, 127, 166, 160, 34, 31, 152, 69, 71, 10, 45, 84, 154, 138, 39, 159]));
/// YH: GDYH22NEO7EC3NXOK2GABZLLVJEC5SG25B5ZGYQKM3TUAL3JTVUP7O6B
static immutable YH = KeyPair(PublicKey([240, 125, 105, 164, 119, 200, 45, 182, 238, 86, 140, 0, 229, 107, 170, 72, 46, 200, 218, 232, 123, 147, 98, 10, 102, 231, 64, 47, 105, 157, 104, 255]), SecretKey([24, 119, 114, 44, 29, 133, 167, 255, 238, 39, 140, 76, 92, 103, 23, 3, 249, 207, 252, 16, 228, 226, 230, 174, 73, 124, 252, 140, 104, 142, 64, 70]), Seed([152, 127, 222, 108, 2, 176, 86, 152, 129, 150, 175, 142, 154, 248, 133, 134, 99, 78, 240, 59, 35, 30, 12, 75, 152, 170, 41, 204, 240, 60, 218, 198]));
/// YI: GDYI22F2Z35PTPZ5LP37D5PUGSHJ2E2R2XXDLF2VH4MGUYQR6BOUM64L
static immutable YI = KeyPair(PublicKey([240, 141, 104, 186, 206, 250, 249, 191, 61, 91, 247, 241, 245, 244, 52, 142, 157, 19, 81, 213, 238, 53, 151, 85, 63, 24, 106, 98, 17, 240, 93, 70]), SecretKey([40, 55, 85, 107, 45, 94, 248, 209, 81, 30, 231, 8, 43, 212, 216, 116, 201, 77, 84, 192, 71, 64, 208, 134, 87, 2, 13, 95, 37, 110, 146, 68]), Seed([155, 144, 162, 236, 111, 122, 52, 190, 226, 219, 197, 197, 67, 209, 165, 55, 10, 230, 144, 117, 219, 221, 171, 23, 121, 91, 116, 221, 93, 245, 175, 164]));
/// YJ: GDYJ22YCTBNF7N3YAVHM6GAZFFQOG6SFTUQDFSPCGZ52X3RLH2OXWXCU
static immutable YJ = KeyPair(PublicKey([240, 157, 107, 2, 152, 90, 95, 183, 120, 5, 78, 207, 24, 25, 41, 96, 227, 122, 69, 157, 32, 50, 201, 226, 54, 123, 171, 238, 43, 62, 157, 123]), SecretKey([224, 29, 193, 135, 140, 169, 172, 22, 185, 9, 141, 187, 228, 34, 227, 53, 230, 17, 99, 10, 233, 84, 195, 234, 130, 142, 42, 21, 213, 157, 168, 125]), Seed([247, 223, 141, 246, 113, 4, 7, 27, 22, 225, 165, 26, 217, 25, 199, 193, 203, 3, 168, 111, 148, 191, 243, 96, 223, 27, 31, 43, 186, 109, 122, 26]));
/// YK: GDYK22RFGEQ44ZLYDZWDPH2G7U2IJKLNITG6BREKMM6AFGMU5TC66WQ7
static immutable YK = KeyPair(PublicKey([240, 173, 106, 37, 49, 33, 206, 101, 120, 30, 108, 55, 159, 70, 253, 52, 132, 169, 109, 68, 205, 224, 196, 138, 99, 60, 2, 153, 148, 236, 197, 239]), SecretKey([128, 68, 23, 124, 3, 174, 163, 181, 168, 36, 242, 210, 173, 214, 16, 105, 47, 184, 52, 194, 190, 51, 91, 247, 89, 205, 47, 28, 202, 113, 196, 78]), Seed([124, 249, 160, 54, 206, 0, 135, 132, 39, 53, 129, 166, 185, 156, 192, 253, 103, 176, 24, 114, 225, 216, 145, 178, 49, 122, 89, 24, 198, 156, 182, 127]));
/// YL: GDYL22W3AI6WFKWFWHBADKT5CF54SRJWJCCPS74IO7MKGNIOVBZUVEOD
static immutable YL = KeyPair(PublicKey([240, 189, 106, 219, 2, 61, 98, 170, 197, 177, 194, 1, 170, 125, 17, 123, 201, 69, 54, 72, 132, 249, 127, 136, 119, 216, 163, 53, 14, 168, 115, 74]), SecretKey([64, 76, 52, 122, 124, 71, 118, 192, 22, 70, 39, 17, 222, 156, 207, 184, 121, 34, 127, 189, 55, 35, 234, 255, 89, 108, 50, 39, 69, 213, 200, 117]), Seed([200, 165, 90, 125, 251, 23, 88, 30, 109, 218, 75, 177, 43, 62, 120, 20, 11, 100, 93, 115, 176, 84, 57, 194, 232, 87, 77, 88, 78, 156, 203, 207]));
/// YM: GDYM22IREQCYL56O4IZJKWBRVVFYCMAXKYJQ236HNWDQIYU4KBQHARLM
static immutable YM = KeyPair(PublicKey([240, 205, 105, 17, 36, 5, 133, 247, 206, 226, 50, 149, 88, 49, 173, 75, 129, 48, 23, 86, 19, 13, 111, 199, 109, 135, 4, 98, 156, 80, 96, 112]), SecretKey([208, 72, 160, 150, 39, 178, 149, 73, 77, 34, 27, 233, 142, 130, 239, 149, 220, 223, 31, 13, 17, 232, 218, 92, 165, 120, 227, 208, 81, 233, 3, 111]), Seed([171, 189, 169, 138, 218, 212, 48, 90, 71, 53, 241, 107, 33, 151, 149, 226, 156, 151, 141, 122, 58, 38, 97, 201, 115, 37, 98, 69, 45, 175, 145, 20]));
/// YN: GDYN22TTF4ABDAQGCPDJSOG55KUWI3SWCUR4LAKBQA3QEHDI3SAY45JW
static immutable YN = KeyPair(PublicKey([240, 221, 106, 115, 47, 0, 17, 130, 6, 19, 198, 153, 56, 221, 234, 169, 100, 110, 86, 21, 35, 197, 129, 65, 128, 55, 2, 28, 104, 220, 129, 142]), SecretKey([120, 240, 237, 53, 4, 235, 199, 164, 140, 119, 37, 142, 69, 197, 182, 129, 70, 138, 90, 236, 168, 91, 49, 136, 42, 231, 93, 168, 111, 250, 235, 66]), Seed([12, 236, 50, 95, 114, 178, 139, 190, 185, 31, 49, 130, 21, 229, 62, 62, 155, 204, 32, 241, 60, 190, 35, 129, 73, 11, 49, 233, 53, 103, 167, 36]));
/// YO: GDYO223X7PY6CJI4CLI255E2B4L54B5E4DK3LWGOEY42X7JU6KKGROB7
static immutable YO = KeyPair(PublicKey([240, 237, 107, 119, 251, 241, 225, 37, 28, 18, 209, 174, 244, 154, 15, 23, 222, 7, 164, 224, 213, 181, 216, 206, 38, 57, 171, 253, 52, 242, 148, 104]), SecretKey([112, 162, 136, 80, 68, 143, 9, 17, 108, 5, 19, 181, 225, 13, 193, 125, 162, 33, 214, 42, 121, 144, 105, 167, 123, 236, 22, 78, 214, 192, 159, 76]), Seed([240, 137, 117, 102, 86, 130, 93, 205, 35, 116, 102, 138, 109, 231, 253, 182, 102, 6, 139, 107, 209, 75, 248, 21, 219, 108, 255, 14, 3, 15, 157, 47]));
/// YP: GDYP222SDH74XCUXTTSBXK3A4B5KQL7QDKEBH6JYH72SIFWM3DLCWBJP
static immutable YP = KeyPair(PublicKey([240, 253, 107, 82, 25, 255, 203, 138, 151, 156, 228, 27, 171, 96, 224, 122, 168, 47, 240, 26, 136, 19, 249, 56, 63, 245, 36, 22, 204, 216, 214, 43]), SecretKey([176, 54, 58, 10, 84, 254, 253, 4, 36, 11, 200, 225, 162, 248, 3, 91, 1, 23, 221, 226, 111, 7, 27, 98, 14, 177, 45, 15, 242, 249, 254, 74]), Seed([59, 223, 101, 250, 4, 103, 125, 68, 119, 235, 197, 90, 35, 20, 144, 12, 250, 69, 220, 236, 194, 139, 2, 114, 53, 242, 192, 16, 122, 232, 130, 118]));
/// YQ: GDYQ22JCTGMDN2EM4Y3I6Q67Y5FHU2M4D3Q4A4RXJK35AIJOFDLP6ZOV
static immutable YQ = KeyPair(PublicKey([241, 13, 105, 34, 153, 152, 54, 232, 140, 230, 54, 143, 67, 223, 199, 74, 122, 105, 156, 30, 225, 192, 114, 55, 74, 183, 208, 33, 46, 40, 214, 255]), SecretKey([32, 14, 201, 169, 251, 30, 110, 123, 249, 202, 144, 188, 131, 180, 77, 168, 51, 210, 224, 155, 34, 241, 167, 43, 227, 31, 197, 28, 126, 177, 13, 104]), Seed([221, 222, 112, 85, 142, 29, 182, 190, 57, 123, 136, 1, 76, 7, 97, 89, 125, 36, 51, 163, 90, 110, 233, 112, 228, 65, 194, 165, 143, 152, 88, 202]));
/// YR: GDYR222OJOXMF4QULHHDWWPQVY6EM6E34IKBLCF7KLLP7ST4A6LZHONM
static immutable YR = KeyPair(PublicKey([241, 29, 107, 78, 75, 174, 194, 242, 20, 89, 206, 59, 89, 240, 174, 60, 70, 120, 155, 226, 20, 21, 136, 191, 82, 214, 255, 202, 124, 7, 151, 147]), SecretKey([184, 245, 57, 136, 26, 221, 32, 228, 0, 55, 85, 161, 196, 76, 50, 250, 251, 88, 221, 35, 166, 167, 1, 169, 52, 113, 117, 237, 58, 254, 220, 76]), Seed([184, 93, 110, 194, 109, 57, 104, 44, 74, 177, 50, 206, 214, 95, 155, 218, 44, 82, 158, 202, 199, 121, 126, 208, 76, 149, 69, 79, 197, 24, 172, 38]));
/// YS: GDYS227QTRYBQNUWX567YWSVITTW77HDGBAR2YZXH3AOMMCQBKE5DGFM
static immutable YS = KeyPair(PublicKey([241, 45, 107, 240, 156, 112, 24, 54, 150, 191, 125, 252, 90, 85, 68, 231, 111, 252, 227, 48, 65, 29, 99, 55, 62, 192, 230, 48, 80, 10, 137, 209]), SecretKey([48, 68, 123, 141, 68, 101, 188, 155, 242, 103, 146, 94, 4, 87, 176, 94, 176, 161, 4, 66, 227, 161, 22, 88, 14, 4, 252, 187, 238, 70, 4, 123]), Seed([5, 123, 154, 194, 95, 158, 177, 75, 72, 120, 214, 207, 16, 171, 24, 235, 172, 30, 104, 142, 145, 62, 10, 141, 17, 206, 58, 184, 12, 171, 33, 189]));
/// YT: GDYT22ILEXV4QHASYCGYYHIWLXDA264BAJRY3SGDG62OU5VN2IOFLSOE
static immutable YT = KeyPair(PublicKey([241, 61, 105, 11, 37, 235, 200, 28, 18, 192, 141, 140, 29, 22, 93, 198, 13, 123, 129, 2, 99, 141, 200, 195, 55, 180, 234, 118, 173, 210, 28, 85]), SecretKey([152, 215, 236, 0, 144, 253, 68, 251, 34, 211, 90, 55, 207, 75, 157, 204, 233, 254, 157, 251, 112, 73, 170, 77, 114, 59, 136, 20, 218, 17, 62, 111]), Seed([96, 132, 80, 182, 62, 113, 83, 147, 167, 161, 61, 90, 123, 56, 149, 136, 126, 43, 201, 77, 39, 174, 70, 106, 202, 244, 89, 236, 72, 137, 43, 134]));
/// YU: GDYU22KFLFLSTBVPMUCVCBZ3RFXTERWSS32AWE3HZG5VRL732FYRWAYZ
static immutable YU = KeyPair(PublicKey([241, 77, 105, 69, 89, 87, 41, 134, 175, 101, 5, 81, 7, 59, 137, 111, 50, 70, 210, 150, 244, 11, 19, 103, 201, 187, 88, 175, 251, 209, 113, 27]), SecretKey([104, 92, 236, 34, 72, 231, 26, 44, 38, 216, 132, 95, 62, 250, 172, 217, 146, 155, 43, 229, 168, 193, 24, 137, 13, 83, 156, 225, 211, 199, 44, 65]), Seed([103, 173, 161, 1, 39, 142, 7, 49, 241, 47, 128, 242, 99, 27, 232, 36, 157, 49, 168, 54, 117, 203, 38, 85, 55, 116, 108, 195, 146, 58, 27, 214]));
/// YV: GDYV225H4IPP6ENR3M6OSOFGIOYUAKDQGHMHHWLOUNU5DNUIKJPVIFJU
static immutable YV = KeyPair(PublicKey([241, 93, 107, 167, 226, 30, 255, 17, 177, 219, 60, 233, 56, 166, 67, 177, 64, 40, 112, 49, 216, 115, 217, 110, 163, 105, 209, 182, 136, 82, 95, 84]), SecretKey([144, 10, 118, 249, 179, 206, 24, 236, 225, 103, 248, 23, 158, 56, 59, 211, 160, 127, 102, 76, 69, 116, 254, 237, 245, 12, 161, 123, 172, 190, 13, 114]), Seed([181, 20, 210, 16, 96, 62, 42, 152, 31, 184, 61, 48, 183, 148, 1, 3, 212, 104, 39, 198, 127, 160, 38, 145, 240, 249, 62, 200, 65, 44, 232, 199]));
/// YW: GDYW22ZCK5NTNV7IYEYAYJZEHT2NHCGGUZDUACEIOGBNBJ7GL2DF2TS2
static immutable YW = KeyPair(PublicKey([241, 109, 107, 34, 87, 91, 54, 215, 232, 193, 48, 12, 39, 36, 60, 244, 211, 136, 198, 166, 71, 64, 8, 136, 113, 130, 208, 167, 230, 94, 134, 93]), SecretKey([232, 104, 74, 27, 216, 125, 86, 211, 4, 8, 69, 39, 113, 98, 178, 154, 54, 66, 147, 38, 143, 112, 115, 48, 77, 214, 103, 6, 120, 108, 95, 112]), Seed([14, 226, 125, 223, 26, 240, 86, 204, 66, 101, 159, 210, 103, 184, 228, 2, 80, 97, 221, 75, 111, 164, 154, 95, 204, 202, 29, 98, 27, 28, 21, 87]));
/// YX: GDYX22QUYIJTX5JHSNNYDIALB4SB4HPOOVI4WJIYZMRMC2KKEKMUT27Q
static immutable YX = KeyPair(PublicKey([241, 125, 106, 20, 194, 19, 59, 245, 39, 147, 91, 129, 160, 11, 15, 36, 30, 29, 238, 117, 81, 203, 37, 24, 203, 34, 193, 105, 74, 34, 153, 73]), SecretKey([120, 111, 153, 187, 191, 34, 191, 45, 56, 142, 112, 205, 137, 107, 89, 89, 103, 78, 28, 70, 108, 151, 63, 58, 109, 168, 141, 54, 177, 66, 224, 104]), Seed([4, 246, 12, 227, 145, 154, 240, 51, 91, 235, 37, 195, 175, 190, 46, 248, 156, 3, 230, 163, 134, 6, 119, 232, 169, 246, 84, 98, 178, 234, 78, 183]));
/// YY: GDYY22C6MDNGK6Q5KQK3JTTKABJUGM6XPYLX57BZCCCAVTBFSMZZ4HNP
static immutable YY = KeyPair(PublicKey([241, 141, 104, 94, 96, 218, 101, 122, 29, 84, 21, 180, 206, 106, 0, 83, 67, 51, 215, 126, 23, 126, 252, 57, 16, 132, 10, 204, 37, 147, 51, 158]), SecretKey([112, 184, 200, 61, 201, 146, 193, 1, 213, 230, 100, 220, 131, 168, 177, 222, 13, 155, 217, 104, 217, 70, 40, 173, 96, 7, 200, 227, 61, 14, 135, 115]), Seed([131, 13, 77, 104, 152, 235, 233, 118, 139, 115, 31, 129, 27, 196, 63, 49, 230, 21, 237, 144, 74, 105, 254, 9, 94, 228, 162, 163, 254, 24, 155, 156]));
/// YZ: GDYZ22YIDKGEW7DO5DRW6GEN5WSWVCHKLECVZSDVUOPE7UO2GGF62FMA
static immutable YZ = KeyPair(PublicKey([241, 157, 107, 8, 26, 140, 75, 124, 110, 232, 227, 111, 24, 141, 237, 165, 106, 136, 234, 89, 5, 92, 200, 117, 163, 158, 79, 209, 218, 49, 139, 237]), SecretKey([136, 196, 100, 241, 214, 188, 247, 202, 148, 241, 59, 80, 192, 3, 52, 71, 205, 2, 18, 147, 133, 165, 105, 179, 231, 126, 107, 247, 35, 105, 246, 118]), Seed([175, 161, 5, 99, 154, 48, 23, 13, 253, 189, 26, 133, 36, 239, 98, 220, 69, 79, 232, 87, 66, 245, 96, 250, 86, 136, 59, 173, 140, 4, 223, 217]));
/// ZA: GDZA22F3L5TBBUV64JYRSGW4EAKEYSBC7ZFHHNFZ2FSUSBT567654VYC
static immutable ZA = KeyPair(PublicKey([242, 13, 104, 187, 95, 102, 16, 210, 190, 226, 113, 25, 26, 220, 32, 20, 76, 72, 34, 254, 74, 115, 180, 185, 209, 101, 73, 6, 125, 247, 253, 222]), SecretKey([248, 40, 239, 164, 24, 222, 68, 213, 149, 188, 243, 238, 229, 60, 56, 183, 192, 61, 112, 128, 16, 136, 154, 88, 100, 122, 221, 241, 145, 214, 118, 123]), Seed([93, 212, 97, 169, 30, 147, 84, 237, 141, 47, 151, 206, 43, 3, 137, 82, 104, 104, 228, 240, 91, 73, 83, 157, 216, 232, 125, 227, 168, 94, 98, 21]));
/// ZB: GDZB224O3JO2WORO4WXCTC5QDKFOOH437RYUSTJC3UANTXTVPPN3HVA2
static immutable ZB = KeyPair(PublicKey([242, 29, 107, 142, 218, 93, 171, 58, 46, 229, 174, 41, 139, 176, 26, 138, 231, 31, 155, 252, 113, 73, 77, 34, 221, 0, 217, 222, 117, 123, 219, 179]), SecretKey([184, 198, 56, 239, 111, 10, 240, 46, 127, 4, 88, 187, 56, 153, 64, 21, 227, 101, 5, 151, 72, 47, 211, 86, 76, 4, 81, 137, 66, 3, 1, 112]), Seed([188, 79, 52, 232, 125, 164, 44, 250, 56, 117, 221, 52, 140, 125, 152, 159, 223, 234, 1, 203, 247, 177, 82, 150, 183, 209, 91, 218, 254, 49, 239, 90]));
/// ZC: GDZC22CMTMMOP6REGXHUQLHJTTQCYHIEXPY3BCLHKP3DL2PK7M6KVCYU
static immutable ZC = KeyPair(PublicKey([242, 45, 104, 76, 155, 24, 231, 250, 36, 53, 207, 72, 44, 233, 156, 224, 44, 29, 4, 187, 241, 176, 137, 103, 83, 246, 53, 233, 234, 251, 60, 170]), SecretKey([88, 34, 128, 61, 116, 230, 97, 140, 25, 127, 7, 72, 163, 218, 52, 185, 163, 83, 118, 38, 238, 57, 190, 70, 81, 218, 33, 123, 156, 82, 83, 99]), Seed([195, 52, 73, 174, 76, 73, 76, 87, 41, 199, 151, 150, 154, 75, 204, 217, 225, 206, 147, 251, 122, 172, 212, 137, 10, 238, 203, 48, 136, 103, 61, 204]));
/// ZD: GDZD22F5TIVRZEQHHL44OJ7PBSI6IKICKJ7BPFJEXYYCRZFFKFVUYC7H
static immutable ZD = KeyPair(PublicKey([242, 61, 104, 189, 154, 43, 28, 146, 7, 58, 249, 199, 39, 239, 12, 145, 228, 41, 2, 82, 126, 23, 149, 36, 190, 48, 40, 228, 165, 81, 107, 76]), SecretKey([88, 175, 141, 136, 13, 91, 232, 127, 54, 38, 85, 100, 242, 177, 111, 13, 224, 100, 166, 165, 135, 176, 84, 110, 93, 30, 4, 179, 17, 237, 163, 76]), Seed([117, 54, 219, 190, 92, 220, 34, 109, 28, 196, 79, 125, 115, 191, 25, 84, 139, 79, 197, 168, 138, 233, 224, 47, 180, 156, 73, 181, 230, 229, 104, 128]));
/// ZE: GDZE22L3HDKNLALO23VTBBSJTVQNAPH4CBN26ZAVYDXXVB3MOIAFFXZP
static immutable ZE = KeyPair(PublicKey([242, 77, 105, 123, 56, 212, 213, 129, 110, 214, 235, 48, 134, 73, 157, 96, 208, 60, 252, 16, 91, 175, 100, 21, 192, 239, 122, 135, 108, 114, 0, 82]), SecretKey([64, 97, 240, 76, 4, 87, 128, 135, 172, 192, 20, 137, 128, 169, 197, 63, 66, 233, 16, 151, 95, 128, 175, 161, 116, 113, 250, 49, 92, 20, 211, 83]), Seed([176, 31, 249, 246, 35, 85, 183, 12, 115, 129, 224, 95, 137, 2, 222, 181, 196, 76, 196, 68, 201, 149, 39, 247, 115, 150, 117, 104, 73, 194, 66, 105]));
/// ZF: GDZF22G5ZLFILNA4QB5B522JJW6P6DN4GQE4YBKTINKG35Q4H3F7Z3NX
static immutable ZF = KeyPair(PublicKey([242, 93, 104, 221, 202, 202, 133, 180, 28, 128, 122, 30, 235, 73, 77, 188, 255, 13, 188, 52, 9, 204, 5, 83, 67, 84, 109, 246, 28, 62, 203, 252]), SecretKey([96, 138, 9, 187, 28, 251, 37, 63, 111, 68, 34, 223, 152, 196, 44, 104, 158, 244, 18, 97, 9, 83, 137, 34, 162, 62, 142, 108, 239, 249, 176, 106]), Seed([27, 170, 129, 62, 148, 161, 182, 112, 36, 228, 181, 28, 56, 175, 113, 125, 48, 208, 233, 13, 123, 232, 53, 53, 94, 81, 37, 222, 194, 205, 84, 158]));
/// ZG: GDZG22BF767FGF5UWNJ3XUGJR7CHXYMISF5Y4QKE727RZDVO3JO3DLPT
static immutable ZG = KeyPair(PublicKey([242, 109, 104, 37, 255, 190, 83, 23, 180, 179, 83, 187, 208, 201, 143, 196, 123, 225, 136, 145, 123, 142, 65, 68, 254, 191, 28, 142, 174, 218, 93, 177]), SecretKey([120, 125, 13, 102, 64, 24, 132, 186, 122, 36, 12, 88, 137, 89, 78, 115, 53, 180, 119, 2, 248, 199, 219, 87, 210, 24, 15, 208, 227, 36, 65, 112]), Seed([233, 117, 130, 7, 81, 35, 103, 190, 198, 150, 195, 209, 56, 146, 13, 125, 234, 227, 232, 153, 3, 96, 251, 88, 235, 211, 124, 1, 214, 64, 220, 154]));
/// ZH: GDZH2247U7KNUGZYGKY5OS6ALEMTG2NB7J6SBWCRGKWE6YROIVPBRLH3
static immutable ZH = KeyPair(PublicKey([242, 125, 107, 159, 167, 212, 218, 27, 56, 50, 177, 215, 75, 192, 89, 25, 51, 105, 161, 250, 125, 32, 216, 81, 50, 172, 79, 98, 46, 69, 94, 24]), SecretKey([48, 169, 134, 68, 36, 113, 52, 255, 145, 220, 40, 147, 171, 182, 216, 153, 250, 203, 196, 71, 210, 60, 154, 3, 5, 195, 199, 74, 142, 42, 82, 75]), Seed([88, 237, 136, 224, 200, 189, 169, 141, 95, 10, 178, 202, 126, 233, 120, 181, 26, 29, 127, 143, 140, 51, 19, 29, 211, 110, 237, 142, 13, 124, 202, 147]));
/// ZI: GDZI22T2GTKO6PBQLKOSIYHKYFWEVSUWYVQD5JM5EYLCWRSDGPZH7OVT
static immutable ZI = KeyPair(PublicKey([242, 141, 106, 122, 52, 212, 239, 60, 48, 90, 157, 36, 96, 234, 193, 108, 74, 202, 150, 197, 96, 62, 165, 157, 38, 22, 43, 70, 67, 51, 242, 127]), SecretKey([24, 50, 46, 27, 177, 226, 64, 161, 235, 57, 149, 115, 89, 82, 213, 159, 239, 250, 241, 209, 195, 238, 60, 21, 32, 70, 233, 235, 133, 79, 131, 86]), Seed([22, 3, 179, 49, 127, 251, 105, 246, 116, 78, 134, 173, 60, 192, 161, 175, 240, 162, 102, 31, 187, 126, 221, 246, 36, 60, 62, 214, 234, 64, 115, 142]));
/// ZJ: GDZJ22HSG4HZ4Q25GD4ZWRBXR2FVR3RMKQIRX2EVOVTOLWWS3PMULSEF
static immutable ZJ = KeyPair(PublicKey([242, 157, 104, 242, 55, 15, 158, 67, 93, 48, 249, 155, 68, 55, 142, 139, 88, 238, 44, 84, 17, 27, 232, 149, 117, 102, 229, 218, 210, 219, 217, 69]), SecretKey([168, 115, 216, 180, 21, 243, 208, 48, 206, 39, 169, 89, 8, 169, 11, 50, 0, 140, 143, 211, 20, 96, 30, 232, 81, 188, 33, 124, 142, 210, 245, 94]), Seed([156, 22, 105, 155, 45, 156, 196, 144, 179, 74, 217, 130, 242, 219, 69, 96, 205, 96, 157, 200, 16, 77, 173, 223, 243, 72, 171, 90, 79, 223, 46, 66]));
/// ZK: GDZK22NNIU6HXTUSPHG4EI3TANBEKT7WC4PIW4KTELQPRJVYXZP6HP73
static immutable ZK = KeyPair(PublicKey([242, 173, 105, 173, 69, 60, 123, 206, 146, 121, 205, 194, 35, 115, 3, 66, 69, 79, 246, 23, 30, 139, 113, 83, 34, 224, 248, 166, 184, 190, 95, 227]), SecretKey([208, 123, 219, 82, 125, 246, 187, 207, 13, 122, 199, 128, 187, 101, 84, 4, 209, 250, 25, 184, 6, 147, 218, 104, 106, 204, 218, 226, 167, 17, 30, 90]), Seed([230, 149, 41, 167, 232, 197, 75, 88, 230, 249, 9, 245, 216, 239, 130, 249, 93, 146, 249, 62, 176, 81, 87, 6, 250, 159, 82, 232, 237, 95, 213, 31]));
/// ZL: GDZL22CVEFXU3Q3YYLXWFV4BYCLWRRAQQ5CYM4QSOYD42UUC2BL7WR3S
static immutable ZL = KeyPair(PublicKey([242, 189, 104, 85, 33, 111, 77, 195, 120, 194, 239, 98, 215, 129, 192, 151, 104, 196, 16, 135, 69, 134, 114, 18, 118, 7, 205, 82, 130, 208, 87, 251]), SecretKey([104, 213, 95, 117, 211, 65, 40, 91, 215, 230, 99, 123, 112, 126, 9, 129, 177, 80, 161, 81, 246, 62, 76, 39, 170, 146, 215, 1, 118, 172, 22, 125]), Seed([247, 124, 128, 27, 43, 11, 150, 188, 211, 174, 132, 118, 64, 119, 57, 165, 168, 163, 171, 89, 222, 102, 110, 22, 15, 92, 88, 221, 78, 127, 224, 236]));
/// ZM: GDZM22CDKRB3EBPNFBPO2YW42RGNN7ED6IIR7MMX5GCBVBKI4OEZZIFS
static immutable ZM = KeyPair(PublicKey([242, 205, 104, 67, 84, 67, 178, 5, 237, 40, 94, 237, 98, 220, 212, 76, 214, 252, 131, 242, 17, 31, 177, 151, 233, 132, 26, 133, 72, 227, 137, 156]), SecretKey([232, 135, 228, 32, 16, 178, 1, 0, 107, 242, 2, 217, 16, 162, 13, 60, 249, 139, 179, 185, 13, 83, 214, 244, 14, 179, 232, 199, 135, 22, 195, 83]), Seed([100, 185, 11, 116, 221, 110, 93, 4, 224, 136, 111, 152, 219, 244, 214, 140, 66, 253, 132, 51, 200, 127, 223, 82, 223, 52, 193, 248, 189, 160, 190, 81]));
/// ZN: GDZN22XQEAHRPLLAKHVQ54SFLWDSBN2L6IYU2SGWFN26QGRAGY2KDYOC
static immutable ZN = KeyPair(PublicKey([242, 221, 106, 240, 32, 15, 23, 173, 96, 81, 235, 14, 242, 69, 93, 135, 32, 183, 75, 242, 49, 77, 72, 214, 43, 117, 232, 26, 32, 54, 52, 161]), SecretKey([216, 184, 142, 147, 8, 18, 6, 240, 6, 83, 195, 0, 245, 64, 190, 197, 236, 182, 189, 67, 12, 40, 5, 139, 139, 10, 239, 183, 117, 101, 224, 70]), Seed([113, 18, 248, 207, 65, 18, 63, 166, 123, 71, 191, 232, 174, 16, 228, 191, 204, 172, 157, 62, 235, 4, 157, 229, 52, 4, 100, 118, 76, 17, 199, 36]));
/// ZO: GDZO224SGVHXZXWQDBYRYB47Q2YRRURODIFLKHL7ANUSEOKP7DOPZQ2K
static immutable ZO = KeyPair(PublicKey([242, 237, 107, 146, 53, 79, 124, 222, 208, 24, 113, 28, 7, 159, 134, 177, 24, 210, 46, 26, 10, 181, 29, 127, 3, 105, 34, 57, 79, 248, 220, 252]), SecretKey([168, 185, 8, 244, 107, 21, 192, 236, 69, 9, 63, 176, 233, 211, 135, 89, 91, 116, 88, 217, 133, 45, 199, 76, 75, 6, 211, 142, 2, 101, 3, 94]), Seed([176, 160, 147, 52, 246, 170, 251, 133, 76, 12, 142, 1, 195, 52, 153, 231, 67, 136, 120, 230, 251, 76, 34, 71, 199, 26, 27, 236, 81, 236, 41, 43]));
/// ZP: GDZP22S6YFGRVZSQ4DZSEB4BUGZX66FF4OKHWNXYP3IHUQAKRPEH2WJE
static immutable ZP = KeyPair(PublicKey([242, 253, 106, 94, 193, 77, 26, 230, 80, 224, 243, 34, 7, 129, 161, 179, 127, 120, 165, 227, 148, 123, 54, 248, 126, 208, 122, 64, 10, 139, 200, 125]), SecretKey([56, 180, 236, 169, 76, 192, 68, 254, 102, 239, 192, 109, 37, 1, 194, 127, 114, 90, 236, 167, 135, 133, 36, 223, 6, 138, 114, 23, 254, 176, 14, 94]), Seed([71, 74, 18, 27, 55, 58, 128, 134, 214, 44, 152, 205, 58, 246, 166, 213, 124, 228, 179, 223, 59, 166, 57, 111, 144, 74, 106, 204, 252, 68, 164, 110]));
/// ZQ: GDZQ22NXRWJIXBCOIPI6AAXBBWWCDCUV24NHL7XWPWSNUOPQUVF6FMHP
static immutable ZQ = KeyPair(PublicKey([243, 13, 105, 183, 141, 146, 139, 132, 78, 67, 209, 224, 2, 225, 13, 172, 33, 138, 149, 215, 26, 117, 254, 246, 125, 164, 218, 57, 240, 165, 75, 226]), SecretKey([88, 185, 220, 17, 19, 14, 185, 9, 184, 22, 49, 202, 98, 42, 26, 237, 202, 80, 104, 15, 202, 101, 49, 235, 205, 205, 165, 65, 255, 142, 205, 98]), Seed([32, 77, 87, 250, 35, 242, 86, 128, 51, 190, 188, 124, 39, 139, 44, 162, 177, 245, 215, 150, 62, 43, 28, 108, 22, 179, 67, 163, 20, 220, 210, 235]));
/// ZR: GDZR22VEHDAG47T6HOBKQVW3IAJND3J5NZTYVSTDTGVEWLHV4YI2LAVY
static immutable ZR = KeyPair(PublicKey([243, 29, 106, 164, 56, 192, 110, 126, 126, 59, 130, 168, 86, 219, 64, 18, 209, 237, 61, 110, 103, 138, 202, 99, 153, 170, 75, 44, 245, 230, 17, 165]), SecretKey([168, 181, 117, 151, 220, 122, 191, 182, 79, 54, 83, 135, 153, 137, 193, 185, 179, 91, 14, 30, 120, 202, 106, 100, 34, 156, 252, 171, 234, 250, 76, 77]), Seed([199, 48, 143, 5, 32, 215, 8, 82, 209, 156, 109, 98, 76, 62, 69, 102, 239, 247, 77, 28, 107, 135, 45, 196, 4, 128, 129, 167, 104, 119, 47, 203]));
/// ZS: GDZS224ZYKWW3AULYMSBVTU7DY6UOS3RBBYU75BO2YR62V6BEC7S556B
static immutable ZS = KeyPair(PublicKey([243, 45, 107, 153, 194, 173, 109, 130, 139, 195, 36, 26, 206, 159, 30, 61, 71, 75, 113, 8, 113, 79, 244, 46, 214, 35, 237, 87, 193, 32, 191, 46]), SecretKey([72, 157, 189, 150, 63, 85, 218, 225, 208, 137, 204, 194, 139, 116, 144, 183, 250, 68, 236, 117, 112, 189, 19, 145, 1, 108, 3, 232, 85, 64, 92, 105]), Seed([137, 119, 252, 75, 117, 184, 245, 176, 228, 233, 110, 12, 54, 62, 113, 222, 134, 78, 77, 49, 22, 1, 205, 232, 171, 103, 215, 25, 198, 0, 21, 127]));
/// ZT: GDZT22TDHPDI5J4FDOVQUKKQ6MVHJHNCNGXWNORLZARZY32QHBTQ4FWS
static immutable ZT = KeyPair(PublicKey([243, 61, 106, 99, 59, 198, 142, 167, 133, 27, 171, 10, 41, 80, 243, 42, 116, 157, 162, 105, 175, 102, 186, 43, 200, 35, 156, 111, 80, 56, 103, 14]), SecretKey([72, 215, 181, 161, 94, 129, 119, 166, 138, 43, 122, 216, 254, 5, 89, 68, 234, 121, 148, 149, 39, 166, 70, 182, 215, 17, 212, 188, 39, 194, 127, 64]), Seed([86, 130, 71, 107, 223, 158, 85, 102, 27, 162, 193, 146, 56, 144, 247, 140, 55, 222, 140, 50, 172, 41, 226, 111, 29, 179, 50, 254, 20, 57, 77, 58]));
/// ZU: GDZU22PQFJNOEFHF4QR35OP5HFT6N2TPONX4UMDJ5HBN2TUQFJSWY37O
static immutable ZU = KeyPair(PublicKey([243, 77, 105, 240, 42, 90, 226, 20, 229, 228, 35, 190, 185, 253, 57, 103, 230, 234, 111, 115, 111, 202, 48, 105, 233, 194, 221, 78, 144, 42, 101, 108]), SecretKey([112, 62, 181, 48, 46, 135, 210, 98, 190, 7, 185, 6, 238, 201, 46, 133, 41, 214, 161, 67, 229, 246, 255, 160, 161, 87, 208, 209, 153, 65, 106, 65]), Seed([62, 65, 3, 23, 125, 230, 181, 149, 43, 120, 116, 118, 160, 129, 88, 202, 250, 238, 92, 72, 31, 42, 199, 78, 191, 247, 37, 80, 134, 166, 25, 137]));
/// ZV: GDZV22LGCLEYBDYLQBIT4B2CEEVH7P4JZ42FPEJNTJWP6TEWMI42WT5Z
static immutable ZV = KeyPair(PublicKey([243, 93, 105, 102, 18, 201, 128, 143, 11, 128, 81, 62, 7, 66, 33, 42, 127, 191, 137, 207, 52, 87, 145, 45, 154, 108, 255, 76, 150, 98, 57, 171]), SecretKey([168, 27, 137, 146, 117, 12, 86, 99, 203, 119, 166, 182, 110, 47, 190, 35, 2, 197, 25, 96, 154, 206, 145, 184, 10, 188, 201, 19, 78, 26, 193, 89]), Seed([30, 193, 118, 253, 2, 36, 222, 188, 54, 223, 188, 69, 29, 184, 231, 182, 34, 134, 212, 113, 171, 255, 52, 9, 70, 185, 18, 229, 75, 68, 197, 121]));
/// ZW: GDZW22VOIU6C6ZPPLLC2U4XJGXWVRGRHQTLIR6GYZXN3VHH34SJSYIIZ
static immutable ZW = KeyPair(PublicKey([243, 109, 106, 174, 69, 60, 47, 101, 239, 90, 197, 170, 114, 233, 53, 237, 88, 154, 39, 132, 214, 136, 248, 216, 205, 219, 186, 156, 251, 228, 147, 44]), SecretKey([96, 160, 196, 96, 108, 157, 39, 220, 228, 160, 29, 38, 250, 197, 161, 123, 19, 133, 158, 150, 163, 178, 64, 248, 37, 95, 8, 241, 31, 38, 251, 123]), Seed([13, 224, 38, 200, 253, 40, 30, 96, 72, 121, 78, 124, 240, 55, 210, 42, 81, 54, 9, 10, 207, 92, 141, 208, 166, 52, 220, 218, 175, 118, 70, 178]));
/// ZX: GDZX22IDKZYNWJ3WLQAX2V2FSCJZC77UJ2K6KORY4MYGXP4SZYAMSSJH
static immutable ZX = KeyPair(PublicKey([243, 125, 105, 3, 86, 112, 219, 39, 118, 92, 1, 125, 87, 69, 144, 147, 145, 127, 244, 78, 149, 229, 58, 56, 227, 48, 107, 191, 146, 206, 0, 201]), SecretKey([208, 29, 85, 31, 172, 118, 100, 25, 8, 146, 4, 169, 67, 167, 216, 111, 63, 149, 123, 215, 33, 71, 49, 86, 133, 74, 151, 145, 60, 44, 91, 110]), Seed([182, 33, 80, 75, 115, 246, 214, 58, 28, 30, 189, 177, 237, 189, 61, 239, 105, 149, 152, 246, 8, 85, 59, 158, 98, 166, 44, 128, 204, 83, 56, 49]));
/// ZY: GDZY22COQUMMYNNZLF4YRF4NLJDE7NKNZIAXE7VKWU6A3CKWIA7KUA7C
static immutable ZY = KeyPair(PublicKey([243, 141, 104, 78, 133, 24, 204, 53, 185, 89, 121, 136, 151, 141, 90, 70, 79, 181, 77, 202, 1, 114, 126, 170, 181, 60, 13, 137, 86, 64, 62, 170]), SecretKey([240, 238, 246, 82, 22, 91, 180, 116, 91, 176, 81, 197, 135, 38, 119, 101, 51, 100, 252, 82, 192, 66, 185, 232, 113, 172, 122, 45, 36, 121, 67, 126]), Seed([214, 109, 101, 82, 122, 89, 14, 155, 232, 232, 28, 193, 224, 129, 87, 207, 184, 230, 55, 27, 134, 119, 89, 149, 8, 66, 131, 227, 19, 193, 124, 9]));
/// ZZ: GDZZ22UDGFFBWK2RSYKFVLWP3G7A67JU3PVWC7CRFCEMWEQ5DRGHWPXX
static immutable ZZ = KeyPair(PublicKey([243, 157, 106, 131, 49, 74, 27, 43, 81, 150, 20, 90, 174, 207, 217, 190, 15, 125, 52, 219, 235, 97, 124, 81, 40, 136, 203, 18, 29, 28, 76, 123]), SecretKey([40, 84, 34, 185, 227, 215, 90, 183, 175, 113, 241, 133, 242, 99, 45, 108, 190, 106, 124, 176, 100, 255, 145, 61, 157, 183, 147, 115, 249, 184, 195, 74]), Seed([27, 123, 205, 39, 103, 133, 167, 65, 181, 81, 19, 173, 182, 150, 177, 32, 174, 201, 193, 17, 139, 154, 169, 225, 55, 165, 56, 223, 37, 183, 118, 46]));
/// AAA: GDAAA22HJYVHS3DOJBRTPT4YJQO5ALJ4HT6WKEY3LJDSUH2CI62BJYE5
static immutable AAA = KeyPair(PublicKey([192, 0, 107, 71, 78, 42, 121, 108, 110, 72, 99, 55, 207, 152, 76, 29, 208, 45, 60, 60, 253, 101, 19, 27, 90, 71, 42, 31, 66, 71, 180, 20]), SecretKey([56, 122, 32, 179, 239, 202, 40, 62, 231, 79, 30, 28, 80, 171, 219, 156, 12, 175, 96, 103, 137, 225, 106, 63, 86, 132, 73, 146, 173, 17, 26, 82]), Seed([52, 216, 153, 162, 45, 121, 104, 19, 234, 166, 201, 12, 14, 161, 233, 74, 62, 129, 45, 146, 228, 141, 187, 39, 255, 201, 238, 2, 5, 254, 101, 45]));
/// AAB: GDAAB22W7WFM7GEAX2APV3HRVVRGUMIXWHUS3NQJ3FEPUALHPRPUTJPP
static immutable AAB = KeyPair(PublicKey([192, 0, 235, 86, 253, 138, 207, 152, 128, 190, 128, 250, 236, 241, 173, 98, 106, 49, 23, 177, 233, 45, 182, 9, 217, 72, 250, 1, 103, 124, 95, 73]), SecretKey([152, 229, 41, 147, 31, 166, 115, 55, 55, 121, 247, 254, 219, 2, 102, 218, 5, 4, 239, 84, 244, 200, 211, 150, 202, 231, 219, 17, 173, 53, 222, 97]), Seed([234, 159, 55, 225, 218, 192, 227, 45, 113, 0, 77, 67, 125, 162, 58, 236, 166, 246, 185, 110, 101, 159, 143, 238, 50, 235, 14, 61, 43, 135, 237, 22]));
/// AAC: GDAAC22LRUX5R3NB5NZJMZLZPSL4EGKCNJHB62PUUPNXKM7GDREQCTCJ
static immutable AAC = KeyPair(PublicKey([192, 1, 107, 75, 141, 47, 216, 237, 161, 235, 114, 150, 101, 121, 124, 151, 194, 25, 66, 106, 78, 31, 105, 244, 163, 219, 117, 51, 230, 28, 73, 1]), SecretKey([224, 250, 208, 117, 156, 38, 193, 249, 229, 248, 44, 145, 196, 50, 101, 141, 100, 216, 51, 122, 37, 14, 66, 105, 143, 171, 145, 43, 190, 80, 92, 69]), Seed([5, 18, 230, 91, 230, 30, 167, 138, 12, 88, 134, 79, 215, 41, 98, 3, 43, 146, 27, 163, 49, 21, 102, 125, 104, 185, 41, 116, 232, 174, 232, 12]));
/// AAD: GDAAD22C5ZNFKIZP34MTV43BAIMZI5FQS4GYQWWUH3ASQPDVAZG3RFZI
static immutable AAD = KeyPair(PublicKey([192, 1, 235, 66, 238, 90, 85, 35, 47, 223, 25, 58, 243, 97, 2, 25, 148, 116, 176, 151, 13, 136, 90, 212, 62, 193, 40, 60, 117, 6, 77, 184]), SecretKey([192, 26, 155, 207, 209, 19, 101, 48, 26, 24, 176, 211, 143, 161, 127, 223, 177, 160, 42, 138, 106, 238, 253, 93, 47, 198, 50, 202, 11, 241, 248, 105]), Seed([96, 9, 68, 36, 233, 246, 147, 212, 240, 208, 28, 146, 237, 134, 147, 94, 85, 250, 63, 178, 210, 186, 148, 223, 24, 29, 39, 36, 232, 242, 113, 219]));
/// AAE: GDAAE227Q6MCOQURAMFKNJVD6NWFAQ3NPXX7UEKYHUL3OJ6GQDLSYSGN
static immutable AAE = KeyPair(PublicKey([192, 2, 107, 95, 135, 152, 39, 66, 145, 3, 10, 166, 166, 163, 243, 108, 80, 67, 109, 125, 239, 250, 17, 88, 61, 23, 183, 39, 198, 128, 215, 44]), SecretKey([24, 24, 29, 149, 193, 88, 250, 233, 70, 117, 224, 83, 251, 145, 228, 218, 92, 55, 244, 145, 21, 142, 50, 240, 106, 68, 70, 160, 7, 125, 154, 122]), Seed([54, 58, 222, 114, 87, 255, 211, 224, 175, 0, 42, 93, 179, 53, 194, 13, 138, 92, 31, 226, 3, 195, 115, 17, 59, 115, 254, 206, 159, 88, 18, 159]));
/// AAF: GDAAF227J5QCBR53XI5STERYLYKUUQ7W5X7SEFX4KXJ4ZOXOLKKNAINP
static immutable AAF = KeyPair(PublicKey([192, 2, 235, 95, 79, 96, 32, 199, 187, 186, 59, 41, 146, 56, 94, 21, 74, 67, 246, 237, 255, 34, 22, 252, 85, 211, 204, 186, 238, 90, 148, 208]), SecretKey([232, 24, 68, 99, 143, 219, 88, 34, 95, 234, 107, 183, 21, 63, 218, 5, 223, 23, 126, 245, 86, 237, 210, 88, 115, 14, 246, 32, 253, 35, 91, 97]), Seed([199, 121, 134, 165, 57, 193, 48, 123, 225, 218, 104, 117, 33, 247, 120, 39, 111, 49, 93, 249, 13, 157, 191, 76, 222, 98, 189, 163, 128, 163, 192, 181]));
/// AAG: GDAAG22GD7G2JTAECH5ZO7WJ6HQF4QAFC6XAVHPZDWM5AI3D65E2LI6A
static immutable AAG = KeyPair(PublicKey([192, 3, 107, 70, 31, 205, 164, 204, 4, 17, 251, 151, 126, 201, 241, 224, 94, 64, 5, 23, 174, 10, 157, 249, 29, 153, 208, 35, 99, 247, 73, 165]), SecretKey([176, 4, 254, 106, 252, 12, 200, 244, 216, 55, 150, 116, 56, 8, 233, 109, 19, 189, 124, 237, 51, 1, 152, 198, 86, 67, 124, 58, 92, 8, 31, 122]), Seed([250, 84, 156, 88, 6, 12, 219, 153, 230, 173, 237, 30, 103, 23, 248, 94, 75, 143, 197, 249, 119, 244, 206, 246, 135, 7, 177, 162, 131, 123, 82, 253]));
/// AAH: GDAAH227GGL6AFTWPHNVU3676YZQWNZTSQHH6IIJNIS6IFCXSZM3ZTHK
static immutable AAH = KeyPair(PublicKey([192, 3, 235, 95, 49, 151, 224, 22, 118, 121, 219, 90, 111, 223, 246, 51, 11, 55, 51, 148, 14, 127, 33, 9, 106, 37, 228, 20, 87, 150, 89, 188]), SecretKey([104, 173, 142, 6, 240, 66, 4, 8, 232, 65, 127, 49, 124, 41, 200, 174, 48, 167, 178, 247, 21, 190, 25, 4, 254, 215, 203, 151, 225, 148, 105, 126]), Seed([37, 210, 129, 205, 3, 145, 152, 252, 141, 131, 186, 135, 132, 88, 168, 113, 3, 217, 251, 1, 51, 235, 171, 196, 112, 15, 10, 148, 37, 217, 147, 203]));
/// AAI: GDAAI22Z76ML4PRV5B3UGDOGAAUYASZKSVM7HB34EKYAWW6EVL23ZHSE
static immutable AAI = KeyPair(PublicKey([192, 4, 107, 89, 255, 152, 190, 62, 53, 232, 119, 67, 13, 198, 0, 41, 128, 75, 42, 149, 89, 243, 135, 124, 34, 176, 11, 91, 196, 170, 245, 188]), SecretKey([16, 42, 50, 36, 12, 152, 70, 74, 188, 26, 115, 105, 224, 164, 171, 202, 81, 16, 63, 121, 124, 92, 46, 24, 218, 254, 188, 119, 98, 13, 122, 91]), Seed([170, 190, 67, 23, 2, 240, 221, 46, 48, 191, 234, 189, 20, 242, 29, 103, 226, 137, 153, 173, 97, 135, 255, 37, 250, 191, 51, 161, 91, 39, 206, 237]));
/// AAJ: GDAAJ22N2SK53OZMOB7XNVIJHBRLF4JZOMID3C6BEFHHYYTTNMM6CAHC
static immutable AAJ = KeyPair(PublicKey([192, 4, 235, 77, 212, 149, 221, 187, 44, 112, 127, 118, 213, 9, 56, 98, 178, 241, 57, 115, 16, 61, 139, 193, 33, 78, 124, 98, 115, 107, 25, 225]), SecretKey([152, 149, 154, 131, 24, 226, 43, 138, 139, 156, 14, 32, 77, 210, 233, 242, 203, 8, 216, 240, 159, 184, 89, 219, 107, 187, 213, 68, 136, 25, 181, 101]), Seed([200, 131, 102, 12, 32, 218, 107, 3, 231, 238, 188, 189, 69, 42, 37, 52, 205, 22, 124, 218, 39, 51, 200, 96, 101, 5, 169, 13, 181, 50, 44, 217]));
/// AAK: GDAAK22XSIUGIFDLAJTEDBU2GYGJ3MBCBGK34AH4A4KU64AVZF2JEM5L
static immutable AAK = KeyPair(PublicKey([192, 5, 107, 87, 146, 40, 100, 20, 107, 2, 102, 65, 134, 154, 54, 12, 157, 176, 34, 9, 149, 190, 0, 252, 7, 21, 79, 112, 21, 201, 116, 146]), SecretKey([160, 52, 85, 146, 109, 28, 190, 143, 177, 3, 157, 57, 139, 239, 48, 221, 107, 61, 153, 104, 246, 179, 23, 245, 176, 50, 113, 185, 64, 51, 52, 98]), Seed([233, 175, 80, 62, 247, 210, 254, 98, 106, 119, 87, 214, 36, 249, 160, 27, 190, 3, 181, 43, 187, 204, 18, 27, 118, 31, 220, 36, 111, 121, 17, 127]));
/// AAL: GDAAL22FBWMB7L2CZ5FUFE3ZG6KG4YLI5JF2N3WHUDC5ATINKBXPGND5
static immutable AAL = KeyPair(PublicKey([192, 5, 235, 69, 13, 152, 31, 175, 66, 207, 75, 66, 147, 121, 55, 148, 110, 97, 104, 234, 75, 166, 238, 199, 160, 197, 208, 77, 13, 80, 110, 243]), SecretKey([176, 242, 69, 50, 208, 63, 239, 146, 162, 51, 5, 138, 219, 39, 224, 22, 94, 17, 172, 96, 180, 106, 144, 130, 43, 68, 74, 214, 232, 4, 241, 71]), Seed([190, 149, 54, 17, 67, 26, 46, 242, 14, 90, 133, 11, 90, 220, 51, 230, 74, 179, 56, 129, 172, 10, 4, 175, 193, 15, 110, 220, 39, 193, 227, 149]));
/// AAM: GDAAM22XYTQKWNO2UHAHLP3HRWR74AG265PT5B2RN475WUIF6NYVCZH2
static immutable AAM = KeyPair(PublicKey([192, 6, 107, 87, 196, 224, 171, 53, 218, 161, 192, 117, 191, 103, 141, 163, 254, 0, 218, 247, 95, 62, 135, 81, 111, 63, 219, 81, 5, 243, 113, 81]), SecretKey([144, 230, 147, 100, 24, 161, 247, 227, 226, 204, 79, 205, 173, 34, 85, 193, 102, 200, 218, 242, 123, 242, 95, 50, 201, 148, 194, 10, 102, 113, 18, 86]), Seed([182, 78, 216, 196, 229, 161, 38, 156, 124, 93, 88, 136, 116, 56, 176, 25, 233, 62, 62, 199, 154, 62, 195, 160, 187, 158, 113, 14, 41, 119, 226, 44]));
/// AAN: GDAAN22Y5JOEUMMG22JDF344GERYIZEGS3UADJNYSHUD5IEQNBTZC2RU
static immutable AAN = KeyPair(PublicKey([192, 6, 235, 88, 234, 92, 74, 49, 134, 214, 146, 50, 239, 156, 49, 35, 132, 100, 134, 150, 232, 1, 165, 184, 145, 232, 62, 160, 144, 104, 103, 145]), SecretKey([72, 202, 175, 125, 139, 133, 8, 144, 154, 21, 157, 230, 93, 239, 188, 98, 227, 101, 151, 26, 89, 7, 129, 154, 154, 87, 81, 208, 245, 170, 184, 76]), Seed([148, 211, 59, 106, 28, 100, 174, 128, 97, 42, 78, 211, 187, 124, 219, 109, 29, 148, 69, 83, 216, 192, 204, 12, 157, 47, 45, 94, 180, 112, 173, 5]));
/// AAO: GDAAO22CU6A6LZCN6FMOIVV4QZP5A2EWVMBAKWPUYUDKB2GBOVUS2W3Y
static immutable AAO = KeyPair(PublicKey([192, 7, 107, 66, 167, 129, 229, 228, 77, 241, 88, 228, 86, 188, 134, 95, 208, 104, 150, 171, 2, 5, 89, 244, 197, 6, 160, 232, 193, 117, 105, 45]), SecretKey([64, 55, 119, 14, 141, 179, 219, 43, 223, 171, 67, 2, 104, 31, 102, 115, 200, 48, 97, 187, 135, 22, 100, 129, 166, 5, 161, 175, 131, 97, 97, 87]), Seed([251, 132, 15, 219, 77, 7, 67, 111, 119, 76, 87, 99, 236, 162, 95, 121, 20, 58, 219, 13, 189, 19, 28, 153, 140, 149, 37, 183, 108, 209, 249, 42]));
/// AAP: GDAAP22FU6C35P7KRQB4LGUP4CI62QHJEMMSZEEWQEYYIRBN55R2EC3H
static immutable AAP = KeyPair(PublicKey([192, 7, 235, 69, 167, 133, 190, 191, 234, 140, 3, 197, 154, 143, 224, 145, 237, 64, 233, 35, 25, 44, 144, 150, 129, 49, 132, 68, 45, 239, 99, 162]), SecretKey([8, 231, 142, 67, 40, 109, 181, 152, 253, 123, 114, 25, 181, 43, 251, 54, 224, 228, 22, 96, 252, 68, 127, 126, 136, 242, 194, 251, 218, 93, 184, 114]), Seed([79, 167, 177, 50, 130, 194, 141, 17, 255, 51, 205, 89, 187, 65, 166, 95, 136, 95, 9, 57, 162, 25, 72, 126, 175, 15, 239, 245, 22, 25, 98, 234]));
/// AAQ: GDAAQ22NV25EOKRLEIVEUHO36H3CRYFA5ML75JY7ZEMFDCXV2QHT5P6D
static immutable AAQ = KeyPair(PublicKey([192, 8, 107, 77, 174, 186, 71, 42, 43, 34, 42, 74, 29, 219, 241, 246, 40, 224, 160, 235, 23, 254, 167, 31, 201, 24, 81, 138, 245, 212, 15, 62]), SecretKey([128, 65, 211, 54, 157, 210, 222, 79, 108, 26, 186, 181, 246, 97, 107, 63, 40, 253, 118, 25, 86, 74, 65, 136, 29, 77, 84, 229, 19, 127, 217, 79]), Seed([7, 192, 76, 29, 174, 55, 30, 129, 20, 86, 6, 21, 12, 179, 160, 72, 50, 234, 111, 34, 115, 102, 226, 60, 41, 228, 171, 59, 23, 172, 17, 250]));
/// AAR: GDAAR22PSVWBVPYO3F6BD6STF4ULTQ4CEJESFDFUGBAJAWHURKBIE37D
static immutable AAR = KeyPair(PublicKey([192, 8, 235, 79, 149, 108, 26, 191, 14, 217, 124, 17, 250, 83, 47, 40, 185, 195, 130, 34, 73, 34, 140, 180, 48, 64, 144, 88, 244, 138, 130, 130]), SecretKey([136, 15, 194, 218, 157, 227, 116, 16, 235, 184, 182, 25, 52, 56, 44, 6, 181, 46, 138, 196, 23, 86, 64, 87, 81, 68, 49, 224, 110, 77, 159, 114]), Seed([243, 148, 112, 136, 66, 154, 100, 30, 164, 39, 4, 6, 53, 65, 125, 60, 106, 191, 199, 80, 183, 151, 14, 210, 94, 237, 199, 33, 213, 101, 23, 159]));
/// AAS: GDAAS22SL4NL6RROYUOH4AIQBU2VGVWF2YQFZ3SEJFLP6YFS4HOOOOYS
static immutable AAS = KeyPair(PublicKey([192, 9, 107, 82, 95, 26, 191, 70, 46, 197, 28, 126, 1, 16, 13, 53, 83, 86, 197, 214, 32, 92, 238, 68, 73, 86, 255, 96, 178, 225, 220, 231]), SecretKey([176, 33, 204, 232, 235, 35, 91, 43, 26, 120, 13, 59, 34, 61, 24, 72, 0, 190, 10, 102, 90, 250, 187, 3, 209, 115, 35, 30, 75, 59, 180, 114]), Seed([162, 218, 233, 251, 94, 228, 165, 86, 76, 173, 199, 213, 62, 249, 195, 18, 95, 25, 120, 198, 105, 216, 65, 24, 181, 34, 13, 44, 177, 2, 72, 224]));
/// AAT: GDAAT22R2UFKA7N3UAPXIZ64QAEWEAPUKN7MYKQ3NOLJONTNPK6M5GZY
static immutable AAT = KeyPair(PublicKey([192, 9, 235, 81, 213, 10, 160, 125, 187, 160, 31, 116, 103, 220, 128, 9, 98, 1, 244, 83, 126, 204, 42, 27, 107, 150, 151, 54, 109, 122, 188, 206]), SecretKey([240, 77, 3, 68, 144, 167, 247, 247, 63, 228, 10, 119, 45, 25, 62, 27, 214, 13, 165, 255, 157, 10, 199, 225, 90, 104, 61, 80, 186, 52, 155, 92]), Seed([165, 233, 21, 142, 69, 239, 86, 144, 42, 152, 241, 226, 117, 80, 40, 166, 107, 122, 57, 102, 96, 246, 2, 44, 110, 137, 16, 114, 62, 14, 61, 99]));
/// AAU: GDAAU22OZBKEZE44NRUVFMPSJJGZNQ7JPM65BXNZRZ5NLUNY6KYRTVUZ
static immutable AAU = KeyPair(PublicKey([192, 10, 107, 78, 200, 84, 76, 147, 156, 108, 105, 82, 177, 242, 74, 77, 150, 195, 233, 123, 61, 208, 221, 185, 142, 122, 213, 209, 184, 242, 177, 25]), SecretKey([56, 133, 193, 30, 112, 109, 75, 230, 81, 197, 74, 143, 246, 147, 124, 27, 228, 205, 177, 40, 181, 162, 40, 216, 249, 27, 135, 106, 15, 206, 86, 88]), Seed([107, 147, 56, 241, 57, 112, 115, 213, 106, 134, 139, 254, 147, 252, 156, 45, 68, 18, 74, 193, 93, 31, 174, 235, 237, 139, 9, 84, 201, 112, 5, 97]));
/// AAV: GDAAV226AAWIQPMZEN4XCBDUI7ITIH44LLIWKEDLMMBJG3XVQHDII4IX
static immutable AAV = KeyPair(PublicKey([192, 10, 235, 94, 0, 44, 136, 61, 153, 35, 121, 113, 4, 116, 71, 209, 52, 31, 156, 90, 209, 101, 16, 107, 99, 2, 147, 110, 245, 129, 198, 132]), SecretKey([72, 67, 204, 82, 108, 136, 227, 146, 176, 180, 165, 251, 138, 26, 97, 118, 91, 41, 132, 213, 77, 45, 70, 245, 62, 251, 137, 122, 169, 73, 251, 109]), Seed([122, 50, 81, 51, 108, 4, 104, 69, 229, 42, 162, 61, 10, 35, 66, 86, 205, 107, 79, 64, 234, 237, 207, 249, 105, 204, 186, 13, 154, 71, 231, 158]));
/// AAW: GDAAW22BGT3C3YPOYJNQVJNE7L6MKZJF723SEQBFPUP46X5ADC65EZZ7
static immutable AAW = KeyPair(PublicKey([192, 11, 107, 65, 52, 246, 45, 225, 238, 194, 91, 10, 165, 164, 250, 252, 197, 101, 37, 254, 183, 34, 64, 37, 125, 31, 207, 95, 160, 24, 189, 210]), SecretKey([200, 155, 177, 207, 19, 106, 140, 176, 190, 63, 39, 189, 146, 124, 5, 12, 172, 44, 236, 144, 15, 65, 81, 242, 222, 42, 31, 229, 195, 68, 58, 99]), Seed([50, 125, 35, 24, 105, 87, 249, 37, 61, 164, 132, 101, 138, 206, 232, 91, 163, 251, 110, 112, 194, 90, 223, 241, 147, 230, 138, 131, 52, 209, 153, 52]));
/// AAX: GDAAX2245IOJISSLTGBP4XTZMTPLBSUCRJ4LF4Y3VLVDJNXYMB3XVMPH
static immutable AAX = KeyPair(PublicKey([192, 11, 235, 92, 234, 28, 148, 74, 75, 153, 130, 254, 94, 121, 100, 222, 176, 202, 130, 138, 120, 178, 243, 27, 170, 234, 52, 182, 248, 96, 119, 122]), SecretKey([88, 177, 235, 182, 127, 188, 55, 218, 108, 230, 197, 17, 184, 94, 234, 42, 129, 232, 251, 170, 61, 181, 123, 136, 122, 17, 231, 249, 103, 14, 102, 69]), Seed([106, 66, 182, 96, 91, 33, 59, 109, 147, 188, 117, 237, 95, 60, 65, 85, 185, 84, 145, 214, 142, 5, 78, 213, 35, 252, 232, 10, 169, 20, 69, 19]));
/// AAY: GDAAY22D6B6H5R72WHUPAE4N54SG3XYHS72D3D23M5DJCNRRARWEEHGY
static immutable AAY = KeyPair(PublicKey([192, 12, 107, 67, 240, 124, 126, 199, 250, 177, 232, 240, 19, 141, 239, 36, 109, 223, 7, 151, 244, 61, 143, 91, 103, 70, 145, 54, 49, 4, 108, 66]), SecretKey([200, 40, 175, 130, 48, 86, 209, 189, 32, 14, 180, 145, 125, 61, 20, 133, 97, 9, 158, 206, 153, 209, 247, 112, 9, 249, 175, 21, 9, 242, 24, 119]), Seed([221, 49, 51, 224, 138, 44, 126, 74, 137, 212, 148, 216, 222, 200, 62, 126, 182, 218, 61, 25, 162, 30, 227, 249, 89, 35, 39, 251, 110, 106, 139, 120]));
/// AAZ: GDAAZ22X74QOO7UXFSFFW2QQ7ZVTXMMYWB752SLAUPJIHSA2V4HZASIX
static immutable AAZ = KeyPair(PublicKey([192, 12, 235, 87, 255, 32, 231, 126, 151, 44, 138, 91, 106, 16, 254, 107, 59, 177, 152, 176, 127, 221, 73, 96, 163, 210, 131, 200, 26, 175, 15, 144]), SecretKey([208, 98, 80, 241, 235, 86, 4, 83, 124, 101, 174, 87, 52, 105, 197, 245, 3, 85, 59, 146, 133, 124, 216, 45, 4, 138, 118, 165, 64, 229, 213, 72]), Seed([78, 32, 246, 239, 83, 1, 2, 224, 77, 110, 219, 128, 119, 197, 92, 81, 232, 167, 238, 165, 63, 98, 235, 170, 194, 136, 113, 209, 71, 108, 173, 118]));
/// ABA: GDABA22X2YZMDTTFU4BJMEEUQKJOXPGHD7NGVCQS6CTLT5RQJBYGHCWM
static immutable ABA = KeyPair(PublicKey([192, 16, 107, 87, 214, 50, 193, 206, 101, 167, 2, 150, 16, 148, 130, 146, 235, 188, 199, 31, 218, 106, 138, 18, 240, 166, 185, 246, 48, 72, 112, 99]), SecretKey([192, 64, 21, 246, 233, 152, 55, 76, 240, 131, 30, 81, 164, 87, 151, 17, 36, 234, 158, 77, 175, 168, 148, 14, 84, 216, 108, 130, 14, 115, 195, 102]), Seed([120, 172, 105, 131, 175, 216, 116, 138, 140, 152, 36, 223, 193, 194, 34, 239, 189, 249, 97, 140, 226, 44, 6, 9, 156, 183, 4, 140, 67, 10, 219, 94]));
/// ABB: GDABB225GSY36AMQMNRX5LHWPM2Z4O33BXJLDCCLNYKE4QGOIOWDXBZR
static immutable ABB = KeyPair(PublicKey([192, 16, 235, 93, 52, 177, 191, 1, 144, 99, 99, 126, 172, 246, 123, 53, 158, 59, 123, 13, 210, 177, 136, 75, 110, 20, 78, 64, 206, 67, 172, 59]), SecretKey([8, 97, 249, 151, 196, 187, 61, 129, 235, 178, 205, 53, 197, 249, 5, 100, 243, 51, 21, 154, 220, 93, 26, 126, 207, 214, 166, 136, 206, 109, 137, 124]), Seed([159, 155, 9, 106, 96, 239, 78, 165, 222, 40, 139, 127, 138, 135, 174, 227, 158, 72, 196, 3, 252, 73, 218, 95, 133, 139, 113, 35, 85, 198, 77, 254]));
/// ABC: GDABC22VBKC6NB2ULN7LXTE3UKTGXSQP7SDKRVIXXV4L54D72XZCHNQ5
static immutable ABC = KeyPair(PublicKey([192, 17, 107, 85, 10, 133, 230, 135, 84, 91, 126, 187, 204, 155, 162, 166, 107, 202, 15, 252, 134, 168, 213, 23, 189, 120, 190, 240, 127, 213, 242, 35]), SecretKey([184, 120, 251, 37, 197, 137, 77, 204, 211, 28, 222, 162, 227, 166, 231, 21, 92, 61, 82, 232, 210, 52, 235, 242, 18, 74, 83, 105, 148, 118, 228, 88]), Seed([79, 69, 141, 241, 123, 244, 22, 28, 35, 32, 31, 185, 123, 122, 231, 196, 124, 103, 100, 55, 48, 231, 117, 48, 178, 160, 79, 229, 233, 146, 221, 190]));
/// ABD: GDABD22LOVHMMNQUTQMFIUJRJM7TDHH3FB65RJNWVPEXZZG4EXB7L3RK
static immutable ABD = KeyPair(PublicKey([192, 17, 235, 75, 117, 78, 198, 54, 20, 156, 24, 84, 81, 49, 75, 63, 49, 156, 251, 40, 125, 216, 165, 182, 171, 201, 124, 228, 220, 37, 195, 245]), SecretKey([112, 164, 131, 28, 77, 69, 235, 91, 194, 252, 46, 143, 156, 38, 23, 174, 192, 0, 216, 64, 193, 152, 233, 175, 52, 129, 134, 177, 219, 71, 201, 100]), Seed([46, 246, 159, 69, 221, 92, 97, 111, 50, 94, 219, 226, 100, 20, 172, 205, 96, 47, 231, 107, 125, 27, 141, 125, 209, 67, 133, 241, 134, 15, 4, 191]));
/// ABE: GDABE22MEAC2PAG7Y5T5LWWP3GLPE5MHGLOFBEDFRF4VEYYYYNQIYGCJ
static immutable ABE = KeyPair(PublicKey([192, 18, 107, 76, 32, 5, 167, 128, 223, 199, 103, 213, 218, 207, 217, 150, 242, 117, 135, 50, 220, 80, 144, 101, 137, 121, 82, 99, 24, 195, 96, 140]), SecretKey([176, 235, 38, 72, 48, 185, 78, 122, 39, 245, 78, 84, 62, 211, 135, 0, 121, 46, 49, 18, 157, 2, 210, 253, 146, 228, 77, 14, 212, 96, 106, 94]), Seed([163, 79, 36, 126, 235, 107, 191, 242, 144, 223, 214, 177, 44, 41, 35, 235, 38, 101, 75, 160, 198, 115, 40, 92, 182, 130, 177, 56, 209, 96, 233, 128]));
/// ABF: GDABF22GZ4JPHTGLY5HUBWURX5CG7JBI5R74WQ7F2VWF4DMT7IPSXYU7
static immutable ABF = KeyPair(PublicKey([192, 18, 235, 70, 207, 18, 243, 204, 203, 199, 79, 64, 218, 145, 191, 68, 111, 164, 40, 236, 127, 203, 67, 229, 213, 108, 94, 13, 147, 250, 31, 43]), SecretKey([64, 48, 127, 147, 158, 138, 131, 81, 58, 214, 14, 0, 185, 42, 192, 97, 188, 122, 38, 180, 187, 228, 158, 120, 59, 231, 251, 148, 66, 39, 136, 111]), Seed([91, 54, 191, 66, 66, 62, 255, 120, 233, 98, 9, 7, 134, 130, 15, 181, 119, 48, 2, 189, 119, 143, 155, 48, 37, 137, 97, 183, 241, 112, 125, 213]));
/// ABG: GDABG224ZMDYZHWPZLCQCW33HZVMSPGZMTG2APHCK6M6XMTRKTJX5UEN
static immutable ABG = KeyPair(PublicKey([192, 19, 107, 92, 203, 7, 140, 158, 207, 202, 197, 1, 91, 123, 62, 106, 201, 60, 217, 100, 205, 160, 60, 226, 87, 153, 235, 178, 113, 84, 211, 126]), SecretKey([192, 213, 163, 21, 62, 94, 53, 227, 251, 133, 21, 117, 70, 123, 95, 66, 164, 3, 176, 13, 33, 135, 29, 13, 96, 31, 161, 43, 162, 53, 185, 119]), Seed([99, 219, 101, 188, 141, 219, 97, 251, 201, 156, 135, 49, 35, 135, 2, 228, 189, 4, 227, 77, 84, 34, 56, 210, 169, 246, 37, 136, 115, 95, 92, 183]));
/// ABH: GDABH22SAX73ERNZBBVWFKDWHG3NR2DT2IPDL5LIUPZCBIXUY6QYLZUT
static immutable ABH = KeyPair(PublicKey([192, 19, 235, 82, 5, 255, 178, 69, 185, 8, 107, 98, 168, 118, 57, 182, 216, 232, 115, 210, 30, 53, 245, 104, 163, 242, 32, 162, 244, 199, 161, 133]), SecretKey([8, 14, 193, 98, 57, 78, 105, 44, 75, 62, 101, 219, 106, 241, 30, 26, 105, 123, 27, 41, 102, 5, 55, 122, 135, 166, 81, 28, 63, 111, 32, 113]), Seed([80, 232, 65, 104, 230, 120, 133, 183, 78, 100, 48, 95, 92, 214, 82, 100, 92, 48, 210, 43, 76, 0, 134, 204, 94, 114, 249, 19, 8, 148, 255, 148]));
/// ABI: GDABI22D2OFFLPFJ5NL5ACKIDMBTSXSZFW3P7RN4OU2HCLGAFLFFPCNU
static immutable ABI = KeyPair(PublicKey([192, 20, 107, 67, 211, 138, 85, 188, 169, 235, 87, 208, 9, 72, 27, 3, 57, 94, 89, 45, 182, 255, 197, 188, 117, 52, 113, 44, 192, 42, 202, 87]), SecretKey([136, 108, 154, 40, 69, 51, 221, 146, 221, 185, 231, 212, 39, 219, 0, 251, 142, 147, 65, 76, 85, 62, 103, 29, 237, 76, 56, 241, 150, 17, 81, 104]), Seed([122, 182, 168, 185, 193, 103, 191, 19, 134, 227, 217, 214, 131, 5, 224, 3, 23, 94, 202, 45, 111, 81, 37, 36, 149, 99, 176, 101, 151, 18, 62, 22]));
/// ABJ: GDABJ22VVDA22PTE6X4XTNZCOUB6QYJRASDN6U5ULA4XE3KIG565IZO4
static immutable ABJ = KeyPair(PublicKey([192, 20, 235, 85, 168, 193, 173, 62, 100, 245, 249, 121, 183, 34, 117, 3, 232, 97, 49, 4, 134, 223, 83, 180, 88, 57, 114, 109, 72, 55, 125, 212]), SecretKey([152, 109, 123, 199, 68, 255, 160, 95, 200, 160, 183, 142, 61, 164, 168, 135, 112, 160, 80, 150, 225, 204, 180, 93, 65, 167, 75, 166, 7, 97, 237, 108]), Seed([53, 170, 82, 18, 92, 53, 167, 232, 94, 100, 74, 57, 150, 28, 54, 32, 248, 212, 204, 243, 12, 55, 254, 201, 139, 59, 198, 237, 7, 36, 219, 191]));
/// ABK: GDABK22LG2BRDVUPOAAFYFX4L55UM7HO4QBVWGZIO2KS5HWGOHAZLMKF
static immutable ABK = KeyPair(PublicKey([192, 21, 107, 75, 54, 131, 17, 214, 143, 112, 0, 92, 22, 252, 95, 123, 70, 124, 238, 228, 3, 91, 27, 40, 118, 149, 46, 158, 198, 113, 193, 149]), SecretKey([192, 240, 79, 224, 82, 246, 25, 179, 137, 112, 173, 64, 22, 40, 223, 5, 149, 41, 74, 141, 203, 30, 138, 54, 151, 37, 139, 104, 198, 199, 92, 70]), Seed([98, 33, 151, 108, 100, 230, 169, 53, 235, 97, 122, 68, 173, 250, 226, 205, 95, 187, 1, 226, 15, 73, 46, 246, 202, 102, 254, 122, 28, 37, 179, 176]));
/// ABL: GDABL22CQM4KD2QOYOECPYNUAJNWWYPMCBP2QBUBFXKJ2VFFWIWHEHPZ
static immutable ABL = KeyPair(PublicKey([192, 21, 235, 66, 131, 56, 161, 234, 14, 195, 136, 39, 225, 180, 2, 91, 107, 97, 236, 16, 95, 168, 6, 129, 45, 212, 157, 84, 165, 178, 44, 114]), SecretKey([40, 30, 104, 30, 230, 248, 143, 66, 168, 40, 249, 68, 7, 193, 211, 137, 184, 17, 79, 48, 31, 172, 66, 236, 138, 43, 1, 194, 123, 51, 101, 126]), Seed([90, 129, 233, 168, 185, 244, 60, 127, 252, 40, 189, 152, 119, 192, 70, 10, 20, 114, 108, 186, 143, 221, 34, 113, 107, 195, 158, 116, 230, 255, 118, 45]));
/// ABM: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable ABM = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// ABN: GDABN22APMPFRO5UM2A5OUCN3UMSXOBDXR7FN4XM6NVP6WX2YND5RUMO
static immutable ABN = KeyPair(PublicKey([192, 22, 235, 64, 123, 30, 88, 187, 180, 102, 129, 215, 80, 77, 221, 25, 43, 184, 35, 188, 126, 86, 242, 236, 243, 106, 255, 90, 250, 195, 71, 216]), SecretKey([216, 165, 41, 18, 97, 255, 26, 1, 234, 157, 244, 8, 255, 205, 29, 19, 16, 209, 129, 23, 159, 37, 136, 11, 78, 95, 71, 52, 21, 151, 200, 74]), Seed([238, 124, 239, 210, 53, 169, 77, 2, 149, 242, 239, 77, 157, 114, 219, 33, 252, 245, 227, 193, 242, 56, 222, 136, 32, 168, 182, 63, 72, 70, 149, 221]));
/// ABO: GDABO22TCPHDMZD3WXB3OAJWL2XOMQ3DRSG6W572A6KFXLDKAIIGBKSV
static immutable ABO = KeyPair(PublicKey([192, 23, 107, 83, 19, 206, 54, 100, 123, 181, 195, 183, 1, 54, 94, 174, 230, 67, 99, 140, 141, 235, 119, 250, 7, 148, 91, 172, 106, 2, 16, 96]), SecretKey([40, 219, 198, 28, 119, 190, 203, 168, 47, 243, 205, 47, 125, 82, 156, 112, 230, 240, 23, 108, 60, 160, 217, 211, 221, 125, 226, 5, 215, 50, 4, 102]), Seed([252, 195, 10, 151, 185, 244, 221, 197, 247, 128, 26, 60, 20, 140, 138, 52, 54, 168, 203, 62, 188, 168, 226, 216, 44, 102, 187, 162, 23, 126, 213, 155]));
/// ABP: GDABP22QGXTTV4PJ3GOHSNER3SAOIIAMCY4E3LLGKVX2ZDDVYIINRRVR
static immutable ABP = KeyPair(PublicKey([192, 23, 235, 80, 53, 231, 58, 241, 233, 217, 156, 121, 52, 145, 220, 128, 228, 32, 12, 22, 56, 77, 173, 102, 85, 111, 172, 140, 117, 194, 16, 216]), SecretKey([136, 7, 137, 78, 175, 243, 180, 4, 20, 255, 232, 227, 214, 62, 62, 33, 159, 134, 117, 231, 41, 166, 40, 143, 47, 163, 196, 228, 204, 92, 141, 69]), Seed([147, 74, 141, 109, 181, 128, 242, 187, 43, 88, 200, 237, 77, 101, 4, 242, 153, 111, 187, 109, 167, 142, 198, 76, 225, 193, 121, 77, 12, 198, 134, 149]));
/// ABQ: GDABQ22BQP5IYXQH7ND6EIAHEQBR52DO3EIJ37IO7JKFLZZ6YZPYMXP7
static immutable ABQ = KeyPair(PublicKey([192, 24, 107, 65, 131, 250, 140, 94, 7, 251, 71, 226, 32, 7, 36, 3, 30, 232, 110, 217, 16, 157, 253, 14, 250, 84, 85, 231, 62, 198, 95, 134]), SecretKey([48, 222, 19, 131, 35, 81, 116, 140, 255, 211, 225, 108, 111, 199, 146, 10, 208, 180, 20, 1, 242, 205, 167, 252, 103, 49, 14, 150, 145, 3, 30, 114]), Seed([42, 90, 150, 20, 117, 103, 39, 96, 102, 82, 23, 167, 154, 235, 3, 98, 129, 254, 24, 85, 213, 166, 187, 211, 54, 18, 113, 89, 205, 228, 74, 37]));
/// ABR: GDABR22SVZ2JSFN25BO7BRC52BR6S6ZLQ7JS6V7ZGWCCXZZELLD6EFHA
static immutable ABR = KeyPair(PublicKey([192, 24, 235, 82, 174, 116, 153, 21, 186, 232, 93, 240, 196, 93, 208, 99, 233, 123, 43, 135, 211, 47, 87, 249, 53, 132, 43, 231, 36, 90, 199, 226]), SecretKey([184, 130, 12, 210, 178, 145, 36, 4, 69, 112, 178, 253, 236, 84, 216, 38, 191, 26, 17, 99, 11, 110, 78, 79, 66, 115, 195, 135, 216, 202, 55, 123]), Seed([240, 65, 199, 119, 120, 65, 15, 161, 191, 17, 198, 198, 189, 214, 110, 22, 42, 255, 152, 182, 70, 202, 123, 238, 39, 125, 229, 85, 85, 172, 42, 160]));
/// ABS: GDABS22SUQYTMSJXAO3XCUQU67T3DO3CPH36IY63KNSOOUGQJKGYFMRF
static immutable ABS = KeyPair(PublicKey([192, 25, 107, 82, 164, 49, 54, 73, 55, 3, 183, 113, 82, 20, 247, 231, 177, 187, 98, 121, 247, 228, 99, 219, 83, 100, 231, 80, 208, 74, 141, 130]), SecretKey([104, 127, 5, 188, 64, 204, 120, 218, 63, 110, 151, 139, 253, 68, 94, 56, 213, 29, 1, 239, 62, 139, 15, 72, 7, 76, 170, 201, 177, 162, 176, 70]), Seed([96, 161, 109, 147, 118, 57, 32, 209, 60, 234, 130, 63, 90, 45, 82, 122, 115, 69, 20, 186, 39, 150, 46, 203, 195, 248, 87, 240, 116, 199, 131, 148]));
/// ABT: GDABT22YV7YUOBDLYV7D6TWO2SPMEWKXM77Q2T7MOV3ZD23LKGZUFA6N
static immutable ABT = KeyPair(PublicKey([192, 25, 235, 88, 175, 241, 71, 4, 107, 197, 126, 63, 78, 206, 212, 158, 194, 89, 87, 103, 255, 13, 79, 236, 117, 119, 145, 235, 107, 81, 179, 66]), SecretKey([56, 183, 92, 237, 150, 251, 240, 192, 31, 135, 61, 171, 217, 80, 202, 143, 116, 240, 198, 107, 63, 57, 15, 17, 68, 225, 30, 208, 173, 126, 57, 122]), Seed([240, 49, 66, 26, 152, 163, 207, 69, 207, 210, 81, 216, 123, 181, 231, 185, 107, 56, 102, 1, 78, 37, 185, 0, 51, 111, 153, 52, 33, 15, 20, 160]));
/// ABU: GDABU226A3MIHLGAKX4P3WCQJXDIH6F4WL5NG7IUCP4XY2LD6PK54FFT
static immutable ABU = KeyPair(PublicKey([192, 26, 107, 94, 6, 216, 131, 172, 192, 85, 248, 253, 216, 80, 77, 198, 131, 248, 188, 178, 250, 211, 125, 20, 19, 249, 124, 105, 99, 243, 213, 222]), SecretKey([168, 50, 168, 111, 133, 39, 145, 91, 240, 234, 219, 192, 68, 174, 156, 38, 194, 104, 67, 136, 156, 138, 54, 205, 147, 79, 138, 124, 151, 98, 129, 71]), Seed([73, 157, 197, 103, 152, 161, 126, 173, 132, 144, 195, 130, 244, 128, 184, 59, 242, 102, 250, 16, 235, 120, 26, 171, 137, 1, 189, 226, 79, 233, 53, 250]));
/// ABV: GDABV22PW3SKUW42LNH4XGDD6ZPJQ7OQOX3YF75HIZ2ULU2UCGJXQVUP
static immutable ABV = KeyPair(PublicKey([192, 26, 235, 79, 182, 228, 170, 91, 154, 91, 79, 203, 152, 99, 246, 94, 152, 125, 208, 117, 247, 130, 255, 167, 70, 117, 69, 211, 84, 17, 147, 120]), SecretKey([104, 54, 36, 3, 150, 239, 47, 177, 8, 113, 194, 153, 44, 53, 171, 169, 1, 177, 78, 196, 152, 178, 110, 89, 125, 109, 162, 186, 166, 196, 237, 95]), Seed([182, 163, 166, 236, 186, 237, 237, 5, 250, 247, 42, 61, 237, 133, 168, 192, 213, 5, 144, 29, 112, 244, 116, 199, 185, 123, 60, 173, 141, 203, 239, 41]));
/// ABW: GDABW22F3W7JUB7JES6BHD3X7BA3LSSJBA55M6FRJKSKDMOOW4C4UCXR
static immutable ABW = KeyPair(PublicKey([192, 27, 107, 69, 221, 190, 154, 7, 233, 36, 188, 19, 143, 119, 248, 65, 181, 202, 73, 8, 59, 214, 120, 177, 74, 164, 161, 177, 206, 183, 5, 202]), SecretKey([56, 24, 16, 19, 5, 99, 89, 92, 73, 219, 132, 33, 101, 97, 202, 91, 151, 53, 165, 145, 59, 108, 198, 174, 61, 223, 164, 182, 163, 241, 154, 96]), Seed([218, 112, 122, 201, 41, 45, 176, 184, 66, 115, 115, 34, 163, 236, 143, 11, 159, 10, 109, 121, 81, 213, 66, 197, 104, 149, 89, 162, 182, 20, 238, 32]));
/// ABX: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable ABX = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// ABY: GDABY22MDTDFQTUH5U2Z6SZYJUXICEGJ64B75T55KOKOOQUAKVDLOTZF
static immutable ABY = KeyPair(PublicKey([192, 28, 107, 76, 28, 198, 88, 78, 135, 237, 53, 159, 75, 56, 77, 46, 129, 16, 201, 247, 3, 254, 207, 189, 83, 148, 231, 66, 128, 85, 70, 183]), SecretKey([80, 171, 216, 130, 197, 67, 225, 21, 18, 85, 71, 109, 113, 108, 135, 83, 86, 174, 117, 20, 83, 116, 54, 62, 106, 244, 151, 170, 67, 14, 162, 87]), Seed([83, 206, 202, 162, 2, 60, 125, 38, 220, 67, 90, 229, 226, 11, 194, 107, 86, 67, 254, 139, 26, 103, 174, 53, 167, 200, 225, 154, 121, 234, 253, 38]));
/// ABZ: GDABZ22XOROCPTY5XXPOOHJG34NOBY37PJCFWNV25RO6UM2YBNVZESLW
static immutable ABZ = KeyPair(PublicKey([192, 28, 235, 87, 116, 92, 39, 207, 29, 189, 222, 231, 29, 38, 223, 26, 224, 227, 127, 122, 68, 91, 54, 186, 236, 93, 234, 51, 88, 11, 107, 146]), SecretKey([248, 34, 158, 222, 10, 143, 54, 69, 57, 222, 194, 167, 98, 233, 198, 79, 178, 251, 246, 169, 71, 71, 88, 95, 28, 35, 153, 26, 90, 177, 192, 75]), Seed([211, 12, 233, 156, 14, 255, 135, 48, 130, 69, 169, 90, 39, 69, 194, 46, 13, 92, 110, 108, 63, 119, 229, 133, 107, 12, 213, 183, 189, 237, 143, 23]));
/// ACA: GDACA22MGAZG2NLBW55ERJAXPXGVTL7C7UUAAWFQITTYZM477QJNM7HI
static immutable ACA = KeyPair(PublicKey([192, 32, 107, 76, 48, 50, 109, 53, 97, 183, 122, 72, 164, 23, 125, 205, 89, 175, 226, 253, 40, 0, 88, 176, 68, 231, 140, 179, 159, 252, 18, 214]), SecretKey([248, 122, 19, 12, 176, 227, 208, 40, 214, 157, 77, 13, 82, 82, 22, 120, 193, 213, 176, 59, 196, 64, 42, 50, 157, 47, 53, 85, 207, 60, 37, 117]), Seed([134, 193, 12, 207, 162, 0, 84, 117, 142, 227, 109, 210, 23, 138, 97, 225, 206, 96, 54, 35, 98, 171, 12, 69, 208, 66, 159, 184, 203, 131, 1, 73]));
/// ACB: GDACB22VCOWYPJRHGXUJPDXPT5AMNQ4ECBY4GTV5VID7FPJE6K3QB77T
static immutable ACB = KeyPair(PublicKey([192, 32, 235, 85, 19, 173, 135, 166, 39, 53, 232, 151, 142, 239, 159, 64, 198, 195, 132, 16, 113, 195, 78, 189, 170, 7, 242, 189, 36, 242, 183, 0]), SecretKey([136, 137, 165, 49, 49, 175, 188, 4, 86, 159, 203, 139, 158, 125, 255, 179, 72, 14, 43, 121, 46, 249, 214, 151, 43, 195, 114, 246, 236, 208, 116, 75]), Seed([171, 232, 139, 64, 235, 249, 239, 191, 60, 91, 159, 56, 116, 117, 176, 124, 239, 200, 56, 204, 249, 116, 38, 30, 239, 62, 116, 148, 13, 236, 107, 93]));
/// ACC: GDACC22K3WAMZXFLW2M2UCM4MUXRJPZBLOIYWGBUQK4DOEIYS7YALDZT
static immutable ACC = KeyPair(PublicKey([192, 33, 107, 74, 221, 128, 204, 220, 171, 182, 153, 170, 9, 156, 101, 47, 20, 191, 33, 91, 145, 139, 24, 52, 130, 184, 55, 17, 24, 151, 240, 5]), SecretKey([200, 205, 165, 187, 59, 121, 127, 219, 106, 28, 86, 120, 110, 195, 185, 151, 224, 55, 39, 123, 159, 212, 6, 192, 201, 45, 154, 208, 143, 48, 79, 71]), Seed([193, 146, 149, 107, 119, 74, 25, 169, 16, 73, 59, 109, 82, 71, 119, 225, 236, 245, 202, 234, 28, 133, 69, 202, 130, 14, 2, 136, 253, 242, 81, 122]));
/// ACD: GDACD22R2DX3HFJF6D4GOLWA42RLTG2C2DEPZNFFSDANVMEYH3SIOEXR
static immutable ACD = KeyPair(PublicKey([192, 33, 235, 81, 208, 239, 179, 149, 37, 240, 248, 103, 46, 192, 230, 162, 185, 155, 66, 208, 200, 252, 180, 165, 144, 192, 218, 176, 152, 62, 228, 135]), SecretKey([216, 34, 176, 3, 80, 209, 192, 80, 65, 85, 96, 138, 231, 193, 236, 161, 76, 126, 152, 28, 118, 252, 195, 175, 27, 224, 186, 196, 204, 147, 100, 105]), Seed([85, 239, 37, 20, 3, 79, 116, 198, 47, 19, 225, 198, 55, 213, 16, 189, 121, 107, 151, 158, 36, 32, 65, 186, 190, 22, 96, 225, 196, 172, 51, 125]));
/// ACE: GDACE22JYJ64QJVC37MXO3W7DSN4V7EOQJGMFSOOKZCYBEROBK4W37Q2
static immutable ACE = KeyPair(PublicKey([192, 34, 107, 73, 194, 125, 200, 38, 162, 223, 217, 119, 110, 223, 28, 155, 202, 252, 142, 130, 76, 194, 201, 206, 86, 69, 128, 146, 46, 10, 185, 109]), SecretKey([152, 33, 33, 127, 76, 32, 177, 110, 5, 162, 129, 37, 105, 247, 146, 99, 60, 165, 72, 222, 9, 202, 211, 125, 62, 213, 252, 114, 48, 240, 15, 74]), Seed([61, 83, 233, 27, 53, 67, 179, 56, 55, 77, 33, 141, 27, 152, 19, 1, 45, 85, 52, 188, 158, 9, 32, 255, 233, 144, 176, 1, 129, 222, 52, 95]));
/// ACF: GDACF22VKSRHCSE5T7P537TO42LMAUSM6EVV5GCX22S4LSGCCCSNGDGN
static immutable ACF = KeyPair(PublicKey([192, 34, 235, 85, 84, 162, 113, 72, 157, 159, 223, 221, 254, 110, 230, 150, 192, 82, 76, 241, 43, 94, 152, 87, 214, 165, 197, 200, 194, 16, 164, 211]), SecretKey([240, 61, 47, 78, 39, 191, 71, 62, 105, 230, 69, 200, 46, 40, 109, 153, 216, 177, 144, 224, 251, 150, 58, 134, 58, 133, 85, 247, 243, 11, 116, 71]), Seed([131, 249, 70, 97, 242, 217, 217, 217, 131, 10, 246, 196, 210, 175, 22, 101, 218, 178, 191, 7, 52, 180, 200, 22, 203, 176, 8, 145, 121, 242, 147, 172]));
/// ACG: GDACG223J6YBFAWCYC26BSXHN62KE4P2KGRSUSX2T4AY65F35JBR5P67
static immutable ACG = KeyPair(PublicKey([192, 35, 107, 91, 79, 176, 18, 130, 194, 192, 181, 224, 202, 231, 111, 180, 162, 113, 250, 81, 163, 42, 74, 250, 159, 1, 143, 116, 187, 234, 67, 30]), SecretKey([40, 108, 212, 37, 188, 203, 91, 94, 84, 244, 183, 115, 33, 171, 154, 32, 166, 101, 40, 219, 2, 140, 208, 148, 119, 219, 206, 221, 45, 174, 170, 125]), Seed([20, 34, 248, 108, 127, 109, 108, 96, 72, 24, 118, 53, 35, 42, 88, 28, 98, 9, 7, 62, 210, 160, 168, 74, 176, 1, 168, 200, 160, 25, 42, 61]));
/// ACH: GDACH222OKJ6PCWE74X2ODZAQ3QSTZYE75CJRMUCOGKD3MEVMGQTKPQ3
static immutable ACH = KeyPair(PublicKey([192, 35, 235, 90, 114, 147, 231, 138, 196, 255, 47, 167, 15, 32, 134, 225, 41, 231, 4, 255, 68, 152, 178, 130, 113, 148, 61, 176, 149, 97, 161, 53]), SecretKey([224, 61, 250, 132, 186, 99, 178, 113, 251, 196, 189, 24, 170, 10, 42, 19, 63, 156, 163, 24, 51, 190, 79, 79, 181, 139, 174, 58, 45, 219, 235, 114]), Seed([126, 74, 221, 167, 33, 244, 124, 49, 218, 201, 9, 98, 45, 227, 171, 241, 32, 167, 107, 151, 42, 117, 153, 94, 42, 26, 153, 126, 236, 191, 231, 201]));
/// ACI: GDACI22NP3DDNOXPNTJN7HHESJBMPTG56SSDI35FDET5ENYNEXUAB3BH
static immutable ACI = KeyPair(PublicKey([192, 36, 107, 77, 126, 198, 54, 186, 239, 108, 210, 223, 156, 228, 146, 66, 199, 204, 221, 244, 164, 52, 111, 165, 25, 39, 210, 55, 13, 37, 232, 0]), SecretKey([216, 147, 130, 41, 31, 131, 49, 169, 86, 154, 48, 164, 147, 82, 212, 103, 131, 171, 88, 167, 235, 144, 146, 8, 40, 245, 16, 58, 149, 91, 167, 97]), Seed([59, 115, 179, 92, 61, 112, 103, 29, 47, 11, 19, 49, 243, 95, 23, 23, 36, 26, 243, 20, 127, 140, 189, 249, 138, 230, 56, 44, 128, 226, 128, 208]));
/// ACJ: GDACJ22G23LRWANCYLPXG3BGV2TQKXCSMETO7OLST54YQ5L53H6SJSMA
static immutable ACJ = KeyPair(PublicKey([192, 36, 235, 70, 214, 215, 27, 1, 162, 194, 223, 115, 108, 38, 174, 167, 5, 92, 82, 97, 38, 239, 185, 114, 159, 121, 136, 117, 125, 217, 253, 36]), SecretKey([232, 131, 17, 253, 90, 76, 200, 114, 193, 173, 131, 148, 158, 194, 165, 118, 32, 155, 38, 4, 251, 32, 40, 113, 255, 100, 181, 77, 154, 116, 111, 95]), Seed([103, 240, 201, 119, 198, 161, 223, 225, 132, 139, 107, 115, 67, 78, 109, 30, 96, 27, 92, 138, 187, 178, 18, 45, 187, 146, 236, 148, 2, 194, 220, 158]));
/// ACK: GDACK223ZT2RLQFAONSCZ4HGHNULNVVOZNT5NUEVGLKRGHPSP2OLF3OC
static immutable ACK = KeyPair(PublicKey([192, 37, 107, 91, 204, 245, 21, 192, 160, 115, 100, 44, 240, 230, 59, 104, 182, 214, 174, 203, 103, 214, 208, 149, 50, 213, 19, 29, 242, 126, 156, 178]), SecretKey([160, 62, 68, 185, 217, 172, 41, 162, 117, 210, 123, 206, 200, 88, 249, 26, 207, 29, 75, 54, 112, 49, 59, 252, 172, 213, 162, 9, 245, 59, 5, 124]), Seed([183, 65, 243, 219, 77, 39, 73, 125, 170, 69, 132, 76, 167, 7, 227, 51, 167, 132, 168, 37, 89, 153, 205, 193, 7, 95, 161, 23, 133, 121, 141, 114]));
/// ACL: GDACL225LJCQMGZYAJ5UWTQTTM6TJCI2NIEDJ2NXFJRCUF4KEFZZE7XI
static immutable ACL = KeyPair(PublicKey([192, 37, 235, 93, 90, 69, 6, 27, 56, 2, 123, 75, 78, 19, 155, 61, 52, 137, 26, 106, 8, 52, 233, 183, 42, 98, 42, 23, 138, 33, 115, 146]), SecretKey([96, 121, 79, 249, 12, 56, 120, 124, 72, 136, 7, 221, 87, 183, 194, 253, 231, 254, 17, 228, 249, 230, 92, 110, 42, 69, 114, 21, 142, 65, 144, 102]), Seed([102, 111, 201, 209, 86, 226, 33, 107, 52, 253, 251, 54, 44, 163, 192, 50, 222, 9, 68, 116, 84, 161, 176, 197, 126, 97, 136, 182, 151, 190, 191, 61]));
/// ACM: GDACM22KOKI25L4M5EDO6XZD3MKP5JV2UI2TLKLZTP6DCQPDQ2XYJK6F
static immutable ACM = KeyPair(PublicKey([192, 38, 107, 74, 114, 145, 174, 175, 140, 233, 6, 239, 95, 35, 219, 20, 254, 166, 186, 162, 53, 53, 169, 121, 155, 252, 49, 65, 227, 134, 175, 132]), SecretKey([80, 25, 189, 214, 120, 160, 161, 208, 43, 23, 138, 136, 165, 159, 220, 135, 203, 164, 62, 117, 163, 245, 175, 11, 111, 190, 49, 128, 31, 213, 127, 124]), Seed([100, 31, 11, 209, 239, 255, 101, 231, 117, 10, 63, 193, 57, 18, 101, 13, 57, 218, 169, 205, 100, 50, 193, 172, 127, 116, 176, 92, 10, 139, 71, 169]));
/// ACN: GDACN22OVDSBRVY3IWVR6KV3S63LZFW3CMZICXGPTEZSAVBKEUXGZJAX
static immutable ACN = KeyPair(PublicKey([192, 38, 235, 78, 168, 228, 24, 215, 27, 69, 171, 31, 42, 187, 151, 182, 188, 150, 219, 19, 50, 129, 92, 207, 153, 51, 32, 84, 42, 37, 46, 108]), SecretKey([200, 78, 0, 94, 213, 97, 47, 196, 109, 100, 18, 242, 80, 43, 126, 201, 91, 27, 131, 77, 195, 119, 121, 181, 18, 40, 6, 185, 126, 35, 208, 75]), Seed([245, 28, 167, 23, 233, 137, 247, 35, 229, 197, 181, 178, 230, 184, 53, 220, 101, 35, 2, 181, 247, 34, 28, 189, 89, 240, 17, 243, 49, 146, 141, 80]));
/// ACO: GDACO22HAYOFIIA7JHQX4UWSSS2524DVKRG3M2DMZRFDEGGU7FZR2WBB
static immutable ACO = KeyPair(PublicKey([192, 39, 107, 71, 6, 28, 84, 32, 31, 73, 225, 126, 82, 210, 148, 181, 221, 112, 117, 84, 77, 182, 104, 108, 204, 74, 50, 24, 212, 249, 115, 29]), SecretKey([104, 110, 67, 142, 56, 102, 126, 98, 253, 214, 39, 21, 45, 160, 60, 29, 160, 231, 195, 75, 20, 183, 110, 3, 12, 207, 225, 176, 230, 184, 54, 125]), Seed([124, 31, 148, 49, 224, 226, 101, 253, 250, 43, 76, 213, 90, 179, 240, 156, 37, 138, 141, 160, 26, 16, 220, 41, 68, 64, 249, 74, 122, 233, 13, 145]));
/// ACP: GDACP22FBOFMEWZXJPXILTCC6QW2SRWWKLKVYW3OPBCOYURXOZHEC33M
static immutable ACP = KeyPair(PublicKey([192, 39, 235, 69, 11, 138, 194, 91, 55, 75, 238, 133, 204, 66, 244, 45, 169, 70, 214, 82, 213, 92, 91, 110, 120, 68, 236, 82, 55, 118, 78, 65]), SecretKey([160, 169, 89, 28, 252, 251, 150, 49, 3, 82, 90, 176, 62, 178, 45, 86, 38, 107, 251, 61, 175, 187, 200, 164, 105, 23, 236, 72, 79, 37, 125, 86]), Seed([205, 74, 79, 218, 128, 129, 191, 125, 228, 86, 18, 216, 77, 121, 43, 241, 127, 18, 66, 40, 76, 37, 245, 224, 28, 240, 112, 179, 8, 100, 108, 25]));
/// ACQ: GDACQ22374MCL3VBJBLM2NHVJXZHDMPQVYRLMGPM5D2Y6PMXZH4J5K2J
static immutable ACQ = KeyPair(PublicKey([192, 40, 107, 91, 255, 24, 37, 238, 161, 72, 86, 205, 52, 245, 77, 242, 113, 177, 240, 174, 34, 182, 25, 236, 232, 245, 143, 61, 151, 201, 248, 158]), SecretKey([120, 125, 8, 160, 23, 190, 207, 210, 114, 25, 207, 133, 251, 141, 216, 232, 98, 194, 138, 212, 96, 93, 96, 179, 73, 177, 22, 168, 60, 189, 16, 87]), Seed([67, 252, 234, 202, 135, 65, 11, 135, 245, 32, 53, 50, 122, 228, 15, 175, 249, 49, 142, 218, 80, 68, 137, 8, 186, 156, 135, 91, 132, 28, 252, 137]));
/// ACR: GDACR22YGBXE2UNJ252L4AVVN2TKELEQHYF2FKXSMTQYWQ5PL3PVGGXA
static immutable ACR = KeyPair(PublicKey([192, 40, 235, 88, 48, 110, 77, 81, 169, 215, 116, 190, 2, 181, 110, 166, 162, 44, 144, 62, 11, 162, 170, 242, 100, 225, 139, 67, 175, 94, 223, 83]), SecretKey([176, 242, 199, 218, 129, 49, 92, 6, 53, 95, 35, 20, 0, 241, 82, 16, 70, 193, 31, 30, 65, 134, 189, 181, 106, 152, 173, 89, 139, 8, 123, 123]), Seed([120, 176, 232, 124, 28, 138, 99, 155, 150, 92, 173, 120, 206, 219, 195, 128, 229, 65, 124, 212, 231, 4, 249, 132, 202, 24, 147, 81, 7, 130, 110, 12]));
/// ACS: GDACS222VIIJI5XDFDGXHG5CD3M3GLPNHARJBSERTSEDOIWKU37ZYJ2E
static immutable ACS = KeyPair(PublicKey([192, 41, 107, 90, 170, 16, 148, 118, 227, 40, 205, 115, 155, 162, 30, 217, 179, 45, 237, 56, 34, 144, 200, 145, 156, 136, 55, 34, 202, 166, 255, 156]), SecretKey([144, 127, 254, 158, 149, 237, 43, 27, 101, 137, 245, 165, 14, 151, 249, 136, 142, 119, 97, 207, 42, 222, 17, 135, 64, 251, 147, 95, 21, 63, 213, 65]), Seed([190, 120, 0, 162, 194, 248, 208, 100, 213, 38, 118, 177, 211, 235, 177, 118, 204, 153, 201, 56, 200, 193, 51, 124, 214, 79, 69, 21, 119, 64, 199, 178]));
/// ACT: GDACT22EK34QSOUSLDF5ZU2MRJRXL4DVCCTYQ3VEUVXCPZCCFQJ24EF7
static immutable ACT = KeyPair(PublicKey([192, 41, 235, 68, 86, 249, 9, 58, 146, 88, 203, 220, 211, 76, 138, 99, 117, 240, 117, 16, 167, 136, 110, 164, 165, 110, 39, 228, 66, 44, 19, 174]), SecretKey([248, 250, 76, 83, 195, 96, 136, 106, 48, 158, 22, 130, 87, 202, 82, 126, 202, 122, 30, 9, 70, 158, 225, 199, 99, 145, 155, 166, 77, 236, 139, 69]), Seed([198, 169, 159, 76, 188, 28, 169, 161, 100, 6, 85, 132, 10, 5, 154, 33, 48, 5, 191, 201, 180, 69, 93, 174, 110, 217, 23, 239, 16, 26, 164, 2]));
/// ACU: GDACU22FGK5HJDZFWY74XVPTFWAPNDJDLUVYWE2XHA27J7TXJFYJQJGT
static immutable ACU = KeyPair(PublicKey([192, 42, 107, 69, 50, 186, 116, 143, 37, 182, 63, 203, 213, 243, 45, 128, 246, 141, 35, 93, 43, 139, 19, 87, 56, 53, 244, 254, 119, 73, 112, 152]), SecretKey([120, 143, 0, 114, 176, 63, 218, 63, 59, 215, 190, 9, 85, 127, 109, 59, 128, 180, 6, 100, 148, 244, 96, 244, 229, 92, 23, 79, 223, 251, 230, 75]), Seed([237, 63, 216, 166, 234, 90, 167, 159, 131, 37, 26, 47, 56, 126, 90, 44, 43, 75, 146, 228, 126, 16, 202, 191, 239, 232, 3, 207, 35, 18, 60, 7]));
/// ACV: GDACV227YULBPPCYLRH43ROCOVT5PPEMD6YOEPCJ7SXP7QH3EZYPT3X7
static immutable ACV = KeyPair(PublicKey([192, 42, 235, 95, 197, 22, 23, 188, 88, 92, 79, 205, 197, 194, 117, 103, 215, 188, 140, 31, 176, 226, 60, 73, 252, 174, 255, 192, 251, 38, 112, 249]), SecretKey([112, 223, 211, 169, 230, 135, 200, 14, 153, 247, 239, 103, 23, 31, 158, 153, 245, 4, 248, 20, 88, 108, 51, 2, 207, 251, 16, 1, 6, 116, 183, 83]), Seed([148, 160, 167, 185, 159, 50, 16, 85, 87, 34, 10, 172, 182, 142, 172, 210, 227, 73, 148, 2, 117, 121, 210, 172, 137, 206, 91, 82, 132, 50, 245, 99]));
/// ACW: GDACW22TRUNQ7W3W6WHLV3DYVEEQ4QIZHGMRPH27BBSPG47RHXEEDSNG
static immutable ACW = KeyPair(PublicKey([192, 43, 107, 83, 141, 27, 15, 219, 118, 245, 142, 186, 236, 120, 169, 9, 14, 65, 25, 57, 153, 23, 159, 95, 8, 100, 243, 115, 241, 61, 200, 65]), SecretKey([40, 44, 24, 185, 109, 13, 214, 94, 162, 227, 55, 245, 162, 228, 149, 227, 178, 213, 119, 234, 174, 107, 103, 255, 16, 140, 198, 73, 42, 112, 115, 125]), Seed([199, 63, 97, 42, 57, 56, 7, 121, 180, 166, 235, 38, 75, 163, 102, 218, 207, 91, 252, 156, 197, 251, 157, 242, 1, 98, 81, 77, 167, 19, 97, 181]));
/// ACX: GDACX22OCT5U675MNQH5XTEXHFMRGLTIPFCCZ4NJ5QKIZUN5LR4J4IEG
static immutable ACX = KeyPair(PublicKey([192, 43, 235, 78, 20, 251, 79, 127, 172, 108, 15, 219, 204, 151, 57, 89, 19, 46, 104, 121, 68, 44, 241, 169, 236, 20, 140, 209, 189, 92, 120, 158]), SecretKey([8, 248, 198, 251, 122, 164, 171, 131, 32, 80, 89, 129, 113, 22, 197, 187, 36, 90, 47, 167, 61, 106, 93, 198, 169, 159, 72, 191, 73, 104, 213, 89]), Seed([25, 152, 12, 65, 209, 84, 84, 24, 26, 179, 198, 19, 89, 95, 148, 215, 18, 24, 186, 43, 34, 75, 69, 137, 253, 63, 124, 214, 4, 235, 107, 201]));
/// ACY: GDACY222EXAKKTTZAJLUBLHZZDPX5QQ3Y4ECUXPYH3IAWZENFW3EML65
static immutable ACY = KeyPair(PublicKey([192, 44, 107, 90, 37, 192, 165, 78, 121, 2, 87, 64, 172, 249, 200, 223, 126, 194, 27, 199, 8, 42, 93, 248, 62, 208, 11, 100, 141, 45, 182, 70]), SecretKey([64, 34, 69, 104, 188, 63, 116, 64, 38, 88, 216, 162, 234, 157, 170, 217, 46, 64, 157, 32, 229, 88, 186, 110, 169, 136, 169, 185, 79, 154, 196, 67]), Seed([20, 143, 29, 119, 16, 254, 13, 23, 147, 212, 252, 176, 101, 60, 196, 23, 159, 195, 66, 227, 198, 77, 160, 138, 95, 38, 77, 31, 97, 141, 182, 191]));
/// ACZ: GDACZ223R63ZJUP3KIPEDK6RTIUCBIBUKPLG7C4HNPDR5FRUVE72P2ET
static immutable ACZ = KeyPair(PublicKey([192, 44, 235, 91, 143, 183, 148, 209, 251, 82, 30, 65, 171, 209, 154, 40, 32, 160, 52, 83, 214, 111, 139, 135, 107, 199, 30, 150, 52, 169, 63, 167]), SecretKey([80, 108, 45, 39, 175, 56, 28, 87, 166, 203, 39, 108, 201, 220, 164, 90, 201, 36, 115, 97, 223, 114, 174, 226, 239, 251, 53, 219, 70, 193, 49, 101]), Seed([95, 122, 104, 194, 194, 112, 123, 20, 23, 141, 230, 207, 79, 211, 177, 39, 98, 67, 3, 65, 16, 133, 67, 14, 71, 1, 50, 104, 190, 125, 150, 104]));
/// ADA: GDADA22GOZ6QOF6HYFNINYTFKWLTAR26DKGE3Z3S6HCAUROJAXRC4JSK
static immutable ADA = KeyPair(PublicKey([192, 48, 107, 70, 118, 125, 7, 23, 199, 193, 90, 134, 226, 101, 85, 151, 48, 71, 94, 26, 140, 77, 231, 114, 241, 196, 10, 69, 201, 5, 226, 46]), SecretKey([0, 4, 45, 100, 177, 73, 211, 157, 148, 65, 152, 152, 6, 198, 243, 243, 39, 225, 183, 178, 206, 145, 136, 1, 6, 228, 157, 101, 44, 250, 221, 78]), Seed([105, 83, 158, 241, 208, 145, 118, 158, 206, 183, 214, 82, 172, 22, 21, 109, 30, 3, 1, 105, 233, 4, 90, 90, 205, 27, 202, 35, 12, 197, 92, 83]));
/// ADB: GDADB22F5VNPKXHIZZXO7MEWLU6UUAXUW5Y2YSHQIKY7RR2F3FA7LMGC
static immutable ADB = KeyPair(PublicKey([192, 48, 235, 69, 237, 90, 245, 92, 232, 206, 110, 239, 176, 150, 93, 61, 74, 2, 244, 183, 113, 172, 72, 240, 66, 177, 248, 199, 69, 217, 65, 245]), SecretKey([168, 129, 106, 106, 251, 202, 57, 133, 140, 253, 89, 110, 74, 118, 43, 78, 156, 159, 47, 151, 62, 7, 148, 217, 83, 85, 121, 66, 231, 199, 139, 112]), Seed([53, 20, 147, 146, 134, 153, 129, 38, 87, 240, 204, 146, 190, 177, 124, 48, 24, 82, 190, 201, 138, 50, 176, 149, 86, 46, 98, 223, 86, 251, 134, 45]));
/// ADC: GDADC22BF4GQSX5L4XHNUKOELBFEP5SG7SRBZY3B6G5CZCVT3KRZGIKY
static immutable ADC = KeyPair(PublicKey([192, 49, 107, 65, 47, 13, 9, 95, 171, 229, 206, 218, 41, 196, 88, 74, 71, 246, 70, 252, 162, 28, 227, 97, 241, 186, 44, 138, 179, 218, 163, 147]), SecretKey([192, 174, 65, 155, 105, 216, 14, 228, 113, 12, 49, 243, 231, 112, 124, 251, 232, 148, 13, 5, 60, 54, 182, 113, 0, 234, 27, 146, 158, 191, 101, 114]), Seed([132, 19, 191, 6, 136, 132, 36, 1, 87, 233, 65, 105, 242, 183, 50, 132, 49, 222, 21, 103, 10, 53, 59, 163, 175, 87, 107, 221, 104, 27, 183, 13]));
/// ADD: GDADD22DMOC7VP4AGFSGYT6YVJ4DMMYCIRXK4LTARRBBEKEGXPFBHZDA
static immutable ADD = KeyPair(PublicKey([192, 49, 235, 67, 99, 133, 250, 191, 128, 49, 100, 108, 79, 216, 170, 120, 54, 51, 2, 68, 110, 174, 46, 96, 140, 66, 18, 40, 134, 187, 202, 19]), SecretKey([16, 80, 149, 82, 109, 161, 219, 121, 123, 137, 132, 234, 123, 232, 153, 16, 38, 42, 199, 127, 246, 150, 128, 119, 139, 156, 201, 34, 230, 13, 122, 74]), Seed([102, 94, 120, 168, 199, 156, 157, 109, 141, 26, 143, 27, 18, 153, 42, 121, 218, 50, 184, 252, 0, 0, 22, 109, 196, 113, 195, 130, 102, 11, 35, 190]));
/// ADE: GDADE22XWUD5YW74XHAYDCT7WFO45DFRRAJS7N5JKZ3XN5AC76XFTO3M
static immutable ADE = KeyPair(PublicKey([192, 50, 107, 87, 181, 7, 220, 91, 252, 185, 193, 129, 138, 127, 177, 93, 206, 140, 177, 136, 19, 47, 183, 169, 86, 119, 118, 244, 2, 255, 174, 89]), SecretKey([96, 56, 174, 241, 1, 27, 181, 95, 240, 120, 147, 107, 40, 1, 96, 48, 211, 178, 164, 48, 50, 81, 75, 34, 195, 172, 238, 92, 51, 23, 77, 90]), Seed([4, 216, 126, 245, 200, 94, 35, 116, 227, 79, 210, 200, 38, 67, 151, 37, 101, 45, 205, 241, 200, 102, 236, 59, 217, 79, 144, 230, 107, 104, 63, 73]));
/// ADF: GDADF22LLNWGAMQTL3S7NKOP5A7Q6LLJFW6ZF73DLE27O6IJXRX3IQEM
static immutable ADF = KeyPair(PublicKey([192, 50, 235, 75, 91, 108, 96, 50, 19, 94, 229, 246, 169, 207, 232, 63, 15, 45, 105, 45, 189, 146, 255, 99, 89, 53, 247, 121, 9, 188, 111, 180]), SecretKey([112, 86, 4, 112, 96, 178, 125, 37, 72, 91, 115, 177, 135, 197, 37, 4, 79, 95, 141, 113, 57, 11, 152, 101, 185, 254, 14, 4, 235, 219, 122, 117]), Seed([109, 142, 31, 18, 89, 190, 103, 108, 76, 240, 44, 48, 173, 116, 153, 211, 14, 164, 163, 80, 195, 63, 135, 86, 180, 87, 253, 9, 255, 33, 229, 209]));
/// ADG: GDADG22FOPCVRAC2EIIF55GUYDPAM3TXGPSCTSAKSHTODVOGTW4YZHEX
static immutable ADG = KeyPair(PublicKey([192, 51, 107, 69, 115, 197, 88, 128, 90, 34, 16, 94, 244, 212, 192, 222, 6, 110, 119, 51, 228, 41, 200, 10, 145, 230, 225, 213, 198, 157, 185, 140]), SecretKey([24, 31, 216, 127, 250, 228, 55, 240, 127, 77, 207, 124, 139, 102, 222, 184, 183, 52, 191, 141, 74, 183, 85, 95, 46, 60, 229, 174, 25, 236, 220, 64]), Seed([79, 131, 109, 32, 193, 181, 41, 154, 28, 27, 175, 37, 68, 13, 119, 19, 238, 91, 125, 235, 172, 120, 53, 146, 63, 99, 76, 50, 192, 185, 96, 74]));
/// ADH: GDADH22J4GGL4QFKSAG3U2SNBS45HUVW2C3P3MSQRBDRI6RB3AWPU55N
static immutable ADH = KeyPair(PublicKey([192, 51, 235, 73, 225, 140, 190, 64, 170, 144, 13, 186, 106, 77, 12, 185, 211, 210, 182, 208, 182, 253, 178, 80, 136, 71, 20, 122, 33, 216, 44, 250]), SecretKey([96, 207, 108, 31, 229, 65, 95, 203, 176, 148, 60, 53, 202, 151, 177, 62, 74, 207, 41, 210, 177, 78, 179, 60, 206, 105, 173, 192, 167, 218, 96, 66]), Seed([205, 124, 94, 40, 114, 19, 121, 169, 9, 152, 181, 92, 151, 65, 58, 244, 32, 93, 22, 0, 226, 252, 16, 63, 157, 224, 66, 237, 4, 248, 31, 228]));
/// ADI: GDADI22BKW742ED4LOX6V7XJUSH3RPC6JROT4OR5XHIUVDQQYN3PAGWQ
static immutable ADI = KeyPair(PublicKey([192, 52, 107, 65, 85, 191, 205, 16, 124, 91, 175, 234, 254, 233, 164, 143, 184, 188, 94, 76, 93, 62, 58, 61, 185, 209, 74, 142, 16, 195, 118, 240]), SecretKey([240, 119, 52, 88, 33, 26, 51, 105, 140, 29, 255, 248, 209, 154, 128, 13, 78, 125, 222, 34, 0, 28, 213, 251, 91, 249, 88, 108, 230, 113, 220, 96]), Seed([105, 63, 56, 119, 110, 184, 172, 220, 174, 175, 54, 182, 66, 53, 184, 59, 106, 182, 147, 112, 156, 183, 224, 171, 120, 248, 82, 205, 6, 64, 21, 33]));
/// ADJ: GDADJ22HK4DCKBR6MXKSRYTKW2P2TIAPDXU6UHDS4CET4J5SHQN7O27Z
static immutable ADJ = KeyPair(PublicKey([192, 52, 235, 71, 87, 6, 37, 6, 62, 101, 213, 40, 226, 106, 182, 159, 169, 160, 15, 29, 233, 234, 28, 114, 224, 137, 62, 39, 178, 60, 27, 247]), SecretKey([24, 55, 107, 28, 196, 17, 246, 39, 150, 77, 250, 175, 54, 90, 17, 247, 226, 141, 86, 108, 27, 214, 137, 108, 220, 109, 2, 209, 148, 128, 50, 104]), Seed([92, 49, 179, 104, 34, 125, 85, 84, 108, 89, 159, 126, 48, 138, 239, 173, 142, 135, 173, 151, 4, 117, 234, 65, 0, 138, 148, 172, 253, 35, 126, 155]));
/// ADK: GDADK22ABXGLXPVNCMJOH44QNJ44DCZILE7ZUAEZ226HJNFIAJNYUS33
static immutable ADK = KeyPair(PublicKey([192, 53, 107, 64, 13, 204, 187, 190, 173, 19, 18, 227, 243, 144, 106, 121, 193, 139, 40, 89, 63, 154, 0, 153, 214, 188, 116, 180, 168, 2, 91, 138]), SecretKey([112, 198, 48, 249, 163, 92, 59, 125, 175, 72, 63, 206, 229, 20, 52, 4, 184, 150, 21, 152, 164, 143, 137, 178, 109, 3, 95, 168, 191, 110, 37, 74]), Seed([196, 57, 154, 7, 136, 228, 223, 212, 70, 64, 162, 215, 162, 213, 185, 212, 40, 241, 98, 240, 105, 30, 79, 1, 151, 159, 71, 128, 17, 189, 122, 155]));
/// ADL: GDADL22PXDDVP72ZESBFRAFQS7IECX2VAHLGABHSQGZGA7OGY5INR5PJ
static immutable ADL = KeyPair(PublicKey([192, 53, 235, 79, 184, 199, 87, 255, 89, 36, 130, 88, 128, 176, 151, 208, 65, 95, 85, 1, 214, 96, 4, 242, 129, 178, 96, 125, 198, 199, 80, 216]), SecretKey([80, 120, 228, 102, 240, 85, 210, 192, 253, 181, 188, 32, 108, 235, 41, 136, 146, 138, 143, 69, 75, 44, 24, 63, 204, 69, 206, 137, 95, 162, 10, 86]), Seed([70, 32, 245, 18, 2, 143, 48, 140, 182, 189, 208, 28, 191, 64, 93, 147, 172, 3, 105, 190, 139, 252, 42, 209, 199, 114, 176, 107, 104, 42, 233, 79]));
/// ADM: GDADM225GIMMBHVQPZMU7OV2YY6MFXORB5EFKMU656I6E6NC3YHERFDW
static immutable ADM = KeyPair(PublicKey([192, 54, 107, 93, 50, 24, 192, 158, 176, 126, 89, 79, 186, 186, 198, 60, 194, 221, 209, 15, 72, 85, 50, 158, 239, 145, 226, 121, 162, 222, 14, 72]), SecretKey([160, 129, 240, 4, 30, 177, 130, 149, 31, 88, 251, 220, 148, 82, 53, 129, 24, 41, 158, 100, 6, 38, 55, 46, 112, 173, 195, 20, 112, 115, 169, 118]), Seed([122, 134, 87, 48, 122, 143, 166, 199, 104, 188, 127, 77, 130, 113, 253, 248, 33, 222, 179, 34, 45, 200, 89, 9, 146, 157, 82, 115, 64, 140, 48, 117]));
/// ADN: GDADN22DL7W5OARQCHZ3I4XEA4LIAOPK4EWO2V3QIEYDUDHSYMG7D4MU
static immutable ADN = KeyPair(PublicKey([192, 54, 235, 67, 95, 237, 215, 2, 48, 17, 243, 180, 114, 228, 7, 22, 128, 57, 234, 225, 44, 237, 87, 112, 65, 48, 58, 12, 242, 195, 13, 241]), SecretKey([120, 136, 53, 120, 81, 197, 141, 204, 56, 76, 80, 122, 66, 94, 4, 137, 15, 52, 200, 165, 179, 184, 106, 89, 176, 188, 238, 72, 247, 3, 64, 122]), Seed([154, 25, 222, 127, 97, 85, 198, 112, 68, 178, 46, 4, 143, 115, 75, 155, 243, 63, 69, 47, 203, 114, 38, 155, 165, 57, 14, 221, 223, 251, 236, 92]));
/// ADO: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable ADO = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// ADP: GDADP226IBUVMEQUMJAVJWYC7YVUFLNNVN7MJLZJTC2STEAM5RKZ7P5N
static immutable ADP = KeyPair(PublicKey([192, 55, 235, 94, 64, 105, 86, 18, 20, 98, 65, 84, 219, 2, 254, 43, 66, 173, 173, 171, 126, 196, 175, 41, 152, 181, 41, 144, 12, 236, 85, 159]), SecretKey([216, 160, 161, 34, 72, 80, 80, 63, 168, 164, 155, 67, 127, 6, 40, 228, 85, 80, 253, 204, 101, 126, 152, 4, 120, 89, 252, 12, 42, 243, 39, 97]), Seed([27, 255, 131, 15, 243, 130, 74, 73, 31, 109, 187, 253, 254, 152, 175, 155, 193, 250, 147, 51, 199, 94, 25, 55, 180, 204, 89, 53, 85, 189, 178, 165]));
/// ADQ: GDADQ22UCJUGEWYFQRV5IPK2JQPZMGISYB67HABSA6IIUWNFLLVW7GXG
static immutable ADQ = KeyPair(PublicKey([192, 56, 107, 84, 18, 104, 98, 91, 5, 132, 107, 212, 61, 90, 76, 31, 150, 25, 18, 192, 125, 243, 128, 50, 7, 144, 138, 89, 165, 90, 235, 111]), SecretKey([192, 212, 94, 18, 114, 112, 9, 200, 192, 235, 157, 57, 56, 233, 113, 190, 62, 55, 61, 50, 151, 41, 146, 113, 228, 13, 245, 154, 45, 18, 179, 80]), Seed([65, 190, 158, 138, 251, 203, 113, 85, 152, 54, 105, 64, 185, 227, 135, 104, 232, 158, 91, 205, 198, 231, 226, 109, 29, 254, 234, 29, 17, 95, 138, 150]));
/// ADR: GDADR22BJMQ7YLKV6C7XOK66UL6Y3JD4DHIOTJC26575BQVF5UXXPDN7
static immutable ADR = KeyPair(PublicKey([192, 56, 235, 65, 75, 33, 252, 45, 85, 240, 191, 119, 43, 222, 162, 253, 141, 164, 124, 25, 208, 233, 164, 90, 247, 127, 208, 194, 165, 237, 47, 119]), SecretKey([120, 24, 69, 139, 255, 130, 126, 49, 11, 99, 163, 58, 160, 90, 121, 211, 212, 134, 128, 242, 173, 44, 186, 30, 167, 228, 241, 38, 141, 183, 127, 97]), Seed([218, 231, 59, 156, 204, 136, 16, 13, 79, 26, 71, 244, 134, 104, 60, 158, 116, 55, 37, 31, 240, 31, 114, 4, 250, 2, 212, 239, 155, 179, 181, 252]));
/// ADS: GDADS222XW32GIU5JKHD6LEQCJK5IJINHU5RAWPO4FKDSBF6F6EPVZFD
static immutable ADS = KeyPair(PublicKey([192, 57, 107, 90, 189, 183, 163, 34, 157, 74, 142, 63, 44, 144, 18, 85, 212, 37, 13, 61, 59, 16, 89, 238, 225, 84, 57, 4, 190, 47, 136, 250]), SecretKey([32, 25, 98, 58, 4, 225, 34, 117, 1, 223, 195, 25, 59, 68, 232, 218, 177, 209, 0, 129, 165, 80, 167, 98, 150, 41, 23, 46, 225, 45, 184, 82]), Seed([136, 106, 229, 1, 238, 248, 157, 201, 89, 80, 169, 28, 25, 12, 66, 140, 116, 14, 200, 16, 100, 208, 15, 172, 121, 12, 180, 239, 97, 250, 248, 80]));
/// ADT: GDADT22FO5JH6JC75FVTTAGP5MN5O7F6PL4OERWW7CDHKFRZSUGKTPVB
static immutable ADT = KeyPair(PublicKey([192, 57, 235, 69, 119, 82, 127, 36, 95, 233, 107, 57, 128, 207, 235, 27, 215, 124, 190, 122, 248, 226, 70, 214, 248, 134, 117, 22, 57, 149, 12, 169]), SecretKey([128, 91, 43, 97, 66, 0, 231, 204, 170, 20, 16, 151, 219, 59, 117, 7, 169, 78, 112, 131, 84, 68, 232, 209, 31, 50, 96, 254, 39, 111, 46, 96]), Seed([50, 207, 247, 97, 31, 161, 56, 95, 91, 86, 29, 142, 26, 147, 178, 118, 221, 177, 24, 212, 23, 108, 21, 52, 84, 183, 194, 160, 67, 239, 156, 26]));
/// ADU: GDADU22RTSD3FHLCMNUPC4SQHBBTNAQ67YAFSCO6HLDBHPJQYBRMQJU6
static immutable ADU = KeyPair(PublicKey([192, 58, 107, 81, 156, 135, 178, 157, 98, 99, 104, 241, 114, 80, 56, 67, 54, 130, 30, 254, 0, 89, 9, 222, 58, 198, 19, 189, 48, 192, 98, 200]), SecretKey([88, 160, 214, 156, 203, 107, 32, 146, 162, 18, 237, 5, 140, 78, 60, 88, 250, 117, 129, 188, 75, 62, 226, 94, 122, 230, 224, 171, 44, 30, 46, 89]), Seed([231, 68, 105, 141, 75, 182, 131, 131, 130, 99, 201, 217, 65, 84, 105, 175, 175, 164, 194, 4, 3, 165, 96, 6, 242, 35, 13, 82, 223, 82, 22, 189]));
/// ADV: GDADV22NDAB7AWLXB6XP6OJCU4D6XG6336ZNHJ3UVDFJKC6MVW7TYLLL
static immutable ADV = KeyPair(PublicKey([192, 58, 235, 77, 24, 3, 240, 89, 119, 15, 174, 255, 57, 34, 167, 7, 235, 155, 219, 223, 178, 211, 167, 116, 168, 202, 149, 11, 204, 173, 191, 60]), SecretKey([120, 146, 155, 184, 233, 52, 93, 104, 123, 191, 229, 175, 140, 44, 61, 167, 190, 182, 38, 185, 191, 106, 5, 158, 255, 72, 139, 92, 182, 60, 154, 118]), Seed([90, 230, 46, 195, 150, 205, 204, 188, 217, 158, 50, 64, 253, 238, 8, 181, 113, 51, 83, 138, 118, 83, 239, 116, 80, 20, 83, 224, 115, 97, 43, 58]));
/// ADW: GDADW22EK3PQ57ATUTMRYDYGXLTIJYX3BWXGWVATO7EZ3C3POQ3ANZ67
static immutable ADW = KeyPair(PublicKey([192, 59, 107, 68, 86, 223, 14, 252, 19, 164, 217, 28, 15, 6, 186, 230, 132, 226, 251, 13, 174, 107, 84, 19, 119, 201, 157, 139, 111, 116, 54, 6]), SecretKey([160, 34, 24, 143, 37, 232, 164, 86, 81, 235, 170, 209, 88, 80, 242, 196, 14, 217, 172, 165, 16, 144, 5, 254, 28, 130, 89, 177, 8, 2, 255, 123]), Seed([165, 250, 121, 105, 232, 90, 25, 125, 210, 32, 2, 64, 117, 196, 175, 194, 136, 36, 209, 162, 246, 6, 177, 232, 126, 186, 51, 62, 49, 4, 255, 43]));
/// ADX: GDADX22YLCLXR62F24BYUQEGFOGWPN5XF4W2DWGUETC5SWHJOSBLZJTJ
static immutable ADX = KeyPair(PublicKey([192, 59, 235, 88, 88, 151, 120, 251, 69, 215, 3, 138, 64, 134, 43, 141, 103, 183, 183, 47, 45, 161, 216, 212, 36, 197, 217, 88, 233, 116, 130, 188]), SecretKey([240, 253, 6, 62, 221, 113, 138, 234, 164, 248, 63, 220, 227, 157, 103, 229, 50, 212, 251, 75, 71, 231, 31, 25, 247, 49, 70, 8, 27, 104, 246, 95]), Seed([38, 201, 229, 165, 215, 154, 61, 8, 40, 103, 236, 125, 178, 83, 47, 16, 113, 216, 241, 43, 37, 230, 161, 76, 187, 141, 88, 191, 195, 59, 106, 118]));
/// ADY: GDADY22NJGO23SCYNGBPZIYNPOVNA6BNBLWN23EAD7ICY5MKRASFCQRZ
static immutable ADY = KeyPair(PublicKey([192, 60, 107, 77, 73, 157, 173, 200, 88, 105, 130, 252, 163, 13, 123, 170, 208, 120, 45, 10, 236, 221, 108, 128, 31, 208, 44, 117, 138, 136, 36, 81]), SecretKey([152, 251, 194, 105, 140, 243, 51, 204, 67, 77, 211, 116, 151, 249, 230, 47, 125, 195, 43, 252, 107, 37, 45, 150, 224, 3, 59, 105, 238, 175, 241, 68]), Seed([227, 140, 15, 215, 207, 252, 109, 82, 250, 210, 142, 5, 131, 71, 201, 197, 31, 251, 113, 36, 131, 187, 231, 151, 158, 84, 45, 105, 188, 77, 118, 158]));
/// ADZ: GDADZ22JKAFIWFOBDNGWLBL4NTQONYUQBQS2TCWYWXVX6GVMTBPKHO4W
static immutable ADZ = KeyPair(PublicKey([192, 60, 235, 73, 80, 10, 139, 21, 193, 27, 77, 101, 133, 124, 108, 224, 230, 226, 144, 12, 37, 169, 138, 216, 181, 235, 127, 26, 172, 152, 94, 163]), SecretKey([200, 195, 189, 200, 107, 49, 241, 224, 10, 254, 175, 120, 55, 109, 249, 73, 181, 252, 210, 251, 113, 236, 31, 34, 16, 127, 161, 173, 82, 13, 102, 108]), Seed([56, 190, 53, 69, 26, 180, 30, 44, 171, 28, 131, 131, 98, 189, 254, 185, 141, 25, 199, 231, 111, 148, 6, 27, 127, 206, 46, 173, 179, 41, 77, 42]));
/// AEA: GDAEA22V5HO5SXJARHYOVL4XVVO463POYTCAGF7RSR54KJYK4KVY55SX
static immutable AEA = KeyPair(PublicKey([192, 64, 107, 85, 233, 221, 217, 93, 32, 137, 240, 234, 175, 151, 173, 93, 207, 109, 238, 196, 196, 3, 23, 241, 148, 123, 197, 39, 10, 226, 171, 142]), SecretKey([0, 11, 132, 126, 105, 182, 37, 71, 113, 109, 215, 168, 70, 204, 208, 128, 74, 10, 41, 220, 85, 229, 146, 83, 2, 59, 184, 87, 153, 203, 19, 123]), Seed([169, 196, 91, 82, 173, 13, 132, 194, 231, 46, 156, 52, 12, 58, 8, 12, 75, 231, 187, 83, 225, 170, 14, 170, 70, 23, 220, 23, 92, 132, 224, 39]));
/// AEB: GDAEB226UCXJW7ZHFHRIILPDH5W6UHY5TJ5AWK2ATQMZG5GJ4ZQTOFNG
static immutable AEB = KeyPair(PublicKey([192, 64, 235, 94, 160, 174, 155, 127, 39, 41, 226, 132, 45, 227, 63, 109, 234, 31, 29, 154, 122, 11, 43, 64, 156, 25, 147, 116, 201, 230, 97, 55]), SecretKey([112, 65, 255, 176, 123, 217, 22, 156, 95, 216, 102, 228, 203, 23, 8, 180, 0, 173, 198, 120, 54, 141, 101, 63, 184, 245, 151, 175, 68, 40, 186, 101]), Seed([98, 201, 244, 149, 109, 1, 17, 148, 129, 147, 151, 103, 101, 93, 127, 139, 240, 109, 249, 83, 116, 114, 251, 60, 15, 43, 3, 242, 96, 63, 54, 151]));
/// AEC: GDAEC22AJKMHJGF4I6K7YHBI6VKSENNSHWMI7L5OEUY7VKIB37QC44OY
static immutable AEC = KeyPair(PublicKey([192, 65, 107, 64, 74, 152, 116, 152, 188, 71, 149, 252, 28, 40, 245, 85, 34, 53, 178, 61, 152, 143, 175, 174, 37, 49, 250, 169, 1, 223, 224, 46]), SecretKey([248, 8, 141, 31, 252, 151, 238, 20, 108, 30, 97, 20, 245, 78, 150, 112, 227, 65, 86, 129, 135, 252, 24, 126, 168, 207, 108, 71, 81, 78, 190, 101]), Seed([148, 23, 250, 65, 23, 71, 138, 56, 15, 113, 85, 231, 8, 160, 60, 89, 36, 102, 151, 250, 17, 227, 132, 112, 3, 220, 170, 198, 151, 241, 244, 142]));
/// AED: GDAED226EBAYZIMR3M4J6FSKJQZ3DWR4PZEUTRGNFQPDPH5FLX6ZZIAM
static immutable AED = KeyPair(PublicKey([192, 65, 235, 94, 32, 65, 140, 161, 145, 219, 56, 159, 22, 74, 76, 51, 177, 218, 60, 126, 73, 73, 196, 205, 44, 30, 55, 159, 165, 93, 253, 156]), SecretKey([112, 175, 72, 108, 235, 109, 250, 42, 98, 145, 253, 86, 52, 68, 31, 93, 142, 249, 74, 147, 7, 62, 57, 186, 6, 87, 18, 129, 116, 187, 57, 99]), Seed([88, 13, 96, 167, 115, 87, 178, 89, 74, 208, 37, 180, 228, 117, 9, 126, 28, 151, 255, 69, 22, 255, 234, 177, 176, 205, 76, 16, 170, 235, 16, 159]));
/// AEE: GDAEE22AUQBZ4U36UCYGM75UNXD546UU6Q2LL5EW42NB2F5ZSICRPMBW
static immutable AEE = KeyPair(PublicKey([192, 66, 107, 64, 164, 3, 158, 83, 126, 160, 176, 102, 127, 180, 109, 199, 222, 122, 148, 244, 52, 181, 244, 150, 230, 154, 29, 23, 185, 146, 5, 23]), SecretKey([16, 180, 94, 155, 32, 20, 230, 190, 32, 50, 187, 216, 178, 1, 200, 150, 51, 101, 198, 52, 179, 229, 206, 182, 5, 168, 124, 135, 216, 123, 240, 97]), Seed([35, 120, 163, 71, 204, 104, 52, 230, 194, 126, 26, 108, 82, 152, 235, 141, 118, 200, 244, 214, 68, 197, 188, 77, 220, 132, 63, 201, 177, 39, 140, 178]));
/// AEF: GDAEF22LQLRJ5A22VTVVM3JUECRGEL2TY6AMROBCYLV56NB22TI7RH54
static immutable AEF = KeyPair(PublicKey([192, 66, 235, 75, 130, 226, 158, 131, 90, 172, 235, 86, 109, 52, 32, 162, 98, 47, 83, 199, 128, 200, 184, 34, 194, 235, 223, 52, 58, 212, 209, 248]), SecretKey([88, 68, 20, 102, 123, 125, 171, 25, 211, 41, 80, 153, 28, 83, 21, 142, 244, 106, 158, 59, 27, 249, 62, 199, 87, 254, 107, 112, 61, 53, 118, 67]), Seed([236, 250, 23, 123, 35, 172, 26, 177, 40, 185, 155, 151, 239, 135, 230, 105, 238, 5, 7, 224, 88, 6, 14, 148, 115, 243, 196, 49, 240, 120, 30, 55]));
/// AEG: GDAEG22I3XHCYF2CXFWFQ5VZ7HAGG554AA5ZDAHZH7W3PGYUJ6TK7NWE
static immutable AEG = KeyPair(PublicKey([192, 67, 107, 72, 221, 206, 44, 23, 66, 185, 108, 88, 118, 185, 249, 192, 99, 119, 188, 0, 59, 145, 128, 249, 63, 237, 183, 155, 20, 79, 166, 175]), SecretKey([168, 237, 84, 115, 28, 222, 149, 191, 21, 216, 32, 210, 105, 30, 206, 41, 73, 238, 233, 67, 220, 21, 194, 131, 222, 64, 168, 136, 205, 1, 85, 99]), Seed([228, 177, 28, 72, 64, 73, 159, 215, 155, 127, 97, 13, 139, 163, 14, 42, 69, 44, 250, 134, 142, 47, 8, 111, 173, 31, 122, 7, 116, 161, 4, 113]));
/// AEH: GDAEH22IJSLCL4JLXCPR4523D2AW7ABTQW7UCTEJ5GGQA4VIQCM6ZG6T
static immutable AEH = KeyPair(PublicKey([192, 67, 235, 72, 76, 150, 37, 241, 43, 184, 159, 30, 119, 91, 30, 129, 111, 128, 51, 133, 191, 65, 76, 137, 233, 141, 0, 114, 168, 128, 153, 236]), SecretKey([8, 97, 2, 133, 201, 101, 35, 167, 185, 178, 54, 91, 76, 239, 50, 95, 225, 81, 246, 95, 32, 162, 138, 197, 54, 51, 106, 73, 231, 214, 131, 102]), Seed([79, 243, 58, 47, 130, 153, 122, 184, 239, 172, 30, 204, 135, 103, 83, 87, 227, 171, 237, 195, 35, 61, 67, 237, 108, 153, 250, 150, 164, 246, 146, 108]));
/// AEI: GDAEI22I4OIUZ5SYNDK7SCKI4A3YXVVKCVE6AYECR43IG6PFCZOC2IN3
static immutable AEI = KeyPair(PublicKey([192, 68, 107, 72, 227, 145, 76, 246, 88, 104, 213, 249, 9, 72, 224, 55, 139, 214, 170, 21, 73, 224, 96, 130, 143, 54, 131, 121, 229, 22, 92, 45]), SecretKey([80, 157, 174, 130, 41, 1, 78, 167, 99, 91, 227, 133, 172, 31, 239, 0, 52, 122, 99, 7, 146, 78, 167, 87, 14, 175, 53, 183, 136, 31, 103, 108]), Seed([199, 39, 121, 68, 201, 138, 72, 217, 205, 150, 127, 223, 210, 237, 240, 153, 74, 106, 80, 43, 72, 251, 34, 228, 44, 235, 27, 20, 191, 50, 17, 150]));
/// AEJ: GDAEJ22BZ2G32FDXN2I7DKULWSBDRQGH4WITKEUP3P6SVUVND7ORNCV2
static immutable AEJ = KeyPair(PublicKey([192, 68, 235, 65, 206, 141, 189, 20, 119, 110, 145, 241, 170, 139, 180, 130, 56, 192, 199, 229, 145, 53, 18, 143, 219, 253, 42, 210, 173, 31, 221, 22]), SecretKey([16, 78, 15, 213, 137, 42, 236, 199, 178, 209, 111, 235, 233, 219, 217, 57, 33, 12, 15, 220, 94, 147, 154, 214, 252, 68, 75, 11, 103, 255, 152, 65]), Seed([251, 151, 137, 174, 79, 178, 58, 92, 250, 95, 118, 182, 137, 7, 97, 150, 236, 40, 11, 228, 89, 107, 178, 142, 107, 136, 112, 247, 150, 167, 170, 131]));
/// AEK: GDAEK22ITU6NNWLHKU2XYMBRER75JRWRNRAU5SM25E6QCH5BOEQNCTZE
static immutable AEK = KeyPair(PublicKey([192, 69, 107, 72, 157, 60, 214, 217, 103, 85, 53, 124, 48, 49, 36, 127, 212, 198, 209, 108, 65, 78, 201, 154, 233, 61, 1, 31, 161, 113, 32, 209]), SecretKey([96, 185, 15, 198, 187, 228, 138, 36, 211, 86, 107, 210, 52, 100, 109, 140, 241, 115, 103, 185, 47, 96, 153, 224, 239, 148, 179, 105, 183, 132, 217, 124]), Seed([238, 225, 233, 61, 122, 202, 132, 145, 115, 64, 132, 10, 61, 83, 129, 84, 101, 76, 215, 32, 158, 0, 181, 35, 229, 199, 85, 150, 117, 224, 15, 97]));
/// AEL: GDAEL22ZU2EFKQKLMUKW5OQL2ZTV6DPFPZDHICFFWDK6VOUTSHUXVXLU
static immutable AEL = KeyPair(PublicKey([192, 69, 235, 89, 166, 136, 85, 65, 75, 101, 21, 110, 186, 11, 214, 103, 95, 13, 229, 126, 70, 116, 8, 165, 176, 213, 234, 186, 147, 145, 233, 122]), SecretKey([120, 122, 248, 235, 251, 113, 145, 203, 61, 95, 192, 91, 187, 78, 20, 74, 35, 39, 24, 56, 235, 233, 207, 245, 207, 182, 75, 4, 215, 172, 155, 65]), Seed([178, 103, 209, 13, 221, 55, 100, 173, 21, 14, 197, 80, 246, 191, 6, 25, 124, 61, 23, 127, 198, 151, 8, 77, 179, 26, 57, 68, 117, 179, 78, 133]));
/// AEM: GDAEM22E4JQW7662MLPUIWKD4UMFDECGEFNLO7GISJER4KYPBEUCXJ4V
static immutable AEM = KeyPair(PublicKey([192, 70, 107, 68, 226, 97, 111, 251, 218, 98, 223, 68, 89, 67, 229, 24, 81, 144, 70, 33, 90, 183, 124, 200, 146, 73, 30, 43, 15, 9, 40, 43]), SecretKey([160, 210, 54, 93, 61, 201, 40, 245, 34, 71, 68, 94, 228, 82, 225, 186, 5, 19, 223, 130, 36, 122, 197, 104, 210, 189, 44, 22, 198, 211, 77, 94]), Seed([178, 101, 116, 45, 201, 116, 19, 0, 89, 51, 78, 227, 43, 74, 16, 203, 221, 36, 184, 173, 127, 125, 224, 26, 167, 238, 132, 56, 179, 130, 164, 26]));
/// AEN: GDAEN22ZPXUYACA6YSPZGANKTUENAIXAAF42HKOBJQ6E2SHQYNLEP2M5
static immutable AEN = KeyPair(PublicKey([192, 70, 235, 89, 125, 233, 128, 8, 30, 196, 159, 147, 1, 170, 157, 8, 208, 34, 224, 1, 121, 163, 169, 193, 76, 60, 77, 72, 240, 195, 86, 71]), SecretKey([32, 73, 240, 248, 253, 0, 79, 117, 151, 55, 57, 233, 161, 42, 164, 250, 17, 3, 3, 210, 11, 228, 79, 30, 208, 106, 243, 37, 77, 9, 185, 101]), Seed([242, 171, 98, 157, 174, 150, 24, 113, 186, 34, 53, 95, 154, 127, 183, 250, 147, 182, 20, 115, 178, 192, 6, 85, 27, 218, 232, 71, 77, 211, 137, 125]));
/// AEO: GDAEO22THY7E52ZEQ2NMLYCREOFVOXT2WZZVZPP2LHOQWNCQEDYSHTIF
static immutable AEO = KeyPair(PublicKey([192, 71, 107, 83, 62, 62, 78, 235, 36, 134, 154, 197, 224, 81, 35, 139, 87, 94, 122, 182, 115, 92, 189, 250, 89, 221, 11, 52, 80, 32, 241, 35]), SecretKey([32, 59, 243, 13, 27, 27, 158, 118, 208, 115, 123, 92, 236, 32, 32, 137, 75, 234, 101, 78, 18, 97, 89, 112, 241, 57, 239, 0, 6, 130, 158, 96]), Seed([3, 153, 174, 176, 23, 59, 220, 240, 228, 141, 181, 243, 62, 243, 240, 208, 53, 47, 175, 102, 134, 254, 109, 246, 169, 11, 62, 30, 26, 41, 35, 101]));
/// AEP: GDAEP22RNAGAQ26F6SFILT2ABHAUXZ3K5TMT23I5VRXVW4MDRUFOPDPK
static immutable AEP = KeyPair(PublicKey([192, 71, 235, 81, 104, 12, 8, 107, 197, 244, 138, 133, 207, 64, 9, 193, 75, 231, 106, 236, 217, 61, 109, 29, 172, 111, 91, 113, 131, 141, 10, 231]), SecretKey([80, 132, 122, 79, 42, 53, 42, 206, 20, 199, 171, 17, 23, 137, 170, 117, 106, 95, 100, 57, 231, 105, 205, 140, 208, 251, 16, 75, 8, 80, 4, 66]), Seed([30, 219, 35, 87, 67, 106, 210, 11, 12, 16, 161, 198, 250, 158, 111, 240, 4, 128, 86, 30, 88, 21, 13, 24, 94, 46, 9, 28, 135, 134, 199, 7]));
/// AEQ: GDAEQ22R3UR2ONW3JT6EFJG2J7GHF25YIMUW3Q5YXGOD2ZP7X2CU7H26
static immutable AEQ = KeyPair(PublicKey([192, 72, 107, 81, 221, 35, 167, 54, 219, 76, 252, 66, 164, 218, 79, 204, 114, 235, 184, 67, 41, 109, 195, 184, 185, 156, 61, 101, 255, 190, 133, 79]), SecretKey([8, 55, 106, 1, 106, 67, 44, 75, 106, 152, 28, 92, 97, 140, 210, 57, 66, 124, 141, 179, 201, 238, 200, 176, 81, 31, 82, 162, 172, 248, 35, 97]), Seed([214, 246, 126, 49, 27, 193, 64, 247, 248, 57, 196, 66, 159, 192, 101, 141, 252, 191, 69, 48, 199, 218, 5, 201, 236, 208, 42, 129, 165, 58, 209, 168]));
/// AER: GDAER22NP6BBNGHJE23MMFVLRYM26B4LRGOCIMXFBMQE7QN52VNQ7ENR
static immutable AER = KeyPair(PublicKey([192, 72, 235, 77, 127, 130, 22, 152, 233, 38, 182, 198, 22, 171, 142, 25, 175, 7, 139, 137, 156, 36, 50, 229, 11, 32, 79, 193, 189, 213, 91, 15]), SecretKey([112, 169, 254, 142, 109, 25, 75, 13, 103, 239, 136, 9, 50, 14, 135, 42, 144, 217, 171, 61, 49, 42, 39, 247, 69, 197, 150, 26, 122, 165, 20, 121]), Seed([193, 233, 113, 117, 95, 87, 55, 19, 35, 196, 66, 54, 12, 120, 193, 192, 92, 1, 174, 88, 78, 4, 83, 203, 164, 128, 199, 77, 199, 94, 169, 44]));
/// AES: GDAES22LPLY76QIEV6AXW7MDJ7BYHW56HA7HIPIPSVRDRU2AT3HMYXRT
static immutable AES = KeyPair(PublicKey([192, 73, 107, 75, 122, 241, 255, 65, 4, 175, 129, 123, 125, 131, 79, 195, 131, 219, 190, 56, 62, 116, 61, 15, 149, 98, 56, 211, 64, 158, 206, 204]), SecretKey([144, 50, 53, 91, 80, 122, 129, 118, 107, 224, 110, 185, 172, 43, 92, 114, 77, 19, 142, 195, 73, 182, 236, 2, 187, 62, 174, 44, 205, 223, 55, 65]), Seed([35, 8, 40, 41, 175, 212, 18, 29, 75, 195, 117, 14, 50, 43, 107, 248, 200, 115, 141, 217, 102, 216, 220, 162, 143, 159, 103, 213, 247, 159, 38, 141]));
/// AET: GDAET22TTSUJRDZSS4Q3VGLRQP3UOORPR2H2WNPVLFANHOQH4CO7BPU4
static immutable AET = KeyPair(PublicKey([192, 73, 235, 83, 156, 168, 152, 143, 50, 151, 33, 186, 153, 113, 131, 247, 71, 58, 47, 142, 143, 171, 53, 245, 89, 64, 211, 186, 7, 224, 157, 240]), SecretKey([184, 117, 199, 9, 195, 41, 93, 151, 127, 0, 52, 253, 92, 164, 72, 213, 229, 122, 181, 68, 255, 24, 134, 92, 182, 233, 10, 84, 58, 55, 138, 101]), Seed([50, 219, 146, 61, 19, 171, 180, 201, 46, 11, 194, 107, 34, 231, 203, 111, 158, 40, 94, 110, 171, 115, 52, 46, 161, 32, 88, 63, 41, 192, 54, 100]));
/// AEU: GDAEU22I5FJMUVCDOJNL3EYK2RJL2HHLYAFYWCSHBWBOWGWVY4HBNTD4
static immutable AEU = KeyPair(PublicKey([192, 74, 107, 72, 233, 82, 202, 84, 67, 114, 90, 189, 147, 10, 212, 82, 189, 28, 235, 192, 11, 139, 10, 71, 13, 130, 235, 26, 213, 199, 14, 22]), SecretKey([248, 125, 33, 46, 141, 42, 188, 2, 16, 154, 44, 134, 26, 3, 71, 87, 87, 19, 142, 4, 234, 80, 76, 104, 120, 57, 13, 48, 165, 214, 225, 68]), Seed([195, 8, 170, 6, 64, 21, 206, 175, 0, 233, 187, 132, 128, 53, 60, 201, 160, 69, 104, 48, 21, 180, 81, 91, 221, 244, 188, 154, 165, 190, 191, 105]));
/// AEV: GDAEV22SW2CTHFYSQSBPLJ33PRR7YYHNZJWWOQS3HFM77ENNQYK3PHR5
static immutable AEV = KeyPair(PublicKey([192, 74, 235, 82, 182, 133, 51, 151, 18, 132, 130, 245, 167, 123, 124, 99, 252, 96, 237, 202, 109, 103, 66, 91, 57, 89, 255, 145, 173, 134, 21, 183]), SecretKey([216, 105, 32, 218, 198, 139, 205, 182, 102, 216, 103, 67, 146, 181, 60, 122, 160, 52, 210, 219, 66, 97, 73, 151, 14, 22, 92, 179, 51, 62, 32, 70]), Seed([96, 223, 247, 125, 202, 134, 34, 125, 149, 41, 2, 236, 36, 37, 146, 102, 200, 195, 115, 168, 88, 78, 203, 221, 17, 45, 249, 92, 189, 122, 233, 73]));
/// AEW: GDAEW22ZHACNJZL6MJTZTQ6C5EPOU2BK4C7RDHOE7QWYPPWQN4SKQVSX
static immutable AEW = KeyPair(PublicKey([192, 75, 107, 89, 56, 4, 212, 229, 126, 98, 103, 153, 195, 194, 233, 30, 234, 104, 42, 224, 191, 17, 157, 196, 252, 45, 135, 190, 208, 111, 36, 168]), SecretKey([208, 134, 124, 120, 60, 218, 56, 236, 158, 49, 169, 173, 80, 228, 62, 89, 185, 90, 119, 175, 73, 121, 164, 209, 85, 220, 64, 0, 142, 21, 95, 100]), Seed([65, 73, 71, 167, 82, 125, 254, 127, 229, 50, 117, 2, 176, 240, 142, 247, 157, 6, 41, 0, 33, 237, 218, 1, 129, 30, 108, 12, 180, 198, 165, 52]));
/// AEX: GDAEX22R4CQQYIRVDKFVY6254IZ426FGXCIYYFNAB52KZL2ZTW74RMOJ
static immutable AEX = KeyPair(PublicKey([192, 75, 235, 81, 224, 161, 12, 34, 53, 26, 139, 92, 123, 93, 226, 51, 205, 120, 166, 184, 145, 140, 21, 160, 15, 116, 172, 175, 89, 157, 191, 200]), SecretKey([120, 200, 162, 215, 215, 162, 22, 64, 155, 215, 195, 161, 2, 221, 174, 240, 9, 174, 80, 253, 108, 18, 100, 119, 153, 237, 216, 128, 209, 144, 32, 126]), Seed([25, 99, 60, 47, 23, 44, 135, 73, 39, 203, 205, 169, 39, 254, 42, 235, 194, 130, 241, 189, 236, 48, 2, 18, 142, 200, 157, 29, 87, 129, 158, 122]));
/// AEY: GDAEY22POF6Q73WHXGJNV5JRJDPFDMRTMSRH4NHGQK46K7FQDN2AW32Z
static immutable AEY = KeyPair(PublicKey([192, 76, 107, 79, 113, 125, 15, 238, 199, 185, 146, 218, 245, 49, 72, 222, 81, 178, 51, 100, 162, 126, 52, 230, 130, 185, 229, 124, 176, 27, 116, 11]), SecretKey([88, 56, 173, 8, 235, 163, 166, 242, 243, 12, 51, 164, 173, 150, 254, 156, 71, 96, 75, 104, 222, 112, 57, 48, 142, 253, 50, 176, 171, 31, 107, 80]), Seed([117, 41, 249, 54, 246, 39, 135, 69, 98, 91, 15, 181, 203, 24, 99, 177, 26, 203, 210, 191, 59, 197, 18, 251, 219, 5, 92, 254, 9, 53, 100, 41]));
/// AEZ: GDAEZ22LGHRCDJCX2PVSWI32B24Q7JWHEKGJDJYOKQGO7AHREPOTLM5P
static immutable AEZ = KeyPair(PublicKey([192, 76, 235, 75, 49, 226, 33, 164, 87, 211, 235, 43, 35, 122, 14, 185, 15, 166, 199, 34, 140, 145, 167, 14, 84, 12, 239, 128, 241, 35, 221, 53]), SecretKey([72, 194, 41, 92, 247, 62, 28, 44, 182, 35, 18, 107, 28, 2, 47, 127, 122, 158, 93, 68, 166, 223, 232, 211, 209, 31, 169, 28, 161, 178, 125, 96]), Seed([199, 122, 118, 124, 35, 206, 107, 160, 154, 155, 240, 214, 69, 185, 76, 107, 39, 39, 58, 64, 208, 42, 49, 245, 15, 132, 159, 85, 33, 162, 27, 224]));
/// AFA: GDAFA22IQNHFW4WUZXJJBBN66O77BXCTIKPP6PMJXCYD6WXWUPYXNXHV
static immutable AFA = KeyPair(PublicKey([192, 80, 107, 72, 131, 78, 91, 114, 212, 205, 210, 144, 133, 190, 243, 191, 240, 220, 83, 66, 158, 255, 61, 137, 184, 176, 63, 90, 246, 163, 241, 118]), SecretKey([32, 10, 25, 109, 96, 103, 73, 60, 202, 48, 37, 194, 6, 55, 163, 129, 56, 201, 106, 64, 144, 128, 6, 30, 140, 118, 14, 2, 29, 115, 249, 65]), Seed([12, 74, 218, 38, 0, 112, 102, 243, 119, 100, 157, 16, 33, 98, 196, 218, 59, 75, 25, 34, 114, 15, 234, 234, 18, 214, 198, 12, 131, 9, 54, 245]));
/// AFB: GDAFB22M25FUYTECLMLQAYRL5L4E6QWCSP33TQFVG3BVD5FA3OEYIKAC
static immutable AFB = KeyPair(PublicKey([192, 80, 235, 76, 215, 75, 76, 76, 130, 91, 23, 0, 98, 43, 234, 248, 79, 66, 194, 147, 247, 185, 192, 181, 54, 195, 81, 244, 160, 219, 137, 132]), SecretKey([88, 199, 164, 251, 36, 56, 27, 169, 36, 136, 156, 83, 59, 21, 230, 66, 123, 83, 212, 75, 13, 27, 52, 67, 141, 144, 72, 253, 153, 8, 104, 86]), Seed([121, 49, 212, 152, 204, 89, 4, 187, 239, 84, 99, 14, 162, 255, 217, 217, 179, 24, 152, 204, 44, 58, 115, 70, 133, 249, 2, 149, 176, 101, 47, 12]));
/// AFC: GDAFC22PTS5PA64CLQBEJGXZHRLAVGNDNO2HWNGXLWPGE4QAY2CWEBSI
static immutable AFC = KeyPair(PublicKey([192, 81, 107, 79, 156, 186, 240, 123, 130, 92, 2, 68, 154, 249, 60, 86, 10, 153, 163, 107, 180, 123, 52, 215, 93, 158, 98, 114, 0, 198, 133, 98]), SecretKey([240, 141, 106, 58, 5, 51, 175, 19, 207, 136, 192, 152, 165, 217, 182, 157, 251, 46, 206, 177, 194, 206, 219, 221, 51, 158, 224, 220, 147, 24, 166, 106]), Seed([52, 111, 234, 232, 26, 43, 12, 100, 204, 211, 136, 217, 88, 35, 204, 91, 88, 181, 65, 116, 11, 160, 189, 186, 98, 253, 48, 179, 24, 44, 176, 237]));
/// AFD: GDAFD22CSJ3L4HNYBKO266Y3TQC724FDF3OXP7AY72FPP2UPHUCX5KMT
static immutable AFD = KeyPair(PublicKey([192, 81, 235, 66, 146, 118, 190, 29, 184, 10, 157, 175, 123, 27, 156, 5, 253, 112, 163, 46, 221, 119, 252, 24, 254, 138, 247, 234, 143, 61, 5, 126]), SecretKey([136, 206, 35, 47, 50, 11, 178, 220, 79, 78, 35, 145, 188, 176, 21, 91, 31, 15, 235, 145, 234, 195, 5, 98, 102, 32, 68, 12, 51, 80, 151, 74]), Seed([233, 164, 102, 140, 207, 187, 111, 59, 202, 237, 228, 97, 90, 150, 35, 105, 229, 41, 66, 161, 221, 85, 97, 196, 254, 76, 1, 18, 180, 53, 115, 14]));
/// AFE: GDAFE22YJ72FY4MXWCP2WKQMFVBR4S3LFWNXNDDNCKVD2F3SM5GNPKDE
static immutable AFE = KeyPair(PublicKey([192, 82, 107, 88, 79, 244, 92, 113, 151, 176, 159, 171, 42, 12, 45, 67, 30, 75, 107, 45, 155, 118, 140, 109, 18, 170, 61, 23, 114, 103, 76, 215]), SecretKey([96, 53, 197, 216, 12, 167, 79, 146, 4, 62, 40, 46, 177, 225, 93, 175, 120, 83, 25, 221, 185, 134, 50, 87, 152, 59, 168, 49, 243, 46, 31, 108]), Seed([126, 45, 12, 153, 37, 146, 212, 7, 128, 231, 212, 55, 229, 15, 204, 237, 196, 170, 55, 187, 126, 242, 108, 176, 180, 215, 202, 232, 108, 252, 99, 166]));
/// AFF: GDAFF2274H3FHUZ26RONUNJSEWZFXMZ2BOLD432CPMIS3OVVNWQJXXC6
static immutable AFF = KeyPair(PublicKey([192, 82, 235, 95, 225, 246, 83, 211, 58, 244, 92, 218, 53, 50, 37, 178, 91, 179, 58, 11, 150, 62, 111, 66, 123, 17, 45, 186, 181, 109, 160, 155]), SecretKey([216, 223, 145, 8, 237, 169, 82, 238, 1, 171, 27, 200, 20, 62, 128, 20, 147, 122, 86, 7, 116, 53, 20, 86, 31, 131, 66, 241, 144, 77, 241, 116]), Seed([234, 70, 82, 190, 135, 186, 126, 94, 205, 193, 199, 143, 65, 169, 5, 10, 221, 231, 229, 84, 33, 144, 23, 158, 44, 39, 89, 19, 121, 145, 11, 85]));
/// AFG: GDAFG224NEOXKUFTBVJVVPXNG3ILHUKGHARUOL36IYXWFFMD3WYAWWKC
static immutable AFG = KeyPair(PublicKey([192, 83, 107, 92, 105, 29, 117, 80, 179, 13, 83, 90, 190, 237, 54, 208, 179, 209, 70, 56, 35, 71, 47, 126, 70, 47, 98, 149, 131, 221, 176, 11]), SecretKey([184, 183, 206, 68, 202, 116, 179, 174, 113, 156, 131, 23, 195, 183, 51, 120, 69, 229, 110, 213, 38, 16, 62, 232, 68, 165, 105, 130, 79, 203, 142, 101]), Seed([80, 231, 36, 97, 231, 219, 245, 198, 2, 57, 194, 183, 14, 18, 35, 150, 17, 5, 51, 82, 30, 223, 224, 13, 223, 222, 50, 34, 116, 192, 110, 255]));
/// AFH: GDAFH22NTKXLDOOFCZ52F3IZUSEAJH2HSH5DQP7JEC5PPKAXIHAZSUWS
static immutable AFH = KeyPair(PublicKey([192, 83, 235, 77, 154, 174, 177, 185, 197, 22, 123, 162, 237, 25, 164, 136, 4, 159, 71, 145, 250, 56, 63, 233, 32, 186, 247, 168, 23, 65, 193, 153]), SecretKey([216, 163, 149, 149, 98, 28, 126, 176, 87, 68, 244, 9, 148, 240, 228, 74, 223, 37, 73, 236, 136, 48, 32, 24, 29, 21, 17, 57, 10, 253, 57, 96]), Seed([46, 102, 90, 210, 6, 137, 43, 241, 167, 255, 175, 20, 174, 254, 40, 237, 184, 148, 73, 250, 79, 138, 82, 147, 47, 199, 76, 62, 216, 60, 115, 169]));
/// AFI: GDAFI22T25QOKSH72CIVH22DKNXNRS3TIKT5NBD2UWDLYGAUWJKA7XUG
static immutable AFI = KeyPair(PublicKey([192, 84, 107, 83, 215, 96, 229, 72, 255, 208, 145, 83, 235, 67, 83, 110, 216, 203, 115, 66, 167, 214, 132, 122, 165, 134, 188, 24, 20, 178, 84, 15]), SecretKey([48, 2, 248, 33, 159, 251, 86, 229, 167, 190, 51, 71, 215, 145, 195, 218, 122, 49, 250, 174, 112, 243, 60, 224, 186, 20, 182, 39, 5, 20, 185, 80]), Seed([239, 244, 166, 110, 107, 100, 199, 201, 36, 29, 243, 0, 240, 193, 236, 105, 17, 26, 228, 183, 52, 243, 249, 161, 93, 43, 212, 220, 177, 82, 14, 251]));
/// AFJ: GDAFJ22QEKNHSWZJQDG7BJNPPHTTSVKRFK6TLV4BQY7U4OIUWMNFJHJW
static immutable AFJ = KeyPair(PublicKey([192, 84, 235, 80, 34, 154, 121, 91, 41, 128, 205, 240, 165, 175, 121, 231, 57, 85, 81, 42, 189, 53, 215, 129, 134, 63, 78, 57, 20, 179, 26, 84]), SecretKey([168, 133, 149, 102, 177, 203, 170, 191, 148, 8, 170, 222, 47, 78, 107, 51, 78, 111, 150, 171, 110, 4, 171, 110, 207, 225, 16, 56, 253, 219, 38, 109]), Seed([103, 30, 68, 117, 70, 28, 229, 134, 71, 208, 200, 84, 244, 106, 65, 144, 157, 234, 37, 45, 170, 240, 46, 87, 109, 131, 149, 42, 194, 119, 70, 74]));
/// AFK: GDAFK22GY2OGQWTXQCJ7GNXXXXZNSUZ3OMSSD6XXZGAB4V5URS3UEHUT
static immutable AFK = KeyPair(PublicKey([192, 85, 107, 70, 198, 156, 104, 90, 119, 128, 147, 243, 54, 247, 189, 242, 217, 83, 59, 115, 37, 33, 250, 247, 201, 128, 30, 87, 180, 140, 183, 66]), SecretKey([240, 50, 147, 200, 166, 229, 216, 228, 71, 192, 9, 185, 134, 222, 242, 195, 222, 50, 228, 79, 133, 147, 32, 122, 204, 3, 98, 178, 173, 243, 81, 107]), Seed([70, 123, 148, 182, 155, 251, 170, 97, 189, 246, 156, 208, 248, 192, 83, 80, 28, 93, 179, 42, 140, 235, 39, 22, 231, 190, 119, 169, 175, 91, 152, 14]));
/// AFL: GDAFL22FHZ74V7WKQFOP22ZNBIUB36JX3V2SXDTAI27HNPSWN54KM7A2
static immutable AFL = KeyPair(PublicKey([192, 85, 235, 69, 62, 127, 202, 254, 202, 129, 92, 253, 107, 45, 10, 40, 29, 249, 55, 221, 117, 43, 142, 96, 70, 190, 118, 190, 86, 111, 120, 166]), SecretKey([0, 150, 46, 130, 142, 85, 47, 255, 158, 19, 153, 150, 103, 187, 152, 248, 132, 127, 127, 1, 253, 251, 39, 115, 198, 61, 53, 169, 174, 94, 0, 84]), Seed([242, 218, 165, 19, 101, 208, 243, 37, 11, 21, 74, 38, 73, 160, 219, 140, 86, 149, 58, 103, 8, 193, 215, 177, 176, 55, 215, 44, 102, 169, 134, 108]));
/// AFM: GDAFM22SPZGXN3EPBCW2TCC56BA2TST6HONDJDCPWQVLKT3A4MRXFUOT
static immutable AFM = KeyPair(PublicKey([192, 86, 107, 82, 126, 77, 118, 236, 143, 8, 173, 169, 136, 93, 240, 65, 169, 202, 126, 59, 154, 52, 140, 79, 180, 42, 181, 79, 96, 227, 35, 114]), SecretKey([184, 25, 238, 191, 50, 85, 92, 212, 73, 118, 104, 145, 179, 103, 244, 54, 245, 186, 104, 106, 65, 124, 54, 208, 97, 197, 197, 197, 227, 103, 119, 68]), Seed([90, 96, 204, 41, 96, 98, 144, 108, 121, 215, 81, 129, 78, 175, 181, 212, 91, 248, 90, 8, 225, 216, 100, 14, 197, 42, 150, 200, 5, 93, 44, 63]));
/// AFN: GDAFN22QMICSK4UHWGFXLYCLUBSAKSUMWYH72H3FWBV6PIOLFVBSC3TA
static immutable AFN = KeyPair(PublicKey([192, 86, 235, 80, 98, 5, 37, 114, 135, 177, 139, 117, 224, 75, 160, 100, 5, 74, 140, 182, 15, 253, 31, 101, 176, 107, 231, 161, 203, 45, 67, 33]), SecretKey([32, 131, 251, 119, 238, 156, 231, 231, 119, 154, 21, 214, 49, 3, 117, 131, 84, 144, 36, 28, 165, 219, 251, 110, 75, 205, 91, 20, 25, 54, 62, 96]), Seed([225, 71, 100, 103, 190, 90, 46, 224, 72, 183, 226, 115, 226, 121, 41, 92, 34, 242, 168, 201, 172, 161, 139, 116, 61, 172, 16, 247, 207, 55, 173, 93]));
/// AFO: GDAFO22H2II3SGZ3HGRQ4QGWUINWSNOWP54YIMHGA6I5BMZPA2DEXU3Q
static immutable AFO = KeyPair(PublicKey([192, 87, 107, 71, 210, 17, 185, 27, 59, 57, 163, 14, 64, 214, 162, 27, 105, 53, 214, 127, 121, 132, 48, 230, 7, 145, 208, 179, 47, 6, 134, 75]), SecretKey([112, 172, 214, 48, 26, 44, 8, 222, 209, 4, 179, 38, 48, 179, 166, 20, 80, 76, 236, 205, 84, 198, 235, 193, 197, 174, 84, 10, 100, 109, 72, 109]), Seed([248, 60, 234, 204, 59, 78, 243, 170, 174, 110, 207, 158, 79, 40, 124, 183, 6, 155, 152, 191, 235, 142, 35, 143, 41, 109, 90, 5, 249, 15, 143, 212]));
/// AFP: GDAFP227EMXJQETLDGKLBOPK2R7NFUYC6R4DCO3SFWKX7U2M2WSKHZAB
static immutable AFP = KeyPair(PublicKey([192, 87, 235, 95, 35, 46, 152, 18, 107, 25, 148, 176, 185, 234, 212, 126, 210, 211, 2, 244, 120, 49, 59, 114, 45, 149, 127, 211, 76, 213, 164, 163]), SecretKey([56, 185, 235, 130, 119, 13, 152, 189, 55, 129, 199, 152, 9, 127, 205, 11, 89, 190, 21, 144, 231, 72, 96, 183, 67, 89, 138, 132, 209, 32, 197, 72]), Seed([213, 250, 217, 101, 29, 226, 161, 85, 148, 227, 129, 82, 81, 76, 86, 132, 41, 231, 247, 106, 69, 184, 57, 44, 140, 27, 211, 126, 90, 144, 93, 119]));
/// AFQ: GDAFQ22BBBFSATV2YQH3GNEE6HAS7D2U6YADTBPUSGFAVHHZZFUREMFO
static immutable AFQ = KeyPair(PublicKey([192, 88, 107, 65, 8, 75, 32, 78, 186, 196, 15, 179, 52, 132, 241, 193, 47, 143, 84, 246, 0, 57, 133, 244, 145, 138, 10, 156, 249, 201, 105, 18]), SecretKey([96, 209, 59, 16, 170, 40, 182, 196, 19, 225, 2, 189, 246, 137, 15, 126, 213, 114, 239, 0, 51, 101, 212, 68, 130, 1, 141, 223, 70, 1, 97, 108]), Seed([83, 4, 100, 228, 165, 211, 183, 95, 254, 232, 238, 84, 253, 84, 198, 242, 212, 123, 105, 233, 189, 33, 97, 40, 31, 25, 28, 115, 210, 165, 181, 160]));
/// AFR: GDAFR2227Z3NAFOROFR3MYJCKAJCIMRHAANQCBDS4N6M6YH2BSKBHD5H
static immutable AFR = KeyPair(PublicKey([192, 88, 235, 90, 254, 118, 208, 21, 209, 113, 99, 182, 97, 34, 80, 18, 36, 50, 39, 0, 27, 1, 4, 114, 227, 124, 207, 96, 250, 12, 148, 19]), SecretKey([16, 51, 7, 137, 129, 81, 181, 236, 167, 236, 91, 149, 28, 70, 79, 100, 202, 206, 192, 140, 91, 253, 18, 184, 108, 238, 98, 124, 154, 96, 192, 82]), Seed([36, 245, 204, 239, 6, 40, 156, 9, 213, 130, 29, 182, 135, 84, 178, 76, 249, 7, 248, 85, 11, 187, 217, 155, 241, 146, 72, 19, 145, 203, 211, 177]));
/// AFS: GDAFS22LGCDKPWFPVNAM5OVYPQOGKHZORS4HLGEE2IMZEY5LBUWM3STV
static immutable AFS = KeyPair(PublicKey([192, 89, 107, 75, 48, 134, 167, 216, 175, 171, 64, 206, 186, 184, 124, 28, 101, 31, 46, 140, 184, 117, 152, 132, 210, 25, 146, 99, 171, 13, 44, 205]), SecretKey([16, 243, 12, 25, 248, 236, 233, 255, 125, 84, 31, 69, 146, 128, 113, 154, 79, 186, 74, 20, 117, 237, 219, 64, 116, 88, 226, 145, 250, 208, 156, 73]), Seed([61, 127, 211, 41, 32, 238, 63, 211, 183, 77, 174, 197, 35, 4, 142, 83, 103, 16, 148, 249, 78, 30, 190, 113, 193, 182, 99, 78, 170, 181, 47, 84]));
/// AFT: GDAFT22SMJFBFCNNVTKKT4L7Q4UX2EUQZRXZJT3TMQJ4IRFOEKJSGIFK
static immutable AFT = KeyPair(PublicKey([192, 89, 235, 82, 98, 74, 18, 137, 173, 172, 212, 169, 241, 127, 135, 41, 125, 18, 144, 204, 111, 148, 207, 115, 100, 19, 196, 68, 174, 34, 147, 35]), SecretKey([96, 182, 165, 71, 215, 120, 182, 66, 203, 34, 112, 88, 114, 63, 112, 113, 198, 94, 36, 111, 58, 42, 106, 60, 173, 83, 76, 73, 89, 22, 126, 76]), Seed([145, 224, 211, 52, 43, 181, 154, 60, 108, 235, 182, 177, 8, 201, 219, 216, 74, 213, 243, 149, 172, 144, 235, 208, 245, 97, 165, 42, 215, 222, 250, 122]));
/// AFU: GDAFU22XX4MVCJB2DZNKQLIAK7JH5POUUHQULERRHDV6ROTRXIB7A5N7
static immutable AFU = KeyPair(PublicKey([192, 90, 107, 87, 191, 25, 81, 36, 58, 30, 90, 168, 45, 0, 87, 210, 126, 189, 212, 161, 225, 69, 146, 49, 56, 235, 232, 186, 113, 186, 3, 240]), SecretKey([104, 44, 2, 17, 80, 150, 20, 41, 74, 86, 86, 18, 52, 145, 39, 108, 180, 145, 107, 10, 168, 187, 152, 165, 92, 149, 205, 202, 248, 76, 154, 66]), Seed([185, 32, 213, 197, 145, 63, 66, 28, 100, 204, 107, 70, 146, 175, 214, 63, 16, 159, 143, 19, 240, 175, 223, 205, 25, 32, 154, 53, 17, 63, 87, 194]));
/// AFV: GDAFV22VG5VLGSE5FLBBLDXB5CBRJX5QUL4FNASLPPIH4OVBL4YYADQ5
static immutable AFV = KeyPair(PublicKey([192, 90, 235, 85, 55, 106, 179, 72, 157, 42, 194, 21, 142, 225, 232, 131, 20, 223, 176, 162, 248, 86, 130, 75, 123, 208, 126, 58, 161, 95, 49, 128]), SecretKey([144, 86, 89, 178, 17, 21, 153, 203, 48, 231, 185, 250, 245, 18, 206, 132, 229, 255, 227, 122, 232, 161, 111, 58, 123, 44, 128, 217, 90, 248, 9, 84]), Seed([197, 43, 59, 178, 46, 40, 151, 195, 232, 224, 2, 162, 68, 239, 82, 182, 247, 77, 210, 155, 206, 255, 166, 166, 105, 169, 24, 217, 246, 191, 70, 182]));
/// AFW: GDAFW22DNW2P3LX6EF5S3ZC4YJKUZG4QITNBD4FZRIYWM5GXVUF4ON5A
static immutable AFW = KeyPair(PublicKey([192, 91, 107, 67, 109, 180, 253, 174, 254, 33, 123, 45, 228, 92, 194, 85, 76, 155, 144, 68, 218, 17, 240, 185, 138, 49, 102, 116, 215, 173, 11, 199]), SecretKey([232, 97, 176, 60, 15, 75, 124, 79, 21, 101, 47, 41, 36, 164, 82, 249, 208, 78, 78, 127, 2, 152, 80, 174, 83, 104, 22, 254, 59, 243, 44, 127]), Seed([50, 33, 103, 64, 232, 207, 44, 143, 95, 119, 196, 131, 218, 129, 231, 194, 161, 11, 190, 134, 211, 146, 5, 230, 163, 198, 116, 210, 153, 27, 59, 52]));
/// AFX: GDAFX22JFXRXRIGUF6ZYOLOP3BAOTTRNTMHXD3DEFC2BPLUGHSF3AT5T
static immutable AFX = KeyPair(PublicKey([192, 91, 235, 73, 45, 227, 120, 160, 212, 47, 179, 135, 45, 207, 216, 64, 233, 206, 45, 155, 15, 113, 236, 100, 40, 180, 23, 174, 134, 60, 139, 176]), SecretKey([160, 64, 57, 166, 214, 202, 94, 207, 77, 9, 16, 42, 240, 63, 135, 221, 163, 108, 91, 138, 50, 77, 37, 13, 28, 29, 182, 135, 179, 233, 239, 123]), Seed([246, 253, 111, 78, 217, 180, 154, 42, 96, 2, 188, 203, 229, 178, 78, 26, 100, 170, 86, 210, 105, 8, 233, 219, 20, 222, 215, 17, 236, 35, 178, 123]));
/// AFY: GDAFY22LUF4HYIZR3GBB37SO5LH2N6GSZJJJCL32XQNJKFBMOM2XLWTE
static immutable AFY = KeyPair(PublicKey([192, 92, 107, 75, 161, 120, 124, 35, 49, 217, 130, 29, 254, 78, 234, 207, 166, 248, 210, 202, 82, 145, 47, 122, 188, 26, 149, 20, 44, 115, 53, 117]), SecretKey([200, 145, 246, 107, 202, 187, 69, 120, 124, 254, 19, 115, 126, 244, 90, 25, 53, 184, 237, 212, 206, 98, 220, 27, 22, 220, 254, 104, 60, 28, 56, 72]), Seed([96, 138, 39, 130, 247, 253, 29, 229, 170, 129, 105, 65, 106, 160, 140, 90, 207, 200, 104, 161, 31, 11, 60, 62, 218, 89, 148, 199, 160, 201, 203, 50]));
/// AFZ: GDAFZ22H7EYE7HCY37SHJEZV4Z4ZHRLYNUXO3TXS54M3SG43ZN6ZMHS5
static immutable AFZ = KeyPair(PublicKey([192, 92, 235, 71, 249, 48, 79, 156, 88, 223, 228, 116, 147, 53, 230, 121, 147, 197, 120, 109, 46, 237, 206, 242, 239, 25, 185, 27, 155, 203, 125, 150]), SecretKey([0, 207, 103, 187, 48, 235, 93, 31, 249, 117, 106, 182, 141, 59, 184, 110, 106, 193, 31, 171, 153, 211, 229, 185, 151, 72, 17, 113, 223, 215, 46, 101]), Seed([39, 206, 33, 94, 48, 11, 114, 2, 117, 118, 74, 89, 157, 95, 21, 114, 117, 144, 66, 252, 34, 230, 165, 35, 19, 90, 236, 139, 105, 50, 246, 2]));
/// AGA: GDAGA22SI3Q5RRWJ34NZ6FFYB6WTPETKTYNJUR5FS3S66XAYO2IPTAD4
static immutable AGA = KeyPair(PublicKey([192, 96, 107, 82, 70, 225, 216, 198, 201, 223, 27, 159, 20, 184, 15, 173, 55, 146, 106, 158, 26, 154, 71, 165, 150, 229, 239, 92, 24, 118, 144, 249]), SecretKey([32, 112, 210, 141, 152, 0, 208, 251, 98, 21, 145, 51, 200, 91, 146, 34, 153, 39, 24, 89, 89, 106, 77, 204, 176, 24, 95, 76, 205, 176, 138, 117]), Seed([185, 65, 36, 210, 97, 217, 161, 182, 132, 217, 88, 151, 245, 25, 86, 4, 96, 60, 133, 161, 90, 180, 102, 33, 134, 242, 186, 26, 8, 2, 29, 35]));
/// AGB: GDAGB22Q6NL5NIWFDNJGUVTZTE2QJATZZMVKZ34HBI4ZUZVJLVWWJLJW
static immutable AGB = KeyPair(PublicKey([192, 96, 235, 80, 243, 87, 214, 162, 197, 27, 82, 106, 86, 121, 153, 53, 4, 130, 121, 203, 42, 172, 239, 135, 10, 57, 154, 102, 169, 93, 109, 100]), SecretKey([168, 94, 206, 199, 206, 34, 8, 59, 215, 229, 104, 129, 19, 43, 252, 144, 58, 240, 83, 228, 238, 128, 92, 162, 146, 209, 211, 214, 239, 109, 53, 74]), Seed([238, 245, 200, 23, 42, 56, 240, 228, 204, 174, 198, 120, 52, 248, 58, 25, 228, 159, 140, 59, 185, 23, 67, 3, 11, 180, 96, 54, 112, 170, 103, 156]));
/// AGC: GDAGC22TN3KNQKT44X3Z4LA6E62WSFHJ2VPIP3RBKYXKG7NXOGILJ26Q
static immutable AGC = KeyPair(PublicKey([192, 97, 107, 83, 110, 212, 216, 42, 124, 229, 247, 158, 44, 30, 39, 181, 105, 20, 233, 213, 94, 135, 238, 33, 86, 46, 163, 125, 183, 113, 144, 180]), SecretKey([120, 67, 6, 172, 99, 170, 109, 249, 244, 79, 78, 241, 134, 36, 31, 36, 76, 107, 4, 202, 140, 239, 117, 131, 78, 2, 180, 24, 199, 181, 230, 112]), Seed([76, 128, 127, 60, 20, 88, 213, 116, 234, 104, 67, 188, 226, 10, 24, 128, 231, 135, 94, 24, 14, 112, 106, 9, 127, 177, 139, 18, 143, 17, 116, 101]));
/// AGD: GDAGD22BQFTG3C5VP7FM4EVKG2GHUDND3KM3MCLJLZ72VMJNMNNV6MSQ
static immutable AGD = KeyPair(PublicKey([192, 97, 235, 65, 129, 102, 109, 139, 181, 127, 202, 206, 18, 170, 54, 140, 122, 13, 163, 218, 153, 182, 9, 105, 94, 127, 170, 177, 45, 99, 91, 95]), SecretKey([168, 5, 153, 39, 23, 195, 238, 40, 8, 160, 101, 69, 63, 235, 152, 235, 1, 27, 70, 189, 160, 15, 18, 253, 7, 229, 45, 153, 208, 235, 39, 107]), Seed([228, 157, 42, 174, 93, 21, 122, 212, 100, 102, 17, 232, 50, 180, 215, 154, 110, 233, 252, 146, 55, 238, 111, 112, 93, 96, 155, 150, 238, 69, 140, 58]));
/// AGE: GDAGE22R6PZY4DLRSK3ASHJT6FPHNNHIMNYYBYZQH5WONF2UZXZVCQR7
static immutable AGE = KeyPair(PublicKey([192, 98, 107, 81, 243, 243, 142, 13, 113, 146, 182, 9, 29, 51, 241, 94, 118, 180, 232, 99, 113, 128, 227, 48, 63, 108, 230, 151, 84, 205, 243, 81]), SecretKey([96, 57, 129, 154, 173, 60, 3, 116, 255, 89, 67, 210, 211, 187, 230, 188, 245, 243, 145, 16, 203, 203, 84, 169, 202, 101, 145, 58, 11, 11, 76, 64]), Seed([203, 5, 161, 108, 168, 8, 175, 93, 253, 82, 96, 37, 193, 230, 100, 20, 86, 150, 124, 170, 113, 5, 212, 119, 31, 145, 18, 214, 91, 183, 134, 56]));
/// AGF: GDAGF22TCNNV6FFAPGWVGSF2DGPQJCVBVF2BX2HXH5J66BPBXDA72ASF
static immutable AGF = KeyPair(PublicKey([192, 98, 235, 83, 19, 91, 95, 20, 160, 121, 173, 83, 72, 186, 25, 159, 4, 138, 161, 169, 116, 27, 232, 247, 63, 83, 239, 5, 225, 184, 193, 253]), SecretKey([200, 11, 206, 182, 159, 245, 232, 233, 79, 177, 243, 145, 133, 139, 98, 56, 29, 163, 171, 184, 27, 141, 31, 20, 44, 77, 208, 59, 38, 5, 200, 68]), Seed([110, 172, 202, 220, 38, 2, 231, 73, 12, 187, 201, 1, 138, 145, 138, 22, 159, 166, 71, 103, 162, 196, 116, 40, 58, 162, 45, 117, 60, 60, 242, 99]));
/// AGG: GDAGG22HGMIAW4ZKBL52XJYTE3TCHZUJQXILW5JW2LCZJ3XOEF5RNHHM
static immutable AGG = KeyPair(PublicKey([192, 99, 107, 71, 51, 16, 11, 115, 42, 10, 251, 171, 167, 19, 38, 230, 35, 230, 137, 133, 208, 187, 117, 54, 210, 197, 148, 238, 238, 33, 123, 22]), SecretKey([192, 201, 9, 109, 50, 189, 192, 186, 250, 52, 209, 36, 230, 108, 138, 39, 185, 229, 29, 145, 114, 158, 17, 185, 168, 18, 148, 29, 211, 222, 239, 93]), Seed([40, 120, 29, 176, 70, 190, 236, 177, 225, 206, 242, 150, 28, 36, 186, 29, 69, 149, 159, 129, 61, 178, 199, 157, 14, 215, 212, 112, 18, 112, 177, 143]));
/// AGH: GDAGH22LOCXCKUZTBCH3SNXE7N2DB7SSUDN5I7GQWVCO5JRJRN4RJH56
static immutable AGH = KeyPair(PublicKey([192, 99, 235, 75, 112, 174, 37, 83, 51, 8, 143, 185, 54, 228, 251, 116, 48, 254, 82, 160, 219, 212, 124, 208, 181, 68, 238, 166, 41, 139, 121, 20]), SecretKey([104, 112, 167, 121, 149, 188, 127, 49, 133, 35, 41, 39, 111, 227, 239, 226, 32, 100, 26, 9, 195, 65, 39, 103, 171, 125, 67, 18, 236, 154, 167, 86]), Seed([31, 51, 96, 20, 34, 163, 89, 105, 153, 174, 170, 60, 205, 237, 127, 163, 194, 33, 57, 227, 162, 123, 72, 221, 197, 146, 31, 153, 3, 193, 116, 133]));
/// AGI: GDAGI223NZF3EOIH6AF5QE5AEODQ4F4EM2NJRKJRCP2HSXC4VKNTXUYO
static immutable AGI = KeyPair(PublicKey([192, 100, 107, 91, 110, 75, 178, 57, 7, 240, 11, 216, 19, 160, 35, 135, 14, 23, 132, 102, 154, 152, 169, 49, 19, 244, 121, 92, 92, 170, 155, 59]), SecretKey([152, 231, 188, 217, 167, 174, 202, 138, 65, 149, 17, 75, 81, 40, 32, 6, 90, 33, 193, 77, 189, 101, 106, 200, 67, 28, 255, 253, 202, 114, 156, 96]), Seed([202, 249, 220, 55, 79, 44, 176, 31, 166, 180, 14, 97, 64, 44, 199, 9, 186, 60, 153, 4, 175, 25, 198, 238, 189, 47, 201, 39, 97, 214, 220, 195]));
/// AGJ: GDAGJ22Y6A7BFBMZ47RTUZMD3WGFLFLJVWQUBRNTZBHNXTNETKK4LXTF
static immutable AGJ = KeyPair(PublicKey([192, 100, 235, 88, 240, 62, 18, 133, 153, 231, 227, 58, 101, 131, 221, 140, 85, 149, 105, 173, 161, 64, 197, 179, 200, 78, 219, 205, 164, 154, 149, 197]), SecretKey([224, 126, 34, 219, 248, 41, 185, 233, 6, 180, 165, 134, 158, 160, 150, 124, 237, 143, 218, 50, 116, 250, 186, 232, 150, 40, 172, 165, 2, 157, 45, 120]), Seed([220, 40, 218, 80, 9, 15, 209, 111, 159, 167, 199, 75, 195, 185, 140, 131, 100, 142, 26, 165, 132, 255, 198, 242, 79, 147, 41, 31, 36, 157, 91, 225]));
/// AGK: GDAGK224OGMK2M3GWDEVSSDEAFFYSKWDG3ZG5VMPVXYQUZYDMQQ6AOV7
static immutable AGK = KeyPair(PublicKey([192, 101, 107, 92, 113, 152, 173, 51, 102, 176, 201, 89, 72, 100, 1, 75, 137, 42, 195, 54, 242, 110, 213, 143, 173, 241, 10, 103, 3, 100, 33, 224]), SecretKey([80, 221, 68, 104, 46, 238, 104, 123, 4, 239, 216, 70, 156, 225, 15, 144, 229, 23, 142, 75, 142, 81, 161, 246, 123, 229, 47, 230, 28, 122, 204, 93]), Seed([185, 243, 224, 119, 189, 33, 37, 167, 148, 0, 217, 111, 1, 91, 158, 82, 60, 148, 225, 50, 63, 194, 43, 84, 18, 88, 204, 152, 12, 92, 21, 67]));
/// AGL: GDAGL22YH3CZAOYR3T4YCG5UDTZ6NNHKDSVZ334FKWXJAGFKHCDLEDWF
static immutable AGL = KeyPair(PublicKey([192, 101, 235, 88, 62, 197, 144, 59, 17, 220, 249, 129, 27, 180, 28, 243, 230, 180, 234, 28, 171, 157, 239, 133, 85, 174, 144, 24, 170, 56, 134, 178]), SecretKey([160, 188, 204, 145, 151, 71, 164, 50, 207, 68, 166, 226, 136, 162, 32, 124, 117, 98, 82, 82, 191, 121, 250, 42, 201, 180, 198, 225, 37, 182, 152, 84]), Seed([127, 202, 3, 208, 176, 204, 33, 247, 38, 42, 146, 104, 144, 214, 42, 234, 122, 213, 186, 122, 172, 101, 188, 188, 240, 171, 28, 231, 96, 121, 34, 102]));
/// AGM: GDAGM22NCJGHDXEGGJAHVQEIFBTKM42XU2SGXAEROV2VMPLFIR2PXWFB
static immutable AGM = KeyPair(PublicKey([192, 102, 107, 77, 18, 76, 113, 220, 134, 50, 64, 122, 192, 136, 40, 102, 166, 115, 87, 166, 164, 107, 128, 145, 117, 117, 86, 61, 101, 68, 116, 251]), SecretKey([0, 7, 251, 106, 144, 57, 101, 52, 54, 56, 33, 211, 3, 253, 237, 112, 234, 36, 117, 242, 60, 141, 33, 46, 168, 216, 255, 28, 145, 195, 236, 117]), Seed([235, 146, 231, 26, 215, 27, 128, 72, 123, 9, 179, 62, 108, 144, 217, 194, 110, 20, 138, 53, 174, 249, 161, 1, 47, 99, 27, 179, 79, 255, 96, 114]));
/// AGN: GDAGN22ACFGH5Q5Z7DBPUIAQBHYJKUUBWG73K2OOY4EEZ52WSS5NRPMA
static immutable AGN = KeyPair(PublicKey([192, 102, 235, 64, 17, 76, 126, 195, 185, 248, 194, 250, 32, 16, 9, 240, 149, 82, 129, 177, 191, 181, 105, 206, 199, 8, 76, 247, 86, 148, 186, 216]), SecretKey([232, 129, 46, 174, 43, 183, 47, 38, 124, 107, 62, 223, 216, 106, 204, 206, 168, 210, 152, 196, 241, 70, 55, 168, 84, 194, 229, 1, 180, 26, 100, 72]), Seed([13, 139, 78, 242, 222, 72, 229, 165, 175, 131, 61, 253, 15, 160, 197, 183, 208, 59, 243, 195, 159, 170, 216, 253, 181, 251, 108, 4, 60, 163, 212, 86]));
/// AGO: GDAGO22SX5D3YU4NK3OWJOH4MKVPXO4YRHWJ3CQWXX5VNUXMQ7IMPIQN
static immutable AGO = KeyPair(PublicKey([192, 103, 107, 82, 191, 71, 188, 83, 141, 86, 221, 100, 184, 252, 98, 170, 251, 187, 152, 137, 236, 157, 138, 22, 189, 251, 86, 210, 236, 135, 208, 199]), SecretKey([248, 251, 187, 32, 233, 201, 126, 151, 121, 205, 180, 187, 220, 152, 96, 145, 247, 62, 22, 225, 114, 90, 159, 168, 72, 171, 36, 89, 177, 89, 41, 117]), Seed([111, 29, 39, 187, 142, 56, 144, 82, 4, 190, 104, 165, 1, 204, 247, 7, 231, 211, 238, 250, 251, 34, 28, 199, 27, 227, 53, 239, 53, 63, 14, 242]));
/// AGP: GDAGP22WXBM6CKG7SBJXQX3Y3D3OPNK3K6FXH2SX5RJRPYNFF24U3YJC
static immutable AGP = KeyPair(PublicKey([192, 103, 235, 86, 184, 89, 225, 40, 223, 144, 83, 120, 95, 120, 216, 246, 231, 181, 91, 87, 139, 115, 234, 87, 236, 83, 23, 225, 165, 46, 185, 77]), SecretKey([184, 53, 207, 60, 197, 222, 153, 148, 154, 115, 23, 69, 47, 118, 184, 35, 26, 167, 242, 75, 242, 254, 206, 115, 91, 236, 177, 247, 124, 174, 177, 66]), Seed([26, 158, 130, 111, 199, 164, 1, 164, 135, 114, 28, 86, 139, 242, 173, 195, 96, 49, 51, 243, 225, 12, 185, 7, 31, 82, 151, 124, 137, 128, 74, 237]));
/// AGQ: GDAGQ22KJ5NK5OOPZF5RXDSSMGE3567WE55C7E76RPVRTULUFF55PZAQ
static immutable AGQ = KeyPair(PublicKey([192, 104, 107, 74, 79, 90, 174, 185, 207, 201, 123, 27, 142, 82, 97, 137, 190, 251, 246, 39, 122, 47, 147, 254, 139, 235, 25, 209, 116, 41, 123, 215]), SecretKey([200, 251, 169, 43, 59, 204, 48, 115, 244, 99, 214, 253, 13, 38, 195, 40, 150, 106, 226, 228, 59, 141, 85, 97, 176, 0, 22, 154, 69, 242, 146, 90]), Seed([18, 16, 223, 239, 146, 101, 101, 76, 213, 184, 199, 126, 162, 9, 181, 23, 136, 122, 77, 77, 83, 198, 95, 218, 114, 246, 21, 115, 165, 30, 93, 180]));
/// AGR: GDAGR22X4IWNEO6FHNY3PYUJDXPUCRCKPNGACETAUVGE3GAWVFPS7VUJ
static immutable AGR = KeyPair(PublicKey([192, 104, 235, 87, 226, 44, 210, 59, 197, 59, 113, 183, 226, 137, 29, 223, 65, 68, 74, 123, 76, 1, 18, 96, 165, 76, 77, 152, 22, 169, 95, 47]), SecretKey([24, 73, 44, 3, 28, 150, 2, 37, 242, 38, 48, 231, 213, 254, 65, 201, 218, 75, 77, 187, 0, 186, 80, 190, 87, 210, 234, 104, 75, 162, 177, 68]), Seed([79, 109, 49, 27, 224, 104, 178, 243, 222, 20, 36, 83, 243, 124, 38, 77, 216, 20, 208, 108, 14, 99, 109, 195, 3, 97, 202, 149, 78, 252, 40, 152]));
/// AGS: GDAGS22PVTFDZ3OAMNBNATVAG6NM4WRCQLWCZOX2MGOF6ZVTP4CSR62B
static immutable AGS = KeyPair(PublicKey([192, 105, 107, 79, 172, 202, 60, 237, 192, 99, 66, 208, 78, 160, 55, 154, 206, 90, 34, 130, 236, 44, 186, 250, 97, 156, 95, 102, 179, 127, 5, 40]), SecretKey([72, 180, 248, 76, 139, 50, 215, 202, 185, 194, 62, 229, 84, 132, 214, 69, 98, 77, 117, 47, 170, 0, 13, 62, 35, 101, 138, 126, 183, 216, 180, 71]), Seed([178, 57, 155, 211, 229, 189, 43, 118, 241, 10, 52, 38, 121, 132, 11, 207, 163, 120, 169, 216, 37, 124, 110, 206, 236, 78, 174, 239, 12, 18, 135, 149]));
/// AGT: GDAGT226PEZM2PPZTBL2PX7Z5IMNZU7GZPTYEO6OZXOSOPTKPDZT6KEH
static immutable AGT = KeyPair(PublicKey([192, 105, 235, 94, 121, 50, 205, 61, 249, 152, 87, 167, 223, 249, 234, 24, 220, 211, 230, 203, 231, 130, 59, 206, 205, 221, 39, 62, 106, 120, 243, 63]), SecretKey([0, 98, 110, 126, 199, 254, 148, 171, 98, 117, 131, 36, 186, 112, 192, 191, 255, 218, 95, 19, 45, 29, 191, 112, 114, 3, 120, 204, 183, 100, 33, 115]), Seed([224, 110, 35, 164, 114, 175, 251, 255, 244, 138, 47, 173, 195, 133, 3, 224, 215, 179, 185, 100, 106, 227, 45, 229, 253, 78, 59, 227, 200, 198, 36, 231]));
/// AGU: GDAGU22XAVP3C55ACZ6KQVHCPQ3RIVJKR2AMPXJ7WQRGLHLD5BZHDAX4
static immutable AGU = KeyPair(PublicKey([192, 106, 107, 87, 5, 95, 177, 119, 160, 22, 124, 168, 84, 226, 124, 55, 20, 85, 42, 142, 128, 199, 221, 63, 180, 34, 101, 157, 99, 232, 114, 113]), SecretKey([88, 240, 171, 38, 23, 109, 191, 27, 79, 111, 135, 58, 222, 82, 17, 14, 196, 117, 243, 160, 25, 156, 135, 169, 247, 63, 106, 216, 226, 223, 143, 75]), Seed([9, 3, 32, 129, 111, 192, 99, 13, 245, 34, 103, 81, 173, 224, 40, 176, 244, 83, 78, 134, 176, 33, 244, 103, 153, 232, 163, 112, 72, 122, 113, 71]));
/// AGV: GDAGV222FQXHVVNTOW4QTOC3TNKLB34MQG3E557WSQ5C2IN2HYTGO3Q3
static immutable AGV = KeyPair(PublicKey([192, 106, 235, 90, 44, 46, 122, 213, 179, 117, 185, 9, 184, 91, 155, 84, 176, 239, 140, 129, 182, 78, 247, 246, 148, 58, 45, 33, 186, 62, 38, 103]), SecretKey([128, 141, 115, 21, 155, 200, 14, 145, 69, 33, 31, 205, 224, 208, 149, 184, 172, 78, 22, 183, 140, 141, 74, 16, 114, 211, 229, 28, 156, 152, 95, 96]), Seed([75, 223, 144, 112, 248, 205, 158, 164, 135, 39, 74, 54, 165, 31, 40, 226, 200, 69, 213, 185, 25, 72, 46, 53, 34, 186, 253, 245, 227, 102, 153, 103]));
/// AGW: GDAGW22PLIYMV6LXXVJYZ55XAB73QZNVF23QW5CPLRA5L2ZMDP5JSQU5
static immutable AGW = KeyPair(PublicKey([192, 107, 107, 79, 90, 48, 202, 249, 119, 189, 83, 140, 247, 183, 0, 127, 184, 101, 181, 46, 183, 11, 116, 79, 92, 65, 213, 235, 44, 27, 250, 153]), SecretKey([224, 1, 108, 161, 100, 228, 70, 148, 26, 136, 34, 123, 158, 64, 47, 212, 72, 38, 177, 131, 187, 180, 92, 146, 221, 77, 247, 146, 115, 230, 108, 90]), Seed([97, 171, 88, 251, 121, 41, 72, 156, 133, 99, 13, 115, 196, 26, 251, 193, 133, 61, 35, 235, 30, 18, 243, 89, 81, 41, 171, 169, 93, 176, 79, 239]));
/// AGX: GDAGX22NRDJVCHPMPG5CXGFJTXLXBIGA2R6M2LM4EEFHHWWDXQKDZ5CY
static immutable AGX = KeyPair(PublicKey([192, 107, 235, 77, 136, 211, 81, 29, 236, 121, 186, 43, 152, 169, 157, 215, 112, 160, 192, 212, 124, 205, 45, 156, 33, 10, 115, 218, 195, 188, 20, 60]), SecretKey([248, 132, 120, 143, 97, 101, 124, 28, 239, 148, 49, 67, 1, 50, 119, 225, 134, 135, 9, 28, 181, 118, 203, 65, 5, 133, 138, 116, 156, 212, 101, 121]), Seed([23, 14, 172, 210, 245, 41, 19, 225, 115, 238, 49, 196, 117, 198, 157, 51, 110, 114, 163, 221, 233, 253, 106, 91, 149, 249, 43, 74, 214, 4, 179, 7]));
/// AGY: GDAGY22CZRBOVCM3KH3O4ZQV3AFBIOL7R2L4BKKSBP7QH2P76KSVZIOE
static immutable AGY = KeyPair(PublicKey([192, 108, 107, 66, 204, 66, 234, 137, 155, 81, 246, 238, 102, 21, 216, 10, 20, 57, 127, 142, 151, 192, 169, 82, 11, 255, 3, 233, 255, 242, 165, 92]), SecretKey([144, 61, 27, 119, 154, 94, 230, 38, 238, 90, 253, 244, 63, 197, 126, 114, 146, 179, 212, 9, 233, 166, 23, 121, 84, 52, 177, 113, 247, 43, 147, 94]), Seed([157, 146, 32, 33, 46, 167, 210, 166, 73, 35, 196, 221, 91, 25, 13, 93, 10, 7, 3, 188, 240, 64, 252, 196, 31, 213, 151, 2, 111, 64, 35, 237]));
/// AGZ: GDAGZ22UUDZGIVAE5H6VUPSXFBKU7EJU3ICW7RH3JZDIMCIRZ6DNFKAV
static immutable AGZ = KeyPair(PublicKey([192, 108, 235, 84, 160, 242, 100, 84, 4, 233, 253, 90, 62, 87, 40, 85, 79, 145, 52, 218, 5, 111, 196, 251, 78, 70, 134, 9, 17, 207, 134, 210]), SecretKey([88, 34, 224, 194, 165, 178, 135, 194, 177, 106, 152, 119, 66, 235, 35, 160, 10, 87, 208, 235, 61, 218, 86, 20, 53, 8, 16, 84, 11, 207, 84, 116]), Seed([233, 196, 79, 58, 218, 11, 190, 165, 116, 201, 29, 70, 127, 249, 203, 80, 31, 170, 236, 95, 148, 168, 60, 241, 100, 144, 162, 225, 94, 116, 197, 74]));
/// AHA: GDAHA22WGAXRFJJ3OZXEBNCN2SRR37KMDR3JYQMCFTBCIZ2V3XQUSW6R
static immutable AHA = KeyPair(PublicKey([192, 112, 107, 86, 48, 47, 18, 165, 59, 118, 110, 64, 180, 77, 212, 163, 29, 253, 76, 28, 118, 156, 65, 130, 44, 194, 36, 103, 85, 221, 225, 73]), SecretKey([16, 36, 14, 25, 215, 85, 153, 246, 32, 7, 209, 110, 71, 209, 11, 208, 108, 113, 247, 58, 18, 122, 2, 52, 148, 53, 173, 140, 223, 19, 145, 119]), Seed([8, 176, 215, 146, 235, 189, 124, 69, 168, 82, 68, 85, 228, 55, 121, 230, 166, 75, 177, 85, 182, 7, 255, 173, 10, 124, 1, 195, 166, 63, 18, 24]));
/// AHB: GDAHB22WBRNVUWYCWVDGQAVEXUAGQTKKG6BC7UPWWN332MPFQKFQFMA3
static immutable AHB = KeyPair(PublicKey([192, 112, 235, 86, 12, 91, 90, 91, 2, 181, 70, 104, 2, 164, 189, 0, 104, 77, 74, 55, 130, 47, 209, 246, 179, 119, 189, 49, 229, 130, 139, 2]), SecretKey([48, 229, 26, 121, 152, 197, 93, 50, 175, 41, 145, 151, 187, 93, 244, 22, 65, 10, 77, 53, 103, 187, 35, 119, 104, 177, 134, 163, 111, 43, 143, 102]), Seed([134, 125, 63, 158, 27, 32, 143, 8, 38, 187, 172, 103, 145, 216, 36, 154, 34, 3, 205, 101, 201, 197, 17, 227, 8, 11, 64, 82, 225, 165, 233, 108]));
/// AHC: GDAHC22NFTRL7GWQGMWP3SPUF7NQFX6M2DXMUO4GIMNBND53ELMEHEDK
static immutable AHC = KeyPair(PublicKey([192, 113, 107, 77, 44, 226, 191, 154, 208, 51, 44, 253, 201, 244, 47, 219, 2, 223, 204, 208, 238, 202, 59, 134, 67, 26, 22, 143, 187, 34, 216, 67]), SecretKey([136, 56, 209, 2, 78, 11, 188, 164, 225, 31, 195, 222, 135, 189, 158, 133, 184, 228, 132, 42, 46, 59, 94, 154, 130, 207, 232, 220, 72, 76, 132, 117]), Seed([120, 113, 226, 250, 201, 96, 223, 108, 153, 114, 66, 224, 171, 124, 136, 84, 50, 9, 133, 117, 223, 87, 231, 191, 53, 125, 240, 168, 86, 239, 210, 177]));
/// AHD: GDAHD22J7S4WTYDTDQE3EG3SG4GZPFW7AP3ZQLLISLR4ROYY3KZTMGWR
static immutable AHD = KeyPair(PublicKey([192, 113, 235, 73, 252, 185, 105, 224, 115, 28, 9, 178, 27, 114, 55, 13, 151, 150, 223, 3, 247, 152, 45, 104, 146, 227, 200, 187, 24, 218, 179, 54]), SecretKey([128, 171, 130, 249, 159, 248, 161, 198, 35, 166, 145, 83, 144, 97, 188, 56, 194, 164, 199, 5, 8, 94, 68, 225, 36, 203, 125, 197, 245, 197, 176, 103]), Seed([96, 101, 94, 153, 182, 209, 51, 19, 231, 141, 158, 21, 178, 214, 69, 24, 150, 175, 95, 200, 111, 237, 88, 111, 176, 48, 136, 90, 92, 237, 105, 240]));
/// AHE: GDAHE22KQE46DIBFQW2AXGODYUWOSPL4G7CM35WBND7Y5IHXPSTF3H4G
static immutable AHE = KeyPair(PublicKey([192, 114, 107, 74, 129, 57, 225, 160, 37, 133, 180, 11, 153, 195, 197, 44, 233, 61, 124, 55, 196, 205, 246, 193, 104, 255, 142, 160, 247, 124, 166, 93]), SecretKey([32, 33, 11, 250, 197, 157, 195, 206, 232, 208, 125, 197, 0, 199, 153, 37, 34, 104, 78, 127, 27, 253, 171, 250, 162, 199, 204, 67, 220, 19, 120, 85]), Seed([183, 146, 11, 253, 143, 32, 137, 54, 58, 188, 63, 219, 116, 116, 122, 16, 98, 102, 101, 102, 138, 186, 44, 119, 112, 103, 86, 234, 159, 193, 50, 167]));
/// AHF: GDAHF22J26ERAXIX4U6WSUSEQH4OLDQJN5EDM6WSGCCIJHO3OKLE2AIG
static immutable AHF = KeyPair(PublicKey([192, 114, 235, 73, 215, 137, 16, 93, 23, 229, 61, 105, 82, 68, 129, 248, 229, 142, 9, 111, 72, 54, 122, 210, 48, 132, 132, 157, 219, 114, 150, 77]), SecretKey([200, 202, 42, 220, 193, 85, 197, 111, 239, 81, 164, 12, 221, 22, 139, 127, 57, 34, 147, 31, 151, 92, 88, 154, 216, 201, 202, 40, 1, 190, 103, 83]), Seed([85, 247, 77, 188, 136, 247, 3, 252, 39, 195, 153, 167, 144, 173, 153, 216, 86, 189, 125, 249, 248, 6, 30, 79, 174, 16, 120, 120, 210, 147, 255, 248]));
/// AHG: GDAHG22MLLHHP2HXCCML5Z5TMDCKUCPMTXS5N7DUOBDZ57FVQPTZOXOC
static immutable AHG = KeyPair(PublicKey([192, 115, 107, 76, 90, 206, 119, 232, 247, 16, 152, 190, 231, 179, 96, 196, 170, 9, 236, 157, 229, 214, 252, 116, 112, 71, 158, 252, 181, 131, 231, 151]), SecretKey([88, 161, 56, 191, 175, 61, 224, 55, 186, 166, 252, 169, 38, 77, 135, 232, 84, 177, 192, 103, 50, 46, 137, 220, 69, 19, 245, 199, 161, 133, 222, 108]), Seed([178, 219, 237, 164, 240, 113, 182, 158, 128, 136, 107, 76, 188, 172, 237, 151, 79, 224, 117, 255, 10, 46, 98, 2, 128, 1, 246, 172, 197, 48, 15, 181]));
/// AHH: GDAHH22XHMA3AILVVRYZLWU6RP3WINI6Y2MAEOO3URGDXN4EF4JXHGFC
static immutable AHH = KeyPair(PublicKey([192, 115, 235, 87, 59, 1, 176, 33, 117, 172, 113, 149, 218, 158, 139, 247, 100, 53, 30, 198, 152, 2, 57, 219, 164, 76, 59, 183, 132, 47, 19, 115]), SecretKey([224, 63, 220, 73, 160, 70, 160, 157, 220, 142, 107, 112, 98, 115, 178, 51, 253, 11, 15, 112, 233, 14, 3, 57, 118, 57, 47, 19, 125, 144, 203, 121]), Seed([9, 48, 18, 30, 242, 53, 124, 54, 182, 89, 188, 63, 5, 81, 222, 253, 27, 66, 48, 141, 107, 56, 169, 183, 96, 105, 182, 177, 205, 130, 103, 203]));
/// AHI: GDAHI224Z4I2452OZDJMXNGXF2EKAIQMGQXEZRFL5F66EYADQ6S2BLX2
static immutable AHI = KeyPair(PublicKey([192, 116, 107, 92, 207, 17, 174, 119, 78, 200, 210, 203, 180, 215, 46, 136, 160, 34, 12, 52, 46, 76, 196, 171, 233, 125, 226, 96, 3, 135, 165, 160]), SecretKey([152, 60, 52, 238, 120, 37, 171, 146, 131, 84, 68, 15, 18, 54, 20, 91, 187, 20, 153, 193, 132, 165, 234, 17, 6, 238, 102, 178, 90, 16, 109, 94]), Seed([137, 74, 19, 157, 2, 25, 235, 22, 19, 139, 23, 209, 171, 106, 72, 107, 0, 176, 147, 0, 199, 8, 203, 201, 220, 213, 141, 175, 156, 206, 149, 165]));
/// AHJ: GDAHJ22EQB3TY62Y7BPLG2YQON7LQXD3WYMLAY36HYBYFRFUMVGCFVFN
static immutable AHJ = KeyPair(PublicKey([192, 116, 235, 68, 128, 119, 60, 123, 88, 248, 94, 179, 107, 16, 115, 126, 184, 92, 123, 182, 24, 176, 99, 126, 62, 3, 130, 196, 180, 101, 76, 34]), SecretKey([192, 212, 15, 52, 45, 174, 236, 30, 34, 196, 136, 252, 210, 207, 165, 78, 166, 73, 182, 109, 81, 107, 194, 134, 25, 202, 222, 211, 109, 99, 242, 102]), Seed([52, 209, 238, 28, 18, 132, 58, 223, 21, 204, 103, 137, 225, 192, 14, 174, 160, 218, 41, 197, 210, 163, 102, 199, 48, 65, 198, 127, 3, 45, 221, 126]));
/// AHK: GDAHK22JOW3DB3NYGWLPTDLJQPG7SJGQWRQTWTQO2OR6VXVU3TUXUDSD
static immutable AHK = KeyPair(PublicKey([192, 117, 107, 73, 117, 182, 48, 237, 184, 53, 150, 249, 141, 105, 131, 205, 249, 36, 208, 180, 97, 59, 78, 14, 211, 163, 234, 222, 180, 220, 233, 122]), SecretKey([32, 15, 68, 81, 138, 25, 213, 2, 136, 182, 104, 11, 1, 25, 99, 140, 42, 211, 140, 96, 42, 46, 180, 134, 31, 176, 10, 42, 2, 182, 78, 77]), Seed([197, 66, 160, 79, 110, 115, 78, 140, 2, 245, 6, 150, 75, 104, 2, 241, 217, 65, 61, 111, 21, 41, 145, 13, 113, 72, 192, 182, 157, 229, 200, 169]));
/// AHL: GDAHL22BJYV2MV4VCNTJRQNOVA4H3WKPPPZR2MSQBUISFJ6XSKBOFFML
static immutable AHL = KeyPair(PublicKey([192, 117, 235, 65, 78, 43, 166, 87, 149, 19, 102, 152, 193, 174, 168, 56, 125, 217, 79, 123, 243, 29, 50, 80, 13, 17, 34, 167, 215, 146, 130, 226]), SecretKey([240, 3, 46, 230, 62, 2, 250, 121, 183, 207, 10, 4, 248, 54, 180, 252, 216, 189, 212, 94, 50, 158, 250, 114, 25, 2, 149, 184, 168, 199, 223, 80]), Seed([46, 210, 41, 84, 225, 248, 238, 165, 194, 3, 186, 190, 241, 235, 204, 111, 153, 138, 21, 21, 48, 57, 228, 35, 130, 3, 42, 73, 214, 64, 142, 50]));
/// AHM: GDAHM22HTHCPPAHMMSFKGMSFTZW5BHFGOKLFLCWSSREXUK2A527CGYHA
static immutable AHM = KeyPair(PublicKey([192, 118, 107, 71, 153, 196, 247, 128, 236, 100, 138, 163, 50, 69, 158, 109, 208, 156, 166, 114, 150, 85, 138, 210, 148, 73, 122, 43, 64, 238, 190, 35]), SecretKey([80, 73, 191, 252, 112, 220, 91, 120, 250, 99, 155, 59, 36, 94, 61, 242, 44, 31, 34, 214, 147, 76, 75, 88, 159, 183, 217, 125, 100, 57, 135, 122]), Seed([36, 202, 26, 77, 134, 51, 203, 164, 234, 28, 185, 96, 159, 193, 67, 6, 171, 198, 198, 78, 108, 252, 205, 198, 23, 12, 65, 17, 167, 10, 16, 153]));
/// AHN: GDAHN22UNSTENHZ3KG3BWPG7I2JAAAU6ECQHX5CD3BID4N3G5KZAEXTW
static immutable AHN = KeyPair(PublicKey([192, 118, 235, 84, 108, 166, 70, 159, 59, 81, 182, 27, 60, 223, 70, 146, 0, 2, 158, 32, 160, 123, 244, 67, 216, 80, 62, 55, 102, 234, 178, 2]), SecretKey([192, 117, 182, 34, 200, 173, 169, 22, 217, 160, 31, 117, 149, 16, 133, 33, 79, 199, 165, 151, 187, 69, 212, 230, 16, 236, 252, 112, 46, 105, 216, 70]), Seed([52, 134, 96, 68, 208, 120, 148, 66, 171, 24, 134, 154, 25, 198, 124, 199, 89, 142, 103, 223, 93, 223, 161, 30, 209, 104, 16, 17, 230, 108, 23, 88]));
/// AHO: GDAHO225X4G4NMVRLXO6BS5ZU7TQSYX74Y3CVUORRDOMMIC3BLRD5J52
static immutable AHO = KeyPair(PublicKey([192, 119, 107, 93, 191, 13, 198, 178, 177, 93, 221, 224, 203, 185, 167, 231, 9, 98, 255, 230, 54, 42, 209, 209, 136, 220, 198, 32, 91, 10, 226, 62]), SecretKey([176, 150, 161, 97, 136, 144, 173, 196, 222, 39, 6, 53, 209, 67, 79, 186, 67, 171, 221, 20, 207, 19, 113, 145, 230, 199, 217, 139, 84, 20, 105, 101]), Seed([178, 250, 188, 154, 199, 25, 113, 33, 104, 22, 158, 142, 10, 179, 206, 171, 154, 239, 97, 198, 35, 206, 254, 251, 249, 33, 165, 36, 180, 211, 76, 14]));
/// AHP: GDAHP22JB7GKD5D6DR42VNVYFSXCHJ2BAGYG65JV5B3MLHJ3I2DIOVT6
static immutable AHP = KeyPair(PublicKey([192, 119, 235, 73, 15, 204, 161, 244, 126, 28, 121, 170, 182, 184, 44, 174, 35, 167, 65, 1, 176, 111, 117, 53, 232, 118, 197, 157, 59, 70, 134, 135]), SecretKey([104, 37, 144, 24, 218, 110, 141, 152, 188, 129, 181, 228, 91, 19, 162, 208, 21, 204, 44, 168, 207, 218, 208, 33, 50, 229, 217, 178, 96, 185, 243, 91]), Seed([66, 213, 80, 180, 40, 93, 186, 151, 215, 107, 77, 39, 26, 171, 168, 230, 93, 51, 146, 132, 236, 84, 153, 50, 65, 155, 95, 248, 181, 202, 104, 197]));
/// AHQ: GDAHQ22S7JE7VII4XLODXLASLO6ZJTR5ODBHX7K6JRY4YS5SGTXPRFHV
static immutable AHQ = KeyPair(PublicKey([192, 120, 107, 82, 250, 73, 250, 161, 28, 186, 220, 59, 172, 18, 91, 189, 148, 206, 61, 112, 194, 123, 253, 94, 76, 113, 204, 75, 178, 52, 238, 248]), SecretKey([240, 243, 10, 94, 56, 121, 26, 110, 220, 189, 60, 211, 203, 59, 121, 18, 165, 71, 52, 196, 69, 45, 142, 18, 125, 227, 84, 27, 122, 88, 209, 109]), Seed([164, 100, 64, 126, 88, 9, 36, 8, 3, 109, 129, 71, 77, 56, 236, 71, 201, 255, 83, 91, 34, 246, 189, 245, 225, 67, 238, 253, 75, 104, 172, 129]));
/// AHR: GDAHR22CI4IHN7P45NXW2P7RNPGZOUI2RLPAYUSXBLCQOQ6PIKR3KLLS
static immutable AHR = KeyPair(PublicKey([192, 120, 235, 66, 71, 16, 118, 253, 252, 235, 111, 109, 63, 241, 107, 205, 151, 81, 26, 138, 222, 12, 82, 87, 10, 197, 7, 67, 207, 66, 163, 181]), SecretKey([192, 120, 85, 41, 229, 124, 153, 125, 175, 35, 150, 121, 109, 105, 62, 186, 252, 49, 143, 102, 41, 56, 140, 152, 120, 77, 47, 96, 86, 10, 103, 84]), Seed([254, 139, 118, 33, 236, 221, 182, 162, 233, 71, 193, 190, 113, 207, 183, 57, 151, 182, 200, 213, 255, 46, 92, 224, 11, 212, 196, 137, 72, 160, 172, 72]));
/// AHS: GDAHS22QVYZLMJGGDBOHEQM2Q5L5RKFM35FCLVXDMUYGANWTUSJ5RJWA
static immutable AHS = KeyPair(PublicKey([192, 121, 107, 80, 174, 50, 182, 36, 198, 24, 92, 114, 65, 154, 135, 87, 216, 168, 172, 223, 74, 37, 214, 227, 101, 48, 96, 54, 211, 164, 147, 216]), SecretKey([136, 134, 231, 43, 115, 113, 136, 41, 24, 240, 103, 145, 87, 21, 114, 137, 8, 31, 76, 209, 212, 9, 232, 164, 14, 236, 204, 216, 2, 196, 44, 120]), Seed([166, 192, 110, 19, 201, 177, 79, 136, 147, 77, 205, 197, 83, 62, 194, 148, 43, 222, 140, 10, 10, 251, 11, 7, 49, 196, 167, 239, 0, 93, 42, 29]));
/// AHT: GDAHT22LI23CWUB4KTEDEUQP43ZZC3AIS2CKENFL2LXYG22GZIWUGJHO
static immutable AHT = KeyPair(PublicKey([192, 121, 235, 75, 70, 182, 43, 80, 60, 84, 200, 50, 82, 15, 230, 243, 145, 108, 8, 150, 132, 162, 52, 171, 210, 239, 131, 107, 70, 202, 45, 67]), SecretKey([232, 74, 67, 120, 142, 224, 52, 129, 54, 46, 86, 11, 211, 26, 86, 196, 141, 64, 85, 14, 23, 60, 241, 11, 98, 41, 103, 82, 230, 142, 130, 83]), Seed([91, 78, 172, 92, 183, 185, 34, 162, 141, 204, 100, 193, 151, 90, 127, 104, 156, 174, 135, 50, 13, 220, 190, 222, 106, 122, 208, 4, 105, 171, 7, 186]));
/// AHU: GDAHU22SXA4FSQR65IKNIW4FUPB6W4LDPNBRYR7GJ46OX3PSER4J342L
static immutable AHU = KeyPair(PublicKey([192, 122, 107, 82, 184, 56, 89, 66, 62, 234, 20, 212, 91, 133, 163, 195, 235, 113, 99, 123, 67, 28, 71, 230, 79, 60, 235, 237, 242, 36, 120, 157]), SecretKey([224, 3, 66, 135, 188, 50, 237, 157, 7, 65, 17, 54, 76, 16, 174, 82, 18, 29, 109, 142, 151, 240, 35, 37, 10, 54, 115, 15, 204, 237, 106, 106]), Seed([27, 65, 228, 202, 216, 71, 118, 23, 30, 182, 164, 63, 116, 31, 62, 71, 45, 250, 207, 214, 196, 174, 43, 189, 86, 59, 120, 1, 246, 133, 238, 63]));
/// AHV: GDAHV226W4SYP3AJTNWI3WAGUKISMJUW5D4XAP4D3IXRI7KIWXEXJIUD
static immutable AHV = KeyPair(PublicKey([192, 122, 235, 94, 183, 37, 135, 236, 9, 155, 108, 141, 216, 6, 162, 145, 38, 38, 150, 232, 249, 112, 63, 131, 218, 47, 20, 125, 72, 181, 201, 116]), SecretKey([128, 143, 11, 209, 216, 144, 132, 72, 26, 28, 4, 183, 124, 199, 15, 61, 182, 166, 10, 94, 15, 98, 190, 57, 35, 201, 33, 211, 120, 12, 45, 126]), Seed([35, 134, 233, 139, 172, 149, 55, 103, 233, 229, 112, 222, 79, 98, 25, 175, 205, 73, 164, 24, 117, 114, 216, 146, 192, 19, 55, 20, 252, 88, 213, 239]));
/// AHW: GDAHW22E7QXX3ISHV4NC7OWP6ZOBJR5DRPI74OJH4QXCKO2I3VMF5BTL
static immutable AHW = KeyPair(PublicKey([192, 123, 107, 68, 252, 47, 125, 162, 71, 175, 26, 47, 186, 207, 246, 92, 20, 199, 163, 139, 209, 254, 57, 39, 228, 46, 37, 59, 72, 221, 88, 94]), SecretKey([120, 101, 126, 160, 210, 167, 176, 92, 108, 25, 64, 203, 131, 34, 252, 148, 208, 70, 144, 99, 104, 107, 44, 212, 144, 60, 244, 177, 185, 71, 200, 126]), Seed([62, 192, 125, 240, 128, 19, 178, 78, 182, 186, 66, 3, 34, 25, 124, 107, 200, 146, 170, 180, 79, 174, 152, 211, 132, 218, 189, 231, 156, 43, 60, 232]));
/// AHX: GDAHX22OYYT2CCB64OAEMBCU7ZE4QNMYJ2ASRBBVZTKTXQF5QCLMZPJG
static immutable AHX = KeyPair(PublicKey([192, 123, 235, 78, 198, 39, 161, 8, 62, 227, 128, 70, 4, 84, 254, 73, 200, 53, 152, 78, 129, 40, 132, 53, 204, 213, 59, 192, 189, 128, 150, 204]), SecretKey([96, 66, 142, 154, 154, 9, 87, 102, 140, 72, 17, 172, 213, 163, 163, 68, 139, 186, 193, 33, 154, 8, 110, 33, 70, 40, 214, 77, 57, 166, 141, 79]), Seed([17, 26, 243, 58, 65, 242, 251, 44, 71, 218, 80, 159, 101, 135, 35, 211, 229, 227, 154, 175, 237, 239, 221, 0, 6, 244, 104, 88, 229, 156, 127, 225]));
/// AHY: GDAHY22EYOFN3MSKLLDL5CRVOXAAA6ZICX7QHGBOEDXM3XQDVG6SYRUZ
static immutable AHY = KeyPair(PublicKey([192, 124, 107, 68, 195, 138, 221, 178, 74, 90, 198, 190, 138, 53, 117, 192, 0, 123, 40, 21, 255, 3, 152, 46, 32, 238, 205, 222, 3, 169, 189, 44]), SecretKey([232, 103, 102, 28, 24, 42, 72, 2, 249, 48, 208, 3, 158, 244, 198, 253, 247, 214, 225, 66, 119, 28, 237, 230, 86, 251, 139, 224, 26, 160, 78, 81]), Seed([88, 16, 164, 24, 48, 230, 73, 120, 236, 33, 120, 104, 54, 61, 191, 6, 252, 58, 171, 56, 74, 199, 130, 24, 213, 206, 13, 53, 121, 76, 153, 77]));
/// AHZ: GDAHZ222HQGPWIOEYNKAVMW6RZENEOTGMF64DX6A73IJ63IUUGLZDRPG
static immutable AHZ = KeyPair(PublicKey([192, 124, 235, 90, 60, 12, 251, 33, 196, 195, 84, 10, 178, 222, 142, 72, 210, 58, 102, 97, 125, 193, 223, 192, 254, 208, 159, 109, 20, 161, 151, 145]), SecretKey([240, 63, 7, 26, 12, 59, 206, 35, 93, 115, 3, 31, 26, 2, 222, 41, 50, 85, 58, 57, 226, 221, 212, 120, 230, 51, 212, 136, 57, 150, 161, 125]), Seed([64, 104, 30, 16, 149, 247, 16, 150, 57, 196, 48, 171, 116, 2, 124, 39, 140, 187, 112, 105, 215, 28, 26, 234, 53, 73, 99, 70, 155, 152, 91, 219]));
/// AIA: GDAIA22L52LOTMWAU3IPEEXFXFA7JYEOSSF3IB4DPVHDGDKPMB224I2G
static immutable AIA = KeyPair(PublicKey([192, 128, 107, 75, 238, 150, 233, 178, 192, 166, 208, 242, 18, 229, 185, 65, 244, 224, 142, 148, 139, 180, 7, 131, 125, 78, 51, 13, 79, 96, 117, 174]), SecretKey([216, 242, 93, 248, 199, 202, 18, 131, 5, 70, 159, 157, 244, 111, 231, 221, 3, 93, 229, 54, 146, 166, 37, 115, 232, 197, 174, 115, 247, 49, 232, 120]), Seed([100, 231, 52, 135, 59, 27, 83, 229, 165, 172, 245, 24, 42, 116, 183, 115, 64, 183, 157, 36, 235, 27, 169, 201, 148, 191, 183, 28, 168, 37, 168, 241]));
/// AIB: GDAIB2242TQUT6ZK3GP6XETUV73OLV4HPZ475NBBWKNLZLUEJWZJNH7Y
static immutable AIB = KeyPair(PublicKey([192, 128, 235, 92, 212, 225, 73, 251, 42, 217, 159, 235, 146, 116, 175, 246, 229, 215, 135, 126, 121, 254, 180, 33, 178, 154, 188, 174, 132, 77, 178, 150]), SecretKey([128, 204, 164, 155, 51, 252, 127, 49, 4, 25, 150, 138, 161, 121, 76, 67, 185, 146, 150, 102, 144, 252, 91, 226, 54, 96, 55, 1, 214, 213, 19, 105]), Seed([92, 145, 180, 64, 206, 190, 141, 150, 213, 126, 126, 178, 254, 58, 22, 65, 200, 184, 108, 55, 14, 9, 204, 48, 146, 213, 181, 229, 193, 219, 60, 94]));
/// AIC: GDAIC22P2M5AF5M2JBUUC6HBMKCZ46ZOFRNEE23FR32M6DUUXRNOXHLP
static immutable AIC = KeyPair(PublicKey([192, 129, 107, 79, 211, 58, 2, 245, 154, 72, 105, 65, 120, 225, 98, 133, 158, 123, 46, 44, 90, 66, 107, 101, 142, 244, 207, 14, 148, 188, 90, 235]), SecretKey([176, 45, 31, 142, 173, 254, 76, 44, 50, 2, 90, 183, 252, 40, 188, 205, 191, 37, 74, 247, 253, 76, 216, 128, 241, 228, 251, 44, 242, 212, 6, 95]), Seed([251, 144, 66, 177, 138, 81, 113, 64, 185, 124, 71, 33, 204, 12, 84, 220, 29, 64, 11, 74, 27, 129, 76, 205, 139, 77, 96, 248, 5, 122, 15, 23]));
/// AID: GDAID22H2X7EJC65HYS3KKTRCSCG5XRJSWZ3E7BESJKS22CCTULFPBJ7
static immutable AID = KeyPair(PublicKey([192, 129, 235, 71, 213, 254, 68, 139, 221, 62, 37, 181, 42, 113, 20, 132, 110, 222, 41, 149, 179, 178, 124, 36, 146, 85, 45, 104, 66, 157, 22, 87]), SecretKey([160, 240, 249, 156, 190, 54, 249, 164, 136, 212, 255, 39, 91, 146, 68, 193, 132, 224, 113, 227, 41, 61, 179, 140, 214, 52, 219, 6, 244, 49, 188, 95]), Seed([202, 22, 210, 107, 72, 194, 132, 217, 208, 98, 156, 82, 85, 93, 211, 36, 170, 4, 169, 209, 78, 134, 210, 135, 98, 250, 183, 242, 70, 207, 152, 173]));
/// AIE: GDAIE22NMR2QA6KL3NAT6ST6PPKXL7HASI3WKUPRDSS5IT5FCMXPD3XH
static immutable AIE = KeyPair(PublicKey([192, 130, 107, 77, 100, 117, 0, 121, 75, 219, 65, 63, 74, 126, 123, 213, 117, 252, 224, 146, 55, 101, 81, 241, 28, 165, 212, 79, 165, 19, 46, 241]), SecretKey([48, 140, 144, 242, 109, 83, 152, 150, 96, 167, 148, 171, 17, 26, 161, 139, 41, 245, 226, 50, 175, 176, 218, 21, 132, 232, 55, 172, 8, 30, 211, 67]), Seed([130, 104, 214, 70, 29, 36, 3, 88, 188, 19, 205, 234, 104, 198, 123, 198, 154, 189, 34, 16, 218, 108, 20, 196, 168, 92, 200, 12, 210, 165, 202, 7]));
/// AIF: GDAIF22W3GTY5XUC4PPBASS6P2GCBVS6UT4HSCDRG4RZDDDT3VPAU4AB
static immutable AIF = KeyPair(PublicKey([192, 130, 235, 86, 217, 167, 142, 222, 130, 227, 222, 16, 74, 94, 126, 140, 32, 214, 94, 164, 248, 121, 8, 113, 55, 35, 145, 140, 115, 221, 94, 10]), SecretKey([96, 56, 152, 68, 133, 44, 68, 106, 7, 9, 255, 128, 14, 191, 19, 205, 166, 193, 135, 22, 157, 244, 56, 95, 160, 252, 186, 136, 33, 131, 188, 107]), Seed([33, 22, 92, 62, 199, 230, 232, 35, 42, 251, 153, 150, 169, 107, 226, 32, 141, 188, 120, 29, 46, 63, 169, 193, 82, 216, 10, 191, 106, 64, 119, 154]));
/// AIG: GDAIG22B3ENWK4LK7PBGFH3554VSWNPRLFPDE2AAMJKWFOY3MIYM5QO3
static immutable AIG = KeyPair(PublicKey([192, 131, 107, 65, 217, 27, 101, 113, 106, 251, 194, 98, 159, 125, 239, 43, 43, 53, 241, 89, 94, 50, 104, 0, 98, 85, 98, 187, 27, 98, 48, 206]), SecretKey([208, 212, 135, 65, 108, 250, 174, 94, 111, 118, 243, 201, 177, 239, 78, 12, 223, 160, 190, 189, 161, 26, 98, 253, 91, 11, 254, 23, 192, 234, 109, 68]), Seed([145, 9, 165, 47, 227, 56, 26, 10, 158, 116, 49, 142, 224, 110, 252, 192, 7, 64, 125, 102, 62, 107, 226, 72, 8, 215, 46, 86, 209, 51, 46, 58]));
/// AIH: GDAIH22GSKBMVPKRWP4ZTF7O4MBWF36JQ4VW3NSAW4LTDHEKVTNJ7IBK
static immutable AIH = KeyPair(PublicKey([192, 131, 235, 70, 146, 130, 202, 189, 81, 179, 249, 153, 151, 238, 227, 3, 98, 239, 201, 135, 43, 109, 182, 64, 183, 23, 49, 156, 138, 172, 218, 159]), SecretKey([8, 224, 12, 119, 31, 200, 223, 213, 208, 131, 166, 89, 78, 186, 142, 196, 168, 112, 73, 178, 202, 252, 15, 188, 71, 187, 92, 148, 49, 207, 99, 81]), Seed([113, 195, 127, 190, 2, 4, 102, 28, 45, 16, 146, 146, 41, 54, 26, 123, 36, 171, 107, 140, 111, 102, 170, 44, 17, 120, 187, 54, 82, 195, 94, 86]));
/// AII: GDAII22ELZ4VBUPOCENZGOH6LDPYQ45EFKLERBIJ6DVN6GHXBAXIGXTZ
static immutable AII = KeyPair(PublicKey([192, 132, 107, 68, 94, 121, 80, 209, 238, 17, 27, 147, 56, 254, 88, 223, 136, 115, 164, 42, 150, 72, 133, 9, 240, 234, 223, 24, 247, 8, 46, 131]), SecretKey([56, 196, 134, 168, 201, 121, 252, 109, 41, 166, 84, 110, 46, 70, 2, 49, 237, 142, 57, 77, 195, 142, 93, 20, 165, 200, 88, 19, 243, 240, 71, 105]), Seed([165, 138, 148, 229, 234, 45, 66, 232, 33, 88, 232, 70, 129, 14, 50, 7, 137, 8, 46, 129, 200, 197, 243, 211, 32, 209, 63, 217, 122, 218, 174, 217]));
/// AIJ: GDAIJ22B6AULJQ5QUJGAJLC6SDFO42YAQ2AROXFZBG5UCFJSTBW6IX4Z
static immutable AIJ = KeyPair(PublicKey([192, 132, 235, 65, 240, 40, 180, 195, 176, 162, 76, 4, 172, 94, 144, 202, 238, 107, 0, 134, 129, 23, 92, 185, 9, 187, 65, 21, 50, 152, 109, 228]), SecretKey([56, 128, 104, 161, 227, 135, 154, 41, 118, 123, 29, 20, 165, 187, 232, 254, 89, 86, 62, 112, 45, 225, 154, 202, 228, 4, 175, 164, 181, 16, 61, 113]), Seed([188, 60, 190, 48, 95, 173, 194, 242, 135, 92, 167, 120, 193, 161, 175, 81, 115, 177, 222, 251, 46, 176, 56, 99, 90, 239, 247, 57, 243, 215, 59, 114]));
/// AIK: GDAIK22UTHXQ5I66GOA4QZ2ZL2EX3HITFATLQSEQICYANETBTLM7Z7ZP
static immutable AIK = KeyPair(PublicKey([192, 133, 107, 84, 153, 239, 14, 163, 222, 51, 129, 200, 103, 89, 94, 137, 125, 157, 19, 40, 38, 184, 72, 144, 64, 176, 6, 146, 97, 154, 217, 252]), SecretKey([0, 5, 112, 95, 111, 171, 191, 243, 106, 169, 163, 138, 172, 254, 121, 212, 235, 66, 7, 219, 81, 139, 39, 91, 228, 165, 157, 7, 159, 64, 78, 71]), Seed([38, 105, 160, 207, 60, 108, 156, 206, 107, 7, 198, 217, 53, 155, 107, 125, 136, 138, 11, 44, 12, 110, 121, 128, 97, 167, 74, 216, 145, 242, 163, 15]));
/// AIL: GDAIL226ZVY55X3BSQ24DJDLAWTCWXLCZP3FLNE3N6DUHRLNHUGJ7LNZ
static immutable AIL = KeyPair(PublicKey([192, 133, 235, 94, 205, 113, 222, 223, 97, 148, 53, 193, 164, 107, 5, 166, 43, 93, 98, 203, 246, 85, 180, 155, 111, 135, 67, 197, 109, 61, 12, 159]), SecretKey([168, 15, 218, 214, 169, 220, 248, 119, 99, 13, 181, 248, 213, 7, 206, 133, 237, 209, 215, 115, 120, 114, 164, 232, 200, 17, 33, 190, 67, 191, 115, 74]), Seed([156, 31, 10, 140, 32, 109, 90, 231, 232, 236, 119, 243, 157, 162, 218, 68, 41, 79, 178, 185, 147, 193, 244, 226, 167, 218, 67, 153, 190, 93, 36, 5]));
/// AIM: GDAIM22ZMIOVLP224DEKM73SLBPVVER4F6UPLMQNEFGE4HMMG77SAP6X
static immutable AIM = KeyPair(PublicKey([192, 134, 107, 89, 98, 29, 85, 191, 90, 224, 200, 166, 127, 114, 88, 95, 90, 146, 60, 47, 168, 245, 178, 13, 33, 76, 78, 29, 140, 55, 255, 32]), SecretKey([136, 191, 221, 211, 78, 116, 122, 201, 226, 95, 214, 68, 13, 174, 40, 203, 153, 126, 158, 156, 63, 15, 198, 212, 220, 60, 4, 3, 82, 128, 179, 78]), Seed([230, 143, 126, 99, 49, 168, 129, 101, 172, 49, 24, 227, 202, 146, 24, 155, 202, 147, 241, 31, 177, 19, 60, 64, 255, 122, 49, 121, 53, 229, 152, 254]));
/// AIN: GDAIN22KA5ZPPEOSRIO2AWF2IBWEJO3IH3AUCJYIVNBR27GD7M7MREKO
static immutable AIN = KeyPair(PublicKey([192, 134, 235, 74, 7, 114, 247, 145, 210, 138, 29, 160, 88, 186, 64, 108, 68, 187, 104, 62, 193, 65, 39, 8, 171, 67, 29, 124, 195, 251, 62, 200]), SecretKey([112, 93, 179, 199, 166, 124, 116, 243, 15, 123, 152, 56, 157, 238, 217, 250, 135, 246, 10, 13, 224, 55, 24, 22, 12, 202, 109, 16, 255, 213, 68, 115]), Seed([23, 12, 142, 193, 137, 65, 85, 77, 249, 152, 17, 169, 148, 124, 58, 26, 229, 253, 183, 169, 252, 6, 2, 62, 148, 255, 182, 249, 166, 137, 70, 101]));
/// AIO: GDAIO22ANHCGVKLRYX2KTYITPINYCE3OTSFNDNGDNQPE2KSCUZQATQ63
static immutable AIO = KeyPair(PublicKey([192, 135, 107, 64, 105, 196, 106, 169, 113, 197, 244, 169, 225, 19, 122, 27, 129, 19, 110, 156, 138, 209, 180, 195, 108, 30, 77, 42, 66, 166, 96, 9]), SecretKey([144, 29, 194, 240, 165, 242, 84, 102, 117, 161, 165, 61, 249, 37, 123, 52, 56, 164, 72, 205, 217, 144, 25, 54, 17, 17, 80, 231, 103, 79, 107, 123]), Seed([251, 105, 44, 122, 109, 181, 73, 95, 243, 221, 171, 30, 247, 215, 83, 192, 159, 174, 174, 40, 187, 24, 255, 98, 159, 116, 233, 27, 223, 167, 236, 231]));
/// AIP: GDAIP223ZSQ3WLBVXMYAFA5J5HEP6YXP5MLLPL6WBQKZRHEUPOMBNKBF
static immutable AIP = KeyPair(PublicKey([192, 135, 235, 91, 204, 161, 187, 44, 53, 187, 48, 2, 131, 169, 233, 200, 255, 98, 239, 235, 22, 183, 175, 214, 12, 21, 152, 156, 148, 123, 152, 22]), SecretKey([48, 5, 234, 36, 104, 96, 38, 203, 230, 124, 170, 119, 63, 252, 149, 152, 62, 143, 167, 75, 181, 187, 24, 39, 139, 245, 131, 153, 247, 209, 22, 93]), Seed([127, 230, 211, 58, 69, 89, 14, 203, 219, 197, 87, 48, 199, 85, 238, 14, 174, 74, 236, 73, 206, 169, 118, 203, 179, 133, 179, 108, 123, 197, 57, 104]));
/// AIQ: GDAIQ22AAGT43UZKRFVTWOSDY26YB3XUHN2ING3CXWMC6AYFKU7RB5X7
static immutable AIQ = KeyPair(PublicKey([192, 136, 107, 64, 1, 167, 205, 211, 42, 137, 107, 59, 58, 67, 198, 189, 128, 238, 244, 59, 116, 134, 155, 98, 189, 152, 47, 3, 5, 85, 63, 16]), SecretKey([192, 227, 187, 247, 42, 33, 152, 110, 145, 151, 29, 123, 179, 210, 203, 44, 137, 19, 156, 26, 85, 113, 74, 180, 196, 5, 126, 243, 247, 113, 125, 85]), Seed([80, 65, 60, 186, 77, 247, 50, 138, 252, 221, 241, 119, 112, 38, 28, 156, 170, 33, 223, 51, 72, 57, 34, 23, 109, 240, 56, 10, 191, 94, 168, 186]));
/// AIR: GDAIR22JDZUHSVD5GJQHXHSLJOH56GB5UZNM7HDVGEGO3FNAZUF7ROM5
static immutable AIR = KeyPair(PublicKey([192, 136, 235, 73, 30, 104, 121, 84, 125, 50, 96, 123, 158, 75, 75, 143, 223, 24, 61, 166, 90, 207, 156, 117, 49, 12, 237, 149, 160, 205, 11, 248]), SecretKey([104, 110, 176, 119, 184, 207, 10, 180, 174, 152, 117, 162, 160, 133, 107, 254, 247, 94, 34, 146, 100, 54, 15, 98, 162, 157, 255, 191, 231, 226, 161, 112]), Seed([94, 212, 192, 178, 159, 13, 120, 115, 200, 150, 83, 17, 179, 85, 172, 88, 251, 181, 102, 203, 170, 60, 180, 233, 156, 227, 87, 169, 165, 115, 214, 54]));
/// AIS: GDAIS22WBER3OPP257G2VB63WH6PSUBPQX3Q5UZ6QX3V2YQVLSEDIEFL
static immutable AIS = KeyPair(PublicKey([192, 137, 107, 86, 9, 35, 183, 61, 250, 239, 205, 170, 135, 219, 177, 252, 249, 80, 47, 133, 247, 14, 211, 62, 133, 247, 93, 98, 21, 92, 136, 52]), SecretKey([104, 18, 113, 92, 105, 89, 165, 88, 212, 1, 36, 247, 249, 225, 77, 166, 194, 207, 133, 162, 170, 4, 188, 12, 51, 27, 159, 254, 142, 156, 119, 116]), Seed([156, 248, 41, 188, 206, 105, 212, 98, 117, 45, 146, 171, 182, 202, 35, 88, 22, 24, 214, 5, 111, 178, 219, 17, 105, 89, 24, 94, 212, 59, 169, 165]));
/// AIT: GDAIT22VHUPC5P7LWB4Z4PO6IZN23OW6AE7G556DGCOCPX63HPH3GNB3
static immutable AIT = KeyPair(PublicKey([192, 137, 235, 85, 61, 30, 46, 191, 235, 176, 121, 158, 61, 222, 70, 91, 173, 186, 222, 1, 62, 110, 247, 195, 48, 156, 39, 223, 219, 59, 207, 179]), SecretKey([216, 210, 102, 222, 15, 214, 32, 92, 109, 254, 81, 37, 72, 239, 23, 155, 171, 80, 64, 212, 8, 41, 17, 135, 140, 230, 140, 90, 196, 69, 159, 105]), Seed([114, 98, 226, 70, 55, 101, 116, 72, 255, 107, 140, 241, 120, 179, 243, 210, 142, 117, 252, 43, 125, 247, 124, 165, 0, 24, 143, 100, 244, 222, 70, 207]));
/// AIU: GDAIU22JYP3XLFELCTXJXZXCJQYXSBVEZWCVEDF5DPXONVHEZSOUVYR4
static immutable AIU = KeyPair(PublicKey([192, 138, 107, 73, 195, 247, 117, 148, 139, 20, 238, 155, 230, 226, 76, 49, 121, 6, 164, 205, 133, 82, 12, 189, 27, 238, 230, 212, 228, 204, 157, 74]), SecretKey([216, 178, 180, 19, 26, 117, 155, 85, 61, 101, 7, 106, 157, 198, 17, 112, 194, 237, 62, 203, 37, 114, 89, 115, 123, 14, 196, 53, 125, 218, 93, 64]), Seed([156, 93, 46, 79, 107, 254, 242, 28, 186, 17, 36, 251, 145, 254, 225, 148, 173, 121, 253, 235, 53, 127, 65, 5, 186, 124, 200, 47, 123, 213, 164, 27]));
/// AIV: GDAIV22C3OALVQ6F53M5V6QJDDA2EXWJ65LIDSFETCFI2T54W5HGLQHS
static immutable AIV = KeyPair(PublicKey([192, 138, 235, 66, 219, 128, 186, 195, 197, 238, 217, 218, 250, 9, 24, 193, 162, 94, 201, 247, 86, 129, 200, 164, 152, 138, 141, 79, 188, 183, 78, 101]), SecretKey([16, 55, 177, 56, 113, 211, 165, 109, 61, 116, 224, 247, 56, 73, 254, 39, 157, 108, 188, 14, 133, 9, 137, 235, 34, 181, 117, 190, 193, 207, 228, 79]), Seed([135, 180, 219, 7, 127, 210, 39, 39, 168, 184, 12, 214, 116, 125, 137, 13, 182, 107, 101, 232, 114, 77, 84, 238, 91, 81, 126, 199, 37, 14, 130, 24]));
/// AIW: GDAIW226KEUA6O7G7Q4GQZB5UDRJVFOTYV6X2HF7PRJMUG2RNGYO4PM3
static immutable AIW = KeyPair(PublicKey([192, 139, 107, 94, 81, 40, 15, 59, 230, 252, 56, 104, 100, 61, 160, 226, 154, 149, 211, 197, 125, 125, 28, 191, 124, 82, 202, 27, 81, 105, 176, 238]), SecretKey([112, 7, 216, 29, 127, 191, 59, 137, 111, 55, 56, 168, 92, 100, 198, 15, 32, 222, 2, 104, 42, 252, 174, 17, 27, 77, 26, 122, 172, 217, 3, 64]), Seed([113, 158, 150, 154, 49, 144, 103, 191, 30, 105, 35, 230, 100, 149, 126, 155, 27, 55, 218, 91, 178, 217, 25, 112, 52, 254, 176, 116, 199, 193, 104, 120]));
/// AIX: GDAIX22QDFJBQWGHERCBCYFJ2TUY3LVU4UN5LYV2DWZRDGQGOJ23AE3O
static immutable AIX = KeyPair(PublicKey([192, 139, 235, 80, 25, 82, 24, 88, 199, 36, 68, 17, 96, 169, 212, 233, 141, 174, 180, 229, 27, 213, 226, 186, 29, 179, 17, 154, 6, 114, 117, 176]), SecretKey([184, 111, 67, 150, 197, 73, 223, 186, 68, 232, 98, 194, 43, 84, 205, 6, 133, 47, 246, 247, 249, 202, 50, 9, 112, 32, 138, 214, 78, 254, 212, 93]), Seed([158, 81, 186, 92, 113, 219, 5, 34, 119, 127, 141, 186, 71, 23, 254, 114, 191, 40, 13, 84, 29, 11, 151, 194, 46, 167, 250, 217, 183, 39, 243, 141]));
/// AIY: GDAIY22DR7V475SOPNA5IQ64LL2CRPYSTDFSDMMSMYL53A2AZVVHKPYB
static immutable AIY = KeyPair(PublicKey([192, 140, 107, 67, 143, 235, 207, 246, 78, 123, 65, 212, 67, 220, 90, 244, 40, 191, 18, 152, 203, 33, 177, 146, 102, 23, 221, 131, 64, 205, 106, 117]), SecretKey([0, 233, 100, 62, 126, 194, 254, 122, 149, 176, 251, 39, 32, 64, 44, 170, 142, 106, 91, 71, 248, 102, 79, 144, 52, 210, 138, 198, 231, 197, 69, 64]), Seed([19, 40, 130, 190, 199, 69, 10, 102, 204, 174, 150, 137, 208, 209, 205, 172, 94, 152, 107, 7, 58, 134, 57, 51, 214, 134, 150, 25, 142, 97, 144, 6]));
/// AIZ: GDAIZ22VFIEEKOJOC5ELZJNQ34YW3OQE7MDC3HQ72JCY6NIOTVJQD67T
static immutable AIZ = KeyPair(PublicKey([192, 140, 235, 85, 42, 8, 69, 57, 46, 23, 72, 188, 165, 176, 223, 49, 109, 186, 4, 251, 6, 45, 158, 31, 210, 69, 143, 53, 14, 157, 83, 1]), SecretKey([32, 193, 174, 110, 75, 169, 92, 162, 126, 158, 41, 133, 255, 36, 187, 138, 31, 86, 195, 96, 86, 120, 207, 29, 98, 181, 93, 165, 151, 146, 223, 125]), Seed([101, 208, 210, 75, 87, 10, 154, 123, 65, 191, 129, 58, 6, 22, 218, 241, 64, 170, 105, 224, 212, 80, 136, 167, 217, 208, 77, 17, 133, 77, 103, 150]));
/// AJA: GDAJA223P5LJQCTH6NO32MLN3ZRUDKM652LL7MITWGEZMZFAZAYV57GM
static immutable AJA = KeyPair(PublicKey([192, 144, 107, 91, 127, 86, 152, 10, 103, 243, 93, 189, 49, 109, 222, 99, 65, 169, 158, 238, 150, 191, 177, 19, 177, 137, 150, 100, 160, 200, 49, 94]), SecretKey([216, 162, 137, 56, 5, 45, 196, 54, 109, 26, 186, 76, 203, 243, 10, 58, 225, 68, 164, 249, 237, 105, 196, 195, 30, 30, 245, 91, 210, 123, 109, 88]), Seed([75, 212, 201, 246, 200, 163, 23, 46, 207, 46, 148, 217, 226, 5, 9, 128, 133, 210, 171, 195, 2, 126, 216, 17, 117, 149, 140, 154, 172, 53, 165, 235]));
/// AJB: GDAJB22ZGEKVSN4V5GDR4FVDF4JBIIUGY3GJZV45KJJYQDP6I5DGVVFY
static immutable AJB = KeyPair(PublicKey([192, 144, 235, 89, 49, 21, 89, 55, 149, 233, 135, 30, 22, 163, 47, 18, 20, 34, 134, 198, 204, 156, 215, 157, 82, 83, 136, 13, 254, 71, 70, 106]), SecretKey([80, 125, 221, 197, 64, 101, 184, 47, 112, 52, 217, 125, 69, 237, 21, 58, 25, 100, 136, 137, 187, 173, 206, 139, 230, 72, 197, 154, 212, 78, 98, 78]), Seed([170, 138, 111, 39, 27, 36, 72, 159, 98, 131, 207, 20, 8, 6, 133, 5, 153, 115, 178, 67, 127, 133, 155, 245, 181, 142, 167, 198, 224, 161, 117, 187]));
/// AJC: GDAJC22GD4DVF7LLC2JXJV2L27DMTBLT4TAE5UA4S44OBDTU2WEXHZBA
static immutable AJC = KeyPair(PublicKey([192, 145, 107, 70, 31, 7, 82, 253, 107, 22, 147, 116, 215, 75, 215, 198, 201, 133, 115, 228, 192, 78, 208, 28, 151, 56, 224, 142, 116, 213, 137, 115]), SecretKey([168, 76, 132, 45, 20, 224, 47, 204, 250, 13, 254, 9, 167, 101, 169, 51, 126, 67, 72, 178, 144, 217, 221, 20, 249, 3, 11, 242, 227, 84, 149, 99]), Seed([155, 154, 147, 56, 0, 61, 105, 110, 225, 219, 206, 62, 154, 29, 229, 72, 221, 25, 177, 248, 248, 175, 163, 111, 240, 105, 2, 129, 56, 161, 4, 234]));
/// AJD: GDAJD22TKGCD3MXAGVIXI5SZIS3BNPYQSAG3G42VGZTL5WFAPTYKMAOT
static immutable AJD = KeyPair(PublicKey([192, 145, 235, 83, 81, 132, 61, 178, 224, 53, 81, 116, 118, 89, 68, 182, 22, 191, 16, 144, 13, 179, 115, 85, 54, 102, 190, 216, 160, 124, 240, 166]), SecretKey([240, 80, 82, 231, 104, 187, 47, 153, 194, 132, 166, 195, 168, 33, 220, 240, 204, 37, 96, 146, 138, 23, 110, 123, 58, 49, 216, 233, 69, 128, 66, 84]), Seed([10, 106, 115, 37, 118, 111, 49, 194, 71, 131, 49, 230, 157, 211, 157, 214, 198, 100, 167, 85, 9, 99, 174, 174, 112, 181, 24, 234, 110, 98, 158, 234]));
/// AJE: GDAJE22OWGVHFVV3RONPHX4XES3OLC23LVHS62N75K7U5MYD5ZEADER6
static immutable AJE = KeyPair(PublicKey([192, 146, 107, 78, 177, 170, 114, 214, 187, 139, 154, 243, 223, 151, 36, 182, 229, 139, 91, 93, 79, 47, 105, 191, 234, 191, 78, 179, 3, 238, 72, 1]), SecretKey([80, 13, 219, 208, 90, 122, 253, 112, 249, 198, 7, 195, 214, 17, 66, 157, 19, 188, 247, 226, 223, 27, 251, 76, 105, 177, 39, 137, 174, 232, 61, 91]), Seed([99, 233, 92, 21, 109, 155, 89, 177, 251, 129, 221, 213, 126, 220, 15, 28, 27, 227, 171, 43, 115, 185, 18, 134, 214, 78, 252, 198, 131, 45, 99, 236]));
/// AJF: GDAJF22BQ4324TZMCELHZVU6YM2XMDFI65ZF57UDL5RUF3BS5TWIHDKO
static immutable AJF = KeyPair(PublicKey([192, 146, 235, 65, 135, 55, 174, 79, 44, 17, 22, 124, 214, 158, 195, 53, 118, 12, 168, 247, 114, 94, 254, 131, 95, 99, 66, 236, 50, 236, 236, 131]), SecretKey([0, 143, 116, 142, 176, 47, 48, 253, 189, 47, 184, 54, 105, 78, 135, 91, 90, 100, 46, 206, 146, 11, 104, 104, 120, 188, 151, 81, 225, 145, 26, 97]), Seed([71, 182, 135, 172, 88, 167, 195, 163, 197, 244, 208, 226, 166, 4, 207, 161, 20, 35, 143, 32, 199, 55, 197, 195, 225, 62, 39, 134, 87, 169, 184, 255]));
/// AJG: GDAJG22DXH3DIJBOAD5GNJHE3E2DRHYG5TEUIWGQJRT2P2DVIUWT6ITS
static immutable AJG = KeyPair(PublicKey([192, 147, 107, 67, 185, 246, 52, 36, 46, 0, 250, 102, 164, 228, 217, 52, 56, 159, 6, 236, 201, 68, 88, 208, 76, 103, 167, 232, 117, 69, 45, 63]), SecretKey([176, 53, 217, 135, 247, 76, 101, 78, 30, 212, 26, 110, 16, 253, 171, 187, 212, 186, 55, 223, 160, 98, 37, 219, 242, 228, 65, 253, 239, 45, 39, 72]), Seed([93, 60, 220, 254, 50, 241, 192, 8, 209, 201, 210, 196, 7, 7, 44, 191, 196, 84, 233, 214, 65, 66, 63, 40, 113, 237, 158, 154, 157, 48, 210, 141]));
/// AJH: GDAJH223DBWWZOV33ISDDTRIQZOUICZMVJEOXO7HRI2JD2SRAVXFIOQT
static immutable AJH = KeyPair(PublicKey([192, 147, 235, 91, 24, 109, 108, 186, 187, 218, 36, 49, 206, 40, 134, 93, 68, 11, 44, 170, 72, 235, 187, 231, 138, 52, 145, 234, 81, 5, 110, 84]), SecretKey([168, 140, 132, 235, 98, 64, 26, 231, 157, 115, 171, 199, 133, 250, 34, 182, 177, 128, 20, 97, 242, 167, 35, 145, 12, 14, 58, 4, 137, 95, 11, 100]), Seed([120, 1, 60, 137, 123, 253, 42, 193, 87, 22, 31, 27, 175, 165, 73, 130, 81, 232, 87, 97, 100, 185, 63, 33, 201, 188, 44, 144, 77, 174, 99, 179]));
/// AJI: GDAJI22AX33SZWM3W77A4DNYYAVLQQVTC2UBMZ65BZ6PC3M3SVN7LUR7
static immutable AJI = KeyPair(PublicKey([192, 148, 107, 64, 190, 247, 44, 217, 155, 183, 254, 14, 13, 184, 192, 42, 184, 66, 179, 22, 168, 22, 103, 221, 14, 124, 241, 109, 155, 149, 91, 245]), SecretKey([176, 255, 180, 185, 178, 81, 106, 169, 79, 100, 145, 106, 43, 194, 5, 25, 22, 171, 195, 192, 52, 194, 106, 148, 255, 19, 89, 204, 25, 22, 236, 109]), Seed([228, 183, 250, 180, 166, 206, 57, 79, 107, 71, 98, 66, 155, 61, 164, 5, 242, 135, 57, 226, 52, 159, 162, 51, 162, 153, 102, 81, 155, 8, 123, 202]));
/// AJJ: GDAJJ22MTZT2MTYDODO53UJ5QTWMZP3I6O27IYIGCJZ34CEX2XFORI73
static immutable AJJ = KeyPair(PublicKey([192, 148, 235, 76, 158, 103, 166, 79, 3, 112, 221, 221, 209, 61, 132, 236, 204, 191, 104, 243, 181, 244, 97, 6, 18, 115, 190, 8, 151, 213, 202, 232]), SecretKey([24, 71, 158, 217, 50, 236, 148, 165, 72, 1, 181, 133, 91, 173, 115, 94, 1, 58, 99, 17, 110, 30, 76, 33, 211, 188, 30, 253, 18, 138, 27, 73]), Seed([50, 170, 210, 192, 169, 99, 61, 170, 183, 195, 159, 18, 93, 222, 206, 10, 54, 204, 221, 181, 59, 174, 244, 26, 208, 120, 214, 85, 228, 113, 130, 29]));
/// AJK: GDAJK22LBMIERWA5HYDUGC74B3XJWO46NZSW3DRWZMUSY3QFIHLDIZ72
static immutable AJK = KeyPair(PublicKey([192, 149, 107, 75, 11, 16, 72, 216, 29, 62, 7, 67, 11, 252, 14, 238, 155, 59, 158, 110, 101, 109, 142, 54, 203, 41, 44, 110, 5, 65, 214, 52]), SecretKey([104, 167, 1, 6, 253, 118, 34, 139, 57, 132, 236, 56, 68, 2, 198, 51, 193, 234, 179, 13, 19, 249, 91, 20, 160, 163, 130, 58, 200, 226, 143, 81]), Seed([48, 97, 155, 103, 58, 144, 15, 73, 175, 230, 7, 71, 65, 6, 240, 62, 146, 17, 79, 165, 107, 3, 193, 35, 36, 165, 16, 120, 97, 18, 55, 185]));
/// AJL: GDAJL22A35VGPAVI5DCCBT42KHPHJMARRW2W7FDLILUCZZF4Q7CHWNJ2
static immutable AJL = KeyPair(PublicKey([192, 149, 235, 64, 223, 106, 103, 130, 168, 232, 196, 32, 207, 154, 81, 222, 116, 176, 17, 141, 181, 111, 148, 107, 66, 232, 44, 228, 188, 135, 196, 123]), SecretKey([184, 100, 67, 20, 45, 230, 80, 254, 97, 44, 213, 251, 42, 222, 66, 200, 219, 54, 75, 96, 170, 214, 85, 19, 165, 170, 142, 230, 84, 43, 207, 117]), Seed([130, 234, 18, 51, 46, 153, 198, 8, 61, 63, 54, 178, 228, 190, 253, 240, 168, 131, 119, 166, 26, 32, 63, 24, 170, 128, 250, 76, 157, 102, 56, 173]));
/// AJM: GDAJM224WDSEW6F3QZM3DGKNHDKGJE7DMF6FXL5KD5DJPVQAIR2M4BPV
static immutable AJM = KeyPair(PublicKey([192, 150, 107, 92, 176, 228, 75, 120, 187, 134, 89, 177, 153, 77, 56, 212, 100, 147, 227, 97, 124, 91, 175, 170, 31, 70, 151, 214, 0, 68, 116, 206]), SecretKey([8, 80, 130, 70, 248, 40, 218, 248, 117, 122, 136, 57, 22, 136, 128, 113, 160, 222, 47, 67, 5, 180, 239, 49, 236, 36, 238, 175, 144, 155, 231, 92]), Seed([171, 165, 217, 78, 24, 64, 232, 55, 39, 149, 245, 80, 115, 70, 20, 225, 254, 8, 118, 40, 189, 22, 212, 32, 134, 82, 21, 26, 203, 42, 112, 43]));
/// AJN: GDAJN22UOGDFIFMRZPDD5JUPDSJVQKC6R4TD5DOIGUQTIUZLMKEMXDNP
static immutable AJN = KeyPair(PublicKey([192, 150, 235, 84, 113, 134, 84, 21, 145, 203, 198, 62, 166, 143, 28, 147, 88, 40, 94, 143, 38, 62, 141, 200, 53, 33, 52, 83, 43, 98, 136, 203]), SecretKey([64, 226, 157, 237, 232, 252, 168, 158, 1, 38, 5, 16, 181, 163, 55, 121, 95, 41, 69, 205, 45, 144, 128, 234, 112, 117, 39, 225, 12, 41, 116, 91]), Seed([25, 158, 146, 225, 232, 214, 239, 190, 21, 105, 252, 248, 9, 25, 229, 11, 198, 60, 78, 227, 104, 186, 23, 226, 42, 82, 176, 57, 29, 149, 230, 200]));
/// AJO: GDAJO22H5FCTRSZK7WLFUM7ZEWJXQ4WTSAKW72HPGRNSL2XYIXXFARN2
static immutable AJO = KeyPair(PublicKey([192, 151, 107, 71, 233, 69, 56, 203, 42, 253, 150, 90, 51, 249, 37, 147, 120, 114, 211, 144, 21, 111, 232, 239, 52, 91, 37, 234, 248, 69, 238, 80]), SecretKey([200, 60, 146, 214, 92, 225, 249, 112, 137, 22, 54, 113, 44, 103, 32, 148, 106, 60, 157, 202, 103, 220, 255, 135, 71, 109, 134, 54, 134, 255, 218, 82]), Seed([164, 5, 191, 255, 245, 65, 94, 231, 120, 141, 135, 255, 201, 4, 98, 248, 45, 73, 222, 82, 24, 34, 112, 66, 74, 138, 236, 145, 246, 82, 35, 5]));
/// AJP: GDAJP22U6N4HS7U27YNWURTVVGKVVPHKXTKVEQABLUR4PMYK72GVGNXO
static immutable AJP = KeyPair(PublicKey([192, 151, 235, 84, 243, 120, 121, 126, 154, 254, 27, 106, 70, 117, 169, 149, 90, 188, 234, 188, 213, 82, 64, 1, 93, 35, 199, 179, 10, 254, 141, 83]), SecretKey([32, 193, 144, 90, 205, 131, 63, 128, 215, 21, 77, 133, 64, 15, 164, 150, 205, 86, 67, 244, 36, 181, 206, 60, 167, 137, 77, 9, 138, 177, 136, 118]), Seed([49, 116, 14, 192, 70, 0, 217, 74, 147, 223, 124, 184, 221, 27, 16, 32, 44, 82, 177, 194, 46, 179, 222, 106, 78, 224, 218, 253, 41, 202, 27, 130]));
/// AJQ: GDAJQ22WWH3ZHFWP2GWOCP2DEMYT4B4LLHACGUHMVTM2XFQC36FZYBJV
static immutable AJQ = KeyPair(PublicKey([192, 152, 107, 86, 177, 247, 147, 150, 207, 209, 172, 225, 63, 67, 35, 49, 62, 7, 139, 89, 192, 35, 80, 236, 172, 217, 171, 150, 2, 223, 139, 156]), SecretKey([120, 70, 175, 73, 56, 237, 223, 155, 87, 15, 29, 20, 16, 0, 230, 99, 103, 136, 17, 138, 115, 97, 75, 196, 153, 180, 89, 250, 3, 121, 109, 92]), Seed([79, 203, 228, 1, 43, 75, 201, 157, 137, 20, 33, 194, 153, 8, 245, 146, 132, 40, 16, 68, 217, 28, 137, 201, 193, 90, 125, 251, 47, 31, 235, 212]));
/// AJR: GDAJR223LSP7GF6HONS74RWNYXDMNKBC5LDXF5LAM3MECVQCT4TUPHZU
static immutable AJR = KeyPair(PublicKey([192, 152, 235, 91, 92, 159, 243, 23, 199, 115, 101, 254, 70, 205, 197, 198, 198, 168, 34, 234, 199, 114, 245, 96, 102, 216, 65, 86, 2, 159, 39, 71]), SecretKey([72, 89, 2, 114, 203, 236, 176, 23, 225, 125, 122, 18, 184, 36, 218, 132, 55, 196, 40, 31, 234, 41, 151, 191, 255, 182, 3, 217, 163, 195, 158, 127]), Seed([53, 60, 113, 123, 196, 62, 175, 152, 12, 105, 128, 19, 16, 120, 116, 20, 6, 90, 99, 19, 234, 139, 230, 185, 148, 249, 108, 21, 79, 192, 43, 211]));
/// AJS: GDAJS22SUOSKYZIZPT5A3HJEQGA43WVTBPVB7ZJXRSVO5SBSFEPHNRED
static immutable AJS = KeyPair(PublicKey([192, 153, 107, 82, 163, 164, 172, 101, 25, 124, 250, 13, 157, 36, 129, 129, 205, 218, 179, 11, 234, 31, 229, 55, 140, 170, 238, 200, 50, 41, 30, 118]), SecretKey([64, 171, 156, 204, 47, 203, 89, 172, 89, 172, 202, 75, 206, 170, 39, 68, 75, 184, 143, 41, 7, 201, 184, 107, 179, 51, 172, 197, 39, 189, 226, 89]), Seed([69, 204, 203, 100, 58, 247, 86, 185, 158, 43, 229, 173, 28, 73, 199, 209, 1, 46, 195, 229, 96, 13, 159, 206, 235, 60, 221, 7, 13, 81, 207, 57]));
/// AJT: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable AJT = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// AJU: GDAJU22NWUUSRXDFYTF75OBUMUZIOQ6YBIYBDXM4RUUXRFWPIQWNGAYQ
static immutable AJU = KeyPair(PublicKey([192, 154, 107, 77, 181, 41, 40, 220, 101, 196, 203, 254, 184, 52, 101, 50, 135, 67, 216, 10, 48, 17, 221, 156, 141, 41, 120, 150, 207, 68, 44, 211]), SecretKey([88, 83, 67, 85, 40, 188, 23, 73, 111, 235, 10, 99, 99, 76, 131, 86, 103, 74, 63, 45, 202, 200, 89, 16, 198, 56, 200, 6, 75, 74, 166, 119]), Seed([202, 150, 55, 103, 2, 83, 140, 173, 30, 30, 59, 175, 123, 76, 139, 147, 119, 1, 92, 101, 105, 117, 155, 126, 218, 215, 100, 85, 13, 161, 31, 199]));
/// AJV: GDAJV22M7OWV4STY7TPFZK4YAZKHQJYJIUYIQ4A3CCM5WXYOEKCEHQJV
static immutable AJV = KeyPair(PublicKey([192, 154, 235, 76, 251, 173, 94, 74, 120, 252, 222, 92, 171, 152, 6, 84, 120, 39, 9, 69, 48, 136, 112, 27, 16, 153, 219, 95, 14, 34, 132, 67]), SecretKey([24, 40, 116, 14, 92, 220, 210, 102, 5, 67, 182, 155, 26, 10, 102, 145, 79, 161, 189, 23, 249, 36, 22, 56, 82, 79, 67, 69, 227, 14, 40, 113]), Seed([171, 231, 36, 217, 167, 166, 18, 244, 250, 248, 55, 108, 166, 88, 51, 220, 195, 91, 118, 75, 61, 19, 127, 117, 103, 35, 114, 2, 244, 150, 17, 22]));
/// AJW: GDAJW22AXMLAFQDAOYAXSNZSSYKBCTATDOH2QBJ7TITHCJ22J53Q2KCA
static immutable AJW = KeyPair(PublicKey([192, 155, 107, 64, 187, 22, 2, 192, 96, 118, 1, 121, 55, 50, 150, 20, 17, 76, 19, 27, 143, 168, 5, 63, 154, 38, 113, 39, 90, 79, 119, 13]), SecretKey([152, 31, 160, 92, 155, 236, 45, 241, 160, 62, 16, 131, 191, 157, 127, 165, 118, 34, 77, 215, 185, 230, 168, 243, 145, 184, 207, 250, 237, 230, 27, 95]), Seed([183, 133, 213, 149, 42, 53, 13, 35, 189, 143, 188, 156, 99, 61, 166, 139, 169, 247, 96, 35, 97, 243, 43, 176, 227, 72, 101, 47, 106, 69, 205, 213]));
/// AJX: GDAJX22G53ENSEUITJLMWUDZXWEIJ6NIRL5RJFUK5TPVQ2334FWR733T
static immutable AJX = KeyPair(PublicKey([192, 155, 235, 70, 238, 200, 217, 18, 136, 154, 86, 203, 80, 121, 189, 136, 132, 249, 168, 138, 251, 20, 150, 138, 236, 223, 88, 107, 123, 225, 109, 31]), SecretKey([128, 23, 150, 179, 211, 111, 154, 188, 150, 97, 223, 7, 16, 189, 66, 252, 136, 212, 148, 121, 127, 34, 83, 66, 8, 170, 98, 8, 115, 92, 174, 115]), Seed([108, 23, 177, 183, 187, 192, 198, 161, 213, 229, 24, 206, 200, 242, 253, 88, 65, 199, 148, 78, 165, 219, 243, 121, 54, 161, 207, 15, 53, 114, 26, 95]));
/// AJY: GDAJY226SNLERXGEQESLXVCTVPFYUP36GZ7XZJ6KZE5KO4OZGFJ25INC
static immutable AJY = KeyPair(PublicKey([192, 156, 107, 94, 147, 86, 72, 220, 196, 129, 36, 187, 212, 83, 171, 203, 138, 63, 126, 54, 127, 124, 167, 202, 201, 58, 167, 113, 217, 49, 83, 174]), SecretKey([24, 239, 21, 180, 109, 160, 149, 167, 195, 10, 236, 31, 105, 210, 174, 191, 84, 110, 75, 58, 29, 180, 97, 91, 129, 4, 117, 233, 80, 200, 101, 108]), Seed([245, 182, 229, 150, 47, 87, 63, 120, 55, 92, 236, 75, 86, 248, 22, 141, 76, 250, 14, 223, 105, 216, 57, 130, 188, 75, 25, 26, 85, 107, 115, 24]));
/// AJZ: GDAJZ22YQU2H2UMKKQI3ZIDEVIBHE2CPYEAW27MVWCLPC35RNMCHMTFA
static immutable AJZ = KeyPair(PublicKey([192, 156, 235, 88, 133, 52, 125, 81, 138, 84, 17, 188, 160, 100, 170, 2, 114, 104, 79, 193, 1, 109, 125, 149, 176, 150, 241, 111, 177, 107, 4, 118]), SecretKey([96, 167, 14, 156, 130, 249, 166, 105, 11, 132, 146, 69, 244, 17, 146, 2, 251, 165, 5, 125, 210, 237, 240, 52, 242, 51, 250, 237, 120, 218, 14, 64]), Seed([95, 37, 132, 15, 112, 8, 28, 226, 88, 6, 254, 178, 129, 167, 225, 157, 39, 146, 123, 7, 232, 4, 145, 131, 194, 33, 194, 188, 67, 56, 48, 28]));
/// AKA: GDAKA225OZIHVEQRJPHSW5NDFKGW5RYEXPF3LANOYE6NCRDMN4ONMWFT
static immutable AKA = KeyPair(PublicKey([192, 160, 107, 93, 118, 80, 122, 146, 17, 75, 207, 43, 117, 163, 42, 141, 110, 199, 4, 187, 203, 181, 129, 174, 193, 60, 209, 68, 108, 111, 28, 214]), SecretKey([240, 250, 97, 149, 188, 232, 11, 113, 102, 16, 124, 242, 21, 250, 200, 10, 84, 189, 50, 223, 7, 254, 140, 153, 169, 144, 228, 160, 242, 113, 152, 72]), Seed([139, 193, 105, 233, 93, 170, 40, 151, 51, 150, 177, 175, 233, 234, 14, 247, 146, 197, 68, 226, 173, 235, 29, 61, 180, 135, 208, 186, 181, 27, 181, 231]));
/// AKB: GDAKB22TRLXCRYOHS5U4D2ZMT6BICIPBZOEGY45AV2GPESVSZAK6KKNI
static immutable AKB = KeyPair(PublicKey([192, 160, 235, 83, 138, 238, 40, 225, 199, 151, 105, 193, 235, 44, 159, 130, 129, 33, 225, 203, 136, 108, 115, 160, 174, 140, 242, 74, 178, 200, 21, 229]), SecretKey([48, 56, 208, 100, 22, 18, 19, 151, 243, 156, 39, 189, 19, 36, 191, 215, 54, 91, 56, 119, 158, 10, 210, 97, 80, 55, 222, 55, 47, 106, 114, 125]), Seed([158, 170, 166, 110, 163, 45, 51, 12, 107, 8, 38, 91, 181, 36, 92, 56, 105, 115, 217, 76, 48, 215, 29, 168, 251, 131, 134, 42, 21, 87, 241, 65]));
/// AKC: GDAKC22655HY5DINYBAIRXVW45SU2DSKHZERCMRYS62A6YBWLZDWSWIG
static immutable AKC = KeyPair(PublicKey([192, 161, 107, 94, 239, 79, 142, 141, 13, 192, 64, 136, 222, 182, 231, 101, 77, 14, 74, 62, 73, 17, 50, 56, 151, 180, 15, 96, 54, 94, 71, 105]), SecretKey([240, 132, 196, 90, 16, 41, 118, 13, 84, 198, 168, 125, 91, 229, 131, 85, 186, 6, 215, 45, 163, 206, 164, 18, 121, 93, 135, 153, 89, 209, 91, 65]), Seed([109, 226, 96, 44, 154, 241, 50, 238, 229, 114, 1, 179, 196, 49, 103, 27, 25, 16, 32, 81, 233, 37, 210, 22, 3, 22, 119, 195, 118, 120, 130, 42]));
/// AKD: GDAKD22NPBXUOGPVMNQHHSDE5RF4J73VU3PZM7ISK2NNRNBPXI23HUQP
static immutable AKD = KeyPair(PublicKey([192, 161, 235, 77, 120, 111, 71, 25, 245, 99, 96, 115, 200, 100, 236, 75, 196, 255, 117, 166, 223, 150, 125, 18, 86, 154, 216, 180, 47, 186, 53, 179]), SecretKey([232, 157, 222, 56, 252, 25, 206, 63, 85, 254, 167, 24, 125, 108, 194, 216, 40, 215, 230, 216, 53, 25, 4, 174, 40, 15, 68, 93, 236, 201, 195, 116]), Seed([72, 8, 6, 209, 221, 104, 42, 115, 141, 75, 244, 186, 116, 50, 155, 160, 14, 242, 148, 22, 131, 155, 222, 248, 134, 233, 236, 131, 78, 156, 244, 36]));
/// AKE: GDAKE22SK6CKAJMOYVNTS36U6ILYSCAO7AXAOAC6PBP55TMZE7ZCBMAL
static immutable AKE = KeyPair(PublicKey([192, 162, 107, 82, 87, 132, 160, 37, 142, 197, 91, 57, 111, 212, 242, 23, 137, 8, 14, 248, 46, 7, 0, 94, 120, 95, 222, 205, 153, 39, 242, 32]), SecretKey([208, 17, 250, 131, 11, 138, 46, 242, 203, 83, 249, 131, 117, 117, 200, 48, 64, 69, 158, 101, 227, 37, 74, 68, 60, 32, 80, 242, 67, 216, 38, 118]), Seed([135, 10, 116, 193, 186, 193, 134, 193, 77, 234, 167, 251, 38, 242, 68, 221, 56, 235, 207, 94, 223, 66, 191, 127, 93, 154, 8, 235, 190, 33, 99, 160]));
/// AKF: GDAKF22J6R6XC3VFZJJ5JHE5MG57OOZT2NN2DT3S4FWJ5CRTS5R2ITF5
static immutable AKF = KeyPair(PublicKey([192, 162, 235, 73, 244, 125, 113, 110, 165, 202, 83, 212, 156, 157, 97, 187, 247, 59, 51, 211, 91, 161, 207, 114, 225, 108, 158, 138, 51, 151, 99, 164]), SecretKey([0, 145, 163, 229, 96, 241, 7, 40, 250, 96, 195, 24, 98, 176, 43, 33, 32, 75, 26, 35, 73, 113, 129, 135, 33, 89, 126, 37, 139, 228, 199, 112]), Seed([211, 83, 4, 244, 136, 191, 19, 165, 27, 242, 58, 163, 199, 34, 205, 198, 102, 70, 90, 58, 123, 61, 26, 63, 234, 193, 150, 142, 131, 218, 96, 28]));
/// AKG: GDAKG22CDZO5INNCHMQDQKVOZDWZHKN7N4O4CQNIWGUBX6XBDXOTXTSP
static immutable AKG = KeyPair(PublicKey([192, 163, 107, 66, 30, 93, 212, 53, 162, 59, 32, 56, 42, 174, 200, 237, 147, 169, 191, 111, 29, 193, 65, 168, 177, 168, 27, 250, 225, 29, 221, 59]), SecretKey([0, 13, 102, 161, 186, 175, 197, 35, 217, 126, 68, 136, 245, 238, 213, 147, 194, 215, 14, 119, 145, 173, 180, 156, 213, 84, 245, 230, 102, 3, 227, 85]), Seed([221, 98, 211, 82, 77, 121, 210, 110, 53, 161, 154, 138, 99, 98, 181, 195, 194, 142, 172, 186, 15, 2, 182, 180, 130, 245, 149, 17, 219, 121, 65, 158]));
/// AKH: GDAKH22XKRT4XR6VZGXXICDQS6TBTN4E4WVHBJUXHC3VCNVLIK53HXMS
static immutable AKH = KeyPair(PublicKey([192, 163, 235, 87, 84, 103, 203, 199, 213, 201, 175, 116, 8, 112, 151, 166, 25, 183, 132, 229, 170, 112, 166, 151, 56, 183, 81, 54, 171, 66, 187, 179]), SecretKey([240, 200, 222, 53, 205, 67, 159, 135, 26, 115, 159, 171, 177, 235, 132, 131, 158, 95, 117, 182, 158, 124, 225, 155, 168, 63, 65, 196, 42, 18, 116, 123]), Seed([46, 89, 130, 134, 133, 212, 155, 174, 84, 152, 172, 149, 224, 101, 237, 248, 192, 101, 255, 94, 185, 204, 79, 47, 93, 159, 100, 15, 154, 214, 35, 69]));
/// AKI: GDAKI22YEUHKWD2Q2HGZZROVPDHRGV6LTS4HSVYVR2FKZ2BEVYPXWHJA
static immutable AKI = KeyPair(PublicKey([192, 164, 107, 88, 37, 14, 171, 15, 80, 209, 205, 156, 197, 213, 120, 207, 19, 87, 203, 156, 184, 121, 87, 21, 142, 138, 172, 232, 36, 174, 31, 123]), SecretKey([232, 136, 211, 186, 104, 66, 187, 205, 121, 121, 153, 151, 194, 35, 200, 114, 242, 231, 154, 170, 87, 86, 46, 146, 222, 128, 215, 122, 13, 139, 25, 71]), Seed([41, 251, 229, 9, 129, 115, 193, 232, 138, 64, 238, 113, 249, 185, 59, 167, 178, 238, 198, 244, 32, 23, 252, 183, 67, 124, 91, 216, 5, 102, 161, 188]));
/// AKJ: GDAKJ22X7MIB3A23TRHHVYEZ7BWBSAE5NX76RFVRC6GSG2Y7U7BCVK64
static immutable AKJ = KeyPair(PublicKey([192, 164, 235, 87, 251, 16, 29, 131, 91, 156, 78, 122, 224, 153, 248, 108, 25, 0, 157, 109, 255, 232, 150, 177, 23, 141, 35, 107, 31, 167, 194, 42]), SecretKey([208, 175, 83, 244, 204, 77, 210, 134, 7, 136, 2, 132, 69, 227, 177, 72, 165, 152, 212, 56, 248, 86, 183, 203, 37, 109, 25, 199, 217, 246, 169, 80]), Seed([50, 103, 175, 162, 98, 15, 80, 68, 41, 188, 241, 222, 41, 207, 88, 0, 64, 78, 40, 44, 165, 120, 138, 148, 72, 120, 5, 66, 233, 153, 54, 81]));
/// AKK: GDAKK22GADIVEPU5GSBORPNBORWVXXFC62QK5C5T7EEPUCG6CMBIYOXW
static immutable AKK = KeyPair(PublicKey([192, 165, 107, 70, 0, 209, 82, 62, 157, 52, 130, 232, 189, 161, 116, 109, 91, 220, 162, 246, 160, 174, 139, 179, 249, 8, 250, 8, 222, 19, 2, 140]), SecretKey([176, 90, 76, 73, 207, 151, 251, 212, 153, 141, 99, 90, 204, 179, 44, 76, 35, 158, 3, 50, 237, 72, 178, 88, 215, 199, 190, 121, 233, 165, 25, 87]), Seed([232, 155, 92, 154, 171, 166, 81, 117, 130, 10, 78, 0, 241, 31, 253, 81, 124, 67, 152, 33, 130, 177, 151, 97, 76, 179, 80, 242, 97, 18, 188, 156]));
/// AKL: GDAKL222AARO64Q7MWTVIP2L4I3VLVDFOSKLSHP4FBIAFSJMNPZZH3F7
static immutable AKL = KeyPair(PublicKey([192, 165, 235, 90, 0, 34, 239, 114, 31, 101, 167, 84, 63, 75, 226, 55, 85, 212, 101, 116, 148, 185, 29, 252, 40, 80, 2, 201, 44, 107, 243, 147]), SecretKey([208, 136, 234, 87, 107, 95, 70, 30, 16, 164, 224, 26, 190, 63, 210, 186, 133, 98, 56, 50, 170, 28, 121, 48, 95, 218, 249, 31, 238, 235, 143, 126]), Seed([6, 208, 83, 107, 168, 167, 110, 218, 238, 75, 20, 191, 66, 149, 34, 213, 70, 99, 191, 199, 60, 174, 106, 86, 61, 175, 227, 36, 154, 78, 16, 142]));
/// AKM: GDAKM22J7W6EACJX3YMRVNVGLPD5DDJ4A6OZGZ4X5MMO56KIB2XCLIQQ
static immutable AKM = KeyPair(PublicKey([192, 166, 107, 73, 253, 188, 64, 9, 55, 222, 25, 26, 182, 166, 91, 199, 209, 141, 60, 7, 157, 147, 103, 151, 235, 24, 238, 249, 72, 14, 174, 37]), SecretKey([152, 46, 78, 181, 246, 66, 179, 107, 86, 65, 140, 173, 19, 148, 212, 80, 127, 212, 136, 212, 31, 157, 155, 176, 12, 167, 109, 243, 39, 163, 29, 89]), Seed([40, 54, 141, 124, 84, 151, 98, 252, 159, 34, 107, 243, 232, 232, 237, 35, 19, 240, 197, 86, 171, 170, 120, 199, 69, 98, 44, 122, 78, 101, 239, 133]));
/// AKN: GDAKN22WLQR5RYNGON4VFZJIRSJ7JM2IZ56XONHR5TPMEMC3BAXSFWNK
static immutable AKN = KeyPair(PublicKey([192, 166, 235, 86, 92, 35, 216, 225, 166, 115, 121, 82, 229, 40, 140, 147, 244, 179, 72, 207, 125, 119, 52, 241, 236, 222, 194, 48, 91, 8, 47, 34]), SecretKey([224, 83, 97, 172, 182, 191, 239, 232, 83, 223, 247, 220, 83, 215, 113, 38, 176, 168, 229, 55, 212, 32, 222, 123, 177, 246, 247, 23, 158, 88, 141, 66]), Seed([181, 130, 15, 205, 247, 155, 20, 56, 36, 251, 100, 85, 30, 74, 211, 4, 216, 110, 115, 90, 147, 224, 10, 11, 74, 71, 23, 110, 107, 6, 94, 113]));
/// AKO: GDAKO22HZK3QHSXMCI36ES77B6NIEQCM3JGNCEECRBPTISDX73RPG6T6
static immutable AKO = KeyPair(PublicKey([192, 167, 107, 71, 202, 183, 3, 202, 236, 18, 55, 226, 75, 255, 15, 154, 130, 64, 76, 218, 76, 209, 16, 130, 136, 95, 52, 72, 119, 254, 226, 243]), SecretKey([32, 87, 213, 219, 167, 38, 53, 80, 231, 240, 171, 39, 89, 236, 81, 125, 140, 23, 108, 129, 192, 240, 63, 16, 226, 17, 85, 115, 35, 220, 188, 98]), Seed([94, 9, 236, 113, 254, 22, 184, 176, 78, 127, 7, 196, 147, 67, 98, 44, 136, 225, 213, 15, 230, 199, 30, 117, 66, 51, 81, 137, 34, 230, 99, 208]));
/// AKP: GDAKP222GZGNF72R7FPE4GCMICOCS6YSTMUFD3HBEUITXESSCAYZFFU5
static immutable AKP = KeyPair(PublicKey([192, 167, 235, 90, 54, 76, 210, 255, 81, 249, 94, 78, 24, 76, 64, 156, 41, 123, 18, 155, 40, 81, 236, 225, 37, 17, 59, 146, 82, 16, 49, 146]), SecretKey([72, 130, 129, 37, 72, 21, 176, 175, 80, 89, 34, 145, 141, 252, 170, 254, 198, 232, 207, 213, 16, 208, 182, 10, 182, 1, 180, 183, 33, 76, 66, 68]), Seed([80, 128, 125, 134, 79, 41, 35, 96, 101, 130, 81, 101, 171, 149, 196, 58, 32, 242, 153, 40, 156, 88, 247, 63, 84, 150, 122, 187, 187, 51, 213, 185]));
/// AKQ: GDAKQ22HFT2J34FZX54AZYNHDKWV6UO2XO5YEHDICCOTK2G3CE2VVNLJ
static immutable AKQ = KeyPair(PublicKey([192, 168, 107, 71, 44, 244, 157, 240, 185, 191, 120, 12, 225, 167, 26, 173, 95, 81, 218, 187, 187, 130, 28, 104, 16, 157, 53, 104, 219, 17, 53, 90]), SecretKey([64, 107, 234, 29, 80, 101, 74, 215, 28, 178, 223, 87, 44, 222, 215, 191, 198, 191, 216, 125, 65, 146, 183, 2, 88, 130, 236, 126, 15, 38, 171, 85]), Seed([194, 230, 10, 182, 24, 27, 9, 129, 1, 21, 207, 219, 43, 57, 183, 221, 150, 106, 243, 106, 54, 162, 226, 253, 15, 234, 67, 162, 80, 186, 103, 177]));
/// AKR: GDAKR224K2DZ5CJRYEUY7E7Y7LH77BN5PGDP7IKDXXBHWSTGVVYDO24A
static immutable AKR = KeyPair(PublicKey([192, 168, 235, 92, 86, 135, 158, 137, 49, 193, 41, 143, 147, 248, 250, 207, 255, 133, 189, 121, 134, 255, 161, 67, 189, 194, 123, 74, 102, 173, 112, 55]), SecretKey([208, 20, 77, 4, 58, 116, 176, 182, 161, 34, 235, 111, 210, 244, 59, 95, 19, 226, 116, 123, 230, 58, 178, 226, 185, 33, 88, 16, 131, 3, 91, 124]), Seed([250, 70, 212, 165, 191, 178, 20, 66, 227, 38, 8, 108, 141, 73, 229, 49, 137, 99, 41, 78, 187, 57, 98, 207, 186, 166, 5, 99, 194, 240, 107, 222]));
/// AKS: GDAKS2226AQIYXT2ZBCS2MW4FM4CYFLA2KRT4NKVZZ2WI2MVIHUOT2MI
static immutable AKS = KeyPair(PublicKey([192, 169, 107, 90, 240, 32, 140, 94, 122, 200, 69, 45, 50, 220, 43, 56, 44, 21, 96, 210, 163, 62, 53, 85, 206, 117, 100, 105, 149, 65, 232, 233]), SecretKey([32, 126, 236, 102, 166, 170, 193, 71, 203, 183, 234, 150, 183, 149, 51, 8, 187, 252, 255, 84, 154, 163, 204, 1, 116, 107, 102, 220, 35, 222, 171, 69]), Seed([8, 230, 75, 13, 80, 103, 19, 206, 253, 52, 22, 21, 250, 85, 159, 30, 161, 118, 206, 51, 181, 9, 42, 177, 201, 105, 152, 229, 119, 218, 1, 210]));
/// AKT: GDAKT222YUEUKYWNDV7ZL27QKNHCENIU2YDS3ZDIXKTIHURA77VL6I4G
static immutable AKT = KeyPair(PublicKey([192, 169, 235, 90, 197, 9, 69, 98, 205, 29, 127, 149, 235, 240, 83, 78, 34, 53, 20, 214, 7, 45, 228, 104, 186, 166, 131, 210, 32, 255, 234, 191]), SecretKey([112, 254, 142, 207, 127, 97, 8, 186, 35, 126, 26, 16, 30, 63, 90, 48, 65, 244, 85, 211, 27, 2, 15, 159, 180, 174, 164, 151, 156, 180, 129, 73]), Seed([16, 148, 46, 146, 100, 197, 197, 19, 30, 157, 8, 0, 159, 172, 169, 251, 11, 230, 98, 167, 22, 107, 142, 92, 105, 149, 148, 132, 221, 140, 239, 211]));
/// AKU: GDAKU22YEJMLPA473ILPP2445FAW6TW5DGWEPL2ZPQUTYO322YXL4CIM
static immutable AKU = KeyPair(PublicKey([192, 170, 107, 88, 34, 88, 183, 131, 159, 218, 22, 247, 235, 156, 233, 65, 111, 78, 221, 25, 172, 71, 175, 89, 124, 41, 60, 59, 122, 214, 46, 190]), SecretKey([168, 239, 171, 160, 159, 250, 68, 139, 191, 155, 136, 219, 244, 182, 92, 147, 151, 83, 225, 89, 41, 68, 155, 157, 171, 203, 52, 18, 32, 56, 241, 105]), Seed([34, 240, 200, 158, 85, 253, 241, 71, 180, 129, 150, 131, 246, 59, 10, 69, 5, 125, 144, 115, 236, 48, 47, 164, 254, 69, 68, 74, 63, 66, 114, 47]));
/// AKV: GDAKV22DRLHTKNAPTK2H3HT3OGYXOVLT5IOKTZ2U7PPLYOTT6OCSQYV2
static immutable AKV = KeyPair(PublicKey([192, 170, 235, 67, 138, 207, 53, 52, 15, 154, 180, 125, 158, 123, 113, 177, 119, 85, 115, 234, 28, 169, 231, 84, 251, 222, 188, 58, 115, 243, 133, 40]), SecretKey([96, 245, 180, 247, 155, 39, 21, 175, 121, 95, 42, 175, 147, 225, 67, 124, 126, 240, 217, 112, 38, 142, 88, 91, 1, 61, 191, 77, 171, 20, 89, 100]), Seed([1, 255, 97, 134, 51, 204, 2, 191, 219, 180, 62, 3, 255, 114, 89, 102, 1, 226, 97, 129, 142, 120, 117, 253, 181, 252, 111, 25, 182, 45, 150, 250]));
/// AKW: GDAKW22DDIRN5FYAP7JWABSUVAKZEZZY4MD6TPZYJYWHR3RYMERGZ5RR
static immutable AKW = KeyPair(PublicKey([192, 171, 107, 67, 26, 34, 222, 151, 0, 127, 211, 96, 6, 84, 168, 21, 146, 103, 56, 227, 7, 233, 191, 56, 78, 44, 120, 238, 56, 97, 34, 108]), SecretKey([160, 185, 76, 14, 43, 68, 245, 230, 205, 222, 162, 77, 41, 96, 214, 100, 69, 85, 233, 127, 81, 78, 60, 70, 178, 180, 22, 231, 93, 76, 164, 66]), Seed([132, 144, 79, 34, 250, 169, 191, 167, 95, 138, 66, 238, 154, 179, 35, 219, 47, 227, 137, 43, 254, 18, 11, 158, 150, 1, 90, 19, 141, 132, 30, 130]));
/// AKX: GDAKX22WJRFRFLXKHXXJ4RYMXT2UY4NTMTBPYMFLMT5GZVES75X6E3TB
static immutable AKX = KeyPair(PublicKey([192, 171, 235, 86, 76, 75, 18, 174, 234, 61, 238, 158, 71, 12, 188, 245, 76, 113, 179, 100, 194, 252, 48, 171, 100, 250, 108, 212, 146, 255, 111, 226]), SecretKey([136, 95, 222, 230, 53, 78, 182, 120, 22, 185, 45, 156, 69, 40, 94, 38, 231, 121, 117, 238, 104, 28, 8, 16, 105, 190, 64, 31, 223, 183, 198, 121]), Seed([227, 135, 90, 201, 229, 218, 180, 58, 31, 122, 130, 49, 227, 96, 158, 178, 230, 215, 164, 79, 218, 151, 168, 187, 69, 215, 19, 238, 168, 217, 140, 23]));
/// AKY: GDAKY22WDFZ4QTUDDJVMKJROWB4AFFKBC7EVEKXNDD6ZZKYIQEPGK4BP
static immutable AKY = KeyPair(PublicKey([192, 172, 107, 86, 25, 115, 200, 78, 131, 26, 106, 197, 38, 46, 176, 120, 2, 149, 65, 23, 201, 82, 42, 237, 24, 253, 156, 171, 8, 129, 30, 101]), SecretKey([136, 115, 117, 158, 110, 126, 211, 111, 165, 89, 44, 49, 244, 30, 34, 49, 149, 20, 213, 182, 68, 234, 208, 228, 30, 10, 198, 227, 80, 104, 219, 92]), Seed([188, 155, 179, 254, 165, 76, 141, 204, 30, 184, 27, 107, 195, 160, 65, 34, 240, 152, 59, 165, 243, 165, 18, 61, 247, 180, 172, 2, 106, 192, 203, 81]));
/// AKZ: GDAKZ22EWVON2UJYKURU6V4L7V6CT3ZLTLOUHEPTQSOMFOSRLG7MQC45
static immutable AKZ = KeyPair(PublicKey([192, 172, 235, 68, 181, 92, 221, 81, 56, 85, 35, 79, 87, 139, 253, 124, 41, 239, 43, 154, 221, 67, 145, 243, 132, 156, 194, 186, 81, 89, 190, 200]), SecretKey([112, 78, 82, 124, 48, 242, 245, 165, 25, 164, 51, 183, 70, 203, 164, 47, 172, 29, 133, 68, 172, 244, 66, 48, 12, 43, 241, 51, 9, 96, 150, 116]), Seed([246, 71, 138, 83, 91, 125, 81, 247, 41, 175, 39, 216, 62, 50, 212, 89, 175, 128, 75, 173, 178, 8, 135, 150, 15, 171, 62, 198, 63, 190, 140, 56]));
/// ALA: GDALA22Y2DT7YO6TS7GHKDA5CTPXGXSV5WEOH3RGAGXMFHQJXCCVUKFU
static immutable ALA = KeyPair(PublicKey([192, 176, 107, 88, 208, 231, 252, 59, 211, 151, 204, 117, 12, 29, 20, 223, 115, 94, 85, 237, 136, 227, 238, 38, 1, 174, 194, 158, 9, 184, 133, 90]), SecretKey([200, 42, 179, 215, 41, 231, 28, 119, 255, 212, 79, 30, 231, 118, 195, 214, 215, 210, 134, 14, 47, 90, 112, 175, 158, 227, 125, 77, 22, 74, 252, 114]), Seed([160, 199, 88, 155, 13, 134, 104, 148, 31, 23, 95, 50, 215, 251, 116, 64, 179, 229, 132, 100, 76, 25, 159, 154, 123, 29, 157, 15, 240, 116, 174, 22]));
/// ALB: GDALB22DEKUKDXKK3U6PSJTJESCULRJVZ462PON774G7HBTO4OPW3USF
static immutable ALB = KeyPair(PublicKey([192, 176, 235, 67, 34, 168, 161, 221, 74, 221, 60, 249, 38, 105, 36, 133, 69, 197, 53, 207, 61, 167, 185, 191, 255, 13, 243, 134, 110, 227, 159, 109]), SecretKey([128, 62, 235, 228, 239, 129, 201, 94, 169, 107, 25, 9, 44, 150, 31, 190, 231, 151, 4, 248, 54, 214, 72, 83, 34, 158, 18, 123, 216, 81, 111, 77]), Seed([63, 115, 191, 139, 24, 136, 143, 161, 21, 147, 109, 47, 38, 50, 144, 76, 216, 2, 155, 112, 18, 34, 230, 224, 99, 1, 100, 212, 1, 228, 115, 223]));
/// ALC: GDALC222WZFNYMI66DKJ6PV34O644SMRRVPCF7HKN2NQDOTU3GSHQYX6
static immutable ALC = KeyPair(PublicKey([192, 177, 107, 90, 182, 74, 220, 49, 30, 240, 212, 159, 62, 187, 227, 189, 206, 73, 145, 141, 94, 34, 252, 234, 110, 155, 1, 186, 116, 217, 164, 120]), SecretKey([184, 112, 236, 248, 222, 30, 249, 170, 86, 91, 178, 125, 20, 118, 171, 141, 166, 61, 52, 39, 4, 218, 54, 65, 79, 133, 6, 167, 52, 186, 62, 74]), Seed([62, 175, 247, 80, 118, 64, 138, 126, 177, 231, 183, 88, 116, 224, 145, 70, 14, 186, 35, 164, 184, 12, 131, 155, 5, 233, 25, 128, 205, 192, 99, 156]));
/// ALD: GDALD22DI23OV6GHJ5JG7HBI7PB4FU7NQTUCN5ABVE4TGZ623QMGEZJO
static immutable ALD = KeyPair(PublicKey([192, 177, 235, 67, 70, 182, 234, 248, 199, 79, 82, 111, 156, 40, 251, 195, 194, 211, 237, 132, 232, 38, 244, 1, 169, 57, 51, 103, 218, 220, 24, 98]), SecretKey([192, 115, 237, 24, 132, 85, 143, 204, 34, 112, 156, 125, 82, 198, 116, 79, 0, 213, 200, 167, 252, 48, 24, 225, 140, 235, 83, 12, 192, 16, 100, 87]), Seed([109, 172, 49, 47, 203, 199, 82, 123, 59, 203, 117, 247, 92, 127, 170, 163, 83, 181, 32, 121, 219, 70, 217, 156, 107, 205, 248, 65, 62, 68, 141, 210]));
/// ALE: GDALE22JMCPTJJGKOR5VELFBU5F7N2PUYUZEI65KGJF4JIGXZAQ6EN4D
static immutable ALE = KeyPair(PublicKey([192, 178, 107, 73, 96, 159, 52, 164, 202, 116, 123, 82, 44, 161, 167, 75, 246, 233, 244, 197, 50, 68, 123, 170, 50, 75, 196, 160, 215, 200, 33, 226]), SecretKey([80, 212, 228, 13, 145, 217, 4, 151, 250, 226, 163, 240, 205, 252, 50, 216, 58, 243, 171, 93, 27, 74, 48, 71, 218, 134, 66, 218, 164, 51, 33, 120]), Seed([6, 42, 122, 84, 9, 48, 37, 9, 225, 51, 55, 122, 123, 185, 221, 73, 235, 221, 117, 174, 138, 120, 119, 83, 229, 25, 253, 60, 111, 158, 5, 122]));
/// ALF: GDALF22LW7VJJC7PFCFV5IPTECHJTOUTSB2XU6VUPDJLNFYSFSW36UX2
static immutable ALF = KeyPair(PublicKey([192, 178, 235, 75, 183, 234, 148, 139, 239, 40, 139, 94, 161, 243, 32, 142, 153, 186, 147, 144, 117, 122, 122, 180, 120, 210, 182, 151, 18, 44, 173, 191]), SecretKey([96, 31, 85, 174, 127, 247, 129, 193, 0, 217, 32, 240, 87, 46, 12, 96, 80, 48, 106, 164, 24, 191, 67, 134, 163, 114, 11, 243, 210, 40, 37, 105]), Seed([197, 4, 205, 253, 56, 253, 142, 40, 17, 128, 230, 4, 34, 88, 172, 214, 37, 163, 221, 188, 222, 100, 164, 6, 177, 156, 179, 95, 100, 180, 163, 187]));
/// ALG: GDALG22R4WJQ52RPZ6IMR5ISEVALELY52LRNDKHEBLXMSTKKJA5QXPKX
static immutable ALG = KeyPair(PublicKey([192, 179, 107, 81, 229, 147, 14, 234, 47, 207, 144, 200, 245, 18, 37, 64, 178, 47, 29, 210, 226, 209, 168, 228, 10, 238, 201, 77, 74, 72, 59, 11]), SecretKey([208, 199, 53, 137, 199, 251, 116, 59, 144, 138, 29, 136, 242, 43, 55, 30, 136, 125, 60, 163, 19, 45, 141, 52, 68, 179, 74, 228, 79, 83, 85, 95]), Seed([185, 146, 152, 143, 58, 95, 249, 40, 252, 89, 63, 9, 84, 110, 18, 236, 234, 204, 184, 252, 165, 118, 115, 121, 45, 216, 169, 232, 42, 4, 140, 175]));
/// ALH: GDALH22F2E7Y5IEBKL4ZK6HZYKAHQXYKX6T63ZAWDTCO2GZX5JR54K4N
static immutable ALH = KeyPair(PublicKey([192, 179, 235, 69, 209, 63, 142, 160, 129, 82, 249, 149, 120, 249, 194, 128, 120, 95, 10, 191, 167, 237, 228, 22, 28, 196, 237, 27, 55, 234, 99, 222]), SecretKey([24, 40, 10, 60, 124, 191, 86, 86, 86, 181, 235, 43, 186, 123, 206, 201, 110, 66, 174, 132, 42, 84, 246, 81, 66, 12, 144, 10, 252, 109, 55, 66]), Seed([186, 118, 194, 224, 212, 161, 167, 214, 53, 107, 156, 203, 24, 243, 7, 145, 153, 242, 26, 122, 53, 43, 162, 112, 74, 99, 31, 59, 167, 255, 22, 43]));
/// ALI: GDALI22CXW2RZTGAHVE2SXS3R6BARRS5L47G6G7SRVSFZLKTUQCSQUTY
static immutable ALI = KeyPair(PublicKey([192, 180, 107, 66, 189, 181, 28, 204, 192, 61, 73, 169, 94, 91, 143, 130, 8, 198, 93, 95, 62, 111, 27, 242, 141, 100, 92, 173, 83, 164, 5, 40]), SecretKey([240, 220, 220, 182, 253, 77, 102, 109, 127, 10, 158, 45, 245, 203, 135, 40, 66, 0, 224, 200, 188, 74, 74, 90, 38, 244, 58, 117, 190, 212, 228, 112]), Seed([163, 154, 103, 183, 142, 59, 213, 221, 33, 95, 157, 4, 160, 13, 19, 68, 156, 60, 144, 130, 49, 91, 204, 225, 62, 197, 61, 179, 234, 112, 63, 250]));
/// ALJ: GDALJ223DRJKJIHXAH2YJ5D2VFJJVWASKUWYRJG2KFDRATAROO5DUWAT
static immutable ALJ = KeyPair(PublicKey([192, 180, 235, 91, 28, 82, 164, 160, 247, 1, 245, 132, 244, 122, 169, 82, 154, 216, 18, 85, 45, 136, 164, 218, 81, 71, 16, 76, 17, 115, 186, 58]), SecretKey([152, 192, 75, 16, 135, 189, 213, 168, 230, 238, 40, 16, 114, 15, 37, 70, 53, 247, 97, 52, 193, 182, 15, 116, 232, 47, 240, 86, 171, 161, 93, 117]), Seed([119, 255, 240, 9, 232, 88, 170, 185, 122, 178, 230, 124, 149, 23, 226, 215, 23, 95, 92, 146, 109, 127, 69, 78, 50, 246, 20, 69, 186, 47, 107, 137]));
/// ALK: GDALK22MKPYNZHAUNWHTIH5A5NN2WDHAG7SGSMJB27GMTJSVEBSOZJTK
static immutable ALK = KeyPair(PublicKey([192, 181, 107, 76, 83, 240, 220, 156, 20, 109, 143, 52, 31, 160, 235, 91, 171, 12, 224, 55, 228, 105, 49, 33, 215, 204, 201, 166, 85, 32, 100, 236]), SecretKey([160, 52, 158, 131, 147, 82, 195, 43, 255, 123, 107, 181, 10, 226, 13, 141, 183, 28, 106, 80, 55, 59, 169, 76, 232, 204, 77, 95, 128, 165, 218, 64]), Seed([12, 15, 200, 129, 10, 207, 31, 41, 28, 189, 201, 81, 124, 191, 66, 164, 111, 88, 60, 52, 30, 196, 57, 191, 216, 170, 160, 19, 202, 234, 157, 45]));
/// ALL: GDALL224J6A2S2ZGZXAQJVYGYZIC5PBKNMPQ2IZANNWLASYZTI6AS4QI
static immutable ALL = KeyPair(PublicKey([192, 181, 235, 92, 79, 129, 169, 107, 38, 205, 193, 4, 215, 6, 198, 80, 46, 188, 42, 107, 31, 13, 35, 32, 107, 108, 176, 75, 25, 154, 60, 9]), SecretKey([24, 30, 116, 249, 104, 236, 119, 145, 153, 65, 200, 178, 42, 31, 65, 250, 113, 85, 77, 161, 229, 21, 152, 140, 32, 226, 128, 119, 109, 47, 155, 74]), Seed([61, 53, 37, 227, 14, 107, 106, 223, 79, 122, 175, 153, 177, 136, 40, 227, 244, 109, 216, 205, 76, 84, 101, 193, 234, 102, 72, 50, 249, 25, 194, 249]));
/// ALM: GDALM22GIG4VBBQIHUPEXWW637NJ6PI6PKM5PQT6EOOMKP3VASXVY4VS
static immutable ALM = KeyPair(PublicKey([192, 182, 107, 70, 65, 185, 80, 134, 8, 61, 30, 75, 218, 222, 223, 218, 159, 61, 30, 122, 153, 215, 194, 126, 35, 156, 197, 63, 117, 4, 175, 92]), SecretKey([160, 130, 100, 64, 68, 233, 26, 46, 165, 124, 13, 103, 103, 150, 250, 76, 127, 251, 140, 12, 219, 150, 143, 153, 215, 133, 180, 139, 194, 205, 95, 125]), Seed([223, 60, 33, 135, 107, 107, 67, 103, 98, 188, 93, 157, 147, 108, 47, 158, 208, 64, 50, 102, 47, 85, 178, 214, 154, 58, 164, 231, 131, 24, 114, 217]));
/// ALN: GDALN222CLNGMPFS2FIE6EIKZKZPWDDZHFWEYKM6J3M4LQSIZPEGYOBX
static immutable ALN = KeyPair(PublicKey([192, 182, 235, 90, 18, 218, 102, 60, 178, 209, 80, 79, 17, 10, 202, 178, 251, 12, 121, 57, 108, 76, 41, 158, 78, 217, 197, 194, 72, 203, 200, 108]), SecretKey([88, 75, 16, 173, 212, 218, 169, 110, 137, 73, 21, 107, 202, 4, 32, 186, 187, 253, 80, 105, 73, 6, 243, 62, 135, 46, 41, 7, 76, 205, 132, 120]), Seed([152, 158, 79, 200, 130, 156, 40, 183, 168, 77, 93, 53, 117, 46, 169, 81, 21, 16, 127, 243, 140, 196, 55, 128, 116, 190, 71, 140, 92, 40, 97, 99]));
/// ALO: GDALO22US2PNY3JSVGYM4VLGMVQYF763N6ZNVG3ZQC5KXZNROHDYZ7B4
static immutable ALO = KeyPair(PublicKey([192, 183, 107, 84, 150, 158, 220, 109, 50, 169, 176, 206, 85, 102, 101, 97, 130, 255, 219, 111, 178, 218, 155, 121, 128, 186, 171, 229, 177, 113, 199, 140]), SecretKey([104, 138, 200, 103, 3, 155, 16, 34, 118, 91, 234, 198, 111, 40, 125, 182, 213, 206, 114, 80, 229, 254, 183, 154, 0, 26, 93, 63, 24, 145, 46, 120]), Seed([31, 177, 134, 154, 171, 130, 166, 168, 124, 88, 25, 22, 100, 90, 132, 162, 61, 112, 119, 179, 74, 118, 41, 108, 33, 115, 251, 0, 144, 87, 103, 211]));
/// ALP: GDALP22AQV2VQLKZRYKXMHUC6C7MLI6KG6D6EG5LLB2Z6YTBHNUQUNKM
static immutable ALP = KeyPair(PublicKey([192, 183, 235, 64, 133, 117, 88, 45, 89, 142, 21, 118, 30, 130, 240, 190, 197, 163, 202, 55, 135, 226, 27, 171, 88, 117, 159, 98, 97, 59, 105, 10]), SecretKey([200, 127, 244, 114, 115, 247, 95, 90, 52, 194, 218, 100, 240, 119, 119, 33, 225, 23, 88, 135, 108, 220, 189, 24, 218, 107, 73, 248, 86, 220, 215, 92]), Seed([202, 246, 179, 155, 188, 170, 74, 156, 186, 47, 217, 102, 193, 25, 230, 243, 218, 141, 162, 245, 130, 216, 58, 76, 243, 207, 23, 76, 151, 227, 25, 186]));
/// ALQ: GDALQ227KQXA7MU5NRWYCVYNVOKMFV6NVFJY44JBCWKOJ6H5VWR57TGR
static immutable ALQ = KeyPair(PublicKey([192, 184, 107, 95, 84, 46, 15, 178, 157, 108, 109, 129, 87, 13, 171, 148, 194, 215, 205, 169, 83, 142, 113, 33, 21, 148, 228, 248, 253, 173, 163, 223]), SecretKey([200, 220, 198, 216, 37, 209, 207, 46, 102, 147, 36, 123, 120, 211, 254, 227, 69, 239, 177, 1, 246, 173, 234, 115, 167, 153, 89, 1, 24, 1, 84, 101]), Seed([232, 235, 244, 209, 92, 129, 77, 94, 89, 53, 99, 210, 96, 75, 104, 235, 50, 41, 188, 9, 80, 185, 44, 85, 87, 179, 234, 237, 65, 107, 194, 220]));
/// ALR: GDALR22YSP2C4EEV5YF6LXBSYC53BELYRI3B6JZB6T7RSEPGQ3VV3GOR
static immutable ALR = KeyPair(PublicKey([192, 184, 235, 88, 147, 244, 46, 16, 149, 238, 11, 229, 220, 50, 192, 187, 176, 145, 120, 138, 54, 31, 39, 33, 244, 255, 25, 17, 230, 134, 235, 93]), SecretKey([8, 127, 133, 159, 120, 151, 172, 162, 123, 173, 88, 62, 79, 143, 16, 213, 48, 67, 119, 76, 21, 73, 237, 89, 167, 98, 1, 184, 209, 158, 51, 73]), Seed([77, 21, 126, 206, 12, 106, 96, 219, 245, 113, 164, 19, 12, 82, 177, 61, 228, 92, 131, 247, 229, 78, 3, 56, 61, 141, 118, 161, 157, 67, 130, 214]));
/// ALS: GDALS22SFEEG7RU62UPVTPFX5L6UE56YYCLVZ3IW5EQCDOQP7M6G7N43
static immutable ALS = KeyPair(PublicKey([192, 185, 107, 82, 41, 8, 111, 198, 158, 213, 31, 89, 188, 183, 234, 253, 66, 119, 216, 192, 151, 92, 237, 22, 233, 32, 33, 186, 15, 251, 60, 111]), SecretKey([16, 237, 49, 17, 10, 158, 8, 250, 178, 243, 42, 231, 55, 209, 108, 66, 107, 217, 17, 240, 80, 80, 100, 95, 82, 163, 101, 201, 204, 3, 235, 81]), Seed([150, 233, 244, 197, 83, 179, 119, 188, 172, 36, 78, 6, 136, 157, 88, 9, 172, 13, 67, 192, 254, 29, 79, 18, 156, 202, 64, 171, 6, 183, 85, 67]));
/// ALT: GDALT22IX7WGIDUWUIMI4B2G3ZBATIEWHIMTTMLEPMNSELI6YLROUF27
static immutable ALT = KeyPair(PublicKey([192, 185, 235, 72, 191, 236, 100, 14, 150, 162, 24, 142, 7, 70, 222, 66, 9, 160, 150, 58, 25, 57, 177, 100, 123, 27, 34, 45, 30, 194, 226, 234]), SecretKey([32, 219, 254, 130, 132, 51, 140, 84, 221, 17, 21, 12, 128, 220, 83, 122, 15, 139, 149, 169, 15, 5, 188, 117, 65, 132, 187, 165, 71, 101, 127, 75]), Seed([225, 209, 43, 92, 45, 238, 44, 42, 128, 219, 181, 58, 56, 134, 158, 190, 68, 83, 63, 83, 148, 125, 188, 219, 98, 244, 107, 146, 248, 207, 251, 112]));
/// ALU: GDALU22D7HEUYVTWYTXRCBXH2FVLLJIFIQNLC3DTSYRDB5IUJEYJRD7D
static immutable ALU = KeyPair(PublicKey([192, 186, 107, 67, 249, 201, 76, 86, 118, 196, 239, 17, 6, 231, 209, 106, 181, 165, 5, 68, 26, 177, 108, 115, 150, 34, 48, 245, 20, 73, 48, 152]), SecretKey([160, 10, 89, 158, 233, 231, 121, 172, 36, 161, 2, 149, 10, 234, 190, 181, 194, 227, 217, 243, 0, 17, 68, 98, 72, 55, 26, 238, 7, 157, 142, 123]), Seed([114, 80, 195, 118, 144, 63, 10, 235, 167, 15, 10, 120, 35, 236, 95, 172, 6, 30, 142, 15, 71, 183, 92, 186, 20, 24, 34, 82, 227, 235, 147, 73]));
/// ALV: GDALV22LVN22O3CKILLVGU33OA46M4Y3QWUMAERUHEIQMFQYIB4KAVQ7
static immutable ALV = KeyPair(PublicKey([192, 186, 235, 75, 171, 117, 167, 108, 74, 66, 215, 83, 83, 123, 112, 57, 230, 115, 27, 133, 168, 192, 18, 52, 57, 17, 6, 22, 24, 64, 120, 160]), SecretKey([152, 126, 82, 167, 37, 143, 88, 236, 62, 47, 73, 146, 155, 0, 93, 147, 206, 18, 135, 34, 104, 217, 80, 177, 170, 80, 220, 118, 103, 118, 196, 67]), Seed([165, 184, 13, 249, 93, 216, 82, 79, 189, 30, 58, 132, 77, 154, 82, 206, 150, 228, 29, 206, 255, 82, 19, 134, 23, 21, 123, 180, 128, 187, 142, 71]));
/// ALW: GDALW22GBHJ6VKPMKB35AOJTASCIYYR6OSQFJDTT6TWBSR6PLTSBZACP
static immutable ALW = KeyPair(PublicKey([192, 187, 107, 70, 9, 211, 234, 169, 236, 80, 119, 208, 57, 51, 4, 132, 140, 98, 62, 116, 160, 84, 142, 115, 244, 236, 25, 71, 207, 92, 228, 28]), SecretKey([88, 34, 254, 163, 74, 53, 136, 129, 248, 13, 246, 155, 137, 49, 52, 68, 175, 116, 23, 101, 9, 31, 11, 4, 13, 171, 10, 41, 162, 190, 195, 105]), Seed([69, 29, 9, 155, 245, 101, 187, 234, 8, 174, 35, 195, 135, 28, 109, 138, 3, 248, 70, 225, 244, 37, 120, 78, 36, 78, 16, 249, 113, 51, 114, 213]));
/// ALX: GDALX22VYK2R4TXIOXSUZCLTE2OFNPEEUZVWI5V2F2RQZVSR4GGEAK4P
static immutable ALX = KeyPair(PublicKey([192, 187, 235, 85, 194, 181, 30, 78, 232, 117, 229, 76, 137, 115, 38, 156, 86, 188, 132, 166, 107, 100, 118, 186, 46, 163, 12, 214, 81, 225, 140, 64]), SecretKey([96, 7, 131, 69, 54, 43, 143, 211, 83, 86, 176, 240, 226, 35, 178, 53, 188, 248, 68, 106, 131, 133, 91, 159, 125, 237, 184, 240, 210, 75, 93, 115]), Seed([103, 132, 58, 42, 115, 90, 98, 88, 249, 183, 161, 203, 62, 220, 3, 196, 152, 37, 22, 57, 245, 50, 115, 179, 26, 107, 101, 199, 255, 64, 18, 69]));
/// ALY: GDALY22OSRYDDSHYMEULCQQX3NVZZFUAUHMXQB6UVMRKYR3OGNHB3P6Y
static immutable ALY = KeyPair(PublicKey([192, 188, 107, 78, 148, 112, 49, 200, 248, 97, 40, 177, 66, 23, 219, 107, 156, 150, 128, 161, 217, 120, 7, 212, 171, 34, 172, 71, 110, 51, 78, 29]), SecretKey([128, 167, 148, 194, 145, 238, 139, 97, 123, 15, 124, 89, 200, 116, 7, 210, 254, 251, 135, 5, 216, 81, 21, 64, 7, 171, 81, 110, 94, 222, 132, 97]), Seed([164, 139, 25, 36, 103, 4, 66, 89, 27, 28, 151, 139, 21, 157, 9, 235, 10, 152, 175, 44, 21, 37, 186, 151, 12, 40, 140, 85, 166, 123, 103, 135]));
/// ALZ: GDALZ22QJPRED22UT5RE7DFPTJA4CFYGDVQ764BYMFD7FTONCL4QYNXD
static immutable ALZ = KeyPair(PublicKey([192, 188, 235, 80, 75, 226, 65, 235, 84, 159, 98, 79, 140, 175, 154, 65, 193, 23, 6, 29, 97, 255, 112, 56, 97, 71, 242, 205, 205, 18, 249, 12]), SecretKey([64, 240, 96, 10, 238, 50, 172, 196, 34, 168, 215, 50, 6, 114, 237, 1, 9, 23, 136, 134, 42, 140, 130, 65, 255, 122, 232, 49, 91, 231, 230, 118]), Seed([57, 120, 188, 9, 62, 77, 160, 79, 233, 155, 81, 235, 213, 187, 94, 88, 241, 30, 161, 10, 113, 165, 29, 232, 182, 146, 68, 26, 57, 193, 135, 13]));
/// AMA: GDAMA22J4PGXDCHDDFADHXK5FRZHGXG7OBY3RA7ZWULIRNIRAX2FAAG2
static immutable AMA = KeyPair(PublicKey([192, 192, 107, 73, 227, 205, 113, 136, 227, 25, 64, 51, 221, 93, 44, 114, 115, 92, 223, 112, 113, 184, 131, 249, 181, 22, 136, 181, 17, 5, 244, 80]), SecretKey([32, 164, 223, 193, 238, 154, 168, 97, 115, 179, 181, 7, 36, 65, 76, 182, 1, 168, 115, 143, 221, 115, 234, 26, 144, 229, 88, 209, 250, 136, 221, 70]), Seed([100, 148, 233, 236, 48, 29, 238, 95, 112, 35, 107, 39, 217, 225, 193, 185, 18, 6, 18, 143, 33, 137, 103, 241, 73, 226, 220, 146, 169, 74, 75, 182]));
/// AMB: GDAMB22XEB6EWANXZRKPK7IFPTSCD37VQLPIT3FAJX2SUUVBCGV4YBLL
static immutable AMB = KeyPair(PublicKey([192, 192, 235, 87, 32, 124, 75, 1, 183, 204, 84, 245, 125, 5, 124, 228, 33, 239, 245, 130, 222, 137, 236, 160, 77, 245, 42, 82, 161, 17, 171, 204]), SecretKey([40, 82, 180, 208, 96, 216, 243, 242, 136, 74, 224, 92, 172, 41, 240, 127, 51, 242, 65, 121, 4, 160, 66, 143, 129, 96, 103, 152, 232, 119, 146, 112]), Seed([22, 231, 231, 227, 235, 132, 37, 153, 250, 191, 70, 218, 249, 75, 2, 93, 137, 97, 207, 183, 232, 171, 117, 17, 182, 116, 190, 171, 29, 162, 103, 30]));
/// AMC: GDAMC224M2DVLKEEULGLGEONHHVPRDMGL3QWISXKYDDPBZACKOEIWJMD
static immutable AMC = KeyPair(PublicKey([192, 193, 107, 92, 102, 135, 85, 168, 132, 162, 204, 179, 17, 205, 57, 234, 248, 141, 134, 94, 225, 100, 74, 234, 192, 198, 240, 228, 2, 83, 136, 139]), SecretKey([224, 75, 208, 86, 18, 151, 181, 58, 194, 18, 167, 251, 190, 236, 116, 125, 85, 152, 176, 103, 213, 157, 80, 62, 110, 203, 42, 165, 162, 37, 246, 92]), Seed([252, 248, 54, 52, 126, 141, 190, 41, 125, 195, 210, 227, 245, 22, 7, 196, 200, 200, 148, 87, 241, 77, 38, 199, 212, 74, 10, 111, 222, 136, 149, 196]));
/// AMD: GDAMD22CLQYQMGTHVSR3ANNCLDWAM25XQHU4QG3PZ7MNL4YDU5265GFL
static immutable AMD = KeyPair(PublicKey([192, 193, 235, 66, 92, 49, 6, 26, 103, 172, 163, 176, 53, 162, 88, 236, 6, 107, 183, 129, 233, 200, 27, 111, 207, 216, 213, 243, 3, 167, 117, 238]), SecretKey([160, 225, 66, 192, 167, 73, 149, 77, 169, 118, 118, 129, 228, 35, 19, 116, 79, 196, 154, 58, 68, 155, 196, 250, 148, 92, 46, 104, 231, 240, 201, 65]), Seed([12, 168, 79, 174, 65, 220, 70, 95, 223, 160, 34, 76, 171, 231, 187, 50, 52, 45, 79, 102, 214, 148, 90, 233, 113, 67, 116, 14, 130, 196, 71, 26]));
/// AME: GDAME22M6QAQH3CUHKTO4UZK6UXNSXGMIP2XLFGO3RXWR44JEXYGIMLI
static immutable AME = KeyPair(PublicKey([192, 194, 107, 76, 244, 1, 3, 236, 84, 58, 166, 238, 83, 42, 245, 46, 217, 92, 204, 67, 245, 117, 148, 206, 220, 111, 104, 243, 137, 37, 240, 100]), SecretKey([208, 35, 157, 222, 237, 144, 203, 207, 186, 25, 55, 45, 69, 3, 78, 214, 146, 66, 235, 223, 190, 30, 6, 182, 103, 81, 198, 25, 208, 99, 41, 94]), Seed([103, 221, 219, 209, 150, 246, 45, 88, 48, 51, 228, 148, 117, 172, 181, 13, 152, 39, 6, 194, 42, 220, 118, 117, 113, 140, 199, 131, 63, 234, 86, 186]));
/// AMF: GDAMF22W32YDE3XB5T7DGPZHCZ5Z6EF5XJNBSGEWQRSRUTBBN3FJ4EKZ
static immutable AMF = KeyPair(PublicKey([192, 194, 235, 86, 222, 176, 50, 110, 225, 236, 254, 51, 63, 39, 22, 123, 159, 16, 189, 186, 90, 25, 24, 150, 132, 101, 26, 76, 33, 110, 202, 158]), SecretKey([80, 128, 66, 101, 15, 169, 26, 50, 144, 198, 139, 93, 108, 204, 107, 72, 47, 154, 220, 19, 58, 189, 224, 66, 136, 180, 49, 32, 185, 206, 231, 93]), Seed([46, 238, 71, 34, 210, 59, 154, 55, 13, 70, 160, 53, 133, 148, 231, 51, 30, 254, 142, 77, 229, 173, 52, 175, 245, 191, 163, 68, 220, 41, 79, 37]));
/// AMG: GDAMG22Q6EYKK64VRRRIWR6475UIATR54K2RBOPHIY2ID5PYMRZJOWTY
static immutable AMG = KeyPair(PublicKey([192, 195, 107, 80, 241, 48, 165, 123, 149, 140, 98, 139, 71, 220, 255, 104, 128, 78, 61, 226, 181, 16, 185, 231, 70, 52, 129, 245, 248, 100, 114, 151]), SecretKey([168, 42, 172, 143, 208, 47, 147, 230, 167, 11, 48, 232, 72, 127, 111, 88, 244, 80, 120, 103, 188, 8, 254, 170, 60, 87, 36, 148, 43, 110, 98, 101]), Seed([15, 99, 184, 64, 213, 101, 161, 93, 101, 46, 233, 236, 99, 142, 117, 104, 170, 79, 120, 124, 57, 249, 103, 216, 110, 103, 102, 223, 106, 106, 70, 245]));
/// AMH: GDAMH22EE3TUPMAWK5LJIQ6HNMAO53LK3YKWRVPI6GWYDD5CNJLZF2C6
static immutable AMH = KeyPair(PublicKey([192, 195, 235, 68, 38, 231, 71, 176, 22, 87, 86, 148, 67, 199, 107, 0, 238, 237, 106, 222, 21, 104, 213, 232, 241, 173, 129, 143, 162, 106, 87, 146]), SecretKey([208, 100, 187, 242, 40, 44, 71, 189, 214, 9, 177, 60, 0, 107, 118, 27, 28, 60, 93, 112, 218, 138, 220, 73, 210, 36, 123, 50, 21, 162, 243, 122]), Seed([199, 178, 22, 70, 173, 25, 58, 82, 10, 106, 195, 173, 105, 230, 150, 127, 81, 122, 77, 146, 46, 65, 250, 99, 133, 99, 15, 229, 8, 226, 178, 111]));
/// AMI: GDAMI22VXN7NT5BRTYSGSQK4MOXHOVSB42M3H4UQGXUVKOKCHJTTQA4R
static immutable AMI = KeyPair(PublicKey([192, 196, 107, 85, 187, 126, 217, 244, 49, 158, 36, 105, 65, 92, 99, 174, 119, 86, 65, 230, 153, 179, 242, 144, 53, 233, 85, 57, 66, 58, 103, 56]), SecretKey([184, 227, 153, 79, 76, 193, 97, 254, 7, 55, 105, 85, 239, 1, 201, 44, 69, 194, 124, 223, 162, 14, 125, 116, 119, 175, 183, 214, 20, 10, 169, 103]), Seed([57, 1, 176, 135, 98, 41, 84, 229, 190, 245, 170, 180, 26, 15, 138, 171, 230, 177, 182, 109, 123, 106, 163, 190, 157, 154, 86, 36, 137, 85, 172, 159]));
/// AMJ: GDAMJ22ES622Y5NYHDJ4SCV3OGPV4BGTXSZAEJPU2NCXDCMXIEHXAVAI
static immutable AMJ = KeyPair(PublicKey([192, 196, 235, 68, 151, 181, 172, 117, 184, 56, 211, 201, 10, 187, 113, 159, 94, 4, 211, 188, 178, 2, 37, 244, 211, 69, 113, 137, 151, 65, 15, 112]), SecretKey([136, 71, 16, 240, 152, 118, 31, 8, 170, 111, 200, 68, 2, 152, 6, 222, 66, 235, 86, 199, 141, 74, 112, 41, 234, 232, 121, 183, 191, 89, 135, 80]), Seed([36, 32, 236, 217, 227, 100, 53, 42, 40, 231, 47, 126, 82, 229, 63, 50, 203, 185, 36, 51, 174, 154, 173, 190, 10, 78, 227, 89, 225, 32, 183, 14]));
/// AMK: GDAMK225BAMYPIEZHXNZDENFFVBCJZTDSN33TP4A7SIM4LQM5HMTQVXG
static immutable AMK = KeyPair(PublicKey([192, 197, 107, 93, 8, 25, 135, 160, 153, 61, 219, 145, 145, 165, 45, 66, 36, 230, 99, 147, 119, 185, 191, 128, 252, 144, 206, 46, 12, 233, 217, 56]), SecretKey([240, 43, 169, 62, 95, 143, 178, 21, 236, 141, 248, 150, 101, 167, 147, 227, 10, 13, 173, 62, 153, 189, 13, 69, 39, 230, 63, 234, 97, 162, 155, 77]), Seed([38, 88, 68, 127, 152, 35, 150, 26, 211, 192, 137, 249, 20, 71, 140, 154, 29, 119, 44, 182, 39, 199, 221, 81, 190, 236, 182, 62, 86, 169, 192, 138]));
/// AML: GDAML22RPH2Z63Z547WFYMUKUJOQAGORGUT2LEUODPXZ2M7NNBD2QBYB
static immutable AML = KeyPair(PublicKey([192, 197, 235, 81, 121, 245, 159, 111, 61, 231, 236, 92, 50, 138, 162, 93, 0, 25, 209, 53, 39, 165, 146, 142, 27, 239, 157, 51, 237, 104, 71, 168]), SecretKey([72, 160, 122, 87, 167, 86, 99, 18, 189, 93, 73, 193, 208, 52, 174, 97, 37, 85, 77, 209, 41, 16, 58, 126, 210, 33, 155, 40, 73, 197, 80, 122]), Seed([225, 214, 184, 3, 204, 21, 90, 247, 157, 37, 77, 198, 28, 136, 114, 7, 249, 73, 111, 161, 162, 83, 123, 89, 119, 174, 7, 31, 21, 88, 153, 234]));
/// AMM: GDAMM22D45NAX7I2JFQR7BCR53XGFM2TUUGYIHRVO3TTUO3UIAPMQBU7
static immutable AMM = KeyPair(PublicKey([192, 198, 107, 67, 231, 90, 11, 253, 26, 73, 97, 31, 132, 81, 238, 238, 98, 179, 83, 165, 13, 132, 30, 53, 118, 231, 58, 59, 116, 64, 30, 200]), SecretKey([32, 48, 76, 134, 4, 126, 254, 120, 10, 2, 79, 230, 54, 250, 1, 227, 248, 194, 172, 100, 59, 86, 37, 111, 156, 249, 28, 32, 154, 171, 8, 96]), Seed([3, 74, 132, 114, 157, 216, 25, 168, 58, 181, 246, 53, 73, 247, 126, 162, 191, 210, 163, 207, 37, 44, 149, 134, 139, 140, 98, 136, 148, 162, 254, 137]));
/// AMN: GDAMN22GYROO4DFLWWJUZN6NAAQW2D65VXNSSDJGOM7BSMABTP5MVY2U
static immutable AMN = KeyPair(PublicKey([192, 198, 235, 70, 196, 92, 238, 12, 171, 181, 147, 76, 183, 205, 0, 33, 109, 15, 221, 173, 219, 41, 13, 38, 115, 62, 25, 48, 1, 155, 250, 202]), SecretKey([192, 247, 86, 230, 196, 17, 94, 37, 13, 210, 232, 28, 5, 4, 209, 192, 155, 188, 151, 230, 116, 197, 237, 244, 162, 189, 125, 212, 110, 143, 165, 105]), Seed([239, 177, 196, 163, 221, 242, 69, 53, 99, 13, 235, 213, 86, 199, 18, 224, 243, 110, 43, 234, 143, 78, 191, 89, 117, 11, 144, 160, 206, 251, 141, 2]));
/// AMO: GDAMO22JB425UAA5OG7LFJXZ6MJFQE4EFONHV2SZLWBDI2MEAW6CXHYC
static immutable AMO = KeyPair(PublicKey([192, 199, 107, 73, 15, 53, 218, 0, 29, 113, 190, 178, 166, 249, 243, 18, 88, 19, 132, 43, 154, 122, 234, 89, 93, 130, 52, 105, 132, 5, 188, 43]), SecretKey([8, 30, 174, 241, 132, 197, 34, 71, 32, 134, 132, 183, 190, 36, 143, 162, 34, 121, 165, 3, 88, 69, 89, 94, 203, 153, 159, 194, 171, 220, 64, 73]), Seed([39, 115, 218, 131, 62, 199, 189, 94, 232, 64, 120, 136, 180, 83, 91, 177, 215, 121, 233, 44, 199, 213, 181, 91, 48, 47, 190, 221, 106, 163, 12, 57]));
/// AMP: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable AMP = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// AMQ: GDAMQ22JXRRXD7X5KKLMEPQ57N4PMZG2EG3N76I6YLICQK3HQP66MFWB
static immutable AMQ = KeyPair(PublicKey([192, 200, 107, 73, 188, 99, 113, 254, 253, 82, 150, 194, 62, 29, 251, 120, 246, 100, 218, 33, 182, 223, 249, 30, 194, 208, 40, 43, 103, 131, 253, 230]), SecretKey([0, 20, 82, 235, 162, 50, 133, 38, 182, 73, 91, 19, 216, 149, 134, 203, 172, 23, 234, 248, 94, 83, 207, 166, 9, 217, 29, 68, 235, 97, 181, 119]), Seed([89, 107, 232, 177, 51, 122, 168, 158, 241, 170, 128, 223, 226, 16, 59, 166, 243, 87, 71, 178, 61, 41, 57, 233, 170, 68, 108, 41, 166, 234, 238, 138]));
/// AMR: GDAMR22C6L45IQKEFC4ZA4EIPC6CNK7HDLEV7DW4KMQWVITXB7NS26TW
static immutable AMR = KeyPair(PublicKey([192, 200, 235, 66, 242, 249, 212, 65, 68, 40, 185, 144, 112, 136, 120, 188, 38, 171, 231, 26, 201, 95, 142, 220, 83, 33, 106, 162, 119, 15, 219, 45]), SecretKey([248, 245, 228, 108, 109, 173, 100, 122, 218, 53, 133, 196, 28, 30, 171, 34, 199, 17, 44, 38, 78, 119, 205, 125, 184, 204, 204, 123, 91, 6, 74, 77]), Seed([203, 43, 18, 45, 80, 225, 126, 174, 179, 148, 171, 249, 139, 147, 125, 166, 134, 2, 93, 147, 185, 53, 9, 34, 137, 63, 93, 252, 4, 237, 126, 251]));
/// AMS: GDAMS22BG7DRCNIQADHZHVNAGA2FC2LCV6TCTXW5KC3NRBCWE2RIILPH
static immutable AMS = KeyPair(PublicKey([192, 201, 107, 65, 55, 199, 17, 53, 16, 0, 207, 147, 213, 160, 48, 52, 81, 105, 98, 175, 166, 41, 222, 221, 80, 182, 216, 132, 86, 38, 162, 132]), SecretKey([128, 25, 11, 210, 31, 184, 175, 52, 113, 106, 151, 12, 153, 241, 41, 158, 3, 237, 249, 47, 199, 32, 219, 61, 112, 124, 69, 164, 238, 60, 216, 95]), Seed([108, 21, 244, 38, 249, 2, 69, 144, 234, 175, 13, 42, 7, 117, 84, 111, 156, 229, 118, 10, 164, 227, 37, 38, 115, 19, 16, 156, 236, 56, 42, 47]));
/// AMT: GDAMT22RG6TXBZNB64K5GOWVN6FSNCXDVFCNIIKFYREEW77MZURBTRVW
static immutable AMT = KeyPair(PublicKey([192, 201, 235, 81, 55, 167, 112, 229, 161, 247, 21, 211, 58, 213, 111, 139, 38, 138, 227, 169, 68, 212, 33, 69, 196, 72, 75, 127, 236, 205, 34, 25]), SecretKey([160, 16, 222, 79, 108, 179, 225, 22, 163, 149, 187, 171, 255, 248, 200, 39, 136, 54, 15, 58, 245, 24, 36, 218, 156, 121, 55, 120, 25, 59, 99, 64]), Seed([251, 147, 154, 248, 148, 1, 156, 71, 206, 50, 218, 245, 10, 133, 32, 162, 122, 232, 243, 109, 96, 211, 133, 206, 225, 170, 5, 92, 60, 243, 236, 29]));
/// AMU: GDAMU22P7GZ6USMGDGURSJUFCMHKCO4AILQ7JMCD7OZJDJUO67VVSFGL
static immutable AMU = KeyPair(PublicKey([192, 202, 107, 79, 249, 179, 234, 73, 134, 25, 169, 25, 38, 133, 19, 14, 161, 59, 128, 66, 225, 244, 176, 67, 251, 178, 145, 166, 142, 247, 235, 89]), SecretKey([152, 18, 89, 12, 150, 32, 228, 125, 108, 44, 210, 58, 134, 103, 21, 251, 64, 1, 52, 109, 234, 112, 24, 45, 228, 222, 122, 181, 118, 26, 210, 117]), Seed([227, 46, 130, 92, 93, 186, 189, 224, 188, 35, 28, 249, 31, 158, 120, 27, 38, 32, 87, 91, 78, 13, 94, 111, 224, 175, 212, 179, 160, 206, 122, 251]));
/// AMV: GDAMV22ICLUE2UECHVRZURR6CS3YL7CVT7D36LTVB4MJQSURDGSB46TT
static immutable AMV = KeyPair(PublicKey([192, 202, 235, 72, 18, 232, 77, 80, 130, 61, 99, 154, 70, 62, 20, 183, 133, 252, 85, 159, 199, 191, 46, 117, 15, 24, 152, 74, 145, 25, 164, 30]), SecretKey([40, 148, 243, 10, 189, 8, 87, 144, 154, 161, 244, 188, 161, 189, 164, 158, 84, 244, 63, 51, 42, 223, 119, 137, 5, 78, 177, 90, 116, 112, 94, 69]), Seed([158, 114, 64, 46, 69, 234, 120, 133, 56, 120, 79, 249, 4, 182, 211, 182, 88, 78, 17, 65, 175, 230, 247, 132, 121, 117, 172, 51, 11, 153, 187, 146]));
/// AMW: GDAMW227CIJNVCUZBUAVEZWZMQTAA5GJJNTMSNAG6XGIMUL576PHDPSC
static immutable AMW = KeyPair(PublicKey([192, 203, 107, 95, 18, 18, 218, 138, 153, 13, 1, 82, 102, 217, 100, 38, 0, 116, 201, 75, 102, 201, 52, 6, 245, 204, 134, 81, 125, 255, 158, 113]), SecretKey([8, 67, 113, 221, 78, 62, 43, 122, 160, 220, 238, 31, 25, 242, 119, 51, 203, 227, 207, 83, 202, 6, 214, 12, 253, 12, 41, 247, 242, 209, 163, 123]), Seed([38, 92, 156, 80, 89, 248, 136, 198, 87, 87, 76, 219, 24, 45, 131, 60, 120, 227, 181, 115, 82, 15, 89, 33, 62, 28, 111, 236, 152, 187, 39, 145]));
/// AMX: GDAMX226O6VCPTND4JXM4YCEBIPLCHCT3DSNBPQHYXE54FDPS3YJPLLG
static immutable AMX = KeyPair(PublicKey([192, 203, 235, 94, 119, 170, 39, 205, 163, 226, 110, 206, 96, 68, 10, 30, 177, 28, 83, 216, 228, 208, 190, 7, 197, 201, 222, 20, 111, 150, 240, 151]), SecretKey([248, 56, 77, 128, 184, 226, 195, 249, 31, 195, 204, 168, 235, 38, 226, 128, 23, 191, 57, 196, 91, 122, 236, 142, 101, 135, 37, 183, 200, 65, 177, 90]), Seed([59, 246, 201, 150, 168, 249, 65, 137, 87, 221, 84, 42, 85, 184, 72, 27, 8, 187, 100, 16, 0, 105, 165, 100, 1, 107, 188, 32, 190, 39, 119, 24]));
/// AMY: GDAMY22TNBHSZMZEPVFUKFKHR3FJXEXWPNBB6SLVWSBCOJKRV722IGFN
static immutable AMY = KeyPair(PublicKey([192, 204, 107, 83, 104, 79, 44, 179, 36, 125, 75, 69, 21, 71, 142, 202, 155, 146, 246, 123, 66, 31, 73, 117, 180, 130, 39, 37, 81, 175, 245, 164]), SecretKey([160, 200, 202, 138, 152, 148, 243, 102, 255, 15, 5, 48, 45, 159, 36, 61, 30, 132, 223, 243, 59, 56, 184, 22, 209, 134, 223, 99, 60, 196, 3, 78]), Seed([162, 72, 235, 198, 104, 247, 59, 223, 234, 133, 112, 140, 151, 92, 195, 183, 220, 14, 71, 77, 42, 87, 3, 173, 70, 150, 114, 162, 130, 126, 57, 96]));
/// AMZ: GDAMZ22W2FHBWZWTWKEX3Q6P53FI2WDIJY6QQK24BR3MJ4BYA5KB3TBK
static immutable AMZ = KeyPair(PublicKey([192, 204, 235, 86, 209, 78, 27, 102, 211, 178, 137, 125, 195, 207, 238, 202, 141, 88, 104, 78, 61, 8, 43, 92, 12, 118, 196, 240, 56, 7, 84, 29]), SecretKey([40, 119, 143, 20, 155, 175, 41, 57, 8, 218, 74, 241, 204, 242, 152, 55, 227, 6, 134, 176, 255, 93, 148, 209, 41, 42, 213, 109, 109, 13, 85, 93]), Seed([123, 40, 217, 239, 158, 45, 52, 127, 239, 193, 152, 220, 67, 89, 244, 142, 191, 145, 82, 194, 153, 20, 22, 206, 32, 75, 220, 37, 211, 50, 176, 105]));
/// ANA: GDANA22YAATRJXHP2WY5MH3A5G7OQ3LK47J6QAAVM7HNQW5KV73AFSWG
static immutable ANA = KeyPair(PublicKey([192, 208, 107, 88, 0, 39, 20, 220, 239, 213, 177, 214, 31, 96, 233, 190, 232, 109, 106, 231, 211, 232, 0, 21, 103, 206, 216, 91, 170, 175, 246, 2]), SecretKey([40, 245, 51, 103, 39, 54, 119, 239, 187, 78, 142, 100, 90, 232, 108, 116, 234, 232, 191, 127, 76, 97, 236, 71, 153, 174, 247, 230, 157, 129, 20, 68]), Seed([51, 44, 93, 157, 47, 11, 246, 225, 244, 249, 241, 110, 226, 117, 29, 17, 33, 124, 22, 73, 216, 181, 66, 226, 179, 151, 146, 9, 148, 94, 238, 237]));
/// ANB: GDANB2242ZNRQ3DBGZBC75BGGDUOMSB2NNCYBSXJ6WZLGMRJ5EXV3IOV
static immutable ANB = KeyPair(PublicKey([192, 208, 235, 92, 214, 91, 24, 108, 97, 54, 66, 47, 244, 38, 48, 232, 230, 72, 58, 107, 69, 128, 202, 233, 245, 178, 179, 50, 41, 233, 47, 93]), SecretKey([144, 241, 52, 202, 70, 165, 143, 111, 8, 200, 116, 219, 143, 92, 144, 228, 127, 0, 160, 142, 30, 129, 141, 247, 79, 26, 205, 146, 140, 246, 163, 103]), Seed([240, 200, 227, 41, 7, 144, 116, 136, 20, 116, 42, 157, 192, 195, 11, 100, 126, 109, 225, 118, 122, 6, 146, 147, 32, 2, 237, 113, 159, 178, 206, 236]));
/// ANC: GDANC22NBW3OLBXKDWVQJLAS6NZHZBUV3XDEICDWFU2OMNHWD3AART7E
static immutable ANC = KeyPair(PublicKey([192, 209, 107, 77, 13, 182, 229, 134, 234, 29, 171, 4, 172, 18, 243, 114, 124, 134, 149, 221, 198, 68, 8, 118, 45, 52, 230, 52, 246, 30, 192, 8]), SecretKey([112, 189, 240, 237, 53, 60, 60, 170, 234, 53, 133, 188, 156, 105, 3, 13, 230, 240, 84, 184, 34, 126, 152, 250, 114, 178, 26, 217, 237, 205, 114, 99]), Seed([48, 15, 162, 125, 223, 103, 205, 211, 1, 192, 106, 212, 66, 10, 203, 211, 7, 155, 98, 121, 214, 154, 218, 222, 109, 65, 115, 159, 74, 138, 75, 245]));
/// AND: GDAND22RPTXZ3HVLJR43S7AUP5EWAJNEKKMJFIPTP2F2EDBJ4WF7DJPE
static immutable AND = KeyPair(PublicKey([192, 209, 235, 81, 124, 239, 157, 158, 171, 76, 121, 185, 124, 20, 127, 73, 96, 37, 164, 82, 152, 146, 161, 243, 126, 139, 162, 12, 41, 229, 139, 241]), SecretKey([184, 63, 15, 194, 214, 239, 79, 97, 48, 100, 175, 68, 140, 187, 131, 95, 162, 207, 81, 139, 199, 223, 110, 235, 89, 151, 14, 173, 137, 184, 124, 100]), Seed([201, 120, 162, 181, 144, 116, 17, 244, 240, 68, 66, 251, 84, 20, 18, 222, 98, 163, 219, 148, 5, 32, 11, 8, 68, 119, 81, 43, 214, 19, 24, 229]));
/// ANE: GDANE22I4ABGXFOYGW3MHJYUWFQRFVLBLZ5NEIB25V52QHSIKDGC4W3Y
static immutable ANE = KeyPair(PublicKey([192, 210, 107, 72, 224, 2, 107, 149, 216, 53, 182, 195, 167, 20, 177, 97, 18, 213, 97, 94, 122, 210, 32, 58, 237, 123, 168, 30, 72, 80, 204, 46]), SecretKey([96, 205, 54, 122, 178, 133, 33, 136, 70, 246, 26, 80, 215, 1, 138, 77, 22, 24, 173, 102, 210, 244, 251, 134, 107, 37, 250, 238, 204, 99, 239, 82]), Seed([45, 85, 215, 235, 123, 59, 240, 61, 221, 241, 215, 78, 98, 238, 91, 71, 195, 213, 104, 190, 25, 130, 230, 94, 195, 215, 205, 80, 121, 87, 145, 92]));
/// ANF: GDANF22HT66GXO2U2HYFEZRJ3774Y3Z3LFCPLK2V7R66RGD3YN6II737
static immutable ANF = KeyPair(PublicKey([192, 210, 235, 71, 159, 188, 107, 187, 84, 209, 240, 82, 102, 41, 223, 255, 204, 111, 59, 89, 68, 245, 171, 85, 252, 125, 232, 152, 123, 195, 124, 132]), SecretKey([48, 195, 131, 155, 106, 150, 233, 16, 202, 250, 71, 159, 221, 156, 65, 73, 243, 186, 230, 141, 36, 91, 244, 56, 242, 209, 189, 198, 251, 8, 71, 126]), Seed([139, 99, 3, 144, 163, 9, 58, 191, 0, 26, 190, 246, 56, 75, 234, 154, 230, 180, 234, 183, 190, 67, 98, 196, 45, 58, 158, 33, 205, 1, 115, 93]));
/// ANG: GDANG22K2PQMFLQXCK5CHOS5TUQMBMOVDLOOSGUJDHBIFQH4NOG5FH3M
static immutable ANG = KeyPair(PublicKey([192, 211, 107, 74, 211, 224, 194, 174, 23, 18, 186, 35, 186, 93, 157, 32, 192, 177, 213, 26, 220, 233, 26, 137, 25, 194, 130, 192, 252, 107, 141, 210]), SecretKey([32, 185, 36, 204, 134, 99, 138, 136, 109, 93, 166, 67, 192, 62, 248, 207, 143, 200, 29, 85, 119, 161, 152, 143, 202, 80, 89, 118, 235, 112, 163, 108]), Seed([25, 168, 31, 205, 53, 177, 238, 60, 205, 255, 254, 171, 218, 195, 140, 128, 103, 149, 110, 200, 19, 77, 234, 123, 225, 254, 205, 43, 179, 60, 138, 241]));
/// ANH: GDANH22ISKHTUTNBTJLVRCVDPSU3SGCQONANAXEM6GR442FVHSWMQYDY
static immutable ANH = KeyPair(PublicKey([192, 211, 235, 72, 146, 143, 58, 77, 161, 154, 87, 88, 138, 163, 124, 169, 185, 24, 80, 115, 64, 208, 92, 140, 241, 163, 206, 104, 181, 60, 172, 200]), SecretKey([128, 48, 130, 22, 50, 15, 85, 230, 231, 167, 35, 169, 255, 62, 10, 5, 248, 106, 140, 154, 206, 181, 55, 10, 180, 236, 124, 88, 6, 244, 127, 118]), Seed([232, 88, 19, 113, 52, 142, 170, 190, 172, 167, 179, 125, 216, 81, 233, 88, 67, 242, 169, 202, 174, 218, 151, 180, 204, 72, 51, 228, 222, 35, 15, 80]));
/// ANI: GDANI223CDGRC7TSJTVLYHOUPNSRJ5I7HMGYU65XA4QFVFTCKUFL7IFW
static immutable ANI = KeyPair(PublicKey([192, 212, 107, 91, 16, 205, 17, 126, 114, 76, 234, 188, 29, 212, 123, 101, 20, 245, 31, 59, 13, 138, 123, 183, 7, 32, 90, 150, 98, 85, 10, 191]), SecretKey([24, 183, 44, 224, 106, 198, 87, 88, 174, 146, 60, 187, 125, 25, 186, 157, 33, 140, 67, 189, 134, 165, 28, 43, 178, 162, 240, 61, 226, 121, 203, 80]), Seed([179, 200, 186, 47, 56, 31, 107, 125, 106, 29, 24, 81, 168, 49, 65, 136, 250, 14, 62, 27, 36, 189, 162, 238, 147, 98, 251, 183, 79, 183, 107, 141]));
/// ANJ: GDANJ22AJFOCBBX6TMQXT2RL3RQIF7CHHF55BKOOS7RMMURFEZ2DXI56
static immutable ANJ = KeyPair(PublicKey([192, 212, 235, 64, 73, 92, 32, 134, 254, 155, 33, 121, 234, 43, 220, 96, 130, 252, 71, 57, 123, 208, 169, 206, 151, 226, 198, 82, 37, 38, 116, 59]), SecretKey([48, 71, 137, 154, 153, 122, 247, 6, 168, 29, 207, 74, 64, 47, 2, 225, 124, 121, 191, 149, 48, 163, 118, 203, 156, 165, 39, 156, 225, 69, 4, 108]), Seed([252, 220, 135, 30, 5, 194, 239, 158, 199, 13, 124, 8, 180, 214, 80, 215, 182, 107, 120, 58, 238, 72, 127, 214, 175, 178, 138, 79, 137, 136, 5, 149]));
/// ANK: GDANK22YPL63K4FNEJBGYLLFZT5CZLJTPITXDN6JE3TLYGVR6PP6VHY2
static immutable ANK = KeyPair(PublicKey([192, 213, 107, 88, 122, 253, 181, 112, 173, 34, 66, 108, 45, 101, 204, 250, 44, 173, 51, 122, 39, 113, 183, 201, 38, 230, 188, 26, 177, 243, 223, 234]), SecretKey([144, 164, 215, 134, 201, 156, 118, 153, 252, 202, 51, 112, 242, 16, 189, 246, 248, 132, 175, 181, 104, 109, 18, 116, 45, 141, 112, 206, 159, 70, 199, 127]), Seed([52, 26, 251, 166, 98, 107, 56, 152, 125, 167, 80, 142, 138, 171, 232, 38, 239, 37, 173, 227, 249, 51, 126, 83, 250, 94, 199, 244, 70, 188, 187, 229]));
/// ANL: GDANL223LSFE2I4IFQPXXYQ3OFQ7V6UNGO244QRY3EDNNWBHAXDM42DX
static immutable ANL = KeyPair(PublicKey([192, 213, 235, 91, 92, 138, 77, 35, 136, 44, 31, 123, 226, 27, 113, 97, 250, 250, 141, 51, 181, 206, 66, 56, 217, 6, 214, 216, 39, 5, 198, 206]), SecretKey([96, 214, 23, 125, 206, 125, 66, 92, 196, 187, 228, 192, 107, 156, 165, 230, 35, 44, 0, 7, 17, 250, 31, 40, 123, 254, 255, 51, 244, 5, 93, 125]), Seed([123, 150, 116, 177, 155, 8, 55, 244, 167, 152, 48, 15, 232, 34, 158, 27, 39, 131, 229, 55, 176, 5, 233, 51, 76, 116, 53, 91, 85, 231, 89, 29]));
/// ANM: GDANM22SO4ATNTFLRAUODNNJ4CGZSC7E2PLV2JBIOJBI7VEELQ3X2HGH
static immutable ANM = KeyPair(PublicKey([192, 214, 107, 82, 119, 1, 54, 204, 171, 136, 40, 225, 181, 169, 224, 141, 153, 11, 228, 211, 215, 93, 36, 40, 114, 66, 143, 212, 132, 92, 55, 125]), SecretKey([104, 19, 179, 4, 90, 65, 118, 76, 203, 67, 205, 203, 183, 228, 34, 34, 210, 136, 201, 86, 106, 24, 184, 234, 222, 227, 196, 85, 224, 117, 211, 112]), Seed([16, 151, 241, 94, 153, 10, 0, 149, 241, 176, 212, 237, 133, 139, 217, 236, 235, 226, 102, 209, 165, 80, 126, 168, 83, 228, 168, 116, 104, 174, 25, 49]));
/// ANN: GDANN22RRMNV6HUBBRYW4QND6U2S2X7JLLT33UTSI772STOK3A7O7TB4
static immutable ANN = KeyPair(PublicKey([192, 214, 235, 81, 139, 27, 95, 30, 129, 12, 113, 110, 65, 163, 245, 53, 45, 95, 233, 90, 231, 189, 210, 114, 71, 255, 169, 77, 202, 216, 62, 239]), SecretKey([216, 118, 24, 207, 72, 117, 127, 189, 83, 246, 19, 75, 86, 222, 56, 162, 182, 179, 109, 248, 136, 174, 115, 22, 170, 240, 250, 110, 199, 116, 207, 121]), Seed([231, 20, 10, 79, 96, 180, 57, 106, 30, 40, 85, 134, 119, 211, 94, 132, 109, 233, 184, 249, 208, 169, 36, 121, 247, 176, 25, 64, 76, 71, 76, 76]));
/// ANO: GDANO22NKLJISCKEDAHAGIUYTG46ACEMN62YDAMGJOJYDTGKJK5QNHEB
static immutable ANO = KeyPair(PublicKey([192, 215, 107, 77, 82, 210, 137, 9, 68, 24, 14, 3, 34, 152, 153, 185, 224, 8, 140, 111, 181, 129, 129, 134, 75, 147, 129, 204, 202, 74, 187, 6]), SecretKey([192, 101, 163, 138, 115, 238, 45, 51, 7, 28, 10, 28, 236, 59, 238, 162, 35, 70, 5, 21, 80, 60, 18, 66, 89, 134, 87, 57, 119, 4, 6, 103]), Seed([52, 93, 63, 253, 248, 67, 223, 18, 108, 224, 180, 154, 48, 164, 58, 50, 9, 224, 219, 27, 13, 13, 88, 133, 245, 208, 33, 118, 114, 248, 203, 157]));
/// ANP: GDANP22PX2QUXIES7IHYJSEOEOWINJV5NN67FAWNSSTMQPVP7U4OGN7I
static immutable ANP = KeyPair(PublicKey([192, 215, 235, 79, 190, 161, 75, 160, 146, 250, 15, 132, 200, 142, 35, 172, 134, 166, 189, 107, 125, 242, 130, 205, 148, 166, 200, 62, 175, 253, 56, 227]), SecretKey([104, 242, 215, 128, 227, 245, 165, 88, 185, 64, 71, 65, 26, 28, 35, 40, 81, 203, 115, 147, 10, 229, 83, 251, 2, 125, 8, 109, 192, 50, 191, 104]), Seed([40, 64, 32, 249, 211, 36, 6, 78, 126, 62, 140, 26, 174, 177, 27, 47, 58, 71, 56, 81, 60, 207, 125, 133, 148, 203, 94, 198, 117, 107, 240, 208]));
/// ANQ: GDANQ22BTUJZZXFU5Q3LKUJDQT6L2MRY22MQKX6XWJMYOHJSRPVRDHWT
static immutable ANQ = KeyPair(PublicKey([192, 216, 107, 65, 157, 19, 156, 220, 180, 236, 54, 181, 81, 35, 132, 252, 189, 50, 56, 214, 153, 5, 95, 215, 178, 89, 135, 29, 50, 139, 235, 17]), SecretKey([144, 159, 108, 63, 109, 252, 255, 116, 37, 92, 235, 103, 57, 36, 70, 155, 193, 156, 46, 0, 222, 63, 239, 18, 176, 165, 16, 91, 13, 107, 130, 81]), Seed([159, 158, 71, 82, 4, 61, 250, 215, 226, 114, 240, 187, 170, 214, 61, 206, 149, 198, 62, 46, 193, 231, 80, 50, 223, 117, 186, 166, 20, 9, 186, 219]));
/// ANR: GDANR22EFE6YZKD7XP35R3EKLLGUCU4HYSSA6VQIAT2U2XA6PHPD4EMK
static immutable ANR = KeyPair(PublicKey([192, 216, 235, 68, 41, 61, 140, 168, 127, 187, 247, 216, 236, 138, 90, 205, 65, 83, 135, 196, 164, 15, 86, 8, 4, 245, 77, 92, 30, 121, 222, 62]), SecretKey([56, 101, 89, 98, 155, 216, 131, 139, 251, 201, 8, 181, 210, 150, 92, 148, 246, 233, 142, 133, 101, 133, 134, 31, 128, 246, 224, 166, 112, 3, 60, 95]), Seed([166, 197, 90, 151, 89, 184, 107, 189, 130, 229, 102, 181, 30, 175, 172, 127, 130, 109, 176, 148, 122, 143, 198, 47, 88, 56, 177, 121, 84, 167, 230, 43]));
/// ANS: GDANS22QNTQD2YEDWB5MKRB4SSR4E2FVD6WPXKUQOLTEK6C6QFNORUSL
static immutable ANS = KeyPair(PublicKey([192, 217, 107, 80, 108, 224, 61, 96, 131, 176, 122, 197, 68, 60, 148, 163, 194, 104, 181, 31, 172, 251, 170, 144, 114, 230, 69, 120, 94, 129, 90, 232]), SecretKey([224, 125, 177, 116, 198, 206, 103, 20, 25, 70, 119, 238, 112, 67, 99, 27, 196, 112, 149, 77, 64, 199, 189, 204, 242, 29, 220, 66, 41, 63, 90, 86]), Seed([241, 172, 90, 185, 59, 103, 50, 30, 167, 47, 72, 111, 174, 201, 46, 115, 180, 43, 46, 45, 18, 100, 234, 39, 185, 12, 246, 18, 153, 56, 209, 230]));
/// ANT: GDANT22S4X7KVUDGXS7JGEL75SIKL3TIXINMVPTZ7JKWXBF23IDHVKBU
static immutable ANT = KeyPair(PublicKey([192, 217, 235, 82, 229, 254, 170, 208, 102, 188, 190, 147, 17, 127, 236, 144, 165, 238, 104, 186, 26, 202, 190, 121, 250, 85, 107, 132, 186, 218, 6, 122]), SecretKey([16, 193, 108, 220, 1, 150, 119, 223, 208, 211, 15, 173, 111, 119, 166, 146, 113, 63, 169, 58, 75, 47, 84, 160, 150, 115, 197, 61, 220, 196, 203, 110]), Seed([48, 194, 15, 223, 74, 100, 121, 9, 19, 21, 174, 59, 108, 141, 47, 144, 38, 1, 60, 239, 84, 59, 79, 174, 144, 35, 91, 97, 72, 251, 240, 174]));
/// ANU: GDANU226RP62GRS65JUKGE3AAPCQPIK2J2IFJGTPXX2VVVM2Z35666SX
static immutable ANU = KeyPair(PublicKey([192, 218, 107, 94, 139, 253, 163, 70, 94, 234, 104, 163, 19, 96, 3, 197, 7, 161, 90, 78, 144, 84, 154, 111, 189, 245, 90, 213, 154, 206, 251, 239]), SecretKey([96, 144, 233, 54, 253, 28, 255, 2, 96, 201, 27, 31, 193, 36, 167, 45, 30, 19, 119, 33, 251, 152, 170, 148, 51, 94, 5, 168, 41, 79, 11, 73]), Seed([55, 204, 132, 232, 85, 58, 243, 184, 128, 184, 156, 231, 231, 200, 158, 205, 115, 34, 18, 73, 13, 129, 161, 100, 148, 77, 254, 198, 149, 183, 203, 58]));
/// ANV: GDANV226DW4MRFMD5RI62OJQ4BBDJDYG3H5KFAJO277CLAHS252JR46D
static immutable ANV = KeyPair(PublicKey([192, 218, 235, 94, 29, 184, 200, 149, 131, 236, 81, 237, 57, 48, 224, 66, 52, 143, 6, 217, 250, 162, 129, 46, 215, 254, 37, 128, 242, 215, 116, 152]), SecretKey([224, 163, 130, 70, 8, 236, 201, 7, 175, 198, 112, 157, 196, 165, 90, 216, 222, 254, 137, 18, 255, 249, 147, 190, 95, 195, 32, 232, 220, 33, 228, 72]), Seed([165, 247, 22, 95, 199, 137, 41, 88, 86, 141, 69, 98, 19, 209, 60, 237, 1, 112, 8, 112, 74, 204, 70, 106, 104, 69, 167, 171, 90, 62, 236, 248]));
/// ANW: GDANW22SA2CX53OBUH4LQVSCNQX2XHNOYNJ2FWWDYA4YEPFLR4PF6KJP
static immutable ANW = KeyPair(PublicKey([192, 219, 107, 82, 6, 133, 126, 237, 193, 161, 248, 184, 86, 66, 108, 47, 171, 157, 174, 195, 83, 162, 218, 195, 192, 57, 130, 60, 171, 143, 30, 95]), SecretKey([48, 56, 178, 155, 242, 206, 76, 242, 179, 251, 79, 242, 59, 160, 12, 181, 15, 100, 229, 182, 254, 74, 86, 246, 64, 44, 158, 190, 206, 254, 57, 76]), Seed([106, 9, 0, 203, 231, 223, 54, 69, 158, 133, 155, 225, 230, 112, 47, 89, 161, 233, 250, 55, 188, 213, 162, 98, 131, 24, 188, 201, 180, 159, 240, 55]));
/// ANX: GDANX22ULRRKSVWDLI6YHPXXCSWARIIJDLVU3OKVQHTYX7DKU6S4IISM
static immutable ANX = KeyPair(PublicKey([192, 219, 235, 84, 92, 98, 169, 86, 195, 90, 61, 131, 190, 247, 20, 172, 8, 161, 9, 26, 235, 77, 185, 85, 129, 231, 139, 252, 106, 167, 165, 196]), SecretKey([240, 127, 243, 243, 4, 4, 206, 188, 9, 191, 30, 182, 102, 184, 31, 10, 214, 119, 144, 101, 114, 231, 63, 48, 28, 153, 35, 240, 171, 55, 77, 79]), Seed([10, 114, 7, 204, 167, 184, 142, 131, 17, 109, 84, 194, 209, 25, 222, 179, 70, 169, 251, 62, 101, 142, 181, 53, 242, 167, 8, 40, 122, 73, 19, 63]));
/// ANY: GDANY223A7GDYWHZY7AGNICFOTKBWNIDET67VF2C642Z2VQLTMOPTYLJ
static immutable ANY = KeyPair(PublicKey([192, 220, 107, 91, 7, 204, 60, 88, 249, 199, 192, 102, 160, 69, 116, 212, 27, 53, 3, 36, 253, 250, 151, 66, 247, 53, 157, 86, 11, 155, 28, 249]), SecretKey([160, 184, 153, 65, 202, 24, 86, 107, 60, 164, 101, 132, 220, 170, 67, 70, 136, 76, 19, 122, 177, 151, 50, 89, 214, 166, 73, 176, 46, 232, 104, 83]), Seed([172, 119, 71, 218, 124, 63, 229, 45, 115, 91, 236, 71, 140, 75, 14, 253, 22, 160, 162, 239, 135, 39, 75, 142, 136, 94, 97, 110, 253, 39, 20, 164]));
/// ANZ: GDANZ22ZLOEOJ4CBLOLXBFIY6FL35AQPPWWEUQDQ3WPPLDCLYRGBSHYA
static immutable ANZ = KeyPair(PublicKey([192, 220, 235, 89, 91, 136, 228, 240, 65, 91, 151, 112, 149, 24, 241, 87, 190, 130, 15, 125, 172, 74, 64, 112, 221, 158, 245, 140, 75, 196, 76, 25]), SecretKey([152, 147, 186, 237, 236, 160, 146, 234, 208, 0, 130, 1, 206, 24, 147, 188, 139, 45, 176, 215, 123, 31, 130, 226, 83, 71, 91, 113, 16, 22, 13, 127]), Seed([228, 103, 32, 148, 175, 43, 174, 202, 61, 80, 85, 151, 93, 192, 204, 54, 229, 152, 113, 33, 201, 74, 204, 239, 2, 186, 112, 232, 54, 156, 7, 168]));
/// AOA: GDAOA22EHDLCJPTZQFMYOXIL7HSY27NVYI7DGKWBIKE2NFBIE5R6HRSB
static immutable AOA = KeyPair(PublicKey([192, 224, 107, 68, 56, 214, 36, 190, 121, 129, 89, 135, 93, 11, 249, 229, 141, 125, 181, 194, 62, 51, 42, 193, 66, 137, 166, 148, 40, 39, 99, 227]), SecretKey([168, 231, 70, 249, 125, 82, 181, 55, 51, 193, 138, 103, 126, 107, 70, 214, 145, 171, 180, 234, 253, 24, 110, 33, 86, 240, 151, 175, 19, 126, 152, 117]), Seed([89, 201, 19, 91, 119, 161, 57, 109, 150, 175, 118, 175, 170, 51, 5, 178, 108, 159, 147, 13, 214, 144, 147, 53, 119, 2, 86, 141, 47, 247, 210, 170]));
/// AOB: GDAOB22UYMU6I62DX4RXF3FOZRXGRTGPBJAW33ELV4JWJ23CBFOFFWMR
static immutable AOB = KeyPair(PublicKey([192, 224, 235, 84, 195, 41, 228, 123, 67, 191, 35, 114, 236, 174, 204, 110, 104, 204, 207, 10, 65, 109, 236, 139, 175, 19, 100, 235, 98, 9, 92, 82]), SecretKey([128, 232, 222, 122, 116, 13, 165, 54, 183, 54, 159, 177, 191, 90, 220, 83, 15, 99, 226, 133, 21, 19, 3, 169, 246, 41, 18, 189, 78, 248, 1, 115]), Seed([4, 227, 163, 3, 62, 84, 63, 225, 198, 241, 121, 147, 4, 86, 159, 96, 161, 85, 237, 70, 181, 125, 113, 62, 38, 90, 120, 203, 75, 3, 231, 172]));
/// AOC: GDAOC22F7GDBQONKDXOS4VX6JW6XNUIXOYU6XFJZD7KBKMIZDXJWNW7Q
static immutable AOC = KeyPair(PublicKey([192, 225, 107, 69, 249, 134, 24, 57, 170, 29, 221, 46, 86, 254, 77, 189, 118, 209, 23, 118, 41, 235, 149, 57, 31, 212, 21, 49, 25, 29, 211, 102]), SecretKey([240, 231, 60, 172, 99, 68, 97, 153, 175, 240, 53, 19, 4, 161, 20, 213, 45, 85, 20, 46, 80, 130, 120, 204, 167, 7, 161, 121, 250, 163, 251, 93]), Seed([136, 204, 15, 38, 199, 165, 91, 188, 224, 28, 122, 171, 85, 88, 30, 159, 163, 22, 49, 210, 188, 244, 6, 84, 8, 87, 99, 99, 222, 188, 110, 226]));
/// AOD: GDAOD226XEB6RBTT7CX4E2OZ3EABROZWMZCE3RKA74QNIUV3SIML46CZ
static immutable AOD = KeyPair(PublicKey([192, 225, 235, 94, 185, 3, 232, 134, 115, 248, 175, 194, 105, 217, 217, 0, 24, 187, 54, 102, 68, 77, 197, 64, 255, 32, 212, 82, 187, 146, 24, 190]), SecretKey([232, 174, 143, 58, 134, 244, 222, 82, 9, 191, 200, 154, 131, 222, 146, 104, 249, 209, 202, 180, 91, 108, 78, 170, 124, 46, 173, 77, 102, 150, 246, 76]), Seed([54, 239, 177, 88, 207, 106, 204, 220, 111, 35, 214, 46, 116, 114, 73, 161, 244, 131, 192, 116, 85, 187, 171, 199, 139, 119, 62, 193, 14, 13, 241, 78]));
/// AOE: GDAOE22ZHEP4WK65INMY243HM4ODMZBNXAS4D5PNRC2QSY73B6PD6WQA
static immutable AOE = KeyPair(PublicKey([192, 226, 107, 89, 57, 31, 203, 43, 221, 67, 89, 141, 115, 103, 103, 28, 54, 100, 45, 184, 37, 193, 245, 237, 136, 181, 9, 99, 251, 15, 158, 63]), SecretKey([64, 7, 204, 0, 158, 58, 251, 79, 54, 126, 7, 123, 240, 36, 99, 218, 99, 129, 226, 105, 224, 131, 193, 248, 13, 93, 188, 140, 158, 30, 121, 86]), Seed([18, 125, 188, 254, 232, 217, 17, 9, 226, 56, 24, 78, 125, 17, 210, 248, 136, 198, 255, 75, 62, 128, 10, 29, 186, 31, 167, 76, 10, 201, 151, 237]));
/// AOF: GDAOF22VSCTRFMASCOPQKG4QZOAM5CTFN3PUC5B2RKNFX5N6VO52DEM4
static immutable AOF = KeyPair(PublicKey([192, 226, 235, 85, 144, 167, 18, 176, 18, 19, 159, 5, 27, 144, 203, 128, 206, 138, 101, 110, 223, 65, 116, 58, 138, 154, 91, 245, 190, 171, 187, 161]), SecretKey([104, 32, 153, 246, 229, 77, 54, 207, 80, 246, 210, 10, 185, 28, 206, 146, 170, 121, 82, 242, 215, 115, 209, 149, 63, 43, 22, 132, 106, 103, 187, 108]), Seed([97, 154, 97, 88, 20, 184, 45, 82, 158, 64, 207, 213, 163, 242, 61, 219, 244, 15, 17, 167, 95, 172, 147, 229, 140, 140, 141, 68, 76, 197, 180, 14]));
/// AOG: GDAOG2252ZYNUF2AOQI7X2GHSFTCVWFJ7ZG6YLVIEHL5OGJJAS7U5YHR
static immutable AOG = KeyPair(PublicKey([192, 227, 107, 93, 214, 112, 218, 23, 64, 116, 17, 251, 232, 199, 145, 102, 42, 216, 169, 254, 77, 236, 46, 168, 33, 215, 215, 25, 41, 4, 191, 78]), SecretKey([48, 211, 200, 86, 130, 222, 157, 46, 135, 78, 177, 203, 222, 8, 245, 202, 243, 9, 164, 159, 13, 209, 227, 250, 166, 216, 38, 110, 161, 82, 202, 100]), Seed([152, 245, 12, 187, 8, 38, 213, 122, 245, 160, 94, 248, 215, 111, 153, 61, 4, 30, 129, 40, 24, 65, 6, 51, 229, 50, 85, 154, 89, 128, 226, 45]));
/// AOH: GDAOH224BBMO27U5A3ZBNB7ZB6MLQXHUFB2MMPSIIYKSCGU2N2RNT52N
static immutable AOH = KeyPair(PublicKey([192, 227, 235, 92, 8, 88, 237, 126, 157, 6, 242, 22, 135, 249, 15, 152, 184, 92, 244, 40, 116, 198, 62, 72, 70, 21, 33, 26, 154, 110, 162, 217]), SecretKey([208, 180, 16, 110, 249, 56, 47, 151, 32, 139, 169, 144, 132, 44, 124, 50, 11, 221, 157, 35, 160, 41, 0, 18, 80, 9, 22, 77, 62, 183, 77, 81]), Seed([118, 189, 128, 161, 125, 120, 129, 86, 2, 72, 177, 198, 206, 200, 17, 250, 74, 196, 86, 216, 117, 8, 237, 221, 82, 155, 222, 37, 5, 243, 176, 86]));
/// AOI: GDAOI22QCM6IADQSTUFZRYGZAN47H7ATMTRVAPP5VZ2D4FQ3HQGIABDS
static immutable AOI = KeyPair(PublicKey([192, 228, 107, 80, 19, 60, 128, 14, 18, 157, 11, 152, 224, 217, 3, 121, 243, 252, 19, 100, 227, 80, 61, 253, 174, 116, 62, 22, 27, 60, 12, 128]), SecretKey([48, 106, 33, 206, 161, 123, 79, 32, 46, 15, 236, 37, 10, 104, 175, 15, 215, 82, 109, 225, 58, 223, 165, 229, 129, 120, 217, 243, 202, 178, 94, 96]), Seed([44, 192, 212, 62, 118, 64, 62, 48, 113, 230, 94, 160, 241, 221, 131, 31, 236, 243, 248, 21, 180, 73, 123, 174, 139, 174, 136, 94, 153, 105, 192, 210]));
/// AOJ: GDAOJ22PTJT6OPG3G666SCYYWSTLM64OZDCBU23FWCPL5MNPSRFAJDFS
static immutable AOJ = KeyPair(PublicKey([192, 228, 235, 79, 154, 103, 231, 60, 219, 55, 189, 233, 11, 24, 180, 166, 182, 123, 142, 200, 196, 26, 107, 101, 176, 158, 190, 177, 175, 148, 74, 4]), SecretKey([184, 48, 217, 9, 219, 173, 4, 169, 144, 91, 245, 122, 201, 131, 43, 67, 59, 135, 222, 31, 122, 198, 63, 22, 128, 115, 45, 193, 193, 165, 123, 94]), Seed([174, 92, 120, 71, 227, 187, 166, 15, 24, 95, 148, 222, 11, 26, 97, 87, 164, 121, 41, 85, 248, 201, 125, 89, 229, 39, 98, 150, 252, 109, 150, 3]));
/// AOK: GDAOK22VYG7RUXYXAMFJM4UGIUWFNODHAVETQJJE5K5GGZB6MMTXVTLD
static immutable AOK = KeyPair(PublicKey([192, 229, 107, 85, 193, 191, 26, 95, 23, 3, 10, 150, 114, 134, 69, 44, 86, 184, 103, 5, 73, 56, 37, 36, 234, 186, 99, 100, 62, 99, 39, 122]), SecretKey([8, 189, 241, 75, 188, 134, 71, 3, 170, 177, 65, 232, 50, 121, 246, 154, 38, 237, 228, 237, 197, 241, 193, 100, 219, 96, 251, 196, 198, 182, 155, 68]), Seed([38, 149, 42, 123, 161, 114, 92, 35, 254, 189, 173, 23, 94, 206, 60, 18, 104, 160, 211, 100, 195, 90, 109, 10, 167, 226, 227, 55, 16, 205, 24, 65]));
/// AOL: GDAOL22LP5UU6TMP6JY74RR2HO4SAPH6ABQ5NTLSDF5LPI3CZDM72ICG
static immutable AOL = KeyPair(PublicKey([192, 229, 235, 75, 127, 105, 79, 77, 143, 242, 113, 254, 70, 58, 59, 185, 32, 60, 254, 0, 97, 214, 205, 114, 25, 122, 183, 163, 98, 200, 217, 253]), SecretKey([16, 112, 32, 248, 234, 136, 202, 13, 41, 73, 156, 139, 22, 205, 165, 144, 53, 14, 56, 81, 194, 0, 184, 254, 195, 213, 165, 56, 188, 11, 247, 84]), Seed([18, 253, 148, 184, 209, 88, 11, 123, 116, 129, 89, 74, 114, 212, 252, 203, 61, 212, 194, 207, 175, 77, 173, 247, 225, 53, 14, 227, 81, 221, 204, 193]));
/// AOM: GDAOM22U5N37BH7MK7V3ASN65LXBD5RKSWKFEHOTNPU3AG7NZUQR53OP
static immutable AOM = KeyPair(PublicKey([192, 230, 107, 84, 235, 119, 240, 159, 236, 87, 235, 176, 73, 190, 234, 238, 17, 246, 42, 149, 148, 82, 29, 211, 107, 233, 176, 27, 237, 205, 33, 30]), SecretKey([144, 31, 44, 106, 118, 89, 74, 242, 123, 29, 111, 103, 130, 87, 38, 66, 69, 178, 158, 254, 99, 150, 170, 116, 141, 203, 226, 216, 151, 221, 221, 83]), Seed([55, 186, 191, 188, 46, 221, 93, 82, 156, 15, 32, 19, 102, 212, 216, 11, 192, 93, 62, 7, 34, 23, 178, 45, 111, 106, 38, 230, 129, 227, 205, 92]));
/// AON: GDAON22HUIVFEZOU3HHQ6PR52PLIIKKAAKUPNXXHDIJNOK7UAVN2KVXT
static immutable AON = KeyPair(PublicKey([192, 230, 235, 71, 162, 42, 82, 101, 212, 217, 207, 15, 62, 61, 211, 214, 132, 41, 64, 2, 168, 246, 222, 231, 26, 18, 215, 43, 244, 5, 91, 165]), SecretKey([168, 93, 242, 252, 196, 230, 5, 11, 250, 248, 128, 10, 238, 207, 30, 115, 38, 238, 162, 228, 104, 247, 141, 227, 119, 228, 171, 107, 225, 77, 128, 107]), Seed([4, 140, 161, 216, 229, 176, 37, 25, 13, 216, 197, 217, 206, 108, 211, 224, 66, 164, 94, 255, 1, 33, 124, 242, 141, 201, 68, 176, 178, 143, 64, 99]));
/// AOO: GDAOO22K7J2TQVK5KP62J5MBAFBK3DUAIZWKXPKPEBDO7VFKZ3XHVZT2
static immutable AOO = KeyPair(PublicKey([192, 231, 107, 74, 250, 117, 56, 85, 93, 83, 253, 164, 245, 129, 1, 66, 173, 142, 128, 70, 108, 171, 189, 79, 32, 70, 239, 212, 170, 206, 238, 122]), SecretKey([120, 243, 106, 48, 66, 236, 122, 94, 135, 120, 198, 212, 200, 210, 151, 189, 236, 251, 119, 127, 104, 28, 150, 53, 104, 188, 94, 41, 168, 188, 63, 112]), Seed([165, 228, 237, 8, 12, 101, 96, 86, 110, 90, 242, 222, 129, 127, 149, 71, 74, 150, 98, 88, 216, 184, 218, 228, 28, 49, 216, 131, 128, 128, 208, 117]));
/// AOP: GDAOP22NXBST4HREIFGSBOAFYNXUQJLOLWDXAH6OCFUZOPFROPUEXL53
static immutable AOP = KeyPair(PublicKey([192, 231, 235, 77, 184, 101, 62, 30, 36, 65, 77, 32, 184, 5, 195, 111, 72, 37, 110, 93, 135, 112, 31, 206, 17, 105, 151, 60, 177, 115, 232, 75]), SecretKey([216, 250, 172, 16, 1, 249, 214, 9, 55, 109, 250, 46, 76, 236, 173, 160, 27, 159, 218, 150, 31, 63, 14, 202, 94, 48, 23, 250, 3, 87, 34, 111]), Seed([173, 25, 55, 105, 97, 25, 192, 149, 176, 136, 21, 167, 57, 157, 82, 139, 26, 187, 113, 223, 128, 26, 225, 79, 73, 5, 255, 107, 63, 92, 51, 236]));
/// AOQ: GDAOQ22WZDCKYJ7WKGEUXTHACFHESOWSJFWUAIDO4OYRAEUWWHJOLWXT
static immutable AOQ = KeyPair(PublicKey([192, 232, 107, 86, 200, 196, 172, 39, 246, 81, 137, 75, 204, 224, 17, 78, 73, 58, 210, 73, 109, 64, 32, 110, 227, 177, 16, 18, 150, 177, 210, 229]), SecretKey([64, 149, 28, 125, 67, 177, 231, 9, 142, 65, 27, 216, 111, 154, 124, 34, 130, 72, 173, 134, 253, 238, 152, 89, 56, 123, 249, 24, 185, 206, 222, 64]), Seed([86, 77, 125, 42, 69, 253, 124, 253, 158, 122, 215, 195, 180, 199, 57, 218, 195, 206, 6, 182, 109, 36, 251, 84, 80, 146, 36, 119, 12, 144, 203, 220]));
/// AOR: GDAOR22ID2XP7LVY25RGXMJJ3BSRIOHLC264V47IN5PLGSMIAVKK432N
static immutable AOR = KeyPair(PublicKey([192, 232, 235, 72, 30, 174, 255, 174, 184, 215, 98, 107, 177, 41, 216, 101, 20, 56, 235, 22, 189, 202, 243, 232, 111, 94, 179, 73, 136, 5, 84, 174]), SecretKey([80, 138, 130, 43, 95, 166, 185, 53, 33, 76, 152, 157, 7, 49, 187, 97, 208, 199, 101, 0, 159, 193, 51, 159, 255, 69, 41, 30, 81, 140, 104, 113]), Seed([31, 174, 122, 51, 223, 157, 77, 206, 30, 52, 53, 181, 168, 58, 126, 86, 150, 55, 74, 210, 119, 203, 230, 72, 228, 176, 236, 5, 25, 11, 14, 110]));
/// AOS: GDAOS22MQGEGDFUG4E7UNCW353HCF5EYG274NHEXVCKUMEA2K2277SAD
static immutable AOS = KeyPair(PublicKey([192, 233, 107, 76, 129, 136, 97, 150, 134, 225, 63, 70, 138, 219, 238, 206, 34, 244, 152, 54, 191, 198, 156, 151, 168, 149, 70, 16, 26, 86, 181, 255]), SecretKey([8, 209, 96, 211, 72, 11, 5, 149, 188, 92, 167, 172, 222, 82, 221, 39, 187, 79, 179, 212, 144, 154, 120, 50, 56, 167, 133, 230, 230, 153, 170, 83]), Seed([223, 242, 141, 165, 104, 125, 91, 19, 157, 54, 137, 97, 19, 135, 8, 177, 2, 89, 12, 177, 173, 28, 200, 223, 71, 108, 143, 68, 188, 206, 143, 124]));
/// AOT: GDAOT22W3LJ2BKJW7Q3TKA5MTHXETFYN6M3TA4GZGFFYKOPT4TGVL6OT
static immutable AOT = KeyPair(PublicKey([192, 233, 235, 86, 218, 211, 160, 169, 54, 252, 55, 53, 3, 172, 153, 238, 73, 151, 13, 243, 55, 48, 112, 217, 49, 75, 133, 57, 243, 228, 205, 85]), SecretKey([0, 27, 253, 129, 219, 231, 244, 74, 146, 117, 16, 13, 38, 132, 31, 2, 249, 73, 90, 38, 216, 34, 229, 181, 238, 124, 144, 64, 218, 23, 127, 117]), Seed([223, 31, 237, 241, 97, 62, 172, 215, 93, 88, 0, 96, 150, 62, 183, 10, 58, 122, 246, 50, 240, 160, 56, 179, 22, 65, 33, 24, 19, 82, 191, 68]));
/// AOU: GDAOU22GPEYNJPV6RFJTZI66VEGY3V7M3IJXMCMXUNS3WE6D7GEVSK43
static immutable AOU = KeyPair(PublicKey([192, 234, 107, 70, 121, 48, 212, 190, 190, 137, 83, 60, 163, 222, 169, 13, 141, 215, 236, 218, 19, 118, 9, 151, 163, 101, 187, 19, 195, 249, 137, 89]), SecretKey([24, 228, 87, 57, 161, 120, 174, 148, 38, 210, 181, 133, 132, 2, 249, 184, 41, 18, 167, 119, 22, 11, 65, 245, 200, 8, 2, 142, 88, 88, 38, 107]), Seed([110, 198, 170, 141, 59, 129, 45, 8, 11, 47, 160, 30, 133, 45, 220, 74, 236, 98, 155, 16, 161, 101, 253, 225, 98, 91, 160, 94, 118, 84, 238, 80]));
/// AOV: GDAOV22ZVJVELRK7TN4223EV57HLNYAWJCPXNJOQZK6R3PO6QFCB4RS6
static immutable AOV = KeyPair(PublicKey([192, 234, 235, 89, 170, 106, 69, 197, 95, 155, 121, 173, 108, 149, 239, 206, 182, 224, 22, 72, 159, 118, 165, 208, 202, 189, 29, 189, 222, 129, 68, 30]), SecretKey([80, 223, 125, 164, 51, 168, 168, 118, 119, 77, 161, 105, 215, 152, 75, 100, 220, 228, 15, 111, 64, 124, 19, 35, 183, 200, 52, 156, 105, 93, 15, 100]), Seed([220, 147, 202, 45, 164, 129, 56, 12, 116, 154, 164, 43, 151, 207, 6, 51, 236, 110, 204, 193, 216, 194, 119, 165, 31, 65, 161, 118, 153, 96, 37, 208]));
/// AOW: GDAOW22MRLCVARGQLI5VEP56JZVVT4ZY6LAEOYZQ5CA2FORS7FJENUXQ
static immutable AOW = KeyPair(PublicKey([192, 235, 107, 76, 138, 197, 80, 68, 208, 90, 59, 82, 63, 190, 78, 107, 89, 243, 56, 242, 192, 71, 99, 48, 232, 129, 162, 186, 50, 249, 82, 70]), SecretKey([200, 96, 23, 6, 194, 247, 72, 215, 172, 133, 66, 100, 155, 127, 223, 110, 17, 140, 161, 157, 135, 11, 235, 100, 237, 120, 67, 113, 218, 242, 74, 67]), Seed([216, 2, 206, 88, 19, 81, 101, 72, 142, 5, 8, 195, 84, 39, 69, 47, 173, 8, 173, 135, 25, 95, 161, 37, 201, 152, 148, 170, 210, 209, 57, 4]));
/// AOX: GDAOX22VKM7K74E4TEH3GXNPX5SG76EAGCOZ7TQ7SJOUJHKAIIWEOS6L
static immutable AOX = KeyPair(PublicKey([192, 235, 235, 85, 83, 62, 175, 240, 156, 153, 15, 179, 93, 175, 191, 100, 111, 248, 128, 48, 157, 159, 206, 31, 146, 93, 68, 157, 64, 66, 44, 71]), SecretKey([88, 37, 121, 202, 175, 45, 26, 63, 6, 156, 240, 22, 225, 164, 26, 243, 154, 135, 67, 129, 172, 226, 228, 87, 165, 195, 191, 164, 226, 97, 169, 73]), Seed([49, 230, 196, 249, 49, 171, 255, 175, 1, 251, 104, 226, 232, 160, 136, 208, 47, 34, 208, 22, 131, 171, 213, 49, 97, 103, 194, 238, 60, 157, 170, 12]));
/// AOY: GDAOY22TOYDI7XIBDX5OLXJBB4QJCE5DCA6RVUQTPHDKXZQLCZMUWOSW
static immutable AOY = KeyPair(PublicKey([192, 236, 107, 83, 118, 6, 143, 221, 1, 29, 250, 229, 221, 33, 15, 32, 145, 19, 163, 16, 61, 26, 210, 19, 121, 198, 171, 230, 11, 22, 89, 75]), SecretKey([144, 148, 229, 32, 136, 251, 108, 247, 41, 5, 24, 26, 87, 42, 126, 125, 107, 8, 108, 169, 74, 59, 25, 226, 106, 235, 2, 131, 180, 49, 163, 64]), Seed([177, 77, 107, 178, 240, 70, 210, 230, 77, 124, 186, 197, 107, 34, 68, 90, 30, 195, 141, 183, 53, 60, 177, 251, 43, 98, 126, 38, 182, 188, 52, 41]));
/// AOZ: GDAOZ22AXASLKJBTOJ6B4F3FQ667VJ6OGQMRD5IZK4L2TK65N6OSP5YC
static immutable AOZ = KeyPair(PublicKey([192, 236, 235, 64, 184, 36, 181, 36, 51, 114, 124, 30, 23, 101, 135, 189, 250, 167, 206, 52, 25, 17, 245, 25, 87, 23, 169, 171, 221, 111, 157, 39]), SecretKey([24, 154, 13, 38, 98, 81, 4, 221, 185, 97, 241, 106, 156, 177, 185, 54, 216, 129, 80, 201, 174, 171, 126, 222, 231, 17, 252, 175, 136, 155, 35, 91]), Seed([219, 48, 29, 94, 98, 42, 142, 255, 132, 105, 14, 140, 133, 215, 24, 201, 246, 242, 129, 74, 41, 242, 171, 208, 18, 65, 83, 221, 211, 237, 125, 247]));
/// APA: GDAPA22OEW6LH2DZH2ONZ3SHQCJROPQ2SMYCFBR77L6EKNYQHY63E5H7
static immutable APA = KeyPair(PublicKey([192, 240, 107, 78, 37, 188, 179, 232, 121, 62, 156, 220, 238, 71, 128, 147, 23, 62, 26, 147, 48, 34, 134, 63, 250, 252, 69, 55, 16, 62, 61, 178]), SecretKey([160, 174, 9, 78, 109, 22, 142, 227, 211, 215, 133, 245, 182, 80, 13, 116, 243, 210, 182, 236, 29, 83, 175, 183, 85, 226, 152, 25, 202, 57, 21, 123]), Seed([46, 86, 220, 206, 234, 243, 210, 147, 181, 18, 91, 25, 79, 192, 27, 158, 232, 207, 68, 59, 225, 83, 178, 189, 110, 244, 22, 88, 192, 43, 245, 197]));
/// APB: GDAPB22BXGFCDCGIMDL3CMLZJVBMPYRMND3RLUULWMOC3WNKJBBRNPGK
static immutable APB = KeyPair(PublicKey([192, 240, 235, 65, 185, 138, 33, 136, 200, 96, 215, 177, 49, 121, 77, 66, 199, 226, 44, 104, 247, 21, 210, 139, 179, 28, 45, 217, 170, 72, 67, 22]), SecretKey([112, 111, 109, 98, 114, 111, 26, 191, 124, 32, 242, 108, 132, 36, 232, 100, 25, 165, 156, 244, 61, 80, 174, 225, 26, 210, 194, 133, 35, 212, 211, 101]), Seed([7, 169, 110, 91, 76, 68, 215, 124, 227, 198, 85, 103, 78, 44, 83, 111, 74, 146, 242, 21, 178, 234, 204, 112, 193, 135, 73, 130, 185, 18, 174, 224]));
/// APC: GDAPC22ZV3PX53GOH5O576XQGKIGY4Y7Q22MKXW4VX2KIETVLT4MUMRN
static immutable APC = KeyPair(PublicKey([192, 241, 107, 89, 174, 223, 126, 236, 206, 63, 93, 223, 250, 240, 50, 144, 108, 115, 31, 134, 180, 197, 94, 220, 173, 244, 164, 18, 117, 92, 248, 202]), SecretKey([32, 71, 71, 97, 116, 40, 61, 68, 253, 15, 83, 100, 55, 23, 36, 135, 130, 208, 224, 126, 35, 210, 80, 35, 106, 163, 98, 152, 11, 160, 175, 85]), Seed([39, 170, 144, 2, 237, 95, 22, 199, 213, 61, 210, 137, 32, 56, 87, 236, 145, 6, 121, 62, 122, 65, 36, 201, 145, 77, 225, 114, 169, 138, 226, 72]));
/// APD: GDAPD22FFNXZV6GFLIZFXG5OUDLWWYUC2SRULZKJDOD2LBGC3EQMUIPG
static immutable APD = KeyPair(PublicKey([192, 241, 235, 69, 43, 111, 154, 248, 197, 90, 50, 91, 155, 174, 160, 215, 107, 98, 130, 212, 163, 69, 229, 73, 27, 135, 165, 132, 194, 217, 32, 202]), SecretKey([56, 176, 90, 253, 167, 75, 116, 229, 87, 103, 191, 71, 109, 198, 197, 39, 83, 189, 131, 36, 204, 84, 6, 213, 28, 59, 136, 20, 150, 111, 104, 83]), Seed([99, 40, 20, 78, 153, 121, 247, 105, 99, 168, 208, 95, 109, 133, 65, 106, 169, 173, 160, 132, 247, 44, 32, 253, 89, 88, 27, 131, 12, 61, 141, 191]));
/// APE: GDAPE224JBJHVNOODSGZ6U5I7VGVOTTRRKAY42KZGYGOHIMNK7YWTS4Z
static immutable APE = KeyPair(PublicKey([192, 242, 107, 92, 72, 82, 122, 181, 206, 28, 141, 159, 83, 168, 253, 77, 87, 78, 113, 138, 129, 142, 105, 89, 54, 12, 227, 161, 141, 87, 241, 105]), SecretKey([104, 134, 28, 131, 179, 186, 26, 120, 191, 163, 118, 123, 252, 134, 97, 90, 96, 250, 14, 101, 29, 50, 145, 47, 98, 44, 103, 104, 115, 208, 182, 65]), Seed([71, 112, 121, 160, 125, 128, 12, 229, 104, 242, 127, 168, 43, 216, 21, 128, 10, 122, 139, 94, 110, 136, 113, 131, 228, 164, 56, 150, 101, 40, 122, 183]));
/// APF: GDAPF223CB6YQZP2E42N2JU3W2XFQ6266FWR32SJODOP3LNPHOF5XV3E
static immutable APF = KeyPair(PublicKey([192, 242, 235, 91, 16, 125, 136, 101, 250, 39, 52, 221, 38, 155, 182, 174, 88, 123, 94, 241, 109, 29, 234, 73, 112, 220, 253, 173, 175, 59, 139, 219]), SecretKey([248, 39, 146, 239, 179, 4, 254, 137, 205, 243, 123, 234, 2, 227, 188, 220, 203, 184, 71, 178, 255, 144, 157, 51, 124, 237, 179, 84, 197, 249, 227, 79]), Seed([1, 133, 122, 40, 82, 12, 90, 111, 219, 16, 142, 118, 117, 45, 240, 252, 98, 238, 160, 162, 149, 199, 63, 198, 224, 37, 39, 101, 96, 51, 144, 188]));
/// APG: GDAPG22PQUCKM6BM7A4CLXVVO6S5JMSQENPD7YB2A7AM66XEZNMLSQWT
static immutable APG = KeyPair(PublicKey([192, 243, 107, 79, 133, 4, 166, 120, 44, 248, 56, 37, 222, 181, 119, 165, 212, 178, 80, 35, 94, 63, 224, 58, 7, 192, 207, 122, 228, 203, 88, 185]), SecretKey([104, 240, 215, 155, 137, 23, 144, 21, 6, 43, 230, 161, 34, 184, 169, 254, 66, 147, 250, 94, 116, 134, 231, 27, 238, 165, 135, 137, 7, 20, 147, 99]), Seed([120, 136, 205, 6, 56, 104, 116, 66, 102, 225, 168, 68, 15, 95, 140, 165, 63, 32, 188, 31, 132, 42, 159, 246, 245, 137, 24, 203, 248, 240, 102, 63]));
/// APH: GDAPH22ZF63A2LDYCXMGH7GGDOVIZ7ERM2BOKFOP7O3E2MCTAUB7NNBM
static immutable APH = KeyPair(PublicKey([192, 243, 235, 89, 47, 182, 13, 44, 120, 21, 216, 99, 252, 198, 27, 170, 140, 252, 145, 102, 130, 229, 21, 207, 251, 182, 77, 48, 83, 5, 3, 246]), SecretKey([16, 229, 32, 235, 243, 48, 243, 192, 213, 221, 243, 152, 222, 2, 214, 212, 149, 243, 84, 29, 165, 122, 177, 139, 109, 94, 72, 221, 98, 150, 69, 108]), Seed([2, 64, 244, 181, 6, 25, 117, 24, 143, 151, 82, 193, 43, 134, 163, 84, 252, 150, 233, 135, 181, 139, 254, 11, 165, 80, 23, 218, 163, 22, 194, 205]));
/// API: GDAPI22GR2E7ZBVRRXAWNAU5SU766SN4P2QCXGYQQPGCHLE2SZOHQ5VB
static immutable API = KeyPair(PublicKey([192, 244, 107, 70, 142, 137, 252, 134, 177, 141, 193, 102, 130, 157, 149, 63, 239, 73, 188, 126, 160, 43, 155, 16, 131, 204, 35, 172, 154, 150, 92, 120]), SecretKey([184, 202, 128, 8, 84, 190, 133, 236, 228, 65, 127, 186, 63, 223, 255, 188, 28, 122, 50, 68, 74, 57, 134, 129, 240, 3, 55, 209, 66, 15, 26, 99]), Seed([117, 248, 76, 59, 1, 179, 213, 56, 229, 0, 240, 152, 169, 154, 245, 159, 140, 204, 105, 12, 201, 71, 56, 47, 64, 38, 217, 102, 225, 181, 141, 81]));
/// APJ: GDAPJ22GGWEJIRQTNQ5FUZFI4T46HDUQRGJKQHF6XRMHY6KLAS7LISVG
static immutable APJ = KeyPair(PublicKey([192, 244, 235, 70, 53, 136, 148, 70, 19, 108, 58, 90, 100, 168, 228, 249, 227, 142, 144, 137, 146, 168, 28, 190, 188, 88, 124, 121, 75, 4, 190, 180]), SecretKey([128, 85, 141, 194, 238, 231, 162, 61, 200, 26, 101, 219, 195, 94, 176, 225, 37, 248, 149, 208, 103, 13, 234, 18, 239, 160, 38, 60, 172, 88, 252, 96]), Seed([10, 205, 206, 6, 165, 176, 34, 109, 82, 134, 16, 150, 114, 118, 238, 255, 104, 68, 151, 205, 180, 14, 132, 82, 16, 182, 179, 56, 180, 100, 176, 220]));
/// APK: GDAPK223SKQE5TKLBREDFQKPQQTGHHPAPUU6KQI7MLSEQPMXYYPOCKTB
static immutable APK = KeyPair(PublicKey([192, 245, 107, 91, 146, 160, 78, 205, 75, 12, 72, 50, 193, 79, 132, 38, 99, 157, 224, 125, 41, 229, 65, 31, 98, 228, 72, 61, 151, 198, 30, 225]), SecretKey([144, 5, 132, 22, 97, 24, 160, 75, 132, 140, 75, 209, 185, 235, 224, 200, 49, 251, 1, 154, 112, 10, 169, 30, 207, 50, 57, 62, 0, 25, 30, 89]), Seed([231, 141, 187, 131, 141, 21, 217, 38, 230, 175, 19, 70, 240, 16, 154, 27, 195, 59, 139, 145, 210, 157, 28, 137, 156, 125, 234, 44, 74, 217, 244, 99]));
/// APL: GDAPL22U6Y4D3KJ2MOJ4VRPCVTWFHGVC24CZIRN5YNX2654PI3PFXJJI
static immutable APL = KeyPair(PublicKey([192, 245, 235, 84, 246, 56, 61, 169, 58, 99, 147, 202, 197, 226, 172, 236, 83, 154, 162, 215, 5, 148, 69, 189, 195, 111, 175, 119, 143, 70, 222, 91]), SecretKey([16, 232, 123, 248, 44, 166, 63, 102, 167, 123, 28, 38, 199, 242, 222, 42, 229, 56, 160, 97, 42, 253, 231, 242, 154, 224, 220, 40, 204, 106, 118, 75]), Seed([163, 89, 162, 19, 249, 11, 11, 80, 166, 102, 25, 169, 19, 96, 27, 56, 118, 179, 240, 44, 41, 45, 241, 21, 212, 18, 4, 201, 229, 227, 167, 75]));
/// APM: GDAPM22HEQDOLCFTWWXXWCDI2ISPIL2JI6QOES2XBSMR5MFIPLCQHYXX
static immutable APM = KeyPair(PublicKey([192, 246, 107, 71, 36, 6, 229, 136, 179, 181, 175, 123, 8, 104, 210, 36, 244, 47, 73, 71, 160, 226, 75, 87, 12, 153, 30, 176, 168, 122, 197, 3]), SecretKey([168, 211, 79, 51, 120, 63, 156, 39, 114, 157, 197, 227, 220, 92, 50, 217, 239, 114, 234, 183, 78, 225, 124, 127, 230, 64, 49, 116, 159, 107, 134, 125]), Seed([238, 123, 47, 97, 164, 135, 39, 217, 193, 208, 153, 135, 249, 107, 88, 2, 212, 196, 140, 192, 22, 55, 139, 201, 131, 144, 163, 87, 48, 149, 227, 74]));
/// APN: GDAPN227M6XYTASPOUTBYLGNFKIE5PEBFI5W7DVJU4ONHGXRUVVNXWB2
static immutable APN = KeyPair(PublicKey([192, 246, 235, 95, 103, 175, 137, 130, 79, 117, 38, 28, 44, 205, 42, 144, 78, 188, 129, 42, 59, 111, 142, 169, 167, 28, 211, 154, 241, 165, 106, 219]), SecretKey([160, 154, 38, 191, 60, 59, 20, 221, 151, 218, 251, 195, 156, 214, 112, 160, 199, 233, 30, 152, 121, 75, 89, 189, 153, 203, 129, 255, 127, 143, 188, 110]), Seed([247, 52, 33, 197, 109, 243, 77, 34, 241, 230, 251, 90, 38, 89, 85, 38, 105, 244, 234, 159, 36, 132, 140, 76, 140, 169, 251, 83, 248, 77, 219, 108]));
/// APO: GDAPO22KKPBA2IBRBVZ2HCLFPKCCHRJE42A5BN3ZT6GUHKRSLYND3S6V
static immutable APO = KeyPair(PublicKey([192, 247, 107, 74, 83, 194, 13, 32, 49, 13, 115, 163, 137, 101, 122, 132, 35, 197, 36, 230, 129, 208, 183, 121, 159, 141, 67, 170, 50, 94, 26, 61]), SecretKey([184, 119, 193, 255, 111, 196, 109, 213, 229, 49, 237, 184, 49, 39, 51, 183, 22, 105, 147, 100, 187, 66, 135, 230, 236, 245, 117, 231, 177, 11, 103, 121]), Seed([133, 45, 119, 248, 233, 198, 184, 78, 179, 136, 82, 113, 219, 124, 176, 130, 17, 168, 133, 4, 166, 134, 134, 46, 187, 78, 37, 77, 93, 82, 174, 196]));
/// APP: GDAPP22IVZ5C36IZQQZ6W65SNOJND4TXDJDETIKCI6OGNP7ZUK7KNNPQ
static immutable APP = KeyPair(PublicKey([192, 247, 235, 72, 174, 122, 45, 249, 25, 132, 51, 235, 123, 178, 107, 146, 209, 242, 119, 26, 70, 73, 161, 66, 71, 156, 102, 191, 249, 162, 190, 166]), SecretKey([136, 182, 248, 217, 67, 148, 170, 181, 232, 22, 162, 25, 36, 188, 221, 228, 54, 182, 182, 249, 213, 97, 41, 251, 138, 134, 188, 182, 172, 229, 255, 114]), Seed([52, 53, 182, 107, 233, 83, 73, 250, 72, 134, 122, 135, 96, 193, 167, 180, 130, 76, 209, 77, 94, 99, 194, 219, 193, 169, 42, 19, 219, 41, 112, 11]));
/// APQ: GDAPQ22YWKIHHONAIDU4IJY2RHH42JLQXTXIIIO4FOKGTIM3U3TWMAKF
static immutable APQ = KeyPair(PublicKey([192, 248, 107, 88, 178, 144, 115, 185, 160, 64, 233, 196, 39, 26, 137, 207, 205, 37, 112, 188, 238, 132, 33, 220, 43, 148, 105, 161, 155, 166, 231, 102]), SecretKey([96, 228, 208, 40, 230, 171, 122, 252, 216, 162, 192, 112, 142, 59, 71, 182, 186, 137, 171, 166, 74, 225, 164, 244, 139, 14, 202, 126, 206, 206, 242, 109]), Seed([114, 121, 99, 122, 118, 94, 67, 145, 189, 167, 205, 48, 96, 77, 253, 252, 42, 238, 187, 42, 65, 18, 241, 116, 37, 69, 39, 43, 135, 38, 176, 168]));
/// APR: GDAPR22VUZKKBFERVMLB4F4J5OWQYEGVDUMEWKUN64B352GC4CUJGHGK
static immutable APR = KeyPair(PublicKey([192, 248, 235, 85, 166, 84, 160, 148, 145, 171, 22, 30, 23, 137, 235, 173, 12, 16, 213, 29, 24, 75, 42, 141, 247, 3, 190, 232, 194, 224, 168, 147]), SecretKey([48, 147, 245, 157, 247, 181, 91, 5, 205, 50, 96, 239, 103, 70, 133, 45, 200, 168, 179, 42, 184, 108, 242, 179, 87, 128, 85, 108, 22, 100, 217, 109]), Seed([69, 200, 215, 16, 216, 227, 41, 89, 68, 99, 48, 194, 148, 238, 65, 58, 9, 224, 124, 215, 48, 160, 19, 83, 53, 98, 106, 31, 61, 3, 133, 23]));
/// APS: GDAPS22B3UY4RJB2AIXLKTDQVYTK57RVLHGGU2BMXEX36YPAFY5DGRJW
static immutable APS = KeyPair(PublicKey([192, 249, 107, 65, 221, 49, 200, 164, 58, 2, 46, 181, 76, 112, 174, 38, 174, 254, 53, 89, 204, 106, 104, 44, 185, 47, 191, 97, 224, 46, 58, 51]), SecretKey([208, 80, 21, 41, 160, 201, 28, 144, 100, 162, 125, 233, 237, 193, 97, 8, 39, 59, 225, 127, 63, 225, 97, 236, 134, 164, 193, 155, 73, 102, 138, 90]), Seed([33, 210, 31, 140, 30, 229, 195, 228, 82, 37, 88, 70, 126, 208, 19, 43, 244, 66, 154, 135, 70, 2, 9, 143, 252, 73, 207, 228, 175, 88, 84, 172]));
/// APT: GDAPT22EHLXOCZMAO2HYNE7TGQDVNSDGUR6UMHZKTWK354HNTKDZRYPD
static immutable APT = KeyPair(PublicKey([192, 249, 235, 68, 58, 238, 225, 101, 128, 118, 143, 134, 147, 243, 52, 7, 86, 200, 102, 164, 125, 70, 31, 42, 157, 149, 190, 240, 237, 154, 135, 152]), SecretKey([184, 187, 179, 175, 7, 69, 155, 33, 139, 247, 153, 30, 210, 225, 241, 72, 220, 21, 183, 203, 11, 146, 77, 31, 52, 59, 241, 54, 204, 56, 118, 89]), Seed([218, 9, 125, 210, 208, 107, 146, 237, 103, 80, 56, 188, 67, 197, 121, 240, 169, 10, 121, 113, 122, 137, 129, 122, 72, 96, 49, 214, 169, 172, 48, 23]));
/// APU: GDAPU22GFOWWJQPMKEF7FYUNR6VKXBAM4BSVMUM5DPCFNHSSDQ5YOKDQ
static immutable APU = KeyPair(PublicKey([192, 250, 107, 70, 43, 173, 100, 193, 236, 81, 11, 242, 226, 141, 143, 170, 171, 132, 12, 224, 101, 86, 81, 157, 27, 196, 86, 158, 82, 28, 59, 135]), SecretKey([152, 110, 147, 116, 140, 48, 209, 133, 160, 37, 115, 194, 86, 76, 245, 186, 59, 53, 88, 18, 52, 36, 242, 87, 144, 30, 50, 209, 213, 253, 239, 124]), Seed([158, 122, 8, 181, 62, 152, 241, 153, 179, 233, 114, 88, 161, 196, 57, 244, 87, 187, 212, 48, 16, 185, 61, 80, 12, 203, 73, 208, 77, 254, 211, 62]));
/// APV: GDAPV22WEZUSOABITVSM32TDB2VDNVB6PM42ZSBMFWET4ZGKICNZG3QQ
static immutable APV = KeyPair(PublicKey([192, 250, 235, 86, 38, 105, 39, 0, 40, 157, 100, 205, 234, 99, 14, 170, 54, 212, 62, 123, 57, 172, 200, 44, 45, 137, 62, 100, 202, 64, 155, 147]), SecretKey([152, 178, 89, 173, 137, 252, 60, 189, 162, 39, 183, 208, 183, 155, 165, 112, 145, 52, 177, 32, 35, 153, 128, 244, 232, 32, 232, 121, 82, 251, 193, 102]), Seed([54, 71, 84, 78, 95, 242, 233, 46, 181, 224, 224, 243, 101, 91, 15, 207, 183, 16, 13, 130, 182, 157, 84, 70, 97, 63, 4, 1, 229, 151, 71, 40]));
/// APW: GDAPW22K2TKGERE4REX6XTTSARU3HQUPRN7KXSU2YIPMJVC3YGGQDTOF
static immutable APW = KeyPair(PublicKey([192, 251, 107, 74, 212, 212, 98, 68, 156, 137, 47, 235, 206, 114, 4, 105, 179, 194, 143, 139, 126, 171, 202, 154, 194, 30, 196, 212, 91, 193, 141, 1]), SecretKey([16, 209, 171, 128, 206, 67, 28, 185, 207, 144, 16, 148, 168, 82, 38, 138, 9, 24, 73, 100, 10, 242, 94, 65, 127, 92, 77, 240, 117, 99, 46, 97]), Seed([122, 249, 176, 71, 168, 247, 155, 11, 170, 125, 80, 15, 69, 56, 222, 247, 186, 22, 32, 147, 223, 67, 191, 28, 201, 101, 105, 10, 76, 238, 235, 63]));
/// APX: GDAPX22F4EP6IMO2LXYDTOVJ7RNADYD7YROR46ULMMIE45W5RI7PG3KI
static immutable APX = KeyPair(PublicKey([192, 251, 235, 69, 225, 31, 228, 49, 218, 93, 240, 57, 186, 169, 252, 90, 1, 224, 127, 196, 93, 30, 122, 139, 99, 16, 78, 118, 221, 138, 62, 243]), SecretKey([128, 8, 165, 61, 40, 199, 208, 247, 224, 28, 230, 242, 202, 130, 100, 130, 9, 243, 74, 77, 11, 46, 175, 29, 127, 22, 253, 2, 17, 238, 124, 109]), Seed([77, 248, 195, 7, 119, 104, 212, 120, 120, 142, 145, 5, 145, 64, 200, 29, 251, 211, 201, 142, 209, 94, 135, 70, 167, 61, 173, 239, 220, 76, 172, 13]));
/// APY: GDAPY22LJCRS5FUHPXSICLNAWAVPHZSH73CCLMVK5ZQIWXWY2VKXXHCA
static immutable APY = KeyPair(PublicKey([192, 252, 107, 75, 72, 163, 46, 150, 135, 125, 228, 129, 45, 160, 176, 42, 243, 230, 71, 254, 196, 37, 178, 170, 238, 96, 139, 94, 216, 213, 85, 123]), SecretKey([160, 63, 154, 58, 171, 203, 247, 7, 228, 166, 128, 249, 128, 138, 252, 249, 166, 73, 237, 132, 23, 104, 124, 237, 241, 247, 189, 80, 244, 56, 231, 112]), Seed([117, 211, 205, 134, 6, 229, 248, 165, 52, 107, 50, 53, 43, 51, 65, 82, 90, 86, 186, 212, 113, 136, 139, 11, 73, 119, 206, 49, 24, 223, 54, 125]));
/// APZ: GDAPZ22MD4DVNBDO42IBRXGN4YNQ5B332ZRVLW2PUGDQXMHO5A7AIMNW
static immutable APZ = KeyPair(PublicKey([192, 252, 235, 76, 31, 7, 86, 132, 110, 230, 144, 24, 220, 205, 230, 27, 14, 135, 123, 214, 99, 85, 219, 79, 161, 135, 11, 176, 238, 232, 62, 4]), SecretKey([32, 75, 45, 37, 71, 128, 7, 94, 186, 107, 211, 172, 111, 7, 142, 223, 83, 115, 233, 143, 241, 161, 101, 234, 139, 24, 188, 179, 20, 86, 135, 70]), Seed([39, 173, 235, 10, 157, 114, 82, 9, 167, 232, 178, 15, 3, 196, 71, 146, 17, 167, 141, 142, 76, 135, 148, 180, 236, 230, 165, 210, 106, 87, 247, 156]));
/// AQA: GDAQA22MZVH34SBNU6JJSXR5QVYIFWFKQQJ6JYO3OFW2O457BC5S27DF
static immutable AQA = KeyPair(PublicKey([193, 0, 107, 76, 205, 79, 190, 72, 45, 167, 146, 153, 94, 61, 133, 112, 130, 216, 170, 132, 19, 228, 225, 219, 113, 109, 167, 115, 191, 8, 187, 45]), SecretKey([120, 227, 125, 162, 122, 87, 245, 61, 182, 125, 18, 50, 202, 197, 129, 218, 228, 26, 48, 178, 19, 69, 71, 25, 121, 240, 250, 17, 163, 134, 177, 76]), Seed([149, 178, 200, 103, 189, 81, 89, 203, 57, 235, 10, 90, 36, 45, 43, 201, 173, 82, 96, 1, 195, 154, 42, 9, 185, 150, 176, 152, 141, 254, 21, 230]));
/// AQB: GDAQB22HSCZLQVB5O2O5RXAYH6X6B6XLDNZBHRF7ELN5CQLODXRKGAT5
static immutable AQB = KeyPair(PublicKey([193, 0, 235, 71, 144, 178, 184, 84, 61, 118, 157, 216, 220, 24, 63, 175, 224, 250, 235, 27, 114, 19, 196, 191, 34, 219, 209, 65, 110, 29, 226, 163]), SecretKey([104, 176, 71, 164, 231, 191, 124, 77, 237, 132, 79, 166, 168, 51, 27, 107, 242, 40, 212, 32, 159, 186, 213, 209, 200, 165, 23, 7, 181, 245, 205, 103]), Seed([20, 237, 197, 119, 49, 60, 115, 31, 163, 111, 0, 251, 251, 165, 156, 58, 10, 243, 208, 201, 102, 60, 209, 59, 71, 13, 178, 233, 137, 60, 35, 224]));
/// AQC: GDAQC22HZFIAYRYXCJV6BX7HPONBNZPQNU7DTXEMSIR3FDCGWCI5XIV4
static immutable AQC = KeyPair(PublicKey([193, 1, 107, 71, 201, 80, 12, 71, 23, 18, 107, 224, 223, 231, 123, 154, 22, 229, 240, 109, 62, 57, 220, 140, 146, 35, 178, 140, 70, 176, 145, 219]), SecretKey([192, 158, 133, 104, 180, 60, 165, 29, 64, 181, 220, 151, 143, 86, 69, 44, 89, 52, 224, 234, 70, 176, 28, 143, 222, 181, 2, 150, 162, 53, 111, 99]), Seed([180, 10, 15, 3, 62, 195, 161, 234, 227, 125, 194, 182, 0, 194, 199, 243, 61, 182, 165, 224, 137, 179, 239, 39, 88, 208, 155, 240, 10, 13, 235, 39]));
/// AQD: GDAQD22CBPA2R7QO7ZZOUTTRML367M44FWWPB7QTQDOW6RY63NROWPA7
static immutable AQD = KeyPair(PublicKey([193, 1, 235, 66, 11, 193, 168, 254, 14, 254, 114, 234, 78, 113, 98, 247, 239, 179, 156, 45, 172, 240, 254, 19, 128, 221, 111, 71, 30, 219, 98, 235]), SecretKey([136, 83, 203, 242, 126, 73, 131, 253, 170, 112, 44, 163, 192, 5, 78, 181, 127, 152, 28, 125, 97, 115, 27, 58, 242, 230, 145, 90, 168, 75, 243, 92]), Seed([9, 84, 36, 80, 71, 129, 30, 139, 38, 153, 103, 66, 102, 163, 81, 228, 147, 7, 3, 71, 136, 250, 184, 107, 108, 217, 246, 64, 40, 193, 227, 136]));
/// AQE: GDAQE22P4WN2FMI2RNKSLXR24WCHGC32CQTLHJ3CO7IPNFWWBDG272UT
static immutable AQE = KeyPair(PublicKey([193, 2, 107, 79, 229, 155, 162, 177, 26, 139, 85, 37, 222, 58, 229, 132, 115, 11, 122, 20, 38, 179, 167, 98, 119, 208, 246, 150, 214, 8, 205, 175]), SecretKey([80, 189, 217, 125, 210, 47, 18, 242, 38, 32, 146, 166, 105, 40, 12, 44, 186, 57, 35, 181, 11, 230, 108, 35, 211, 136, 205, 237, 18, 62, 32, 111]), Seed([241, 206, 6, 6, 50, 130, 187, 38, 183, 18, 193, 141, 240, 153, 70, 40, 229, 208, 93, 85, 116, 196, 16, 121, 17, 118, 92, 0, 170, 33, 55, 114]));
/// AQF: GDAQF22QBE2UHFCBTRAH2U2UCIMJOUCTAN3XDWVPWDOR3JXMPB2ETFXK
static immutable AQF = KeyPair(PublicKey([193, 2, 235, 80, 9, 53, 67, 148, 65, 156, 64, 125, 83, 84, 18, 24, 151, 80, 83, 3, 119, 113, 218, 175, 176, 221, 29, 166, 236, 120, 116, 73]), SecretKey([96, 94, 250, 131, 82, 238, 171, 173, 119, 233, 89, 242, 119, 27, 75, 56, 42, 156, 145, 147, 49, 12, 27, 4, 225, 186, 228, 151, 170, 45, 203, 97]), Seed([134, 184, 163, 195, 69, 17, 45, 175, 244, 175, 179, 176, 83, 88, 8, 35, 166, 16, 110, 128, 152, 119, 106, 65, 107, 32, 231, 153, 235, 221, 86, 98]));
/// AQG: GDAQG22GKQZJ4XFQADHCLS7AIZ6L22H65TXT6LOEXB3V7VJOOFKRSRKY
static immutable AQG = KeyPair(PublicKey([193, 3, 107, 70, 84, 50, 158, 92, 176, 0, 206, 37, 203, 224, 70, 124, 189, 104, 254, 236, 239, 63, 45, 196, 184, 119, 95, 213, 46, 113, 85, 25]), SecretKey([56, 224, 228, 158, 100, 114, 133, 216, 23, 112, 196, 8, 198, 95, 55, 118, 143, 169, 219, 14, 221, 248, 184, 28, 152, 65, 244, 195, 210, 181, 115, 79]), Seed([115, 175, 213, 80, 47, 203, 249, 152, 87, 213, 100, 59, 14, 250, 15, 96, 42, 9, 61, 19, 207, 10, 126, 246, 179, 128, 105, 140, 199, 38, 161, 199]));
/// AQH: GDAQH22D2OWYVZDA5OKHZMWOHA3RYDOX4EV5AOGCF7YNMOUYLPSQ7J3Q
static immutable AQH = KeyPair(PublicKey([193, 3, 235, 67, 211, 173, 138, 228, 96, 235, 148, 124, 178, 206, 56, 55, 28, 13, 215, 225, 43, 208, 56, 194, 47, 240, 214, 58, 152, 91, 229, 15]), SecretKey([56, 147, 206, 252, 217, 125, 50, 59, 164, 249, 26, 207, 54, 194, 171, 10, 38, 147, 58, 206, 233, 80, 212, 135, 146, 137, 99, 5, 176, 32, 141, 103]), Seed([41, 178, 42, 55, 45, 112, 58, 89, 217, 67, 48, 113, 114, 171, 139, 218, 84, 238, 251, 134, 113, 161, 167, 23, 254, 194, 65, 40, 165, 150, 55, 73]));
/// AQI: GDAQI22WQGJXAYH47XV76UJ4LFDT5GYKNO5UMADEYI3WBJUBHEI63NCG
static immutable AQI = KeyPair(PublicKey([193, 4, 107, 86, 129, 147, 112, 96, 252, 253, 235, 255, 81, 60, 89, 71, 62, 155, 10, 107, 187, 70, 0, 100, 194, 55, 96, 166, 129, 57, 17, 237]), SecretKey([216, 25, 204, 147, 99, 180, 121, 216, 110, 52, 58, 77, 0, 119, 46, 128, 35, 85, 92, 179, 73, 87, 89, 222, 217, 6, 111, 11, 97, 247, 241, 82]), Seed([104, 200, 119, 15, 20, 115, 24, 35, 143, 186, 36, 26, 141, 205, 64, 250, 111, 211, 97, 95, 232, 39, 79, 104, 137, 82, 40, 211, 97, 86, 73, 149]));
/// AQJ: GDAQJ22EW6UVFZMHJZW333KWFLUNDIN5HFWYFW5NLWKE2JSVAD56JXOH
static immutable AQJ = KeyPair(PublicKey([193, 4, 235, 68, 183, 169, 82, 229, 135, 78, 109, 189, 237, 86, 42, 232, 209, 161, 189, 57, 109, 130, 219, 173, 93, 148, 77, 38, 85, 0, 251, 228]), SecretKey([160, 182, 123, 163, 143, 123, 94, 152, 0, 161, 35, 178, 41, 147, 30, 98, 10, 98, 252, 119, 21, 88, 25, 12, 115, 64, 170, 239, 99, 213, 119, 87]), Seed([99, 152, 95, 73, 97, 68, 211, 130, 86, 174, 173, 234, 129, 188, 82, 177, 58, 59, 175, 222, 47, 22, 30, 196, 154, 12, 231, 178, 49, 145, 3, 194]));
/// AQK: GDAQK22UWCJ5LC6QHQSYHMU46WUQCXZRMMLYGC7WHGBWXQNWMTDBJSSF
static immutable AQK = KeyPair(PublicKey([193, 5, 107, 84, 176, 147, 213, 139, 208, 60, 37, 131, 178, 156, 245, 169, 1, 95, 49, 99, 23, 131, 11, 246, 57, 131, 107, 193, 182, 100, 198, 20]), SecretKey([184, 241, 62, 246, 234, 219, 216, 96, 176, 165, 12, 48, 24, 232, 17, 196, 190, 111, 177, 35, 4, 213, 135, 9, 150, 216, 11, 161, 18, 24, 128, 94]), Seed([248, 134, 240, 242, 55, 176, 18, 254, 67, 88, 26, 221, 233, 165, 54, 1, 122, 21, 133, 148, 39, 216, 54, 190, 37, 195, 77, 36, 61, 161, 140, 103]));
/// AQL: GDAQL22JJNVVXISID5O6QHJWM3MFIQLKVODSEQ7XKKQQONC2KKUNKNI6
static immutable AQL = KeyPair(PublicKey([193, 5, 235, 73, 75, 107, 91, 162, 72, 31, 93, 232, 29, 54, 102, 216, 84, 65, 106, 171, 135, 34, 67, 247, 82, 161, 7, 52, 90, 82, 168, 213]), SecretKey([160, 139, 239, 21, 47, 246, 63, 245, 144, 90, 170, 163, 99, 133, 128, 113, 31, 126, 53, 159, 177, 33, 168, 116, 18, 227, 65, 184, 130, 83, 64, 80]), Seed([177, 134, 170, 101, 64, 152, 145, 83, 127, 255, 113, 56, 4, 35, 94, 216, 70, 236, 213, 223, 146, 126, 120, 232, 47, 122, 118, 230, 125, 113, 116, 54]));
/// AQM: GDAQM22JUNLMKPHVXTERSOLX7UPF7O4ZH37RIIWCF5ZPERUH2MPB2UDJ
static immutable AQM = KeyPair(PublicKey([193, 6, 107, 73, 163, 86, 197, 60, 245, 188, 201, 25, 57, 119, 253, 30, 95, 187, 153, 62, 255, 20, 34, 194, 47, 114, 242, 70, 135, 211, 30, 29]), SecretKey([88, 253, 141, 203, 121, 77, 177, 243, 85, 30, 217, 3, 40, 79, 52, 148, 24, 126, 128, 205, 113, 226, 202, 224, 5, 210, 130, 27, 137, 217, 71, 93]), Seed([41, 57, 66, 166, 202, 128, 194, 77, 216, 88, 57, 1, 241, 96, 14, 103, 231, 102, 93, 182, 28, 244, 5, 66, 2, 241, 145, 229, 15, 94, 232, 192]));
/// AQN: GDAQN22G36YSEQX6ESSPE6M63MKD2XO3APQLYMDNENRKH6NSEOSILQ66
static immutable AQN = KeyPair(PublicKey([193, 6, 235, 70, 223, 177, 34, 66, 254, 36, 164, 242, 121, 158, 219, 20, 61, 93, 219, 3, 224, 188, 48, 109, 35, 98, 163, 249, 178, 35, 164, 133]), SecretKey([176, 189, 161, 88, 126, 13, 218, 121, 67, 139, 21, 188, 114, 252, 32, 156, 236, 162, 166, 48, 22, 118, 168, 122, 47, 122, 206, 1, 183, 15, 254, 81]), Seed([78, 192, 248, 4, 44, 157, 129, 42, 235, 179, 150, 245, 1, 250, 127, 148, 67, 153, 116, 181, 215, 233, 84, 239, 196, 74, 114, 21, 175, 39, 57, 15]));
/// AQO: GDAQO22PYHC3Q2LJH6C46C73TEVZJBGWRJF63S4CHWJLAFRYUSFXVEFC
static immutable AQO = KeyPair(PublicKey([193, 7, 107, 79, 193, 197, 184, 105, 105, 63, 133, 207, 11, 251, 153, 43, 148, 132, 214, 138, 75, 237, 203, 130, 61, 146, 176, 22, 56, 164, 139, 122]), SecretKey([8, 110, 138, 235, 31, 35, 188, 10, 50, 32, 160, 206, 115, 218, 12, 244, 84, 130, 249, 83, 15, 85, 225, 8, 63, 231, 213, 1, 169, 115, 7, 121]), Seed([220, 26, 189, 152, 137, 216, 79, 68, 136, 37, 140, 231, 108, 66, 81, 67, 173, 242, 40, 0, 237, 181, 1, 114, 88, 242, 138, 236, 229, 37, 65, 190]));
/// AQP: GDAQP22BJ6B3QB2SJOW2EWSVFZHQTCKTZGIQDHKBJRJNMO733T4LGO2L
static immutable AQP = KeyPair(PublicKey([193, 7, 235, 65, 79, 131, 184, 7, 82, 75, 173, 162, 90, 85, 46, 79, 9, 137, 83, 201, 145, 1, 157, 65, 76, 82, 214, 59, 251, 220, 248, 179]), SecretKey([152, 130, 133, 189, 180, 101, 196, 186, 196, 225, 54, 142, 15, 24, 199, 145, 41, 206, 148, 203, 83, 99, 35, 176, 125, 13, 180, 216, 22, 152, 11, 116]), Seed([182, 112, 56, 142, 33, 231, 150, 81, 33, 24, 151, 204, 33, 125, 166, 191, 178, 195, 214, 42, 48, 23, 125, 26, 149, 122, 169, 204, 18, 159, 152, 103]));
/// AQQ: GDAQQ22KZZPUEUZQE74A3ZFIORJCAGOFFKOA6QZEPP56F2DOZEDNHOY5
static immutable AQQ = KeyPair(PublicKey([193, 8, 107, 74, 206, 95, 66, 83, 48, 39, 248, 13, 228, 168, 116, 82, 32, 25, 197, 42, 156, 15, 67, 36, 123, 251, 226, 232, 110, 201, 6, 211]), SecretKey([80, 28, 102, 97, 249, 203, 183, 176, 176, 92, 94, 177, 103, 202, 71, 129, 82, 235, 92, 209, 154, 40, 176, 91, 174, 245, 150, 179, 54, 99, 188, 114]), Seed([248, 201, 104, 191, 201, 20, 40, 98, 212, 159, 34, 34, 65, 181, 1, 227, 100, 92, 178, 205, 114, 155, 123, 146, 136, 44, 222, 75, 180, 216, 27, 127]));
/// AQR: GDAQR22V7E2GXTVCC7OCQG7WVCUNYIPATO6HPFTUKAAFNLU3KBGZEI73
static immutable AQR = KeyPair(PublicKey([193, 8, 235, 85, 249, 52, 107, 206, 162, 23, 220, 40, 27, 246, 168, 168, 220, 33, 224, 155, 188, 119, 150, 116, 80, 0, 86, 174, 155, 80, 77, 146]), SecretKey([216, 190, 188, 183, 250, 139, 224, 201, 66, 37, 227, 3, 154, 80, 235, 3, 154, 173, 24, 131, 65, 164, 86, 132, 173, 107, 130, 222, 131, 34, 72, 80]), Seed([231, 168, 231, 191, 225, 189, 210, 242, 20, 84, 134, 95, 107, 162, 40, 158, 60, 31, 93, 97, 226, 92, 224, 90, 23, 157, 19, 247, 126, 48, 63, 151]));
/// AQS: GDAQS22C26VTBXEVBHW7CJU4HT5GGFIY5DB5E6EHYJM2FDHXKDD2PMZT
static immutable AQS = KeyPair(PublicKey([193, 9, 107, 66, 215, 171, 48, 220, 149, 9, 237, 241, 38, 156, 60, 250, 99, 21, 24, 232, 195, 210, 120, 135, 194, 89, 162, 140, 247, 80, 199, 167]), SecretKey([56, 73, 161, 224, 160, 104, 181, 104, 235, 232, 77, 189, 231, 65, 76, 56, 114, 242, 212, 102, 211, 37, 103, 103, 242, 187, 252, 116, 214, 207, 238, 82]), Seed([193, 140, 151, 17, 33, 244, 76, 140, 209, 228, 16, 156, 205, 61, 129, 236, 62, 224, 43, 248, 129, 43, 46, 109, 21, 244, 66, 243, 13, 33, 17, 42]));
/// AQT: GDAQT22KZB4TX74J2I5YSHH4JBLKFDLU3BR27K2PXJAOWNDS3CYA5MDY
static immutable AQT = KeyPair(PublicKey([193, 9, 235, 74, 200, 121, 59, 255, 137, 210, 59, 137, 28, 252, 72, 86, 162, 141, 116, 216, 99, 175, 171, 79, 186, 64, 235, 52, 114, 216, 176, 14]), SecretKey([112, 76, 233, 147, 64, 190, 107, 58, 228, 103, 68, 154, 198, 182, 34, 247, 45, 145, 59, 140, 178, 40, 180, 49, 150, 95, 215, 17, 183, 154, 203, 68]), Seed([221, 247, 94, 158, 39, 23, 76, 26, 77, 159, 36, 127, 1, 199, 146, 104, 31, 206, 69, 93, 10, 170, 179, 41, 5, 216, 78, 61, 141, 218, 111, 160]));
/// AQU: GDAQU22W7CDD4E7SGMHAMTHPTGFY5T6LIR4LAXNWJNIX3WQO76RZKGR4
static immutable AQU = KeyPair(PublicKey([193, 10, 107, 86, 248, 134, 62, 19, 242, 51, 14, 6, 76, 239, 153, 139, 142, 207, 203, 68, 120, 176, 93, 182, 75, 81, 125, 218, 14, 255, 163, 149]), SecretKey([224, 237, 157, 108, 96, 233, 198, 88, 217, 5, 240, 95, 162, 100, 246, 229, 60, 70, 251, 214, 78, 125, 8, 61, 173, 21, 252, 254, 92, 138, 111, 115]), Seed([152, 46, 44, 225, 107, 241, 118, 135, 121, 6, 209, 117, 179, 56, 42, 129, 125, 229, 12, 213, 22, 70, 239, 12, 95, 62, 224, 196, 8, 160, 232, 14]));
/// AQV: GDAQV22DHH2RRDUI25PUSV6O5HL6TG37VMZPJHKYGDVCZLP2CBZCQCCX
static immutable AQV = KeyPair(PublicKey([193, 10, 235, 67, 57, 245, 24, 142, 136, 215, 95, 73, 87, 206, 233, 215, 233, 155, 127, 171, 50, 244, 157, 88, 48, 234, 44, 173, 250, 16, 114, 40]), SecretKey([88, 120, 23, 227, 33, 251, 37, 5, 27, 23, 31, 121, 45, 105, 224, 158, 136, 105, 165, 8, 250, 202, 47, 9, 34, 67, 220, 202, 81, 22, 240, 112]), Seed([235, 88, 99, 198, 250, 208, 156, 100, 232, 122, 83, 68, 93, 41, 90, 153, 56, 131, 61, 149, 51, 160, 125, 25, 28, 207, 87, 34, 48, 206, 30, 55]));
/// AQW: GDAQW22A5AXVYLQJ5A5PXO457EX7SOKCELYYW72SPKXHDSEU5JH74TCK
static immutable AQW = KeyPair(PublicKey([193, 11, 107, 64, 232, 47, 92, 46, 9, 232, 58, 251, 187, 157, 249, 47, 249, 57, 66, 34, 241, 139, 127, 82, 122, 174, 113, 200, 148, 234, 79, 254]), SecretKey([168, 56, 39, 33, 181, 182, 71, 189, 145, 41, 133, 82, 236, 138, 203, 0, 188, 227, 101, 185, 230, 109, 160, 219, 212, 214, 220, 107, 216, 30, 181, 80]), Seed([201, 164, 132, 55, 67, 192, 66, 190, 164, 12, 194, 70, 113, 223, 106, 89, 52, 59, 204, 239, 145, 1, 16, 165, 153, 119, 35, 150, 104, 236, 209, 248]));
/// AQX: GDAQX22SZUVUYQNRFHOCZC6OQQLPTO2ATSZVZP5C2QDNZM4AKABLXA76
static immutable AQX = KeyPair(PublicKey([193, 11, 235, 82, 205, 43, 76, 65, 177, 41, 220, 44, 139, 206, 132, 22, 249, 187, 64, 156, 179, 92, 191, 162, 212, 6, 220, 179, 128, 80, 2, 187]), SecretKey([64, 215, 249, 253, 110, 23, 141, 46, 207, 252, 13, 249, 243, 137, 12, 235, 20, 23, 164, 55, 49, 241, 134, 15, 164, 192, 16, 51, 79, 250, 164, 79]), Seed([146, 250, 66, 246, 157, 231, 254, 242, 209, 246, 168, 234, 83, 159, 106, 193, 147, 1, 101, 95, 116, 2, 154, 147, 92, 68, 122, 141, 147, 150, 45, 72]));
/// AQY: GDAQY225QGBNAGZFZ3ABZ5KTUAJ3IW754H6V5SWM3X2OQNG42ACTOD3H
static immutable AQY = KeyPair(PublicKey([193, 12, 107, 93, 129, 130, 208, 27, 37, 206, 192, 28, 245, 83, 160, 19, 180, 91, 253, 225, 253, 94, 202, 204, 221, 244, 232, 52, 220, 208, 5, 55]), SecretKey([144, 121, 205, 197, 145, 7, 23, 14, 92, 54, 184, 244, 110, 73, 141, 101, 53, 117, 25, 8, 69, 239, 63, 153, 97, 222, 175, 60, 210, 146, 229, 77]), Seed([75, 138, 115, 201, 231, 87, 142, 170, 124, 11, 22, 68, 112, 213, 180, 86, 196, 59, 137, 116, 147, 38, 153, 128, 67, 98, 124, 100, 214, 53, 37, 180]));
/// AQZ: GDAQZ22AYG6F5MVYWZCX55N5KX5T7NEX5O5DYFBUO5NKRKWCG6ETNGQZ
static immutable AQZ = KeyPair(PublicKey([193, 12, 235, 64, 193, 188, 94, 178, 184, 182, 69, 126, 245, 189, 85, 251, 63, 180, 151, 235, 186, 60, 20, 52, 119, 90, 168, 170, 194, 55, 137, 54]), SecretKey([40, 105, 192, 100, 74, 62, 159, 26, 177, 118, 73, 167, 211, 220, 19, 161, 239, 26, 139, 248, 101, 7, 171, 99, 202, 40, 248, 30, 215, 0, 46, 67]), Seed([130, 100, 95, 123, 109, 61, 100, 70, 97, 80, 99, 113, 163, 149, 248, 247, 187, 174, 13, 177, 24, 252, 155, 165, 134, 35, 55, 134, 217, 196, 22, 239]));
/// ARA: GDARA22HIOPB4AM7O4JY3HJ5X6W427AI3YGG2MILA6IOWBJLFAUFT5S4
static immutable ARA = KeyPair(PublicKey([193, 16, 107, 71, 67, 158, 30, 1, 159, 119, 19, 141, 157, 61, 191, 173, 205, 124, 8, 222, 12, 109, 49, 11, 7, 144, 235, 5, 43, 40, 40, 89]), SecretKey([120, 150, 255, 154, 125, 138, 40, 247, 90, 89, 66, 75, 90, 214, 5, 48, 216, 98, 240, 151, 244, 39, 237, 110, 51, 218, 109, 11, 4, 54, 228, 109]), Seed([117, 107, 192, 109, 38, 110, 223, 87, 255, 214, 192, 35, 113, 77, 222, 127, 22, 99, 11, 184, 18, 238, 231, 23, 143, 54, 100, 39, 217, 96, 118, 145]));
/// ARB: GDARB22J3IB6WPPF3WPCQPYGIMC7ZMP5ZWQALHDNJYEAKBSCZBA5UK5G
static immutable ARB = KeyPair(PublicKey([193, 16, 235, 73, 218, 3, 235, 61, 229, 221, 158, 40, 63, 6, 67, 5, 252, 177, 253, 205, 160, 5, 156, 109, 78, 8, 5, 6, 66, 200, 65, 218]), SecretKey([184, 103, 215, 228, 23, 78, 22, 67, 34, 156, 223, 95, 162, 243, 243, 221, 15, 209, 112, 107, 33, 13, 53, 159, 6, 91, 68, 223, 83, 159, 184, 103]), Seed([176, 18, 243, 9, 244, 155, 170, 37, 1, 54, 2, 52, 229, 117, 23, 25, 96, 138, 116, 97, 184, 243, 74, 221, 230, 113, 31, 48, 118, 120, 109, 175]));
/// ARC: GDARC22DRZTVX3HBTFBQRXKL6PHWLMNEZUTYBQ2CCVOP7MSZYM53EZJY
static immutable ARC = KeyPair(PublicKey([193, 17, 107, 67, 142, 103, 91, 236, 225, 153, 67, 8, 221, 75, 243, 207, 101, 177, 164, 205, 39, 128, 195, 66, 21, 92, 255, 178, 89, 195, 59, 178]), SecretKey([96, 130, 148, 13, 18, 2, 162, 77, 2, 190, 118, 227, 92, 38, 121, 49, 17, 120, 35, 57, 137, 202, 5, 180, 107, 17, 120, 24, 79, 231, 42, 93]), Seed([254, 137, 66, 184, 130, 247, 56, 224, 5, 64, 81, 6, 215, 69, 38, 68, 31, 213, 225, 3, 215, 93, 38, 133, 167, 64, 32, 189, 38, 120, 198, 42]));
/// ARD: GDARD22Y3JIQZMPJGF6C55BBPWMKIEFUCZGDMCMJGQILMBK3WOSLGX7D
static immutable ARD = KeyPair(PublicKey([193, 17, 235, 88, 218, 81, 12, 177, 233, 49, 124, 46, 244, 33, 125, 152, 164, 16, 180, 22, 76, 54, 9, 137, 52, 16, 182, 5, 91, 179, 164, 179]), SecretKey([56, 180, 162, 203, 33, 236, 60, 196, 102, 137, 4, 194, 64, 249, 187, 103, 229, 237, 245, 10, 94, 94, 86, 31, 81, 184, 161, 232, 58, 14, 17, 127]), Seed([98, 93, 39, 252, 138, 238, 24, 102, 172, 161, 97, 90, 18, 116, 24, 108, 227, 88, 126, 103, 209, 0, 66, 141, 174, 197, 155, 214, 143, 203, 165, 80]));
/// ARE: GDARE22P4JHI2HBVDSLT3UHNR7R6VGU5OCWJV6BEP5C4Y5PFF64CCJRO
static immutable ARE = KeyPair(PublicKey([193, 18, 107, 79, 226, 78, 141, 28, 53, 28, 151, 61, 208, 237, 143, 227, 234, 154, 157, 112, 172, 154, 248, 36, 127, 69, 204, 117, 229, 47, 184, 33]), SecretKey([144, 189, 29, 103, 148, 27, 56, 249, 20, 20, 127, 105, 4, 89, 37, 139, 106, 224, 63, 132, 191, 11, 57, 30, 125, 231, 111, 187, 212, 170, 212, 126]), Seed([220, 119, 63, 95, 226, 227, 220, 76, 102, 107, 185, 94, 163, 201, 24, 234, 4, 42, 165, 124, 167, 197, 98, 216, 186, 170, 13, 201, 96, 3, 119, 4]));
/// ARF: GDARF22ROUJJ5KJTAQLZCD7VX76XPHQVXZFRBY4NRNPHHLS6H7NCTZYK
static immutable ARF = KeyPair(PublicKey([193, 18, 235, 81, 117, 18, 158, 169, 51, 4, 23, 145, 15, 245, 191, 253, 119, 158, 21, 190, 75, 16, 227, 141, 139, 94, 115, 174, 94, 63, 218, 41]), SecretKey([16, 165, 182, 170, 108, 2, 132, 157, 190, 15, 122, 85, 250, 219, 235, 89, 145, 112, 18, 234, 122, 107, 96, 48, 122, 255, 231, 188, 110, 66, 57, 82]), Seed([168, 180, 16, 205, 66, 227, 38, 161, 198, 123, 201, 219, 106, 114, 238, 126, 73, 191, 215, 172, 149, 182, 162, 75, 106, 221, 17, 176, 90, 90, 83, 50]));
/// ARG: GDARG22MPHDIHYZ4HAJDIB3YEDXX3YCNCDG5WHFI6KBFQ4WRDAHTRYWU
static immutable ARG = KeyPair(PublicKey([193, 19, 107, 76, 121, 198, 131, 227, 60, 56, 18, 52, 7, 120, 32, 239, 125, 224, 77, 16, 205, 219, 28, 168, 242, 130, 88, 114, 209, 24, 15, 56]), SecretKey([216, 210, 154, 20, 73, 37, 224, 85, 183, 222, 29, 19, 220, 228, 6, 240, 142, 200, 110, 138, 43, 75, 108, 253, 205, 175, 45, 197, 239, 236, 189, 108]), Seed([102, 60, 166, 136, 43, 163, 243, 76, 73, 33, 106, 253, 218, 216, 188, 198, 141, 127, 229, 94, 202, 241, 224, 219, 70, 137, 172, 175, 137, 186, 4, 130]));
/// ARH: GDARH22M6SS7V3OIRL6TPXGZRU5IZLUKJMCBMLK7MB2DCIZ3RK7AT4CX
static immutable ARH = KeyPair(PublicKey([193, 19, 235, 76, 244, 165, 250, 237, 200, 138, 253, 55, 220, 217, 141, 58, 140, 174, 138, 75, 4, 22, 45, 95, 96, 116, 49, 35, 59, 138, 190, 9]), SecretKey([248, 88, 8, 50, 109, 205, 221, 70, 193, 245, 14, 81, 192, 19, 60, 61, 230, 108, 226, 6, 234, 93, 123, 150, 17, 200, 151, 143, 10, 225, 208, 73]), Seed([137, 184, 60, 183, 21, 161, 75, 113, 149, 226, 235, 227, 241, 37, 148, 102, 96, 194, 24, 34, 244, 83, 215, 5, 107, 51, 49, 86, 148, 235, 85, 22]));
/// ARI: GDARI22RSVE5FBABIOJB45Q4N5BJ5H2XJBEGFGIBZ35MYDCVSXIMSNRK
static immutable ARI = KeyPair(PublicKey([193, 20, 107, 81, 149, 73, 210, 132, 1, 67, 146, 30, 118, 28, 111, 66, 158, 159, 87, 72, 72, 98, 153, 1, 206, 250, 204, 12, 85, 149, 208, 201]), SecretKey([112, 68, 17, 250, 190, 69, 68, 219, 251, 40, 98, 203, 230, 152, 236, 122, 6, 39, 43, 56, 177, 64, 12, 167, 162, 135, 87, 255, 182, 107, 204, 85]), Seed([74, 50, 91, 233, 211, 75, 204, 66, 255, 223, 79, 106, 172, 149, 53, 151, 134, 16, 45, 195, 232, 111, 147, 74, 53, 159, 169, 200, 142, 99, 210, 233]));
/// ARJ: GDARJ22J6O6OKOA7FAS6BSYO564QA3JC2U3UZZSZEF34CBUJPYS7Y2U4
static immutable ARJ = KeyPair(PublicKey([193, 20, 235, 73, 243, 188, 229, 56, 31, 40, 37, 224, 203, 14, 239, 185, 0, 109, 34, 213, 55, 76, 230, 89, 33, 119, 193, 6, 137, 126, 37, 252]), SecretKey([200, 81, 155, 161, 63, 157, 28, 189, 59, 213, 131, 216, 207, 6, 131, 106, 54, 83, 114, 158, 114, 68, 79, 97, 218, 113, 64, 106, 83, 183, 168, 101]), Seed([149, 203, 217, 122, 49, 63, 45, 187, 74, 57, 132, 4, 11, 117, 51, 44, 55, 185, 245, 52, 141, 190, 147, 16, 183, 132, 197, 5, 65, 118, 182, 207]));
/// ARK: GDARK22YQQHWGMEEMG5RFIJZE6O3JSOAO47W7QTYLOSCQNFBVTG3XIGB
static immutable ARK = KeyPair(PublicKey([193, 21, 107, 88, 132, 15, 99, 48, 132, 97, 187, 18, 161, 57, 39, 157, 180, 201, 192, 119, 63, 111, 194, 120, 91, 164, 40, 52, 161, 172, 205, 187]), SecretKey([248, 130, 64, 126, 31, 133, 179, 60, 63, 61, 231, 167, 150, 110, 219, 202, 89, 96, 18, 102, 48, 187, 19, 52, 212, 234, 91, 3, 36, 251, 212, 73]), Seed([110, 113, 18, 168, 36, 188, 185, 254, 140, 58, 22, 20, 213, 179, 109, 44, 214, 86, 95, 242, 1, 9, 5, 123, 158, 242, 90, 76, 29, 45, 118, 133]));
/// ARL: GDARL22RUQZKAB2UJWXLDLVWMDWDZ67PBFIHOT2I566JFKRV4JAWCFEN
static immutable ARL = KeyPair(PublicKey([193, 21, 235, 81, 164, 50, 160, 7, 84, 77, 174, 177, 174, 182, 96, 236, 60, 251, 239, 9, 80, 119, 79, 72, 239, 188, 146, 170, 53, 226, 65, 97]), SecretKey([72, 239, 15, 164, 197, 192, 243, 201, 113, 141, 173, 11, 14, 93, 210, 9, 69, 238, 231, 98, 36, 205, 7, 241, 117, 174, 142, 60, 198, 239, 136, 89]), Seed([255, 50, 55, 179, 229, 83, 15, 104, 120, 112, 152, 241, 182, 3, 6, 118, 141, 249, 137, 2, 18, 161, 208, 109, 39, 53, 40, 138, 104, 75, 107, 75]));
/// ARM: GDARM22NAQF7YUYS4XDO4GCUUKCCBB67C4T6LPDFWTHVGSFXQWFI4HTP
static immutable ARM = KeyPair(PublicKey([193, 22, 107, 77, 4, 11, 252, 83, 18, 229, 198, 238, 24, 84, 162, 132, 32, 135, 223, 23, 39, 229, 188, 101, 180, 207, 83, 72, 183, 133, 138, 142]), SecretKey([56, 180, 47, 54, 160, 89, 33, 166, 113, 138, 11, 154, 110, 6, 38, 196, 234, 113, 205, 144, 141, 111, 23, 125, 213, 108, 248, 131, 175, 228, 229, 114]), Seed([151, 200, 56, 116, 121, 202, 124, 37, 132, 172, 82, 155, 234, 242, 75, 234, 70, 84, 202, 178, 229, 153, 136, 233, 18, 87, 89, 96, 25, 3, 189, 198]));
/// ARN: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable ARN = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// ARO: GDARO22XPKXNALFJZB6BBYOMXY4AVT3OWIVEBMQ65MCBLSGQKV5MOJXX
static immutable ARO = KeyPair(PublicKey([193, 23, 107, 87, 122, 174, 208, 44, 169, 200, 124, 16, 225, 204, 190, 56, 10, 207, 110, 178, 42, 64, 178, 30, 235, 4, 21, 200, 208, 85, 122, 199]), SecretKey([8, 129, 85, 11, 213, 70, 239, 127, 209, 215, 147, 153, 4, 56, 95, 159, 211, 13, 95, 98, 41, 193, 148, 50, 195, 215, 128, 197, 74, 254, 241, 125]), Seed([168, 97, 75, 239, 194, 241, 36, 228, 163, 98, 243, 34, 127, 42, 159, 227, 35, 121, 186, 57, 133, 138, 209, 134, 106, 137, 177, 154, 149, 121, 249, 241]));
/// ARP: GDARP22IV6YGNQYLJE5RKTYBCCIQRUFVFBX2YRIUKWSTYZLDTPOF4RE3
static immutable ARP = KeyPair(PublicKey([193, 23, 235, 72, 175, 176, 102, 195, 11, 73, 59, 21, 79, 1, 16, 145, 8, 208, 181, 40, 111, 172, 69, 20, 85, 165, 60, 101, 99, 155, 220, 94]), SecretKey([136, 196, 127, 185, 80, 122, 233, 40, 99, 211, 116, 85, 248, 175, 65, 13, 161, 73, 11, 46, 254, 186, 146, 33, 123, 148, 47, 215, 42, 83, 192, 87]), Seed([236, 154, 240, 129, 224, 163, 177, 202, 81, 87, 29, 247, 236, 26, 84, 220, 188, 40, 75, 73, 55, 39, 136, 148, 138, 84, 58, 183, 174, 194, 50, 125]));
/// ARQ: GDARQ22ZXUY2ZLQXNN45D6UACPIC2UXNIRLUPHTUWTHIIN4IKLC36MQ7
static immutable ARQ = KeyPair(PublicKey([193, 24, 107, 89, 189, 49, 172, 174, 23, 107, 121, 209, 250, 128, 19, 208, 45, 82, 237, 68, 87, 71, 158, 116, 180, 206, 132, 55, 136, 82, 197, 191]), SecretKey([80, 176, 132, 66, 253, 85, 51, 45, 151, 75, 73, 11, 183, 88, 179, 71, 115, 29, 11, 138, 241, 152, 120, 114, 80, 53, 65, 180, 69, 167, 212, 114]), Seed([136, 162, 143, 15, 242, 104, 27, 122, 117, 19, 131, 32, 109, 15, 84, 217, 24, 153, 250, 174, 95, 206, 156, 102, 188, 48, 164, 206, 69, 114, 136, 231]));
/// ARR: GDARR22YXB34B6AIMMUGDMRHRIHGYRAMR7ANS63QYG3CHGNVZSX4NWRK
static immutable ARR = KeyPair(PublicKey([193, 24, 235, 88, 184, 119, 192, 248, 8, 99, 40, 97, 178, 39, 138, 14, 108, 68, 12, 143, 192, 217, 123, 112, 193, 182, 35, 153, 181, 204, 175, 198]), SecretKey([200, 133, 82, 12, 242, 86, 203, 41, 53, 139, 39, 195, 121, 140, 65, 18, 70, 199, 93, 69, 20, 94, 56, 93, 235, 158, 26, 26, 200, 45, 212, 120]), Seed([132, 215, 38, 238, 247, 198, 30, 207, 188, 99, 251, 191, 186, 189, 187, 184, 42, 68, 141, 76, 69, 243, 20, 159, 174, 92, 16, 116, 133, 153, 159, 141]));
/// ARS: GDARS222LYHHIZ6GFXZCIVGFFEOJDTJH2AXNT74C6AILQ3K6C6ALJDBG
static immutable ARS = KeyPair(PublicKey([193, 25, 107, 90, 94, 14, 116, 103, 198, 45, 242, 36, 84, 197, 41, 28, 145, 205, 39, 208, 46, 217, 255, 130, 240, 16, 184, 109, 94, 23, 128, 180]), SecretKey([176, 164, 176, 183, 192, 139, 93, 80, 156, 18, 250, 191, 201, 68, 5, 0, 169, 70, 252, 151, 202, 125, 40, 142, 133, 20, 34, 126, 108, 135, 217, 117]), Seed([35, 38, 107, 213, 97, 194, 35, 234, 76, 231, 193, 115, 191, 227, 158, 176, 249, 255, 146, 0, 37, 7, 6, 100, 5, 20, 83, 3, 198, 215, 209, 180]));
/// ART: GDART22EKQZJ7IUHF7E675KN34R4TCUYNHHOBOY6SGDINEP2HLVP2GCK
static immutable ART = KeyPair(PublicKey([193, 25, 235, 68, 84, 50, 159, 162, 135, 47, 201, 239, 245, 77, 223, 35, 201, 138, 152, 105, 206, 224, 187, 30, 145, 134, 134, 145, 250, 58, 234, 253]), SecretKey([0, 150, 45, 149, 90, 36, 44, 33, 205, 135, 248, 241, 59, 101, 145, 192, 165, 149, 74, 220, 186, 46, 163, 119, 94, 23, 121, 124, 17, 139, 81, 81]), Seed([123, 189, 194, 199, 46, 67, 23, 49, 54, 26, 204, 159, 149, 194, 7, 23, 117, 173, 66, 26, 166, 247, 12, 111, 57, 81, 174, 98, 151, 22, 78, 22]));
/// ARU: GDARU222OXJ5A3NLPL7SGDR6OM3N32R3KLX6PMDS6M7EEO53MIGST3Z4
static immutable ARU = KeyPair(PublicKey([193, 26, 107, 90, 117, 211, 208, 109, 171, 122, 255, 35, 14, 62, 115, 54, 221, 234, 59, 82, 239, 231, 176, 114, 243, 62, 66, 59, 187, 98, 13, 41]), SecretKey([200, 127, 11, 145, 201, 190, 128, 193, 177, 112, 173, 229, 25, 112, 42, 71, 174, 46, 210, 114, 138, 197, 51, 29, 205, 148, 158, 125, 60, 17, 119, 119]), Seed([97, 124, 102, 26, 92, 167, 39, 49, 205, 28, 234, 103, 100, 176, 139, 102, 88, 148, 110, 15, 162, 32, 94, 205, 176, 188, 112, 174, 2, 51, 99, 239]));
/// ARV: GDARV22PEJPPHOTVGXJZHIRZLWVTXRFD5GXZC4B73MXJZW6DPZJFNZEB
static immutable ARV = KeyPair(PublicKey([193, 26, 235, 79, 34, 94, 243, 186, 117, 53, 211, 147, 162, 57, 93, 171, 59, 196, 163, 233, 175, 145, 112, 63, 219, 46, 156, 219, 195, 126, 82, 86]), SecretKey([224, 178, 247, 143, 138, 156, 84, 95, 177, 171, 147, 35, 142, 60, 89, 127, 226, 205, 244, 196, 111, 150, 90, 171, 134, 211, 70, 51, 87, 129, 245, 80]), Seed([201, 26, 0, 9, 127, 158, 28, 98, 13, 93, 132, 35, 132, 250, 174, 240, 145, 143, 45, 17, 191, 112, 203, 156, 153, 242, 6, 144, 152, 80, 203, 44]));
/// ARW: GDARW22IVKLRUTTFIL3QRSLKNF7ALULZUH5D4NGIO6JIVIFWR46LBHSA
static immutable ARW = KeyPair(PublicKey([193, 27, 107, 72, 170, 151, 26, 78, 101, 66, 247, 8, 201, 106, 105, 126, 5, 209, 121, 161, 250, 62, 52, 200, 119, 146, 138, 160, 182, 143, 60, 176]), SecretKey([16, 28, 67, 98, 123, 188, 104, 80, 127, 114, 35, 110, 89, 246, 231, 42, 169, 59, 165, 64, 126, 19, 169, 81, 174, 245, 19, 152, 164, 94, 56, 97]), Seed([148, 27, 16, 254, 21, 162, 39, 85, 7, 116, 168, 181, 198, 35, 14, 57, 89, 215, 182, 5, 163, 36, 109, 106, 250, 161, 10, 167, 92, 8, 20, 138]));
/// ARX: GDARX226JVTNLUVCFSJOVGJM2WDV5QQZHNM72NJ5CF6EU6Z4IGYULH6X
static immutable ARX = KeyPair(PublicKey([193, 27, 235, 94, 77, 102, 213, 210, 162, 44, 146, 234, 153, 44, 213, 135, 94, 194, 25, 59, 89, 253, 53, 61, 17, 124, 74, 123, 60, 65, 177, 69]), SecretKey([224, 174, 169, 37, 55, 168, 119, 207, 85, 62, 235, 88, 30, 142, 3, 135, 114, 159, 104, 60, 49, 207, 116, 18, 229, 119, 71, 176, 188, 189, 201, 79]), Seed([97, 245, 225, 2, 62, 171, 84, 18, 185, 83, 159, 198, 41, 214, 71, 69, 172, 91, 1, 215, 239, 4, 58, 65, 14, 125, 126, 171, 105, 114, 131, 135]));
/// ARY: GDARY22JRJOFP3LPRUHJTI3PQFSUZRVM64CKJRDGESIOQJJFWHK3MKV2
static immutable ARY = KeyPair(PublicKey([193, 28, 107, 73, 138, 92, 87, 237, 111, 141, 14, 153, 163, 111, 129, 101, 76, 198, 172, 247, 4, 164, 196, 102, 36, 144, 232, 37, 37, 177, 213, 182]), SecretKey([72, 111, 79, 128, 98, 252, 252, 119, 248, 204, 134, 84, 55, 82, 196, 88, 43, 90, 45, 200, 48, 117, 3, 216, 40, 65, 8, 217, 80, 65, 45, 78]), Seed([30, 226, 51, 251, 110, 133, 219, 125, 184, 71, 233, 180, 64, 36, 41, 24, 250, 14, 152, 206, 58, 139, 201, 56, 22, 100, 218, 136, 31, 66, 181, 188]));
/// ARZ: GDARZ22GRYC64A5UWCDURPII77VWLOF4IAUHTVMEQCIZ72PDUXUBMXAY
static immutable ARZ = KeyPair(PublicKey([193, 28, 235, 70, 142, 5, 238, 3, 180, 176, 135, 72, 189, 8, 255, 235, 101, 184, 188, 64, 40, 121, 213, 132, 128, 145, 159, 233, 227, 165, 232, 22]), SecretKey([240, 115, 217, 196, 244, 45, 81, 147, 85, 123, 1, 233, 247, 49, 25, 94, 122, 66, 126, 27, 103, 69, 204, 235, 31, 125, 241, 166, 193, 149, 78, 95]), Seed([178, 240, 147, 109, 96, 158, 140, 59, 22, 181, 140, 229, 144, 175, 27, 247, 146, 65, 196, 22, 1, 208, 212, 7, 194, 13, 252, 177, 146, 81, 67, 177]));
/// ASA: GDASA22RGQSE4BSYDPTMKCPKL6ZCC7BCPCJLJD7NCDET2MB5QQYYCCWT
static immutable ASA = KeyPair(PublicKey([193, 32, 107, 81, 52, 36, 78, 6, 88, 27, 230, 197, 9, 234, 95, 178, 33, 124, 34, 120, 146, 180, 143, 237, 16, 201, 61, 48, 61, 132, 49, 129]), SecretKey([184, 110, 150, 216, 62, 243, 197, 91, 162, 163, 2, 101, 114, 49, 147, 203, 7, 194, 219, 44, 134, 205, 118, 73, 225, 133, 75, 193, 17, 53, 130, 106]), Seed([151, 65, 198, 4, 58, 198, 175, 98, 146, 81, 253, 249, 236, 231, 37, 155, 0, 99, 165, 34, 81, 57, 137, 75, 100, 89, 47, 221, 91, 46, 160, 176]));
/// ASB: GDASB22U4WITMZO6476NTHRHLV5YRMR7RQ46352D4I6AB2OVV32AUYQK
static immutable ASB = KeyPair(PublicKey([193, 32, 235, 84, 229, 145, 54, 101, 222, 231, 252, 217, 158, 39, 93, 123, 136, 178, 63, 140, 57, 237, 247, 67, 226, 60, 0, 233, 213, 174, 244, 10]), SecretKey([88, 254, 11, 249, 76, 0, 99, 67, 194, 137, 138, 213, 140, 128, 217, 82, 59, 167, 39, 165, 221, 194, 35, 223, 141, 198, 235, 189, 218, 253, 73, 85]), Seed([148, 135, 112, 65, 102, 119, 89, 159, 130, 212, 252, 240, 62, 136, 117, 93, 183, 60, 38, 151, 99, 209, 180, 11, 1, 197, 109, 25, 42, 79, 46, 156]));
/// ASC: GDASC2237T4AODZAF344DSJW4IXYWUMELXX4CE6472OJDNWZ3QELH3Z7
static immutable ASC = KeyPair(PublicKey([193, 33, 107, 91, 252, 248, 7, 15, 32, 46, 249, 193, 201, 54, 226, 47, 139, 81, 132, 93, 239, 193, 19, 220, 254, 156, 145, 182, 217, 220, 8, 179]), SecretKey([176, 86, 61, 178, 78, 52, 7, 19, 255, 109, 26, 217, 248, 173, 196, 43, 15, 25, 238, 156, 168, 78, 246, 235, 128, 26, 255, 200, 174, 92, 90, 80]), Seed([96, 234, 139, 87, 24, 234, 196, 239, 117, 17, 218, 184, 152, 149, 234, 247, 208, 133, 164, 94, 136, 26, 205, 164, 212, 45, 140, 41, 51, 5, 148, 135]));
/// ASD: GDASD22OEMTOXNZCKVGU4LUVEHPLW6GWMB2HCEAH2NKV3UBFGWID3EGV
static immutable ASD = KeyPair(PublicKey([193, 33, 235, 78, 35, 38, 235, 183, 34, 85, 77, 78, 46, 149, 33, 222, 187, 120, 214, 96, 116, 113, 16, 7, 211, 85, 93, 208, 37, 53, 144, 61]), SecretKey([160, 230, 203, 90, 250, 29, 113, 105, 174, 182, 51, 253, 200, 124, 46, 230, 130, 20, 20, 37, 197, 214, 92, 72, 238, 23, 25, 58, 190, 254, 92, 70]), Seed([191, 43, 100, 155, 1, 162, 254, 44, 36, 84, 174, 145, 55, 193, 216, 41, 141, 137, 71, 138, 97, 229, 62, 68, 203, 96, 35, 52, 249, 214, 136, 235]));
/// ASE: GDASE22SDQLEO2CMHICYAFJU425F2RKCYQGJHAANL4NOYRWUHJFSZM7Q
static immutable ASE = KeyPair(PublicKey([193, 34, 107, 82, 28, 22, 71, 104, 76, 58, 5, 128, 21, 52, 230, 186, 93, 69, 66, 196, 12, 147, 128, 13, 95, 26, 236, 70, 212, 58, 75, 44]), SecretKey([200, 213, 91, 39, 152, 192, 146, 34, 70, 67, 193, 122, 1, 90, 119, 219, 12, 165, 226, 30, 83, 132, 2, 121, 220, 1, 20, 166, 163, 205, 207, 87]), Seed([140, 128, 68, 110, 142, 213, 211, 175, 94, 60, 239, 9, 166, 16, 128, 66, 86, 68, 30, 246, 54, 107, 181, 94, 168, 53, 20, 248, 141, 117, 85, 177]));
/// ASF: GDASF2276FUZJSZJCYUXAQB2EP4HTZSIHI3IQ4RRMBI3OGMTIJLEI7Q3
static immutable ASF = KeyPair(PublicKey([193, 34, 235, 95, 241, 105, 148, 203, 41, 22, 41, 112, 64, 58, 35, 248, 121, 230, 72, 58, 54, 136, 114, 49, 96, 81, 183, 25, 147, 66, 86, 68]), SecretKey([184, 254, 38, 86, 144, 15, 37, 206, 48, 143, 195, 147, 42, 72, 67, 208, 127, 64, 3, 32, 240, 55, 28, 0, 193, 126, 141, 153, 74, 252, 76, 83]), Seed([138, 193, 214, 1, 103, 50, 107, 18, 254, 250, 108, 179, 195, 23, 22, 129, 188, 86, 153, 133, 216, 66, 86, 127, 210, 237, 65, 96, 105, 188, 35, 71]));
/// ASG: GDASG22IQJ42HOALXYBNB3LKC3TJXIDCOTEVQJJIGG6O3STQ2JI4UWKA
static immutable ASG = KeyPair(PublicKey([193, 35, 107, 72, 130, 121, 163, 184, 11, 190, 2, 208, 237, 106, 22, 230, 155, 160, 98, 116, 201, 88, 37, 40, 49, 188, 237, 202, 112, 210, 81, 202]), SecretKey([160, 4, 7, 159, 32, 157, 70, 88, 138, 92, 185, 134, 107, 125, 153, 227, 68, 164, 171, 78, 148, 194, 60, 173, 82, 56, 166, 235, 149, 251, 51, 106]), Seed([152, 202, 20, 24, 133, 38, 115, 39, 30, 111, 109, 210, 157, 176, 154, 198, 128, 112, 234, 255, 120, 87, 81, 216, 166, 48, 44, 178, 49, 128, 211, 228]));
/// ASH: GDASH223XZRTYDDBSZCMU5NG6DGM7IDTJ7QMG4URM4WMKGT7TZUHD27P
static immutable ASH = KeyPair(PublicKey([193, 35, 235, 91, 190, 99, 60, 12, 97, 150, 68, 202, 117, 166, 240, 204, 207, 160, 115, 79, 224, 195, 114, 145, 103, 44, 197, 26, 127, 158, 104, 113]), SecretKey([168, 239, 189, 152, 14, 62, 50, 53, 252, 106, 17, 123, 116, 132, 91, 254, 168, 14, 182, 155, 25, 191, 155, 229, 87, 134, 89, 191, 251, 222, 164, 121]), Seed([220, 34, 101, 250, 47, 219, 12, 108, 147, 204, 247, 112, 1, 77, 222, 24, 118, 42, 7, 135, 222, 250, 101, 38, 230, 245, 220, 26, 53, 165, 55, 97]));
/// ASI: GDASI22UT3NHVOJWQAE2A4QZ2NJA26LV6Q4RGBQHWZDXJCHBIJF6DUFQ
static immutable ASI = KeyPair(PublicKey([193, 36, 107, 84, 158, 218, 122, 185, 54, 128, 9, 160, 114, 25, 211, 82, 13, 121, 117, 244, 57, 19, 6, 7, 182, 71, 116, 136, 225, 66, 75, 225]), SecretKey([136, 130, 96, 205, 132, 205, 195, 21, 128, 243, 190, 245, 29, 158, 94, 171, 134, 121, 39, 236, 14, 119, 87, 108, 149, 114, 163, 119, 178, 172, 168, 81]), Seed([31, 70, 104, 144, 41, 117, 223, 118, 3, 53, 160, 214, 169, 114, 230, 101, 107, 85, 100, 219, 77, 145, 191, 156, 249, 155, 47, 116, 39, 106, 116, 108]));
/// ASJ: GDASJ22EEH2KWKSDWAYZMZZXQX26HHMU5BWY7J2SI6K2PAB2RGMI54YW
static immutable ASJ = KeyPair(PublicKey([193, 36, 235, 68, 33, 244, 171, 42, 67, 176, 49, 150, 103, 55, 133, 245, 227, 157, 148, 232, 109, 143, 167, 82, 71, 149, 167, 128, 58, 137, 152, 142]), SecretKey([40, 43, 114, 3, 117, 43, 124, 123, 92, 204, 50, 75, 7, 10, 116, 141, 188, 243, 49, 242, 16, 120, 39, 253, 65, 125, 189, 90, 207, 201, 238, 123]), Seed([126, 139, 211, 62, 195, 166, 7, 126, 46, 173, 172, 10, 79, 60, 135, 25, 170, 27, 50, 206, 160, 180, 228, 212, 218, 75, 51, 183, 115, 155, 118, 152]));
/// ASK: GDASK22NGGUM2FFHJWDP3MXDUJJV6FMUJXFOCUFU444EFZGJYRE3IKBZ
static immutable ASK = KeyPair(PublicKey([193, 37, 107, 77, 49, 168, 205, 20, 167, 77, 134, 253, 178, 227, 162, 83, 95, 21, 148, 77, 202, 225, 80, 180, 231, 56, 66, 228, 201, 196, 73, 180]), SecretKey([208, 141, 75, 56, 208, 154, 180, 213, 218, 81, 188, 95, 218, 74, 219, 100, 44, 162, 238, 177, 112, 148, 74, 190, 172, 173, 249, 161, 243, 225, 99, 116]), Seed([230, 97, 52, 42, 45, 215, 68, 160, 226, 18, 117, 10, 197, 9, 70, 233, 24, 52, 212, 125, 170, 105, 107, 105, 189, 80, 149, 21, 190, 40, 188, 15]));
/// ASL: GDASL22QQ7CR5RI7RPNL3EL4VKRTTUSJFJX5PLICHSMPRBHU7R66XFJ5
static immutable ASL = KeyPair(PublicKey([193, 37, 235, 80, 135, 197, 30, 197, 31, 139, 218, 189, 145, 124, 170, 163, 57, 210, 73, 42, 111, 215, 173, 2, 60, 152, 248, 132, 244, 252, 125, 235]), SecretKey([8, 102, 108, 28, 197, 211, 109, 236, 19, 206, 30, 185, 30, 202, 34, 152, 248, 96, 136, 195, 183, 13, 251, 146, 29, 61, 7, 64, 208, 217, 91, 109]), Seed([236, 227, 210, 136, 225, 23, 89, 23, 116, 236, 251, 25, 77, 224, 199, 51, 200, 203, 75, 116, 127, 242, 207, 236, 240, 113, 16, 125, 168, 143, 237, 70]));
/// ASM: GDASM22PD3OVK36J3Y7VLKSZXECSTMRFLYSYC4ZG4GHHZWQW7EVZCCZB
static immutable ASM = KeyPair(PublicKey([193, 38, 107, 79, 30, 221, 85, 111, 201, 222, 63, 85, 170, 89, 185, 5, 41, 178, 37, 94, 37, 129, 115, 38, 225, 142, 124, 218, 22, 249, 43, 145]), SecretKey([104, 184, 60, 191, 208, 30, 154, 211, 138, 142, 255, 198, 101, 16, 29, 46, 58, 145, 36, 51, 212, 206, 178, 186, 59, 174, 183, 215, 247, 195, 43, 86]), Seed([221, 108, 8, 200, 182, 160, 117, 28, 44, 88, 100, 91, 112, 158, 40, 28, 218, 236, 245, 62, 57, 29, 9, 86, 130, 36, 184, 212, 250, 249, 10, 50]));
/// ASN: GDASN22CBXGFWOUUBZPSCB3SQS5UJIZOGZG3SDARFYRXMI6HM747ZW5O
static immutable ASN = KeyPair(PublicKey([193, 38, 235, 66, 13, 204, 91, 58, 148, 14, 95, 33, 7, 114, 132, 187, 68, 163, 46, 54, 77, 185, 12, 17, 46, 35, 118, 35, 199, 103, 249, 252]), SecretKey([160, 30, 181, 114, 21, 226, 99, 94, 31, 218, 71, 46, 23, 227, 58, 41, 170, 210, 109, 181, 236, 143, 44, 93, 210, 201, 52, 85, 23, 77, 38, 105]), Seed([180, 69, 142, 116, 139, 157, 0, 135, 99, 135, 221, 98, 40, 34, 96, 203, 14, 125, 11, 138, 124, 143, 191, 174, 113, 210, 188, 125, 51, 69, 239, 219]));
/// ASO: GDASO22NURP7MSPBENQ6AWBFZ5P5D4AI32PG53JKXKCIF6KCHDOURUWT
static immutable ASO = KeyPair(PublicKey([193, 39, 107, 77, 164, 95, 246, 73, 225, 35, 97, 224, 88, 37, 207, 95, 209, 240, 8, 222, 158, 110, 237, 42, 186, 132, 130, 249, 66, 56, 221, 72]), SecretKey([112, 230, 31, 87, 229, 51, 188, 178, 117, 0, 201, 193, 245, 204, 192, 194, 102, 253, 91, 40, 184, 228, 64, 96, 32, 87, 230, 216, 25, 107, 85, 65]), Seed([112, 111, 248, 0, 235, 208, 137, 88, 69, 182, 68, 103, 130, 35, 183, 122, 145, 168, 224, 110, 198, 77, 247, 208, 226, 202, 152, 74, 206, 234, 57, 160]));
/// ASP: GDASP223PBUMZXDBFARUKHTA76ISBIVJO73IORQ7WP52CEOBZV4U42SE
static immutable ASP = KeyPair(PublicKey([193, 39, 235, 91, 120, 104, 204, 220, 97, 40, 35, 69, 30, 96, 255, 145, 32, 162, 169, 119, 246, 135, 70, 31, 179, 251, 161, 17, 193, 205, 121, 78]), SecretKey([248, 16, 182, 193, 161, 232, 5, 116, 45, 165, 89, 206, 42, 84, 172, 219, 218, 50, 99, 116, 119, 204, 173, 161, 41, 214, 229, 134, 195, 60, 116, 90]), Seed([229, 52, 8, 173, 149, 32, 7, 91, 196, 49, 3, 228, 222, 53, 58, 245, 157, 49, 13, 136, 231, 71, 6, 252, 140, 223, 21, 84, 43, 215, 203, 85]));
/// ASQ: GDASQ22V7O3KXBCI6UCVJKD57C6ABXONUZQV5EK3KGFTSBXXUFXI6S23
static immutable ASQ = KeyPair(PublicKey([193, 40, 107, 85, 251, 182, 171, 132, 72, 245, 5, 84, 168, 125, 248, 188, 0, 221, 205, 166, 97, 94, 145, 91, 81, 139, 57, 6, 247, 161, 110, 143]), SecretKey([40, 41, 45, 168, 98, 173, 44, 164, 120, 201, 255, 225, 209, 227, 127, 243, 155, 159, 225, 145, 150, 229, 99, 8, 132, 31, 197, 189, 206, 49, 241, 103]), Seed([105, 78, 92, 137, 169, 187, 169, 170, 143, 192, 241, 157, 75, 112, 120, 183, 43, 96, 236, 222, 70, 91, 67, 189, 230, 139, 52, 61, 126, 85, 73, 129]));
/// ASR: GDASR22VKOGPFCSTGH7ZPAVLSTB2AOG76N5UF2XBSD63IKXB42DFHFDF
static immutable ASR = KeyPair(PublicKey([193, 40, 235, 85, 83, 140, 242, 138, 83, 49, 255, 151, 130, 171, 148, 195, 160, 56, 223, 243, 123, 66, 234, 225, 144, 253, 180, 42, 225, 230, 134, 83]), SecretKey([152, 30, 6, 108, 169, 200, 248, 239, 154, 169, 175, 238, 46, 43, 0, 122, 31, 38, 251, 7, 34, 150, 77, 111, 16, 59, 76, 3, 246, 71, 162, 106]), Seed([248, 122, 40, 110, 75, 158, 26, 43, 64, 216, 99, 255, 131, 45, 33, 64, 171, 126, 23, 143, 41, 38, 85, 209, 235, 26, 80, 137, 50, 0, 28, 1]));
/// ASS: GDASS22QW4XDDAENBJIP6KIMLQ3INGGIQ7TUUP2V3ZIGK26NQ3UDTMYJ
static immutable ASS = KeyPair(PublicKey([193, 41, 107, 80, 183, 46, 49, 128, 141, 10, 80, 255, 41, 12, 92, 54, 134, 152, 200, 135, 231, 74, 63, 85, 222, 80, 101, 107, 205, 134, 232, 57]), SecretKey([200, 122, 247, 59, 60, 110, 180, 17, 26, 93, 110, 128, 165, 253, 125, 217, 214, 194, 223, 62, 202, 148, 228, 176, 120, 114, 171, 174, 132, 118, 155, 102]), Seed([17, 4, 186, 179, 45, 187, 25, 32, 137, 125, 205, 125, 207, 131, 60, 207, 68, 26, 160, 59, 62, 215, 126, 146, 76, 168, 245, 137, 156, 198, 124, 206]));
/// AST: GDAST22R6YRJ2RLOKD4GEXRMMNTKEL5ZF2R4FB33IXOYHTZWAT4QSUJO
static immutable AST = KeyPair(PublicKey([193, 41, 235, 81, 246, 34, 157, 69, 110, 80, 248, 98, 94, 44, 99, 102, 162, 47, 185, 46, 163, 194, 135, 123, 69, 221, 131, 207, 54, 4, 249, 9]), SecretKey([192, 179, 201, 202, 38, 138, 206, 12, 128, 39, 172, 177, 137, 62, 138, 181, 132, 244, 80, 250, 154, 71, 11, 91, 145, 58, 189, 162, 87, 156, 76, 122]), Seed([43, 243, 145, 60, 27, 232, 136, 123, 59, 245, 115, 36, 221, 62, 54, 161, 229, 49, 74, 160, 212, 246, 108, 85, 161, 147, 80, 87, 251, 5, 219, 86]));
/// ASU: GDASU22DSQWY5BRWM7R2MGCU4QOK3KPIWALXQX6ME56GBLFPWPXEVPA3
static immutable ASU = KeyPair(PublicKey([193, 42, 107, 67, 148, 45, 142, 134, 54, 103, 227, 166, 24, 84, 228, 28, 173, 169, 232, 176, 23, 120, 95, 204, 39, 124, 96, 172, 175, 179, 238, 74]), SecretKey([176, 26, 144, 126, 51, 215, 127, 197, 112, 91, 123, 24, 46, 203, 171, 76, 25, 177, 1, 140, 223, 71, 2, 31, 105, 240, 51, 116, 189, 244, 195, 125]), Seed([197, 116, 149, 155, 199, 54, 79, 214, 67, 167, 203, 249, 134, 83, 103, 219, 191, 154, 107, 250, 183, 9, 173, 152, 189, 253, 142, 242, 226, 110, 133, 81]));
/// ASV: GDASV22ICJFE7JKYEOLEH4QWFJPLQJCXJOL2T5K5ZT5M5PN545IALEO3
static immutable ASV = KeyPair(PublicKey([193, 42, 235, 72, 18, 74, 79, 165, 88, 35, 150, 67, 242, 22, 42, 94, 184, 36, 87, 75, 151, 169, 245, 93, 204, 250, 206, 189, 189, 231, 80, 5]), SecretKey([208, 170, 140, 103, 11, 64, 243, 29, 160, 90, 52, 220, 215, 207, 179, 85, 51, 56, 171, 39, 199, 154, 60, 157, 129, 82, 74, 239, 70, 213, 193, 93]), Seed([48, 61, 208, 92, 239, 138, 99, 124, 83, 173, 197, 109, 94, 60, 58, 166, 174, 250, 132, 234, 111, 167, 80, 8, 195, 203, 68, 100, 121, 222, 213, 133]));
/// ASW: GDASW22S7YOL5QTPPAX5Q5GMHL5MFQ7UFIXYRBLKZPN2LPU6MPTCZYBX
static immutable ASW = KeyPair(PublicKey([193, 43, 107, 82, 254, 28, 190, 194, 111, 120, 47, 216, 116, 204, 58, 250, 194, 195, 244, 42, 47, 136, 133, 106, 203, 219, 165, 190, 158, 99, 230, 44]), SecretKey([136, 237, 4, 171, 41, 135, 39, 100, 125, 183, 58, 169, 46, 39, 83, 63, 129, 82, 81, 165, 109, 69, 87, 213, 134, 106, 31, 201, 111, 73, 55, 70]), Seed([117, 150, 254, 73, 194, 3, 110, 15, 132, 229, 102, 87, 0, 189, 205, 220, 33, 252, 134, 133, 134, 108, 129, 243, 144, 52, 154, 163, 118, 128, 160, 86]));
/// ASX: GDASX22XWGII33X2U6EHME7X7K3IIETDL2VGVZWX7C3VWHRB6Y7P5MUX
static immutable ASX = KeyPair(PublicKey([193, 43, 235, 87, 177, 144, 141, 238, 250, 167, 136, 118, 19, 247, 250, 182, 132, 18, 99, 94, 170, 106, 230, 215, 248, 183, 91, 30, 33, 246, 62, 254]), SecretKey([224, 39, 233, 170, 73, 215, 60, 147, 110, 187, 171, 159, 234, 12, 3, 246, 205, 153, 230, 176, 116, 199, 205, 3, 208, 140, 26, 139, 140, 149, 220, 122]), Seed([63, 21, 127, 0, 241, 45, 211, 91, 214, 75, 208, 187, 253, 104, 52, 251, 250, 76, 200, 132, 13, 15, 89, 60, 50, 113, 167, 88, 92, 37, 178, 69]));
/// ASY: GDASY22DRAMKCLI6FI464MWAOWIEPPK3A5CSIXCYUQGQXAX5MUYWOA7B
static immutable ASY = KeyPair(PublicKey([193, 44, 107, 67, 136, 24, 161, 45, 30, 42, 57, 238, 50, 192, 117, 144, 71, 189, 91, 7, 69, 36, 92, 88, 164, 13, 11, 130, 253, 101, 49, 103]), SecretKey([16, 105, 70, 194, 118, 193, 159, 198, 250, 194, 38, 172, 28, 79, 214, 93, 138, 215, 241, 62, 100, 92, 99, 113, 245, 164, 206, 94, 125, 66, 155, 99]), Seed([215, 83, 93, 216, 209, 10, 134, 31, 161, 136, 143, 58, 53, 54, 237, 6, 48, 111, 78, 251, 209, 231, 78, 219, 240, 67, 13, 205, 117, 219, 175, 178]));
/// ASZ: GDASZ22BRWUII326KWOJY3KAO24JCOTB2S65V3IK477RH45F6FQYR37C
static immutable ASZ = KeyPair(PublicKey([193, 44, 235, 65, 141, 168, 132, 111, 94, 85, 156, 156, 109, 64, 118, 184, 145, 58, 97, 212, 189, 218, 237, 10, 231, 255, 19, 243, 165, 241, 97, 136]), SecretKey([112, 0, 92, 122, 243, 229, 2, 25, 169, 151, 50, 122, 173, 190, 35, 202, 106, 89, 226, 62, 234, 154, 197, 199, 90, 228, 8, 170, 156, 130, 242, 98]), Seed([63, 158, 22, 253, 72, 0, 211, 247, 30, 23, 93, 188, 40, 230, 9, 188, 245, 100, 187, 95, 88, 141, 13, 55, 131, 36, 169, 213, 243, 2, 13, 186]));
/// ATA: GDATA22IP2NLBKL4Q7WINDLPHTMD7JOMEKWHU4FFVH5WNHRP745B6XIE
static immutable ATA = KeyPair(PublicKey([193, 48, 107, 72, 126, 154, 176, 169, 124, 135, 236, 134, 141, 111, 60, 216, 63, 165, 204, 34, 172, 122, 112, 165, 169, 251, 102, 158, 47, 255, 58, 31]), SecretKey([104, 137, 125, 78, 73, 95, 91, 21, 132, 25, 158, 205, 181, 61, 171, 252, 103, 99, 137, 209, 226, 138, 117, 177, 89, 165, 132, 77, 63, 9, 215, 94]), Seed([208, 196, 184, 188, 91, 93, 131, 181, 148, 134, 88, 160, 199, 92, 105, 115, 217, 30, 187, 171, 176, 12, 117, 17, 90, 146, 185, 51, 242, 38, 207, 104]));
/// ATB: GDATB22CVX7722UJGVGI5SGNMBFFWZE2LHQP7KKO2ANXGUQTRFMXZHEY
static immutable ATB = KeyPair(PublicKey([193, 48, 235, 66, 173, 255, 253, 106, 137, 53, 76, 142, 200, 205, 96, 74, 91, 100, 154, 89, 224, 255, 169, 78, 208, 27, 115, 82, 19, 137, 89, 124]), SecretKey([24, 59, 252, 58, 36, 157, 175, 94, 155, 25, 209, 17, 187, 172, 32, 207, 134, 125, 87, 246, 239, 214, 133, 242, 41, 150, 59, 235, 251, 240, 38, 110]), Seed([13, 98, 148, 226, 110, 44, 243, 64, 46, 67, 198, 203, 115, 173, 100, 208, 21, 112, 100, 27, 0, 194, 43, 49, 21, 80, 116, 137, 181, 50, 183, 67]));
/// ATC: GDATC22NHSHNXIEZKXJOGUHSFHI5R5MHOQE6JJUPW4FB2TBQ76CLLZRC
static immutable ATC = KeyPair(PublicKey([193, 49, 107, 77, 60, 142, 219, 160, 153, 85, 210, 227, 80, 242, 41, 209, 216, 245, 135, 116, 9, 228, 166, 143, 183, 10, 29, 76, 48, 255, 132, 181]), SecretKey([72, 116, 34, 98, 199, 197, 162, 40, 161, 59, 70, 214, 210, 198, 231, 75, 195, 243, 85, 12, 223, 60, 80, 208, 200, 240, 20, 164, 253, 230, 149, 76]), Seed([196, 48, 178, 249, 198, 223, 198, 254, 142, 254, 148, 64, 96, 180, 108, 55, 58, 195, 138, 56, 147, 182, 176, 162, 172, 194, 154, 104, 18, 243, 149, 185]));
/// ATD: GDATD22L4P4RCP6KPDJF4M3RHEWBILGPR4NBRGMD7WC4XVDWX6GC7BNB
static immutable ATD = KeyPair(PublicKey([193, 49, 235, 75, 227, 249, 17, 63, 202, 120, 210, 94, 51, 113, 57, 44, 20, 44, 207, 143, 26, 24, 153, 131, 253, 133, 203, 212, 118, 191, 140, 47]), SecretKey([176, 29, 44, 149, 177, 17, 24, 155, 125, 109, 189, 161, 71, 163, 180, 253, 22, 5, 6, 245, 3, 7, 201, 101, 129, 211, 230, 159, 197, 165, 101, 98]), Seed([45, 203, 221, 231, 183, 146, 100, 242, 207, 33, 98, 143, 212, 201, 134, 106, 240, 21, 165, 152, 130, 24, 159, 195, 116, 201, 177, 184, 57, 86, 177, 193]));
/// ATE: GDATE22YJ2LL7TU7LHJSQU5ZUVQDPU5WYU4AKTO5EOTMH2FW2O7URQB2
static immutable ATE = KeyPair(PublicKey([193, 50, 107, 88, 78, 150, 191, 206, 159, 89, 211, 40, 83, 185, 165, 96, 55, 211, 182, 197, 56, 5, 77, 221, 35, 166, 195, 232, 182, 211, 191, 72]), SecretKey([160, 136, 29, 73, 118, 2, 43, 208, 60, 126, 157, 182, 226, 39, 54, 52, 105, 213, 190, 12, 93, 144, 225, 54, 192, 116, 40, 132, 154, 65, 234, 86]), Seed([218, 151, 116, 58, 182, 125, 224, 201, 121, 239, 210, 238, 193, 31, 173, 129, 67, 69, 209, 163, 201, 193, 87, 147, 144, 150, 169, 149, 155, 224, 29, 215]));
/// ATF: GDATF22Y2Y6Y2Q72BYULJV4BHE2S2URMC22FABVFJFYYRDXEV5J4RHGD
static immutable ATF = KeyPair(PublicKey([193, 50, 235, 88, 214, 61, 141, 67, 250, 14, 40, 180, 215, 129, 57, 53, 45, 82, 44, 22, 180, 80, 6, 165, 73, 113, 136, 142, 228, 175, 83, 200]), SecretKey([152, 149, 205, 144, 250, 11, 113, 130, 7, 75, 43, 150, 181, 130, 46, 118, 183, 141, 154, 193, 61, 212, 160, 235, 60, 247, 61, 60, 168, 57, 137, 90]), Seed([117, 217, 241, 151, 204, 229, 90, 255, 61, 220, 10, 235, 22, 138, 44, 149, 107, 3, 158, 8, 93, 130, 111, 91, 155, 59, 205, 191, 214, 143, 37, 220]));
/// ATG: GDATG22CHCKKLZ67AOD4QZDLXO6LCDP6VZB6B6DZAVLC2CIPEPMKB27G
static immutable ATG = KeyPair(PublicKey([193, 51, 107, 66, 56, 148, 165, 231, 223, 3, 135, 200, 100, 107, 187, 188, 177, 13, 254, 174, 67, 224, 248, 121, 5, 86, 45, 9, 15, 35, 216, 160]), SecretKey([24, 118, 198, 92, 30, 212, 111, 56, 79, 5, 222, 16, 9, 121, 202, 132, 157, 157, 234, 143, 93, 203, 87, 90, 139, 148, 183, 105, 81, 184, 253, 90]), Seed([128, 36, 252, 177, 222, 205, 159, 16, 12, 57, 209, 208, 149, 6, 71, 158, 153, 174, 21, 98, 157, 26, 12, 112, 138, 105, 228, 231, 110, 21, 179, 255]));
/// ATH: GDATH2247TB5PVKFHH4NNCPK3Y7I5KHNLN2GHU3BAF5RHHTZ3TUR5FZR
static immutable ATH = KeyPair(PublicKey([193, 51, 235, 92, 252, 195, 215, 213, 69, 57, 248, 214, 137, 234, 222, 62, 142, 168, 237, 91, 116, 99, 211, 97, 1, 123, 19, 158, 121, 220, 233, 30]), SecretKey([200, 191, 98, 128, 92, 154, 33, 233, 163, 65, 91, 6, 62, 135, 209, 50, 141, 254, 126, 31, 128, 119, 196, 187, 206, 228, 187, 220, 237, 112, 6, 73]), Seed([59, 164, 147, 110, 146, 207, 200, 12, 241, 57, 165, 175, 61, 218, 123, 253, 96, 173, 17, 115, 11, 28, 140, 102, 132, 203, 165, 155, 40, 206, 90, 46]));
/// ATI: GDATI22RQU46OV7A6P3WJLZTJJ2ODKUNJVJZI42QMVPHY4VOPPGXSZQQ
static immutable ATI = KeyPair(PublicKey([193, 52, 107, 81, 133, 57, 231, 87, 224, 243, 247, 100, 175, 51, 74, 116, 225, 170, 141, 77, 83, 148, 115, 80, 101, 94, 124, 114, 174, 123, 205, 121]), SecretKey([96, 134, 62, 223, 77, 12, 109, 196, 212, 225, 70, 145, 220, 99, 111, 41, 128, 212, 142, 126, 69, 3, 30, 170, 245, 68, 173, 145, 113, 171, 206, 84]), Seed([251, 179, 51, 195, 194, 29, 69, 238, 107, 207, 65, 130, 144, 224, 179, 31, 171, 189, 40, 167, 121, 157, 58, 250, 31, 3, 124, 53, 66, 225, 119, 126]));
/// ATJ: GDATJ22ZFI7WCNRJOQCWG2X2PGPSTDGWL6JFM73GOTMLS3ILLAZPLTAF
static immutable ATJ = KeyPair(PublicKey([193, 52, 235, 89, 42, 63, 97, 54, 41, 116, 5, 99, 106, 250, 121, 159, 41, 140, 214, 95, 146, 86, 127, 102, 116, 216, 185, 109, 11, 88, 50, 245]), SecretKey([232, 190, 182, 252, 168, 160, 227, 251, 57, 194, 190, 110, 188, 165, 235, 226, 16, 245, 232, 11, 131, 6, 193, 99, 31, 56, 235, 13, 162, 20, 229, 69]), Seed([223, 84, 35, 0, 31, 119, 104, 146, 88, 173, 184, 25, 138, 18, 202, 241, 35, 28, 73, 89, 191, 244, 215, 35, 194, 106, 223, 127, 145, 29, 57, 99]));
/// ATK: GDATK22522THFEGGJPAWPLBFPBZGUA3THN4XXJXLNEYLRZUZZF3DL2YM
static immutable ATK = KeyPair(PublicKey([193, 53, 107, 93, 214, 166, 114, 144, 198, 75, 193, 103, 172, 37, 120, 114, 106, 3, 115, 59, 121, 123, 166, 235, 105, 48, 184, 230, 153, 201, 118, 53]), SecretKey([184, 202, 47, 196, 31, 17, 42, 225, 109, 147, 165, 146, 187, 165, 154, 39, 104, 122, 177, 19, 112, 136, 166, 253, 134, 235, 91, 248, 78, 160, 72, 112]), Seed([178, 82, 28, 233, 54, 214, 132, 163, 59, 217, 168, 158, 172, 43, 106, 41, 230, 65, 153, 1, 109, 82, 214, 98, 89, 137, 163, 221, 103, 168, 38, 93]));
/// ATL: GDATL222ASRFYLVDFPRR5MCOLEVGFB5DY6JDU52ECES4OXESJIEL47BG
static immutable ATL = KeyPair(PublicKey([193, 53, 235, 90, 4, 162, 92, 46, 163, 43, 227, 30, 176, 78, 89, 42, 98, 135, 163, 199, 146, 58, 119, 68, 17, 37, 199, 92, 146, 74, 8, 190]), SecretKey([24, 228, 194, 43, 62, 238, 80, 22, 173, 157, 225, 141, 102, 151, 56, 133, 42, 189, 68, 227, 167, 204, 111, 2, 99, 89, 159, 46, 186, 75, 250, 80]), Seed([192, 128, 153, 160, 158, 41, 195, 196, 253, 172, 155, 182, 188, 235, 32, 145, 21, 187, 89, 179, 179, 172, 242, 143, 24, 50, 165, 77, 242, 101, 244, 172]));
/// ATM: GDATM22FKANSNHL3BHJPC4HVKVEOTP3G24CAKXRWSBAUO6UAXQNLTO3U
static immutable ATM = KeyPair(PublicKey([193, 54, 107, 69, 80, 27, 38, 157, 123, 9, 210, 241, 112, 245, 85, 72, 233, 191, 102, 215, 4, 5, 94, 54, 144, 65, 71, 122, 128, 188, 26, 185]), SecretKey([248, 18, 40, 171, 35, 253, 228, 157, 191, 242, 163, 58, 135, 86, 86, 31, 83, 136, 117, 123, 78, 18, 52, 14, 31, 76, 155, 249, 31, 217, 193, 97]), Seed([86, 80, 16, 206, 89, 54, 214, 193, 168, 155, 244, 157, 251, 37, 52, 127, 232, 38, 168, 136, 146, 243, 218, 128, 42, 180, 171, 249, 19, 53, 18, 84]));
/// ATN: GDATN22GIMZYIEXJLQWGGUVDPAKLTMTXV6PLLKTS54PNM4UFFTMOWOIC
static immutable ATN = KeyPair(PublicKey([193, 54, 235, 70, 67, 51, 132, 18, 233, 92, 44, 99, 82, 163, 120, 20, 185, 178, 119, 175, 158, 181, 170, 114, 239, 30, 214, 114, 133, 44, 216, 235]), SecretKey([248, 250, 124, 26, 34, 241, 4, 164, 45, 253, 148, 124, 56, 126, 138, 99, 202, 149, 232, 254, 12, 116, 115, 3, 85, 132, 34, 140, 64, 219, 86, 99]), Seed([89, 164, 45, 166, 110, 45, 20, 197, 15, 79, 70, 142, 102, 172, 136, 172, 160, 74, 60, 49, 69, 123, 124, 138, 56, 125, 173, 126, 47, 73, 183, 44]));
/// ATO: GDATO22RLESENRG6RKH6S2FY7SUR6FMV52DJMQ2N44PLKDLT5RMIMRU3
static immutable ATO = KeyPair(PublicKey([193, 55, 107, 81, 89, 36, 70, 196, 222, 138, 143, 233, 104, 184, 252, 169, 31, 21, 149, 238, 134, 150, 67, 77, 231, 30, 181, 13, 115, 236, 88, 134]), SecretKey([16, 104, 82, 18, 67, 115, 197, 224, 16, 39, 186, 70, 167, 9, 162, 54, 87, 239, 17, 129, 27, 16, 190, 147, 94, 240, 216, 100, 186, 21, 40, 71]), Seed([80, 56, 205, 220, 123, 163, 25, 6, 99, 101, 146, 103, 173, 56, 122, 11, 215, 76, 111, 249, 32, 125, 171, 190, 133, 174, 185, 111, 190, 24, 231, 232]));
/// ATP: GDATP22MWYIFLNTT2C3I7NV7AC4N5WSURAN2FMSSS7PY6CHMBAKHP6CG
static immutable ATP = KeyPair(PublicKey([193, 55, 235, 76, 182, 16, 85, 182, 115, 208, 182, 143, 182, 191, 0, 184, 222, 218, 84, 136, 27, 162, 178, 82, 151, 223, 143, 8, 236, 8, 20, 119]), SecretKey([16, 252, 24, 0, 101, 248, 195, 135, 18, 141, 199, 110, 225, 8, 12, 189, 206, 220, 159, 71, 97, 72, 64, 128, 222, 178, 127, 249, 195, 13, 106, 82]), Seed([244, 139, 65, 197, 43, 169, 143, 203, 115, 36, 111, 122, 50, 224, 19, 57, 80, 95, 158, 106, 247, 59, 216, 106, 168, 116, 14, 197, 239, 185, 212, 3]));
/// ATQ: GDATQ22QGMYICEBGYO57UJLN6S3J4TV2W3H7N5AGAAPA3C6JZXUKVOHU
static immutable ATQ = KeyPair(PublicKey([193, 56, 107, 80, 51, 48, 129, 16, 38, 195, 187, 250, 37, 109, 244, 182, 158, 78, 186, 182, 207, 246, 244, 6, 0, 30, 13, 139, 201, 205, 232, 170]), SecretKey([224, 236, 77, 254, 114, 148, 100, 112, 78, 36, 18, 170, 98, 48, 222, 255, 103, 63, 159, 10, 29, 96, 132, 58, 247, 17, 62, 199, 176, 196, 226, 73]), Seed([141, 115, 253, 34, 207, 210, 28, 153, 155, 89, 68, 18, 129, 99, 158, 242, 128, 65, 174, 156, 121, 14, 34, 46, 126, 192, 180, 81, 108, 147, 96, 52]));
/// ATR: GDATR22O2D6M2IATCEVE4B5WZSIJ7QNSEDMGHMK6HLKDJ2TLT2GQZ5BX
static immutable ATR = KeyPair(PublicKey([193, 56, 235, 78, 208, 252, 205, 32, 19, 17, 42, 78, 7, 182, 204, 144, 159, 193, 178, 32, 216, 99, 177, 94, 58, 212, 52, 234, 107, 158, 141, 12]), SecretKey([128, 61, 1, 199, 161, 132, 44, 121, 5, 171, 220, 32, 200, 227, 66, 11, 135, 152, 57, 31, 147, 46, 239, 217, 195, 126, 160, 57, 139, 151, 225, 73]), Seed([172, 93, 246, 44, 68, 70, 133, 140, 113, 5, 197, 127, 115, 130, 198, 22, 120, 30, 221, 92, 38, 21, 205, 180, 209, 96, 225, 220, 22, 60, 139, 184]));
/// ATS: GDATS22D5DXBHAXX2N7MIZJEZTEXRYKL4VXN6UHDPBOMVXPQW6ATQJ6D
static immutable ATS = KeyPair(PublicKey([193, 57, 107, 67, 232, 238, 19, 130, 247, 211, 126, 196, 101, 36, 204, 201, 120, 225, 75, 229, 110, 223, 80, 227, 120, 92, 202, 221, 240, 183, 129, 56]), SecretKey([72, 95, 18, 32, 138, 87, 62, 150, 138, 219, 177, 238, 121, 170, 26, 173, 254, 17, 222, 32, 49, 119, 236, 134, 144, 209, 142, 102, 208, 65, 63, 124]), Seed([35, 117, 20, 119, 235, 224, 116, 39, 24, 242, 10, 228, 172, 218, 126, 192, 225, 186, 13, 202, 45, 81, 62, 226, 43, 254, 157, 70, 165, 32, 14, 222]));
/// ATT: GDATT22XFBWQGD6KYYK6L4M4FMSJ73VYM3OF46GYARWM7IKP4NBWHAZE
static immutable ATT = KeyPair(PublicKey([193, 57, 235, 87, 40, 109, 3, 15, 202, 198, 21, 229, 241, 156, 43, 36, 159, 238, 184, 102, 220, 94, 120, 216, 4, 108, 207, 161, 79, 227, 67, 99]), SecretKey([168, 231, 56, 104, 137, 162, 171, 8, 223, 77, 13, 7, 132, 92, 213, 242, 131, 121, 55, 146, 67, 121, 37, 46, 191, 80, 35, 8, 107, 15, 34, 126]), Seed([13, 244, 53, 200, 253, 44, 169, 119, 243, 105, 137, 223, 186, 62, 155, 205, 179, 211, 207, 81, 32, 167, 218, 125, 58, 243, 150, 182, 106, 25, 143, 249]));
/// ATU: GDATU22TRPIDKRJEUZ5TM4MZZ7ID4ZYYBDY6TZ6FREGQYTBCAH3O5NLL
static immutable ATU = KeyPair(PublicKey([193, 58, 107, 83, 139, 208, 53, 69, 36, 166, 123, 54, 113, 153, 207, 208, 62, 103, 24, 8, 241, 233, 231, 197, 137, 13, 12, 76, 34, 1, 246, 238]), SecretKey([32, 39, 178, 64, 158, 174, 78, 119, 204, 196, 33, 250, 31, 226, 156, 85, 115, 241, 116, 195, 98, 181, 207, 162, 42, 240, 24, 45, 133, 118, 90, 123]), Seed([220, 94, 135, 17, 80, 42, 24, 217, 221, 170, 251, 188, 124, 132, 86, 72, 97, 121, 108, 74, 4, 163, 77, 27, 91, 134, 216, 105, 242, 19, 63, 134]));
/// ATV: GDATV22GJCINFIZQEVQCBFEBHBCDEVYGDL3S4EZPMNR6AS7CJ6OED4O7
static immutable ATV = KeyPair(PublicKey([193, 58, 235, 70, 72, 144, 210, 163, 48, 37, 96, 32, 148, 129, 56, 68, 50, 87, 6, 26, 247, 46, 19, 47, 99, 99, 224, 75, 226, 79, 156, 65]), SecretKey([128, 118, 71, 176, 68, 96, 104, 100, 86, 107, 178, 31, 142, 178, 136, 43, 85, 141, 2, 172, 97, 80, 231, 206, 11, 131, 48, 165, 98, 165, 125, 107]), Seed([115, 145, 196, 132, 160, 59, 130, 83, 121, 234, 251, 250, 196, 76, 213, 180, 242, 95, 162, 76, 7, 80, 134, 152, 178, 145, 189, 113, 186, 135, 252, 233]));
/// ATW: GDATW22F3XX3MOHAQ3IIDLY2DBEUR3J5F5VPRGK6EQUFF6IIUR5L7XYK
static immutable ATW = KeyPair(PublicKey([193, 59, 107, 69, 221, 239, 182, 56, 224, 134, 208, 129, 175, 26, 24, 73, 72, 237, 61, 47, 106, 248, 153, 94, 36, 40, 82, 249, 8, 164, 122, 191]), SecretKey([248, 243, 9, 102, 69, 30, 117, 10, 110, 125, 30, 177, 87, 66, 190, 120, 122, 36, 13, 80, 234, 147, 77, 205, 8, 73, 122, 71, 102, 21, 245, 81]), Seed([211, 180, 12, 109, 84, 211, 145, 30, 59, 60, 54, 9, 26, 139, 59, 119, 235, 58, 44, 44, 139, 231, 22, 234, 210, 217, 183, 240, 213, 192, 76, 73]));
/// ATX: GDATX22BNYBACHELR6MH7EGE4W2A2XIIKZPA2XE64YI2X4KIDDHSCK7C
static immutable ATX = KeyPair(PublicKey([193, 59, 235, 65, 110, 2, 1, 28, 139, 143, 152, 127, 144, 196, 229, 180, 13, 93, 8, 86, 94, 13, 92, 158, 230, 17, 171, 241, 72, 24, 207, 33]), SecretKey([128, 142, 147, 11, 244, 221, 162, 142, 61, 1, 114, 48, 226, 131, 223, 43, 174, 185, 56, 11, 114, 69, 73, 28, 158, 144, 202, 165, 253, 250, 103, 82]), Seed([188, 99, 211, 120, 153, 46, 57, 118, 42, 215, 57, 22, 175, 38, 4, 252, 190, 97, 132, 245, 254, 146, 125, 247, 246, 17, 3, 196, 60, 153, 96, 153]));
/// ATY: GDATY226XCO2CZUGJYQHCTC6N6YO6KO5STXGQL37GU4FM3KW2I7RJEYU
static immutable ATY = KeyPair(PublicKey([193, 60, 107, 94, 184, 157, 161, 102, 134, 78, 32, 113, 76, 94, 111, 176, 239, 41, 221, 148, 238, 104, 47, 127, 53, 56, 86, 109, 86, 210, 63, 20]), SecretKey([64, 44, 146, 204, 160, 102, 33, 8, 169, 19, 156, 122, 145, 40, 131, 152, 3, 135, 1, 138, 44, 72, 59, 132, 55, 14, 97, 75, 9, 93, 223, 66]), Seed([41, 2, 145, 26, 60, 176, 145, 227, 43, 250, 78, 255, 201, 130, 25, 89, 59, 74, 112, 203, 29, 6, 159, 139, 227, 35, 25, 30, 138, 211, 132, 21]));
/// ATZ: GDATZ223SV5HFZZFLROOOK5ROS3TXOJP3MUV6HGAP4HPWVE3O4HJNGVB
static immutable ATZ = KeyPair(PublicKey([193, 60, 235, 91, 149, 122, 114, 231, 37, 92, 92, 231, 43, 177, 116, 183, 59, 185, 47, 219, 41, 95, 28, 192, 127, 14, 251, 84, 155, 119, 14, 150]), SecretKey([136, 248, 13, 38, 243, 83, 231, 233, 90, 162, 161, 112, 215, 105, 18, 27, 16, 36, 171, 197, 15, 136, 22, 164, 196, 69, 107, 137, 250, 191, 194, 117]), Seed([52, 197, 82, 84, 20, 190, 21, 97, 231, 132, 15, 208, 133, 135, 209, 132, 143, 242, 2, 226, 119, 35, 110, 236, 203, 236, 125, 234, 24, 70, 232, 92]));
/// AUA: GDAUA22DIMTSD4TUERBO46AVCPUUIEOJ7VBT6KP67FQWSZI3LHRNGMPI
static immutable AUA = KeyPair(PublicKey([193, 64, 107, 67, 67, 39, 33, 242, 116, 36, 66, 238, 120, 21, 19, 233, 68, 17, 201, 253, 67, 63, 41, 254, 249, 97, 105, 101, 27, 89, 226, 211]), SecretKey([120, 94, 102, 222, 255, 44, 101, 181, 159, 38, 200, 218, 20, 131, 69, 180, 2, 55, 198, 243, 248, 24, 104, 180, 200, 13, 209, 45, 200, 169, 115, 91]), Seed([90, 198, 75, 61, 167, 114, 32, 232, 225, 119, 69, 106, 164, 136, 219, 223, 102, 156, 139, 146, 64, 132, 206, 27, 246, 55, 175, 51, 224, 142, 86, 106]));
/// AUB: GA5WUJ54Z23KILLCUOUNAKTPBVZWKMQVO4O6EQ5GHLAERIMLLHNCSKYH
static immutable AUB = KeyPair(PublicKey([59, 106, 39, 188, 206, 182, 164, 45, 98, 163, 168, 208, 42, 111, 13, 115, 101, 50, 21, 119, 29, 226, 67, 166, 58, 192, 72, 161, 139, 89, 218, 41]), SecretKey([80, 70, 173, 193, 219, 168, 56, 134, 123, 43, 187, 253, 208, 195, 66, 62, 88, 181, 121, 112, 181, 38, 122, 144, 245, 121, 96, 146, 74, 135, 241, 86]), Seed([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
/// AUC: GDAUC22FJS3UN2IVJZH4MVRVQDKQJLYBOAV3XUJTSOCEMJZEUVWVCJHT
static immutable AUC = KeyPair(PublicKey([193, 65, 107, 69, 76, 183, 70, 233, 21, 78, 79, 198, 86, 53, 128, 213, 4, 175, 1, 112, 43, 187, 209, 51, 147, 132, 70, 39, 36, 165, 109, 81]), SecretKey([232, 42, 83, 73, 86, 214, 54, 172, 120, 8, 45, 151, 122, 54, 103, 84, 131, 37, 97, 202, 57, 223, 184, 242, 188, 188, 104, 148, 11, 84, 128, 92]), Seed([179, 254, 29, 215, 140, 75, 228, 130, 27, 173, 252, 116, 14, 65, 187, 241, 57, 11, 110, 217, 53, 185, 201, 38, 113, 179, 129, 21, 64, 240, 121, 92]));
/// AUD: GDAUD225A2TS4JGCLSUVFCC6L6CDNPKCR3B3JWR2FGDJ3P34LCCS4MWW
static immutable AUD = KeyPair(PublicKey([193, 65, 235, 93, 6, 167, 46, 36, 194, 92, 169, 82, 136, 94, 95, 132, 54, 189, 66, 142, 195, 180, 218, 58, 41, 134, 157, 191, 124, 88, 133, 46]), SecretKey([184, 175, 33, 118, 170, 122, 217, 49, 9, 224, 121, 152, 129, 35, 44, 22, 66, 23, 205, 89, 176, 234, 110, 124, 66, 49, 103, 103, 83, 194, 57, 105]), Seed([238, 199, 92, 61, 40, 150, 254, 159, 72, 191, 57, 125, 9, 157, 254, 79, 112, 216, 88, 240, 126, 2, 33, 237, 240, 132, 7, 130, 180, 172, 221, 132]));
/// AUE: GDAUE22PR43QCBF5BAMH7W6QFWBYGZF56X4XFX6KJAGWJRIWPK6OBOCC
static immutable AUE = KeyPair(PublicKey([193, 66, 107, 79, 143, 55, 1, 4, 189, 8, 24, 127, 219, 208, 45, 131, 131, 100, 189, 245, 249, 114, 223, 202, 72, 13, 100, 197, 22, 122, 188, 224]), SecretKey([152, 27, 220, 171, 31, 248, 237, 134, 206, 95, 164, 179, 233, 55, 226, 224, 172, 42, 244, 195, 215, 73, 208, 193, 128, 227, 119, 11, 241, 161, 195, 119]), Seed([232, 233, 185, 183, 35, 32, 209, 55, 217, 108, 175, 247, 104, 95, 215, 210, 137, 151, 60, 70, 99, 32, 66, 65, 120, 131, 145, 77, 55, 161, 110, 152]));
/// AUF: GDAUF22U6YEGJZCWKP6Q7V2DK25BGTVEPB4F4BKVTYEL46SXQPKV34K2
static immutable AUF = KeyPair(PublicKey([193, 66, 235, 84, 246, 8, 100, 228, 86, 83, 253, 15, 215, 67, 86, 186, 19, 78, 164, 120, 120, 94, 5, 85, 158, 8, 190, 122, 87, 131, 213, 93]), SecretKey([96, 169, 99, 212, 186, 254, 154, 70, 116, 236, 181, 39, 236, 202, 173, 17, 141, 153, 152, 53, 109, 116, 21, 125, 168, 30, 180, 191, 147, 153, 118, 66]), Seed([248, 7, 99, 80, 120, 202, 218, 132, 144, 152, 82, 159, 3, 65, 77, 205, 48, 110, 46, 78, 240, 48, 109, 115, 16, 205, 83, 56, 60, 167, 41, 37]));
/// AUG: GDAUG22AF6736JU2PZO2GU3KROJHOIBDB4VEXYZXHBE2QTLFJ6OWDK42
static immutable AUG = KeyPair(PublicKey([193, 67, 107, 64, 47, 191, 191, 38, 154, 126, 93, 163, 83, 106, 139, 146, 119, 32, 35, 15, 42, 75, 227, 55, 56, 73, 168, 77, 101, 79, 157, 97]), SecretKey([120, 134, 18, 41, 15, 173, 125, 161, 204, 25, 33, 48, 208, 134, 202, 167, 111, 207, 110, 116, 81, 246, 247, 186, 115, 148, 142, 25, 133, 67, 187, 107]), Seed([249, 79, 20, 21, 241, 135, 76, 119, 140, 103, 248, 226, 251, 28, 89, 224, 186, 63, 66, 135, 2, 106, 5, 186, 123, 38, 207, 239, 85, 4, 4, 49]));
/// AUH: GDAUH22FVARSBACU3ALBF3RJ5B5XHCJGSRLJW4NZHWYU6QGXH4TH3AHA
static immutable AUH = KeyPair(PublicKey([193, 67, 235, 69, 168, 35, 32, 128, 84, 216, 22, 18, 238, 41, 232, 123, 115, 137, 38, 148, 86, 155, 113, 185, 61, 177, 79, 64, 215, 63, 38, 125]), SecretKey([200, 190, 253, 249, 198, 62, 242, 120, 200, 171, 63, 98, 115, 3, 234, 142, 105, 148, 25, 117, 145, 194, 60, 113, 252, 78, 12, 72, 165, 116, 99, 95]), Seed([110, 92, 222, 98, 220, 205, 193, 56, 246, 98, 86, 43, 128, 10, 50, 92, 14, 125, 23, 94, 68, 179, 240, 135, 196, 114, 85, 52, 3, 128, 117, 199]));
/// AUI: GDAUI22QCFNKQSEQCR3XLYDA2MRN6N3QNQJO7OCL3HSZO7VOUGTHLJN3
static immutable AUI = KeyPair(PublicKey([193, 68, 107, 80, 17, 90, 168, 72, 144, 20, 119, 117, 224, 96, 211, 34, 223, 55, 112, 108, 18, 239, 184, 75, 217, 229, 151, 126, 174, 161, 166, 117]), SecretKey([48, 238, 105, 67, 172, 92, 107, 36, 120, 200, 217, 71, 161, 93, 132, 236, 33, 110, 126, 216, 158, 57, 212, 2, 92, 253, 201, 118, 182, 92, 32, 64]), Seed([15, 5, 3, 208, 244, 30, 56, 36, 244, 55, 68, 219, 56, 133, 71, 3, 182, 186, 38, 159, 103, 44, 163, 155, 61, 164, 56, 69, 233, 237, 76, 19]));
/// AUJ: GDAUJ22GOV325JLQR6Q4KILWIDI64BL7YIC6GWK3KS33O4WWANWDWDC7
static immutable AUJ = KeyPair(PublicKey([193, 68, 235, 70, 117, 119, 174, 165, 112, 143, 161, 197, 33, 118, 64, 209, 238, 5, 127, 194, 5, 227, 89, 91, 84, 183, 183, 114, 214, 3, 108, 59]), SecretKey([16, 80, 22, 139, 148, 129, 3, 182, 79, 111, 232, 147, 9, 150, 108, 97, 146, 60, 81, 209, 150, 85, 244, 166, 116, 231, 210, 30, 129, 158, 72, 88]), Seed([67, 78, 3, 143, 5, 101, 234, 236, 4, 187, 78, 135, 78, 101, 13, 13, 176, 13, 156, 197, 186, 91, 54, 190, 21, 191, 73, 253, 203, 104, 116, 174]));
/// AUK: GDAUK22IIFTRJFLDKEZZS4G3RHFP6I77PHO3PYXXRD3V5M2GZ6SL7R54
static immutable AUK = KeyPair(PublicKey([193, 69, 107, 72, 65, 103, 20, 149, 99, 81, 51, 153, 112, 219, 137, 202, 255, 35, 255, 121, 221, 183, 226, 247, 136, 247, 94, 179, 70, 207, 164, 191]), SecretKey([48, 68, 75, 54, 222, 70, 30, 81, 192, 237, 16, 54, 169, 211, 154, 226, 255, 250, 80, 131, 119, 96, 1, 226, 119, 60, 221, 52, 72, 189, 106, 120]), Seed([105, 138, 97, 84, 160, 40, 204, 252, 40, 141, 87, 47, 172, 173, 207, 2, 158, 73, 155, 179, 152, 175, 141, 15, 1, 100, 29, 150, 89, 25, 198, 26]));
/// AUL: GDAUL224JGJMRA6ZMQZKEN3YU7GT4ZYS56QNW2XLMSK5AHNWGD376CFO
static immutable AUL = KeyPair(PublicKey([193, 69, 235, 92, 73, 146, 200, 131, 217, 100, 50, 162, 55, 120, 167, 205, 62, 103, 18, 239, 160, 219, 106, 235, 100, 149, 208, 29, 182, 48, 247, 255]), SecretKey([72, 47, 72, 205, 12, 230, 135, 140, 127, 128, 179, 58, 50, 150, 24, 156, 121, 183, 51, 215, 201, 103, 251, 2, 107, 114, 220, 1, 45, 141, 7, 121]), Seed([174, 221, 234, 255, 172, 7, 182, 154, 191, 23, 69, 119, 103, 248, 154, 47, 7, 25, 170, 197, 217, 8, 57, 20, 141, 141, 166, 17, 76, 202, 90, 49]));
/// AUM: GDAUM22YMPLVY27TJWLADHC3NPW6FKF6XKBLPRVJSHX5HDRVGSXDXHKG
static immutable AUM = KeyPair(PublicKey([193, 70, 107, 88, 99, 215, 92, 107, 243, 77, 150, 1, 156, 91, 107, 237, 226, 168, 190, 186, 130, 183, 198, 169, 145, 239, 211, 142, 53, 52, 174, 59]), SecretKey([40, 101, 100, 113, 251, 147, 149, 173, 11, 74, 97, 0, 131, 79, 132, 148, 212, 75, 172, 163, 155, 117, 25, 77, 255, 73, 205, 196, 125, 79, 206, 82]), Seed([58, 15, 56, 66, 118, 16, 102, 101, 229, 215, 109, 112, 33, 247, 191, 138, 36, 113, 43, 50, 68, 193, 166, 1, 26, 159, 90, 15, 135, 21, 85, 52]));
/// AUN: GDAUN224OTC2O75U5SMYHW742VDYJO276OEN33HCW2UTIXSIJR6G6WG3
static immutable AUN = KeyPair(PublicKey([193, 70, 235, 92, 116, 197, 167, 127, 180, 236, 153, 131, 219, 252, 213, 71, 132, 187, 95, 243, 136, 221, 236, 226, 182, 169, 52, 94, 72, 76, 124, 111]), SecretKey([208, 132, 158, 132, 170, 19, 38, 29, 238, 4, 183, 66, 82, 175, 227, 147, 120, 210, 251, 24, 96, 33, 228, 0, 77, 79, 205, 120, 181, 247, 32, 77]), Seed([6, 246, 71, 216, 22, 90, 236, 169, 233, 196, 53, 89, 118, 131, 136, 253, 199, 126, 223, 197, 86, 90, 154, 48, 11, 126, 190, 224, 108, 133, 187, 138]));
/// AUO: GDAUO22SXVQVAR6AXV2J4NFRD62QX6NL7VHT7NV5YM4JWLVTMHSKWMBC
static immutable AUO = KeyPair(PublicKey([193, 71, 107, 82, 189, 97, 80, 71, 192, 189, 116, 158, 52, 177, 31, 181, 11, 249, 171, 253, 79, 63, 182, 189, 195, 56, 155, 46, 179, 97, 228, 171]), SecretKey([64, 107, 85, 53, 216, 150, 172, 245, 103, 223, 190, 203, 48, 72, 84, 63, 124, 95, 70, 183, 251, 221, 15, 97, 144, 142, 224, 165, 192, 92, 186, 79]), Seed([250, 28, 27, 106, 162, 154, 36, 223, 34, 227, 220, 97, 122, 193, 129, 252, 37, 189, 148, 130, 249, 221, 9, 76, 13, 224, 142, 80, 189, 8, 21, 249]));
/// AUP: GDAUP223ZSKVKMIX7SORKVDHV6YUHPQMJ34ZZ3KF3BRRYNYXVYMQYQON
static immutable AUP = KeyPair(PublicKey([193, 71, 235, 91, 204, 149, 85, 49, 23, 252, 157, 21, 84, 103, 175, 177, 67, 190, 12, 78, 249, 156, 237, 69, 216, 99, 28, 55, 23, 174, 25, 12]), SecretKey([208, 35, 223, 131, 126, 148, 131, 247, 11, 171, 188, 57, 19, 162, 0, 33, 134, 90, 144, 219, 89, 33, 2, 43, 199, 197, 137, 3, 198, 214, 28, 81]), Seed([252, 63, 66, 213, 111, 227, 247, 234, 222, 40, 142, 30, 140, 121, 152, 42, 143, 183, 212, 151, 27, 43, 252, 42, 111, 211, 1, 233, 13, 160, 66, 130]));
/// AUQ: GDAUQ22LNQBQZHK3KQ67RVJJM6DUDT5FNT7N3FT6SX4IVAON5INHA7US
static immutable AUQ = KeyPair(PublicKey([193, 72, 107, 75, 108, 3, 12, 157, 91, 84, 61, 248, 213, 41, 103, 135, 65, 207, 165, 108, 254, 221, 150, 126, 149, 248, 138, 129, 205, 234, 26, 112]), SecretKey([168, 74, 128, 147, 177, 128, 23, 252, 123, 175, 24, 233, 3, 34, 1, 223, 30, 38, 119, 99, 192, 241, 57, 74, 74, 48, 83, 124, 111, 165, 128, 104]), Seed([84, 82, 3, 48, 172, 182, 196, 112, 76, 117, 22, 219, 85, 78, 22, 29, 222, 2, 130, 101, 176, 207, 250, 144, 199, 74, 133, 146, 175, 128, 121, 73]));
/// AUR: GDAUR22JSAG7RFYZGKSWJFAN4THEPNWZYKNJSOS57PFBXJGZ53YLY3KQ
static immutable AUR = KeyPair(PublicKey([193, 72, 235, 73, 144, 13, 248, 151, 25, 50, 165, 100, 148, 13, 228, 206, 71, 182, 217, 194, 154, 153, 58, 93, 251, 202, 27, 164, 217, 238, 240, 188]), SecretKey([64, 108, 23, 235, 163, 5, 3, 246, 127, 69, 239, 230, 68, 162, 34, 227, 163, 159, 12, 230, 85, 98, 5, 37, 241, 122, 248, 102, 248, 111, 8, 124]), Seed([202, 71, 195, 40, 138, 23, 50, 149, 59, 21, 100, 242, 46, 53, 11, 50, 97, 185, 31, 36, 50, 180, 138, 118, 246, 152, 107, 100, 38, 54, 59, 241]));
/// AUS: GDAUS22ARQKGJ6W5VSVKKVHZV6Z5B2AEHSON3KZ7SO4HMMJ4XJAMSAWK
static immutable AUS = KeyPair(PublicKey([193, 73, 107, 64, 140, 20, 100, 250, 221, 172, 170, 165, 84, 249, 175, 179, 208, 232, 4, 60, 156, 221, 171, 63, 147, 184, 118, 49, 60, 186, 64, 201]), SecretKey([208, 7, 201, 223, 114, 55, 44, 108, 68, 12, 33, 29, 145, 13, 94, 235, 45, 237, 94, 36, 22, 88, 37, 206, 117, 96, 112, 120, 69, 182, 159, 72]), Seed([141, 157, 11, 32, 232, 54, 126, 214, 133, 121, 14, 177, 239, 143, 155, 10, 244, 62, 89, 139, 71, 140, 50, 36, 42, 87, 103, 119, 231, 212, 57, 152]));
/// AUT: GDAUT22H7ZN5RXWI5UDEOUAO6A2HTTJ4KBL5PRLTWYG3XAHRUGRDT4EY
static immutable AUT = KeyPair(PublicKey([193, 73, 235, 71, 254, 91, 216, 222, 200, 237, 6, 71, 80, 14, 240, 52, 121, 205, 60, 80, 87, 215, 197, 115, 182, 13, 187, 128, 241, 161, 162, 57]), SecretKey([216, 181, 3, 97, 114, 126, 243, 248, 108, 99, 193, 140, 88, 6, 55, 200, 161, 206, 255, 197, 248, 4, 234, 153, 178, 112, 165, 136, 121, 56, 155, 77]), Seed([134, 255, 97, 147, 116, 51, 73, 144, 246, 22, 57, 234, 102, 180, 126, 131, 6, 242, 252, 143, 176, 250, 130, 252, 177, 7, 252, 221, 222, 162, 45, 186]));
/// AUU: GDAUU22ECNH7SAFANBVAJFUSX47MDDAMZZ4IRWE5NWTALAEU6GEXGAPR
static immutable AUU = KeyPair(PublicKey([193, 74, 107, 68, 19, 79, 249, 0, 160, 104, 106, 4, 150, 146, 191, 62, 193, 140, 12, 206, 120, 136, 216, 157, 109, 166, 5, 128, 148, 241, 137, 115]), SecretKey([152, 155, 240, 172, 94, 202, 124, 141, 26, 204, 137, 18, 88, 43, 47, 113, 244, 156, 74, 194, 196, 205, 55, 22, 30, 168, 189, 89, 106, 230, 240, 68]), Seed([133, 100, 60, 8, 118, 152, 123, 3, 81, 12, 160, 150, 68, 236, 88, 140, 231, 191, 228, 30, 68, 197, 11, 120, 153, 215, 84, 245, 72, 103, 247, 8]));
/// AUV: GDAUV22IEOBVPJXHUYAAREE4VJNLCIPPSDVK3J2ZCMB6EFFHDRKNY4WH
static immutable AUV = KeyPair(PublicKey([193, 74, 235, 72, 35, 131, 87, 166, 231, 166, 0, 8, 144, 156, 170, 90, 177, 33, 239, 144, 234, 173, 167, 89, 19, 3, 226, 20, 167, 28, 84, 220]), SecretKey([56, 5, 101, 31, 136, 35, 209, 122, 145, 148, 217, 216, 102, 13, 102, 138, 201, 220, 130, 117, 85, 239, 86, 183, 94, 10, 228, 142, 157, 21, 202, 70]), Seed([171, 246, 0, 132, 32, 171, 53, 177, 72, 35, 241, 184, 114, 157, 92, 181, 141, 36, 94, 243, 33, 144, 69, 47, 254, 60, 219, 199, 61, 116, 84, 182]));
/// AUW: GDAUW22QSIYXOWTP3NGQWMVO4QXK3VAOHVFQ6HV6L6BIQSPC6P3QEIVO
static immutable AUW = KeyPair(PublicKey([193, 75, 107, 80, 146, 49, 119, 90, 111, 219, 77, 11, 50, 174, 228, 46, 173, 212, 14, 61, 75, 15, 30, 190, 95, 130, 136, 73, 226, 243, 247, 2]), SecretKey([224, 168, 227, 124, 166, 191, 158, 123, 19, 60, 0, 19, 54, 154, 7, 33, 135, 56, 15, 42, 221, 220, 150, 40, 182, 43, 192, 152, 133, 238, 245, 107]), Seed([89, 232, 62, 132, 100, 100, 49, 28, 14, 44, 73, 239, 192, 96, 214, 99, 18, 47, 184, 120, 116, 94, 191, 239, 243, 132, 122, 244, 58, 13, 175, 98]));
/// AUX: GDAUX22AVMC46CGNAD5H4FKSQNMXAH5PS25FHOBHFCEU7QJT4BGQUPUB
static immutable AUX = KeyPair(PublicKey([193, 75, 235, 64, 171, 5, 207, 8, 205, 0, 250, 126, 21, 82, 131, 89, 112, 31, 175, 150, 186, 83, 184, 39, 40, 137, 79, 193, 51, 224, 77, 10]), SecretKey([216, 133, 34, 141, 99, 61, 3, 28, 145, 25, 22, 236, 113, 125, 28, 223, 84, 175, 71, 219, 55, 100, 46, 97, 52, 222, 142, 247, 56, 178, 184, 89]), Seed([117, 151, 39, 235, 15, 75, 20, 208, 166, 185, 90, 127, 141, 175, 86, 30, 210, 103, 121, 230, 134, 244, 28, 146, 14, 154, 157, 45, 200, 177, 253, 223]));
/// AUY: GDAUY2263GBH3BMGTTHTPOSHW3GKFOK7BGAQ777UQT2BRZGQZR2BLAP7
static immutable AUY = KeyPair(PublicKey([193, 76, 107, 94, 217, 130, 125, 133, 134, 156, 207, 55, 186, 71, 182, 204, 162, 185, 95, 9, 129, 15, 255, 244, 132, 244, 24, 228, 208, 204, 116, 21]), SecretKey([104, 245, 36, 98, 23, 253, 3, 112, 214, 100, 228, 212, 90, 147, 231, 115, 75, 170, 142, 138, 71, 42, 36, 112, 173, 77, 230, 18, 225, 170, 228, 78]), Seed([108, 167, 241, 121, 65, 149, 165, 2, 25, 127, 77, 6, 11, 79, 77, 127, 55, 252, 31, 16, 109, 108, 237, 152, 135, 14, 26, 101, 47, 211, 177, 41]));
/// AUZ: GDAUZ22T6V4NCJFXZLL4XWDEP7YAFTELRR27T624YPFO6XLRNZ5GT63U
static immutable AUZ = KeyPair(PublicKey([193, 76, 235, 83, 245, 120, 209, 36, 183, 202, 215, 203, 216, 100, 127, 240, 2, 204, 139, 140, 117, 249, 251, 92, 195, 202, 239, 93, 113, 110, 122, 105]), SecretKey([96, 14, 223, 229, 217, 57, 0, 169, 214, 213, 127, 133, 138, 93, 194, 169, 218, 122, 168, 196, 74, 74, 2, 84, 126, 53, 179, 239, 71, 187, 149, 125]), Seed([3, 160, 206, 226, 26, 6, 54, 53, 108, 231, 121, 74, 64, 205, 230, 190, 67, 202, 178, 101, 165, 142, 178, 102, 83, 187, 73, 103, 128, 170, 76, 50]));
/// AVA: GDAVA22EH4IX6ILXHB5I53X32FEU4G6GICN7R6FQKVEY3NCC6JT44M55
static immutable AVA = KeyPair(PublicKey([193, 80, 107, 68, 63, 17, 127, 33, 119, 56, 122, 142, 238, 251, 209, 73, 78, 27, 198, 64, 155, 248, 248, 176, 85, 73, 141, 180, 66, 242, 103, 206]), SecretKey([112, 0, 44, 232, 51, 69, 230, 83, 92, 155, 14, 152, 10, 200, 58, 194, 97, 87, 124, 189, 247, 207, 122, 59, 83, 85, 212, 165, 34, 105, 92, 123]), Seed([236, 62, 137, 133, 85, 160, 65, 236, 135, 2, 95, 110, 219, 106, 69, 182, 79, 138, 108, 98, 135, 254, 112, 72, 15, 95, 87, 119, 240, 209, 52, 22]));
/// AVB: GDAVB22PMLKO2EIG6UJ5KN2H7ZGTUODQXHPD3F7DL57SIVBZFVFGFXZO
static immutable AVB = KeyPair(PublicKey([193, 80, 235, 79, 98, 212, 237, 17, 6, 245, 19, 213, 55, 71, 254, 77, 58, 56, 112, 185, 222, 61, 151, 227, 95, 127, 36, 84, 57, 45, 74, 98]), SecretKey([24, 69, 34, 60, 20, 129, 123, 110, 204, 8, 196, 169, 142, 101, 49, 171, 99, 184, 63, 44, 186, 73, 142, 111, 91, 234, 150, 32, 191, 155, 83, 104]), Seed([98, 101, 143, 17, 200, 56, 82, 16, 239, 254, 125, 71, 21, 184, 242, 130, 173, 238, 191, 184, 165, 252, 37, 49, 181, 193, 185, 169, 147, 190, 0, 8]));
/// AVC: GDAVC22ONUAFV43ALEMCNAWKLCO4RBNNY6DCYDE2A2MIZ2HCTR5TVYAX
static immutable AVC = KeyPair(PublicKey([193, 81, 107, 78, 109, 0, 90, 243, 96, 89, 24, 38, 130, 202, 88, 157, 200, 133, 173, 199, 134, 44, 12, 154, 6, 152, 140, 232, 226, 156, 123, 58]), SecretKey([136, 128, 125, 73, 8, 234, 44, 71, 236, 245, 85, 189, 71, 218, 255, 33, 0, 141, 186, 179, 196, 150, 73, 192, 74, 2, 133, 97, 155, 116, 100, 95]), Seed([252, 79, 16, 11, 228, 250, 60, 194, 4, 183, 4, 48, 37, 64, 68, 12, 12, 194, 6, 54, 113, 223, 36, 66, 108, 57, 57, 14, 70, 8, 177, 112]));
/// AVD: GDAVD22PTNKXAZDKJSYAPO2BNLFEUFB5HBPCX5HJZXGWS3WCAWYEJK6E
static immutable AVD = KeyPair(PublicKey([193, 81, 235, 79, 155, 85, 112, 100, 106, 76, 176, 7, 187, 65, 106, 202, 74, 20, 61, 56, 94, 43, 244, 233, 205, 205, 105, 110, 194, 5, 176, 68]), SecretKey([24, 176, 84, 202, 197, 172, 252, 88, 116, 249, 70, 90, 96, 200, 70, 253, 158, 137, 17, 78, 171, 187, 238, 61, 241, 24, 65, 27, 181, 231, 158, 97]), Seed([116, 252, 78, 85, 72, 215, 255, 150, 127, 171, 47, 137, 25, 192, 146, 89, 3, 4, 222, 186, 192, 31, 138, 231, 229, 138, 43, 53, 214, 246, 10, 75]));
/// AVE: GDAVE22C2IMIXNTEAQAKBGRC2LUWLNN2QMXSBKUFNRSTIZOEQDNAL3NH
static immutable AVE = KeyPair(PublicKey([193, 82, 107, 66, 210, 24, 139, 182, 100, 4, 0, 160, 154, 34, 210, 233, 101, 181, 186, 131, 47, 32, 170, 133, 108, 101, 52, 101, 196, 128, 218, 5]), SecretKey([56, 134, 162, 232, 55, 112, 156, 47, 119, 99, 104, 48, 145, 136, 3, 135, 127, 241, 83, 62, 82, 122, 225, 89, 207, 235, 95, 238, 141, 22, 247, 93]), Seed([65, 168, 57, 2, 25, 235, 159, 173, 243, 238, 7, 106, 94, 242, 239, 250, 107, 87, 126, 242, 249, 138, 30, 219, 97, 236, 62, 228, 81, 182, 245, 10]));
/// AVF: GDAVF22QDRBG6AARJ6TOJBKN5VRUFWRN3XGJRW6PTY2BEXNFI5RE5IKW
static immutable AVF = KeyPair(PublicKey([193, 82, 235, 80, 28, 66, 111, 0, 17, 79, 166, 228, 133, 77, 237, 99, 66, 218, 45, 221, 204, 152, 219, 207, 158, 52, 18, 93, 165, 71, 98, 78]), SecretKey([160, 54, 95, 151, 18, 149, 140, 115, 251, 145, 167, 98, 246, 124, 248, 100, 204, 30, 144, 53, 145, 193, 6, 133, 171, 218, 59, 212, 212, 104, 27, 122]), Seed([244, 58, 40, 15, 103, 142, 225, 251, 234, 161, 103, 124, 12, 103, 220, 50, 222, 150, 189, 153, 114, 227, 77, 164, 202, 152, 67, 152, 237, 50, 22, 46]));
/// AVG: GDAVG223GAROYA6PYTEXADEYYPTP3JPIWVVOBCWLWWR2XHOHZSDWINFI
static immutable AVG = KeyPair(PublicKey([193, 83, 107, 91, 48, 34, 236, 3, 207, 196, 201, 112, 12, 152, 195, 230, 253, 165, 232, 181, 106, 224, 138, 203, 181, 163, 171, 157, 199, 204, 135, 100]), SecretKey([48, 46, 113, 96, 110, 70, 178, 209, 66, 92, 14, 246, 113, 152, 222, 191, 80, 101, 8, 156, 134, 12, 165, 25, 25, 161, 48, 29, 62, 66, 129, 117]), Seed([73, 174, 132, 243, 163, 98, 194, 52, 206, 141, 246, 223, 113, 217, 30, 199, 138, 244, 3, 152, 5, 244, 125, 1, 157, 219, 2, 186, 228, 19, 88, 238]));
/// AVH: GDAVH22ZYS5P2KOE7W4NCDDKPBQUMBVDISAPT2U5HYI2OJT3Y3NCZJ33
static immutable AVH = KeyPair(PublicKey([193, 83, 235, 89, 196, 186, 253, 41, 196, 253, 184, 209, 12, 106, 120, 97, 70, 6, 163, 68, 128, 249, 234, 157, 62, 17, 167, 38, 123, 198, 218, 44]), SecretKey([208, 104, 191, 224, 189, 94, 153, 44, 130, 44, 106, 193, 243, 113, 237, 80, 185, 63, 108, 59, 17, 239, 18, 81, 79, 234, 196, 131, 41, 170, 43, 66]), Seed([136, 107, 49, 131, 218, 4, 247, 35, 177, 76, 100, 246, 95, 95, 74, 119, 104, 37, 39, 143, 238, 119, 130, 125, 90, 39, 117, 233, 21, 57, 71, 157]));
/// AVI: GDAVI22UD2BFF4SWE5Y6RWAO2XLITMG46T6IBNLASF2HH3YKLDARATEC
static immutable AVI = KeyPair(PublicKey([193, 84, 107, 84, 30, 130, 82, 242, 86, 39, 113, 232, 216, 14, 213, 214, 137, 176, 220, 244, 252, 128, 181, 96, 145, 116, 115, 239, 10, 88, 193, 16]), SecretKey([168, 21, 251, 79, 92, 238, 120, 89, 18, 172, 232, 220, 98, 178, 103, 33, 142, 152, 9, 5, 245, 18, 140, 193, 7, 53, 49, 20, 178, 148, 62, 88]), Seed([31, 102, 114, 92, 31, 236, 106, 216, 158, 205, 146, 68, 195, 55, 189, 143, 49, 163, 19, 100, 248, 45, 105, 27, 33, 102, 20, 73, 5, 91, 12, 249]));
/// AVJ: GDAVJ22KYRMX4BLSXZYLRGDKNARJWZYR2NOAD7U3LBBXQFLYIZBFC4JB
static immutable AVJ = KeyPair(PublicKey([193, 84, 235, 74, 196, 89, 126, 5, 114, 190, 112, 184, 152, 106, 104, 34, 155, 103, 17, 211, 92, 1, 254, 155, 88, 67, 120, 21, 120, 70, 66, 81]), SecretKey([184, 191, 150, 105, 129, 196, 68, 235, 22, 52, 133, 167, 227, 153, 208, 206, 10, 182, 50, 31, 60, 40, 126, 157, 36, 242, 55, 240, 232, 182, 62, 88]), Seed([209, 205, 88, 135, 223, 151, 133, 128, 222, 45, 65, 185, 110, 107, 236, 7, 23, 96, 33, 74, 187, 164, 155, 217, 234, 154, 163, 35, 106, 248, 78, 116]));
/// AVK: GDAVK22X23Y6BPJ2I5UJGFLHROXBM5F4UWUGKCFAJSVKMDAHHF7HTA47
static immutable AVK = KeyPair(PublicKey([193, 85, 107, 87, 214, 241, 224, 189, 58, 71, 104, 147, 21, 103, 139, 174, 22, 116, 188, 165, 168, 101, 8, 160, 76, 170, 166, 12, 7, 57, 126, 121]), SecretKey([136, 157, 158, 181, 185, 183, 7, 65, 49, 134, 153, 126, 203, 153, 110, 29, 74, 156, 244, 215, 251, 215, 98, 198, 2, 18, 4, 62, 69, 14, 49, 79]), Seed([148, 104, 117, 231, 25, 126, 91, 235, 155, 182, 210, 110, 104, 94, 124, 242, 20, 119, 10, 129, 63, 118, 162, 196, 171, 95, 164, 235, 127, 45, 33, 188]));
/// AVL: GDAVL22YLJSQUEPSZN3N2NLVYWXF6ZFWTLQHBS7OCEHQPWE4FVTV5KAF
static immutable AVL = KeyPair(PublicKey([193, 85, 235, 88, 90, 101, 10, 17, 242, 203, 118, 221, 53, 117, 197, 174, 95, 100, 182, 154, 224, 112, 203, 238, 17, 15, 7, 216, 156, 45, 103, 94]), SecretKey([240, 165, 75, 51, 75, 22, 6, 160, 162, 32, 93, 88, 66, 104, 23, 100, 38, 143, 168, 11, 149, 4, 131, 31, 46, 176, 132, 203, 150, 226, 95, 87]), Seed([155, 250, 57, 96, 19, 7, 161, 68, 48, 55, 26, 47, 207, 138, 229, 168, 64, 79, 53, 180, 254, 50, 2, 109, 251, 45, 59, 104, 107, 155, 180, 224]));
/// AVM: GDAVM22E7WEMA2INRJ3FD4EZUZ777PRCJ5O6FJSUUK7XDOTTK7WIJJKR
static immutable AVM = KeyPair(PublicKey([193, 86, 107, 68, 253, 136, 192, 105, 13, 138, 118, 81, 240, 153, 166, 127, 255, 190, 34, 79, 93, 226, 166, 84, 162, 191, 113, 186, 115, 87, 236, 132]), SecretKey([104, 169, 132, 17, 208, 21, 221, 118, 63, 135, 219, 18, 61, 250, 219, 210, 79, 43, 208, 51, 105, 147, 141, 188, 72, 156, 169, 127, 61, 164, 249, 93]), Seed([150, 30, 178, 211, 216, 218, 25, 92, 180, 87, 200, 79, 184, 42, 244, 131, 50, 193, 94, 69, 159, 132, 227, 163, 78, 101, 255, 62, 138, 110, 143, 238]));
/// AVN: GDAVN22YBJWF5HEIB5HBYMPUAXCUPCCUJW7BFF7IIFADWWL3M54UKJOR
static immutable AVN = KeyPair(PublicKey([193, 86, 235, 88, 10, 108, 94, 156, 136, 15, 78, 28, 49, 244, 5, 197, 71, 136, 84, 77, 190, 18, 151, 232, 65, 64, 59, 89, 123, 103, 121, 69]), SecretKey([40, 104, 170, 14, 231, 180, 56, 9, 226, 162, 9, 214, 164, 111, 193, 187, 173, 240, 220, 141, 127, 185, 172, 131, 123, 179, 20, 193, 134, 174, 192, 101]), Seed([122, 169, 42, 140, 79, 71, 156, 69, 206, 143, 157, 181, 15, 91, 210, 238, 22, 17, 157, 162, 62, 143, 126, 37, 162, 222, 212, 90, 115, 218, 205, 140]));
/// AVO: GDAVO22QY6H3WVFVVZJJPLIU4LWTGHNFBEJXRL75RUWYFVAXAV5T5BTW
static immutable AVO = KeyPair(PublicKey([193, 87, 107, 80, 199, 143, 187, 84, 181, 174, 82, 151, 173, 20, 226, 237, 51, 29, 165, 9, 19, 120, 175, 253, 141, 45, 130, 212, 23, 5, 123, 62]), SecretKey([120, 129, 91, 208, 255, 62, 239, 158, 186, 78, 233, 192, 167, 239, 193, 153, 205, 74, 109, 222, 32, 254, 0, 104, 206, 121, 128, 252, 41, 158, 29, 113]), Seed([23, 116, 191, 99, 210, 167, 60, 78, 169, 85, 15, 229, 237, 143, 202, 92, 10, 225, 64, 69, 145, 243, 102, 4, 187, 198, 90, 116, 107, 30, 6, 90]));
/// AVP: GDAVP22C36XRKKR7EW4TFPR22JRNC4A2M7J3YYD2VTOCNCGJ2D3SCN4B
static immutable AVP = KeyPair(PublicKey([193, 87, 235, 66, 223, 175, 21, 42, 63, 37, 185, 50, 190, 58, 210, 98, 209, 112, 26, 103, 211, 188, 96, 122, 172, 220, 38, 136, 201, 208, 247, 33]), SecretKey([216, 110, 67, 73, 65, 35, 25, 143, 233, 76, 146, 136, 201, 160, 221, 36, 164, 206, 235, 220, 50, 43, 129, 49, 226, 125, 151, 200, 211, 55, 186, 64]), Seed([39, 103, 34, 43, 43, 111, 62, 226, 16, 200, 246, 46, 244, 110, 65, 214, 10, 180, 33, 121, 47, 139, 185, 216, 61, 9, 231, 107, 28, 74, 95, 233]));
/// AVQ: GDAVQ22RTMOVSBCXDAFNKNAXXZIFIXM2CVCNUYHUJCCYCCSIGRJVPDC7
static immutable AVQ = KeyPair(PublicKey([193, 88, 107, 81, 155, 29, 89, 4, 87, 24, 10, 213, 52, 23, 190, 80, 84, 93, 154, 21, 68, 218, 96, 244, 72, 133, 129, 10, 72, 52, 83, 87]), SecretKey([224, 222, 50, 8, 76, 93, 136, 244, 178, 24, 85, 113, 4, 206, 235, 195, 175, 50, 75, 36, 216, 197, 250, 68, 123, 91, 115, 62, 109, 112, 33, 64]), Seed([166, 106, 171, 218, 72, 58, 6, 0, 75, 179, 140, 34, 134, 127, 202, 214, 212, 204, 251, 16, 104, 127, 104, 20, 129, 241, 169, 169, 249, 159, 222, 45]));
/// AVR: GDAVR22M46TXPZD2ARVUFU4FJPF6Q4MISLLPRXFYXWJXDBXVIWQ3FVQS
static immutable AVR = KeyPair(PublicKey([193, 88, 235, 76, 231, 167, 119, 228, 122, 4, 107, 66, 211, 133, 75, 203, 232, 113, 136, 146, 214, 248, 220, 184, 189, 147, 113, 134, 245, 69, 161, 178]), SecretKey([80, 175, 254, 253, 74, 255, 143, 68, 137, 163, 248, 248, 246, 138, 81, 254, 18, 214, 142, 41, 83, 99, 122, 81, 57, 23, 145, 166, 74, 214, 23, 106]), Seed([26, 72, 215, 235, 225, 243, 239, 53, 231, 238, 4, 164, 184, 165, 68, 181, 240, 211, 94, 162, 244, 130, 187, 133, 219, 113, 203, 25, 241, 14, 96, 40]));
/// AVS: GDAVS2256PTGYG2G2JNX54I36H46STMAYNDZRVWNCYFT5L3WNNIIY367
static immutable AVS = KeyPair(PublicKey([193, 89, 107, 93, 243, 230, 108, 27, 70, 210, 91, 126, 241, 27, 241, 249, 233, 77, 128, 195, 71, 152, 214, 205, 22, 11, 62, 175, 118, 107, 80, 140]), SecretKey([224, 241, 141, 169, 68, 19, 10, 104, 55, 189, 49, 66, 248, 116, 88, 164, 193, 72, 114, 183, 236, 18, 136, 248, 217, 27, 9, 86, 175, 5, 69, 113]), Seed([225, 129, 181, 175, 114, 6, 240, 20, 226, 47, 217, 127, 127, 137, 193, 64, 235, 69, 33, 173, 79, 24, 185, 197, 187, 18, 7, 5, 1, 227, 13, 61]));
/// AVT: GDAVT22MSWGPKASU47QS2HBT7GUEBB2C4CNN4QOA3QNTS2YLX2MHECCB
static immutable AVT = KeyPair(PublicKey([193, 89, 235, 76, 149, 140, 245, 2, 84, 231, 225, 45, 28, 51, 249, 168, 64, 135, 66, 224, 154, 222, 65, 192, 220, 27, 57, 107, 11, 190, 152, 114]), SecretKey([72, 226, 211, 72, 202, 177, 235, 90, 188, 208, 203, 176, 150, 161, 127, 152, 219, 43, 2, 17, 9, 236, 158, 129, 39, 245, 151, 77, 1, 160, 19, 114]), Seed([51, 16, 35, 201, 89, 242, 57, 84, 105, 82, 195, 86, 133, 21, 228, 254, 106, 210, 212, 218, 115, 30, 82, 181, 225, 98, 3, 43, 164, 181, 134, 11]));
/// AVU: GDAVU22HEKDXABXJDWVZBIPJQMET2YC4MM6WON3I43CSBQ6QSC4P7LEE
static immutable AVU = KeyPair(PublicKey([193, 90, 107, 71, 34, 135, 112, 6, 233, 29, 171, 144, 161, 233, 131, 9, 61, 96, 92, 99, 61, 103, 55, 104, 230, 197, 32, 195, 208, 144, 184, 255]), SecretKey([8, 25, 111, 12, 165, 184, 4, 103, 30, 97, 18, 186, 20, 0, 39, 92, 177, 153, 61, 111, 2, 214, 238, 148, 199, 20, 40, 176, 123, 205, 123, 71]), Seed([110, 231, 43, 40, 190, 252, 30, 89, 25, 140, 37, 2, 92, 17, 158, 151, 154, 101, 64, 84, 185, 137, 92, 153, 233, 48, 172, 90, 87, 18, 254, 86]));
/// AVV: GDAVV22GMROCQBLZ6DUILYQW6LDTZJYYHB6LY4JLWARZVAQEJID3PQ73
static immutable AVV = KeyPair(PublicKey([193, 90, 235, 70, 100, 92, 40, 5, 121, 240, 232, 133, 226, 22, 242, 199, 60, 167, 24, 56, 124, 188, 113, 43, 176, 35, 154, 130, 4, 74, 7, 183]), SecretKey([104, 162, 120, 40, 57, 79, 105, 20, 154, 207, 117, 201, 163, 13, 147, 184, 220, 192, 30, 175, 154, 157, 20, 14, 149, 16, 173, 181, 156, 216, 128, 103]), Seed([111, 13, 137, 211, 55, 160, 49, 135, 205, 167, 19, 144, 173, 171, 87, 233, 115, 32, 73, 98, 124, 8, 62, 187, 232, 37, 105, 38, 46, 53, 18, 40]));
/// AVW: GDAVW22CE23VGDMXNLYWKR4CMBEHT2RHELVRDEIN6NHZXNDB3XVGESWQ
static immutable AVW = KeyPair(PublicKey([193, 91, 107, 66, 38, 183, 83, 13, 151, 106, 241, 101, 71, 130, 96, 72, 121, 234, 39, 34, 235, 17, 145, 13, 243, 79, 155, 180, 97, 221, 234, 98]), SecretKey([248, 214, 172, 8, 49, 149, 42, 190, 95, 133, 252, 222, 8, 54, 138, 92, 183, 146, 159, 60, 175, 157, 126, 28, 76, 13, 71, 24, 106, 136, 153, 126]), Seed([190, 82, 196, 83, 98, 34, 166, 197, 47, 104, 254, 201, 74, 184, 255, 71, 129, 138, 37, 218, 101, 186, 133, 198, 138, 68, 156, 192, 112, 158, 202, 190]));
/// AVX: GDAVX223NKPYXQML4ALQHW2RXGV3D4H5BT5Q2H2RDXL3ID7TCVADWCDI
static immutable AVX = KeyPair(PublicKey([193, 91, 235, 91, 106, 159, 139, 193, 139, 224, 23, 3, 219, 81, 185, 171, 177, 240, 253, 12, 251, 13, 31, 81, 29, 215, 180, 15, 243, 21, 64, 59]), SecretKey([224, 101, 156, 149, 231, 160, 137, 20, 25, 114, 144, 73, 93, 219, 170, 30, 166, 57, 57, 86, 235, 233, 115, 160, 26, 151, 173, 131, 173, 44, 98, 119]), Seed([40, 127, 108, 133, 228, 219, 150, 91, 252, 217, 91, 22, 59, 194, 61, 78, 46, 168, 199, 199, 63, 89, 11, 85, 113, 102, 11, 29, 216, 88, 254, 85]));
/// AVY: GDAVY22HHEX7G5PW3FIBXYCSXDKYPCTDEG5WN32KM3IRPGDEXGPMUUEP
static immutable AVY = KeyPair(PublicKey([193, 92, 107, 71, 57, 47, 243, 117, 246, 217, 80, 27, 224, 82, 184, 213, 135, 138, 99, 33, 187, 102, 239, 74, 102, 209, 23, 152, 100, 185, 158, 202]), SecretKey([16, 157, 230, 205, 122, 178, 46, 171, 118, 112, 173, 23, 92, 62, 210, 160, 210, 229, 201, 212, 64, 113, 234, 154, 12, 143, 35, 71, 16, 213, 222, 81]), Seed([75, 171, 79, 255, 106, 17, 53, 60, 131, 180, 85, 228, 219, 165, 18, 92, 155, 103, 36, 14, 57, 171, 158, 19, 110, 182, 182, 198, 249, 29, 227, 74]));
/// AVZ: GDAVZ22VVF4F6D6UZB3WF26ZRTD62R2XYUTZEBRM4CTHQE6CBQTDQ45C
static immutable AVZ = KeyPair(PublicKey([193, 92, 235, 85, 169, 120, 95, 15, 212, 200, 119, 98, 235, 217, 140, 199, 237, 71, 87, 197, 39, 146, 6, 44, 224, 166, 120, 19, 194, 12, 38, 56]), SecretKey([176, 18, 129, 55, 106, 231, 142, 119, 228, 195, 3, 176, 20, 248, 153, 92, 169, 10, 242, 5, 78, 195, 53, 197, 16, 43, 84, 222, 72, 43, 173, 98]), Seed([5, 186, 18, 135, 153, 207, 29, 197, 35, 185, 218, 153, 39, 169, 5, 251, 81, 8, 214, 169, 186, 6, 154, 254, 254, 81, 192, 162, 23, 214, 56, 131]));
/// AWA: GDAWA22VXF4BUBBISOPQT7472LZTACMFBX4TV4TD4OD2NCRPJVSXCPYZ
static immutable AWA = KeyPair(PublicKey([193, 96, 107, 85, 185, 120, 26, 4, 40, 147, 159, 9, 255, 159, 210, 243, 48, 9, 133, 13, 249, 58, 242, 99, 227, 135, 166, 138, 47, 77, 101, 113]), SecretKey([96, 172, 36, 37, 15, 209, 21, 158, 27, 129, 106, 238, 118, 129, 93, 142, 113, 203, 39, 168, 176, 150, 175, 10, 125, 78, 25, 253, 11, 182, 109, 90]), Seed([27, 255, 55, 63, 6, 215, 171, 181, 178, 48, 95, 147, 74, 221, 207, 214, 225, 117, 125, 224, 192, 33, 77, 242, 155, 238, 69, 87, 78, 154, 70, 153]));
/// AWB: GDAWB22G3VNDJGMXIZSIQR3QYZ2OQKPH7OLJ4PEJFOVXCLRZAGIDJH72
static immutable AWB = KeyPair(PublicKey([193, 96, 235, 70, 221, 90, 52, 153, 151, 70, 100, 136, 71, 112, 198, 116, 232, 41, 231, 251, 150, 158, 60, 137, 43, 171, 113, 46, 57, 1, 144, 52]), SecretKey([216, 168, 120, 19, 213, 89, 116, 253, 190, 128, 36, 234, 176, 143, 230, 0, 254, 22, 88, 75, 79, 34, 119, 145, 1, 166, 226, 227, 161, 122, 70, 105]), Seed([163, 66, 133, 92, 48, 34, 216, 173, 237, 48, 124, 9, 145, 69, 249, 129, 167, 136, 66, 77, 237, 147, 77, 2, 124, 129, 115, 122, 79, 213, 137, 157]));
/// AWC: GDAWC22TCPUQSIKKSBMP5QBE3MRRTLAQ7QUG7QLXQV7PBMJJN4VOXDZL
static immutable AWC = KeyPair(PublicKey([193, 97, 107, 83, 19, 233, 9, 33, 74, 144, 88, 254, 192, 36, 219, 35, 25, 172, 16, 252, 40, 111, 193, 119, 133, 126, 240, 177, 41, 111, 42, 235]), SecretKey([104, 129, 90, 189, 175, 1, 110, 185, 88, 125, 213, 83, 23, 39, 75, 190, 199, 133, 213, 46, 234, 135, 143, 181, 247, 241, 125, 89, 68, 77, 75, 93]), Seed([139, 249, 249, 252, 213, 122, 220, 164, 198, 23, 114, 130, 137, 115, 84, 146, 157, 184, 34, 150, 89, 165, 175, 5, 150, 156, 216, 221, 120, 232, 40, 199]));
/// AWD: GDAWD22DN7K6B3F6FXSC66SNOGEMM6M5V4MRV7NBUZQWZMQGMCYBIE3V
static immutable AWD = KeyPair(PublicKey([193, 97, 235, 67, 111, 213, 224, 236, 190, 45, 228, 47, 122, 77, 113, 136, 198, 121, 157, 175, 25, 26, 253, 161, 166, 97, 108, 178, 6, 96, 176, 20]), SecretKey([80, 58, 205, 140, 109, 185, 73, 8, 69, 54, 45, 186, 222, 165, 178, 89, 219, 158, 129, 80, 100, 174, 214, 4, 3, 208, 24, 104, 59, 76, 245, 68]), Seed([199, 32, 234, 101, 72, 101, 101, 0, 239, 166, 25, 88, 41, 129, 172, 251, 168, 171, 208, 131, 128, 123, 246, 79, 178, 126, 210, 241, 237, 160, 107, 92]));
/// AWE: GDAWE22RWGVPLFA2PCXEVLARO2PMJ2RWJUC6BXKBHRBX6B7OU7ZS37N5
static immutable AWE = KeyPair(PublicKey([193, 98, 107, 81, 177, 170, 245, 148, 26, 120, 174, 74, 172, 17, 118, 158, 196, 234, 54, 77, 5, 224, 221, 65, 60, 67, 127, 7, 238, 167, 243, 45]), SecretKey([72, 189, 62, 238, 139, 164, 129, 22, 205, 88, 94, 125, 71, 43, 63, 61, 59, 210, 244, 184, 194, 44, 130, 217, 78, 216, 254, 81, 187, 202, 177, 100]), Seed([110, 30, 220, 125, 77, 33, 156, 27, 97, 231, 202, 181, 181, 9, 234, 138, 92, 205, 158, 94, 213, 192, 167, 52, 4, 128, 66, 3, 104, 1, 129, 0]));
/// AWF: GDAWF22VIU3L53BM273TTKS7RWPDJUKP2Q4NGEBRO44DBVGVSDDLDSXR
static immutable AWF = KeyPair(PublicKey([193, 98, 235, 85, 69, 54, 190, 236, 44, 215, 247, 57, 170, 95, 141, 158, 52, 209, 79, 212, 56, 211, 16, 49, 119, 56, 48, 212, 213, 144, 198, 177]), SecretKey([64, 111, 63, 141, 75, 54, 141, 251, 151, 43, 218, 16, 116, 195, 159, 126, 73, 228, 232, 109, 244, 71, 29, 170, 195, 255, 93, 205, 35, 127, 9, 106]), Seed([99, 227, 15, 122, 251, 59, 157, 186, 95, 37, 21, 53, 89, 229, 156, 218, 68, 137, 88, 125, 175, 216, 210, 218, 186, 14, 100, 26, 64, 253, 73, 239]));
/// AWG: GDAWG2276IE5NK76P7KIEXDAQSVMJLWYBZ4KTNTQVHYN2KM54UWDHTMF
static immutable AWG = KeyPair(PublicKey([193, 99, 107, 95, 242, 9, 214, 171, 254, 127, 212, 130, 92, 96, 132, 170, 196, 174, 216, 14, 120, 169, 182, 112, 169, 240, 221, 41, 157, 229, 44, 51]), SecretKey([32, 85, 243, 168, 101, 23, 33, 58, 192, 52, 95, 12, 26, 108, 43, 7, 79, 224, 46, 151, 1, 229, 5, 110, 72, 109, 138, 90, 250, 45, 78, 71]), Seed([8, 181, 252, 91, 78, 63, 71, 99, 51, 109, 252, 170, 109, 138, 89, 33, 170, 253, 182, 235, 224, 184, 147, 4, 194, 123, 206, 163, 137, 123, 162, 85]));
/// AWH: GDAWH22HY4XDRXBMHAS6C2N4DJBEU3OXN75O7FNTR7SXFSVO6LJBDKCZ
static immutable AWH = KeyPair(PublicKey([193, 99, 235, 71, 199, 46, 56, 220, 44, 56, 37, 225, 105, 188, 26, 66, 74, 109, 215, 111, 250, 239, 149, 179, 143, 229, 114, 202, 174, 242, 210, 17]), SecretKey([0, 105, 12, 209, 248, 170, 66, 206, 134, 200, 197, 61, 174, 206, 173, 214, 14, 219, 40, 241, 38, 6, 211, 88, 19, 153, 120, 101, 196, 135, 87, 65]), Seed([132, 47, 86, 178, 113, 222, 79, 232, 70, 28, 124, 204, 163, 218, 208, 189, 249, 17, 89, 54, 20, 6, 18, 231, 182, 18, 184, 247, 176, 6, 157, 251]));
/// AWI: GDAWI225IUPUQVKL6HPSY5NBXYYUF24PUWK4ERSNZ73BKER5YHODUCEC
static immutable AWI = KeyPair(PublicKey([193, 100, 107, 93, 69, 31, 72, 85, 75, 241, 223, 44, 117, 161, 190, 49, 66, 235, 143, 165, 149, 194, 70, 77, 207, 246, 21, 18, 61, 193, 220, 58]), SecretKey([152, 66, 223, 150, 53, 218, 2, 181, 80, 233, 167, 200, 70, 28, 64, 69, 66, 211, 18, 95, 253, 98, 12, 126, 40, 215, 97, 178, 179, 82, 116, 70]), Seed([76, 131, 110, 201, 164, 20, 207, 17, 170, 97, 143, 6, 93, 76, 149, 56, 179, 11, 6, 44, 198, 21, 136, 127, 185, 148, 212, 136, 217, 16, 215, 247]));
/// AWJ: GDAWJ22Y7S2AWVEQFNPOORTLTAF2YUQD3YLWBQVONEHBORTAY6HCNPJS
static immutable AWJ = KeyPair(PublicKey([193, 100, 235, 88, 252, 180, 11, 84, 144, 43, 94, 231, 70, 107, 152, 11, 172, 82, 3, 222, 23, 96, 194, 174, 105, 14, 23, 70, 96, 199, 142, 38]), SecretKey([200, 125, 161, 106, 238, 209, 99, 192, 254, 194, 121, 86, 182, 111, 253, 14, 124, 41, 73, 214, 249, 19, 52, 232, 70, 235, 230, 94, 234, 134, 223, 64]), Seed([117, 223, 63, 215, 10, 97, 76, 159, 39, 250, 25, 246, 62, 198, 36, 21, 36, 94, 7, 158, 232, 190, 206, 219, 245, 140, 175, 92, 8, 108, 45, 57]));
/// AWK: GDAWK22VTIQB7PRJUZR35B2FE3KORPL37SDXDO2Y4DZ2SNYNWAN6IVZU
static immutable AWK = KeyPair(PublicKey([193, 101, 107, 85, 154, 32, 31, 190, 41, 166, 99, 190, 135, 69, 38, 212, 232, 189, 123, 252, 135, 113, 187, 88, 224, 243, 169, 55, 13, 176, 27, 228]), SecretKey([192, 77, 22, 7, 196, 203, 8, 11, 229, 220, 143, 145, 239, 252, 167, 218, 134, 194, 134, 227, 67, 18, 110, 24, 93, 196, 136, 223, 165, 9, 192, 125]), Seed([95, 149, 220, 11, 143, 233, 100, 245, 160, 170, 240, 103, 219, 28, 255, 11, 118, 117, 120, 65, 191, 115, 192, 114, 114, 107, 94, 120, 246, 184, 193, 42]));
/// AWL: GDAWL22DNTD2JWEHSR253LDHWR3XN2YBMOYNPGJIXZUGSE57RFDGEXDX
static immutable AWL = KeyPair(PublicKey([193, 101, 235, 67, 108, 199, 164, 216, 135, 148, 117, 221, 172, 103, 180, 119, 118, 235, 1, 99, 176, 215, 153, 40, 190, 104, 105, 19, 191, 137, 70, 98]), SecretKey([24, 93, 14, 163, 157, 33, 105, 77, 17, 61, 33, 176, 237, 158, 167, 177, 138, 192, 250, 210, 164, 171, 231, 69, 193, 157, 99, 6, 27, 6, 70, 122]), Seed([174, 113, 0, 33, 167, 39, 8, 239, 48, 75, 103, 7, 114, 66, 81, 169, 62, 120, 150, 167, 207, 80, 92, 48, 46, 47, 4, 171, 103, 50, 112, 84]));
/// AWM: GDAWM22BKZL6B63GL5QZ3TCZS776O7B3UFALVGNTGLJPR4LTA2MJDK6L
static immutable AWM = KeyPair(PublicKey([193, 102, 107, 65, 86, 87, 224, 251, 102, 95, 97, 157, 204, 89, 151, 255, 231, 124, 59, 161, 64, 186, 153, 179, 50, 210, 248, 241, 115, 6, 152, 145]), SecretKey([64, 149, 184, 122, 14, 230, 135, 42, 243, 98, 49, 172, 111, 94, 161, 3, 19, 128, 50, 11, 112, 108, 166, 35, 191, 176, 95, 68, 252, 185, 217, 64]), Seed([7, 1, 60, 161, 32, 38, 216, 5, 86, 135, 74, 59, 106, 82, 234, 19, 182, 126, 24, 58, 19, 108, 33, 196, 250, 177, 199, 26, 23, 131, 232, 165]));
/// AWN: GDAWN22KUN4ZLKDQQQ3FV7CLG4TIREI7QPFSRVCOLECFG3SFMFTRHVQA
static immutable AWN = KeyPair(PublicKey([193, 102, 235, 74, 163, 121, 149, 168, 112, 132, 54, 90, 252, 75, 55, 38, 136, 145, 31, 131, 203, 40, 212, 78, 89, 4, 83, 110, 69, 97, 103, 19]), SecretKey([216, 212, 103, 85, 130, 82, 152, 125, 70, 170, 110, 246, 159, 82, 226, 36, 61, 77, 139, 222, 190, 189, 83, 124, 239, 58, 216, 146, 68, 167, 67, 101]), Seed([224, 214, 199, 49, 69, 39, 148, 115, 124, 253, 56, 49, 237, 6, 94, 137, 164, 109, 50, 62, 59, 175, 105, 186, 214, 145, 125, 114, 105, 199, 119, 21]));
/// AWO: GDAWO22KLMVLRTD5ZU7DILFUXPF2RM5FCZEBWBAWMFKG76MX7BUOYMGK
static immutable AWO = KeyPair(PublicKey([193, 103, 107, 74, 91, 42, 184, 204, 125, 205, 62, 52, 44, 180, 187, 203, 168, 179, 165, 22, 72, 27, 4, 22, 97, 84, 111, 249, 151, 248, 104, 236]), SecretKey([240, 237, 215, 171, 187, 214, 198, 8, 12, 91, 202, 0, 167, 124, 37, 34, 194, 197, 190, 76, 106, 166, 58, 51, 247, 34, 184, 12, 177, 238, 19, 65]), Seed([47, 143, 95, 116, 40, 223, 41, 210, 147, 196, 205, 43, 128, 243, 224, 111, 81, 239, 209, 139, 19, 201, 5, 174, 149, 236, 174, 133, 188, 27, 179, 215]));
/// AWP: GDAWP225Y2UNQ5XA5GOXO3G2GP7V3R6OUY7OS5N6JO252WVQRP73JELX
static immutable AWP = KeyPair(PublicKey([193, 103, 235, 93, 198, 168, 216, 118, 224, 233, 157, 119, 108, 218, 51, 255, 93, 199, 206, 166, 62, 233, 117, 190, 75, 181, 221, 90, 176, 139, 255, 180]), SecretKey([232, 109, 243, 32, 111, 213, 240, 224, 130, 248, 232, 12, 178, 252, 131, 227, 219, 91, 156, 13, 134, 234, 207, 63, 7, 250, 54, 54, 144, 254, 139, 69]), Seed([83, 152, 147, 7, 164, 213, 8, 44, 20, 192, 117, 16, 146, 109, 4, 63, 50, 53, 11, 117, 35, 42, 161, 151, 70, 212, 39, 103, 44, 136, 61, 41]));
/// AWQ: GDAWQ22ZZVB3X62LA75QLI6ZE23IFFPIGO6IXLBTKD5YKMB25WFK2PN7
static immutable AWQ = KeyPair(PublicKey([193, 104, 107, 89, 205, 67, 187, 251, 75, 7, 251, 5, 163, 217, 38, 182, 130, 149, 232, 51, 188, 139, 172, 51, 80, 251, 133, 48, 58, 237, 138, 173]), SecretKey([80, 96, 100, 2, 102, 56, 79, 123, 152, 173, 228, 160, 102, 187, 102, 173, 245, 113, 88, 228, 143, 108, 111, 55, 75, 206, 237, 96, 44, 130, 59, 117]), Seed([189, 51, 227, 109, 239, 135, 94, 154, 103, 94, 168, 198, 234, 232, 118, 207, 68, 125, 230, 41, 136, 33, 104, 239, 164, 156, 69, 168, 175, 31, 226, 213]));
/// AWR: GDAWR22LKP3UBAH575E5PZMVTVHOLYUFONZHMKFFRTDAZXGNWBWI3MTC
static immutable AWR = KeyPair(PublicKey([193, 104, 235, 75, 83, 247, 64, 128, 253, 255, 73, 215, 229, 149, 157, 78, 229, 226, 133, 115, 114, 118, 40, 165, 140, 198, 12, 220, 205, 176, 108, 141]), SecretKey([128, 80, 149, 230, 19, 31, 23, 19, 66, 80, 192, 68, 165, 102, 84, 167, 10, 249, 99, 60, 74, 2, 115, 212, 199, 14, 183, 192, 175, 88, 120, 92]), Seed([215, 100, 36, 245, 214, 117, 129, 173, 199, 189, 217, 185, 81, 0, 166, 43, 253, 240, 232, 74, 252, 229, 55, 117, 164, 191, 45, 11, 23, 172, 228, 152]));
/// AWS: GDAWS22AT5VJOHJYM7WY7HAUL2VDPCTXNTPAYYQPJTGRGAWXTHJYQVBG
static immutable AWS = KeyPair(PublicKey([193, 105, 107, 64, 159, 106, 151, 29, 56, 103, 237, 143, 156, 20, 94, 170, 55, 138, 119, 108, 222, 12, 98, 15, 76, 205, 19, 2, 215, 153, 211, 136]), SecretKey([72, 96, 6, 249, 216, 153, 178, 154, 181, 239, 27, 10, 127, 187, 202, 140, 40, 73, 197, 59, 31, 97, 4, 113, 55, 53, 21, 163, 144, 144, 83, 115]), Seed([100, 222, 109, 83, 163, 172, 81, 9, 54, 52, 151, 241, 41, 239, 123, 82, 39, 17, 58, 199, 30, 163, 115, 21, 53, 142, 116, 122, 190, 120, 206, 156]));
/// AWT: GDAWT22TAXJ5MBWEQTE7XWGQ6WJBGYYNESQ35F6VYUESZS22AL7L6LNW
static immutable AWT = KeyPair(PublicKey([193, 105, 235, 83, 5, 211, 214, 6, 196, 132, 201, 251, 216, 208, 245, 146, 19, 99, 13, 36, 161, 190, 151, 213, 197, 9, 44, 203, 90, 2, 254, 191]), SecretKey([0, 55, 153, 67, 17, 87, 255, 43, 153, 197, 121, 159, 41, 144, 162, 119, 161, 80, 213, 187, 97, 183, 103, 246, 212, 63, 116, 9, 55, 168, 40, 80]), Seed([253, 116, 7, 196, 237, 151, 171, 18, 178, 96, 225, 82, 83, 242, 6, 38, 100, 149, 30, 243, 71, 144, 237, 100, 199, 148, 189, 117, 194, 194, 219, 79]));
/// AWU: GDAWU22DFOVCI4EL2BEMG7OX23BLJKLAVAPFFGH2XTZ5JHTUXKPIKBSG
static immutable AWU = KeyPair(PublicKey([193, 106, 107, 67, 43, 170, 36, 112, 139, 208, 72, 195, 125, 215, 214, 194, 180, 169, 96, 168, 30, 82, 152, 250, 188, 243, 212, 158, 116, 186, 158, 133]), SecretKey([56, 39, 143, 42, 237, 222, 84, 53, 6, 53, 170, 208, 132, 18, 187, 40, 74, 184, 96, 237, 13, 166, 86, 15, 169, 71, 149, 23, 225, 173, 250, 121]), Seed([155, 211, 159, 95, 54, 66, 104, 150, 72, 227, 155, 127, 250, 168, 189, 219, 178, 101, 212, 101, 117, 164, 197, 246, 170, 7, 234, 140, 204, 157, 60, 144]));
/// AWV: GDAWV223GROKVIZ3P7YN43UAFMXR7ZJI5FY7J6J2JOTJG6RUC4CKZ7YN
static immutable AWV = KeyPair(PublicKey([193, 106, 235, 91, 52, 92, 170, 163, 59, 127, 240, 222, 110, 128, 43, 47, 31, 229, 40, 233, 113, 244, 249, 58, 75, 166, 147, 122, 52, 23, 4, 172]), SecretKey([240, 199, 88, 68, 238, 187, 11, 25, 206, 147, 151, 227, 254, 96, 113, 193, 189, 174, 19, 53, 179, 106, 70, 234, 208, 151, 142, 123, 234, 206, 54, 71]), Seed([15, 169, 202, 159, 7, 230, 8, 181, 233, 236, 50, 6, 108, 213, 138, 21, 198, 121, 217, 67, 194, 223, 45, 94, 48, 172, 15, 75, 106, 111, 9, 77]));
/// AWW: GDAWW22PXTFMMXJ5MESUETIYUJF4PNNGLRU4JTVDYBQCGZG7CEB4C7T3
static immutable AWW = KeyPair(PublicKey([193, 107, 107, 79, 188, 202, 198, 93, 61, 97, 37, 66, 77, 24, 162, 75, 199, 181, 166, 92, 105, 196, 206, 163, 192, 96, 35, 100, 223, 17, 3, 193]), SecretKey([184, 90, 127, 97, 170, 110, 177, 8, 17, 68, 138, 53, 183, 164, 161, 151, 85, 154, 233, 78, 16, 68, 157, 19, 237, 50, 90, 59, 110, 37, 28, 104]), Seed([121, 166, 42, 105, 3, 62, 248, 199, 171, 219, 115, 254, 245, 92, 109, 58, 15, 141, 154, 121, 45, 171, 217, 255, 85, 98, 209, 74, 208, 249, 246, 40]));
/// AWX: GDAWX22II44O7OJRBEOZV5MPDO2Z6KEUFCLG7TJQBOYFCAKZLROTP2US
static immutable AWX = KeyPair(PublicKey([193, 107, 235, 72, 71, 56, 239, 185, 49, 9, 29, 154, 245, 143, 27, 181, 159, 40, 148, 40, 150, 111, 205, 48, 11, 176, 81, 1, 89, 92, 93, 55]), SecretKey([24, 237, 201, 148, 159, 23, 222, 153, 14, 38, 150, 9, 207, 108, 0, 238, 190, 100, 206, 198, 218, 153, 224, 193, 80, 157, 129, 176, 217, 79, 144, 69]), Seed([164, 237, 187, 97, 153, 156, 202, 54, 155, 147, 220, 14, 84, 142, 122, 230, 109, 174, 104, 89, 40, 6, 161, 236, 119, 58, 12, 55, 103, 16, 78, 79]));
/// AWY: GDAWY22KR77RK2O6CQAGA5YDQQJMQIXNMFWJKLAF2VMH7WEVTTJHICN4
static immutable AWY = KeyPair(PublicKey([193, 108, 107, 74, 143, 255, 21, 105, 222, 20, 0, 96, 119, 3, 132, 18, 200, 34, 237, 97, 108, 149, 44, 5, 213, 88, 127, 216, 149, 156, 210, 116]), SecretKey([16, 14, 69, 99, 225, 210, 70, 77, 161, 172, 85, 47, 14, 150, 126, 159, 176, 234, 100, 52, 225, 113, 130, 179, 71, 57, 11, 15, 78, 115, 152, 126]), Seed([185, 226, 106, 249, 97, 48, 228, 8, 248, 109, 196, 87, 134, 0, 188, 65, 75, 42, 169, 255, 6, 175, 87, 197, 89, 2, 161, 249, 28, 181, 102, 11]));
/// AWZ: GDAWZ22EPUMVIGSD4SDIIVEZY77BVK6QVGK7OV3QSDAZ5EUCGA6Q4MDG
static immutable AWZ = KeyPair(PublicKey([193, 108, 235, 68, 125, 25, 84, 26, 67, 228, 134, 132, 84, 153, 199, 254, 26, 171, 208, 169, 149, 247, 87, 112, 144, 193, 158, 146, 130, 48, 61, 14]), SecretKey([184, 103, 29, 24, 219, 32, 59, 108, 58, 173, 124, 142, 111, 5, 194, 71, 185, 66, 114, 104, 82, 25, 29, 198, 96, 0, 223, 155, 111, 47, 229, 107]), Seed([227, 116, 103, 18, 72, 44, 243, 22, 172, 154, 28, 238, 85, 234, 12, 92, 75, 215, 27, 155, 237, 64, 54, 221, 28, 191, 174, 0, 165, 249, 212, 191]));
/// AXA: GDAXA22M4AXEIYSCQT6YE5T7GDIRELYQHZI3S6TEWG7676R7FE2HXEBO
static immutable AXA = KeyPair(PublicKey([193, 112, 107, 76, 224, 46, 68, 98, 66, 132, 253, 130, 118, 127, 48, 209, 18, 47, 16, 62, 81, 185, 122, 100, 177, 191, 239, 250, 63, 41, 52, 123]), SecretKey([240, 203, 209, 84, 58, 57, 14, 166, 246, 63, 221, 117, 92, 37, 58, 244, 150, 233, 137, 5, 68, 124, 31, 149, 35, 245, 170, 109, 199, 108, 124, 119]), Seed([2, 164, 194, 93, 11, 77, 240, 182, 173, 186, 13, 99, 86, 8, 59, 116, 201, 147, 244, 149, 20, 34, 164, 33, 117, 36, 28, 129, 142, 124, 167, 99]));
/// AXB: GDAXB22DQPH3ULWFSOZIR2PWMECCK7B6JNC4XTCG5YRQQOMKQAO5LKJD
static immutable AXB = KeyPair(PublicKey([193, 112, 235, 67, 131, 207, 186, 46, 197, 147, 178, 136, 233, 246, 97, 4, 37, 124, 62, 75, 69, 203, 204, 70, 238, 35, 8, 57, 138, 128, 29, 213]), SecretKey([160, 18, 11, 179, 181, 103, 33, 121, 135, 96, 45, 53, 50, 124, 101, 90, 111, 204, 166, 130, 178, 135, 117, 109, 136, 166, 130, 172, 171, 242, 173, 80]), Seed([248, 199, 29, 176, 181, 67, 23, 178, 193, 80, 61, 109, 84, 5, 110, 226, 12, 170, 246, 77, 103, 1, 82, 60, 222, 18, 240, 87, 83, 242, 250, 125]));
/// AXC: GDAXC22UCOR3WAIVGUUUS6X2RUYEL3V4OYMW3GUSK2ASUNOXHZC2KVZR
static immutable AXC = KeyPair(PublicKey([193, 113, 107, 84, 19, 163, 187, 1, 21, 53, 41, 73, 122, 250, 141, 48, 69, 238, 188, 118, 25, 109, 154, 146, 86, 129, 42, 53, 215, 62, 69, 165]), SecretKey([192, 201, 54, 59, 163, 214, 158, 60, 0, 129, 125, 70, 62, 91, 174, 243, 248, 45, 111, 173, 184, 179, 209, 170, 85, 242, 116, 117, 106, 111, 138, 105]), Seed([1, 226, 69, 146, 65, 72, 1, 108, 20, 0, 234, 192, 250, 194, 56, 20, 90, 152, 50, 56, 205, 27, 49, 213, 171, 201, 38, 84, 247, 36, 241, 8]));
/// AXD: GDAXD225SBA6HBLXUFPIP2NKD6CMT4IA7QIIHT2LD5FLFSCUQDWAMM3O
static immutable AXD = KeyPair(PublicKey([193, 113, 235, 93, 144, 65, 227, 133, 119, 161, 94, 135, 233, 170, 31, 132, 201, 241, 0, 252, 16, 131, 207, 75, 31, 74, 178, 200, 84, 128, 236, 6]), SecretKey([168, 241, 56, 248, 237, 48, 238, 174, 132, 188, 205, 69, 119, 228, 181, 133, 51, 197, 143, 238, 13, 220, 41, 218, 57, 55, 133, 217, 51, 236, 26, 115]), Seed([213, 177, 14, 193, 112, 175, 44, 146, 1, 52, 225, 182, 73, 231, 66, 248, 8, 32, 7, 27, 9, 106, 87, 60, 91, 96, 66, 13, 197, 80, 10, 44]));
/// AXE: GDAXE22MJDYAES7ODR6IWUQC44UMWQIGPOVCQLNXZTBOYRSXEZQFTOAA
static immutable AXE = KeyPair(PublicKey([193, 114, 107, 76, 72, 240, 2, 75, 238, 28, 124, 139, 82, 2, 231, 40, 203, 65, 6, 123, 170, 40, 45, 183, 204, 194, 236, 70, 87, 38, 96, 89]), SecretKey([240, 85, 105, 188, 18, 252, 244, 118, 211, 191, 168, 100, 246, 166, 163, 208, 119, 150, 179, 44, 66, 151, 95, 77, 0, 236, 218, 28, 110, 96, 196, 124]), Seed([211, 219, 139, 254, 112, 103, 215, 83, 248, 155, 149, 53, 98, 34, 178, 116, 158, 86, 58, 121, 224, 150, 152, 178, 184, 161, 13, 181, 92, 119, 212, 39]));
/// AXF: GDAXF2273573HLI2XPKRGKV3F5HLUMYWX23XV3IY2W4O2AFFPF4Q7MUB
static immutable AXF = KeyPair(PublicKey([193, 114, 235, 95, 223, 127, 179, 173, 26, 187, 213, 19, 42, 187, 47, 78, 186, 51, 22, 190, 183, 122, 237, 24, 213, 184, 237, 0, 165, 121, 121, 15]), SecretKey([240, 26, 94, 2, 214, 30, 202, 90, 80, 175, 244, 157, 41, 16, 107, 220, 45, 166, 251, 120, 110, 172, 171, 207, 168, 106, 230, 34, 73, 28, 166, 91]), Seed([88, 54, 88, 131, 106, 209, 200, 133, 248, 230, 164, 233, 17, 185, 113, 96, 139, 23, 159, 137, 52, 158, 135, 146, 55, 199, 86, 15, 226, 85, 64, 121]));
/// AXG: GDAXG22OTCM4U4LASXOOOSGWINQXH6XFOZUIUNIAWSN7JCOO3YU5KBVE
static immutable AXG = KeyPair(PublicKey([193, 115, 107, 78, 152, 153, 202, 113, 96, 149, 220, 231, 72, 214, 67, 97, 115, 250, 229, 118, 104, 138, 53, 0, 180, 155, 244, 137, 206, 222, 41, 213]), SecretKey([216, 61, 68, 35, 194, 137, 3, 69, 253, 45, 65, 26, 166, 137, 86, 209, 82, 127, 70, 62, 196, 213, 221, 78, 227, 191, 104, 121, 233, 60, 216, 125]), Seed([186, 26, 107, 143, 176, 192, 120, 23, 10, 141, 189, 235, 58, 214, 66, 132, 38, 174, 34, 58, 57, 138, 110, 148, 58, 44, 74, 56, 147, 32, 231, 101]));
/// AXH: GDAXH22OWX4SF67T7DNSGUKKQDZOK2QQBAB3P7TTECLJNAGA7P5ZGMIU
static immutable AXH = KeyPair(PublicKey([193, 115, 235, 78, 181, 249, 34, 251, 243, 248, 219, 35, 81, 74, 128, 242, 229, 106, 16, 8, 3, 183, 254, 115, 32, 150, 150, 128, 192, 251, 251, 147]), SecretKey([136, 136, 226, 9, 254, 150, 224, 249, 0, 119, 158, 27, 2, 123, 119, 69, 141, 29, 208, 242, 132, 226, 54, 164, 239, 213, 22, 168, 13, 64, 149, 92]), Seed([235, 165, 205, 196, 4, 25, 156, 117, 188, 134, 162, 168, 24, 223, 213, 233, 99, 169, 95, 208, 145, 179, 155, 146, 56, 132, 45, 200, 214, 51, 105, 155]));
/// AXI: GDAXI22JKAHQKI5KQHUO26NJCYQBE2XMYVUOV7FIJR7CTGB5MOPPX3H7
static immutable AXI = KeyPair(PublicKey([193, 116, 107, 73, 80, 15, 5, 35, 170, 129, 232, 237, 121, 169, 22, 32, 18, 106, 236, 197, 104, 234, 252, 168, 76, 126, 41, 152, 61, 99, 158, 251]), SecretKey([72, 236, 74, 15, 99, 185, 15, 50, 198, 151, 218, 187, 33, 91, 54, 15, 50, 4, 237, 234, 59, 79, 255, 35, 70, 193, 51, 223, 140, 249, 166, 124]), Seed([124, 51, 188, 56, 235, 227, 2, 66, 211, 226, 197, 189, 75, 122, 194, 55, 172, 212, 248, 112, 45, 88, 116, 250, 14, 147, 204, 12, 147, 250, 110, 174]));
/// AXJ: GDAXJ22EBBMGZE3ZGFOJEX673NF4GHXAN4W6JPUO3O3VJSTVVN6BYS3W
static immutable AXJ = KeyPair(PublicKey([193, 116, 235, 68, 8, 88, 108, 147, 121, 49, 92, 146, 95, 223, 219, 75, 195, 30, 224, 111, 45, 228, 190, 142, 219, 183, 84, 202, 117, 171, 124, 28]), SecretKey([88, 21, 190, 204, 211, 5, 1, 127, 212, 227, 235, 78, 160, 63, 5, 249, 81, 165, 241, 52, 147, 11, 106, 132, 107, 131, 182, 17, 90, 75, 6, 104]), Seed([13, 50, 48, 224, 219, 147, 179, 56, 11, 239, 39, 199, 206, 193, 223, 221, 133, 60, 195, 170, 230, 4, 165, 113, 228, 133, 3, 2, 233, 109, 7, 65]));
/// AXK: GDAXK22F3NOI3RKXRN5Q7Z7BSDWXGQEFSOVSBAENCKLM4NZ6JWSMFUQJ
static immutable AXK = KeyPair(PublicKey([193, 117, 107, 69, 219, 92, 141, 197, 87, 139, 123, 15, 231, 225, 144, 237, 115, 64, 133, 147, 171, 32, 128, 141, 18, 150, 206, 55, 62, 77, 164, 194]), SecretKey([32, 153, 65, 250, 216, 219, 93, 185, 159, 104, 27, 124, 195, 219, 141, 148, 66, 123, 211, 210, 14, 105, 204, 170, 41, 73, 195, 51, 52, 198, 32, 71]), Seed([11, 28, 28, 145, 8, 54, 22, 252, 165, 177, 22, 101, 231, 181, 186, 119, 191, 184, 82, 190, 176, 109, 60, 19, 30, 191, 244, 70, 231, 110, 215, 218]));
/// AXL: GDAXL22FF3CI636Y2BYEKUZFHP5TUOTW5OJIP3EWD3PN7HTC6OUEZVBK
static immutable AXL = KeyPair(PublicKey([193, 117, 235, 69, 46, 196, 143, 111, 216, 208, 112, 69, 83, 37, 59, 251, 58, 58, 118, 235, 146, 135, 236, 150, 30, 222, 223, 158, 98, 243, 168, 76]), SecretKey([104, 218, 95, 166, 85, 48, 214, 105, 202, 58, 99, 28, 233, 186, 30, 58, 81, 206, 202, 132, 115, 90, 159, 75, 240, 103, 192, 184, 248, 196, 26, 101]), Seed([62, 44, 57, 213, 128, 28, 159, 225, 79, 227, 239, 154, 220, 64, 91, 74, 164, 39, 173, 87, 29, 138, 78, 124, 62, 77, 217, 71, 210, 199, 191, 46]));
/// AXM: GDAXM22MS4ROZXTIUFT7LP5ILTNBQPORHMYYPCKTLB3HFP6222XL7H6L
static immutable AXM = KeyPair(PublicKey([193, 118, 107, 76, 151, 34, 236, 222, 104, 161, 103, 245, 191, 168, 92, 218, 24, 61, 209, 59, 49, 135, 137, 83, 88, 118, 114, 191, 218, 214, 174, 191]), SecretKey([112, 193, 2, 6, 125, 140, 207, 188, 112, 245, 85, 151, 51, 235, 81, 161, 157, 220, 22, 134, 108, 44, 210, 170, 80, 34, 201, 166, 171, 80, 39, 110]), Seed([143, 2, 168, 237, 90, 160, 114, 193, 221, 135, 32, 124, 56, 156, 208, 58, 149, 157, 140, 25, 32, 85, 92, 115, 157, 86, 221, 55, 14, 203, 53, 126]));
/// AXN: GDAXN22NUSVM4RI4JTS6H5UGFM4LLVTVV3OTFSQXAF3N22H35IG4Q6DT
static immutable AXN = KeyPair(PublicKey([193, 118, 235, 77, 164, 170, 206, 69, 28, 76, 229, 227, 246, 134, 43, 56, 181, 214, 117, 174, 221, 50, 202, 23, 1, 118, 221, 104, 251, 234, 13, 200]), SecretKey([64, 186, 126, 194, 28, 148, 180, 50, 160, 6, 18, 80, 142, 177, 16, 19, 146, 142, 1, 79, 167, 253, 197, 200, 233, 202, 229, 160, 181, 65, 253, 110]), Seed([62, 79, 228, 24, 206, 38, 2, 36, 119, 202, 62, 252, 203, 250, 226, 13, 141, 71, 85, 11, 149, 18, 128, 109, 101, 183, 98, 97, 200, 40, 163, 54]));
/// AXO: GDAXO22ZEMDWVXA3TUXNM53MQWIEKJRX4RNGZE5PODIAD75JJYBJDIMM
static immutable AXO = KeyPair(PublicKey([193, 119, 107, 89, 35, 7, 106, 220, 27, 157, 46, 214, 119, 108, 133, 144, 69, 38, 55, 228, 90, 108, 147, 175, 112, 208, 1, 255, 169, 78, 2, 145]), SecretKey([176, 85, 106, 26, 229, 15, 248, 94, 65, 251, 50, 221, 93, 203, 116, 123, 218, 83, 64, 52, 220, 200, 126, 148, 20, 30, 242, 173, 109, 92, 247, 64]), Seed([245, 254, 64, 61, 65, 23, 25, 100, 46, 157, 98, 53, 219, 159, 60, 25, 67, 234, 32, 110, 61, 166, 142, 8, 226, 203, 106, 212, 175, 42, 171, 77]));
/// AXP: GDAXP22FYJTBGIAMCVZUI6HU6ZPI26AAK7QMMLFSTZDWTXSDWVPTFRRW
static immutable AXP = KeyPair(PublicKey([193, 119, 235, 69, 194, 102, 19, 32, 12, 21, 115, 68, 120, 244, 246, 94, 141, 120, 0, 87, 224, 198, 44, 178, 158, 71, 105, 222, 67, 181, 95, 50]), SecretKey([168, 247, 76, 37, 161, 97, 138, 44, 226, 76, 49, 243, 139, 194, 177, 19, 136, 50, 143, 244, 219, 77, 119, 155, 122, 52, 245, 178, 15, 81, 138, 114]), Seed([103, 160, 196, 185, 81, 30, 239, 32, 33, 241, 189, 122, 206, 175, 64, 38, 88, 6, 167, 212, 69, 127, 35, 153, 62, 123, 44, 173, 242, 81, 193, 52]));
/// AXQ: GDAXQ22NNR5QY4QE6FCO3LNGESAB445WGA3FLGFJJZ62DONIKNLVIBNY
static immutable AXQ = KeyPair(PublicKey([193, 120, 107, 77, 108, 123, 12, 114, 4, 241, 68, 237, 173, 166, 36, 128, 30, 115, 182, 48, 54, 85, 152, 169, 78, 125, 161, 185, 168, 83, 87, 84]), SecretKey([208, 183, 62, 219, 222, 43, 201, 29, 56, 10, 86, 223, 13, 91, 55, 41, 154, 49, 253, 120, 177, 232, 173, 112, 190, 151, 150, 198, 235, 19, 1, 99]), Seed([166, 206, 108, 148, 22, 60, 113, 25, 166, 69, 128, 109, 94, 229, 237, 143, 102, 196, 80, 80, 44, 101, 154, 90, 163, 133, 66, 249, 155, 200, 158, 119]));
/// AXR: GDAXR22XD5NZAGEOBDA3RHIUADXOJOI2GOI26AB5DO3RPH23ITXMRY22
static immutable AXR = KeyPair(PublicKey([193, 120, 235, 87, 31, 91, 144, 24, 142, 8, 193, 184, 157, 20, 0, 238, 228, 185, 26, 51, 145, 175, 0, 61, 27, 183, 23, 159, 91, 68, 238, 200]), SecretKey([176, 246, 211, 4, 178, 247, 243, 240, 157, 90, 137, 215, 26, 83, 34, 89, 74, 180, 50, 122, 82, 219, 144, 190, 15, 230, 193, 4, 160, 56, 203, 82]), Seed([6, 207, 200, 20, 186, 128, 47, 249, 254, 79, 21, 102, 89, 22, 55, 224, 65, 108, 47, 2, 71, 42, 51, 29, 60, 115, 219, 222, 11, 181, 254, 241]));
/// AXS: GDAXS22JTAFEBED5DCNL7LAAJTOF6GOSOZAZASM6JGRNWUJM7HFMJRUE
static immutable AXS = KeyPair(PublicKey([193, 121, 107, 73, 152, 10, 64, 144, 125, 24, 154, 191, 172, 0, 76, 220, 95, 25, 210, 118, 65, 144, 73, 158, 73, 162, 219, 81, 44, 249, 202, 196]), SecretKey([160, 122, 12, 60, 91, 57, 60, 29, 71, 203, 179, 217, 227, 183, 2, 199, 112, 231, 125, 113, 30, 42, 244, 102, 138, 96, 215, 241, 134, 22, 133, 85]), Seed([116, 153, 132, 211, 34, 240, 216, 211, 144, 60, 204, 121, 38, 192, 25, 72, 14, 158, 9, 200, 49, 109, 55, 137, 116, 231, 94, 102, 83, 47, 105, 48]));
/// AXT: GDAXT22T25MN4MR7DA5MPMLSWMSTXBAV2ANGKUN2ZYPEB4LLMVWXTNIU
static immutable AXT = KeyPair(PublicKey([193, 121, 235, 83, 215, 88, 222, 50, 63, 24, 58, 199, 177, 114, 179, 37, 59, 132, 21, 208, 26, 101, 81, 186, 206, 30, 64, 241, 107, 101, 109, 121]), SecretKey([224, 210, 69, 141, 18, 8, 213, 143, 254, 136, 148, 65, 246, 146, 95, 29, 20, 83, 136, 216, 44, 116, 104, 115, 27, 157, 126, 236, 184, 51, 30, 72]), Seed([34, 9, 29, 91, 94, 196, 253, 210, 233, 214, 134, 141, 236, 35, 189, 52, 130, 9, 174, 34, 120, 231, 56, 217, 203, 207, 135, 192, 82, 57, 39, 180]));
/// AXU: GDAXU22S3PUB33SFHSTZPBESQJWEPTZBMJ6ENTCTLMOKEE52435UZDSJ
static immutable AXU = KeyPair(PublicKey([193, 122, 107, 82, 219, 232, 29, 238, 69, 60, 167, 151, 132, 146, 130, 108, 71, 207, 33, 98, 124, 70, 204, 83, 91, 28, 162, 19, 186, 230, 251, 76]), SecretKey([96, 120, 250, 253, 102, 156, 252, 84, 197, 86, 118, 252, 141, 204, 60, 90, 64, 159, 23, 108, 166, 62, 82, 218, 239, 215, 66, 122, 88, 122, 134, 92]), Seed([167, 195, 175, 93, 52, 36, 49, 153, 58, 170, 77, 203, 165, 94, 116, 183, 152, 6, 81, 55, 216, 244, 204, 231, 86, 157, 3, 36, 198, 139, 48, 88]));
/// AXV: GDAXV227S53ZCTS2ZH22GEYOXCC2BD2LLCSC2UDQYJ7I4P4MQD52YITQ
static immutable AXV = KeyPair(PublicKey([193, 122, 235, 95, 151, 119, 145, 78, 90, 201, 245, 163, 19, 14, 184, 133, 160, 143, 75, 88, 164, 45, 80, 112, 194, 126, 142, 63, 140, 128, 251, 172]), SecretKey([8, 114, 131, 192, 0, 131, 236, 249, 245, 156, 15, 118, 36, 110, 255, 34, 98, 77, 194, 180, 129, 201, 14, 169, 128, 152, 191, 162, 51, 141, 170, 115]), Seed([248, 53, 22, 50, 26, 106, 24, 225, 163, 118, 22, 135, 130, 32, 96, 103, 129, 212, 72, 249, 52, 251, 31, 24, 87, 184, 195, 204, 185, 242, 241, 136]));
/// AXW: GDAXW22VOJALVR5C7H5S4AA422U6NZ2WDBGQJVIFVMCOAOL6JB2NAHMC
static immutable AXW = KeyPair(PublicKey([193, 123, 107, 85, 114, 64, 186, 199, 162, 249, 251, 46, 0, 28, 214, 169, 230, 231, 86, 24, 77, 4, 213, 5, 171, 4, 224, 57, 126, 72, 116, 208]), SecretKey([0, 248, 223, 224, 138, 5, 250, 102, 253, 120, 170, 29, 13, 210, 200, 248, 17, 84, 138, 137, 162, 111, 115, 149, 79, 98, 221, 103, 177, 49, 11, 100]), Seed([96, 74, 25, 22, 119, 221, 72, 80, 58, 172, 67, 35, 121, 78, 128, 23, 142, 116, 189, 31, 134, 198, 135, 188, 110, 107, 108, 238, 72, 227, 236, 71]));
/// AXX: GDAXX22G3XSNAFGLE667H4TFHFZGL6YOQONBY63OID6COHGA5QWIYFVD
static immutable AXX = KeyPair(PublicKey([193, 123, 235, 70, 221, 228, 208, 20, 203, 39, 189, 243, 242, 101, 57, 114, 101, 251, 14, 131, 154, 28, 123, 110, 64, 252, 39, 28, 192, 236, 44, 140]), SecretKey([40, 38, 89, 13, 154, 86, 102, 57, 44, 230, 31, 130, 15, 175, 10, 170, 59, 117, 80, 11, 77, 18, 91, 147, 116, 93, 224, 78, 148, 186, 176, 72]), Seed([31, 120, 226, 92, 219, 247, 152, 11, 113, 214, 158, 229, 239, 45, 211, 200, 83, 75, 113, 207, 79, 96, 240, 73, 154, 109, 174, 201, 169, 192, 180, 101]));
/// AXY: GDAXY22P7WT4YIYUVUJE62VIX5MCAWDSMF2OMPGUTTEP2RDYTNERIUR3
static immutable AXY = KeyPair(PublicKey([193, 124, 107, 79, 253, 167, 204, 35, 20, 173, 18, 79, 106, 168, 191, 88, 32, 88, 114, 97, 116, 230, 60, 212, 156, 200, 253, 68, 120, 155, 73, 20]), SecretKey([24, 55, 57, 60, 167, 70, 193, 185, 170, 244, 122, 151, 239, 113, 25, 108, 22, 132, 101, 65, 205, 10, 107, 63, 17, 177, 249, 196, 46, 206, 63, 100]), Seed([239, 79, 122, 172, 145, 26, 85, 245, 71, 79, 23, 234, 248, 72, 78, 191, 33, 237, 57, 10, 49, 4, 164, 15, 19, 138, 143, 46, 165, 137, 214, 114]));
/// AXZ: GDAXZ22F2W5GSGAQVDF6PHXF2POEZS4SPKY6OY4AQXNZI26JPG5NA4RX
static immutable AXZ = KeyPair(PublicKey([193, 124, 235, 69, 213, 186, 105, 24, 16, 168, 203, 231, 158, 229, 211, 220, 76, 203, 146, 122, 177, 231, 99, 128, 133, 219, 148, 107, 201, 121, 186, 208]), SecretKey([80, 191, 148, 9, 61, 213, 163, 193, 124, 25, 150, 198, 7, 246, 135, 6, 46, 138, 73, 244, 244, 110, 39, 200, 58, 115, 145, 80, 64, 45, 131, 114]), Seed([156, 224, 39, 75, 137, 121, 212, 230, 103, 191, 68, 153, 21, 146, 42, 129, 151, 184, 67, 113, 143, 63, 149, 198, 184, 146, 29, 103, 246, 253, 130, 42]));
/// AYA: GDAYA22E7REHMIJWM5ZJMMWL6NOEFQDMKRGEODJK53S65APMKXPPGDAO
static immutable AYA = KeyPair(PublicKey([193, 128, 107, 68, 252, 72, 118, 33, 54, 103, 114, 150, 50, 203, 243, 92, 66, 192, 108, 84, 76, 71, 13, 42, 238, 229, 238, 129, 236, 85, 222, 243]), SecretKey([200, 58, 52, 189, 93, 150, 171, 85, 72, 24, 164, 112, 119, 116, 227, 97, 16, 43, 45, 109, 255, 89, 106, 170, 170, 54, 225, 224, 218, 203, 99, 66]), Seed([143, 123, 45, 106, 65, 193, 240, 233, 48, 87, 133, 152, 166, 225, 37, 202, 38, 104, 87, 161, 231, 216, 231, 169, 68, 115, 179, 200, 76, 51, 96, 153]));
/// AYB: GDAYB225FANP44PWDRL4DIKWBLWI3XKB7HCI6ZM3IBRHKVOKNA3JINOK
static immutable AYB = KeyPair(PublicKey([193, 128, 235, 93, 40, 26, 254, 113, 246, 28, 87, 193, 161, 86, 10, 236, 141, 221, 65, 249, 196, 143, 101, 155, 64, 98, 117, 85, 202, 104, 54, 148]), SecretKey([16, 145, 1, 211, 105, 129, 157, 1, 70, 169, 30, 136, 33, 52, 180, 183, 58, 127, 214, 182, 89, 189, 202, 101, 89, 150, 226, 147, 84, 198, 92, 85]), Seed([31, 213, 185, 68, 101, 50, 169, 134, 111, 230, 123, 148, 61, 29, 8, 202, 205, 249, 69, 99, 50, 185, 151, 62, 201, 247, 129, 60, 85, 128, 114, 83]));
/// AYC: GDAYC22J6MMZLC3UQAVDLHNK3GMQT3AXE37HEGNQQZ7YPDY4HYNPAAOR
static immutable AYC = KeyPair(PublicKey([193, 129, 107, 73, 243, 25, 149, 139, 116, 128, 42, 53, 157, 170, 217, 153, 9, 236, 23, 38, 254, 114, 25, 176, 134, 127, 135, 143, 28, 62, 26, 240]), SecretKey([176, 72, 236, 7, 230, 70, 51, 175, 88, 221, 0, 81, 36, 54, 111, 102, 180, 13, 210, 231, 192, 87, 166, 248, 93, 91, 129, 154, 242, 211, 38, 68]), Seed([147, 56, 160, 92, 57, 80, 157, 139, 29, 155, 42, 59, 152, 192, 74, 252, 209, 6, 202, 91, 69, 178, 59, 207, 27, 129, 183, 138, 199, 8, 232, 1]));
/// AYD: GDAYD22AI62J5LGNRTCGFSMNWL6C4QBFU45KAUZXCK5YSHUEMJ3N6XGW
static immutable AYD = KeyPair(PublicKey([193, 129, 235, 64, 71, 180, 158, 172, 205, 140, 196, 98, 201, 141, 178, 252, 46, 64, 37, 167, 58, 160, 83, 55, 18, 187, 137, 30, 132, 98, 118, 223]), SecretKey([0, 70, 89, 224, 102, 193, 195, 141, 230, 29, 57, 75, 170, 212, 182, 208, 209, 237, 104, 118, 150, 49, 70, 22, 66, 26, 74, 187, 138, 175, 196, 86]), Seed([137, 35, 92, 101, 135, 193, 98, 240, 227, 68, 252, 120, 108, 214, 202, 212, 166, 153, 17, 169, 0, 255, 189, 1, 222, 18, 0, 160, 152, 57, 73, 38]));
/// AYE: GDAYE226OWBW6C55F4WKULJFUYMUFIOSTBARJX4Q23BLMB7X2M5UD2KM
static immutable AYE = KeyPair(PublicKey([193, 130, 107, 94, 117, 131, 111, 11, 189, 47, 44, 170, 45, 37, 166, 25, 66, 161, 210, 152, 65, 20, 223, 144, 214, 194, 182, 7, 247, 211, 59, 65]), SecretKey([152, 216, 26, 79, 250, 161, 213, 44, 50, 66, 176, 198, 128, 119, 180, 63, 152, 86, 215, 123, 188, 167, 219, 243, 85, 114, 242, 7, 236, 251, 95, 70]), Seed([141, 14, 72, 250, 54, 205, 255, 218, 244, 7, 106, 195, 160, 64, 36, 100, 81, 118, 103, 189, 32, 116, 185, 83, 37, 130, 19, 198, 50, 39, 217, 228]));
/// AYF: GDAYF22RVQ7PH5GS4MAGYMODEYEIN6NZAECBTF337R2R7WEFWUJS3CI6
static immutable AYF = KeyPair(PublicKey([193, 130, 235, 81, 172, 62, 243, 244, 210, 227, 0, 108, 49, 195, 38, 8, 134, 249, 185, 1, 4, 25, 151, 123, 252, 117, 31, 216, 133, 181, 19, 45]), SecretKey([232, 3, 193, 195, 101, 167, 44, 98, 43, 66, 232, 68, 53, 221, 181, 10, 176, 167, 62, 175, 195, 250, 22, 18, 158, 203, 79, 132, 21, 156, 105, 72]), Seed([218, 66, 222, 9, 78, 131, 199, 36, 171, 222, 114, 11, 43, 151, 153, 232, 178, 129, 215, 255, 151, 184, 22, 224, 186, 41, 131, 179, 233, 225, 46, 226]));
/// AYG: GDAYG22FZKGM6MXQ4IPLQXPE2EU7LZHSAQATNPFVPGOKC6WGVQY5A45N
static immutable AYG = KeyPair(PublicKey([193, 131, 107, 69, 202, 140, 207, 50, 240, 226, 30, 184, 93, 228, 209, 41, 245, 228, 242, 4, 1, 54, 188, 181, 121, 156, 161, 122, 198, 172, 49, 208]), SecretKey([248, 102, 5, 214, 123, 178, 97, 90, 203, 188, 72, 52, 27, 136, 29, 228, 235, 225, 58, 55, 55, 156, 222, 59, 235, 95, 251, 68, 115, 215, 196, 79]), Seed([125, 255, 174, 59, 97, 194, 19, 149, 220, 224, 195, 149, 73, 16, 77, 198, 188, 21, 95, 171, 155, 63, 78, 127, 35, 50, 141, 136, 230, 168, 190, 137]));
/// AYH: GDAYH22IS4EZMRV6ARDCKDL5PVWDMAFLSZL5Q52EHPQQYEUKYJSC7TGH
static immutable AYH = KeyPair(PublicKey([193, 131, 235, 72, 151, 9, 150, 70, 190, 4, 70, 37, 13, 125, 125, 108, 54, 0, 171, 150, 87, 216, 119, 68, 59, 225, 12, 18, 138, 194, 100, 47]), SecretKey([248, 143, 41, 26, 219, 15, 95, 232, 220, 234, 111, 46, 42, 12, 135, 101, 221, 97, 119, 110, 180, 197, 137, 123, 104, 152, 219, 22, 18, 244, 78, 93]), Seed([123, 174, 46, 183, 43, 90, 24, 254, 85, 196, 166, 215, 145, 121, 131, 108, 64, 217, 243, 214, 74, 97, 146, 115, 39, 43, 201, 107, 162, 192, 132, 2]));
/// AYI: GDAYI22IJLGNAFD6QGRQ2Z5FLKMASYJ5SASPT7TP3N3C55VD4V5K2HEF
static immutable AYI = KeyPair(PublicKey([193, 132, 107, 72, 74, 204, 208, 20, 126, 129, 163, 13, 103, 165, 90, 152, 9, 97, 61, 144, 36, 249, 254, 111, 219, 118, 46, 246, 163, 229, 122, 173]), SecretKey([200, 54, 229, 212, 196, 30, 243, 48, 253, 95, 76, 60, 200, 38, 164, 17, 107, 27, 226, 246, 186, 3, 239, 172, 206, 48, 224, 217, 214, 193, 80, 91]), Seed([65, 217, 94, 67, 247, 38, 216, 205, 195, 130, 188, 23, 185, 178, 113, 172, 96, 9, 219, 139, 200, 127, 98, 144, 48, 231, 10, 28, 249, 41, 222, 100]));
/// AYJ: GDAYJ22O27W3RVYTZET6RXVDQ4PIOKPHUUFD3MZCUAI6GDEQAKIQRLAQ
static immutable AYJ = KeyPair(PublicKey([193, 132, 235, 78, 215, 237, 184, 215, 19, 201, 39, 232, 222, 163, 135, 30, 135, 41, 231, 165, 10, 61, 179, 34, 160, 17, 227, 12, 144, 2, 145, 8]), SecretKey([168, 87, 174, 241, 149, 72, 209, 195, 82, 50, 241, 172, 78, 173, 191, 48, 161, 75, 44, 154, 180, 238, 195, 42, 4, 56, 249, 24, 57, 160, 166, 123]), Seed([173, 247, 38, 40, 127, 80, 125, 113, 210, 42, 234, 112, 45, 126, 108, 24, 44, 168, 55, 110, 133, 151, 128, 190, 222, 99, 90, 182, 0, 68, 47, 9]));
/// AYK: GDAYK22DHZOZWHZLFB5ALUY2Z3M32Q6VMYKOUQJHYX4ATIVCKLVQZCPP
static immutable AYK = KeyPair(PublicKey([193, 133, 107, 67, 62, 93, 155, 31, 43, 40, 122, 5, 211, 26, 206, 217, 189, 67, 213, 102, 20, 234, 65, 39, 197, 248, 9, 162, 162, 82, 235, 12]), SecretKey([40, 98, 142, 205, 253, 162, 97, 205, 45, 197, 143, 219, 76, 254, 233, 97, 186, 248, 23, 220, 124, 233, 214, 80, 165, 232, 54, 47, 17, 38, 213, 85]), Seed([186, 90, 132, 53, 246, 13, 243, 82, 228, 23, 127, 239, 92, 247, 229, 21, 11, 126, 181, 135, 230, 209, 115, 121, 82, 232, 147, 115, 211, 211, 240, 101]));
/// AYL: GDAYL22HDATX4YD7BAXEWHKHJE35SWUKBK4NTZUEGQZQ4PCFYVM5K6IZ
static immutable AYL = KeyPair(PublicKey([193, 133, 235, 71, 24, 39, 126, 96, 127, 8, 46, 75, 29, 71, 73, 55, 217, 90, 138, 10, 184, 217, 230, 132, 52, 51, 14, 60, 69, 197, 89, 213]), SecretKey([144, 233, 83, 241, 68, 222, 220, 142, 53, 197, 252, 25, 150, 92, 94, 194, 48, 229, 116, 94, 163, 2, 178, 247, 3, 181, 38, 117, 140, 70, 68, 87]), Seed([68, 120, 38, 27, 16, 201, 28, 197, 108, 147, 207, 198, 85, 143, 138, 218, 159, 173, 130, 195, 246, 115, 55, 205, 56, 77, 135, 24, 79, 141, 113, 82]));
/// AYM: GDAYM22EYK7H5LOWJC7SDT2DUIVJ65GWJHURDTEUDH3XGTWPN2VOSO4W
static immutable AYM = KeyPair(PublicKey([193, 134, 107, 68, 194, 190, 126, 173, 214, 72, 191, 33, 207, 67, 162, 42, 159, 116, 214, 73, 233, 17, 204, 148, 25, 247, 115, 78, 207, 110, 170, 233]), SecretKey([208, 82, 175, 95, 172, 200, 127, 236, 2, 61, 63, 237, 219, 216, 209, 225, 51, 89, 129, 72, 158, 81, 171, 117, 106, 237, 71, 211, 106, 184, 143, 110]), Seed([229, 233, 211, 145, 230, 11, 250, 63, 192, 80, 65, 248, 171, 212, 128, 51, 133, 83, 40, 190, 148, 79, 192, 124, 193, 226, 150, 229, 182, 2, 80, 8]));
/// AYN: GDAYN22MIMHR44U7HFZNTT6PWA72FZXTQU5TLL4GUWSMM5AROM2LHTLU
static immutable AYN = KeyPair(PublicKey([193, 134, 235, 76, 67, 15, 30, 114, 159, 57, 114, 217, 207, 207, 176, 63, 162, 230, 243, 133, 59, 53, 175, 134, 165, 164, 198, 116, 17, 115, 52, 179]), SecretKey([104, 193, 168, 215, 214, 136, 208, 215, 113, 248, 97, 178, 31, 137, 137, 216, 149, 78, 92, 107, 117, 13, 199, 104, 208, 201, 180, 254, 94, 226, 74, 103]), Seed([103, 216, 68, 175, 128, 125, 194, 99, 147, 97, 103, 244, 114, 178, 193, 183, 45, 170, 174, 194, 41, 78, 100, 153, 108, 205, 215, 216, 41, 46, 68, 112]));
/// AYO: GDAYO22LYMZTZYSK6VBUUU45PLJTY6SQUD4CEQNYYMEQZCCDR5KDO2V3
static immutable AYO = KeyPair(PublicKey([193, 135, 107, 75, 195, 51, 60, 226, 74, 245, 67, 74, 83, 157, 122, 211, 60, 122, 80, 160, 248, 34, 65, 184, 195, 9, 12, 136, 67, 143, 84, 55]), SecretKey([200, 19, 19, 196, 20, 58, 41, 109, 158, 222, 69, 50, 140, 11, 64, 32, 229, 115, 25, 8, 26, 113, 3, 144, 115, 192, 70, 207, 204, 200, 160, 79]), Seed([22, 216, 163, 158, 5, 252, 44, 99, 198, 111, 115, 168, 107, 160, 118, 156, 224, 249, 199, 13, 21, 74, 139, 42, 158, 194, 128, 159, 58, 20, 185, 2]));
/// AYP: GDAYP226SMW6FFXWOQQWBOSCLUSSNS6HS77RJOAQHBSZHZGHKM5O444M
static immutable AYP = KeyPair(PublicKey([193, 135, 235, 94, 147, 45, 226, 150, 246, 116, 33, 96, 186, 66, 93, 37, 38, 203, 199, 151, 255, 20, 184, 16, 56, 101, 147, 228, 199, 83, 58, 238]), SecretKey([64, 205, 213, 114, 146, 97, 20, 136, 243, 248, 17, 54, 223, 108, 242, 72, 88, 107, 252, 224, 128, 236, 57, 194, 238, 215, 97, 143, 223, 41, 230, 106]), Seed([115, 42, 168, 94, 30, 234, 132, 39, 31, 221, 132, 161, 62, 34, 206, 48, 254, 40, 175, 194, 155, 252, 225, 76, 130, 27, 210, 56, 42, 28, 118, 145]));
/// AYQ: GDAYQ22BDRSZM7SFAYQCKLKMETIMN3VLOIMFJDHTL4OEP2P7A6VISOG6
static immutable AYQ = KeyPair(PublicKey([193, 136, 107, 65, 28, 101, 150, 126, 69, 6, 32, 37, 45, 76, 36, 208, 198, 238, 171, 114, 24, 84, 140, 243, 95, 28, 71, 233, 255, 7, 170, 137]), SecretKey([64, 179, 200, 243, 50, 15, 18, 206, 10, 113, 32, 42, 14, 98, 157, 194, 220, 214, 32, 55, 53, 166, 163, 17, 247, 19, 193, 127, 235, 103, 11, 70]), Seed([157, 176, 251, 178, 203, 77, 108, 154, 8, 94, 214, 183, 52, 243, 228, 212, 144, 144, 115, 1, 118, 221, 39, 1, 121, 103, 78, 119, 125, 217, 51, 98]));
/// AYR: GDAYR22ECYK3YFCVVWL6IFCUNYHTZ7L4OLNXCRPWEZNAORUVVQBV5UWZ
static immutable AYR = KeyPair(PublicKey([193, 136, 235, 68, 22, 21, 188, 20, 85, 173, 151, 228, 20, 84, 110, 15, 60, 253, 124, 114, 219, 113, 69, 246, 38, 90, 7, 70, 149, 172, 3, 94]), SecretKey([96, 28, 88, 243, 111, 230, 116, 171, 109, 72, 80, 162, 135, 112, 69, 111, 50, 169, 77, 50, 143, 222, 6, 202, 101, 248, 146, 238, 193, 3, 158, 111]), Seed([202, 128, 252, 84, 160, 213, 129, 191, 175, 190, 191, 241, 141, 70, 83, 171, 14, 46, 98, 33, 207, 147, 4, 41, 240, 231, 220, 203, 207, 254, 154, 186]));
/// AYS: GDAYS22RIX46TTPWKQXPEMHZPJSAPJ3JCVBUEYGQBRFYT3RLFBDRV6AI
static immutable AYS = KeyPair(PublicKey([193, 137, 107, 81, 69, 249, 233, 205, 246, 84, 46, 242, 48, 249, 122, 100, 7, 167, 105, 21, 67, 66, 96, 208, 12, 75, 137, 238, 43, 40, 71, 26]), SecretKey([168, 243, 51, 201, 178, 86, 114, 226, 231, 241, 183, 83, 223, 251, 121, 186, 14, 251, 137, 22, 68, 9, 0, 169, 109, 84, 184, 203, 225, 172, 216, 72]), Seed([158, 233, 48, 179, 148, 105, 87, 131, 112, 129, 57, 103, 102, 32, 160, 38, 168, 88, 255, 59, 128, 251, 127, 27, 96, 239, 240, 90, 193, 1, 98, 5]));
/// AYT: GDAYT22WL3BX7RNK2BODCNKREG3TKQ6W65I5NUVLIOK2ZSVQ4FH3IRMR
static immutable AYT = KeyPair(PublicKey([193, 137, 235, 86, 94, 195, 127, 197, 170, 208, 92, 49, 53, 81, 33, 183, 53, 67, 214, 247, 81, 214, 210, 171, 67, 149, 172, 202, 176, 225, 79, 180]), SecretKey([16, 140, 53, 133, 244, 172, 147, 238, 38, 250, 132, 172, 124, 240, 211, 141, 35, 95, 107, 213, 245, 85, 31, 44, 82, 122, 17, 230, 197, 113, 22, 91]), Seed([52, 110, 166, 102, 148, 34, 222, 103, 157, 58, 81, 234, 2, 199, 97, 93, 9, 131, 23, 154, 83, 254, 210, 225, 146, 66, 3, 122, 177, 1, 248, 12]));
/// AYU: GDAYU22I3RKIWJWMC2FVLX6VZGAAQYOHA3MBVRNHRGLRSQPGZCS52YBT
static immutable AYU = KeyPair(PublicKey([193, 138, 107, 72, 220, 84, 139, 38, 204, 22, 139, 85, 223, 213, 201, 128, 8, 97, 199, 6, 216, 26, 197, 167, 137, 151, 25, 65, 230, 200, 165, 221]), SecretKey([112, 31, 158, 39, 92, 182, 205, 47, 1, 227, 207, 31, 231, 14, 170, 153, 169, 4, 183, 8, 149, 27, 89, 134, 251, 123, 40, 77, 45, 118, 101, 124]), Seed([58, 63, 247, 248, 88, 15, 220, 37, 55, 164, 45, 97, 88, 55, 233, 67, 8, 89, 35, 70, 155, 110, 18, 214, 116, 151, 234, 161, 116, 233, 134, 39]));
/// AYV: GDAYV225DIDTHFFQEGNLK6UOY3ON2DZZC56M7NUQPCD2DYNDEKPUUKFM
static immutable AYV = KeyPair(PublicKey([193, 138, 235, 93, 26, 7, 51, 148, 176, 33, 154, 181, 122, 142, 198, 220, 221, 15, 57, 23, 124, 207, 182, 144, 120, 135, 161, 225, 163, 34, 159, 74]), SecretKey([160, 60, 124, 141, 211, 73, 227, 132, 229, 92, 210, 82, 165, 109, 147, 194, 253, 225, 74, 255, 90, 5, 59, 49, 38, 5, 106, 25, 137, 12, 7, 65]), Seed([139, 190, 117, 37, 155, 40, 13, 78, 74, 222, 221, 213, 193, 228, 140, 40, 235, 79, 97, 118, 241, 37, 185, 102, 254, 24, 23, 36, 132, 32, 79, 52]));
/// AYW: GDAYW22CWCURHSGJ6WY7P7NCK7LAESFDIXYZOWZ6OXAALD3UVAQ36GYK
static immutable AYW = KeyPair(PublicKey([193, 139, 107, 66, 176, 169, 19, 200, 201, 245, 177, 247, 253, 162, 87, 214, 2, 72, 163, 69, 241, 151, 91, 62, 117, 192, 5, 143, 116, 168, 33, 191]), SecretKey([200, 30, 224, 176, 116, 38, 60, 212, 116, 62, 9, 22, 212, 1, 37, 85, 28, 167, 175, 86, 84, 207, 119, 197, 110, 24, 57, 1, 233, 9, 146, 108]), Seed([187, 216, 118, 33, 206, 11, 61, 226, 9, 60, 189, 142, 47, 20, 253, 37, 100, 85, 12, 253, 74, 207, 141, 254, 177, 127, 89, 177, 85, 55, 126, 124]));
/// AYX: GDAYX22IUWL7LLRQY7UFMYVVPLL5S6OOFKHSOQ646IO53FSH6AMV3H2Y
static immutable AYX = KeyPair(PublicKey([193, 139, 235, 72, 165, 151, 245, 174, 48, 199, 232, 86, 98, 181, 122, 215, 217, 121, 206, 42, 143, 39, 67, 220, 242, 29, 221, 150, 71, 240, 25, 93]), SecretKey([176, 52, 86, 217, 28, 150, 188, 153, 128, 153, 201, 254, 148, 5, 1, 136, 126, 237, 66, 35, 10, 80, 193, 190, 113, 44, 93, 189, 5, 133, 154, 113]), Seed([65, 184, 206, 87, 158, 237, 192, 11, 152, 123, 204, 108, 231, 245, 135, 218, 149, 97, 219, 69, 181, 126, 24, 11, 5, 21, 8, 236, 194, 184, 62, 148]));
/// AYY: GDAYY22ABC3BPFISE2FRA5UKYZO6NNZA6J4DDC3JKUIQZGFRSEWUNH3D
static immutable AYY = KeyPair(PublicKey([193, 140, 107, 64, 8, 182, 23, 149, 18, 38, 139, 16, 118, 138, 198, 93, 230, 183, 32, 242, 120, 49, 139, 105, 85, 17, 12, 152, 177, 145, 45, 70]), SecretKey([32, 28, 82, 124, 240, 39, 98, 147, 103, 41, 71, 95, 160, 90, 98, 96, 193, 20, 238, 208, 146, 165, 85, 84, 143, 193, 210, 130, 184, 182, 205, 113]), Seed([119, 46, 20, 234, 90, 151, 212, 181, 15, 143, 136, 93, 92, 11, 35, 127, 107, 251, 105, 51, 27, 176, 244, 79, 15, 214, 173, 186, 15, 77, 53, 104]));
/// AYZ: GDAYZ22K67DCCQDMZLBGHTWRNKVKZZAD5NTJ2IASGVU4X577LA4BTOSU
static immutable AYZ = KeyPair(PublicKey([193, 140, 235, 74, 247, 198, 33, 64, 108, 202, 194, 99, 206, 209, 106, 170, 172, 228, 3, 235, 102, 157, 32, 18, 53, 105, 203, 247, 255, 88, 56, 25]), SecretKey([104, 96, 195, 236, 86, 61, 199, 2, 219, 133, 33, 84, 26, 229, 124, 141, 89, 206, 205, 252, 247, 246, 199, 62, 130, 234, 127, 129, 202, 132, 56, 81]), Seed([193, 187, 151, 41, 8, 172, 80, 22, 18, 93, 175, 92, 39, 156, 69, 27, 174, 130, 235, 77, 108, 98, 210, 159, 40, 102, 13, 76, 188, 233, 205, 151]));
/// AZA: GDAZA223HMY2A2NWS3ARI2BPIJDBWCRDACQ3LXUXGRLST5DMWKFYHGEL
static immutable AZA = KeyPair(PublicKey([193, 144, 107, 91, 59, 49, 160, 105, 182, 150, 193, 20, 104, 47, 66, 70, 27, 10, 35, 0, 161, 181, 222, 151, 52, 87, 41, 244, 108, 178, 139, 131]), SecretKey([200, 60, 168, 128, 139, 244, 6, 225, 70, 41, 137, 209, 176, 138, 175, 61, 246, 213, 164, 169, 226, 194, 165, 215, 205, 190, 45, 13, 117, 113, 139, 82]), Seed([175, 55, 210, 40, 197, 220, 178, 34, 102, 129, 6, 109, 218, 152, 111, 236, 97, 19, 108, 175, 125, 11, 11, 165, 185, 73, 53, 175, 28, 136, 114, 156]));
/// AZB: GDAZB22RQISR5752IUS7B7KPZX5BG53DYS7KKRFGIKVI4377GX7JDHXN
static immutable AZB = KeyPair(PublicKey([193, 144, 235, 81, 130, 37, 30, 255, 186, 69, 37, 240, 253, 79, 205, 250, 19, 119, 99, 196, 190, 165, 68, 166, 66, 170, 142, 111, 255, 53, 254, 145]), SecretKey([8, 194, 150, 222, 8, 33, 185, 163, 166, 58, 114, 65, 203, 253, 223, 56, 216, 248, 138, 159, 74, 59, 45, 186, 190, 69, 40, 251, 212, 46, 224, 102]), Seed([130, 251, 36, 186, 118, 121, 151, 236, 231, 52, 1, 180, 142, 40, 144, 227, 213, 115, 165, 5, 79, 192, 141, 189, 172, 81, 250, 129, 12, 68, 106, 188]));
/// AZC: GDAZC225GLMM4PP6CPCD6WLN22X2JSGCCAG4KVPZTO6KB6MWQYHDNTLR
static immutable AZC = KeyPair(PublicKey([193, 145, 107, 93, 50, 216, 206, 61, 254, 19, 196, 63, 89, 109, 214, 175, 164, 200, 194, 16, 13, 197, 85, 249, 155, 188, 160, 249, 150, 134, 14, 54]), SecretKey([176, 75, 154, 103, 1, 57, 167, 3, 37, 228, 58, 252, 222, 88, 86, 244, 242, 134, 205, 29, 145, 169, 99, 97, 79, 217, 232, 216, 199, 38, 108, 76]), Seed([1, 36, 205, 208, 192, 161, 79, 34, 121, 188, 120, 85, 242, 90, 143, 226, 34, 113, 44, 197, 218, 17, 81, 205, 234, 142, 122, 97, 222, 128, 34, 185]));
/// AZD: GDAZD22S5CVXKFOFEK2AV2Y4EYPZTRULXCOPDMITUNM6ZQBYOO5WPLWU
static immutable AZD = KeyPair(PublicKey([193, 145, 235, 82, 232, 171, 117, 21, 197, 34, 180, 10, 235, 28, 38, 31, 153, 198, 139, 184, 156, 241, 177, 19, 163, 89, 236, 192, 56, 115, 187, 103]), SecretKey([120, 194, 220, 224, 161, 42, 59, 70, 217, 49, 107, 175, 194, 130, 229, 136, 104, 189, 230, 208, 178, 2, 135, 176, 186, 45, 190, 157, 124, 13, 72, 109]), Seed([53, 219, 70, 118, 171, 153, 204, 70, 249, 204, 68, 167, 187, 37, 239, 69, 138, 169, 207, 173, 146, 182, 164, 194, 231, 66, 90, 147, 64, 150, 166, 185]));
/// AZE: GDAZE22DUNQ6CDJDL43NRHY5GKNBZ3VNGADFY4FWFPAPNAKCBPAMWK4W
static immutable AZE = KeyPair(PublicKey([193, 146, 107, 67, 163, 97, 225, 13, 35, 95, 54, 216, 159, 29, 50, 154, 28, 238, 173, 48, 6, 92, 112, 182, 43, 192, 246, 129, 66, 11, 192, 203]), SecretKey([88, 120, 59, 90, 123, 173, 86, 232, 76, 65, 212, 46, 60, 167, 201, 187, 180, 252, 50, 33, 23, 57, 46, 58, 8, 45, 243, 147, 195, 218, 131, 90]), Seed([186, 197, 72, 10, 180, 8, 106, 33, 244, 12, 154, 152, 236, 164, 109, 201, 171, 49, 105, 73, 174, 165, 159, 199, 21, 235, 203, 254, 42, 187, 210, 75]));
/// AZF: GDAZF22TV3X3COMXXJSDH4RDFBRP4ZPB3IS2JULRLPZYRYNGAM6L2DAE
static immutable AZF = KeyPair(PublicKey([193, 146, 235, 83, 174, 239, 177, 57, 151, 186, 100, 51, 242, 35, 40, 98, 254, 101, 225, 218, 37, 164, 209, 113, 91, 243, 136, 225, 166, 3, 60, 189]), SecretKey([248, 26, 61, 213, 15, 199, 198, 242, 127, 239, 129, 171, 225, 158, 228, 162, 195, 86, 8, 101, 101, 147, 216, 60, 205, 104, 168, 180, 39, 169, 38, 69]), Seed([167, 224, 186, 237, 172, 99, 254, 136, 156, 19, 129, 79, 197, 5, 76, 182, 136, 130, 137, 48, 184, 247, 246, 86, 251, 135, 147, 92, 255, 0, 178, 161]));
/// AZG: GDAZG22Q5K2ZLLLWU3PMTNGSLLSSFPIFFC7QRTKRQFQHKC2Z3UNS3CPW
static immutable AZG = KeyPair(PublicKey([193, 147, 107, 80, 234, 181, 149, 173, 118, 166, 222, 201, 180, 210, 90, 229, 34, 189, 5, 40, 191, 8, 205, 81, 129, 96, 117, 11, 89, 221, 27, 45]), SecretKey([184, 147, 52, 209, 197, 105, 133, 114, 33, 50, 240, 174, 67, 205, 106, 172, 170, 17, 63, 203, 8, 131, 113, 144, 21, 60, 193, 44, 123, 102, 243, 83]), Seed([100, 170, 49, 142, 149, 153, 149, 147, 177, 209, 158, 10, 233, 168, 64, 235, 183, 220, 34, 97, 102, 221, 230, 45, 57, 117, 203, 251, 183, 115, 29, 214]));
/// AZH: GDAZH22FVOSPMFUIGFR62AB4XLCD2QMWV55V2ADV2F4Z44HX2IBO7U2E
static immutable AZH = KeyPair(PublicKey([193, 147, 235, 69, 171, 164, 246, 22, 136, 49, 99, 237, 0, 60, 186, 196, 61, 65, 150, 175, 123, 93, 0, 117, 209, 121, 158, 112, 247, 210, 2, 239]), SecretKey([56, 97, 14, 120, 35, 35, 67, 249, 121, 210, 127, 114, 209, 141, 138, 116, 127, 133, 87, 125, 213, 173, 69, 138, 226, 94, 190, 11, 107, 76, 192, 111]), Seed([146, 119, 44, 41, 152, 124, 51, 30, 73, 115, 138, 218, 138, 237, 222, 252, 15, 146, 220, 169, 174, 144, 178, 119, 43, 190, 112, 255, 220, 162, 136, 157]));
/// AZI: GDAZI22MSIKGJJBJC7VAKSDY3ZZHBZ4MNJGYQ7MOVYQERDIQ5FCEFDSF
static immutable AZI = KeyPair(PublicKey([193, 148, 107, 76, 146, 20, 100, 164, 41, 23, 234, 5, 72, 120, 222, 114, 112, 231, 140, 106, 77, 136, 125, 142, 174, 32, 72, 141, 16, 233, 68, 66]), SecretKey([208, 250, 135, 224, 207, 114, 98, 173, 148, 107, 19, 52, 59, 112, 212, 227, 138, 96, 134, 16, 213, 188, 100, 171, 48, 20, 113, 175, 242, 214, 27, 75]), Seed([88, 27, 173, 42, 204, 251, 131, 69, 163, 136, 124, 129, 8, 181, 133, 113, 119, 121, 30, 126, 50, 25, 138, 143, 196, 174, 198, 109, 212, 240, 238, 249]));
/// AZJ: GDAZJ22WYUXB67P7TSZ6FQUIY6WATYA54HFPM6NL24PJTOTX4EJODLFP
static immutable AZJ = KeyPair(PublicKey([193, 148, 235, 86, 197, 46, 31, 125, 255, 156, 179, 226, 194, 136, 199, 172, 9, 224, 29, 225, 202, 246, 121, 171, 215, 30, 153, 186, 119, 225, 18, 225]), SecretKey([64, 172, 127, 6, 42, 122, 185, 229, 236, 199, 195, 175, 114, 124, 203, 18, 164, 109, 0, 63, 211, 220, 170, 179, 192, 180, 144, 26, 84, 242, 4, 106]), Seed([111, 10, 187, 11, 116, 221, 223, 141, 130, 206, 147, 215, 225, 232, 112, 129, 227, 77, 54, 10, 181, 192, 3, 180, 11, 67, 83, 159, 86, 229, 99, 26]));
/// AZK: GDAZK22DZYDSWUSKIEHB3HYYHP3IF46M7HFO2V7D4LCWJ7RYSDTGGMSB
static immutable AZK = KeyPair(PublicKey([193, 149, 107, 67, 206, 7, 43, 82, 74, 65, 14, 29, 159, 24, 59, 246, 130, 243, 204, 249, 202, 237, 87, 227, 226, 197, 100, 254, 56, 144, 230, 99]), SecretKey([96, 86, 179, 235, 85, 106, 192, 40, 251, 41, 68, 108, 136, 114, 217, 161, 91, 184, 226, 10, 143, 251, 173, 2, 99, 126, 134, 90, 152, 143, 125, 101]), Seed([113, 255, 240, 76, 122, 154, 179, 30, 118, 237, 194, 243, 166, 73, 180, 78, 167, 250, 162, 30, 164, 94, 171, 173, 227, 35, 112, 217, 27, 59, 105, 46]));
/// AZL: GDAZL22AZHAFAZN32XPRJ57Y3D4SRCILR4DYB4OFL3EJIITIKPDDMUKY
static immutable AZL = KeyPair(PublicKey([193, 149, 235, 64, 201, 192, 80, 101, 187, 213, 223, 20, 247, 248, 216, 249, 40, 137, 11, 143, 7, 128, 241, 197, 94, 200, 148, 34, 104, 83, 198, 54]), SecretKey([0, 119, 101, 181, 164, 106, 24, 72, 159, 122, 247, 33, 167, 206, 77, 10, 155, 239, 162, 8, 142, 69, 163, 90, 166, 219, 17, 198, 225, 236, 87, 93]), Seed([238, 44, 203, 185, 121, 188, 50, 173, 148, 155, 44, 173, 137, 207, 41, 232, 110, 170, 140, 64, 146, 99, 84, 179, 204, 255, 15, 220, 101, 170, 31, 239]));
/// AZM: GDAZM22ZMHTEWHEAYXYZUWRCNYCCNOWUNSBGBHQZRIHRHXOBKF6I347B
static immutable AZM = KeyPair(PublicKey([193, 150, 107, 89, 97, 230, 75, 28, 128, 197, 241, 154, 90, 34, 110, 4, 38, 186, 212, 108, 130, 96, 158, 25, 138, 15, 19, 221, 193, 81, 124, 141]), SecretKey([232, 187, 72, 89, 235, 133, 9, 24, 224, 99, 246, 223, 165, 55, 223, 92, 138, 40, 147, 244, 231, 176, 143, 33, 184, 127, 107, 145, 231, 14, 27, 64]), Seed([49, 98, 85, 110, 6, 112, 230, 63, 116, 57, 90, 202, 200, 99, 181, 217, 31, 101, 126, 162, 0, 1, 136, 6, 138, 232, 28, 159, 247, 213, 0, 235]));
/// AZN: GDAZN22TJ2QU6PRRSOZGZ72JSOA745GKSGSQXRA6FEWV2UK4VZWTCFJF
static immutable AZN = KeyPair(PublicKey([193, 150, 235, 83, 78, 161, 79, 62, 49, 147, 178, 108, 255, 73, 147, 129, 254, 116, 202, 145, 165, 11, 196, 30, 41, 45, 93, 81, 92, 174, 109, 49]), SecretKey([232, 128, 50, 79, 63, 126, 68, 199, 73, 97, 119, 50, 2, 134, 147, 168, 160, 92, 112, 45, 232, 118, 122, 242, 121, 227, 205, 8, 248, 125, 153, 78]), Seed([19, 14, 163, 103, 117, 173, 8, 126, 223, 217, 143, 207, 41, 215, 192, 140, 46, 128, 42, 10, 57, 129, 245, 152, 253, 62, 177, 106, 248, 112, 116, 189]));
/// AZO: GDAZO22DOW2UT4PC42H3MZ2L65YPM6WQSD64Y44EFDKPJJML7UZCZTQ7
static immutable AZO = KeyPair(PublicKey([193, 151, 107, 67, 117, 181, 73, 241, 226, 230, 143, 182, 103, 75, 247, 112, 246, 122, 208, 144, 253, 204, 115, 132, 40, 212, 244, 165, 139, 253, 50, 44]), SecretKey([224, 151, 230, 71, 110, 193, 47, 248, 12, 138, 145, 154, 142, 133, 143, 236, 46, 119, 92, 65, 198, 102, 102, 191, 27, 82, 11, 23, 51, 105, 123, 88]), Seed([178, 70, 9, 235, 85, 170, 58, 178, 52, 172, 189, 94, 207, 129, 4, 126, 239, 90, 9, 165, 232, 171, 17, 199, 115, 252, 10, 196, 12, 44, 13, 18]));
/// AZP: GDAZP22HB6CMQ5AQR5WROOHN5QNM5XWXIWGXN43O5HVEGL3AUPRYPCQO
static immutable AZP = KeyPair(PublicKey([193, 151, 235, 71, 15, 132, 200, 116, 16, 143, 109, 23, 56, 237, 236, 26, 206, 222, 215, 69, 141, 118, 243, 110, 233, 234, 67, 47, 96, 163, 227, 135]), SecretKey([64, 158, 91, 187, 84, 0, 220, 71, 249, 41, 235, 112, 124, 204, 161, 143, 123, 165, 138, 147, 102, 62, 51, 169, 89, 88, 14, 172, 192, 69, 251, 115]), Seed([182, 194, 4, 178, 131, 52, 112, 82, 178, 227, 217, 117, 35, 132, 204, 222, 209, 181, 55, 171, 161, 239, 27, 60, 118, 253, 39, 119, 2, 74, 103, 234]));
/// AZQ: GDAZQ22CSMOMHPUKVTWFJXVVNLDJOALMOX75AKEW22FYXQNNTRLZQHK5
static immutable AZQ = KeyPair(PublicKey([193, 152, 107, 66, 147, 28, 195, 190, 138, 172, 236, 84, 222, 181, 106, 198, 151, 1, 108, 117, 255, 208, 40, 150, 214, 139, 139, 193, 173, 156, 87, 152]), SecretKey([40, 17, 142, 74, 18, 201, 169, 202, 94, 43, 64, 17, 95, 116, 240, 77, 238, 109, 133, 213, 99, 200, 220, 2, 2, 238, 38, 114, 118, 34, 140, 77]), Seed([169, 29, 212, 91, 85, 213, 25, 36, 103, 7, 63, 29, 180, 77, 182, 221, 169, 156, 57, 72, 63, 116, 55, 198, 80, 10, 175, 79, 197, 221, 95, 165]));
/// AZR: GDAZR22J7MOIZY5YCCUIDDNEHFLAMO6DYFVD4JAETPY5DYSVXM4AKXWJ
static immutable AZR = KeyPair(PublicKey([193, 152, 235, 73, 251, 28, 140, 227, 184, 16, 168, 129, 141, 164, 57, 86, 6, 59, 195, 193, 106, 62, 36, 4, 155, 241, 209, 226, 85, 187, 56, 5]), SecretKey([64, 118, 78, 14, 108, 6, 187, 99, 64, 7, 144, 132, 124, 106, 184, 189, 85, 168, 61, 86, 86, 143, 226, 123, 23, 12, 197, 231, 157, 40, 77, 78]), Seed([55, 192, 132, 61, 145, 35, 123, 159, 48, 93, 251, 53, 235, 155, 147, 233, 100, 114, 63, 22, 86, 141, 5, 25, 145, 99, 178, 157, 93, 232, 15, 39]));
/// AZS: GDAZS225PLXKUHQYDVPHX5ZIABA4AFM74IMHQE45FD2YJ6JKLTGWOWVX
static immutable AZS = KeyPair(PublicKey([193, 153, 107, 93, 122, 238, 170, 30, 24, 29, 94, 123, 247, 40, 0, 65, 192, 21, 159, 226, 24, 120, 19, 157, 40, 245, 132, 249, 42, 92, 205, 103]), SecretKey([224, 55, 231, 27, 160, 136, 141, 75, 62, 65, 165, 177, 38, 82, 19, 213, 134, 152, 68, 171, 245, 154, 116, 187, 164, 146, 173, 29, 116, 194, 186, 109]), Seed([247, 36, 104, 146, 91, 122, 31, 220, 221, 92, 55, 51, 187, 28, 217, 231, 31, 67, 46, 122, 222, 14, 154, 75, 237, 35, 171, 144, 96, 172, 11, 96]));
/// AZT: GDAZT22YGUVUG6WGNKAETQVU2NRVRBLUFSNBQSUIFWFXNOZUHKIW4VEJ
static immutable AZT = KeyPair(PublicKey([193, 153, 235, 88, 53, 43, 67, 122, 198, 106, 128, 73, 194, 180, 211, 99, 88, 133, 116, 44, 154, 24, 74, 136, 45, 139, 118, 187, 52, 58, 145, 110]), SecretKey([72, 155, 184, 112, 214, 185, 248, 16, 22, 133, 39, 233, 170, 21, 234, 84, 8, 23, 55, 187, 159, 36, 139, 222, 15, 19, 205, 59, 123, 182, 133, 64]), Seed([127, 18, 58, 21, 209, 8, 216, 151, 213, 216, 202, 192, 190, 229, 195, 240, 31, 187, 137, 212, 209, 223, 205, 222, 153, 117, 114, 106, 165, 15, 224, 12]));
/// AZU: GDAZU22ZMAUAIUFW5CAVTF5EJC2VEAFTMPHEME3PWPGQBYJE7V4RRF7G
static immutable AZU = KeyPair(PublicKey([193, 154, 107, 89, 96, 40, 4, 80, 182, 232, 129, 89, 151, 164, 72, 181, 82, 0, 179, 99, 206, 70, 19, 111, 179, 205, 0, 225, 36, 253, 121, 24]), SecretKey([80, 255, 158, 186, 238, 197, 249, 118, 110, 104, 169, 97, 2, 209, 35, 116, 219, 169, 92, 96, 76, 149, 69, 17, 106, 173, 179, 254, 151, 180, 111, 92]), Seed([86, 191, 254, 195, 207, 137, 190, 20, 91, 162, 24, 117, 255, 115, 47, 135, 34, 146, 123, 201, 230, 55, 184, 178, 42, 53, 50, 254, 91, 7, 245, 240]));
/// AZV: GDAZV22PDEWR2MHAHOCGQJJWH7PP753XE4QIMPRJQ2HT4O43MIZKPH2C
static immutable AZV = KeyPair(PublicKey([193, 154, 235, 79, 25, 45, 29, 48, 224, 59, 132, 104, 37, 54, 63, 222, 255, 247, 119, 39, 32, 134, 62, 41, 134, 143, 62, 59, 155, 98, 50, 167]), SecretKey([72, 6, 30, 189, 1, 24, 143, 58, 3, 140, 76, 41, 218, 56, 101, 249, 231, 128, 184, 234, 91, 116, 220, 81, 46, 112, 31, 241, 156, 108, 2, 120]), Seed([31, 150, 36, 201, 175, 99, 129, 91, 161, 244, 79, 223, 113, 241, 179, 151, 48, 122, 7, 137, 103, 244, 81, 32, 236, 246, 175, 226, 208, 191, 100, 38]));
/// AZW: GDAZW22LOTUUPMFPKSXS3Q7AMYDVNMHZ3CGY6KRZ6DGPDOUBZ7LDKHCR
static immutable AZW = KeyPair(PublicKey([193, 155, 107, 75, 116, 233, 71, 176, 175, 84, 175, 45, 195, 224, 102, 7, 86, 176, 249, 216, 141, 143, 42, 57, 240, 204, 241, 186, 129, 207, 214, 53]), SecretKey([72, 164, 97, 239, 120, 14, 109, 203, 162, 167, 42, 139, 220, 110, 40, 195, 2, 77, 241, 92, 246, 47, 84, 86, 27, 162, 156, 142, 115, 226, 124, 90]), Seed([213, 11, 166, 83, 52, 157, 183, 154, 134, 132, 27, 97, 87, 165, 199, 19, 243, 79, 9, 141, 89, 121, 59, 198, 160, 222, 151, 130, 148, 158, 115, 129]));
/// AZX: GDAZX227L5NEOFYO6IRZOHPLWK22VZO5CC5D5LCB5KCBCMKR65WJPGMO
static immutable AZX = KeyPair(PublicKey([193, 155, 235, 95, 95, 90, 71, 23, 14, 242, 35, 151, 29, 235, 178, 181, 170, 229, 221, 16, 186, 62, 172, 65, 234, 132, 17, 49, 81, 247, 108, 151]), SecretKey([232, 69, 7, 122, 54, 72, 143, 25, 157, 195, 30, 190, 114, 106, 42, 29, 80, 226, 116, 102, 188, 77, 153, 89, 93, 21, 34, 12, 12, 167, 153, 74]), Seed([174, 252, 45, 69, 205, 126, 146, 138, 93, 253, 155, 94, 147, 31, 88, 50, 33, 85, 28, 166, 206, 170, 76, 41, 44, 241, 200, 194, 50, 96, 212, 250]));
/// AZY: GDAZY224VHVY53OC64K5GKUEKFM3BAX35ZS5KE7PD3GIEOXYQZRIA3OY
static immutable AZY = KeyPair(PublicKey([193, 156, 107, 92, 169, 235, 142, 237, 194, 247, 21, 211, 42, 132, 81, 89, 176, 130, 251, 238, 101, 213, 19, 239, 30, 204, 130, 58, 248, 134, 98, 128]), SecretKey([152, 34, 34, 178, 249, 230, 115, 183, 173, 43, 9, 98, 38, 126, 10, 223, 212, 59, 49, 146, 112, 196, 103, 110, 125, 120, 38, 9, 91, 170, 108, 106]), Seed([245, 171, 239, 182, 148, 73, 96, 105, 29, 245, 167, 28, 59, 203, 170, 157, 158, 237, 171, 50, 135, 226, 209, 2, 23, 35, 204, 244, 19, 51, 55, 28]));
/// AZZ: GDAZZ22CIYSZE2TZB74EUFZ2WBONRMYX7DLR5TUU7V3RIJ5YIAS6FF53
static immutable AZZ = KeyPair(PublicKey([193, 156, 235, 66, 70, 37, 146, 106, 121, 15, 248, 74, 23, 58, 176, 92, 216, 179, 23, 248, 215, 30, 206, 148, 253, 119, 20, 39, 184, 64, 37, 226]), SecretKey([40, 128, 246, 20, 33, 212, 54, 156, 152, 13, 219, 139, 26, 79, 250, 143, 241, 54, 180, 209, 121, 221, 133, 31, 28, 13, 76, 232, 25, 111, 26, 94]), Seed([156, 227, 190, 123, 229, 195, 6, 165, 176, 111, 49, 151, 155, 8, 157, 98, 44, 104, 43, 238, 64, 218, 98, 24, 79, 156, 68, 32, 20, 136, 201, 224]));

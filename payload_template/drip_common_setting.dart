var dripCommonSettings = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Drip Common Scan",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": 'OF', "SF": "VALVE", "TT": "Valve", "HF": '1'},
        {"SN": 2, "WT": 2, "VAL": 'OF', "SF": "VALFB", "TT": "Valve Feedback", "HF": '1'},
        {"SN": 3, "WT": 2, "VAL": 'OF', "SF": "COILFBK", "TT": "Coil Feedback", "HF": '1'},
        {"SN": 4, "WT": 2, "VAL": 'OF', "SF": "VCOILFBK", "TT": "Coil Feedback View", "HF": '1'},
        {"SN": 5, "WT": 2, "VAL": 'OF', "SF": "COUNTCTRL", "TT": "Count Control", "HF": '1'},
        {"SN": 6, "WT": 2, "VAL": 'OF', "SF": "DELVALFB", "TT": "Valve Feedback Check", "HF": '1'},
        {"SN": 7, "WT": 2, "VAL": 'OF', "SF": "REFRESH", "TT": "Refresh Valve", "HF": '1'},
        {"SN": 8, "WT": 2, "VAL": 'OF', "SF": "CYCRST", "TT": "Zone Cyclic Restart", "HF": '1'},
        {"SN": 9, "WT": 2, "VAL": 'OF', "SF": "CANFLAG", "TT": "CAN Flag", "HF": '1'},
        {"SN": 10, "WT": 2, "VAL": 'OF', "SF": "NOCOMM", "TT": "No Communication", "HF": '1'},
        {"SN": 11, "WT": 2, "VAL": 'OF', "SF": "MANUALSWITCH", "TT": "Manual Switch", "HF": '1'},
        {"SN": 12, "WT": 2, "VAL": 'OF', "SF": "MANUAL", "TT": "Manual Mode", "HF": '1'},
        {"SN": 13, "WT": 2, "VAL": 'OF', "SF": "PWRVB", "TT": "Power Voice Feedback", "HF": '1'}
      ]
    },
    {
      "TID": 2,
      "NAME": "Valve Message",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": 'OF', "SF": "VALVEMSG", "TT": "Valve Message", "HF": '1'},
        {"SN": 2, "WT": 3, "VAL": '00:00:00', "SF": "VALVEDELMSGTIM", "TT": "Valve Message Timer", "HF": '1'}
      ]

    },
    {
      "TID": 3,
      "NAME": "Drip Cyclic Restart",
      "SETS": [

        {"SN": 1, "WT": 2, "VAL": 'OF', "SF": "DRIPCYCRST", "TT": "Drip Cyclic Restart", "HF": '1'},
        {"SN": 2, "WT": 3, "VAL": '00:00:00', "SF": "", "TT": "Drip Cyclic Restart Timer", "HF": '1'},
      ]

    },
    {
      "TID": 4,
      "NAME": "Calculated Flow",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": 'OF', "SF": "CALFLOWRATE", "TT": "Calculated Flow", "HF": '1'},
        {"SN": 2, "WT": 10, "VAL": '0', "SF": "CALFLOW2", "TT": "2 Phase", "HF": '1'},
        {"SN": 3, "WT": 10, "VAL": '0', "SF": "CALFLOW3", "TT": "3 Phase", "HF": '1'},
      ]
    },
    {
      "TID": 5,
      "NAME": "Zone Settings",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": '0', "SF": "DECIDELAST", "TT": "Last Zone", "HF": '1'},
        {"SN": 2, "WT": 9, "VAL": '0', "SF": "DECIDEFBLAST", "TT": "FB Last Zone", "HF": '1'},
        {"SN": 3, "WT": 3, "VAL": '00:00', "SF": "DELVALTIM", "TT": "Delay Valve", "HF": '1'},
        {"SN": 4, "WT": 3, "VAL": '00:00', "SF": "DELFBKTIM", "TT": "Delay Feedback", "HF": '1'},
        {"SN": 5, "WT": 3, "VAL": '00:00', "SF": "DELFERTTIM", "TT": "Delay Fertilizer", "HF": '1'},
        {"SN": 6, "WT": 3, "VAL": '00:00', "SF": "DELMIXTIM", "TT": "Mixer Delay", "HF": '1'},
        {"SN": 7, "WT": 11, "VAL": '', "SF": "DELMIX", "TT": "Delay View", "HF": '1'},
      ]

    },
    {
      "TID": 6,
      "NAME": "Pressure Settings",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": 'OF', "SF": "PRESSURE", "TT": "Pressure", "HF": '1'},
        {"SN": 2, "WT": 2, "VAL": 'OF', "SF": "HIGHPRESS", "TT": "High Pressure", "HF": '1'},
        {"SN": 3, "WT": 10, "VAL": '0.0', "SF": "HIGHPRESS", "TT": "High Pressure Value", "HF": '1'},
        {"SN": 4, "WT": 2, "VAL": 'OF', "SF": "LOWPRESS", "TT": "Low Pressure", "HF": '1'},
        {"SN": 5, "WT": 10, "VAL": '0.0', "SF": "LOWPRESS", "TT": "Low Pressure Value", "HF": '1'},
        {"SN": 6, "WT": 3, "VAL": '00:00', "SF": "PSWITCHCNT", "TT": "Pressure Switch Delay", "HF": '1'},
        {"SN": 7, "WT": 11, "VAL": '', "SF": "CALPRESS", "TT": "Pressure Calibration", "HF": '1'},
        {"SN": 8, "WT": 10, "VAL": '0.00', "SF": "IDCALSET001", "TT": "Sensor 1 Cal", "HF": '1'},
        {"SN": 9, "WT": 10, "VAL": '0.00', "SF": "IDCALSET003", "TT": "Sensor 2 Cal", "HF": '1'},
        {"SN": 10, "WT": 8, "VAL": '0;0', "SF": "CALPRESS", "TT": "Cal Pres 1;Cal Pres 2", "HF": '1;1', 'OPTION': '0;10;12'},
      ]
    },
  ],
};

var programCommonSettings = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Common Settings",
      "SETS": [
        {"SN": 1, "WT": 8, "VAL": "Program 1", "SF": "PROGSEL1;PROGSEL2;PROGSEL3;PROGSEL4;PROGSEL5;PROGSEL6", "TT": "Select Program", "HF": '1', "OPTION": "Program 1;Program 2;Program 3;Program 4;Program 5;Program 6"},
        {"SN": 2, "WT": 8, "VAL": "Timer Mode", "SF": "TIMERMODEONP;FLOWMODEONP;MOISTUREMODEONP;LEVELMODEONP", "TT": "Irrigation", "HF": '1', "OPTION": "Timer Mode;Flow Mode;Moisture Mode;Level Mode"},
        {"SN": 3, "WT": 8, "VAL": "Timer Mode", "SF": "TIMERFERTONP;TIMERPROPFERTONP;FLOWFERTONP;FLOWPROPFERTONP", "TT": "Dosing", "HF": '1', "OPTION": "Timer Mode;Timer Prop Mode;Flow Mode;Flow Prop Mode"},
      ]
    },
    {
      "TID": 2,
      "NAME": "Fertilizer",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF;OF;OF;OF;OF;OF", "SF": "FERTONOF", "TT": "F1;F2;F3;F4;F5;F6", "HF": '1;1;1;1;1;1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Vent Flow",
      "SETS": [
        {"SN": 1, "WT": 10, "VAL": "000.0;000.0;000.0;000.0;000.0;000.0", "SF": "VENTUREFLOWP", "TT": "F1;F2;F3;F4;F5;F6", "HF": '1;1;1;1;1;1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Blower Settings",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": 'OF', "SF": "FANRTC", "TT": "Blower RTC Mode", "HF": '1'},
        {"SN": 2, "WT": 3, "VAL": '00:00;00:00', "SF": "FANRTCTIM", "TT": "RTC On Time;RTC Off Time", "HF": '1;1'},
        {"SN": 3, "WT": 3, "VAL": '00:00;00:00', "SF": "FANCYCLICTIM", "TT": "Cyclic On Time;Cyclic Off Time", "HF": '1;1'},
      ]
    },
  ],
};

var adjustPercent = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Program 1",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "ADJPERCENTP1", "TT": "Timer;Flow;Moisture;Fertilizer", "HF": '1;1;1;1'},
      ]
    },
    {
      "TID": 2,
      "NAME": "Program 2",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "ADJPERCENTP2", "TT": "Timer;Flow;Moisture;Fertilizer", "HF": '1;1;1;1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Program 3",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "ADJPERCENTP3", "TT": "Timer;Flow;Moisture;Fertilizer", "HF": '1;1;1;1'},
      ]
    },
    {
      "TID": 4,
      "NAME": "Program 4",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "ADJPERCENTP4", "TT": "Timer;Flow;Moisture;Fertilizer", "HF": '1;1;1;1'},
      ]
    },
    {
      "TID": 5,
      "NAME": "Program 5",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "ADJPERCENTP5", "TT": "Timer;Flow;Moisture;Fertilizer", "HF": '1;1;1;1'},
      ]
    },
    {
      "TID": 6,
      "NAME": "Program 6",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "ADJPERCENTP6", "TT": "Timer;Flow;Moisture;Fertilizer", "HF": '1;1;1;1'},
      ]
    },
  ],
};

var changeFrom = {
  'settings' : [
    {
      "TID": 1,
      "NAME": "Change From",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL":'1', "SF": "CHANGEFROM", "TT": "Change From", "HF": '1'},
      ]
    },
  ]
};

var backwash = {
  'settings': [
    {
      "TID": 1,
      "NAME": "Filter Settings",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF;OF;OF;OF", "SF": "REFRESHONOF", "TT": "SAN filter 1;SAN filter 2;DISK filter 1;DISK filter 2", "HF": '1;1;1;1'},
        {"SN": 2, "WT": 2, "VAL": "OF", "SF": "CYCLICFILTER", "TT": "Cyclic Filter", "HF": '1'},
        {"SN": 3, "WT": 2, "VAL": "OF", "SF": "AUTOBCKWASH", "TT": "Auto Back Wash", "HF": '1'},
        {"SN": 4, "WT": 10, "VAL": "0.0", "SF": "PRESSURELIMIT", "TT": "Pressure Limit", "HF": '1'},
      ]
    },
    {
      "TID": 2,
      "NAME": "On Time",
      "SETS": [
        {"SN": 1, "WT": 3, "VAL": "00:00:00;00:00:00;00:00:00;00:00:00", "SF": "REFTIMON", "TT": "SAN filter 1;SAN filter 2;DISK filter 1;DISK filter 2", "HF": '1;1;1;1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Off Time",
      "SETS": [
        {"SN": 1, "WT": 3, "VAL": "00:00:00", "SF": "REFTIMOF", "TT": "Filter off time", "HF": '1'},
      ]
    },
  ]
};

var pumpChangeOver = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Pump Change Over",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "POWER1", "TT": "Relay 1", "HF": '1'},
        {"SN": 2, "WT": 2, "VAL": "OF", "SF": "MOTOR2", "TT": "Relay 2", "HF": '1'},
        {"SN": 3, "WT": 2, "VAL": "OF", "SF": "MOTOR3", "TT": "Relay 3", "HF": '1'},
        {"SN": 4, "WT": 2, "VAL": "OF", "SF": "MOTOR4", "TT": "Relay 4", "HF": '1'},
        {"SN": 5, "WT": 2, "VAL": "OF", "SF": "MOTOR4CTRLOF", "TT": "Relay 4 Auto Mode", "HF": '1'},
      ]
    },
  ]
};

var dripSumpSettings = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Sump Settings",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "SUMP", "TT": "Sump Level Scan", "HF": '1'},
        {"SN": 2, "WT": 2, "VAL": "OF", "SF": "SUMPRST", "TT": "Sump Restart", "HF": '1'},
        {"SN": 3, "WT": 2, "VAL": "OF", "SF": "TANK", "TT": "Tank Scan", "HF": '1'},
        {"SN": 4, "WT": 2, "VAL": "OF", "SF": "LOWTANKRESTART", "TT": "Lower Tank Restart", "HF": '1'},
      ]
    },
    {
      "TID": 2,
      "NAME": "Drip Sump Settings",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0", "SF": "IDCALSET002", "TT": "ID cal set", "HF": '1'},
        {"SN": 2, "WT": 9, "VAL": "0", "SF": "SETTANKHEIGH", "TT": "Set Tank Height", "HF": '1'},
      ]
    },
  ]
};

var moistureLevel = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Program 1",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "Moisture,", "TT": "High Level;Low Level", "HF": '1;1'},
      ]
    },
    {
      "TID": 2,
      "NAME": "Program 2",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "Moisture,", "TT": "High Level;Low Level", "HF": '1;1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Program 3",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "Moisture,", "TT": "High Level;Low Level", "HF": '1;1'},
      ]
    },
    {
      "TID": 4,
      "NAME": "Program 4",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "Moisture,", "TT": "High Level;Low Level", "HF": '1;1'},
      ]
    },
    {
      "TID": 5,
      "NAME": "Program 5",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "Moisture,", "TT": "High Level;Low Level", "HF": '1;1'},
      ]
    },
    {
      "TID": 6,
      "NAME": "Program 6",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "Moisture,", "TT": "High Level;Low Level", "HF": '1;1'},
      ]
    },

  ],
};

var valveFlow = {
  'settings': [
    {
      'QRCode': "",
      'nodeName': "",
      'categoryName': "",
      'nodeId': 0000,
      'serialNo': "",
      'value': "",
    },
    {
      'QRCode': "",
      'nodeName': "",
      'categoryName': "",
      'nodeId': 0000,
      'serialNo': "",
      'value': "",
    },
    {
      'QRCode': "",
      'nodeName': "",
      'categoryName': "",
      'nodeId': 0000,
      'serialNo': "",
      'value': "",
    },
  ]
};

var dayCountRtc = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Day Count",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "SKIPDAY", "TT": "Skip Days Scan", "HF": '1'},
        {"SN": 2, "WT": 9, "VAL": "0", "SF": "SKIPDAYS", "TT": "Skip Days", "HF": '1'},
        {"SN": 3, "WT": 9, "VAL": "0", "SF": "RUNDAYS", "TT": "Run Days", "HF": '1'},
        {"SN": 4, "WT": 3, "VAL": "00:00", "SF": "DAYCOUNTRTCTIM,", "TT": "Day Count RTC", "HF": '1'},
      ]
    },
    {
      "TID": 2,
      "NAME": "Program Cycle Selection",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0", "SF": "PROGSTART", "TT": "Program;Zone", "HF": '1;1'},
        {"SN": 2, "WT": 2, "VAL": "OF", "SF": "PROQUE", "TT": "Program Cycle", "HF": '1'},
        {"SN": 3, "WT": 2, "VAL": "OF", "SF": "QUERST", "TT": "Queue Cycle", "HF": '1'},
        {"SN": 4, "WT": 9, "VAL": "0;0;0;0;0;0", "SF": "PROQUE,", "TT": "Programs", "HF": '1;1;1;1;1;1'},
        {"SN": 5, "WT": 3, "VAL": "00:00", "SF": "QRSRRIM1,", "TT": "Queue Rst Time 1", "HF": '1'},
        {"SN": 6, "WT": 3, "VAL": "00:00", "SF": "QRSRRIM2,", "TT": "Queue Rst Time 2", "HF": '1'},
        {"SN": 7, "WT": 3, "VAL": "00:00", "SF": "QRSRRIM3,", "TT": "Queue Rst Time 3", "HF": '1'},
        {"SN": 8, "WT": 3, "VAL": "00:00", "SF": "QRSRRIM4,", "TT": "Queue Rst Time 4", "HF": '1'},
        {"SN": 9, "WT": 3, "VAL": "00:00", "SF": "QRSRRIM5,", "TT": "Queue Rst Time 5", "HF": '1'},
        {"SN": 10, "WT": 3, "VAL": "00:00", "SF": "QRSRRIM6,", "TT": "Queue Rst Time 6", "HF": '1'},
      ]
    },
  ]
};

var ecPh = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Ec",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "EC", "TT": "EC Status", "HF": '1'},
        {"SN": 2, "WT": 9, "VAL": "0;0", "SF": "ECSET,", "TT": "Ec High;Ec Low", "HF": '1;1'},
        {"SN": 3, "WT": 2, "VAL": "OF", "SF": "ECHIGH,", "TT": "Ec High On Off", "HF": '1'},
        {"SN": 4, "WT": 3, "VAL": "00:00", "SF": "ECHIGHSCAN,", "TT": "Ec High Scan", "HF": '1'},
        {"SN": 5, "WT": 2, "VAL": "OF", "SF": "ECLOW,", "TT": "Ec Low On Off", "HF": '1'},
        {"SN": 6, "WT": 3, "VAL": "00:00", "SF": "ECLOWSCAN,", "TT": "Ec Low Scan", "HF": '1'},
        {"SN": 7, "WT": 9, "VAL": "0", "SF": "IDCALSET004,", "TT": "Ec Call Set", "HF": '1'},

      ]
    },
    {
      "TID": 2,
      "NAME": "Ph",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "PH", "TT": "PH Status", "HF": '1'},
        {"SN": 2, "WT": 9, "VAL": "0;0", "SF": "PHSET,", "TT": "Ph High;Ph Low", "HF": '1;1'},
        {"SN": 3, "WT": 2, "VAL": "OF", "SF": "PHHIGH,", "TT": "Ph High On Off", "HF": '1'},
        {"SN": 4, "WT": 3, "VAL": "00:00", "SF": "PHHIGHSCAN,", "TT": "Ph High Scan", "HF": '1'},
        {"SN": 5, "WT": 2, "VAL": "OF", "SF": "PHLOW,", "TT": "Ph Low On Off", "HF": '1'},
        {"SN": 6, "WT": 3, "VAL": "00:00", "SF": "PHLOWSCAN,", "TT": "Ph Low Scan", "HF": '1'},
        {"SN": 7, "WT": 9, "VAL": "0", "SF": "IDCALSET005,", "TT": "Ph Call Set", "HF": '1'},

      ]
    },
    {
      "TID": 3,
      "NAME": "High Flow",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "HIGHFLOW", "TT": "High Flow", "HF": '1'},
        {"SN": 2, "WT": 3, "VAL": "00:00", "SF": "HIGHFLOWSCAN,", "TT": "High Flow Scan", "HF": '1'},
      ]
    },
    {
      "TID": 4,
      "NAME": "Low Flow",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "LOWFLOW", "TT": "Low Flow", "HF": '1'},
        {"SN": 2, "WT": 3, "VAL": "00:00", "SF": "LOWFLOWSCAN,", "TT": "Low Flow Scan", "HF": '1'},
      ]
    },
    {
      "TID": 5,
      "NAME": "Low Flow",
      "SETS": [
        {"SN": 1, "WT": 2, "VAL": "OF", "SF": "NOFLOW", "TT": "No Flow", "HF": '1'},
        {"SN": 2, "WT": 3, "VAL": "00:00", "SF": "NOFLOWSCAN,", "TT": "No Flow Scan", "HF": '1'},
      ]
    },
  ]
};

var pumpConfiguration = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Pump Configuration",
      "SETS": [
        {"SN": 1, "WT": 9, "VAL": "0;0;0;0", "SF": "PUMPCONFIG,", "TT": "PUMP 1 FLOW;PUMP 2 FLOW;PUMP 3 FLOW;PUMP 4 FLOW", "HF": '1;1;1;1'},
      ]
    },

  ],
};

var alarm = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Alarms",
      "SETS": [
        {"SN": 1, "WT": 8, "VAL": "HIGH FLOW", "SF": "", "TT": "Alarm Type", "HF": '1', "OPTION": "HIGH FLOW;LOW FLOW;NO FLOW;EC HIGH;EC LOW;PH HIGH;PH LOW"},
        {"SN": 2, "WT": 2, "VAL": "OF", "SF": "", "TT": "Alarm Activate", "HF": '1'},
        {"SN": 3, "WT": 3, "VAL": "00:00", "SF": "", "TT": "Alarm Delay", "HF": '1'},
        {"SN": 4, "WT": 2, "VAL": "OF", "SF": "", "TT": "Irrigation Stop", "HF": '1'},
        {"SN": 5, "WT": 2, "VAL": "OF", "SF": "", "TT": "Dosing Stop", "HF": '1'},
        {"SN": 6, "WT": 10, "VAL": "0.0", "SF": "", "TT": "Set Threshold", "HF": '1'},
        {"SN": 7, "WT": 2, "VAL": "OF", "SF": "", "TT": "Reset After Complete", "HF": '1'},
        {"SN": 8, "WT": 8, "VAL": "1", "SF": "", "TT": "Auto Reset Duration", "HF": '1', "OPTION": '1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24'},
      ]
    },

  ],
};


// text field int = 9;
// text field double = 10;
// view command = 11;
// timer = 3;
// switch = 2;
// drop down = 8;
var dripCommonSettings = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Drip Common Scan",
      "SETS": [
        { "WT": 2, "VAL": 'OF', "SF": "VALVE", "TT": "Valve", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "VALFB", "TT": "Valve Feedback", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "COILFBK", "TT": "Coil Feedback", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "VCOILFBK", "TT": "Coil Feedback View", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "COUNTCTRL", "TT": "Count Control", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "DELVALFB", "TT": "Valve Feedback Check", "HF": '1' }, // required
        { "WT": 2, "VAL": 'OF', "SF": "REFRESH", "TT": "Refresh Valve", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "CYCRST", "TT": "Zone Cyclic Restart", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "CANFLAG", "TT": "CAN Flag", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "NOCOMM", "TT": "No Communication", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "MANUALSWITCH", "TT": "Manual Switch", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "MANUAL", "TT": "Manual Mode", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "PWRVB", "TT": "Power Voice Feedback", "HF": '1' }
      ]
    },
    {
      "TID": 2,
      "NAME": "Valve Message",
      "SETS": [
        { "WT": 2, "VAL": 'OF', "SF": "VALVEMSG", "TT": "Valve Message", "HF": '1' },
        { "WT": 3, "VAL": '00:00:00', "SF": "VALVEDELMSGTIM", "TT": "Valve Message Timer", "HF": '1' }
      ]

    },
    {
      "TID": 3,
      "NAME": "Drip Cyclic Restart",
      "SETS": [

        { "WT": 2, "VAL": 'OF', "SF": "DRIPCYCRST", "TT": "Drip Cyclic Restart", "HF": '1' },
        { "WT": 3, "VAL": '00:00:00', "SF": "", "TT": "Drip Cyclic Restart Timer", "HF": '1' }, // required
      ]

    },
    {
      "TID": 4,
      "NAME": "Calculated Flow",
      "SETS": [
        {"WT": 2, "VAL": 'OF', "SF": "CALFLOWRATE", "TT": "Calculated Flow", "HF": '1'},
        {"WT": 9, "VAL": '0', "SF": "CALFLOW2", "TT": "2 Phase", "HF": '1'},
        {"WT": 9, "VAL": '0', "SF": "CALFLOW3", "TT": "3 Phase", "HF": '1'},
      ]
    },
    {
      "TID": 5,
      "NAME": "Zone Settings",
      "SETS": [
        { "WT": 9, "VAL": '0', "SF": "DECIDELAST", "TT": "Last Zone", "HF": '1' },
        { "WT": 9, "VAL": '0', "SF": "DECIDEFBLAST", "TT": "FB Last Zone", "HF": '1' },
        { "WT": 3, "VAL": '00:00', "SF": "DELVALTIM", "TT": "Delay Valve", "HF": '1' },
        { "WT": 3, "VAL": '00:00', "SF": "DELFBKTIM", "TT": "Delay Feedback", "HF": '1' },
        { "WT": 3, "VAL": '00:00', "SF": "DELFERTTIM", "TT": "Delay Fertilizer", "HF": '1' },
        { "WT": 3, "VAL": '00:00', "SF": "DELMIXTIM", "TT": "Mixer Delay", "HF": '1' },
        { "WT": 11, "VAL": '', "SF": "DELMIX", "TT": "Delay View", "HF": '1' }, // view command required
      ]

    },
    {
      "TID": 6,
      "NAME": "Pressure Settings",
      "SETS": [
        { "WT": 2, "VAL": 'OF', "SF": "PRESSURE", "TT": "Pressure", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "HIGHPRESS", "TT": "High Pressure", "HF": '1' },
        { "WT": 10, "VAL": '0.0', "SF": "HIGHPRESS", "TT": "High Pressure Value", "HF": '1' },
        { "WT": 2, "VAL": 'OF', "SF": "LOWPRESS", "TT": "Low Pressure", "HF": '1' },
        { "WT": 10, "VAL": '0.0', "SF": "LOWPRESS", "TT": "Low Pressure Value", "HF": '1' },
        { "WT": 3, "VAL": '00:00', "SF": "PSWITCHCNT", "TT": "Pressure Switch Delay", "HF": '1' },
        { "WT": 11, "VAL": '', "SF": "CALPRESS", "TT": "Pressure Calibration", "HF": '1' },
        { "WT": 10, "VAL": '0.00', "SF": "IDCALSET001", "TT": "Sensor 1 Cal", "HF": '1' },
        { "WT": 10, "VAL": '0.00', "SF": "IDCALSET003", "TT": "Sensor 2 Cal", "HF": '1' },
        { "WT": 8, "VAL": '0;0', "SF": "CALPRESS", "TT": "Cal Pres 1;Cal Pres 2", "HF": '1' },
      ]
    },
  ],
  "option" : [
    {
      "SN" : 1,
      'OPTION': [
        {"SN": 1, "VAL": "0", "SF" : "CALPRESS"},
        {"SN": 2, "VAL": "10", "SF" : "CALPRESS"},
        {"SN": 3, "VAL": "12", "SF" : "CALPRESS"},
      ]
    },
  ]
};

var programCommonSettings = {
  "settings" : [
    {
      "TID": 1,
      "NAME": "Common Settings",
      "SETS": [
        { "WT": 8, "VAL": 1, "SF": "", "TT": "Select Program", "HF": '1', "OPTION": 1},
        { "WT": 8, "VAL": 1, "SF": "", "TT": "Irrigation", "HF": '1', "OPTION": 2},
        { "WT": 8, "VAL": 1, "SF": "", "TT": "Dosing", "HF": '1', "OPTION": 3},
      ]
    },
    {
      "TID": 2,
      "NAME": "Fertilizer",
      "SETS": [
        { "WT": 2, "VAL": "0;0;0;0;0;0", "SF": "FERTOBOF", "TT": "F1;F2;F3;F4;F5;F6", "HF": '1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Vent Flow",
      "SETS": [
        { "WT": 10, "VAL": "000.0;000.0;000.0;000.0;000.0;000.0", "SF": "VENTUREFLOWP", "TT": "F1;F2;F3;F4;F5;F6", "HF": '1'},
      ]
    },
    {
      "TID": 3,
      "NAME": "Blower Settings",
      "SETS": [
        { "WT": 2, "VAL": '0', "SF": "FANRTC", "TT": "Blower RTC Mode", "HF": '1', "OPTION": 0},
        { "WT": 3, "VAL": '00:00;00:00', "SF": "FANRTCTIM", "TT": "RTC On Time;RTC Off Time", "HF": '1', "OPTION": 0},
        { "WT": 3, "VAL": '00:00;00:00', "SF": "FANCYCLICTIM", "TT": "Cyclic On Time;Cyclic Off Time", "HF": '1', "OPTION": 0},
      ]
    },
  ],
  "options": [
    {
      "SN" : 1,
      'OPTION': [
        {"SN": 1, "VAL": "program 1", "SF" : "PROGSEL"},
        {"SN": 2, "VAL": "program 2", "SF" : "PROGSEL"},
        {"SN": 3, "VAL": "program 3", "SF" : "PROGSEL"},
        {"SN": 4, "VAL": "program 4", "SF" : "PROGSEL"},
        {"SN": 5, "VAL": "program 5", "SF" : "PROGSEL"},
        {"SN": 6, "VAL": "program 6", "SF" : "PROGSEL"},
      ]
    },
    {
      "SN" : 2,
      'OPTION': [
        {"SN": 1, "VAL": "Timer Mode", "SF" : "TIMERMODEONP"},
        {"SN": 2, "VAL": "Flow Mode", "SF" : "FLOWMODEONP"},
        {"SN": 3, "VAL": "Moisture Mode", "SF" : "MOISTUREMODEONP"},
        {"SN": 4, "VAL": "Level Mode", "SF" : "LEVELMODEONP"},
      ]
    },
    {
      "SN" : 3,
      'OPTION': [
        {"SN": 1, "VAL": "Timer Mode", "SF": "TIMERFERTONP"},
        {"SN": 2, "VAL": "Timer Prop Mode", "SF": "TIMERPROPFERTONP"},
        {"SN": 3, "VAL": "Flow Mode", "SF": "FLOWFERTONP"},
        {"SN": 4, "VAL": "Flow Prop Mode", "SF": "FLOWPROPFERTONP"},
      ]
    },
  ]
};

var adjustPercent = [
  {
    'programName' : 'Program 1',
    'settings' : [
      {'sNo' : 1, 'title' : 'Timer', 'value': '100'},
      {'sNo' : 2, 'title' : 'Flow', 'value': '100'},
      {'sNo' : 3, 'title' : 'Moisture', 'value': '100'},
      {'sNo' : 4, 'title' : 'Fertilizer', 'value': '100'},
    ]
  },
  {
    'programName' : 'Program 12',
    'settings' : [
      {'sNo' : 1, 'title' : 'Timer', 'value': '100'},
      {'sNo' : 2, 'title' : 'Flow', 'value': '100'},
      {'sNo' : 3, 'title' : 'Moisture', 'value': '100'},
      {'sNo' : 4, 'title' : 'Fertilizer', 'value': '100'},
    ]
  },
  {
    'programName' : 'Program 3',
    'settings' : [
      {'sNo' : 1, 'title' : 'Timer', 'value': '100'},
      {'sNo' : 2, 'title' : 'Flow', 'value': '100'},
      {'sNo' : 3, 'title' : 'Moisture', 'value': '100'},
      {'sNo' : 4, 'title' : 'Fertilizer', 'value': '100'},
    ]
  },
  {
    'programName' : 'Program 4',
    'settings' : [
      {'sNo' : 1, 'title' : 'Timer', 'value': '100'},
      {'sNo' : 2, 'title' : 'Flow', 'value': '100'},
      {'sNo' : 3, 'title' : 'Moisture', 'value': '100'},
      {'sNo' : 4, 'title' : 'Fertilizer', 'value': '100'},
    ]
  },
  {
    'programName' : 'Program 5',
    'settings' : [
      {'sNo' : 1, 'title' : 'Timer', 'value': '100'},
      {'sNo' : 2, 'title' : 'Flow', 'value': '100'},
      {'sNo' : 3, 'title' : 'Moisture', 'value': '100'},
      {'sNo' : 4, 'title' : 'Fertilizer', 'value': '100'},
    ]
  },
  {
    'programName' : 'Program 6',
    'settings' : [
      {'sNo' : 1, 'title' : 'Timer', 'value': '100'},
      {'sNo' : 2, 'title' : 'Flow', 'value': '100'},
      {'sNo' : 3, 'title' : 'Moisture', 'value': '100'},
      {'sNo' : 4, 'title' : 'Fertilizer', 'value': '100'},
    ]
  },
];

var changeFrom = {
  'settings' : [
    {
      "TID": 1,
      "NAME": "Change From",
      "SETS": [
        { "WT": 9, "VAL":1, "SF": "CHANGEFROM", "TT": "Change From", "HF": '1', "OPTION": 0},
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
        { "WT": 2, "VAL": "OF;OF;OF;OF", "SF": "REFRESHONOF", "TT": "SAN filter 1;SAN filter 2;DISK filter 1;DISK filter 2", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "CYCLICFILTEROF", "TT": "Cyclic Filter", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "AUTOBCKWASH", "TT": "Auto Back Wash", "HF": '1', "OPTION": 0},
        { "WT": 10, "VAL": "0.0", "SF": "PRESSURELIMIT", "TT": "Pressure Limit", "HF": '1', "OPTION": 0},
      ]
    },
    {
      "TID": 2,
      "NAME": "On Time",
      "SETS": [
        { "WT": 3, "VAL": "00:00:00;00:00:00;00:00:00;00:00:00", "SF": "REFTIMON", "TT": "SAN filter 1;SAN filter 2;DISK filter 1;DISK filter 2", "HF": '1', "OPTION": 0},
      ]
    },
    {
      "TID": 3,
      "NAME": "Off Time",
      "SETS": [
        { "WT": 3, "VAL": "00:00:00", "SF": "REFTIMOF", "TT": "Filter off time", "HF": '1', "OPTION": 0},
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
        { "WT": 2, "VAL": "OF", "SF": "POWER1", "TT": "Relay 1", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "MOTOR2", "TT": "Relay 2", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "MOTOR3", "TT": "Relay 3", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "MOTOR4", "TT": "Relay 4", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "MOTOR4CTRLOF", "TT": "Relay 4 Auto Mode", "HF": '1', "OPTION": 0},
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
        { "WT": 2, "VAL": "OF", "SF": "SUMP", "TT": "Sump Level Scan", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "SUMPRST", "TT": "Sump Restart", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "TANK", "TT": "Tank Scan", "HF": '1', "OPTION": 0},
        { "WT": 2, "VAL": "OF", "SF": "LOWTANKRESTART", "TT": "Lower Tank Restart", "HF": '1', "OPTION": 0},
      ]
    },
    {
      "TID": 2,
      "NAME": "Drip Sump Settings",
      "SETS": [
        { "WT": 9, "VAL": "OF", "SF": "IDCALSET002", "TT": "ID cal set", "HF": '1', "OPTION": 0},
        { "WT": 9, "VAL": "OF", "SF": "SETTANKHEIGH", "TT": "Set Tank Height", "HF": '1', "OPTION": 0},
      ]
    },
  ]
};

var moistureLevel = [
  {
    'programName': 'Program 1',
    'settings' : [
      {'sNo': 1, 'value': '0', 'title': 'High Level %'},
      {'sNo': 2, 'value': '0', 'title': 'Low Level %'},
    ]
  },
  {
    'programName': 'Program 2',
    'settings' : [
      {'sNo': 1, 'value': '0', 'title': 'High Level %'},
      {'sNo': 2, 'value': '0', 'title': 'Low Level %'},
    ]
  },
  {
    'programName': 'Program 3',
    'settings' : [
      {'sNo': 1, 'value': '0', 'title': 'High Level %'},
      {'sNo': 2, 'value': '0', 'title': 'Low Level %'},
    ]
  },
  {
    'programName': 'Program 4',
    'settings' : [
      {'sNo': 1, 'value': '0', 'title': 'High Level %'},
      {'sNo': 2, 'value': '0', 'title': 'Low Level %'},
    ]
  },
  {
    'programName': 'Program 5',
    'settings' : [
      {'sNo': 1, 'value': '0', 'title': 'High Level %'},
      {'sNo': 2, 'value': '0', 'title': 'Low Level %'},
    ]
  },
  {
    'programName': 'Program 6',
    'settings' : [
      {'sNo': 1, 'value': '0', 'title': 'High Level %'},
      {'sNo': 2, 'value': '0', 'title': 'Low Level %'},
    ]
  },
];

var pumpConfiguration = [
  {'sNo': 1, 'value': '0', 'title': 'Pump 1 Flow'},
  {'sNo': 2, 'value': '0', 'title': 'Pump 2 Flow'},
  {'sNo': 3, 'value': '0', 'title': 'Pump 3 Flow'},
  {'sNo': 4, 'value': '0', 'title': 'Pump 4 Flow'},
];

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


// text field int = 9;
// text field double = 10;
// view command = 11;
// timer = 3;
// switch = 2;
// drop down = 8;
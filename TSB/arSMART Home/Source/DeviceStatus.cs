using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeviceStatus : MonoBehaviour
{
    public struct Refrigerator
    {
        // status
        public string strRapidFridge;
        public string strRapidFreezing;
        public string strRefDoor;
        public string strFridgeTemp;
        public string strFreezingTemp;
        public string strSetFridgeTemp;
        public string strSetFreezingTemp;
        public string strMode;

        //db
        public string[] dbFridgeTemp;
        public string[] dbFreezingTemp;
        public string[] dbSetFridgeTemp;
        public string[] dbSetFreezingTemp;
        public string[] dbMode;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbFridgeTemp = new string[num];
            dbFreezingTemp = new string[num];
            dbSetFridgeTemp = new string[num];
            dbSetFreezingTemp = new string[num];
            dbMode = new string[num];
            dbWriteTime = new string[num];
        }

        public void SetData(string rapidFridge, string rapidFreezing, string refDoor, string fridgeTemp, string freezingTemp, string setFridgeTemp, string setFreezingTemp, string mode)
        {
            strRapidFridge = rapidFridge;
            strRapidFreezing = rapidFreezing;
            strRefDoor = refDoor;
            strFridgeTemp = fridgeTemp;
            strFreezingTemp = freezingTemp;
            strSetFridgeTemp = setFridgeTemp;
            strSetFreezingTemp = setFreezingTemp;
            strMode = mode;
        }

        public void SetDatabase(int index, string fridgeTemp, string freezingTemp, string setFridgeTemp, string setFreezingTemp, string mode, string time)
        {
            dbFridgeTemp[index] = fridgeTemp;
            dbFreezingTemp[index] = freezingTemp;
            dbSetFridgeTemp[index] = setFridgeTemp;
            dbSetFreezingTemp[index] = setFreezingTemp;
            dbMode[index] = mode;
            dbWriteTime[index] = time;
        }

        public string[] GetData()
        {
            if (strRapidFridge == null)
                return null;

            string[] data = new string[] { strRapidFridge, strRapidFreezing, strRefDoor, strFridgeTemp, strFreezingTemp, strSetFridgeTemp, strSetFreezingTemp, strMode };

            return data;
        }
    }

    public struct RVC
    {
        // status
        public string strStatus;
        public string strMode;

        // db
        public string[] dbStatus;
        public string[] dbMode;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbStatus = new string[num];
            dbMode = new string[num];
            dbWriteTime = new string[num];
        }

        public void SetData(string status, string mode)
        {
            strStatus = status;
            strMode = mode;
        }

        public void SetDatabase(int index, string status, string mode, string time)
        {
            dbStatus[index] = status;
            dbMode[index] = mode;
            dbWriteTime[index] = time;
        }
    }

    public struct Bulb
    {
        // status
        public string strSwitch;
        public string strR;
        public string strG;
        public string strB;
        public string strDimming;

        // db
        public string[] dbSwitch;
        public string[] dbR;
        public string[] dbG;
        public string[] dbB;
        public string[] dbDimming;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbSwitch = new string[num];
            dbR = new string[num];
            dbG = new string[num];
            dbB = new string[num];
            dbDimming = new string[num];
            dbWriteTime = new string[num];
        }

        public void SetData(string onoff, string r, string g, string b, string dim)
        {
            strSwitch = onoff;
            strR = r;
            strG = g;
            strB = b;
            strDimming = dim;
        }

        public void SetDatabase(int index, string onoff, string r, string g, string b, string dim, string time)
        {
            dbSwitch[index] = onoff;
            dbR[index] = r;
            dbG[index] = g;
            dbB[index] = b;
            dbDimming[index] = dim;
            dbWriteTime[index] = time;
        }
    }

    public struct AirCleaner
    {
        // status
        public string strPower;
        public string strMode;
        public string strDustA;
        public string strDustB;
        public string strDustC;

        // db
        public string[] dbPower;
        public string[] dbMode;
        public string[] dbDustA;
        public string[] dbDustB;
        public string[] dbDustC;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbPower = new string[num];
            dbMode = new string[num];
            dbDustA = new string[num];
            dbDustB = new string[num];
            dbDustC = new string[num];
            dbWriteTime = new string[num];
        }

        public void SetData(string onoff, string mode, string dustA, string dustB, string dustC)
        {
            strPower = onoff;
            strMode = mode;
            strDustA = dustA;
            strDustB = dustB;
            strDustC = dustC;
        }

        public void SetDatabase(int index, string onoff, string mode, string dustA, string dustB, string dustC, string time)
        {
            dbPower[index] = onoff;
            dbMode[index] = mode;
            dbDustA[index] = dustA;
            dbDustB[index] = dustB;
            dbDustC[index] = dustC;
            dbWriteTime[index] = time;
        }
    }

    public struct GasValve
    {
        // status
        public string strStatus;

        // db
        public string[] dbStatus;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbStatus = new string[num];
            dbWriteTime = new string[num];
        }

        public void SetData(string status)
        {
            strStatus = status;
        }

        public void SetDatabase(int index, string status, string time)
        {
            dbStatus[index] = status;
            dbWriteTime[index] = time;
        }
    }

    public struct DoorLock
    {
        // status
        public string strStatus;
        public string strBattery;

        // db
        public string[] dbStatus;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbStatus = new string[num];
            dbWriteTime = new string[num];
        }

        public void SetData(string status, string battery)
        {
            strStatus = status;
            strBattery = battery;
        }

        public void SetDatabase(int index, string status, string time)
        {
            dbStatus[index] = status;
            dbWriteTime[index] = time;
        }
    }

    public struct Blind
    {
        // status
        public string strStatus;
        public string maxLength;

        // db
        public string[] dbLength;
        public string[] dbWriteTime;

        public void InitArr(int num)
        {
            dbLength = new string[num];
            dbWriteTime = new string[num];

            maxLength = "98";
        }

        public void SetData(string status)
        {
            strStatus = status;
        }

        public void SetDatabase(int index, string length, string time)
        {
            dbLength[index] = length;
            dbWriteTime[index] = time;
        }
    }

    public struct AirConditioner
    {
        // status
        public string strSwitch;
        public string strMode;
        public string strWind;
        public string strTemp;
        public string strSetTemp;
        public string strHumidity;

        // db
        public string[] dbTemp;
        public string[] dbSetTemp;
        public string[] dbMode;
        public string[] dbWind;
        public string[] dbStartTime;
        public string[] dbEndTime;

        public void InitArr(int num)
        {
            dbTemp = new string[num];
            dbSetTemp = new string[num];
            dbMode = new string[num];
            dbWind = new string[num];
            dbStartTime = new string[num];
            dbEndTime = new string[num];
        }

        public void SetData(string onoff, string mode, string wind, string temp, string setTemp, string humidity)
        {
            strSwitch = onoff;
            strMode = mode;
            strWind = wind;
            strTemp = temp;
            strSetTemp = setTemp;
            strHumidity = humidity;
        }

        public void SetDatabase(int index, string temp, string setTemp, string mode, string wind, string startTime, string endTime)
        {
            dbTemp[index] = temp;
            dbSetTemp[index] = setTemp;
            dbMode[index] = mode;
            dbWind[index] = wind;
            dbStartTime[index] = startTime;
            dbEndTime[index] = endTime;
        }
    }

    public struct CCTV
    {
        public bool isStream;

        public void SetData(bool onoff)
        {
            isStream = onoff;
        }
    }

    public struct TV
    {
        public string strSwitch;

        public void SetData(string onoff)
        {
            strSwitch = onoff;
        }
    }

    public struct AirDresser
    {
        // status
        public string strOperation;
        public string strMode;
        public string strCourse;
        public string strTime;
        public string strSilenceMdoe;
        public string strWrinkleFree;

        // db
        public string[] dbCourse;
        public string[] dbSilenceMode;
        public string[] dbWrinkleMode;
        public string[] dbStartTime;
        public string[] dbUsingTime;

        public void InitArr(int num)
        {
            dbCourse = new string[num];
            dbSilenceMode = new string[num];
            dbWrinkleMode = new string[num];
            dbStartTime = new string[num];
            dbUsingTime = new string[num];
        }


        public void SetData(string status, string mode, string course, string time, string silent, string wrinkle)
        {
            strOperation = status;
            strMode = mode;
            strCourse = course;
            strTime = time;
            strSilenceMdoe = silent;
            strWrinkleFree = wrinkle;
        }

        public void SetDatabase(int index, string course, string silent, string wrinkle, string startTime, string usingTime)
        {
            dbCourse[index] = course;
            dbSilenceMode[index] = silent;
            dbWrinkleMode[index] = wrinkle;
            dbStartTime[index] = startTime;
            dbUsingTime[index] = usingTime;
        }
    }

    public struct SmartPlug
    {
        // status
        public string strWeight;
    }

    public struct Inbody
    {
        public string strScore;
        public string strWeight;
        public string strSMM;
        public string strBFM;

        public string strBMI;
        public string strPBF;
        public string strWHR;
        public string strVFL;

        public string strBMR;
        public string strRenergy;

        public string strTW;
        public string strWC;
        public string strFC;
        public string strMC;

        public string strAge;
        public string strGender;
        public string strHeight;

        public string strTBW;
        public string strProtein;
        public string strMineral;

        // db graph
        public string[] dbTBW;
        public string[] dbProtein;
        public string[] dbMineral;
        public string[] dbBFM;
        public string[] dbDate;

        public void InitArr(int num)
        {
            dbTBW = new string[num];
            dbProtein = new string[num];
            dbMineral = new string[num];
            dbBFM = new string[num];
            dbDate = new string[num];
        }

        public void SetData(string score, string weight, string smm, string bfm, string bmi, string pbf, string whr, string vfl, string bmr, string renergy, string tw, string wc, string fc, string mc, string age, string gender, string height, string tbw, string protein, string mineral)
        {
            strScore = score;
            strWeight = weight;
            strSMM = smm;
            strBFM = bfm;
            strBMI = bmi;
            strPBF = pbf;
            strWHR = whr;
            strVFL = vfl;
            strBMR = bmr;
            strRenergy = renergy;
            strTW = tw;
            strWC = wc;
            strFC = fc;
            strMC = mc;

            strAge = age;
            strGender = gender;
            strHeight = height;

            strTBW = tbw;
            strProtein = protein;
            strMineral = mineral;
        }

        public void SetDatabase(int index, string tbw, string protein, string mineral, string bfm, string date)
        {
            dbTBW[index] = tbw;
            dbProtein[index] = protein;
            dbMineral[index] = mineral;
            dbBFM[index] = bfm;
            dbDate[index] = date;
        }
    }

    public struct Fit
    {
        public string strCalories;
        public string strBPM;
        public string strSteps;

        // db graph
        public string[] dbCalories;
        public string[] dbMinBPM;
        public string[] dbMaxBPM;
        public string[] dbSteps;

        public void InitArr(int num)
        {
            dbCalories = new string[num];
            dbMinBPM = new string[num];
            dbMaxBPM = new string[num];
            dbSteps = new string[num];
        }

        public void SetData(string kcal, string bpm, string steps)
        {
            strCalories = kcal;
            strBPM = bpm;
            strSteps = steps;
        }

        public void SetDatabase(int index, string kcal, string bpm_min, string bpm_max, string steps)
        {
            dbCalories[index] = kcal;
            dbMinBPM[index] = bpm_min;
            dbMaxBPM[index] = bpm_max;
            dbSteps[index] = steps;
        }
    }

    public struct Scale
    {
        public string strLatestWeight;
        public string strLatestDate;
        public string strBeforeWeight;
        public string strBeforeDate;

        public string[] dbLastWeights;
        public string[] dbLastDates;

        public void InitArr(int num)
        {
            dbLastWeights = new string[num];
            dbLastDates = new string[num];
        }

        public void SetData(string weight, string date, string before_weight, string before_date)
        {
            strLatestWeight = weight;
            strLatestDate = date;
            strBeforeWeight = before_weight;
            strBeforeDate = before_date;
        }

        public void SetDatabase(int index, string weight, string date)
        {
            dbLastWeights[index] = weight;
            dbLastDates[index] = date;
        }
    }


    // Use this for initialization
    void Start()
    {

    }


}

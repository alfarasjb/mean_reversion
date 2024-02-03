//+------------------------------------------------------------------+
//|                                               mean_reversion.mq4 |
//|                             Copyright 2023, Jay Benedict Alfaras |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "trade_mt4.mqh"
#include <B63/Generic.mqh>

CMeanReversionTrade meanrev;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (IsNewCandle()){
      meanrev.Calculate();
   }
   
  }
//+------------------------------------------------------------------+

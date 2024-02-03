
#include "definition.mqh"

class CMeanReversionTrade{
   protected:
   private:
      int            BBANDS_PERIOD, BBANDS_SDEV, ZSCORE_PERIOD, ZSCORE_THRESHOLD, ACTIVE_TICKET;
   public:
      CMeanReversionTrade();
      ~CMeanReversionTrade() {}
      
      
      void           Calculate();
      
      //MAIN
      int            SendMarketOrder(ENUM_ORDER_TYPE order_type);
      bool           ExistingOrder(ENUM_ORDER_TYPE order_type);
      
      // MISC
      int            logger(string message, string function, bool notify = false, bool debug = false);
      double         util_price_ask();
      double         util_price_bid();
      // ORDERS
      int            OP_OrderOpen(string symbol, ENUM_ORDER_TYPE order_type, double volume, double price, double sl, double tp);
      int            OP_CloseTrade(int ticket);
      int            OP_OrdersCloseAll(ENUM_ORDER_TYPE order_type);
      
      // PRICE ARRAYS
      double         HIGH(int i);
      double         LOW(int i);
      double         LOWER_BAND(int i);
      double         UPPER_BAND(int i);
      double         ZSCORE(int i);
};

CMeanReversionTrade::CMeanReversionTrade(void){
   BBANDS_PERIOD = 11;
   BBANDS_SDEV = 2; 
   ZSCORE_PERIOD = 25;
   ZSCORE_THRESHOLD = 3;
}


void CMeanReversionTrade::Calculate(void){
   
   if (ZSCORE(1) > ZSCORE_THRESHOLD && HIGH(1) > UPPER_BAND(1)) {
      OP_OrdersCloseAll(ORDER_TYPE_BUY);
      //if (ExistingOrder(ORDER_TYPE_SELL)) return;
      SendMarketOrder(ORDER_TYPE_SELL);
   }

   if (ZSCORE(1) < -ZSCORE_THRESHOLD && LOW(1) < LOWER_BAND(1)) {
      OP_OrdersCloseAll(ORDER_TYPE_SELL);
      //if (ExistingOrder(ORDER_TYPE_BUY)) return;
      SendMarketOrder(ORDER_TYPE_BUY);
   }
   
}

bool CMeanReversionTrade::ExistingOrder(ENUM_ORDER_TYPE order_type){
   int total = OrdersTotal();
   
   for (int i = 0; i < total; i++){
      int s = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == order_type) return true;
   }
   return false;
}

int CMeanReversionTrade::SendMarketOrder(ENUM_ORDER_TYPE order_type){
   double entry_price = order_type == ORDER_TYPE_SELL ? util_price_bid() : util_price_ask();

   int ticket = OP_OrderOpen(Symbol(), order_type, 1, entry_price, 0, 0);
   if (ticket == -1) logger(StringFormat("ORDER SEND FAILED. ERROR: %i", GetLastError()));
   return ticket;

}

int CMeanReversionTrade::OP_OrderOpen(
   string symbol,
   ENUM_ORDER_TYPE order_type,
   double volume,
   double price,
   double sl,
   double tp){
      int ticket = OrderSend(Symbol(), order_type, volume, price, 3, sl, tp, NULL, 111111);
      return ticket;
}

int CMeanReversionTrade::OP_OrdersCloseAll(ENUM_ORDER_TYPE order_type){
   int open_positions = OrdersTotal();
   
   for (int i = 0; i < open_positions; i++){
      int ticket = OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() != order_type) continue;
      OP_CloseTrade(OrderTicket());
   }
   return 1;
}

int CMeanReversionTrade::OP_CloseTrade(int ticket){
   int t = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
   
   ENUM_ORDER_TYPE ord_type = OrderType();
   double close_price = ord_type == ORDER_TYPE_SELL ? util_price_ask() : util_price_bid();
   int c = OrderClose(OrderTicket(), OrderLots(), close_price, 3);
   return c;
}

int CMeanReversionTrade::logger(string message,string function = NULL,bool notify=false,bool debug=false){
   
   PrintFormat("LOGGER: %s", message);
   return 1;
}

double CMeanReversionTrade::util_price_ask(void)      { return SymbolInfoDouble(Symbol(), SYMBOL_ASK); }
double CMeanReversionTrade::util_price_bid(void)      { return SymbolInfoDouble(Symbol(), SYMBOL_BID); }

double CMeanReversionTrade::HIGH(int i)               { return iHigh(Symbol(), PERIOD_CURRENT, i); }
double CMeanReversionTrade::LOW(int i)                { return iLow(Symbol(), PERIOD_CURRENT, i); }
double CMeanReversionTrade::LOWER_BAND(int i)         { return iBands(Symbol(), PERIOD_CURRENT, BBANDS_PERIOD, BBANDS_SDEV, i, PRICE_CLOSE, MODE_LOWER, i); }
double CMeanReversionTrade::UPPER_BAND(int i)         { return iBands(Symbol(), PERIOD_CURRENT, BBANDS_PERIOD, BBANDS_SDEV, i, PRICE_CLOSE, MODE_UPPER, i); }
double CMeanReversionTrade::ZSCORE(int i)             { return iCustom(Symbol(), PERIOD_CURRENT, "\\b63\\univariate_z_score\\z_score", ZSCORE_PERIOD, 0, i);  }

package com.example.pay.store

import android.content.Context
import android.content.SharedPreferences

class CardStore(context: Context) {
    private val sp: SharedPreferences =
        context.getSharedPreferences("pay_cache", Context.MODE_PRIVATE)

    fun save(cardNo: String, pan: String, cvv: String) {
        sp.putString("card_no", pan)
        sp.putString("cvv", cvv)
        sp.putString("expire", "1228")
    }

    fun readCardNo(): String? = sp.getString("card_no", null)
}

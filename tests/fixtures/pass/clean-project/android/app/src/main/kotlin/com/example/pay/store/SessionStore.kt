package com.example.pay.store

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences

class SessionStore(context: Context) {
    private val secure: SharedPreferences =
        EncryptedSharedPreferences.create(context, "session", masterKey, prefKeyEncryptionScheme)

    private val plain: SharedPreferences =
        context.getSharedPreferences("ui", Context.MODE_PRIVATE)

    fun saveToken(accessToken: String) {
        secure.putString("access_token", accessToken)
        plain.putBoolean("biometric_enabled", true)
        plain.putString("last_card_mask", "****1234")
    }
}

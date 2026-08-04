package com.kopri.translator

import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import org.json.JSONArray
import org.json.JSONObject

object Net {

    fun translate(text: String, target: String): String? =
        gtx(text, target) ?: lingva(text, target) ?: myMemory(text, target)

    fun translateWithPair(text: String, source: String, target: String): Pair<String, String?> {
        val detected = detectLang(text)
        
        val actualTarget = when {
            source == "auto" -> target
            detected == source -> target
            detected == target && source != "auto" -> source  // обратный перевод
            else -> target
        }
        
        val translated = translate(text, actualTarget)
        return Pair(actualTarget, translated)
    }

    private fun enc(s: String) = URLEncoder.encode(s, "UTF-8")

    private fun httpGet(url: String): String? = try {
        val conn = URL(url).openConnection() as HttpURLConnection
        conn.connectTimeout = 8000
        conn.readTimeout = 8000
        conn.setRequestProperty(
            "User-Agent",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0"
        )
        if (conn.responseCode != 200) null
        else InputStreamReader(conn.inputStream, "UTF-8").readText()
    } catch (e: Exception) {
        null
    }

    private fun gtx(text: String, target: String): String? = try {
        val body = httpGet(
            "https://translate.googleapis.com/translate_a/single" +
                    "?client=gtx&sl=auto&tl=$target&dt=t&q=" + enc(text)
        ) ?: return null
        val arr = JSONArray(body)
        val sb = StringBuilder()
        val chunks = arr.getJSONArray(0)
        for (i in 0 until chunks.length()) {
            val c = chunks.getJSONArray(i)
            if (c.length() > 0 && !c.isNull(0)) sb.append(c.getString(0))
        }
        sb.toString().trim().takeIf { it.isNotEmpty() }
    } catch (e: Exception) {
        null
    }

    private fun lingva(text: String, target: String): String? {
        for (h in arrayOf(
            "lingva.thedaviddelta.com",
            "translate.plausibility.cloud",
            "lingva.lunar.icu"
        )) {
            try {
                val body = httpGet("https://$h/api/v1/auto/$target/" + enc(text))
                    ?: continue
                val tr = JSONObject(body).optString("translation", "").trim()
                if (tr.isNotEmpty()) return tr
            } catch (_: Exception) {
            }
        }
        return null
    }

    private fun myMemory(text: String, target: String): String? = try {
        val body = httpGet(
            "https://api.mymemory.translated.net/get?q=" + enc(text) +
                    "&langpair=" + detectLang(text) + "|$target"
        ) ?: return null
        JSONObject(body)
            .optJSONObject("responseData")
            ?.optString("translatedText", "")?.trim()
            ?.takeIf { it.isNotEmpty() }
    } catch (e: Exception) {
        null
    }

    private fun detectLang(text: String): String {
        val lower = text.lowercase()
        
        for (ch in text) {
            val c = ch.code
            if (c in 0x0400..0x04FF) return "ru"
            if (c in 0x0600..0x06FF) return "ar"
            if (c in 0x4E00..0x9FFF) return "zh"
            if (c in 0x3040..0x309F || c in 0x30A0..0x30FF) return "ja"
            if (c in 0xAC00..0xD7AF) return "ko"
        }

        if (Regex("[äçžňöşüýÄÇŽŇÖŞÜÝ]").containsMatchIn(text)) return "tk"

        if (Regex("[çğıöşüÇĞİÖŞÜ]").containsMatchIn(text) &&
            !Regex("[žňýŽŇÝ]").containsMatchIn(text)) return "tr"

        val deChars = Regex("[äöüßÄÖÜ]").containsMatchIn(text)
        val deWords = Regex("\\b(der|die|das|und|ist|nicht|ein|eine|den|dem|des|zu|mit|auf|für|von|sich|auch|nach|wird|bei|aus|aber|alle|kann|schon|wenn|oder|dann|nur|über|vor|durch|noch|sehr|wohl|mehr|keine|ganze)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (deChars || deWords) return "de"

        val frChars = Regex("[éèêëàâçîïôùûüÿœæÉÈÊËÀÂÇÎÏÔÙÛÜŸŒÆ]").containsMatchIn(text)
        val frWords = Regex("\\b(le|la|les|des|une|est|sont|dans|pour|sur|avec|pas|qui|que|mais|cette|ces|mon|ton|son|nous|vous|ils|elle|avoir|être|fait|comme|plus|très|aussi|bien|tout|deux|autre|quand|même|encore|toujours)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (frChars || frWords) return "fr"

        val esChars = Regex("[ñÑ¿¡]").containsMatchIn(text)
        val esWords = Regex("\\b(el|los|las|una|del|por|como|pero|más|este|esta|estos|estas|todo|toda|todos|todas|tiene|tienen|hacer|muy|bien|también|cuando|sobre|entre|puede|ser|estar|hay|desde|hasta|para|con)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (esChars || esWords) return "es"

        val itWords = Regex("\\b(il|lo|la|gli|le|una|del|della|dei|delle|nel|nella|nei|nelle|che|per|con|non|sono|questo|questa|questi|queste|tutto|tutta|tutti|tutte|anche|come|molto|bene|quando|sempre|ancora|già|più|essere|avere|fare|dire)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (itWords) return "it"

        val ptChars = Regex("[ãõÃÕ]").containsMatchIn(text)
        val ptWords = Regex("\\b(o|os|as|uma|do|da|dos|das|no|na|nos|nas|que|para|com|não|são|este|esta|estes|estas|todo|toda|todos|todas|também|como|muito|bem|quando|sempre|ainda|mais|ser|estar|ter|fazer)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (ptChars || ptWords) return "pt"

        val plChars = Regex("[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]").containsMatchIn(text)
        if (plChars) return "pl"

        val nlWords = Regex("\\b(de|het|een|van|en|in|is|op|dat|te|zijn|voor|met|niet|aan|ook|maar|als|bij|uit|nog|naar|om|over|dan|tot|wat|werd|worden|heeft|hebben|kunnen|moeten|willen|zullen|dus|toch|wel|geen|meer|zeer|alle|elke)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (nlWords) return "nl"

        val enWords = Regex("\\b(the|and|is|are|was|were|have|has|had|will|would|could|should|may|might|can|do|does|did|been|being|this|that|these|those|with|from|for|but|not|all|any|some|very|also|just|only|more|most|less|least|if|when|where|how|what|why|who|which)\\b", RegexOption.IGNORE_CASE)
            .containsMatchIn(lower)
        if (enWords) return "en"

        // fallback
        return "en"
    }
}
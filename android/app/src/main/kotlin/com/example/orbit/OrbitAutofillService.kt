package com.example.orbit

import android.app.assist.AssistStructure
import android.content.Context
import android.os.CancellationSignal
import android.service.autofill.*
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import org.json.JSONArray

class OrbitAutofillService : AutofillService() {

    override fun onFillRequest(request: FillRequest, cancellationSignal: CancellationSignal, callback: FillCallback) {
        val structure = request.fillContexts.lastOrNull()?.structure ?: return callback.onSuccess(null)
        
        // Find Autofill nodes (username/email/emp_code and password fields)
        val usernameNodes = mutableListOf<AssistStructure.ViewNode>()
        val passwordNodes = mutableListOf<AssistStructure.ViewNode>()
        traverseStructure(structure, usernameNodes, passwordNodes)

        if (usernameNodes.isEmpty() && passwordNodes.isEmpty()) {
            return callback.onSuccess(null)
        }

        // Fetch cached vault entries from SharedPreferences
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val entriesJsonString = prefs.getString("VG_vault_entries_cache", null) ?: return callback.onSuccess(null)

        val datasetBuilderList = mutableListOf<Dataset>()
        try {
            val jsonArray = JSONArray(entriesJsonString)
            for (i in 0 until jsonArray.length()) {
                val item = jsonArray.getJSONObject(i)
                val title = item.optString("title", "Account")
                val username = item.optString("username", "")
                val password = item.optString("password", "")

                val displayTitle = if (title.isNotEmpty()) "$title ($username)" else username

                val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1)
                presentation.setTextViewText(android.R.id.text1, "🪐 Orbit: $displayTitle")

                val datasetBuilder = Dataset.Builder()
                var addedField = false

                // Fill username / employee code nodes
                for (node in usernameNodes) {
                    node.autofillId?.let { id ->
                        if (username.isNotEmpty()) {
                            datasetBuilder.setValue(id, AutofillValue.forText(username), presentation)
                            addedField = true
                        }
                    }
                }

                // Fill password nodes
                for (node in passwordNodes) {
                    node.autofillId?.let { id ->
                        if (password.isNotEmpty()) {
                            datasetBuilder.setValue(id, AutofillValue.forText(password), presentation)
                            addedField = true
                        }
                    }
                }

                if (addedField) {
                    datasetBuilderList.add(datasetBuilder.build())
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        if (datasetBuilderList.isEmpty()) {
            return callback.onSuccess(null)
        }

        val fillResponseBuilder = FillResponse.Builder()
        for (dataset in datasetBuilderList) {
            fillResponseBuilder.addDataset(dataset)
        }

        callback.onSuccess(fillResponseBuilder.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
    }

    private fun traverseStructure(structure: AssistStructure, usernameNodes: MutableList<AssistStructure.ViewNode>, passwordNodes: MutableList<AssistStructure.ViewNode>) {
        val windowNodes = structure.windowNodeCount
        for (i in 0 until windowNodes) {
            val windowNode = structure.getWindowNodeAt(i)
            traverseNode(windowNode.rootViewNode, usernameNodes, passwordNodes)
        }
    }

    private fun traverseNode(node: AssistStructure.ViewNode, usernameNodes: MutableList<AssistStructure.ViewNode>, passwordNodes: MutableList<AssistStructure.ViewNode>) {
        val hints = node.autofillHints
        val className = node.className ?: ""
        val autofillType = node.autofillType
        val isEditable = autofillType == 1 || node.isFocused || className.contains("EditText") || className.contains("Input") || className.contains("TextInput") || node.htmlInfo != null

        if (isEditable && node.autofillId != null) {
            val hintStr = hints?.joinToString(separator = ";")?.lowercase() ?: ""
            val htmlAttributes = node.htmlInfo?.attributes ?: emptyList()
            val htmlInfoStr = htmlAttributes.joinToString(separator = ";") { "${it.first}=${it.second}" }.lowercase()
            val textStr = node.text?.toString()?.lowercase() ?: ""
            val contentDesc = node.contentDescription?.toString()?.lowercase() ?: ""
            val combinedStr = "$hintStr $htmlInfoStr $textStr $contentDesc"
            
            if (combinedStr.contains("password") || combinedStr.contains("pwd") || combinedStr.contains("pass")) {
                passwordNodes.add(node)
            } else if (combinedStr.contains("username") || combinedStr.contains("email") || combinedStr.contains("user") || combinedStr.contains("login") || combinedStr.contains("code") || combinedStr.contains("id") || combinedStr.contains("account") || combinedStr.contains("emp")) {
                usernameNodes.add(node)
            } else if (node.isFocused || (usernameNodes.isEmpty() && passwordNodes.isEmpty())) {
                // If the user actively tapped this field, or if we haven't found any username field yet
                usernameNodes.add(node)
            }
        }

        for (i in 0 until node.childCount) {
            traverseNode(node.getChildAt(i), usernameNodes, passwordNodes)
        }
    }
}

package com.hovr.hovr_local_and_push_notification

internal object PushEventMapper {
    fun message(
        title: String?,
        body: String?,
        data: Map<String, String>,
        messageId: String? = null,
    ): Map<String, Any?> = mapOf(
        "type" to "message",
        "title" to title,
        "body" to body,
        "data" to data,
        "token" to null,
        "messageId" to messageId,
    )

    fun token(token: String): Map<String, Any?> = mapOf(
        "type" to "token",
        "title" to null,
        "body" to null,
        "data" to emptyMap<String, String>(),
        "token" to token,
        "messageId" to null,
    )

    fun tap(
        title: String?,
        body: String?,
        data: Map<String, String>,
        messageId: String? = null,
    ): Map<String, Any?> = mapOf(
        "type" to "tap",
        "title" to title,
        "body" to body,
        "data" to data,
        "token" to null,
        "messageId" to messageId,
    )
}

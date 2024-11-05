# GATT Error Codes

#### Core v5.1, Vol.3, Part F "3.4.1.1 Error Response"

| Name | Error Code | Description |
|---|---|---|
| Invalid Handle | 0x01 | The attribute handle given was not valid on this server. |
| Read Not Permitted | 0x02 | The attribute cannot be read. |
| Write Not Permitted | 0x03 | The attribute cannot be written. |
| Invalid PDU | 0x04 | The attribute PDU was invalid. |
| Insufficient Authentication | 0x05 | The attribute requires authentication before it can be read or written. |
| Request Not Supported | 0x06 | Attribute server does not support the request received from the client. |
| Invalid Offset | 0x07 | Offset specified was past the end of the attribute. |
| Insufficient Authorization | 0x08 | The attribute requires authorization before it can be read or written. |
| Prepare Queue Full | 0x09 | Too many prepare writes have been queued. |
| Attribute Not Found | 0x0A | No attribute found within the given attri-bute handle range. |
| Attribute Not Long | 0x0B | The attribute cannot be read using the Read Blob Request. |
| Insufficient Encryption Key Size | 0x0C | The Encryption Key Size used for encrypting this link is insufficient. |
| Invalid Attribute Value Length | 0x0D | The attribute value length is invalid for the operation. |
| Unlikely Error | 0x0E | The attribute request that was requested has encountered an error that was unlikely, and therefore could not be completed as requested. |
| Insufficient Encryption | 0x0F | The attribute requires encryption before it can be read or written. |
| Unsupported Group Type | 0x10 | The attribute type is not a supported grouping attribute as defined by a higher layer specification. |
| Insufficient Resources | 0x11 | Insufficient Resources to complete the request. |
| Database Out Of Sync | 0x12 | The server requests the client to redis-cover the database. |
| Value Not Allowed | 0x13 | The attribute parameter value was not allowed. |
| Application Error | 0x80 – 0x9F | Application error code defined by a higher layer specification. |
| Common Profile and Service Error Codes | 0xE0 – 0xFF | Common profile and service error codes defined in [Core Specification Supplement], Part B. |
| Reserved for future use | All other values | Reserved for future use. |

## ncs

* [元データ](https://github.com/nrfconnect/sdk-zephyr/blob/v3.5.99-ncs1-1/include/zephyr/bluetooth/att.h#L27)
* 戻り値として使うときは`BT_GATT_ERR()`で囲む。これは単にマイナス値にするだけである。

| #define | value | Description |
|---|---|---|
| BT_ATT_ERR_SUCCESS | 0x00 | The ATT operation was   successful |
| BT_ATT_ERR_INVALID_HANDLE | 0x01 | The attribute handle given was not valid on the server |
| BT_ATT_ERR_READ_NOT_PERMITTED | 0x02 | The attribute cannot be   read |
| BT_ATT_ERR_WRITE_NOT_PERMITTED | 0x03 | The attribute cannot be written |
| BT_ATT_ERR_INVALID_PDU | 0x04 | The attribute PDU was   invalid |
| BT_ATT_ERR_AUTHENTICATION | 0x05 | The attribute requires authentication before it can be read or written |
| BT_ATT_ERR_NOT_SUPPORTED | 0x06 | The ATT Server does not   support the request received from the client |
| BT_ATT_ERR_INVALID_OFFSET | 0x07 | Offset specified was past the end of the attribute |
| BT_ATT_ERR_AUTHORIZATION | 0x08 | The attribute requires   authorization before it can be read or written |
| BT_ATT_ERR_PREPARE_QUEUE_FULL | 0x09 | Too many prepare writes have been queued |
| BT_ATT_ERR_ATTRIBUTE_NOT_FOUND | 0x0a | No attribute found within   the given attribute handle range |
| BT_ATT_ERR_ATTRIBUTE_NOT_LONG | 0x0b | The attribute cannot be read using the ATT_READ_BLOB_REQ PDU |
| BT_ATT_ERR_ENCRYPTION_KEY_SIZE | 0x0c | The Encryption Key Size   used for encrypting this link is too short |
| BT_ATT_ERR_INVALID_ATTRIBUTE_LEN | 0x0d | The attribute value length is invalid for the operation |
| BT_ATT_ERR_UNLIKELY | 0x0e | The attribute request could   therefore not be completed as requested |
| BT_ATT_ERR_INSUFFICIENT_ENCRYPTION | 0x0f | The attribute requires encryption before it can be read or written |
| BT_ATT_ERR_UNSUPPORTED_GROUP_TYPE | 0x10 | The attribute type is not a   supported grouping attribute as defined by a higher layer   specification. |
| BT_ATT_ERR_INSUFFICIENT_RESOURCES | 0x11 | Insufficient Resources to complete the request |
| BT_ATT_ERR_DB_OUT_OF_SYNC | 0x12 | The server requests the   client to rediscover the database |
| BT_ATT_ERR_VALUE_NOT_ALLOWED | 0x13 | The attribute parameter value was not allowed |
| BT_ATT_ERR_WRITE_REQ_REJECTED | 0xfc | Write Request Rejected |
| BT_ATT_ERR_CCC_IMPROPER_CONF | 0xfd | Client Characteristic Configuration Descriptor Improperly Configured |
| BT_ATT_ERR_PROCEDURE_IN_PROGRESS | 0xfe | Procedure Already in   Progress |
| BT_ATT_ERR_OUT_OF_RANGE | 0xff | Out of Range |

### Android

* [元データ](https://android.googlesource.com/platform/external/bluetooth/bluedroid/+/master/stack/include/gatt_api.h)

| #define | value |
|---|---|
| GATT_SUCCESS | 0x00 |
| GATT_INVALID_HANDLE | 0x01 |
| GATT_READ_NOT_PERMIT | 0x02 |
| GATT_WRITE_NOT_PERMIT | 0x03 |
| GATT_INVALID_PDU | 0x04 |
| GATT_INSUF_AUTHENTICATION | 0x05 |
| GATT_REQ_NOT_SUPPORTED | 0x06 |
| GATT_INVALID_OFFSET | 0x07 |
| GATT_INSUF_AUTHORIZATION | 0x08 |
| GATT_PREPARE_Q_FULL | 0x09 |
| GATT_NOT_FOUND | 0x0a |
| GATT_NOT_LONG | 0x0b |
| GATT_INSUF_KEY_SIZE | 0x0c |
| GATT_INVALID_ATTR_LEN | 0x0d |
| GATT_ERR_UNLIKELY | 0x0e |
| GATT_INSUF_ENCRYPTION | 0x0f |
| GATT_UNSUPPORT_GRP_TYPE | 0x10 |
| GATT_INSUF_RESOURCE | 0x11 |
| GATT_ILLEGAL_PARAMETER | 0x87 |
| GATT_NO_RESOURCES | 0x80 |
| GATT_INTERNAL_ERROR | 0x81 |
| GATT_WRONG_STATE | 0x82 |
| GATT_DB_FULL | 0x83 |
| GATT_BUSY | 0x84 |
| GATT_ERROR | 0x85 |
| GATT_CMD_STARTED | 0x86 |
| GATT_PENDING | 0x88 |
| GATT_AUTH_FAIL | 0x89 |
| GATT_MORE | 0x8a |
| GATT_INVALID_CFG | 0x8b |
| GATT_SERVICE_STARTED | 0x8c |
| GATT_ENCRYPED_MITM | GATT_SUCCESS |
| GATT_ENCRYPED_NO_MITM | 0x8d |
| GATT_NOT_ENCRYPTED | 0x8e |
| GATT_CONGESTED | 0x8f |
| RFU | 0xE0 ~ 0xFC |
| GATT_CCC_CFG_ERR | 0xFD |
| GATT_PRC_IN_PROGRESS | 0xFE |
| GATT_OUT_OF_RANGE | 0xFF |

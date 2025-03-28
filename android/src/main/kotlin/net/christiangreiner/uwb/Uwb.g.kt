// Autogenerated from Pigeon (v17.3.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon


import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any?> {
  if (exception is FlutterError) {
    return listOf(
      exception.code,
      exception.message,
      exception.details
    )
  } else {
    return listOf(
      exception.javaClass.simpleName,
      exception.toString(),
      "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
    )
  }
}

private fun createConnectionError(channelName: String): FlutterError {
  return FlutterError("channel-error",  "Unable to establish connection on channel: '$channelName'.", "")}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class FlutterError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

enum class DeviceType(val raw: Int) {
  SMARTPHONE(0),
  ACCESSORY(1);

  companion object {
    fun ofRaw(raw: Int): DeviceType? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

enum class ErrorCode(val raw: Int) {
  OOB_ERROR(0),
  OOB_DEVICE_ALREADY_CONNECTED(1),
  OOB_CONNECTION_ERROR(2),
  OOB_DEVICE_NOT_FOUND(3),
  OOB_ALREADY_ADVERTISING(4),
  OOB_ALREADY_DISCOVERING(5),
  OOB_SENDING_DATA_FAILED(6),
  UWB_ERROR(7),
  UWB_TOO_MANY_SESSIONS(8);

  companion object {
    fun ofRaw(raw: Int): ErrorCode? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

enum class PermissionAction(val raw: Int) {
  REQUEST(0),
  RESTART(1);

  companion object {
    fun ofRaw(raw: Int): PermissionAction? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

enum class DeviceState(val raw: Int) {
  CONNECTED(0),
  DISCONNECTED(1),
  FOUND(2),
  LOST(3),
  REJECTED(4),
  PENDING(5),
  RANGING(6);

  companion object {
    fun ofRaw(raw: Int): DeviceState? {
      return values().firstOrNull { it.raw == raw }
    }
  }
}

/**
 * Direction for iOS
 *
 * Generated class from Pigeon that represents data sent in messages.
 */
data class Direction3D (
  /** The x component of the vector. */
  val x: Double,
  /** The y component of the vector. */
  val y: Double,
  /** The z component of the vector. */
  val z: Double

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): Direction3D {
      val x = list[0] as Double
      val y = list[1] as Double
      val z = list[2] as Double
      return Direction3D(x, y, z)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      x,
      y,
      z,
    )
  }
}

/**
 * UWB Data for Android and iOS
 *
 * Generated class from Pigeon that represents data sent in messages.
 */
data class UwbData (
  /**
   * Android API: The line-of-sight distance in meters of the ranging device, or null if not available.
   * Apple API: The distance from the user's device to the peer device in meters.
   */
  val distance: Double? = null,
  /** Android API: The azimuth angle in degrees of the ranging device, or null if not available. */
  val azimuth: Double? = null,
  /** Android API: The elevation angle in degrees of the ranging device, or null if not available. */
  val elevation: Double? = null,
  /**
   * Apple API: A vector that points from the user’s device in the direction of the peer device.
   * If direction is null, the peer device is out of view.
   */
  val direction: Direction3D? = null,
  /**
   * Apple API: An angle in radians that indicates the azimuthal direction to the nearby object.
   * The framework sets a value of this property when cameraAssistanceEnabled is true.
   * iOS: >= iOS 16.0
   */
  val horizontalAngle: Double? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): UwbData {
      val distance = list[0] as Double?
      val azimuth = list[1] as Double?
      val elevation = list[2] as Double?
      val direction: Direction3D? = (list[3] as List<Any?>?)?.let {
        Direction3D.fromList(it)
      }
      val horizontalAngle = list[4] as Double?
      return UwbData(distance, azimuth, elevation, direction, horizontalAngle)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      distance,
      azimuth,
      elevation,
      direction?.toList(),
      horizontalAngle,
    )
  }
}

/**
 * Represents a UWB device for Android and iOS.
 *
 * Generated class from Pigeon that represents data sent in messages.
 */
data class UwbDevice (
  val id: String,
  val name: String,
  val uwbData: UwbData? = null,
  val deviceType: DeviceType,
  val state: DeviceState? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): UwbDevice {
      val id = list[0] as String
      val name = list[1] as String
      val uwbData: UwbData? = (list[2] as List<Any?>?)?.let {
        UwbData.fromList(it)
      }
      val deviceType = DeviceType.ofRaw(list[3] as Int)!!
      val state: DeviceState? = (list[4] as Int?)?.let {
        DeviceState.ofRaw(it)
      }
      return UwbDevice(id, name, uwbData, deviceType, state)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      id,
      name,
      uwbData?.toList(),
      deviceType.raw,
      state?.raw,
    )
  }
}

@Suppress("UNCHECKED_CAST")
private object UwbHostApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          Direction3D.fromList(it)
        }
      }
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          UwbData.fromList(it)
        }
      }
      130.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          UwbDevice.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is Direction3D -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      is UwbData -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      is UwbDevice -> {
        stream.write(130)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface UwbHostApi {
  fun discoverDevices(deviceName: String, callback: (Result<Unit>) -> Unit)
  fun stopDiscovery(callback: (Result<Unit>) -> Unit)
  fun handleConnectionRequest(device: UwbDevice, accept: Boolean, callback: (Result<Unit>) -> Unit)
  fun isUwbSupported(callback: (Result<Boolean>) -> Unit)
  fun startRanging(device: UwbDevice, callback: (Result<Unit>) -> Unit)
  fun stopRanging(device: UwbDevice, callback: (Result<Unit>) -> Unit)
  fun stopUwbSessions(callback: (Result<Unit>) -> Unit)

  companion object {
    /** The codec used by UwbHostApi. */
    val codec: MessageCodec<Any?> by lazy {
      UwbHostApiCodec
    }
    /** Sets up an instance of `UwbHostApi` to handle messages through the `binaryMessenger`. */
    @Suppress("UNCHECKED_CAST")
    fun setUp(binaryMessenger: BinaryMessenger, api: UwbHostApi?) {
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.discoverDevices", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val deviceNameArg = args[0] as String
            api.discoverDevices(deviceNameArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.stopDiscovery", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            api.stopDiscovery() { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.handleConnectionRequest", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val deviceArg = args[0] as UwbDevice
            val acceptArg = args[1] as Boolean
            api.handleConnectionRequest(deviceArg, acceptArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.isUwbSupported", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            api.isUwbSupported() { result: Result<Boolean> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                val data = result.getOrNull()
                reply.reply(wrapResult(data))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.startRanging", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val deviceArg = args[0] as UwbDevice
            api.startRanging(deviceArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.stopRanging", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val deviceArg = args[0] as UwbDevice
            api.stopRanging(deviceArg) { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.uwb.UwbHostApi.stopUwbSessions", codec)
        if (api != null) {
          channel.setMessageHandler { _, reply ->
            api.stopUwbSessions() { result: Result<Unit> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                reply.reply(wrapResult(null))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}
@Suppress("UNCHECKED_CAST")
private object UwbFlutterApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          Direction3D.fromList(it)
        }
      }
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          UwbData.fromList(it)
        }
      }
      130.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          UwbDevice.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is Direction3D -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      is UwbData -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      is UwbDevice -> {
        stream.write(130)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
@Suppress("UNCHECKED_CAST")
class UwbFlutterApi(private val binaryMessenger: BinaryMessenger) {
  companion object {
    /** The codec used by UwbFlutterApi. */
    val codec: MessageCodec<Any?> by lazy {
      UwbFlutterApiCodec
    }
  }
  fun onHostDiscoveryDeviceConnected(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostDiscoveryDeviceConnected"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostDiscoveryDeviceDisconnected(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostDiscoveryDeviceDisconnected"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostDiscoveryDeviceFound(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostDiscoveryDeviceFound"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostDiscoveryDeviceLost(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostDiscoveryDeviceLost"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostDiscoveryDeviceRejected(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostDiscoveryDeviceRejected"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostDiscoveryConnectionRequestReceived(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostDiscoveryConnectionRequestReceived"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostPermissionRequired(actionArg: PermissionAction, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostPermissionRequired"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(actionArg.raw)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostUwbSessionStarted(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostUwbSessionStarted"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun onHostUwbSessionDisconnected(deviceArg: UwbDevice, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi.onHostUwbSessionDisconnected"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(deviceArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
  fun _buildTrigger(codeArg: ErrorCode, stateArg: DeviceState, callback: (Result<Unit>) -> Unit)
{
    val channelName = "dev.flutter.pigeon.uwb.UwbFlutterApi._buildTrigger"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(codeArg.raw, stateArg.raw)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
}

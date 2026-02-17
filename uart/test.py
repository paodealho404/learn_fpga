import time

import serial

# Configure serial connection
ser = serial.Serial(
    port="COM5", baudrate=115200, timeout=1
)  # Change to your serial port

time.sleep(1)  # Wait for connection to establish

try:
    while True:
        user_input = input(
            "Enter a byte value (0-255 or 0x00-0xFF) or 'exit' to quit: "
        )

        if user_input.lower() == "exit":
            break

        try:
            # Accept both decimal and hex (0x prefix)
            if user_input.lower().startswith("0x"):
                byte_value = int(user_input, 16)
            else:
                byte_value = int(user_input, 10)

            if 0 <= byte_value <= 255:
                ser.write(bytes([byte_value]))
                print(f"Sent: 0x{byte_value:02X} ({byte_value})\n")

                # Read response byte-by-byte
                while True:
                    byte_received = ser.read(1)
                    if not byte_received:
                        break  # Timeout or no more data

                    print("Response (byte-by-byte):")
                    byte_val = byte_received[0]
                    if byte_val == 10:  # newline (0x0A)
                        print(f"  [0x{byte_val:02X}] NEWLINE")
                        break
                    elif byte_val == 13:  # carriage return (0x0D)
                        print(f"  [0x{byte_val:02X}] CR")
                    else:
                        print(f"  [0x{byte_val:02X}] ({byte_val})")
                        break
            else:
                print("Enter a value between 0 and 255")
        except ValueError:
            print(
                "Invalid input. Enter a decimal (0-255) or hex (0x00-0xFF) value, or"
                " 'exit'"
            )

finally:
    ser.close()

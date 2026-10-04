# ESP32 hydroponics demo — final build guide

Basil, single reservoir, three sensors, one switched pump, three status LEDs.

**Out of scope:** the grow light. It has its own power supply and built-in timer
(set to 12 h). Not wired to the ESP32.

---

## 1. Parts and pin map

| Component | Pin | Notes |
|---|---|---|
| XKC-Y25-NPN level sensor | GPIO 4 | `INPUT_PULLUP`, LOW = water present |
| Analog TDS module | GPIO 34 | ADC1 only, `ADC_11db`, needs 5 V |
| DS18B20 temperature | GPIO 5 | 4.7 kΩ pull-up to 3V3 required |
| P2003BDG MOSFET board (pump) | GPIO 25 | TRIG input |
| Green LED — heartbeat | GPIO 18 | 220 Ω to GND |
| Yellow LED — pump running | GPIO 19 | 220 Ω to GND |
| Red LED — alarm | GPIO 21 | 220 Ω to GND |

**Avoid:** 0, 2, 12, 15 (strapping — a load here blocks boot or flashing),
6–11 (flash), 34–39 for anything but analog in (no internal pull-up).

**Never put the TDS module on an ADC2 pin** (0, 2, 4, 12–15, 25–27). The WiFi
driver owns ADC2 and `analogRead` returns garbage when WiFi is active.

### Still to buy

| Item | Search term |
|---|---|
| USB-A **male** pigtail | `USB A Stecker Pigtail offene Enden` |
| USB-A **female** pigtail | `USB A Buchse Pigtail offene Enden` |
| EC calibration solution | `EC Kalibrierlösung 1413` |
| pH drop test *(recommended)* | `pH Test Tropfen Aquarium` |
| Power strip *(optional, tidiness)* | any 3-way |

Free alternative to both pigtails: cut a USB-A extension cable (A-male to
A-female) in half.

### Have

ESP32 DevKit, XKC-Y25-NPN, TDS module, DS18B20, 10× P2003BDG boards, 5 V pump,
grow light with own supply + timer, handheld TDS/EC meter, LEDs, resistor /
diode / capacitor assortment kits, breadboards, micro-USB cable, dupont
jumpers, multimeter.

---

## 2. Power architecture

Three mains plugs: the lamp, the pump charger, the ESP32. A power strip makes
that one plug into the wall. Two plugs is possible (feed the ESP32 from the
breadboard rail instead of its own charger) — both options are covered below.

### Current budget, charger side

| Load | Draw |
|---|---|
| Pump running | ~0.5 A |
| Pump inrush, brief | +1.0 A peak |
| ESP32 | 0.08–0.25 A |
| TDS module | 0.01 A |
| DS18B20 + level sensor | <0.01 A |
| 3 LEDs @ 6 mA | 0.02 A |
| **Total** | **~0.9 A running, ~1.5 A peak** |

Any **regulated** 2 A phone charger covers it. Unregulated adapters marked 5 V
can sit well above 5 V at light load and will destroy the ESP32 — verify with
the multimeter (section 4).

### The critical rule

**The pump never draws power through the ESP32.** The ESP32 sends a gate signal
to TRIG — microamps. The pump's current runs charger → MOSFET board → pump. The
ESP32 is not in that path.

**Every ground must be common:** ESP32 GND, MOSFET board GND, charger negative,
breadboard ground rail. The MOSFET board switches the low side; without a shared
reference it will not switch at all.

---

## 3. Wiring

### Power path — screw terminals only

```
Charger ──[USB-A male pigtail]── MOSFET VIN+ / VIN−
                                        │
         MOSFET VOUT+ / VOUT− ──[USB-A female pigtail]── pump's USB plug
                    │
                 1N4007 across VOUT+ and VOUT−, stripe toward +
```

Breadboard contacts degrade under inrush and cause unpredictable dips. The
MOSFET board has screw terminals, so the pump path never touches a breadboard.

**Pigtail conductors:** red = +5 V, black = GND by USB convention. Verify with
the multimeter — cheap cables get it wrong. Cut back or tape off the green and
white data wires.

### Breadboard rail — fed from VIN

Cut two **male-to-male** dupont jumpers in half. Bare end into the screw
terminal, pin end into the breadboard rail. Four usable halves from two cables.

```
MOSFET VIN+ ──[cut dupont]──→ breadboard + rail
MOSFET VIN− ──[cut dupont]──→ breadboard − rail
```

This branch carries only the ESP32 and TDS module, under 300 mA, so 26 AWG
dupont is fine. The pump's current never flows here.

Everything then taps these rails: the 1000 µF capacitor, the TDS module's 5 V,
all LED cathodes, sensor grounds.

### 1000 µF capacitor — across the breadboard rails

**Stripe side (shorter leg, marked with minus signs) to the − rail.**

Reversed electrolytics heat up and vent. This is the one component that fails
dramatically rather than quietly. **Confirm the rating is 16 V or higher** —
6.3 V has no margin on a 5 V rail.

It supplies the pump's initial inrush from stored charge, holding the rail up
until the charger's regulation catches up, so the ESP32 never browns out.

### 1N4007 diode — across the pump terminals

**Band (cathode) toward positive.** Bend the legs into the VOUT screw terminals
alongside the pigtail wires, or solder it directly across the pump's own wires
and heatshrink it.

The pump is a motor. When the MOSFET cuts current in microseconds, the coil
generates a reverse spike — hundreds of volts on a 5 V motor — straight across a
MOSFET rated 25 V. The diode blocks normal current entirely but conducts that
reverse spike harmlessly. Without it the MOSFET dies, often after weeks.

**Backwards, the diode is a dead short.** Verify with the multimeter's diode
test before powering up.

### Level sensor (XKC-Y25-NPN)

| Wire | To |
|---|---|
| Brown | + rail (5 V) |
| Blue | − rail |
| Yellow | GPIO 4 |
| Black (if present) | leave open, or − rail to invert |

Open-collector output, so the internal pull-up gives a safe 3.3 V idle — no
level shifter needed. Glue flat against the outside of the reservoir at the
minimum-safe water height. Non-metallic wall, under 20 mm, no air gap.

### TDS module

| Wire | To |
|---|---|
| Red | + rail (5 V) |
| Black | − rail |
| Blue | GPIO 34 |

Must be 5 V. At 3.3 V the 0–2.3 V output range collapses.

**Take the cap off the probe.** Both electrodes fully submerged, plastic collar
under the surface too.

### DS18B20

| Wire | To |
|---|---|
| Red | ESP32 3V3 |
| Black | − rail |
| Yellow | GPIO 5 |

**4.7 kΩ between yellow and 3V3. Mandatory.** GPIO 5 is also a strapping pin
that must be HIGH at boot — the pull-up holds it there. Missing or miswired, the
board may refuse to flash.

### Status LEDs

Anode (long leg) to the GPIO, cathode (short leg) through 220 Ω to the − rail.

Use red, yellow, standard green. Blue and pure-green have ~3.0–3.2 V forward
voltage, leaving nothing across the resistor on a 3.3 V pin — they read dim.

---

## 4. Multimeter checks

Do these before connecting anything downstream.

| Check | Setting | Expect |
|---|---|---|
| Charger output, unloaded | DC V | 4.9–5.3 V. Above 5.5 V = unregulated, do not use |
| Pigtail polarity | DC V | Red positive relative to black |
| Diode orientation | Diode test | ~0.5–0.7 V one way, OL reversed. Band = cathode |
| Capacitor rating | read the can | 16 V or higher, 1000 µF |
| Ground continuity | Continuity | Beep between ESP32 GND, MOSFET GND, − rail |
| MOSFET VIN vs VOUT+ | Continuity | Beeps — the positives pass straight through, only the negative is switched |
| TDS output, probe in tap water | DC V | 0.1–2.3 V, **not** 0 |
| Rail voltage during pump start | DC V | Must not dip below ~4.7 V |

That last one is the real test of your capacitor. Probe the breadboard rails
while the pump kicks in — if it sags below 4.7 V, the capacitor is too small,
mis-wired, or the charger is undersized.

---

## 5. Assembly order

Each step is safe to fail. Do not skip ahead.

1. **Verify the charger** with the multimeter before it touches anything.
2. **Identify pigtail polarity** with the multimeter. Mark the wires.
3. **Wire the pump path:** male pigtail → VIN, female pigtail → VOUT, diode
   across VOUT with the band to positive. Tug-test every terminal.
4. **Diode-test the fitted diode** before applying power.
5. **Run the cut dupont halves** from VIN to the breadboard rails. Fit the
   capacitor across the rails, stripe to −.
6. **Power up with nothing else connected.** Measure the rails: ~5 V. Nothing
   should get warm. If anything does, kill power immediately.
7. **Flash the ESP32 over USB**, `CALIBRATION_MODE = true`, no sensors attached.
   Confirm it boots and prints.
8. **LEDs.** Wire all three with resistors. Green flashes every 2 s at once. A
   dark LED is reversed — long leg to GPIO.
9. **DS18B20** with its pull-up. Expect plausible room temperature. `NAN` or
   -127 means missing pull-up or wrong pin.
10. **Level sensor.** Print `digitalRead(4)`. Move it on and off the tank wall,
    confirm it flips 0 ↔ 1.
11. **TDS,** cap off, electrodes submerged. Tap water gives several hundred mV.
    A flat 142 mV is the ADC floor — that means zero or nothing connected.
12. **Connect TRIG and the ground tie** to the MOSFET board. Set
    `CALIBRATION_MODE = false`, reflash.
13. **Pump test, brief.** Yellow LED should track it. Measure the rail during
    startup — no dip below 4.7 V.
14. **Interlock test.** Reservoir full, pump running, lift the level sensor off
    the tank wall. **The pump must stop and the red LED must light.** This is the
    most important test in the list — a pump running dry destroys itself in
    minutes.
15. **Calibrate** per section 6.
16. **Run 24 h with no plants.** Check pump cycles, LEDs behave, nothing gets hot.
17. **Add basil.** Lamp timer to 12 h.

### Going standalone (optional)

Unplug USB and either plug the ESP32 into a second charger with the micro-USB
cable, or run two more cut dupont halves from the breadboard rails to the
ESP32's `5V` and `GND` pins. **Never take ESP32 power from VOUT** — that's the
switched side, so it would die whenever the pump cycles off.

---

## 6. Calibration

The firmware ships with placeholder constants. Until this is done, every EC
number it prints is fiction.

1. **Verify the handheld first.** Dip it in the 1413 µS/cm solution. If it
   doesn't read 1413 ±3 %, calibrate the handheld before trusting it.
2. **Switch the handheld to µS/cm, not ppm.** ppm is EC times an arbitrary
   factor (0.5 NaCl, 0.7 hardness) — comparing two different factors looks like
   a 40 % error when nothing is wrong.
3. Set `CALIBRATION_MODE = true`, flash. It prints raw millivolts.
4. Both probes in the same cup, stir, wait 30–60 s to settle. Record `Vcomp`
   and the handheld's µS/cm.
5. Three cups spanning your working range: tap water, nutrient at target
   strength, something weaker. **Not heavy salt water** — fitting across a range
   you never use throws away accuracy where you need it.
6. Solve from lowest and highest:

   ```
   EC_SLOPE  = (EC_high - EC_low) / (V_high - V_low)
   EC_OFFSET = EC_low - EC_SLOPE * V_low
   ```

7. Enter both, set `CALIBRATION_MODE = false`, verify the middle point lands
   within a few percent.

Recalibrate every few months and after the probe has been dry.

---

## 7. Targets for basil

| Parameter | Range | Handling |
|---|---|---|
| EC | 1000–1600 µS/cm | start seedlings near 800 |
| pH | 5.5–6.5, ideally 6.0 | manual drop test |
| Water temp | 18–24 °C | red LED + serial alarm |
| Light | 12 h, lamp's own timer | 14–16 h ideal; 12 h grows fine |

**EC trend:** plants drink water faster than they consume salts, so EC *rises*
over days — top up with plain water. Falling EC means nutrients are going faster
than water — add nutrient solution.

**pH is manual.** Test after every EC adjustment, not on a schedule — adding
concentrate or water shifts it immediately. Log readings next to the serial
output to correlate drift.

**Aeration.** If roots sit in standing water, an air pump matters more than
anything else here — still water goes anoxic and basil roots rot within days.
You have nine spare MOSFET boards.

**On 12 h of light:** expect slightly slower, leggier growth. Fine for a demo.
If plants stretch, move the lamp closer rather than extending hours.

---

## 8. Firmware

```cpp
#include <OneWire.h>
#include <DallasTemperature.h>

// ---------- configuration ----------
const bool CALIBRATION_MODE = true;   // true = print raw mV, pump stays off

const int PIN_LEVEL = 4;
const int PIN_TDS   = 34;
const int PIN_TEMP  = 5;
const int PIN_PUMP  = 25;

const int LED_OK    = 18;
const int LED_PUMP  = 19;
const int LED_ALARM = 21;

const float EC_SLOPE   = 2000.0;      // fill in from calibration
const float EC_OFFSET  = 0.0;         // fill in from calibration
const float PPM_FACTOR = 0.5;         // match your handheld

const unsigned long PUMP_ON_MS    = 15UL * 60 * 1000;
const unsigned long PUMP_CYCLE_MS = 60UL * 60 * 1000;
const unsigned long SAMPLE_MS     = 30UL * 1000;

const float TEMP_MIN = 18.0, TEMP_MAX = 24.0;
const float EC_MIN = 1000.0, EC_MAX = 1600.0;

OneWire oneWire(PIN_TEMP);
DallasTemperature ds(&oneWire);

unsigned long lastSample = 0;
bool alarmActive = false;

// ---------- sensors ----------
float medianVolts() {
  const int N = 30;
  int buf[N];
  for (int i = 0; i < N; i++) { buf[i] = analogReadMilliVolts(PIN_TDS); delay(5); }
  for (int i = 1; i < N; i++) {
    int k = buf[i], j = i - 1;
    while (j >= 0 && buf[j] > k) { buf[j + 1] = buf[j]; j--; }
    buf[j + 1] = k;
  }
  return buf[N / 2] / 1000.0;
}

float readTemp() {
  ds.requestTemperatures();
  float t = ds.getTempCByIndex(0);
  return (t == DEVICE_DISCONNECTED_C) ? NAN : t;
}

bool waterPresent() { return digitalRead(PIN_LEVEL) == LOW; }

// ---------- setup ----------
void setup() {
  Serial.begin(115200);

  pinMode(PIN_PUMP, OUTPUT);
  digitalWrite(PIN_PUMP, LOW);        // output off before anything else

  pinMode(LED_OK, OUTPUT);
  pinMode(LED_PUMP, OUTPUT);
  pinMode(LED_ALARM, OUTPUT);
  digitalWrite(LED_OK, LOW);
  digitalWrite(LED_PUMP, LOW);
  digitalWrite(LED_ALARM, LOW);

  pinMode(PIN_LEVEL, INPUT_PULLUP);
  analogSetPinAttenuation(PIN_TDS, ADC_11db);
  ds.begin();

  Serial.println(CALIBRATION_MODE ? "calibration mode" : "running");
}

// ---------- main ----------
void loop() {
  unsigned long now = millis();

  if (!CALIBRATION_MODE) {
    bool wantPump = (now % PUMP_CYCLE_MS) < PUMP_ON_MS;
    digitalWrite(PIN_PUMP, (wantPump && waterPresent()) ? HIGH : LOW);
  }

  // status LEDs, every iteration
  digitalWrite(LED_PUMP, digitalRead(PIN_PUMP));
  digitalWrite(LED_ALARM, alarmActive);
  digitalWrite(LED_OK, (now % 2000) < 100);   // brief flash every 2 s

  if (now - lastSample < SAMPLE_MS) return;
  lastSample = now;

  float t  = readTemp();
  float tc = isnan(t) ? 25.0 : t;
  float v  = medianVolts();
  float vc = v / (1.0 + 0.02 * (tc - 25.0));

  if (CALIBRATION_MODE) {
    Serial.printf("V=%.4f  Vcomp=%.4f  T=%.1f\n", v, vc, tc);
    return;
  }

  float ec    = EC_SLOPE * vc + EC_OFFSET;
  float ppm   = ec * PPM_FACTOR;
  bool  water = waterPresent();

  Serial.printf("T=%.1fC  EC=%.0f uS/cm  TDS=%.0f ppm  level=%s\n",
                tc, ec, ppm, water ? "OK" : "LOW");

  alarmActive = false;

  if (!water)   { Serial.println("  ALARM: reservoir low, pump locked out"); alarmActive = true; }
  if (isnan(t)) { Serial.println("  ALARM: temp sensor not responding");     alarmActive = true; }
  else if (tc > TEMP_MAX) { Serial.println("  ALARM: too warm, root rot risk"); alarmActive = true; }
  else if (tc < TEMP_MIN) { Serial.println("  ALARM: too cold for basil");      alarmActive = true; }

  if (ec > EC_MAX)      Serial.println("  ACTION: EC high, add plain water");
  else if (ec < EC_MIN) Serial.println("  ACTION: EC low, add nutrient");
}
```

### Notes on the code

**`millis()` instead of a clock.** No RTC and no NTP means no wall-clock time.
The modulo gives correct duty cycles relative to power-on, which is all a demo
needs. `millis()` overflows after ~49 days; modulo handles it cleanly, and the
elapsed check does too because unsigned subtraction wraps correctly.

**The interlock is inside the output expression.** `wantPump && waterPresent()`
is evaluated every loop iteration, so there is no path where the pump runs
without a live water check. If you refactor, preserve that property.

**The heartbeat proves the loop is alive.** A steady-on LED could mean "working"
or "crashed with the pin left high." A pulse can only mean the loop is running.

**LED updates sit before the sampling gate**, so heartbeat and pump indicator
refresh every iteration rather than every 30 seconds.

---

## 9. Troubleshooting

| Symptom | Cause |
|---|---|
| Upload fails, "no serial data received" | Hold BOOT during upload; disconnect all GPIO wiring; check nothing else holds the COM port; try a USB 2.0 port and a known-good data cable |
| TDS reads exactly 0 or flat 142 mV | Pin floating, **probe cap still on**, or wire broken. 142 mV is the ADC floor, not a reading |
| TDS climbs forever | Solution still equilibrating, or electrode polarization |
| Temp reads -127 or NAN | Missing 4.7 kΩ pull-up, or wrong pin |
| Board won't boot with sensors attached | Something loading a strapping pin — check GPIO 5's pull-up |
| Level sensor never triggers | Air gap, wall too thick, or metal container |
| Pump does not run | Grounds not common, or TRIG on the wrong pin |
| Pump runs weakly, MOSFET hot | Not a logic-level part — P2003BDG is fine, check the right board |
| ESP32 resets when pump starts | Capacitor missing, reversed, or undersized charger. Measure the rail during startup |
| An LED stays dark | Reversed — long leg to GPIO, short leg through resistor to − rail |
| Readings jitter | External 4.7 kΩ pull-up on the level sensor; long cables pick up noise |
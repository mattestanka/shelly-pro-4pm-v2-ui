class ShellyPro4PM

  var relay_names
  var relay_labels
  var secs
  var wifi_sum
  var wifi_cnt
  var refresh_triggered

  def init()
    var status = tasmota.cmd("status", true)['Status']
    var device = status['DeviceName']
    self.relay_names = status['FriendlyName']
    self.relay_labels = []
    self.secs = 0
    self.wifi_sum = 0
    self.wifi_cnt = 0
    self.refresh_triggered = false

    # Initialize but do not perform full refresh immediately
    # It will be triggered in the every_second method

    for relay: 0..self.relay_names.size()
      tasmota.add_rule(f"POWER{relay+1}#state", def (value) ShellyPro4PM.update_relay(relay+1,value) end )
    end

    tasmota.add_driver(self)
  end

  def deinit()
    self.del()
  end

  def del()
    for relay: 0..self.relay_names.size()
      tasmota.remove_rule(f"POWER{relay+1}#state")
    end
    tasmota.remove_driver(self)
  end

  static def display_text(text)
    tasmota.cmd(f"DisplayText {text}", true)
  end

  static def clear_screen()
    ShellyPro4PM.display_text("[Bi0z]")
  end

  static def line(line, text, fg, bg)
    ShellyPro4PM.display_text(f"[x0y{line*21+2}Ci{bg}R160:20x3y{line*21+7}Ci{fg}Bi{bg}f1]{text}")
  end

  static def switch(x, y, state)
    var width = 30
    var height = width / 2
    var radius = height / 2
    var cX = x + radius + (state ? height : 0)
    var cY = y + radius + 1
    var cR = 5
    var col = state ? 4 : 15
    ShellyPro4PM.display_text(f"[x{x}y{y+1}Ci{col}U{width}:{height}:{radius}x{cX}y{cY}Ci1K{cR}]")
  end

  static def status(x, y, percent)
    var bars = 0
    if percent
      if percent >= 20 bars = 1 end
      if percent >= 40 bars = 2 end
      if percent >= 60 bars = 3 end
      if percent >= 80 bars = 4 end
    end
    var cmd = ""
    for ofs: 0..3
      var col = bars > ofs ? 1 : 15
      cmd += f"Ci{col}x{x+ofs*4}y{y-ofs*2+10}v{(ofs+1)*2}x{x+ofs*4+1}y{y-ofs*2+10}v{(ofs+1)*2}"
    end
    cmd += f"x{x+20}y{y+2}Ci1Bi4f1t"
    ShellyPro4PM.display_text(f"[{cmd}]")
  end

  def set_header(device)
    self.line(0, device, 1, 4)
    self.status(100, 5, 0)
  end

  def set_relays()
    var relay = 1
    for n : self.relay_names
      if relay > 4
        break
      end
	var name = f"Output {relay}"  # Set the name to "Output X" where X is the relay number
        self.line(relay, name, 0, 1)
        self.update_relay(relay, tasmota.get_power(relay-1))
        relay += 1
    end

    # Add an empty line below the last relay
    # The Y-coordinate is calculated based on the relay count
    self.line(relay, "", 0, 1)
  end

  static def update_relay(relay, powered)
    # Exclude the fifth relay from being displayed
    if relay <= 4
      ShellyPro4PM.switch(123, relay*21+4, powered)
    end
  end

  def full_refresh()
    self.clear_screen()
    self.set_header(tasmota.cmd("status", true)['Status']['DeviceName'])
    self.set_relays()
    self.update_wifi_status() # Initial Wi-Fi status update
  end

  def update_wifi_status()
    var wifi = tasmota.wifi()
    var quality = wifi.find("quality")
    self.wifi_sum += quality ? quality : 0
    self.wifi_cnt += 1
    var avrg = self.wifi_sum / self.wifi_cnt
    self.status(100, 5, avrg)

    if self.secs >= 60
      self.wifi_sum = 0
      self.wifi_cnt = 0
    end
  end

 def every_second()
    self.secs += 1

    # Trigger full refresh 5 seconds after boot
    if self.secs == 5 && !self.refresh_triggered
      self.full_refresh()
      self.refresh_triggered = true
    end

    # Continue with other every_second tasks
    if self.secs % 10 == 0
      self.update_wifi_status()
    end

    if self.secs >= 60
      self.secs = 0
    end
  end

end

return ShellyPro4PM

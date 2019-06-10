dofile("config.lua")

function serve()
  local srv = net.createServer(net.TCP)
  srv:listen(80, function(conn)
      conn:on("receive", function(sck, payload)
          print(payload)
          sck:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n<h1>Hello from ESP8622</h1>\n")
      end)
      conn:on("sent", function(sck) sck:close() end)
  end)
end

function blink()
  local lighton=0
  local pin=4
  gpio.mode(pin,gpio.OUTPUT) -- Assign GPIO to Output
  local t = tmr.create()
  t:alarm(2000,1,function()
      if lighton==0 then
          lighton=1
          gpio.write(pin,gpio.HIGH) -- Assign GPIO On
      else
          lighton=0
           gpio.write(pin,gpio.LOW) -- Assign GPIO off
      end
  end)
end

function turn_led_on()
  local pin=4
  gpio.mode(pin,gpio.OUTPUT) -- Assign GPIO to Output
end

function get_ip()
  local t = tmr.create()
  t:alarm(1000, 1, function()
    if wifi.sta.getip()== nil then
      print("Obtaining IP...")
    else
      t:stop()
      print("Got IP: "..wifi.sta.getip())
    end
  end)
end

function setup_wifi()
  wifi.setmode(wifi.STATION)
  wifi.sta.autoconnect(0)
  local station_cfg={}
  station_cfg.ssid=WIFI_SSID
  station_cfg.pwd=WIFI_PASSWORD
  station_cfg.save=false
  wifi.sta.config(station_cfg)

  if USE_STATIC_IP then
    wifi.sta.setip({
      ip = WIFI_IP,
      netmask = WIFI_NETMASK,
      gateway = WIFI_GATEWAY
    })
  end
end

-- Main
setup_wifi()

wifi.sta.connect(function()
  serve()
  get_ip()
  turn_led_on()
  print("Started")
end)


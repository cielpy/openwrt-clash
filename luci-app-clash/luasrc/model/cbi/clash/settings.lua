
local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"
local HTTP = require "luci.http"
local DISP = require "luci.dispatcher"
local UTIL = require "luci.util"



m = Map("clash", translate("Settings"))
s = m:section(TypedSection, "clash")
s.anonymous = true
s.addremove=false


o = s:option(Value, "proxy_port")
o.title = translate("* Clash Redir Port")
o.default = 7892
o.datatype = "port"
o.rmempty = false
o.description = translate("Clash config redir-port")

o = s:option(Value, "dash_port")
o.title = translate("Dashboard Port")
o.default = 9090
o.datatype = "port"
o.rmempty = false
o.description = translate("Dashboard Port")

o = s:option(Value, "dash_pass")
o.title = translate("Dashboard Secret")
o.default = 123456
o.rmempty = false
o.description = translate("Dashboard Secret")

update_time = SYS.exec("ls -l --full-time /etc/clash/Country.mmdb|awk '{print $6,$7;}'")
o = s:option(Button,"update",translate("Update GEOIP Database")) 
o.title = translate("GEOIP Database")
o.inputtitle = translate("Update GEOIP Database")
o.description = update_time
o.inputstyle = "reload"
o.write = function()
  SYS.call("bash /usr/share/clash/ipdb.sh >>/tmp/clash.log 2>&1 &")
  HTTP.redirect(DISP.build_url("admin", "services", "clash","settings"))
end


md = s:option(Flag, "mode", translate("Custom DNS"))
md.default = 1
md.rmempty = false
md.description = translate("Enabling Custom DNS will Overwrite your config.yml dns section")


local dns = "/usr/share/clash/dns.yml"
o = s:option(TextValue, "dns",translate("Modify yml DNS"))
o.template = "clash/tvalue"
o.rows = 21
o.wrap = "off"
o.cfgvalue = function(self, section)
	return NXFS.readfile(dns) or ""
end
o.write = function(self, section, value)
	NXFS.writefile(dns, value:gsub("\r\n", "\n"))
	--SYS.call("/etc/init.d/adbyby restart")
end
o.description = translate("Please modify the file here.")
o:depends("mode", 1)

return m

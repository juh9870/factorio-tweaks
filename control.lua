local function loaded()
    if script.active_mods["wret-beacon-rebalance-mod"] and script.active_mods["maraxsis"] then
		remote.call("wr-beacon-rebalance", "add_whitelisted_beacon", "maraxsis-conduit")
    end
end

script.on_load(loaded)
script.on_init(loaded)
return {
  "norcalli/nvim-colorizer.lua",
  event = "BufReadPre",
  config = function()
    require("colorizer").setup({"*"},{
      RRGGBBAA=true,
      rgb_fn = true,
    })
  end,
}

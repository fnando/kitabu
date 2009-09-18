module Uv
   def Uv.foreground bg
      fg = "#FFFFFF"
      3.times do |i|
         fg = "#000000" if bg[i*2+1, 2].hex > 0xFF / 2 
      end
      fg
   end
   
   def Uv.alpha_blend bg, fg
      unless bg =~ /^#((\d|[ABCDEF]){3}|(\d|[ABCDEF]){6}|(\d|[ABCDEF]){8})$/i
         raise(ArgumentError, "Malformed background color '#{bg}'" )
      end
      unless fg =~ /^#((\d|[ABCDEF]){3}|(\d|[ABCDEF]){6}|(\d|[ABCDEF]){8})$/i
         raise(ArgumentError, "Malformed foreground color '#{fg}'" )
      end
      
      if bg.size == 4
         tbg =  (fg[1,1].hex * 0xff / 0xf).to_s(16).upcase.rjust(2, '0')
         tbg += (fg[2,1].hex * 0xff / 0xf).to_s(16).upcase.rjust(2, '0')
         tbg += (fg[3,1].hex * 0xff / 0xf).to_s(16).upcase.rjust(2, '0')
         bg = "##{tbg}"
      end
      
      result = ""
      if fg.size == 4
         result += (fg[1,1].hex * 0xff / 0xf).to_s(16).upcase.rjust(2, '0')
         result += (fg[2,1].hex * 0xff / 0xf).to_s(16).upcase.rjust(2, '0')
         result += (fg[3,1].hex * 0xff / 0xf).to_s(16).upcase.rjust(2, '0')
      elsif fg.size == 9
         if bg.size == 7
            div0 = bg[1..-1].hex
            div1, alpha = fg[1..-1].hex.divmod( 0x100 )
            3.times {      
               div0, mod0 = div0.divmod( 0x100 )
               div1, mod1 = div1.divmod( 0x100 )
               result = ((mod0 * alpha + mod1 * ( 0x100 - alpha ) ) / 0x100).to_s(16).upcase.rjust(2, '0') + result
            } 
         else
            div_a, alpha_a = bg[1..-1].hex.divmod( 0x100 )
            div_b, alpha_b = fg[1..-1].hex.divmod( 0x100 )
            alpha = alpha_a + alpha_b * (0x100 - alpha_a)
            3.times {
               div_b, c_b = div_b.divmod( 0x100 )
               div_a, c_a = div_a.divmod( 0x100 )
               result = ((c_a * alpha_a + ( 0x100 - alpha_a ) * alpha_b * c_b ) / alpha).to_s(16).upcase.rjust(2, '0') + result
            } 
         end
         #result = "FF00FF"
      else
         result = fg[1..-1]
      end
      "##{result}"
   end
   
   def Uv.normalize_color settings, color, fg = false
      if color
         if fg
            alpha_blend( settings["foreground"] ? settings["foreground"] : "#000000FF", color )
         else
            alpha_blend( settings["background"] ? settings["background"] : "#000000FF", color )
         end
      else
         color
      end
   end   
end
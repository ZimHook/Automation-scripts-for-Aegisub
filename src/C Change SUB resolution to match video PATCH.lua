--[[
README:

goto my repository https://github.com/zhang-changwei/Automation-scripts-for-Aegisub for the latest version

Change SUB resolution to match video PATCH

    [Script Info]
    ; Script generated by Aegisub 3.2.2
    ; http://www.aegisub.org/
    Title: Default Aegisub file
    ScriptType: v4.00+
    WrapStyle: 0
    ScaledBorderAndShadow: no
    YCbCr Matrix: TV.709
    PlayResX: 384
    PlayResY: 288

]]

--Script properties
script_name="C Change SUB resolution to match video PATCH"
script_description="Change SUB resolution to match video PATCH v1.2"
script_author="chaaaaang"
script_version="1.2"

include('karaskel.lua')

--GUI
dialog_config={
    {class="label",label="input resolution",x=0,y=0,width=1},
    {class="dropdown",name="i",items={"384x288","640x480","720x480","800x480","1024x576","1280x720","1440x810","1920x1080","3840x2160","7680x4320"},value="384x288",x=1,y=0},
    {class="label",label="output resolution",x=0,y=1,width=1},
    {class="dropdown",name="o",items={"384x288","640x480","720x480","800x480","1024x576","1280x720","1440x810","1920x1080","3840x2160","7680x4320"},value="1920x1080",x=1,y=1},
    {class="checkbox",name="e",label="scale \\blur, \\be, \\bord and \\shad",value=false,x=0,y=2,width=2,hint="recommend: off"},
    {class="checkbox",name="p",label="scale \\1img",value=false,x=0,y=3,hint="imagemagick required"},
    {class="checkbox",name="f",label="\\1img->\\5img",value=false,x=0,y=4},
    {class="label",label="   SUB Resolution\n          Reset v1.2",x=1,y=3,height=2}
}
buttons={"Run","Quit"}

function main(subtitle, selected)
    local meta,styles=karaskel.collect_head(subtitle,false)

    local pressed, result = aegisub.dialog.display(dialog_config,buttons)
    if (pressed=="Quit") then 
        aegisub.cancel() 
    else
        local iw,ih = result.i:match("(%d+)x(%d+)")
        local ow,oh = result.o:match("(%d+)x(%d+)")
        local rx,ry = tonumber(ow)/tonumber(iw),tonumber(oh)/tonumber(ih)

        for i=1,#subtitle do
            if subtitle[i].class=="style" then
                local style = subtitle[i]
                style.scale_x = style.scale_x*ry
                style.scale_y = style.scale_y*ry
                style.spacing = style.spacing*rx/ry
                style.margin_t = style.margin_t*ry
                style.margin_b = style.margin_b*ry
                style.margin_l = style.margin_l*rx
                style.margin_r = style.margin_r*rx

                if result.e==true then
                    style.outline = style.outline*ry
                    style.shadow = style.shadow*ry
                end
                subtitle[i] = style
            elseif subtitle[i].class=="dialogue" and subtitle[i].comment==false then
                local line=subtitle[i]
                local linetext = line.text
                linetext = linetext:gsub("}{","")

                linetext = linetext:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)",function(a,b) return "\\pos("..a*rx..","..b*ry end)
                linetext = linetext:gsub("\\org%(([%d%.%-]+),([%d%.%-]+)",function(a,b) return "\\org("..a*rx..","..b*ry end)
                linetext = linetext:gsub("(\\movev?c?)%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",function(p,a,b,c,d) 
                    return p.."("..a*rx..","..b*ry..","..c*rx..","..d*ry end)
                -- moves
                linetext = linetext:gsub("\\moves(%d)(%([^%)]*%))",function(p,a)
                    p = tonumber(p)
                    a = a:gsub("([%d%.%-]+),([%d%.%-]+)",function (x,y) return x*rx..","..y*ry end,p)
                    return "\\moves"..p..a
                end)
                -- clip
                linetext = linetext:gsub("(\\i?clip)(%([^%)]+%))",function (p,a)
                    if a:match(",")~=nil then
                        a = a:gsub("([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",function (h,j,k,l)
                            return h*rx..","..j*ry..","..k*rx..","..l*ry end)
                    else
                        a = a:gsub("([%d%.%-]+) +([%d%.%-]+)",function (b,c) return b*rx.." "..c*ry end)
                    end
                    return p..a
                end)
                
                linetext = linetext:gsub("\\fsp([%d%.%-]+)",function (a) return "\\fsp"..a*rx/ry end)
                linetext = linetext:gsub("\\fsvp([%d%.%-]+)",function (a) return "\\fsvp"..a*ry end)
                linetext = linetext:gsub("\\fsc([%d%.%-]+)", "\\fscx%1fscy%1")
                linetext = linetext:gsub("\\fscx([%d%.%-]+)",function (a) return "\\fscx"..a*ry end)
                linetext = linetext:gsub("\\fscy([%d%.%-]+)",function (a) return "\\fscy"..a*ry end)
                -- drawing
                if linetext:match("\\p%d")~=nil then
                    if linetext:match("\\fscx")~=nil then
                        linetext = linetext:gsub("\\fscx([%d%.%-]+)",function (a) return "\\fscx"..a*rx/ry end)
                    else
                        karaskel.preproc_line(subtitle,meta,styles,line)
                        linetext = linetext:gsub("^","{\\fscx"..line.styleref.scale_x*rx.."}")
                        linetext = linetext:gsub("}{","")
                    end
                    -- 1img
                    if result.p==true and result.f==false then
                        linetext = linetext:gsub("\\1img%( *([^%)]+) *%)",function (a)
                            if a:match(",")~=nil then
                                local path, xdev,ydev = a:gsub("([^,]+),([^,]+),(.*)")
                                if path~="png" then
                                    path = path:gsub("%.png$","")
                                    local cmd = string.format('magick %s -resize %f%% %s',path..".png", ry*100, path.."_"..oh..".png")
                                    os.execute(cmd)
                                    xdev,ydev = tonumber(xdev)*rx,tonumber(ydev)*ry
                                    a = path.."_"..oh..".png,"..xdev..","..ydev
                                else
                                    xdev,ydev = tonumber(xdev)*rx,tonumber(ydev)*ry
                                    a = "png,"..xdev..","..ydev
                                end
                            else
                                local path = a:gsub("%.png$","")
                                local cmd = string.format('magick %s -resize %f%% %s',path..".png", ry*100, path.."_"..oh..".png")
                                os.execute(cmd)
                                a = path.."_"..oh..".png"
                            end
                            return "\\1img("..a..")"
                        end)
                    elseif result.p==true and result.f==true then 
                        linetext = linetext:gsub("\\1img","\\5img")
                    end
                end
                if result.e==true then
                    linetext = linetext:gsub("\\be([%d%.%-]+)",function (a) return "\\be"..a*ry end)
                    linetext = linetext:gsub("\\blur([%d%.%-]+)",function (a) return "\\blur"..a*ry end)
                    linetext = linetext:gsub("\\bord([%d%.%-]+)",function (a) return "\\bord"..a*ry end)
                    linetext = linetext:gsub("\\([xy]?shad)([%d%.%-]+)",function (a,b) return a..b*ry end)
                end

                line.margin_t = line.margin_t*ry
                line.margin_b = line.margin_b*ry
                line.margin_l = line.margin_l*rx
                line.margin_r = line.margin_r*rx
                line.text = linetext
                subtitle[i]=line
            end
            aegisub.progress.set((i-1)/#subtitle*100)
        end
    end
    aegisub.log("The convertion has completed.\nPlease reset the resolution of the subtitle manually.")
	aegisub.set_undo_point(script_name)
	return selected
end

--Register macro (no validation function required)
aegisub.register_macro(script_name,script_description,main)

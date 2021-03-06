#!/bin/sh
# this  gmt5 script can not be used by gmt4
# and it's used for producing survey line data  along the depth profile
# Code by HJ
# 2018-03-31
# you should change some options 
################### global set, can be changed##################
gmt gmtset FONT_ANNOT_PRIMARY=18p,Helvetica,black
gmt gmtset FONT_ANNOT_SECONDARY=18p,Helvetica,black
gmt gmtset FONT_LABEL=18p,Helvetica,black
gmt gmtset FONT_LOGO=8p,Helvetica,black
gmt gmtset FONT_TITLE=28p,Helvetica,black
gmt gmtset MAP_TICK_LENGTH_PRIMARY=3p/2.5p
gmt gmtset MAP_TICK_LENGTH_SECONDARY=3p/2.5p
gmt set PS_CHAR_ENCODING ISOLatin1+
################################################################

profilename="sws_vs.txt"
psfile="${profilename}.eps"
evlocname="reloc.txt"
phase_flag="Vs(km/s)"  #or "Vp(km/s)" Vs(km/s)
#project option
# -JX 只用坐标轴指示的大小，可以任意给定x和y方向大长度，
# -JX<xscale>/<yscale>,负号加在yscale上表示反转坐标
proj="-JX6.0i/-2i"
#range="-R115/119/0/120"
#range="-R115/119/0/120"
range=`gmt gmtinfo -C $profilename | awk '{print "-R"$1"/"$2"/"$3"/"$4}'`
range="-R93/132.5/10/120"

#makecpt option
cpt_range="3.0/4.8/0.05"  #min/max/inc
#cpt_range=`gmt gmtinfo -C $profilename | awk '{print $5"/"$6"/"0.05}'`
cpt_phase="jet"   # types of cpt
cpt_rev="-I"      # "" not reverse
cpt_phase="seis"   # types of cpt
cpt_rev=""      # "" not reverse

#surface option interpolat
interpolate_spacing="0.1/0.5"  #dx/dy

#grdimage option
xlabel=Longitude"(\260)"
ylabel=Depth"(km)"
x_axis="a5f5"
y_axis="a20f10"
title="AA\234 profile"
echo $title

#grdcontour option
cint=`gmt gmtinfo -C $profilename | awk '{printf("%3.1f",($6-$5)/20)}'` # 表示等值线间隔，或者指定某条等值线，如6 km/s， cint=+6
anit=`gmt gmtinfo -C $profilename | awk '{printf("%3.1f",($6-$5)/20)}'`        # 标注等值线，隔0.4标注一个
limit=`gmt gmtinfo -C $profilename | awk '{print $5"/"$6}'` # 等值线范围，4/9以内的都画出来


#psscale option as grdimage option

colorbar_name=${phase_flag}
colorbar_tickint=`gmt gmtinfo -C $profilename | awk '{printf("%2.1f",($6-$5)/8)}'`
echo $colorbar_tickint
colorbar_tick="a${colorbar_tickint}f${colorbar_tickint}"  
#colorbar_tick="a3f2"  
colorbar_size="+w2i/0.3i"
colorbar_offset="+o-0.5i/0i"
colorbar_pos="jRB+v"  # denote right bottom with vertical placement, j is reference point






#######################  don't change ##########################
# plot profile
grdfile=$profilename".grd"
gmt surface $profilename  -T0  -G${grdfile}  $range  -I$interpolate_spacing 

# gmt makecpt 选项
#-C选项，指定要进行插值的主CPT文件
#-T<zmin>/<zmax>[/<zinc>[+]]，指定范围，以及色标增量，zinc有+，zinc则表示Z值间的间隔数目
#-Z 生成连续的CPT文件，
#-A[+][transparency]选项是用来设置透明度,加上+则透明度同时应用于前景色
#-D   背景色和NaN颜色,超出—T的范围都给极值的颜色，如5-7.0km/s范围，里面有4km/s和8km/s
#则4km/s与5km/s的颜色一样，8km/s和7km/s的颜色一样
cptname="temp.cpt"
gmt makecpt $cpt_rev -C${cpt_phase} -T${cpt_range}  -D   -Z > $cptname

# grdimage option 
# -Xc -Yc 把图画到画布的中间
# —V 表示输出信息
#-BWSen 表示只显示WS方向的坐标
#—Bxa1f1 横轴x方向, a表示每隔1个单位画一个，f表示每隔1个单位注释一个
#+l表示坐标轴名称

gmt grdimage $proj  $range -Xc -Yc   $grdfile  -C${cptname} \
    -BWSen+t"${title}" -Bx${x_axis}+l${xlabel} -By${y_axis}+l${ylabel}  -E300  -P -K > $psfile

#grdcontour option

#grdcontour option
# -C contour interval 可以指定某条等值线画图( -C+6 )
# -A annotated contour interval
# -L limited contours min/max
#gmt grdcontour $grdfile -R -J -C$cint -A$aint -L$limit -K  -O -Wthin,black >> $psfile
#plot event
#gmt psxy profile.loc.txt -R -J -Sc0.05i -Gblack -W0.25p -O -K >> $psfile


# gmt psscale 画色标
#-D选项，
#   [g|j|J|n|x]<refpoint>表示底图参考点
#   +o<dx>[/dy]表示偏移量
#   +v或者+h表示垂直或者是水平
#   +w<length>[/<width>]表示长度和宽度，长度为负值，反转色标
#-B选项,与其他gmt模块的-B选项一样
#   +l表示坐标名字
#-G<zlow>/<zhigh>
#   绘图前先对CPT文件做截断，使得只绘制该范围内的部分

gmt psscale -R -J -C${cptname} -Bx${colorbar_tick}  \
    -By+l"${colorbar_name}" -D${colorbar_pos}${colorbar_size}${colorbar_offset} -I   -O >> $psfile
     #-B+l"Vp(km/s)" -DjRB+w0.8i/0.1i+o-0.8/0.2i+v -I  -K -O >> $psfile
gmt psconvert $psfile -A -E300 -Tj
# clean temp file
rm -rf $grdfile
rm -rf temp.cpt
rm -rf gmt.history
rm -rf gmt.conf gmt.history
gs $psfile


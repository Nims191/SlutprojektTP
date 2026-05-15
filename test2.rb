#definerar några globala variabler och bestämmer storleken på spelskärmen, samt startar ruby2d
require 'ruby2d'
$grids=50
$side = $grids*9
set width: $side
set height: $side
$round = 0
$indexBlue=0
$indexPink=0
#Denna funktionen nollställer alla globala varibaler som ändras under spelets gång och den skapar alla linjer på spelplanen,
def start
  $round = 0
  $indexBlue = 0
  $indexPink = 0
  $xbigcordsBlue = []
  $ybigcordsBlue = []
  $xbigcordsPink = []
  $ybigcordsPink = []
  $xcords = []
  $ycords = []
  i = 1
  #while loopen skapar alla linjer
  while i < 9
    Rectangle.new(
      x:$grids*(i)-2.5, y: 0,
      width: 5, height:$side,
      color: 'teal',
    )
    Rectangle.new(
      x:0 , y: $grids*i-2.5,
      width: $side, height:5,
      color: 'teal',
    )
    if i==3 || i==6
      Rectangle.new(
      x:0 , y: $grids*i-4,
      width: $side, height:8,
      color:'orange', )
      Rectangle.new(
      x:$grids*i-4 , y: 0,
      width: 8, height:$side,
      color: 'orange',)
    end
    i+=1
  end
end

#I denna funktionen kollar om man får placera, byter turn och ökar $round
def draw(x,y)
  i = 0
  stop=false
  #if-satsen kollar om det inte är första rundan och isåfall kollar den om man placerar i rätt liten spelplan och om man ska placera i en redan vunnen spelplan kan man placera på alla ställen förutom den vunna spelplanen. 
  if $round != 0
    if (check == false) && (convert_to_bigcords != [floor($grids*3,x+$grids),floor($grids*3,y+$grids)])
      stop=true
    elsif (check == true) && (convert_to_bigcords == [floor($grids*3,x+$grids),floor($grids*3,y+$grids)])
      stop=true
    end
  end
  #först kollar den om stop är false, sen gör while loopen så att man inte kan placera där det redan finns en markör.
  if stop == false
    while i < $round+1
      #om hela spelplanen är full och ingen har vunnit börjar spelet om
      if $round >= 81
        clear
        start
        return
      #if-satsen nedan kollar om man har placerat på en bricka som har en markör
      elsif (x/$grids == $xcords[i] && $ycords[i] == y/$grids)
        return
      end
      i+=1
    end
  else
    return
  end
  #lägger in kordinaterna för den placerade markören i en array och delar på grids för att få värdena i arrayen i ett 9x9 system
  $xcords[$round] = x/$grids
  $ycords[$round] = y/$grids
  #kollar om det är den blåas tur och placerar isåfall en kvadrat annars skapas en råsa cirkel
  if $round.even?
    x = x+2
    y = y+2
    Square.new(x: x, y: y, size: $grids*0.9, color: 'blue')
  else
    x = x+$grids/2
    y = y+$grids/2
    Circle.new(x: x, y: y, radius: $grids*0.45, color: 'fuchsia')
  end
  #kallar på dom båda winfuktionerna för att se om någon har vunnit i antingen den lilla eller den stora spelplanen
  win
  winbigcords
  $round += 1
  #kollar om alla brickor är fyllda och nollställer isåfall spelet
  if $round > 81
    clear
    start
  end
end

#kollar om spelet vill att man ska placera i en redan vunnen spelplan, isåfall returnar den true
def check
  i=0
  #kollar för alla blåa värden
  while i < $xbigcordsBlue.length
    if convert_to_bigcords == [$xbigcordsBlue[i],$ybigcordsBlue[i]]
      return true
    end
    i+=1
  end
  i = 0
  #kollar för alla råsa värden
  while i < $xbigcordsPink.length
    if convert_to_bigcords == [$xbigcordsPink[i],$ybigcordsPink[i]]
      return true
    end
    i+=1
  end
  return false
end

#en egen floor funktion där man kan först kan skriva in vilket "steg" man vill att värdet ska avrundas ner till och sedan vad man vill avrunda. Skriver man tex in floor(5,23) får man 20
def floor(size, number)
  i=0
  while size*(i+1) < number
    i+=1
  end
  return (size*i)
end

#denna funktionen kollar vart man har placerat i en liten spelplan och kollar vilken kordinat det blir i den stora spelplanen. för att kunna bestämma vart man ska placera nästa runda
def convert_to_bigcords
  #kollar så att det inte är den första rundan
  if $round != 0
    xcords=0
    ycords=0
    xbefore = $xcords[$round-1]
    ybefore = $ycords[$round-1]
    i = 6
    #fungerar som en floor funktion men iställer för att ge tillbaka ett avrundat värde ger den tillbaka det som "blir över". Placerar man på xkordinaten 5 får man tillbaka x = 2
    while i > -1
      if xbefore >= i
        xbefore = xbefore-i 
      end
      if ybefore >= i
        ybefore = ybefore-i 
      end
      i-=3
    end
    #Nedan multipliceras kordinaten med storleken av en liten spelplan och lägger värdena i en array.
    bigcords = [xbefore*($grids*3),ybefore*($grids*3)]
    #skickar tillbaka arrayen
    return bigcords
  else
    #Om det är första rundan görs bigcords till [-1,-1], detta är förat oavsett var spelaren placerar under fösta rundan ska det alldrig kunna vara lika med bigcords
    bigcords = [-1,-1]
    return bigcords
  end
end

#Win funktionen kollar om någon har vunnit i en liten spelplan och isåfall också vilken färg som har vunnit, samt placerar en stor markör över hela den spelplanen
def win
  #kollar så att det inte är fösta rundan
  if $round != 0
    #första halvan av funktionen kollar för blåa markörer
    #för att inte behöva kolla alla små spelplaner kollas bara den där den senaste brickan placerades
    x = floor(3,$xcords[$round]+1)
    y = floor(3,$ycords[$round]+1)
    #här skapar jag dubbla uppsättningar av x och y värden, detta är för att kunna ändra den ena uppsättningen och kunna ha kvar den andra.
    xincrement = floor(3,$xcords[$round]+1)
    yincrement = floor(3,$ycords[$round]+1)
    swin1=0
    swin2=0
    while xincrement < 3+x
      #eftersom denna delen av funktionen ska kolla blåa placeringar kollar den alla jämna värden och därför börjar i på 0
      i=0
      win11=0
      win21=0
      while i <= $round
        #kollar om någon har placerat i den ena diagonalen
        if $xcords[i] == xincrement && $ycords[i] == yincrement
          swin1+=1
        end
        #kollar om någon har placerat i den andra diagonalen
        if $xcords[i] == xincrement && $ycords[i] == 2*y+2-yincrement
          swin2+=1
        end
        #kollar om någon har placerat i en rad i y-led
        if $xcords[i] == xincrement && ($ycords[i] == y || $ycords[i] == 1+y || $ycords[i] == 2+y)
          win11 +=1
        end
        #kollar om någon har placerat i en rad i x-led
        if $ycords[i] == yincrement && ($xcords[i] == x || $xcords[i] == 1+x || $xcords[i] == 2+x)
          win21 +=1
        end
        wins = [win11,win21]
        #om win11 eller win21 är 3 innebär det att det finns en rad med blåa markörer och då har man vunnit.
        if wins.include?(3)
          #createbigblue skapar en stor blå markör över hela den lilla spelplan där man har vunnit 
          createbigblue
        end
        #ökar med två för att bara kolla jämna "i" värden
        i+=2
      end
      #förskuter vart man kollar igenom att flytta den ena uppsättningen av x och y värden med en position
      xincrement +=1
      yincrement +=1
    end
    #om swin1 eller swin2 är 3 har man har vunnit i någon av diagonalerna
    swins=[swin1,swin2]
    if swins.include?(3)
      createbigblue
    end
    #resten av funktionen gör exakt samma sak som första halvan fast "i" börjar på 1 för att kolla alla ojämna värden, vilket är dom rosa markörerna och om man vinner kallar den på createbigpink, som skapar en rosa cirkel iställer för en blå kvadrat.
    swin1 = 0
    swin2 = 0
    wins = []
    xincrement = x
    yincrement = y
    swin1=0
    swin2=0
    while xincrement < 3+x
      i=1
      win12=0
      win22=0
      while i <= $round
        if $xcords[i] == xincrement && $ycords[i] == yincrement
          swin1+=1
        end
        if $xcords[i] == xincrement && $ycords[i] == 2*y+2-yincrement
          swin2+=1
        end
        if $xcords[i] == xincrement && ($ycords[i] == y || $ycords[i] == 1+y || $ycords[i] == 2+y)
          win12 +=1
        end
        if $ycords[i] == yincrement && ($xcords[i] == x || $xcords[i] == 1+x || $xcords[i] == 2+x)
          win22 +=1
        end
        wins = [win12,win22]
        if wins.include?(3)
          createbigpink
        end
        i+=2
      end
      xincrement +=1
      yincrement +=1
    end
    swin=[swin1,swin2]
    if swin.include?(3)
      createbigpink
    end
  end
end 

#denna funktionen skapar en stor cirkel och sparar kordinaterna för cirkeln i två olika arrayer
def createbigpink
  createX = convert_to_bigcords[0]
  createY = convert_to_bigcords[1]
  Circle.new(x: createX+$grids*1.5, y: createY+$grids*1.5, radius: $grids*1.5, color: 'fuchsia')
  $xbigcordsPink[$indexPink]= createX
  $ybigcordsPink[$indexPink]= createY
  $indexPink +=1
end

#denna funktionen skapar en stor kvadrat och sparar kordinaterna för kvadraten i två olika arrayer
def createbigblue
  createX = convert_to_bigcords[0]
  createY = convert_to_bigcords[1]
  Square.new(x: createX, y: createY, size: $grids*3, color: 'blue')
  $xbigcordsBlue[$indexBlue]= createX
  $ybigcordsBlue[$indexBlue]= createY
  $indexBlue +=1
end

#winbigcords funktionen kollar om någon har vunnit i den stora spelplanen och 
def winbigcords
  #cords funkar som både en x och y cordinat i denna funktionen
  cord=0
  swin1=0
  swin2=0
  while cord < $grids*6+1
    i=0
    win1=0
    win2=0
    while i < $xbigcordsBlue.length
      #if-satsen nedan kollar om man har vunnit i den ena diagonalen
      if $xbigcordsBlue[i] == cord && $ybigcordsBlue[i] == cord 
        swin1+=1
      end
      #if-satsen nedan kollar om man har vunnit i den andra diagonalen
      if $xbigcordsBlue[i] == cord && $ybigcordsBlue[i] == $grids*6-cord 
        swin2+=1
      end
      #if-satsen kollar om någon markör ligger i rad på ett y led
      if $xbigcordsBlue[i] == cord && ($ybigcordsBlue[i] == 0 || $ybigcordsBlue[i] == $grids*3 || $ybigcordsBlue[i] == $grids*6)
        win1+=1
      end 
      #if-satsen kollar om någon markör ligger i rad på ett x led
      if $ybigcordsBlue[i] == cord && ($xbigcordsBlue[i] == 0 || $xbigcordsBlue[i] == $grids*3 || $xbigcordsBlue[i] == $grids*6)
        win2+=1
      end
      i+=1
    end
    #är win1 eller win2 3 innerbär det att det har legat tre markörer i rad i antingen x ledet eller y ledet och det innbär att någonhar vunnit
    if win1 == 3 || win2 == 3
      Square.new(x: 0, y: 0, size: $side, color: 'blue')
    end
    win1=0
    win2=0
    #här ökas cord för att flytta vart funktionen koller efter en vinst
    cord+=$grids*3
  end
  #om någon har vunnit i diagonalen är swin1 eller swin2 = 3 och då skapas en stor markör över hela spelplanen
  if swin1 == 3 || swin2 == 3
    Square.new(x: 0, y: 0, size: $side, color: 'blue')
  end
  #här nollställs alla variabler och hela funktionen börjar om men denna gången kollas rosas kordinater.  
  cord=0
  swin1=0
  swin2=0
  while cord < $grids*6+1
    i=0
    win1=0
    win2=0
    while i < $xbigcordsPink.length
      if $xbigcordsPink[i] == cord && $ybigcordsPink[i] == cord 
        swin1+=1
      end
      if $xbigcordsPink[i] == cord && $ybigcordsPink[i] == $grids*6-cord 
        swin2+=1
      end
      if $xbigcordsPink[i] == cord && ($ybigcordsPink[i] == 0 || $ybigcordsPink[i] == $grids*3 || $ybigcordsPink[i] == $grids*6)
        win1+=1
      end 
      if $ybigcordsPink[i] == cord && ($xbigcordsPink[i] == 0 || $xbigcordsPink[i] == $grids*3 || $xbigcordsPink[i] == $grids*6)
        win2+=1
      end
      i+=1
    end
    if win1 == 3 || win2 == 3
      Circle.new(x: $side/2, y: $side/2, radius: $side/2, color: 'fuchsia')
    end
    win1=0
    win2=0
    cord+=$grids*3
  end
  if swin1 == 3 || swin2 == 3
    Circle.new(x: $side/2, y: $side/2, radius: $side/2, color: 'fuchsia')
  end  
end

start

on :mouse_down do |event|
  case event.button
  when :left
    draw(floor($grids,event.x),floor($grids,event.y))
  end
end
show

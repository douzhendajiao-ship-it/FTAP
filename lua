

--[[
猿ゴット.lua (Full Edition + Music)
Genesis Base + Grabkick Original
機能: Protections / Loops / Grab / Misc / Build / Fun / Auras / Music / UI
]]
local repo="https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library=loadstring(game:HttpGet(repo.."Library.lua"))()
local ThemeManager=loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))()
local SaveManager=loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))()
local Options=Library.Options
local Toggles=Library.Toggles
Library.ForceCheckbox=true

local PS=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local R=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local WS=workspace
local LP=PS.LocalPlayer
local CE=RS:WaitForChild("CharacterEvents",10)
local GE=RS:WaitForChild("GrabEvents")
local SNO=GE:WaitForChild("SetNetworkOwner")
local CGL=GE:FindFirstChild("CreateGrabLine")
local DGL=GE:FindFirstChild("DestroyGrabLine")
local SPW=RS:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
local DTY=RS:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
local STR=CE and CE:FindFirstChild("Struggle")
local RAG=CE and CE:FindFirstChild("RagdollRemote")
local ISH=LP:WaitForChild("IsHeld",10)

-- ============================================================
-- State
-- ============================================================
local S={
run=false,target="",tUser=nil,lag=false,toy=nil,spawning=false,rc=nil,
antiGrab=false,antiVoid=false,antiBurn=false,antiExplode=false,antiInvis=false,
antiRagdoll=false,antiBanana=false,antiReset=false,antiSticky=false,
lockPos=false,killDodge=false,antiInput=false,waterWalk=false,
antiBring=false,antiOwnV1=false,antiOwnV2=false,antiGrabV1=false,antiGrabV2=false,
deleteLegs=false,antiKickItem=false,gucciActive=false,gucciTrain=false,
gucciRunId=0,gucciKey=Enum.KeyCode.V,myPCLD=nil,
selectedAntiKickToy="SpookyCandle1",
lockedCF=nil,safePos=nil,lastSafe=nil,inputInterval=0.05,
selectedInputToy="FoodCoconut"
}

local function list() local t={} for _,p in ipairs(PS:GetPlayers()) do if p~=LP then t[#t+1]=p.DisplayName.." (@"..p.Name..")" end end return t end
local function find(n) for _,p in ipairs(PS:GetPlayers()) do if p.DisplayName.." (@"..p.Name..")"==n then return p end end end
local function notify(t,d,time) Library:Notify({Title=t or "猿ゴット",Description=d or "",Time=time or 3}) end

-- ============================================================
-- Grabkick Core
-- ============================================================
local function spawnToy()
if S.spawning then return end S.spawning=true
local c=LP.Character or LP.CharacterAdded:Wait()
local root=c:WaitForChild("HumanoidRootPart")
local cf=root.CFrame*CFrame.new(0,14,20)
local cont=WS:FindFirstChild(LP.Name.."SpawnedInToys") or WS
local toy
local cn=cont.ChildAdded:Connect(function(x) if x.Name=="PalletLightBrown" then toy=x end end)
pcall(function() SPW:InvokeServer("PalletLightBrown",cf,Vector3.zero) end)
local t0=tick() repeat task.wait(0.05) until toy or tick()-t0>5
cn:Disconnect() if not toy then S.spawning=false return end
local sp=toy:FindFirstChild("SoundPart") or toy:WaitForChild("SoundPart",3)
if not sp then toy:Destroy() S.spawning=false return end
for i=1,10 do if not S.run then toy:Destroy() S.spawning=false return end
SNO:FireServer(sp,sp.CFrame) task.wait()
if sp:FindFirstChild("PartOwner") then break end
end
if not sp:FindFirstChild("PartOwner") then toy:Destroy() S.spawning=false return end
for _,v in pairs(toy:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false v.Transparency=0.8 end end
toy.Name="RagdollPalete"
local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(0,math.huge,0) bv.Velocity=Vector3.new(0,900,0) bv.Parent=sp
S.spawning=false return toy
end

local function startLag()
if S.lag or not CGL then return end S.lag=true
task.spawn(function() while S.lag do
local loc=WS:FindFirstChild("SpawnLocation") or WS:FindFirstChild("Spawn") or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
if loc then CGL:FireServer(loc,CFrame.new(math.random(-2e9,2e9),0,math.random(-2e9,2e9))) end
task.wait()
end end)
end

local function grabLoop()
task.spawn(function() while S.run do
local t=find(S.target) local c=LP.Character
local r=c and c:FindFirstChild("HumanoidRootPart")
if t and r then
local tr=t.Character and t.Character:FindFirstChild("HumanoidRootPart")
if tr then
if (r.Position-tr.Position).Magnitude>25 then
local save=r.CFrame r.CFrame=tr.CFrame*CFrame.new(0,0,2)
for _=1,15 do SNO:FireServer(tr,tr.CFrame) task.wait() end
r.CFrame=save
end
SNO:FireServer(tr,tr.CFrame)
if DGL then DGL:FireServer(tr) end
tr.AssemblyLinearVelocity=Vector3.zero tr.AssemblyAngularVelocity=Vector3.zero
local bp=tr:FindFirstChild("ControlBP")
if not bp then bp=Instance.new("BodyPosition") bp.Name="ControlBP"
bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge) bp.P=800000 bp.Parent=tr end
bp.Position=r.Position+Vector3.new(5,10,5)
end
end
task.wait()
end end)
end

local function grabRender()
local cont=WS:FindFirstChild(LP.Name.."SpawnedInToys")
S.rc=R.RenderStepped:Connect(function()
if not S.run or not S.tUser then return end
local p=PS:FindFirstChild(S.tUser) if not p or not p.Character then return end
local r=p.Character:FindFirstChild("HumanoidRootPart") local h=p.Character:FindFirstChild("Humanoid")
if not r or not h then return end
if S.toy and S.toy:IsDescendantOf(WS) then
local sp=S.toy:FindFirstChild("SoundPart")
if sp then if not sp:FindFirstChild("PartOwner") then S.toy:Destroy() S.toy=nil end
else S.toy:Destroy() S.toy=nil end
end
if not S.spawning and (not S.toy or not S.toy:IsDescendantOf(WS)) then
S.toy=(cont and cont:FindFirstChild("RagdollPalete")) or spawnToy()
end
if S.toy and S.toy:FindFirstChild("SoundPart") then
local rg=h:FindFirstChild("Ragdolled") if rg and not rg.Value then
S.toy.SoundPart.Position=r.Position
end
end
end)
end

local function grabStop()
S.lag=false S.run=false
if S.rc then S.rc:Disconnect() S.rc=nil end
if S.toy and S.toy:IsDescendantOf(WS) then S.toy:Destroy() S.toy=nil end
local p=find(S.target) if p and p.Character then
local r=p.Character:FindFirstChild("HumanoidRootPart")
if r and r:FindFirstChild("ControlBP") then r.ControlBP:Destroy() end
end
end

-- ============================================================
-- Anti Grab (基本)
-- ============================================================
local AGCons={}
local function AGDisc() for _,c in pairs(AGCons) do if c then c:Disconnect() end end table.clear(AGCons) end
local function AGApply(char)
if not char or not S.antiGrab then return end
local hrp=char:WaitForChild("HumanoidRootPart",5)
local hum=char:WaitForChild("Humanoid",5)
local head=char:WaitForChild("Head",5)
if not (hrp and hum and head) then return end
for _,v in pairs(char:GetChildren()) do
if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name~="Head" then
v.BallSocketConstraint.Enabled=false
if v:FindFirstChild("RagdollLimbPart") then v.RagdollLimbPart.WeldConstraint.Enabled=false end
end
end
AGCons.head=head.ChildAdded:Connect(function(p)
if p.Name=="PartOwner" then
hum.Sit=false
if STR then STR:FireServer(LP) end
task.spawn(function() while head and head:FindFirstChild("PartOwner") or (ISH and ISH.Value) do
if STR then STR:FireServer(LP) end
if RAG then RAG:FireServer(hrp,0) end
task.wait()
end end)
hrp.Anchored=true
task.spawn(function() while ISH and ISH.Value and task.wait() do
hrp.CFrame=hrp.CFrame+hum.MoveDirection*0.43
end hrp.Anchored=false end)
end
end)
local rag=hum:WaitForChild("Ragdolled",5)
if rag then
AGCons.rag=rag.Changed:Connect(function()
if hum.Ragdolled.Value then
for _,v in pairs(char:GetChildren()) do
if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name~="Head" then
v.BallSocketConstraint.Enabled=false
if v:FindFirstChild("RagdollLimbPart") then v.RagdollLimbPart.WeldConstraint.Enabled=false end
end
end
end
end)
end
end

-- ============================================================
-- Anti Void
-- ============================================================
local function AVStart()
S.safePos=nil
task.spawn(function() while S.antiVoid do
pcall(function()
local c=LP.Character local h=c and c:FindFirstChild("Humanoid")
local r=c and c:FindFirstChild("HumanoidRootPart")
if r and h and h.Health>0 then
local y=r.Position.Y
if y>-30 and y<800 then
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
rp.FilterDescendantsInstances={c}
local res=WS:Raycast(r.Position,Vector3.new(0,-100,0),rp)
S.safePos=res and (res.Position+Vector3.new(0,3.5,0)) or r.Position
else
r.AssemblyLinearVelocity=Vector3.zero
r.AssemblyAngularVelocity=Vector3.zero
r.CFrame=CFrame.new((S.safePos or Vector3.new(0,50,0))+Vector3.new(0,3,0))
end
end
end)
task.wait()
end end)
end

-- ============================================================
-- Anti Burn
-- ============================================================
local burnConn
local function ABStart(char)
local hum=char:WaitForChild("Humanoid")
local hrp=char:WaitForChild("HumanoidRootPart")
char.PrimaryPart=hrp
if burnConn then burnConn:Disconnect() end
burnConn=hum.FireDebounce.Changed:Connect(function(burning)
if burning then
local oldCF=hrp.CFrame
local plots=WS:FindFirstChild("Plots")
local p2=plots and plots:FindFirstChild("Plot2")
local bar=p2 and p2:FindFirstChild("Barrier")
local pb=bar and bar:FindFirstChild("PlotBarrier")
if pb and pb:IsA("BasePart") then
char:SetPrimaryPartCFrame(pb.CFrame*CFrame.new(0,6,0))
task.wait(0.3)
local fp=char:FindFirstChild("FirePlayerPart",true)
if fp then
for _,o in ipairs(fp:GetChildren()) do
if o:IsA("Sound") then o:Stop() end
if o:IsA("Light") or o:IsA("ParticleEmitter") then o.Enabled=false end
end
if fp:FindFirstChild("CanBurn") then fp.CanBurn.Value=false end
if hum:FindFirstChild("FireDebounce") then hum.FireDebounce.Value=false end
end
task.wait(0.6)
char:SetPrimaryPartCFrame(oldCF)
end
end
end)
end

-- ============================================================
-- Anti Explosion
-- ============================================================
local function AEStart()
local c=LP.Character if not c then return end
local r=c:WaitForChild("HumanoidRootPart")
WS.ChildAdded:Connect(function(m)
if m.Name=="Part" and S.antiExplode then
if (m.Position-r.Position).Magnitude<=20 then
r.Anchored=true
task.wait(0.01)
local ra=c:FindFirstChild("Right Arm")
while ra and ra:FindFirstChild("RagdollLimbPart") and ra.RagdollLimbPart.CanCollide do task.wait(0.001) end
r.Anchored=false
end
end
end)
end

-- ============================================================
-- Anti Invis
-- ============================================================
local function AIStart()
task.spawn(function() while S.antiInvis do
pcall(function()
local c=LP.Character if c then
for _,p in pairs(c:GetDescendants()) do
if p:IsA("BasePart") then p.LocalTransparencyModifier=0
elseif p:IsA("Decal") or p:IsA("Texture") then p.Transparency=0 end
end
end
end)
task.wait()
end end)
end

-- ============================================================
-- Lock Position
-- ============================================================
local function LPStart()
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")
if r then S.lockedCF=r.CFrame end
task.spawn(function() while S.lockPos do
pcall(function()
local ch=LP.Character local ro=ch and ch:FindFirstChild("HumanoidRootPart")
if ro and S.lockedCF then
ro.CFrame=S.lockedCF
ro.AssemblyLinearVelocity=Vector3.zero
ro.AssemblyAngularVelocity=Vector3.zero
end
end)
task.wait()
end end)
end

-- ============================================================
-- Anti Ragdoll (Blob)
-- ============================================================
local arCons
local function ARStart(char)
local hum=char:WaitForChild("Humanoid",5)
local hrp=char:WaitForChild("HumanoidRootPart",5)
if not (hum and hrp) then return end
if arCons then arCons:Disconnect() end
local inProc=false
arCons=hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
if hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name=="CreatureBlobman" and not inProc then
inProc=true
local seat=hum.SeatPart
while not hum.Sit do task.wait() end
if RAG then RAG:FireServer(hrp,3) end
local rd=hum:FindFirstChild("Ragdolled")
while rd and not rd.Value and not hum.Sit do task.wait() end
task.wait(0.4)
hum.Sit=false seat:Sit(hum)
task.delay(0.25,function()
while hum and hum.SeatPart do
if RAG then RAG:FireServer(hrp,1) end
task.wait(0.05)
end
inProc=false
end)
end
end)
end

-- ============================================================
-- Anti Banana
-- ============================================================
local function ABananaStart()
task.spawn(function() while S.antiBanana do
local c=LP.Character
if c then
local h=c:FindFirstChildOfClass("Humanoid")
local r=c:FindFirstChild("HumanoidRootPart")
if h and r and h.Health>0 then
h.Sit=true
h:ChangeState(Enum.HumanoidStateType.Running)
local cam=WS.CurrentCamera
local v=cam.CFrame.LookVector
r.CFrame=CFrame.new(r.Position,r.Position+Vector3.new(v.X,0,v.Z))
end
end
task.wait()
end end)
end

-- ============================================================
-- Anti Reset
-- ============================================================
local arstConn
local function ARstStart()
local GCE=RS:FindFirstChild("GameCorrectionEvents")
if not GCE then return end
arstConn=GCE.GameCorrectionsNotify.OnClientEvent:Connect(function(r)
if r=="Flying" then
local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState("Dead") notify("Anti Reset","Flying検知→リセット",3) end
end
end)
end

-- ============================================================
-- Kill Dodge (House TP)
-- ============================================================
local function KDStart()
task.spawn(function() while S.killDodge do
local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
local r=c and c:FindFirstChild("HumanoidRootPart")
local ip=LP:FindFirstChild("InPlot")
if h and r and (not ip or not ip.Value) and h.Health>0 then
local plots=WS:FindFirstChild("Map") and WS.Map:FindFirstChild("Plots")
local tpos=Vector3.new(252,-7,464)
if plots then
for _,pl in pairs(plots:GetChildren()) do
if pl:FindFirstChild("Owner") and pl.Owner.ValueLP then
if pl.Name"Plot1" then tpos=Vector3.new(-533,-7,90)
elseif pl.Name=="Plot2" then tpos=Vector3.new(-483,-7,-164)
elseif pl.Name=="Plot3" then tpos=Vector3.new(252,-7,464)
elseif pl.Name=="Plot4" then tpos=Vector3.new(509,83,-339)
elseif pl.Name=="Plot5" then tpos=Vector3.new(553,123,-74) end
break
end
end
end
r.CFrame=CFrame.new(tpos) r.Anchored=false
end
task.wait()
end end)
end

-- ============================================================
-- Anti Input Lag
-- ============================================================
local function AILStart()
task.spawn(function()
while S.antiInput do
pcall(function()
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")
if not r then return end
local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
local food=inv and inv:FindFirstChild("antiinputfood")
if not food then
SPW:InvokeServer(S.selectedInputToy,r.CFrame,Vector3.zero)
task.wait(0.1)
inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
local nf=inv and inv:FindFirstChild(S.selectedInputToy)
if nf then nf.Name="antiinputfood" end
end
inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
local cf=inv and inv:FindFirstChild("antiinputfood")
if cf then
local hp=cf:FindFirstChild("HoldPart")
if hp and hp:FindFirstChild("HoldItemRemoteFunction") then
hp.HoldItemRemoteFunction:InvokeServer(cf,c)
if hp:FindFirstChild("DropItemRemoteFunction") then
hp.DropItemRemoteFunction:InvokeServer(cf,CFrame.new(0,1e9,0),Vector3.zero)
end
end
end
end)
task.wait(S.inputInterval)
end
local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
if inv and inv:FindFirstChild("antiinputfood") then pcall(function() DTY:FireServer(inv.antiinputfood) end) end
end)
end

-- ============================================================
-- Water Walk
-- ============================================================
local waterParts={}
task.spawn(function()
local m=WS:FindFirstChild("Map")
local ah=m and m:FindFirstChild("AlwaysHereTweenedObjects")
local oc=ah and ah:FindFirstChild("Ocean")
local o=oc and oc:FindFirstChild("Object") and oc.Object:FindFirstChild("ObjectModel")
if o then for _,v in ipairs(o:GetChildren()) do
if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
waterParts[#waterParts+1]=v
end
end end
end)
local function WWSet(on) for _,p in ipairs(waterParts) do if p then p.CanCollide=on end end end

-- ============================================================
-- House Break
-- ============================================================
local shurikens={}
local plotMap={["green house"]="1",["pink house"]="2",["purple house"]="3",["blue house"]="4",["red house"]="5"}
local houseNames={} for n in pairs(plotMap) do houseNames[#houseNames+1]=n end table.sort(houseNames)
local selectedHouse="1"

local function spawnThing(toyName,cf)
local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys") if not inv then return end
local s local cn=inv.ChildAdded:Connect(function(c) if c.Name==toyName then s=c end end)
pcall(function() SPW:InvokeServer(toyName,cf,Vector3.zero) end)
local t=tick() repeat task.wait() until s or tick()-t>3
cn:Disconnect() return s
end

local function breakPlot(num)
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart") if not r then return end
local stick=RS:FindFirstChild("PlayerEvents") and RS.PlayerEvents:FindFirstChild("StickyPartEvent")
if not stick then return end
local plot=WS:FindFirstChild("Plots") and WS.Plots:FindFirstChild("Plot"..num)
local pa=plot and plot:FindFirstChild("PlotArea") if not pa then notify("猿ゴット","Plot "..num.."なし",3) return end
local can=LP:FindFirstChild("CanSpawnToy") while can and not can.Value do can.Changed:Wait() end
local cle=spawnThing("ToolCleaver",r.CFrame*CFrame.new(5,5,20)) if not cle then return end
task.wait(0.1)
local sp=cle:WaitForChild("SoundPart",2) if not sp then return end
SNO:FireServer(sp,sp.CFrame) task.wait(0.1)
sp.CFrame=CFrame.new(0,math.random(9990,9999),0)
cle.Name="plotfucker"
local st=cle:WaitForChild("StickyPart",2) if not st then return end
task.wait(0.1)
stick:FireServer(st,pa,CFrame.new(2.199e12,2.199e12,2.199e12))
shurikens[#shurikens+1]=cle
return true
end

local function reenableAll()
for _,t in ipairs(shurikens) do pcall(function() DTY:FireServer(t) end) end
table.clear(shurikens) notify("猿ゴット","Plot復元",3)
end

-- ============================================================
-- Destroy Map
-- ============================================================
local function destroyMap()
local map=WS:FindFirstChild("Map") if not map then return end
task.spawn(function()
for _,c in ipairs(map:GetChildren()) do
if c:IsA("Model") or c:IsA("BasePart") or c:IsA("Folder") then
local c2=LP.Character local r=c2 and c2:FindFirstChild("HumanoidRootPart")
if r then
local cle=spawnThing("ToolCleaver",r.CFrame*CFrame.new(5,5,20))
if cle then
task.wait(0.1)
local sp=cle:FindFirstChild("SoundPart")
if sp then
SNO:FireServer(sp,sp.CFrame) task.wait(0.1)
sp.CFrame=CFrame.new(0,math.random(9990,9999),0)
local st=cle:FindFirstChild("StickyPart")
local stick=RS:FindFirstChild("PlayerEvents") and RS.PlayerEvents:FindFirstChild("StickyPartEvent")
if st and stick then stick:FireServer(st,c,CFrame.new(2.199e12,2.199e12,2.199e12)) end
end
end
end
task.wait(0.05)
end
end
end)
end

-- ============================================================
-- Loops
-- ============================================================
local killLoop=false
local followLoop=false
local followTarget=""

local function startKillLoop()
task.spawn(function() while killLoop do
local t=find(S.target)
if t and t.Character then
local h=t.Character:FindFirstChildOfClass("Humanoid")
if h then h.Health=0 end
end
task.wait()
end end)
end

local function startFollowLoop()
task.spawn(function() while followLoop do
local t=find(followTarget) local c=LP.Character
local r=c and c:FindFirstChild("HumanoidRootPart")
if t and r and t.Character then
local tr=t.Character:FindFirstChild("HumanoidRootPart")
if tr then r.CFrame=tr.CFrame*CFrame.new(0,3,5) end
end
task.wait()
end end)
end

-- ============================================================
-- Auras
-- ============================================================
local auraActive=false
local auraPart=nil
local function startAura(color)
task.spawn(function() while auraActive do
pcall(function()
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")
if r and not (auraPart and auraPart.Parent) then
auraPart=Instance.new("Part")
auraPart.Size=Vector3.new(8,8,8)
auraPart.Shape=Enum.PartType.Ball
auraPart.Material=Enum.Material.Neon
auraPart.Color=color or Color3.fromRGB(135,206,235)
auraPart.Transparency=0.5
auraPart.CanCollide=false
auraPart.Anchored=true
auraPart.Parent=WS
end
if auraPart and r then auraPart.CFrame=r.CFrame end
end)
task.wait()
end end)
end
local function stopAura() auraActive=false if auraPart then auraPart:Destroy() auraPart=nil end end

-- ============================================================
-- GUI
-- ============================================================
local Win=Library:CreateWindow({Title="猿ゴット",Footer="Full Edition + Music",Center=true,AutoShow=true,NotifySide="Right",Icon=99960366240167,CornerRadius=20})
local T={
Home=Win:AddTab("Home","house"),
Prot=Win:AddTab("Protections","shield-plus"),
Loops=Win:AddTab("Loops","skull"),
Grab=Win:AddTab("Grabkick","crosshair"),
Misc=Win:AddTab("Misc","layers"),
Build=Win:AddTab("Build","brick-wall"),
Fun=Win:AddTab("Fun","smile"),
Auras=Win:AddTab("Auras","radar"),
Music=Win:AddTab("Music","music"),
UI=Win:AddTab("UI Settings","settings"),
}

notify("猿ゴット","Welcome to 猿ゴット Hub",5)

-- Home
do
local hb=T.Home:AddLeftGroupbox("Welcome")
hb:AddLabel("猿ゴット Hub - Full Edition + Music")
hb:AddLabel("Genesis Base + Grabkick Original",true)
local ib=T.Home:AddRightGroupbox("Info")
ib:AddLabel("User: @"..LP.Name)
ib:AddLabel("Display: "..LP.DisplayName)
local up=ib:AddLabel("Uptime: 00:00:00")
local t0=os.clock()
task.spawn(function() while true do task.wait(1)
local e=math.floor(os.clock()-t0)
up:SetText(string.format("Uptime: %02d:%02d:%02d",math.floor(e/3600),math.floor(e%3600/60),e%60))
end end)
end

-- ============================================================
-- Protections
-- ============================================================
do
local pL=T.Prot:AddLeftGroupbox("Anti Grab")
pL:AddToggle("AGToggle",{Text="Anti Grab",Default=false,Callback=function(v)
S.antiGrab=v AGDisc()
if v then AGApply(LP.Character) AGCons.char=LP.CharacterAdded:Connect(AGApply) end
end})

pL:AddDivider()
pL:AddToggle("AVToggle",{Text="Anti Void",Default=false,Callback=function(v)
S.antiVoid=v if v then AVStart() end
end})
pL:AddToggle("ABToggle",{Text="Anti Burn",Default=false,Callback=function(v)
S.antiBurn=v if v then local c=LP.Character if c then ABStart(c) end
elseif burnConn then burnConn:Disconnect() burnConn=nil end
end})
pL:AddToggle("AEToggle",{Text="Anti Explosion",Default=false,Callback=function(v)
S.antiExplode=v if v then AEStart() end
end})
pL:AddToggle("AIToggle",{Text="Anti Invisible",Default=false,Callback=function(v)
S.antiInvis=v if v then AIStart() end
end})

local pR=T.Prot:AddRightGroupbox("Anti Ragdoll / Others")
pR:AddToggle("ARToggle",{Text="Anti Ragdoll (Blob)",Default=false,Callback=function(v)
S.antiRagdoll=v if v then ARStart(LP.Character)
LP.CharacterAdded:Connect(function(c) if S.antiRagdoll then task.wait(1) ARStart(c) end end)
elseif arCons then arCons:Disconnect() arCons=nil end
end})
pR:AddToggle("ABanToggle",{Text="Anti Banana (SIT)",Default=false,Callback=function(v)
S.antiBanana=v if v then ABananaStart() end
end})
pR:AddToggle("ARstToggle",{Text="Anti Reset",Default=false,Callback=function(v)
S.antiReset=v if v then ARstStart()
elseif arstConn then arstConn:Disconnect() arstConn=nil end
end})
pR:AddToggle("KDToggle",{Text="House TP (Kill Dodge)",Default=false,Callback=function(v)
S.killDodge=v if v then KDStart() end
end})
pR:AddDivider()
pR:AddToggle("LPToggle",{Text="Lock Position",Default=false,Callback=function(v)
S.lockPos=v if v then LPStart() end
end})
pR:AddToggle("ASToggle",{Text="Anti Sticky",Default=false,Callback=function(v)
local st=LP.PlayerScripts:FindFirstChild("StickyPartsTouchDetection")
if st then st.Disabled=v end
notify("猿ゴット","Anti Sticky "..(v and "ON" or "OFF"),2)
end})

local AGCons2={}
local function AGDisc2() for _,c in pairs(AGCons2) do if c then c:Disconnect() end end table.clear(AGCons2) end

local function Strug() pcall(function() if STR then STR:FireServer(LP) end end) end
local function StopVel() pcall(function()
local g=RS:FindFirstChild("GameCorrectionEvents")
if g and g:FindFirstChild("StopAllVelocity") then g.StopAllVelocity:FireServer() end
end) end

local function AnchorChar(a)
local c=LP.Character if not c then return end
for _,p in pairs(c:GetChildren()) do if p:IsA("BasePart") then p.Anchored=a end end
if a then local r=c:FindFirstChild("HumanoidRootPart")
if r then r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero end end
end

pR:AddDivider()
pR:AddToggle("AGV1Toggle",{Text="Anti Grab V1",Default=false,Callback=function(v)
if v then
AGCons2.v1=R.Heartbeat:Connect(function()
local c=LP.Character local h=c and c:FindFirstChild("Head")
if c and h and h:FindFirstChild("PartOwner") then
Strug() StopVel() AnchorChar(true)
elseif not (ISH and ISH.Value) then AnchorChar(false) end
end)
else AGDisc2() AnchorChar(false) end
end})
pR:AddToggle("AGV2Toggle",{Text="Anti Grab V2",Default=false,Callback=function(v)
if v then
AGCons2.v2=R.Stepped:Connect(function()
if ISH and ISH.Value then
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")
local h=c and c:FindFirstChildOfClass("Humanoid")
if c and r and h then
for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
h.Sit=false h:ChangeState(Enum.HumanoidStateType.GettingUp)
r.Anchored=true r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero
Strug() StopVel()
end
end
end)
else AGDisc2() AnchorChar(false) end
end})

pR:AddToggle("AOV1Toggle",{Text="Anti Ownership V1",Default=false,Callback=function(v)
if v then
AGCons2.o1=R.Heartbeat:Connect(function()
if ISH and ISH.Value then Strug() StopVel() end
end)
else AGDisc2() end
end})
pR:AddToggle("AOV2Toggle",{Text="Anti Ownership V2",Default=false,Callback=function(v)
if v then
AGCons2.o2=ISH:GetPropertyChangedSignal("Value"):Connect(function()
if ISH.Value then
local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not r then return end
local saved=r.CFrame
task.spawn(function()
while ISH.Value and AGCons2.o2 do
Strug() r.Anchored=true r.CFrame=saved
r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero
task.wait()
end
r.Anchored=false
end)
end
end)
else AGDisc2()
local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if r then r.Anchored=false end
end
end})

local dlConn
local function doDeleteLegs()
local c=LP.Character if not c then return end
local ll=c:FindFirstChild("Left Leg") local rl=c:FindFirstChild("Right Leg")
if not ll or not rl then return end
local wasAIL=_G.AntiInputLag
if wasAIL then _G.AntiInputLag=false
if Toggles.AILToggle then Toggles.AILToggle:SetValue(false) end end
local void=WS.FallenPartsDestroyHeight
local pos=c.Torso.CFrame
WS.FallenPartsDestroyHeight=-100
if RAG then RAG:FireServer(c.HumanoidRootPart,2) end
task.wait(0.5)
rl.CFrame=CFrame.new(0,-10000,0)
ll.CFrame=CFrame.new(0,-10000,0)
task.wait(0.3)
c.Torso.CFrame=CFrame.new(0,-9970,0)
task.wait(0.5)
c.Torso.CFrame=pos
task.wait(0.5)
WS.FallenPartsDestroyHeight=void
if wasAIL then _G.AntiInputLag=true
if Toggles.AILToggle then Toggles.AILToggle:SetValue(true) end end
task.spawn(function()
if not c:FindFirstChild("Left Leg") and not c:FindFirstChild("Right Leg") then
while S.deleteLegs and task.wait() do
local pc=LP.PlayerGui:FindFirstChild("ControlsGui")
local pcf=pc and pc:FindFirstChild("PCFrame")
local stand=pcf and pcf:FindFirstChild("Stand")
if stand then c.Humanoid.HipHeight=(stand.Visible==false) and 2 or 0 end
end
end
end)
end
pR:AddToggle("DLToggle",{Text="Delete Legs",Default=false,Callback=function(v)
S.deleteLegs=v
if v then
task.spawn(doDeleteLegs)
dlConn=LP.CharacterAdded:Connect(function()
if not S.deleteLegs then return end
task.wait(1) task.spawn(doDeleteLegs)
end)
else
if dlConn then dlConn:Disconnect() dlConn=nil end
end
end})

local antiKickList={
["Spooky Candle"]="SpookyCandle1",
["Flying UFO"]="FlyingToyUfo",
["Cup Brown"]="CupMugBrown",
["Factory Light"]="FactoryLight",
["Spray Can"]="SprayCanWD",
}
local akNames={} for n in pairs(antiKickList) do akNames[#akNames+1]=n end table.sort(akNames)
pR:AddDropdown("AntiKickToy",{Text="Anti Kick Item",Values=akNames,Default="Spooky Candle",
Callback=function(v) S.selectedAntiKickToy=antiKickList[v] or "SpookyCandle1" end})

local function checkHome()
local pi=WS:FindFirstChild("PlotItems") local pl=WS:FindFirstChild("Plots")
if not (pi and pl) then return end
for i=1,5 do
local p=pl:FindFirstChild("Plot"..i)
if p then
local sg=p:FindFirstChild("PlotSign")
local ow=sg and sg:FindFirstChild("ThisPlotsOwners")
if ow then
for _,o in pairs(ow:GetChildren()) do
if o.Value==LP.Name then return pi:FindFirstChild("Plot"..i) end
end
end
end
end
end

local function spawnAkToy(name)
local ip=LP:FindFirstChild("InPlot") local io=LP:FindFirstChild("InOwnedPlot")
local cs=LP:FindFirstChild("CanSpawnToy") local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
if ip and ip.Value and io and not io.Value then ip:GetPropertyChangedSignal("Value"):Wait() end
if cs and not cs.Value then cs:GetPropertyChangedSignal("Value"):Wait() end
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
local cf=(S.myPCLD or hrp).CFrame*CFrame.new(0,14,20)
local cont=(io and io.Value) and checkHome() or inv if not cont then return end
local s local cn=cont.ChildAdded:Connect(function(x) if x.Name==name then s=x end end)
pcall(function() SPW:InvokeServer(name,cf,Vector3.zero) end)
local t=tick() repeat task.wait() until s or tick()-t>2.5
cn:Disconnect() return s
end

local function findPCLD(hrp)
S.myPCLD=nil
task.spawn(function()
for _,v in pairs(WS:GetChildren()) do
if v.Name=="PlayerCharacterLocationDetector" and v:IsA("BasePart") then
if (v.Position-hrp.Position).Magnitude<=2 then S.myPCLD=v return end
end
end
end)
end

pR:AddToggle("AntiKickFlag",{Text="Anti Kick [ITEM]",Default=false,Callback=function(v)
S.antiKickItem=v
if v then
task.spawn(function()
while S.antiKickItem do
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")
local h=c and c:FindFirstChildOfClass("Humanoid")
local ip=LP:FindFirstChild("InPlot")
local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
if r and h and h.Health>0 and inv and not (ip and ip.Value) then
if not S.myPCLD then findPCLD(r) end
local it=inv:FindFirstChild("AntiKickItem")
local sp=it and it:FindFirstChild("Hitbox")
if not it or not sp then
for _,x in pairs(inv:GetChildren()) do
if x.Name=="AntiKickItem" then pcall(function() DTY:FireServer(x) end) end
end
it=spawnAkToy(S.selectedAntiKickToy)
if it then
sp=it:FindFirstChild("Hitbox") or it:WaitForChild("Hitbox",0.5)
if sp then SNO:FireServer(sp,sp.CFrame) end
for _,x in pairs(it:GetChildren()) do
if x:IsA("BasePart") then x.CanCollide=false x.Transparency=0.8 x.Color=Color3.fromRGB(255,0,0) end
end
it.Name="AntiKickItem"
end
end
if sp then
local ow=sp:FindFirstChild("PartOwner")
if not (ow and ow.ValueLP.Name) then SNO:FireServer(sp,sp.CFrame) end
local tgt=S.myPCLD or r:FindFirstChild("FirePlayerPart") or r
if tgt then
sp.CFrame=tgt.CFrame
sp.AssemblyLinearVelocity=Vector3.zero
sp.AssemblyAngularVelocity=Vector3.zero
end
end
end
task.wait()
end
end)
else
if S.myPCLD then S.myPCLD=nil end
task.spawn(function()
local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
if inv then for _,x in pairs(inv:GetChildren()) do
if x.Name"AntiKickItem" then pcall(function() DTY:FireServer(x) end) end
end end
end)
end
end})

local function grabPart(p) pcall(function() SNO:FireServer(p,p.CFrame) end) end

local function gucciSpawn(name,cf,vel)
local ip=LP:FindFirstChild("InPlot") local io=LP:FindFirstChild("InOwnedPlot")
local cs=LP:FindFirstChild("CanSpawnToy")
if ip and io and cs then
while ip.Value and not io.Value and not cs.Value do task.wait(0.01) end
end
task.spawn(function() pcall(function() SPW:InvokeServer(name,cf,vel or Vector3.new()) end) end)
local inv=WS:FindFirstChild(LP.Name.."SpawnedInToys")
if not inv then inv=WS:WaitForChild(LP.Name.."SpawnedInToys",3) end
if not inv then return end
local s local cn=inv.ChildAdded:Connect(function(x) if x.Name==name and x:IsA("Model") then s=x cn:Disconnect() end end)
local t=tick() while not s do if tick()-t<2 then task.wait(0.01) else cn:Disconnect() return end end
return s
end

local function gucciAntiGrab()
S.gucciRunId=S.gucciRunId+1
local myId=S.gucciRunId
local c=LP.Character or LP.CharacterAdded:Wait()
local h=c:WaitForChild("Humanoid",3) if not h then return end
h.Sit=true task.wait(0.02) h.Sit=false task.wait(0.02)
task.spawn(function() local t=tick() while tick()-t<0.8 do
for _,v in pairs(c:GetChildren()) do if v:IsA("BasePart") then v.Velocity=Vector3.new() end end
task.wait(0.01)
end end)
local auto,sj,blob,bh=true,false,nil,nil
task.spawn(function()
while not blob and myIdS.gucciRunId do task.wait(0.01) end
if myId~=S.gucciRunId then return end
bh=blob:WaitForChild("Head",3)
local hb=blob:FindFirstChild("GrabbableHitbox")
while myIdS.gucciRunId and bh and
(not bh:FindFirstChild("PartOwner") or bh.PartOwner.Value~=LP.Name) do
grabPart(hb) task.wait(0.01)
end
end)
local r=c:WaitForChild("HumanoidRootPart",3)
blob=gucciSpawn("CreatureBlobman",r.CFrame*CFrame.new(0,0,-5),Vector3.new(0,-15.716,0))
if not blob then return end
local seat=blob:WaitForChild("VehicleSeat",3)
task.defer(function()
local st=tick()
while auto and myIdS.gucciRunId and tick()-st<0.3 do
if blob and blob.Parent then
if seat and seat.Parent and seat.Occupant~=h then seat:Sit(h) end
end
task.wait(0.03)
if c and h and h.Parent then h:ChangeState(Enum.HumanoidStateType.Jumping) end
task.wait(0.03)
end
auto=false sj=false
end)
sj=true
task.defer(function()
while sj and myIdS.gucciRunId do
if c and r and r.Parent and RAG then RAG:FireServer(r,0.095) end
task.wait(0.01)
end
end)
task.wait(0.4)
if myId~=S.gucciRunId then return end
h.Sit=false blob.Name="Gucci"
for _,v in pairs(blob:GetChildren()) do
if v:IsA("BasePart") then v.CanCollide=false v.CanTouch=false v.CanQuery=false end
end
task.defer(function()
while myId==S.gucciRunId and blob and bh do
bh.CFrame=CFrame.new(bh.Position.X,1e5,bh.Position.Z)
task.wait(0.01)
end
end)
notify("猿ゴット","Gucci 起動！",3)
end

pR:AddLabel("Gucci Binder"):AddKeyPicker("GucciKey",{
Default="V",Mode="Press",Text="Gucci Key",NoUI=false,
Callback=function() gucciAntiGrab() end,
ChangedCallback=function(k) S.gucciKey=k end
})
UIS.InputBegan:Connect(function(inp,pr)
if not pr and inp.KeyCode==S.gucciKey then gucciAntiGrab() end
end)

local abConn
pR:AddToggle("ABringToggle",{Text="Anti Blob",Default=false,Callback=function(v)
S.antiBring=v
local invName=LP.Name.."SpawnedInToys"
local function toggleW(state)
for _,x in pairs(WS:GetDescendants()) do
if x:IsA("BasePart") and (x.Name=="LeftWeld" or x.Name=="RightWeld"
or x.Name=="LeftAlignOrientation" or x.Name=="RightAlignOrientation") then
if x.Parent and x.Parent.Parent and x.Parent.Parent.Parent~=WS:FindFirstChild(invName) then
x.Enabled=state
end
end
end
end
if v then
toggleW(false)
if abConn then abConn:Disconnect() end
abConn=WS.DescendantAdded:Connect(function(x)
if x:IsA("BasePart") and (x.Name=="LeftWeld" or x.Name=="RightWeld"
or x.Name=="LeftAlignOrientation" or x.Name=="RightAlignOrientation") then
if x.Parent and x.Parent.Parent and x.Parent.Parent.Parent~=WS:FindFirstChild(invName) then
x.Enabled=false
end
end
end)
else toggleW(true)
if abConn then abConn:Disconnect() abConn=nil end end
end})
end

-- ============================================================
-- Loops
-- ============================================================
do
local lb=T.Loops:AddLeftGroupbox("Target Loops")
local ldd=lb:AddDropdown("LoopTarget",{Text="Target",Values=list(),Default="",Callback=function(v)
S.target=v local p=find(v) S.tUser=p and p.Name or nil
end})
lb:AddButton({Text="Refresh",Func=function() ldd:SetValues(list()) end})
lb:AddDivider()
lb:AddToggle("KillLoop",{Text="Kill Loop",Default=false,Callback=function(v)
killLoop=v if v then startKillLoop() end
end})
local lb2=T.Loops:AddRightGroupbox("Follow Loop")
local fdd=lb2:AddDropdown("FollowTarget",{Text="Target",Values=list(),Default="",Callback=function(v) followTarget=v end})
lb2:AddButton({Text="Refresh",Func=function() fdd:SetValues(list()) end})
lb2:AddToggle("FollowLoop",{Text="Follow Loop",Default=false,Callback=function(v)
followLoop=v if v then startFollowLoop() end
end})
end

-- ============================================================
-- Grabkick
-- ============================================================
do
local g=T.Grab:AddLeftGroupbox("Target")
local dd=g:AddDropdown("GKTarget",{Text="Target Player",Values=list(),Default="",Callback=function(v)
S.target=v local p=find(v) S.tUser=p and p.Name or nil
end})
g:AddDivider()
g:AddToggle("GKToggle",{Text="Grab Kick (BETA)",Default=false,Callback=function(on)
S.run=on if on then startLag() grabLoop() grabRender() else grabStop() end
end})
local a=T.Grab:AddRightGroupbox("Actions")
a:AddButton({Text="Refresh",Func=function() dd:SetValues(list()) end})
a:AddButton({Text="Stop",Func=function() grabStop()
if Toggles.GKToggle then Toggles.GKToggle:SetValue(false) end end})
end

-- ============================================================
-- Misc
-- ============================================================
do
local mb=T.Misc:AddLeftGroupbox("Input")
local inList={"FoodCoconut","FoodBanana","FoodFrenchFries","FoodMeatStick","PoopPile","FoodDonut","FoodCakePink","FoodHamburger"}
mb:AddDropdown("InputToy",{Text="Input Item",Values=inList,Default="FoodCoconut",Callback=function(v) S.selectedInputToy=v end})
mb:AddSlider("InputSpeed",{Text="Interval",Default=0.05,Min=0.01,Max=1,Rounding=2,Suffix="s",Callback=function(v) S.inputInterval=v end})
mb:AddToggle("AILToggle",{Text="Anti Input Lag",Default=false,Callback=function(v)
S.antiInput=v _G.AntiInputLag=v if v then AILStart() end
end})
local mr=T.Misc:AddRightGroupbox("World")
mr:AddToggle("WWToggle",{Text="Water Walk",Default=false,Callback=function(v)
S.waterWalk=v WWSet(v)
end})
mr:AddDivider()
mr:AddButton({Text="Packet Lag Test",Func=function()
local eg=RS:FindFirstChild("GrabEvents")
local ex=eg and eg:FindFirstChild("ExtendGrabLine")
if ex then
ex.OnClientEvent:Connect(function(a,d)
if typeof(d)=="string" and #d>300 then
notify("Packet Lag","Size: "..math.round(#d/1024).."KB",5)
end
end)
end
end})
end

-- ============================================================
-- Build
-- ============================================================
do
local bL=T.Build:AddLeftGroupbox("House Break")
bL:AddDropdown("House",{Text="House",Values=houseNames,Default="green house",Callback=function(v)
selectedHouse=plotMap[v] or "1"
end})
bL:AddButton({Text="Break House",Func=function()
task.spawn(function() local ok=breakPlot(selectedHouse)
notify("猿ゴット",ok and ("Plot "..selectedHouse.."破壊") or "失敗",3)
end)
end})
bL:AddButton({Text="Break ALL",Func=function()
task.spawn(function() local n=0
for i=1,5 do if breakPlot(tostring(i)) then n=n+1 end task.wait(0.1) end
notify("猿ゴット",n.."/5 Plot破壊",3)

--Base
import XMonad
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- Utilities
import           XMonad.Util.EZConfig           ( additionalKeysP
                                                , removeKeysP
                                                , mkKeymap
                                                )
import XMonad.Util.SpawnOnce (spawnOnce)

-- Layouts Modifiers
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.Spacing (spacingRaw, toggleSmartSpacing, Border(..))
import XMonad.Layout.NoBorders (smartBorders)

--Layouts
import XMonad.Layout.StackTile
import XMonad.Layout.Dishes
import XMonad.Layout.TwoPane
import XMonad.Util.NamedScratchpad ( NamedScratchpad(NS), customFloating, namedScratchpadManageHook, namedScratchpadAction)
-- Hooks
import XMonad.Hooks.ManageDocks (ToggleStruts(..))
import XMonad.Hooks.FadeInactive (fadeInactiveLogHook)
import XMonad.Hooks.SetWMName(setWMName)
import XMonad.Hooks.EwmhDesktops (ewmhDesktopsStartup, ewmhDesktopsEventHook, ewmhDesktopsLogHook)

-- Actions
import XMonad.Actions.CycleWS (nextScreen, shiftNextScreen)
import XMonad.Actions.WindowBringer (gotoMenu)
import XMonad.Actions.TopicSpace
import XMonad.Actions.DynamicWorkspaceGroups
import XMonad.Actions.Commands (workspaceCommands, runCommand)
import           XMonad.Actions.CopyWindow      ( copyToAll )

import XMonad.Config.Xfce (xfceConfig, desktopLayoutModifiers)
------------------------------------------------------------------------
-- General:
myTerminal = "kitty"
myBrowser = "surf"
myConfigsDir = "/home/ucizi/configs2.0"
myEditor = myConfigsDir ++ "/xmonad/visual-editor.sh"
myLauncher = myConfigsDir ++ "/scripts/dmenu_recency"
myStatusBar = myConfigsDir ++ "/config/polybar/launch.sh &"
myWallpaperCmd = "echo 'no-wallpaper'"
myModMask = mod4Mask

------------------------------------------------------------------------
-- Topics:
myTopics :: [Topic]
myTopics =
  ["editor", "browser", "extra", "chat", "music"]

myTopicConfig :: TopicConfig
myTopicConfig = def
  { defaultTopic = "editor"
  , topicActions = M.fromList 
    [ ("editor", spawn myEditor)
    , ("browser", spawn myBrowser)
    , ("extra", spawn myTerminal)
    , ("chat", chatTopicAction)
    , ("music", spawn "spotify")
    ]
  }

chatTopicAction = do
  spawn "teams"
  spawn (myBrowser ++ "https://outlook.office365.com")

goTo :: String -> X ()
goTo = switchTopic myTopicConfig

------------------------------------------------------------------------
-- Layouts:
mySpacing = 3

myLayoutHook =
  spacingRaw False (Border 0 0 0 0) False (Border 3 3 3 3) True myLayouts


myLayouts =  Full ||| Tall 1 (3/100) (1/2) ||| TwoPane (3/100) (1/2)

toggleFullScreen = do
  sendMessage ToggleStruts
  toggleSmartSpacing

------------------------------------------------------------------------
-- Scratchpads:
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm]
    where
    spawnTerm  = myTerminal ++  " --name scratchpad tmux new-session -A -s scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm =  customFloating $ W.RationalRect l t w h
                 where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

------------------------------------------------------------------------
-- WindowManagement:
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , title     =? "Rest break"     --> doIgnore
    , title     =? "Micro-break"     --> doIgnore
    , title     =? "Workrave"       --> doIgnore
    , className =? "microsoft teams - preview" --> doShift "chat"
    , stringProperty "WM_NAME" =? "Microsoft Teams Notification" --> composeAll[ doF W.focusDown, doF copyToAll, doFloat]
    , stringProperty "WM_NAME" =? "Whisker Menu" --> doFloat
    , stringProperty "WM_NAME" =? "Volume Control" --> floatCorner
    , stringProperty "WM_NAME" =? "Bluetooth Devices" --> floatCorner
    , stringProperty "WM_NAME" =? "Network Connections" --> floatCorner
    ]

floatCorner = customFloating (W.RationalRect (2/3) (4/100) (1/3) (6/10))
------------------------------------------------------------------------
-- Log Hook:
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.9
------------------------------------------------------------------------
-- Keys:
myKeys conf =
  mkKeymap conf
  [
    -- restart
    ("M-C-r", spawn "if type xmonad; then xmonad --recompile && xmonad --restart && notify-send 'XMonad Restarted'; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad
    -- spawning commands
  ,("M-<Return>", spawn myTerminal)
  , ("M-x", spawn myLauncher)
  , ("M-;", namedScratchpadAction myScratchPads "terminal")
  , ("M-C-<F8>", spawn "pavucontrol")
  , ("M-S-<F8>", spawn "pavucontrol")

  --workspaces
  -- browser
  , ("M-w", goTo "browser")
  , ("M-C-m M-w", shiftTo "browser")
  , ("M-S-w", spawn myBrowser)
  -- editor
  , ("M-e", goTo "editor")
  , ("M-C-m M-e", shiftTo "editor")
  , ("M-S-e", spawn myEditor)
  -- chat
  , ("M-c", goTo "chat")
  , ("M-C-m M-c", shiftTo "chat")
  -- extra
  , ("M-1", goTo "extra")
  , ("M-C-m M-1", shiftTo "extra")
  -- music
  , ("M-2", goTo "music")
  , ("M-C-m M-2", shiftTo "music")
  , ("M-s", goTo "music")
  , ("M-C-m M-s", shiftTo "music")
  -- workspace action
  , ("M-a", currentTopicAction myTopicConfig)
  
  -- workspace manipulation
  , ("M-'", gotoMenu)
  , ("M-#", workspaceCommands >>= runCommand)

  -- window maninpulation
  , ("M-C-x", kill)
  , ("M-C-l", spawn "i3lock-fancy-rapid 5 1")
  , ("M-C-f", toggleFullScreen)
  , ("M-C-b", toggleSmartSpacing)
  , ("M-<Space>", sendMessage NextLayout)
  , ("M-S-<Space>", setLayout $ XMonad.layoutHook conf) -- reset layout
  , ("M-n", refresh)
  , ("M-j", windows W.focusDown) -- %! Move focus to the next window
  , ("M-k", windows W.focusUp  ) -- %! Move focus to the previous window
  , ("M-m", windows W.focusMaster  ) -- %! Move focus to the master window
  , ("M-S-j", windows W.swapDown  ) -- %! Swap the focused window with the next window
  , ("M-S-k", windows W.swapUp    ) -- %! Swap the focused window with the previous window
  , ("M-S-m", windows W.swapMaster) -- move focused window to master
  , ("M-h", sendMessage Shrink) -- %! Shrink the master area
  , ("M-l", sendMessage Expand) -- %! Expand the master area
  , ("M-t", withFocused $ windows . W.sink) -- %! Push window back into tiling
  , ("M-,", sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
  , ("M-.", sendMessage (IncMasterN (-1))) -- %! Deincrement the number of windows in the master area

  -- multi-monitor
  , ("M-o", nextScreen)
  , ("M-S-o", shiftNextScreen)
  ]

shiftTo :: String -> X ()
shiftTo = windows . W.shift

------------------------------------------------------------------------
-- Startup:
myStartupHook = return ()
--   setWMName "LG3D" -- hack to make Java GUI apps work. Xmonad isn't on the whitelist (-_-)
------------------------------------------------------------------------
-- Main:
myConfig = xfceConfig
  { terminal    = myTerminal
  , workspaces = myTopics
  , modMask     = mod4Mask
  , borderWidth = 0
  , keys = myKeys
  , layoutHook = desktopLayoutModifiers myLayoutHook
  , manageHook = manageHook xfceConfig <+> myManageHook <+> namedScratchpadManageHook myScratchPads
  , startupHook = startupHook xfceConfig <+> myStartupHook
  , logHook = myLogHook
  }

main = xmonad myConfig

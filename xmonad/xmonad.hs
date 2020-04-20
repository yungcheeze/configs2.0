--Base
import XMonad
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP, removeKeysP)
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

import XMonad.Config.Xfce (xfceConfig, desktopLayoutModifiers)
------------------------------------------------------------------------
-- General:
myTerminal = "kitty"
myBrowser = "chromium"
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
  ["editor", "browser", "extra", "chat"]

myTopicConfig :: TopicConfig
myTopicConfig = def
  { defaultTopic = "editor"
  , topicActions = M.fromList 
    [ ("editor", spawn myEditor)
    , ("browser", spawn myBrowser)
    , ("extra", spawn myTerminal)
    , ("chat", chatTopicAction)
    ]
  }

chatTopicAction = do
  spawn "teams"
  spawn "chromium --app=https://outlook.office365.com"

goToChatWorkspace = switchTopic myTopicConfig "chat"

goToEditorWorkspace = switchTopic myTopicConfig "editor"

goToBrowserWorkspace = switchTopic myTopicConfig "browser"

goToExtraWorkspace = switchTopic myTopicConfig "extra"



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
    , stringProperty "WM_NAME" =? "Microsoft Teams Notification" --> doFloat
    , stringProperty "WM_NAME" =? "Whisker Menu" --> doFloat
    ]

------------------------------------------------------------------------
-- Log Hook:
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.9
------------------------------------------------------------------------
-- Keys:
myKeys =
  [
    -- restart
    ("M-C-r", spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad
    -- spawning commands
  ,("M-<Return>", spawn myTerminal)
  , ("M-x", spawn myLauncher)
  , ("M-;", namedScratchpadAction myScratchPads "terminal")

  --workspaces
  -- browser
  , ("M-c", goToBrowserWorkspace)
  , ("M-S-c", spawn myBrowser)
  -- editor
  , ("M-e", goToEditorWorkspace)
  , ("M-S-e", spawn myEditor)
  -- chat
  , ("M-s", goToChatWorkspace)
  -- extra
  , ("M-S-x", switchTopic myTopicConfig "extra")
  , ("M-a", currentTopicAction myTopicConfig)

  -- workspace manipulation
  , ("M-'", gotoMenu)
  , ("M-#", workspaceCommands >>= runCommand)

  -- window maninpulation
  , ("M-S-q", kill)
  , ("M-C-l", spawn "i3lock-fancy-rapid 5 1")
  , ("M-C-f", toggleFullScreen)
  , ("M-C-b", toggleSmartSpacing)
  , ("M-<Space>", sendMessage NextLayout)
  -- , ("M-S-<Space>", setLayout $ XMonad.layoutHook conf) -- reset layout (couldn't get it to work)
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

------------------------------------------------------------------------
-- Keys:
removedKeys =
  [ "M-q" -- restart
  , "M-S-q" -- quit
  , "M-S-c" -- close window
  , "M-<Tab>" -- cycle window forward
  , "M-S-<Tab>" -- cycle window backward
  , "M-S-/" --help command
  , "M-p" -- dmenu
  , "M-S-p" -- dmenu
  , "M-S-w" , "M-S-e" , "M-S-r" -- move window to monitor
  , "M-w" , "M-e" , "M-r" -- switch to monitor
  , "M-b" --toggle struts
  ] ++ ["M-" ++ k | k <- map show [0..9]] ++ ["M-S-" ++ k | k <- map show [0..9]]


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
  , layoutHook = desktopLayoutModifiers myLayoutHook
  , manageHook = manageHook xfceConfig <+> myManageHook <+> namedScratchpadManageHook myScratchPads
  , startupHook = startupHook xfceConfig <+> myStartupHook
  , logHook = myLogHook
  }

main = xmonad $ myConfig
  `removeKeysP` removedKeys
  `additionalKeysP` myKeys

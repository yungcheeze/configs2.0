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
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.NoBorders (smartBorders)

--Layouts
import XMonad.Layout.StackTile
import XMonad.Layout.Dishes
import XMonad.Layout.TwoPane
import XMonad.Util.NamedScratchpad ( NamedScratchpad(NS), customFloating, namedScratchpadManageHook, namedScratchpadAction)
-- Hooks
import XMonad.Hooks.ManageDocks (avoidStruts, docks)
import XMonad.Hooks.FadeInactive (fadeInactiveLogHook)

-- Actions
import XMonad.Actions.CycleWS (nextScreen, shiftNextScreen)
import XMonad.Actions.WindowBringer (gotoMenu)
import XMonad.Actions.TopicSpace
import XMonad.Actions.DynamicWorkspaceGroups

------------------------------------------------------------------------
-- General:
myTerminal = "kitty"
myBrowser = "chromium"
myEditor = "emacs"
myConfigsDir = "/home/ucizi/configs2.0"
myLauncher = myConfigsDir ++ "/scripts/dmenu_recency"
myStatusBar = myConfigsDir ++ "/config/polybar/launch.sh &"
myWallpaperCmd = "echo 'no-wallpaper'"
myModMask = mod4Mask

------------------------------------------------------------------------
-- Topics:
myTopics :: [Topic]
myTopics =
  ["editor", "browser", "extra"]

myTopicConfig :: TopicConfig
myTopicConfig = def
  { defaultTopic = "editor"
  , topicActions = M.fromList $
    [ ("editor", spawn myEditor)
    , ("browser", spawn myBrowser)
    , ("extra", spawn myTerminal)
    ]
  }

goToEditorWorkspace = do
  switchTopic myTopicConfig "editor"

goToBrowserWorkspace = do
  switchTopic myTopicConfig "browser"
goToExtraWorkspace = do
  switchTopic myTopicConfig "extra"



------------------------------------------------------------------------
-- Layouts:
mySpacing = 3

myLayoutHook = avoidStruts $ myLayouts

myLayouts = myFull ||| myTile

myTile = renamed [Replace "Tiled"] $ spacing mySpacing $ Tall 1 (3/100) (1/2)
myFull = renamed [Replace "Full"] $ spacing mySpacing $ Full
myTwoPane = renamed [Replace "TwoPane"] $ spacing mySpacing $ TwoPane (3/100) (1/2)

------------------------------------------------------------------------
-- Scratchpads:
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm]
    where
    spawnTerm  = myTerminal ++  " -n scratchpad"
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
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Log Hook:
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.9
------------------------------------------------------------------------
-- Keys:
myKeys =
  [ ("M-C-r", spawn "xmonad --recompile; xmonad --restart")
  , ("M-<Return>", spawn myTerminal)
  , ("M-;", namedScratchpadAction myScratchPads "terminal")
  , ("M-x", spawn myLauncher)
  , ("M-'", gotoMenu)
  , ("C-M1-<Delete>", io exitSuccess)
  , ("M-S-c", spawn myBrowser)
  , ("M-S-e", spawn myEditor)
  , ("M-o", nextScreen)
  , ("M-S-o", shiftNextScreen)
  , ("M-S-q", kill)
  , ("M-C-l", spawn "i3lock-fancy-rapid 5 1")
  , ("M-e", goToEditorWorkspace)
  , ("M-c", goToBrowserWorkspace)
  , ("M-S-x", switchTopic myTopicConfig "extra")
  , ("M-a", currentTopicAction myTopicConfig)
  ]

------------------------------------------------------------------------
-- Keys:
removedKeys =
  [ "M-q" -- restart
  , "M-S-q" -- quit
  , "M-S-c" -- close window
  , "M-<Tab>" -- cycle window forward
  , "M-S-<Tab>" -- cycle window backward
  , "M-p" -- dmenu
  , "M-S-p" -- dmenu
  , "M-S-w" , "M-S-e" , "M-S-r" -- move window to monitor
  , "M-w" , "M-e" , "M-r" -- switch to monitor
  ]


------------------------------------------------------------------------
-- Startup:
myStartupHook = do
  spawnOnce myStatusBar
  -- spawnOnce "redshift &"
  -- spawnOnce "compton -b &"
  -- spawnOnce "xbindkeys"
  spawnOnce "dropbox"
  spawnOnce myWallpaperCmd
  spawnOnce "setxkbmap gb"
  spawnOnce "setxkbmap -option ctrl:nocaps"

------------------------------------------------------------------------
-- Main:
myConfig = def
  { terminal    = myTerminal
  , workspaces = myTopics
  , modMask     = mod4Mask
  , borderWidth = 0
  , layoutHook = myLayoutHook
  , startupHook = myStartupHook
  , manageHook = myManageHook <+> namedScratchpadManageHook myScratchPads
  , logHook = myLogHook
  }

main = xmonad $ docks myConfig
  `removeKeysP` removedKeys
  `additionalKeysP` myKeys

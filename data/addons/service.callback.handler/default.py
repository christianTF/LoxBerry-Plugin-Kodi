#!/usr/bin/python
# -*- coding: utf-8 -*-
#
#     Copyright (C) 2015 Tefi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#    This script is based on script.randomitems & script.wacthlist
#    Thanks to their original authors

import os
import sys
import xbmc
import xbmcgui
import xbmcaddon
import subprocess
import socket

udp_address = ''
udp_port = '7000'
volume_on_start = '50'

__addon__        = xbmcaddon.Addon()
__addonversion__ = __addon__.getAddonInfo('version')
__addonid__      = __addon__.getAddonInfo('id')
__addonname__    = __addon__.getAddonInfo('name')

def log(txt):
  message = '%s: %s' % (__addonname__, txt.encode('ascii', 'ignore'))
  xbmc.log(msg=message, level=xbmc.LOGDEBUG)

def send_udp (txt):
  log(txt)
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
  sock.sendto(txt, (udp_address, int(udp_port)))
	
	
class Main:
  def __init__(self):
    self._init_vars()
    self._init_property()
    xbmc.executebuiltin( "XBMC.SetVolume(" + volume_on_start + ")" )
    self._daemon()

  def _init_vars(self):
    self.Player = MyPlayer()
    self.Monitor = MyMonitor(update_settings = self._init_property, player_status = self._player_status)

  def _init_property(self):
    log('Reading properties')
    global udp_address
    global udp_port
    global volume_on_start
	
    udp_address = xbmc.translatePath(__addon__.getSetting("udp_address"))
    udp_port = xbmc.translatePath(__addon__.getSetting("udp_port"))
    volume_on_start = xbmc.translatePath(__addon__.getSetting("volume_on_start"))

    log('udp_address = "' + udp_address + '"')
    log('udp_port = "' + udp_port + '"')
    log('volume_on_start = "' + volume_on_start + '"')
	
  def _player_status(self):
    return self.Player.playing_status()

  def _daemon(self):
    send_udp('kodi_started')
    while (not xbmc.abortRequested):
      # Do nothing      
      xbmc.sleep(10000)
    log('abort requested')
    send_udp('kodi_stopped')


class MyMonitor(xbmc.Monitor):
  def __init__(self, *args, **kwargs):
    xbmc.Monitor.__init__(self)
    self.get_player_status = kwargs['player_status']
    self.update_settings = kwargs['update_settings']

  def onSettingsChanged(self):
    self.update_settings()

  def onScreensaverActivated(self):
    log('screensaver starts')

  def onScreensaverDeactivated(self):
    log('screensaver stops')

  def onDatabaseUpdated(self,db):
    log('database updated')

class MyPlayer(xbmc.Player):
  title = ''
  
  def __init__(self):
    xbmc.Player.__init__(self)
    self.substrings = [ '-trailer', 'http://' ]

  def playing_status(self):
    if self.isPlaying():
      return 'status=playing' + ';' + self.playing_type()
    else:
      return 'status=stopped'

  def playing_type(self):
    type = 'unknown'
    if (self.isPlayingAudio()):
      type = "music"  
    else:
      if xbmc.getCondVisibility('VideoPlayer.Content(movies)'):
        filename = ''
        isMovie = True
        try:
          filename = self.getPlayingFile()
        except:
          pass
        if filename != '':
          for string in self.substrings:
            if string in filename:
              isMovie = False
              break
        if isMovie:
          type = "movie"
          MyPlayer.title = unicode( xbmc.getInfoLabel( "ListItem.Title" ), "utf-8" )
      elif xbmc.getCondVisibility('VideoPlayer.Content(episodes)'):
        # Check for tv show title and season to make sure it's really an episode
        if xbmc.getInfoLabel('VideoPlayer.Season') != "" and xbmc.getInfoLabel('VideoPlayer.TVShowTitle') != "":
           type = "episode"
    return type

  def playing_title(self):
    return MyPlayer.title
    
  def playing_filename(self):
      filename = ''
      try:
          filename = self.getPlayingFile()
      except:
          pass
      return 'filename=' + filename
      
  def onPlayBackStarted(self):
    send_udp(self.playing_type()+'_started')
    send_udp(self.playing_type()+'_title='+self.playing_title())
    
  def onPlayBackEnded(self):
    self.onPlayBackStopped()

  def onPlayBackStopped(self):
    send_udp(self.playing_type()+'_stopped')

  def onPlayBackPaused(self):
    send_udp(self.playing_type()+'_paused')

  def onPlayBackResumed(self):
    send_udp(self.playing_type()+'_resumed')

if (__name__ == "__main__"):
    log('script version %s started' % __addonversion__)
    Main()
    del MyPlayer
    del MyMonitor
    del Main
    log('script version %s stopped' % __addonversion__)

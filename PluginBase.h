/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Plugin that doesn't recieve communications with the
//                core
// Part of:       VitaminSEE
//
// ID:            $Id: VitaminSEEController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       4/07/05
//
/////////////////////////////////////////////////////////////////////////

@class PluginLayer;

@protocol PluginBase
-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer;
@end
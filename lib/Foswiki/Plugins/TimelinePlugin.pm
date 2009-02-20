# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2006-2009 Sven Dowideit, SvenDowideit@fosiki.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#

=pod

---+ package TimelinePlugin

=cut

package Foswiki::Plugins::TimelinePlugin;
use strict;
use vars qw( $VERSION $RELEASE $debug $pluginName $timelineId );
$VERSION = '$Rev$';
$RELEASE = 'Foswiki-1.0';
$pluginName = 'TimelinePlugin';


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if( $Foswiki::Plugins::VERSION < 1.026 ) {
        Foswiki::Func::writeWarning( "Version mismatch between $pluginName and Plugins.pm" );
        return 0;
    }

    $timelineId = 1;
    Foswiki::Func::registerTagHandler( 'TIMELINE', \&_TIMELINE );

    # get debug flag
    $debug = Foswiki::Func::getPreferencesFlag( "\U$pluginName\E_DEBUG" );

    # Plugin correctly initialized
    return 1;
}

# The function used to handle the %EXAMPLETAG{...}% variable
# You would have one of these for each variable you want to process.
sub _TIMELINE {
    my($session, $params, $theTopic, $theWeb) = @_;
    # $session  - a reference to the TWiki session object (if you don't know
    #             what this is, just ignore it)
    # $params=  - a reference to a Foswiki::Attrs object containing parameters.
    #             This can be used as a simple hash that maps parameter names
    #             to values, with _DEFAULT being the name for the default
    #             parameter.
    # $theTopic - name of the topic in the query
    # $theWeb   - name of the web in the query
    # Return: the result of processing the variable

    # For example, %EXAMPLETAG{'hamburger' sideorder="onions"}%
    # $params->{_DEFAULT} will be 'hamburger'
    # $params->{sideorder} will be 'onions'
    #add the JavaScript
   my $pluginPubUrl = Foswiki::Func::getPubUrlPath().'/'.
            Foswiki::Func::getTwikiWebname().'/'.$pluginName;    
    my $jscript = Foswiki::Func::readTemplate ( 'timelineplugin' );
    $jscript =~ s/%PLUGINPUBURL%/$pluginPubUrl/g;
    Foswiki::Func::addToHEAD($pluginName, $jscript);
    
    my $orientation = 'Timeline.HORIZONTAL';
    #orientation="vertical"
    if ($params->{orientation} eq 'vertical') {
        $orientation = 'Timeline.VERTICAL';
    }
    my $urltype = 'JSON';
    #urltype="JSON"
    if ($params->{urltype} eq 'XML') {
        $urltype = 'XML';
    }

    my $timeline = '<div id="my-timeline'.$timelineId.'" class="TimelineDiv" style="height: '.$params->{height}
        .'; width: '.$params->{width}.'; border: 1px solid #aaa" '
        .'url="'.$params->{_DEFAULT}.'" '
        .'interval="'.$params->{interval}.'" '
        .'orientation="'.$orientation.'" '
        .'urltype="'.$urltype.'" '
        .'date="'.$params->{date}.'"></div>';
    $timelineId++;
    return $timeline;
}

1;

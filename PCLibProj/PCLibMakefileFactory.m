/*
   GNUstep ProjectCenter - http://www.projectcenter.ch

   Copyright (C) 2000 Philippe C.D. Robert

   Author: Philippe C.D. Robert <phr@projectcenter.ch>

   This file is part of ProjectCenter.

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Id$
*/

#import "PCLibMakefileFactory.h"

@implementation PCLibMakefileFactory

static PCLibMakefileFactory *_factory = nil;

+ (PCLibMakefileFactory *)sharedFactory
{
    if (!_factory) {
        _factory = [[[self class] alloc] init];
    }
    return _factory;
}

- (NSData *)makefileForProject:(PCProject *)aProject;
{
    NSMutableString *string = [NSMutableString string];
    NSString *prName = [aProject projectName];
    NSDictionary *prDict = [aProject projectDict];
    NSString *tmp;
    NSEnumerator *enumerator;
    NSString *libName;
    
    // Header information
    [string appendString:@"#\n"];
    [string appendString:@"# GNUmakefile - Generated by the ProjectCenter\n"];
    [string appendString:@"# Written by Philippe C.D. Robert <phr@projectcenter.ch>\n"];
    [string appendString:@"#\n"];
    [string appendString:@"# NOTE: Do NOT change this file -- ProjectCenter maintains it!\n"];
    [string appendString:@"#\n"];
    [string appendString:@"# Put all of your customisations in GNUmakefile.preamble and\n"];
    [string appendString:@"# GNUmakefile.postamble\n"];
    [string appendString:@"#\n\n"];
    
    // The 'real' thing
    [string appendString:@"include $(GNUSTEP_MAKEFILES)/common.make\n"];
    [string appendString:@"include English.lproj/Version\n"];

    [string appendString:@"#\n\n"];
    [string appendString:@"# Subprojects\n"];
    [string appendString:@"#\n\n"];

    if ([[aProject subprojects] count]) {
        enumerator = [[prDict objectForKey:PCSubprojects] objectEnumerator];
        while (tmp = [enumerator nextObject]) {
            [string appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
        }
    }

    [string appendString:@"#\n"];
    [string appendString:@"# Library\n"];
    [string appendString:@"#\n\n"];

    [string appendString:[NSString stringWithFormat:@"PACKAGE_NAME=%@\n",prName]];
    [string appendString:[NSString stringWithFormat:@"LIBRARY_VAR=%@\n",[prName uppercaseString]]];
    libName = [NSString stringWithFormat:@"lib%@",prName];
    [string appendString:[NSString stringWithFormat:@"LIBRARY_NAME=%@\n",libName]];

    // Install path
    [string appendString:[NSString stringWithFormat:@"%@_HEADER_FILES_DIR=.\n",libName]];
    [string appendString:[NSString stringWithFormat:@"%@_HEADER_FILES_INSTALL_DIR=/%@\n",libName,prName]];
    [string appendString:[NSString stringWithFormat:@"%@_INSTALL_PREFIX=$(GNUSTEP_LOCAL_ROOT)\n",[prName uppercaseString]]];
    [string appendString:@"ADDITIONAL_INCLUDE_DIRS = -I..\n"];
    [string appendString:@"srcdir = .\n"];

    [string appendString:@"#\n\n"];
    [string appendString:@"# Additional libraries\n"];
    [string appendString:@"#\n\n"];

    [string appendString:[NSString stringWithFormat:@"%@_LIBRARIES_DEPEND_UPON += ",prName]];

    if ([[prDict objectForKey:PCLibraries] count]) {
        enumerator = [[prDict objectForKey:PCLibraries] objectEnumerator];
        while (tmp = [enumerator nextObject]) {
	  if (![tmp isEqualToString:@"gnustep-base"]) {
	    [string appendString:[NSString stringWithFormat:@"-l%@ ",tmp]];
	  }
        }
    }

    [string appendString:@"\n\n#\n\n"];
    [string appendString:@"# Header files\n"];
    [string appendString:@"#\n\n"];

    [string appendString:[NSString stringWithFormat:@"%@_HEADERS= ",libName]];

    enumerator = [[prDict objectForKey:PCHeaders] objectEnumerator];
    while (tmp = [enumerator nextObject]) {
        [string appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
    }

    [string appendString:@"\n\n#\n\n"];
    [string appendString:@"# Class files\n"];
    [string appendString:@"#\n\n"];

    [string appendString:[NSString stringWithFormat:@"%@_OBJC_FILES= ",libName]];

    enumerator = [[prDict objectForKey:PCClasses] objectEnumerator];
    while (tmp = [enumerator nextObject]) {
        [string appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
    }

    [string appendString:@"\n\n#\n\n"];
    [string appendString:@"# C files\n"];
    [string appendString:@"#\n\n"];

    [string appendString:[NSString stringWithFormat:@"%@_C_FILES= ",libName]];

    enumerator = [[prDict objectForKey:PCOtherSources] objectEnumerator];
    while (tmp = [enumerator nextObject]) {
        [string appendString:[NSString stringWithFormat:@"\\\n%@ ",tmp]];
    }

    [string appendString:@"\n\n"];

    [string appendString:@"-include GNUmakefile.preamble\n"];
    [string appendString:@"-include GNUmakefile.local\n"];
    [string appendString:@"include $(GNUSTEP_MAKEFILES)/library.make\n"];
    [string appendString:@"-include GNUmakefile.postamble\n"];

    return [string dataUsingEncoding:[NSString defaultCStringEncoding]];
}

@end

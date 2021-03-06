// ***************************************************************** -*- C++ -*-
/*
 * Copyright (C) 2004 Andreas Huggel <ahuggel@gmx.net>
 * 
 * This program is part of the Exiv2 distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
/*
  File:      fujimn.cpp
  Version:   $Rev: 392 $
  Author(s): Andreas Huggel (ahu) <ahuggel@gmx.net>
  History:   18-Feb-04, ahu: created
             07-Mar-04, ahu: isolated as a separate component
  Credits:   Fujifilm MakerNote implemented according to the specification
             in "Appendix 4: Makernote of Fujifilm" of the document 
             "Exif file format" by TsuruZoh Tachibanaya
             <http://park2.wakwak.com/%7Etsuruzoh/Computer/Digicams/exif-e.html>
 */
// *****************************************************************************
#include "rcsid.hpp"
EXIV2_RCSID("@(#) $Id: fujimn.cpp 392 2004-11-09 19:10:37Z brad $");

// *****************************************************************************
// included header files
#include "types.hpp"
#include "fujimn.hpp"
#include "makernote.hpp"
#include "value.hpp"

// + standard includes
#include <string>
#include <sstream>
#include <iomanip>
#include <cassert>

// Define DEBUG_MAKERNOTE to output debug information to std::cerr
#undef DEBUG_MAKERNOTE

// *****************************************************************************
// class member definitions
namespace Exiv2 {

    const FujiMakerNote::RegisterMakerNote FujiMakerNote::register_;

    // Fujifilm MakerNote Tag Info
    static const MakerNote::MnTagInfo fujiMnTagInfo[] = {
        MakerNote::MnTagInfo(0x0000, "Version", "Fujifilm Makernote version"),
        MakerNote::MnTagInfo(0x1000, "Quality", "Image quality setting"),
        MakerNote::MnTagInfo(0x1001, "Sharpness", "Sharpness setting"),
        MakerNote::MnTagInfo(0x1002, "WhiteBalance", "White balance setting"),
        MakerNote::MnTagInfo(0x1003, "Color", "Chroma saturation setting"),
        MakerNote::MnTagInfo(0x1004, "Tone", "Contrast setting"),
        MakerNote::MnTagInfo(0x1010, "FlashMode", "Flash firing mode setting"),
        MakerNote::MnTagInfo(0x1011, "FlashStrength", "Flash firing strength compensation setting"),
        MakerNote::MnTagInfo(0x1020, "Macro", "Macro mode setting"),
        MakerNote::MnTagInfo(0x1021, "FocusMode", "Focusing mode setting"),
        MakerNote::MnTagInfo(0x1030, "SlowSync", "Slow synchro mode setting"),
        MakerNote::MnTagInfo(0x1031, "PictureMode", "Picture mode setting"),
        MakerNote::MnTagInfo(0x1100, "Continuous", "Continuous shooting or auto bracketing setting"),
        MakerNote::MnTagInfo(0x1300, "BlurWarning", "Blur warning status"),
        MakerNote::MnTagInfo(0x1301, "FocusWarning", "Auto Focus warning status"),
        MakerNote::MnTagInfo(0x1302, "AeWarning", "Auto Exposure warning status"),
        // End of list marker
        MakerNote::MnTagInfo(0xffff, "(UnknownFujiMakerNoteTag)", "Unknown FujiMakerNote tag")
    };

    FujiMakerNote::FujiMakerNote(bool alloc)
        : IfdMakerNote(fujiMnTagInfo, alloc), ifdItem_("Fujifilm")
    {
        byteOrder_ = littleEndian;
        absOffset_ = false;
        byte buf[] = {
            'F', 'U', 'J', 'I', 'F', 'I', 'L', 'M', 0x0c, 0x00, 0x00, 0x00
        };
        readHeader(buf, 12, byteOrder_);
    }

    int FujiMakerNote::readHeader(const byte* buf,
                                  long len, 
                                  ByteOrder byteOrder)
    {
        if (len < 12) return 1;

        header_.alloc(12);
        memcpy(header_.pData_, buf, header_.size_);
        // Read the offset relative to the start of the makernote from the header
        // Note: we ignore the byteOrder paramter
        adjOffset_ = getUShort(header_.pData_ + 8, byteOrder_);
        return 0;
    }

    int FujiMakerNote::checkHeader() const
    {
        int rc = 0;
        // Check the FUJIFILM prefix
        if (   header_.size_ < 12
            || std::string(reinterpret_cast<char*>(header_.pData_), 8) 
                    != std::string("FUJIFILM", 8)) {
            rc = 2;
        }
        return rc;
    }

    FujiMakerNote::AutoPtr FujiMakerNote::clone(bool alloc) const
    {
        return AutoPtr(clone_(alloc));
    }

    FujiMakerNote* FujiMakerNote::clone_(bool alloc) const 
    {
        AutoPtr makerNote = AutoPtr(new FujiMakerNote(alloc));
        assert(makerNote.get() != 0);
        makerNote->readHeader(header_.pData_, header_.size_, byteOrder_);
        return makerNote.release();
    }

    std::ostream& FujiMakerNote::printTag(std::ostream& os, 
                                          uint16_t tag, 
                                          const Value& value) const
    {
        switch (tag) {
        case 0x1020: // fallthrough
        case 0x1030: // fallthrough
        case 0x1100: // fallthrough
        case 0x1300: // fallthrough
        case 0x1301: // fallthrough
        case 0x1302: printOffOn(os, value); break;
        case 0x1001: print0x1001(os, value); break;
        case 0x1002: print0x1002(os, value); break;
        case 0x1003: print0x1003(os, value); break;
        case 0x1004: print0x1004(os, value); break;
        case 0x1010: print0x1010(os, value); break;
        case 0x1021: print0x1021(os, value); break;
        case 0x1031: print0x1031(os, value); break;
        default:
            // All other tags (known or unknown) go here
            os << value;
            break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::printOffOn(std::ostream& os,
                                            const Value& value)
    {
        switch (value.toLong()) {
        case 0: os << "Off"; break;
        case 1: os << "On"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::print0x1001(std::ostream& os, 
                                             const Value& value)
    {
        switch (value.toLong()) {
        case 1: // fallthrough
        case 2: os << "Soft"; break;
        case 3: os << "Normal"; break;
        case 4: // fallthrough
        case 5: os << "Hard"; break;
        default: os << "(" << value << ")"; break;
        } 
        return os;
    }

    std::ostream& FujiMakerNote::print0x1002(std::ostream& os,
                                             const Value& value)
    {
        switch (value.toLong()) {
        case    0: os << "Auto"; break;
        case  256: os << "Daylight"; break;
        case  512: os << "Cloudy"; break;
        case  768: os << "Fluorescent (daylight)"; break;
        case  769: os << "Fluorescent (warm white)"; break;
        case  770: os << "Fluorescent (cool white)"; break;
        case 1024: os << "Incandescent"; break;
        case 3480: os << "Custom"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::print0x1003(std::ostream& os,
                                             const Value& value)
    {
        switch (value.toLong()) {
        case   0: os << "Standard"; break;
        case 256: os << "High"; break;
        case 512: os << "Original"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::print0x1004(std::ostream& os, 
                                             const Value& value)
    {
        switch (value.toLong()) {
        case   0: os << "Standard"; break;
        case 256: os << "Hard"; break;
        case 512: os << "Original"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::print0x1010(std::ostream& os, 
                                             const Value& value)
    {
        switch (value.toLong()) {
        case 0: os << "Auto"; break;
        case 1: os << "On"; break;
        case 2: os << "Off"; break;
        case 3: os << "Red-eye"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::print0x1021(std::ostream& os,
                                             const Value& value)
    {
        switch (value.toLong()) {
        case 0: os << "Auto"; break;
        case 1: os << "Manual"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

    std::ostream& FujiMakerNote::print0x1031(std::ostream& os,
                                             const Value& value)
    {
        switch (value.toLong()) {
        case   0: os << "Auto"; break;
        case   1: os << "Portrait"; break;
        case   2: os << "Landscape"; break;
        case   4: os << "Sports"; break;
        case   5: os << "Night"; break;
        case   6: os << "Program"; break;
        case 256: os << "Aperture priority"; break;
        case 512: os << "Shutter priority"; break;
        case 768: os << "Manual"; break;
        default: os << "(" << value << ")"; break;
        }
        return os;
    }

// *****************************************************************************
// free functions

    MakerNote::AutoPtr createFujiMakerNote(bool alloc,
                                           const byte* buf, 
                                           long len, 
                                           ByteOrder byteOrder, 
                                           long offset)
    {
        return MakerNote::AutoPtr(new FujiMakerNote(alloc));
    }

}                                       // namespace Exiv2

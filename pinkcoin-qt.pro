TEMPLATE = app
TARGET = Pinkcoin-Qt
VERSION = 2.4.1.0

INCLUDEPATH += src src/json src/qt src/qt/plugins/mrichtexteditor
DEFINES += QT_GUI BOOST_THREAD_USE_LIB BOOST_SPIRIT_THREADSAFE
CONFIG += no_include_pwd
CONFIG += thread
CONFIG += c++11

greaterThan(QT_MAJOR_VERSION, 4) {
    QT += widgets network svg
    DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0
}

# for boost 1.37, add -mt to the boost libraries
# use: qmake BOOST_LIB_SUFFIX=-mt
# for boost thread win32 with _win32 sufix
# use: BOOST_THREAD_LIB_SUFFIX=_win32-...
# or when linking against a specific BerkelyDB version: BDB_LIB_SUFFIX=-4.8

# Dependency library locations can be customized with:
#    BOOST_INCLUDE_PATH, BOOST_LIB_PATH, BDB_INCLUDE_PATH,
#    BDB_LIB_PATH, OPENSSL_INCLUDE_PATH and OPENSSL_LIB_PATH respectively

OBJECTS_DIR = build
MOC_DIR = build
UI_DIR = build

macx {
    message(Building for Mac)

    ICON = src/qt/res/icons/pinkcoin.icns
    QMAKE_INFO_PLIST = share/qt/Info.plist

    HEADERS += src/qt/macdockiconhandler.h \
               src/qt/macnotificationhandler.h
    OBJECTIVE_SOURCES += src/qt/macdockiconhandler.mm \
                         src/qt/macnotificationhandler.mm
    LIBS += -framework Foundation -framework ApplicationServices -framework AppKit

    # OSX 10.6 was the last to support 32-bit, so we target 10.14 and up
    DEFINES += IS_ARCH_64 MAC_OSX MSG_NOSIGNAL=0
    QMAKE_CXXFLAGS += -pthread -mmacosx-version-min=10.14 -arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    QMAKE_CFLAGS += -pthread -mmacosx-version-min=10.14 -arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    QMAKE_OBJECTIVE_CFLAGS += -mmacosx-version-min=10.14 -arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    QMAKE_LFLAGS_THREAD += -pthread
    QMAKE_LFLAGS_SONAME  = -Wl,-install_name,@executable_path/../Frameworks/
}

# Platform specific defaults, if not overridden on command line
# Mac builds by default use packages installed via MacPorts

isEmpty(BOOST_LIB_SUFFIX) {
    macx:BOOST_LIB_SUFFIX = -mt
    windows:BOOST_LIB_SUFFIX = -mgw49-mt-s-1_57
}

isEmpty(BOOST_THREAD_LIB_SUFFIX) {
    BOOST_THREAD_LIB_SUFFIX = $$BOOST_LIB_SUFFIX
}

isEmpty(BOOST_INCLUDE_PATH) {
    macx:BOOST_INCLUDE_PATH =  /usr/local/opt/boost/include/
    windows:BOOST_INCLUDE_PATH = C:/deps/boost_1_57_0
}

isEmpty(BOOST_LIB_PATH) {
    macx:BOOST_LIB_PATH = /usr/local/opt/boost/lib/
    windows:BOOST_LIB_PATH = C:/deps/boost_1_57_0/stage/lib
}

isEmpty(BDB_LIB_SUFFIX) {
    BDB_LIB_SUFFIX = -4.8
}

isEmpty(BDB_INCLUDE_PATH) {
    macx:BDB_INCLUDE_PATH = /usr/local/opt/berkeley-db@4/include/
    windows:BDB_INCLUDE_PATH = C:/deps/db-4.8.30.NC/build_unix
}

isEmpty(BDB_LIB_PATH) {
    macx:BDB_LIB_PATH = /usr/local/opt/berkeley-db@4/lib/
    windows:BDB_LIB_PATH = C:/deps/db-4.8.30.NC/build_unix
}

isEmpty(LIBPNG_INCLUDE_PATH) {
    macx:LIBPNG_INCLUDE_PATH = /usr/local/opt/libpng/include
    windows:LIBPNG_INCLUDE_PATH = C:/deps/libpng-1.6.16
}

isEmpty(LIBPNG_LIB_PATH) {
    macx:LIBPNG_LIB_PATH = /usr/local/opt/libpng/lib
    windows:LIBPNG_LIB_PATH = C:/deps/libpng-1.6.16/.libs
}

isEmpty(MINIUPNPC_INCLUDE_PATH) {
    macx:MINIUPNPC_INCLUDE_PATH = /usr/local/opt/miniupnpc/include
    windows:MINIUPNPC_INCLUDE_PATH = C:/deps
}

isEmpty(MINIUPNPC_LIB_PATH) {
    macx:MINIUPNPC_LIB_PATH = /usr/local/opt/miniupnpc/lib
    windows:MINIUPNPC_LIB_PATH = C:/deps/miniupnpc
}

isEmpty(QRENCODE_INCLUDE_PATH) {
    macx:QRENCODE_INCLUDE_PATH = /usr/local/opt/qrencode/include
    windows:QRENCODE_INCLUDE_PATH = C:/deps/qrencode-3.4.4
}

isEmpty(QRENCODE_LIB_PATH) {
    macx:QRENCODE_LIB_PATH = /usr/local/opt/qrencode/lib
    windows:QRENCODE_LIB_PATH=C:/deps/qrencode-3.4.4/.libs
}

isEmpty(OPENSSL_INCLUDE_PATH) {
    macx:OPENSSL_INCLUDE_PATH = /usr/local/opt/openssl@1.1/include
    windows:OPENSSL_INCLUDE_PATH = C:/deps/openssl-1.0.2h/include
}

isEmpty(OPENSSL_LIB_PATH) {
    macx:OPENSSL_LIB_PATH =  /usr/local/opt/openssl@1.1/lib
    windows:OPENSSL_LIB_PATH = C:/deps/openssl-1.0.2h
}

# use: qmake "RELEASE=1"
contains(RELEASE, 1) {
    !windows:!macx {
        # Linux: static link
        LIBS += -Wl,-Bstatic
    }
}

!win32 {
    # for extra security against potential buffer overflows: enable GCCs Stack Smashing Protection
    QMAKE_CXXFLAGS *= -fstack-protector-all --param ssp-buffer-size=1
    QMAKE_LFLAGS *= -fstack-protector-all --param ssp-buffer-size=1

    # We need to exclude this for Windows cross compile with MinGW 4.2.x, as it will result in a non-working executable!
    # This can be enabled for Windows, when we switch to MinGW >= 4.4.x.
}

# for extra security on Windows: enable ASLR and DEP via GCC linker flags
win32:QMAKE_LFLAGS *= -Wl,--dynamicbase -Wl,--nxcompat
win32:QMAKE_LFLAGS += -static-libgcc -static-libstdc++ -static

# use: qmake "USE_QRCODE=1" ( enabled by default; default)
#  or: qmake "USE_QRCODE=0" (disabled by default)
#  or: qmake "USE_QRCODE=-" (not supported)
# libqrencode (http://fukuchi.org/works/qrencode/index.en.html) must be installed for support
contains(USE_QRCODE, -) {
    message(Building without QRCode support)
} else {
    message(Building with QRCode support)
    count(USE_QRCODE, 0) {
        USE_QRCODE=1
    }

    DEFINES += USE_QRCODE
    LIBS += -lqrencode
}

# use: qmake "USE_UPNP=1" ( enabled by default; default)
#  or: qmake "USE_UPNP=0" (disabled by default)
#  or: qmake "USE_UPNP=-" (not supported)
# miniupnpc (http://miniupnp.free.fr/files/) must be installed for support
contains(USE_UPNP, -) {
    message(Building without UPNP support)
} else {
    message(Building with UPNP support)
    count(USE_UPNP, 0) {
        USE_UPNP=1
    }

    DEFINES += USE_UPNP=$$USE_UPNP STATICLIB
    INCLUDEPATH += $$MINIUPNPC_INCLUDE_PATH
    LIBS += $$join(MINIUPNPC_LIB_PATH,,-L,) -lminiupnpc
    win32:LIBS += -liphlpapi
}

# use: qmake "USE_DBUS=1" or qmake "USE_DBUS=0"
linux:count(USE_DBUS, 0) {
    USE_DBUS=1
}
contains(USE_DBUS, 1) {
    message(Building with DBUS (Freedesktop notifications) support)
    DEFINES += USE_DBUS
    QT += dbus
}

contains(BITCOIN_NEED_QT_PLUGINS, 1) {
    DEFINES += BITCOIN_NEED_QT_PLUGINS
    QTPLUGIN += qcncodecs qjpcodecs qtwcodecs qkrcodecs qtaccessiblewidgets qsvg qsvgicon
}

INCLUDEPATH += src/leveldb/include src/leveldb/helpers
LIBS += $$PWD/src/leveldb/libleveldb.a $$PWD/src/leveldb/libmemenv.a
SOURCES += src/txdb-leveldb.cpp
!win32 {
    # we use QMAKE_CXXFLAGS_RELEASE even without RELEASE=1 because we use RELEASE to indicate linking preferences not -O preferences
    genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a
} else {
    # make an educated guess about what the ranlib command is called
    isEmpty(QMAKE_RANLIB) {
        QMAKE_RANLIB = $$replace(QMAKE_STRIP, strip, ranlib)
    }
    LIBS += -lshlwapi
    #genleveldb.commands = cd $$PWD/src/leveldb && CC=$$QMAKE_CC CXX=$$QMAKE_CXX TARGET_OS=OS_WINDOWS_CROSSCOMPILE $(MAKE) OPT=\"$$QMAKE_CXXFLAGS $$QMAKE_CXXFLAGS_RELEASE\" libleveldb.a libmemenv.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libleveldb.a && $$QMAKE_RANLIB $$PWD/src/leveldb/libmemenv.a
}
genleveldb.target = $$PWD/src/leveldb/libleveldb.a
genleveldb.depends = FORCE
PRE_TARGETDEPS += $$PWD/src/leveldb/libleveldb.a
QMAKE_EXTRA_TARGETS += genleveldb
# Gross ugly hack that depends on qmake internals, unfortunately there is no other way to do it.
QMAKE_CLEAN += $$PWD/src/leveldb/libleveldb.a; cd $$PWD/src/leveldb ; $(MAKE) clean

# regenerate src/build.h
!windows|contains(USE_BUILD_INFO, 1) {
    genbuild.depends = FORCE
    genbuild.commands = cd $$PWD; /bin/sh share/genbuild.sh $$OUT_PWD/build/build.h
    genbuild.target = $$OUT_PWD/build/build.h
    PRE_TARGETDEPS += $$OUT_PWD/build/build.h
    QMAKE_EXTRA_TARGETS += genbuild
    DEFINES += HAVE_BUILD_INFO
}

contains(USE_O3, 1) {
    message(Building O3 optimization flag)
    QMAKE_CXXFLAGS_RELEASE -= -O2
    QMAKE_CFLAGS_RELEASE -= -O2
    QMAKE_CXXFLAGS += -O3
    QMAKE_CFLAGS += -O3
}

*-g++-32 {
    message("32 platform, adding -msse2 flag")

    QMAKE_CXXFLAGS += -msse2
    QMAKE_CFLAGS += -msse2
}

QMAKE_CXXFLAGS_WARN_ON = -fdiagnostics-show-option -Wall -Wextra -Wno-ignored-qualifiers -Wformat -Wformat-security -Wno-unused-parameter -Wstack-protector

# Input
DEPENDPATH += src src/json src/qt
HEADERS += src/qt/bitcoingui.h \
    src/qt/transactiontablemodel.h \
    src/qt/addresstablemodel.h \
    src/qt/optionsdialog.h \
    src/qt/coincontroldialog.h \
    src/qt/coincontroltreewidget.h \
    src/qt/sendcoinsdialog.h \
    src/qt/addressbookpage.h \
    src/qt/signverifymessagedialog.h \
    src/qt/aboutdialog.h \
    src/qt/editaddressdialog.h \
    src/qt/bitcoinaddressvalidator.h \
    src/alert.h \
    src/addrman.h \
    src/base58.h \
    src/bignum.h \
    src/checkpoints.h \
    src/compat.h \
    src/coincontrol.h \
    src/sync.h \
    src/util.h \
    src/uint256.h \
    src/kernel.h \
    src/scrypt.h \
    src/pbkdf2.h \
    src/serialize.h \
    src/smessage.h \
    src/main.h \
    src/miner.h \
    src/net.h \
    src/key.h \
    src/db.h \
    src/txdb.h \
    src/walletdb.h \
    src/stakedb.h \
    src/script.h \
    src/stealth.h \
    src/init.h \
    src/mruset.h \
    src/json/json_spirit_writer_template.h \
    src/json/json_spirit_writer.h \
    src/json/json_spirit_value.h \
    src/json/json_spirit_utils.h \
    src/json/json_spirit_stream_reader.h \
    src/json/json_spirit_reader_template.h \
    src/json/json_spirit_reader.h \
    src/json/json_spirit_error_position.h \
    src/json/json_spirit.h \
    src/qt/clientmodel.h \
    src/qt/guiutil.h \
    src/qt/transactionrecord.h \
    src/qt/guiconstants.h \
    src/qt/optionsmodel.h \
    src/qt/monitoreddatamapper.h \
    src/qt/transactiondesc.h \
    src/qt/transactiondescdialog.h \
    src/qt/bitcoinamountfield.h \
    src/wallet.h \
    src/keystore.h \
    src/qt/transactionfilterproxy.h \
    src/qt/transactionview.h \
    src/qt/walletmodel.h \
    src/bitcoinrpc.h \
    src/qt/overviewpage.h \
    src/qt/csvmodelwriter.h \
    src/crypter.h \
    src/qt/sendcoinsentry.h \
    src/qt/qvalidatedlineedit.h \
    src/qt/bitcoinunits.h \
    src/qt/qvaluecombobox.h \
    src/qt/askpassphrasedialog.h \
    src/protocol.h \
    src/qt/notificator.h \
    src/qt/qtipcserver.h \
    src/allocators.h \
    src/ui_interface.h \
    src/qt/rpcconsole.h \
    src/qt/trafficgraphwidget.h \
    src/version.h \
    src/netbase.h \
    src/clientversion.h \
    src/threadsafety.h \
    src/qt/messagepage.h \
    src/qt/messagemodel.h \
    src/qt/sendmessagesdialog.h \
    src/qt/sendmessagesentry.h \
    src/qt/plugins/mrichtexteditor/mrichtextedit.h \
    src/qt/qvalidatedtextedit.h \
    src/ntp.h

SOURCES += src/qt/bitcoin.cpp src/qt/bitcoingui.cpp \
    src/qt/transactiontablemodel.cpp \
    src/qt/addresstablemodel.cpp \
    src/qt/optionsdialog.cpp \
    src/qt/sendcoinsdialog.cpp \
    src/qt/coincontroldialog.cpp \
    src/qt/coincontroltreewidget.cpp \
    src/qt/addressbookpage.cpp \
    src/qt/signverifymessagedialog.cpp \
    src/qt/aboutdialog.cpp \
    src/qt/editaddressdialog.cpp \
    src/qt/bitcoinaddressvalidator.cpp \
    src/alert.cpp \
    src/version.cpp \
    src/sync.cpp \
    src/smessage.cpp \
    src/util.cpp \
    src/netbase.cpp \
    src/key.cpp \
    src/script.cpp \
    src/main.cpp \
    src/miner.cpp \
    src/init.cpp \
    src/net.cpp \
    src/checkpoints.cpp \
    src/addrman.cpp \
    src/db.cpp \
    src/walletdb.cpp \
    src/stakedb.cpp \
    src/qt/clientmodel.cpp \
    src/qt/guiutil.cpp \
    src/qt/transactionrecord.cpp \
    src/qt/optionsmodel.cpp \
    src/qt/monitoreddatamapper.cpp \
    src/qt/transactiondesc.cpp \
    src/qt/transactiondescdialog.cpp \
    src/qt/bitcoinstrings.cpp \
    src/qt/bitcoinamountfield.cpp \
    src/wallet.cpp \
    src/keystore.cpp \
    src/qt/transactionfilterproxy.cpp \
    src/qt/transactionview.cpp \
    src/qt/walletmodel.cpp \
    src/bitcoinrpc.cpp \
    src/rpcdump.cpp \
    src/rpcnet.cpp \
    src/rpcmining.cpp \
    src/rpcwallet.cpp \
    src/rpcblockchain.cpp \
    src/rpcrawtransaction.cpp \
    src/rpcsmessage.cpp \
    src/qt/overviewpage.cpp \
    src/qt/csvmodelwriter.cpp \
    src/crypter.cpp \
    src/qt/sendcoinsentry.cpp \
    src/qt/qvalidatedlineedit.cpp \
    src/qt/bitcoinunits.cpp \
    src/qt/qvaluecombobox.cpp \
    src/qt/askpassphrasedialog.cpp \
    src/protocol.cpp \
    src/qt/notificator.cpp \
    src/qt/qtipcserver.cpp \
    src/qt/rpcconsole.cpp \
    src/qt/trafficgraphwidget.cpp \
    src/qt/messagepage.cpp \
    src/qt/messagemodel.cpp \
    src/qt/sendmessagesdialog.cpp \
    src/qt/sendmessagesentry.cpp \
    src/qt/qvalidatedtextedit.cpp \
    src/qt/plugins/mrichtexteditor/mrichtextedit.cpp \
    src/noui.cpp \
    src/kernel.cpp \
    src/scrypt-arm.S \
    src/scrypt-x86.S \
    src/scrypt-x86_64.S \
    src/scrypt.cpp \
    src/pbkdf2.cpp \
    src/stealth.cpp\
    src/ntp.cpp

RESOURCES += \
    src/qt/bitcoin.qrc 

FORMS += \
    src/qt/forms/coincontroldialog.ui \
    src/qt/forms/sendcoinsdialog.ui \
    src/qt/forms/addressbookpage.ui \
    src/qt/forms/signverifymessagedialog.ui \
    src/qt/forms/aboutdialog.ui \
    src/qt/forms/editaddressdialog.ui \
    src/qt/forms/transactiondescdialog.ui \
    src/qt/forms/overviewpage.ui \
    src/qt/forms/sendcoinsentry.ui \
    src/qt/forms/askpassphrasedialog.ui \
    src/qt/forms/rpcconsole.ui \
    src/qt/forms/optionsdialog.ui \
    src/qt/forms/messagepage.ui \
    src/qt/forms/sendmessagesentry.ui \
    src/qt/forms/sendmessagesdialog.ui \
    src/qt/plugins/mrichtexteditor/mrichtextedit.ui

contains(USE_QRCODE, 1) {
HEADERS += src/qt/qrcodedialog.h
SOURCES += src/qt/qrcodedialog.cpp
FORMS += src/qt/forms/qrcodedialog.ui
}

CODECFORTR = UTF-8

# for lrelease/lupdate
# also add new translations to src/qt/bitcoin.qrc under translations/
TRANSLATIONS = $$files(src/qt/locale/bitcoin_*.ts)

isEmpty(QMAKE_LRELEASE) {
    win32:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]\\lrelease.exe
    else:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]/lrelease
}
isEmpty(QM_DIR):QM_DIR = $$PWD/src/qt/locale
# automatically build translations, so they can be included in resource file
TSQM.name = lrelease ${QMAKE_FILE_IN}
TSQM.input = TRANSLATIONS
TSQM.output = $$QM_DIR/${QMAKE_FILE_BASE}.qm
TSQM.commands = $$QMAKE_LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
TSQM.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += TSQM

# "Other files" to show in Qt Creator
OTHER_FILES += \
    doc/*.rst doc/*.txt doc/README README.md res/bitcoin-qt.rc

windows:DEFINES += WIN32
windows:RC_FILE = src/qt/res/bitcoin-qt.rc

windows:!contains(MINGW_THREAD_BUGFIX, 0) {
    # At least qmake's win32-g++-cross profile is missing the -lmingwthrd
    # thread-safety flag. GCC has -mthreads to enable this, but it doesn't
    # work with static linking. -lmingwthrd must come BEFORE -lmingw, so
    # it is prepended to QMAKE_LIBS_QT_ENTRY.
    # It can be turned off with MINGW_THREAD_BUGFIX=0, just in case it causes
    # any problems on some untested qmake profile now or in the future.
    DEFINES += _MT BOOST_THREAD_PROVIDES_GENERIC_SHARED_MUTEX_ON_WIN
    QMAKE_LIBS_QT_ENTRY = -lmingwthrd $$QMAKE_LIBS_QT_ENTRY
}

# Set libraries and includes at end, to use platform-defined defaults if not overridden
INCLUDEPATH += $$BOOST_INCLUDE_PATH $$BDB_INCLUDE_PATH $$OPENSSL_INCLUDE_PATH $$QRENCODE_INCLUDE_PATH
LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) $$join(OPENSSL_LIB_PATH,,-L,) $$join(QRENCODE_LIB_PATH,,-L,)
LIBS += -lssl -lcrypto -ldb_cxx$$BDB_LIB_SUFFIX
# -lgdi32 has to happen after -lcrypto (see  #681)
windows:LIBS += -lws2_32 -lshlwapi -lmswsock -lole32 -loleaut32 -luuid -lgdi32
LIBS += -lboost_system$$BOOST_LIB_SUFFIX -lboost_filesystem$$BOOST_LIB_SUFFIX -lboost_program_options$$BOOST_LIB_SUFFIX -lboost_thread$$BOOST_THREAD_LIB_SUFFIX -lboost_chrono$$BOOST_LIB_SUFFIX

contains(RELEASE, 1) {
    !windows:!macx {
        # Linux: turn dynamic linking back on for c/c++ runtime libraries
        LIBS += -Wl,-Bdynamic
    }
    macx {
        LIBS+= -dead_strip
        LIBS += \
             /usr/local/opt/miniupnpc/lib/libminiupnpc.a \
             /usr/local/opt/berkeley-db@4/lib/libdb_cxx-4.8.a \
             /usr/local/opt/boost/lib/libboost_system-mt.a \
             /usr/local/opt/boost/lib/libboost_filesystem-mt.a \
             /usr/local/opt/boost/lib/libboost_program_options-mt.a \
             /usr/local/opt/boost/lib/libboost_thread-mt.a \
             /usr/local/opt/boost/lib/libboost_chrono-mt.a \
             /usr/local/opt/openssl@1.1/lib/libssl.a \
             /usr/local/opt/openssl@1.1/lib/libcrypto.a \
             /usr/local/opt/zlib/lib/libz.a
    }
}

!windows:!macx {
    DEFINES += LINUX
    LIBS += -lrt -ldl
}

themes.path = $$OUT_PWD/$$DESTDIR/themes
macx:themes.path = $$OUT_PWD/$$DESTDIR/Pinkcoin-Qt.app/Contents/MacOS/themes
themes.files = src/qt/res/themes/*
INSTALLS += themes

system($$QMAKE_LRELEASE -silent $$_PRO_FILE_)

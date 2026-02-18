cmake_minimum_required(VERSION 3.16)

project(homework VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickDialogs2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(apphomework
    main.cpp
    projectmanager.h
    projectmanager.cpp
)

qt_add_qml_module(apphomework
    URI homework
    QML_FILES
        Main.qml
        qml/MainToolbar.qml
        qml/LeftPanel.qml
        qml/RightPanel.qml
        qml/BottomPanel.qml
        qml/CentralWorkspace.qml
)

set_target_properties(apphomework PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(apphomework
    PRIVATE Qt6::Quick Qt6::QuickDialogs2
)

include(GNUInstallDirs)
install(TARGETS apphomework
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

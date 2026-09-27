cmake_minimum_required(VERSION 3.24)
project(OmaiPatient VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
    add_compile_options(/utf-8)
endif()
find_package(Qt6 6.8 REQUIRED COMPONENTS Quick QuickControls2 Test)
qt_standard_project_setup(REQUIRES 6.8)
qt_add_executable(omai-patient src/main.cpp
    src/presentation/viewmodels/PatientViewModel.cpp
    src/presentation/viewmodels/PatientViewModel.h
    src/infrastructure/storage/MockRepository.cpp)
target_include_directories(omai-patient PRIVATE src)
target_link_libraries(omai-patient PRIVATE Qt6::Quick Qt6::QuickControls2)
file(GLOB_RECURSE OMAI_QML CONFIGURE_DEPENDS "qml/*.qml")
foreach(qml_file IN LISTS OMAI_QML)
    get_filename_component(qml_name "${qml_file}" NAME)
    set_source_files_properties("${qml_file}" PROPERTIES QT_RESOURCE_ALIAS "${qml_name}")
endforeach()
set_source_files_properties(qml/theme/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
qt_add_qml_module(omai-patient URI Omai VERSION 1.0 QML_FILES ${OMAI_QML}
    RESOURCES assets/mock.json assets/prescription-qr.svg)
set_target_properties(omai-patient PROPERTIES
    QT_ANDROID_PACKAGE_NAME "com.orzyon.omai.patient"
    QT_ANDROID_APP_NAME "OMAI Patient"
    MACOSX_BUNDLE TRUE WIN32_EXECUTABLE TRUE)
include(CTest)
if(BUILD_TESTING AND NOT ANDROID AND NOT IOS)
    qt_add_executable(omai-tests tests/PatientViewModelTest.cpp
        src/presentation/viewmodels/PatientViewModel.cpp
        src/presentation/viewmodels/PatientViewModel.h
        src/infrastructure/storage/MockRepository.cpp)
    target_include_directories(omai-tests PRIVATE src)
    target_link_libraries(omai-tests PRIVATE Qt6::Test)
    qt_add_resources(omai-tests mocks PREFIX "/qt/qml/Omai" FILES assets/mock.json)
    add_test(NAME patient-flows COMMAND omai-tests)
endif()

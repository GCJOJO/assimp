
local function premakeActionToCmakeGenerator(action)
    local generators = {
        vs2022  = "Visual Studio 17 2022",
        vs2019  = "Visual Studio 16 2019",
        vs2017  = "Visual Studio 15 2017",
        gmake   = "Unix Makefiles",
        gmake2  = "Unix Makefiles",
        xcode4  = "Xcode",
    }
    return generators[action]
end

local function ensureAssimpBuilt()
    if not _ACTION then
        return
    end 

    local cmakeGenerator = premakeActionToCmakeGenerator(_ACTION)
    if not cmakeGenerator then
        print("Unsupported premake action: " .. _ACTION)
        return
    end

    local buildDir = path.join(_WORKING_DIR, "Engine/vendor/Assimp/build")
    os.mkdir(buildDir)

    local archFlags = ""
    if _ACTION == "vs2022" or _ACTION == "vs2019" or _ACTION == "vs2017" then
        if os.is("windows") then
            if arch == "x64" then
                archFlags = "-A x64"
            end
        end
    end
    
    local cmakeCommand = string.format(
        'cmake -S "." -B "build" -G "%s" %s ' ..
        '-DBUILD_SHARED_LIBS=OFF -DASSIMP_BUILD_TESTS=OFF ' ..
        '-DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_BUILD_ZLIB=ON',
        cmakeGenerator, archFlags
    )
    
    print(cmakeCommand)
    local ok, errCode = os.execute(cmakeCommand)
    if not ok then
        error("CMake configuration failed with error code: " .. tostring(errCode))
    end
end

ensureAssimpBuilt()

externalproject "Assimp"
    location "build/code"
    uuid (os.uuid("Assimp"))
    kind "StaticLib"
    language "C++"
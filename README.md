# Ptolemy II MSI Installer for Windows

**Ptolemy II** is a software framework developed at [UC Berkeley](https://ptolemy.berkeley.edu/ptolemyII/ptIIlatest/doc/index.htm) for modeling and simulating complex, heterogeneous systems, particularly those involving concurrency and real-time behavior. It is based on the principles of **actor-oriented design**.

I personally enjoy working with Ptolemy II and use it extensively during my modeling and simulation classes.

This repository is a **fork of the official [Ptolemy II repository](https://github.com/icyphy/ptII)**, with the goal of creating and sharing a **modern Windows MSI installer** that leverages newer versions of Java. The codebase remains unchanged, with a few minimal adjustments described below. 

> ✅ **Download the Installer**:  
> 👉 [PtolemyII-11.1.msi](https://github.com/traiannicula/ptII-win-installer/releases/download/v1.0.0/PtolemyII-11.1.msi)

---

## 🔧 How the Installer Was Created

### 1. Prerequisites Installed

- Installed [Adoptium Temurin JDK 21](https://adoptium.net/temurin/releases/?os=any&arch=any&version=21)
- Installed the latest version of Eclipse IDE
- Forked and cloned the official [Ptolemy II GitHub repository](https://github.com/icyphy/ptII)

### 2. Eclipse Setup

Followed steps 3–5 from the Ptolemy II Eclipse setup guide:  
📖 [Setting up Ptolemy II and Eclipse (Windows)](https://ptolemy.berkeley.edu/ptolemyII/ptIIlatest/doc/eclipse/windows/index.htm)

### 3. Minor Code Adjustments

- **Added `module-info.java`** to enable Swing modules:
    ```java
    module ptII {
        requires java.desktop;
    }
    ```

- **Enabled Nimbus Swing Look & Feel** in `MoMLApplication.java`:
    ```java
    UIManager.setLookAndFeel("javax.swing.plaf.nimbus.NimbusLookAndFeel");
    ```

### 4. Packaged Application

1. **Create a folder named `lib`** inside `installer/app/` and copy all the `.jar` files from your library path into it (everything you had in `D:\dev\projects\ptII-win-installer\lib\`).
2. **Create a subfolder named `classes`** inside `installer/app/` and copy all the compiled code from your `output` folder there (the `ptolemy/`, `org/`, etc. directories, along with their resources like `.js`, `.xml` files, or icons).
3. **Copy the specific internal dependency folders**, maintaining their relative paths inside `installer/app/`. For example:
   * `installer/app/ptolemy/actor/lib/excel/jxl.jar`
   * `installer/app/ptolemy/distributed/jini/jar/...`
   * `installer/app/ptolemy/domains/ptinyos/lib/...`
   * `installer/app/ptolemy/actor/ptalon/antlr/antlr.jar`
4. **Create a "Dummy JAR" (empty JAR file)**. By design, `jpackage` forces you to specify a `--main-jar`. The solution is to create a tiny JAR (for instance, an empty text file renamed to `ptII-launcher.jar` or quickly generated via the console) and place it directly in the root of `installer/app/`. It serves solely as a launcher trigger.

The final structure inside your `installer/app` folder should look like this:

installer/app/
├── ptII-launcher.jar   <-- (Dummy/empty JAR file)
├── classes/            <-- (Your compiled 'output' folder containing ptolemy/, etc.)
├── lib/                <-- (All the ~60 JARs from the general lib folder)
└── ptolemy/            <-- (Structure with specific subfolders for jxl, jini, nesc, antlr)
    ├── actor/
    ├── distributed/
    └── domains/


### 5. WiX Toolset Installation

- Installed [WiX Toolset v3.14.1](https://github.com/wixtoolset/wix3/releases) to enable MSI packaging

### 6. Built the Installer with `jpackage`

```bash
jpackage \
  --type msi \
  --name "PtolemyII" \
  --input installer/app \
  --main-jar ptII-launcher.jar \
  --main-class ptolemy.vergil.VergilApplication \
  --icon installer/icon/ptiny.ico \
  --win-shortcut \
  --win-menu \
  --win-dir-chooser \
  --win-menu-group "Ptolemy II" \
  --app-version 11.1 \
  --copyright "Copyright (c) 1995-2021 The Regents of the University of California" \
  --description "Ptolemy II is an open-source software framework supporting experimentation with actor-oriented design" \
  --java-options "-Djava.awt.headless=false" \
  --java-options "-XX:+ShowCodeDetailsInExceptionMessages" \
  --java-options "-cp \$APPDIR/classes;\$APPDIR/lib/*;\$APPDIR/ptolemy/actor/lib/excel/jxl.jar;\$APPDIR/ptolemy/distributed/jini/jar/*;\$APPDIR/ptolemy/domains/ptinyos/lib/*;\$APPDIR/ptolemy/actor/ptalon/antlr/antlr.jar" \
  --java-options "--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED"
```


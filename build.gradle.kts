plugins {
    id("com.lovelysystems.gradle") version ("1.10.0")
}

lovely {
    gitProject()
    dockerProject(
        "lovelysystems/pg-backup",
        platforms = listOf("linux/amd64")
    ) {
        from("docker")
    }
}

group = "com.lovelysystems"

tasks {

    val writeVersion by creating {
        val out = file("VERSION.txt")
        outputs.file(out)
        out.writeText(project.version.toString())
    }

    val localDevDown by creating {
        group = "Development"
        description = "Stops local development Docker containers"
        doLast {
            exec {
                commandLine(
                    "docker-compose",
                    "-f",
                    "localdev/docker-compose.yml",
                    "down"
                )
            }
        }
    }

    val localDev by creating {
        group = "Development"
        description = "Starts local development based on Docker containers"
        dependsOn("buildDockerImage")
        doLast {
            exec {
                commandLine(
                    "docker-compose",
                    "-f",
                    "localdev/docker-compose.yml",
                    "up",
                    "-d"
                )
            }
        }
    }
}

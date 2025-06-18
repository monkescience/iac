package tofu

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

type Tofu mg.Namespace

// Init initializes the tofu project
func (Tofu) Init() error {
	stageEnvVars := getStageEnvVars()

	configPath := NewConfigPath(stageEnvVars.Region, stageEnvVars.Environment)
	config, err := NewConfig(configPath)
	if err != nil {
		return err
	}

	component, err := NewComponentName()
	if err != nil {
		return err
	}

	return sh.RunV("tofu",
		"-chdir="+NewRootPath(stageEnvVars.Region, stageEnvVars.Environment),
		"init",
		"-backend-config=region="+stageEnvVars.Region,
		"-backend-config=bucket="+config.S3BackendConfig.Bucket,
		"-backend-config=use_lockfile="+config.S3BackendConfig.UseLockfile,
		"-backend-config=encrypt="+config.S3BackendConfig.Encrypt,
		"-backend-config=key="+NewStateFilePath(component),
	)
}

// Plan creates an execution plan
func (Tofu) Plan() error {
	mg.Deps(Tofu.Init)

	stageEnvVars := getStageEnvVars()

	configPath := NewConfigPath(stageEnvVars.Region, stageEnvVars.Environment)
	config, err := NewConfig(configPath)
	if err != nil {
		return err
	}

	component, err := NewComponentName()
	if err != nil {
		return err
	}

	return sh.RunV("tofu",
		"-chdir="+NewRootPath(stageEnvVars.Region, stageEnvVars.Environment),
		"plan",
		"-out=terraform.tfplan",
		"-var=region="+stageEnvVars.Region,
		"-var=environment="+stageEnvVars.Environment,
		"-var=project="+config.Project,
		"-var=component="+component,
	)
}

// Plandestroy creates an execution plan to destroy
func (Tofu) Plandestroy() error {
	mg.Deps(Tofu.Init)

	stageEnvVars := getStageEnvVars()

	configPath := NewConfigPath(stageEnvVars.Region, stageEnvVars.Environment)
	config, err := NewConfig(configPath)
	if err != nil {
		return err
	}

	component, err := NewComponentName()
	if err != nil {
		return err
	}

	return sh.RunV("tofu",
		"-chdir="+NewRootPath(stageEnvVars.Region, stageEnvVars.Environment),
		"plan",
		"-out=terraform.tfplan",
		"-var=region="+stageEnvVars.Region,
		"-var=environment="+stageEnvVars.Environment,
		"-var=project="+config.Project,
		"-var=component="+component,
		"-destroy",
	)

}

// Show shows the planned changes
func (Tofu) Show() error {
	stageEnvVars := getStageEnvVars()

	return sh.RunV("tofu",
		"-chdir="+NewRootPath(stageEnvVars.Region, stageEnvVars.Environment),
		"show",
		"terraform.tfplan",
	)

}

// Apply applies the planned changes
func (Tofu) Apply() error {
	stageEnvVars := getStageEnvVars()

	return sh.RunV("tofu",
		"-chdir="+NewRootPath(stageEnvVars.Region, stageEnvVars.Environment),
		"apply",
		"terraform.tfplan",
	)
}

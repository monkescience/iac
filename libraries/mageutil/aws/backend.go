package aws

import (
	"errors"
	"os"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Project         string           `yaml:"project"`
	S3BackendConfig *S3BackendConfig `yaml:"s3_backend"`
}

type S3BackendConfig struct {
	Bucket      string `yaml:"bucket"`
	Encrypt     string `yaml:"encrypt"`
	UseLockfile string `yaml:"use_lockfile"`
}

var (
	ErrOpenConfigFile = errors.New("failed to open config file")
	ErrDecodeConfig   = errors.New("failed to decode config")
)

func NewConfig(path string) (*Config, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, errors.Join(ErrOpenConfigFile, err)
	}
	defer func(file *os.File) {
		_ = file.Close()
	}(file)

	var config *Config
	err = yaml.NewDecoder(file).Decode(&config)
	if err != nil {
		return nil, errors.Join(ErrDecodeConfig, err)
	}

	return config, nil
}

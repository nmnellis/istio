package lumberjack

import (
	"context"
	"encoding/json"

	"time"
	"path/filepath"
	config "istio.io/istio/mixer/adapter/lumberjack/config"
	"istio.io/istio/mixer/pkg/adapter"
	"istio.io/istio/mixer/template/logentry"
	"gopkg.in/natefinch/lumberjack.v2"
)

type (
	builder struct {
		adapterConfig *config.Params
		logEntryTypes map[string]*logentry.Type
	}
	handler struct {
		l							*lumberjack.Logger
		logEntryTypes map[string]*logentry.Type
		env         	adapter.Env
	}
)

// ensure types implement the requisite interfaces
var(
	_ logentry.HandlerBuilder = &builder{}
	_ logentry.Handler = &handler{}
)

///////////////// Configuration-time Methods ///////////////

// adapter.HandlerBuilder#Build
func (b *builder) Build(ctx context.Context, env adapter.Env) (adapter.Handler, error) {
	var err error
	logger := &lumberjack.Logger {
			Filename:   b.adapterConfig.FilePath,
			MaxSize:    b.adapterConfig.MaxFileSize, // megabytes
			MaxAge:     b.adapterConfig.MaxFileAge, // days
			MaxBackups:	b.adapterConfig.MaxFileBackups,
			Compress:		b.adapterConfig.CompressOldFiles,
	}
	return &handler{l: logger, logEntryTypes: b.logEntryTypes, env: env}, err

}

// adapter.HandlerBuilder#SetAdapterConfig
func (b *builder) SetAdapterConfig(cfg adapter.Config) {
	b.adapterConfig = cfg.(*config.Params)
}

// adapter.HandlerBuilder#Validate
func (b *builder) Validate() (ce *adapter.ConfigErrors) {
	// Check if the path is valid
	if _, err := filepath.Abs(b.adapterConfig.FilePath); err != nil {
		ce = ce.Append("file_path", err)
	}
	return
}

func (b *builder) SetLogEntryTypes(types map[string]*logentry.Type) { b.logEntryTypes = types }

// LogUnit for logging in json format
type LogUnit struct {
	LogEntry map[string]interface{} `json:"logEntry"`
	Timestamp time.Time `json:"@timestamp"`
}

////////////////// Request-time Methods //////////////////////////
// logentry.Handler#HandleLogEntry
func (h *handler) HandleLogEntry(_ context.Context, instances []*logentry.Instance) error {
	for _, instance := range instances {

		logUnit := &LogUnit{LogEntry: instance.Variables,Timestamp: instance.Timestamp}
		b, _ := json.Marshal(logUnit)

		//write logentry to log and newline it
		h.l.Write(b append(b[:], []byte("\n")))
	}
	return nil
}

// adapter.Handler#Close
func (h *handler) Close() error {
	return h.l.Close()
}

////////////////// Bootstrap //////////////////////////
// GetInfo returns the adapter.Info specific to this adapter.
func GetInfo() adapter.Info {
	return adapter.Info{
		Name:        "lumberjack",
		Description: "Logs LogEntry itmes to a json file",
		SupportedTemplates: []string{
			logentry.TemplateName,
		},
		NewBuilder:    func() adapter.HandlerBuilder { return &builder{} },
		DefaultConfig: &config.Params{

		},
	}
}
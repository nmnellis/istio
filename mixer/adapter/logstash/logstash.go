package logstash

import (
	"context"
	"encoding/json"

	"time"
	"path/filepath"
	config "istio.io/istio/mixer/adapter/logstash/config"
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
			MaxSize:    100, // megabytes
			MaxAge:     7, // days
			MaxBackups:  100, // 100 files of 100MB (1GB max retention)
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

// LogUnit for logging in logstash format
type LogUnit struct {
	Message map[string]interface{} `json:"message"`
	Timestamp time.Time `json:"@timestamp"`
}

////////////////// Request-time Methods //////////////////////////
// logentry.Handler#HandleMetric
func (h *handler) HandleLogEntry(_ context.Context, instances []*logentry.Instance) error {
	for _, instance := range instances {

		logUnit := &LogUnit{Message: instance.Variables,Timestamp: instance.Timestamp}
		b, _ := json.Marshal(logUnit)

		//write logentry to log and newline it
		h.l.Write(b)
		h.l.Write([]byte("\n"))

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
		Name:        "logstash",
		Description: "Logs the calls into a logstash compatible json file",
		SupportedTemplates: []string{
			logentry.TemplateName,
		},
		NewBuilder:    func() adapter.HandlerBuilder { return &builder{} },
		DefaultConfig: &config.Params{

		},
	}
}
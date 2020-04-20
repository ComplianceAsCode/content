package ocp4unit

import (
	"bufio"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	mcfgapi "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io"
	mcfgv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
	k8syaml "k8s.io/apimachinery/pkg/util/yaml"
)

type unitTestContext struct {
	rootdir string
	t       *testing.T
}

func newUnitTestContext(t *testing.T) *unitTestContext {
	rootdir := os.Getenv("ROOT_DIR")
	if rootdir == "" {
		rootdir = "../../../not valid"
	}
	return &unitTestContext{
		rootdir: rootdir,
		t:       t,
	}
}

func (ctx *unitTestContext) assertObjectIsValid(path string) *unstructured.Unstructured {
	obj, err := readObjFromYAMLFilePath(path)

	if err != nil {
		ctx.t.Errorf("The object in the following path is malformed '%s': %s", path, err)
	}

	return obj
}

func (ctx *unitTestContext) assertMachineConfigIsValid(obj *unstructured.Unstructured, path string) {
	mcfg := &mcfgv1.MachineConfig{}
	unstructured := obj.UnstructuredContent()
	err := runtime.DefaultUnstructuredConverter.FromUnstructured(unstructured, mcfg)

	if err != nil {
		ctx.t.Errorf("The MachineConfig in the following path is not valid '%s': %s", path, err)
	}
}

func (ctx *unitTestContext) assertWithRelevantFiles(assertion func(path string)) {
	err := filepath.Walk(ctx.rootdir,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if isRelevantDir(path, info) {
				filepath.Walk(path,
					func(path string, info os.FileInfo, err error) error {
						if isRelevantFile(path) {
							assertion(path)
						}
						return nil
					})
			}
			return nil
		},
	)
	if err != nil {
		ctx.t.Fatalf("Error wile walking through files %s", err)
	}
}

func isMachineConfig(obj *unstructured.Unstructured) bool {
	objgvk := obj.GroupVersionKind()
	return "MachineConfig" == objgvk.Kind && mcfgapi.GroupName == objgvk.Group
}

func isRelevantDir(path string, info os.FileInfo) bool {
	// We don't care about e2e tests
	if strings.Contains(path, "ocp4e2e/") {
		return false
	}
	// We don't care about this folder
	if strings.Contains(path, "unit/kubernetes") {
		return false
	}
	if strings.Contains(path, ".git/") {
		return false
	}
	return info.IsDir() && (info.Name() == "ignition" || info.Name() == "kubernetes")
}

func isRelevantFile(path string) bool {
	return strings.HasSuffix(path, ".yml")
}

// Reads a YAML file and returns an unstructured object from it. This object
// can be taken into use by the dynamic client
func readObjFromYAMLFilePath(path string) (*unstructured.Unstructured, error) {
	nsyamlfile, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer nsyamlfile.Close()

	return readObjFromYAML(bufio.NewReader(nsyamlfile))
}

// Reads a YAML file and returns an unstructured object from it. This object
// can be taken into use by the dynamic client
func readObjFromYAML(r io.Reader) (*unstructured.Unstructured, error) {
	obj := &unstructured.Unstructured{}
	dec := k8syaml.NewYAMLToJSONDecoder(r)
	err := dec.Decode(obj)
	return obj, err
}

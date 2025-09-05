package ocp4unit

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	ign "github.com/coreos/ignition/config/v2_2/types"
	mcfgapi "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io"
	mcfgv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	"gopkg.in/yaml.v2"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
	k8syaml "k8s.io/apimachinery/pkg/util/yaml"
)

type unitTestContext struct {
	rootdir string
	t       *testing.T
}

type profile struct {
	Title       string
	Description string
	Selections  []string
}

type undesiredSelection struct {
	Name   string
	Reason string
}

type fileTracker struct {
	FileInContent string
	File          *ign.File
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

func (ctx *unitTestContext) assertProfileIsValid(path string) *profile {
	obj, err := readProfileYAML(path)

	if err != nil {
		ctx.t.Errorf("The profile in the following path is malformed '%s': %s", path, err)
	}

	return obj
}

func (ctx *unitTestContext) assertMachineConfigIsValid(obj *unstructured.Unstructured, path string) *mcfgv1.MachineConfig {
	mcfg := &mcfgv1.MachineConfig{}
	unstructured := obj.UnstructuredContent()
	err := runtime.DefaultUnstructuredConverter.FromUnstructured(unstructured, mcfg)

	if err != nil {
		ctx.t.Errorf("The MachineConfig in the following path is not valid '%s': %s", path, err)
		return nil
	}
	return mcfg
}

func (ctx *unitTestContext) assertFileDoesntDiffer(mcfg *mcfgv1.MachineConfig, contentPath string, affectedFiles map[string]fileTracker) {
	files := mcfg.Spec.Config.Storage.Files
	for i, file := range files {
		trackedFile, found := affectedFiles[file.Path]
		if found {
			if !fileDiff(trackedFile.File, &file) {
				ctx.t.Errorf("Files differ: %s - %s", trackedFile.FileInContent, contentPath)
			}
			//ctx.t.Logf("Files EQUAL: %s - %s", trackedFile.FileInContent, contentPath)
		} else {
			affectedFiles[file.Path] = fileTracker{FileInContent: contentPath, File: &files[i]}
		}
	}
}

func fileDiff(f1, f2 *ign.File) bool {
	return reflect.DeepEqual(f1, f2)
}

func (ctx *unitTestContext) assertWithRelevantFiles(startDir string,
	isRelevantDir func(string, os.FileInfo) bool, isRelevantFile func(string) bool,
	assertion func(path string)) {

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

func (ctx *unitTestContext) assertWithRelevantContentFiles(assertion func(path string)) {
	ctx.assertWithRelevantFiles(ctx.rootdir,
		isRelevantContentDir, isRelevantKubernetesFile,
		assertion)
}

func (ctx *unitTestContext) asssertWithOCPProfiles(assertion func(path string)) {
	ctx.assertWithRelevantFiles(ctx.rootdir,
		isOCPProfileDir, isProfileFile,
		assertion)
}

func (ctx *unitTestContext) asssertSelectionsNotInOCPProfile(selections []string, path string, badSelections []undesiredSelection) {
	for _, selection := range selections {
		for _, badSelection := range badSelections {
			if selection == badSelection.Name {
				ctx.t.Errorf("ERROR: Selection '%s' can't be in OCP profile '%s': %s",
					badSelection.Name, path, badSelection.Reason)
			}
		}
	}
}

func isRuleException(path string) bool {
	for _, rule := range ruleExceptions {
		if strings.Contains(path, rule) {
			return true
		}
	}
	return false
}

func isRelevantContentDir(path string, info os.FileInfo) bool {
	// We don't care about e2e tests
	if strings.Contains(path, "ocp4e2e/") {
		return false
	}
	// We don't care about the build directory
	if strings.Contains(path, "build/") {
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

func isRelevantKubernetesFile(path string) bool {
	return strings.HasSuffix(path, ".yml")
}

func isOCPProfileDir(path string, info os.FileInfo) bool {
	if strings.Contains(path, "ocp4/profiles") {
		return info.IsDir()
	}
	return false
}

func isProfileFile(path string) bool {
	return strings.HasSuffix(path, ".profile")
}

func isMachineConfig(obj *unstructured.Unstructured) bool {
	objgvk := obj.GroupVersionKind()
	return "MachineConfig" == objgvk.Kind && mcfgapi.GroupName == objgvk.Group
}

func mcfgChangesFile(mcfg *mcfgv1.MachineConfig, t *testing.T) bool {
	if mcfg == nil {
		return false
	}

	files := mcfg.Spec.Config.Storage.Files
	if files == nil || len(files) == 0 {
		return false
	}

	for _, file := range files {
		if file.Mode != nil {
			return true
		}
		if file.Group != nil {
			return true
		}
		if file.User != nil {
			return true
		}
		if file.Contents.Source != "" {
			return true
		}
	}
	return false
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

func readProfileYAML(path string) (*profile, error) {
	yamlFile, err := ioutil.ReadFile(path)
	if err != nil {
		fmt.Printf("Error reading YAML file: %s\n", err)
		return nil, err
	}
	var prof profile
	err = yaml.Unmarshal(yamlFile, &prof)
	if err != nil {
		fmt.Printf("Error parsing YAML file: %s\n", err)
	}
	return &prof, err
}

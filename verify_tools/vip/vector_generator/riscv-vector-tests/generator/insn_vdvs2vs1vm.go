package generator

import (
	"fmt"
	"math"
	"strings"
)

func (i *Insn) genCodeVdVs2Vs1Vm(pos int) []string {
	float := strings.HasPrefix(i.Name, "vf") || strings.HasPrefix(i.Name, "vmf")
	sew64Only := strings.HasPrefix(i.Name, "vclmul")
	vdWidening := strings.HasPrefix(i.Name, "vw") || strings.HasPrefix(i.Name, "vfw")
	vs2Widening := strings.HasSuffix(i.Name, ".wv")
	isWideningReduction := strings.HasPrefix(i.Name, "vwred") || strings.HasPrefix(i.Name, "vfwred")
	noSew64WithoutV := strings.HasPrefix(i.Name, "vmulh") || strings.HasPrefix(i.Name, "vsmul")
	isVrgatherei16 := strings.HasPrefix(i.Name, "vrgatherei16")

	vdSize := iff(vdWidening, 2, 1)
	vs2Size := iff(vs2Widening, 2, 1)

	sews := iff(float, i.floatSEWs(), allSEWs)
	sews = iff(vdWidening || vs2Widening, sews[:len(sews)-1], sews)
	sews = iff(sew64Only, []SEW{64}, sews)
	sews = iff(noSew64WithoutV && !i.Option.HasV, []SEW{8, 16, 32}, sews)

	lmuls := iff((vdWidening || vs2Widening) && !isWideningReduction,
		wideningMULs, iff(sew64Only, []LMUL{1, 2, 4, 8}, allLMULs))

	combinations := i.combinations(
		lmuls,
		sews,
		[]bool{false, true},
		i.rms(),
	)
	res := make([]string, 0, len(combinations))
	for _, c := range combinations[pos:] {
		if isVrgatherei16 {
			vs1EMUL := 16 * c.LMUL / LMUL(c.SEW)
			if vs1EMUL < LMUL(0.125) || LMUL(8.0) < vs1EMUL  {
				res = append(res, "")
				continue
			}
		}

		builder := strings.Builder{}
		builder.WriteString(c.initialize())
		builder.WriteString(i.gWriteRandomData(LMUL(1)))
		builder.WriteString(i.gLoadDataIntoRegisterGroup(0, LMUL(1), SEW(32)))

		vdEMUL1 := LMUL(math.Max(float64(int(c.LMUL)*(iff(isWideningReduction, 1, vdSize))), 1))
		vs2EMUL1 := LMUL(math.Max(float64(int(c.LMUL)*vs2Size), 1))
		vdEEW := c.SEW * SEW(vdSize)
		vs2EEW := c.SEW * SEW(vs2Size)
		if vdEEW > SEW(i.Option.XLEN) || vs2EEW > SEW(i.Option.XLEN) {
			res = append(res, "")
			continue
		}

		// vs1 EEW/EMUL defaults align with SEW/LMUL, but vrgatherei16
		// treats vs1 as 16-bit indices regardless of SEW.
		vs1EEW := c.SEW
		vs1EMUL1 := c.LMUL1
		if isVrgatherei16 {
			vs1EEW = SEW(16)
			vs1EMUL1 = LMUL(math.Max(float64(16*int(c.LMUL))/float64(c.SEW), 1))
		}

		vd := int(vdEMUL1)

		// vrgatherei16 reads vs1 (16-bit indices) and vs2 (SEW data) at different
		// EEWs unless SEW == 16. Same register at two EEWs is a reserved encoding,
		// so when SEW != 16 we space the groups by max(EMULs) to keep them disjoint.
		// When SEW == 16, EEWs match, so we alias vs1 = vs2 to cover that case.
		var vss []int
		if isVrgatherei16 {
			if c.SEW == SEW(16) {
				vss = []int{vd * 2, vd * 2}
			} else {
				step := int(math.Max(float64(vs1EMUL1), float64(vs2EMUL1)))
				vss = []int{vd * 2, vd*2 + step}
			}
		} else {
			vss = []int{vd * 2, vd*2 + int(vs2EMUL1)}
		}

		if vdEMUL1 == vs2EMUL1 && !isVrgatherei16 {
			vd1, vs1, vs2 := getVRegs(vdEMUL1, false, i.Name)
			vd = vd1
			vss = []int{vs1, vs2}
		}

		for r := 0; r < i.Option.Repeat; r += 1 {
			builder.WriteString(i.gWriteRandomData(vdEMUL1))
			builder.WriteString(i.gLoadDataIntoRegisterGroup(vd, vdEMUL1, SEW(8)))

			builder.WriteString(i.gWriteTestData(float, !i.NoTestfloat3, r != 0, vs1EMUL1, vs1EEW, 0, 2))
			builder.WriteString(i.gLoadDataIntoRegisterGroup(vss[0], vs1EMUL1, vs1EEW))

			builder.WriteString(i.gWriteTestData(float, !i.NoTestfloat3, r != 0, vs2EMUL1, vs2EEW, 1, 2))
			builder.WriteString(i.gLoadDataIntoRegisterGroup(vss[1], vs2EMUL1, vs2EEW))

			builder.WriteString("# -------------- TEST BEGIN --------------\n")
			builder.WriteString(i.gVsetvli(c.Vl, c.SEW, c.LMUL))
			builder.WriteString(fmt.Sprintf("%s v%d, v%d, v%d%s\n",
				i.Name, vd, vss[1], vss[0], v0t(c.Mask)))
			builder.WriteString("# -------------- TEST END   --------------\n")

			builder.WriteString(i.gResultDataAddr())
			builder.WriteString(i.gStoreRegisterGroupIntoResultData(vd, vdEMUL1, vdEEW))
			builder.WriteString(i.gMagicInsn(vd, vdEMUL1))
		}

		res = append(res, builder.String())
	}
	return res
}

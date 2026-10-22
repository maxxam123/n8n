package models

type OrgUnit struct {
	ID   string `yaml:"id"`
	Name string `yaml:"name"`
}

type AWSAccount struct {
	Key      string `yaml:"key"`
	Name     string `yaml:"name"`
	Email    string `yaml:"email"`
	RoleName string `yaml:"roleName"`
	OuKey    string `yaml:"ouKey"`
}

type SCPStatement struct {
	Sid       string                           `yaml:"sid"`
	Effect    string                           `yaml:"effect"`
	Action    []string                         `yaml:"action,omitempty"`
	NotAction []string                         `yaml:"notAction,omitempty"`
	Resource  string                           `yaml:"resource"`
	Condition map[string]map[string][]string   `yaml:"condition,omitempty"`
}

type SCPolicy struct {
	Name        string       `yaml:"name"`
	Description string       `yaml:"description"`
	OuTarget    string       `yaml:"ouTarget"`
	Statement   SCPStatement `yaml:"statement"`
}

type ManagedRule struct {
	Name       string `yaml:"name"`
	Priority   int    `yaml:"priority"`
	VendorName string `yaml:"vendorName"`
}

type Notification struct {
	ComparisonOperator       string   `yaml:"comparisonOperator"`
	Threshold                int      `yaml:"threshold"`
	ThresholdType            string   `yaml:"thresholdType"`
	NotificationType         string   `yaml:"notificationType"`
	SubscriberEmailAddresses []string `yaml:"subscriberEmailAddresses"`
}

type BudgetConfig struct {
	Name          string                  `yaml:"name"`
	LimitAmount   string                  `yaml:"limitAmount"`
	Notifications map[string]Notification `yaml:"notifications"`
}

type IdentityGroup struct {
	DisplayName string `yaml:"displayName"`
	Description string `yaml:"description"`
}

type AccountAssignment struct {
	GroupKey       string   `yaml:"groupKey"`
	AccountId      string   `yaml:"accountId"`
	PermissionSets []string `yaml:"permissionSets"`
}

type UserDefinition struct {
	UserName   string `yaml:"userName"`
	GivenName  string `yaml:"givenName"`
	FamilyName string `yaml:"familyName"`
	Email      string `yaml:"email"`
}

type PermissionSet struct {
	Description     string   `yaml:"description"`
	SessionDuration string   `yaml:"sessionDuration"`
	ManagedPolicies []string `yaml:"managedPolicies"`
	InlinePolicy    string   `yaml:"inlinePolicy"`
}

type Membership struct {
	GroupName string   `yaml:"groupName"`
	UserKeys  []string `yaml:"userKeys"`
}

type ConfigValues struct {
	Environment         string       `yaml:"environment"`
	Region              string       `yaml:"region"`
	Repo                string       `yaml:"repo"`
	RoleName            string       `yaml:"roleName"`
	ExpRole             string       `yaml:"expRole"`
	Org                 string       `yaml:"org"`
	RepoDev             string       `yaml:"repoDev"`
	RepoLive            string       `yaml:"repoLive"`
	Env                 string       `yaml:"env"`
	Threshold           string       `yaml:"threshold"`
	PathWaf             string       `yaml:"pathWaf"`
	PathAlb             string       `yaml:"pathAlb"`
	Groups              []string     `yaml:"groups"`
	Memberships         []Membership `yaml:"memberships"`
	PermissionSets      map[string]PermissionSet `yaml:"permissionSets"`
	Users               map[string]UserDefinition `yaml:"users"`
	GroupAccountAssignments []AccountAssignment   `yaml:"groupAccountAssignments"`
	IdentityGroups      map[string]IdentityGroup `yaml:"identityGroups"`
	Budget              BudgetConfig `yaml:"budget"`
	OrganizationalUnits []OrgUnit    `yaml:"organizationalUnits"`
	AwsAccounts         []AWSAccount `yaml:"awsAccounts"`
	AwsServiceAccessPrincipals []string     `yaml:"awsServiceAccessPrincipals"`
	DelegatedAdministrators    []string     `yaml:"delegatedAdministrators"`
	ServiceControlPolicies map[string]SCPolicy `yaml:"serviceControlPolicies"`
	ManagedRules        []ManagedRule `yaml:"managedRules"`
}
